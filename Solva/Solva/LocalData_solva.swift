//
//  LocalData_solva.swift
//  Solva
//
//  预制静态数据文件。
//  设计思路：集中存放不随用户操作变化的「配置型数据」——五款游戏的展示目录信息、
//  规则简介文案，以及全部成就的静态定义列表。运行时状态（是否解锁/进度）不放在此文件，
//  由 AchievementStore_solva 结合本文件的定义与持久化的运行时状态合并展示。
//  注：全部用户可见文案均为英文，符合项目 UI 文本统一使用英文的规范。
//
import SwiftUI

/// 单个游戏在首页目录中展示所需的静态信息
struct GameCatalogEntry_solva: Identifiable {
    let gameType_solva: GameType_solva
    let title_solva: String
    let subtitle_solva: String
    let ruleSummary_solva: String
    let badgeText_solva: String
    let seatIcon_solva: String
    let accentColor_solva: Color

    var id: String { gameType_solva.rawValue }
}

/// 预制数据统一入口
/// 设计思路：以 enum + static 常量的方式组织，避免实例化，属于纯只读配置表
enum LocalData_solva {

    /// 五款游戏的目录展示数据，首页/记录/统计/成就页面均从此读取标题与配色，保证全局一致
    static let gameCatalog_solva: [GameCatalogEntry_solva] = [
        GameCatalogEntry_solva(
            gameType_solva: .accordion,
            title_solva: "Accordion Solitaire",
            subtitle_solva: "Single-row compression",
            ruleSummary_solva: "52 cards are dealt in a single row. Move any card onto the card 1, 3 or 4 spaces to its left when they share a rank or suit, compressing the row into as few piles as possible. Chaining merges quickly triggers a Harmonic Combo bonus.",
            badgeText_solva: "Strategy · Solo",
            seatIcon_solva: "pianokeys",
            accentColor_solva: Color(red: 0.98, green: 0.55, blue: 0.24)
        ),
        GameCatalogEntry_solva(
            gameType_solva: .penguin,
            title_solva: "Penguin Solitaire",
            subtitle_solva: "Polar migration",
            ruleSummary_solva: "One Ice Block card sets the starting rank for the foundations. The remaining 51 cards fill 8 tableau columns; move a face-up card with everything above it as a group, landing in descending, alternating colors. Clearing a whole column earns a Migration Point to peek at a hidden card.",
            badgeText_solva: "Patience · Solo",
            seatIcon_solva: "snowflake",
            accentColor_solva: Color(red: 0.30, green: 0.70, blue: 0.95)
        ),
        GameCatalogEntry_solva(
            gameType_solva: .osmosis,
            title_solva: "Osmosis Solitaire",
            subtitle_solva: "Quantum permeation",
            ruleSummary_solva: "Four reserve piles surround a base foundation. The other three foundations may only accept a rank once the base foundation already holds it — like osmosis spreading outward. A single Quantum Buffer slot lets you park a blocked card to break up tough deals.",
            badgeText_solva: "Puzzle · Solo",
            seatIcon_solva: "atom",
            accentColor_solva: Color(red: 0.55, green: 0.45, blue: 0.90)
        ),
        GameCatalogEntry_solva(
            gameType_solva: .doublePyramid,
            title_solva: "Double Pyramid",
            subtitle_solva: "Advanced 13-count",
            ruleSummary_solva: "Two decks build two 7-row pyramids sharing one stock. Any two exposed cards summing to 13 are cleared (a King clears alone) — pairing can even cross between the two pyramids. Clearing both pyramids triggers a Perfect Cascade bonus.",
            badgeText_solva: "Calculation · Solo",
            seatIcon_solva: "triangle.fill",
            accentColor_solva: Color(red: 0.95, green: 0.35, blue: 0.45)
        ),
        GameCatalogEntry_solva(
            gameType_solva: .fourSeasons,
            title_solva: "Four Seasons",
            subtitle_solva: "Circular rotation",
            ruleSummary_solva: "Spring, Summer, Autumn and Winter piles ring the table; the active turn rotates clockwise through them. Only the active season may play — onto its foundation, or onto the next season clockwise. An unbroken rotation earns a Harmony Bonus.",
            badgeText_solva: "Rhythm · Solo",
            seatIcon_solva: "arrow.triangle.2.circlepath",
            accentColor_solva: Color(red: 0.20, green: 0.75, blue: 0.55)
        )
    ]

    /// 根据游戏类型查询目录信息
    static func catalogEntry_solva(for gameType: GameType_solva) -> GameCatalogEntry_solva {
        gameCatalog_solva.first(where: { $0.gameType_solva == gameType })!
    }

