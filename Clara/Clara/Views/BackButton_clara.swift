import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Clara: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Clara.layer.cornerRadius = 22
        view_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        view_Clara.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Clara.layer.shadowRadius = 8
        view_Clara.layer.shadowOpacity = 0.2
        return view_Clara
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.layer.cornerRadius = 18
        return view_Clara
    }()
    
    private var gradientLayer_Clara: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.backgroundColor = .white
        view_Clara.layer.cornerRadius = 15
        return view_Clara
    }()
    
    private let iconView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.image = UIImage(systemName: "chevron.left")
        imageView_Clara.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        imageView_Clara.contentMode = .scaleAspectFit
        return imageView_Clara
    }()
    
    // MARK: - 回调
    
    var onTapped_Clara: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Clara()
        setupActions_Clara()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Clara == nil {
            let gradient_Clara = CAGradientLayer()
            gradient_Clara.frame = gradientRing_Clara.bounds
            gradient_Clara.colors = [
                ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.3).cgColor,
                ColorConfig_Clara.primaryGradientEnd_Clara.withAlphaComponent(0.3).cgColor
            ]
            gradient_Clara.startPoint = CGPoint(x: 0, y: 0)
            gradient_Clara.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Clara = gradient_Clara
            gradientRing_Clara.layer.insertSublayer(gradient_Clara, at: 0)
        } else {
            gradientLayer_Clara?.frame = gradientRing_Clara.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Clara() {
        addSubview(containerView_Clara)
        containerView_Clara.addSubview(gradientRing_Clara)
        containerView_Clara.addSubview(iconContainer_Clara)
        iconContainer_Clara.addSubview(iconView_Clara)
        
        containerView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Clara() {
        let tapGesture_Clara = UITapGestureRecognizer(target: self, action: #selector(handleTap_Clara))
        containerView_Clara.addGestureRecognizer(tapGesture_Clara)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Clara() {
        // 按压动画
        containerView_Clara.animatePressDown_Clara {
            self.containerView_Clara.animatePressUp_Clara {
                self.onTapped_Clara?()
            }
        }
        
        // 触觉反馈
        let generator_Clara = UIImpactFeedbackGenerator(style: .light)
        generator_Clara.impactOccurred()
    }
}
