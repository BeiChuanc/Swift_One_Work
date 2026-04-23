import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Nest(_ amout_Nest: CGFloat) {
        let paddingView_Nest = UIView(frame: CGRect(x: 0, y: 0, width: amout_Nest, height: self.frame.height))
        self.leftView = paddingView_Nest
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Nest(_ amout_Nest: CGFloat) {
        let paddingView_Nest = UIView(frame: CGRect(x: 0, y: 0, width: amout_Nest, height: self.frame.height))
        self.rightView = paddingView_Nest
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Nest(_ color_Nest: UIColor) {
        guard let placeholderText_Nest = self.placeholder else { return }
        let attributes_Nest: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Nest,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Nest = NSAttributedString(string: placeholderText_Nest, attributes: attributes_Nest)
        self.attributedPlaceholder = attributePlaccehoder_Nest
    }
}
