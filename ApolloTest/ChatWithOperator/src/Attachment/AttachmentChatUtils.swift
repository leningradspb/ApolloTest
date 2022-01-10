import Foundation

class AttachmentChatUtils {
    
    /**
     Максимальный размер вложения в байтах (10мб).
     */
    private static let maxAttachmentSize = NSNumber(value: 1024*1024*10)
    
    private static let cameraPhotoType = "jpeg"
    
    private static let imageTypes: [SupportingAttachmentType] = [
        .jpeg,
        .jpg,
        .heic,
        .png,
    ]
    
    public static func isSupportedType(url: URL) -> Bool {
        return getMimeType(url: url) != nil
    }
    
    public static func getCameraMimeType() -> SupportingAttachmentType {
        return SupportingAttachmentType.jpeg
    }
    
    public static func getMimeType(ext: String) -> SupportingAttachmentType? {
        if let mimeType = SupportingAttachmentType(rawValue: ext.lowercased()) {
            return mimeType
        }
        else {
            return nil
        }
    }
    
    public static func getMimeType(url: URL) -> SupportingAttachmentType? {
        let fileName = url.lastPathComponent
        if let ext = fileName.components(separatedBy: ".").last {
            return getMimeType(ext: ext)
        }
        else {
            return nil
        }
    }
    
    public static func createPhotoName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return "IMG_\(dateFormatter.string(from: Date())).\(SupportingAttachmentType.jpeg.rawValue)"
    }
        
    public static func getContentType(_ item: AttachmentChatItem) -> AttachmentTypeDto {
        if item.imageData != nil {
            return .image
        }
        else if let url = item.url, let mimeType = getMimeType(url: url), imageTypes.first(where: { $0 == mimeType }) != nil {
            return .image
        }
        else {
            return .file
        }
    }
    
    public static func validateAttachment(_ item: AttachmentChatItem) throws {
        var attachmentSize: NSNumber = NSNumber(value: Int(truncating: maxAttachmentSize) + 1)
        if let imageData = item.imageData {
            attachmentSize = NSNumber(value: imageData.count)
        }
        else if let fileUrl = item.url,
            let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path),
            let fileSize = attributes[.size] as? NSNumber {
            attachmentSize = fileSize
            
            if SupportingAttachmentType(rawValue: fileUrl.pathExtension) == nil {
//                throw AttachmentValidationError(validationMessage: applicationStrings("Chat.ErrorMessage.File.Rejected"))
            }
        }
        else {
//            throw AttachmentValidationError(validationMessage: applicationStrings("Chat.ErrorMessage.File.Unexpected"))
        }
        
        if Float(truncating:attachmentSize) > Float(truncating: maxAttachmentSize) {
//            throw AttachmentValidationError(validationMessage: applicationStrings("Chat.ErrorMessage.File.TooLong"))
        }
    }
}
