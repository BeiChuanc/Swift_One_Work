import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Breeze: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Breeze: UIView = {
        let view_Breeze = UIView()
        view_Breeze.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Breeze.layer.cornerRadius = 22
        view_Breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_Breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Breeze.layer.shadowRadius = 8
        view_Breeze.layer.shadowOpacity = 0.2
        return view_Breeze
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Breeze: UIView = {
        let view_Breeze = UIView()
        view_Breeze.layer.cornerRadius = 18
        return view_Breeze
    }()
    
    private var gradientLayer_Breeze: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Breeze: UIView = {
        let view_Breeze = UIView()
        view_Breeze.backgroundColor = .white
        view_Breeze.layer.cornerRadius = 15
        return view_Breeze
    }()
    
    private let iconView_Breeze: UIImageView = {
        let imageView_Breeze = UIImageView()
        imageView_Breeze.image = UIImage(systemName: "chevron.left")
        imageView_Breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        imageView_Breeze.contentMode = .scaleAspectFit
        return imageView_Breeze
    }()
    
    // MARK: - 回调
    
    var onTapped_Breeze: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
        setupActions_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Breeze == nil {
            let gradient_Breeze = CAGradientLayer()
            gradient_Breeze.frame = gradientRing_Breeze.bounds
            gradient_Breeze.colors = [
                ColorConfig_Breeze.primaryGradientStart_Breeze.withAlphaComponent(0.3).cgColor,
                ColorConfig_Breeze.primaryGradientEnd_Breeze.withAlphaComponent(0.3).cgColor
            ]
            gradient_Breeze.startPoint = CGPoint(x: 0, y: 0)
            gradient_Breeze.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Breeze = gradient_Breeze
            gradientRing_Breeze.layer.insertSublayer(gradient_Breeze, at: 0)
        } else {
            gradientLayer_Breeze?.frame = gradientRing_Breeze.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Breeze() {
        addSubview(containerView_Breeze)
        containerView_Breeze.addSubview(gradientRing_Breeze)
        containerView_Breeze.addSubview(iconContainer_Breeze)
        iconContainer_Breeze.addSubview(iconView_Breeze)
        
        containerView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Breeze() {
        let tapGesture_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Breeze))
        containerView_Breeze.addGestureRecognizer(tapGesture_Breeze)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Breeze() {
        // 按压动画
        containerView_Breeze.animatePressDown_Breeze {
            self.containerView_Breeze.animatePressUp_Breeze {
                self.onTapped_Breeze?()
            }
        }
        
        // 触觉反馈
        let generator_Breeze = UIImpactFeedbackGenerator(style: .light)
        generator_Breeze.impactOccurred()
    }
}
