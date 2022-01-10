import Foundation

class OmniChatSocketTransport {
    
    fileprivate(set) var acessToken: String!
    
    private var activity: Activity!
    
    private var url: String!
    
    private var socket: Socket!
    
    private var channel: Channel!
    
    fileprivate weak var delegate: OmniChatSocketTransportDelegate?
    
    /**
     Список отправляемых сообщений пользователем.
     На каждом сообщении висит таймер, если ответ от сервера не придет до окончания данного таймера, сообщение считается не доставленым.
     При получении ответа сервера, сравнивается ключ sendingMessages с messageId (refId) ответа, для мержинга клиентского сообщения и полученного.
     */
    private var sendingMessages: [String : String?] = [:]
    
    /**
     Таймер с последнего события начало печати пользователя.
     Таймер запускается после отправки события MessageEventType.is_typing.
     Все события ввода текста клиентом, поступающие во время работы таймера игнорируются.
     */
    private var clientTypingEventTimer: DefaultLifecycleTimer?
    
    /**
     Временной интервал отправки события набора текста пользователем.
     */
    private let clientTypingTimeImterval: TimeInterval = 2
    
    /**
     Создание транспорта для работы с socket чата.
     
     - parameters:
        - token: Токен для подключения к сокету
        - activity: Данные об активности для подключения к каналу
        - url: URL адрес в виде строки для подключения к сокету
        - delegate: Делегат обработки событий в сокетах.
     */
    static func create(token: String,
                       activity: Activity,
                       url: String,
                       delegate: OmniChatSocketTransportDelegate) -> OmniChatSocketTransport {
        let transport = OmniChatSocketTransport()
        
        let url = "\(url)websocket"
        transport.socket = transport.createSocket(url:url, token: token)
        transport.channel = transport.createChanel(token: token, activity: activity)
        transport.url = url
        transport.activity = activity
        transport.acessToken = token
        transport.delegate = delegate
        
        return transport
    }
    
    public func reconnect(activity: Activity) {
        leaveChannel()
        disconnect()

        socket = createSocket(url: url, token: acessToken)
        channel = createChanel(token: acessToken, activity: activity)
    }
    
    public func isConnected() -> Bool {
        return socket.isConnected
    }
    
    private func createSocket(url: String, token: String) -> Socket {
        let socket = Socket(url: url, params: ["guardian_token": "\(token)", "vsn": "2.0.0"])
        socket.heartbeatIntervalMs = 30000
        
        socket.onOpen { [weak self] in
            self?.delegate?.updatedConnectionStatus(.joined)
            ChatErrorHandler.handleInfo("\(Date()). Socket onOpen")
        }
        
        socket.onClose { [weak self] in
            self?.delegate?.updatedConnectionStatus(.disconnected)
            ChatErrorHandler.handleInfo("\(Date()). Socket onClose")
        }
        
        socket.onError { [weak self] error in
            DispatchQueue.global().async {
                // При получении ошибки в сокет необходимо переподключиться к сокету с той же активностью.
                self?.delegate?.updatedConnectionStatus(.disconnected)
                if let activityId = self?.activity.id {
                    self?.delegate?.reconnectToSocket(activityId: activityId)
                }
                ChatErrorHandler.handleInfo("\(Date()). Socket onError, error = '\(error.localizedDescription)'")
            }
        }
        
        socket.connect()
        
        return socket
    }
    
    private func createChanel(token: String, activity: Activity) -> Channel {
        let channel = socket.channel("room:\(activity.id)")
        _ = channel.join(joinParams: ["guardian_token": "\(token)"], timeout: nil)
        subscribe(channel: channel)
        
        return channel
    }
    
