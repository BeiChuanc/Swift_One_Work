import Foundation
import UIKit

extension UIColor {

    /// 返回指定透明度的颜色副本（项目统一透明方法，禁止直接使用 withOpacity / withValues）
    /// - Parameter alpha_pane: 透明度（0.0 ~ 1.0）
    /// - Returns: 设置透明度后的新 UIColor
    func alpha_Pane(_ alpha_pane: CGFloat) -> UIColor {
        return withAlphaComponent(alpha_pane)
    }
    
    convenience init(hexstring_Pane: String, alpha_Pane: CGFloat = 1.0) {
        
        var cgString_Pane = hexstring_Pane.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Pane.hasPrefix("#") {
            cgString_Pane = String(cgString_Pane.dropFirst())
        }
        
        
        guard cgString_Pane.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Pane: UInt64 = 0
        Scanner(string: cgString_Pane).scanHexInt64(&rgbValue_Pane)
        
        let r_Pane = CGFloat((rgbValue_Pane & 0xFF0000) >> 16) / 255.0
        let g_Pane = CGFloat((rgbValue_Pane & 0x00FF00) >> 8) / 255.0
        let b_Pane = CGFloat(rgbValue_Pane & 0x0000FF) / 255.0
        
        self.init(red: r_Pane, green: g_Pane, blue: b_Pane, alpha: alpha_Pane)
    }
}
