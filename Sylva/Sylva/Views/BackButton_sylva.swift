import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Sylva: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Sylva.layer.cornerRadius = 22
        view_Sylva.layer.shadowColor = ColorConfig_Sylva.shadowColor_Sylva.cgColor
        view_Sylva.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Sylva.layer.shadowRadius = 8
        view_Sylva.layer.shadowOpacity = 0.2
        return view_Sylva
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.layer.cornerRadius = 18
        return view_Sylva
    }()
    
    private var gradientLayer_Sylva: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.backgroundColor = .white
        view_Sylva.layer.cornerRadius = 15
        return view_Sylva
    }()
    
    private let iconView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.image = UIImage(systemName: "chevron.left")
        imageView_Sylva.tintColor = ColorConfig_Sylva.primaryGradientStart_Sylva
        imageView_Sylva.contentMode = .scaleAspectFit
        return imageView_Sylva
    }()
    
    // MARK: - 回调
    
    var onTapped_Sylva: (() -> Void)?
    
    /// 便捷配置回调，等同于设置 onTapped_Sylva
    func configure_Sylva(_ action: @escaping () -> Void) {
        onTapped_Sylva = action
    }
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sylva()
        setupActions_Sylva()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Sylva == nil {
            let gradient_Sylva = CAGradientLayer()
            gradient_Sylva.frame = gradientRing_Sylva.bounds
            gradient_Sylva.colors = [
                ColorConfig_Sylva.primaryGradientStart_Sylva.withAlphaComponent(0.3).cgColor,
                ColorConfig_Sylva.primaryGradientEnd_Sylva.withAlphaComponent(0.3).cgColor
            ]
            gradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
            gradient_Sylva.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Sylva = gradient_Sylva
            gradientRing_Sylva.layer.insertSublayer(gradient_Sylva, at: 0)
        } else {
            gradientLayer_Sylva?.frame = gradientRing_Sylva.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Sylva() {
        addSubview(containerView_Sylva)
        containerView_Sylva.addSubview(gradientRing_Sylva)
        containerView_Sylva.addSubview(iconContainer_Sylva)
        iconContainer_Sylva.addSubview(iconView_Sylva)
        
        containerView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Sylva() {
        let tapGesture_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sylva))
        containerView_Sylva.addGestureRecognizer(tapGesture_Sylva)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Sylva() {
        // 按压动画
        containerView_Sylva.animatePressDown_Sylva {
            self.containerView_Sylva.animatePressUp_Sylva {
                self.onTapped_Sylva?()
            }
        }
        
        // 触觉反馈
        let generator_Sylva = UIImpactFeedbackGenerator(style: .light)
        generator_Sylva.impactOccurred()
    }
}
