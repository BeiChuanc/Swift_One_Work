import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Pane(_ amout_Pane: CGFloat) {
        let paddingView_Pane = UIView(frame: CGRect(x: 0, y: 0, width: amout_Pane, height: self.frame.height))
        self.leftView = paddingView_Pane
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Pane(_ amout_Pane: CGFloat) {
        let paddingView_Pane = UIView(frame: CGRect(x: 0, y: 0, width: amout_Pane, height: self.frame.height))
        self.rightView = paddingView_Pane
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Pane(_ color_Pane: UIColor) {
        guard let placeholderText_Pane = self.placeholder else { return }
        let attributes_Pane: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Pane,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Pane = NSAttributedString(string: placeholderText_Pane, attributes: attributes_Pane)
        self.attributedPlaceholder = attributePlaccehoder_Pane
    }
}
