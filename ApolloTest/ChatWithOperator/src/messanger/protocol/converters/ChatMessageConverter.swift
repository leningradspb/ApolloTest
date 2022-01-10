import Foundation

/**
 Конвертирует MessageInMessagesFeed от сервера Omni в клиентский ChatMessage.
 
 - author: Q-ITS
 */
class ChatMessageConverter {
    
    /**
     Формат строкового представления даты, получаемой от сервера.
     "yyyy-MM-dd hh:mm:ss"
     */
    private static let insertedAtFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    /**
     Конвертация представления сообщения Omni из запроса MessagesFeed.
     Некоторые поля в Omni представлены строками, при конвертации они заменяются объектным представление enum.
     
     
     - parametes:
     - message: Объектное представление десериализованного сообщения от Omni.
     */
    static public func convert(message: MessageInMessagesFeed?) -> ChatMessage? {
        
        guard let message = message,
            let messageSenderString = message.sender,
            let messageSender = MessageSenderDto(rawValue: messageSenderString) else {
                return nil
        }
        
        guard let id = message.id,
            let activityId = message.activityId,
            let timestamp = insertedAtFormatter.date(from: message.insertedAt ?? "") else {
                return nil
        }
        // в редких случаях сервер может прислать nil, вместо пустого сообщения.
        let text = message.body ?? ""
        let messageStatus = MessageStatusEnum.create(isRead: message.isRead ?? false)
        
        let attachment: AttachmentDto?
        if let messageAttachment = message.attachment {
            attachment = AttachmentConvertor.convert(messageAttachment)
        }
        else {
            attachment = nil
        }
        
        return createMessage(messageSender: messageSender,
                             id: id,
                             text: text,
                             operatorId: message.operatorId,
                             activityId: activityId,
                             timestamp: timestamp,
                             messageStatus: messageStatus,
                             temporaryId: nil,
                             clientMessageId: message.customerId,
                             receiver: message.receiver,
                             attachment: attachment)
    }
    
    /**
     Конвертация представления сообщения Omni из запроса MessagesFeed.
     Некоторые поля в Omni представлены строками, при конвертации они заменяются объектным представление enum.
     
     
     - parametes:
     - message: Объектное представление десериализованного сообщения от Omni.
     */
    static public func convert(message: MessageInFirstMessagesFeed?) -> ChatMessage? {
        let attachment = (message?.attachment != nil)
            ? AttachmentConvertor.convertToMessageAttachment(message!.attachment!)
            : nil
        
        return convert(message: MessageInMessagesFeed(id: message?.id,
                                                      activityId: message?.activityId,
                                                      body: message?.body,
                                                      customerId: message?.customerId,
                                                      operatorId: message?.operatorId,
                                                      insertedAt: message?.insertedAt,
                                                      isRead: message?.isRead,
                                                      sender: message?.sender,
                                                      receiver: message?.receiver,
                                                      attachment: attachment))
    }
    
    /**
     Получение сообщения из payload ответа сервера.
     */
    static public func convert(payload: Payload?) -> ChatMessage? {
        guard let payload = payload,
            let messageSenderString = payload["sender"] as? String,
            let messageSender = MessageSenderDto(rawValue: messageSenderString) else {
                return nil
        }
        
        // TODO: Временное решение для работы с Stub
        let id: String
        if let intId = payload["id"] as? Int {
            id = String(intId)
        }
        else if let stringId = payload["id"] as? String {
            id = stringId
        }
        else {
            return nil
        }
        
        guard
            let activityId = payload["activityId"] as? String,
            let timestamp = insertedAtFormatter.date(from: (payload["insertedAt"] as? String) ?? "") else {
                return nil
        }
        
        // в редких случаях сервер может прислать nil, вместо пустого сообщения.
        let text = (payload["body"] as? String) ?? ""
        
        let messageStatus = MessageStatusEnum.create(isRead: (payload["isRead"] as? Bool) ?? false)
        let operatorIdString: String?
        if let operatorId = payload["operatorId"] as? Int {
            operatorIdString = String(operatorId)
        }
        else if let operatorId = payload["operatorId"] as? String {
            operatorIdString = operatorId
        }
        else {
            operatorIdString = nil
        }
        
        let attachment: AttachmentDto?
        if let attachmentPayload = payload["attachment"] as? [String: Any] {
            attachment = AttachmentConvertor.convert(attachmentPayload)
        }
        else {
            attachment = nil
        }
        
        return createMessage(messageSender: messageSender,
                             id: id,
                             text: text,
                             operatorId: operatorIdString,
                             activityId: activityId,
                             timestamp: timestamp,
                             messageStatus: messageStatus,
                             temporaryId: payload["temporaryId"] as? String,
                             clientMessageId: payload["customerId"] as? String,
                             receiver: payload["receiver"] as? String,
                             attachment: attachment)
    }
    
