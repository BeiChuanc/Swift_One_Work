import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Niche: String, alpha_Niche: CGFloat = 1.0) {
        
        var cgString_Niche = hexstring_Niche.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Niche.hasPrefix("#") {
            cgString_Niche = String(cgString_Niche.dropFirst())
        }
        
        
        guard cgString_Niche.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Niche: UInt64 = 0
        Scanner(string: cgString_Niche).scanHexInt64(&rgbValue_Niche)
        
        let r_Niche = CGFloat((rgbValue_Niche & 0xFF0000) >> 16) / 255.0
        let g_Niche = CGFloat((rgbValue_Niche & 0x00FF00) >> 8) / 255.0
        let b_Niche = CGFloat(rgbValue_Niche & 0x0000FF) / 255.0
        
        self.init(red: r_Niche, green: g_Niche, blue: b_Niche, alpha: alpha_Niche)
    }
    
    /// 兼容 iOS 15+ 的透明度调整方法（替代仅 iOS 17+ 可用的 withValues(alpha:)）
    /// - Parameter alpha: 目标透明度（0.0 ~ 1.0）
    /// - Returns: 调整透明度后的新颜色
    func withValues(alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
}
