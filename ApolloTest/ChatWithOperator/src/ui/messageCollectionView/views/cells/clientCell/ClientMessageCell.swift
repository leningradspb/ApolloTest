import UIKit

/**
 Базовая ячейка для отображения сообщений.
 Содержит MessageView с различным контентом.
 В ячейке используется ручной расчет frame элементов, вместо constraints. Т.к. автоматически сложно рассчитать будущий размер ячейки.
 */
class ClientMessageCell: UICollectionViewCell, MessageCell {
    
    /**
     Идентификатор ячейки для переиспользования при регистрации ячейки в коллекции.
     */
    @objc  static let reuseIdentifier = "ClientMessageCell"
    
    /**
     При отображении коллекция запрашивает размер будущей ячейки. Т.к. у нас еще нет объекта класса для расчета размеров, используется статическая ячейка.
     Данная ячейка заполняется контентом для предварительного расчета размера будущей ячейки.
     */
    @objc  static let cellForCalculateSize: ClientMessageCell = ClientMessageCell.viewFromNib()
    
    /**
     Отступы от максимальной ширины для contentView.
     */
    @objc  static let insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /**
     View внутри ячейки для отображения сообщения.
     */
    private let messageView: ClientMessageView = ClientMessageView.viewFromNib()
    
    /**
     Отображет иконку для повторной отправки сообщения.
     */
    private let resendImageView: UIImageView = UIImageView()
    
    private var message: ChatMessage?
    
    private weak var delegate: MessageCellDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resendImageView.image = ChatImage.resendImage
        resendImageView.sizeToFit()
        addSubview(messageView)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()

        contentView.backgroundColor = .white
        
        messageView.frame.origin.y = 0
        
        messageView.frame.size.width = frame.width - 40
        messageView.layoutIfNeeded()
        messageView.frame.origin.x = frame.width - messageView.frame.width
        
        if self.message?.messageStatus == .UNDELIVERED {
            resendImageView.frame.origin.x = frame.width - resendImageView.frame.width
            resendImageView.frame.origin.y = messageView.frame.height
        }
        
        frame.size.height = self.message?.messageStatus == .UNDELIVERED ? resendImageView.frame.origin.y : messageView.frame.height
    }

    /**
     Установка переданного сообщения на UI.
     После установки пересчитывается layout.
     */
    func bind(_ item: ChatMessage, _ delegate: MessageCellDelegate?) {
        self.message = item
        self.delegate = delegate
        
        if self.message?.messageStatus == .UNDELIVERED && self.message?.attachment == nil {
            addSubview(resendImageView)
        }
        else {
            resendImageView.removeFromSuperview()
        }
        
        messageView.bind(item, delegate)
        layoutIfNeeded()
    }
    
    func reloadMessage(_ item: ChatMessage) {
        bind(item, delegate)
    }
    
    func unbind() -> ChatMessage? {
        return message
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
