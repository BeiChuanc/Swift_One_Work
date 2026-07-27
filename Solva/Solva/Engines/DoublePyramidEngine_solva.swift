//
//  DoublePyramidEngine_solva.swift
//  Solva
//
//  双金字塔纸牌（Double Pyramid，金字塔 13 进阶变体）游戏引擎。
//  设计思路：使用两副牌（104 张）搭出两座独立的 7 层金字塔（各 28 张，共 56 张），
//  剩余 48 张作为共用备用堆，逐张翻入弃牌堆。任意两张「未被遮挡」的明牌
//  （可来自同一金字塔，也可跨两座金字塔，或与弃牌堆顶牌组合）只要点数之和为 13 即可成对消除，
//  K 可单独消除。新颖进阶点：允许跨金字塔配对，双塔同时清空可触发「完美连锁」大额加分。
//  关键属性：pyramids_solva（两座金字塔，nil 代表已消除）、stock_solva/waste_solva（备用堆/弃牌堆）
//  关键方法：tapPyramidCard_solva/tapWaste_solva（选牌与配对）、drawStock_solva（抽牌/重发）
import Foundation
import Combine

/// 卡牌在双金字塔棋盘上的位置引用
enum PyramidCardLocation_solva: Equatable {
    case pyramid(Int, Int, Int) // pyramidIndex, row, col
    case waste
}

final class DoublePyramidEngine_solva: GameEngineBase_solva {

    /// 两座金字塔，行数 0~6，行 r 有 r+1 个槛位，nil 表示该位置牌已被消除
    @Published var pyramids_solva: [[[Card_solva?]]] = []
    @Published var stock_solva: [Card_solva] = []
    @Published var waste_solva: [Card_solva] = []
    @Published var redealsRemaining_solva: Int = 2
    @Published var selection_solva: PyramidCardLocation_solva? = nil
    @Published var clearedPyramidIndices_solva: Set<Int> = []
    @Published var hintLocations_solva: [PyramidCardLocation_solva] = []

    private let maxRedeals_solva = 2
    private var history_solva: [(pyramids: [[[Card_solva?]]], stock: [Card_solva], waste: [Card_solva], redeals: Int, cleared: Set<Int>, score: Int, moves: Int)] = []

    init() {
        super.init(gameType_solva: .doublePyramid)
        newGame_solva()
    }

    // MARK: 开局

    func newGame_solva() {
        var deck_solva = DeckFactory_solva.shuffledDoubleDeck_solva()
        var pyr_solva: [[[Card_solva?]]] = []
        for _ in 0..<2 {
            var rows_solva: [[Card_solva?]] = []
            for r_solva in 0..<7 {
                var row_solva: [Card_solva?] = []
                for _ in 0...r_solva {
                    var card_solva = deck_solva.removeFirst()
                    card_solva.isFaceUp_solva = true
                    row_solva.append(card_solva)
                }
                rows_solva.append(row_solva)
            }
            pyr_solva.append(rows_solva)
        }
        pyramids_solva = pyr_solva
        stock_solva = deck_solva.map { card_solva in
            var c_solva = card_solva
            c_solva.isFaceUp_solva = false
            return c_solva
        }
        waste_solva = []
        redealsRemaining_solva = maxRedeals_solva
        selection_solva = nil
        clearedPyramidIndices_solva = []
        hintLocations_solva = []
        history_solva.removeAll()
        resetCommonState_solva()
    }

    // MARK: 暴露判定

    /// 某金字塔位置是否「未被遮挡」（其下方两张牌均已消除，或已在最底行）
    func isExposed_solva(_ p_solva: Int, _ r_solva: Int, _ c_solva: Int) -> Bool {
        guard pyramids_solva[p_solva][r_solva][c_solva] != nil else { return false }
        if r_solva == 6 { return true }
        let belowLeft_solva = pyramids_solva[p_solva][r_solva + 1][c_solva]
        let belowRight_solva = pyramids_solva[p_solva][r_solva + 1][c_solva + 1]
        return belowLeft_solva == nil && belowRight_solva == nil
    }

    private func card_solva(at location_solva: PyramidCardLocation_solva) -> Card_solva? {
        switch location_solva {
        case .pyramid(let p_solva, let r_solva, let c_solva): return pyramids_solva[p_solva][r_solva][c_solva]
        case .waste: return waste_solva.last
        }
    }

    private func removeCard_solva(at location_solva: PyramidCardLocation_solva) {
        switch location_solva {
        case .pyramid(let p_solva, let r_solva, let c_solva):
            pyramids_solva[p_solva][r_solva][c_solva] = nil
            checkPyramidCleared_solva(p_solva)
        case .waste:
            if waste_solva.isEmpty == false { waste_solva.removeLast() }
        }
    }

    private func checkPyramidCleared_solva(_ p_solva: Int) {
        let cleared_solva = pyramids_solva[p_solva].allSatisfy { row_solva in row_solva.allSatisfy { $0 == nil } }
        if cleared_solva, clearedPyramidIndices_solva.contains(p_solva) == false {
            clearedPyramidIndices_solva.insert(p_solva)
            score_solva += 150
        }
    }

    // MARK: 交互

    func tapPyramidCard_solva(_ p_solva: Int, _ r_solva: Int, _ c_solva: Int) {
        guard isExposed_solva(p_solva, r_solva, c_solva), let card_solva = pyramids_solva[p_solva][r_solva][c_solva] else { return }
        handleTap_solva(location: .pyramid(p_solva, r_solva, c_solva), card: card_solva)
    }

    func tapWaste_solva() {
        guard let card_solva = waste_solva.last else { return }
        handleTap_solva(location: .waste, card: card_solva)
    }

