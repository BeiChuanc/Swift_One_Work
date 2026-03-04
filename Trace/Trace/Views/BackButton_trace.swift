import Foundation
import UIKit
import SnapKit

// MARK: 返回按钮组件

/// 返回按钮组件
/// 功能：现代化的返回按钮，带图标和文字
/// 设计：圆角卡片、图标、渐变背景、动画效果
class BackButton_Trace: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_Trace.layer.cornerRadius = 22
        view_Trace.layer.shadowColor = ColorConfig_Trace.shadowColor_Trace.cgColor
        view_Trace.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Trace.layer.shadowRadius = 8
        view_Trace.layer.shadowOpacity = 0.2
        return view_Trace
    }()
    
    /// 渐变装饰圆环
    private let gradientRing_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.layer.cornerRadius = 18
        return view_Trace
    }()
    
    private var gradientLayer_Trace: CAGradientLayer?
    
    /// 图标容器
    private let iconContainer_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.backgroundColor = .white
        view_Trace.layer.cornerRadius = 15
        return view_Trace
    }()
    
    private let iconView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.image = UIImage(systemName: "chevron.left")
        imageView_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        imageView_Trace.contentMode = .scaleAspectFit
        return imageView_Trace
    }()
    
    // MARK: - 回调
    
    var onTapped_Trace: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
        setupActions_Trace()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 创建渐变图层
        if gradientLayer_Trace == nil {
            let gradient_Trace = CAGradientLayer()
            gradient_Trace.frame = gradientRing_Trace.bounds
            gradient_Trace.colors = [
                ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.3).cgColor,
                ColorConfig_Trace.primaryGradientEnd_Trace.withAlphaComponent(0.3).cgColor
            ]
            gradient_Trace.startPoint = CGPoint(x: 0, y: 0)
            gradient_Trace.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Trace = gradient_Trace
            gradientRing_Trace.layer.insertSublayer(gradient_Trace, at: 0)
        } else {
            gradientLayer_Trace?.frame = gradientRing_Trace.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Trace() {
        addSubview(containerView_Trace)
        containerView_Trace.addSubview(gradientRing_Trace)
        containerView_Trace.addSubview(iconContainer_Trace)
        iconContainer_Trace.addSubview(iconView_Trace)
        
        containerView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientRing_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        iconContainer_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        iconView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    private func setupActions_Trace() {
        let tapGesture_Trace = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        containerView_Trace.addGestureRecognizer(tapGesture_Trace)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Trace() {
        // 按压动画
        containerView_Trace.animatePressDown_Trace {
            self.containerView_Trace.animatePressUp_Trace {
                self.onTapped_Trace?()
            }
        }
        
        // 触觉反馈
        let generator_Trace = UIImpactFeedbackGenerator(style: .light)
        generator_Trace.impactOccurred()
    }
}
