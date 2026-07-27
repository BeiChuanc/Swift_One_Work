//
//  OsmosisBoardView_solva.swift
//  Solva
//
//  渗透纸牌棋盘 UI。
//  设计思路：顶部展示 4 组基础堆（基准堆用花色高亮标出），中部为量子暂存位，
//  底部横排 4 个储备堆，仅渲染与转发点击，判定逻辑全部位于 OsmosisEngine_solva。
//
import SwiftUI

struct OsmosisGameScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var coordinator_solva: GameSessionCoordinator_solva
    @StateObject private var engine_solva = OsmosisEngine_solva()

    private var entry_solva: GameCatalogEntry_solva { LocalData_solva.catalogEntry_solva(for: .osmosis) }

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
            OsmosisBoardView_solva(engine_solva: engine_solva)
        }
        .onAppear { engine_solva.coordinator_solva = coordinator_solva }
    }
}

struct OsmosisBoardView_solva: View {
    @ObservedObject var engine_solva: OsmosisEngine_solva

    var body: some View {
        // 使用自适应缩放容器，确保三行内容（基础堆/暂存位/储备堆）始终完整落在可视区域内，
        // 不会因固定尺寸溢出而侵入顶部 HUD 区域。
        AutoFitBoard_solva {
            VStack(spacing: 20) {
                foundationsRow_solva
                bufferSlot_solva
                reserveRow_solva
            }
            .padding(.horizontal, 24)
        }
    }

    private var foundationsRow_solva: some View {
        HStack(spacing: 16) {
            foundationColumn_solva(suit: engine_solva.baseSuit_solva, cards: engine_solva.baseFoundation_solva, isBase: true)
            ForEach(Suit_solva.allCases.filter { $0 != engine_solva.baseSuit_solva }) { suit_solva in
                foundationColumn_solva(suit: suit_solva, cards: engine_solva.sideFoundations_solva[suit_solva] ?? [], isBase: false)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func foundationColumn_solva(suit: Suit_solva, cards: [Card_solva], isBase: Bool) -> some View {
        VStack(spacing: 6) {
            Text(isBase ? "Base \(suit.symbol_solva)" : suit.symbol_solva)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isBase ? Palette_solva.gold_solva : Palette_solva.textSecondary_solva)
            ZStack {
                if let top_solva = cards.last {
                    PlayingCardView_solva(card_solva: top_solva, width_solva: 54)
                } else {
                    EmptySlotView_solva(width_solva: 54)
                }
            }
            Text("\(cards.count)/13")
                .font(.system(size: 9))
                .foregroundStyle(Palette_solva.textSecondary_solva)
        }
        .frame(maxWidth: .infinity)
    }

    private var bufferSlot_solva: some View {
        VStack(spacing: 6) {
            Text("Quantum Buffer")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Palette_solva.textSecondary_solva)
            ZStack {
                if let held_solva = engine_solva.buffer_solva {
                    PlayingCardView_solva(card_solva: held_solva.card, width_solva: 58, isHintTarget_solva: engine_solva.hintUseBuffer_solva)
                } else {
                    EmptySlotView_solva(width_solva: 58, systemIcon_solva: "atom")
                }
            }
            .onTapGesture { engine_solva.tapBuffer_solva() }
        }
    }

    private var reserveRow_solva: some View {
        HStack(spacing: 22) {
            ForEach(engine_solva.reservePiles_solva.indices, id: \.self) { pileIndex_solva in
                reservePileView_solva(pileIndex_solva)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func reservePileView_solva(_ pileIndex_solva: Int) -> some View {
        let pile_solva = engine_solva.reservePiles_solva[pileIndex_solva]
        return VStack(spacing: 6) {
            ZStack {
                if pile_solva.count > 1 {
                    PlayingCardView_solva(card_solva: pile_solva[pile_solva.count - 2], width_solva: 58)
                        .offset(x: 3, y: 3)
                        .opacity(0.45)
                }
                if let top_solva = pile_solva.last {
                    PlayingCardView_solva(card_solva: top_solva, width_solva: 58, isHintTarget_solva: engine_solva.hintReserveIndex_solva == pileIndex_solva)
                } else {
                    EmptySlotView_solva(width_solva: 58)
                }
            }
            .onTapGesture { engine_solva.tapReserveTop_solva(pileIndex_solva) }
            Text("\(pile_solva.count) left")
                .font(.system(size: 9))
                .foregroundStyle(Palette_solva.textSecondary_solva)
        }
        .frame(maxWidth: .infinity)
    }
}
