import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Tidy: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Tidy: UIView = {
        let view_Tidy = UIView()
        view_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Tidy.layer.cornerRadius = 22
        view_Tidy.layer.shadowColor = ColorConfig_Tidy.shadowColor_Tidy.cgColor
        view_Tidy.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Tidy.layer.shadowRadius = 8
        view_Tidy.layer.shadowOpacity = 0.2
        return view_Tidy
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Tidy: UIView = {
        let view_Tidy = UIView()
        view_Tidy.layer.cornerRadius = 18
        return view_Tidy
    }()
    
    private var gradientLayer_Tidy: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Tidy: UIView = {
        let view_Tidy = UIView()
        view_Tidy.backgroundColor = .white
        view_Tidy.layer.cornerRadius = 15
        return view_Tidy
    }()
    
    private let iconView_Tidy: UIImageView = {
        let imageView_Tidy = UIImageView()
        imageView_Tidy.image = UIImage(systemName: "chevron.left")
        imageView_Tidy.tintColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        imageView_Tidy.contentMode = .scaleAspectFit
        return imageView_Tidy
    }()
    
    // MARK: - 回调
    
    var onTapped_Tidy: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
        setupActions_Tidy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Tidy == nil {
            let gradient_Tidy = CAGradientLayer()
            gradient_Tidy.frame = gradientRing_Tidy.bounds
            gradient_Tidy.colors = [
                ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.3).cgColor,
                ColorConfig_Tidy.primaryGradientEnd_Tidy.withAlphaComponent(0.3).cgColor
            ]
            gradient_Tidy.startPoint = CGPoint(x: 0, y: 0)
            gradient_Tidy.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Tidy = gradient_Tidy
            gradientRing_Tidy.layer.insertSublayer(gradient_Tidy, at: 0)
        } else {
            gradientLayer_Tidy?.frame = gradientRing_Tidy.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Tidy() {
        addSubview(containerView_Tidy)
        containerView_Tidy.addSubview(gradientRing_Tidy)
        containerView_Tidy.addSubview(iconContainer_Tidy)
        iconContainer_Tidy.addSubview(iconView_Tidy)
        
        containerView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Tidy() {
        let tapGesture_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleTap_Tidy))
        containerView_Tidy.addGestureRecognizer(tapGesture_Tidy)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Tidy() {
        // 按压动画
        containerView_Tidy.animatePressDown_Tidy {
            self.containerView_Tidy.animatePressUp_Tidy {
                self.onTapped_Tidy?()
            }
        }
        
        // 触觉反馈
        let generator_Tidy = UIImpactFeedbackGenerator(style: .light)
        generator_Tidy.impactOccurred()
    }
}
