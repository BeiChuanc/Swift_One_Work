import Foundation
import UIKit

extension UIColor {
    
    /// 返回指定透明度的颜色副本（兼容 iOS 17 以下系统）
    /// - Parameter alpha: 目标透明度，范围 0.0 ~ 1.0
    /// - Returns: 设置了新透明度的 UIColor
    func withValues(alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
    
    convenience init(hexstring_Ornit: String, alpha_Ornit: CGFloat = 1.0) {
        
        var cgString_Ornit = hexstring_Ornit.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Ornit.hasPrefix("#") {
            cgString_Ornit = String(cgString_Ornit.dropFirst())
        }
        
        
        guard cgString_Ornit.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Ornit: UInt64 = 0
        Scanner(string: cgString_Ornit).scanHexInt64(&rgbValue_Ornit)
        
        let r_Ornit = CGFloat((rgbValue_Ornit & 0xFF0000) >> 16) / 255.0
        let g_Ornit = CGFloat((rgbValue_Ornit & 0x00FF00) >> 8) / 255.0
        let b_Ornit = CGFloat(rgbValue_Ornit & 0x0000FF) / 255.0
        
        self.init(red: r_Ornit, green: g_Ornit, blue: b_Ornit, alpha: alpha_Ornit)
    }
}
