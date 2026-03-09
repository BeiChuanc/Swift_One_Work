import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Moode: String, alpha_Moode: CGFloat = 1.0) {
        
        var cgString_Moode = hexstring_Moode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Moode.hasPrefix("#") {
            cgString_Moode = String(cgString_Moode.dropFirst())
        }
        
        
        guard cgString_Moode.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Moode: UInt64 = 0
        Scanner(string: cgString_Moode).scanHexInt64(&rgbValue_Moode)
        
        let r_Moode = CGFloat((rgbValue_Moode & 0xFF0000) >> 16) / 255.0
        let g_Moode = CGFloat((rgbValue_Moode & 0x00FF00) >> 8) / 255.0
        let b_Moode = CGFloat(rgbValue_Moode & 0x0000FF) / 255.0
        
        self.init(red: r_Moode, green: g_Moode, blue: b_Moode, alpha: alpha_Moode)
    }
}
