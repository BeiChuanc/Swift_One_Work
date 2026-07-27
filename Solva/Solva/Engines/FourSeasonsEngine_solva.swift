//
//  FourSeasonsEngine_solva.swift
//  Solva
//
//  四季纸牌（Four Seasons，环形循环接龙）游戏引擎。
//  设计思路：春/夏/秋/冬四座牌墩环绕排列，行动权按「春→夏→秋→冬→春…」顺时针循环流转，
//  每回合只有当前「当值季节」可以出牌：可将自身顶牌送入对应花色基础堆，
//  也可将其接到顺时针下一季节牌墩的顶牌上（降序 + 颜色交替），
//  或使用共享的「太阳弃牌」（由中央太阳备用堆抽出）完成同样的操作；也可选择跳过本回合。
//  每完整走完一轮（4 个回合）且期间没有任何跳过，即达成一次「和谐轮回」并获得加成。
//  关键属性：seasonPiles_solva（四季牌墩）、activeSeason_solva（当值季节）、harmonyRotationsCompleted_solva
//  关键方法：tapActiveSeasonCard_solva/tapWasteCard_solva/tapFoundation_solva/tapNextSeasonPile_solva/skipTurn_solva/drawStock_solva
import Foundation
import Combine

/// 四季枚举，环形顺序 spring → summer → autumn → winter → spring…
enum Season_solva: Int, CaseIterable, Equatable {
    case spring = 0, summer, autumn, winter

    var next_solva: Season_solva { Season_solva(rawValue: (rawValue + 1) % 4)! }

    var displayName_solva: String {
        switch self {
        case .spring: return "Spring"
        case .summer: return "Summer"
        case .autumn: return "Autumn"
        case .winter: return "Winter"
        }
    }

    var themeColor_solva: (Double, Double, Double) {
        switch self {
        case .spring: return (0.45, 0.80, 0.45)
        case .summer: return (0.98, 0.78, 0.25)
        case .autumn: return (0.90, 0.50, 0.20)
        case .winter: return (0.45, 0.75, 0.95)
        }
    }
}

/// 当前选中的卡牌来源：某季节牌墩顶牌，或太阳弃牌
enum FourSeasonsSelection_solva: Equatable {
    case season(Season_solva)
    case waste
}

final class FourSeasonsEngine_solva: GameEngineBase_solva {

    @Published var seasonPiles_solva: [Season_solva: [Card_solva]] = [:]
    @Published var foundations_solva: [Suit_solva: [Card_solva]] = [:]
    @Published var solarWaste_solva: Card_solva? = nil
    @Published var sunStock_solva: [Card_solva] = []
    @Published var activeSeason_solva: Season_solva = .spring
    @Published var selection_solva: FourSeasonsSelection_solva? = nil
    @Published var harmonyRotationsCompleted_solva: Int = 0
    @Published var hintKind_solva: String? = nil

    private var skipsInCurrentRotation_solva = 0
    private var turnsInCurrentRotation_solva = 0

    private var history_solva: [(piles: [Season_solva: [Card_solva]], foundations: [Suit_solva: [Card_solva]], waste: Card_solva?, stock: [Card_solva], active: Season_solva, harmony: Int, skips: Int, turns: Int, score: Int, moves: Int)] = []

    init() {
        super.init(gameType_solva: .fourSeasons)
        newGame_solva()
    }

    // MARK: 开局

    func newGame_solva() {
        var deck_solva = DeckFactory_solva.shuffledDeck_solva()
        var piles_solva: [Season_solva: [Card_solva]] = [:]
        for season_solva in Season_solva.allCases {
            var pile_solva: [Card_solva] = []
            for i_solva in 0..<12 {
                var card_solva = deck_solva.removeFirst()
                card_solva.isFaceUp_solva = (i_solva == 11)
                pile_solva.append(card_solva)
            }
            piles_solva[season_solva] = pile_solva
        }
        seasonPiles_solva = piles_solva
        sunStock_solva = deck_solva.map { card_solva in
            var c_solva = card_solva
            c_solva.isFaceUp_solva = false
            return c_solva
        }
        solarWaste_solva = nil
        foundations_solva = Dictionary(uniqueKeysWithValues: Suit_solva.allCases.map { ($0, []) })
        activeSeason_solva = .spring
        selection_solva = nil
        harmonyRotationsCompleted_solva = 0
        skipsInCurrentRotation_solva = 0
        turnsInCurrentRotation_solva = 0
        hintKind_solva = nil
        history_solva.removeAll()
        resetCommonState_solva()
    }

    // MARK: 交互

