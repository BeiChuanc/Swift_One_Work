import Foundation
import UIKit

// MARK: 构图网格叠加视图

/// 构图网格叠加视图
/// 核心作用：在预览图片上叠加绘制 8 种可选的构图辅助网格，并支持自定义整体透明度
/// 设计思路：
///   通过 draw(_ rect:) 使用 CoreGraphics 按 gridType_Tidy 分支绘制不同的辅助线路径，
///   所有线条统一使用白色描边 + 细微投影，保证在明暗不同的照片上都清晰可辨；
///   gridOpacity_Tidy 直接映射为 view.alpha，调节整体网格可见度。
/// 关键属性/方法：
///   - gridType_Tidy：当前选择的构图网格模板类型，赋值后自动重绘
///   - gridOpacity_Tidy：网格透明度（0...1），赋值后自动更新
class CompositionGridOverlayView_Tidy: UIView {

    /// 当前构图网格类型，赋值后触发重绘
    var gridType_Tidy: GridTemplateType_Tidy = .ruleOfThirds_tidy {
        didSet { setNeedsDisplay() }
    }

    /// 网格透明度（0...1），赋值后更新视图整体 alpha
    var gridOpacity_Tidy: CGFloat = 0.85 {
        didSet { self.alpha = gridOpacity_Tidy }
    }

