import UIKit

public class AttachmentChatItem {
    
    public let name: String
    
    public let url: URL?
    
    public let imageData: Data?
        
    public init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.imageData = nil
    }
    
    public init(image: UIImage) throws {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw AttachmentChatError("Не удалось создать изображение из переданной data")
        }
        self.imageData = imageData
        self.name = AttachmentChatUtils.createPhotoName()
        self.url = nil
    }
}
