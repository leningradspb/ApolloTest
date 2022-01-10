import Foundation

protocol AttachmentChatTransportDelegate: class {
    /**
     Вызывается после получения ответа на отправленое сообщение пользователем
     
     - parameters:
        - message: Отправленное сообщение полученное с сервера
     */
//    func successSendMessage(_ message: ClientChatMessage)
    
    /**
     Ошибка отправки клиентского сообщения.
     Не был получен ответ от сервера или ответ содержит ошибку
     */
    func errorSendMessage(clientMessageId: String)
}