    func tapActiveSeasonCard_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        guard let top_solva = seasonPiles_solva[activeSeason_solva]?.last, top_solva.isFaceUp_solva else { return }
        hintKind_solva = nil
        selection_solva = (selection_solva == .season(activeSeason_solva)) ? nil : .season(activeSeason_solva)
    }

    func tapWasteCard_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false, solarWaste_solva != nil else { return }
        hintKind_solva = nil
        selection_solva = (selection_solva == .waste) ? nil : .waste
    }

    func tapFoundation_solva(_ suit_solva: Suit_solva) {
        guard let selection_solva else { return }
        attemptSendToFoundation_solva(selection_solva, suit: suit_solva)
    }

    /// 目标固定为「当值季节顺时针下一位」的牌墩
    func tapNextSeasonPile_solva() {
        guard let selection_solva else { return }
        attemptMoveToNextSeason_solva(selection_solva)
    }

    func skipTurn_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        selection_solva = nil
        pushHistory_solva()
        advanceTurn_solva(wasSkip: true)
        evaluateGameEnd_solva()
    }

    func drawStock_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        guard solarWaste_solva == nil, sunStock_solva.isEmpty == false else { return }
        pushHistory_solva()
        var card_solva = sunStock_solva.removeFirst()
        card_solva.isFaceUp_solva = true
        solarWaste_solva = card_solva
        moveCount_solva += 1
        advanceTurn_solva(wasSkip: false)
        evaluateGameEnd_solva()
    }

    // MARK: 执行移动

    private func attemptSendToFoundation_solva(_ selection: FourSeasonsSelection_solva, suit: Suit_solva) {
        defer { self.selection_solva = nil }
        switch selection {
        case .season(let season_solva):
            guard season_solva == activeSeason_solva, let card_solva = seasonPiles_solva[season_solva]?.last else { return }
            guard card_solva.suit_solva == suit, isNextForFoundation_solva(card_solva) else { return }
            pushHistory_solva()
            seasonPiles_solva[season_solva]?.removeLast()
            foundations_solva[suit, default: []].append(card_solva)
            flipNewTop_solva(season_solva)
            awardEmptyBonusIfNeeded_solva(season_solva)
            score_solva += 15
            moveCount_solva += 1
            advanceTurn_solva(wasSkip: false)
            evaluateGameEnd_solva()
        case .waste:
            guard let card_solva = solarWaste_solva, card_solva.suit_solva == suit, isNextForFoundation_solva(card_solva) else { return }
            pushHistory_solva()
            solarWaste_solva = nil
            foundations_solva[suit, default: []].append(card_solva)
            score_solva += 15
            moveCount_solva += 1
            advanceTurn_solva(wasSkip: false)
            evaluateGameEnd_solva()
        }
    }

    private func attemptMoveToNextSeason_solva(_ selection: FourSeasonsSelection_solva) {
        defer { self.selection_solva = nil }
        let nextSeason_solva = activeSeason_solva.next_solva
        let targetTop_solva = seasonPiles_solva[nextSeason_solva]?.last

        switch selection {
        case .season(let season_solva):
            guard season_solva == activeSeason_solva, let card_solva = seasonPiles_solva[season_solva]?.last else { return }
            guard isValidRingPlacement_solva(card_solva, onto: targetTop_solva) else { return }
            pushHistory_solva()
            seasonPiles_solva[season_solva]?.removeLast()
            seasonPiles_solva[nextSeason_solva, default: []].append(card_solva)
            flipNewTop_solva(season_solva)
            awardEmptyBonusIfNeeded_solva(season_solva)
            score_solva += 8
            moveCount_solva += 1
            advanceTurn_solva(wasSkip: false)
            evaluateGameEnd_solva()
        case .waste:
            guard let card_solva = solarWaste_solva else { return }
            guard isValidRingPlacement_solva(card_solva, onto: targetTop_solva) else { return }
            pushHistory_solva()
            solarWaste_solva = nil
            seasonPiles_solva[nextSeason_solva, default: []].append(card_solva)
            score_solva += 8
            moveCount_solva += 1
            advanceTurn_solva(wasSkip: false)
            evaluateGameEnd_solva()
        }
    }

    private func isNextForFoundation_solva(_ card_solva: Card_solva) -> Bool {
        card_solva.rank_solva.rawValue == (foundations_solva[card_solva.suit_solva]?.count ?? 0) + 1
    }

    private func isValidRingPlacement_solva(_ card_solva: Card_solva, onto targetTop_solva: Card_solva?) -> Bool {
        guard let targetTop_solva else { return true }
        return card_solva.rank_solva.rawValue == targetTop_solva.rank_solva.rawValue - 1 && card_solva.isOppositeColor_solva(of: targetTop_solva)
    }

    private func flipNewTop_solva(_ season_solva: Season_solva) {
        guard var pile_solva = seasonPiles_solva[season_solva], let lastIndex_solva = pile_solva.indices.last, pile_solva[lastIndex_solva].isFaceUp_solva == false else { return }
        pile_solva[lastIndex_solva].isFaceUp_solva = true
        seasonPiles_solva[season_solva] = pile_solva
    }

    private func awardEmptyBonusIfNeeded_solva(_ season_solva: Season_solva) {
        if seasonPiles_solva[season_solva]?.isEmpty ?? false {
            score_solva += 30
        }
    }

    /// 每次行动后调用：推进当值季节，并结算「和谐轮回」
    private func advanceTurn_solva(wasSkip: Bool) {
        if wasSkip { skipsInCurrentRotation_solva += 1 }
        turnsInCurrentRotation_solva += 1
        activeSeason_solva = activeSeason_solva.next_solva
        if turnsInCurrentRotation_solva >= AppConfig_solva.seasonsCycleLength_solva {
            if skipsInCurrentRotation_solva == 0 {
                harmonyRotationsCompleted_solva += 1
                score_solva += 40
            }
            turnsInCurrentRotation_solva = 0
            skipsInCurrentRotation_solva = 0
        }
    }

    // MARK: 提示 / 撤销 / 结束判定

    func requestHint_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        if let top_solva = seasonPiles_solva[activeSeason_solva]?.last, top_solva.isFaceUp_solva {
            if isNextForFoundation_solva(top_solva) {
                hintKind_solva = "season"
                hintMessage_solva = "\(activeSeason_solva.displayName_solva)'s \(top_solva.rank_solva.label_solva)\(top_solva.suit_solva.symbol_solva) can go straight to its foundation."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
            if isValidRingPlacement_solva(top_solva, onto: seasonPiles_solva[activeSeason_solva.next_solva]?.last) {
                hintKind_solva = "season"
                hintMessage_solva = "Send \(activeSeason_solva.displayName_solva)'s top card onto \(activeSeason_solva.next_solva.displayName_solva)."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
        }
        if let wasteCard_solva = solarWaste_solva {
            if isNextForFoundation_solva(wasteCard_solva) {
                hintKind_solva = "waste"
                hintMessage_solva = "The Solar Waste card can go straight to its foundation."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
            if isValidRingPlacement_solva(wasteCard_solva, onto: seasonPiles_solva[activeSeason_solva.next_solva]?.last) {
                hintKind_solva = "waste"
                hintMessage_solva = "Send the Solar Waste card onto \(activeSeason_solva.next_solva.displayName_solva)."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
        }
        if solarWaste_solva == nil, sunStock_solva.isEmpty == false {
            hintMessage_solva = "No move for \(activeSeason_solva.displayName_solva) right now — draw from the Sun Stock."
        } else {
            hintMessage_solva = "No move available — you may need to skip this turn."
        }
        scheduleHintClear_solva()
    }

    private func scheduleHintClear_solva() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            self?.hintKind_solva = nil
            self?.hintMessage_solva = nil
        }
    }

    func undo_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false, let last_solva = history_solva.popLast() else { return }
        seasonPiles_solva = last_solva.piles
        foundations_solva = last_solva.foundations
        solarWaste_solva = last_solva.waste
        sunStock_solva = last_solva.stock
        activeSeason_solva = last_solva.active
        harmonyRotationsCompleted_solva = last_solva.harmony
        skipsInCurrentRotation_solva = last_solva.skips
        turnsInCurrentRotation_solva = last_solva.turns
        score_solva = last_solva.score
        moveCount_solva = last_solva.moves
        selection_solva = nil
    }

    private func pushHistory_solva() {
        history_solva.append((piles: seasonPiles_solva, foundations: foundations_solva, waste: solarWaste_solva, stock: sunStock_solva, active: activeSeason_solva, harmony: harmonyRotationsCompleted_solva, skips: skipsInCurrentRotation_solva, turns: turnsInCurrentRotation_solva, score: score_solva, moves: moveCount_solva))
        if history_solva.count > 100 { history_solva.removeFirst() }
    }

    /// 忽略「当值季节」限制，判断棋盘上是否仍存在任何可能的行动（用于死局判定）
    private func hasAnyMoveAnywhere_solva() -> Bool {
        if sunStock_solva.isEmpty == false && solarWaste_solva == nil { return true }
        for season_solva in Season_solva.allCases {
            guard let top_solva = seasonPiles_solva[season_solva]?.last, top_solva.isFaceUp_solva else { continue }
            if isNextForFoundation_solva(top_solva) { return true }
            if isValidRingPlacement_solva(top_solva, onto: seasonPiles_solva[season_solva.next_solva]?.last) { return true }
        }
        if let wasteCard_solva = solarWaste_solva {
            if isNextForFoundation_solva(wasteCard_solva) { return true }
            for season_solva in Season_solva.allCases where isValidRingPlacement_solva(wasteCard_solva, onto: seasonPiles_solva[season_solva.next_solva]?.last) {
                return true
            }
        }
        return false
    }

    private func evaluateGameEnd_solva() {
        let total_solva = foundations_solva.values.reduce(0) { $0 + $1.count }
        if total_solva == 52 {
            score_solva += 600
            finishGame_solva(outcome_solva: .won)
            return
        }
        if hasAnyMoveAnywhere_solva() == false {
            finishGame_solva(outcome_solva: .lost)
        }
    }

    override func specialMetricForFinish_solva() -> Int? {
        harmonyRotationsCompleted_solva
    }
}
