import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Epoch: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Epoch.layer.cornerRadius = 22
        view_Epoch.layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        view_Epoch.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Epoch.layer.shadowRadius = 8
        view_Epoch.layer.shadowOpacity = 0.2
        return view_Epoch
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.layer.cornerRadius = 18
        return view_Epoch
    }()
    
    private var gradientLayer_Epoch: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = .white
        view_Epoch.layer.cornerRadius = 15
        return view_Epoch
    }()
    
    private let iconView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.image = UIImage(systemName: "chevron.left")
        imageView_Epoch.tintColor = ColorConfig_Epoch.primaryGradientStart_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()
    
    // MARK: - 回调
    
    var onTapped_Epoch: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
        setupActions_Epoch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Epoch == nil {
            let gradient_Epoch = CAGradientLayer()
            gradient_Epoch.frame = gradientRing_Epoch.bounds
            gradient_Epoch.colors = [
                ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.3).cgColor,
                ColorConfig_Epoch.primaryGradientEnd_Epoch.withAlphaComponent(0.3).cgColor
            ]
            gradient_Epoch.startPoint = CGPoint(x: 0, y: 0)
            gradient_Epoch.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Epoch = gradient_Epoch
            gradientRing_Epoch.layer.insertSublayer(gradient_Epoch, at: 0)
        } else {
            gradientLayer_Epoch?.frame = gradientRing_Epoch.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Epoch() {
        addSubview(containerView_Epoch)
        containerView_Epoch.addSubview(gradientRing_Epoch)
        containerView_Epoch.addSubview(iconContainer_Epoch)
        iconContainer_Epoch.addSubview(iconView_Epoch)
        
        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Epoch() {
        let tapGesture_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleTap_Epoch))
        containerView_Epoch.addGestureRecognizer(tapGesture_Epoch)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Epoch() {
        // 按压动画
        containerView_Epoch.animatePressDown_Epoch {
            self.containerView_Epoch.animatePressUp_Epoch {
                self.onTapped_Epoch?()
            }
        }
        
        // 触觉反馈
        let generator_Epoch = UIImpactFeedbackGenerator(style: .light)
        generator_Epoch.impactOccurred()
    }
}
