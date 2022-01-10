import UIKit

/**

 */
class TextContentMessageView: UIView {
    
    /**
     TextView для отображения текста из сообщения.
     */
    /*
    @IBOutlet private weak var messageTextView: MessageTextView!

    /**
     Действие по нажатию на URL
     */
    private var urlTapAction: ((URL) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageTextView.font = ChatFonts.body1
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.dataDetectorTypes = .link
        messageTextView.tintColor = UIColor.textOnDarkLinks
        messageTextView.delegate = self
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        messageTextView.frame.origin = .zero
        messageTextView.frame.size = messageTextView.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        frame.size = CGSize(width: messageTextView.frame.maxX, height: messageTextView.frame.maxY)
    }
    
    /**
     Заполнение View переданным message.
     
     - parameters:
        - message: Сообщение для заполнения View.
     */
    func bind(_ message: ChatMessage) {
        messageTextView.text = message.text
        
        if message is ClientChatMessage {
            messageTextView.textColor = ChatColors.appWhite
        }
        else {
            messageTextView.textColor = ChatColors.appBlack
        }
    
        layoutIfNeeded()
    }
    
    /**
     Установка действия по долгому нажатию
     
     - parameters:
        - action: действие по долгому нажатию
     */
    func setLongPressAction(_ action: @escaping (_: UILongPressGestureRecognizer) -> Void) {
        messageTextView.longPressAction = action
    }
    
    /**
     Установка действия по нажатию на URL
     
     - parameters:
        - action: действие по долгому нажатию
     */
    func setUrlTapAction(_ action: @escaping (URL) -> Void) {
        urlTapAction = action
    }
}

extension TextContentMessageView: UITextViewDelegate {
    public func textView(_ textView: UITextView,
                         shouldInteractWith URL: URL,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        urlTapAction?(URL)
        return false
    }
     */
}
