//
//  OsmosisEngine_solva.swift
//  Solva
//
//  渗透纸牌（Osmosis Solitaire）游戏引擎。
//  设计思路：取出 1 张牌作为基准基础堆 A 的起始牌（该花色的基础堆按点数循环顺序建墩），
//  其余 51 张均分入 4 组暗牌储备堆（仅顶牌可见）。另外 3 组基础堆（B/C/D，对应其余花色）
//  不要求顺序，只要基准堆 A 中已经出现过对应点数，任意时刻都可以把该点数的牌放入其所属花色的基础堆
//  ——如同点数从 A 向外「渗透」。
//  新颖补充玩法「量子穿透」：提供 1 个暂存位，可临时收纳某储备堆顶牌以解锁其下方的牌，
//  待时机成熟再送入基础堆，或放回原储备堆，大幅提升可玩性与策略深度。
//  关键属性：baseFoundation_solva（基准堆 A）、sideFoundations_solva（B/C/D）、reservePiles_solva、buffer_solva
//  关键方法：tapReserveTop_solva/tapBuffer_solva（交互入口）
import Foundation
import Combine

final class OsmosisEngine_solva: GameEngineBase_solva {

    private(set) var baseSuit_solva: Suit_solva = .spades
    private(set) var baseRank_solva: Rank_solva = .ace

    /// 基准基础堆 A（严格按循环点数顺序建墩）
    @Published var baseFoundation_solva: [Card_solva] = []
    /// 其余三组基础堆（无需顺序，只要点数已在 A 中出现即可放入）
    @Published var sideFoundations_solva: [Suit_solva: [Card_solva]] = [:]
    /// 4 组储备堆，仅顶牌可见
    @Published var reservePiles_solva: [[Card_solva]] = []
    /// 暂存位（量子穿透缓冲区）：记录卡牌与其来源储备堆索引
    @Published var buffer_solva: (card: Card_solva, originPile: Int)? = nil

    @Published var hintReserveIndex_solva: Int? = nil
    @Published var hintUseBuffer_solva: Bool = false

    private var history_solva: [(base: [Card_solva], side: [Suit_solva: [Card_solva]], reserves: [[Card_solva]], buffer: (card: Card_solva, originPile: Int)?, score: Int, moves: Int)] = []

    init() {
        super.init(gameType_solva: .osmosis)
        newGame_solva()
    }

    // MARK: 开局

    func newGame_solva() {
        var deck_solva = DeckFactory_solva.shuffledDeck_solva()
        var base_solva = deck_solva.removeFirst()
        base_solva.isFaceUp_solva = true
        baseSuit_solva = base_solva.suit_solva
        baseRank_solva = base_solva.rank_solva
        baseFoundation_solva = [base_solva]

        sideFoundations_solva = [:]
        for suit_solva in Suit_solva.allCases where suit_solva != baseSuit_solva {
            sideFoundations_solva[suit_solva] = []
        }

        var piles_solva: [[Card_solva]] = Array(repeating: [], count: 4)
        var round_solva = 0
        while deck_solva.isEmpty == false {
            var card_solva = deck_solva.removeFirst()
            card_solva.isFaceUp_solva = false
            piles_solva[round_solva % 4].append(card_solva)
            round_solva += 1
        }
        for i_solva in piles_solva.indices {
            if piles_solva[i_solva].isEmpty == false {
                piles_solva[i_solva][piles_solva[i_solva].count - 1].isFaceUp_solva = true
            }
        }
        reservePiles_solva = piles_solva
        buffer_solva = nil
        hintReserveIndex_solva = nil
        hintUseBuffer_solva = false
        history_solva.removeAll()
        resetCommonState_solva()
    }

    // MARK: 规则判定

    /// 指定花色/点数的牌当前是否可以放入其对应基础堆
    private func isEligibleForFoundation_solva(_ card_solva: Card_solva) -> Bool {
        if card_solva.suit_solva == baseSuit_solva {
            return card_solva.rank_solva == nextBaseRankNeeded_solva()
        } else {
            let already_solva = sideFoundations_solva[card_solva.suit_solva]?.contains(where: { $0.rank_solva == card_solva.rank_solva }) ?? true
            guard already_solva == false else { return false }
            return baseFoundation_solva.contains(where: { $0.rank_solva == card_solva.rank_solva })
        }
    }

    private func nextBaseRankNeeded_solva() -> Rank_solva {
        var rank_solva = baseRank_solva
        for _ in 0..<baseFoundation_solva.count { rank_solva = rank_solva.cyclicNext_solva }
        return rank_solva
    }

    private func sendToFoundation_solva(_ card_solva: Card_solva) {
        if card_solva.suit_solva == baseSuit_solva {
            baseFoundation_solva.append(card_solva)
        } else {
            sideFoundations_solva[card_solva.suit_solva, default: []].append(card_solva)
        }
    }

    // MARK: 交互

