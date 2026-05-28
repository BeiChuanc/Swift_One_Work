import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Ornit(_ amout_Ornit: CGFloat) {
        let paddingView_Ornit = UIView(frame: CGRect(x: 0, y: 0, width: amout_Ornit, height: self.frame.height))
        self.leftView = paddingView_Ornit
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Ornit(_ amout_Ornit: CGFloat) {
        let paddingView_Ornit = UIView(frame: CGRect(x: 0, y: 0, width: amout_Ornit, height: self.frame.height))
        self.rightView = paddingView_Ornit
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Ornit(_ color_Ornit: UIColor) {
        guard let placeholderText_Ornit = self.placeholder else { return }
        let attributes_Ornit: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Ornit,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Ornit = NSAttributedString(string: placeholderText_Ornit, attributes: attributes_Ornit)
        self.attributedPlaceholder = attributePlaccehoder_Ornit
    }
}
