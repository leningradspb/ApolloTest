import UIKit

/**
 Общий протокол для всех ячеек отображающих сообщения.
 */
protocol MessageCell {
    
    /**
     Установка переданного сообщения в ячейку.
     */
    func bind(_ item: ChatMessage, _ delegate: MessageCellDelegate?)
    
    /**
     Обновление содержимого сообщения после ответа от сервера, не обновляет размер, только содержимое.
     Сервер может прислать только обновленное значение статуса и даты.
     
     - parameters:
        - item: обновленное сообщение
     */
    func reloadMessage(_ item: ChatMessage)
    
    /**
     Установка переданного сообщения в ячейку.
     */
    func unbind() -> ChatMessage?
    
    /**
     Расчет размера ячейки при установке ей переданного элемента, при максимальной ширине 'width'.
     
     - parametets:
        - width: Ширина ячейки для расчета.
        - item: Сообщение которое необходимо отобразить в ячейке
     - returns: Размер ячейки (width совпадает с переданным).
     */
    static func size(width: CGFloat, item: ChatMessage) -> CGSize
}
