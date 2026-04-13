import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Clara: String, alpha_Clara: CGFloat = 1.0) {
        
        var cgString_Clara = hexstring_Clara.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Clara.hasPrefix("#") {
            cgString_Clara = String(cgString_Clara.dropFirst())
        }
        
        
        guard cgString_Clara.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Clara: UInt64 = 0
        Scanner(string: cgString_Clara).scanHexInt64(&rgbValue_Clara)
        
        let r_Clara = CGFloat((rgbValue_Clara & 0xFF0000) >> 16) / 255.0
        let g_Clara = CGFloat((rgbValue_Clara & 0x00FF00) >> 8) / 255.0
        let b_Clara = CGFloat(rgbValue_Clara & 0x0000FF) / 255.0
        
        self.init(red: r_Clara, green: g_Clara, blue: b_Clara, alpha: alpha_Clara)
    }
}