    private func handleTap_solva(location: PyramidCardLocation_solva, card: Card_solva) {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        hintLocations_solva = []

        if card.rank_solva == .king {
            pushHistory_solva()
            removeCard_solva(at: location)
            score_solva += 26
            moveCount_solva += 1
            selection_solva = nil
            evaluateGameEnd_solva()
            return
        }

        if let selected_solva = selection_solva {
            if selected_solva == location {
                selection_solva = nil
                return
            }
            guard let selectedCard_solva = card_solva(at: selected_solva) else { selection_solva = location; return }
            if selectedCard_solva.rank_solva.pyramidValue_solva + card.rank_solva.pyramidValue_solva == 13 {
                pushHistory_solva()
                removeCard_solva(at: selected_solva)
                removeCard_solva(at: location)
                score_solva += 26
                moveCount_solva += 1
                selection_solva = nil
                evaluateGameEnd_solva()
            } else {
                selection_solva = location
            }
        } else {
            selection_solva = location
        }
    }

    /// 抽牌：从备用堆翻出一张到弃牌堆；备用堆耗尽且仍有重发次数时执行重发
    func drawStock_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        if stock_solva.isEmpty == false {
            var card_solva = stock_solva.removeFirst()
            card_solva.isFaceUp_solva = true
            waste_solva.append(card_solva)
            moveCount_solva += 1
        } else if redealsRemaining_solva > 0 {
            stock_solva = waste_solva.reversed().map { card_solva in
                var c_solva = card_solva
                c_solva.isFaceUp_solva = false
                return c_solva
            }
            waste_solva = []
            redealsRemaining_solva -= 1
        }
        evaluateGameEnd_solva()
    }

    // MARK: 提示 / 撤销 / 结束判定

    /// 当前所有可操作（未被遮挡）的位置
    private func exposedLocations_solva() -> [PyramidCardLocation_solva] {
        var result_solva: [PyramidCardLocation_solva] = []
        for p_solva in 0..<pyramids_solva.count {
            for r_solva in 0..<pyramids_solva[p_solva].count {
                for c_solva in 0..<pyramids_solva[p_solva][r_solva].count where isExposed_solva(p_solva, r_solva, c_solva) {
                    result_solva.append(.pyramid(p_solva, r_solva, c_solva))
                }
            }
        }
        if waste_solva.isEmpty == false { result_solva.append(.waste) }
        return result_solva
    }

    func requestHint_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        let locations_solva = exposedLocations_solva()
        for loc_solva in locations_solva {
            if card_solva(at: loc_solva)?.rank_solva == .king {
                hintLocations_solva = [loc_solva]
                hintMessage_solva = "Remove the lone King — it always equals 13."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
        }
        for i_solva in 0..<locations_solva.count {
            for j_solva in (i_solva + 1)..<locations_solva.count {
                guard let a_solva = card_solva(at: locations_solva[i_solva]), let b_solva = card_solva(at: locations_solva[j_solva]) else { continue }
                if a_solva.rank_solva.pyramidValue_solva + b_solva.rank_solva.pyramidValue_solva == 13 {
                    hintLocations_solva = [locations_solva[i_solva], locations_solva[j_solva]]
                    hintMessage_solva = "Pair the \(a_solva.rank_solva.label_solva)\(a_solva.suit_solva.symbol_solva) with the \(b_solva.rank_solva.label_solva)\(b_solva.suit_solva.symbol_solva) — sums to 13."
                    usedHintCount_solva += 1
                    scheduleHintClear_solva()
                    return
                }
            }
        }
        hintMessage_solva = stock_solva.isEmpty && redealsRemaining_solva == 0
            ? "No more moves available."
            : "No pair right now — draw a new card from the stock."
        scheduleHintClear_solva()
    }

    private func scheduleHintClear_solva() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            self?.hintLocations_solva = []
            self?.hintMessage_solva = nil
        }
    }

    func undo_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false, let last_solva = history_solva.popLast() else { return }
        pyramids_solva = last_solva.pyramids
        stock_solva = last_solva.stock
        waste_solva = last_solva.waste
        redealsRemaining_solva = last_solva.redeals
        clearedPyramidIndices_solva = last_solva.cleared
        score_solva = last_solva.score
        moveCount_solva = last_solva.moves
        selection_solva = nil
    }

    private func pushHistory_solva() {
        history_solva.append((pyramids: pyramids_solva, stock: stock_solva, waste: waste_solva, redeals: redealsRemaining_solva, cleared: clearedPyramidIndices_solva, score: score_solva, moves: moveCount_solva))
        if history_solva.count > 100 { history_solva.removeFirst() }
    }

    private func hasAnyValidMove_solva() -> Bool {
        let locations_solva = exposedLocations_solva()
        for loc_solva in locations_solva where card_solva(at: loc_solva)?.rank_solva == .king { return true }
        for i_solva in 0..<locations_solva.count {
            for j_solva in (i_solva + 1)..<locations_solva.count {
                guard let a_solva = card_solva(at: locations_solva[i_solva]), let b_solva = card_solva(at: locations_solva[j_solva]) else { continue }
                if a_solva.rank_solva.pyramidValue_solva + b_solva.rank_solva.pyramidValue_solva == 13 { return true }
            }
        }
        return false
    }

    private func evaluateGameEnd_solva() {
        if clearedPyramidIndices_solva.count == 2 {
            score_solva += 800
            finishGame_solva(outcome_solva: .won)
            return
        }
        if hasAnyValidMove_solva() { return }
        if stock_solva.isEmpty == false || redealsRemaining_solva > 0 { return }
        finishGame_solva(outcome_solva: .lost)
    }

    override func specialMetricForFinish_solva() -> Int? {
        clearedPyramidIndices_solva.count
    }
}
