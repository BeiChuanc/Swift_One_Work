import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Lumia(_ amout_Lumia: CGFloat) {
        let paddingView_Lumia = UIView(frame: CGRect(x: 0, y: 0, width: amout_Lumia, height: self.frame.height))
        self.leftView = paddingView_Lumia
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Lumia(_ amout_Lumia: CGFloat) {
        let paddingView_Lumia = UIView(frame: CGRect(x: 0, y: 0, width: amout_Lumia, height: self.frame.height))
        self.rightView = paddingView_Lumia
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Lumia(_ color_Lumia: UIColor) {
        guard let placeholderText_Lumia = self.placeholder else { return }
        let attributes_Lumia: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Lumia,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Lumia = NSAttributedString(string: placeholderText_Lumia, attributes: attributes_Lumia)
        self.attributedPlaceholder = attributePlaccehoder_Lumia
    }
}
