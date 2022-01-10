import Foundation

/**
 Счетчик количества переподключений к сокету.
 
 Перед началом переподключения необходимо проверить доступность переподключения isAvailable(),
 если переподкючение доступно добавить новую попытку переподключения методом add().
 
 После успешного переподключения необходимо вызвать clear(), для очистки попыток переподключения.
 
 - author: Q-ITS
 */
class OmniChatSocketReconnectCounter {
    
    private var counter = [String: Int]()
    
    private let limit: Int
    
    init(reconnectLimit: Int) {
        self.limit = reconnectLimit
    }
    
    /**
     Доступно ли переподключение для переданной активности
     
     - parameters:
        - activityId: Идентификатор активности для которой выполняется переподключени
     - returns: true - лимит попыток переподключение для переданной активности не исчерпан, false - лимит попыток испчерпан
     */
    public func isAvailable(_ activityId: String) -> Bool {
        return counter[activityId] ?? 0 <= limit
    }
    
    /**
     Добавление попытки переподключения для переданной активности
     
     - parameters:
        - activityId: Идентификатор активности для которой выполняется переподключени
     */
    public func add(_ activityId: String) {
        if var count = counter[activityId] {
            count += 1
            counter[activityId] = count
        }
        else {
            counter[activityId] = 1
        }
    }
    
    /**
     Очистить количества попыток переподключения для всех активностей.
     */
    public func clear() {
        counter = [:]
    }
    
}
