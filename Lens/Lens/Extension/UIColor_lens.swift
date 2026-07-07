import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Lens: String, alpha_Lens: CGFloat = 1.0) {
        
        var cgString_Lens = hexstring_Lens.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Lens.hasPrefix("#") {
            cgString_Lens = String(cgString_Lens.dropFirst())
        }
        
        
        guard cgString_Lens.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Lens: UInt64 = 0
        Scanner(string: cgString_Lens).scanHexInt64(&rgbValue_Lens)
        
        let r_Lens = CGFloat((rgbValue_Lens & 0xFF0000) >> 16) / 255.0
        let g_Lens = CGFloat((rgbValue_Lens & 0x00FF00) >> 8) / 255.0
        let b_Lens = CGFloat(rgbValue_Lens & 0x0000FF) / 255.0
        
        self.init(red: r_Lens, green: g_Lens, blue: b_Lens, alpha: alpha_Lens)
    }
}
