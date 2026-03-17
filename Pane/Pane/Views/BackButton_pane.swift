import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Pane: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Pane.layer.cornerRadius = 22
        view_Pane.layer.shadowColor = ColorConfig_Pane.shadowColor_Pane.cgColor
        view_Pane.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Pane.layer.shadowRadius = 8
        view_Pane.layer.shadowOpacity = 0.2
        return view_Pane
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.layer.cornerRadius = 18
        return view_Pane
    }()
    
    private var gradientLayer_Pane: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.backgroundColor = .white
        view_Pane.layer.cornerRadius = 15
        return view_Pane
    }()
    
    private let iconView_Pane: UIImageView = {
        let imageView_Pane = UIImageView()
        imageView_Pane.image = UIImage(systemName: "chevron.left")
        imageView_Pane.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        imageView_Pane.contentMode = .scaleAspectFit
        return imageView_Pane
    }()
    
    // MARK: - 回调
    
    var onTapped_Pane: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        setupActions_Pane()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Pane == nil {
            let gradient_Pane = CAGradientLayer()
            gradient_Pane.frame = gradientRing_Pane.bounds
            gradient_Pane.colors = [
                ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.3).cgColor,
                ColorConfig_Pane.primaryGradientEnd_Pane.withAlphaComponent(0.3).cgColor
            ]
            gradient_Pane.startPoint = CGPoint(x: 0, y: 0)
            gradient_Pane.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Pane = gradient_Pane
            gradientRing_Pane.layer.insertSublayer(gradient_Pane, at: 0)
        } else {
            gradientLayer_Pane?.frame = gradientRing_Pane.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Pane() {
        addSubview(containerView_Pane)
        containerView_Pane.addSubview(gradientRing_Pane)
        containerView_Pane.addSubview(iconContainer_Pane)
        iconContainer_Pane.addSubview(iconView_Pane)
        
        containerView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Pane() {
        let tapGesture_Pane = UITapGestureRecognizer(target: self, action: #selector(handleTap_Pane))
        containerView_Pane.addGestureRecognizer(tapGesture_Pane)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Pane() {
        // 按压动画
        containerView_Pane.animatePressDown_Pane {
            self.containerView_Pane.animatePressUp_Pane {
                self.onTapped_Pane?()
            }
        }
        
        // 触觉反馈
        let generator_Pane = UIImpactFeedbackGenerator(style: .light)
        generator_Pane.impactOccurred()
    }
}
