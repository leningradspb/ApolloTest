import Foundation

class NewMessagePayload: PayloadProtocol {
    
    public let message: ChatMessage
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        guard let message = ChatMessageConverter.convert(payload: payload) else {
            return nil
        }
        
        if let clientMessage = message as? ClientChatMessage {
            clientMessage.clientMessageId = sendedMessage?.joinRef
            self.message = clientMessage
        }
        else {
            self.message = message
        }
    }
    
    static func getEvent() -> String {
        return "new_msg"
    }
    
}
