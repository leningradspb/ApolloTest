import Foundation

// TODO: Добавить десериализацию
class IsTypingPayload: PayloadProtocol {
    
    /**
     * {@code true}, если статус "печатает" - положительный.
     *
     * <p>
     *     Принято отправлять событие только со значением {@code true}.
     *     Сервер сам изменит статус на {@code false}, когда перестанет получать это событие.
     * </p>
     */
    public let value: Bool
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
        if let intValue = payload["value"] as? Int {
            if intValue == 0 {
                value = false
            }
            else if intValue == 1 {
                value = true
            }
            else {
                return nil
            }
        }
        else if let stringValue = payload["value"] as? String {
            if stringValue == "0" {
                self.value = false
            }
            else if stringValue == "1" {
                self.value = true
            }
            else if let value = Bool(stringValue) {
                self.value = value
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    static func getEvent() -> String {
        return "is_typing"
    }
}
