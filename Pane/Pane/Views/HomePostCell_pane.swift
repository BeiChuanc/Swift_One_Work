import UIKit
import SnapKit

// MARK: 首页帖子网格卡片

/// 首页帖子网格卡片 Cell
/// 核心作用：在两列网格中展示帖子封面、标题、作者头像和点赞/评论数，支持举报/删除操作
/// 设计理念：圆角卡片 + 多层渐变遮罩 + 右上角操作按钮，模拟「窗格」层次感
/// 关键属性：
///   onLikeTapped_Pane   - 点赞回调（外部 VC 处理 ViewModel 调用）
///   onActionTapped_Pane - 举报/删除回调（外部 VC 通过 ReportDeleteHelper 处理）
class HomePostCell_Pane: UICollectionViewCell {

    // MARK: - 静态常量
    static let reuseId_Pane = "HomePostCell_Pane"

    // MARK: - UI组件

    /// 卡片主容器（圆角 + 裁切内容）
    private let containerView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    /// 媒体封面（使用 MediaDisplayView_Pane 统一处理图片/视频/占位）
    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.layer.cornerRadius = 0
        v.clipsToBounds = true
        return v
    }()

    /// 顶部遮罩渐变（黑色→透明，为操作按钮提供背景）
    private let topGradientOverlay_Pane = UIView()
    private var topGradientLayer_Pane: CAGradientLayer?

    /// 底部主渐变遮罩（透明→深黑，承载文字和底栏）
    private let bottomGradientOverlay_Pane = UIView()
    private var bottomGradientLayer_Pane: CAGradientLayer?

    /// 右上角举报/删除按钮（自己：trash；他人：ellipsis）
    private let actionButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        btn.layer.cornerRadius = 13
        btn.clipsToBounds = true
        btn.tintColor = .white
        return btn
    }()

    /// 帖子标题
    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    /// 作者头像（UserAvatarView_Pane 统一处理头像加载与占位）
    private let avatarView_Pane: UserAvatarView_Pane = {
        let v = UserAvatarView_Pane()
        v.onlineIndicator_Pane.isHidden = true
        return v
    }()

    /// 作者名称
    private let authorLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.9)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    /// 点赞图标
    private let likeButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.75)
        btn.isUserInteractionEnabled = true
        return btn
    }()

    /// 点赞数（固定不压缩）
    private let likeCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .white
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()

    // MARK: - 属性

    /// 点赞回调
    var onLikeTapped_Pane: (() -> Void)?

    /// 举报/删除操作回调（由外部 VC 通过 ReportDeleteHelper 处理）
    var onActionTapped_Pane: (() -> Void)?

    /// 当前点赞状态
    private var isLiked_Pane: Bool = false

    // MARK: - 高亮按压动画

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                containerView_Pane.animatePressDown_Pane()
            } else {
                containerView_Pane.animatePressUp_Pane()
            }
        }
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        setupShadow_Pane()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer_Pane?.frame    = topGradientOverlay_Pane.bounds
        bottomGradientLayer_Pane?.frame = bottomGradientOverlay_Pane.bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 18).cgPath
    }

    // MARK: - UI布局

    private func setupUI_Pane() {
        contentView.addSubview(containerView_Pane)
        containerView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 媒体封面铺满
        containerView_Pane.addSubview(mediaView_Pane)
        mediaView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 顶部渐变（为操作按钮提供阴影背景）
        containerView_Pane.addSubview(topGradientOverlay_Pane)
        topGradientOverlay_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        let topGL = CAGradientLayer()
        topGL.colors = [UIColor.black.withAlphaComponent(0.45).cgColor, UIColor.clear.cgColor]
        topGL.startPoint = CGPoint(x: 0.5, y: 0)
        topGL.endPoint   = CGPoint(x: 0.5, y: 1)
        topGradientOverlay_Pane.layer.addSublayer(topGL)
        topGradientLayer_Pane = topGL

        // 底部渐变
        containerView_Pane.addSubview(bottomGradientOverlay_Pane)
        bottomGradientOverlay_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.65)
        }
        let botGL = CAGradientLayer()
        botGL.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.85).cgColor]
        botGL.startPoint = CGPoint(x: 0.5, y: 0)
        botGL.endPoint   = CGPoint(x: 0.5, y: 1)
        bottomGradientOverlay_Pane.layer.addSublayer(botGL)
        bottomGradientLayer_Pane = botGL

        // 右上角操作按钮
        containerView_Pane.addSubview(actionButton_Pane)
        actionButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(26)
        }
        actionButton_Pane.addTarget(self, action: #selector(handleActionTap_Pane), for: .touchUpInside)

        // 帖子标题
        containerView_Pane.addSubview(titleLabel_Pane)
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().offset(-40)
        }

        // 底栏：头像 | 作者名（弹性） | 点赞按钮 | 点赞数
        containerView_Pane.addSubview(avatarView_Pane)
        containerView_Pane.addSubview(authorLabel_Pane)
        containerView_Pane.addSubview(likeCountLabel_Pane)
        containerView_Pane.addSubview(likeButton_Pane)

        avatarView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-11)
            $0.width.height.equalTo(22)
        }

        // 点赞数：固定在右侧，不允许被压缩
        likeCountLabel_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalTo(avatarView_Pane)
        }

        // 点赞图标：紧贴数字左侧
        likeButton_Pane.snp.makeConstraints {
            $0.trailing.equalTo(likeCountLabel_Pane.snp.leading).offset(-3)
            $0.centerY.equalTo(avatarView_Pane)
            $0.width.height.equalTo(18)
        }

        // 作者名：头像右侧到点赞图标左侧，超长截断
        authorLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(avatarView_Pane.snp.trailing).offset(5)
            $0.centerY.equalTo(avatarView_Pane)
            $0.trailing.lessThanOrEqualTo(likeButton_Pane.snp.leading).offset(-6)
        }

        likeButton_Pane.addTarget(self, action: #selector(handleLikeTap_Pane), for: .touchUpInside)
    }

    private func setupShadow_Pane() {
        layer.shadowColor   = UIColor.black.withAlphaComponent(0.18).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset  = CGSize(width: 0, height: 5)
        layer.shadowRadius  = 12
        layer.masksToBounds = false
        containerView_Pane.layer.masksToBounds = true
    }

    // MARK: - 数据配置

    /// 配置 Cell 显示内容
    /// - Parameters:
    ///   - post_pane:    帖子数据模型
    ///   - isLiked_pane: 当前用户是否已点赞
    ///   - isOwner_pane: 是否为当前用户的帖子（决定操作按钮图标）
    func configure_Pane(post_pane: TitleModel_Pane, isLiked_pane: Bool, isOwner_pane: Bool) {
        titleLabel_Pane.text     = post_pane.title_Pane
        authorLabel_Pane.text    = post_pane.titleUserName_Pane
        likeCountLabel_Pane.text = "\(post_pane.likes_Pane)"

        // MediaDisplayView_Pane 统一加载封面媒体
        mediaView_Pane.configure_Pane(mediaPath_Pane: post_pane.titleMeidas_Pane.first)

        // UserAvatarView_Pane 统一加载作者头像（自动处理缓存、默认占位）
        avatarView_Pane.configure_Pane(userId_Pane: post_pane.titleUserId_Pane)

        // 操作按钮图标：自己的帖子用 trash，他人用 ellipsis
        let iconName_pane = isOwner_pane ? "trash.fill" : "ellipsis"
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        actionButton_Pane.setImage(UIImage(systemName: iconName_pane, withConfiguration: cfg_pane), for: .normal)

        refreshLikeState_Pane(isLiked_pane: isLiked_pane, animated_pane: false)
    }

    private func refreshLikeState_Pane(isLiked_pane: Bool, animated_pane: Bool) {
        isLiked_Pane = isLiked_pane
        likeButton_Pane.tintColor = isLiked_pane
            ? UIColor(hexstring_Pane: "#FC8181")
            : UIColor.white.withAlphaComponent(0.75)
        if animated_pane { likeButton_Pane.animatePulse_Pane() }
    }

    // MARK: - 事件处理

    @objc private func handleLikeTap_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .medium)
        gen_pane.impactOccurred()
        refreshLikeState_Pane(isLiked_pane: !isLiked_Pane, animated_pane: true)
        onLikeTapped_Pane?()
    }

    /// 操作按钮点击：触觉反馈 + 脉冲动画 + 回调（由 VC 调用 ReportDeleteHelper）
    @objc private func handleActionTap_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .medium)
        gen_pane.impactOccurred()
        actionButton_Pane.animatePulse_Pane()
        onActionTapped_Pane?()
    }
}
