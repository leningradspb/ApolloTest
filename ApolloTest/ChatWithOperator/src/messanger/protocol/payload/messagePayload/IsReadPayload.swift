import Foundation

class IsReadPayload: PayloadProtocol {
    
    /**
     * Список сообщений, которые были прочитаны.
     */
    public let ids: [Int]
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        self.ids = payload["ids"] as? [Int] ?? []
    }
    
    static func getEvent() -> String {
        return "is_read"
    }
    
    
}
