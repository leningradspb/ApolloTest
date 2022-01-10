import Foundation

/**
 Класс для хранения и обработки истории сообщений.
 
 Реализует:
 - Сортировку сообщений для вывода на UI
 - Мержинг загруженной истории
 - Мержинг отправленного сообщения и полученного ответа
 
 - author: Q-ITS
 */
public class ChatMessageHistory {
    
    /**
     Список статусов оператора для данной сессии.
     С сервера приходит событие об изменении статуса оператора, на клиенте храним их в виде сообщений
     */
    private var operatorStatusMessages = [OperatorStatusChatMessage]()
    
    /**
     Список сообщений, полученных в запросе истории сообщений
     */
    private var historyMessages = [ChatMessage]()
    
    /**
     Список отправляемых сообщений пользователем.
     После получения ответа на них, они переносятся из этого списка в список истории сообщений
     */
    private var sendingMessages = [ChatMessage]()
    
    /**
     Список сообщений, ввода текста оператором.
     Включает только 1 элемент если оператор вводит сообщение.
     Сделано в виде списка для единообразия с остальными списками сообщений
     */
    private var typingMessages = [TypingChatMessage]()
    
    /**
     Время отображения события оператор печатает
     */
    private let operatorTypingTimeInterval: TimeInterval
    
    /**
     Closure для уведомления об обновлении списка сообщений. Например сообщение удалилось по таймеру.
     */
    public var messagesUpdated: (() -> Void)?
    
    /**
     - parameters:
        - Время отображения события оператор печатает
     */
    public init(operatorTypingTimeInterval: TimeInterval) {
        self.operatorTypingTimeInterval = operatorTypingTimeInterval
    }
    
    /**
     Сортированный список всех сообщений и событий для отображения на UI.
     Список сортируется по дате создания сообщения на сервере или по дате получения event.
     Включает: операторские, клиентские, информационные сообщения, статусы оператора в виде сообщений
     
     - returns: Список всех сообщений для отображения на UI.
     */
    public func getLoadedMessages() -> [ChatMessage] {
        var result: [ChatMessage] = [ChatMessage]()
        
        result.append(contentsOf: operatorStatusMessages.filter({$0.operatorStatus == .found_not_operator}) )
        result.append(contentsOf: historyMessages)
        result.append(contentsOf: sendingMessages)
        result.append(contentsOf: typingMessages)
        return result.sorted(by: { $0.timestamp < $1.timestamp})
    }
    
    public func isIncludeMessage(_ message: ChatMessage) -> Bool {
        return getLoadedMessages().first(where: {
            ChatMessageMergingComparator.compare($0, message) && $0.activityId == message.activityId
        }) != nil
    }
    
    public func getMessage(_ id: Int) -> ChatMessage? {
        return getLoadedMessages().first(where: { $0.id == String(id) })
    }
    
    public func getMessages(_ ids: [Int]) -> [ChatMessage]? {
        return getLoadedMessages().filter({ message in
            ids.first{ message.id == String($0) } != nil
        })
    }
    
    /**
     Мержит полученную историю сообщений в текущий список уже полученной истории.
     Полученные сообщения добавляются в начало списка, т.к. считаются более старыми.
     При отображении список будет отсортирован
     
     - parameters:
        - messages: Список сообщений для добавления с общий список истории сообщений.
     */
    public func addMessagesHistory(_ messages: [ChatMessage?]) {
        for message in messages {
            if let message = message {
                // Для исключения дублирования сообщений
                if !historyMessages.contains(where: { $0.id == message.id }) {
                    historyMessages.insert(message, at: 0)
                }
            }
        }
    }
    
    /**
     Добавление в список отправляемого сообщения клиентом.
     После получения ответа, сообщение будет перенесено в историю сообщений.
     
     - parameters:
        - message: Отправляемое сообщение, созданное на клиенте.
     */
    public func addSendingMessage(_ message: ChatMessage) {
        removeSendingMessage(message)
        sendingMessages.append(message)
    }
    
