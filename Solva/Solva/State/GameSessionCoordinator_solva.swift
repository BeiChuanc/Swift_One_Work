//
//  GameSessionCoordinator_solva.swift
//  Solva
//
//  游戏对局结算协调器。
//  设计思路：五款游戏引擎彼此独立、规则差异很大，但「一局结束后要做的事」是统一的——
//  生成对局记录、更新个人统计、判定并解锁成就。将这一整套闭环流程集中到本类，
//  各引擎只需在结束时调用 finish_solva，即可保证数据链路完整、不重复、不遗漏。
//  关键属性：latestUnlockedAchievements_solva（最近一次结算新解锁的成就，供 Toast 展示）
//  关键方法：finish_solva（统一入口，串联 记录/统计/成就 三大存储）
import Foundation
import Combine

final class GameSessionCoordinator_solva: ObservableObject {

    /// 最近一次结算解锁的成就（用于驱动全局成就 Toast 展示，展示后由 UI 层清空）
    @Published var latestUnlockedAchievements_solva: [AchievementDefinition_solva] = []

    private let recordsStore_solva: RecordsStore_solva
    private let statsStore_solva: StatsStore_solva
    private let achievementStore_solva: AchievementStore_solva

    init(recordsStore: RecordsStore_solva, statsStore: StatsStore_solva, achievementStore: AchievementStore_solva) {
        self.recordsStore_solva = recordsStore
        self.statsStore_solva = statsStore
        self.achievementStore_solva = achievementStore
    }

    /// 结算一局游戏，串联「记录 → 统计 → 成就」的完整闭环
    /// - Parameter payload_solva: 引擎构造的统一结束上报数据
    func finish_solva(_ payload_solva: GameFinishPayload_solva) {
        let record_solva = GameRecord_solva(
            gameType: payload_solva.gameType_solva,
            outcome: payload_solva.outcome_solva,
            score: payload_solva.score_solva,
            moveCount: payload_solva.moveCount_solva,
            durationSeconds: payload_solva.durationSeconds_solva,
            usedHintCount: payload_solva.usedHintCount_solva
        )
        recordsStore_solva.addRecord_solva(record_solva)
        statsStore_solva.applyFinish_solva(payload_solva)
        let unlocked_solva = achievementStore_solva.evaluate_solva(payload_solva: payload_solva, latestStats_solva: statsStore_solva.stats_solva)
        if unlocked_solva.isEmpty == false {
            latestUnlockedAchievements_solva.append(contentsOf: unlocked_solva)
        }
    }
}
