import UIKit
import SnapKit

// MARK: - 帖子卡片显示模式枚举

/// 帖子卡片显示模式
/// - fullWidth: 首页单列宽卡模式，图标区高度 120pt
/// - grid: 发现页双列窄卡模式，图标区高度 90pt
enum TracePostCardMode_Trace {
    case fullWidth_trace
    case grid_trace
}

// MARK: - 帖子卡片组件

/// 通用帖子卡片视图
/// 核心作用：在首页和发现页中复用的帖子展示卡片，支持两种布局模式
/// 设计思路：渐变图标区 + 标签徽章 + 标题 + 内容摘要 + 作者行 + 点赞行，卡片白底+阴影
/// 关键属性：displayMode（布局模式），onLikeTapped（点赞回调），onTapped（点击回调）
class TracePostCard_Trace: UIView {
    
    // MARK: - 常量
    
    /// Tag 图标映射表（Tag名 → SF Symbol）
    private static let tagIconMap_Trace: [String: String] = [
        "Life":    "sun.max.fill",
        "Moments": "sparkles",
        "Night":   "moon.stars.fill",
        "Nature":  "leaf.fill",
        "Memory":  "clock.fill",
        "Stars":   "star.fill",
        "Warmth":  "flame.fill",
        "Friends": "person.2.fill"
    ]
    
    /// Tag 渐变色映射表（Tag名 → [起始色, 结束色]）
    private static let tagGradientMap_Trace: [String: (String, String)] = [
        "Life":    ("#B794F6", "#90CDF4"),
        "Moments": ("#FBB6CE", "#FED7AA"),
        "Night":   ("#553C9A", "#6B46C1"),
        "Nature":  ("#68D391", "#38B2AC"),
        "Memory":  ("#F6AD55", "#ED8936"),
        "Stars":   ("#F6E05E", "#ECC94B"),
        "Warmth":  ("#FC8181", "#F6AD55"),
        "Friends": ("#76E4F7", "#4299E1")
    ]
    
    // MARK: - UI 组件
    
