import Foundation
import UIKit

extension UITextField {
    
    // LeftAdd
    func addLeftPadding_Vestir(_ amout_Vestir: CGFloat) {
        let paddingView_Vestir = UIView(frame: CGRect(x: 0, y: 0, width: amout_Vestir, height: self.frame.height))
        self.leftView = paddingView_Vestir
        self.leftViewMode = .always
    }
    
    // RightAdd
    func addRightPadding_Vestir(_ amout_Vestir: CGFloat) {
        let paddingView_Vestir = UIView(frame: CGRect(x: 0, y: 0, width: amout_Vestir, height: self.frame.height))
        self.rightView = paddingView_Vestir
        self.rightViewMode = .always
    }
    
    /// 设置带系统图标的左侧内边距
    /// - Parameters:
    ///   - icon: SF Symbol 图标名称
    ///   - tintColor: 图标颜色
    func setLeftPadding_Vestir(icon iconName_Vestir: String, tintColor color_Vestir: UIColor) {
        let containerView_Vestir = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let iconView_Vestir = UIImageView(frame: CGRect(x: 12, y: 12, width: 20, height: 20))
        let config_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iconView_Vestir.image = UIImage(systemName: iconName_Vestir, withConfiguration: config_Vestir)
        iconView_Vestir.tintColor = color_Vestir
        iconView_Vestir.contentMode = .scaleAspectFit
        containerView_Vestir.addSubview(iconView_Vestir)
        self.leftView = containerView_Vestir
        self.leftViewMode = .always
    }

    // PlaceHodlerTextColor
    func placeHolderTextColor_Vestir(_ color_Vestir: UIColor) {
        guard let placeholderText_Vestir = self.placeholder else { return }
        let attributes_Vestir: [NSAttributedString.Key: Any] = [
            .foregroundColor: color_Vestir,
            .font: self.font ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributePlaccehoder_Vestir = NSAttributedString(string: placeholderText_Vestir, attributes: attributes_Vestir)
        self.attributedPlaceholder = attributePlaccehoder_Vestir
    }
}
