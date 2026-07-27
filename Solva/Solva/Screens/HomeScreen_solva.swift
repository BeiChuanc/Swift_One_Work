//
//  HomeScreen_solva.swift
//  Solva
//
//  首页（游戏大厅）页面。
//  设计思路：顶部为横向招牌条——最左侧是「How to Play」呼吸灯圆形入口（无文本，
//  持续呼吸动画吸引新玩家注意），紧接品牌铭牌，右侧「Match History / Profile /
//  Achievements」横向入口（不再使用侧边纵向列表）；
//  主体区域用 CasinoTableView_solva 把 5 款游戏当作围坐在牌桌四周的座位环形展示，
//  替代传统纵向列表/网格，整体呈现欧美私人牌室大厅的沉浸式质感。
//  注：技术支持 / 隐私政策入口已移入 Profile（StatsScreen_solva）页面，
//  首页顶部导航条不再展示这两个入口，避免与游戏相关的核心导航混杂。
//  左上角、招牌条下方额外悬浮一个 H5Bridge 模块入口按钮，点击后用
//  H5BrowserPresenter_solva 以竖屏模态打开 H5BrowserScreen_solva。
//
import SwiftUI

struct HomeScreen_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva
    @EnvironmentObject var recordsStore_solva: RecordsStore_solva
    @EnvironmentObject var statsStore_solva: StatsStore_solva
    @EnvironmentObject var achievementStore_solva: AchievementStore_solva

    var body: some View {
        VStack(spacing: 0) {
            topBar_solva
                .padding(.horizontal, 22)
                .padding(.top, 10)
                .padding(.bottom, 4)

            CasinoTableView_solva(seatCount_solva: LocalData_solva.gameCatalog_solva.count) { index_solva in
                let entry_solva = LocalData_solva.gameCatalog_solva[index_solva]
                let gameStats_solva = statsStore_solva.stats_solva.stats_solva(for: entry_solva.gameType_solva)
                GameMenuCardView_solva(
                    entry_solva: entry_solva,
                    bestScore_solva: gameStats_solva.bestScore_solva,
                    winCount_solva: gameStats_solva.wonCount_solva,
                    onTap_solva: { navigation_solva.push_solva(.playing(entry_solva.gameType_solva)) }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CasinoFeltBackground_solva(tint_solva: Palette_solva.gold_solva, intensity_solva: 0.10).ignoresSafeArea())
        .overlay(alignment: .topLeading) {
            h5BridgeEntryButton_solva
                .padding(.leading, 22)
                .padding(.top, 62)
        }
    }

    /// H5Bridge 模块入口：点击后以竖屏模态打开 H5BrowserScreen_solva
    private var h5BridgeEntryButton_solva: some View {
        BreathingIconButton_solva(icon_solva: "globe", tint_solva: Palette_solva.hint_solva, size_solva: 38) {
            H5BrowserPresenter_solva.present_solva()
        }
    }

    private var topBar_solva: some View {
        HStack(spacing: 14) {
            // 左上角「How to Play」呼吸灯圆形入口：无文本标签，用持续呼吸动画替代文字提示，
            // 单独放在最左侧而不混入右侧滚动导航条，让新玩家第一眼就能注意到玩法说明入口。
            BreathingIconButton_solva(icon_solva: "book.fill", tint_solva: Palette_solva.gold_solva, size_solva: 42) {
                navigation_solva.push_solva(.howToPlay)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("SOLVA")
                    .font(.casinoDisplay_solva(24))
                    .casinoTracked_solva(2)
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                Text("PRIVATE CARD ROOM")
                    .font(.casinoLabel_solva(9))
                    .casinoTracked_solva(2)
                    .foregroundStyle(Palette_solva.gold_solva.alpha_solva(0.85))
            }

            Spacer(minLength: 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    topNavButton_solva(icon: "list.bullet.rectangle.fill", title: "Match History") {
                        navigation_solva.push_solva(.records)
                    }
                    topNavButton_solva(icon: "person.crop.circle.fill", title: "Profile") {
                        navigation_solva.push_solva(.stats)
                    }
                    topNavButton_solva(icon: "rosette", title: "Achievements", badge: "\(achievementStore_solva.unlockedCount_solva)/\(achievementStore_solva.totalCount_solva)") {
                        navigation_solva.push_solva(.achievements)
                    }
                }
            }
        }
    }

    private func topNavButton_solva(icon: String, title: String, badge: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                IconBadge_solva(icon_solva: icon, tint_solva: Palette_solva.gold_solva, size_solva: 30, ringStyle_solva: false)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title.uppercased())
                        .casinoTracked_solva(0.6)
                        .font(.casinoLabel_solva(11.5))
                        .foregroundStyle(Palette_solva.textPrimary_solva)
                    if let badge_solva = badge {
                        Text(badge_solva)
                            .font(.casinoNumeric_solva(9))
                            .foregroundStyle(Palette_solva.textSecondary_solva)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Palette_solva.panel_solva.alpha_solva(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(Palette_solva.gold_solva.alpha_solva(0.3), lineWidth: 1)
            )
        }
    }
}
