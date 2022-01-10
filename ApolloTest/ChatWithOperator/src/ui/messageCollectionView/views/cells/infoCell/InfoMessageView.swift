import UIKit

class InfoMessageView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    
    /**
     Отступы внутри для contentMessageView
     */
    private let contentEdge = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.textColor = ChatColors.appMediumGray
        textLabel.font = ChatFonts.tiny
        textLabel.textAlignment = .center
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        textLabel.frame.size = textLabel.sizeThatFits(CGSize(width: frame.width - (contentEdge.left + contentEdge.right),
                                                       height: CGFloat.greatestFiniteMagnitude))
        textLabel.frame.origin.y = contentEdge.top
        textLabel.frame.origin.x = (frame.width - textLabel.frame.width) / 2
        frame.size.height = textLabel.frame.height + (contentEdge.top + contentEdge.bottom)
    }
    
    func bind(_ message: ChatMessage) {
        textLabel.text = message.text
        layoutIfNeeded()
    }
}
