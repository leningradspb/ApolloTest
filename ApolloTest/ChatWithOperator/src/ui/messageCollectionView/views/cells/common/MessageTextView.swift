import UIKit

/**
 TextView для сообщения.
 Имеет кастомное действие по долгому нажатию.
 */
class MessageTextView: UITextView {
    
    var longPressAction: ((_: UILongPressGestureRecognizer) -> Void)?
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        longPressAction?(gestureRecognizer)
    }
    
    override open func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            super.addGestureRecognizer(longPressGestureRecognizer) 
        }
        else {
            super.addGestureRecognizer(gestureRecognizer)
        }
    }
}
