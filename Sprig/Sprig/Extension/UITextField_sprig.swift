import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Sprig(_ amout_Sprig: CGFloat) {
        let paddingView_Sprig = UIView(frame: CGRect(x: 0, y: 0, width: amout_Sprig, height: self.frame.height))
        self.leftView = paddingView_Sprig
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Sprig(_ amout_Sprig: CGFloat) {
        let paddingView_Sprig = UIView(frame: CGRect(x: 0, y: 0, width: amout_Sprig, height: self.frame.height))
        self.rightView = paddingView_Sprig
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Sprig(_ color_Sprig: UIColor) {
        guard let placeholderText_Sprig = self.placeholder else { return }
        let attributes_Sprig: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Sprig,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Sprig = NSAttributedString(string: placeholderText_Sprig, attributes: attributes_Sprig)
        self.attributedPlaceholder = attributePlaccehoder_Sprig
    }
}
