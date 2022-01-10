import UIKit
//import RBMK
//import NetworkLayer

/**
 Содержит MessageCollectionView для отображения списка сообщений и inputMessageView для ввода сообщений.

 - authors: Q-ITS, Q-SHU
 */
class ChatViewController: UIViewController {
    
    /**
     Контэйнер для добавления компонента отображения списка сообщений.
     */
    @IBOutlet private weak var containerView: UIView!
    
    /**
     Коллекция в рамках которой отображается список сообщений
     */
    private var messageCollectionView: MessageCollectionView!
    
    @IBOutlet private weak var headerView: UIView!

    @IBOutlet private weak var navigationBar: UIView!

    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    /**
     View для отображения информационных сообщений
     */
    private var infoChatView: InfoChatView?
    
    /**
     Нижняя часть экрана, в которой располагается поле ввода сообщения.
     Выделено в отдельный outlet, т.к. xib не умеет инициализировать другой xib. Все поля subview (из xib) равны nil.
     */
    @IBOutlet private weak var footerView: UIView!
    
    /**
     Поле ввода сообщения пользователем. Располагается в footerView.
     */
    private var inputMessageView: InputMessageView = InputMessageView.viewFromNib()
    
    /**
     Нижний отступ от границы экрана, до footerView. При открытии клавиатуры, позволяет сместить весь контент.
     */
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
//    private lazy var fakeNavigationView: UIView = {
//        let titleSting = appServices?.textProvider.textForKey("TitleText.Chat")
//        let model = NavigationViewModel(
//            titleText: titleSting,
//            leftButtonImage: .leftArrowIcon,
//            action: { [weak self] in
//                guard let self = self else { return }
//                self.pop()
//            },
//            leftButtonAccessibility: AccessibilityConstants.backButton,
//            design: NavigationViewModel.Design.preffered(for: .white)
//        )
//        return model.component(.white)
//    }()
    
    /**
     Сервис для работы с сервером.
     */
    fileprivate var chatService: ChatService?
    
//    private weak var appServices: ApplicationServices?
    
    private var needUpdateAfterWillAppear = true
    
//    private weak var customTabBarController: TabBarController?
    
    private let activityIndicator: UIViewController
    
    private lazy var somethingWentWrongViewController: UIViewController? = {
        return createSomethingWentWrongViewController()
    }()
    
    private var pingTimer: Timer?

//    private var personalDataChangingCoordinator: PersonalDataChangingCoordinator?
//
//    private let claimCreatingManager: ClaimCreatingManager
//
//    public init(appServices: ApplicationServices,
//                tabBarController: TabBarController?,
//                activityIndicator: UIViewController,
//                claimCreatingManager: ClaimCreatingManager) {
//        self.appServices = appServices
//        self.customTabBarController = tabBarController
//        self.activityIndicator = activityIndicator
//        self.claimCreatingManager = claimCreatingManager
//        super.init(nibName: nil, bundle: nil)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        configureUI()
        subscribeEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needUpdateAfterWillAppear {
            hideReconnectToOmniView()
            connectToOmni()
            
            // После загрузки View начинается подгрузка сообщений,
            // что бы избежать визуального скролинга списка сообщений, скрывается View до момента его отображения
            messageCollectionView.isHidden = true
        }
        else {
            needUpdateAfterWillAppear = true
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // возвращает отображение списка сообщения после viewWillAppear
        self.messageCollectionView.isHidden = false
        
        DispatchQueue.main.async {
            self.containerView.layoutIfNeeded()
            self.headerView?.layoutIfNeeded()
            self.messageCollectionView.availableHistoryLazyLoading = true
        }
        
        try? getChatService().stopSocketDisconnectTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopPingTimer()
        
        do {
            try getChatService().startSocketDisconnectTimer()
        }
        catch {
            ChatErrorHandler.handleError(error)
        }
    }

