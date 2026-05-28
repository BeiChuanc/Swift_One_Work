import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Ornit: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Ornit: UIView = {
        let view_Ornit = UIView()
        view_Ornit.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Ornit.layer.cornerRadius = 22
        view_Ornit.layer.shadowColor = ColorConfig_Ornit.shadowColor_Ornit.cgColor
        view_Ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Ornit.layer.shadowRadius = 8
        view_Ornit.layer.shadowOpacity = 0.2
        return view_Ornit
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Ornit: UIView = {
        let view_Ornit = UIView()
        view_Ornit.layer.cornerRadius = 18
        return view_Ornit
    }()
    
    private var gradientLayer_Ornit: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Ornit: UIView = {
        let view_Ornit = UIView()
        view_Ornit.backgroundColor = .white
        view_Ornit.layer.cornerRadius = 15
        return view_Ornit
    }()
    
    private let iconView_Ornit: UIImageView = {
        let imageView_Ornit = UIImageView()
        imageView_Ornit.image = UIImage(systemName: "chevron.left")
        imageView_Ornit.tintColor = ColorConfig_Ornit.primaryGradientStart_Ornit
        imageView_Ornit.contentMode = .scaleAspectFit
        return imageView_Ornit
    }()
    
    // MARK: - 回调
    
    var onTapped_Ornit: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Ornit()
        setupActions_Ornit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Ornit == nil {
            let gradient_Ornit = CAGradientLayer()
            gradient_Ornit.frame = gradientRing_Ornit.bounds
            gradient_Ornit.colors = [
                ColorConfig_Ornit.primaryGradientStart_Ornit.withAlphaComponent(0.3).cgColor,
                ColorConfig_Ornit.primaryGradientEnd_Ornit.withAlphaComponent(0.3).cgColor
            ]
            gradient_Ornit.startPoint = CGPoint(x: 0, y: 0)
            gradient_Ornit.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Ornit = gradient_Ornit
            gradientRing_Ornit.layer.insertSublayer(gradient_Ornit, at: 0)
        } else {
            gradientLayer_Ornit?.frame = gradientRing_Ornit.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Ornit() {
        addSubview(containerView_Ornit)
        containerView_Ornit.addSubview(gradientRing_Ornit)
        containerView_Ornit.addSubview(iconContainer_Ornit)
        iconContainer_Ornit.addSubview(iconView_Ornit)
        
        containerView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Ornit() {
        let tapGesture_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleTap_Ornit))
        containerView_Ornit.addGestureRecognizer(tapGesture_Ornit)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Ornit() {
        // 按压动画
        containerView_Ornit.animatePressDown_Ornit {
            self.containerView_Ornit.animatePressUp_Ornit {
                self.onTapped_Ornit?()
            }
        }
        
        // 触觉反馈
        let generator_Ornit = UIImpactFeedbackGenerator(style: .light)
        generator_Ornit.impactOccurred()
    }
}
