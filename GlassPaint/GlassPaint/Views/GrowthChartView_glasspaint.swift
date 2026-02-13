import Foundation
import UIKit
import SnapKit

// MARK: 成长曲线图视图

/// 成长曲线图视图
/// 功能：显示用户的彩绘技能成长曲线
/// 特性：三条曲线（线条流畅度、色彩搭配、技法提升）、渐变填充、动画绘制
class GrowthChartView_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 图表容器
    private let chartContainer_Glasspaint = UIView()
    
    /// 图例容器
    private let legendContainer_Glasspaint = UIView()
    
    /// 线条流畅度图例
    private let lineSmoothnessLegend_Glasspaint = UIView()
    private let lineSmoothnessLabel_Glasspaint = UILabel()
    private let lineSmoothnessValue_Glasspaint = UILabel()
    
    /// 色彩搭配图例
    private let colorMatchingLegend_Glasspaint = UIView()
    private let colorMatchingLabel_Glasspaint = UILabel()
    private let colorMatchingValue_Glasspaint = UILabel()
    
    /// 技法提升图例
    private let techniqueLegend_Glasspaint = UIView()
    private let techniqueLabel_Glasspaint = UILabel()
    private let techniqueValue_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    /// 成长数据
    private var growthData_Glasspaint: GrowthData_Glasspaint?
    
    /// 曲线图层
    private var lineSmoothnessLayer_Glasspaint: CAShapeLayer?
    private var colorMatchingLayer_Glasspaint: CAShapeLayer?
    private var techniqueLayer_Glasspaint: CAShapeLayer?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 添加渐变背景
        let gradientLayer_glasspaint = CAGradientLayer()
        gradientLayer_glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer_glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_glasspaint.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer_glasspaint, at: 0)
        
        backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        layer.cornerRadius = 20
        layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.8
        layer.borderWidth = 1
        layer.borderColor = ColorConfig_Glasspaint.divider_Glasspaint.withAlphaComponent(0.3).cgColor
        
        // 图表容器（添加背景装饰）
        addSubview(chartContainer_Glasspaint)
        chartContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.withAlphaComponent(0.3)
        chartContainer_Glasspaint.layer.cornerRadius = 12
        
        // 图例容器
        addSubview(legendContainer_Glasspaint)
        
        // 设置图例
        setupLegends_Glasspaint()
        
        // 布局
        chartContainer_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
            make.height.equalTo(220)
        }
        
        legendContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(chartContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 更新渐变层frame
        DispatchQueue.main.async {
            gradientLayer_glasspaint.frame = self.bounds
        }
    }
    
    /// 设置图例
    private func setupLegends_Glasspaint() {
        // 线条流畅度图例
        legendContainer_Glasspaint.addSubview(lineSmoothnessLegend_Glasspaint)
        lineSmoothnessLegend_Glasspaint.backgroundColor = ColorConfig_Glasspaint.levelBeginnerColor_Glasspaint
        lineSmoothnessLegend_Glasspaint.layer.cornerRadius = 4
        
        legendContainer_Glasspaint.addSubview(lineSmoothnessLabel_Glasspaint)
        lineSmoothnessLabel_Glasspaint.text = "Line Smoothness"
        lineSmoothnessLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lineSmoothnessLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        legendContainer_Glasspaint.addSubview(lineSmoothnessValue_Glasspaint)
        lineSmoothnessValue_Glasspaint.text = "0"
        lineSmoothnessValue_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lineSmoothnessValue_Glasspaint.textColor = ColorConfig_Glasspaint.levelBeginnerColor_Glasspaint
        
        // 色彩搭配图例
        legendContainer_Glasspaint.addSubview(colorMatchingLegend_Glasspaint)
        colorMatchingLegend_Glasspaint.backgroundColor = ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint
        colorMatchingLegend_Glasspaint.layer.cornerRadius = 4
        
        legendContainer_Glasspaint.addSubview(colorMatchingLabel_Glasspaint)
        colorMatchingLabel_Glasspaint.text = "Color Matching"
        colorMatchingLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        colorMatchingLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        legendContainer_Glasspaint.addSubview(colorMatchingValue_Glasspaint)
        colorMatchingValue_Glasspaint.text = "0"
        colorMatchingValue_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        colorMatchingValue_Glasspaint.textColor = ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint
        
        // 技法提升图例
        legendContainer_Glasspaint.addSubview(techniqueLegend_Glasspaint)
        techniqueLegend_Glasspaint.backgroundColor = ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint
        techniqueLegend_Glasspaint.layer.cornerRadius = 4
        
        legendContainer_Glasspaint.addSubview(techniqueLabel_Glasspaint)
        techniqueLabel_Glasspaint.text = "Technique"
        techniqueLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        techniqueLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        legendContainer_Glasspaint.addSubview(techniqueValue_Glasspaint)
        techniqueValue_Glasspaint.text = "0"
        techniqueValue_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        techniqueValue_Glasspaint.textColor = ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint
        
        // 布局图例
        lineSmoothnessLegend_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(8)
        }
        
        lineSmoothnessLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(lineSmoothnessLegend_Glasspaint.snp.right).offset(8)
            make.centerY.equalTo(lineSmoothnessLegend_Glasspaint)
        }
        
        lineSmoothnessValue_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(lineSmoothnessLegend_Glasspaint)
        }
        
        colorMatchingLegend_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(lineSmoothnessLegend_Glasspaint.snp.bottom).offset(12)
            make.width.height.equalTo(8)
        }
        
        colorMatchingLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(colorMatchingLegend_Glasspaint.snp.right).offset(8)
            make.centerY.equalTo(colorMatchingLegend_Glasspaint)
        }
        
        colorMatchingValue_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(colorMatchingLegend_Glasspaint)
        }
        
        techniqueLegend_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(colorMatchingLegend_Glasspaint.snp.bottom).offset(12)
            make.width.height.equalTo(8)
            make.bottom.equalToSuperview()
        }
        
        techniqueLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(techniqueLegend_Glasspaint.snp.right).offset(8)
            make.centerY.equalTo(techniqueLegend_Glasspaint)
        }
        
        techniqueValue_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(techniqueLegend_Glasspaint)
        }
    }
    
    // MARK: - 配置
    
    /// 配置成长曲线
    /// 参数：
    /// - growthData_glasspaint: 成长数据
    func configure_Glasspaint(with_glasspaint growthData_glasspaint: GrowthData_Glasspaint) {
        self.growthData_Glasspaint = growthData_glasspaint
        
        // 更新图例数值
        lineSmoothnessValue_Glasspaint.text = String(format: "%.0f", growthData_glasspaint.lineSmoothnessScore_Glasspaint)
        colorMatchingValue_Glasspaint.text = String(format: "%.0f", growthData_glasspaint.colorMatchingScore_Glasspaint)
        techniqueValue_Glasspaint.text = String(format: "%.0f", growthData_glasspaint.techniqueScore_Glasspaint)
        
        // 绘制曲线（延迟以确保布局完成）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.drawChart_Glasspaint()
        }
    }
    
    // MARK: - 绘制
    
    /// 绘制图表
    private func drawChart_Glasspaint() {
        guard let data_glasspaint = growthData_Glasspaint else { return }
        
        // 清除旧图层
        lineSmoothnessLayer_Glasspaint?.removeFromSuperlayer()
        colorMatchingLayer_Glasspaint?.removeFromSuperlayer()
        techniqueLayer_Glasspaint?.removeFromSuperlayer()
        
        let width_glasspaint = chartContainer_Glasspaint.bounds.width
        let height_glasspaint = chartContainer_Glasspaint.bounds.height
        
        // 绘制三条曲线
        lineSmoothnessLayer_Glasspaint = drawCurveLine_Glasspaint(
            value_glasspaint: data_glasspaint.lineSmoothnessScore_Glasspaint,
            color_glasspaint: ColorConfig_Glasspaint.levelBeginnerColor_Glasspaint,
            width_glasspaint: width_glasspaint,
            height_glasspaint: height_glasspaint
        )
        
        colorMatchingLayer_Glasspaint = drawCurveLine_Glasspaint(
            value_glasspaint: data_glasspaint.colorMatchingScore_Glasspaint,
            color_glasspaint: ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint,
            width_glasspaint: width_glasspaint,
            height_glasspaint: height_glasspaint
        )
        
        techniqueLayer_Glasspaint = drawCurveLine_Glasspaint(
            value_glasspaint: data_glasspaint.techniqueScore_Glasspaint,
            color_glasspaint: ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint,
            width_glasspaint: width_glasspaint,
            height_glasspaint: height_glasspaint
        )
        
        // 添加图层
        if let layer_glasspaint = lineSmoothnessLayer_Glasspaint {
            chartContainer_Glasspaint.layer.addSublayer(layer_glasspaint)
            animateCurveLine_Glasspaint(layer_glasspaint: layer_glasspaint, delay_glasspaint: 0)
        }
        
        if let layer_glasspaint = colorMatchingLayer_Glasspaint {
            chartContainer_Glasspaint.layer.addSublayer(layer_glasspaint)
            animateCurveLine_Glasspaint(layer_glasspaint: layer_glasspaint, delay_glasspaint: 0.1)
        }
        
        if let layer_glasspaint = techniqueLayer_Glasspaint {
            chartContainer_Glasspaint.layer.addSublayer(layer_glasspaint)
            animateCurveLine_Glasspaint(layer_glasspaint: layer_glasspaint, delay_glasspaint: 0.2)
        }
    }
    
    /// 绘制单条曲线
    /// 参数：
    /// - value_glasspaint: 数值（0-100）
    /// - color_glasspaint: 曲线颜色
    /// - width_glasspaint: 图表宽度
    /// - height_glasspaint: 图表高度
    /// 返回值：曲线图层
    private func drawCurveLine_Glasspaint(
        value_glasspaint: Double,
        color_glasspaint: UIColor,
        width_glasspaint: CGFloat,
        height_glasspaint: CGFloat
    ) -> CAShapeLayer {
        let padding_glasspaint: CGFloat = 20
        let actualWidth_glasspaint = width_glasspaint - padding_glasspaint * 2
        let actualHeight_glasspaint = height_glasspaint - padding_glasspaint * 2
        
        let path_glasspaint = UIBezierPath()
        
        // 计算Y坐标（反转，因为坐标系原点在左上角）
        let yValue_glasspaint = actualHeight_glasspaint * (1 - CGFloat(value_glasspaint) / 100.0) + padding_glasspaint
        
        // 创建更流畅的波浪曲线
        path_glasspaint.move(to: CGPoint(x: padding_glasspaint, y: yValue_glasspaint))
        
        // 使用多个控制点创建更自然的曲线
        let segment1End_glasspaint = CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.33, y: yValue_glasspaint - 8)
        let segment2End_glasspaint = CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.66, y: yValue_glasspaint + 8)
        let finalEnd_glasspaint = CGPoint(x: padding_glasspaint + actualWidth_glasspaint, y: yValue_glasspaint)
        
        path_glasspaint.addCurve(
            to: segment1End_glasspaint,
            controlPoint1: CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.15, y: yValue_glasspaint + 5),
            controlPoint2: CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.25, y: yValue_glasspaint - 5)
        )
        
        path_glasspaint.addCurve(
            to: segment2End_glasspaint,
            controlPoint1: CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.45, y: yValue_glasspaint - 12),
            controlPoint2: CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.55, y: yValue_glasspaint + 12)
        )
        
        path_glasspaint.addCurve(
            to: finalEnd_glasspaint,
            controlPoint1: CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.75, y: yValue_glasspaint + 5),
            controlPoint2: CGPoint(x: padding_glasspaint + actualWidth_glasspaint * 0.90, y: yValue_glasspaint - 3)
        )
        
        // 创建图层
        let shapeLayer_glasspaint = CAShapeLayer()
        shapeLayer_glasspaint.path = path_glasspaint.cgPath
        shapeLayer_glasspaint.strokeColor = color_glasspaint.cgColor
        shapeLayer_glasspaint.fillColor = UIColor.clear.cgColor
        shapeLayer_glasspaint.lineWidth = 3.5
        shapeLayer_glasspaint.lineCap = .round
        shapeLayer_glasspaint.lineJoin = .round
        
        // 添加阴影效果
        shapeLayer_glasspaint.shadowColor = color_glasspaint.cgColor
        shapeLayer_glasspaint.shadowOffset = CGSize(width: 0, height: 2)
        shapeLayer_glasspaint.shadowRadius = 4
        shapeLayer_glasspaint.shadowOpacity = 0.3
        
        return shapeLayer_glasspaint
    }
    
    /// 为曲线添加动画
    /// 参数：
    /// - layer_glasspaint: 曲线图层
    /// - delay_glasspaint: 延迟时间
    private func animateCurveLine_Glasspaint(layer_glasspaint: CAShapeLayer, delay_glasspaint: TimeInterval) {
        let animation_glasspaint = CABasicAnimation(keyPath: "strokeEnd")
        animation_glasspaint.fromValue = 0
        animation_glasspaint.toValue = 1
        animation_glasspaint.duration = AnimationConfig_Glasspaint.durationSlow_Glasspaint
        animation_glasspaint.beginTime = CACurrentMediaTime() + delay_glasspaint
        animation_glasspaint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation_glasspaint.fillMode = .backwards
        
        layer_glasspaint.add(animation_glasspaint, forKey: "strokeEndAnimation")
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 重新绘制图表（如果有数据）
        if growthData_Glasspaint != nil {
            drawChart_Glasspaint()
        }
    }
}
