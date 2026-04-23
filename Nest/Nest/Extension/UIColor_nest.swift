import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Nest: String, alpha_Nest: CGFloat = 1.0) {
        
        var cgString_Nest = hexstring_Nest.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Nest.hasPrefix("#") {
            cgString_Nest = String(cgString_Nest.dropFirst())
        }
        
        
        guard cgString_Nest.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Nest: UInt64 = 0
        Scanner(string: cgString_Nest).scanHexInt64(&rgbValue_Nest)
        
        let r_Nest = CGFloat((rgbValue_Nest & 0xFF0000) >> 16) / 255.0
        let g_Nest = CGFloat((rgbValue_Nest & 0x00FF00) >> 8) / 255.0
        let b_Nest = CGFloat(rgbValue_Nest & 0x0000FF) / 255.0
        
        self.init(red: r_Nest, green: g_Nest, blue: b_Nest, alpha: alpha_Nest)
    }
}
