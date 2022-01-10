//
//  OperatorButtonCell.swift
//  RosbankProject
//
//  Created by Антон Прохоров on 27.10.2020.
//  Copyright © 2020 Rosbank. All rights reserved.
//

import UIKit
//import RBMK

class OperatorButtonCell: UICollectionViewCell, MessageCell {
    
    /// Идентификатор ячейки для переиспользования при регистрации ячейки в коллекции.
    @objc static let reuseIdentifier = "OperatorButtonCell"
    
    /// Button View внутри ячейки для отображения кнопки создания заявки.
    private let freeFormButton = UIView()
    
    /// Отступы внутри ячейки для buttonView
    private static let contentEdge = UIEdgeInsets(top: 16, left: .zero, bottom: 4, right: .zero)
    
    /// Высота кнопки
    private static let freeFormButtonHeight: CGFloat = 48
    
    /// Отступы кнопки
    private static let sidesOffset = contentEdge.left + contentEdge.right

    /// Фиксированная высота ячеки
    private static let cellHeight = contentEdge.top + freeFormButtonHeight + contentEdge.bottom
    
    private weak var delegate: MessageCellDelegate?
    private var chatMessage: ChatMessage?
    
    private func configureUI(buttonTitle: String) {
//        let viewModel = ButtonViewModel(
//            action: { [weak self] in
//                guard let self = self,
//                      let chatMessage = self.chatMessage,
//                      let delegate = self.delegate else { return }
//                delegate.didTapConnectedButton(cell: self, message: chatMessage)
//            },
//            title: buttonTitle,
//            isEnabled: true,
//            design: ButtonViewModel.Design.simpleRedRoboto(.white).preffered)
//
//        freeFormButton.prepare(with: viewModel)
        addSubview(freeFormButton)
        
    }
    
    /**
     Выполняет показ лодера на кнопке.
     */
    internal func showLoader() {
//        freeFormButton.isLoadingState = true
    }
    
    /**
     Выполняет скрытие лоадера с кнопки.
     */
    internal func dismissLoader() {
//        freeFormButton.isLoadingState = false
    }
    
    /**
     Включает возможность взаимодействия с кнопкой.
     */
    internal func allowButtonInteracion() {
        freeFormButton.isUserInteractionEnabled = true
    }
    
    /**
     Отключает возможность взаимодействия с кнопкой.
     */
    internal func disableButtonInteraction() {
        freeFormButton.isUserInteractionEnabled = false
    }
    
    /**
     Возобновляет анимацию кнопки.
     */
    internal func restoreButtonAnimationIfNeedIt() {
//        freeFormButton.restoreLoaderAnimationIfNeedIt()
    }
    
    /**
     - Parameters:
        - messageText: Текст сообщения
     - Returns: Заголовок кнопки
     */
    private func getButtonTitle(messageText: String?) -> String {
        switch messageText {
        case OperatorInitiatedProcessType.changePersonalData.rawValue,
             OperatorInitiatedProcessType.claimFreeForm.rawValue:
            return messageText ?? ""
//            return applicationStrings("Chat.List.Action.ClaimsFreeForm")
        /**
         Функционал переведен на итерацию 2.
         
        case OperatorInitiatedProcessType.incident.rawValue:
            return applicationStrings("Chat.List.Action.IncidentRosbankOnline")
        case OperatorInitiatedProcessType.kaskoAuto.rawValue:
            return applicationStrings("Chat.List.Action.KaskoRosbankAuto")
        case OperatorInitiatedProcessType.pledgeAuto.rawValue:
            return applicationStrings("Chat.List.Action.PledgeRosbankAuto")
        */
        default:
            ChatErrorHandler.handleError(BaseChatError("Can't recognize operator message."))
            return String()
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        freeFormButton.frame.size.width = frame.width - OperatorButtonCell.sidesOffset

        freeFormButton.frame.size.height = OperatorButtonCell.freeFormButtonHeight
        freeFormButton.layoutIfNeeded()
        freeFormButton.frame.origin.x = OperatorButtonCell.contentEdge.left
        freeFormButton.frame.origin.y = OperatorButtonCell.contentEdge.top

        frame.size.height = OperatorButtonCell.cellHeight
        
        // В ios 14 freeFormButton добавляется под contentView, поэтому вытаскиваем наверх чтобы работал Tap
        bringSubviewToFront(freeFormButton)
    }
    
    func bind(_ item: ChatMessage, _ delegate: MessageCellDelegate?) {
        self.delegate = delegate
        self.chatMessage = item
        configureUI(buttonTitle: getButtonTitle(messageText: item.text))
        layoutIfNeeded()
    }
    
    func reloadMessage(_ item: ChatMessage) {
        bind(item, delegate)
    }
    
    func unbind() -> ChatMessage? {
        return nil
    }
    
    /**
     Расчет размера ячейки при установке ей переданного message.
     */
    static func size(width:CGFloat, item: ChatMessage) -> CGSize {
        return CGSize(width: width - OperatorButtonCell.sidesOffset,
                      height: OperatorButtonCell.cellHeight)
    }
    
}
