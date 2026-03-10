import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Doze: String, alpha_Doze: CGFloat = 1.0) {
        
        var cgString_Doze = hexstring_Doze.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Doze.hasPrefix("#") {
            cgString_Doze = String(cgString_Doze.dropFirst())
        }
        
        
        guard cgString_Doze.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Doze: UInt64 = 0
        Scanner(string: cgString_Doze).scanHexInt64(&rgbValue_Doze)
        
        let r_Doze = CGFloat((rgbValue_Doze & 0xFF0000) >> 16) / 255.0
        let g_Doze = CGFloat((rgbValue_Doze & 0x00FF00) >> 8) / 255.0
        let b_Doze = CGFloat(rgbValue_Doze & 0x0000FF) / 255.0
        
        self.init(red: r_Doze, green: g_Doze, blue: b_Doze, alpha: alpha_Doze)
    }
}
