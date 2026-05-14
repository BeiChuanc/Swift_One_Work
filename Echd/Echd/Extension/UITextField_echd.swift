import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Echd(_ amout_Echd: CGFloat) {
        let paddingView_Echd = UIView(frame: CGRect(x: 0, y: 0, width: amout_Echd, height: self.frame.height))
        self.leftView = paddingView_Echd
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Echd(_ amout_Echd: CGFloat) {
        let paddingView_Echd = UIView(frame: CGRect(x: 0, y: 0, width: amout_Echd, height: self.frame.height))
        self.rightView = paddingView_Echd
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Echd(_ color_Echd: UIColor) {
        guard let placeholderText_Echd = self.placeholder else { return }
        let attributes_Echd: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Echd,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Echd = NSAttributedString(string: placeholderText_Echd, attributes: attributes_Echd)
        self.attributedPlaceholder = attributePlaccehoder_Echd
    }
}
