import Foundation


class PresenceStatePayload: PayloadProtocol {
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        return nil
    }
    
    static func getEvent() -> String {
        return "presence_state"
    }
}
