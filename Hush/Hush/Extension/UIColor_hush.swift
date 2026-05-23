import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Hush: String, alpha_Hush: CGFloat = 1.0) {
        
        var cgString_Hush = hexstring_Hush.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Hush.hasPrefix("#") {
            cgString_Hush = String(cgString_Hush.dropFirst())
        }
        
        
        guard cgString_Hush.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Hush: UInt64 = 0
        Scanner(string: cgString_Hush).scanHexInt64(&rgbValue_Hush)
        
        let r_Hush = CGFloat((rgbValue_Hush & 0xFF0000) >> 16) / 255.0
        let g_Hush = CGFloat((rgbValue_Hush & 0x00FF00) >> 8) / 255.0
        let b_Hush = CGFloat(rgbValue_Hush & 0x0000FF) / 255.0
        
        self.init(red: r_Hush, green: g_Hush, blue: b_Hush, alpha: alpha_Hush)
    }
}
