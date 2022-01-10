import Foundation
import Apollo

/**
 Класс включает логику создания клиентов для выполнения запросов в Омни на основе библиотеки Apollo.
 
 - author: Q-ITS
 */

class CustomInterceptor: ApolloInterceptor {
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
//        request.addHeader(name: "Authorization", value: "Bearer <<TOKEN>>")
        
        print("request :\(request)")
        print("response :\(String(describing: response))")
        
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
    }
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(CustomInterceptor(), at: 0)
        return interceptors
    }
}

public class ApolloClientCreator {
    
    /**
     Создание клиента для выполнения запросов в Омни (не включая авторизацию.
    
    - parameters:
        - token: Токен для выполнения подключения к Омни
        - url: URL адрес сервера для получения одноразового токена.
        - queue: Очередь в рамках которой будут выполняться запросы
    */

    
    public static func createApolloClient(token: String, apiUrl: String, queue: DispatchQueue) -> ApolloClient {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "OmniChatHttpTransport.ApolloClient.\(UUID().uuidString)")
        sessionConfiguration.httpAdditionalHeaders = ["authorization" : "Bearer \(token)"]
        let sessionClient = createSessionClient(sessionConfiguration, queue)
//        let networkTransport = HTTPNetworkTransport(url: URL(string: apiUrl)!, client: sessionClient)
////        DefaultInterceptorProvider
//
////        return  ApolloClient(networkTransport: networkTransport, store: apolloStore)
//        return ApolloClient(networkTransport: networkTransport)
        
        let cache = InMemoryNormalizedCache()
                let store1 = ApolloStore(cache: cache)
                let authPayloads = ["authorization" : "Bearer \(token)"]
                let configuration = URLSessionConfiguration.background(withIdentifier: "OmniChatHttpTransport.ApolloClient.\(UUID().uuidString)")
                configuration.httpAdditionalHeaders = authPayloads
                
                let client1 = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
                let provider = NetworkInterceptorProvider(client: client1, shouldInvalidateClientOnDeinit: true, store: store1)
        
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                 endpointURL: URL(string: apiUrl)!)
        
        return ApolloClient(networkTransport: requestChainTransport,
                            store: store1)
    }
    
    /**
     Создание клиента для выполнения авторизации в Омни.
     
     - parameters:
        - url: URL адрес сервера для получения одноразового токена.
        - queue: Очередь в рамках которой будут выполняться запросы
     */
    public static func createAuthenticationApolloClient(apiUrl: String, queue: DispatchQueue) -> ApolloClient {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "OmniChatHttpTransport.AuthenticationApolloClient.\(UUID().uuidString)")
        let sessionClient = createSessionClient(sessionConfiguration, queue)
//        let networkTransport = HTTPNetworkTransport(url: URL(string: apiUrl)!, client: sessionClient)
//        return ApolloClient(networkTransport: networkTransport)
        
        let cache = InMemoryNormalizedCache()
                let store1 = ApolloStore(cache: cache)
//                let authPayloads = ["Authorization": "Bearer <<TOKEN>>"]
                let configuration = URLSessionConfiguration.default
//                configuration.httpAdditionalHeaders = authPayloads
                
                let client1 = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
                let provider = NetworkInterceptorProvider(client: client1, shouldInvalidateClientOnDeinit: true, store: store1)
        
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                 endpointURL: URL(string: apiUrl)!)
        
        return ApolloClient(networkTransport: requestChainTransport,
                            store: store1)
    }
    
    /**
     Сессия реализована с использованием отдельной очереди self.threadSafeQueue
     
     - parameters:
        - sessionConfiguration: Конфигурация сессии для создания клиента
        - threadSafeQueue: Поток в котором будем выполнять URLSessionClient
     - returns: URLSessionClient с очередью threadSafeQueue и sessionConfiguration
     */
    private static func createSessionClient(_ sessionConfiguration: URLSessionConfiguration,
                                            _ queue: DispatchQueue) -> URLSessionClient {
        let operationQueue = OperationQueue()
        operationQueue.underlyingQueue = queue
        return URLSessionClient(sessionConfiguration: sessionConfiguration, callbackQueue: operationQueue)
    }
}
