import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Posture: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Posture: UIView = {
        let view_Posture = UIView()
        view_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Posture.layer.cornerRadius = 22
        view_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        view_Posture.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Posture.layer.shadowRadius = 8
        view_Posture.layer.shadowOpacity = 0.2
        return view_Posture
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Posture: UIView = {
        let view_Posture = UIView()
        view_Posture.layer.cornerRadius = 18
        return view_Posture
    }()
    
    private var gradientLayer_Posture: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Posture: UIView = {
        let view_Posture = UIView()
        view_Posture.backgroundColor = .white
        view_Posture.layer.cornerRadius = 15
        return view_Posture
    }()
    
    private let iconView_Posture: UIImageView = {
        let imageView_Posture = UIImageView()
        imageView_Posture.image = UIImage(systemName: "chevron.left")
        imageView_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        imageView_Posture.contentMode = .scaleAspectFit
        return imageView_Posture
    }()
    
    // MARK: - 回调
    
    var onTapped_Posture: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
        setupActions_Posture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Posture == nil {
            let gradient_Posture = CAGradientLayer()
            gradient_Posture.frame = gradientRing_Posture.bounds
            gradient_Posture.colors = [
                ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.3).cgColor,
                ColorConfig_Posture.primaryGradientEnd_Posture.withAlphaComponent(0.3).cgColor
            ]
            gradient_Posture.startPoint = CGPoint(x: 0, y: 0)
            gradient_Posture.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Posture = gradient_Posture
            gradientRing_Posture.layer.insertSublayer(gradient_Posture, at: 0)
        } else {
            gradientLayer_Posture?.frame = gradientRing_Posture.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Posture() {
        addSubview(containerView_Posture)
        containerView_Posture.addSubview(gradientRing_Posture)
        containerView_Posture.addSubview(iconContainer_Posture)
        iconContainer_Posture.addSubview(iconView_Posture)
        
        containerView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Posture() {
        let tapGesture_Posture = UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture))
        containerView_Posture.addGestureRecognizer(tapGesture_Posture)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Posture() {
        // 按压动画
        containerView_Posture.animatePressDown_Posture {
            self.containerView_Posture.animatePressUp_Posture {
                self.onTapped_Posture?()
            }
        }
        
        // 触觉反馈
        let generator_Posture = UIImpactFeedbackGenerator(style: .light)
        generator_Posture.impactOccurred()
    }
}
