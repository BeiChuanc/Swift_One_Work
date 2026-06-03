import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Bague: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Bague: UIView = {
        let view_Bague = UIView()
        view_Bague.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Bague.layer.cornerRadius = 22
        view_Bague.layer.shadowColor = ColorConfig_Bague.shadowColor_Bague.cgColor
        view_Bague.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Bague.layer.shadowRadius = 8
        view_Bague.layer.shadowOpacity = 0.2
        return view_Bague
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Bague: UIView = {
        let view_Bague = UIView()
        view_Bague.layer.cornerRadius = 18
        return view_Bague
    }()
    
    private var gradientLayer_Bague: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Bague: UIView = {
        let view_Bague = UIView()
        view_Bague.backgroundColor = .white
        view_Bague.layer.cornerRadius = 15
        return view_Bague
    }()
    
    private let iconView_Bague: UIImageView = {
        let imageView_Bague = UIImageView()
        imageView_Bague.image = UIImage(systemName: "chevron.left")
        imageView_Bague.tintColor = ColorConfig_Bague.primaryGradientStart_Bague
        imageView_Bague.contentMode = .scaleAspectFit
        return imageView_Bague
    }()
    
    // MARK: - 回调
    
    var onTapped_Bague: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Bague()
        setupActions_Bague()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Bague == nil {
            let gradient_Bague = CAGradientLayer()
            gradient_Bague.frame = gradientRing_Bague.bounds
            gradient_Bague.colors = [
                ColorConfig_Bague.primaryGradientStart_Bague.withAlphaComponent(0.3).cgColor,
                ColorConfig_Bague.primaryGradientEnd_Bague.withAlphaComponent(0.3).cgColor
            ]
            gradient_Bague.startPoint = CGPoint(x: 0, y: 0)
            gradient_Bague.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Bague = gradient_Bague
            gradientRing_Bague.layer.insertSublayer(gradient_Bague, at: 0)
        } else {
            gradientLayer_Bague?.frame = gradientRing_Bague.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Bague() {
        addSubview(containerView_Bague)
        containerView_Bague.addSubview(gradientRing_Bague)
        containerView_Bague.addSubview(iconContainer_Bague)
        iconContainer_Bague.addSubview(iconView_Bague)
        
        containerView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Bague() {
        let tapGesture_Bague = UITapGestureRecognizer(target: self, action: #selector(handleTap_Bague))
        containerView_Bague.addGestureRecognizer(tapGesture_Bague)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Bague() {
        // 按压动画
        containerView_Bague.animatePressDown_Bague {
            self.containerView_Bague.animatePressUp_Bague {
                self.onTapped_Bague?()
            }
        }
        
        // 触觉反馈
        let generator_Bague = UIImpactFeedbackGenerator(style: .light)
        generator_Bague.impactOccurred()
    }
}
