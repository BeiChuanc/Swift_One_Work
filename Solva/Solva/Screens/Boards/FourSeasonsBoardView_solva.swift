//
//  FourSeasonsBoardView_solva.swift
//  Solva
//
//  四季纸牌棋盘 UI。
//  设计思路：四座季节牌墩改为「单行环形接续」横向排布 —— 枢纽 + Spring→Summer→Autumn→Winter→(回到 Spring)，
//  牌墩之间以箭头连接直观呈现「环形循环」核心玩法，同时天然贴合横屏宽高比，
//  避免竖向十字布局在横屏下被过度压缩、卡牌显示过小的问题。
//  中央枢纽集中展示 4 组基础堆、太阳备用堆/弃牌堆与当值季节指示。
//  仅负责渲染与手势转发，全部规则判定位于 FourSeasonsEngine_solva。
//
import SwiftUI

struct FourSeasonsGameScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var coordinator_solva: GameSessionCoordinator_solva
    @StateObject private var engine_solva = FourSeasonsEngine_solva()

    private var entry_solva: GameCatalogEntry_solva { LocalData_solva.catalogEntry_solva(for: .fourSeasons) }

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
            FourSeasonsBoardView_solva(engine_solva: engine_solva)
        }
        .onAppear { engine_solva.coordinator_solva = coordinator_solva }
    }
}

struct FourSeasonsBoardView_solva: View {
    @ObservedObject var engine_solva: FourSeasonsEngine_solva

    /// 卡牌基准宽度：横屏下四季牌墩改为「单行环形接续」布局，天然贴合宽屏比例，
    /// 因此可以采用比原竖向十字布局更大的卡牌尺寸，缩放后依旧清晰可辨。
    private let cardWidth_solva: CGFloat = 62

    /// 四季按顺时针顺序排列：Spring → Summer → Autumn → Winter → (回到 Spring)，
    /// 与 Season_solva.next_solva 的推进顺序完全一致，用连接箭头直观呈现「环形循环」。
    private let seasonOrder_solva: [Season_solva] = [.spring, .summer, .autumn, .winter]

    var body: some View {
        AutoFitBoard_solva {
            HStack(spacing: 12) {
                centerHub_solva
                ForEach(Array(seasonOrder_solva.enumerated()), id: \.offset) { index_solva, season_solva in
                    cycleArrow_solva(from: index_solva == 0 ? seasonOrder_solva.last! : seasonOrder_solva[index_solva - 1], to: season_solva, isWrap_solva: false)
                    seasonRow_solva(season_solva)
                }
                cycleArrow_solva(from: seasonOrder_solva.last!, to: seasonOrder_solva.first!, isWrap_solva: true)
            }
            .padding(14)
        }
    }

    /// 季节间的循环连接箭头：当前激活季节 → 下一季节 的那一段会高亮，直观提示玩家下一步走向。
    private func cycleArrow_solva(from: Season_solva, to: Season_solva, isWrap_solva: Bool) -> some View {
        let isCurrentTransition_solva = engine_solva.activeSeason_solva == from && engine_solva.activeSeason_solva.next_solva == to
        return Image(systemName: isWrap_solva ? "arrow.triangle.2.circlepath" : "arrow.right")
            .font(.system(size: isWrap_solva ? 14 : 13, weight: .bold))
            .foregroundStyle(isCurrentTransition_solva ? Palette_solva.hint_solva : Palette_solva.textSecondary_solva.alpha_solva(0.45))
    }

    private func seasonColor_solva(_ season_solva: Season_solva) -> Color {
        let t_solva = season_solva.themeColor_solva
        return Color(red: t_solva.0, green: t_solva.1, blue: t_solva.2)
    }

