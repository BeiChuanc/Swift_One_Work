//
//  ContentView.swift
//  Solva
//
//  App 根视图。
//  设计思路：仅作为最外层容器，实际内容全部交由 RootRouterView_solva 依据
//  NavigationManager_solva 的路由状态渲染，保持根视图文件极简。
//  额外在最底层铺一层常驻深色绒面背景：系统 UIWindow 默认背景为白色，
//  若页面切换瞬间（转场动画的前后几帧）恰好没有任何不透明内容覆盖，
//  就会露出这层白色造成「闪白」；本层背景不会随路由切换而重新创建，
//  始终存在于所有页面下方，从根本上消除闪白问题。
//  冷启动阶段额外叠加 LaunchAnimationScreen_solva 发牌动画，用趣味动效顶替
//  「纯色/白屏」的空窗期，固定展示时长后与正式首页做透明度淡入淡出切换。
//  发牌动画结束、首页视图层级稳定后，额外调用一次 H5BrowserPresenter_solva
//  以竖屏模态展示 H5Bridge 模块的 H5BrowserScreen_solva（H5Bridge 模块）。
//
//  Created by 北川 on 2026/7/25.
//

import SwiftUI

struct ContentView: View {
    /// 是否仍处于启动动画阶段，true 时展示 LaunchAnimationScreen_solva 顶替正式内容
    @State private var isLaunching_solva = true

    var body: some View {
        ZStack {
            Palette_solva.feltDeep_solva.ignoresSafeArea()
            RootRouterView_solva()

            if isLaunching_solva {
                LaunchAnimationScreen_solva()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 固定展示一段时间，让发牌动画完整播放一轮后再淡出，露出正式首页
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    isLaunching_solva = false
                }
            }
        }
    }
}

private func makePreviewCoordinator_solva() -> (RecordsStore_solva, StatsStore_solva, AchievementStore_solva, GameSessionCoordinator_solva) {
    let records_preview = RecordsStore_solva()
    let stats_preview = StatsStore_solva()
    let achievements_preview = AchievementStore_solva()
    let coordinator_preview = GameSessionCoordinator_solva(recordsStore: records_preview, statsStore: stats_preview, achievementStore: achievements_preview)
    return (records_preview, stats_preview, achievements_preview, coordinator_preview)
}

#Preview {
    let preview_solva = makePreviewCoordinator_solva()
    ContentView()
        .environmentObject(NavigationManager_solva())
        .environmentObject(preview_solva.0)
        .environmentObject(preview_solva.1)
        .environmentObject(preview_solva.2)
        .environmentObject(preview_solva.3)
}
