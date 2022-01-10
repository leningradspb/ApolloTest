import UIKit
//import RBMK

/**
 View для отображения пользовательского сообщения.
 Отделение от СontentMessageView позволяет переиспользовать логику построения контента и внешнюю оболочку.
 */
class ClientMessageView: UIView {
    
    /**
     View для отображения контента
     */
   private let contentMessageView: ContentMessageView = ContentMessageView.viewFromNib()
    
    /**
     Отступы внутри для contentMessageView
     */
    private let contentEdge = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    /**
     Сообщение для отображения.
     */
    private var message: ChatMessage?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(contentMessageView)
        contentMessageView.longPressAction = { [weak self] gesture in
            self?.handleLongPress(gesture: gesture)
        }
        contentMessageView.urlTapAction = { [weak self] url in
            self?.handleUrlTap(url: url)
        }
        backgroundColor = .gray

        layer.cornerRadius = 6
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPressGesture)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        contentMessageView.frame.origin.y = contentEdge.top
        contentMessageView.frame.origin.x = contentEdge.left
        contentMessageView.frame.size.width = frame.width - (contentEdge.left + contentEdge.right)
        contentMessageView.layoutIfNeeded()
        
        frame.size.height = contentMessageView.frame.height + (contentEdge.top + contentEdge.bottom)
        frame.size.width = contentMessageView.frame.width + (contentEdge.left + contentEdge.right)
    }
    
    func bind(_ message: ChatMessage, _ delegate: MessageCellDelegate?) {
        self.message = message
        contentMessageView.bind(message, delegate)
        
        // TODO: Разобраться с причиной "зависания" приложения при установке Accessibility
//        setAccessibility(from: message)
    }
    
    /**
     По долгому нажатию на View текст сообщения копируется в буфер.
     */
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began, let message = message {
        UIPasteboard.general.string = message.text
            let alert = UIAlertController(title: "",
                                          message: "Text.Chat.Clipboard.Notification",
                                          preferredStyle: .alert)
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            if let rootViewController = rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
              alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /**
     По нажатию на URL осуществляется переход по Deeplink или открытие ссылки в браузер
     */
    private func handleUrlTap(url: URL) {
//        if AppDelegate.appDelegate().deeplinkAction.isDeeplink(url) {
//            let absoluteUrlString = url.absoluteURL.absoluteString
//            AppDelegate.appDelegate().deeplinkAction.pushDeeplink(absoluteUrlString)
//            return
//        }
        
        guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        if comps.scheme == nil {
            comps.scheme = "https"
        }
        if let validUrl = comps.url {
            UIApplication.shared.open(validUrl)
        }
    }
    
    private func setAccessibility(from message: ChatMessage) {
        var text = ""
        if let messageText = message.text {
            text += messageText
        }
        if let attachment = message.attachment {
            // TODO
        }
        text += ". \(ContentMessageView.createDateText(from: message))"
        
        let localizedText = "Chat.ClientMessageBubble.Accessibility"
        if localizedText.contains("%@") { // "Ваше сообщение. %@"
            text = String(format: localizedText, text)
        }
        
//        let accessibility = AccessibilityComponents(type: .staticText, description: text)
//        let implementer = AccessibilityImplementer(view: self)
//        implementer.set(accessibility: accessibility)
        
        accessibilityDragSourceDescriptors = [] // убирает фразу "Доступны действия"
    }
}
