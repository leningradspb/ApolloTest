import Foundation

/**
 Методы обратной связи поля ввода.
 
 - authors: authors: Q-ITS, Q-SHU
 */
protocol InputViewDelegate: class {
    
    /**
     Была нажата кнопка отправки сообщения.
     
     - parameters:
        - text: Введенное сообщение пользователем, может быть пустым.
     - attachedItem: файловое вложение
     */
    func didTapSendButton(text: String?, attachedItem: AttachmentChatItem?)
    
    /**
     Была нажата кнопка для прикрепления ресурса.
     */
    func didTapAttachmentButton()
    
    /**
     Пользователь вводит текст
     */
    func isTyping()
    
    func textDidChanged()
}
