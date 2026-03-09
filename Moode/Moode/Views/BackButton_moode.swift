import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Moode: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Moode.layer.cornerRadius = 22
        view_Moode.layer.shadowColor = ColorConfig_Moode.shadowColor_Moode.cgColor
        view_Moode.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Moode.layer.shadowRadius = 8
        view_Moode.layer.shadowOpacity = 0.2
        return view_Moode
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.layer.cornerRadius = 18
        return view_Moode
    }()
    
    private var gradientLayer_Moode: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = .white
        view_Moode.layer.cornerRadius = 15
        return view_Moode
    }()
    
    private let iconView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.image = UIImage(systemName: "chevron.left")
        imageView_Moode.tintColor = ColorConfig_Moode.primaryGradientStart_Moode
        imageView_Moode.contentMode = .scaleAspectFit
        return imageView_Moode
    }()
    
    // MARK: - 回调
    
    var onTapped_Moode: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
        setupActions_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Moode == nil {
            let gradient_Moode = CAGradientLayer()
            gradient_Moode.frame = gradientRing_Moode.bounds
            gradient_Moode.colors = [
                ColorConfig_Moode.primaryGradientStart_Moode.withAlphaComponent(0.3).cgColor,
                ColorConfig_Moode.primaryGradientEnd_Moode.withAlphaComponent(0.3).cgColor
            ]
            gradient_Moode.startPoint = CGPoint(x: 0, y: 0)
            gradient_Moode.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Moode = gradient_Moode
            gradientRing_Moode.layer.insertSublayer(gradient_Moode, at: 0)
        } else {
            gradientLayer_Moode?.frame = gradientRing_Moode.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Moode() {
        addSubview(containerView_Moode)
        containerView_Moode.addSubview(gradientRing_Moode)
        containerView_Moode.addSubview(iconContainer_Moode)
        iconContainer_Moode.addSubview(iconView_Moode)
        
        containerView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Moode() {
        let tapGesture_Moode = UITapGestureRecognizer(target: self, action: #selector(handleTap_Moode))
        containerView_Moode.addGestureRecognizer(tapGesture_Moode)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Moode() {
        // 按压动画
        containerView_Moode.animatePressDown_Moode {
            self.containerView_Moode.animatePressUp_Moode {
                self.onTapped_Moode?()
            }
        }
        
        // 触觉反馈
        let generator_Moode = UIImpactFeedbackGenerator(style: .light)
        generator_Moode.impactOccurred()
    }
}