    private func configureUI() {
        view.backgroundColor = .white
        inputMessageView.backgroundColor = .white
        containerView.backgroundColor = .white
        footerView.backgroundColor = .white
        
        messageCollectionView = MessageCollectionView(frame: containerView.bounds,
                                                      collectionViewLayout: MessageFlowLayout())
        messageCollectionView.messageCollectionDelegate = self
        containerView.addSubview(messageCollectionView)
        
        inputMessageView.delegate = self
        inputMessageView.frame = footerView.bounds
        footerView.addSubview(inputMessageView)
        
//        fakeNavigationView.frame = navigationBar.bounds
//        fakeNavigationView.autoresizingMask = .flexibleWidth
//        navigationBar.addSubview(fakeNavigationView)
    }
    
    private func getChatService(_ functionName: String = #function) throws -> ChatService {
        if let chatService = chatService {
            return chatService
        }
        else {
            throw BaseChatError("\(functionName): Отсутствует ChatService")
        }
    }
    
    private func createChatService(_ settings: ChatSettings, _ token: ChatTokenForOmni) -> ChatService {
        let chatServiceSettings = ChatServiceSettings(reconnectLimit: 5,
                                                      chatSettings: settings,
                                                      omniToken: token)
        
        let chatService = ChatService(chatSettings: chatServiceSettings)
        chatService.addDelegate(delegate: messageCollectionView, sessionConnectionDelegate: self)
        
        inputMessageView.configure(attachEnabled: !settings.uploadAttachmentUrl.isEmpty, maxTextLength: Int(settings.maxMessageLength))
        inputMessageView.updateAttachmentButton(isEnabled: false)
        messageCollectionView.addChatService(chatService)
        
        return chatService
    }
    
    private func authenticate(_ completion: ((Error?) -> Void)?) {
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.getChatService().authenticate()
                self?.messageCollectionView.updateUI()
                completion?(nil)
            }
            catch {
                completion?(error)
            }
        }
    }
    
    private func connectToOmni() {
        startLoadingData()
        let errorHandler: ((Error) -> Void) = { [weak self] error in
            self?.stopLoadingData()
            ChatErrorHandler.handleError(error)
            self?.showReconnectToOmniView()
        }
        
        let succesHandler:((ChatSettings, ChatTokenForOmni) -> Void) = { [weak self] settings, token in
            guard let `self` = self else {
                return
            }
            
            if self.chatService == nil {
                ChatErrorHandler.handleInfo("Создание ChatService перед подключением к OMNI")
                self.chatService = self.createChatService(settings, token)
            }
            
            self.authenticate { [weak self] authenticateError in
                if let authenticateError = authenticateError {
                    errorHandler(authenticateError)
                }
                else {
                    self?.stopLoadingData()
                }
            }
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if let chatService = self.chatService {
                succesHandler(chatService.chatSettings.chatSettings, chatService.chatSettings.omniToken)
            }
            else {
                self.loadChatSettings { [weak self] settingsResult in
                    switch settingsResult {
                    case .success(let settings):
                        self?.loadChatOmniToken { tokenResult in
                            switch tokenResult {
                            case .success(let token):
                                succesHandler(settings, token)
                            case .failure(let error):
                                errorHandler(error)
                            }
                        }
                    case .failure(let error):
                        errorHandler(error)
                    }
                }
            }
        }
    }
    
    private func startPingTimer() {
        // При переписке в чате нет взаимодействия с backend EVO. Отправляется запрос, чтобы сессия не разрывалась по бездействию
        if pingTimer?.isValid ?? false { return }
        pingTimer = Timer.scheduledTimer(timeInterval: 30,
                                         target: self,
                                         selector: #selector(firePingTimer),
                                         userInfo: nil,
                                         repeats: true)
        pingTimer?.tolerance = 1
    }
    
    @objc private func firePingTimer() {
        // В документации не сказано, что нужно запрашивать настройки. Данная реализация - негласная договоренность с андроидом.
        // На самом деле пинг уже отправляется внутри класса Socket.
        loadChatSettings(nil)
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    @objc private func forceUpdateHistory() {
        DispatchQueue.global().async {
            do {
                try self.getChatService().forceUpdateMessagesHistory()
            }
            catch {
                ChatErrorHandler.handleError(error)
            }
        }
    }
    
    private func createSomethingWentWrongViewController() -> UIViewController? {
//        guard let appServices = appServices else {
//            return nil
//        }
//        let completion = DestinationViewController.Completions.retrySource { [weak self] shouldRetry in
//            if shouldRetry {
//                ChatErrorHandler.handleInfo("Удаление ChatService перед переподключением к OMNI")
//                self?.chatService = nil
//                self?.hideReconnectToOmniView()
//                self?.connectToOmni()
//            }
//            else {
//                self?.customTabBarController?.navigationController?.popViewController(animated: true)
//                //self?.customTabBarController?.showTab(index: 0)
//            }
//        }
//        let configurator = SomethingWentWrongConfigurator()
//        return configurator.configure(completion: completion,
//                                      inject: .somethingWentWrong(model: SomethingWentWrongInject(retry: true)),
//                                      appServices: appServices,
//                                      claimCreatingManager: self.claimCreatingManager)
        return nil
    }
    
    private func showReconnectToOmniView() {
        OperationQueue.main.addOperation { [weak self] in
            guard let `self` = self,
                let somethingWentWrongViewController = self.somethingWentWrongViewController else {
                return
            }
            
            self.addChild(somethingWentWrongViewController)
            self.view.addSubview(somethingWentWrongViewController.view)
            
            somethingWentWrongViewController.view.translatesAutoresizingMaskIntoConstraints = false
            somethingWentWrongViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            somethingWentWrongViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            somethingWentWrongViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            somethingWentWrongViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            somethingWentWrongViewController.didMove(toParent: self)
        }
    }
    
    private func hideReconnectToOmniView() {
        OperationQueue.main.addOperation { [weak self] in
            self?.somethingWentWrongViewController?.removeFromParent()
            self?.somethingWentWrongViewController?.view.removeFromSuperview()
        }
    }
    
    private func subscribeEvents() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardDidShow),
                           name: UIResponder.keyboardWillShowNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(keyboardDidHide),
                           name: UIResponder.keyboardWillHideNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(forceUpdateHistory),
                           name: UIApplication.didBecomeActiveNotification,
                           object: nil)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tapGesture.cancelsTouchesInView = false
