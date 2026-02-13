import Foundation
import UIKit
import SnapKit

// MARK: 标签类型枚举

/// 标签类型枚举
/// 功能：定义标签的展示类型
enum TagType_Glasspaint {
    /// 难度标签
    case level_glasspaint(PaintingLevel_Glasspaint)
    /// 风格标签
    case style_glasspaint(PaintingStyle_Glasspaint)
    /// 场景标签
    case scene_glasspaint(String)
    /// 载体标签
    case carrier_glasspaint(CarrierType_Glasspaint)
    /// 自定义标签
    case custom_glasspaint(String, UIColor)
}

// MARK: 彩绘标签视图

/// 彩绘标签视图
/// 功能：显示难度、风格、场景等标签信息
/// 特性：自适应宽度、渐变背景、图标支持、点击交互
class PaintingTagView_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 容器视图
    private let containerView_Glasspaint = UIView()
    
    /// 图标
    private let iconImageView_Glasspaint = UIImageView()
    
    /// 文字标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 渐变层
    private let gradientLayer_Glasspaint = CAGradientLayer()
    
    // MARK: - 数据属性
    
    /// 标签类型
    private var tagType_Glasspaint: TagType_Glasspaint?
    
    /// 点击回调
    var onTap_Glasspaint: (() -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
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
    /// - tagType_glasspaint: 标签类型
    convenience init(tagType_glasspaint: TagType_Glasspaint) {
        self.init(frame: .zero)
        self.tagType_Glasspaint = tagType_glasspaint
        configure_Glasspaint(with_glasspaint: tagType_glasspaint)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 容器视图
        addSubview(containerView_Glasspaint)
        containerView_Glasspaint.layer.cornerRadius = 8
        containerView_Glasspaint.layer.masksToBounds = true
        
        // 图标
        containerView_Glasspaint.addSubview(iconImageView_Glasspaint)
        iconImageView_Glasspaint.contentMode = .scaleAspectFit
        iconImageView_Glasspaint.tintColor = .white
        
        // 文字
        containerView_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel_Glasspaint.textColor = .white
        titleLabel_Glasspaint.adjustsFontSizeToFitWidth = false
        titleLabel_Glasspaint.lineBreakMode = .byTruncatingTail
        titleLabel_Glasspaint.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // 布局
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(26)
        }
        
        iconImageView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_Glasspaint.snp.right).offset(4)
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleTap_Glasspaint))
        addGestureRecognizer(tapGesture_glasspaint)
        isUserInteractionEnabled = true
    }
    
    // MARK: - 配置
    
    /// 配置标签
    /// 参数：
    /// - tagType_glasspaint: 标签类型
    func configure_Glasspaint(with_glasspaint tagType_glasspaint: TagType_Glasspaint) {
        self.tagType_Glasspaint = tagType_glasspaint
        
        switch tagType_glasspaint {
        case .level_glasspaint(let level_glasspaint):
            configureLevelTag_Glasspaint(level_glasspaint: level_glasspaint)
            
        case .style_glasspaint(let style_glasspaint):
            configureStyleTag_Glasspaint(style_glasspaint: style_glasspaint)
            
        case .scene_glasspaint(let scene_glasspaint):
            configureSceneTag_Glasspaint(scene_glasspaint: scene_glasspaint)
            
        case .carrier_glasspaint(let carrier_glasspaint):
            configureCarrierTag_Glasspaint(carrier_glasspaint: carrier_glasspaint)
            
        case .custom_glasspaint(let text_glasspaint, let color_glasspaint):
            configureCustomTag_Glasspaint(text_glasspaint: text_glasspaint, color_glasspaint: color_glasspaint)
        }
        
        // 设置约束
        snp.makeConstraints { make in
            make.height.equalTo(28)
        }
    }
    
    /// 配置难度标签
    private func configureLevelTag_Glasspaint(level_glasspaint: PaintingLevel_Glasspaint) {
        titleLabel_Glasspaint.text = level_glasspaint.rawValue
        iconImageView_Glasspaint.image = UIImage(systemName: "star.fill")
        
        let color_glasspaint: UIColor
        switch level_glasspaint {
        case .beginner_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.levelBeginnerColor_Glasspaint
        case .intermediate_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint
        case .advanced_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint
        }
        
        setBackgroundColor_Glasspaint(color_glasspaint: color_glasspaint)
    }
    
    /// 配置风格标签
    private func configureStyleTag_Glasspaint(style_glasspaint: PaintingStyle_Glasspaint) {
        titleLabel_Glasspaint.text = style_glasspaint.rawValue
        iconImageView_Glasspaint.image = UIImage(systemName: "paintbrush.fill")
        
        let color_glasspaint: UIColor
        switch style_glasspaint {
        case .minimalist_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.styleMinimalistColor_Glasspaint
        case .retro_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.styleRetroColor_Glasspaint
        case .cute_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.styleCuteColor_Glasspaint
        case .modern_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.styleModernColor_Glasspaint
        case .artistic_glasspaint:
            color_glasspaint = ColorConfig_Glasspaint.styleArtisticColor_Glasspaint
        }
        
        setBackgroundColor_Glasspaint(color_glasspaint: color_glasspaint)
    }
    
    /// 配置场景标签
    private func configureSceneTag_Glasspaint(scene_glasspaint: String) {
        titleLabel_Glasspaint.text = scene_glasspaint
        iconImageView_Glasspaint.image = UIImage(systemName: "house.fill")
        
        setBackgroundColor_Glasspaint(color_glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint)
    }
    
    /// 配置载体标签
    private func configureCarrierTag_Glasspaint(carrier_glasspaint: CarrierType_Glasspaint) {
        titleLabel_Glasspaint.text = carrier_glasspaint.rawValue
        
        let (icon_glasspaint, color_glasspaint): (String, UIColor)
        switch carrier_glasspaint {
        case .glassCup_glasspaint:
            icon_glasspaint = "cup.and.saucer.fill"
            color_glasspaint = ColorConfig_Glasspaint.carrierGlassCupColor_Glasspaint
        case .glassPlate_glasspaint:
            icon_glasspaint = "circle.fill"
            color_glasspaint = ColorConfig_Glasspaint.carrierGlassPlateColor_Glasspaint
        case .ornament_glasspaint:
            icon_glasspaint = "gift.fill"
            color_glasspaint = ColorConfig_Glasspaint.carrierOrnamentColor_Glasspaint
        case .vase_glasspaint:
            icon_glasspaint = "leaf.fill"
            color_glasspaint = ColorConfig_Glasspaint.carrierVaseColor_Glasspaint
        case .window_glasspaint:
            icon_glasspaint = "square.fill"
            color_glasspaint = ColorConfig_Glasspaint.carrierWindowColor_Glasspaint
        }
        
        iconImageView_Glasspaint.image = UIImage(systemName: icon_glasspaint)
        setBackgroundColor_Glasspaint(color_glasspaint: color_glasspaint)
    }
    
    /// 配置自定义标签
    private func configureCustomTag_Glasspaint(text_glasspaint: String, color_glasspaint: UIColor) {
        titleLabel_Glasspaint.text = text_glasspaint
        iconImageView_Glasspaint.image = UIImage(systemName: "tag.fill")
        setBackgroundColor_Glasspaint(color_glasspaint: color_glasspaint)
    }
    
    /// 设置背景颜色（带渐变效果）
    private func setBackgroundColor_Glasspaint(color_glasspaint: UIColor) {
        containerView_Glasspaint.backgroundColor = color_glasspaint
    }
    
    // MARK: - 交互
    
    /// 处理点击事件
    @objc private func handleTap_Glasspaint() {
        // 点击动画
        animatePressDown_Glasspaint {
            self.animatePressUp_Glasspaint()
        }
        
        // 触发回调
        onTap_Glasspaint?()
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Glasspaint.frame = containerView_Glasspaint.bounds
    }
}
