import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Breeze: String, alpha_Breeze: CGFloat = 1.0) {
        
        var cgString_Breeze = hexstring_Breeze.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Breeze.hasPrefix("#") {
            cgString_Breeze = String(cgString_Breeze.dropFirst())
        }
        
        
        guard cgString_Breeze.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Breeze: UInt64 = 0
        Scanner(string: cgString_Breeze).scanHexInt64(&rgbValue_Breeze)
        
        let r_Breeze = CGFloat((rgbValue_Breeze & 0xFF0000) >> 16) / 255.0
        let g_Breeze = CGFloat((rgbValue_Breeze & 0x00FF00) >> 8) / 255.0
        let b_Breeze = CGFloat(rgbValue_Breeze & 0x0000FF) / 255.0
        
        self.init(red: r_Breeze, green: g_Breeze, blue: b_Breeze, alpha: alpha_Breeze)
    }
}
