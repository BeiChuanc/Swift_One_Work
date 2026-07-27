//
//  RootRouterView_solva.swift
//  Solva
//
//  根路由容器视图。
//  设计思路：整个 App 只有这一处依据 NavigationManager_solva.currentRoute_solva 做分发，
//  所有页面切换都经由项目内置导航管理器驱动，不使用系统 NavigationStack，
//  顶层叠加全局成就 Toast，保证成就解锁提示能覆盖在任意页面之上。
//
import SwiftUI

struct RootRouterView_solva: View {
    @EnvironmentObject var navigation_solva: NavigationManager_solva

    var body: some View {
        ZStack {
            switch navigation_solva.currentRoute_solva {
            case .home:
                HomeScreen_solva()
            case .playing(let gameType_solva):
                GameContainerScreen_solva(gameType_solva: gameType_solva)
            case .records:
                RecordsScreen_solva()
            case .stats:
                StatsScreen_solva()
            case .achievements:
                AchievementsScreen_solva()
            case .howToPlay:
                HowToPlayScreen_solva()
            }
        }
        .transition(.opacity)
        .overlay(AchievementToastView_solva())
        .statusBarHidden(true)
    }
}
