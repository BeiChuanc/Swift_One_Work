import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Sylva: String, alpha_Sylva: CGFloat = 1.0) {
        
        var cgString_Sylva = hexstring_Sylva.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Sylva.hasPrefix("#") {
            cgString_Sylva = String(cgString_Sylva.dropFirst())
        }
        
        
        guard cgString_Sylva.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Sylva: UInt64 = 0
        Scanner(string: cgString_Sylva).scanHexInt64(&rgbValue_Sylva)
        
        let r_Sylva = CGFloat((rgbValue_Sylva & 0xFF0000) >> 16) / 255.0
        let g_Sylva = CGFloat((rgbValue_Sylva & 0x00FF00) >> 8) / 255.0
        let b_Sylva = CGFloat(rgbValue_Sylva & 0x0000FF) / 255.0
        
        self.init(red: r_Sylva, green: g_Sylva, blue: b_Sylva, alpha: alpha_Sylva)
    }
}