//        messageCollectionView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        let animationCurveRawNSN = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
            let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let bottomInset = self.view.frame.intersection(keyboardFrame).height - self.view.layoutMargins.bottom
            self.bottomConstraint.constant = bottomInset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.messageCollectionView.scrollToLastIndexPath(position: .top, animated: true)
                self.view.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        let animationCurveRawNSN = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func loadChatOmniToken(_ completion: ((Result<ChatTokenForOmni, Error>) -> Void)?) {
//        guard let appServices = appServices else {
            completion?(.failure(BaseChatError("Отсутствует appServices для выполнения DialogTokenRequest")))
            return
//        }
//        let request = DialogTokenRequest()
//        appServices.apiProvider.dialogService.createToken(request: request, completion: { result, error in
//            if let error = error {
//                completion?(.failure(error))
//            }
//            else if let data = result?.data {
//                let omniToken = ChatTokenForOmni(token: data.token)
//                completion?(.success(omniToken))
//            }
//            else {
//                let dataError = BaseChatError("Получен error = '\(String(describing: error?.localizedDescription))', result.data = '\(String(describing: result?.data))', result.result = '\(String(describing: result?.result))', request: '\(request)'")
//                completion?(.failure(dataError))
//            }
//        })
    }
    
    private func loadChatSettings(_ completion: ((Result<ChatSettings, Error>) -> Void)?) {
//        guard let appServices = appServices else {
            completion?(.failure(BaseChatError("Отсутствует appServices для выполнения DialogTokenRequest")))
            return
//        }
//        let request = DialogSettingRequest()
//        appServices.apiProvider.dialogService.getSettings(request: request, completion: { result, error in
//            if let error = error {
//                completion?(.failure(error))
//            }
//            else if let data = result?.data {
//                let chatSettings = ChatSettings(authenticationEndpointUrl: data.authenticationEndpoint,
//                                                httpServerEndpointUrl: data.httpServerEndpoint,
//                                                webSocketServerEndpointUrl: data.wsServerEndpoint,
//                                                downloadAttachmentUrl: data.downloadAttachmentUrl,
//                                                uploadAttachmentUrl: data.uploadAttachmentUrl,
//                                                maxMessageLength: 6000,
//                                                sessionTimeout: 180)
//                completion?(.success(chatSettings))
//            }
//            else {
//                let dataError = BaseChatError("Получен error = '\(String(describing: error?.localizedDescription))', result.data = '\(String(describing: result?.data))', result.result = '\(String(describing: result?.result))', request: '\(request)'")
//                completion?(.failure(dataError))
//            }
//        })
    }
        
    func startLoadingData() {
        OperationQueue.main.addOperation { [weak self] in
            guard let `self` = self else {
                return
            }
            let activityIndicatorHeight = self.view.frame.height
                - self.navigationBar.frame.height
                - self.view.safeAreaInsets.top
            self.activityIndicator.view.frame = CGRect(x: self.view.bounds.origin.x,
                                                       y: self.view.bounds.height
                                                        - activityIndicatorHeight,
                                                       width: self.view.bounds.width,
                                                       height: activityIndicatorHeight)
            self.activityIndicator.willMove(toParent: self)
            self.view.addSubview(self.activityIndicator.view)
            self.addChild(self.activityIndicator)
            self.activityIndicator.didMove(toParent: self)
        }
    }
    
    func stopLoadingData() {
        OperationQueue.main.addOperation { [weak self] in
            self?.activityIndicator.willMove(toParent: nil)
            self?.activityIndicator.view.removeFromSuperview()
            self?.activityIndicator.removeFromParent()
        }
    }
    
    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ChatViewController: SessionConnectionStatusListener {
    
    func onConnectionStateChanged(_ status: SessionConnectionStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            ChatErrorHandler.handleInfo("onConnectionStateChanged: '\(status)'")

            self.removeInfoChatView()
            
            let infoChatView = InfoChatView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 0),
                                            status: status)
            infoChatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapReconnectInfoChatView)))
            self.addInfoView(infoChatView)
            
            if status.isConnected() {
                // Автоматически скрываем данные о статусе соединения, только когда оно уже установлено
                let timer = DefaultLifecycleTimer(timeInterval: 5) { [weak self] in
                    // Статус мог изменить, поэтому необходимо удалять только если статус не изменился.
                    if self?.infoChatView?.getStatus()?.isConnected() == true {
                        self?.removeInfoChatView()
                    }
                }
                timer.start()
            }
            
            if status != .authenticated {
                // Статус authenticated не всегда актуален, пользователь может быть уже .joined, но пришел статус .authenticated
                self.inputMessageView.updateAttachmentButton(isEnabled: status == .joined)
            }
            
            if status == .joined {
                self.startPingTimer()
            } else if status == .disconnected {
                self.stopPingTimer()
            }
        }
    }
    
    func didReconnect() {
        DispatchQueue.global().async {
            do {
                try self.getChatService().loadMessagesHistory()
                self.messageCollectionView.needUpdateUI(true)
            } catch {
                //Данную ошибку не обрабатываем, так как она не влияет на работоспособность функционала
                ChatErrorHandler.handleError(error)
            }
        }
    }
}

