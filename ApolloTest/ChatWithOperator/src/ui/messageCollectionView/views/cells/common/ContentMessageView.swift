import UIKit

/**
 View для отображения контента сообщения, без внешней обертки.
 Все компоненты не включают отступы и считаются из точки (0:0).
 Пользовательское и операторское сообщение имеют схожий дизайн отображения контента сообщения, только разные рамки.
 При расхождении дизайна и способа отображения контента, разделить данное View.
 */
class ContentMessageView: UIView {
    
    /**
     Контейнер для отображения содержимого сообщения
     - Текстовое сообщение
     - Файловое вложение
     */
    @IBOutlet private weak var messageViewContainer: UIView!
    
    /**
     Статус сообщения в виде иконки.
     */
    @IBOutlet private weak var statusImageView: UIImageView!
    
    /**
     Label для отображения времени отправки сообщения.
     */
    @IBOutlet private weak var timeLabel: UILabel!
    
    /**
     Действие по долгому нажатию на View
     */
    var longPressAction: ((_: UILongPressGestureRecognizer) -> Void)?
    
    /**
     View для отображения текстового сообщения
     */
    private let textView: TextContentMessageView = TextContentMessageView.viewFromNib()
    
    /**
     View для отображения файлового вложения
     */
    private let attachmentView: AttachmentContentMessageView = AttachmentContentMessageView.viewFromNib()
    
    /**
     Действие по нажатию на URL
     */
    var urlTapAction: ((URL) -> ())?
    
    private weak var delegate: MessageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        let messageViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let messageViewWidth = frame.width - (messageViewInsets.left + messageViewInsets.right)
        textView.frame.origin = .zero
        textView.frame.size = CGSize(width: messageViewWidth, height: 0)
        textView.layoutIfNeeded()
        attachmentView.frame.origin = .zero
        attachmentView.frame.size = CGSize(width: messageViewWidth, height: 0)
        attachmentView.layoutIfNeeded()
        
        messageViewContainer.frame.origin = CGPoint(x: messageViewInsets.left, y: messageViewInsets.top)
        messageViewContainer.frame.size = CGSize(width: textView.superview != nil ? textView.frame.width : attachmentView.frame.width,
                                                 height: textView.superview != nil ? textView.frame.height : attachmentView.frame.height)
        
        statusImageView.frame.origin.y = messageViewContainer.frame.maxY + 2
        timeLabel.frame.origin.y = statusImageView.frame.minY

        frame.size = CGSize(width: max(messageViewContainer.frame.width,
                                       timeLabel.frame.width + (statusImageView.image == nil ? 0 : statusImageView.frame.width + 8)),
                            height: max(statusImageView.frame.maxY, timeLabel.frame.maxY))

        statusImageView.frame.origin.x = frame.width - statusImageView.frame.width
        timeLabel.frame.origin.x = statusImageView.image == nil ? frame.width - timeLabel.frame.width
            : statusImageView.frame.minX - timeLabel.frame.width - 8
    }
    
    private func configureUI() {
        timeLabel.font = ChatFonts.tiny
        statusImageView.image = nil
        statusImageView.sizeToFit()
    }
    
    /**
     Заполнение View переданным message.
     
     - parameters:
        - message: Сообщение для заполнения View.
     */
    func bind(_ message: ChatMessage, _ delegate: MessageCellDelegate?) {
        textView.removeFromSuperview()
        attachmentView.removeFromSuperview()
        if message.attachment != nil {
            attachmentView.bind(message, delegate)
            messageViewContainer.addSubview(attachmentView)
        }
        else {
//            textView.setLongPressAction({ [weak self] gesture in
//                self?.longPressAction?(gesture)
//            })
//            textView.setUrlTapAction { [weak self] url in
//                self?.urlTapAction?(url)
//            }
//            textView.bind(message)
            messageViewContainer.addSubview(self.textView)
        }
        
        timeLabel.text = Self.createDateText(from: message)
        timeLabel.sizeToFit()
        
        if message is ClientChatMessage {
            updateStatus(message)
            timeLabel.textColor = ChatColors.appTextVeryLightGray
        }
        else {
            timeLabel.textColor = ChatColors.appTextMediumGray
        }
        
        if message is InfoChatMessage || message is OperatorChatMessage {
            statusImageView.image = nil
        }
        layoutIfNeeded()
    }
    
    private func updateStatus(_ message: ChatMessage) {
        switch message.messageStatus {
        case .DELIVERED:
            statusImageView.image = ChatImage.sentStatusImage
        case .READ:
            statusImageView.image = ChatImage.readStatusImage
        case .UNDELIVERED, .PENDING:
            statusImageView.image = nil
        }
        
        statusImageView.sizeToFit()
        layoutIfNeeded()
    }
    
    
    static func createDateText(from message: ChatMessage) -> String {
        if message.messageStatus == .UNDELIVERED, message.attachment == nil {
            return "Text.Chat.MessageNotDelivered"
        }
        else {
            return Self.formatedDate(message.timestamp)
        }
    }
    
    /**
     Форматирование даты получения сообщения.
     Для сегодня или вчера добавляется префикс и выводится только время сообщения с префиксом.
     Для дат позавчера и старше возвращается дата в формате "yyyy.MM.dd HH:mm"
     
     - parameters:
     - date: Дата для конвертации в строку
     - returns: Строковое представление даты, в соответствии с правилами для сообщений
     */
    static func formatedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        var prefix = "%@"
        if calendar.isDateInToday(date) {
            prefix = "Text.Chat.DateToday"
            dateFormatter.dateFormat = "HH:mm"
        }
        else if calendar.isDateInYesterday(date) {
            prefix = "Text.Chat.DateYesterday"
            dateFormatter.dateFormat = "HH:mm"
        }
        else {
            dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        }
        return String(format: prefix, dateFormatter.string(from: date))
    }
}
