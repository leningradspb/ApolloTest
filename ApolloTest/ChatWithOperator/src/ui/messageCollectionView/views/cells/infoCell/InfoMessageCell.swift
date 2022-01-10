import UIKit

/**
 Ячейка для отображения информационного сообщения.
 */
class InfoMessageCell: UICollectionViewCell, MessageCell {

    /**
     Идентификатор ячейки для переиспользования при регистрации ячейки в коллекции.
     */
    @objc  static let reuseIdentifier = "InfoMessageCell"
    
    private static let cellForCalculateSize: InfoMessageCell = InfoMessageCell.viewFromNib()
    
    /**
     Максимальная ширина сообщения на экране относительно переданной в методе size(width:CGFloat, message: Message)
     */
    @objc  static let maxWidthPercent: CGFloat = 1.0
    
    private let cellEdge: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 0)
    
    /**
     View внутри ячейки для отображения сообщения.
     */
    private let messageView: InfoMessageView = InfoMessageView.viewFromNib()
    
    private var message: ChatMessage?
    
    private weak var delegate: MessageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(messageView)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        messageView.frame.size.width = frame.width * InfoMessageCell.maxWidthPercent
        messageView.layoutIfNeeded()
        messageView.frame.origin.y = 0
        messageView.frame.origin.x = 0
        
        frame.size.height = messageView.frame.height
    }

    func bind(_ item: ChatMessage, _ delegate: MessageCellDelegate?) {
        self.message = item
        self.delegate = delegate
        messageView.bind(item)
        layoutIfNeeded()
    }
    
    func reloadMessage(_ item: ChatMessage) {
        bind(item, delegate)
    }
    
    func unbind() -> ChatMessage? {
        return self.message
    }
    
    static func size(width: CGFloat, item: ChatMessage) -> CGSize {
        cellForCalculateSize.frame.size.width = width
        cellForCalculateSize.bind(item, nil)
        return cellForCalculateSize.frame.size
    }
}
