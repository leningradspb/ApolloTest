import Foundation

/**
 Базовый класс сообщения чата
 
 Хранит общие поля для сообщений чата.
 
 - author: Q-ITS
 */
public class ChatMessage {
    
    /**
     Уникальный идентификатор. Пустой при отправке пользовательского сообщения на сервер. В ответах сервера всегда присутствует.
     */
    public var id: String?
    
    /**
     Текст сообщения. При его наличии attachment = nil
     */
    public var text: String?
    
    /**
     Вложение в сообщение. При его наличии text = nil
     */
    public var attachment: AttachmentDto?
    
    /**
     Идентификатор оператора, привязанного к сообщению
     
     TODO: возможно стоит убрать из общего сообщения и перенести в те реализации, где необходимо
     */
    public var operatorId: String?
    
    /**
     * Идентификатор активности, к которой принадлежит сообщение
     */
    public var activityId: String?
    
    /**
     Время отправки
     */
    public var timestamp: Date
    
    /**
     Статус доставки сообщения.
     
     Для сообщения пользователя изменяется в зависимости от команды от сервера
     Для сообщения оператора отправляется запрос на изменение статуса (получен/прочитан)
     */
    public var messageStatus: MessageStatusEnum
    
    /**
     Получатель сообщения (пользователь/оператор/другое), техническая информация
     */
    public var receiver: String?
    
    /**
        * В качестве уникального идентификатора решено использовать конкатенацию пары ActivityId + MessageId.
        * Это позволяет однозначно привязать заявку к сообщению платформы CTI
    */
    public let messageId: String?
    
    public init(id: String? = nil,
                text: String?,
                attachment: AttachmentDto? = nil,
                operatorId: String? = nil,
                activityId: String? = nil,
                timestamp: Date,
                messageStatus: MessageStatusEnum,
                receiver: String? = nil) {
        self.id = id
        self.text = text
        self.attachment = attachment
        self.operatorId = operatorId
        self.activityId = activityId
        self.timestamp = timestamp
        self.messageStatus = messageStatus
        self.receiver = receiver
        
        if let chatMessageId = id, let activityId = activityId {
            messageId = "\(activityId):\(chatMessageId)"
        } else {
            messageId = nil
        }
    }
}
