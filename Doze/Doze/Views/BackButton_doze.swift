import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Doze: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Doze.layer.cornerRadius = 22
        view_Doze.layer.shadowColor = ColorConfig_Doze.shadowColor_Doze.cgColor
        view_Doze.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Doze.layer.shadowRadius = 8
        view_Doze.layer.shadowOpacity = 0.2
        return view_Doze
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.layer.cornerRadius = 18
        return view_Doze
    }()
    
    private var gradientLayer_Doze: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.backgroundColor = .white
        view_Doze.layer.cornerRadius = 15
        return view_Doze
    }()
    
    private let iconView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.image = UIImage(systemName: "chevron.left")
        imageView_Doze.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        imageView_Doze.contentMode = .scaleAspectFit
        return imageView_Doze
    }()
    
    // MARK: - 回调
    
    var onTapped_Doze: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Doze()
        setupActions_Doze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Doze == nil {
            let gradient_Doze = CAGradientLayer()
            gradient_Doze.frame = gradientRing_Doze.bounds
            gradient_Doze.colors = [
                ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.3).cgColor,
                ColorConfig_Doze.primaryGradientEnd_Doze.withAlphaComponent(0.3).cgColor
            ]
            gradient_Doze.startPoint = CGPoint(x: 0, y: 0)
            gradient_Doze.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Doze = gradient_Doze
            gradientRing_Doze.layer.insertSublayer(gradient_Doze, at: 0)
        } else {
            gradientLayer_Doze?.frame = gradientRing_Doze.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Doze() {
        addSubview(containerView_Doze)
        containerView_Doze.addSubview(gradientRing_Doze)
        containerView_Doze.addSubview(iconContainer_Doze)
        iconContainer_Doze.addSubview(iconView_Doze)
        
        containerView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Doze() {
        let tapGesture_Doze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Doze))
        containerView_Doze.addGestureRecognizer(tapGesture_Doze)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Doze() {
        // 按压动画
        containerView_Doze.animatePressDown_Doze {
            self.containerView_Doze.animatePressUp_Doze {
                self.onTapped_Doze?()
            }
        }
        
        // 触觉反馈
        let generator_Doze = UIImpactFeedbackGenerator(style: .light)
        generator_Doze.impactOccurred()
    }
}
