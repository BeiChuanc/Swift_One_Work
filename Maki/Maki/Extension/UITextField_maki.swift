import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Maki(_ amout_Maki: CGFloat) {
        let paddingView_Maki = UIView(frame: CGRect(x: 0, y: 0, width: amout_Maki, height: self.frame.height))
        self.leftView = paddingView_Maki
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Maki(_ amout_Maki: CGFloat) {
        let paddingView_Maki = UIView(frame: CGRect(x: 0, y: 0, width: amout_Maki, height: self.frame.height))
        self.rightView = paddingView_Maki
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Maki(_ color_Maki: UIColor) {
        guard let placeholderText_Maki = self.placeholder else { return }
        let attributes_Maki: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Maki,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Maki = NSAttributedString(string: placeholderText_Maki, attributes: attributes_Maki)
        self.attributedPlaceholder = attributePlaccehoder_Maki
    }
}
