import Foundation

/**
 * Информация о текущей странице истории сообщений чата
 *
 * @author Q-AFU
 */
class HistoryPage {
    
    /**
     * Курсор для получения следующей страницы истории сообщений.
     */
    public var cursor: String?
    
    /**
     * Доступна ли следующая страница истории сообщений.
     */
    public var hasNextPage: Bool
    
    init(cursor: String?, hasNextPage: Bool) {
        self.cursor = cursor
        self.hasNextPage = hasNextPage
    }
    
}
