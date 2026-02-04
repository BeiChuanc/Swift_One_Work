import SwiftUI

// MARK: - Color 扩展
// 核心作用：提供十六进制颜色支持
// 设计思路：解析十六进制字符串并转换为 Color 对象

extension Color {
    
    /// 通过十六进制字符串初始化颜色
    /// - Parameter hex: 十六进制颜色字符串（支持 3/6/8 位）
    init(hex: String) {
        let hexString_baseswiftui = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int_baseswiftui: UInt64 = 0
        Scanner(string: hexString_baseswiftui).scanHexInt64(&int_baseswiftui)
        let a_baseswiftui, r_baseswiftui, g_baseswiftui, b_baseswiftui: UInt64
        
        switch hexString_baseswiftui.count {
        case 3: // RGB (12-bit)
            (a_baseswiftui, r_baseswiftui, g_baseswiftui, b_baseswiftui) = (255, (int_baseswiftui >> 8) * 17, (int_baseswiftui >> 4 & 0xF) * 17, (int_baseswiftui & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a_baseswiftui, r_baseswiftui, g_baseswiftui, b_baseswiftui) = (255, int_baseswiftui >> 16, int_baseswiftui >> 8 & 0xFF, int_baseswiftui & 0xFF)
        case 8: // ARGB (32-bit)
            (a_baseswiftui, r_baseswiftui, g_baseswiftui, b_baseswiftui) = (int_baseswiftui >> 24, int_baseswiftui >> 16 & 0xFF, int_baseswiftui >> 8 & 0xFF, int_baseswiftui & 0xFF)
        default:
            (a_baseswiftui, r_baseswiftui, g_baseswiftui, b_baseswiftui) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r_baseswiftui) / 255,
            green: Double(g_baseswiftui) / 255,
            blue: Double(b_baseswiftui) / 255,
            opacity: Double(a_baseswiftui) / 255
        )
    }
}
