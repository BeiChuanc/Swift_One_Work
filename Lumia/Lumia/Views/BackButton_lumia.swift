import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Lumia: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Lumia: UIView = {
        let view_Lumia = UIView()
        view_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Lumia.layer.cornerRadius = 22
        view_Lumia.layer.shadowColor = ColorConfig_Lumia.shadowColor_Lumia.cgColor
        view_Lumia.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Lumia.layer.shadowRadius = 8
        view_Lumia.layer.shadowOpacity = 0.2
        return view_Lumia
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Lumia: UIView = {
        let view_Lumia = UIView()
        view_Lumia.layer.cornerRadius = 18
        return view_Lumia
    }()
    
    private var gradientLayer_Lumia: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Lumia: UIView = {
        let view_Lumia = UIView()
        view_Lumia.backgroundColor = .white
        view_Lumia.layer.cornerRadius = 15
        return view_Lumia
    }()
    
    private let iconView_Lumia: UIImageView = {
        let imageView_Lumia = UIImageView()
        imageView_Lumia.image = UIImage(systemName: "chevron.left")
        imageView_Lumia.tintColor = ColorConfig_Lumia.primaryGradientStart_Lumia
        imageView_Lumia.contentMode = .scaleAspectFit
        return imageView_Lumia
    }()
    
    // MARK: - 回调
    
    var onTapped_Lumia: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
        setupActions_Lumia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Lumia == nil {
            let gradient_Lumia = CAGradientLayer()
            gradient_Lumia.frame = gradientRing_Lumia.bounds
            gradient_Lumia.colors = [
                ColorConfig_Lumia.primaryGradientStart_Lumia.withAlphaComponent(0.3).cgColor,
                ColorConfig_Lumia.primaryGradientEnd_Lumia.withAlphaComponent(0.3).cgColor
            ]
            gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
            gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Lumia = gradient_Lumia
            gradientRing_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        } else {
            gradientLayer_Lumia?.frame = gradientRing_Lumia.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Lumia() {
        addSubview(containerView_Lumia)
        containerView_Lumia.addSubview(gradientRing_Lumia)
        containerView_Lumia.addSubview(iconContainer_Lumia)
        iconContainer_Lumia.addSubview(iconView_Lumia)
        
        containerView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Lumia() {
        let tapGesture_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia))
        containerView_Lumia.addGestureRecognizer(tapGesture_Lumia)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Lumia() {
        // 按压动画
        containerView_Lumia.animatePressDown_Lumia {
            self.containerView_Lumia.animatePressUp_Lumia {
                self.onTapped_Lumia?()
            }
        }
        
        // 触觉反馈
        let generator_Lumia = UIImpactFeedbackGenerator(style: .light)
        generator_Lumia.impactOccurred()
    }
}
