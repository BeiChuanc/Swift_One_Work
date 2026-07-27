//
//  AccordionBoardView_solva.swift
//  Solva
//
//  手风琴纸牌棋盘 UI。
//  设计思路：仅负责渲染与转发交互，不包含任何业务判定逻辑（判定均在 AccordionEngine_solva 中）。
//  52 个位置以 13 列 x 4 行网格呈现，贴近横屏比例；点击某一格触发选中/尝试合并，
//  顶部信息条展示「和声连击」与「风箱重奏」剩余次数，体现该游戏专属的新颖玩法。
//
import SwiftUI

struct AccordionGameScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var coordinator_solva: GameSessionCoordinator_solva
    @StateObject private var engine_solva = AccordionEngine_solva()

    private var entry_solva: GameCatalogEntry_solva { LocalData_solva.catalogEntry_solva(for: .accordion) }

    var body: some View {
        GameScaffold_solva(
            title_solva: entry_solva.title_solva,
            accentColor_solva: entry_solva.accentColor_solva,
            elapsedSeconds_solva: engine_solva.elapsedSeconds_solva,
            score_solva: engine_solva.score_solva,
            moveCount_solva: engine_solva.moveCount_solva,
            canUndo_solva: true,
            isGameWon_solva: engine_solva.isGameWon_solva,
            isGameOver_solva: engine_solva.isGameOver_solva,
            usedHintCount_solva: engine_solva.usedHintCount_solva,
            newlyUnlocked_solva: engine_solva.newlyUnlockedAchievements_solva,
            hintMessage_solva: engine_solva.hintMessage_solva,
            onBack_solva: { navigation_solva.pop_solva() },
            onUndo_solva: { engine_solva.undo_solva() },
            onHint_solva: { engine_solva.requestHint_solva() },
            onRestart_solva: { engine_solva.newGame_solva() }
        ) {
            AccordionBoardView_solva(engine_solva: engine_solva)
        }
        .onAppear { engine_solva.coordinator_solva = coordinator_solva }
    }
}

struct AccordionBoardView_solva: View {
    @ObservedObject var engine_solva: AccordionEngine_solva

    private let columns_solva = 13
    private let rows_solva = 4
    private let spacing_solva: CGFloat = 6

    var body: some View {
        VStack(spacing: 8) {
            infoBar_solva
            GeometryReader { geo_solva in
                // 同时依据「可用宽度」与「可用高度」反推卡牌宽度，确保 4 行网格在竖向也绝不超出可视区域。
                let widthBased_solva = (geo_solva.size.width - spacing_solva * CGFloat(columns_solva - 1) - 16) / CGFloat(columns_solva)
                let heightBased_solva = (geo_solva.size.height - spacing_solva * CGFloat(rows_solva - 1) - 4) / CGFloat(rows_solva) * AppConfig_solva.cardAspectRatio_solva
                let cardWidth_solva = max(24, min(58, widthBased_solva, heightBased_solva))
                let gridColumns_solva = Array(repeating: GridItem(.fixed(cardWidth_solva), spacing: spacing_solva), count: columns_solva)
                LazyVGrid(columns: gridColumns_solva, spacing: spacing_solva) {
                    ForEach(0..<(rows_solva * columns_solva), id: \.self) { index_solva in
                        cell_solva(index_solva, width_solva: cardWidth_solva)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var infoBar_solva: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "waveform.path")
                    .foregroundStyle(Palette_solva.hint_solva)
                Text("Combo x\(engine_solva.comboStreak_solva)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Palette_solva.panel_solva))

            Text("\(engine_solva.activePileCount_solva) piles left")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Palette_solva.textSecondary_solva)

            Spacer()

            Button {
                engine_solva.reshuffle_solva()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "shuffle")
                    Text("Bellow Reprise ×\(engine_solva.reshuffleCharges_solva)")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(engine_solva.reshuffleCharges_solva > 0 ? Color.black : Palette_solva.textSecondary_solva)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Capsule().fill(engine_solva.reshuffleCharges_solva > 0 ? Palette_solva.gold_solva : Color.white.alpha_solva(0.06)))
            }
            .disabled(engine_solva.reshuffleCharges_solva == 0)
        }
    }

    @ViewBuilder
    private func cell_solva(_ index_solva: Int, width_solva: CGFloat) -> some View {
        let pile_solva = engine_solva.piles_solva[index_solva]
        ZStack {
            if let stackDepthCard_solva = pile_solva.count > 1 ? pile_solva[pile_solva.count - 2] : nil {
                PlayingCardView_solva(card_solva: stackDepthCard_solva, width_solva: width_solva)
                    .offset(x: 2, y: 2)
                    .opacity(0.5)
            }
            if let top_solva = pile_solva.last {
                PlayingCardView_solva(
                    card_solva: top_solva,
                    width_solva: width_solva,
                    isSelected_solva: engine_solva.selectedIndex_solva == index_solva,
                    isHintTarget_solva: engine_solva.hintSource_solva == index_solva || engine_solva.hintTarget_solva == index_solva
                )
                .overlay(alignment: .bottomTrailing) {
                    if pile_solva.count > 1 {
                        Text("\(pile_solva.count)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Circle().fill(Color.black.alpha_solva(0.6)))
                            .offset(x: 4, y: 4)
                    }
                }
            } else {
                EmptySlotView_solva(width_solva: width_solva)
            }
        }
        .onTapGesture {
            engine_solva.selectOrMove_solva(index_solva)
        }
    }
}
