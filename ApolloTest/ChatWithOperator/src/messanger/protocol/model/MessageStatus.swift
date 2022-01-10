import Foundation

public enum MessageStatusEnum: Int {

    /**
     * Ожидание
     *
     * <p>Отображается, если отправленное сообщение не было доставлено.</p>
     */
     case PENDING

    /**
     * Доставлено
     *
     * <p>Отображается, если отправленное сообщение доставлено, но НЕ прочитано получателем.</p>
     */
     case DELIVERED

    /**
     * Прочитано
     *
     * <p>Отображается, если получатель прочитал сообщение.</p>
     */
     case READ
    
    /**
     * Не доставлено
     *
     * <p>Отображается в случае ошибки доставки сообщения.</p>
     */
    case UNDELIVERED
    
    public static func create(isRead: Bool) -> MessageStatusEnum {
        return isRead ? .READ : .DELIVERED
    }
}