    /// 卡片容器（白色圆角，阴影）
    private let cardContainer_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.backgroundColor = ColorConfig_Trace.cardBackground_Trace
        view_Trace.layer.cornerRadius = 16
        view_Trace.layer.shadowColor = UIColor.black.cgColor
        view_Trace.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Trace.layer.shadowRadius = 12
        view_Trace.layer.shadowOpacity = 0.08
        view_Trace.layer.masksToBounds = false
        return view_Trace
    }()
    
    /// 渐变图标区（卡片顶部彩色区域）
    private let gradientIconView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.layer.cornerRadius = 12
        view_Trace.layer.masksToBounds = true
        return view_Trace
    }()
    
    /// 渐变图层
    private let gradientLayer_Trace = CAGradientLayer()
    
    /// 中心图标
    private let iconImageView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        iv_Trace.contentMode = .scaleAspectFit
        iv_Trace.tintColor = UIColor.white.withAlphaComponent(0.9)
        return iv_Trace
    }()
    
    /// 标签徽章容器
    private let tagBadgeView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.layer.cornerRadius = 8
        view_Trace.layer.masksToBounds = true
        return view_Trace
    }()
    
    /// 标签渐变图层
    private let tagGradientLayer_Trace = CAGradientLayer()
    
    /// 标签文字
    private let tagLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lbl_Trace.textColor = .white
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()
    
    /// 帖子标题
    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    /// 内容预览（两行省略）
    private let contentLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    /// 作者行容器
    private let authorRowView_Trace: UIView = UIView()
    
    /// 作者头像（小圆圈占位）
    private let authorAvatarView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.layer.cornerRadius = 10
        view_Trace.layer.masksToBounds = true
        return view_Trace
    }()
    
    /// 作者头像图标
    private let authorIconView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        iv_Trace.image = UIImage(systemName: "person.circle.fill")
        iv_Trace.contentMode = .scaleAspectFill
        iv_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        return iv_Trace
    }()
    
    /// 作者名称
    private let authorNameLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()
    
    /// 点赞行容器
    private let likeRowView_Trace: UIView = UIView()
    
    /// 点赞按钮
    private let likeButton_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn_Trace.setImage(UIImage(systemName: "heart"), for: .normal)
        btn_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        return btn_Trace
    }()
    
    /// 点赞数量标签
    private let likeCountLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()
    
    // MARK: - 约束引用（用于动态切换高度）
    
    /// 图标区高度约束
    private var iconHeightConstraint_Trace: Constraint?
    
    // MARK: - 属性
    
    /// 当前显示模式
    var displayMode_Trace: TracePostCardMode_Trace = .fullWidth_trace {
        didSet { updateLayout_Trace() }
    }
    
    /// 当前帖子数据
    private(set) var post_Trace: TitleModel_Trace?
    
    /// 点赞回调
    var onLikeTapped_Trace: (() -> Void)?
    
    /// 卡片点击回调
    var onTapped_Trace: (() -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化方法
    /// - Parameters:
    ///   - mode_trace: 显示模式（默认为全宽）
    init(mode_trace: TracePostCardMode_Trace = .fullWidth_trace) {
        self.displayMode_Trace = mode_trace
        super.init(frame: .zero)
        setupUI_Trace()
        setupGestures_Trace()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新渐变图层尺寸
        gradientLayer_Trace.frame = gradientIconView_Trace.bounds
        tagGradientLayer_Trace.frame = tagBadgeView_Trace.bounds
    }
    
    // MARK: - UI 设置
    
    /// 构建基础 UI 结构与约束
    private func setupUI_Trace() {
        backgroundColor = .clear
        
        addSubview(cardContainer_Trace)
        cardContainer_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变图标区
        cardContainer_Trace.addSubview(gradientIconView_Trace)
        gradientIconView_Trace.layer.addSublayer(gradientLayer_Trace)
        gradientIconView_Trace.addSubview(iconImageView_Trace)
        
        gradientIconView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            iconHeightConstraint_Trace = make.height.equalTo(iconHeight_Trace).constraint
        }
        
        iconImageView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        // 标签徽章
        cardContainer_Trace.addSubview(tagBadgeView_Trace)
        tagBadgeView_Trace.layer.insertSublayer(tagGradientLayer_Trace, at: 0)
        tagBadgeView_Trace.addSubview(tagLabel_Trace)
        
        tagBadgeView_Trace.snp.makeConstraints { make in
            make.top.equalTo(gradientIconView_Trace.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(18)
        }
        
        tagLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        
        // 标题
        cardContainer_Trace.addSubview(titleLabel_Trace)
        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(tagBadgeView_Trace.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        // 内容预览（grid模式下隐藏）
        cardContainer_Trace.addSubview(contentLabel_Trace)
        contentLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        // 作者行
        cardContainer_Trace.addSubview(authorRowView_Trace)
        authorRowView_Trace.addSubview(authorAvatarView_Trace)
        authorAvatarView_Trace.addSubview(authorIconView_Trace)
        authorRowView_Trace.addSubview(authorNameLabel_Trace)
        
        authorRowView_Trace.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(20)
        }
        
        authorAvatarView_Trace.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        authorIconView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        authorNameLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatarView_Trace.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        // 点赞行
        cardContainer_Trace.addSubview(likeRowView_Trace)
        likeRowView_Trace.addSubview(likeButton_Trace)
        likeRowView_Trace.addSubview(likeCountLabel_Trace)
        
        likeRowView_Trace.snp.makeConstraints { make in
            make.top.equalTo(authorRowView_Trace.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        likeButton_Trace.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        likeCountLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(likeButton_Trace.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        
        likeButton_Trace.addTarget(self, action: #selector(handleLikeTap_Trace), for: .touchUpInside)
        
        updateLayout_Trace()
    }
    
    /// 根据显示模式更新布局
    private func updateLayout_Trace() {
        iconHeightConstraint_Trace?.update(offset: iconHeight_Trace)
        contentLabel_Trace.isHidden = (displayMode_Trace == .grid_trace)
        titleLabel_Trace.numberOfLines = displayMode_Trace == .fullWidth_trace ? 2 : 2
    }
    
    /// 当前模式对应的图标区高度
    private var iconHeight_Trace: CGFloat {
        switch displayMode_Trace {
        case .fullWidth_trace: return 120
        case .grid_trace: return 90
        }
    }
    
    /// 添加手势
    private func setupGestures_Trace() {
        let tap_Trace = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Trace))
        cardContainer_Trace.addGestureRecognizer(tap_Trace)
        cardContainer_Trace.isUserInteractionEnabled = true
    }
    
    // MARK: - 公共方法
    
    /// 配置卡片数据
    /// - Parameters:
    ///   - post_trace: 帖子数据模型
    ///   - isLiked_trace: 当前用户是否已点赞
    func configure_Trace(post_trace: TitleModel_Trace, isLiked_trace: Bool) {
        self.post_Trace = post_trace
        
        let tag_trace = post_trace.titleTag_Trace
        
        // 配置渐变图标区
        let colors_trace = Self.tagGradientMap_Trace[tag_trace] ?? ("#B794F6", "#90CDF4")
        gradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: colors_trace.0).cgColor,
            UIColor(hexstring_Trace: colors_trace.1).cgColor
        ]
        gradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer_Trace.cornerRadius = 12
        
        let iconName_trace = Self.tagIconMap_Trace[tag_trace] ?? "sparkles"
        let config_trace = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        iconImageView_Trace.image = UIImage(systemName: iconName_trace, withConfiguration: config_trace)
        
        // 配置标签徽章
        tagLabel_Trace.text = tag_trace
        tagGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: colors_trace.0).withAlphaComponent(0.9).cgColor,
            UIColor(hexstring_Trace: colors_trace.1).withAlphaComponent(0.9).cgColor
        ]
        tagGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        tagGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 0)
        tagGradientLayer_Trace.cornerRadius = 8
        
        // 配置文字
        titleLabel_Trace.text = post_trace.title_Trace
        contentLabel_Trace.text = post_trace.titleContent_Trace
        authorNameLabel_Trace.text = post_trace.titleUserName_Trace
        likeCountLabel_Trace.text = "\(post_trace.likes_Trace)"
        
        // 配置头像颜色（根据用户ID）
        let avatarColors_trace = UserAvatarView_Trace.defaultAvatarColors_Trace
        let colorIndex_trace = post_trace.titleUserId_Trace % avatarColors_trace.count
        authorIconView_Trace.tintColor = avatarColors_trace[colorIndex_trace]
        
        // 点赞状态
        likeButton_Trace.isSelected = isLiked_trace
        likeButton_Trace.tintColor = isLiked_trace
            ? UIColor(hexstring_Trace: "#FC8181")
            : ColorConfig_Trace.textPlaceholder_Trace
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - 事件处理
    
    /// 处理点赞按钮点击
    @objc private func handleLikeTap_Trace() {
        // 切换点赞状态动画
        likeButton_Trace.animatePulse_Trace()
        let generator_Trace = UIImpactFeedbackGenerator(style: .light)
        generator_Trace.impactOccurred()
        onLikeTapped_Trace?()
    }
    
    /// 处理卡片点击（按压动画）
    @objc private func handleCardTap_Trace() {
        cardContainer_Trace.animatePressDown_Trace {
            self.cardContainer_Trace.animatePressUp_Trace {
                self.onTapped_Trace?()
            }
        }
    }
    
    /// 外部更新点赞状态（无动画）
    /// - Parameter isLiked_trace: 是否已点赞
    func updateLikeState_Trace(isLiked_trace: Bool, count_trace: Int) {
        likeButton_Trace.isSelected = isLiked_trace
        likeButton_Trace.tintColor = isLiked_trace
            ? UIColor(hexstring_Trace: "#FC8181")
            : ColorConfig_Trace.textPlaceholder_Trace
        likeCountLabel_Trace.text = "\(count_trace)"
    }
}