    private func seasonRow_solva(_ season_solva: Season_solva) -> some View {
        let pile_solva = engine_solva.seasonPiles_solva[season_solva] ?? []
        let isActive_solva = engine_solva.activeSeason_solva == season_solva
        let isSelected_solva = engine_solva.selection_solva == .season(season_solva)

        return VStack(spacing: 6) {
            HStack(spacing: 5) {
                Circle().fill(seasonColor_solva(season_solva)).frame(width: 7, height: 7)
                Text(season_solva.displayName_solva)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isActive_solva ? Palette_solva.textPrimary_solva : Palette_solva.textSecondary_solva)
                if isActive_solva {
                    Text("ACTIVE")
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundStyle(Color.black)
                        .fixedSize()
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Capsule().fill(seasonColor_solva(season_solva)))
                }
            }
            .fixedSize()
            ZStack {
                if pile_solva.count > 1 {
                    PlayingCardView_solva(card_solva: pile_solva[pile_solva.count - 2], width_solva: cardWidth_solva)
                        .offset(x: 3, y: 3).opacity(0.4)
                }
                if let top_solva = pile_solva.last {
                    PlayingCardView_solva(card_solva: top_solva, width_solva: cardWidth_solva, isSelected_solva: isSelected_solva, isHintTarget_solva: isActive_solva && engine_solva.hintKind_solva == "season")
                } else {
                    EmptySlotView_solva(width_solva: cardWidth_solva)
                }
            }
            .onTapGesture {
                if isActive_solva {
                    engine_solva.tapActiveSeasonCard_solva()
                } else if season_solva == engine_solva.activeSeason_solva.next_solva {
                    engine_solva.tapNextSeasonPile_solva()
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(engine_solva.activeSeason_solva.next_solva == season_solva && engine_solva.selection_solva != nil ? Palette_solva.hint_solva.alpha_solva(0.7) : Color.clear, lineWidth: 2)
                    .frame(width: cardWidth_solva + 10, height: cardWidth_solva / AppConfig_solva.cardAspectRatio_solva + 10)
            )
            Text("\(pile_solva.count) cards")
                .font(.system(size: 8))
                .foregroundStyle(Palette_solva.textSecondary_solva)
        }
        .frame(maxWidth: .infinity)
    }

    /// 中央枢纽：改为「单行」内部排布（基础堆横排 + 太阳堆/弃牌横排），
    /// 大幅降低整体高度，使横屏下的行高由「季节墩」而非「枢纽」主导，避免整体被压缩过小。
    private var centerHub_solva: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Palette_solva.gold_solva)
                Text("Harmony ×\(engine_solva.harmonyRotationsCompleted_solva)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
            }

            HStack(spacing: 6) {
                ForEach(Suit_solva.allCases) { suit_solva in
                    foundationSlot_solva(suit_solva)
                }
            }

            HStack(spacing: 6) {
                ZStack {
                    if engine_solva.sunStock_solva.isEmpty == false {
                        PlayingCardView_solva(card_solva: engine_solva.sunStock_solva.first!, width_solva: 36)
                    } else {
                        EmptySlotView_solva(width_solva: 36, systemIcon_solva: "sun.max")
                    }
                }
                .onTapGesture { engine_solva.drawStock_solva() }

                ZStack {
                    if let waste_solva = engine_solva.solarWaste_solva {
                        PlayingCardView_solva(card_solva: waste_solva, width_solva: 36, isSelected_solva: engine_solva.selection_solva == .waste, isHintTarget_solva: engine_solva.hintKind_solva == "waste")
                    } else {
                        EmptySlotView_solva(width_solva: 36)
                    }
                }
                .onTapGesture { engine_solva.tapWasteCard_solva() }
            }

            Button {
                engine_solva.skipTurn_solva()
            } label: {
                Text("Skip")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.alpha_solva(0.06)))
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette_solva.panel_solva))
    }

    private func foundationSlot_solva(_ suit_solva: Suit_solva) -> some View {
        let cards_solva = engine_solva.foundations_solva[suit_solva] ?? []
        return ZStack {
            if let top_solva = cards_solva.last {
                PlayingCardView_solva(card_solva: top_solva, width_solva: 36)
            } else {
                EmptySlotView_solva(width_solva: 36)
                    .overlay(Text(suit_solva.symbol_solva).font(.system(size: 12)).foregroundStyle(Color.white.alpha_solva(0.3)))
            }
        }
        .onTapGesture { engine_solva.tapFoundation_solva(suit_solva) }
    }
}