    /**
     Получение сообщения из запроса активности, при отправке первого сообщения
     */
    static func convert(activity: ActivityByFirstMessageResponse) -> ChatMessage? {
        guard let message = activity.messages?.first as? ActivityCreateByFirstMessageMutation.Data.ActivityByFirstMessage.Message,
            let activityId = activity.id else {
                return nil
        }
        guard let id = message.id,
            let timestamp = insertedAtFormatter.date(from: message.insertedAt ?? "") else {
                return nil
        }
        let text = message.body ?? ""
        let messageStatus = MessageStatusEnum.create(isRead: (message.isRead ?? false))
        
        let attachment: AttachmentDto?
        if let messageAttachment = message.attachment {
            attachment = AttachmentConvertor.convertToMessageAttachment(messageAttachment)
        }
        else {
            attachment = nil
        }
        
        return createMessage(messageSender: .CUSTOMER,
                             id: id,
                             text: text,
                             operatorId: message.operatorId ?? "",
                             activityId: activityId,
                             timestamp: timestamp,
                             messageStatus: messageStatus,
                             temporaryId: "123456789",
                             clientMessageId: "",
                             receiver: message.receiver,
                             attachment: attachment)
    }
    /**
     Общий метод для создания сообщения, из входных параметров. Вспомогательный метод.
     */
    static private func createMessage(messageSender:MessageSenderDto, id: String,
                                      text: String, operatorId: String?,
                                      activityId: String, timestamp:Date,
                                      messageStatus: MessageStatusEnum,
                                      temporaryId: String?,
                                      clientMessageId: String?,
                                      receiver: String?,
                                      attachment: AttachmentDto?) -> ChatMessage? {
        
        switch messageSender {
        case .CUSTOMER:
            return ClientChatMessage(id: id,
                                     text: text,
                                     attachment: attachment,
                                     operatorId: operatorId,
                                     activityId: activityId,
                                     timestamp: timestamp,
                                     messageStatus: messageStatus,
                                     receiver: receiver,
                                     temporaryId: temporaryId,
                                     clientMessageId: clientMessageId)
        case .OPERATOR where OperatorInitiatedProcessType.getRawValues().contains(text):
            return OperatorFreeFormButtonChatMessage(id: id,
                                       text: text,
                                       attachment: attachment,
                                       operatorId: operatorId,
                                       activityId: activityId,
                                       timestamp: timestamp,
                                       messageStatus: messageStatus,
                                       receiver: receiver)
        case .OPERATOR:
            return OperatorChatMessage(id: id,
                                       text: text,
                                       attachment: attachment,
                                       operatorId: operatorId,
                                       activityId: activityId,
                                       timestamp: timestamp,
                                       messageStatus: messageStatus,
                                       receiver: receiver)
        case .SYSTEM:
            return InfoChatMessage(id: id,
                                   text: text,
                                   attachment: attachment,
                                   operatorId: operatorId,
                                   activityId: activityId,
                                   timestamp: timestamp,
                                   messageStatus: messageStatus,
                                   receiver: receiver)
        }
    }
    
}

