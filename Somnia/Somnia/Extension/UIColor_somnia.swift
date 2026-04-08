import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Somnia: String, alpha_Somnia: CGFloat = 1.0) {
        
        var cgString_Somnia = hexstring_Somnia.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Somnia.hasPrefix("#") {
            cgString_Somnia = String(cgString_Somnia.dropFirst())
        }
        
        
        guard cgString_Somnia.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Somnia: UInt64 = 0
        Scanner(string: cgString_Somnia).scanHexInt64(&rgbValue_Somnia)
        
        let r_Somnia = CGFloat((rgbValue_Somnia & 0xFF0000) >> 16) / 255.0
        let g_Somnia = CGFloat((rgbValue_Somnia & 0x00FF00) >> 8) / 255.0
        let b_Somnia = CGFloat(rgbValue_Somnia & 0x0000FF) / 255.0
        
        self.init(red: r_Somnia, green: g_Somnia, blue: b_Somnia, alpha: alpha_Somnia)
    }
}