    /// 全部成就的静态定义列表，对应「个人游戏成就记录」功能需求
    /// 覆盖：通用里程碑成就 + 每款游戏的首胜/连胜/速通/零提示/高分/特殊玩法成就
    static let achievementDefinitions_solva: [AchievementDefinition_solva] = [
        // —— General milestones ——
        AchievementDefinition_solva(key_solva: "milestone_first_win", title_solva: "First Light", description_solva: "Win your first game in any solitaire.", iconName_solva: "star.fill", conditionType_solva: .totalWinsAcrossAll, relatedGame_solva: nil, target_solva: 1),
        AchievementDefinition_solva(key_solva: "milestone_wins_10", title_solva: "Regular at the Table", description_solva: "Reach 10 total wins across all games.", iconName_solva: "star.circle.fill", conditionType_solva: .totalWinsAcrossAll, relatedGame_solva: nil, target_solva: 10),
        AchievementDefinition_solva(key_solva: "milestone_wins_50", title_solva: "Card Room Legend", description_solva: "Reach 50 total wins across all games.", iconName_solva: "crown.fill", conditionType_solva: .totalWinsAcrossAll, relatedGame_solva: nil, target_solva: 50),
        AchievementDefinition_solva(key_solva: "milestone_played_100", title_solva: "Seasoned Veteran", description_solva: "Complete 100 games in total (wins or losses).", iconName_solva: "flag.checkered", conditionType_solva: .totalGamesPlayed, relatedGame_solva: nil, target_solva: 100),

        // —— Accordion ——
        AchievementDefinition_solva(key_solva: "accordion_first_win", title_solva: "Opening Chord", description_solva: "Win your first game of Accordion Solitaire.", iconName_solva: "pianokeys", conditionType_solva: .totalWinsForGame, relatedGame_solva: .accordion, target_solva: 1),
        AchievementDefinition_solva(key_solva: "accordion_streak_3", title_solva: "Harmonic Streak", description_solva: "Win 3 Accordion games in a row.", iconName_solva: "waveform", conditionType_solva: .winStreakForGame, relatedGame_solva: .accordion, target_solva: 3),
        AchievementDefinition_solva(key_solva: "accordion_compact", title_solva: "Ultimate Compression", description_solva: "Finish Accordion with 3 piles or fewer remaining.", iconName_solva: "arrow.down.right.and.arrow.up.left", conditionType_solva: .specialMilestone, relatedGame_solva: .accordion, target_solva: 3),

        // —— Penguin ——
        AchievementDefinition_solva(key_solva: "penguin_first_win", title_solva: "Icebreaker", description_solva: "Win your first game of Penguin Solitaire.", iconName_solva: "snowflake", conditionType_solva: .totalWinsForGame, relatedGame_solva: .penguin, target_solva: 1),
        AchievementDefinition_solva(key_solva: "penguin_no_hint", title_solva: "Polar Guide", description_solva: "Win a game of Penguin Solitaire without using any hints.", iconName_solva: "location.north.line.fill", conditionType_solva: .noHintWinForGame, relatedGame_solva: .penguin, target_solva: 1),
        AchievementDefinition_solva(key_solva: "penguin_fast", title_solva: "Swift Migration", description_solva: "Win a game of Penguin Solitaire in under 5 minutes.", iconName_solva: "hare.fill", conditionType_solva: .fastWinForGame, relatedGame_solva: .penguin, target_solva: 300),

        // —— Osmosis ——
        AchievementDefinition_solva(key_solva: "osmosis_first_win", title_solva: "First Permeation", description_solva: "Win your first game of Osmosis Solitaire.", iconName_solva: "drop.fill", conditionType_solva: .totalWinsForGame, relatedGame_solva: .osmosis, target_solva: 1),
        AchievementDefinition_solva(key_solva: "osmosis_high_score", title_solva: "Quantum Resonance", description_solva: "Score 800 points or more in a single Osmosis game.", iconName_solva: "atom", conditionType_solva: .scoreThresholdForGame, relatedGame_solva: .osmosis, target_solva: 800),

        // —— Double Pyramid ——
        AchievementDefinition_solva(key_solva: "pyramid_first_win", title_solva: "Pyramid Apprentice", description_solva: "Win your first game of Double Pyramid.", iconName_solva: "triangle.fill", conditionType_solva: .totalWinsForGame, relatedGame_solva: .doublePyramid, target_solva: 1),
        AchievementDefinition_solva(key_solva: "pyramid_perfect", title_solva: "Perfect Cascade", description_solva: "Clear both pyramids in a single game.", iconName_solva: "sparkles", conditionType_solva: .specialMilestone, relatedGame_solva: .doublePyramid, target_solva: 2),
        AchievementDefinition_solva(key_solva: "pyramid_streak_5", title_solva: "Master Calculator", description_solva: "Win 5 Double Pyramid games in a row.", iconName_solva: "function", conditionType_solva: .winStreakForGame, relatedGame_solva: .doublePyramid, target_solva: 5),

        // —— Four Seasons ——
        AchievementDefinition_solva(key_solva: "seasons_first_win", title_solva: "First Bloom", description_solva: "Win your first game of Four Seasons.", iconName_solva: "leaf.fill", conditionType_solva: .totalWinsForGame, relatedGame_solva: .fourSeasons, target_solva: 1),
        AchievementDefinition_solva(key_solva: "seasons_harmony", title_solva: "Wheel of Harmony", description_solva: "Complete 20 unbroken rotations in a single Four Seasons game.", iconName_solva: "arrow.triangle.2.circlepath", conditionType_solva: .specialMilestone, relatedGame_solva: .fourSeasons, target_solva: 20),
        AchievementDefinition_solva(key_solva: "seasons_fast", title_solva: "Swift as the Wind", description_solva: "Win a game of Four Seasons in under 6 minutes.", iconName_solva: "wind", conditionType_solva: .fastWinForGame, relatedGame_solva: .fourSeasons, target_solva: 360),
    ]
}
