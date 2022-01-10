import Foundation
import Apollo

/**
 Клиентское представление библиотечной ошибки GraphQL ([GraphQLError]).
 Ошибка GraphQLResult включает список ошибок, а не одну ошибку.
 
 - author: Q-ITS
 */
public class GraphQLResultError: OmniChatTransportError {
    
    /**
     Ошибка GraphQLResult включает список ошибок, а не одну ошибку.
     */
    public let errors: [GraphQLError]
    
    /**
     - parameters:
        - errors: Список ошибок полученных в рамках ответа библиотеки Apollo
     */
    public init(_ errors: [GraphQLError]) {
        self.errors = errors
        super.init(errors.description)
    }
    
    /**
    - parameters:
       - message: Описание ошибки при пустом списке errors в result библиотеки Apollo.
    */
    public init(_ message: String) {
        self.errors = []
        super.init(message)
    }
    
    /**
     Создание непредвиденной ошибки в результате ответа библиотеки Apollo.
     Result включает в себя опциональные errors и data. При отсуствии их мы обрабатываем эту ситуацию как непредвиденную.
     
     - paramers:
        - response: Описание ответа библиотеки Apollo.
     */
    static func createUnexpectedError<Data>(_ response: (GraphQLResult<Data>)) -> GraphQLResultError {
        return GraphQLResultError("Не удалось получить результат из '\(response)'")
    }
}
