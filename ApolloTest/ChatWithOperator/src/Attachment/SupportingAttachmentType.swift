import Foundation

enum SupportingAttachmentType: String {
    case jpeg = "jpeg"
    case jpg = "jpg"
    case heic = "heic"
    case txt = "txt"
    case log = "log"
    case png = "png"
    case doc = "doc"
    case pdf = "pdf"
    case rtf = "rtf"
    case xls = "xls"
    case ppt = "ppt"
    case docx = "docx"
    case xlsx = "xlsx"
    case pptx = "pptx"
    
    func getMimeType() -> String {
        switch self {
        case .jpeg:
            return "image/jpeg"
        case .jpg:
            return "image/jpeg"
        case .heic:
            return "image/heic"
        case .txt:
            return "text/plain"
        case .log:
            return "text/plain"
        case .png:
            return "image/png"
        case .doc:
            return "application/msword"
        case .pdf:
            return "application/pdf"
        case .rtf:
            return "application/rtf"
        case .xls:
            return "application/vnd.ms-excel"
        case .ppt:
            return "application/vnd.ms-powerpoint"
        case .docx:
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .xlsx:
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .pptx:
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .log:
            #warning("не знаю как правильно")
            return "text/plain"
        }
    }
}
