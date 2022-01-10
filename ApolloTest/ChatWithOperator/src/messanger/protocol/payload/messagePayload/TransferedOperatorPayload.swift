import Foundation

class TransferedOperatorPayload: PayloadProtocol {
    
    public let value: String
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        guard let newActivity = payload["newActivityId"] as? String else {
            return nil
        }
        value = newActivity
    }
    
    static func getEvent() -> String {
        return "transfer"
    }
    
}
