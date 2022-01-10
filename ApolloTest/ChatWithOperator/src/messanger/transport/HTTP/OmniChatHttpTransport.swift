import Foundation
import Apollo

typealias MessagesFeed = MessagesFeedQuery.Data.MessagesFeed
typealias MessageInMessagesFeed = MessagesFeedQuery.Data.MessagesFeed.Message
typealias AttachmentMessageInMessagesFeed = MessagesFeedQuery.Data.MessagesFeed.Message.Attachment
typealias PageInfoMessagesFeed = MessagesFeedQuery.Data.MessagesFeed.PageInfo

typealias FirstMessagesFeed = FirstMessagesFeedQuery.Data.MessagesFeed
typealias MessageInFirstMessagesFeed = FirstMessagesFeedQuery.Data.MessagesFeed.Message
typealias MessageAttachmentInFirstMessagesFeed = FirstMessagesFeedQuery.Data.MessagesFeed.Message.Attachment
typealias PageInfoInFirstMessagesFeed = FirstMessagesFeedQuery.Data.MessagesFeed.PageInfo

typealias ActivityInActivityGet = ActivityGetQuery.Data.Activity
typealias ActivityByFirstMessageResponse = ActivityCreateByFirstMessageMutation.Data.ActivityByFirstMessage
typealias AttachmnetMessageByActivity = ActivityCreateByFirstMessageMutation.Data.ActivityByFirstMessage.Message.Attachment

/**
 Транспорт HTTP части чата. Отвечает за авторизацию и отправку первого сообщения или создания новой сессии (socket).
 Все запросы выполняются через Apollo транспорт, но с оберткой позволяющей выполнять их синхронно (DispatchSemaphore).
 Синхронные запросы позволяют в клиентском коде выполнять последовательно запросы на создание сессии, без вложенности блоков.
 Авторизация включает несколько сценариев:
 - У пользователя уже есть открытый сокет, сообщение должно быть отправлено через сокеты
 - Сокет был закрыт или еще не создан. Сообщение отправляется через HTTP и позволяет создать новый сокет.
 
 Порядок работы с API:
 - Вызывать метод createTransport, который выполняет авторизацию и создание транспорта (CustomerLoginOneStepWayRequest);
 - Запросить историю сообщений loadMessagesFeed;
 - Если история сообщений пуста, или последняя активность не является открытой (запрос информации об активности getActivity),
 создать новую активность getActivityByFirstMessage;
 - Если активность еще активна, присоединиться к текущей активности, отправив JoinPayload и отправить сообщение в сокет.
 
 - author: Q-ITS
 */
class OmniChatHttpTransport {
    
    /**
     Клиент для отправки основных запросов связанный с активностью и сообщения, кроме получения токена сессии.
     */
    private var apolloClient: ApolloClient?
    
    /**
     Клиент для выполнения авторизационных запросов в омни.
     */
    private let authorizationHttpTransport: OmniAuthorizationHttpTransport
    
    /**
     Адрес для отправки запросов в Омни (получения данных, не авторизации)
     */
    private let omniUrl: String
    
    /**
     Адрес для прохождения процесса авторизации в Омни
     */
    private let authentificateOmniUrl: String
    
    /**
     Поток в котором будут выполняться запросы apolloClient
     */
    private let threadSafeQueue: DispatchQueue
    
    /**
     Временной интервал для ожидания ответа из Омни
     */
    private let intervalTimeout: TimeInterval
    
    /**
     Необходим для оповещения о получении JWT токена.
     JWT токен необходим для установки сокет соединения.
     */
    public var loadedJwtToken: ((String) -> Void)?
    
    /**
     - parameters:
        - omniToken: Токена для авторизации в Омни
        - omniUrl: Адрес для отправки запросов в Омни (получения данных для чата, не авторизации)
        - authentificateOmniUrl: Адрес для прохождения процесса авторизации в Омни
        - chatSettings: Глобальные настройки чата, необходимы для сохранения зависимостей полученных во время работы (jwt токен)
        - intervalTimeout: Временной интервал для ожидания ответа из Омни
     */
    public init(omniToken: String,
                omniUrl: String,
                authentificateOmniUrl: String,
                intervalTimeout: TimeInterval) {
        self.omniUrl = omniUrl
        self.authentificateOmniUrl = authentificateOmniUrl
        self.intervalTimeout = intervalTimeout
        self.threadSafeQueue = DispatchQueue(label: "OmniChatHttpTransport.Apollo.syncQueue")
        self.authorizationHttpTransport = OmniAuthorizationHttpTransport(omniToken: omniToken,
                                                                         url: authentificateOmniUrl,
                                                                         intervalTimeout: intervalTimeout,
                                                                         threadSafeQueue: threadSafeQueue)
    }
    
