import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Base_one(_ amout_Base_one: CGFloat) {
        let paddingView_Base_one = UIView(frame: CGRect(x: 0, y: 0, width: amout_Base_one, height: self.frame.height))
        self.leftView = paddingView_Base_one
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Base_one(_ amout_Base_one: CGFloat) {
        let paddingView_Base_one = UIView(frame: CGRect(x: 0, y: 0, width: amout_Base_one, height: self.frame.height))
        self.rightView = paddingView_Base_one
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Base_one(_ color_Base_one: UIColor) {
        guard let placeholderText_Base_one = self.placeholder else { return }
        let attributes_Base_one: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Base_one,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Base_one = NSAttributedString(string: placeholderText_Base_one, attributes: attributes_Base_one)
        self.attributedPlaceholder = attributePlaccehoder_Base_one
    }
}
