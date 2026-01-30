import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Base_one: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Base_one.layer.cornerRadius = 22
        view_Base_one.layer.shadowColor = ColorConfig_Base_one.shadowColor_Base_one.cgColor
        view_Base_one.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Base_one.layer.shadowRadius = 8
        view_Base_one.layer.shadowOpacity = 0.2
        return view_Base_one
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.layer.cornerRadius = 18
        return view_Base_one
    }()
    
    private var gradientLayer_Base_one: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.backgroundColor = .white
        view_Base_one.layer.cornerRadius = 15
        return view_Base_one
    }()
    
    private let iconView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.image = UIImage(systemName: "chevron.left")
        imageView_Base_one.tintColor = ColorConfig_Base_one.primaryGradientStart_Base_one
        imageView_Base_one.contentMode = .scaleAspectFit
        return imageView_Base_one
    }()
    
    // MARK: - 回调
    
    var onTapped_Base_one: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
        setupActions_Base_one()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Base_one == nil {
            let gradient_Base_one = CAGradientLayer()
            gradient_Base_one.frame = gradientRing_Base_one.bounds
            gradient_Base_one.colors = [
                ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.3).cgColor,
                ColorConfig_Base_one.primaryGradientEnd_Base_one.withAlphaComponent(0.3).cgColor
            ]
            gradient_Base_one.startPoint = CGPoint(x: 0, y: 0)
            gradient_Base_one.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Base_one = gradient_Base_one
            gradientRing_Base_one.layer.insertSublayer(gradient_Base_one, at: 0)
        } else {
            gradientLayer_Base_one?.frame = gradientRing_Base_one.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Base_one() {
        addSubview(containerView_Base_one)
        containerView_Base_one.addSubview(gradientRing_Base_one)
        containerView_Base_one.addSubview(iconContainer_Base_one)
        iconContainer_Base_one.addSubview(iconView_Base_one)
        
        containerView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Base_one() {
        let tapGesture_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleTap_Base_one))
        containerView_Base_one.addGestureRecognizer(tapGesture_Base_one)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Base_one() {
        // 按压动画
        containerView_Base_one.animatePressDown_Base_one {
            self.containerView_Base_one.animatePressUp_Base_one {
                self.onTapped_Base_one?()
            }
        }
        
        // 触觉反馈
        let generator_Base_one = UIImpactFeedbackGenerator(style: .light)
        generator_Base_one.impactOccurred()
    }
}
