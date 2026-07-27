//
//  SolvaApp.swift
//  Solva
//
//  App 入口文件。
//  设计思路：整个 App 只在此处创建全部全局状态对象（导航管理器、对局记录/个人统计/成就
//  三大存储、结算协调器），并通过 environmentObject 注入到根路由视图，
//  保证所有页面共享同一份数据源。App 强制横屏由 Info.plist 的方向配置保证，
//  此处额外隐藏状态栏以获得更沉浸的牌桌体验。
//  额外在 init 中初始化 Airbridge 归因 SDK（H5Bridge 模块，详见该文件夹说明），
//  并在 onOpenURL 中转发 Deeplink 打开事件，这是归因功能生效的必要前置条件。
//  接入 AppDelegate_solva（H5Bridge 模块）是为了让 H5BrowserPresenter_solva
//  展示 H5 页面时能临时切到竖屏，系统查询界面方向只认 AppDelegate 这一个入口。
//
//  Created by 北川 on 2026/7/25.
//

import SwiftUI

@main
struct SolvaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate_solva.self) private var appDelegate_solva
    @StateObject private var navigation_solva = NavigationManager_solva()
    @StateObject private var recordsStore_solva: RecordsStore_solva
    @StateObject private var statsStore_solva: StatsStore_solva
    @StateObject private var achievementStore_solva: AchievementStore_solva
    @StateObject private var coordinator_solva: GameSessionCoordinator_solva

    init() {
        let recordsStore_local = RecordsStore_solva()
        let statsStore_local = StatsStore_solva()
        let achievementStore_local = AchievementStore_solva()
        _recordsStore_solva = StateObject(wrappedValue: recordsStore_local)
        _statsStore_solva = StateObject(wrappedValue: statsStore_local)
        _achievementStore_solva = StateObject(wrappedValue: achievementStore_local)
        _coordinator_solva = StateObject(wrappedValue: GameSessionCoordinator_solva(
            recordsStore: recordsStore_local,
            statsStore: statsStore_local,
            achievementStore: achievementStore_local
        ))

        // H5Bridge 模块：Airbridge App SDK 必须在 App 启动最早阶段初始化一次
        AirbridgeSDKManager_solva.shared_solva.initializeIfNeeded_solva()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigation_solva)
                .environmentObject(recordsStore_solva)
                .environmentObject(statsStore_solva)
                .environmentObject(achievementStore_solva)
                .environmentObject(coordinator_solva)
                .onOpenURL { url_solva in
                    // H5Bridge 模块：采集 URL Scheme / Universal Link 唤起 App 的 Deeplink Open 事件
                    AirbridgeSDKManager_solva.shared_solva.trackDeeplink_solva(url: url_solva)
                }
        }
    }
}