    private func subscribe(channel: Channel) {
        channel.on(MessageEventType.found_operator.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                if let payload = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .found_operator) as? IsFoundOperatorPayload{
                    self?.delegate?.isFoundOperator(payload.value)
                }
            }
        }
        
        channel.on(MessageEventType.info.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                self?.delegate?.isLeaveOperator()
            }
        }
        
        channel.on(MessageEventType.is_read.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                if let payload = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .is_read) as? IsReadPayload {
                    self?.delegate?.isReadMessage(payload.ids)
                }
            }
        }
        
        channel.on(MessageEventType.is_typing.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                if let payload = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .is_typing) as? IsTypingPayload {
                    self?.delegate?.operatorTyping(payload.value)
                }
            }
        }
        
        channel.on(MessageEventType.left.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                self?.delegate?.activityClosed()
                self?.leaveChannel()
                self?.disconnect()
            }
        }
        
        channel.on(MessageEventType.new_msg.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                if let payload = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .new_msg) as? NewMessagePayload {
                    self?.delegate?.receivedNewMessage(payload.message)
                }
            }
        }
        
        channel.on(MessageEventType.phx_close.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                self?.disconnect()
            }
        }
        
        channel.on(MessageEventType.phx_error.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                self?.disconnect()
                
                if let activityId = self?.activity.id {
                    self?.delegate?.reconnectToSocket(activityId: activityId)
                }
            }
        }

        channel.on(MessageEventType.phx_reply.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                self?.phxReplyHandler(sendedMessage, receiveMessage)
            }
        }
        
        channel.on(MessageEventType.presence_diff.rawValue) { (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                // TODO: Определить как обрабатывать данное событие
                _ = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .presence_diff) as? PresenceDiffPayload
            }
        }
        
        channel.on(MessageEventType.presence_state.rawValue) { (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                // TODO: Определить как обрабатывать данное событие
                _ = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .presence_state) as? PresenceStatePayload
            }
        }
        
        channel.on(MessageEventType.transfered.rawValue) { [weak self] (sendedMessage, receiveMessage) in
            DispatchQueue.global().async {
                if let payload = PayloadConverter.decode(payload: receiveMessage.payload, eventType: .transfered) as? TransferedOperatorPayload {
                    self?.delegate?.transferedOperator(newActiviyID: payload.value)
                }
            }
        }
    }
    
    private func phxReplyHandler(_ sendedMessage: Message?, _ receivedMessage: Message) {
        guard let replyPayload = ReplyPayload(receivedMessage.payload, sendedMessage: sendedMessage) else {
            self.delegate?.error(OmniChatTransportError("""
                Ошибка десериализации event = '\(receivedMessage.event)'.
                ReceivedMessage = '\(receivedMessage)'
                SendedMessage = '\(String(describing: sendedMessage))'
                """))
            return
        }
        
        if let error = replyPayload.error {
            self.delegate?.error(OmniChatTransportError("\(error)"))
        }
        else if let responsePayload = replyPayload.payload {
            if let newMessagePayload = responsePayload as? NewMessagePayload {
                phxReplyNewMessage(sendedMessage, receivedMessage, newMessagePayload)
            }
            else {
                self.delegate?.error(OmniChatTransportError("replyPayload.payload is unexpected type: '\(responsePayload)', expected type: '\(NewMessagePayload.self)')"))
            }
        }
        else if replyPayload.payload == nil, replyPayload.status == replyPayload.statusOk {
            // Do nothing. Статус сообщения ok, без тела (например проверка пинга).
        }
        else {
            self.delegate?.error(OmniChatTransportError("phxReplyHandler is empty error and payload, sendedMessage = '\(String(describing: sendedMessage))', receivedMessage = '\(receivedMessage)', receivedError = '\(String(describing: replyPayload.error))'"))
        }
    }
    
    /**
     Обработчик ответа на отправку нового сообщения.
     Если не было найдено отправляемое сообщение, соответствующее полученному, ответ игнорируется.
     */
    private func phxReplyNewMessage(_ sendedMessage: Message?, _ receivedMessage: Message, _ payload: NewMessagePayload) {
        if let ref = receivedMessage.joinRef,
            let clientMessageId = sendingMessages[ref],
            let receivedMessage = payload.message as? ClientChatMessage {
            receivedMessage.clientMessageId = clientMessageId
            self.delegate?.successSendMessage(receivedMessage)
            sendingMessages.removeValue(forKey: ref)
        }
        else {
            // Игнорируем ответ, т.к. не было найдено соответствие отправленного сообщения с полученным.
            ChatErrorHandler.handleInfo("phxReplyNewMessage not found receivedMessage in sendingMessages. receivedMessage = '\(receivedMessage)'")
        }
    }
    
    /**
     После отправки сообщения в сокет, возвращается клиентское представление сообщения для отображения на UI.
     После получения ответа сервера, об получении клиентского сообщение, delegate будет уведомлен об этом.
     Возвращаемое сообщение включает уникальный идентификатор, по которому потом можно будет смержить ответ и временное сообщение.
     
     - parameters:
        - text: Текст сообщения для отправки
     - returns: Временное представление клиентского сообщения для отображения на UI.
     */
    public func sendMessage(_ message: ClientChatMessage) -> ClientChatMessage {
        let ref = socket.push(topic: channel.topic, event: MessageEventType.new_msg.rawValue,
                              payload: ["body": message.text ?? "", "temporaryId": message.temporaryId ?? ""])

        sendingMessages[ref] = message.clientMessageId
        DispatchQueue.main.async {
            let deallocTimer = DefaultLifecycleTimer(timeInterval: 15) { [weak self] in

                if let messageId = self?.sendingMessages[ref] as? String {
                    self?.delegate?.errorSendMessage(clientMessageId: messageId)
                }
                self?.sendingMessages.removeValue(forKey: ref)
            }
            deallocTimer.start()
        }
        
        return message
    }
    
    /**
     Отправка серверу уведомления о прочтении пользователем полученного сообщения.
     */
    public func sendIsReadMessagesEvent(_ messages: [ChatMessage]) {
        var messageIds = [Int]()
        for message in messages {
            if let id = message.id, let messageId = Int(id)  {
                messageIds.append(messageId)
            }
        }
        _ = socket.push(topic: channel.topic, event: MessageEventType.is_read.rawValue, payload: ["ids": messageIds])
    }
    
    public func sendClientTypingEvent() {
        if clientTypingEventTimer == nil {
            clientTypingEventTimer = DefaultLifecycleTimer(timeInterval: clientTypingTimeImterval, handler: {[weak self] in
                self?.clientTypingEventTimer = nil
            })
            clientTypingEventTimer?.start()
            _ = socket.push(topic: channel.topic, event: MessageEventType.is_typing.rawValue, payload: ["value": true])
        }
    }
    
    private func leaveChannel() {
        _ = socket.push(topic: channel.topic, event: MessageEventType.phx_leave.rawValue, payload: [:])
    }
    
    public func disconnect() {
        socket.disconnect()
        delegate?.socketClosed()
        delegate?.updatedConnectionStatus(.disconnected)
    }
}