    private func getApolloClient() throws -> ApolloClient {
        guard let apolloClient = apolloClient else {
            throw OmniChatTransportError("Пользователь не авторизован")
        }
        return apolloClient
    }
    
    public func authorize() throws {
        if apolloClient == nil {
            let tokenSign = try authorizationHttpTransport.loginOneStep()
            if let token = tokenSign.token {
                loadedJwtToken?(token)
                apolloClient = ApolloClientCreator.createApolloClient(token: token, apiUrl: omniUrl, queue: threadSafeQueue)
            }
            else {
                throw OmniChatTransportError("Отсутствует одноразовый token для заголовка запросов в \(tokenSign)")
            }
        }
    }
    
    /**
     Отправка первого сообщения для открытия сокета.
     
     - parameters:
     - message: Текст сообщения пользователя для отправки на сервер.
     - returns: Данные о активности пользователя, позволяющие открыть сокет для последующих сообщений.
     - throws: Серверная ошибка
     */
    public func getActivityByFirstMessage(message: String) throws -> ActivityByFirstMessage? {
        ChatErrorHandler.handleDebugInfo("getActivityByFirstMessage started")
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = ActivityCreateByFirstMessageMutation(channelIdentifier: "chatevoios", message: message)
        
        var activityResult: ActivityByFirstMessageResponse?
        var errorResult: Error?
        try getApolloClient().perform(mutation: request, queue: .global()) { result in
            ChatErrorHandler.handleDebugInfo("getActivityByFirstMessage completed result: '\(result)'")
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    errorResult = GraphQLResultError(errors)
                }
                else if let data = graphQLResult.data {
                    activityResult = data.activityByFirstMessage
                }
                else {
                    errorResult = GraphQLResultError.createUnexpectedError(graphQLResult)
                }
            case .failure(let error):
                errorResult = error
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + intervalTimeout)

        ChatErrorHandler.handleDebugInfo("getActivityByFirstMessage return activityResult: '\(String(describing: activityResult))', errorResult: '\(String(describing: errorResult))'")
        
