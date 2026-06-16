import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Retrs: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Retrs.layer.cornerRadius = 22
        view_Retrs.layer.shadowColor = ColorConfig_Retrs.shadowColor_Retrs.cgColor
        view_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Retrs.layer.shadowRadius = 8
        view_Retrs.layer.shadowOpacity = 0.2
        return view_Retrs
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.layer.cornerRadius = 18
        return view_Retrs
    }()
    
    private var gradientLayer_Retrs: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.backgroundColor = .white
        view_Retrs.layer.cornerRadius = 15
        return view_Retrs
    }()
    
    private let iconView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.image = UIImage(systemName: "chevron.left")
        imageView_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        imageView_Retrs.contentMode = .scaleAspectFit
        return imageView_Retrs
    }()
    
    // MARK: - 回调
    
    var onTapped_Retrs: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
        setupActions_Retrs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Retrs == nil {
            let gradient_Retrs = CAGradientLayer()
            gradient_Retrs.frame = gradientRing_Retrs.bounds
            gradient_Retrs.colors = [
                ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.3).cgColor,
                ColorConfig_Retrs.primaryGradientEnd_Retrs.withAlphaComponent(0.3).cgColor
            ]
            gradient_Retrs.startPoint = CGPoint(x: 0, y: 0)
            gradient_Retrs.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Retrs = gradient_Retrs
            gradientRing_Retrs.layer.insertSublayer(gradient_Retrs, at: 0)
        } else {
            gradientLayer_Retrs?.frame = gradientRing_Retrs.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Retrs() {
        addSubview(containerView_Retrs)
        containerView_Retrs.addSubview(gradientRing_Retrs)
        containerView_Retrs.addSubview(iconContainer_Retrs)
        iconContainer_Retrs.addSubview(iconView_Retrs)
        
        containerView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Retrs() {
        let tapGesture_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleTap_Retrs))
        containerView_Retrs.addGestureRecognizer(tapGesture_Retrs)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Retrs() {
        // 按压动画
        containerView_Retrs.animatePressDown_Retrs {
            self.containerView_Retrs.animatePressUp_Retrs {
                self.onTapped_Retrs?()
            }
        }
        
        // 触觉反馈
        let generator_Retrs = UIImpactFeedbackGenerator(style: .light)
        generator_Retrs.impactOccurred()
    }
}