    /// 点击某储备堆顶牌：可直接送入基础堆，否则若暂存位为空则移入暂存位
    func tapReserveTop_solva(_ pileIndex_solva: Int) {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        guard let top_solva = reservePiles_solva[pileIndex_solva].last else { return }
        clearHint_solva()

        if isEligibleForFoundation_solva(top_solva) {
            pushHistory_solva()
            reservePiles_solva[pileIndex_solva].removeLast()
            sendToFoundation_solva(top_solva)
            revealNewTop_solva(pileIndex_solva)
            moveCount_solva += 1
            score_solva += 20
            evaluateGameEnd_solva()
        } else if buffer_solva == nil {
            pushHistory_solva()
            reservePiles_solva[pileIndex_solva].removeLast()
            buffer_solva = (card: top_solva, originPile: pileIndex_solva)
            revealNewTop_solva(pileIndex_solva)
            moveCount_solva += 1
        }
    }

    /// 点击暂存位：若其中的牌已可放入基础堆则送入，否则放回原储备堆顶部
    func tapBuffer_solva() {
        guard let held_solva = buffer_solva else { return }
        clearHint_solva()
        pushHistory_solva()
        if isEligibleForFoundation_solva(held_solva.card) {
            sendToFoundation_solva(held_solva.card)
            score_solva += 10
            moveCount_solva += 1
            buffer_solva = nil
            evaluateGameEnd_solva()
        } else {
            reservePiles_solva[held_solva.originPile].append(held_solva.card)
            buffer_solva = nil
        }
    }

    private func revealNewTop_solva(_ pileIndex_solva: Int) {
        guard let lastIndex_solva = reservePiles_solva[pileIndex_solva].indices.last else { return }
        reservePiles_solva[pileIndex_solva][lastIndex_solva].isFaceUp_solva = true
    }

    private func clearHint_solva() {
        hintReserveIndex_solva = nil
        hintUseBuffer_solva = false
    }

    // MARK: 提示 / 撤销 / 结束判定

    func requestHint_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        if let held_solva = buffer_solva, isEligibleForFoundation_solva(held_solva.card) {
            hintUseBuffer_solva = true
            hintMessage_solva = "Play the buffered \(held_solva.card.rank_solva.label_solva)\(held_solva.card.suit_solva.symbol_solva) to its foundation."
            usedHintCount_solva += 1
            scheduleHintClear_solva()
            return
        }
        for (index_solva, pile_solva) in reservePiles_solva.enumerated() {
            if let top_solva = pile_solva.last, isEligibleForFoundation_solva(top_solva) {
                hintReserveIndex_solva = index_solva
                hintMessage_solva = "Play the \(top_solva.rank_solva.label_solva)\(top_solva.suit_solva.symbol_solva) from reserve pile \(index_solva + 1)."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
        }
        if buffer_solva == nil {
            hintMessage_solva = "No direct play — try buffering a blocked reserve card with the quantum slot."
        } else {
            hintMessage_solva = "No moves available right now."
        }
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
        baseFoundation_solva = last_solva.base
        sideFoundations_solva = last_solva.side
        reservePiles_solva = last_solva.reserves
        buffer_solva = last_solva.buffer
        score_solva = last_solva.score
        moveCount_solva = last_solva.moves
    }

    private func pushHistory_solva() {
        history_solva.append((base: baseFoundation_solva, side: sideFoundations_solva, reserves: reservePiles_solva, buffer: buffer_solva, score: score_solva, moves: moveCount_solva))
        if history_solva.count > 80 { history_solva.removeFirst() }
    }

    private func evaluateGameEnd_solva() {
        let total_solva = baseFoundation_solva.count + sideFoundations_solva.values.reduce(0) { $0 + $1.count }
        if total_solva == 52 {
            score_solva += 500
            finishGame_solva(outcome_solva: .won)
            return
        }
        let reserveTopsEligible_solva = reservePiles_solva.contains { pile_solva in
            guard let top_solva = pile_solva.last else { return false }
            return isEligibleForFoundation_solva(top_solva)
        }
        if reserveTopsEligible_solva { return }
        if let held_solva = buffer_solva, isEligibleForFoundation_solva(held_solva.card) {
            return
        }
        // 注意：不能仅因「当前暂存位里的牌暂时不可用」就判负——只要还有任意储备堆
        // 尚未耗尽（堆里还压着未揭示的牌），玩家依然可以通过「暂存-归还」反复探测、
        // 揭出新的顶牌继续尝试，这仍是有效的合法路径。只有当全部储备堆都已耗尽、
        // 且暂存位中的牌（如有）确实无法送入基础堆时，才是真正无路可走的死局，
        // 否则会出现「明明还能继续操作，却被提前判定失败」的问题。
        let anyReserveNonEmpty_solva = reservePiles_solva.contains { $0.isEmpty == false }
        if anyReserveNonEmpty_solva { return }
        finishGame_solva(outcome_solva: .lost)
    }
}
