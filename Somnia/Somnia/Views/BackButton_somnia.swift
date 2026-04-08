import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 核心作用：全局通用的返回导航按钮，自适应父视图尺寸
/// 设计思路：渐变填充圆形背景 + 白色粗体 chevron 图标 + 紫色光晕阴影 + 弹簧按压动画
/// 关键属性：onTapped_Somnia 回调，由调用方绑定导航动作
class BackButton_Somnia: UIView {

    // MARK: - UI组件

    /// 渐变圆形背景容器（不 clipsToBounds，以便投射阴影）
    private let bgView_Somnia: UIView = {
        let v = UIView()
        v.layer.shadowColor = ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.30
        return v
    }()

    /// 渐变图层（主渐变色，圆形）
    private var gradientLayer_Somnia: CAGradientLayer?

    /// chevron 图标（白色，bold 字重确保在渐变上清晰可见）
    private let iconView_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        iv.image = UIImage(systemName: "chevron.left", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 回调

    /// 点击回调（由调用方绑定导航动作）
    var onTapped_Somnia: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
        setupActions_Somnia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient_Somnia()
    }

    // MARK: - UI设置

    private func setupUI_Somnia() {
        addSubview(bgView_Somnia)
        bgView_Somnia.addSubview(iconView_Somnia)

        // bgView 填满父视图，留 3pt 内边距以让阴影可见
        bgView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }

        // chevron 图标居中（水平轻微左偏 1pt 视觉矫正），固定尺寸保证锐利
        iconView_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-1)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
    }

    private func setupActions_Somnia() {
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap_Somnia)
    }

    // MARK: - 渐变更新

    /// 根据当前 bgView 的 bounds 更新渐变图层与圆角半径
    private func updateGradient_Somnia() {
        guard bgView_Somnia.bounds.width > 0 else { return }
        let radius_Somnia = bgView_Somnia.bounds.width / 2

        if gradientLayer_Somnia == nil {
            let grad_Somnia = CAGradientLayer()
            grad_Somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
            grad_Somnia.frame = bgView_Somnia.bounds
            grad_Somnia.cornerRadius = radius_Somnia
            bgView_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
            gradientLayer_Somnia = grad_Somnia
        } else {
            gradientLayer_Somnia?.frame = bgView_Somnia.bounds
            gradientLayer_Somnia?.cornerRadius = radius_Somnia
        }

        // 圆形 shadowPath 性能更好，且与视觉形状吻合
        bgView_Somnia.layer.shadowPath = UIBezierPath(ovalIn: bgView_Somnia.bounds).cgPath
    }

    // MARK: - 事件处理

    /// 按钮点击：弹簧缩放动画 + 触觉反馈，动画完成后触发回调
    @objc private func handleTap_Somnia() {
        UIView.animate(withDuration: 0.1, animations: {
            self.bgView_Somnia.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.45,
                initialSpringVelocity: 8,
                options: .allowUserInteraction
            ) {
                self.bgView_Somnia.transform = .identity
            } completion: { _ in
                self.onTapped_Somnia?()
            }
        }
        let generator_Somnia = UIImpactFeedbackGenerator(style: .medium)
        generator_Somnia.impactOccurred()
    }
}
