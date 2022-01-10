import UIKit

/**
 Сервис для работы с сервером сообщений.
 При получении истории сообщений, nil или поврежденные сообщения исключаются из списка.
 
 - author: Q-ITS
 */
class ChatService {
    
    /**
     Транспорт для HTTP запросов:
     Логин, получение истории сообщений, получение активности, отправка сообщения для получения активности.
     */
    private let omniChatHttpTransport: OmniChatHttpTransport
    
    /**
     Транспорт для работы с сокетами. В любой момент может быть отключен от сервера.
     Необходимо переподключиться отправив сообщение через HTTP.
     Создается на основании токена и активности полученных через HTTP транспорт.
     */
    private var omniChatSocketTransport: OmniChatSocketTransport?
    
    /**
     Транспорт для работы с вложениями
     */
    public let attachmentChatTransport: AttachmentChatTransport
    
    /**
     Настройки чата
     */
    public var chatSettings: ChatServiceSettings
    
    /**
     Класс для работы с историей чата
     */
    public let chatMessageHistory: ChatMessageHistory
    
    /**
     Источник данных для чата
     */
    public let chatDataSource: ChatDataSource
    
    /**
     Таймер по окончанию которого происходит отключение от сокета.
     */
    private var disconnectTimer: DefaultLifecycleTimer?
    
    /**
     Протокол взаимодействия с UI
     */
    private weak var delegate: ChatServiceDelegate?
    
    /**
     Cлушатель состояния сессии-соединения для взаимодействия с чатом
     */
    private weak var sessionConnectionDelegate: SessionConnectionStatusListener?
    
    /**
     Информация о последней загруженной странице истории.
     */
    private var pageInfo: HistoryPage?
    
    /**
     Идентификатор загрузки истории. Для предотвращения отправки нескольких запросов подряд.
     При начале загрузки истории флаг переводится в true, по окончанию загрузки возвращается в false.
     */
    private var loadingHistory = false
    
    /**
     Счетчик переподключения к сокету
     */
    private let recconectCounter: OmniChatSocketReconnectCounter
    
    init(chatSettings: ChatServiceSettings) {
        self.chatSettings = chatSettings
        self.recconectCounter = OmniChatSocketReconnectCounter(reconnectLimit: chatSettings.reconnectLimit)
        self.omniChatHttpTransport = OmniChatHttpTransport(omniToken: chatSettings.omniToken.token,
                                                           omniUrl: chatSettings.chatSettings.httpServerEndpointUrl,
                                                           authentificateOmniUrl: chatSettings.chatSettings.authenticationEndpointUrl,
                                                           intervalTimeout: 5)
        self.attachmentChatTransport = AttachmentChatTransport(chatSettings.chatSettings)
        self.chatMessageHistory = ChatMessageHistory(operatorTypingTimeInterval: 10)
        self.chatDataSource = ChatDataSource(chatMessageHistory)
        
        self.attachmentChatTransport.delegate = self
        self.omniChatHttpTransport.loadedJwtToken = { [weak self] token in
            self?.chatSettings.addJwtToken(token)
        }
        self.chatMessageHistory.messagesUpdated = { [weak self] in
            self?.delegate?.needUpdateUI(true)
        }
    }
    
    public func addDelegate(delegate: ChatServiceDelegate,
                            sessionConnectionDelegate: SessionConnectionStatusListener) {
        self.delegate = delegate
        self.sessionConnectionDelegate = sessionConnectionDelegate
    }
    
