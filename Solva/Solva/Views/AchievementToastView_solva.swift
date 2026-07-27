//
//  AchievementToastView_solva.swift
//  Solva
//
//  全局成就解锁提示条组件。
//  设计思路：挂载在根视图顶层，监听 achievementDidUnlock_solva 通知，
//  与具体页面/游戏引擎彻底解耦——任何地方解锁成就都会在此统一呈现浮动提示，
//  体现「状态管理统一添加通知」规范中通知机制的实际用途。
//  内部使用 class 型控制器管理排队展示逻辑，避免在 struct 视图中于逃逸闭包里做可变状态变更。
//
import SwiftUI
import Combine

/// 成就提示队列控制器
/// 关键方法：enqueue_solva（新增一条待展示提示，自动排队顺序播放）
final class AchievementToastController_solva: ObservableObject {
    @Published var currentTitle_solva: String? = nil
    private var queue_solva: [String] = []
    private var isShowing_solva = false

    func enqueue_solva(_ title_solva: String) {
        queue_solva.append(title_solva)
        advanceIfNeeded_solva()
    }

    private func advanceIfNeeded_solva() {
        guard isShowing_solva == false, queue_solva.isEmpty == false else { return }
        isShowing_solva = true
        currentTitle_solva = queue_solva.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig_solva.achievementToastDuration_solva) { [weak self] in
            self?.currentTitle_solva = nil
            self?.isShowing_solva = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.advanceIfNeeded_solva()
            }
        }
    }
}

struct AchievementToastView_solva: View {
    @StateObject private var controller_solva = AchievementToastController_solva()

    var body: some View {
        VStack {
            if let title_solva = controller_solva.currentTitle_solva {
                HStack(spacing: 10) {
                    IconBadge_solva(icon_solva: "rosette", tint_solva: Palette_solva.gold_solva, size_solva: 32)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("ACHIEVEMENT UNLOCKED")
                            .casinoTracked_solva(0.8)
                            .font(.casinoLabel_solva(9.5))
                            .foregroundStyle(Palette_solva.textSecondary_solva)
                        Text(title_solva)
                            .font(.casinoTitle_solva(14))
                            .foregroundStyle(Palette_solva.textPrimary_solva)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Palette_solva.panel_solva)
                        .overlay(Capsule().stroke(Palette_solva.gold_solva.alpha_solva(0.6), lineWidth: 1.2))
                )
                .shadow(color: .black.alpha_solva(0.4), radius: 12, y: 6)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 14)
            }
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: controller_solva.currentTitle_solva)
        .allowsHitTesting(false)
        .onReceive(NotificationCenter.default.publisher(for: .achievementDidUnlock_solva)) { note_solva in
            guard let key_solva = note_solva.userInfo?["key"] as? String,
                  let def_solva = LocalData_solva.achievementDefinitions_solva.first(where: { $0.key_solva == key_solva }) else { return }
            controller_solva.enqueue_solva(def_solva.title_solva)
        }
    }
}
