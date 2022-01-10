import Foundation

/**
 Реализует локализацию текстовых сообщений для чата.
 
 - author: Q-ITS
 - author: Q-SHU
 */
class ChatLocalization {
    
    public static func getOperatorFoundMessagePattern() -> String {
        return "Вам ответит"
    }
    
    public static func getOperatorLeftMessage() -> String {
        return "Оператор неактивен"
    }
    
    public static func getOperatorTypingText() -> String {
        return "Оператор печатает…"
    }
    
    public static func getAttachmentCancel() -> String {
        return "Отмена"
    }
    
    public static func getAttachmentSelectFromLibrary() -> String {
        return "Выбрать из библиотеки"
    }
    
    public static func getAttachmentSelectFromGalery() -> String {
        return "Выбрать из галереи"
    }
    
    public static func getAttachmentCreatePhoto() -> String {
        return "Сделать фотографию"
    }
    
    public static func getDownloadAttachmentUserError() -> String {
        return "Не удалось загрузить вложение, попробуйте еще раз"
    }
    
    public static func getCameraAccessError() -> String {
        return "Для использования данной функции предоставьте приложению доступ к камере в настройках устройства"
    }

    public static func getPhotoLibraryAccessError() -> String {
        return "Для использования данной функции предоставьте приложению доступ к галерее в настройках устройства"
    }
    
    public static func getAccessSettings() -> String {
        return "Настройки"
    }
}
