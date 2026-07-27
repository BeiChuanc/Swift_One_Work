//
//  PenguinEngine_solva.swift
//  Solva
//
//  企鹅纸牌（Penguin Solitaire）游戏引擎。
//  设计思路：取出一张「冰核牌」决定 4 个基础堆的起始点数（循环制：K 之后回到 A），
//  其余 51 张按 Yukon 式规则发入 8 个牌墩（每墩由若干暗牌 + 一段明牌构成）。
//  牌墩内可整组移动任意一张明牌及其上方所有明牌（无需自身构成顺子），
//  落点需比目标顶牌点数小 1 且颜色相反；空列可接受任意牌组。
//  新颖补充玩法「极地迁徙」：每当清空一整列牌墩即获得 1 个迁徙点，
//  可消耗迁徙点提前查看（翻开）某列即将暴露的下一张暗牌，用于策略性规划。
//  关键属性：columns_solva（8 个牌墩）、foundations_solva（4 组基础堆）、migrationPoints_solva
//  关键方法：selectCard_solva/tapColumnArea_solva/tapFoundation_solva（点选交互）、
//           peekNextHiddenCard_solva（消耗迁徙点查看暗牌）
import Foundation
import Combine

final class PenguinEngine_solva: GameEngineBase_solva {

    /// 冰核牌决定的起始点数
    private(set) var baseRank_solva: Rank_solva = .ace
    private(set) var baseSuit_solva: Suit_solva = .spades

    /// 8 个牌墩
    @Published var columns_solva: [[Card_solva]] = []
    /// 4 组基础堆，key 为花色
    @Published var foundations_solva: [Suit_solva: [Card_solva]] = [:]
    /// 当前选中的位置（列索引 + 组起始下标）
    @Published var selection_solva: (column: Int, index: Int)? = nil
    /// 极地迁徙点数
    @Published var migrationPoints_solva: Int = 0
    /// 提示高亮
    @Published var hintFrom_solva: (column: Int, index: Int)? = nil
    @Published var hintToColumn_solva: Int? = nil
    @Published var hintToSuit_solva: Suit_solva? = nil

    private var history_solva: [(columns: [[Card_solva]], foundations: [Suit_solva: [Card_solva]], score: Int, moves: Int, migration: Int)] = []

    init() {
        super.init(gameType_solva: .penguin)
        newGame_solva()
    }

    // MARK: 开局

    func newGame_solva() {
        var deck_solva = DeckFactory_solva.shuffledDeck_solva()
        var base_solva = deck_solva.removeFirst()
        base_solva.isFaceUp_solva = true
        baseRank_solva = base_solva.rank_solva
        baseSuit_solva = base_solva.suit_solva

        foundations_solva = [:]
        for suit_solva in Suit_solva.allCases {
            foundations_solva[suit_solva] = suit_solva == baseSuit_solva ? [base_solva] : []
        }

        var cols_solva: [[Card_solva]] = Array(repeating: [], count: 8)
        for colIndex_solva in 0..<8 {
            for _ in 0..<colIndex_solva {
                var card_solva = deck_solva.removeFirst()
                card_solva.isFaceUp_solva = false
                cols_solva[colIndex_solva].append(card_solva)
            }
        }
        var round_solva = 0
        while deck_solva.isEmpty == false {
            let colIndex_solva = round_solva % 8
            var card_solva = deck_solva.removeFirst()
            card_solva.isFaceUp_solva = true
            cols_solva[colIndex_solva].append(card_solva)
            round_solva += 1
        }
        columns_solva = cols_solva

        selection_solva = nil
        migrationPoints_solva = 0
        hintFrom_solva = nil
        hintToColumn_solva = nil
        hintToSuit_solva = nil
        history_solva.removeAll()
        resetCommonState_solva()
    }

    /// 指定花色当前所需的下一个点数（循环制）
    func requiredRank_solva(for suit_solva: Suit_solva) -> Rank_solva {
        let count_solva = foundations_solva[suit_solva]?.count ?? 0
        var rank_solva = baseRank_solva
        for _ in 0..<count_solva { rank_solva = rank_solva.cyclicNext_solva }
        return rank_solva
    }

    // MARK: 交互

    /// 点选牌墩中的某张明牌，作为移动组的起点
    func selectCard_solva(column: Int, index: Int) {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        guard columns_solva[column].indices.contains(index), columns_solva[column][index].isFaceUp_solva else { return }
        clearHint_solva()
        if let sel_solva = selection_solva {
            if sel_solva.column == column {
                selection_solva = sel_solva.index == index ? nil : (column, index)
            } else {
                attemptMove_solva(fromColumn: sel_solva.column, fromIndex: sel_solva.index, toColumn: column)
            }
        } else {
            selection_solva = (column, index)
        }
    }

