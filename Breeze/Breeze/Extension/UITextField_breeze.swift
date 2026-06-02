import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Breeze(_ amout_Breeze: CGFloat) {
        let paddingView_Breeze = UIView(frame: CGRect(x: 0, y: 0, width: amout_Breeze, height: self.frame.height))
        self.leftView = paddingView_Breeze
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Breeze(_ amout_Breeze: CGFloat) {
        let paddingView_Breeze = UIView(frame: CGRect(x: 0, y: 0, width: amout_Breeze, height: self.frame.height))
        self.rightView = paddingView_Breeze
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Breeze(_ color_Breeze: UIColor) {
        guard let placeholderText_Breeze = self.placeholder else { return }
        let attributes_Breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Breeze,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Breeze = NSAttributedString(string: placeholderText_Breeze, attributes: attributes_Breeze)
        self.attributedPlaceholder = attributePlaccehoder_Breeze
    }
}
