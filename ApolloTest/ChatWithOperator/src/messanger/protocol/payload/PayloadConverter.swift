import Foundation

class PayloadConverter {
    
    static func decode(payload: Payload, sendedMessage: Message?) -> PayloadProtocol? {
        guard let event = sendedMessage?.event,
            let eventType = MessageEventType(rawValue: event) else {
                return nil
        }
        
        switch eventType {
        case .action:
            return nil
        case .found_operator:
            return IsFoundOperatorPayload(payload)
        case .info:
            return nil
        case .input:
            return nil
        case .is_read:
            return IsReadPayload(payload)
        case .is_typing:
            return IsTypingPayload(payload)
        case .left:
            return nil
        case .new_msg:
            return NewMessagePayload(payload, sendedMessage: sendedMessage)
        case .phx_close:
            return nil
        case .phx_error:
            return nil
        case .phx_join:
            return nil
        case .phx_leave:
            return nil
        case .phx_reply:
            return nil
        case .presence_diff:
            return PresenceDiffPayload(payload)
        case .presence_state:
            return PresenceDiffPayload(payload)
        case .transfered:
            return TransferedOperatorPayload(payload)
        }
    }
    
    static func decode(payload: Payload, eventType: MessageEventType) -> PayloadProtocol? {
        switch eventType {
        case .action:
            return nil
        case .found_operator:
            return IsFoundOperatorPayload(payload)
        case .info:
            return nil
        case .input:
            return nil
        case .is_read:
            return IsReadPayload(payload)
        case .is_typing:
            return IsTypingPayload.init(payload)
        case .left:
            return nil
        case .new_msg:
            return NewMessagePayload(payload)
        case .phx_close:
            return nil
        case .phx_error:
            return nil
        case .phx_join:
            return nil
        case .phx_leave:
            return nil
        case .phx_reply:
            return nil
        case .presence_diff:
            return PresenceDiffPayload(payload)
        case .presence_state:
            return PresenceDiffPayload(payload)
        case .transfered:
            return TransferedOperatorPayload(payload)
        }
    }
}
