import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Epoch: String, alpha_Epoch: CGFloat = 1.0) {
        
        var cgString_Epoch = hexstring_Epoch.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Epoch.hasPrefix("#") {
            cgString_Epoch = String(cgString_Epoch.dropFirst())
        }
        
        
        guard cgString_Epoch.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Epoch: UInt64 = 0
        Scanner(string: cgString_Epoch).scanHexInt64(&rgbValue_Epoch)
        
        let r_Epoch = CGFloat((rgbValue_Epoch & 0xFF0000) >> 16) / 255.0
        let g_Epoch = CGFloat((rgbValue_Epoch & 0x00FF00) >> 8) / 255.0
        let b_Epoch = CGFloat(rgbValue_Epoch & 0x0000FF) / 255.0
        
        self.init(red: r_Epoch, green: g_Epoch, blue: b_Epoch, alpha: alpha_Epoch)
    }
}
