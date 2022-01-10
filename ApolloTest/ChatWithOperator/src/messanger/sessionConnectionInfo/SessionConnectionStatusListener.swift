import Foundation

/**
 Интерфейс слушателя состояния сессии-соединения для взаимодействия с чатом
 
 - author: Q-ITS
 */
protocol SessionConnectionStatusListener: class {
    
    /**
     Был обновлен статус соединения с сервером
     
     - parameters:
     - status: Новый статус соединения
     */
    func onConnectionStateChanged(_ status: SessionConnectionStatus)
    
    
    /**
     Уведомляет о том, что произошло переподключение к сокету
     */
    func didReconnect()
    
}
