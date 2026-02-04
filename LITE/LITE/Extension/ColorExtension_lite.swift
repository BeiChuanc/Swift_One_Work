import SwiftUI

// MARK: - Color 扩展
// 核心作用：提供十六进制颜色支持
// 设计思路：解析十六进制字符串并转换为 Color 对象

extension Color {
    
    /// 通过十六进制字符串初始化颜色
    /// - Parameter hex: 十六进制颜色字符串（支持 3/6/8 位）
    init(hex: String) {
        let hexString_lite = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int_lite: UInt64 = 0
        Scanner(string: hexString_lite).scanHexInt64(&int_lite)
        let a_lite, r_lite, g_lite, b_lite: UInt64
        
        switch hexString_lite.count {
        case 3: // RGB (12-bit)
            (a_lite, r_lite, g_lite, b_lite) = (255, (int_lite >> 8) * 17, (int_lite >> 4 & 0xF) * 17, (int_lite & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a_lite, r_lite, g_lite, b_lite) = (255, int_lite >> 16, int_lite >> 8 & 0xFF, int_lite & 0xFF)
        case 8: // ARGB (32-bit)
            (a_lite, r_lite, g_lite, b_lite) = (int_lite >> 24, int_lite >> 16 & 0xFF, int_lite >> 8 & 0xFF, int_lite & 0xFF)
        default:
            (a_lite, r_lite, g_lite, b_lite) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r_lite) / 255,
            green: Double(g_lite) / 255,
            blue: Double(b_lite) / 255,
            opacity: Double(a_lite) / 255
        )
    }
}
