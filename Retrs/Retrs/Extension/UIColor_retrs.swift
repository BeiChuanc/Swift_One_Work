import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Retrs: String, alpha_Retrs: CGFloat = 1.0) {
        
        var cgString_Retrs = hexstring_Retrs.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Retrs.hasPrefix("#") {
            cgString_Retrs = String(cgString_Retrs.dropFirst())
        }
        
        
        guard cgString_Retrs.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Retrs: UInt64 = 0
        Scanner(string: cgString_Retrs).scanHexInt64(&rgbValue_Retrs)
        
        let r_Retrs = CGFloat((rgbValue_Retrs & 0xFF0000) >> 16) / 255.0
        let g_Retrs = CGFloat((rgbValue_Retrs & 0x00FF00) >> 8) / 255.0
        let b_Retrs = CGFloat(rgbValue_Retrs & 0x0000FF) / 255.0
        
        self.init(red: r_Retrs, green: g_Retrs, blue: b_Retrs, alpha: alpha_Retrs)
    }
    
    func withValues(alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
}
