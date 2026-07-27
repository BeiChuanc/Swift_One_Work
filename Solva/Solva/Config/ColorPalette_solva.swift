//
//  ColorPalette_solva.swift
//  Solva
//
//  颜色主题配置文件。
//  设计思路：统一管理全局配色（背景渐变、卡牌配色、文字配色等），
//  并提供「透明度」颜色拓展方法 alpha_solva，全项目透明色统一通过该方法生成，
//  避免各处散落直接调用 .opacity()。
//

import SwiftUI

/// 颜色透明度统一拓展
/// 设计思路：SwiftUI 原生只有 .opacity(_:) 修饰符作用于视图整体，
/// 这里在 Color 上封装一个语义化方法，使「取某颜色的 x 透明度版本」成为项目统一写法。
extension Color {
    /// 返回当前颜色的指定透明度版本
    /// - Parameter value_solva: 透明度取值 0~1
    /// - Returns: 应用透明度后的新颜色
    func alpha_solva(_ value_solva: Double) -> Color {
        self.opacity(value_solva)
    }
}

/// 全局颜色主题
/// 设计思路：以深色「牌桌绒面」风格为基调，各游戏使用 LocalData_solva 中定义的强调色做区分，
/// 保证整体视觉统一又能凸显每款游戏的独立气质。
enum Palette_solva {
    /// App 主背景渐变（深绒面质感）
    static let backgroundTop_solva = Color(red: 0.06, green: 0.10, blue: 0.14)
    static let backgroundBottom_solva = Color(red: 0.03, green: 0.05, blue: 0.08)

    /// 卡片/面板背景
    static let panel_solva = Color(red: 0.11, green: 0.15, blue: 0.20)
    static let panelHighlight_solva = Color(red: 0.16, green: 0.21, blue: 0.27)

    /// 主文字与次文字
    static let textPrimary_solva = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let textSecondary_solva = Color(red: 0.65, green: 0.70, blue: 0.76)

    /// 金色强调（用于成就、最佳成绩等亮点信息）
    static let gold_solva = Color(red: 0.95, green: 0.78, blue: 0.35)
    static let goldDeep_solva = Color(red: 0.72, green: 0.55, blue: 0.20)

    /// 欧美牌室「绒面台呢」配色 —— 用于首页与各游戏背景纹理，替代纯色背景
    static let feltDeep_solva = Color(red: 0.035, green: 0.16, blue: 0.11)
    static let feltCore_solva = Color(red: 0.06, green: 0.24, blue: 0.16)
    static let feltLight_solva = Color(red: 0.10, green: 0.34, blue: 0.22)
    /// 木纹深棕，用于台面外框/滚边
    static let woodBrown_solva = Color(red: 0.24, green: 0.15, blue: 0.09)
    static let woodBrownLight_solva = Color(red: 0.36, green: 0.23, blue: 0.13)
    /// 羊皮纸底色，用于票据风信息面板的点缀强调（少量使用，避免整体翻转为浅色主题）
    static let parchment_solva = Color(red: 0.93, green: 0.88, blue: 0.74)

    /// 卡牌纸面与花色配色
    static let cardFace_solva = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let cardBack_solva = Color(red: 0.16, green: 0.26, blue: 0.42)
    static let cardRedSuit_solva = Color(red: 0.80, green: 0.20, blue: 0.24)
    static let cardBlackSuit_solva = Color(red: 0.14, green: 0.16, blue: 0.20)

    /// 提示/成功/危险语义色
    static let success_solva = Color(red: 0.30, green: 0.78, blue: 0.55)
    static let danger_solva = Color(red: 0.92, green: 0.34, blue: 0.38)
    static let hint_solva = Color(red: 0.98, green: 0.82, blue: 0.30)

    /// 主背景渐变视图
    static var backgroundGradient_solva: LinearGradient {
        LinearGradient(colors: [backgroundTop_solva, backgroundBottom_solva], startPoint: .top, endPoint: .bottom)
    }
}
