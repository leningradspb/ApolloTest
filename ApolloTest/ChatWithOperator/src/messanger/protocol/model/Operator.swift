import Foundation

/**
 * Информаци об операторе
 *
 * @author Q-AFU
 * @author Q-IAN
 */
class Operator {
    
    public var operatorId: String
    
    public var name: String

    init(operatorId: String, name: String) {
        self.operatorId = operatorId
        self.name = name
    }
}
