import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Lens(_ amout_Lens: CGFloat) {
        let paddingView_Lens = UIView(frame: CGRect(x: 0, y: 0, width: amout_Lens, height: self.frame.height))
        self.leftView = paddingView_Lens
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Lens(_ amout_Lens: CGFloat) {
        let paddingView_Lens = UIView(frame: CGRect(x: 0, y: 0, width: amout_Lens, height: self.frame.height))
        self.rightView = paddingView_Lens
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Lens(_ color_Lens: UIColor) {
        guard let placeholderText_Lens = self.placeholder else { return }
        let attributes_Lens: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Lens,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Lens = NSAttributedString(string: placeholderText_Lens, attributes: attributes_Lens)
        self.attributedPlaceholder = attributePlaccehoder_Lens
    }
}
