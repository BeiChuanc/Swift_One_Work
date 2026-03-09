import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Moode(_ amout_Moode: CGFloat) {
        let paddingView_Moode = UIView(frame: CGRect(x: 0, y: 0, width: amout_Moode, height: self.frame.height))
        self.leftView = paddingView_Moode
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Moode(_ amout_Moode: CGFloat) {
        let paddingView_Moode = UIView(frame: CGRect(x: 0, y: 0, width: amout_Moode, height: self.frame.height))
        self.rightView = paddingView_Moode
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Moode(_ color_Moode: UIColor) {
        guard let placeholderText_Moode = self.placeholder else { return }
        let attributes_Moode: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Moode,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Moode = NSAttributedString(string: placeholderText_Moode, attributes: attributes_Moode)
        self.attributedPlaceholder = attributePlaccehoder_Moode
    }
}
