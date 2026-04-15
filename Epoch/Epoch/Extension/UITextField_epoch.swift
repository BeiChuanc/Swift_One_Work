import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Epoch(_ amout_Epoch: CGFloat) {
        let paddingView_Epoch = UIView(frame: CGRect(x: 0, y: 0, width: amout_Epoch, height: self.frame.height))
        self.leftView = paddingView_Epoch
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Epoch(_ amout_Epoch: CGFloat) {
        let paddingView_Epoch = UIView(frame: CGRect(x: 0, y: 0, width: amout_Epoch, height: self.frame.height))
        self.rightView = paddingView_Epoch
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Epoch(_ color_Epoch: UIColor) {
        guard let placeholderText_Epoch = self.placeholder else { return }
        let attributes_Epoch: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Epoch,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Epoch = NSAttributedString(string: placeholderText_Epoch, attributes: attributes_Epoch)
        self.attributedPlaceholder = attributePlaccehoder_Epoch
    }
}
