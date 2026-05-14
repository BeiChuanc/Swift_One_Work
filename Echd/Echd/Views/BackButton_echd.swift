import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Echd: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Echd.layer.cornerRadius = 22
        view_Echd.layer.shadowColor = ColorConfig_Echd.shadowColor_Echd.cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Echd.layer.shadowRadius = 8
        view_Echd.layer.shadowOpacity = 0.2
        return view_Echd
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 18
        return view_Echd
    }()
    
    private var gradientLayer_Echd: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 15
        return view_Echd
    }()
    
    private let iconView_Echd: UIImageView = {
        let imageView_Echd = UIImageView()
        imageView_Echd.image = UIImage(systemName: "chevron.left")
        imageView_Echd.tintColor = ColorConfig_Echd.primaryGradientStart_Echd
        imageView_Echd.contentMode = .scaleAspectFit
        return imageView_Echd
    }()
    
    // MARK: - 回调
    
    var onTapped_Echd: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Echd()
        setupActions_Echd()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Echd == nil {
            let gradient_Echd = CAGradientLayer()
            gradient_Echd.frame = gradientRing_Echd.bounds
            gradient_Echd.colors = [
                ColorConfig_Echd.primaryGradientStart_Echd.withAlphaComponent(0.3).cgColor,
                ColorConfig_Echd.primaryGradientEnd_Echd.withAlphaComponent(0.3).cgColor
            ]
            gradient_Echd.startPoint = CGPoint(x: 0, y: 0)
            gradient_Echd.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Echd = gradient_Echd
            gradientRing_Echd.layer.insertSublayer(gradient_Echd, at: 0)
        } else {
            gradientLayer_Echd?.frame = gradientRing_Echd.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Echd() {
        addSubview(containerView_Echd)
        containerView_Echd.addSubview(gradientRing_Echd)
        containerView_Echd.addSubview(iconContainer_Echd)
        iconContainer_Echd.addSubview(iconView_Echd)
        
        containerView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Echd() {
        let tapGesture_Echd = UITapGestureRecognizer(target: self, action: #selector(handleTap_Echd))
        containerView_Echd.addGestureRecognizer(tapGesture_Echd)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Echd() {
        // 按压动画
        containerView_Echd.animatePressDown_Echd {
            self.containerView_Echd.animatePressUp_Echd {
                self.onTapped_Echd?()
            }
        }
        
        // 触觉反馈
        let generator_Echd = UIImpactFeedbackGenerator(style: .light)
        generator_Echd.impactOccurred()
    }
}
