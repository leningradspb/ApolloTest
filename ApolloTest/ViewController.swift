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
        
//        let chatSettings = ChatSettings(authenticationEndpointUrl: "https://tomni.rosbank.ru:7443/api/customers/",
//                                               httpServerEndpointUrl: "https://tomni.rosbank.ru:7443/api/",
//                                               webSocketServerEndpointUrl: "wss://tomni.rosbank.ru:7443/socket/",
//                                               downloadAttachmentUrl: "https://tomni.rosbank.ru:7443/",
//                                               uploadAttachmentUrl: "https://tomni.rosbank.ru:7443/attachment/upload/",
//                                               maxMessageLength: 6000,
//                                               sessionTimeout: 180)
//
//        let token = ChatTokenForOmni(token: "aa04a12a-40c1-4956-ad20-9e1557c33861")
//        let cSettings = ChatServiceSettings(reconnectLimit: 5, chatSettings: chatSettings, omniToken: token)
//
//
//        let cService = ChatService(chatSettings: cSettings)

        
        let que = DispatchQueue(label: "OmniChatHttpTransport.Apollo.syncQueue")
        let omniAuthorizationHttpTransport = OmniAuthorizationHttpTransport(omniToken: "50fedb77-f625-4e0e-a0d7-1bbf2eb11a17", url: "https://tomni.rosbank.ru:7443/api/customers/", intervalTimeout: 3, threadSafeQueue: que)
        
        
        do {
            try omniAuthorizationHttpTransport.loginOneStep()
            print("success loginOneStep()")
        }
        catch {
            print("error loginOneStep()")
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

//    private func createChatService(_ settings: ChatSettings, _ token: ChatTokenForOmni) -> ChatService {
//        let chatServiceSettings = ChatServiceSettings(reconnectLimit: 5,
//                                                      chatSettings: settings,
//                                                      omniToken: token)
//
//        let chatService = ChatService(chatSettings: chatServiceSettings)
////        chatService.addDelegate(delegate: messageCollectionView, sessionConnectionDelegate: self)
//
////        inputMessageView.configure(attachEnabled: !settings.uploadAttachmentUrl.isEmpty, maxTextLength: Int(settings.maxMessageLength))
////        inputMessageView.updateAttachmentButton(isEnabled: false)
////        messageCollectionView.addChatService(chatService)
//
//        return chatService
//    }
    
//    private func customerLoginOneStepWayMutation() {
//        let customer = CustomerLoginOneStepWayMutation(provider: "rosbank", secret: "50fedb77-f625-4e0e-a0d7-1bbf2eb11a17")
//
//    }

}

