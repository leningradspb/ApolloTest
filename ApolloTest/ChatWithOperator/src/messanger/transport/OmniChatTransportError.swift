import Foundation
import Apollo

/**
 Ошибка уровня транспорта Apollo при HTTP запросах.
 */
public class OmniChatTransportError: BaseChatError {
    
    public static func createFailedRequest(_ request: AnyObject) -> OmniChatTransportError {
        return OmniChatTransportError("Не удалось выполнить '\(request)'")
    }
}
