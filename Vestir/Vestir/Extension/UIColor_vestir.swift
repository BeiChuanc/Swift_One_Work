import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Vestir: String, alpha_Vestir: CGFloat = 1.0) {
        
        var cgString_Vestir = hexstring_Vestir.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Vestir.hasPrefix("#") {
            cgString_Vestir = String(cgString_Vestir.dropFirst())
        }
        
        
        guard cgString_Vestir.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Vestir: UInt64 = 0
        Scanner(string: cgString_Vestir).scanHexInt64(&rgbValue_Vestir)
        
        let r_Vestir = CGFloat((rgbValue_Vestir & 0xFF0000) >> 16) / 255.0
        let g_Vestir = CGFloat((rgbValue_Vestir & 0x00FF00) >> 8) / 255.0
        let b_Vestir = CGFloat(rgbValue_Vestir & 0x0000FF) / 255.0
        
        self.init(red: r_Vestir, green: g_Vestir, blue: b_Vestir, alpha: alpha_Vestir)
    }
}
