import Foundation

class JoinPayload: PayloadProtocol {
    
    public let acessToken: String
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        guard let token = payload["guardian_token"] as? String else {
            return nil
        }
        acessToken = token
    }
    
    static func getEvent() -> String {
        return "phx_join"
    }
}
