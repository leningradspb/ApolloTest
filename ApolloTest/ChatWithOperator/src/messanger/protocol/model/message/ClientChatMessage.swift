import Foundation

/**
 Клиентское сообщение

 - author: Q-ITS
 */
class ClientChatMessage: ChatMessage {

    /**
     Клиентский идентификатор сообщения.
     
     Создаётся клиентом перед отправкой и служит дополнительным идентификатором, когда стандартный id не доступен
     */
    public var clientMessageId: String?
    
    /**
     Идентификатор сообщения присваиваемый клиентом отправлемому сообщению.
     Сервер может вернуть сообщение с temporaryId, если в списке уже есть сообщение с таким id их нужно смержить.
     Может быть nil.
     */
    public var temporaryId: String?
    
    static private var messageId: Int = 0
    
    init(id: String?,
         text: String?,
         attachment: AttachmentDto? = nil,
         operatorId: String? = nil,
         activityId: String? = nil,
         timestamp: Date,
         messageStatus: MessageStatusEnum,
         receiver: String? = nil,
         temporaryId: String? = nil,
         clientMessageId: String? = nil) {
        
        self.temporaryId = temporaryId
        self.clientMessageId = clientMessageId
        super.init(id: id,
                   text: text,
                   attachment: attachment,
                   operatorId: operatorId,
                   activityId: activityId,
                   timestamp: timestamp,
                   messageStatus: messageStatus,
                   receiver: receiver)
    }
    
    /**
     Создание клиентского сообщения, после отправки на сервер.
     Заполнение полей:
     * Date - дата на момент вызова инициализатора
     * messageStatus - Ожидание
     * clientMessageId - уникальный идентификатор клиентского сообщения. Позволяет при получении ответа на отправку сообщения, смержить сообщения.
     Остальные поля nil, т.к. их создает сервер.
     
     - parameters:
        - text: Текст сообщения
        - activityId: Идентификатор активности, может отсутствовать при отправки первого сообщения
        - messageId: Идентификатор сообщения
        - status: Статус отправки сообщения
     */
    convenience init(text: String?,
                     activityId: String? = nil,
                     messageId: String? = nil,
                     status: MessageStatusEnum = .PENDING) {
        let temporyMessageId = messageId ?? ClientChatMessage.makeNextMessageId()
        self.init(id: nil,
                  text: text,
                  activityId: activityId,
                  timestamp: Date(),
                  messageStatus: status,
                  temporaryId: UUID().uuidString,
                  clientMessageId: temporyMessageId)
    }
    
    public static func createAttachmentSendingMessage(temporaryId: String, _ attachment: AttachmentDto) -> ClientChatMessage {
        let message = ClientChatMessage(id: nil,
                                        text: nil,
                                        activityId: nil,
                                        timestamp: Date(),
                                        messageStatus: .PENDING,
                                        temporaryId: temporaryId,
                                        clientMessageId: ClientChatMessage.makeNextMessageId())
        message.attachment = attachment
        return message
    }
    
    private static func makeNextMessageId() -> String {
        messageId += 1
        return "\(UUID().uuidString)-\(messageId)"
    }
}
