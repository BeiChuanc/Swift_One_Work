//
//  StatsScreen_solva.swift
//  Solva
//
//  个人记录（统计）页面。
//  设计思路：满足「个人记录」功能需求——顶部展示跨游戏的总览指标卡（总局数/总胜场/
//  总胜率/总时长），下方逐个游戏展示该游戏的最佳分数/最佳耗时/连胜等详细数据；
//  底部新增「Support & Legal」分区，收纳技术支持/隐私政策两个入口
//  （原位于首页顶部导航条，现整合进个人中心，与账户/数据相关的信息归类到一起）。
//  本次收紧区块间距，全部文案改为英文，并将游戏行的色带替换为图标徽标。
//
import SwiftUI

struct StatsScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var statsStore_solva: StatsStore_solva

    /// 当前展示的信息浮层类型（技术支持/隐私政策），nil 表示未展示
    @State private var activeInfoSheet_solva: InfoSheetKind_solva?

    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                SubPageTopBar_solva(title_solva: "Profile", onBack_solva: { navigation_solva.pop_solva() })

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeaderView_solva(title_solva: "Overview", subtitle_solva: "Cumulative performance across every table")
                            .padding(.horizontal, 18)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                StatChipView_solva(icon_solva: "gamecontroller.fill", value_solva: "\(statsStore_solva.stats_solva.totalGamesPlayed_solva)", label_solva: "Total Games")
                                StatChipView_solva(icon_solva: "trophy.fill", value_solva: "\(statsStore_solva.stats_solva.totalGamesWon_solva)", label_solva: "Total Wins", tint_solva: Palette_solva.success_solva)
                                StatChipView_solva(icon_solva: "percent", value_solva: percentText_solva(statsStore_solva.stats_solva.overallWinRate_solva), label_solva: "Win Rate")
                                StatChipView_solva(icon_solva: "clock.fill", value_solva: durationText_solva(statsStore_solva.stats_solva.totalPlaySeconds_solva), label_solva: "Total Play Time")
                            }
                            .padding(.horizontal, 18)
                        }

                        SectionHeaderView_solva(title_solva: "By Game", subtitle_solva: "Detailed record for every table")
                            .padding(.horizontal, 18)
                            .padding(.top, 4)

                        VStack(spacing: 8) {
                            ForEach(LocalData_solva.gameCatalog_solva) { entry_solva in
                                gameStatRow_solva(entry_solva)
                            }
                        }
                        .padding(.horizontal, 18)

                        SectionHeaderView_solva(title_solva: "Support & Legal", subtitle_solva: "Help, contact and privacy information")
                            .padding(.horizontal, 18)
                            .padding(.top, 4)

                        VStack(spacing: 8) {
                            infoLinkRow_solva(.support)
                            infoLinkRow_solva(.privacy)
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 16)
                    }
                }
            }
            .padding(.top, 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(CasinoFeltBackground_solva(tint_solva: Palette_solva.gold_solva, intensity_solva: 0.08).ignoresSafeArea())

            if let activeInfoSheet_solva {
                InfoSheetOverlay_solva(kind_solva: activeInfoSheet_solva) {
                    withAnimation(.easeInOut(duration: 0.2)) { self.activeInfoSheet_solva = nil }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeInfoSheet_solva)
    }

    /// 「技术支持」/「隐私政策」入口行：点击唤出 InfoSheetOverlay_solva 说明浮层
    private func infoLinkRow_solva(_ kind_solva: InfoSheetKind_solva) -> some View {
        Button {
            activeInfoSheet_solva = kind_solva
        } label: {
            HStack(spacing: 12) {
                IconBadge_solva(icon_solva: kind_solva.icon_solva, tint_solva: kind_solva.accent_solva, size_solva: 36)
                Text(kind_solva.title_solva)
                    .font(.casinoTitle_solva(13))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette_solva.panel_solva.alpha_solva(0.9)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(kind_solva.accent_solva.alpha_solva(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func gameStatRow_solva(_ entry_solva: GameCatalogEntry_solva) -> some View {
        let stats_solva = statsStore_solva.stats_solva.stats_solva(for: entry_solva.gameType_solva)
        return HStack(spacing: 12) {
            IconBadge_solva(icon_solva: entry_solva.seatIcon_solva, tint_solva: entry_solva.accentColor_solva, size_solva: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry_solva.title_solva)
                    .font(.casinoTitle_solva(13))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                Text("\(stats_solva.playedCount_solva) played · \(stats_solva.wonCount_solva) won")
                    .font(.casinoBody_solva(10))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }

            Spacer()

            miniMetric_solva(label: "Best Score", value: "\(stats_solva.bestScore_solva)")
            miniMetric_solva(label: "Best Time", value: stats_solva.bestDurationSeconds_solva.map { durationText_solva($0) } ?? "--")
            miniMetric_solva(label: "Best Streak", value: "\(stats_solva.bestStreak_solva)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette_solva.panel_solva.alpha_solva(0.9)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(entry_solva.accentColor_solva.alpha_solva(0.22), lineWidth: 1))
    }

    private func miniMetric_solva(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.casinoNumeric_solva(13))
                .foregroundStyle(Palette_solva.textPrimary_solva)
            Text(label.uppercased())
                .casinoTracked_solva(0.4)
                .font(.casinoLabel_solva(8.5))
                .foregroundStyle(Palette_solva.textSecondary_solva)
        }
        .frame(minWidth: 64)
    }

    private func percentText_solva(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    private func durationText_solva(_ seconds: Int) -> String {
        let h_solva = seconds / 3600
        let m_solva = (seconds % 3600) / 60
        if h_solva > 0 { return String(format: "%dh %dm", h_solva, m_solva) }
        let s_solva = seconds % 60
        return String(format: "%02d:%02d", m_solva, s_solva)
    }
}
