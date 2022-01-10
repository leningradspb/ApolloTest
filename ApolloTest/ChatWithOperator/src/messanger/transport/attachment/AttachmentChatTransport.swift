import Foundation
import Alamofire

typealias AttachmentLoadingHandler = (Swift.Result<Data, Error>) -> Void
typealias AttachmentUploadingHandler = (Error?) -> Void

class AttachmentChatTransport {
    
    enum RequestKey: String {
        case temporaryId = "temporary_id"
        case activityId = "activity_id"
        case attachment = "attachment"
        case authorization = "authorization"
    }
    
    private var loadingAttachments: [URL : [AttachmentLoadingHandler?]] = [:]
    
    private var uploadingAttachments: [String : AttachmentUploadingHandler?] = [:]
    
    private let chatSettings: ChatSettings
    
    public weak var delegate: AttachmentChatTransportDelegate?
    
    /**
     Список отправляемых сообщений пользователем.
     На каждом сообщении висит таймер, если ответ от сервера не придет до окончания данного таймера, сообщение считается не доставленым.
     При получении ответа сервера, сравнивается ключ sendingMessages с messageId (refId) ответа, для мержинга клиентского сообщения и полученного.
     */
    private var sendingMessages: [String : String?] = [:]
    
    init(_ chatSettings: ChatSettings) {
        self.chatSettings = chatSettings
    }
    
    public func upload(_ item: AttachmentChatItem,
                       activityId: String,
                       jwtToken: String,
                       completionHandler: @escaping AttachmentUploadingHandler) throws -> ChatMessage {
        guard let activityIdData = activityId.data(using: .utf8) else {
            let causeError = AttachmentChatError("Не удалось представить activityId '\(activityId)' в виде Data")
            throw AttachmentValidationError(validationMessage: ChatLocalization.getDownloadAttachmentUserError(), causeError)
        }
        
        let temporaryId = "\(UUID().uuidString)"
        guard let temporaryIdData = temporaryId.data(using: .utf8) else {
            let causeError = AttachmentChatError("Не удалось представить temporaryId '\(temporaryId)' в виде Data")
            throw AttachmentValidationError(validationMessage: ChatLocalization.getDownloadAttachmentUserError(), causeError)
        }
        
        if let imageData = item.imageData {
            upload(imageData,
                   fileName: item.name,
                   jwtToken: jwtToken,
                   activityId: activityIdData,
                   temporaryId: temporaryIdData,
                   temporaryIdString: temporaryId,
                   completionHandler: completionHandler)
        }
        else if let url = item.url {
            upload(url,
                   fileName: item.name,
                   jwtToken: jwtToken,
                   activityId: activityIdData,
                   temporaryId: temporaryIdData,
                   temporaryIdString: temporaryId,
                   completionHandler: completionHandler)
        }
        else {
            throw AttachmentChatError("Переданное вложение не содержит данные изображения или url для файла")
        }
        
        let sendingMessage = ClientChatMessage.createAttachmentSendingMessage(temporaryId: temporaryId, AttachmentDto(item: item))
        
        sendingMessages[temporaryId] = sendingMessage.clientMessageId
        DispatchQueue.main.async {
            let deallocTimer = DefaultLifecycleTimer(timeInterval: 30) { [weak self] in
                if let messageId = self?.sendingMessages[temporaryId] as? String {
                    self?.delegate?.errorSendMessage(clientMessageId: messageId)
                }
                self?.sendingMessages.removeValue(forKey: temporaryId)
            }
            deallocTimer.start()
        }
        
        return sendingMessage
    }
    
    private func upload(_ fileUrl: URL,
                        fileName: String,
                        jwtToken: String,
                        activityId: Data,
                        temporaryId: Data,
                        temporaryIdString: String,
                        completionHandler: @escaping AttachmentUploadingHandler) {
        let url = chatSettings.uploadAttachmentUrl
        let headers = createUploadHeaders(jwtToken: jwtToken)
        addUploadingHandler(temporaryIdString, completionHandler)
        
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(temporaryId, withName: RequestKey.temporaryId.rawValue)
//            multipartFormData.append(activityId, withName: RequestKey.activityId.rawValue)
//            multipartFormData.append(fileUrl, withName: "attachment", fileName: fileName, mimeType: "")
//        },
//                         to: url,
//                         method: .post,
//                         headers: headers) { [weak self] result in
//                            switch result {
//                            case .success(request: _, streamingFromDisk: _, streamFileURL: _):
//                                self?.notifySuccessUploading(temporaryIdString)
//                            case .failure(let error):
//                                self?.notifyErrorUploading(temporaryIdString, error: error)
//                            }
//        }
    }
    
