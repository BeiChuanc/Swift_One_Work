//
//  AccordionEngine_solva.swift
//  Solva
//
//  手风琴纸牌（Accordion Solitaire）游戏引擎。
//  设计思路：52 张牌各占一个初始位置排成一行（本实现按 13 列 x 4 行网格呈现，
//  逻辑上仍是一维的 52 个位置）。可将某位置的顶牌移动到其左侧第 1、3 或 4 个
//  位置的牌堆上（位置索引固定，空位不参与位移但仍占位，符合经典规则的距离判定）。
//  新颖补充玩法：
//  1）「和声连击」——3 秒内连续完成合并可叠加连击加分；
//  2）「风箱重奏」——每局 2 次机会，可将当前所有非空堆的内容随机重新分布到原有位置，
//     用于破解卡死局面，而不改变已固定的规则骨架。
//  终局判定：无法再走时，若剩余堆数 <= 8 视为压缩成功（胜利），否则判定失败。
//  关键属性：piles_solva（52 个位置的牌堆数组）、selectedIndex_solva（当前选中位置）
//  关键方法：selectOrMove_solva（点选交互入口）、reshuffle_solva（风箱重奏）、requestHint_solva（提示）
import Foundation
import Combine

final class AccordionEngine_solva: GameEngineBase_solva {

    /// 52 个位置的牌堆，索引固定不因空堆而收缩
    @Published var piles_solva: [[Card_solva]] = []
    /// 当前选中的位置索引（等待玩家点选目标）
    @Published var selectedIndex_solva: Int? = nil
    /// 提示高亮的起点/终点位置
    @Published var hintSource_solva: Int? = nil
    @Published var hintTarget_solva: Int? = nil
    /// 风箱重奏剩余可用次数
    @Published var reshuffleCharges_solva: Int = 0
    /// 当前和声连击数（用于 UI 展示连击加成）
    @Published var comboStreak_solva: Int = 0

    private var history_solva: [(piles: [[Card_solva]], score: Int, moves: Int, combo: Int)] = []
    private var lastMoveDate_solva: Date? = nil
    private let winPileThreshold_solva = 8
    private let maxReshuffleCharges_solva = 2

    init() {
        super.init(gameType_solva: .accordion)
        newGame_solva()
    }

    /// 当前仍有牌的位置索引集合
    var activeIndices_solva: [Int] { piles_solva.indices.filter { piles_solva[$0].isEmpty == false } }
    /// 当前剩余牌堆数量
    var activePileCount_solva: Int { activeIndices_solva.count }

    /// 开始新的一局：重新洗牌、铺满 52 个位置、重置全部状态
    func newGame_solva() {
        piles_solva = DeckFactory_solva.shuffledDeck_solva().map { card_solva in
            var faceUp_solva = card_solva
            faceUp_solva.isFaceUp_solva = true
            return [faceUp_solva]
        }
        selectedIndex_solva = nil
        hintSource_solva = nil
        hintTarget_solva = nil
        reshuffleCharges_solva = maxReshuffleCharges_solva
        comboStreak_solva = 0
        history_solva.removeAll()
        lastMoveDate_solva = nil
        resetCommonState_solva()
    }

    /// 点选交互统一入口：首次点击选中，再次点击同一目标位置尝试执行移动
    func selectOrMove_solva(_ index_solva: Int) {
        guard isGameOver_solva == false, isGameWon_solva == false, piles_solva[index_solva].isEmpty == false else { return }
        hintSource_solva = nil
        hintTarget_solva = nil

        if let selected_solva = selectedIndex_solva {
            if selected_solva == index_solva {
                selectedIndex_solva = nil
            } else if isValidMove_solva(from: selected_solva, to: index_solva) {
                performMove_solva(from: selected_solva, to: index_solva)
                selectedIndex_solva = nil
            } else {
                selectedIndex_solva = index_solva
            }
        } else {
            selectedIndex_solva = index_solva
        }
    }

