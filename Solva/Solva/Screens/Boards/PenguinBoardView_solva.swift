//
//  PenguinBoardView_solva.swift
//  Solva
//
//  企鹅纸牌棋盘 UI。
//  设计思路：顶部居中展示 4 个基础堆（含冰核基准提示），下方 8 列牌墩横向铺开，
//  仅负责渲染与手势转发，具体规则判定全部在 PenguinEngine_solva 完成。
//
import SwiftUI

struct PenguinGameScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var coordinator_solva: GameSessionCoordinator_solva
    @StateObject private var engine_solva = PenguinEngine_solva()

    private var entry_solva: GameCatalogEntry_solva { LocalData_solva.catalogEntry_solva(for: .penguin) }

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
            PenguinBoardView_solva(engine_solva: engine_solva)
        }
        .onAppear { engine_solva.coordinator_solva = coordinator_solva }
    }
}

struct PenguinBoardView_solva: View {
    @ObservedObject var engine_solva: PenguinEngine_solva

    private let cardWidth_solva: CGFloat = 50

    var body: some View {
        VStack(spacing: 12) {
            foundationsRow_solva
            GeometryReader { geo_solva in
                let colSpacing_solva: CGFloat = 8
                let colWidth_solva = min(cardWidth_solva, (geo_solva.size.width - colSpacing_solva * 7 - 16) / 8)
                HStack(alignment: .top, spacing: colSpacing_solva) {
                    ForEach(engine_solva.columns_solva.indices, id: \.self) { colIndex_solva in
                        columnView_solva(colIndex_solva, width_solva: colWidth_solva, availableHeight_solva: geo_solva.size.height)
                    }
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }

    private var foundationsRow_solva: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Image(systemName: "snowflake")
                Text("Base Rank \(engine_solva.baseRank_solva.label_solva)")
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Palette_solva.textSecondary_solva)

            Spacer()

            ForEach(Suit_solva.allCases) { suit_solva in
                foundationSlot_solva(suit_solva)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "location.north.line.fill")
                Text("\(engine_solva.migrationPoints_solva) migration pts")
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Palette_solva.gold_solva)
        }
    }

    private func foundationSlot_solva(_ suit_solva: Suit_solva) -> some View {
        let cards_solva = engine_solva.foundations_solva[suit_solva] ?? []
        return ZStack {
            if let top_solva = cards_solva.last {
                PlayingCardView_solva(card_solva: top_solva, width_solva: 42, isHintTarget_solva: engine_solva.hintToSuit_solva == suit_solva)
            } else {
                EmptySlotView_solva(width_solva: 42, isHintTarget_solva: engine_solva.hintToSuit_solva == suit_solva, systemIcon_solva: suit_solva.isRed_solva ? nil : nil)
                    .overlay(Text(suit_solva.symbol_solva).font(.system(size: 16)).foregroundStyle(suit_solva.isRed_solva ? Palette_solva.cardRedSuit_solva.alpha_solva(0.5) : Palette_solva.cardBlackSuit_solva.alpha_solva(0.3)))
            }
        }
        .overlay(alignment: .bottom) {
            Text("\(cards_solva.count)/13").font(.system(size: 8, weight: .bold)).foregroundStyle(Palette_solva.textSecondary_solva).offset(y: 14)
        }
        .onTapGesture { engine_solva.tapFoundation_solva(suit_solva) }
    }

    private func columnView_solva(_ colIndex_solva: Int, width_solva: CGFloat, availableHeight_solva: CGFloat) -> some View {
        let column_solva = engine_solva.columns_solva[colIndex_solva]
        let height_solva = width_solva / AppConfig_solva.cardAspectRatio_solva
        let maxOffset_solva: CGFloat = 22
        let offset_solva: CGFloat = column_solva.count > 1 ? min(maxOffset_solva, max(10, (availableHeight_solva - height_solva) / CGFloat(column_solva.count - 1))) : 0

        return ZStack(alignment: .top) {
            EmptySlotView_solva(width_solva: width_solva)
                .onTapGesture { engine_solva.tapColumnArea_solva(colIndex_solva) }

            ForEach(Array(column_solva.enumerated()), id: \.element.id) { pair_solva in
                let cardIndex_solva = pair_solva.offset
                let card_solva = pair_solva.element
                let isSelected_solva = engine_solva.selection_solva.map { $0.column == colIndex_solva && cardIndex_solva >= $0.index } ?? false
                let isHint_solva = (engine_solva.hintFrom_solva?.column == colIndex_solva && cardIndex_solva >= (engine_solva.hintFrom_solva?.index ?? Int.max))
                    || (engine_solva.hintToColumn_solva == colIndex_solva && cardIndex_solva == column_solva.count - 1)

                PlayingCardView_solva(card_solva: card_solva, width_solva: width_solva, isSelected_solva: isSelected_solva, isHintTarget_solva: isHint_solva)
                    .offset(y: CGFloat(cardIndex_solva) * offset_solva)
                    .onTapGesture {
                        if card_solva.isFaceUp_solva {
                            engine_solva.selectCard_solva(column: colIndex_solva, index: cardIndex_solva)
                        } else if engine_solva.migrationPoints_solva > 0 {
                            engine_solva.peekNextHiddenCard_solva(column: colIndex_solva)
                        }
                    }
            }
        }
        .frame(width: width_solva, alignment: .top)
    }
}
