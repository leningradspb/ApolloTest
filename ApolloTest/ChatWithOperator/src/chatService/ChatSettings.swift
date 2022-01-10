import Foundation

/**
 Настройки для работы чата от сервера
 
 - author: Q-ITS
 */
public class ChatSettings {
    
    /**
     * URL точки доступа к серверу авторизации OMNI.
     */
    public let authenticationEndpointUrl: String
    
    /**
     * URL точки доступа к HTTP серверу OMNI.
     */
    public let httpServerEndpointUrl: String
    
    /**
     * URL точки доступа к WebSocket серверу OMNI.
     */
    public let webSocketServerEndpointUrl: String
    
    /**
     * Максимальная длина сообщения в чате (в символах).
     */
    public let maxMessageLength: Int
    
    /**
     * Таймаут сессии чата (в секундах).
     *
     * <p>Используется в качестве времени жизни сессии после того, как пользователь покинул страницу чата.
     * По истечение заданного таймаута - МБ завершает работу с чатом.</p>
     */
    public let sessionTimeout: Int
    
    /**
     URL для загрузки вложений в сообщениях
     */
    public let downloadAttachmentUrl: String
    
    /**
    URL для отправки вложений
    */
    public let uploadAttachmentUrl: String
    
    public init(authenticationEndpointUrl: String,
                httpServerEndpointUrl: String,
                webSocketServerEndpointUrl: String,
                downloadAttachmentUrl: String,
                uploadAttachmentUrl: String,
                maxMessageLength: Int,
                sessionTimeout: Int) {
        self.authenticationEndpointUrl = authenticationEndpointUrl
        self.httpServerEndpointUrl = httpServerEndpointUrl
        self.webSocketServerEndpointUrl = webSocketServerEndpointUrl
        self.downloadAttachmentUrl = downloadAttachmentUrl
        self.uploadAttachmentUrl = uploadAttachmentUrl
        self.maxMessageLength = maxMessageLength
        self.sessionTimeout = sessionTimeout
    }
}
