import Foundation

public class Activity {
    
    public let id: String
    public let state: String
    
    public init(id: String, state: String) {
        self.id = id
        self.state = state
    }
    
    public func isActive() -> Bool {
        return (state == "in_progress" || state == "pending" || state == "on_hold")
    }
    
}
