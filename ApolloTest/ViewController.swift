//
//  ViewController.swift
//  ApolloTest
//
//  Created by Eduard Sinyakov on 10.01.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
//        let apollo = ApolloClientCreator.createApolloClient(token: "6c5c3d00-45ae-4915-8fc7-d4d2ff3594df", apiUrl: "https://tomni.rosbank.ru:7443/api/customers", queue: DispatchQueue(label: "l"))
//
//        print(apollo)
//
//        let omni = OmniChatHttpTransport(omniToken: "6c5c3d00-45ae-4915-8fc7-d4d2ff3594df", omniUrl: "", authentificateOmniUrl: "https://tomni.rosbank.ru:7443/api/customers", intervalTimeout: 5)
//        do {
//           try omni.authorize()
//        } catch {
//            print("rrere")
//        }
//
//        print(omni.loadedJwtToken, omni)
//
//        omni.loadedJwtToken = { [weak self] token in
//            print(token)
//        }
        
//        let chatSettings = ChatSettings(authenticationEndpointUrl: data.authenticationEndpoint,
//                                               httpServerEndpointUrl: data.httpServerEndpoint,
//                                               webSocketServerEndpointUrl: data.wsServerEndpoint,
//                                               downloadAttachmentUrl: data.downloadAttachmentUrl,
//                                               uploadAttachmentUrl: data.uploadAttachmentUrl,
//                                               maxMessageLength: 6000,
//                                               sessionTimeout: 180)
        
        let chatSettings = ChatSettings(authenticationEndpointUrl: "https://tomni.rosbank.ru:7443/api/customers/",
                                               httpServerEndpointUrl: "https://tomni.rosbank.ru:7443/api/",
                                               webSocketServerEndpointUrl: "wss://tomni.rosbank.ru:7443/socket/",
                                               downloadAttachmentUrl: "https://tomni.rosbank.ru:7443/",
                                               uploadAttachmentUrl: "https://tomni.rosbank.ru:7443/attachment/upload/",
                                               maxMessageLength: 6000,
                                               sessionTimeout: 180)
        
        let token = ChatTokenForOmni(token: "aa04a12a-40c1-4956-ad20-9e1557c33861")
        let cSettings = ChatServiceSettings(reconnectLimit: 5, chatSettings: chatSettings, omniToken: token)
        
        
        let cService = ChatService(chatSettings: cSettings)
        
//        do {
//            try cService.authenticate()
//            print("success")
//        }
//        catch {
//            print("error")
//        }
        
//        let charService = createChatService(chatSettings, token)
//        do {
//            try charService.authenticate()
//            print("success")
//        }
//        catch {
//            print("error")
//        }
//
//        print(charService)
        
        let que = DispatchQueue(label: "QUE 1")
        let omniAuthorizationHttpTransport = OmniAuthorizationHttpTransport(omniToken: "aa04a12a-40c1-4956-ad20-9e1557c33861", url: "https://tomni.rosbank.ru:7443/api/customers/", intervalTimeout: 5, threadSafeQueue: que)
        
        
        do {
            try omniAuthorizationHttpTransport.loginOneStep()
            print("success")
        }
        catch {
            print("error")
        }
    }
    
//    if let data = result?.data {
//       let chatSettings = ChatSettings(authenticationEndpointUrl: data.authenticationEndpoint,
//                                       httpServerEndpointUrl: data.httpServerEndpoint,
//                                       webSocketServerEndpointUrl: data.wsServerEndpoint,
//                                       downloadAttachmentUrl: data.downloadAttachmentUrl,
//                                       uploadAttachmentUrl: data.uploadAttachmentUrl,
//                                       maxMessageLength: 6000,
//                                       sessionTimeout: 180)
//       completion?(.success(chatSettings))
//   }

    private func createChatService(_ settings: ChatSettings, _ token: ChatTokenForOmni) -> ChatService {
        let chatServiceSettings = ChatServiceSettings(reconnectLimit: 5,
                                                      chatSettings: settings,
                                                      omniToken: token)
        
        let chatService = ChatService(chatSettings: chatServiceSettings)
//        chatService.addDelegate(delegate: messageCollectionView, sessionConnectionDelegate: self)
        
//        inputMessageView.configure(attachEnabled: !settings.uploadAttachmentUrl.isEmpty, maxTextLength: Int(settings.maxMessageLength))
//        inputMessageView.updateAttachmentButton(isEnabled: false)
//        messageCollectionView.addChatService(chatService)
        
        return chatService
    }

}

