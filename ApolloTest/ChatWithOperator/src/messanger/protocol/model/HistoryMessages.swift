import Foundation

class HistoryMessages {
    
    let messages: [ChatMessage?]
    let pageInfo: HistoryPage
    
    init(messages: [ChatMessage?], pageInfo: HistoryPage) {
        self.messages = messages
        self.pageInfo = pageInfo
    }
}
