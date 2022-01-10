import UIKit

extension UIView {
    class func viewFromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
            else { fatalError("missing expected nib named: \(name)") }
        guard
            /// we're using `first` here because compact map chokes compiler on
            /// optimized release, so you can't use two views in one nib if you wanted to
            /// and are now looking at this
            let view = nib.first as? Self
            else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
    }
}

/**
 Ячейка отображения ввода текста оператором.
 
 - author: Q-SHU
 */
class TypingMessageCell: UICollectionViewCell {
    
    /**
     Идентификатор ячейки для переиспользования при регистрации ячейки в коллекции.
     */
    @objc  static let reuseIdentifier = "TypingMessageCell"
    
    /**
     При отображении коллекция запрашивает размер будущей ячейки. Т.к. у нас еще нет объекта класса для расчета размеров, используется статическая ячейка.
     Данная ячейка заполняется контентом для предварительного расчета размера будущей ячейки.
     */
    @objc  static let cellForCalculateSize: TypingMessageCell = TypingMessageCell.viewFromNib()
    
    @IBOutlet private weak var firstDotView: UIView!
    @IBOutlet private weak var secondDotView: UIView!
    @IBOutlet private weak var thirdDotView: UIView!
    
    private let animationDuration: TimeInterval = 1.05

    var timer: Timer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstDotView.backgroundColor = .red
        secondDotView.backgroundColor = .red
        thirdDotView.backgroundColor = .red
        timer = Timer(timeInterval: animationDuration, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        timer.fire()
    }
    
    @objc private func animate() {
        UIView.animate(withDuration: animationDuration / 3, delay: 0, options: [], animations: {
            self.changeDotsAlpha(0.2, 1, 0.5)
        }, completion: { finished in
            UIView.animate(withDuration: self.animationDuration / 3, delay: 0, options: [], animations: {
                self.changeDotsAlpha(0.5, 0.2, 1)
            }, completion: { finished in
                UIView.animate(withDuration: self.animationDuration / 3, delay: 0, options: [], animations: {
                    self.changeDotsAlpha(1, 0.5, 0.2)
                    }, completion: { finished in
                })
            })
        })
    }
    
    private func changeDotsAlpha(_ firstDotAlpha: CGFloat, _ secondDotAlpha: CGFloat, _ thirdDotAlpha: CGFloat) {
        firstDotView.alpha = firstDotAlpha
        secondDotView.alpha = secondDotAlpha
        thirdDotView.alpha = thirdDotAlpha
    }
    
    public func bind() {
        timer.fire()
    }
    
    /**
     Расчет размера ячейки при установке ей переданного message.
     */
    static func size(width:CGFloat) -> CGSize {
        cellForCalculateSize.sizeToFit()
        cellForCalculateSize.frame.size.width = width
        return cellForCalculateSize.frame.size
    }
}
