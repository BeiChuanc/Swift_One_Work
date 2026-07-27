//
//  DoublePyramidBoardView_solva.swift
//  Solva
//
//  双金字塔纸牌棋盘 UI。
//  设计思路：左右并排展示两座金字塔，中央为共用备用堆/弃牌堆，
//  仅负责渲染三角形布局与手势转发，凑 13 与遮挡判定全部位于 DoublePyramidEngine_solva。
//
import SwiftUI

struct DoublePyramidGameScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var coordinator_solva: GameSessionCoordinator_solva
    @StateObject private var engine_solva = DoublePyramidEngine_solva()

    private var entry_solva: GameCatalogEntry_solva { LocalData_solva.catalogEntry_solva(for: .doublePyramid) }

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
            DoublePyramidBoardView_solva(engine_solva: engine_solva)
        }
        .onAppear { engine_solva.coordinator_solva = coordinator_solva }
    }
}

struct DoublePyramidBoardView_solva: View {
    @ObservedObject var engine_solva: DoublePyramidEngine_solva

    private let cardWidth_solva: CGFloat = 38

    var body: some View {
        AutoFitBoard_solva {
            HStack(alignment: .center, spacing: 18) {
                pyramidView_solva(0)
                centerColumn_solva
                pyramidView_solva(1)
            }
            .padding(.horizontal, 16)
        }
    }

    private func pyramidView_solva(_ p_solva: Int) -> some View {
        let cleared_solva = engine_solva.clearedPyramidIndices_solva.contains(p_solva)
        return VStack(spacing: 5) {
            Text(p_solva == 0 ? "Pyramid I" : "Pyramid II")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(cleared_solva ? Palette_solva.success_solva : Palette_solva.textSecondary_solva)
            ForEach(0..<7, id: \.self) { r_solva in
                HStack(spacing: 4) {
                    ForEach(0...r_solva, id: \.self) { c_solva in
                        cardSlot_solva(p_solva, r_solva, c_solva)
                    }
                }
            }
            if cleared_solva {
                Text("CLEARED")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Palette_solva.success_solva)
            }
        }
    }

    @ViewBuilder
    private func cardSlot_solva(_ p_solva: Int, _ r_solva: Int, _ c_solva: Int) -> some View {
        if let card_solva = engine_solva.pyramids_solva[p_solva][r_solva][c_solva] {
            let exposed_solva = engine_solva.isExposed_solva(p_solva, r_solva, c_solva)
            let location_solva = PyramidCardLocation_solva.pyramid(p_solva, r_solva, c_solva)
            PlayingCardView_solva(
                card_solva: card_solva,
                width_solva: cardWidth_solva,
                isSelected_solva: engine_solva.selection_solva == location_solva,
                isHintTarget_solva: engine_solva.hintLocations_solva.contains(location_solva),
                isDimmed_solva: exposed_solva == false
            )
            .onTapGesture { if exposed_solva { engine_solva.tapPyramidCard_solva(p_solva, r_solva, c_solva) } }
        } else {
            Color.clear.frame(width: cardWidth_solva, height: cardWidth_solva / AppConfig_solva.cardAspectRatio_solva)
        }
    }

    private var centerColumn_solva: some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                Text("Stock")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
                ZStack {
                    if engine_solva.stock_solva.isEmpty == false {
                        PlayingCardView_solva(card_solva: engine_solva.stock_solva.first!, width_solva: 52)
                    } else {
                        EmptySlotView_solva(width_solva: 52, systemIcon_solva: "arrow.triangle.2.circlepath")
                    }
                }
                .onTapGesture { engine_solva.drawStock_solva() }
                Text("\(engine_solva.stock_solva.count) left · redeal ×\(engine_solva.redealsRemaining_solva)")
                    .font(.system(size: 8))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }

            VStack(spacing: 6) {
                Text("Waste")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
                ZStack {
                    if let top_solva = engine_solva.waste_solva.last {
                        PlayingCardView_solva(
                            card_solva: top_solva,
                            width_solva: 52,
                            isSelected_solva: engine_solva.selection_solva == .waste,
                            isHintTarget_solva: engine_solva.hintLocations_solva.contains(.waste)
                        )
                    } else {
                        EmptySlotView_solva(width_solva: 52)
                    }
                }
                .onTapGesture { engine_solva.tapWaste_solva() }
            }
        }
        .frame(width: 100)
    }
}