    /// 点击某一列的空白/空列区域作为落点
    func tapColumnArea_solva(_ column: Int) {
        guard let sel_solva = selection_solva else { return }
        if sel_solva.column == column {
            selection_solva = nil
        } else {
            attemptMove_solva(fromColumn: sel_solva.column, fromIndex: sel_solva.index, toColumn: column)
        }
    }

    /// 点击某一基础堆作为落点
    func tapFoundation_solva(_ suit_solva: Suit_solva) {
        guard let sel_solva = selection_solva else { return }
        attemptSendToFoundation_solva(column: sel_solva.column, index: sel_solva.index, suit: suit_solva)
        selection_solva = nil
    }

    private func clearHint_solva() {
        hintFrom_solva = nil
        hintToColumn_solva = nil
        hintToSuit_solva = nil
    }

    // MARK: 移动执行

    private func attemptMove_solva(fromColumn: Int, fromIndex: Int, toColumn: Int) {
        defer { selection_solva = nil }
        guard fromColumn != toColumn else { return }
        let movingGroup_solva = Array(columns_solva[fromColumn][fromIndex...])
        guard let bottomCard_solva = movingGroup_solva.first else { return }
        let targetTop_solva = columns_solva[toColumn].last

        let isValid_solva: Bool
        if let targetTop_solva {
            isValid_solva = bottomCard_solva.rank_solva.rawValue == targetTop_solva.rank_solva.rawValue - 1 && bottomCard_solva.isOppositeColor_solva(of: targetTop_solva)
        } else {
            isValid_solva = true
        }
        guard isValid_solva else { return }

        pushHistory_solva()
        columns_solva[fromColumn].removeSubrange(fromIndex...)
        columns_solva[toColumn].append(contentsOf: movingGroup_solva)
        moveCount_solva += 1
        score_solva += 5 + movingGroup_solva.count

        flipNewTopIfNeeded_solva(column: fromColumn)
        if columns_solva[fromColumn].isEmpty {
            migrationPoints_solva += 1
            score_solva += 25
        }
        evaluateGameEnd_solva()
    }

    private func attemptSendToFoundation_solva(column: Int, index: Int, suit: Suit_solva) {
        guard columns_solva[column].indices.contains(index), index == columns_solva[column].count - 1 else { return }
        let card_solva = columns_solva[column][index]
        guard card_solva.suit_solva == suit, card_solva.rank_solva == requiredRank_solva(for: suit) else { return }

        pushHistory_solva()
        columns_solva[column].removeLast()
        foundations_solva[suit, default: []].append(card_solva)
        moveCount_solva += 1
        score_solva += 15

        flipNewTopIfNeeded_solva(column: column)
        if columns_solva[column].isEmpty {
            migrationPoints_solva += 1
            score_solva += 25
        }
        evaluateGameEnd_solva()
    }

    /// 若某列顶牌因移出而暴露出下方暗牌，自动将其翻为明牌
    private func flipNewTopIfNeeded_solva(column: Int) {
        guard let last_solva = columns_solva[column].indices.last, columns_solva[column][last_solva].isFaceUp_solva == false else { return }
        columns_solva[column][last_solva].isFaceUp_solva = true
    }

    // MARK: 极地迁徙：查看暗牌

    /// 消耗 1 个迁徙点，提前翻开指定列即将暴露的下一张暗牌（不移动，只是查看）
    func peekNextHiddenCard_solva(column: Int) {
        guard migrationPoints_solva > 0 else { return }
        guard let index_solva = columns_solva[column].lastIndex(where: { $0.isFaceUp_solva == false }) else { return }
        pushHistory_solva()
        columns_solva[column][index_solva].isFaceUp_solva = true
        migrationPoints_solva -= 1
    }

    // MARK: 提示 / 撤销 / 结束判定

