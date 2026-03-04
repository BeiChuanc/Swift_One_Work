import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Trace: String, alpha_Trace: CGFloat = 1.0) {
        
        var cgString_Trace = hexstring_Trace.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Trace.hasPrefix("#") {
            cgString_Trace = String(cgString_Trace.dropFirst())
        }
        
        
        guard cgString_Trace.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Trace: UInt64 = 0
        Scanner(string: cgString_Trace).scanHexInt64(&rgbValue_Trace)
        
        let r_Trace = CGFloat((rgbValue_Trace & 0xFF0000) >> 16) / 255.0
        let g_Trace = CGFloat((rgbValue_Trace & 0x00FF00) >> 8) / 255.0
        let b_Trace = CGFloat(rgbValue_Trace & 0x0000FF) / 255.0
        
        self.init(red: r_Trace, green: g_Trace, blue: b_Trace, alpha: alpha_Trace)
    }
}
