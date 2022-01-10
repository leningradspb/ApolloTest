import UIKit

class AttachmentPreviewManager: NSObject, UIDocumentInteractionControllerDelegate {
            
    private let navigationControllerForDocument: UINavigationController
    
    private var documentController: UIDocumentInteractionController?
    
    /**
     Superview of viewController that present documentsController.
     */
    private var docInteractionControllerWorkaroundSuperview: UIView?
        
    public init(navigationControllerForDocument: UINavigationController) {
        self.navigationControllerForDocument = navigationControllerForDocument
    }

    public func presentPreview(_ data: Data, _ fileName: String) {
        do {
            let url = try getResourceUrl(data, fileName)
            let documentController = UIDocumentInteractionController(url: url)
            documentController.delegate = self
            documentController.presentPreview(animated: true)
        }
        catch {
            ChatErrorHandler.handleError(error)
//            close()
        }
    }
    
    @objc public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        docInteractionControllerWorkaroundSuperview = navigationControllerForDocument.view.superview
        return navigationControllerForDocument.visibleViewController ?? UIViewController()
    }
    
    private func getResourceUrl(_ data: Data, _ fileName: String) throws -> URL {
        if let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            if let fileUrl = NSURL(fileURLWithPath:directory).appendingPathComponent(fileName) {
                try write(to: fileUrl, data: data, options: .atomic)
                return fileUrl
            }
            else {
                throw AttachmentChatError("Не удалось создать путь для файла '\(fileName)' в директории '\(directory)'")
            }
        }
        else {
            throw AttachmentChatError("Не удалось сохранить файл в временную директорию для '\(fileName)'")
        }
    }
    
    private func write(to fileUrl: URL, data: Data, options: NSData.WritingOptions) throws {
        try data.write(to: fileUrl, options: .atomic)
    }
}
