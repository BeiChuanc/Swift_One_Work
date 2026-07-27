//
//  GameResultOverlay_solva.swift
//  Solva
//
//  游戏结算浮层组件。
//  设计思路：胜利/失败共用同一浮层结构，通过 isWin_solva 切换配色与文案，
//  展示本局关键数据（耗时/得分/步数）并提供「再来一局」「返回列表」两个统一出口，
//  保证 5 款游戏的结算体验一致。
//
import SwiftUI

struct GameResultOverlay_solva: View {
    let isWin_solva: Bool
    let accentColor_solva: Color
    let score_solva: Int
    let durationSeconds_solva: Int
    let moveCount_solva: Int
    let newlyUnlocked_solva: [AchievementDefinition_solva]
    let onPlayAgain_solva: () -> Void
    let onBackToMenu_solva: () -> Void

    private var timeText_solva: String {
        String(format: "%02d:%02d", durationSeconds_solva / 60, durationSeconds_solva % 60)
    }

    var body: some View {
        ZStack {
            Color.black.alpha_solva(0.55).ignoresSafeArea()

            VStack(spacing: 16) {
                MedallionBadge_solva(icon_solva: isWin_solva ? "trophy.fill" : "flag.checkered", tint_solva: isWin_solva ? Palette_solva.gold_solva : Palette_solva.textSecondary_solva, size_solva: 64, unlocked_solva: true)

                Text(isWin_solva ? "Victory" : "No More Moves")
                    .casinoTracked_solva(1.4)
                    .font(.casinoDisplay_solva(24))
                    .foregroundStyle(Palette_solva.textPrimary_solva)

                HStack(spacing: 22) {
                    resultMetric_solva(icon: "star.fill", label: "Score", value: "\(score_solva)")
                    resultMetric_solva(icon: "clock.fill", label: "Time", value: timeText_solva)
                    resultMetric_solva(icon: "hand.tap.fill", label: "Moves", value: "\(moveCount_solva)")
                }

                if newlyUnlocked_solva.isEmpty == false {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NEW ACHIEVEMENTS")
                            .casinoTracked_solva(1)
                            .font(.casinoLabel_solva(11))
                            .foregroundStyle(Palette_solva.gold_solva)
                        ForEach(newlyUnlocked_solva) { def_solva in
                            HStack(spacing: 8) {
                                IconBadge_solva(icon_solva: def_solva.iconName_solva, tint_solva: Palette_solva.gold_solva, size_solva: 26, ringStyle_solva: false)
                                Text(def_solva.title_solva)
                                    .font(.casinoTitle_solva(13))
                                    .foregroundStyle(Palette_solva.textPrimary_solva)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.alpha_solva(0.06)))
                }

                HStack(spacing: 12) {
                    resultButton_solva(title: "Menu", filled: false, action: onBackToMenu_solva)
                    resultButton_solva(title: "Play Again", filled: true, action: onPlayAgain_solva)
                }
                .padding(.top, 6)
            }
            .padding(28)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Palette_solva.panel_solva)
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(accentColor_solva.alpha_solva(0.5), lineWidth: 1.5))
            )
            .shadow(color: .black.alpha_solva(0.4), radius: 24, y: 12)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.94)))
    }

    private func resultMetric_solva(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 5) {
            IconBadge_solva(icon_solva: icon, tint_solva: accentColor_solva, size_solva: 30, ringStyle_solva: false)
            Text(value).font(.casinoNumeric_solva(15)).foregroundStyle(Palette_solva.textPrimary_solva)
            Text(label.uppercased()).casinoTracked_solva(0.5).font(.casinoLabel_solva(9)).foregroundStyle(Palette_solva.textSecondary_solva)
        }
    }

    private func resultButton_solva(title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.casinoTitle_solva(14))
                .foregroundStyle(filled ? Color.black : Palette_solva.textPrimary_solva)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(filled ? accentColor_solva : Color.white.alpha_solva(0.08))
                )
        }
    }
}