    /**
     Авторизация пользователя и запрос истории сообщений.
     
     1. Получение JWT токена для HTTP авторизации и загрузки истории сообщений.
     2. Попытка подключения к сокету при наличии Activity или ActivityId
     
     - throws: Ошибка HTTP авторизации или загрузки истории сообщений.
     */
    func authenticate() throws {
        if chatSettings.jwtToken == nil {
            do {
                onConnectionStateChanged(.connecting)
                try omniChatHttpTransport.authorize()
                onConnectionStateChanged(.authenticated)
                try loadMessagesHistory(offsetMessageId: nil)
            }
            catch {
                onConnectionStateChanged(.disconnected)
                throw error
            }
        }
        
        // Проверяем возможность установления Socket соединения
        if let token = chatSettings.jwtToken, omniChatSocketTransport?.isConnected() != true {
            // При наличии данных для активности, можно выполнить автоматическое подключение к сокету, без отправки первого сообщения пользователем.
            if let activity = chatSettings.activityManager.getActivity(), activity.isActive() {
                if self.omniChatSocketTransport == nil {
                    let omniChatSocketTransport = OmniChatSocketTransport.create(token: token,
                                                                                 activity: activity,
                                                                                 url: chatSettings.chatSettings.webSocketServerEndpointUrl,
                                                                                 delegate: self)
                    self.omniChatSocketTransport = omniChatSocketTransport
                }
                else {
                    self.omniChatSocketTransport?.reconnect(activity: activity)
                }
            }
            else if let activityId = getActivityId() {
                // Наличие activityId позволяет получить Activity и подключиться к сокету, если активность живая
                reconnectToSocket(activityId: activityId)
            }
            else {
                // на данный момент невозможно подключиться к сокету, т.к. нет активности, но токен для HTTP соединения был получен успешно.
            }
        }
        else if omniChatSocketTransport?.isConnected() == true {
            onConnectionStateChanged(.authenticated)
        }
    }

    /**
     Отправляет запрос на загрузку истории сообщений.
     1. При первой загрузке будет загружена история с первого сообщения.
     2. При повторной загрузке будет выполнена подгрузка истории
     3. При повторной загрузке и отсутствии новых страниц для загрузки метод ничего не выполнит.
     
     После загрузки истории, делегат будет уведомлен о необходимости обновить UI.
     */
    public func loadMessagesHistory() throws {
        try authenticate()
        
        if !loadingHistory {
            let cursor = pageInfo?.cursor
            if cursor != nil, pageInfo?.hasNextPage == false {
                // Была загружена последняя страница истории сообщений
                delegate?.loadedHistoryLastPage()
                return
            }
            else {
                // Будет выполнена загрузка истории с начала (при cursor = nil) или подгружена новая (при cursor != nil)
                try loadMessagesHistory(offsetMessageId: cursor)
            }
        }
    }
    
