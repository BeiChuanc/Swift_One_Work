import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Niche(_ amout_Niche: CGFloat) {
        let paddingView_Niche = UIView(frame: CGRect(x: 0, y: 0, width: amout_Niche, height: self.frame.height))
        self.leftView = paddingView_Niche
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Niche(_ amout_Niche: CGFloat) {
        let paddingView_Niche = UIView(frame: CGRect(x: 0, y: 0, width: amout_Niche, height: self.frame.height))
        self.rightView = paddingView_Niche
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Niche(_ color_Niche: UIColor) {
        guard let placeholderText_Niche = self.placeholder else { return }
        let attributes_Niche: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Niche,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Niche = NSAttributedString(string: placeholderText_Niche, attributes: attributes_Niche)
        self.attributedPlaceholder = attributePlaccehoder_Niche
    }
}
