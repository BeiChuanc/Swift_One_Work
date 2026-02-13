import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Glasspaint(_ amout_Glasspaint: CGFloat) {
        let paddingView_Glasspaint = UIView(frame: CGRect(x: 0, y: 0, width: amout_Glasspaint, height: self.frame.height))
        self.leftView = paddingView_Glasspaint
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Glasspaint(_ amout_Glasspaint: CGFloat) {
        let paddingView_Glasspaint = UIView(frame: CGRect(x: 0, y: 0, width: amout_Glasspaint, height: self.frame.height))
        self.rightView = paddingView_Glasspaint
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Glasspaint(_ color_Glasspaint: UIColor) {
        guard let placeholderText_Glasspaint = self.placeholder else { return }
        let attributes_Glasspaint: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Glasspaint,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Glasspaint = NSAttributedString(string: placeholderText_Glasspaint, attributes: attributes_Glasspaint)
        self.attributedPlaceholder = attributePlaccehoder_Glasspaint
    }
}