extension ChatViewController: MessageCollectionViewDelegate {
    
    @objc private func didTapReconnectInfoChatView() {
        DispatchQueue.global().async {
            if self.infoChatView!.getStatus() == .disconnected {
                do {
                    try self.getChatService().authenticate()
                }
                catch {
                    ChatErrorHandler.handleError(error)
                }
            }
        }
    }
    
    @objc func updateInfoMessage(_ text: String) {
        DispatchQueue.main.async {
            self.removeInfoChatView()
            
            let infoChatView = InfoChatView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 0),
                                            text: text)
            infoChatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapLoadMessageHistoryInfoChatView)))
            self.addInfoView(infoChatView)
        }
    }

    @objc private func didTapLoadMessageHistoryInfoChatView() {
        DispatchQueue.global().async {
            do {
                try self.getChatService().loadMessagesHistory()
                self.removeInfoChatView()
            }
            catch {
                ChatErrorHandler.handleError(error)
            }
        }
    }
    
    func removeInfoMessage() {
        removeInfoChatView()
    }
    
    private func addInfoView(_ infoView: InfoChatView) {
        DispatchQueue.main.async {
            infoView.layoutIfNeeded()
            self.headerViewHeightConstraint.constant = infoView.frame.height
            self.headerView.addSubview(infoView)
            self.infoChatView = infoView
        }
    }
    
    private func removeInfoChatView() {
        DispatchQueue.main.async {
            if let infoChatView = self.infoChatView {
                infoChatView.removeFromSuperview()
                self.infoChatView = nil
            }
            self.headerViewHeightConstraint.constant = 0
        }
    }
    
    func putCursor() {
        inputMessageView.becomeFirstResponder()
    }
    
    func didTapAttachment(attachment: AttachmentDto) {
        do {
            self.startLoadingData()
            guard let navigationController = navigationController else {
                throw AttachmentChatError("Отсутствует NavigationController для отображения вложения")
            }
            guard let original = attachment.original else {
                throw AttachmentChatError("Отсутствует вложение для отображения \(attachment.getDebugInfo())")
            }
            try getChatService().attachmentChatTransport.download(original) { [weak self] result in
                self?.stopLoadingData()
                switch result {
                case .success(let data):
                    let attachmentManager = AttachmentPreviewManager(navigationControllerForDocument: navigationController)
                    attachmentManager.presentPreview(data, attachment.title)
                    self?.needUpdateAfterWillAppear = false
                case .failure(let error):
                    ChatErrorHandler.handleError(error)
                    self?.showErrorMessage(ChatLocalization.getDownloadAttachmentUserError())
                    return
                }
            }
        }
        catch {
            self.stopLoadingData()
            ChatErrorHandler.handleError(error)
        }
    }
    
    func didTapConnectedButton(cell: OperatorButtonCell, message: ChatMessage) {
        self.needUpdateAfterWillAppear = false
        startOperatorInitiatedProcess(cell: cell, message: message)
    }
    
    private func startOperatorInitiatedProcess(cell: OperatorButtonCell,
                                               message: ChatMessage) {
        guard let messageId = message.messageId,
              let messageActivityId = message.activityId,
              let messageText = message.text else {
            let error = BaseChatError("ChatMessage data corrupted.")
            ChatErrorHandler.handleError(error)
            self.showErrorMessage("Error occured. Can't start process.")
            return
        }
//        guard let appServices = appServices else {
            let error: BaseChatError = BaseChatError("appServices is nil")
            ChatErrorHandler.handleError(error)
            showErrorMessage("Services are unavailable.")
            return
//        }
        guard let navigationController = navigationController else {
            let error = BaseChatError("navigationController is nil")
            ChatErrorHandler.handleError(error)
            return
        }
        
        let requestCreateDate = getRequestCreatedStringDate(from: message.timestamp)
        
        if let processType = OperatorInitiatedProcessType(rawValue: messageText) {
            let operationRequestId: String = "\(messageActivityId):\(messageId)"
            
//            switch processType {
//            case .claimFreeForm:
//                do {
//                    let createCompletion = getClaimCreatingCompletion(cell: cell)
//                    cell.showLoader()
//                    messageCollectionView.enableOperatorButtonsInteraction(false)
//                    self.claimCreatingManager.set(showInitialError: true)
//                    try self.claimCreatingManager.requestToCreateClaimFromMessage(chatMessage: message,
//                                                                                  processType: processType,
//                                                                                  completion: createCompletion)
//                }
//                catch let error as ClaimCreatingManagerError {
//                    ChatErrorHandler.handleInfo(error.cause)
//                }
//                catch let error {
//                    ChatErrorHandler.handleError(error)
//                }
//            case .changePersonalData:
//                let operationRequest = PersonalDataRequestDTO(operationRequestId: operationRequestId,
//                                                              requestCreateDate: requestCreateDate)
//                let personalDataChangingCoordinator = PersonalDataChangingCoordinator(tabBarController: nil,
//                                                                                      navController: navigationController,
//                                                                                      appServices: appServices,
//                                                                                      closeButton: .BackLeftButton,
//                                                                                      operationRequest: operationRequest)
//                self.personalDataChangingCoordinator = personalDataChangingCoordinator
//                personalDataChangingCoordinator.start()
//            }
        }
        else {
            let error = BaseChatError("Can't initialize processType. Unrecognized rawValue")
            ChatErrorHandler.handleError(error)
            self.showErrorMessage("Error occured. Can't start process.")
        }
    }
    
    /**
     - parameters:
        - cell: Ячейка инициировавшая процесс создания заявки.
     - returns: Обработчик завершения создания заявки ( выполняет скрытие лоадера ).
     */
    private func getClaimCreatingCompletion(cell: OperatorButtonCell) -> ((Bool) -> Void) {
        let completion: (Bool) -> Void = { [weak cell, weak self] _ in
            cell?.dismissLoader()
            self?.messageCollectionView.enableOperatorButtonsInteraction(true)
        }
        
        return completion
    }
    
    private func getRequestCreatedStringDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: date)
    }
    
    func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ChatViewController: InputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    func isTyping() {
        do {
            try getChatService().sendClientTypingEvent()
        }
        catch {
            ChatErrorHandler.handleError(error)
        }
    }

    func textDidChanged() {
        //скролл списка вверх, чтобы поле ввода не закрывало историю сообщений
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let numberOfSections = self.messageCollectionView.numberOfSections
            let lastItemIndexPath = IndexPath(row: self.messageCollectionView.numberOfItems(inSection: numberOfSections - 1) - 1,
                                              section: numberOfSections - 1)
            if self.messageCollectionView.indexPathsForVisibleItems.contains(lastItemIndexPath) {
                self.messageCollectionView.scrollRectToVisible(CGRect(x: 0,
                                                                      y: self.messageCollectionView.contentSize.height - 1, width: 1, height: 1),
                                                               animated: false)
            }
        }
    }
    
    func didTapSendButton(text: String?, attachedItem: AttachmentChatItem?) {
        do {
            if let text = text {
                try getChatService().sendMessage(text)
            }
            if let attachedItem = attachedItem {
                try AttachmentChatUtils.validateAttachment(attachedItem)
                try getChatService().sendAttachment(attachedItem)
            }
        }
        catch {
            if let validationError = error as? AttachmentValidationError {
                showErrorMessage(validationError.validationMessage)
            }
            ChatErrorHandler.handleError(error)
        }
    }
    
    func didTapAttachmentButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = ChatColors.alertTint

        alert.addAction(UIAlertAction(title: ChatLocalization.getAttachmentCreatePhoto(), style: .default , handler:{ [weak self] _ in
//            UIImagePickerController.obtainPermission(for: .camera, successHandler: {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .camera
//                self?.needUpdateAfterWillAppear = false
//                self?.present(imagePicker, animated: true, completion: nil)
//            }, failureHandler: {
//                self?.showPermissionError(message: ChatLocalization.getCameraAccessError())
//            })
        }))
        
        alert.addAction(UIAlertAction(title: ChatLocalization.getAttachmentSelectFromGalery(), style: .default , handler:{ [weak self] _ in
//            UIImagePickerController.obtainPermission(for: .photoLibrary, successHandler: {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .photoLibrary
//                self?.needUpdateAfterWillAppear = false
//                self?.present(imagePicker, animated: true, completion: nil)
//            }, failureHandler: {
//                self?.showPermissionError(message: ChatLocalization.getPhotoLibraryAccessError())
//            })
        }))
        
        alert.addAction(UIAlertAction(title: ChatLocalization.getAttachmentSelectFromLibrary(), style: .default , handler:{ [weak self] _ in
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)

            importMenu.allowsMultipleSelection = false
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self?.needUpdateAfterWillAppear = false
            self?.present(importMenu, animated: true)
        }))

        alert.addAction(UIAlertAction(title: ChatLocalization.getAttachmentCancel(), style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            ChatErrorHandler.handleError(BaseChatError("Expected a dictionary containing an image, but was provided the following: \(info)"))
            picker.dismiss(animated: true, completion: nil)
            return
        }
        do {
            try inputMessageView.addAttachment(AttachmentChatItem(image: selectedImage))
        }
        catch {
            ChatErrorHandler.handleError(error)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedFileUrl = urls.first {
            inputMessageView.addAttachment(AttachmentChatItem(url: selectedFileUrl))
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func showPermissionError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ChatLocalization.getAccessSettings(), style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) == true {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: ChatLocalization.getAttachmentCancel(), style: .cancel))
        self.present(alert, animated: true)
    }
}
