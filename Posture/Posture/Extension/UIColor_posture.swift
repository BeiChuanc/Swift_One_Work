import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Posture: String, alpha_Posture: CGFloat = 1.0) {
        
        var cgString_Posture = hexstring_Posture.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Posture.hasPrefix("#") {
            cgString_Posture = String(cgString_Posture.dropFirst())
        }
        
        
        guard cgString_Posture.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Posture: UInt64 = 0
        Scanner(string: cgString_Posture).scanHexInt64(&rgbValue_Posture)
        
        let r_Posture = CGFloat((rgbValue_Posture & 0xFF0000) >> 16) / 255.0
        let g_Posture = CGFloat((rgbValue_Posture & 0x00FF00) >> 8) / 255.0
        let b_Posture = CGFloat(rgbValue_Posture & 0x0000FF) / 255.0
        
        self.init(red: r_Posture, green: g_Posture, blue: b_Posture, alpha: alpha_Posture)
    }
}