    /**
     Добавление в список загруженных сообщений нового сообщения.
     Мержинг с существующими сообщения осуществляется для:
     - Отправленных сообщений, если идентификатор нового сообщения уже есть в списке отправляемых сообщений.
     - Новых сообщений, если идентификатор сообщения уже есть в истории сообщений и они получены в рамках одной активности.
     
     - parameters:
        - message: Новое сообщение
     */
    public func addNewMessage(_ message: ChatMessage) {
        removeSendingMessage(message)
        var historyMessages = self.historyMessages
        if let messageIndex = historyMessages.firstIndex(where: { ChatMessageMergingComparator.compare($0, message) && $0.activityId == message.activityId }) {
            historyMessages[messageIndex] = message
        }
        else {
            historyMessages.append(message)
        }
        self.historyMessages = historyMessages
    }
    
    /**
     Обновление статуса отправляемого сообщения, если оно будет найдено в списке отправляемых сообщений
     
     - parameters:
        - status: Новый статус сообщения (обычно недоставлено)
        - clientId: клиентский идентификатор сообщения
     */
    public func updateSendingMessageStatus(_ status: MessageStatusEnum, clientId: String) -> ChatMessage? {
        if let index = sendingMessages.firstIndex(where: {( $0 as? ClientChatMessage)?.clientMessageId == clientId }) {
            let message = sendingMessages[index]
            message.messageStatus = status
            sendingMessages[index] = message
            return message
        }
        else {
            return nil
        }
    }
    
    /**
     Удаление отправляемого сообщения из списка отправляемых сообщений
     
     - parameters:
        - message: Сообщения для удаления из общего списка
     */
    public func removeSendingMessage(_ message: ChatMessage) {
        while let messageIndex = sendingMessages.firstIndex(where: { ChatMessageMergingComparator.compare($0, message) }) {
            sendingMessages.remove(at: messageIndex)
        }
    }
    
    public func removeResendMessage(_ message: ChatMessage) {
        removeSendingMessage(message)
        while let messageIndex = historyMessages.firstIndex(where: { ChatMessageMergingComparator.compare($0, message) }) {
            historyMessages.remove(at: messageIndex)
        }
    }
    
    /**
     Сохранение статуса оператора.
     При добавлении статуса оператор найден, статус поиск оператора удаляется из истории.
     
     - parameters:
        - status: Статус оператора
        - date: Дата получения статуса клиентом, может остутствовать, тогда используется момент вызова этого метода.
     */
    public func addOperatorStatus(_ status: OperatorStatus, _ date: Date = Date()) {
        let message = OperatorStatusChatMessage(status: status)
        operatorStatusMessages.append(message)
    }
    
    /**
     Обновление данных о печати оператором.
     Сообщение автоматически удаляется по таймеру или входному событию.
     */
    public func updateTypingMessage(_ typing: Bool) {
        if typing {
            typingMessages = []
            let message = TypingChatMessage(text: ChatLocalization.getOperatorTypingText(),
                                            timestamp: Date(),
                                            messageStatus: .DELIVERED)
            typingMessages.append(message)
            
            let timer = DefaultLifecycleTimer(timeInterval: operatorTypingTimeInterval) { [weak self] in
                if self?.typingMessages.count ?? 0 > 0 {
                    self?.typingMessages = []
                    if let messagesUpdated = self?.messagesUpdated {
                        messagesUpdated()
                    }
                }
            }
            timer.start()
        }
        else {
            typingMessages = []
            if let messagesUpdated = messagesUpdated {
                messagesUpdated()
            }
        }
    }
    
    public func updateMessageStatus(_ messageId: String, status: MessageStatusEnum) -> ChatMessage? {
        if let message = historyMessages.first(where: { $0.id == messageId }) {
            message.messageStatus = status
            return message
        }
        if let message = sendingMessages.first(where: { $0.id == messageId }) {
            message.messageStatus = status
            return message
        }
        return nil
    }
}
