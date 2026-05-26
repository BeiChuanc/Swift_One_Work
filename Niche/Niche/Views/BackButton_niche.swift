import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Niche: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Niche.layer.cornerRadius = 22
        view_Niche.layer.shadowColor = ColorConfig_Niche.shadowColor_Niche.cgColor
        view_Niche.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Niche.layer.shadowRadius = 8
        view_Niche.layer.shadowOpacity = 0.2
        return view_Niche
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.layer.cornerRadius = 18
        return view_Niche
    }()
    
    private var gradientLayer_Niche: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.backgroundColor = .white
        view_Niche.layer.cornerRadius = 15
        return view_Niche
    }()
    
    private let iconView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.image = UIImage(systemName: "chevron.left")
        imageView_Niche.tintColor = ColorConfig_Niche.primaryGradientStart_Niche
        imageView_Niche.contentMode = .scaleAspectFit
        return imageView_Niche
    }()
    
    // MARK: - 回调
    
    var onTapped_Niche: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Niche()
        setupActions_Niche()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Niche == nil {
            let gradient_Niche = CAGradientLayer()
            gradient_Niche.frame = gradientRing_Niche.bounds
            gradient_Niche.colors = [
                ColorConfig_Niche.primaryGradientStart_Niche.withAlphaComponent(0.3).cgColor,
                ColorConfig_Niche.primaryGradientEnd_Niche.withAlphaComponent(0.3).cgColor
            ]
            gradient_Niche.startPoint = CGPoint(x: 0, y: 0)
            gradient_Niche.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Niche = gradient_Niche
            gradientRing_Niche.layer.insertSublayer(gradient_Niche, at: 0)
        } else {
            gradientLayer_Niche?.frame = gradientRing_Niche.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Niche() {
        addSubview(containerView_Niche)
        containerView_Niche.addSubview(gradientRing_Niche)
        containerView_Niche.addSubview(iconContainer_Niche)
        iconContainer_Niche.addSubview(iconView_Niche)
        
        containerView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Niche() {
        let tapGesture_Niche = UITapGestureRecognizer(target: self, action: #selector(handleTap_Niche))
        containerView_Niche.addGestureRecognizer(tapGesture_Niche)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Niche() {
        // 按压动画
        containerView_Niche.animatePressDown_Niche {
            self.containerView_Niche.animatePressUp_Niche {
                self.onTapped_Niche?()
            }
        }
        
        // 触觉反馈
        let generator_Niche = UIImpactFeedbackGenerator(style: .light)
        generator_Niche.impactOccurred()
    }
}
