//
//  HowToPlayScreen_solva.swift
//  Solva
//
//  游戏玩法说明页面。
//  设计思路：集中展示 App 内全部 5 款纸牌游戏的规则简介——每张「规则卡」
//  用游戏专属强调色 + 图标徽标呈现标题与标签，正文展示 LocalData_solva 中
//  预置的规则简介文案（含各游戏专属新颖玩法说明），以网格铺开便于横屏浏览，
//  方便玩家在开始对局前快速了解每款游戏的核心规则与特色机制。
//
import SwiftUI

struct HowToPlayScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva

    private let gridColumns_solva = [GridItem(.adaptive(minimum: 300, maximum: 360), spacing: 10)]

    var body: some View {
        VStack(spacing: 6) {
            SubPageTopBar_solva(title_solva: "How to Play", onBack_solva: { navigation_solva.pop_solva() })

            ScrollView {
                LazyVGrid(columns: gridColumns_solva, spacing: 10) {
                    ForEach(LocalData_solva.gameCatalog_solva) { entry_solva in
                        ruleCard_solva(entry_solva)
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

    private func ruleCard_solva(_ entry_solva: GameCatalogEntry_solva) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                IconBadge_solva(icon_solva: entry_solva.seatIcon_solva, tint_solva: entry_solva.accentColor_solva, size_solva: 38)
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry_solva.title_solva)
                        .font(.casinoTitle_solva(15))
                        .foregroundStyle(Palette_solva.textPrimary_solva)
                    Text(entry_solva.badgeText_solva.uppercased())
                        .casinoTracked_solva(1)
                        .font(.casinoLabel_solva(9))
                        .foregroundStyle(entry_solva.accentColor_solva)
                }
                Spacer()
            }

            Text(entry_solva.ruleSummary_solva)
                .font(.casinoBody_solva(11.5))
                .foregroundStyle(Palette_solva.textSecondary_solva)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette_solva.panel_solva.alpha_solva(0.9)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(entry_solva.accentColor_solva.alpha_solva(0.35), lineWidth: 1.2))
    }
}
