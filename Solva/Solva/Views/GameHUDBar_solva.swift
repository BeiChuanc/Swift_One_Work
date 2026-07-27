//
//  GameHUDBar_solva.swift
//  Solva
//
//  游戏内顶部状态栏组件。
//  设计思路：5 款游戏共用同一套「悬浮玻璃感」HUD 呈现计时/得分/步数，
//  并提供返回、撤销、提示、重开四个统一操作入口，具体行为由传入的闭包决定，
//  使 HUD 与具体游戏引擎完全解耦，可在所有 GameContainerScreen 中复用。
//  关键属性：title_solva/accentColor_solva（当前游戏标题与主题色）
//  关键方法：onBack_solva/onUndo_solva/onHint_solva/onRestart_solva（四个操作回调）
import SwiftUI

struct GameHUDBar_solva: View {
    let title_solva: String
    let accentColor_solva: Color
    let elapsedSeconds_solva: Int
    let score_solva: Int
    let moveCount_solva: Int
    var canUndo_solva: Bool = true
    let onBack_solva: () -> Void
    let onUndo_solva: () -> Void
    let onHint_solva: () -> Void
    let onRestart_solva: () -> Void

    private var timeText_solva: String {
        String(format: "%02d:%02d", elapsedSeconds_solva / 60, elapsedSeconds_solva % 60)
    }

    var body: some View {
        HStack(spacing: 14) {
            hudButton_solva(icon: "chevron.left") { onBack_solva() }

            Circle()
                .fill(accentColor_solva)
                .frame(width: 9, height: 9)
                .shadow(color: accentColor_solva.alpha_solva(0.7), radius: 4)
            Text(title_solva)
                .casinoTracked_solva(0.6)
                .font(.casinoTitle_solva(15))
                .foregroundStyle(Palette_solva.textPrimary_solva)
                .lineLimit(1)

            Spacer(minLength: 8)

            metricChip_solva(icon: "clock.fill", text: timeText_solva)
            metricChip_solva(icon: "star.fill", text: "\(score_solva)")
            metricChip_solva(icon: "hand.tap.fill", text: "\(moveCount_solva)")

            Spacer(minLength: 8)

            hudButton_solva(icon: "arrow.uturn.backward", disabled: !canUndo_solva) { onUndo_solva() }
            hudButton_solva(icon: "lightbulb.fill") { onHint_solva() }
            hudButton_solva(icon: "arrow.clockwise") { onRestart_solva() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette_solva.panel_solva.alpha_solva(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.alpha_solva(0.08), lineWidth: 1)
                )
        )
    }

    private func metricChip_solva(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11))
            Text(text).font(.system(size: 13, weight: .semibold, design: .monospaced))
        }
        .foregroundStyle(Palette_solva.textSecondary_solva)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.alpha_solva(0.06)))
    }

    private func hudButton_solva(icon: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(disabled ? Palette_solva.textSecondary_solva.alpha_solva(0.4) : Palette_solva.textPrimary_solva)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white.alpha_solva(0.06)))
        }
        .disabled(disabled)
    }
}
