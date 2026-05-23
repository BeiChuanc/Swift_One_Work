import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Hush(_ amout_Hush: CGFloat) {
        let paddingView_Hush = UIView(frame: CGRect(x: 0, y: 0, width: amout_Hush, height: self.frame.height))
        self.leftView = paddingView_Hush
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Hush(_ amout_Hush: CGFloat) {
        let paddingView_Hush = UIView(frame: CGRect(x: 0, y: 0, width: amout_Hush, height: self.frame.height))
        self.rightView = paddingView_Hush
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Hush(_ color_Hush: UIColor) {
        guard let placeholderText_Hush = self.placeholder else { return }
        let attributes_Hush: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Hush,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Hush = NSAttributedString(string: placeholderText_Hush, attributes: attributes_Hush)
        self.attributedPlaceholder = attributePlaccehoder_Hush
    }
}
