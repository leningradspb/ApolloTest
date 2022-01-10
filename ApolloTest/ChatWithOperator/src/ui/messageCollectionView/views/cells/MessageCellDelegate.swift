import Foundation

protocol MessageCellDelegate: AnyObject {
    
    func didTapAttachment(attachment: AttachmentDto)
    
    /**
     Пользователь нажал кнопку для запуска процесса инициированного оператором.
     
     - Parameters:
        - cell: Ячейка нажатой кнопки.
        - message: Сообщение, прикрепленная кнопка к которому была нажата.
     */
    func didTapConnectedButton(cell: OperatorButtonCell, message: ChatMessage)
}
