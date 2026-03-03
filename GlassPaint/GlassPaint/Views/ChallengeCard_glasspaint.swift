import Foundation
import UIKit
import SnapKit

// MARK: 挑战卡片视图

/// 挑战卡片视图
/// 功能：展示官方挑战活动
/// 特性：渐变边框、载体图标、参与人数、方案预览
class ChallengeCard_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 卡片容器
    private let cardContainer_Glasspaint = UIView()
    
    /// 渐变边框层
    private let gradientBorderLayer_Glasspaint = CAGradientLayer()
    
    /// 载体图标容器
    private let iconContainer_Glasspaint = UIView()
    
    /// 载体图标
    private let carrierIconView_Glasspaint = UIImageView()
    
    /// 挑战标题
    private let titleLabel_Glasspaint = UILabel()
    
    /// 挑战描述
    private let descriptionLabel_Glasspaint = UILabel()
    
    /// 参与人数标签
    private let participantLabel_Glasspaint = UILabel()
    
    /// 参与按钮
    private let joinButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 数据属性
    
    /// 挑战数据
    private var challenge_Glasspaint: ChallengeModel_Glasspaint?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 卡片容器
        addSubview(cardContainer_Glasspaint)
        cardContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        cardContainer_Glasspaint.layer.cornerRadius = 16
        cardContainer_Glasspaint.layer.masksToBounds = true
        cardContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        cardContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainer_Glasspaint.layer.shadowRadius = 12
        cardContainer_Glasspaint.layer.shadowOpacity = 1.0
        
        // 渐变边框
        gradientBorderLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientBorderLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        cardContainer_Glasspaint.layer.insertSublayer(gradientBorderLayer_Glasspaint, at: 0)
        
        // 图标容器
        cardContainer_Glasspaint.addSubview(iconContainer_Glasspaint)
        iconContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        iconContainer_Glasspaint.layer.cornerRadius = 30
        
        // 载体图标
        iconContainer_Glasspaint.addSubview(carrierIconView_Glasspaint)
        carrierIconView_Glasspaint.contentMode = .scaleAspectFit
        carrierIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 标题
        cardContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.numberOfLines = 2
        
        // 描述
        cardContainer_Glasspaint.addSubview(descriptionLabel_Glasspaint)
        descriptionLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        descriptionLabel_Glasspaint.numberOfLines = 3
        
        // 参与人数
        cardContainer_Glasspaint.addSubview(participantLabel_Glasspaint)
        participantLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        participantLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 参与按钮
        cardContainer_Glasspaint.addSubview(joinButton_Glasspaint)
        joinButton_Glasspaint.setTitle("Join Challenge", for: .normal)
        joinButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        joinButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        joinButton_Glasspaint.setTitleColor(.white, for: .normal)
        joinButton_Glasspaint.layer.cornerRadius = 10
        joinButton_Glasspaint.isUserInteractionEnabled = false
        
        // 布局
        cardContainer_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainer_Glasspaint.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.width.height.equalTo(60)
        }
        
        carrierIconView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(iconContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        descriptionLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        
        participantLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel_Glasspaint.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
        }
        
        joinButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(participantLabel_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - 配置
    
    /// 配置挑战卡片
    /// 参数：
    /// - challenge_glasspaint: 挑战数据
    func configure_Glasspaint(with_glasspaint challenge_glasspaint: ChallengeModel_Glasspaint) {
        self.challenge_Glasspaint = challenge_glasspaint
        
        // 设置标题和描述
        titleLabel_Glasspaint.text = challenge_glasspaint.challengeTitle_Glasspaint
        descriptionLabel_Glasspaint.text = challenge_glasspaint.challengeDescription_Glasspaint
        
        // 设置参与人数
        participantLabel_Glasspaint.text = "\(challenge_glasspaint.participantCount_Glasspaint) participants"
        
        // 设置载体图标和颜色
        configureCarrier_Glasspaint(carrier_glasspaint: challenge_glasspaint.carrier_Glasspaint)
    }
    
    /// 配置载体样式
    /// 参数：
    /// - carrier_glasspaint: 载体类型
    private func configureCarrier_Glasspaint(carrier_glasspaint: CarrierType_Glasspaint) {
        let (icon_glasspaint, startColor_glasspaint, endColor_glasspaint): (String, UIColor, UIColor)
        
        switch carrier_glasspaint {
        case .glassCup_glasspaint:
            icon_glasspaint = "cup.and.saucer.fill"
            startColor_glasspaint = ColorConfig_Glasspaint.carrierGlassCupColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint
            
        case .glassPlate_glasspaint:
            icon_glasspaint = "circle.fill"
            startColor_glasspaint = ColorConfig_Glasspaint.carrierGlassPlateColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.textSecondary_Glasspaint
            
        case .ornament_glasspaint:
            icon_glasspaint = "gift.fill"
            startColor_glasspaint = ColorConfig_Glasspaint.carrierOrnamentColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint
            
        case .vase_glasspaint:
            icon_glasspaint = "leaf.fill"
            startColor_glasspaint = ColorConfig_Glasspaint.carrierVaseColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
            
        case .window_glasspaint:
            icon_glasspaint = "square.fill"
            startColor_glasspaint = ColorConfig_Glasspaint.carrierWindowColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        }
        
        carrierIconView_Glasspaint.image = UIImage(systemName: icon_glasspaint)
        carrierIconView_Glasspaint.tintColor = startColor_glasspaint
        
        // 设置渐变边框
        gradientBorderLayer_Glasspaint.colors = [
            startColor_glasspaint.cgColor,
            endColor_glasspaint.cgColor
        ]
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer_Glasspaint.frame = cardContainer_Glasspaint.bounds
    }
}
