//
//  NotificationNames_solva.swift
//  Solva
//
//  全局通知名称定义文件。
//  设计思路：SwiftUI 内部各 ObservableObject 已通过 @Published 驱动响应式刷新，
//  但「成就解锁」「对局记录新增」等属于跨模块的一次性事件（例如需要弹出全局 Toast），
//  按项目规范额外通过 NotificationCenter 广播，使无直接依赖关系的视图也能感知。
//

import Foundation

extension Notification.Name {
    /// 新增一条对局记录时广播
    static let gameRecordDidAdd_solva = Notification.Name("solva.notification.gameRecordDidAdd")
    /// 有成就被解锁时广播（userInfo 中携带 "key" -> 成就 key_solva）
    static let achievementDidUnlock_solva = Notification.Name("solva.notification.achievementDidUnlock")
    /// 个人统计发生更新时广播
    static let personalStatsDidUpdate_solva = Notification.Name("solva.notification.personalStatsDidUpdate")
}
