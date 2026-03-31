import Foundation
import UIKit

extension UIColor {
    
    /// 返回指定透明度的颜色副本
    /// 功能：项目统一透明度设置方法，替代 withAlphaComponent，禁止使用 withOpacity
    /// - Parameter alpha: 目标透明度（0.0 ~ 1.0）
    /// - Returns: 新的 UIColor 实例
    func withValues(alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
    
    convenience init(hexstring_Flick: String, alpha_Flick: CGFloat = 1.0) {
        
        var cgString_Flick = hexstring_Flick.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Flick.hasPrefix("#") {
            cgString_Flick = String(cgString_Flick.dropFirst())
        }
        
        
        guard cgString_Flick.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Flick: UInt64 = 0
        Scanner(string: cgString_Flick).scanHexInt64(&rgbValue_Flick)
        
        let r_Flick = CGFloat((rgbValue_Flick & 0xFF0000) >> 16) / 255.0
        let g_Flick = CGFloat((rgbValue_Flick & 0x00FF00) >> 8) / 255.0
        let b_Flick = CGFloat(rgbValue_Flick & 0x0000FF) / 255.0
        
        self.init(red: r_Flick, green: g_Flick, blue: b_Flick, alpha: alpha_Flick)
    }
}
