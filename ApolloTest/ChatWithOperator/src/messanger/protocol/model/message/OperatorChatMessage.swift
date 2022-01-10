import Foundation

/**
 Сообщение от оператора

 - author: Q-ITS
 */
class OperatorChatMessage: ChatMessage {

    /**
     Информация об операторе.
     Может отсутствовать при получении сообщения от бота (у бота нет id).
     */
    public var _operator: Operator?
    
    init(id: String,
         text: String,
         attachment: AttachmentDto? = nil,
         operatorId: String?,
         activityId: String,
         timestamp: Date,
         messageStatus: MessageStatusEnum,
         receiver: String? = nil) {
        if let operatorId = operatorId {
            self._operator = Operator(operatorId: operatorId, name: operatorId)
        }
        else {
            self._operator = nil
        }
        super.init(id: id,
                   text: text,
                   attachment: attachment,
                   operatorId: operatorId,
                   activityId: activityId,
                   timestamp: timestamp,
                   messageStatus: messageStatus,
                   receiver: receiver)
    }
}

class OperatorFreeFormButtonChatMessage: OperatorChatMessage {
    
    override init(id: String,
                  text: String,
                  attachment: AttachmentDto? = nil,
                  operatorId: String?,
                  activityId: String,
                  timestamp: Date,
                  messageStatus: MessageStatusEnum,
                  receiver: String? = nil) {
        
        super.init(id: id,
                   text: text,
                   attachment: attachment,
                   operatorId: operatorId,
                   activityId: activityId,
                   timestamp: timestamp,
                   messageStatus: messageStatus,
                   receiver: receiver)
    }
}
