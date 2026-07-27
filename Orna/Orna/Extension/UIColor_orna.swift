import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Orna: String, alpha_Orna: CGFloat = 1.0) {
        
        var cgString_Orna = hexstring_Orna.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Orna.hasPrefix("#") {
            cgString_Orna = String(cgString_Orna.dropFirst())
        }
        
        
        guard cgString_Orna.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Orna: UInt64 = 0
        Scanner(string: cgString_Orna).scanHexInt64(&rgbValue_Orna)
        
        let r_Orna = CGFloat((rgbValue_Orna & 0xFF0000) >> 16) / 255.0
        let g_Orna = CGFloat((rgbValue_Orna & 0x00FF00) >> 8) / 255.0
        let b_Orna = CGFloat(rgbValue_Orna & 0x0000FF) / 255.0
        
        self.init(red: r_Orna, green: g_Orna, blue: b_Orna, alpha: alpha_Orna)
    }
}
