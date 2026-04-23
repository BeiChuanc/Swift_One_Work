import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Nest: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Nest.layer.cornerRadius = 22
        view_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        view_Nest.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Nest.layer.shadowRadius = 8
        view_Nest.layer.shadowOpacity = 0.2
        return view_Nest
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.layer.cornerRadius = 18
        return view_Nest
    }()
    
    private var gradientLayer_Nest: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.backgroundColor = .white
        view_Nest.layer.cornerRadius = 15
        return view_Nest
    }()
    
    private let iconView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.image = UIImage(systemName: "chevron.left")
        imageView_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        imageView_Nest.contentMode = .scaleAspectFit
        return imageView_Nest
    }()
    
    // MARK: - 回调
    
    var onTapped_Nest: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Nest()
        setupActions_Nest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Nest == nil {
            let gradient_Nest = CAGradientLayer()
            gradient_Nest.frame = gradientRing_Nest.bounds
            gradient_Nest.colors = [
                ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.3).cgColor,
                ColorConfig_Nest.primaryGradientEnd_Nest.withAlphaComponent(0.3).cgColor
            ]
            gradient_Nest.startPoint = CGPoint(x: 0, y: 0)
            gradient_Nest.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Nest = gradient_Nest
            gradientRing_Nest.layer.insertSublayer(gradient_Nest, at: 0)
        } else {
            gradientLayer_Nest?.frame = gradientRing_Nest.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Nest() {
        addSubview(containerView_Nest)
        containerView_Nest.addSubview(gradientRing_Nest)
        containerView_Nest.addSubview(iconContainer_Nest)
        iconContainer_Nest.addSubview(iconView_Nest)
        
        containerView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Nest() {
        let tapGesture_Nest = UITapGestureRecognizer(target: self, action: #selector(handleTap_Nest))
        containerView_Nest.addGestureRecognizer(tapGesture_Nest)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Nest() {
        // 按压动画
        containerView_Nest.animatePressDown_Nest {
            self.containerView_Nest.animatePressUp_Nest {
                self.onTapped_Nest?()
            }
        }
        
        // 触觉反馈
        let generator_Nest = UIImpactFeedbackGenerator(style: .light)
        generator_Nest.impactOccurred()
    }
}
