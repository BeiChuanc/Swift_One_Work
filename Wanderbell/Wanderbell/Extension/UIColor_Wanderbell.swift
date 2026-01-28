import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Wanderbell: String, alpha_Wanderbell: CGFloat = 1.0) {
        
        var cgString_Wanderbell = hexstring_Wanderbell.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Wanderbell.hasPrefix("#") {
            cgString_Wanderbell = String(cgString_Wanderbell.dropFirst())
        }
        
        
        guard cgString_Wanderbell.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Wanderbell: UInt64 = 0
        Scanner(string: cgString_Wanderbell).scanHexInt64(&rgbValue_Wanderbell)
        
        let r_Wanderbell = CGFloat((rgbValue_Wanderbell & 0xFF0000) >> 16) / 255.0
        let g_Wanderbell = CGFloat((rgbValue_Wanderbell & 0x00FF00) >> 8) / 255.0
        let b_Wanderbell = CGFloat(rgbValue_Wanderbell & 0x0000FF) / 255.0
        
        self.init(red: r_Wanderbell, green: g_Wanderbell, blue: b_Wanderbell, alpha: alpha_Wanderbell)
    }
}
