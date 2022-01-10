import Foundation

/**
 Настройки чата включают:
 - Данные для подключения к серверу
 - Креды для авторизации
 - Данные о последней активности
 
 - author: Q-ITS
 */
public class ChatServiceSettings: NSObject {
    
    /**
     Настройки чата от сервера
     */
    public let chatSettings: ChatSettings
    
    /**
     Токен для авторизации в Омни
     */
    public let omniToken: ChatTokenForOmni
    
    /**
     Токен для подключения к сокету.
     */
    private(set) var jwtToken: String?
    
    /**
     Количество попыток переподключения к сокету
     */
    public let reconnectLimit: Int
    
    /**
     Время отображения события оператор печатает
     */
    private let operatorTypingTimeInterval: TimeInterval = 10
    
    /**
     Данные об активности.
     */
    public let activityManager: ChatActivityManager
    
    /**
     - parameters:
        - reconnectLimit: Количество попыток переподключения к сокету
        - chatSettings: Настройки чата от сервера
        - omniToken: Токен для авторизации в Омни
     */
    public init(reconnectLimit: Int, chatSettings: ChatSettings, omniToken: ChatTokenForOmni) {
        self.reconnectLimit = reconnectLimit
        self.chatSettings = chatSettings
        self.omniToken = omniToken
        self.activityManager = ChatActivityManager()
    }
    
    public func addJwtToken(_ token: String) {
        self.jwtToken = token
    }
    
    public func resetJwtToken() {
        self.jwtToken = nil
    }
}