    func requestHint_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        for (colIndex_solva, column_solva) in columns_solva.enumerated() {
            guard let topIndex_solva = column_solva.indices.last, column_solva[topIndex_solva].isFaceUp_solva else { continue }
            let topCard_solva = column_solva[topIndex_solva]
            if topCard_solva.rank_solva == requiredRank_solva(for: topCard_solva.suit_solva) {
                hintFrom_solva = (colIndex_solva, topIndex_solva)
                hintToSuit_solva = topCard_solva.suit_solva
                hintMessage_solva = "Send the \(topCard_solva.rank_solva.label_solva)\(topCard_solva.suit_solva.symbol_solva) to its foundation."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
        }
        for (fromIndex_solva, fromColumn_solva) in columns_solva.enumerated() {
            for startIndex_solva in fromColumn_solva.indices where fromColumn_solva[startIndex_solva].isFaceUp_solva {
                let bottomCard_solva = fromColumn_solva[startIndex_solva]
                for (toIndex_solva, toColumn_solva) in columns_solva.enumerated() where toIndex_solva != fromIndex_solva {
                    if let targetTop_solva = toColumn_solva.last {
                        if bottomCard_solva.rank_solva.rawValue == targetTop_solva.rank_solva.rawValue - 1 && bottomCard_solva.isOppositeColor_solva(of: targetTop_solva) {
                            hintFrom_solva = (fromIndex_solva, startIndex_solva)
                            hintToColumn_solva = toIndex_solva
                            hintMessage_solva = "Move the \(bottomCard_solva.rank_solva.label_solva)\(bottomCard_solva.suit_solva.symbol_solva) group onto column \(toIndex_solva + 1)."
                            usedHintCount_solva += 1
                            scheduleHintClear_solva()
                            return
                        }
                    } else {
                        // 注意：目标列为空时，attemptMove_solva 允许移动「任意起点」的牌组落入
                        // （并非只能整列移动），此处提示逻辑需与实际移动校验保持一致，
                        // 否则会出现「明明还有合法走法，却提示/判定为无路可走」的问题。
                        hintFrom_solva = (fromIndex_solva, startIndex_solva)
                        hintToColumn_solva = toIndex_solva
                        hintMessage_solva = startIndex_solva == 0
                            ? "Move the entire column \(fromIndex_solva + 1) into the empty column \(toIndex_solva + 1)."
                            : "Move the \(bottomCard_solva.rank_solva.label_solva)\(bottomCard_solva.suit_solva.symbol_solva) group into the empty column \(toIndex_solva + 1)."
                        usedHintCount_solva += 1
                        scheduleHintClear_solva()
                        return
                    }
                }
            }
        }
        hintMessage_solva = "No moves available right now."
        scheduleHintClear_solva()
    }

    private func scheduleHintClear_solva() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            self?.clearHint_solva()
            self?.hintMessage_solva = nil
        }
    }

    func undo_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false, let last_solva = history_solva.popLast() else { return }
        columns_solva = last_solva.columns
        foundations_solva = last_solva.foundations
        score_solva = last_solva.score
        moveCount_solva = last_solva.moves
        migrationPoints_solva = last_solva.migration
        selection_solva = nil
    }

    private func pushHistory_solva() {
        history_solva.append((columns: columns_solva, foundations: foundations_solva, score: score_solva, moves: moveCount_solva, migration: migrationPoints_solva))
        if history_solva.count > 80 { history_solva.removeFirst() }
    }

    private func hasAnyValidMove_solva() -> Bool {
        for column_solva in columns_solva {
            if let top_solva = column_solva.last, top_solva.isFaceUp_solva, top_solva.rank_solva == requiredRank_solva(for: top_solva.suit_solva) {
                return true
            }
        }
        for (fromIndex_solva, fromColumn_solva) in columns_solva.enumerated() {
            for startIndex_solva in fromColumn_solva.indices where fromColumn_solva[startIndex_solva].isFaceUp_solva {
                let bottomCard_solva = fromColumn_solva[startIndex_solva]
                for (toIndex_solva, toColumn_solva) in columns_solva.enumerated() where toIndex_solva != fromIndex_solva {
                    if let targetTop_solva = toColumn_solva.last {
                        if bottomCard_solva.rank_solva.rawValue == targetTop_solva.rank_solva.rawValue - 1 && bottomCard_solva.isOppositeColor_solva(of: targetTop_solva) {
                            return true
                        }
                    } else {
                        // 与 attemptMove_solva 的校验保持一致：目标列为空时任意起点的牌组都可落入，
                        // 不应仅统计「整列移动」，否则会导致存在合法走法时误判为死局。
                        return true
                    }
                }
            }
        }
        return false
    }

    private func evaluateGameEnd_solva() {
        let totalFoundationCards_solva = foundations_solva.values.reduce(0) { $0 + $1.count }
        if totalFoundationCards_solva == 52 {
            score_solva += 500
            finishGame_solva(outcome_solva: .won)
            return
        }
        if hasAnyValidMove_solva() == false {
            finishGame_solva(outcome_solva: .lost)
        }
    }
}