    private func upload(_ imageData: Data,
                        fileName: String,
                        jwtToken: String,
                        activityId: Data,
                        temporaryId: Data,
                        temporaryIdString: String,
                        completionHandler: @escaping AttachmentUploadingHandler) {
        let url = chatSettings.uploadAttachmentUrl
        let headers = createUploadHeaders(jwtToken: jwtToken)
        addUploadingHandler(temporaryIdString, completionHandler)
        
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(temporaryId, withName: RequestKey.temporaryId.rawValue)
//            multipartFormData.append(activityId, withName: RequestKey.activityId.rawValue)
//            multipartFormData.append(imageData,
//                                     withName: RequestKey.attachment.rawValue,
//                                     fileName: fileName,
//                                     mimeType: AttachmentChatUtils.getCameraMimeType().rawValue)
//        },
//                         to: url,
//                         method: .post,
//                         headers: headers) { [weak self] result in
//                            switch result {
//                            case .success(request: _, streamingFromDisk: _, streamFileURL: _):
//                                self?.notifySuccessUploading(temporaryIdString)
//                            case .failure(let error):
//                                self?.notifyErrorUploading(temporaryIdString, error: error)
//                            }
//        }
    }
    
    public func download(_ original: String, completionHandler: @escaping AttachmentLoadingHandler) {
        let path = (chatSettings.downloadAttachmentUrl + original).replacingOccurrences(of: "//", with: "/")
        guard let url = URL(string: path) else {
            return
        }
                
        if !isLoading(url) {
//            let request = Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
//            request.responseData { [weak self] response in
//                if let data = response.data {
//                    self?.notifySuccessLoading(url, data: data)
//                }
//                else if let error = response.error {
//                    self?.notifyErrorLoading(url, error: error)
//                }
//                else {
//                    let error = AttachmentChatError("В ответе на загрузку файла отсутствует ошибка или данные для отображения \(response.debugDescription)")
//                    self?.notifyErrorLoading(url, error: error)
//                }
//            self.removeLoadingHandler(url)
//            }
        }
        
//        addLoadingHandler(url, completionHandler)
    }
    
    private func createUploadHeaders(jwtToken: String) -> [String: String] {
        return [
            RequestKey.authorization.rawValue : "Bearer \(jwtToken)"
        ]
    }
    
    private func isLoading(_ url: URL) -> Bool {
        return loadingAttachments[url]?.isEmpty == true
    }
    
    private func addLoadingHandler(_ url: URL, _ handler: @escaping AttachmentLoadingHandler) {
        var handlers = loadingAttachments[url]
        if handlers == nil {
            handlers = [handler]
        }
        else {
            handlers?.append(handler)
        }
        loadingAttachments[url] = handlers
    }
    
    private func removeLoadingHandler(_ url: URL) {
        loadingAttachments.removeValue(forKey: url)
    }
    
    private func notifySuccessLoading(_ url: URL, data: Data) {
        loadingAttachments[url]?.forEach({ $0?(.success(data)) })
    }
    
    private func notifyErrorLoading(_ url: URL, error: Error) {
        loadingAttachments[url]?.forEach({ $0?(.failure(error)) })
    }
    
    private func addUploadingHandler(_ temporyId: String, _ handler: @escaping AttachmentUploadingHandler) {
        uploadingAttachments[temporyId] = handler
    }
    
    private func removeUploadingHandler(_ temporyId: String) {
        uploadingAttachments.removeValue(forKey: temporyId)
    }
    
    private func notifySuccessUploading(_ temporyId: String) {
        let handler = uploadingAttachments[temporyId]
        handler??(nil)
    }
    
    private func notifyErrorUploading(_ temporyId: String, error: Error) {
        let handler = uploadingAttachments[temporyId]
        handler??(error)
    }
}
