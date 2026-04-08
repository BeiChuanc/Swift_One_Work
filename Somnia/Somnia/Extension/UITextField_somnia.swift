import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Somnia(_ amout_Somnia: CGFloat) {
        let paddingView_Somnia = UIView(frame: CGRect(x: 0, y: 0, width: amout_Somnia, height: self.frame.height))
        self.leftView = paddingView_Somnia
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Somnia(_ amout_Somnia: CGFloat) {
        let paddingView_Somnia = UIView(frame: CGRect(x: 0, y: 0, width: amout_Somnia, height: self.frame.height))
        self.rightView = paddingView_Somnia
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Somnia(_ color_Somnia: UIColor) {
        guard let placeholderText_Somnia = self.placeholder else { return }
        let attributes_Somnia: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Somnia,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Somnia = NSAttributedString(string: placeholderText_Somnia, attributes: attributes_Somnia)
        self.attributedPlaceholder = attributePlaccehoder_Somnia
    }
}
