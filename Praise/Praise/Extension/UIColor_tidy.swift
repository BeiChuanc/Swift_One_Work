import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Tidy: String, alpha_Tidy: CGFloat = 1.0) {
        
        var cgString_Tidy = hexstring_Tidy.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Tidy.hasPrefix("#") {
            cgString_Tidy = String(cgString_Tidy.dropFirst())
        }
        
        
        guard cgString_Tidy.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Tidy: UInt64 = 0
        Scanner(string: cgString_Tidy).scanHexInt64(&rgbValue_Tidy)
        
        let r_Tidy = CGFloat((rgbValue_Tidy & 0xFF0000) >> 16) / 255.0
        let g_Tidy = CGFloat((rgbValue_Tidy & 0x00FF00) >> 8) / 255.0
        let b_Tidy = CGFloat(rgbValue_Tidy & 0x0000FF) / 255.0
        
        self.init(red: r_Tidy, green: g_Tidy, blue: b_Tidy, alpha: alpha_Tidy)
    }

    /// 返回指定透明度的颜色副本
    /// - Parameter alpha: 透明度，取值范围 0.0（完全透明）~ 1.0（完全不透明）
    /// - Returns: 应用透明度后的 UIColor
    func withValues(alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
}
