import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Doze(_ amout_Doze: CGFloat) {
        let paddingView_Doze = UIView(frame: CGRect(x: 0, y: 0, width: amout_Doze, height: self.frame.height))
        self.leftView = paddingView_Doze
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Doze(_ amout_Doze: CGFloat) {
        let paddingView_Doze = UIView(frame: CGRect(x: 0, y: 0, width: amout_Doze, height: self.frame.height))
        self.rightView = paddingView_Doze
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Doze(_ color_Doze: UIColor) {
        guard let placeholderText_Doze = self.placeholder else { return }
        let attributes_Doze: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Doze,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Doze = NSAttributedString(string: placeholderText_Doze, attributes: attributes_Doze)
        self.attributedPlaceholder = attributePlaccehoder_Doze
    }
}
