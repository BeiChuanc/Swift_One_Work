import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Flick: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Flick: UIView = {
        let view_Flick = UIView()
        view_Flick.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Flick.layer.cornerRadius = 22
        view_Flick.layer.shadowColor = ColorConfig_Flick.shadowColor_Flick.cgColor
        view_Flick.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Flick.layer.shadowRadius = 8
        view_Flick.layer.shadowOpacity = 0.2
        return view_Flick
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Flick: UIView = {
        let view_Flick = UIView()
        view_Flick.layer.cornerRadius = 18
        return view_Flick
    }()
    
    private var gradientLayer_Flick: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Flick: UIView = {
        let view_Flick = UIView()
        view_Flick.backgroundColor = .white
        view_Flick.layer.cornerRadius = 15
        return view_Flick
    }()
    
    private let iconView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.image = UIImage(systemName: "chevron.left")
        imageView_Flick.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
        imageView_Flick.contentMode = .scaleAspectFit
        return imageView_Flick
    }()
    
    // MARK: - 回调
    
    var onTapped_Flick: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
        setupActions_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Flick == nil {
            let gradient_Flick = CAGradientLayer()
            gradient_Flick.frame = gradientRing_Flick.bounds
            gradient_Flick.colors = [
                ColorConfig_Flick.primaryGradientStart_Flick.withAlphaComponent(0.3).cgColor,
                ColorConfig_Flick.primaryGradientEnd_Flick.withAlphaComponent(0.3).cgColor
            ]
            gradient_Flick.startPoint = CGPoint(x: 0, y: 0)
            gradient_Flick.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Flick = gradient_Flick
            gradientRing_Flick.layer.insertSublayer(gradient_Flick, at: 0)
        } else {
            gradientLayer_Flick?.frame = gradientRing_Flick.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Flick() {
        addSubview(containerView_Flick)
        containerView_Flick.addSubview(gradientRing_Flick)
        containerView_Flick.addSubview(iconContainer_Flick)
        iconContainer_Flick.addSubview(iconView_Flick)
        
        containerView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Flick() {
        let tapGesture_Flick = UITapGestureRecognizer(target: self, action: #selector(handleTap_Flick))
        containerView_Flick.addGestureRecognizer(tapGesture_Flick)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Flick() {
        // 按压动画
        containerView_Flick.animatePressDown_Flick {
            self.containerView_Flick.animatePressUp_Flick {
                self.onTapped_Flick?()
            }
        }
        
        // 触觉反馈
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
    }
}
