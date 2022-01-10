import UIKit

/**
 Координатор для работы чата. Отображается в tabBar.
 
 - author: Q-ITS
 */
/*
final class ChatCoordinator: Coordinator {
    
    weak var tabBarController: TabBarController?
    weak var appServices: ApplicationServices?
    var deeplinkUrlString: String?
    var deeplinkAction: DeeplinkAction?
    var pushServiceAction: PushServiceAction?
    private let claimCreatingManager: ClaimCreatingManager
    
    init(with tabBarController: TabBarController,
         appServices: ApplicationServices,
         claimCreatingManager: ClaimCreatingManager) {
        self.appServices = appServices
        self.tabBarController = tabBarController
        self.claimCreatingManager = claimCreatingManager
    }
    
    func start() {
        guard let appServices = appServices else {
            return
        }
        
        let activityIndicator = createActivityIndicator(appServices: appServices)
        let chatViewController = ChatViewController(appServices: appServices,
                                                    tabBarController: tabBarController,
                                                    activityIndicator: activityIndicator,
                                                    claimCreatingManager: claimCreatingManager)
                
        tabBarController?.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    private func createActivityIndicator(appServices: ApplicationServices) -> UIViewController {
        let configurator = ActivityIndicatorConfigurator()
        
        // MARK: Сборка модуля
        let viewController = configurator.configure(services: appServices,
                                                    segue: .none,
                                                    destinations: [],
                                                    close: .none,
                                                    completion: .none,
                                                    inject: ActivityIndicatorInject(backgroundColor: .backgroundWhite),
                                                    forcedStyle: nil)
        
        // MARK: Transition
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .custom
        
        return viewController
    }
    
    func stop() {
        
    }
    

    func didRecievedDeeplink(_ stringUrl: String) { }
}
*/
