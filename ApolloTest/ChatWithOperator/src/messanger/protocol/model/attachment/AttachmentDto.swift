import Foundation

/**
 Объект приложенного файла
 
 - author: Q-ITS
 */
public class AttachmentDto {
    
    /**
     Полная название файла включая расширение
     */
    public let title: String
    
    /**
     Расширение файла (прим. `.exe`)
     */
    public let ext: String
    
    /**
     Тип файла для отображения
     */
    public let type: AttachmentTypeDto
    
    /**
     Если `type` равен `image`, будет доступно URL для миниатюры
     */
    public let preview: String?
    
    /**
     URL для загрузки
     */
    public let original: String?
    
    /**
     Размер файла в байтах
     */
    public let size: Int?
    
    public init(title: String,
                ext: String,
                type: AttachmentTypeDto,
                preview: String?,
                original: String?,
                size: Int?) {
        self.title = title
        self.ext = ext
        self.type = type
        self.preview = preview
        self.original = original
        self.size = size
    }
    
    public convenience init(item: AttachmentChatItem) {
        self.init(title: item.name,
                  ext: item.name.components(separatedBy: ".").last ?? "",
                  type: AttachmentChatUtils.getContentType(item),
                  preview: nil,
                  original: nil,
                  size: nil)
    }
    
    public func getDebugInfo() -> String {
        return """
        title: '\(title)'
        ext: '\(ext)'
        type: '\(type)'
        preview: '\(String(describing: preview))'
        original: '\(original)'
        size: '\(size)'
        """
    }
}