    /// 线条颜色
    private let lineColor_Tidy = UIColor.white

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit_Tidy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit_Tidy()
    }

    /// 通用初始化：透明背景、禁止交互、按当前透明度赋值
    private func commonInit_Tidy() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        self.alpha = gridOpacity_Tidy
        contentMode = .redraw
    }

    override func draw(_ rect: CGRect) {
        guard let ctx_tidy = UIGraphicsGetCurrentContext() else { return }
        ctx_tidy.setStrokeColor(lineColor_Tidy.cgColor)
        ctx_tidy.setShadow(offset: .zero, blur: 2, color: UIColor.black.withAlphaComponent(0.35).cgColor)

        switch gridType_Tidy {
        case .ruleOfThirds_tidy: drawRuleOfThirds_Tidy(ctx_tidy, rect)
        case .goldenSpiral_tidy: drawGoldenSpiral_Tidy(ctx_tidy, rect)
        case .symmetry_tidy:     drawSymmetry_Tidy(ctx_tidy, rect)
        case .diagonal_tidy:     drawDiagonal_Tidy(ctx_tidy, rect)
        case .cinemaScope_tidy:  drawCinemaScope_Tidy(ctx_tidy, rect)
        case .idPhoto_tidy:      drawCenteredRatioFrame_Tidy(ctx_tidy, rect, ratioW_tidy: 35, ratioH_tidy: 45)
        case .square_tidy:       drawCenteredRatioFrame_Tidy(ctx_tidy, rect, ratioW_tidy: 1, ratioH_tidy: 1)
        case .portraitCrop_tidy: drawPortraitCrop_Tidy(ctx_tidy, rect)
        }
    }

    // MARK: - 各类型网格绘制

    /// 三分线：两条竖线、两条横线，均分九宫格
    private func drawRuleOfThirds_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect) {
        ctx_tidy.setLineWidth(1)
        for i_tidy in 1...2 {
            let x_tidy = rect_tidy.width * CGFloat(i_tidy) / 3
            ctx_tidy.move(to: CGPoint(x: x_tidy, y: 0))
            ctx_tidy.addLine(to: CGPoint(x: x_tidy, y: rect_tidy.height))
            let y_tidy = rect_tidy.height * CGFloat(i_tidy) / 3
            ctx_tidy.move(to: CGPoint(x: 0, y: y_tidy))
            ctx_tidy.addLine(to: CGPoint(x: rect_tidy.width, y: y_tidy))
        }
        ctx_tidy.strokePath()
    }

    /// 黄金螺旋：用等比递减（黄金比例 0.618）的矩形分割近似表现螺旋分割感
    private func drawGoldenSpiral_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect) {
        ctx_tidy.setLineWidth(1)
        let phi_tidy: CGFloat = 0.618
        var current_tidy = rect_tidy
        var fromRight_tidy = true
        for _ in 0..<5 {
            guard current_tidy.width > 20, current_tidy.height > 20 else { break }
            if fromRight_tidy {
                let cutW_tidy = current_tidy.width * phi_tidy
                ctx_tidy.move(to: CGPoint(x: current_tidy.minX + cutW_tidy, y: current_tidy.minY))
                ctx_tidy.addLine(to: CGPoint(x: current_tidy.minX + cutW_tidy, y: current_tidy.maxY))
                current_tidy = CGRect(x: current_tidy.minX + cutW_tidy, y: current_tidy.minY,
                                       width: current_tidy.width - cutW_tidy, height: current_tidy.height)
            } else {
                let cutH_tidy = current_tidy.height * phi_tidy
                ctx_tidy.move(to: CGPoint(x: current_tidy.minX, y: current_tidy.minY + cutH_tidy))
                ctx_tidy.addLine(to: CGPoint(x: current_tidy.maxX, y: current_tidy.minY + cutH_tidy))
                current_tidy = CGRect(x: current_tidy.minX, y: current_tidy.minY + cutH_tidy,
                                       width: current_tidy.width, height: current_tidy.height - cutH_tidy)
            }
            fromRight_tidy.toggle()
        }
        ctx_tidy.strokePath()
    }

    /// 对称构图：水平 + 垂直中心十字线
    private func drawSymmetry_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect) {
        ctx_tidy.setLineWidth(1)
        ctx_tidy.move(to: CGPoint(x: rect_tidy.midX, y: 0))
        ctx_tidy.addLine(to: CGPoint(x: rect_tidy.midX, y: rect_tidy.height))
        ctx_tidy.move(to: CGPoint(x: 0, y: rect_tidy.midY))
        ctx_tidy.addLine(to: CGPoint(x: rect_tidy.width, y: rect_tidy.midY))
        ctx_tidy.strokePath()
    }

    /// 对角线构图：两条角对角线
    private func drawDiagonal_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect) {
        ctx_tidy.setLineWidth(1)
        ctx_tidy.move(to: CGPoint(x: 0, y: 0))
        ctx_tidy.addLine(to: CGPoint(x: rect_tidy.width, y: rect_tidy.height))
        ctx_tidy.move(to: CGPoint(x: rect_tidy.width, y: 0))
        ctx_tidy.addLine(to: CGPoint(x: 0, y: rect_tidy.height))
        ctx_tidy.strokePath()
    }

    /// 电影 2.39:1 遮幅：上下遮幅条 + 边界线
    private func drawCinemaScope_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect) {
        let targetHeight_tidy = rect_tidy.width / 2.39
        let barHeight_tidy = max((rect_tidy.height - targetHeight_tidy) / 2, 0)
        ctx_tidy.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)
        ctx_tidy.fill(CGRect(x: 0, y: 0, width: rect_tidy.width, height: barHeight_tidy))
        ctx_tidy.fill(CGRect(x: 0, y: rect_tidy.height - barHeight_tidy, width: rect_tidy.width, height: barHeight_tidy))
        ctx_tidy.setLineWidth(1)
        ctx_tidy.move(to: CGPoint(x: 0, y: barHeight_tidy))
        ctx_tidy.addLine(to: CGPoint(x: rect_tidy.width, y: barHeight_tidy))
        ctx_tidy.move(to: CGPoint(x: 0, y: rect_tidy.height - barHeight_tidy))
        ctx_tidy.addLine(to: CGPoint(x: rect_tidy.width, y: rect_tidy.height - barHeight_tidy))
        ctx_tidy.strokePath()
    }

    /// 居中裁切框：按指定宽高比在画面中心绘制矩形边框（用于证件照比例、方形）
    /// 参数：
    /// - ratioW_tidy: 目标宽高比的宽
    /// - ratioH_tidy: 目标宽高比的高
    private func drawCenteredRatioFrame_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect, ratioW_tidy: CGFloat, ratioH_tidy: CGFloat) {
        let targetRatio_tidy = ratioW_tidy / ratioH_tidy
        var frameW_tidy = rect_tidy.width * 0.82
        var frameH_tidy = frameW_tidy / targetRatio_tidy
        if frameH_tidy > rect_tidy.height * 0.82 {
            frameH_tidy = rect_tidy.height * 0.82
            frameW_tidy = frameH_tidy * targetRatio_tidy
        }
        let frame_tidy = CGRect(
            x: rect_tidy.midX - frameW_tidy / 2, y: rect_tidy.midY - frameH_tidy / 2,
            width: frameW_tidy, height: frameH_tidy
        )
        ctx_tidy.setLineWidth(1.5)
        ctx_tidy.stroke(frame_tidy)
        // 中心十字辅助线，帮助定位面部
        ctx_tidy.setLineWidth(0.8)
        ctx_tidy.move(to: CGPoint(x: frame_tidy.midX, y: frame_tidy.minY))
        ctx_tidy.addLine(to: CGPoint(x: frame_tidy.midX, y: frame_tidy.maxY))
        ctx_tidy.move(to: CGPoint(x: frame_tidy.minX, y: frame_tidy.midY))
        ctx_tidy.addLine(to: CGPoint(x: frame_tidy.maxX, y: frame_tidy.midY))
        ctx_tidy.strokePath()
    }

    /// 人像裁割参考线：标注头顶/眼线/肩线/安全裁切位，提示避开关节处裁切
    private func drawPortraitCrop_Tidy(_ ctx_tidy: CGContext, _ rect_tidy: CGRect) {
        ctx_tidy.setLineWidth(1)
        let ratios_tidy: [CGFloat] = [0.12, 0.32, 0.62, 0.88]
        for ratio_tidy in ratios_tidy {
            let y_tidy = rect_tidy.height * ratio_tidy
            ctx_tidy.move(to: CGPoint(x: 0, y: y_tidy))
            ctx_tidy.addLine(to: CGPoint(x: rect_tidy.width, y: y_tidy))
        }
        ctx_tidy.strokePath()
    }
}
