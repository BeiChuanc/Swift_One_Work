//
//  CasinoFeltBackground_solva.swift
//  Solva
//
//  欧美牌室「绒面台呢」纹理背景组件。
//  设计思路：替代原先的纯色/单一线性渐变背景——叠加径向绒面渐变、细密斜纹纹样、
//  四角暗角与顶部高光，营造真实牌桌呢面质感；可传入 tint_solva 让每款游戏使用
//  各自强调色去浸染台呢颜色，使 5 款游戏背景各有细微差异而不是同一张纯色底。
//  关键属性：tint_solva（该场景使用的强调色，用于浸染台呢底色）
import SwiftUI

struct CasinoFeltBackground_solva: View {
    var tint_solva: Color = Palette_solva.gold_solva
    var intensity_solva: Double = 0.16

    var body: some View {
        ZStack {
            // 基础绒面径向渐变
            RadialGradient(
                colors: [Palette_solva.feltLight_solva, Palette_solva.feltCore_solva, Palette_solva.feltDeep_solva],
                center: .center,
                startRadius: 40,
                endRadius: 760
            )

            // 强调色浸染层，赋予每款游戏独立气质
            RadialGradient(
                colors: [tint_solva.alpha_solva(intensity_solva), .clear],
                center: UnitPoint(x: 0.5, y: 0.05),
                startRadius: 10,
                endRadius: 520
            )

            // 细密斜纹纹样，避免大面积纯色
            GeometryReader { geo_solva in
                Path { path_solva in
                    let step_solva: CGFloat = 34
                    var x_solva: CGFloat = -geo_solva.size.height
                    while x_solva < geo_solva.size.width {
                        path_solva.move(to: CGPoint(x: x_solva, y: 0))
                        path_solva.addLine(to: CGPoint(x: x_solva + geo_solva.size.height, y: geo_solva.size.height))
                        x_solva += step_solva
                    }
                }
                .stroke(Color.black.alpha_solva(0.05), lineWidth: 1)
            }

            // 顶部高光
            LinearGradient(colors: [Color.white.alpha_solva(0.05), .clear], startPoint: .top, endPoint: .center)

            // 四角暗角，聚焦视觉中心
            RadialGradient(colors: [.clear, Color.black.alpha_solva(0.5)], center: .center, startRadius: 300, endRadius: 700)
        }
        // 性能优化：该背景由多层渐变 + Path 描边叠加而成，且作为几乎所有页面/棋盘的
        // 背景常驻显示；游戏内每秒计时器刷新会带动父级视图树整体重新求值，
        // 若不做处理，这些静态装饰层也会被反复合成。用 drawingGroup 把整组内容
        // 一次性栅格化为单张纹理，后续帧直接复用，避免不必要的重复合成开销。
        .drawingGroup()
        .ignoresSafeArea()
    }
}
