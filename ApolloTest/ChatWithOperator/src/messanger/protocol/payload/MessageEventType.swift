import Foundation

enum MessageEventType: String {
    
    /**
     Отправка действий в первую очередь влияет на сброс таймера бездействия.
     Через определенное время активность будет закрыта по бездейстию клиента/оператора.
     Чтобы предотвратить это, нужно совершить какое либо действие. Обычно это отправка сообщения и начало печати.
     Кроме этого есть событие `action` которое позволяет передавать любой объект, а сам факт передачи события так же сбрасывает таймер.
     */
    case action = "action"
    
    /**
     Уведомление об обновлении активности (был добавлен оператор).
     В теле события приходит логин `name`, электронная почта `email` и `id` оператора.
     Использовать необходимо только последнее, как гаранитированно неизменяемое.
     */
    case found_operator = "found_operator"
    
    /**
     Носит уведомительный характер, сообщает клиенту, что приложение
     скоро закроет активность по причине неактивности оператора.
     При переподключении событие приходит вновь если счетчик не истек.
     */
    case info = "info"
    
    /**
     Исходящие событие со стороны клиента призванное передать содержимое его поля ввода,
     для предотвращения потери данных.
     */
    case input = "input"
    
    /**
     Существует возможность отметить сообщение как прочитаное, так и получить информацию о том,
     что некоторые сообщения были прочитаны. Необходимо для отрисовки состояния доставки.
     */
    case is_read = "is_read"
    
    /**
     Для уведомления собеседеника о печати, а так же для получения аналогичного уведомления.
     Принято отправлять и принимать только положительный ответ `value: true`.
     При приёме сообщения, рекомендовано отображать статус о печате
     не менее 10 секунд с момента получения последнего события (максимальный интервал повторного события 5 секунд).
     Нужно отключать отображения статуса, при приеме нового текстового сообщения.
     Принято отправлять статус о печати сразу после начала печати, но не чаще чем один раз в 1200 милисекунд.
     Принято отправлять стутус о печати сразу, если печать началась раньше указаного времени но была прервана отправлением сообщения.
     */
    case is_typing = "is_typing"
    
    /**
     Если активность была закрыта, оставшимся участникам активности будет переданно данное событие,
     после его получения необходимо произвести выход из канала используя событие `phx_leave`,
     так как через некоторое время чат сервер будет уничтожен и использование активности для переписки будет невозможно.
     */
    case left = "left"
    
    /**
     Входящее событие говорит нам о том, что сообщение нужно отрисовать или обновить.
     Исходящее сообщение в канал активности добавит сообщение в чат.
     При отправке сообщения можно получить ответ и быть увереным в доставке к приложению.
     */
    case new_msg = "new_msg"
    
    /**
     Отправленное событие сообщит серверу о закрытии соединения, пред его фактическим обрывом.
     Принятое событие сообщает о том, что соединение будет немеделенно закрыто.
     Если после этого сохраняется необходимость в соединении, нужно создать новое.
     */
    case phx_close = "phx_close"
    
    /**
     Фатальная ошибка, после получения, нужно создать новое соединение и произвести подключение к каналам снова.
     Если ошибка повторится после попытки входа в существующие ранее каналы, то это может говорит о невозможности
     подключения к данным каналам связи.
     */
    case phx_error = "phx_error"
    
    /**
     В приложении OMNI потоки данных разбиты на каналы связи
     (прим. так для активности используется канал связи `room`, а для уведомлений оператора `watchtower`).
     Наименование канала представляет из себя namespace с типом канала,
     двоеточие «`:`» и идентификатор канала, всё вместе в рамках `Phoenix` называется `topic`.
     */
    case phx_join = "phx_join"
    
    /**
     Для выхода из канала нужно отправить данное событие. Необхоидо для корректной отписки от уведомлений.
     */
    case phx_leave = "phx_leave"
    
    /**
     На определенные отправленные события (`phx_join`, `new_msg`) придёт ответ,
     в теле ответа будут указаны переданные референсные идентификаторы подключения и события.
     */
    case phx_reply = "phx_reply"
    
    /**
     На каждый канал могут быть подписаны несколько участников, каждый раз при их подписки,
     отключении, потери связи и т.п. будет приходить данное событие.
     */
    case presence_diff = "presence_diff"
    
    /**
     Приходит каждый раз при подключении к комнате, и раз в нное время для актуализации статуса.
     Аналогично `presence_diff`, отображает всех текущих участников и время входа.
     */
    case presence_state = "presence_state"
    
    /**
     Иногда операторы переводят активность на других операторво,
     в этом случае будет создана новая активность, от старой нужно отключиться, к новой подключиться.
     Это обусловленно основным тезисом о активности а так же технической реализацией.
     
     > Активность – это непрерывный диалог между одним оператором и одним клиентом
     */
    case transfered = "transfered"
}