import UIKit

/**
 View для ввода сообщения. Поддерживает авторасширение поля ввода.
 Минимальную/максимальную высоту поля ввода можно указать через minTextViewHeight/maxTextViewHeight. По умолчанию 30pt (1 строка).
 При превышении максимальной высоты, поле начинает скролится.
 
  - authors: Q-ITS, Q-SHU
 */
class InputMessageView: UIView, UITextViewDelegate {
    
    /**
     Контейнер для поля ввода, кнопки отправить и вложения. Имеет скругленные края и тень.
     */
    @IBOutlet weak var textViewContainer: ShadowView!
    
    /**
     Текстовое поле для ввода сообщения.
     */
    @IBOutlet weak var textView: UITextView!
    
    /**
     Кнопка отправки сообщения.
     */
    @IBOutlet private weak var sendButton: UIButton!
    
    /**
     Label для отображения placeholder. Используется, поскольку используется textView, а не TextField.
     */
    @IBOutlet private weak var placeholderLabel: UILabel!
    
    /**
     Высота поля для ввода сообщения. Изменяется в пределах minTextViewHeight/maxTextViewHeight.
     */
    @IBOutlet weak var textViewConstraintsHeight: NSLayoutConstraint!
            
    /**
     Кнопка добавления вложения к сообщению
     */
    @IBOutlet private weak var attachmentButton: UIButton!
        
    @IBOutlet private weak var attachmentInfoView: UIView!
    
    @IBOutlet private weak var attachmentBackgroundView: UIView!
    
    @IBOutlet private weak var attachmentInfoLabel: UILabel!
    
    @IBOutlet private weak var deleteAttachmentButton: UIButton!
    
    /**
     Обратная связь о события в поле ввода.
     */
    public weak var delegate: InputViewDelegate?
    
    /**
     Минимальная высота поля ввода
     */
    public var minTextViewHeight: CGFloat = 30.0
    
    /**
     Максимальная высота поля ввода, после которой текст можно будет скролить.
     */
    public let maxTextViewHeight: CGFloat = 120.0
    
    private let attachmentButtonSize = CGSize(width: 48, height: 48)
    
    private var maxTextLength = 10
    
    private var attachedItem: AttachmentChatItem?
    
    private var attachmentAvailable: Bool = false
    
    private var attachmentIsEnabled: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.tintColor = .gray
        textView.font = ChatFonts.body1
        
        placeholderLabel.text = "Text.Chat.InputHint"
        placeholderLabel.textColor = ChatColors.appTextLightGray
        placeholderLabel.font = ChatFonts.tiny

        textViewContainer.layer.cornerRadius = 24
        textViewContainer.backgroundColor = .white
        textViewContainer.layer.shadowColor = ChatColors.appBlack.cgColor
        textViewContainer.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        textViewContainer.layer.shadowOpacity = 0.15
        textViewContainer.layer.shadowRadius = 2.0
        
        attachmentBackgroundView.backgroundColor = ChatColors.appLightGray
        attachmentBackgroundView.layer.cornerRadius = 20
        
        updateTextViewHeight()
        minTextViewHeight = textView.frame.height
        
        textView.delegate = self
        textView.isScrollEnabled = false
        
        deleteAttachmentButton.setImage(UIImage(named: "chat_remove_attachment"), for: .normal)
        configureUIAfterChangedText()
        
        attachmentButton.accessibilityLabel = ""
        sendButton.accessibilityLabel = ""
        deleteAttachmentButton.accessibilityLabel = ""
    }
    
    public func configure(attachEnabled: Bool, maxTextLength: Int, minTextViewHeight: CGFloat = 30.0, maxTextViewHeight: CGFloat = 120.0) {
        self.attachmentAvailable = attachEnabled
        setAttachButton(isEnabled: false)
        self.maxTextLength = maxTextLength
    }
    
    public func updateAttachmentButton(isEnabled: Bool) {
        setAttachButton(isEnabled: (attachmentAvailable && isEnabled))
        attachmentIsEnabled = isEnabled
    }
    
    public func addAttachment(_ item: AttachmentChatItem) {
        attachedItem = item
        configureSendButton()
    }
    
    public func clearAttachment() {
        attachedItem = nil
        configureSendButton()
    }
    
    public func isAttached() -> Bool {
        return (attachedItem != nil)
    }

    @IBAction func didTapSendButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didTapSendButton(text: self.getInputText(), attachedItem: self.attachedItem)
                self.textView.text = ""
                self.attachedItem = nil
            }
            self.configureUIAfterChangedText()
        }
    }
    
    @IBAction func didTapAttachmentButton(_ sender: Any) {
        delegate?.didTapAttachmentButton()
    }
    
    @IBAction func didTapDeleteAttachment(_ sender: Any) {
        clearAttachment()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        configureUIAfterChangedText()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count > maxTextLength {
            textView.text = newText.substring(to: String.Index(encodedOffset: maxTextLength))
            configureUIAfterChangedText()
            return false
        }
        else {
            return true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        sendButton.isHidden = false
        delegate?.isTyping()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        configureSendButton()
        configurePlaceholder()
        delegate?.isTyping()
    }
    
    private func isSendButtonAvailable() -> Bool {
        return (getInputText() != nil) || isAttached()
    }
    
    private func getInputText() -> String? {
        let text = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
    
    private func configureUIAfterChangedText() {
        delegate?.textDidChanged()
        updateTextViewHeight()
        configureSendButton()
        configurePlaceholder()
    }
    
    private func configurePlaceholder() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func configureSendButton() {
        if isSendButtonAvailable() {
            sendButton.setImage(ChatImage.sendImageActive, for: .normal)
            sendButton.isUserInteractionEnabled = true
        }
        else {
            sendButton.setImage(ChatImage.sendImageInactive, for: .normal)
            sendButton.isUserInteractionEnabled = false
        }
        
        if isAttached() {
            attachmentButton.isEnabled = false
            attachmentInfoView.isHidden = false
            attachmentInfoLabel.text = attachedItem?.name
            accessibilityElements = [attachmentButton!, attachmentInfoLabel!, deleteAttachmentButton!, placeholderLabel!, textView!, sendButton!]
        }
        else {
            attachmentButton.isEnabled = attachmentAvailable && attachmentIsEnabled
            attachmentInfoView.isHidden = true
            accessibilityElements = [attachmentButton!, placeholderLabel!, textView!, sendButton!]
        }
    }
    
    private func setAttachButton(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.attachmentButton.isEnabled = isEnabled
        }
    }
    
    private func updateTextViewHeight() {
        let maxWidth = textView.frame.inset(by: textView.textContainerInset).width - 2 * textView.textContainer.lineFragmentPadding
        let newSize = calculateSizeFor(messageText: textView.text, fixedWidth: maxWidth, font: textView.font!)
        let textInset = textView.textContainerInset.top + textView.textContainerInset.bottom
        textView.isScrollEnabled = max(minTextViewHeight, newSize.height + textInset) > maxTextViewHeight
        textViewConstraintsHeight.constant = min(max(minTextViewHeight, newSize.height + textInset), maxTextViewHeight)
    }
    
    private func calculateSizeFor(messageText: String, fixedWidth: CGFloat, font: UIFont) -> CGSize {
        let boundingRect = messageText.boundingRect(with: CGSize(width: fixedWidth, height: .greatestFiniteMagnitude),
                                                    options: .usesLineFragmentOrigin,
                                                    attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font]),
                                                    context: nil)
        return CGSize(width: boundingRect.width.rounded(.awayFromZero), height: boundingRect.height.rounded(.awayFromZero))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
