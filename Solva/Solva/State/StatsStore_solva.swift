//
//  StatsStore_solva.swift
//  Solva
//
//  个人统计存储类。
//  设计思路：负责「个人记录」功能的聚合数据管理——总对局数/总胜场/总游戏时长，
//  以及每款游戏各自的最佳分数、最佳耗时、连胜数等。数据来源于每局结束时的上报，
//  持久化到 UserDefaults，并作为 ObservableObject 供统计页面订阅刷新。
//  关键属性：stats_solva（个人总览统计模型）
//  关键方法：applyFinish_solva（依据单局结果更新聚合统计）
import Foundation
import Combine

final class StatsStore_solva: ObservableObject {

    /// 当前个人总览统计
    @Published private(set) var stats_solva: PersonalStats_solva = PersonalStats_solva()

    private let storageKey_solva = AppConfig_solva.storageKeyStats_solva

    init() {
        loadFromDisk_solva()
    }

    /// 依据一局结束的上报数据更新统计
    /// - Parameter payload_solva: 单局结束时的统一上报载荷
    func applyFinish_solva(_ payload_solva: GameFinishPayload_solva) {
        var snapshot_solva = stats_solva
        if snapshot_solva.firstPlayedAt_solva == nil {
            snapshot_solva.firstPlayedAt_solva = Date()
        }
        snapshot_solva.totalGamesPlayed_solva += 1
        snapshot_solva.totalPlaySeconds_solva += payload_solva.durationSeconds_solva

        var gameStats_solva = snapshot_solva.stats_solva(for: payload_solva.gameType_solva)
        gameStats_solva.playedCount_solva += 1
        gameStats_solva.totalScore_solva += payload_solva.score_solva

        if payload_solva.outcome_solva == .won {
            snapshot_solva.totalGamesWon_solva += 1
            gameStats_solva.wonCount_solva += 1
            gameStats_solva.currentStreak_solva += 1
            gameStats_solva.bestStreak_solva = max(gameStats_solva.bestStreak_solva, gameStats_solva.currentStreak_solva)
            gameStats_solva.bestScore_solva = max(gameStats_solva.bestScore_solva, payload_solva.score_solva)
            if let best_solva = gameStats_solva.bestDurationSeconds_solva {
                gameStats_solva.bestDurationSeconds_solva = min(best_solva, payload_solva.durationSeconds_solva)
            } else {
                gameStats_solva.bestDurationSeconds_solva = payload_solva.durationSeconds_solva
            }
        } else {
            gameStats_solva.currentStreak_solva = 0
        }

        snapshot_solva.perGame_solva[payload_solva.gameType_solva] = gameStats_solva
        stats_solva = snapshot_solva
        persistToDisk_solva()
        NotificationCenter.default.post(name: .personalStatsDidUpdate_solva, object: nil)
    }

    // MARK: 私有：持久化

    private func persistToDisk_solva() {
        do {
            let data_solva = try JSONEncoder().encode(stats_solva)
            UserDefaults.standard.set(data_solva, forKey: storageKey_solva)
        } catch {
            debugPrint("个人统计持久化失败：\(error)")
        }
    }

    private func loadFromDisk_solva() {
        guard let data_solva = UserDefaults.standard.data(forKey: storageKey_solva) else { return }
        do {
            stats_solva = try JSONDecoder().decode(PersonalStats_solva.self, from: data_solva)
        } catch {
            debugPrint("个人统计读取失败：\(error)")
        }
    }
}
