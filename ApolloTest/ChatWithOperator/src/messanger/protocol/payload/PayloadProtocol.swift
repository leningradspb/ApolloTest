import Foundation

protocol PayloadProtocol {
    init?(_ payload: Payload, sendedMessage: Message?)
    
    static func getEvent() -> String
}
