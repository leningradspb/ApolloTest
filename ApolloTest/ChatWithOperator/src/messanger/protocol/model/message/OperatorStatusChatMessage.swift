import Foundation

/**
 Клиентское представление статусов оператора
 
 - author: Q-ITS
 */
class OperatorStatusChatMessage: ChatMessage {
    
    public let operatorStatus: OperatorStatus
    
    init(status: OperatorStatus, date: Date = Date()) {
        var statusText: String
        switch status {
        case .found_not_operator:
            statusText = "Text.Chat.SearchAvailableOperator"
        case .found_operator:
            statusText = ChatLocalization.getOperatorFoundMessagePattern()
        case .leave:
            statusText = ChatLocalization.getOperatorLeftMessage()
        default:
            statusText = ""
        }
        self.operatorStatus = status
        super.init(text: statusText, timestamp: date, messageStatus: .DELIVERED)
    }
    
}
