import Foundation
import UIKit
import SnapKit

// MARK: 空状态类型枚举

/// 空状态类型枚举
/// 功能：定义不同场景的空状态展示
enum EmptyStateType_Glasspaint {
    /// 无推荐
    case noRecommendations_glasspaint
    /// 无时光轴
    case noTimeline_glasspaint
    /// 无挑战
    case noChallenges_glasspaint
    /// 无作品
    case noPosts_glasspaint
    /// 自定义
    case custom_glasspaint(String, String)
}

// MARK: 空状态视图

/// 空状态视图
/// 功能：显示无数据时的占位界面
/// 特性：图标、提示文字、可自定义
class EmptyStateView_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 图标容器
    private let iconContainerView_Glasspaint = UIView()
    
    /// 图标
    private let iconImageView_Glasspaint = UIImageView()
    
    /// 标题标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 描述标签
    private let descriptionLabel_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    /// 空状态类型
    private var stateType_Glasspaint: EmptyStateType_Glasspaint?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Glasspaint()
    }
    
    /// 便捷初始化
    /// 参数：
    /// - stateType_glasspaint: 空状态类型
    convenience init(stateType_glasspaint: EmptyStateType_Glasspaint) {
        self.init(frame: .zero)
        self.stateType_Glasspaint = stateType_glasspaint
        configure_Glasspaint(with_glasspaint: stateType_glasspaint)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        backgroundColor = .clear
        
        // 图标容器（添加渐变背景）
        addSubview(iconContainerView_Glasspaint)
        iconContainerView_Glasspaint.layer.cornerRadius = 50
        iconContainerView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        iconContainerView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        iconContainerView_Glasspaint.layer.shadowRadius = 16
        iconContainerView_Glasspaint.layer.shadowOpacity = 0.3
        
        // 添加渐变背景
        let iconGradient_glasspaint = CAGradientLayer()
        iconGradient_glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.1).cgColor
        ]
        iconGradient_glasspaint.startPoint = CGPoint(x: 0, y: 0)
        iconGradient_glasspaint.endPoint = CGPoint(x: 1, y: 1)
        iconGradient_glasspaint.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        iconGradient_glasspaint.cornerRadius = 50
        iconContainerView_Glasspaint.layer.insertSublayer(iconGradient_glasspaint, at: 0)
        
        // 图标
        iconContainerView_Glasspaint.addSubview(iconImageView_Glasspaint)
        iconImageView_Glasspaint.contentMode = .scaleAspectFit
        iconImageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
        
        // 标题
        addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.textAlignment = .center
        titleLabel_Glasspaint.numberOfLines = 0
        
        // 描述
        addSubview(descriptionLabel_Glasspaint)
        descriptionLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        descriptionLabel_Glasspaint.textAlignment = .center
        descriptionLabel_Glasspaint.numberOfLines = 0
        
        // 布局
        iconContainerView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(100)
        }
        
        iconImageView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconContainerView_Glasspaint.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        descriptionLabel_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - 配置
    
    /// 配置空状态
    /// 参数：
    /// - stateType_glasspaint: 空状态类型
    func configure_Glasspaint(with_glasspaint stateType_glasspaint: EmptyStateType_Glasspaint) {
        self.stateType_Glasspaint = stateType_glasspaint
        
        switch stateType_glasspaint {
        case .noRecommendations_glasspaint:
            configureNoRecommendations_Glasspaint()
            
        case .noTimeline_glasspaint:
            configureNoTimeline_Glasspaint()
            
        case .noChallenges_glasspaint:
            configureNoChallenges_Glasspaint()
            
        case .noPosts_glasspaint:
            configureNoPosts_Glasspaint()
            
        case .custom_glasspaint(let title_glasspaint, let description_glasspaint):
            configureCustom_Glasspaint(title_glasspaint: title_glasspaint, description_glasspaint: description_glasspaint)
        }
        
        // 添加入场动画
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        animateFadeIn_Glasspaint()
    }
    
    /// 配置无推荐状态
    private func configureNoRecommendations_Glasspaint() {
        iconImageView_Glasspaint.image = UIImage(systemName: "sparkles")
        titleLabel_Glasspaint.text = "No Recommendations Yet"
        descriptionLabel_Glasspaint.text = "Start creating your glass paintings to get personalized recommendations based on your style and skills"
    }
    
    /// 配置无时光轴状态
    private func configureNoTimeline_Glasspaint() {
        iconImageView_Glasspaint.image = UIImage(systemName: "clock.fill")
        titleLabel_Glasspaint.text = "No Timeline Yet"
        descriptionLabel_Glasspaint.text = "Start your glass painting journey! Create and collect artworks to build your personal timeline"
    }
    
    /// 配置无挑战状态
    private func configureNoChallenges_Glasspaint() {
        iconImageView_Glasspaint.image = UIImage(systemName: "trophy.fill")
        titleLabel_Glasspaint.text = "No Challenges Available"
        descriptionLabel_Glasspaint.text = "New challenges are coming soon! Check back later for exciting glass painting challenges"
    }
    
    /// 配置无作品状态
    private func configureNoPosts_Glasspaint() {
        iconImageView_Glasspaint.image = UIImage(systemName: "photo.fill")
        titleLabel_Glasspaint.text = "No Artworks Found"
        descriptionLabel_Glasspaint.text = "Be the first to share your glass painting masterpiece with the community"
    }
    
    /// 配置自定义状态
    private func configureCustom_Glasspaint(title_glasspaint: String, description_glasspaint: String) {
        iconImageView_Glasspaint.image = UIImage(systemName: "exclamationmark.circle.fill")
        titleLabel_Glasspaint.text = title_glasspaint
        descriptionLabel_Glasspaint.text = description_glasspaint
    }
    
}
