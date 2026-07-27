//
//  GameScaffold_solva.swift
//  Solva
//
//  游戏页面通用骨架组件。
//  设计思路：5 款游戏的对局页面结构完全一致（顶部 HUD + 中间棋盘区 + 结算浮层），
//  差异仅在棋盘内容本身，因此把结构抽成本组件，棋盘部分通过泛型 board_solva 闭包注入，
//  各游戏的具体 Screen 文件只需负责拼装 HUD 所需数据与棋盘视图，不重复编写结算/HUD 逻辑。
//
import SwiftUI

struct GameScaffold_solva<Board: View>: View {
    let title_solva: String
    let accentColor_solva: Color
    let elapsedSeconds_solva: Int
    let score_solva: Int
    let moveCount_solva: Int
    let canUndo_solva: Bool
    let isGameWon_solva: Bool
    let isGameOver_solva: Bool
    let usedHintCount_solva: Int
    let newlyUnlocked_solva: [AchievementDefinition_solva]
    let hintMessage_solva: String?

    let onBack_solva: () -> Void
    let onUndo_solva: () -> Void
    let onHint_solva: () -> Void
    let onRestart_solva: () -> Void

    @ViewBuilder let board_solva: () -> Board

    var body: some View {
        ZStack {
            CasinoFeltBackground_solva(tint_solva: accentColor_solva, intensity_solva: 0.22)

            // 主内容强制顶部对齐并占满整屏，保证 HUD 始终贴在屏幕最上方，
            // 不会因为棋盘内容自然尺寸偏大而被父级居中裁切（解决「顶部组件不可见」问题）
            VStack(spacing: 10) {
                GameHUDBar_solva(
                    title_solva: title_solva,
                    accentColor_solva: accentColor_solva,
                    elapsedSeconds_solva: elapsedSeconds_solva,
                    score_solva: score_solva,
                    moveCount_solva: moveCount_solva,
                    canUndo_solva: canUndo_solva,
                    onBack_solva: onBack_solva,
                    onUndo_solva: onUndo_solva,
                    onHint_solva: onHint_solva,
                    onRestart_solva: onRestart_solva
                )
                .padding(.horizontal, 18)
                .padding(.top, 12)

                board_solva()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // 提示条改为悬浮覆盖层，不占用 VStack 布局高度，
            // 避免提示出现时把棋盘/HUD 进一步挤出屏幕（解决「提示弹出后看不到」问题）
            if let hintMessage_solva {
                VStack {
                    Spacer()
                    hintBanner_solva(hintMessage_solva)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(false)
            }

            if isGameWon_solva || isGameOver_solva {
                GameResultOverlay_solva(
                    isWin_solva: isGameWon_solva,
                    accentColor_solva: accentColor_solva,
                    score_solva: score_solva,
                    durationSeconds_solva: elapsedSeconds_solva,
                    moveCount_solva: moveCount_solva,
                    newlyUnlocked_solva: newlyUnlocked_solva,
                    onPlayAgain_solva: onRestart_solva,
                    onBackToMenu_solva: onBack_solva
                )
            }
        }
    }

    private func hintBanner_solva(_ text_solva: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill").foregroundStyle(Palette_solva.hint_solva)
            Text(text_solva)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Palette_solva.textPrimary_solva)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Palette_solva.panel_solva))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Palette_solva.hint_solva.alpha_solva(0.4), lineWidth: 1))
        .shadow(color: .black.alpha_solva(0.4), radius: 12, y: 6)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
