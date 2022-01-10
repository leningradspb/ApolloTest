import Foundation

class PresenceDiffPayload: PayloadProtocol {
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        return nil
    }
    
    static func getEvent() -> String {
        return "presence_diff"
    }
    
    
}
