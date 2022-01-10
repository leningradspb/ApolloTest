import Foundation

class ReplyPayload: PayloadProtocol {
    
    enum ReplyStatus: String {
        case ok = "ok"
        case error = "error"
    }
    
    public let statusOk = "ok"
    public let statusError = "error"
    
    public let status: String
    private(set) var error: String? = nil
    private(set) var payload: PayloadProtocol? = nil
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        guard let status = payload["status"] as? String else { return nil }
        guard let response = payload["response"] else { return nil }
        self.status = status
        
        if ReplyStatus(rawValue: status) == .error {
            self.error = response as? String
        }
        else if let responsePayload = response as? Payload {
            self.payload = PayloadConverter.decode(payload: responsePayload, sendedMessage: sendedMessage)
        }
    }
    
    static func getEvent() -> String {
        return "phx_reply"
    }
}