    /// 是否满足「距离为 1/3/4 且同点数或同花色」的合并条件
    private func isValidMove_solva(from: Int, to: Int) -> Bool {
        guard from != to, piles_solva[from].isEmpty == false, piles_solva[to].isEmpty == false else { return false }
        let distance_solva = from - to
        guard distance_solva == 1 || distance_solva == 3 || distance_solva == 4 else { return false }
        let movingCard_solva = piles_solva[from].last!
        let targetCard_solva = piles_solva[to].last!
        return movingCard_solva.rank_solva == targetCard_solva.rank_solva || movingCard_solva.suit_solva == targetCard_solva.suit_solva
    }

    private func performMove_solva(from: Int, to: Int) {
        pushHistory_solva()
        let card_solva = piles_solva[from].removeLast()
        piles_solva[to].append(card_solva)
        moveCount_solva += 1

        let now_solva = Date()
        if let last_solva = lastMoveDate_solva, now_solva.timeIntervalSince(last_solva) <= 3.0 {
            comboStreak_solva += 1
        } else {
            comboStreak_solva = 0
        }
        lastMoveDate_solva = now_solva
        score_solva += 10 + comboStreak_solva * 5

        evaluateGameEnd_solva()
    }

    /// 风箱重奏：将当前所有非空堆的整体内容随机重新分配到原有位置索引上
    func reshuffle_solva() {
        guard reshuffleCharges_solva > 0, isGameOver_solva == false, isGameWon_solva == false else { return }
        pushHistory_solva()
        let indices_solva = activeIndices_solva
        var contents_solva = indices_solva.map { piles_solva[$0] }
        contents_solva.shuffle()
        for (offset_solva, index_solva) in indices_solva.enumerated() {
            piles_solva[index_solva] = contents_solva[offset_solva]
        }
        reshuffleCharges_solva -= 1
        selectedIndex_solva = nil
        evaluateGameEnd_solva()
    }

    /// 提示：寻找当前任意一组合法移动并高亮展示
    func requestHint_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false else { return }
        let indices_solva = activeIndices_solva
        for from_solva in indices_solva {
            for to_solva in indices_solva where isValidMove_solva(from: from_solva, to: to_solva) {
                hintSource_solva = from_solva
                hintTarget_solva = to_solva
                hintMessage_solva = "Move pile \(from_solva + 1) onto pile \(to_solva + 1) — matching rank or suit."
                usedHintCount_solva += 1
                scheduleHintClear_solva()
                return
            }
        }
        hintMessage_solva = reshuffleCharges_solva > 0
            ? "No direct merge available — try Bellow Reprise to reshuffle the remaining piles."
            : "No more moves available."
        scheduleHintClear_solva()
    }

    private func scheduleHintClear_solva() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.hintSource_solva = nil
            self?.hintTarget_solva = nil
            self?.hintMessage_solva = nil
        }
    }

    /// 撤销上一步操作（含风箱重奏）
    func undo_solva() {
        guard isGameOver_solva == false, isGameWon_solva == false, let last_solva = history_solva.popLast() else { return }
        piles_solva = last_solva.piles
        score_solva = last_solva.score
        moveCount_solva = last_solva.moves
        comboStreak_solva = last_solva.combo
        selectedIndex_solva = nil
    }

    private func pushHistory_solva() {
        history_solva.append((piles: piles_solva, score: score_solva, moves: moveCount_solva, combo: comboStreak_solva))
        if history_solva.count > 60 { history_solva.removeFirst() }
    }

    private func hasAnyValidMove_solva() -> Bool {
        let indices_solva = activeIndices_solva
        for from_solva in indices_solva {
            for to_solva in indices_solva where isValidMove_solva(from: from_solva, to: to_solva) {
                return true
            }
        }
        return false
    }

    private func evaluateGameEnd_solva() {
        let count_solva = activePileCount_solva
        if count_solva == 1 {
            score_solva += 500
            finishGame_solva(outcome_solva: .won)
            return
        }
        guard hasAnyValidMove_solva() == false, reshuffleCharges_solva == 0 else { return }
        if count_solva <= winPileThreshold_solva {
            score_solva += max(0, (winPileThreshold_solva - count_solva) * 20)
            finishGame_solva(outcome_solva: .won)
        } else {
            finishGame_solva(outcome_solva: .lost)
        }
    }

    /// 上报给成就系统的特殊里程碑：最终剩余堆数（越少越好）
    override func specialMetricForFinish_solva() -> Int? {
        activePileCount_solva
    }
}
