//
//  RecordsScreen_solva.swift
//  Solva
//
//  对局记录页面。
//  设计思路：满足「游戏对局记录」功能需求——按时间倒序展示每一局的结果，
//  顶部提供按游戏类型筛选的分段控件，每行展示游戏图标色带/结果标签/得分/耗时/步数。
//  本次收紧顶部与筛选区之间的内边距，并将背景替换为绒面纹理背景，消除多余空白。
//
import SwiftUI

struct RecordsScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var recordsStore_solva: RecordsStore_solva

    @State private var filterGame_solva: GameType_solva? = nil

    private var filteredRecords_solva: [GameRecord_solva] {
        guard let filterGame_solva else { return recordsStore_solva.records_solva }
        return recordsStore_solva.records_solva(for: filterGame_solva)
    }

    var body: some View {
        VStack(spacing: 8) {
            SubPageTopBar_solva(title_solva: "Match History", onBack_solva: { navigation_solva.pop_solva() })

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip_solva(title: "All", isSelected: filterGame_solva == nil) { filterGame_solva = nil }
                    ForEach(LocalData_solva.gameCatalog_solva) { entry_solva in
                        filterChip_solva(title: entry_solva.title_solva, isSelected: filterGame_solva == entry_solva.gameType_solva, tint: entry_solva.accentColor_solva) {
                            filterGame_solva = entry_solva.gameType_solva
                        }
                    }
                }
                .padding(.horizontal, 18)
            }

            if filteredRecords_solva.isEmpty {
                EmptyStateView_solva(icon_solva: "tray", text_solva: "No matches yet — play a game to create your first record.")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredRecords_solva) { record_solva in
                            recordRow_solva(record_solva)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                }
            }
        }
        .padding(.top, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CasinoFeltBackground_solva(tint_solva: Palette_solva.gold_solva, intensity_solva: 0.08).ignoresSafeArea())
    }

    private func filterChip_solva(title: String, isSelected: Bool, tint: Color = Palette_solva.gold_solva, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title.uppercased())
                .casinoTracked_solva(0.4)
                .font(.casinoLabel_solva(11))
                .foregroundStyle(isSelected ? Color.black : Palette_solva.textSecondary_solva)
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(Capsule().fill(isSelected ? tint : Color.white.alpha_solva(0.06)))
                .overlay(Capsule().stroke(isSelected ? .clear : tint.alpha_solva(0.25), lineWidth: 1))
        }
    }

    private func recordRow_solva(_ record_solva: GameRecord_solva) -> some View {
        let entry_solva = LocalData_solva.catalogEntry_solva(for: record_solva.gameType_solva)
        return HStack(spacing: 12) {
            IconBadge_solva(icon_solva: entry_solva.seatIcon_solva, tint_solva: entry_solva.accentColor_solva, size_solva: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry_solva.title_solva)
                    .font(.casinoTitle_solva(13))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                Text(record_solva.finishedAt_solva.formatted(date: .abbreviated, time: .shortened))
                    .font(.casinoBody_solva(10))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }

            Spacer()

            outcomeTag_solva(record_solva.outcome_solva)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record_solva.score_solva) pts")
                    .font(.casinoNumeric_solva(12))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                Text("\(record_solva.durationText_solva) · \(record_solva.moveCount_solva) moves")
                    .font(.casinoBody_solva(10))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette_solva.panel_solva.alpha_solva(0.9)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.alpha_solva(0.06), lineWidth: 1))
    }

    private func outcomeTag_solva(_ outcome_solva: GameOutcome_solva) -> some View {
        let (text_solva, icon_solva, color_solva): (String, String, Color) = {
            switch outcome_solva {
            case .won: return ("WIN", "checkmark.seal.fill", Palette_solva.success_solva)
            case .lost: return ("LOST", "xmark.seal.fill", Palette_solva.danger_solva)
            case .abandoned: return ("QUIT", "minus.circle.fill", Palette_solva.textSecondary_solva)
            }
        }()
        return HStack(spacing: 3) {
            Image(systemName: icon_solva).font(.system(size: 9))
            Text(text_solva).casinoTracked_solva(0.5).font(.casinoLabel_solva(10))
        }
        .foregroundStyle(color_solva)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().stroke(color_solva.alpha_solva(0.5), lineWidth: 1))
    }
}
