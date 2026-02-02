import SwiftUI

// MARK: - Color 扩展
// 核心作用：提供十六进制颜色支持
// 设计思路：解析十六进制字符串并转换为 Color 对象

extension Color {
    
    /// 通过十六进制字符串初始化颜色
    /// - Parameter hex: 十六进制颜色字符串（支持 3/6/8 位）
    init(hex: String) {
        let hexString_blisslink = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int_blisslink: UInt64 = 0
        Scanner(string: hexString_blisslink).scanHexInt64(&int_blisslink)
        let a_blisslink, r_blisslink, g_blisslink, b_blisslink: UInt64
        
        switch hexString_blisslink.count {
        case 3: // RGB (12-bit)
            (a_blisslink, r_blisslink, g_blisslink, b_blisslink) = (255, (int_blisslink >> 8) * 17, (int_blisslink >> 4 & 0xF) * 17, (int_blisslink & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a_blisslink, r_blisslink, g_blisslink, b_blisslink) = (255, int_blisslink >> 16, int_blisslink >> 8 & 0xFF, int_blisslink & 0xFF)
        case 8: // ARGB (32-bit)
            (a_blisslink, r_blisslink, g_blisslink, b_blisslink) = (int_blisslink >> 24, int_blisslink >> 16 & 0xFF, int_blisslink >> 8 & 0xFF, int_blisslink & 0xFF)
        default:
            (a_blisslink, r_blisslink, g_blisslink, b_blisslink) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r_blisslink) / 255,
            green: Double(g_blisslink) / 255,
            blue: Double(b_blisslink) / 255,
            opacity: Double(a_blisslink) / 255
        )
    }
}
