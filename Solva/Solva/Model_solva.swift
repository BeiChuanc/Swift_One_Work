//
//  Model_solva.swift
//  Solva
//
//  核心数据模型文件。
//  设计思路：集中定义 App 内所有纸牌/游戏/记录/成就相关的数据结构，
//  所有具体游戏引擎（Accordion / Penguin / Osmosis / DoublePyramid / FourSeasons）
//  都基于本文件中的 Card_solva / Suit_solva / Rank_solva 构建，
//  对局记录、个人统计、成就系统则基于 GameRecord_solva / PersonalStats_solva / Achievement_solva。
//

import Foundation
import SwiftUI

// MARK: - 花色

/// 花色枚举
/// 设计思路：四种标准花色，附带用于渲染的符号与颜色分类（红/黑）
enum Suit_solva: String, CaseIterable, Codable, Identifiable {
    case hearts, diamonds, clubs, spades

    var id: String { rawValue }

    /// 花色符号（SF Symbols 无法很好表达扑克花色，使用 Unicode 符号绘制）
    var symbol_solva: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }

    /// 是否为红色花色（红桃/方块）
    var isRed_solva: Bool {
        self == .hearts || self == .diamonds
    }
}

// MARK: - 点数

/// 牌面点数枚举，1 = A ... 13 = K
/// 设计思路：使用 Int 原始值方便做加法（如金字塔纸牌中的 13 点求和判定）
enum Rank_solva: Int, CaseIterable, Codable, Identifiable {
    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king

    var id: Int { rawValue }

    /// 牌面展示文本
    var label_solva: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return "\(rawValue)"
        }
    }

    /// 用于金字塔纸牌中「凑 13」判定的数值（与 rawValue 相同，单独暴露语义更清晰）
    var pyramidValue_solva: Int { rawValue }

    /// 环形接龙中用于「按点数顺延」的下一点数（K 之后回到 A，用于四季纸牌的循环表现）
    var cyclicNext_solva: Rank_solva {
        Rank_solva(rawValue: rawValue == 13 ? 1 : rawValue + 1) ?? .ace
    }
}

// MARK: - 扑克牌

/// 单张扑克牌模型
/// 设计思路：值类型 struct，携带唯一 id 便于 SwiftUI 列表 diff 与动画；
/// deckTag_solva 用于区分双人牌局（如双金字塔使用两副牌）中卡牌来自哪一副牌，
/// isFaceUp_solva / isHighlighted_solva 为纯 UI 呈现状态，由各引擎控制。
struct Card_solva: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let suit_solva: Suit_solva
    let rank_solva: Rank_solva
    /// 所属牌堆编号（0 或 1），用于双金字塔纸牌区分两副牌
    var deckTag_solva: Int = 0
    /// 是否正面朝上
    var isFaceUp_solva: Bool = false

    init(id: UUID = UUID(), suit: Suit_solva, rank: Rank_solva, deckTag: Int = 0, isFaceUp: Bool = false) {
        self.id = id
        self.suit_solva = suit
        self.rank_solva = rank
        self.deckTag_solva = deckTag
        self.isFaceUp_solva = isFaceUp
    }

    static func == (lhs: Card_solva, rhs: Card_solva) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// 是否与另一张牌同色（用于 Klondike/Penguin 式的「降序交替颜色」建墩规则）
    func isOppositeColor_solva(of other: Card_solva) -> Bool {
        suit_solva.isRed_solva != other.suit_solva.isRed_solva
    }
}

// MARK: - 游戏类型

/// App 内支持的五种纸牌游戏类型
/// 设计思路：作为贯穿全局的标识，用于路由、记录归档、统计聚合与成就归类
enum GameType_solva: String, CaseIterable, Codable, Identifiable {
    case accordion
    case penguin
    case osmosis
    case doublePyramid
    case fourSeasons

    var id: String { rawValue }
}

// MARK: - 对局结果

/// 单局游戏的最终结果
enum GameOutcome_solva: String, Codable {
    case won        // 胜利通关
    case lost       // 无路可走判负
    case abandoned  // 玩家主动退出/重开
}

// MARK: - 对局记录（对局记录功能）

/// 单条对局记录，对应「对局记录」功能需求
/// 设计思路：每局结束（无论胜负或放弃）都会生成一条记录并持久化，
/// 供「对局记录」列表页按时间倒序展示，并作为个人统计与成就判定的原始数据来源。
struct GameRecord_solva: Identifiable, Codable, Equatable {
    let id: UUID
    let gameType_solva: GameType_solva
    let outcome_solva: GameOutcome_solva
    let score_solva: Int
    let moveCount_solva: Int
    let durationSeconds_solva: Int
    let usedHintCount_solva: Int
    let finishedAt_solva: Date

    init(id: UUID = UUID(), gameType: GameType_solva, outcome: GameOutcome_solva, score: Int,
         moveCount: Int, durationSeconds: Int, usedHintCount: Int, finishedAt: Date = Date()) {
        self.id = id
        self.gameType_solva = gameType
        self.outcome_solva = outcome
        self.score_solva = score
        self.moveCount_solva = moveCount
        self.durationSeconds_solva = durationSeconds
        self.usedHintCount_solva = usedHintCount
        self.finishedAt_solva = finishedAt
    }

