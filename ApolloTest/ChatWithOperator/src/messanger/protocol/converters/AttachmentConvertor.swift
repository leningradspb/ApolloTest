import Foundation

class AttachmentConvertor {
    
    static func convertToMessageAttachment(_ attachment: AttachmnetMessageByActivity) -> AttachmentDto? {
        return convert(ext: attachment.ext!,
                       preview: attachment.preview!,
                       original: attachment.original!,
                       size: attachment.size!,
                       title: attachment.title!,
                       type: attachment.type!)
    }
    
    static func convertToMessageAttachment(_ attachment: MessageAttachmentInFirstMessagesFeed) -> AttachmentMessageInMessagesFeed? {
        return AttachmentMessageInMessagesFeed(ext: attachment.ext,
                                               original: attachment.original,
                                               preview: attachment.preview,
                                               size: attachment.size,
                                               title: attachment.title,
                                               type: attachment.type)
    }
    
    static func convert(_ attachment: AttachmentMessageInMessagesFeed) -> AttachmentDto? {
        return convert(ext: attachment.ext!,
                       preview: attachment.preview!,
                       original: attachment.original!,
                       size: attachment.size!,
                       title: attachment.title!,
                       type: attachment.type!)
    }
    
    static func convert(_ payload: [String: Any]) -> AttachmentDto? {
        guard let ext = payload["ext"] as? String,
            let preview = payload["preview"] as? String,
            let original = payload["original"] as? String,
            let size = payload["size"] as? Int,
            let title = payload["title"] as? String,
            let type = payload["type"] as? String else {
                ChatErrorHandler.handleError(BaseChatError("Полученный payload не соответствует ожидаемой cтруктуре, payload: '\(payload)'"))
                return nil
        }
        return convert(ext: ext,
                       preview: preview,
                       original: original,
                       size: size,
                       title: title,
                       type: type)
    }
    
    
    private static func convert(ext: String,
                                preview: String,
                                original: String,
                                size: Int,
                                title: String,
                                type: String) -> AttachmentDto? {
        let attachmentType: AttachmentTypeDto
        switch type {
        case "file":
            attachmentType = .file
        case "image":
            attachmentType = .image
        default:
            ChatErrorHandler.handleError(BaseChatError("Получен Message с неизвестным типом '\(String(describing: type))'"))
            return nil
        }
        return AttachmentDto(title: title,
                             ext: ext,
                             type: attachmentType,
                             preview: preview,
                             original: original,
                             size: size)
    }
}
