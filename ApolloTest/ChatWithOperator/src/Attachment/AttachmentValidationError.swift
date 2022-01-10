import Foundation

/**
 Ошибка валидации вложения в чате. Включает сообщения для отображения пользователю.
 
 - author: Q-ITS
 */
class AttachmentValidationError: BaseChatError {
    
    /**
     Сообщения для пользователя, можно выводить на UI.
     */
    let validationMessage: String
    
    /**
     - parameters:
        - validationMessage: Текст валидационной ошибки, может быть отображена пользователе
        - cause: Системная или техническая ошибка при валидации
     */
    public init(validationMessage: String, _ cause: Error? = nil) {
        self.validationMessage = validationMessage
        super.init(validationMessage, cause)
    }
}