        if let activity = activityResult {
            return ActivityByFirstMessage(activity: activity)
        }
        else {
            throw errorResult ?? OmniChatTransportError.createFailedRequest(request)
        }
    }
    
    /**
     Загрузка списка последних сообщений пользователя, в максимальном количестве: 50.
     Последнее сообщение хранит идентификатор сесии пользователя, которая может быть еще активна.
     
     - parameters:
        - offset: Идентификатор первого загруженного сообщения с сервера (самое старое)
        - limit: Количество подгружаемых сообщений с сервера, по умолчанию 50 (max = 50).
     - returns: Список сообщений, может быть пустым или nil, если история пуста.
     - throws: Серверная ошибка
     */
    public func loadMessagesFeed(offsetMessageId: String? = nil, limit: Int = 50) throws -> HistoryMessages? {
        if let offsetMessageId = offsetMessageId {
            return try loadHistoryMessagesFeed(offsetMessageId: offsetMessageId, limit: limit)
        }
        else {
            return try loadHistoryFirstMessagesFeed(limit: limit)
        }
    }
    
    private func loadHistoryMessagesFeed(offsetMessageId: String, limit: Int) throws -> HistoryMessages? {
        ChatErrorHandler.handleDebugInfo("loadHistoryMessagesFeed start offsetMessageId: '\(offsetMessageId)', limit: '\(limit)'")
        let semaphore = DispatchSemaphore(value: 0)
        
        var messagesResult: MessagesFeed?
        var errorResult: Error?
        
        let request = MessagesFeedQuery(cursor: offsetMessageId, limit: limit)
        try getApolloClient().fetch(query: request,
                                    cachePolicy: CachePolicy.fetchIgnoringCacheData,
                                    queue: .global()) { result in
                                        ChatErrorHandler.handleDebugInfo("loadHistoryMessagesFeed completed result: '\(result)'")
                                        switch result {
                                        case .success(let graphQLResult):
                                            if let errors = graphQLResult.errors {
                                                errorResult = GraphQLResultError(errors)
                                            }
                                            else if let data = graphQLResult.data {
                                                messagesResult = data.messagesFeed
                                            }
                                            else {
                                                errorResult = GraphQLResultError.createUnexpectedError(graphQLResult)
                                            }
                                        case .failure(let error):
                                            errorResult = error
                                        }
                                        semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + intervalTimeout)
        
        ChatErrorHandler.handleDebugInfo("loadHistoryMessagesFeed return messagesResult: '\(String(describing: messagesResult))', errorResult: '\(String(describing: errorResult))'")
        if let result = messagesResult {
            guard let messages = result.messages?.map({ ChatMessageConverter.convert(message: ($0))}),
                let historyPage = HistoryPageConverter.convert(page: result.pageInfo)
                else {
                    throw OmniChatTransportError("Ошибка десериализации ответа сервера '\(result)'")
            }
            
            return HistoryMessages(messages: messages, pageInfo: historyPage)
        }
        else {
            throw errorResult ?? OmniChatTransportError.createFailedRequest(request)
        }
    }
    
    private func loadHistoryFirstMessagesFeed(limit: Int) throws -> HistoryMessages? {
        ChatErrorHandler.handleDebugInfo("loadHistoryFirstMessagesFeed start limit: '\(limit)'")

        let semaphore = DispatchSemaphore(value: 0)
        
        var messagesResult: FirstMessagesFeed?
        var errorResult: Error?
        
        let request = FirstMessagesFeedQuery(limit: limit)
        try getApolloClient().fetch(query: request,
                                    cachePolicy: CachePolicy.fetchIgnoringCacheData,
                                    queue: DispatchQueue.global()) { result in
                                        ChatErrorHandler.handleDebugInfo("loadHistoryFirstMessagesFeed completed result: '\(result)'")
                                        switch result {
                                        case .success(let graphQLResult):
                                            if let errors = graphQLResult.errors {
                                                errorResult = GraphQLResultError(errors)
                                            }
                                            else if let data = graphQLResult.data {
                                                messagesResult = data.messagesFeed
                                            }
                                            else {
                                                errorResult = GraphQLResultError.createUnexpectedError(graphQLResult)
                                            }
                                        case .failure(let error):
                                            errorResult = error
                                        }
                                        semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + intervalTimeout)
        
        ChatErrorHandler.handleDebugInfo("loadHistoryFirstMessagesFeed return messagesResult: '\(String(describing: messagesResult))', errorResult: '\(String(describing: errorResult))'")
        if let result = messagesResult {
            guard let messages = result.messages?.map({ ChatMessageConverter.convert(message: ($0))}),
                let historyPage = HistoryPageConverter.convert(page: result.pageInfo)
                else {
                    throw OmniChatTransportError("Ошибка десериализации ответа сервера '\(result)'")
            }
            
            return HistoryMessages(messages: messages, pageInfo: historyPage)
        }
        else {
            throw errorResult ?? OmniChatTransportError.createFailedRequest(request)
        }
    }
    
    /**
     Получение данных о переданной активности.
     Активной считается только "pending" и "in_progress".
     
     - parameters:
        - id: Идентификатор активности
     - returns: Данные о активности.
     - throws: Серверная ошибка
     */
    public func getActivity(id: String) throws -> Activity? {
        ChatErrorHandler.handleDebugInfo("getActivity start id: '\(id)'")

        let semaphore = DispatchSemaphore(value: 0)
        
        var activityResult: ActivityInActivityGet?
        var errorResult: Error?
        
        let request = ActivityGetQuery(id: id)
        try getApolloClient().fetch(query: request,
                                    cachePolicy: CachePolicy.fetchIgnoringCacheData,
                                    queue: DispatchQueue.global()) { result in
                                        ChatErrorHandler.handleDebugInfo("getActivity completed result: '\(result)'")
                                        switch result {
                                        case .success(let graphQLResult):
                                            if let errors = graphQLResult.errors {
                                                errorResult = GraphQLResultError(errors)
                                            }
                                            else if let data = graphQLResult.data {
                                                activityResult = data.activity
                                            }
                                            else {
                                                errorResult = GraphQLResultError.createUnexpectedError(graphQLResult)
                                            }
                                        case .failure(let error):
                                            errorResult = error
                                        }
                                        semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + intervalTimeout)
        
        ChatErrorHandler.handleDebugInfo("loadHistoryFirstMessagesFeed return activityResult: '\(String(describing: activityResult))', errorResult: '\(String(describing: errorResult))'")

        if let activity = activityResult {
            return ActivityConverter.convert(activity)
        }
        else {
            throw errorResult ?? OmniChatTransportError.createFailedRequest(request)
        }
    }
}
