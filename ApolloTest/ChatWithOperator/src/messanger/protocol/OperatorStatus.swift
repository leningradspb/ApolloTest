import Foundation

/**
 Описание статусов оператора
 */
public enum OperatorStatus {
    
    /**
     Оператор пока не найден
     */
    case found_not_operator
    
    /**
     Оператор найден
     */
    case found_operator
    
    /**
     Оператора покинул чат
     */
    case leave
    
    /**
     
     */
    case regularStatus
    
}
