import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Maki: String, alpha_Maki: CGFloat = 1.0) {
        
        var cgString_Maki = hexstring_Maki.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Maki.hasPrefix("#") {
            cgString_Maki = String(cgString_Maki.dropFirst())
        }
        
        
        guard cgString_Maki.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Maki: UInt64 = 0
        Scanner(string: cgString_Maki).scanHexInt64(&rgbValue_Maki)
        
        let r_Maki = CGFloat((rgbValue_Maki & 0xFF0000) >> 16) / 255.0
        let g_Maki = CGFloat((rgbValue_Maki & 0x00FF00) >> 8) / 255.0
        let b_Maki = CGFloat(rgbValue_Maki & 0x0000FF) / 255.0
        
        self.init(red: r_Maki, green: g_Maki, blue: b_Maki, alpha: alpha_Maki)
    }
}
