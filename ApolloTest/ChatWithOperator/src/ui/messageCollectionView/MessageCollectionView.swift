import UIKit
//import RBMK

/**
 Коллекция для отображения сообщений из чата.
 Для работы необходимо после инцииализации:
 1. Добавить chatService как источник данных (addChatService)
 2. Добавить messageCollectionDelegate
 
 - authors: Q-ITS
 */
class MessageCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    /**
     Сервис для работы с сообщениями, может быть отсутствовать при ошибке инициализации данных.
     Устанавливается в момент создания ChatService из вне.
     */
    fileprivate weak var chatService: ChatService?
    
    /**
     Обработчик взаимодействия со списком сообщений.
     */
    public weak var messageCollectionDelegate: MessageCollectionViewDelegate?
    
    // TODO: Исправить момент добавления true/false после первого отображения. Т.к. сообщения рисуются сверху вниз при первом отображении всего подгружается история.
    public var availableHistoryLazyLoading: Bool = false
    
    private var refreshComponent: UIRefreshControl?
    
    private var startView: StartChatView = StartChatView.viewFromNib()
    
    private lazy var tryAgainButton: UIView = {
        return UIView()
//        return ComplexTextButtonModel(
//            action: { [weak self] in
//                self?.loadHistoryMessages()
//                self?.hideTryAgainButton()
//            },
//            title: applicationStrings("Chat.List.ReloadError.Repeat"),
//            icon: .iconOperationRepeat,
//            design: ComplexTextButtonModel.Design.complex(.white).preffered
//        ).component(.white)
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = ChatColors.appClear
        delegate = self
        dataSource = self
        collectionViewLayout = collectionViewLayout
        alwaysBounceVertical = true
        
        register(UINib(nibName: OperatorMessageCell.reuseIdentifier, bundle: nil),
                                       forCellWithReuseIdentifier: OperatorMessageCell.reuseIdentifier)
        register(UINib(nibName: ClientMessageCell.reuseIdentifier, bundle: nil),
                                       forCellWithReuseIdentifier: ClientMessageCell.reuseIdentifier)
        register(UINib(nibName: InfoMessageCell.reuseIdentifier, bundle: nil),
                                       forCellWithReuseIdentifier: InfoMessageCell.reuseIdentifier)
        register(UINib(nibName: TypingMessageCell.reuseIdentifier, bundle: nil),
                                       forCellWithReuseIdentifier: TypingMessageCell.reuseIdentifier)
        register(OperatorButtonCell.self, forCellWithReuseIdentifier: OperatorButtonCell.reuseIdentifier)
        
        addStartView()
        addTryAgainButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func addChatService(_ chatService: ChatService) {
        self.chatService = chatService
    }
    
    func scrollToLastIndexPath(position:UICollectionView.ScrollPosition, animated: Bool) {
        self.layoutIfNeeded()
        
        for sectionIndex in (0..<self.numberOfSections).reversed() {
            if self.numberOfItems(inSection: sectionIndex) > 0 {
                self.scrollToItem(at: IndexPath.init(item: self.numberOfItems(inSection: sectionIndex)-1, section: sectionIndex),
                                  at: position,
                                  animated: animated)
                break
            }
        }
    }
    /**
     Обновление UI с сохранением позиции смещения
     */
    func updateUI() {
        DispatchQueue.main.async {
            let curentOffset = self.contentOffset
            let currentContentHeight = self.contentSize.height
            
            self.reloadData()
            self.layoutIfNeeded()
            
            let newOffset = curentOffset.y + (self.contentSize.height - currentContentHeight)
            self.setContentOffset(CGPoint(x: curentOffset.x, y: newOffset), animated: false)
        }
    }
    
    /**
     Обновление UI с скроллом к последнему полученному сообщению
     */
    func reloadUI() {
        DispatchQueue.main.async {
            self.updateUIWithHistory()
            self.reloadData()
            self.scrollToLastIndexPath(position: UICollectionView.ScrollPosition.top, animated: false)
        }
    }
    
    /**
     Устанавливает возможность взаимодействия с кнопками ячеек.
     
     - parameters:
        - enable: Признак возможности взаимодействия с кнопкой ячейки.
     */
    func enableOperatorButtonsInteraction(_ enable: Bool) {
        for sectionIndex in (0..<self.numberOfSections) {
            for itemIndex in (0..<numberOfItems(inSection: sectionIndex)) {
                let itemIndexPath: IndexPath = IndexPath(row: itemIndex, section: sectionIndex)
                
                if let cell = cellForItem(at: itemIndexPath),
                   let operatorButtonCell = cell as? OperatorButtonCell {
                    if enable {
                        operatorButtonCell.allowButtonInteracion()
                    }
                    else {
                        operatorButtonCell.disableButtonInteraction()
                    }
                }
            }
        }
    }
    
    private func addStartView() {
        startView.frame = bounds
        startView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(startView)
        startView.isHidden = true
    }
    
    private func addTryAgainButton() {
        let buttonHeight: CGFloat = 48
        tryAgainButton.frame = CGRect(x: 0, y: -buttonHeight, width: bounds.width, height: buttonHeight)
        tryAgainButton.autoresizingMask = .flexibleWidth
        addSubview(tryAgainButton)
        tryAgainButton.isHidden = true
    }
    
    private func updateUIWithHistory() {
        if let chatService = chatService, chatService.getLoadedMessages().isEmpty {
            startView.isHidden = false
            messageCollectionDelegate?.putCursor()
        }
        else {
            startView.isHidden = true
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let chatService = chatService else {
            return 0
        }
        return chatService.chatDataSource.getSectionCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let chatService = chatService else {
            return 0
        }
        
        var countRow = 0
        if let chatSection = ChatSection(rawValue: section) {
            countRow = chatService.chatDataSource.getRowsInSection(chatSection)
        }
        
        countRow == 0 ? configureEmptyList() : deleteEmptyList()
        
        return countRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO: Исправить на определение секции
        guard let message = chatService?.chatDataSource.getMessage(indexPath: indexPath) else {
            // TODO: Добавить проброс ошибки или обработку данной ситуации
            return UICollectionViewCell()
        }
        
        let cell = getCellForMessage(message, collectionView: collectionView, indexPath: indexPath)
        
        if let messageCell = cell as? MessageCell {
            messageCell.bind(message, self)
            if let operatorCell = messageCell as? OperatorMessageCell {
                operatorCell.setIsLastMessage(!(chatService?.chatDataSource.getMessage(indexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section)) is OperatorChatMessage))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chatService?.didSelect(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chatService = chatService else {
            return .zero
        }
        
        return chatService.chatDataSource.getSizeForMessage(indexPath, width: getCollectionViewWidthWithoutInsets())
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: 0) {
            loadHistoryMessages()
        }
        
        // Возобновляет анимации CALayer при скролле к ячейке.
        if let cell = cell as? OperatorButtonCell {
            cell.restoreButtonAnimationIfNeedIt()
        }
    }
    
    /**
     Вызывает загрузку истории сообщений, на основе текущего состояния списка сообщений.
     Если история не будет загружена, будет отображена ошибка.
     */
    @objc private func loadHistoryMessages() {
        refreshComponent?.beginRefreshing()
        if availableHistoryLazyLoading {
            DispatchQueue.global().async {
                do {
                    try self.chatService?.loadMessagesHistory()
                    self.messageCollectionDelegate?.removeInfoMessage()
                    DispatchQueue.main.async {
                        self.hideTryAgainButton()
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        self.refreshComponent?.endRefreshing()
                        self.showTryAgainButton()
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.refreshComponent?.endRefreshing()
        }
    }
    
    private func showTryAgainButton() {
        if tryAgainButton.isHidden {
            tryAgainButton.isHidden = false
            contentInset.top += tryAgainButton.frame.height
            if indexPathsForVisibleItems.contains(IndexPath(row: 0, section: 0)) {
                scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    private func hideTryAgainButton() {
        if !tryAgainButton.isHidden {
            tryAgainButton.isHidden = true
            contentInset.top -= tryAgainButton.frame.height
            
        }
    }

    private func getCellForMessage(_ message: ChatMessage,
                                   collectionView: UICollectionView,
                                   indexPath: IndexPath) -> UICollectionViewCell {
        switch message {
        case is ClientChatMessage:
            return collectionView.dequeueReusableCell(withReuseIdentifier: ClientMessageCell.reuseIdentifier, for: indexPath)
        case is InfoChatMessage:
            return collectionView.dequeueReusableCell(withReuseIdentifier: InfoMessageCell.reuseIdentifier, for: indexPath)
        case is TypingChatMessage:
            return collectionView.dequeueReusableCell(withReuseIdentifier: TypingMessageCell.reuseIdentifier, for: indexPath)
        case is OperatorStatusChatMessage:
            return collectionView.dequeueReusableCell(withReuseIdentifier: InfoMessageCell.reuseIdentifier, for: indexPath)
        case is OperatorFreeFormButtonChatMessage:
            return collectionView.dequeueReusableCell(withReuseIdentifier: OperatorButtonCell.reuseIdentifier, for: indexPath)
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: OperatorMessageCell.reuseIdentifier, for: indexPath)
        }
    }
    
    private func scrollToBottom() {
        layoutIfNeeded()
        
        let contentLedge = contentSize.height - frame.height
        if contentLedge > 0 {
            setContentOffset(CGPoint(x: contentOffset.x, y: contentLedge), animated: true)
        }
    }
    
    /**
     - returns: Ширина CollectionView без отступов collectionViewLayout и contentInset
     */
    private func getCollectionViewWidthWithoutInsets() -> CGFloat {
        var widthWithoutInsets = bounds.size.width
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            widthWithoutInsets -= (layout.sectionInset.left + layout.sectionInset.right)
        }
        widthWithoutInsets -= (contentInset.left + contentInset.right)
        return widthWithoutInsets
    }
    
    private func configureEmptyList() {
        deleteEmptyList()
        addPullToRefresh()
    }
    
    private func deleteEmptyList() {
        removePulltoRefresh()
    }
    
    private func addPullToRefresh() {
        removePulltoRefresh()
        let refreshComponent = UIRefreshControl()
        refreshComponent.addTarget(self, action: #selector(loadHistoryMessages), for: .valueChanged)
        addSubview(refreshComponent)
        
        self.refreshComponent = refreshComponent
    }
    
    private func removePulltoRefresh() {
        refreshComponent?.removeFromSuperview()
        refreshComponent = nil
    }
}

extension MessageCollectionView: ChatServiceDelegate {

    func needUpdateUI(_ needScrollToBottom: Bool) {
        DispatchQueue.main.async {
            if needScrollToBottom {
                self.reloadUI()
            }
            else {
                self.updateUI()
            }
        }
    }
    func updatedMessages(_ messages: [ChatMessage]) {
        DispatchQueue.main.async {
            guard let cells = self.visibleCells as? [MessageCell] else {
                return
            }
            for message in messages {
                for cell in cells {
                    if let cellMessage = cell.unbind(), ChatMessageMergingComparator.compare(cellMessage, message){
                        cell.reloadMessage(message)
                    }
                }
            }
        }
    }

    func receivedNewMessage(_ message: ChatMessage) {
        reloadUI()
        // Только для операторских сообщений нужно отправлять событие о прочтении
        if (message.messageStatus != .READ) && (message is OperatorChatMessage) {
            chatService?.isReadMessagesEvent([message])
        }
    }
    
    func loadedHistoryLastPage() {
        availableHistoryLazyLoading = false
    }
    
    func operatorTyping(_ typing: Bool) {
        ChatErrorHandler.handleInfo("operatorTyping = '\(typing)'")
    }
    
    func IsFoundOperator(_ found: Bool) {
        ChatErrorHandler.handleInfo("IsFoundOperator = '\(found)'")
    }

    func updateOperatorStatus() {
        
    }
    
    func receivedError(_ error: Error) {
        ChatErrorHandler.handleError(error)
        if let validationError = error as? AttachmentValidationError {
            messageCollectionDelegate?.showErrorMessage(validationError.message)
        }
        else {
            DispatchQueue.main.async {
                self.showTryAgainButton()
            }
        }
    }
}

extension MessageCollectionView: MessageCellDelegate {
    
    func didTapAttachment(attachment: AttachmentDto) {
        messageCollectionDelegate?.didTapAttachment(attachment: attachment)
    }
    
    func didTapConnectedButton(cell: OperatorButtonCell, message: ChatMessage) {
        messageCollectionDelegate?.didTapConnectedButton(cell: cell, message: message)
    }
}

extension UIView {
    class func fromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
            else { fatalError("missing expected nib named: \(name)") }
        guard
            /// we're using `first` here because compact map chokes compiler on
            /// optimized release, so you can't use two views in one nib if you wanted to
            /// and are now looking at this
            let view = nib.first as? Self
            else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
    }
}
