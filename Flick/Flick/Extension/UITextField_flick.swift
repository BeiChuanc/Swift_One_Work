import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Flick(_ amout_Flick: CGFloat) {
        let paddingView_Flick = UIView(frame: CGRect(x: 0, y: 0, width: amout_Flick, height: self.frame.height))
        self.leftView = paddingView_Flick
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Flick(_ amout_Flick: CGFloat) {
        let paddingView_Flick = UIView(frame: CGRect(x: 0, y: 0, width: amout_Flick, height: self.frame.height))
        self.rightView = paddingView_Flick
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Flick(_ color_Flick: UIColor) {
        guard let placeholderText_Flick = self.placeholder else { return }
        let attributes_Flick: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Flick,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Flick = NSAttributedString(string: placeholderText_Flick, attributes: attributes_Flick)
        self.attributedPlaceholder = attributePlaccehoder_Flick
    }
}
