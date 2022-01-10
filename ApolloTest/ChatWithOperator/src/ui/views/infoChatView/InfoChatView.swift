import UIKit

/**
 Отображение информационных сообщений чата, как подзаголовок.
 Возможно отображения:
 - Статуса соединения
 - 
 
 - author: Q-ITS
 */
class InfoChatView: UIView {
    
    /**
     Label для отображения статуса соединения
     */
    private var infoLabel = UILabel()
    
    /**
     Отступы для statusLabel относительно statusView.
     */
    private let labelMargin = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    
    /**
     Текущий статус соединения
     */
    private var status: SessionConnectionStatus?
    
    /**
     - parameters:
        - frame: Размер создаваемого View
        - status: Данные о статусе которые будут установлены в данное View
     */
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
        
        bind(text)
    }
    
    /**
     - parameters:
     - frame: Размер создаваемого View
     - status: Данные о статусе которые будут установлены в данное View
     */
    convenience init(frame: CGRect, status: SessionConnectionStatus) {
        self.init(frame: frame)
        
        bind(status: status)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ChatColors.appRed
        autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]

        infoLabel.textColor = ChatColors.appWhite
        infoLabel.font = ChatFonts.body1
        infoLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        addSubview(infoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        infoLabel.frame.size = infoLabel.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        infoLabel.frame.origin = CGPoint(x: (frame.width - infoLabel.frame.width) / 2, y: labelMargin.top)
        
        if infoLabel.frame.height > 0 {
            frame.size.height = infoLabel.frame.height + labelMargin.top + labelMargin.bottom
        }
        else {
            frame.size.height = 0
        }
    }
    
    public func bind(_ text: String) {
        infoLabel.text = text
    }
    
    public func bind(status: SessionConnectionStatus) {
        self.status = status
        switch status {
        case .connecting:
            infoLabel.text = "Text.Chat.ConnectionInProcess"
            backgroundColor = ChatColors.infoBackgroundGreen
        case .disconnected:
            infoLabel.text = "Text.Chat.ConnectionError"
            backgroundColor = ChatColors.appRed
        case .offline:
            infoLabel.text = "Text.Chat.ConnectionOffline"
            backgroundColor = ChatColors.appRed
        default:
            infoLabel.text = ""
        }
    }

    public func getStatus() -> SessionConnectionStatus? {
        return status
    }
    
    public func needUpdate() -> Bool {
        if let status = self.status {
            return status == .disconnected
        }
        else {
            return true
        }
    }
}
