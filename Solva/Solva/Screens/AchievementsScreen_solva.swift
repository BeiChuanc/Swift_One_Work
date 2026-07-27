//
//  AchievementsScreen_solva.swift
//  Solva
//
//  个人游戏成就记录页面。
//  设计思路：满足「个人游戏成就记录」功能需求——以网格展示全部成就，
//  未解锁成就显示灰度进度条与「还差多少」提示，已解锁成就高亮金色边框并展示解锁时间。
//  本次将图标替换为 MedallionBadge_solva 勋章样式，并收紧顶部区域间距。
//
import SwiftUI

struct AchievementsScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var achievementStore_solva: AchievementStore_solva

    private let gridColumns_solva = [GridItem(.adaptive(minimum: 260, maximum: 320), spacing: 10)]

    var body: some View {
        VStack(spacing: 6) {
            SubPageTopBar_solva(title_solva: "Achievements", onBack_solva: { navigation_solva.pop_solva() })

            HStack(spacing: 6) {
                Image(systemName: "rosette")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette_solva.gold_solva)
                Text("\(achievementStore_solva.unlockedCount_solva) / \(achievementStore_solva.totalCount_solva) UNLOCKED")
                    .casinoTracked_solva(0.6)
                    .font(.casinoLabel_solva(11))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
                Spacer()
            }
            .padding(.horizontal, 18)

            ScrollView {
                LazyVGrid(columns: gridColumns_solva, spacing: 10) {
                    ForEach(achievementStore_solva.displayList_solva) { display_solva in
                        achievementCard_solva(display_solva)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
        .padding(.top, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CasinoFeltBackground_solva(tint_solva: Palette_solva.gold_solva, intensity_solva: 0.08).ignoresSafeArea())
    }

    private func achievementCard_solva(_ display_solva: AchievementDisplay_solva) -> some View {
        let unlocked_solva = display_solva.state_solva.isUnlocked_solva
        let relatedColor_solva = display_solva.definition_solva.relatedGame_solva.map { LocalData_solva.catalogEntry_solva(for: $0).accentColor_solva } ?? Palette_solva.gold_solva

        return HStack(spacing: 12) {
            MedallionBadge_solva(icon_solva: display_solva.definition_solva.iconName_solva, tint_solva: relatedColor_solva, size_solva: 46, unlocked_solva: unlocked_solva)

            VStack(alignment: .leading, spacing: 3) {
                Text(display_solva.definition_solva.title_solva)
                    .font(.casinoTitle_solva(13))
                    .foregroundStyle(unlocked_solva ? Palette_solva.textPrimary_solva : Palette_solva.textSecondary_solva)
                Text(display_solva.definition_solva.description_solva)
                    .font(.casinoBody_solva(10))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
                    .lineLimit(2)

                if unlocked_solva, let date_solva = display_solva.state_solva.unlockedAt_solva {
                    Text("Unlocked \(date_solva.formatted(date: .abbreviated, time: .omitted))")
                        .font(.casinoLabel_solva(9))
                        .foregroundStyle(Palette_solva.gold_solva)
                } else {
                    ProgressView(value: display_solva.progressRatio_solva)
                        .tint(relatedColor_solva)
                }
            }
        }
        .padding(11)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette_solva.panel_solva.alpha_solva(0.9)))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(unlocked_solva ? relatedColor_solva.alpha_solva(0.5) : Color.white.alpha_solva(0.05), lineWidth: 1.2)
        )
        .opacity(unlocked_solva ? 1.0 : 0.85)
    }
}
