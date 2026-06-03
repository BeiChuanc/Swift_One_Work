import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Bague(_ amout_Bague: CGFloat) {
        let paddingView_Bague = UIView(frame: CGRect(x: 0, y: 0, width: amout_Bague, height: self.frame.height))
        self.leftView = paddingView_Bague
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Bague(_ amout_Bague: CGFloat) {
        let paddingView_Bague = UIView(frame: CGRect(x: 0, y: 0, width: amout_Bague, height: self.frame.height))
        self.rightView = paddingView_Bague
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Bague(_ color_Bague: UIColor) {
        guard let placeholderText_Bague = self.placeholder else { return }
        let attributes_Bague: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Bague,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Bague = NSAttributedString(string: placeholderText_Bague, attributes: attributes_Bague)
        self.attributedPlaceholder = attributePlaccehoder_Bague
    }
}
