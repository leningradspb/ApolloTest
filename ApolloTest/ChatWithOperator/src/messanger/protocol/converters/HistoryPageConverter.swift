import Foundation

/**
 Конвертирует PageInfoMessagesFeed или PageInfoinFirstMessagesFeed в клиентскую модель HistoryPage
 
 @author Q-ITS
 */
class HistoryPageConverter {
    
    static public func convert(page: PageInfoMessagesFeed?) -> HistoryPage? {
        if let hasNextPage = page?.hasNextPage {
            return HistoryPage(cursor: page?.cursor, hasNextPage: hasNextPage)
        }
        else {
            return nil
        }
    }
    
    static public func convert(page: PageInfoInFirstMessagesFeed?) -> HistoryPage? {
        if let hasNextPage = page?.hasNextPage {
            return HistoryPage(cursor: page?.cursor, hasNextPage: hasNextPage)
        }
        else {
            return nil
        }
    }
}

