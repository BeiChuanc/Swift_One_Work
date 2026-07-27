//
//  GameEngineBase_solva.swift
//  Solva
//
//  游戏引擎基类。
//  设计思路：5 款纸牌游戏的引擎在「计时/计分/步数/胜负状态/结束上报」上完全共性，
//  差异只在具体的发牌规则与移动规则，因此提取本基类，子类（AccordionEngine_solva 等）
//  只需专注实现各自的业务逻辑，并在开局/结束时调用基类提供的模板方法，
//  从而保证「记录 → 统计 → 成就」的闭环调用不会被任何一个具体游戏遗漏。
//  关键属性：score_solva/moveCount_solva/elapsedSeconds_solva/isGameWon_solva/isGameOver_solva
//  关键方法：resetCommonState_solva（新开局重置公共状态）、finishGame_solva（结束并上报结算协调器）
import Foundation
import Combine

class GameEngineBase_solva: ObservableObject {
    let gameType_solva: GameType_solva

    @Published var score_solva: Int = 0
    @Published var moveCount_solva: Int = 0
    @Published var elapsedSeconds_solva: Int = 0
    @Published var isGameWon_solva: Bool = false
    @Published var isGameOver_solva: Bool = false
    @Published var hintMessage_solva: String? = nil
    @Published var usedHintCount_solva: Int = 0
    @Published var newlyUnlockedAchievements_solva: [AchievementDefinition_solva] = []

    /// 结算协调器，由外部（GameContainerScreen_solva）在创建引擎后注入
    weak var coordinator_solva: GameSessionCoordinator_solva?

    private var timer_solva: Timer?

    init(gameType_solva: GameType_solva) {
        self.gameType_solva = gameType_solva
    }

    /// 启动计时器（每秒 +1），游戏结束后自动停止累计
    func startTimer_solva() {
        stopTimer_solva()
        timer_solva = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, self.isGameWon_solva == false, self.isGameOver_solva == false else { return }
            self.elapsedSeconds_solva += 1
        }
    }

    func stopTimer_solva() {
        timer_solva?.invalidate()
        timer_solva = nil
    }

    /// 新开局时重置全部公共状态（子类在完成发牌后调用）
    func resetCommonState_solva() {
        score_solva = 0
        moveCount_solva = 0
        elapsedSeconds_solva = 0
        isGameWon_solva = false
        isGameOver_solva = false
        hintMessage_solva = nil
        usedHintCount_solva = 0
        newlyUnlockedAchievements_solva = []
        startTimer_solva()
    }

    /// 子类可覆写，提供成就系统需要的「特殊里程碑」数值（如手风琴剩余堆数）
    func specialMetricForFinish_solva() -> Int? { nil }

    /// 结束一局并上报结算协调器，完成「记录/统计/成就」闭环
    func finishGame_solva(outcome_solva: GameOutcome_solva) {
        stopTimer_solva()
        if outcome_solva == .won {
            isGameWon_solva = true
        } else if outcome_solva == .lost {
            isGameOver_solva = true
        }
        let payload_solva = GameFinishPayload_solva(
            gameType_solva: gameType_solva,
            outcome_solva: outcome_solva,
            score_solva: score_solva,
            moveCount_solva: moveCount_solva,
            durationSeconds_solva: elapsedSeconds_solva,
            usedHintCount_solva: usedHintCount_solva,
            specialMetric_solva: specialMetricForFinish_solva()
        )
        if let coordinator_solva {
            coordinator_solva.finish_solva(payload_solva)
            newlyUnlockedAchievements_solva = coordinator_solva.latestUnlockedAchievements_solva
            coordinator_solva.latestUnlockedAchievements_solva = []
        }
    }

    deinit {
        timer_solva?.invalidate()
    }
}
