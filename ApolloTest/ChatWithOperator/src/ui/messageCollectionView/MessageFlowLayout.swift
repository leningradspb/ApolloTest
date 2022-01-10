import UIKit


/**
 Кастомный layout для отображения сообщений в коллекции.
 
 Отступ между сообщениями: 16
 Отступ секции: (top: 10, left: 16, bottom: 10, right: 16)
 
 - authors: Q-ITS
 */
class MessageFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        minimumLineSpacing = 16
        sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
    }
}
