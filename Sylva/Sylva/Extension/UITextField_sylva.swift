import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Sylva(_ amout_Sylva: CGFloat) {
        let paddingView_Sylva = UIView(frame: CGRect(x: 0, y: 0, width: amout_Sylva, height: self.frame.height))
        self.leftView = paddingView_Sylva
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Sylva(_ amout_Sylva: CGFloat) {
        let paddingView_Sylva = UIView(frame: CGRect(x: 0, y: 0, width: amout_Sylva, height: self.frame.height))
        self.rightView = paddingView_Sylva
        self.rightViewMode = .always
    }
    
    // PlaceHodlerTextColor
    func placeHolderTextColor_Sylva(_ color_Sylva: UIColor) {
        guard let placeholderText_Sylva = self.placeholder else { return }
        let attributes_Sylva: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Sylva,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Sylva = NSAttributedString(string: placeholderText_Sylva, attributes: attributes_Sylva)
        self.attributedPlaceholder = attributePlaccehoder_Sylva
    }
    
    /// 设置左侧内边距
    func setLeftPadding_Sylva(padding_Sylva: CGFloat) {
        addLeftPadding_Sylva(padding_Sylva)
    }
    
    /// 设置右侧内边距
    func setRightPadding_Sylva(padding_Sylva: CGFloat) {
        addRightPadding_Sylva(padding_Sylva)
    }
    
    /// 同时设置占位符文字和颜色
    func setPlaceholder_Sylva(placeholder_Sylva: String, color_Sylva: UIColor) {
        let attributes_Sylva: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Sylva,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        self.attributedPlaceholder = NSAttributedString(string: placeholder_Sylva, attributes: attributes_Sylva)
    }
}
