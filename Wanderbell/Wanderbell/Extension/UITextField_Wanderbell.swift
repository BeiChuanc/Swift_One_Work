import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Wanderbell(_ amout_Wanderbell: CGFloat) {
        let paddingView_Wanderbell = UIView(frame: CGRect(x: 0, y: 0, width: amout_Wanderbell, height: self.frame.height))
        self.leftView = paddingView_Wanderbell
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Wanderbell(_ amout_Wanderbell: CGFloat) {
        let paddingView_Wanderbell = UIView(frame: CGRect(x: 0, y: 0, width: amout_Wanderbell, height: self.frame.height))
        self.rightView = paddingView_Wanderbell
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Wanderbell(_ color_Wanderbell: UIColor) {
        guard let placeholderText_Wanderbell = self.placeholder else { return }
        let attributes_Wanderbell: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Wanderbell,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Wanderbell = NSAttributedString(string: placeholderText_Wanderbell, attributes: attributes_Wanderbell)
        self.attributedPlaceholder = attributePlaccehoder_Wanderbell
    }
}
