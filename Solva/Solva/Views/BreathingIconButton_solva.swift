//
//  BreathingIconButton_solva.swift
//  Solva
//
//  「呼吸灯」圆形图标按钮组件。
//  设计思路：用于首页左上角这类需要持续吸引玩家注意、但又不适合占用过多横向空间
//  展示文字标签的入口（如 How to Play）——纯圆形图标，去掉文本，
//  外圈用一层持续放大 + 淡出的光环模拟「呼吸灯」呼吸效果（scale + opacity 双动画，
//  .repeatForever(autoreverses:) 循环播放），比静态图标更容易被玩家一眼注意到。
//  关键属性：icon_solva（SF Symbol 名称）、tint_solva（呼吸光环与图标颜色）、size_solva（按钮直径）
//  关键方法：action_solva（点击回调）
import SwiftUI

struct BreathingIconButton_solva: View {
    let icon_solva: String
    var tint_solva: Color = Palette_solva.gold_solva
    var size_solva: CGFloat = 44
    let action_solva: () -> Void

    /// 呼吸动画开关：true 时光环处于「放大且淡出」的终态，配合 repeatForever 循环往返
    @State private var isBreathing_solva: Bool = false

    var body: some View {
        Button(action: action_solva) {
            ZStack {
                // 呼吸光环：持续放大 + 淡出，营造类似呼吸灯的柔和脉动效果
                Circle()
                    .stroke(tint_solva.alpha_solva(0.6), lineWidth: 2)
                    .frame(width: size_solva, height: size_solva)
                    .scaleEffect(isBreathing_solva ? 1.45 : 1.0)
                    .opacity(isBreathing_solva ? 0.0 : 0.9)

                // 按钮本体：渐变圆底 + 描边，呼吸时投影同步轻微增强，强化「发光」质感
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tint_solva.alpha_solva(0.35), tint_solva.alpha_solva(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size_solva, height: size_solva)
                    .overlay(Circle().strokeBorder(tint_solva.alpha_solva(0.75), lineWidth: 1.3))
                    .shadow(color: tint_solva.alpha_solva(isBreathing_solva ? 0.55 : 0.25), radius: isBreathing_solva ? 9 : 4)

                Image(systemName: icon_solva)
                    .font(.system(size: size_solva * 0.42, weight: .semibold))
                    .foregroundStyle(tint_solva)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                isBreathing_solva = true
            }
        }
    }
}
