import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Retrs(_ amout_Retrs: CGFloat) {
        let paddingView_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: amout_Retrs, height: self.frame.height))
        self.leftView = paddingView_Retrs
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Retrs(_ amout_Retrs: CGFloat) {
        let paddingView_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: amout_Retrs, height: self.frame.height))
        self.rightView = paddingView_Retrs
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Retrs(_ color_Retrs: UIColor) {
        guard let placeholderText_Retrs = self.placeholder else { return }
        let attributes_Retrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Retrs,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Retrs = NSAttributedString(string: placeholderText_Retrs, attributes: attributes_Retrs)
        self.attributedPlaceholder = attributePlaccehoder_Retrs
    }
}
