import Foundation


class IsFoundOperatorPayload: PayloadProtocol {
    
    /**
     Нужно будет обновить описание. Статус ture устанавливается всегда, так как дополнительного атрибута в теле нет
     */
    public let value: Bool
    
    required init?(_ payload: Payload, sendedMessage: Message? = nil) {
       value = true
    }
    
    static func getEvent() -> String {
        return "found_operator"
    }
}
