import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Vestir: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Vestir: UIView = {
        let view_Vestir = UIView()
        view_Vestir.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Vestir.layer.cornerRadius = 22
        view_Vestir.layer.shadowColor = ColorConfig_Vestir.shadowColor_Vestir.cgColor
        view_Vestir.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Vestir.layer.shadowRadius = 8
        view_Vestir.layer.shadowOpacity = 0.2
        return view_Vestir
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Vestir: UIView = {
        let view_Vestir = UIView()
        view_Vestir.layer.cornerRadius = 18
        return view_Vestir
    }()
    
    private var gradientLayer_Vestir: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Vestir: UIView = {
        let view_Vestir = UIView()
        view_Vestir.backgroundColor = .white
        view_Vestir.layer.cornerRadius = 15
        return view_Vestir
    }()
    
    private let iconView_Vestir: UIImageView = {
        let imageView_Vestir = UIImageView()
        imageView_Vestir.image = UIImage(systemName: "chevron.left")
        imageView_Vestir.tintColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        imageView_Vestir.contentMode = .scaleAspectFit
        return imageView_Vestir
    }()
    
    // MARK: - 回调
    
    var onTapped_Vestir: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Vestir()
        setupActions_Vestir()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Vestir == nil {
            let gradient_Vestir = CAGradientLayer()
            gradient_Vestir.frame = gradientRing_Vestir.bounds
            gradient_Vestir.colors = [
                ColorConfig_Vestir.primaryGradientStart_Vestir.withAlphaComponent(0.3).cgColor,
                ColorConfig_Vestir.primaryGradientEnd_Vestir.withAlphaComponent(0.3).cgColor
            ]
            gradient_Vestir.startPoint = CGPoint(x: 0, y: 0)
            gradient_Vestir.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Vestir = gradient_Vestir
            gradientRing_Vestir.layer.insertSublayer(gradient_Vestir, at: 0)
        } else {
            gradientLayer_Vestir?.frame = gradientRing_Vestir.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Vestir() {
        addSubview(containerView_Vestir)
        containerView_Vestir.addSubview(gradientRing_Vestir)
        containerView_Vestir.addSubview(iconContainer_Vestir)
        iconContainer_Vestir.addSubview(iconView_Vestir)
        
        containerView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Vestir() {
        let tapGesture_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleTap_Vestir))
        containerView_Vestir.addGestureRecognizer(tapGesture_Vestir)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Vestir() {
        // 按压动画
        containerView_Vestir.animatePressDown_Vestir {
            self.containerView_Vestir.animatePressUp_Vestir {
                self.onTapped_Vestir?()
            }
        }
        
        // 触觉反馈
        let generator_Vestir = UIImpactFeedbackGenerator(style: .light)
        generator_Vestir.impactOccurred()
    }
}
