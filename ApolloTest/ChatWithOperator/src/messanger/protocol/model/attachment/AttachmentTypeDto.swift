import Foundation

/**
 Тип файла для отображения
 
 ВАЖНО: в оригинальном протоколе представлен в виде String, но в объектной модели для удобства используется enum.
 
 - author: Q-ITS
 */
public enum AttachmentTypeDto {
    
    /**
     Тип ресурса-изображение
     */
    case image
    
    /**
     Произвольный файл
     */
    case file
}
