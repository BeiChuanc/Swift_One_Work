import UIKit
import SnapKit

// MARK: 睡眠成长曲线图组件

/// 宠物睡眠成长折线图
/// 设计：深夜主题渐变填充 + 平滑贝塞尔曲线 + 数据点动画 + 横轴标签
/// 支持月度/季度切换，动画绘制曲线
class SleepGrowthChartView_Doze: UIView {

    // MARK: - 常量

    private let chartPadding_Doze = UIEdgeInsets(top: 20, left: 8, bottom: 36, right: 12)
    private let dotRadius_Doze: CGFloat = 5

    // MARK: - 状态

    private var dataPoints_Doze: [SleepGrowthPoint_Doze] = []

    // MARK: - 图层

    /// 曲线路径图层
    private let lineLayer_Doze = CAShapeLayer()

    /// 渐变填充图层（曲线下方面积）
    private let fillLayer_Doze = CAGradientLayer()

    /// 填充遮罩（使渐变跟随曲线形状）
    private let fillMaskLayer_Doze = CAShapeLayer()

    // MARK: - 子视图

    /// 数据点圆点容器（方便批量清除重建）
    private let dotContainer_Doze = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayers_Doze()
        addSubview(dotContainer_Doze)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        dotContainer_Doze.frame = bounds
    }

    // MARK: - 图层搭建

    private func setupLayers_Doze() {
        // 渐变填充（紫→透明）
        fillLayer_Doze.colors = [
            UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.45).cgColor,
            UIColor(hexstring_Doze: "#90CDF4").withAlphaComponent(0.08).cgColor
        ]
        fillLayer_Doze.startPoint = CGPoint(x: 0.5, y: 0)
        fillLayer_Doze.endPoint = CGPoint(x: 0.5, y: 1)
        fillLayer_Doze.mask = fillMaskLayer_Doze
        layer.addSublayer(fillLayer_Doze)

        // 曲线线条
        lineLayer_Doze.strokeColor = UIColor(hexstring_Doze: "#B794F6").cgColor
        lineLayer_Doze.fillColor = UIColor.clear.cgColor
        lineLayer_Doze.lineWidth = 2.5
        lineLayer_Doze.lineCap = .round
        lineLayer_Doze.lineJoin = .round
        layer.addSublayer(lineLayer_Doze)
    }

    // MARK: - 公开方法

    /// 设置数据并重绘图表（带入场动画）
    /// - Parameter points_doze: 数据点数组（至少 2 个点）
    func setData_Doze(points_doze: [SleepGrowthPoint_Doze]) {
        guard points_doze.count >= 2 else { return }
        dataPoints_Doze = points_doze
        setNeedsLayout()
        layoutIfNeeded()
        redraw_Doze(animated: true)
    }

    // MARK: - 绘制

    private func redraw_Doze(animated: Bool) {
        guard dataPoints_Doze.count >= 2 else { return }
        guard bounds.width > 0, bounds.height > 0 else { return }

        let chartRect_doze = CGRect(
            x: chartPadding_Doze.left,
            y: chartPadding_Doze.top,
            width: bounds.width - chartPadding_Doze.left - chartPadding_Doze.right,
            height: bounds.height - chartPadding_Doze.top - chartPadding_Doze.bottom
        )

        // 计算各点坐标
        let pointCount = CGFloat(dataPoints_Doze.count - 1)
        let xStep_doze = chartRect_doze.width / pointCount
        let points_doze: [CGPoint] = dataPoints_Doze.enumerated().map { (i, item) in
            let x = chartRect_doze.minX + CGFloat(i) * xStep_doze
            let y = chartRect_doze.maxY - item.avgQuality_Doze * chartRect_doze.height
            return CGPoint(x: x, y: y)
        }

        // 构建平滑贝塞尔曲线
        let linePath_doze = smoothBezierPath_Doze(through: points_doze)

        // 构建填充路径（曲线 + 底部封闭）
        let fillPath_doze = linePath_doze.copy() as! UIBezierPath
        fillPath_doze.addLine(to: CGPoint(x: points_doze.last!.x, y: chartRect_doze.maxY))
        fillPath_doze.addLine(to: CGPoint(x: points_doze.first!.x, y: chartRect_doze.maxY))
        fillPath_doze.close()

        // 更新图层 frame
        fillLayer_Doze.frame = bounds
        lineLayer_Doze.frame = bounds

        // 更新路径
        lineLayer_Doze.path = linePath_doze.cgPath
        fillMaskLayer_Doze.path = fillPath_doze.cgPath
        fillMaskLayer_Doze.frame = bounds

        // 曲线描绘动画
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 1.2
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            lineLayer_Doze.strokeEnd = 1
            lineLayer_Doze.add(anim, forKey: "draw_doze")

            // 填充淡入
            let fillAnim = CABasicAnimation(keyPath: "opacity")
            fillAnim.fromValue = 0
            fillAnim.toValue = 1
            fillAnim.duration = 1.4
            fillAnim.beginTime = CACurrentMediaTime() + 0.2
            fillAnim.fillMode = .forwards
            fillAnim.isRemovedOnCompletion = false
            fillLayer_Doze.opacity = 1
            fillLayer_Doze.add(fillAnim, forKey: "fillFade_doze")
        }

        // 重建数据点圆点 + 标签
        rebuildDots_Doze(points: points_doze, chartRect: chartRect_doze, animated: animated)
        rebuildAxisLabels_Doze(points: points_doze)
    }

    /// 生成平滑贝塞尔曲线（Catmull-Rom 控制点算法）
    private func smoothBezierPath_Doze(through points_doze: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        guard points_doze.count >= 2 else { return path }
        path.move(to: points_doze[0])

        for i in 1..<points_doze.count {
            let curr = points_doze[i]
            let prev = points_doze[i - 1]
            let tension: CGFloat = 0.3
            let cp1 = CGPoint(x: prev.x + (curr.x - prev.x) * tension, y: prev.y)
            let cp2 = CGPoint(x: curr.x - (curr.x - prev.x) * tension, y: curr.y)
            path.addCurve(to: curr, controlPoint1: cp1, controlPoint2: cp2)
        }
        return path
    }

    /// 重建数据点圆点（带弹入动画）
    private func rebuildDots_Doze(points: [CGPoint], chartRect: CGRect, animated: Bool) {
        dotContainer_Doze.subviews
            .filter { $0.tag >= 1000 && $0.tag < 2000 }
            .forEach { $0.removeFromSuperview() }

        for (i, pt) in points.enumerated() {
            let item = dataPoints_Doze[i]

            // 外圆（光晕）
            let halo = UIView(frame: CGRect(x: pt.x - 10, y: pt.y - 10, width: 20, height: 20))
            halo.backgroundColor = UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.25)
            halo.layer.cornerRadius = 10
            halo.tag = 1000 + i
            halo.isUserInteractionEnabled = false
            dotContainer_Doze.addSubview(halo)

            // 内圆
            let dot = UIView(frame: CGRect(x: pt.x - dotRadius_Doze, y: pt.y - dotRadius_Doze,
                                           width: dotRadius_Doze * 2, height: dotRadius_Doze * 2))
            dot.backgroundColor = UIColor(hexstring_Doze: "#B794F6")
            dot.layer.cornerRadius = dotRadius_Doze
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
            dot.tag = 1100 + i
            dot.isUserInteractionEnabled = false
            dotContainer_Doze.addSubview(dot)

            // 数值标签（显示质量百分比）
            let valueLabel = UILabel()
            let pct = Int(item.avgQuality_Doze * 100)
            valueLabel.text = "\(pct)%"
            valueLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            valueLabel.textColor = UIColor(hexstring_Doze: "#B794F6")
            valueLabel.sizeToFit()
            valueLabel.center = CGPoint(x: pt.x, y: pt.y - 16)
            valueLabel.tag = 1200 + i
            valueLabel.isUserInteractionEnabled = false
            dotContainer_Doze.addSubview(valueLabel)

            // 弹入动画
            if animated {
                let delay = Double(i) * 0.1 + 0.6
                halo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                halo.alpha = 0
                dot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                dot.alpha = 0
                UIView.animate(withDuration: 0.4, delay: delay,
                               usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5,
                               options: []) {
                    halo.transform = .identity
                    halo.alpha = 1
                    dot.transform = .identity
                    dot.alpha = 1
                }
            }
        }
    }

    /// 重建横轴标签
    private func rebuildAxisLabels_Doze(points: [CGPoint]) {
        dotContainer_Doze.subviews
            .filter { $0.tag >= 2000 }
            .forEach { $0.removeFromSuperview() }

        let bottomY = bounds.height - chartPadding_Doze.bottom + 6
        for (i, pt) in points.enumerated() {
            let label = UILabel()
            label.text = dataPoints_Doze[i].label_Doze
            label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            label.textColor = UIColor.white.withAlphaComponent(0.45)
            label.sizeToFit()
            label.center = CGPoint(x: pt.x, y: bottomY + label.bounds.height / 2)
            label.tag = 2000 + i
            label.isUserInteractionEnabled = false
            dotContainer_Doze.addSubview(label)
        }
    }
}
