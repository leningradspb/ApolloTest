import Foundation

/**
 Описание протокола взаимодействия сокета с клиентом.
 Содержит описание всех событий возможных при взаимодействии с сокетом.
 
 - author: Q-ITS
 */
protocol OmniChatSocketTransportDelegate: class {
    
    /**
     Было получено новое сообщение в сокет
     
     - parameters:
        - message: Новое сообщение от сервера
     */
    func receivedNewMessage(_ message: ChatMessage)
    
    /**
     Вызывается после получения ответа на отправленое сообщение пользователем
     
     - parameters:
        - message: Отправленное сообщение полученное с сервера
     */
    func successSendMessage(_ message: ClientChatMessage)
    
    /**
     Ошибка отправки клиентского сообщения.
     Не был получен ответ от сервера или ответ содержит ошибку
     */
    func errorSendMessage(clientMessageId: String)
    
    /**
     Необходимо пометить сообщение как прочитанное
     
     - parameters:
        - messageIds: Список идентификаторов сообщений
     */
    func isReadMessage(_ messageIds: [Int])
    
    /**
     События набора текста оператором
     
     - parameters:
        - typing: true- оператор набирает сообщение, false - оператор закончил набор сообщения
     */
    func operatorTyping(_ typing: Bool)

    /**
     Событие, оператор был найден
     
     - parameters:
        - found:
     */
    func isFoundOperator(_ found: Bool)
    
    /**
     Оператор покидает чат
     */
    func isLeaveOperator()
    
    /**
     Необходимо переподключиться к сокету с переданной активностью.
     
     - parameters:
        - activityId: Идентификатор активности для переподключения к сокету
     */
    func reconnectToSocket(activityId: String)
    
    /**
     Был обновлен статус соединения с сервером.
     */
    func updatedConnectionStatus(_ status: SessionConnectionStatus)
    
    /**
     События перевод на другого оператора (другую активность)
     
     - parameters:
     - newActiviyID: ID новой активности
     */
    func transferedOperator(newActiviyID: String)
    
    /**
     Активность была закрыта оператором.
     */
    func activityClosed()
    
    /**
     Сокет соединение было закрыто
     */
    func socketClosed()
    
    /**
     Была получена общая ошибка в сокете.
     
     - parameters:
        - error: Описание ошибки
     */
    func error(_ error: OmniChatTransportError)
}
