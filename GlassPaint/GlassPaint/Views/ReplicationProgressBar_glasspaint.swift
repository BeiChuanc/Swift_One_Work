import Foundation
import UIKit
import SnapKit

// MARK: 复刻率进度条

/// 复刻率进度条视图
/// 功能：显示作品的复刻率进度
/// 特性：渐变进度条、百分比文字、动画填充
class ReplicationProgressBar_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 背景进度条
    private let backgroundBar_Glasspaint = UIView()
    
    /// 前景进度条
    private let foregroundBar_Glasspaint = UIView()
    
    /// 渐变层
    private let gradientLayer_Glasspaint = CAGradientLayer()
    
    /// 百分比标签
    private let percentLabel_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    /// 当前进度（0-100）
    private var progress_Glasspaint: Int = 0
    
    /// 进度条高度
    private let barHeight_Glasspaint: CGFloat = 6
    
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
        // 背景进度条
        addSubview(backgroundBar_Glasspaint)
        backgroundBar_Glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint
        backgroundBar_Glasspaint.layer.cornerRadius = barHeight_Glasspaint / 2
        backgroundBar_Glasspaint.layer.masksToBounds = true
        
        // 前景进度条
        backgroundBar_Glasspaint.addSubview(foregroundBar_Glasspaint)
        foregroundBar_Glasspaint.layer.cornerRadius = barHeight_Glasspaint / 2
        foregroundBar_Glasspaint.layer.masksToBounds = true
        
        // 渐变层
        gradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint.cgColor
        ]
        foregroundBar_Glasspaint.layer.addSublayer(gradientLayer_Glasspaint)
        
        // 百分比标签
        addSubview(percentLabel_Glasspaint)
        percentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        percentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        percentLabel_Glasspaint.textAlignment = .right
        
        // 布局
        backgroundBar_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(percentLabel_Glasspaint.snp.left).offset(-8)
            make.height.equalTo(barHeight_Glasspaint)
        }
        
        foregroundBar_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0) // 初始宽度为0
        }
        
        percentLabel_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        
        // 整体高度约束
        snp.makeConstraints { make in
            make.height.equalTo(barHeight_Glasspaint)
        }
    }
    
    // MARK: - 公共方法
    
    /// 设置进度
    /// 功能：更新进度条显示，带动画效果
    /// 参数：
    /// - progress_glasspaint: 进度值（0-100）
    /// - animated_glasspaint: 是否使用动画
    func setProgress_Glasspaint(progress_glasspaint: Int, animated_glasspaint: Bool = true) {
        self.progress_Glasspaint = min(100, max(0, progress_glasspaint))
        
        // 更新百分比文字
        percentLabel_Glasspaint.text = "\(self.progress_Glasspaint)%"
        
        // 计算进度条宽度
        let totalWidth_glasspaint = backgroundBar_Glasspaint.frame.width
        let targetWidth_glasspaint = totalWidth_glasspaint * CGFloat(self.progress_Glasspaint) / 100.0
        
        // 更新颜色（根据进度值）
        updateGradientColors_Glasspaint()
        
        if animated_glasspaint {
            // 动画更新宽度
            UIView.animate(
                withDuration: AnimationConfig_Glasspaint.durationSlow_Glasspaint,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Glasspaint.springDampingNormal_Glasspaint,
                initialSpringVelocity: AnimationConfig_Glasspaint.springVelocity_Glasspaint,
                options: [.curveEaseOut],
                animations: {
                    self.foregroundBar_Glasspaint.snp.updateConstraints { make in
                        make.width.equalTo(targetWidth_glasspaint)
                    }
                    self.layoutIfNeeded()
                },
                completion: nil
            )
            
            // 数字跳动动画
            animateNumberChange_Glasspaint()
        } else {
            foregroundBar_Glasspaint.snp.updateConstraints { make in
                make.width.equalTo(targetWidth_glasspaint)
            }
        }
    }
    
    /// 获取当前进度
    /// 返回值：当前进度值（0-100）
    func getProgress_Glasspaint() -> Int {
        return progress_Glasspaint
    }
    
    // MARK: - 私有方法
    
    /// 更新渐变颜色
    /// 功能：根据进度值调整渐变颜色
    private func updateGradientColors_Glasspaint() {
        let startColor_glasspaint: UIColor
        let endColor_glasspaint: UIColor
        
        if progress_Glasspaint >= 70 {
            // 高复刻率：绿色渐变
            startColor_glasspaint = ColorConfig_Glasspaint.successColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.levelBeginnerColor_Glasspaint
        } else if progress_Glasspaint >= 40 {
            // 中复刻率：橙色渐变
            startColor_glasspaint = ColorConfig_Glasspaint.highReplicationColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.warningColor_Glasspaint
        } else {
            // 低复刻率：蓝色渐变
            startColor_glasspaint = ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint
        }
        
        gradientLayer_Glasspaint.colors = [
            startColor_glasspaint.cgColor,
            endColor_glasspaint.cgColor
        ]
    }
    
    /// 数字跳动动画
    /// 功能：百分比数字的跳动效果
    private func animateNumberChange_Glasspaint() {
        percentLabel_Glasspaint.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(
            withDuration: AnimationConfig_Glasspaint.durationFast_Glasspaint,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Glasspaint.springDampingLight_Glasspaint,
            initialSpringVelocity: AnimationConfig_Glasspaint.springVelocity_Glasspaint,
            options: [.curveEaseOut],
            animations: {
                self.percentLabel_Glasspaint.transform = .identity
            },
            completion: nil
        )
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Glasspaint.frame = foregroundBar_Glasspaint.bounds
        
        // 如果已经有进度值，需要更新宽度
        if progress_Glasspaint > 0 {
            let totalWidth_glasspaint = backgroundBar_Glasspaint.frame.width
            let targetWidth_glasspaint = totalWidth_glasspaint * CGFloat(progress_Glasspaint) / 100.0
            foregroundBar_Glasspaint.snp.updateConstraints { make in
                make.width.equalTo(targetWidth_glasspaint)
            }
        }
    }
}
