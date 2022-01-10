import UIKit

/**
 View с тенью. Тень перерисовывается при каждом изменении фрейма View.
 */
class ShadowView: UIView {

    private func dropShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    override func layoutSubviews() {
        superview?.layoutSubviews()
        
        dropShadow()
    }
}
