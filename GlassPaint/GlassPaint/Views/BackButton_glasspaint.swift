import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Glasspaint: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Glasspaint.layer.cornerRadius = 22
        view_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        view_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Glasspaint.layer.shadowRadius = 8
        view_Glasspaint.layer.shadowOpacity = 0.2
        return view_Glasspaint
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.layer.cornerRadius = 18
        return view_Glasspaint
    }()
    
    private var gradientLayer_Glasspaint: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .white
        view_Glasspaint.layer.cornerRadius = 15
        return view_Glasspaint
    }()
    
    private let iconView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.image = UIImage(systemName: "chevron.left")
        imageView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        imageView_Glasspaint.contentMode = .scaleAspectFit
        return imageView_Glasspaint
    }()
    
    // MARK: - 回调
    
    var onTapped_Glasspaint: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
        setupActions_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Glasspaint == nil {
            let gradient_Glasspaint = CAGradientLayer()
            gradient_Glasspaint.frame = gradientRing_Glasspaint.bounds
            gradient_Glasspaint.colors = [
                ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor,
                ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.3).cgColor
            ]
            gradient_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
            gradient_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Glasspaint = gradient_Glasspaint
            gradientRing_Glasspaint.layer.insertSublayer(gradient_Glasspaint, at: 0)
        } else {
            gradientLayer_Glasspaint?.frame = gradientRing_Glasspaint.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Glasspaint() {
        addSubview(containerView_Glasspaint)
        containerView_Glasspaint.addSubview(gradientRing_Glasspaint)
        containerView_Glasspaint.addSubview(iconContainer_Glasspaint)
        iconContainer_Glasspaint.addSubview(iconView_Glasspaint)
        
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Glasspaint() {
        let tapGesture_Glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleTap_Glasspaint))
        containerView_Glasspaint.addGestureRecognizer(tapGesture_Glasspaint)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Glasspaint() {
        // 按压动画
        containerView_Glasspaint.animatePressDown_Glasspaint {
            self.containerView_Glasspaint.animatePressUp_Glasspaint {
                self.onTapped_Glasspaint?()
            }
        }
        
        // 触觉反馈
        let generator_Glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_Glasspaint.impactOccurred()
    }
}
