import Foundation
import Apollo

class OmniAuthorizationHttpTransport {
    
    typealias OneStepTokenSign = CustomerLoginOneStepWayMutation.Data.OneStepTokenSign
    
    private var provider: String {
        return "rosbank"
    }
    
    /**
     Токен клиента для получения jwtToken
     */
    private let secret: String
    
    /**
     Временной интервал для ожидания ответа из Омни
     */
    private let intervalTimeout: TimeInterval
    
    /**
     Поток в котором будут выполняться запросы apolloClient
     */
    private let threadSafeQueue: DispatchQueue
    
    /**
     Клиент для выполнения запросов авторизации
     */
    private let apolloClient: ApolloClient
    
    /**
     - parameters:
        - omniToken: Токен для авторизации и получения JWT токена
        - url: URL адрес сервера для получения одноразового токена.
     - intervalTimeout: Временной интервал для ожидания ответа из Омни
     - threadSafeQueue: Поток в котором будут выполняться запросы apolloClient
     */
    init(omniToken: String,
         url: String,
         intervalTimeout: TimeInterval,
         threadSafeQueue: DispatchQueue) {
        self.secret = omniToken
        self.intervalTimeout = intervalTimeout
        self.threadSafeQueue = threadSafeQueue
        self.apolloClient = ApolloClientCreator.createAuthenticationApolloClient(apiUrl: url, queue: threadSafeQueue)
    }
    
    /**
     Метод авторизации в один шаг.
     
     - returns: Токен для создания сессии и данные о пользователе
     - throws: Серверная ошибка.
     */
    public func loginOneStep() throws -> OneStepTokenSign {
        ChatErrorHandler.handleDebugInfo("loginOneStep start")

        let semaphore = DispatchSemaphore(value: 0)
        
        var tokenSignResult: OneStepTokenSign?
        var errorResult: Error?
        
        let request = CustomerLoginOneStepWayMutation(provider: provider, secret: secret)
        apolloClient.perform(mutation: request, queue: self.threadSafeQueue) { result in
            ChatErrorHandler.handleDebugInfo("loginOneStep completed result: '\(result)'")
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    errorResult = GraphQLResultError(errors)
                }
                else if let data = graphQLResult.data {
                    tokenSignResult = data.oneStepTokenSign
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
        
        ChatErrorHandler.handleDebugInfo("loginOneStep return tokenSignResult: '\(String(describing: tokenSignResult))', errorResult: '\(String(describing: errorResult))'")

        if let tokenSign = tokenSignResult {
            return tokenSign
        }
        else {
            throw errorResult ?? OmniChatTransportError.createFailedRequest(request)
        }
    }
}
