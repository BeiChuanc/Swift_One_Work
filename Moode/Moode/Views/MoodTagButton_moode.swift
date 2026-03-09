import Foundation
import UIKit
import SnapKit

// MARK: - 情绪标签按钮通用组件

/// 情绪标签按钮组件
/// 功能：用于首页/发现页的情绪过滤筛选，展示单个情绪类型的 Emoji 和名称
/// 设计思路：未选中态为浅色圆角胶囊，选中态切换为情绪专属渐变背景，附带 spring 弹性动画
/// 关键属性：moodType_Moode 设置情绪类型；isSelectedMood_Moode 控制选中状态
class MoodTagButton_Moode: UIView {
    
    // MARK: - UI 组件
    
    /// 背景容器（圆角胶囊）
    private let containerView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.layer.cornerRadius = 18
        view_Moode.clipsToBounds = true
        return view_Moode
    }()
    
    /// 选中态渐变图层（默认隐藏）
    private var gradientLayer_Moode: CAGradientLayer?
    
    /// 未选中态背景色层
    private let normalBgView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = UIColor(hexstring_Moode: "#F0F4FF")
        return view_Moode
    }()
    
    /// Emoji 标签
    private let emojiLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 16)
        label_Moode.textAlignment = .center
        return label_Moode
    }()
    
    /// 情绪名称标签
    private let nameLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 12, weight: .semibold)
        label_Moode.textAlignment = .center
        return label_Moode
    }()
    
    // MARK: - 属性
    
    /// 绑定的情绪类型
    var moodType_Moode: MoodType_Moode? {
        didSet { refreshContent_Moode() }
    }
    
    /// 选中状态（含过渡动画）
    var isSelectedMood_Moode: Bool = false {
        didSet { updateSelectionStyle_Moode(animated_Moode: true) }
    }
    
    /// 点击回调
    var onTapped_Moode: ((MoodType_Moode?) -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
        setupGesture_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Moode?.frame = containerView_Moode.bounds
        normalBgView_Moode.frame = containerView_Moode.bounds
    }
    
    // MARK: - UI 构建
    
    /// 构建内部布局
    private func setupUI_Moode() {
        addSubview(containerView_Moode)
        containerView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView_Moode.addSubview(normalBgView_Moode)
        
        containerView_Moode.addSubview(emojiLabel_Moode)
        emojiLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        containerView_Moode.addSubview(nameLabel_Moode)
        nameLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(emojiLabel_Moode.snp.right).offset(4)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        updateSelectionStyle_Moode(animated_Moode: false)
    }
    
    /// 设置点击手势
    private func setupGesture_Moode() {
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleTap_Moode))
        addGestureRecognizer(tap_Moode)
        isUserInteractionEnabled = true
    }
    
    // MARK: - 内容刷新
    
    /// 根据 moodType 刷新 Emoji 和名称
    private func refreshContent_Moode() {
        guard let mood_Moode = moodType_Moode else { return }
        emojiLabel_Moode.text = mood_Moode.emoji_Moode
        nameLabel_Moode.text = mood_Moode.displayName_Moode
    }
    
    // MARK: - 选中状态切换
    
    /// 更新选中/未选中样式
    /// 参数：
    /// - animated_Moode: 是否使用动画过渡
    private func updateSelectionStyle_Moode(animated_Moode: Bool) {
        if isSelectedMood_Moode {
            // 选中：显示渐变背景，文字变白
            if let mood_Moode = moodType_Moode {
                gradientLayer_Moode?.removeFromSuperlayer()
                let layer_Moode = mood_Moode.createGradientLayer_Moode(frame_Moode: containerView_Moode.bounds)
                containerView_Moode.layer.insertSublayer(layer_Moode, above: normalBgView_Moode.layer)
                gradientLayer_Moode = layer_Moode
            }
            normalBgView_Moode.alpha = 0
            nameLabel_Moode.textColor = .white
            // 边框消失
            containerView_Moode.layer.borderWidth = 0
            // 添加阴影光晕
            layer.shadowColor = (moodType_Moode?.gradientStart_Moode ?? ColorConfig_Moode.primaryGradientStart_Moode).cgColor
            layer.shadowOffset = .zero
            layer.shadowRadius = 8
            layer.shadowOpacity = 0.4
        } else {
            // 未选中：白色/浅色背景，文字为次要色
            gradientLayer_Moode?.removeFromSuperlayer()
            gradientLayer_Moode = nil
            normalBgView_Moode.alpha = 1
            nameLabel_Moode.textColor = ColorConfig_Moode.textSecondary_Moode
            containerView_Moode.layer.borderWidth = 0
            layer.shadowOpacity = 0
        }
        
        if animated_Moode {
            // spring 弹性缩放
            let scaleAnim_Moode: CGFloat = isSelectedMood_Moode ? 1.08 : 1.0
            UIView.animate(
                withDuration: AnimationConfig_Moode.durationSpring_Moode,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Moode.springDampingLight_Moode,
                initialSpringVelocity: AnimationConfig_Moode.springVelocity_Moode,
                options: [.curveEaseOut],
                animations: {
                    self.transform = CGAffineTransform(scaleX: scaleAnim_Moode, y: scaleAnim_Moode)
                }
            )
        }
    }
    
    // MARK: - 手势处理
    
    /// 处理点击手势，触发回调并执行按压动画
    @objc private func handleTap_Moode() {
        let generator_Moode = UIImpactFeedbackGenerator(style: .light)
        generator_Moode.impactOccurred()
        
        animatePressDown_Moode {
            self.animatePressUp_Moode()
        }
        
        onTapped_Moode?(moodType_Moode)
    }
}

// MARK: - 创建"All"标签的工厂方法

extension MoodTagButton_Moode {
    
    /// 创建一个展示"全部"情绪的标签按钮（moodType 为 nil）
    /// 返回值：配置好 emoji=✨、name="All" 的 MoodTagButton_Moode 实例
    static func makeAllButton_Moode() -> MoodTagButton_Moode {
        let btn_Moode = MoodTagButton_Moode()
        // moodType_Moode 为 nil 表示"全部"，onTapped 回调返回 nil 供上层处理
        return btn_Moode
    }
}
