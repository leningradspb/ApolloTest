import Foundation

/**
 Протокол взаимодействия ChatService с UI
 
 - author: Q-ITS
 */
protocol ChatServiceDelegate: class {
    
    /**
     Необходимо обновить UI. Например,
     - Обновлена история сообщений
     - Данные сообщения были изменены
     - Пришел ответ на отправленное сообщение
     - Обновился статус оператора
    
     - parameters:
        - scrollToBottom: Необходимость скролла в конец списка
     */
    func needUpdateUI(_ scrollToBottom: Bool)
    
    /**
     Было обновлено сообщение в чате.
     
     - parameters:
        - message: Данные об обновленном сообщении
     */
    func updatedMessages(_ messages: [ChatMessage])
    
    /**
     Было получено новое сообщение от сервера
     */
    func receivedNewMessage(_ message: ChatMessage)
    
    /**
     Была загружена последняя страница истории чата
     */
    func loadedHistoryLastPage()
    
    /**
     Оператор набирает текст
     
     - parameters:
        - typing: true - оператор набирает сообщение, false - оператор прекратил набор сообщения
     */
    func operatorTyping(_ typing: Bool)
    
    
    func updateOperatorStatus()
    
    /**
     Была получена ошибка при взаимодействии с ChatService, например:
     - Ошибка отправки сообщения
     
     - parameters:
        - error: Полученная ошибка
     */
    func receivedError(_ error: Error)
    
}
