import UIKit

/**
 Данные для работы UI с списком сообщений
 
 - author: Q-ITS
 */
public class ChatDataSource {
    
    private let chatMessageHistory: ChatMessageHistory
    
    public init(_ chatMessageHistory: ChatMessageHistory) {
        self.chatMessageHistory = chatMessageHistory
    }
    
    public func getSectionCount() -> Int {
        return 1
    }
    
    public func getRowsInSection(_ section: ChatSection) -> Int {
        return chatMessageHistory.getLoadedMessages().count
    }
    
    public func getSizeForMessage(_ indexPath: IndexPath, width: CGFloat) -> CGSize {
        guard let message = getMessage(indexPath: indexPath) else {
            return .zero
        }
        
        let size: CGSize
        switch message {
        case is ClientChatMessage:
            size = ClientMessageCell.size(width: width, item: message)
        case is InfoChatMessage:
            size = InfoMessageCell.size(width: width, item: message)
        case is TypingChatMessage:
            size = TypingMessageCell.size(width: width)
        case is OperatorStatusChatMessage:
            size = InfoMessageCell.size(width: width, item: message)
        case is OperatorFreeFormButtonChatMessage:
            size = OperatorButtonCell.size(width: width, item: message)
        default:
            size = OperatorMessageCell.size(width: width, item: message)
        }
        
        return size
    }
    
    public func getMessage(indexPath: IndexPath) -> ChatMessage? {
        if indexPath.row < chatMessageHistory.getLoadedMessages().count {
            return chatMessageHistory.getLoadedMessages()[indexPath.row]
        }
        else {
            return nil
        }
    }
}
