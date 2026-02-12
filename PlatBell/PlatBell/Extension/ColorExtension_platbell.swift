import SwiftUI

// MARK: - Color 扩展
// 核心作用：提供十六进制颜色支持和梦幻神秘主题配色方案
// 设计思路：解析十六进制字符串并转换为 Color 对象，提供主题色常量和渐变色生成方法

extension Color {
    
    /// 通过十六进制字符串初始化颜色
    /// - Parameter hex: 十六进制颜色字符串（支持 3/6/8 位）
    init(hex: String) {
        let hexString_platbell = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int_platbell: UInt64 = 0
        Scanner(string: hexString_platbell).scanHexInt64(&int_platbell)
        let a_platbell, r_platbell, g_platbell, b_platbell: UInt64
        
        switch hexString_platbell.count {
        case 3: // RGB (12-bit)
            (a_platbell, r_platbell, g_platbell, b_platbell) = (255, (int_platbell >> 8) * 17, (int_platbell >> 4 & 0xF) * 17, (int_platbell & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a_platbell, r_platbell, g_platbell, b_platbell) = (255, int_platbell >> 16, int_platbell >> 8 & 0xFF, int_platbell & 0xFF)
        case 8: // ARGB (32-bit)
            (a_platbell, r_platbell, g_platbell, b_platbell) = (int_platbell >> 24, int_platbell >> 16 & 0xFF, int_platbell >> 8 & 0xFF, int_platbell & 0xFF)
        default:
            (a_platbell, r_platbell, g_platbell, b_platbell) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r_platbell) / 255,
            green: Double(g_platbell) / 255,
            blue: Double(b_platbell) / 255,
            opacity: Double(a_platbell) / 255
        )
    }
}

// MARK: - 梦幻神秘主题配色方案

/// 梦幻神秘主题配色常量
/// 为"森屿寻铃记"提供统一的配色方案
enum ThemeColors_platbell {
    
    // MARK: - 主色调
    
    /// 主色调起始色（神秘森林的暮色）
    static let primaryStart_platbell = Color(hex: "667eea")
    
    /// 主色调结束色
    static let primaryEnd_platbell = Color(hex: "764ba2")
    
    /// 主色调渐变
    static let primaryGradient_platbell = LinearGradient(
        colors: [primaryStart_platbell, primaryEnd_platbell],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 辅助色
    
    /// 辅助色起始色（铃铛的魔法光芒）
    static let secondaryStart_platbell = Color(hex: "f093fb")
    
    /// 辅助色结束色
    static let secondaryEnd_platbell = Color(hex: "f5576c")
    
    /// 辅助色渐变
    static let secondaryGradient_platbell = LinearGradient(
        colors: [secondaryStart_platbell, secondaryEnd_platbell],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 点缀色1（蓝色系）
    
    /// 蓝色系起始色（清澈的森林溪流）
    static let accentBlueStart_platbell = Color(hex: "4facfe")
    
    /// 蓝色系结束色
    static let accentBlueEnd_platbell = Color(hex: "00f2fe")
    
    /// 蓝色系渐变
    static let accentBlueGradient_platbell = LinearGradient(
        colors: [accentBlueStart_platbell, accentBlueEnd_platbell],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 点缀色2（绿色系）
    
    /// 绿色系起始色（生机盎然的森屿）
    static let accentGreenStart_platbell = Color(hex: "43e97b")
    
    /// 绿色系结束色
    static let accentGreenEnd_platbell = Color(hex: "38f9d7")
    
    /// 绿色系渐变
    static let accentGreenGradient_platbell = LinearGradient(
        colors: [accentGreenStart_platbell, accentGreenEnd_platbell],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 暖色系
    
    /// 暖色系起始色（黄昏的金色铃声）
    static let warmStart_platbell = Color(hex: "fa709a")
    
    /// 暖色系结束色
    static let warmEnd_platbell = Color(hex: "fee140")
    
    /// 暖色系渐变
    static let warmGradient_platbell = LinearGradient(
        colors: [warmStart_platbell, warmEnd_platbell],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 渐变色集合
    
    /// 所有主题渐变色集合
    static let allGradients_platbell: [LinearGradient] = [
        primaryGradient_platbell,
        secondaryGradient_platbell,
        accentBlueGradient_platbell,
        accentGreenGradient_platbell,
        warmGradient_platbell
    ]
    
    /// 所有主题起始色集合
    static let allStartColors_platbell: [Color] = [
        primaryStart_platbell,
        secondaryStart_platbell,
        accentBlueStart_platbell,
        accentGreenStart_platbell,
        warmStart_platbell
    ]
    
    /// 所有主题结束色集合
    static let allEndColors_platbell: [Color] = [
        primaryEnd_platbell,
        secondaryEnd_platbell,
        accentBlueEnd_platbell,
        accentGreenEnd_platbell,
        warmEnd_platbell
    ]
    
    // MARK: - 工具方法
    
    /// 根据索引获取渐变色
    /// - Parameter index_platbell: 索引
    /// - Returns: 渐变色
    static func gradient_platbell(at index_platbell: Int) -> LinearGradient {
        let safeIndex_platbell = index_platbell % allGradients_platbell.count
        return allGradients_platbell[safeIndex_platbell]
    }
    
    /// 根据字符串哈希值获取渐变色
    /// - Parameter identifier_platbell: 标识字符串
    /// - Returns: 渐变色
    static func gradient_platbell(for identifier_platbell: String) -> LinearGradient {
        let index_platbell = abs(identifier_platbell.hashValue) % allGradients_platbell.count
        return allGradients_platbell[index_platbell]
    }
    
    /// 根据索引获取颜色对（起始色和结束色）
    /// - Parameter index_platbell: 索引
    /// - Returns: 颜色对（起始色，结束色）
    static func colorPair_platbell(at index_platbell: Int) -> (Color, Color) {
        let safeIndex_platbell = index_platbell % allStartColors_platbell.count
        return (allStartColors_platbell[safeIndex_platbell], allEndColors_platbell[safeIndex_platbell])
    }
    
    /// 生成随机梦幻渐变色
    /// - Returns: 随机渐变色
    static func randomGradient_platbell() -> LinearGradient {
        return allGradients_platbell.randomElement() ?? primaryGradient_platbell
    }
    
    /// 创建自定义角度的渐变
    /// - Parameters:
    ///   - index_platbell: 渐变色索引
    ///   - angle_platbell: 角度（度数）
    /// - Returns: 角度渐变
    static func angularGradient_platbell(at index_platbell: Int, angle_platbell: Double = 0) -> AngularGradient {
        let (start_platbell, end_platbell) = colorPair_platbell(at: index_platbell)
        return AngularGradient(
            colors: [start_platbell, end_platbell, start_platbell],
            center: .center,
            angle: .degrees(angle_platbell)
        )
    }
    
    /// 创建径向渐变
    /// - Parameter index_platbell: 渐变色索引
    /// - Returns: 径向渐变
    static func radialGradient_platbell(at index_platbell: Int) -> RadialGradient {
        let (start_platbell, end_platbell) = colorPair_platbell(at: index_platbell)
        return RadialGradient(
            colors: [start_platbell, end_platbell],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )
    }
}
