import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Sprig: String, alpha_Sprig: CGFloat = 1.0) {
        
        var cgString_Sprig = hexstring_Sprig.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Sprig.hasPrefix("#") {
            cgString_Sprig = String(cgString_Sprig.dropFirst())
        }
        
        
        guard cgString_Sprig.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Sprig: UInt64 = 0
        Scanner(string: cgString_Sprig).scanHexInt64(&rgbValue_Sprig)
        
        let r_Sprig = CGFloat((rgbValue_Sprig & 0xFF0000) >> 16) / 255.0
        let g_Sprig = CGFloat((rgbValue_Sprig & 0x00FF00) >> 8) / 255.0
        let b_Sprig = CGFloat(rgbValue_Sprig & 0x0000FF) / 255.0
        
        self.init(red: r_Sprig, green: g_Sprig, blue: b_Sprig, alpha: alpha_Sprig)
    }
}
