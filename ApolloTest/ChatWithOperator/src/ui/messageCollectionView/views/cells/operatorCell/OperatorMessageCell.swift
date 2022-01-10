import UIKit

class OperatorMessageCell: UICollectionViewCell, MessageCell {
    
    /**
     Идентификатор ячейки для переиспользования при регистрации ячейки в коллекции.
     */
    @objc  static let reuseIdentifier = "OperatorMessageCell"
    
    /**
     При отображении коллекция запрашивает размер будущей ячейки. Т.к. у нас еще нет объекта класса для расчета размеров, используется статическая ячейка.
     Данная ячейка заполняется контентом для предварительного расчета размера будущей ячейки.
     */
    @objc  static let cellForCalculateSize: OperatorMessageCell = OperatorMessageCell.viewFromNib()
    
    /**
     Отступы от максимальной ширины для contentView.
     */
    @objc  static let insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /**
     View внутри ячейки для отображения сообщения.
     */
    private let messageView: OperatorMessageView = OperatorMessageView.viewFromNib()
    
    private var message: ChatMessage?
    
    private weak var delegate: MessageCellDelegate?
    
    private let operatorIconView = UIImageView()
        
    override func awakeFromNib() {
        super.awakeFromNib()
    
        operatorIconView.image = UIImage(named: "operator_icon")
        addSubview(operatorIconView)
        addSubview(messageView)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        let operatorIconSize = CGSize(width: 18, height: 18)
        let iconOffset: CGFloat = 7
        messageView.frame.size.width = frame.width - 40 - (operatorIconSize.width + iconOffset)
        messageView.layoutIfNeeded()
        messageView.frame.origin.x = operatorIconSize.width + iconOffset
        
        operatorIconView.frame.size = operatorIconSize
        operatorIconView.frame.origin = CGPoint(x: .zero, y: messageView.frame.size.height - operatorIconSize.height)

        frame.size.height = messageView.frame.size.height
    }
    
    /**
     Установка переданного сообщения на UI.
     После установки пересчитывается layout.
     */
    func bind(_ item: ChatMessage, _ delegate: MessageCellDelegate?) {
        self.message = item
        self.delegate = delegate
        messageView.bind(item, delegate)
        
        layoutIfNeeded()
    }
    
    func reloadMessage(_ item: ChatMessage) {
        bind(item, delegate)
    }
    
    func unbind() -> ChatMessage? {
        return message
    }
    
    func setIsLastMessage(_ isLast: Bool) {
        operatorIconView.isHidden = !isLast
    }
    
    /**
     Расчет размера ячейки при установке ей переданного message.
     */
    static func size(width:CGFloat, item: ChatMessage) -> CGSize {
        cellForCalculateSize.frame.size.width = width - (insets.left + insets.right)
        cellForCalculateSize.bind(item, nil)
        return cellForCalculateSize.frame.size
    }
}