    public func forceUpdateMessagesHistory() throws {
        do {
            self.loadingHistory = true
            if let historyMessages = try omniChatHttpTransport.loadMessagesFeed() {
                chatMessageHistory.addMessagesHistory(historyMessages.messages)
                pageInfo = historyMessages.pageInfo
                delegate?.needUpdateUI(false)
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.loadingHistory = false
                }
            }
        }
        catch {
            self.loadingHistory = false
            throw error
        }
    }
    
    private func loadMessagesHistory(offsetMessageId: String?) throws {
        do {
            self.loadingHistory = true
            if let historyMessages = try omniChatHttpTransport.loadMessagesFeed(offsetMessageId: offsetMessageId) {
                chatMessageHistory.addMessagesHistory(historyMessages.messages)
                pageInfo = historyMessages.pageInfo
                // При offsetMessageId мы выполняем первую загрузку списка сообщений и поэтому скролим в конец списка
                delegate?.needUpdateUI(offsetMessageId == nil)
                
                // TODO: Найти вариант замены таймера. Сейчас он необходим, т.к. обновление списка асинхронно и после обновления сразу подгружается еще история
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.loadingHistory = false
                }
            }
        }
        catch {
            self.loadingHistory = false
            throw error
        }
    }
    
    /**
     Загрузка списка сообщений.
     
     - returns: Список сообщений.
     */
    public func getLoadedMessages() -> [ChatMessage] {
        return chatMessageHistory.getLoadedMessages()
    }
    
    private func getActivityId() -> String? {
        return chatSettings.activityManager.getActivityId(getLoadedMessages())
    }
    
    /**
     Отправка текста сообщения на сервер.
     Ситуации для для отправки сообщения через http транспорт:
     - Первое сообщение, для возможности открыть сокет.
     - Сокет или активность были закрыты. Для переоткрытия сокета необходимо отправить сообщение через http.
     
     - parameters:
     - message: Текст пользовательского сообщения для отправки.
     - throws: Ошибка отправки первого сообщения или создания транспорта для сокетов.
     */
    public func sendMessage(_ message: String, messageId: String? = nil) {
        // Сохраняем отправленное сообщение для отображения на UI. После получения ответа сервера оно будет заменено серверным сообщением.
        var receivedMessage: ClientChatMessage = ClientChatMessage(text: message,
                                                                   activityId: getActivityId(),
                                                                   messageId: messageId)

        saveSendingMessage(message: receivedMessage)
        
        DispatchQueue.global().async {
            do {
                try self.authenticate()
                if (self.omniChatSocketTransport?.isConnected() == true) {
                    receivedMessage = try self.sendMessageSocket(receivedMessage)
                    // Ответ на сообщение приходит асинхронно, поэтому сохраняем сообщение как отправляемое для дальнейшего мержинга.
                    self.chatMessageHistory.addNewMessage(receivedMessage)
                    self.delegate?.updatedMessages([receivedMessage])
                }
                else {
                    receivedMessage = try self.sendFirstMessage(receivedMessage) ?? receivedMessage
                    // Сообщения по HTTP сразу получают ответ, поэтому сохраняются как обработанные сообщения.
                    self.chatMessageHistory.addNewMessage(receivedMessage)
                    self.delegate?.updatedMessages([receivedMessage])
                }
            } catch {
                self.updatedConnectionStatus(.disconnected)
                // При ошибке отправки сообщения, сохраняем сообщение со статусом не доставлено, для возможности переотправки его.
                receivedMessage.messageStatus = .UNDELIVERED
                self.chatMessageHistory.addNewMessage(receivedMessage)
                self.delegate?.needUpdateUI(true)
                self.delegate?.receivedError(error)
            }
        }
    }
    
    public func sendAttachment(_ item: AttachmentChatItem) {
        DispatchQueue.global().async {
            let errorHandler: ((Error?) -> Void) = { [weak self] error in
                if let error = error {
                    self?.delegate?.receivedError(error)
                }
            }
            
            if let activityId = self.chatSettings.activityManager.getActivity()?.id, let jwtToken = self.chatSettings.jwtToken {
                do {
                    let sendingMessage = try self.attachmentChatTransport.upload(item,
                                                                                 activityId: activityId,
                                                                                 jwtToken: jwtToken,
                                                                                 completionHandler: errorHandler)
                    self.saveSendingMessage(message: sendingMessage)
                    if self.omniChatSocketTransport?.isConnected() != true {
                        sendingMessage.messageStatus = .UNDELIVERED
                        self.chatMessageHistory.addNewMessage(sendingMessage)
                        self.delegate?.needUpdateUI(true)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
    
    private func saveSendingMessage(message: ChatMessage) {
        chatMessageHistory.addSendingMessage(message)
        self.delegate?.receivedNewMessage(message)
    }
    
    public func isReadMessagesEvent(_ messages: [ChatMessage]) {
        omniChatSocketTransport?.sendIsReadMessagesEvent(messages)
    }
    
    public func sendClientTypingEvent() {
        omniChatSocketTransport?.sendClientTypingEvent()
    }
    
    /**
     Переподключение к сокету с идентификатором новой активности.
     
     Применяется при:
     - Ошибке от сервера
     - Переводе на другого оператора.
     - Первичной авторизации
     - Переподключение к сокету по новому идентификатору активности.
     
     Если при запросе активности получена ошибка, новая активность будет сохранена для последующих запросов.
     Если получена активность, но она не активна (умерла) - удаляется идентификатор данной активности.
     
     - parameters:
     - activityId: Идентификатор активности с которой необходимо подключиться к сокету.
     */
    public func reconnectToSocket(activityId: String) {
        do {
            guard let activity = try self.omniChatHttpTransport.getActivity(id: activityId) else {
                self.saveNeedUpdateActivity(activityId)
                return
            }
            guard activity.isActive() else {
                self.chatSettings.activityManager.removeActivity()
                return
            }
            if self.recconectCounter.isAvailable(activityId) {
                // добавляем в счетчик попытку переподключения, сброс выполнится в методе self.updatedConnectionStatus()
                self.recconectCounter.add(activityId)
                self.chatSettings.activityManager.updateActivity(activity)
                self.omniChatSocketTransport?.reconnect(activity: activity)
                self.sessionConnectionDelegate?.didReconnect()
            }
            else {
                // Исчерпаны попытки для авторизации
                self.recconectCounter.clear()
                self.saveNeedUpdateActivity(activityId)
            }
        }
        catch {
            self.saveNeedUpdateActivity(activityId)
            self.delegate?.receivedError(error)
        }
    }
    
    fileprivate func sendFirstMessage(_ message: ClientChatMessage) throws -> ClientChatMessage? {
        if let activityId = getActivityId() {
            let activity = try omniChatHttpTransport.getActivity(id: activityId)
            chatSettings.activityManager.updateActivity(activity)
        }
        
        if let activity = chatSettings.activityManager.getActivity(), activity.isActive() == true,
            let acessToken = chatSettings.jwtToken {
            let omniChatSocketTransport = OmniChatSocketTransport.create(token: acessToken,
                                                                         activity: activity,
                                                                         url: chatSettings.chatSettings.webSocketServerEndpointUrl,
                                                                         delegate: self)
            self.omniChatSocketTransport = omniChatSocketTransport
            
            // Открываем сокет и через него шлем сообщение
            return try sendMessageSocket(message)
        }
        else {
            // Отправляем сообщение через HTTP и открываем сокет
            return try sendMessageHttp(message)
        }
    }
    
    fileprivate func sendMessageHttp(_ message: ClientChatMessage) throws -> ClientChatMessage {
        guard let activityByFirstMessage = try omniChatHttpTransport.getActivityByFirstMessage(message: message.text ?? "") else {
            throw OmniChatTransportError("Данные для создания активности не были получены при отправке запроса getActivityByFirstMessage")
        }
        
        // Сохраняем данные активности после отправки первого сообщения и выполняем подключение к сокету.
        if let activity = activityByFirstMessage.activity {
            chatSettings.activityManager.updateActivity(activity)
            try authenticate()
        }
        
        // Сохраняем полученное сообщение
        if let receivedMessage = activityByFirstMessage.message as? ClientChatMessage {
            // Добавляем сообщение "Поиск доступного оператора" после успешной отправки первого сообщения
            chatMessageHistory.addOperatorStatus(.found_not_operator)
            
            receivedMessage.clientMessageId = message.clientMessageId
            receivedMessage.temporaryId = message.temporaryId
            return receivedMessage
        }
        else {
            throw OmniChatTransportError("Сервер не вернул сообщение")
        }
    }
    
    fileprivate func sendMessageSocket(_ message: ClientChatMessage) throws -> ClientChatMessage {
        if chatSettings.activityManager.getActivity() == nil {
            return try sendMessageHttp(message)
        }
        else if let omniChatSocketTransport = omniChatSocketTransport {
            return omniChatSocketTransport.sendMessage(message)
        }
        else {
            throw OmniChatTransportError("Сообщение не было отправлено")
        }
    }
    
    /**
     Обновление активности, если идентификатор переданной активности отличается от текущей
     Если во время обновления активности произойдет ошибка, у делегата будет вызван метод receivedError.
     Обновление активности включает переподключение к сокету, для возможности получать обновления в новой активности.
     
     - parameters:
     - activityId: Идентификатор новой активности, может совпадать с текущей активностью.
     */
    fileprivate func updateActivityIfNeeded(_ activityId: String?) {
        DispatchQueue.global().async {
            guard let activityId = activityId, activityId != self.getActivityId() else {
                return
            }
            
            self.reconnectToSocket(activityId: activityId)
        }
    }
    
    /**
     Сохранение идентификатора новой активности и отключение от сокета.
     */
    fileprivate func saveNeedUpdateActivity(_ activityId: String) {
        chatSettings.activityManager.saveNewActivityId(activityId)
        omniChatSocketTransport?.disconnect()
    }
    
    public func onConnectionStateChanged(_ status: SessionConnectionStatus) {
        self.sessionConnectionDelegate?.onConnectionStateChanged(status)
    }
    
    public func startSocketDisconnectTimer() {
        disconnectTimer = DefaultLifecycleTimer(timeInterval: TimeInterval(chatSettings.chatSettings.sessionTimeout),
                                                handler: { [weak self] in
            self?.omniChatSocketTransport?.disconnect()
        })
        disconnectTimer?.start()
    }
    
    public func stopSocketDisconnectTimer() {
        disconnectTimer?.stop()
        disconnectTimer = nil
    }
    
    public func didSelect(_ indexPath: IndexPath) {
        guard let message = chatDataSource.getMessage(indexPath: indexPath) as? ClientChatMessage else {
            return
        }
        if message.messageStatus == .UNDELIVERED {
            do {
                try resendMessage(message)
            }
            catch {
                ChatErrorHandler.handleError(error)
            }
        }
    }
}

extension ChatService: OmniChatSocketTransportDelegate, AttachmentChatTransportDelegate {
    
    func updatedConnectionStatus(_ status: SessionConnectionStatus) {
        onConnectionStateChanged(status)
        if status.isConnected() {
            recconectCounter.clear()
        }
    }
    
    func successSendMessage(_ message: ClientChatMessage) {
        chatMessageHistory.addNewMessage(message)
        delegate?.updatedMessages([message])
        
        updateActivityIfNeeded(message.activityId)
    }
    
    func receivedNewMessage(_ message: ChatMessage) {
        if chatMessageHistory.isIncludeMessage(message) {
            chatMessageHistory.addNewMessage(message)
            delegate?.updatedMessages([message])
        }
            
        else {
            chatMessageHistory.addNewMessage(message)
            delegate?.receivedNewMessage(message)
        }
        updateActivityIfNeeded(message.activityId)
    }
    
    func errorSendMessage(clientMessageId: String) {
        if let updatedMessage = chatMessageHistory.updateSendingMessageStatus(.UNDELIVERED, clientId: clientMessageId) {
            delegate?.updatedMessages([updatedMessage])
            delegate?.needUpdateUI(true)
        }
    }
    
    func isReadMessage(_ messageIds: [Int]) {
        var updatedMessages = [ChatMessage]()
        for messageId in messageIds {
            if let message = chatMessageHistory.updateMessageStatus("\(messageId)", status: MessageStatusEnum.create(isRead: true)) {
                updatedMessages.append(message)
            }
        }
        delegate?.updatedMessages(updatedMessages)
    }
    
    /* QRMB-7048
     iOS. Чат: убрать системное сообщение "оператор печатает..."*/
    func operatorTyping(_ typing: Bool) {
        //chatSettings.updateTypingMessage(typing)
        //delegate?.needUpdateUI(false)
    }
    
    func transferedOperator(newActiviyID: String) {
        DispatchQueue.global().async {
            self.reconnectToSocket(activityId: newActiviyID)
            self.delegate?.needUpdateUI(false)
        }
    }
    
    func isFoundOperator(_ found: Bool) {
        chatMessageHistory.addOperatorStatus(.found_operator)
        delegate?.needUpdateUI(false)
    }
    
    func isLeaveOperator() {
        chatMessageHistory.addOperatorStatus(.leave)
    }
    
    func error(_ error: OmniChatTransportError) {
        ChatErrorHandler.handleError(error)
    }
    
    func resendMessage(_ resendMessage: ClientChatMessage) throws  {
        chatMessageHistory.removeResendMessage(resendMessage)
        if let text = resendMessage.text {
            self.sendMessage(text, messageId: resendMessage.clientMessageId)
        }
    }
    
    func activityClosed() {
        chatSettings.activityManager.removeActivity()
    }
    
    func socketClosed() {
        // Do nothing
    }
}
