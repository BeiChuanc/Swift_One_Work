//
//  PlayingCardView_solva.swift
//  Solva
//
//  通用扑克牌视图组件。
//  设计思路：全部 5 款游戏共用同一套卡牌渲染逻辑，保证视觉统一；
//  通过 isSelected_solva / isDimmed_solva / isHintTarget_solva 三种状态呈现交互反馈，
//  卡背使用统一的几何纹样体现「有设计感」的视觉风格，而不是简单纯色块。
//  关键属性：card_solva（渲染的卡牌数据）、width_solva（卡牌宽度，高度按比例推算）
//

import SwiftUI

struct PlayingCardView_solva: View {
    let card_solva: Card_solva
    var width_solva: CGFloat = AppConfig_solva.cardBaseWidth_solva
    var isSelected_solva: Bool = false
    var isHintTarget_solva: Bool = false
    var isDimmed_solva: Bool = false

    private var height_solva: CGFloat { width_solva / AppConfig_solva.cardAspectRatio_solva }
    private var cornerRadius_solva: CGFloat { width_solva * 0.12 }

    var body: some View {
        ZStack {
            if card_solva.isFaceUp_solva {
                faceView_solva
            } else {
                backView_solva
            }
        }
        .frame(width: width_solva, height: height_solva)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius_solva, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius_solva, style: .continuous)
                .stroke(borderColor_solva, lineWidth: isSelected_solva || isHintTarget_solva ? 2.6 : 1)
        )
        // 性能优化：阴影渲染需要额外的离屏绘制开销，若对棋盘上全部卡牌（如手风琴 52 张、
        // 双金字塔 50+ 张）都持续渲染阴影，会在每次局面刷新时造成明显卡顿。
        // 因此仅在「选中/提示目标」这类需要视觉强调的少数卡牌上启用阴影，
        // 其余静置状态的卡牌不渲染阴影，大幅降低同屏阴影绘制数量。
        .shadow(
            color: (isSelected_solva || isHintTarget_solva) ? Color.black.alpha_solva(0.35) : .clear,
            radius: isSelected_solva ? 8 : (isHintTarget_solva ? 4 : 0),
            x: 0,
            y: isSelected_solva ? 5 : 0
        )
        .scaleEffect(isSelected_solva ? 1.06 : 1.0)
        .offset(y: isSelected_solva ? -6 : 0)
        .opacity(isDimmed_solva ? 0.45 : 1.0)
        .animation(.spring(response: AppConfig_solva.selectAnimation_solva, dampingFraction: 0.7), value: isSelected_solva)
    }

    private var borderColor_solva: Color {
        if isHintTarget_solva { return Palette_solva.hint_solva }
        if isSelected_solva { return Palette_solva.gold_solva }
        return Color.black.alpha_solva(0.25)
    }

    /// 卡牌正面：左上/右下角标 + 中央大花色符号
    private var faceView_solva: some View {
        let suitColor_solva = card_solva.suit_solva.isRed_solva ? Palette_solva.cardRedSuit_solva : Palette_solva.cardBlackSuit_solva
        return ZStack {
            Palette_solva.cardFace_solva
            VStack {
                HStack {
                    cornerLabel_solva(color: suitColor_solva)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    cornerLabel_solva(color: suitColor_solva)
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(width_solva * 0.08)

            Text(card_solva.suit_solva.symbol_solva)
                .font(.system(size: width_solva * 0.42, weight: .bold))
                .foregroundStyle(suitColor_solva.alpha_solva(0.85))
        }
    }

    private func cornerLabel_solva(color: Color) -> some View {
        VStack(spacing: 0) {
            Text(card_solva.rank_solva.label_solva)
                .font(.system(size: width_solva * 0.20, weight: .heavy, design: .rounded))
            Text(card_solva.suit_solva.symbol_solva)
                .font(.system(size: width_solva * 0.16, weight: .bold))
        }
        .foregroundStyle(color)
    }

    /// 卡牌背面：统一几何纹样，体现整体设计感
    private var backView_solva: some View {
        ZStack {
            LinearGradient(colors: [Palette_solva.cardBack_solva, Palette_solva.cardBack_solva.alpha_solva(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            GeometryReader { geo_solva in
                Path { path_solva in
                    let w_solva = geo_solva.size.width
                    let h_solva = geo_solva.size.height
                    var x_solva: CGFloat = -h_solva
                    while x_solva < w_solva {
                        path_solva.move(to: CGPoint(x: x_solva, y: h_solva))
                        path_solva.addLine(to: CGPoint(x: x_solva + h_solva, y: 0))
                        x_solva += w_solva * 0.16
                    }
                }
                .stroke(Color.white.alpha_solva(0.08), lineWidth: 2)
            }
            RoundedRectangle(cornerRadius: cornerRadius_solva * 0.7, style: .continuous)
                .stroke(Color.white.alpha_solva(0.25), lineWidth: 1.5)
                .padding(width_solva * 0.1)
            Image(systemName: "suit.spade.fill")
                .font(.system(size: width_solva * 0.26))
                .foregroundStyle(Color.white.alpha_solva(0.22))
        }
    }
}

/// 空牌位占位视图：用于表示可放置但当前无牌的槛位（如空列、暂存位），
/// 统一以虚线描边呈现，提升可操作区域的可读性
struct EmptySlotView_solva: View {
    var width_solva: CGFloat = AppConfig_solva.cardBaseWidth_solva
    var isHintTarget_solva: Bool = false
    var systemIcon_solva: String? = nil

    private var height_solva: CGFloat { width_solva / AppConfig_solva.cardAspectRatio_solva }

    var body: some View {
        RoundedRectangle(cornerRadius: width_solva * 0.12, style: .continuous)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.4, dash: [5, 4]))
            .foregroundStyle(isHintTarget_solva ? Palette_solva.hint_solva : Color.white.alpha_solva(0.22))
            .background(Color.white.alpha_solva(0.03))
            .frame(width: width_solva, height: height_solva)
            .overlay {
                if let icon_solva = systemIcon_solva {
                    Image(systemName: icon_solva)
                        .foregroundStyle(Color.white.alpha_solva(0.25))
                        .font(.system(size: width_solva * 0.28))
                }
            }
    }
}
