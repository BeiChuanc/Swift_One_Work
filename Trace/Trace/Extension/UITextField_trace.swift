import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Trace(_ amout_Trace: CGFloat) {
        let paddingView_Trace = UIView(frame: CGRect(x: 0, y: 0, width: amout_Trace, height: self.frame.height))
        self.leftView = paddingView_Trace
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Trace(_ amout_Trace: CGFloat) {
        let paddingView_Trace = UIView(frame: CGRect(x: 0, y: 0, width: amout_Trace, height: self.frame.height))
        self.rightView = paddingView_Trace
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Trace(_ color_Trace: UIColor) {
        guard let placeholderText_Trace = self.placeholder else { return }
        let attributes_Trace: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Trace,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Trace = NSAttributedString(string: placeholderText_Trace, attributes: attributes_Trace)
        self.attributedPlaceholder = attributePlaccehoder_Trace
    }
}
