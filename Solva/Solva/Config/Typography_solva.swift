//
//  Typography_solva.swift
//  Solva
//
//  字体样式配置文件。
//  设计思路：整套 App 走「欧美私人牌室」的复古格调，标题/品牌文字统一使用衬线体
//  （design: .serif）营造刻字招牌质感，数值/计时统一使用等宽字体便于对齐易读，
//  正文统一使用圆体保证在深色台呢背景上的柔和可读性。所有页面必须通过本文件提供的
//  静态方法取字体，禁止在各视图内散落 .system(...) 直接拼写，以保证风格统一。
//
import SwiftUI

extension Font {
    /// 招牌/品牌级衬线大字（如首页 "SOLVA"、结算浮层大标题）
    static func casinoDisplay_solva(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// 卡片/区块标题衬线字（如游戏名称、区块大标题）
    static func casinoTitle_solva(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// 追踪字距后的小型招牌标签（如 "PRIVATE TABLE"、徽章文字），需配合 kerning 使用
    static func casinoLabel_solva(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// 数值/计时专用等宽字体（比分、时间、局数等）
    static func casinoNumeric_solva(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// 正文说明文字（圆体，深色背景下柔和易读）
    static func casinoBody_solva(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension Text {
    /// 招牌字距拓展：为大写标签文字增加字间距，呈现雕刻铭牌的复古质感
    /// - Parameter spacing_solva: 字距（点数），默认 1.6
    func casinoTracked_solva(_ spacing_solva: CGFloat = 1.6) -> Text {
        self.kerning(spacing_solva)
    }
}
