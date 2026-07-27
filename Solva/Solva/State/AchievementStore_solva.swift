//
//  AchievementStore_solva.swift
//  Solva
//
//  成就存储与判定类。
//  设计思路：负责「个人游戏成就记录」功能——维护每个成就的解锁状态与进度，
//  在每局结束时结合 LocalData_solva 中的静态成就定义与最新的个人统计/单局上报数据，
//  统一判定是否达成/推进各类成就，判定逻辑集中在此，避免分散到 5 个游戏引擎中重复实现。
//  关键属性：displayList_solva（成就定义 + 运行时状态的合并展示列表）
//  关键方法：evaluate_solva（单局结束后调用，完成成就判定与解锁）
import Foundation
import Combine

final class AchievementStore_solva: ObservableObject {

    /// 全部成就的运行时状态，key 为成就 key_solva
    @Published private(set) var states_solva: [String: AchievementState_solva] = [:]

    private let storageKey_solva = AppConfig_solva.storageKeyAchievements_solva

    init() {
        loadFromDisk_solva()
        ensureAllDefinitionsHaveState_solva()
    }

    /// 供成就页面直接渲染的合并列表（保持与 LocalData_solva 中定义顺序一致）
    var displayList_solva: [AchievementDisplay_solva] {
        LocalData_solva.achievementDefinitions_solva.map { def_solva in
            AchievementDisplay_solva(definition_solva: def_solva, state_solva: states_solva[def_solva.key_solva] ?? AchievementState_solva(key_solva: def_solva.key_solva))
        }
    }

    /// 已解锁成就数量 / 总成就数量，用于首页/成就页展示总体进度
    var unlockedCount_solva: Int {
        states_solva.values.filter { $0.isUnlocked_solva }.count
    }
    var totalCount_solva: Int {
        LocalData_solva.achievementDefinitions_solva.count
    }

    /// 单局结束后统一判定成就
    /// - Parameters:
    ///   - payload_solva: 本局结束上报数据
    ///   - latestStats_solva: 已完成本局更新后的最新个人统计（由 StatsStore_solva 提供）
    /// - Returns: 本次新解锁的成就定义列表（供 UI 弹出 Toast 展示）
    @discardableResult
    func evaluate_solva(payload_solva: GameFinishPayload_solva, latestStats_solva: PersonalStats_solva) -> [AchievementDefinition_solva] {
        var newlyUnlocked_solva: [AchievementDefinition_solva] = []
        let gameStats_solva = latestStats_solva.stats_solva(for: payload_solva.gameType_solva)

        for def_solva in LocalData_solva.achievementDefinitions_solva {
            guard var state_solva = states_solva[def_solva.key_solva], state_solva.isUnlocked_solva == false else { continue }

            let progress_solva = currentProgress_solva(for: def_solva, payload: payload_solva, latestStats: latestStats_solva, gameStats: gameStats_solva)
            state_solva.currentProgress_solva = max(state_solva.currentProgress_solva, progress_solva)

            if isConditionMet_solva(def_solva, payload: payload_solva, latestStats: latestStats_solva, gameStats: gameStats_solva) {
                state_solva.isUnlocked_solva = true
                state_solva.unlockedAt_solva = Date()
                newlyUnlocked_solva.append(def_solva)
            }
            states_solva[def_solva.key_solva] = state_solva
        }

        if newlyUnlocked_solva.isEmpty == false {
            persistToDisk_solva()
            for def_solva in newlyUnlocked_solva {
                NotificationCenter.default.post(name: .achievementDidUnlock_solva, object: nil, userInfo: ["key": def_solva.key_solva])
            }
        } else {
            persistToDisk_solva()
        }
        return newlyUnlocked_solva
    }

    // MARK: 私有：条件判定

    private func currentProgress_solva(for def_solva: AchievementDefinition_solva, payload: GameFinishPayload_solva, latestStats: PersonalStats_solva, gameStats: GameTypeStats_solva) -> Int {
        switch def_solva.conditionType_solva {
        case .totalWinsAcrossAll: return latestStats.totalGamesWon_solva
        case .totalWinsForGame: return gameStats.wonCount_solva
        case .winStreakForGame: return gameStats.currentStreak_solva
        case .totalGamesPlayed: return latestStats.totalGamesPlayed_solva
        case .scoreThresholdForGame: return payload.score_solva
        case .fastWinForGame: return payload.outcome_solva == .won ? payload.durationSeconds_solva : Int.max
        case .noHintWinForGame: return payload.usedHintCount_solva
        case .specialMilestone: return payload.specialMetric_solva ?? 0
        }
    }

    private func isConditionMet_solva(_ def_solva: AchievementDefinition_solva, payload: GameFinishPayload_solva, latestStats: PersonalStats_solva, gameStats: GameTypeStats_solva) -> Bool {
        if let related_solva = def_solva.relatedGame_solva, related_solva != payload.gameType_solva {
            // 与特定游戏相关的成就，只有该游戏结束时才可能被判定推进/解锁
            // 但历史进度（如连胜数）仍应保留在 state 中，此处直接跳过条件判定
            return false
        }
        switch def_solva.conditionType_solva {
        case .totalWinsAcrossAll:
            return latestStats.totalGamesWon_solva >= def_solva.target_solva
        case .totalWinsForGame:
            return gameStats.wonCount_solva >= def_solva.target_solva
        case .winStreakForGame:
            return gameStats.currentStreak_solva >= def_solva.target_solva
        case .totalGamesPlayed:
            return latestStats.totalGamesPlayed_solva >= def_solva.target_solva
        case .scoreThresholdForGame:
            return payload.outcome_solva == .won && payload.score_solva >= def_solva.target_solva
        case .fastWinForGame:
            return payload.outcome_solva == .won && payload.durationSeconds_solva <= def_solva.target_solva
        case .noHintWinForGame:
            return payload.outcome_solva == .won && payload.usedHintCount_solva == 0
        case .specialMilestone:
            guard let metric_solva = payload.specialMetric_solva else { return false }
            // 语义约定：手风琴「剩余堆数」类成就要求 <= target；其余里程碑类成就要求 >= target
            if def_solva.key_solva == "accordion_compact" {
                return payload.outcome_solva == .won && metric_solva <= def_solva.target_solva
            }
            return metric_solva >= def_solva.target_solva
        }
    }

    // MARK: 私有：持久化

    private func ensureAllDefinitionsHaveState_solva() {
        for def_solva in LocalData_solva.achievementDefinitions_solva where states_solva[def_solva.key_solva] == nil {
            states_solva[def_solva.key_solva] = AchievementState_solva(key_solva: def_solva.key_solva)
        }
    }

    private func persistToDisk_solva() {
        do {
            let data_solva = try JSONEncoder().encode(Array(states_solva.values))
            UserDefaults.standard.set(data_solva, forKey: storageKey_solva)
        } catch {
            debugPrint("成就数据持久化失败：\(error)")
        }
    }

    private func loadFromDisk_solva() {
        guard let data_solva = UserDefaults.standard.data(forKey: storageKey_solva) else { return }
        do {
            let list_solva = try JSONDecoder().decode([AchievementState_solva].self, from: data_solva)
            states_solva = Dictionary(uniqueKeysWithValues: list_solva.map { ($0.key_solva, $0) })
        } catch {
            debugPrint("成就数据读取失败：\(error)")
        }
    }
}
