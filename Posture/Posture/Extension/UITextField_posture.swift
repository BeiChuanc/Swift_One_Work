import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Posture(_ amout_Posture: CGFloat) {
        let paddingView_Posture = UIView(frame: CGRect(x: 0, y: 0, width: amout_Posture, height: self.frame.height))
        self.leftView = paddingView_Posture
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Posture(_ amout_Posture: CGFloat) {
        let paddingView_Posture = UIView(frame: CGRect(x: 0, y: 0, width: amout_Posture, height: self.frame.height))
        self.rightView = paddingView_Posture
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Posture(_ color_Posture: UIColor) {
        guard let placeholderText_Posture = self.placeholder else { return }
        let attributes_Posture: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Posture,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Posture = NSAttributedString(string: placeholderText_Posture, attributes: attributes_Posture)
        self.attributedPlaceholder = attributePlaccehoder_Posture
    }
}
