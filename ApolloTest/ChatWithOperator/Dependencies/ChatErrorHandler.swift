import Foundation
//import NetworkLayer

class ChatErrorHandler {
    
//    public static let logger = LoggerFactory.getLogger(name: "DialogChat")
    
    static func handleError(_ error: Error) {
        if let chatError = error as? BaseChatError {
//            logger.error(message: "error message: '\(chatError.message)', localizedDescription: '\(chatError.localizedDescription)', causeError: '\(String(describing: chatError.cause))', causeError.localizedDescription: '\(String(describing: chatError.cause?.localizedDescription))', ")
            print("chatError.message)")
        }
        else {
//            logger.error(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    static func handleInfo(_ message: String) {
//        logger.info(message: message)
        print(message)
    }
    
    static func handleDebugInfo(_ message: String) {
//        logger.debug(message: message)
        print(message)
    }
}
