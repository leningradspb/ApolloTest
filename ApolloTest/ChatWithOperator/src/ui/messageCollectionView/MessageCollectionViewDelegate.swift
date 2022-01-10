import Foundation

/**
 Протокол взаимодействия со списком сообщений.
 
 - author: Q-ITS
 */
protocol MessageCollectionViewDelegate: class {
    
    /**
     Обновить текст в информационном сообщении
     
     - parameters:
        - text: Текст для информационного сообщения.
     */
    func updateInfoMessage(_ text: String)
    
    /**
     Удаление информационного сообщения
     */
    func removeInfoMessage()
    
    /**
     Устанавливает курсор в поле ввода
     */
    func putCursor()
    
    /**
     Пользователь нажал на сообщение с вложением
     */
    func didTapAttachment(attachment: AttachmentDto)
    
    /**
     Пользователь нажал на кнопку связанную с сообщением
     
     - Parameters:
        - cell: Ячейка нажатой кнопки.
        - message: Сообщение, к которому прикреплена кнопка.
     */
    func didTapConnectedButton(cell: OperatorButtonCell, message: ChatMessage)
    
    func showErrorMessage(_ message: String)
}
