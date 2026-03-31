import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Sprig: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Sprig.layer.cornerRadius = 22
        view_Sprig.layer.shadowColor = ColorConfig_Sprig.shadowColor_Sprig.cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Sprig.layer.shadowRadius = 8
        view_Sprig.layer.shadowOpacity = 0.2
        return view_Sprig
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.layer.cornerRadius = 18
        return view_Sprig
    }()
    
    private var gradientLayer_Sprig: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = .white
        view_Sprig.layer.cornerRadius = 15
        return view_Sprig
    }()
    
    private let iconView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.image = UIImage(systemName: "chevron.left")
        imageView_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        imageView_Sprig.contentMode = .scaleAspectFit
        return imageView_Sprig
    }()
    
    // MARK: - 回调
    
    var onTapped_Sprig: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sprig()
        setupActions_Sprig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Sprig == nil {
            let gradient_Sprig = CAGradientLayer()
            gradient_Sprig.frame = gradientRing_Sprig.bounds
            gradient_Sprig.colors = [
                ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.3).cgColor,
                ColorConfig_Sprig.primaryGradientEnd_Sprig.withAlphaComponent(0.3).cgColor
            ]
            gradient_Sprig.startPoint = CGPoint(x: 0, y: 0)
            gradient_Sprig.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Sprig = gradient_Sprig
            gradientRing_Sprig.layer.insertSublayer(gradient_Sprig, at: 0)
        } else {
            gradientLayer_Sprig?.frame = gradientRing_Sprig.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Sprig() {
        addSubview(containerView_Sprig)
        containerView_Sprig.addSubview(gradientRing_Sprig)
        containerView_Sprig.addSubview(iconContainer_Sprig)
        iconContainer_Sprig.addSubview(iconView_Sprig)
        
        containerView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Sprig() {
        let tapGesture_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sprig))
        containerView_Sprig.addGestureRecognizer(tapGesture_Sprig)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Sprig() {
        // 按压动画
        containerView_Sprig.animatePressDown_Sprig {
            self.containerView_Sprig.animatePressUp_Sprig {
                self.onTapped_Sprig?()
            }
        }
        
        // 触觉反馈
        let generator_Sprig = UIImpactFeedbackGenerator(style: .light)
        generator_Sprig.impactOccurred()
    }
}
