import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Lumia: String, alpha_Lumia: CGFloat = 1.0) {
        
        var cgString_Lumia = hexstring_Lumia.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Lumia.hasPrefix("#") {
            cgString_Lumia = String(cgString_Lumia.dropFirst())
        }
        
        
        guard cgString_Lumia.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Lumia: UInt64 = 0
        Scanner(string: cgString_Lumia).scanHexInt64(&rgbValue_Lumia)
        
        let r_Lumia = CGFloat((rgbValue_Lumia & 0xFF0000) >> 16) / 255.0
        let g_Lumia = CGFloat((rgbValue_Lumia & 0x00FF00) >> 8) / 255.0
        let b_Lumia = CGFloat(rgbValue_Lumia & 0x0000FF) / 255.0
        
        self.init(red: r_Lumia, green: g_Lumia, blue: b_Lumia, alpha: alpha_Lumia)
    }
}
