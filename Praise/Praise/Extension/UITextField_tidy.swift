import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Tidy(_ amout_Tidy: CGFloat) {
        let paddingView_Tidy = UIView(frame: CGRect(x: 0, y: 0, width: amout_Tidy, height: self.frame.height))
        self.leftView = paddingView_Tidy
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Tidy(_ amout_Tidy: CGFloat) {
        let paddingView_Tidy = UIView(frame: CGRect(x: 0, y: 0, width: amout_Tidy, height: self.frame.height))
        self.rightView = paddingView_Tidy
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Tidy(_ color_Tidy: UIColor) {
        guard let placeholderText_Tidy = self.placeholder else { return }
        let attributes_Tidy: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Tidy,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Tidy = NSAttributedString(string: placeholderText_Tidy, attributes: attributes_Tidy)
        self.attributedPlaceholder = attributePlaccehoder_Tidy
    }
}
