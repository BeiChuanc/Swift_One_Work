import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_wanderbell.layer.cornerRadius = 22
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.2
        return view_wanderbell
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 18
        return view_wanderbell
    }()
    
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 15
        return view_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "chevron.left")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    // MARK: - 回调
    
    var onTapped_Wanderbell: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupActions_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Wanderbell == nil {
            let gradient_wanderbell = CAGradientLayer()
            gradient_wanderbell.frame = gradientRing_Wanderbell.bounds
            gradient_wanderbell.colors = [
                ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.3).cgColor,
                ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.withAlphaComponent(0.3).cgColor
            ]
            gradient_wanderbell.startPoint = CGPoint(x: 0, y: 0)
            gradient_wanderbell.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Wanderbell = gradient_wanderbell
            gradientRing_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
        } else {
            gradientLayer_Wanderbell?.frame = gradientRing_Wanderbell.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(gradientRing_Wanderbell)
        containerView_Wanderbell.addSubview(iconContainer_Wanderbell)
        iconContainer_Wanderbell.addSubview(iconView_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Wanderbell() {
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(handleTap_Wanderbell))
        containerView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Wanderbell() {
        // 按压动画
        containerView_Wanderbell.animatePressDown_Wanderbell {
            self.containerView_Wanderbell.animatePressUp_Wanderbell {
                self.onTapped_Wanderbell?()
            }
        }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
}
