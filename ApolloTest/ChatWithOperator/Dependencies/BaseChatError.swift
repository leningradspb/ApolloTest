import Foundation

public class BaseChatError: Error {
    
    public let message: String
    
    public let cause: Error?
    
    public init(_ message: String, _ cause: Error? = nil) {
        self.message = message
        self.cause = cause
    }
    
    var localizedDescription: String {
        return "message: '\(message)', cause: '\(String(describing: cause?.localizedDescription))'"
    }
}
