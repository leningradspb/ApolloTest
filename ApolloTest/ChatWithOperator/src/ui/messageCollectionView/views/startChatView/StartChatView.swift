import UIKit

/**
 Класс стартового экрана чата при отсутствии истории сообщений.
 */
class StartChatView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inputMessageLabel: UILabel!
    @IBOutlet private weak var startImageView: UIImageView!
    
    override func awakeFromNib() {
        titleLabel.text = "applicationStrings(Text.Chat.WelcomeToChat)"
        titleLabel.font = ChatFonts.h3
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        inputMessageLabel.text = "applicationStrings(Text.Chat.AskQuestion)"
        inputMessageLabel.font = ChatFonts.body1
        inputMessageLabel.textColor = .gray
        inputMessageLabel.numberOfLines = 0
        inputMessageLabel.textAlignment = .center
        
        startImageView.image = ChatImage.startScreenImage
    }
}
