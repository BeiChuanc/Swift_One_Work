import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Hush: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Hush.layer.cornerRadius = 22
        view_Hush.layer.shadowColor = ColorConfig_Hush.shadowColor_Hush.cgColor
        view_Hush.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Hush.layer.shadowRadius = 8
        view_Hush.layer.shadowOpacity = 0.2
        return view_Hush
    }()
    
    /// 渐变装饰圆环（clipsToBounds 确保渐变严格裁剪为圆形，不出现矩形溢出）
    private let gradientRing_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.layer.cornerRadius = 18
        view_Hush.clipsToBounds = true
        return view_Hush
    }()
    
    private var gradientLayer_Hush: CAGradientLayer?
    
    private let iconView_Hush: UIImageView = {
        let imageView_Hush = UIImageView()
        imageView_Hush.image = UIImage(systemName: "chevron.left")
        imageView_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        imageView_Hush.contentMode = .scaleAspectFit
        return imageView_Hush
    }()
    
    // MARK: - 回调
    
    var onTapped_Hush: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
        setupActions_Hush()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Hush == nil {
            let gradient_Hush = CAGradientLayer()
            gradient_Hush.frame = gradientRing_Hush.bounds
            gradient_Hush.colors = [
                ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.3).cgColor,
                ColorConfig_Hush.primaryGradientEnd_Hush.withAlphaComponent(0.3).cgColor
            ]
            gradient_Hush.startPoint = CGPoint(x: 0, y: 0)
            gradient_Hush.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Hush = gradient_Hush
            gradientRing_Hush.layer.insertSublayer(gradient_Hush, at: 0)
        } else {
            gradientLayer_Hush?.frame = gradientRing_Hush.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Hush() {
        addSubview(containerView_Hush)
        containerView_Hush.addSubview(gradientRing_Hush)
        // 图标直接放在渐变圆内，移除中间白色矩形容器
        gradientRing_Hush.addSubview(iconView_Hush)
        
        containerView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    private func setupActions_Hush() {
        let tapGesture_Hush = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        containerView_Hush.addGestureRecognizer(tapGesture_Hush)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Hush() {
        // 按压动画
        containerView_Hush.animatePressDown_Hush {
            self.containerView_Hush.animatePressUp_Hush {
                self.onTapped_Hush?()
            }
        }
        
        // 触觉反馈
        let generator_Hush = UIImpactFeedbackGenerator(style: .light)
        generator_Hush.impactOccurred()
    }
}
