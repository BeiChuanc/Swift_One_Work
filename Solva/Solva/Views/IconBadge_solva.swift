//
//  IconBadge_solva.swift
//  Solva
//
//  丰富化图标徽标组件。
//  设计思路：全项目统一用本组件替代裸露的 Image(systemName:)，通过「渐变圆底 + 描边环 +
//  投影 + 图标」四层叠加，避免图标显示单调；ringStyle_solva 可选择双层描边呈现更精致的
//  勋章质感，用于成就墙、顶部导航、游戏座位卡等强调位置。
//  关键属性：icon_solva（SF Symbol 名称）、tint_solva（主题色）、size_solva（整体直径）
import SwiftUI

struct IconBadge_solva: View {
    let icon_solva: String
    var tint_solva: Color = Palette_solva.gold_solva
    var size_solva: CGFloat = 40
    var filled_solva: Bool = false
    var ringStyle_solva: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: filled_solva
                            ? [tint_solva, tint_solva.alpha_solva(0.75)]
                            : [tint_solva.alpha_solva(0.32), tint_solva.alpha_solva(0.10)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            if ringStyle_solva {
                Circle()
                    .strokeBorder(tint_solva.alpha_solva(0.65), lineWidth: 1.2)
                    .padding(1.5)
                Circle()
                    .strokeBorder(Color.white.alpha_solva(0.12), lineWidth: 1)
            }

            Image(systemName: icon_solva)
                .font(.system(size: size_solva * 0.42, weight: .semibold))
                .foregroundStyle(filled_solva ? Color.black.alpha_solva(0.85) : tint_solva)
        }
        .frame(width: size_solva, height: size_solva)
        .shadow(color: tint_solva.alpha_solva(0.4), radius: size_solva * 0.16, y: size_solva * 0.05)
    }
}

/// 六边形勋章徽标：用于成就墙等需要更浓「奖章」质感的位置
struct MedallionBadge_solva: View {
    let icon_solva: String
    var tint_solva: Color = Palette_solva.gold_solva
    var size_solva: CGFloat = 46
    var unlocked_solva: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: unlocked_solva ? [tint_solva.alpha_solva(0.5), tint_solva.alpha_solva(0.14)] : [Color.white.alpha_solva(0.08), Color.white.alpha_solva(0.02)], center: .center, startRadius: 2, endRadius: size_solva * 0.6))
            Circle()
                .strokeBorder(unlocked_solva ? tint_solva : Color.white.alpha_solva(0.18), lineWidth: 1.4)
            Circle()
                .strokeBorder(Color.white.alpha_solva(unlocked_solva ? 0.25 : 0.06), lineWidth: 1)
                .padding(3)
            Image(systemName: icon_solva)
                .font(.system(size: size_solva * 0.4, weight: .bold))
                .foregroundStyle(unlocked_solva ? tint_solva : Palette_solva.textSecondary_solva.alpha_solva(0.5))
        }
        .frame(width: size_solva, height: size_solva)
        .shadow(color: unlocked_solva ? tint_solva.alpha_solva(0.45) : .clear, radius: 8, y: 3)
    }
}
