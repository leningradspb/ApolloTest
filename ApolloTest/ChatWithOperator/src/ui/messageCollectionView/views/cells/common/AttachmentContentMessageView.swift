import UIKit

public class AttachmentContentMessageView: UIView {
        
    /**
     Изображения типа вложения
     */
    @IBOutlet private weak var fileTypeImageView: UIImageView!
    
    /**
     Заголовок для файлового сообщения
     */
    @IBOutlet private weak var titleLabel: UILabel!
    
    /**
     Информация о файле
     */
    @IBOutlet private weak var fileInfoLabel: UILabel!
    
    private var message: ChatMessage?
    
    private weak var delegate: MessageCellDelegate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    override public func layoutIfNeeded() {
        super.layoutIfNeeded()
                
        fileTypeImageView.frame.origin = CGPoint(x: 0, y: 8)
        fileTypeImageView.frame.size = CGSize(width: 32, height: 32)
        
        let horizontalMargin = CGFloat(8.0)
        let widthForTextMax = frame.width - fileTypeImageView.frame.maxX - horizontalMargin
        
        titleLabel.frame.origin = CGPoint(x: fileTypeImageView.frame.maxX + horizontalMargin, y: 3)
        titleLabel.frame.size = CGSize(width: widthForTextMax,
                                       height: titleLabel.sizeThatFits(CGSize(width: widthForTextMax,
                                                                              height: CGFloat.greatestFiniteMagnitude)).height)
        
        fileInfoLabel.frame.origin = CGPoint(x: titleLabel.frame.minX, y: titleLabel.frame.maxY + 2)
        fileInfoLabel.frame.size = fileInfoLabel.sizeThatFits(CGSize(width: widthForTextMax, height: CGFloat.greatestFiniteMagnitude))
        
        frame.size.height = fileInfoLabel.frame.maxY
    }
    
    private func configureUI() {
        titleLabel.font = ChatFonts.body1
        fileInfoLabel.font = ChatFonts.tiny
        fileTypeImageView.image = nil
        fileTypeImageView.tintColor = ChatColors.appWhite
        
        let tapGesure = UITapGestureRecognizer(target: self, action: #selector(didTapAttachment))
        addGestureRecognizer(tapGesure)
    }
    
    /**
     Заполнение View переданным message.
     
     - parameters:
        - message: Сообщение для заполнения View.
     */
    func bind(_ message: ChatMessage, _ delegate: MessageCellDelegate?) {
        self.message = message
        self.delegate = delegate
        guard let attachment = message.attachment else {
            titleLabel.text = ""
            fileInfoLabel.text = nil
            fileTypeImageView.image = nil
            return
        }
        
        if message is ClientChatMessage {
            titleLabel.textColor = ChatColors.appWhite
            fileInfoLabel.textColor = ChatColors.fileInfoOperator
        }
        else {
            titleLabel.textColor = ChatColors.appBlack
            fileInfoLabel.textColor = ChatColors.fileInfoClient
        }
        
        if message.messageStatus == .UNDELIVERED {
            titleLabel.numberOfLines = 0
            titleLabel.text = "Text.Chat.Attachment.Error"
            fileInfoLabel.text = nil
            fileTypeImageView.image = UIImage(named: "chat_attachment_error")
        }
        else {
            titleLabel.numberOfLines = 1
            titleLabel.text = attachment.title
            fileInfoLabel.text = "\(attachment.ext), \(getAttachmentSize(attachment))"
            fileTypeImageView.image = getMimeTypeIcon(attachment)
        }
        
        layoutIfNeeded()
    }
    
    @objc private func didTapAttachment() {
        guard let message = message else {
            ChatErrorHandler.handleInfo("Отсутствует message для отображения вложения")
            return
        }
        guard message.messageStatus == .READ || message.messageStatus == .DELIVERED else {
            return
        }
        guard let attachment = message.attachment else {
            ChatErrorHandler.handleInfo("Отсутствует attachment для отображения вложения")
            return
        }
        delegate?.didTapAttachment(attachment: attachment)
    }
    
    private func getAttachmentSize(_ attachment: AttachmentDto) -> String {
        var size = attachment.size ?? 0
        size = size / 1024
        return "\(size)КБ"
    }
    
    private func getMimeTypeIcon(_ attachment: AttachmentDto) -> UIImage? {
        if let image = UIImage(named: "chat_attachment_\(attachment.ext)") {
            return image
        }
        else {
            return UIImage(named: "chat_attachment_unknown")
        }
    }
}
