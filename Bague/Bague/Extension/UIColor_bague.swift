import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Bague: String, alpha_Bague: CGFloat = 1.0) {
        
        var cgString_Bague = hexstring_Bague.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Bague.hasPrefix("#") {
            cgString_Bague = String(cgString_Bague.dropFirst())
        }
        
        
        guard cgString_Bague.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Bague: UInt64 = 0
        Scanner(string: cgString_Bague).scanHexInt64(&rgbValue_Bague)
        
        let r_Bague = CGFloat((rgbValue_Bague & 0xFF0000) >> 16) / 255.0
        let g_Bague = CGFloat((rgbValue_Bague & 0x00FF00) >> 8) / 255.0
        let b_Bague = CGFloat(rgbValue_Bague & 0x0000FF) / 255.0
        
        self.init(red: r_Bague, green: g_Bague, blue: b_Bague, alpha: alpha_Bague)
    }
}