    /// 格式化后的耗时文本，如 "03:25"
    var durationText_solva: String {
        let m = durationSeconds_solva / 60
        let s = durationSeconds_solva % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - 单游戏统计

/// 针对某一种具体游戏类型的个人累计统计
/// 设计思路：与「个人记录」功能对应，展示每种游戏各自的最佳成绩、胜率等聚合指标
struct GameTypeStats_solva: Codable, Equatable {
    var playedCount_solva: Int = 0
    var wonCount_solva: Int = 0
    var bestScore_solva: Int = 0
    var bestDurationSeconds_solva: Int? = nil
    var totalScore_solva: Int = 0
    var currentStreak_solva: Int = 0
    var bestStreak_solva: Int = 0

    /// 胜率（0~1）
    var winRate_solva: Double {
        playedCount_solva == 0 ? 0 : Double(wonCount_solva) / Double(playedCount_solva)
    }
}

/// 玩家个人总览统计（跨所有游戏聚合），对应「个人记录」功能需求
struct PersonalStats_solva: Codable, Equatable {
    var perGame_solva: [GameType_solva: GameTypeStats_solva] = [:]
    var totalPlaySeconds_solva: Int = 0
    var totalGamesPlayed_solva: Int = 0
    var totalGamesWon_solva: Int = 0
    var firstPlayedAt_solva: Date? = nil

    var overallWinRate_solva: Double {
        totalGamesPlayed_solva == 0 ? 0 : Double(totalGamesWon_solva) / Double(totalGamesPlayed_solva)
    }

    func stats_solva(for gameType: GameType_solva) -> GameTypeStats_solva {
        perGame_solva[gameType] ?? GameTypeStats_solva()
    }
}

// MARK: - 成就（个人游戏成就记录）

/// 成就达成条件类型，用于通用化的进度判定
/// 设计思路：不同成就的达成条件差异较大，用有限枚举描述条件种类，
/// 具体门槛数值由 AchievementDefinition_solva.target_solva 提供，
/// 判定逻辑集中在 AchievementStore_solva 中完成，避免散落各引擎重复实现。
enum AchievementConditionType_solva: String, Codable {
    case totalWinsAcrossAll        // 全部游戏累计胜利次数
    case totalWinsForGame          // 指定游戏累计胜利次数
    case winStreakForGame          // 指定游戏连续胜利次数
    case fastWinForGame            // 指定游戏内在目标时间内通关一次
    case noHintWinForGame          // 指定游戏零提示通关一次
    case scoreThresholdForGame     // 指定游戏单局分数达到门槛
    case totalGamesPlayed          // 累计总对局数
    case specialMilestone          // 特殊里程碑（由引擎主动上报触发，如「手风琴压缩至剩余堆数」）
}

/// 成就定义（静态配置，来自 LocalData_solva）
struct AchievementDefinition_solva: Identifiable, Codable {
    let key_solva: String
    let title_solva: String
    let description_solva: String
    let iconName_solva: String
    let conditionType_solva: AchievementConditionType_solva
    let relatedGame_solva: GameType_solva?
    let target_solva: Int

    var id: String { key_solva }
}

/// 成就的运行时状态（是否解锁、当前进度），对应「个人游戏成就记录」功能需求
struct AchievementState_solva: Identifiable, Codable, Equatable {
    let key_solva: String
    var currentProgress_solva: Int = 0
    var isUnlocked_solva: Bool = false
    var unlockedAt_solva: Date? = nil

    var id: String { key_solva }
}

/// 成就定义与运行时状态的合并展示模型，供成就页面直接渲染
struct AchievementDisplay_solva: Identifiable {
    let definition_solva: AchievementDefinition_solva
    let state_solva: AchievementState_solva

    var id: String { definition_solva.key_solva }
    var progressRatio_solva: Double {
        guard definition_solva.target_solva > 0 else { return state_solva.isUnlocked_solva ? 1 : 0 }
        return min(1, Double(state_solva.currentProgress_solva) / Double(definition_solva.target_solva))
    }
}

// MARK: - 游戏结束上报载荷

/// 各引擎在一局结束时向 GameSessionCoordinator_solva 上报的统一数据载荷
/// 设计思路：让 5 个游戏引擎与「记录 / 统计 / 成就」三大存储解耦，
/// 引擎只需在结束时构造该结构体并调用协调器，即完成数据闭环。
struct GameFinishPayload_solva {
    let gameType_solva: GameType_solva
    let outcome_solva: GameOutcome_solva
    let score_solva: Int
    let moveCount_solva: Int
    let durationSeconds_solva: Int
    let usedHintCount_solva: Int
    /// 特殊里程碑数值（不同游戏含义不同，如手风琴的「最终剩余堆数」），用于成就判定
    let specialMetric_solva: Int?
}
