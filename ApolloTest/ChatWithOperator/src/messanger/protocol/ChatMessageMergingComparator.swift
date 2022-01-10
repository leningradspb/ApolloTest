import Foundation

/**
 Класс позволяет сравнить 2 сообщения.
 Сообщения считаются одним и тем же, если их уникальные идентификаторы совпадают.
 Идентификатор задается сервером или клиентом.
 
 - author: Q-ITS
 */
class ChatMessageMergingComparator {
    
    /**
     Проверка двух сообщений на соответствие идентификаторов, для возможности мержинга их.
     Базовые сообщения проверяются по id. Клиентские сообщения дополнительно проверются по clientMessageId.
     */
    static public func compare(_ firstMessage: ChatMessage, _ secondMessage: ChatMessage) -> Bool {
        if let clientFirstMessage = firstMessage as? ClientChatMessage,
            let clientSecondMessage = secondMessage as? ClientChatMessage {
            return compareClientMessage(firstMessage: clientFirstMessage, secondMessage: clientSecondMessage)
        }
        return compareChatMessage(firstMessage:firstMessage, secondMessage:secondMessage)
    }
    
    /**
     Проверка базового класса сообщений, только по id.
     
     - return: true - id сообщений совпадает, false - id сообщения отсутствует или они не равны
     */
    static private func compareChatMessage(firstMessage: ChatMessage, secondMessage: ChatMessage) -> Bool {
        if let idFirstMessage = firstMessage.id, let idSecondMessage = secondMessage.id {
            return idFirstMessage == idSecondMessage
        } else {
            return false
        }
    }
    
    
    /**
     Проверка клиентских сообщений.
     Порядок проверки сообщений:
     1. message.temporaryId сообщения проверяются по нему (при непустом значении)
     2. message.clientMessageId, который присваивается клиентом (при непустом значении).
     3. message.id.
     
     - return: true - Сообщения равны по одному из идентификаторов.
     */
    static private func compareClientMessage(firstMessage: ClientChatMessage, secondMessage: ClientChatMessage) -> Bool {
        if let temporyIdFirstMessage = firstMessage.temporaryId, let temporyIdSecondMessage = secondMessage.temporaryId,
            (!temporyIdFirstMessage.isEmpty && !temporyIdSecondMessage.isEmpty) {
            return temporyIdFirstMessage == temporyIdSecondMessage
        }
        
        if let clientIdFirstMessage = firstMessage.clientMessageId, let clientIdSecondMessage = secondMessage.clientMessageId {
            return clientIdFirstMessage == clientIdSecondMessage
        }
        
        if let idFirstMessage = firstMessage.id, let idSecondMessage = secondMessage.id {
            return idFirstMessage == idSecondMessage
        } else {
            return false
        }
    }
    
}
