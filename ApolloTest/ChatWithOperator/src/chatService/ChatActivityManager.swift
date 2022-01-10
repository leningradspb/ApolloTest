import Foundation

/**
 Менеджер для работы с активностями чата.
 
 Реализует:
 - Хранение идентификатора активности для последующей загрузки
 - Хранение данных об активности
 - Логику получения идентификатора активности
 
 - author: Q-ITS
 */
public class ChatActivityManager {
    
    /**
     Данные о текущей активности. Позволяют проверить жива ли еще активность, если да, создать сокет на основе ее данных.
     */
    private var activity: Activity?
    
    /**
     Хранит идентификатор новой активности, при следующем запросе на сервер, необходимо предварительно обновить активность
     */
    private var newActivityId: String?
    
    /**
     Обновление текущей активности. При передаче nil активность стирается.
     
     - parameters:
        - activity: Данные об активности, может отстутствовать, если ее не прислал сервер.
     */
    public func updateActivity(_ activity: Activity?) {
        self.activity = activity
    }
    
    /**
     - return: Данные о последней загруженной активности, если активность еще не была получена - nil
     */
    public func getActivity() -> Activity? {
        return activity
    }
    
    /**
     Идентификатор активности для отправки запросов, порядок возврата:
     - Последний полученный в сообщении (не истории сообщений)
     - Актуальный из активности
     - Индикатор активности из последнего сообщения истории сообщений
     - nil если индикатора активности нет
     
     - parameters:
        - historyMessages: История сообщений, из которой будет получен последний activityId, если на клиенте его нет.
     */
    public func getActivityId(_ historyMessages: [ChatMessage]) -> String? {
        if let newActivityId = newActivityId {
            return newActivityId
        }
        else if let activityId = activity?.id {
            return activityId
        }
        else if let activityId = historyMessages.last(where: { $0.activityId != nil })?.activityId {
            return activityId
        }
        else {
            return nil
        }
    }
    
    /**
     Сохраняет новый идентификатор активности.
     Используется если активность не удалось сразу загрузить и ее необходимо обновить при следующем запросе на сервер.
     
     Данные о текущей активности удаляются!
     */
    public func saveNewActivityId(_ activityId: String) {
        updateActivity(nil)
        newActivityId = activityId
    }
    
    /**
     Удаление всех данных об активности.
     - Сама активности.
     - Идентификатор активности для переподключения.
     */
    public func removeActivity() {
        updateActivity(nil)
        newActivityId = nil
    }
    
}
