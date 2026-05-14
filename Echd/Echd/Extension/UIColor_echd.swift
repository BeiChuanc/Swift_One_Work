import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Echd: String, alpha_Echd: CGFloat = 1.0) {
        
        var cgString_Echd = hexstring_Echd.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Echd.hasPrefix("#") {
            cgString_Echd = String(cgString_Echd.dropFirst())
        }
        
        
        guard cgString_Echd.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Echd: UInt64 = 0
        Scanner(string: cgString_Echd).scanHexInt64(&rgbValue_Echd)
        
        let r_Echd = CGFloat((rgbValue_Echd & 0xFF0000) >> 16) / 255.0
        let g_Echd = CGFloat((rgbValue_Echd & 0x00FF00) >> 8) / 255.0
        let b_Echd = CGFloat(rgbValue_Echd & 0x0000FF) / 255.0
        
        self.init(red: r_Echd, green: g_Echd, blue: b_Echd, alpha: alpha_Echd)
    }
}
