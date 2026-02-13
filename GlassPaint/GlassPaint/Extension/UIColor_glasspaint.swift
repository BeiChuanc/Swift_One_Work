import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Glasspaint: String, alpha_Glasspaint: CGFloat = 1.0) {
        
        var cgString_Glasspaint = hexstring_Glasspaint.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Glasspaint.hasPrefix("#") {
            cgString_Glasspaint = String(cgString_Glasspaint.dropFirst())
        }
        
        
        guard cgString_Glasspaint.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Glasspaint: UInt64 = 0
        Scanner(string: cgString_Glasspaint).scanHexInt64(&rgbValue_Glasspaint)
        
        let r_Glasspaint = CGFloat((rgbValue_Glasspaint & 0xFF0000) >> 16) / 255.0
        let g_Glasspaint = CGFloat((rgbValue_Glasspaint & 0x00FF00) >> 8) / 255.0
        let b_Glasspaint = CGFloat(rgbValue_Glasspaint & 0x0000FF) / 255.0
        
        self.init(red: r_Glasspaint, green: g_Glasspaint, blue: b_Glasspaint, alpha: alpha_Glasspaint)
    }
}
