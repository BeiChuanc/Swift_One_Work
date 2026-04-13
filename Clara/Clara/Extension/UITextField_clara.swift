import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Clara(_ amout_Clara: CGFloat) {
        let paddingView_Clara = UIView(frame: CGRect(x: 0, y: 0, width: amout_Clara, height: self.frame.height))
        self.leftView = paddingView_Clara
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Clara(_ amout_Clara: CGFloat) {
        let paddingView_Clara = UIView(frame: CGRect(x: 0, y: 0, width: amout_Clara, height: self.frame.height))
        self.rightView = paddingView_Clara
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Clara(_ color_Clara: UIColor) {
        guard let placeholderText_Clara = self.placeholder else { return }
        let attributes_Clara: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Clara,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Clara = NSAttributedString(string: placeholderText_Clara, attributes: attributes_Clara)
        self.attributedPlaceholder = attributePlaccehoder_Clara
    }
}
