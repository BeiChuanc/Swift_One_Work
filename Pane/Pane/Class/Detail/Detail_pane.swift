import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页面

/// 帖子详情页面
/// 核心作用：完整展示单条帖子内容（媒体、标题、正文、作者信息、点赞、评论列表），
///          支持发布评论、举报/删除帖子与单条评论，帖子数据变动时自动刷新
/// 设计思路：沉浸式媒体顶部 + 上浮圆角白卡 + 互动操作行 + 评论气泡列表；
///          多层装饰元素（主题标签、分类色条、悬浮统计行、渐变评论标题）强化视觉层次
/// 关键属性：
/// - titleModel_Pane: 外部注入的帖子模型
/// - post_Pane: 实时从 ViewModel 取最新帖子（保证评论/点赞实时同步）
class Detail_Pane: UIViewController {

    // MARK: - 属性

    var titleModel_Pane: TitleModel_Pane?

    /// 实时帖子（从 ViewModel 取，优先级高于 titleModel_Pane）
    private var post_Pane: TitleModel_Pane? {
        guard let id_pane = titleModel_Pane?.titleId_Pane else { return titleModel_Pane }
        return TitleViewModel_Pane.shared_Pane.getPosts_Pane()
            .first(where: { $0.titleId_Pane == id_pane }) ?? titleModel_Pane
    }

    private var commentBarBottomCon_Pane: Constraint?

    // MARK: - UI · 自定义导航栏

    private let navBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private var navBarGradient_Pane: CAGradientLayer?

    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.2).cgColor
        return b
    }()

    private let actionButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.2).cgColor
        return b
    }()

    // MARK: - UI · 外层滚动

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Pane = UIView()

    // MARK: - UI · 顶部媒体区

    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.clipsToBounds = true
        v.layer.cornerRadius = 0
        return v
    }()

    /// 媒体底部双层遮罩（增强渐出效果）
    private let mediaMask_Pane: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private var mediaMaskGradient_Pane: CAGradientLayer?

    /// 媒体区左下角主题标签胶囊
    private let themeTagView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 12
        v.layer.borderWidth  = 1
        v.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        v.isUserInteractionEnabled = false
        return v
    }()

    private let themeTagLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 信息卡片

    private let infoCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor   = UIColor.black.withAlphaComponent(0.12).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: -6)
        v.layer.shadowRadius  = 20
        return v
    }()

    /// 卡片顶部装饰拖拽指示线
    private let dragIndicator_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.border_Pane
        v.layer.cornerRadius = 2
        return v
    }()

    /// 卡片顶部微渐变装饰条（视觉分层）
    private let cardTopAccent_Pane: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private var cardTopAccentGradient_Pane: CAGradientLayer?

    // MARK: - UI · 作者信息行

    private let authorAvatarView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        iv.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        iv.layer.borderWidth = 2.5
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        iv.layer.shadowOpacity = 0.4
        iv.layer.shadowRadius  = 6
        iv.layer.shadowOffset  = .zero
        return iv
    }()

    /// 头像外圈渐变环
    private let avatarRing_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.isUserInteractionEnabled = false
        return v
    }()

    private var avatarRingGradient_Pane: CAGradientLayer?

    private let authorNameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    private let dateLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    // MARK: - UI · 标题区（含左侧色条）

    /// 标题左侧渐变色条
    private let titleAccentBar_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    private var titleAccentGradient_Pane: CAGradientLayer?

    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 22, weight: .bold)
        l.textColor     = ColorConfig_Pane.textPrimary_Pane
        l.numberOfLines = 0
        return l
    }()

    private let contentLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 15)
        l.textColor     = ColorConfig_Pane.textSecondary_Pane
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        return l
    }()

    /// 正文区分割线
    private let contentDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    // MARK: - UI · 互动操作行（全宽浮动胶囊）

    private let actionRow_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.backgroundSecondary_Pane
        v.layer.cornerRadius = 18
        v.layer.borderWidth  = 1
        v.layer.borderColor  = ColorConfig_Pane.border_Pane.cgColor
        v.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.12).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.layer.shadowRadius  = 10
        return v
    }()

    private let likeButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        return b
    }()

    private let likeCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    /// 操作行内分割竖线
    private let actionDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    private let commentIconView_Pane: UIImageView = {
        let iv = UIImageView()
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv.image     = UIImage(systemName: "bubble.left.fill", withConfiguration: cfg_pane)
        iv.tintColor = ColorConfig_Pane.primaryGradientEnd_Pane
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    // MARK: - UI · 评论区标题行

    /// 评论区标题容器
    private let commentHeaderRow_Pane: UIView = UIView()

    private let commentSectionLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Comments"
        l.font      = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 评论数量徽章
    private let commentCountBadge_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()

    private var commentBadgeGradient_Pane: CAGradientLayer?

    private let commentBadgeLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 11, weight: .bold)
        l.textColor     = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 评论列表

    private lazy var commentTableView_Pane: UITableView = {
        let tv_pane = UITableView(frame: .zero, style: .plain)
        tv_pane.backgroundColor     = .clear
        tv_pane.separatorStyle      = .none
        tv_pane.isScrollEnabled     = false
        tv_pane.estimatedRowHeight  = 90
        tv_pane.rowHeight           = UITableView.automaticDimension
        tv_pane.register(
            DetailCommentCell_Pane.self,
            forCellReuseIdentifier: DetailCommentCell_Pane.reuseId_Pane
        )
        return tv_pane
    }()

    private var commentTVHeightCon_Pane: Constraint?

    /// KVO 注册标志位：防止 viewDidLoad 未执行时 deinit 崩溃
    private var isKVORegistered_Pane = false

    /// 空评论占位卡片
    private let emptyCommentCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.backgroundSecondary_Pane
        v.layer.cornerRadius = 18
        v.layer.borderWidth  = 1
        v.layer.borderColor  = ColorConfig_Pane.border_Pane.cgColor
        return v
    }()

    private let emptyCommentLabel_Pane: UILabel = {
        let l = UILabel()
        l.text          = "No comments yet 💬\nBe the first to share your thoughts!"
        l.font          = .systemFont(ofSize: 13)
        l.textColor     = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // MARK: - UI · 底部评论输入栏

    private let commentBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        return v
    }()

    private let commentBarDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    private let commentInputCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.backgroundSecondary_Pane
        v.layer.cornerRadius = 20
        v.layer.borderWidth  = 1
        v.layer.borderColor  = ColorConfig_Pane.border_Pane.cgColor
        return v
    }()

    private let commentTextField_Pane: UITextField = {
        let tf = UITextField()
        tf.placeholder     = "Write a comment..."
        tf.font            = .systemFont(ofSize: 14)
        tf.textColor       = ColorConfig_Pane.textPrimary_Pane
        tf.tintColor       = ColorConfig_Pane.primaryGradientStart_Pane
        tf.returnKeyType   = .send
        tf.backgroundColor = .clear
        return tf
    }()

    private let commentSendButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        b.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_pane), for: .normal)
        b.tintColor       = .white
        b.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane
        b.layer.cornerRadius = 16
        b.clipsToBounds   = true
        return b
    }()

    /// 送礼按钮（位于发送按钮左侧10pt，点击弹起礼物面板）
    private let giftButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "gift_btn"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
        setupNotifications_Pane()
        fillData_Pane()
        observeCommentTableHeight_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBarGradient_Pane?.frame        = navBar_Pane.bounds
        mediaMaskGradient_Pane?.frame     = mediaMask_Pane.bounds
        cardTopAccentGradient_Pane?.frame = cardTopAccent_Pane.bounds
        avatarRingGradient_Pane?.frame    = avatarRing_Pane.bounds
        titleAccentGradient_Pane?.frame   = titleAccentBar_Pane.bounds
        commentBadgeGradient_Pane?.frame  = commentCountBadge_Pane.bounds
    }

    deinit {
        if isKVORegistered_Pane {
            commentTableView_Pane.removeObserver(self, forKeyPath: "contentSize")
        }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - KVO

    private func observeCommentTableHeight_Pane() {
        commentTableView_Pane.addObserver(
            self,
            forKeyPath: "contentSize",
            options: [.new],
            context: nil
        )
        isKVORegistered_Pane = true
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "contentSize",
           let size_pane = change?[.newKey] as? CGSize {
            commentTVHeightCon_Pane?.update(offset: max(size_pane.height, 1))
            contentView_Pane.layoutIfNeeded()
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        view.addSubview(scrollView_Pane)
        scrollView_Pane.addSubview(contentView_Pane)

        // 媒体区
        contentView_Pane.addSubview(mediaView_Pane)
        contentView_Pane.addSubview(mediaMask_Pane)
        setupMediaMaskGradient_Pane()
        contentView_Pane.addSubview(themeTagView_Pane)
        themeTagView_Pane.addSubview(themeTagLabel_Pane)

        // 信息卡片
        contentView_Pane.addSubview(infoCard_Pane)
        infoCard_Pane.addSubview(cardTopAccent_Pane)
        setupCardTopAccent_Pane()
        infoCard_Pane.addSubview(dragIndicator_Pane)

        // 头像环 + 头像
        infoCard_Pane.addSubview(avatarRing_Pane)
        setupAvatarRingGradient_Pane()
        infoCard_Pane.addSubview(authorAvatarView_Pane)
        infoCard_Pane.addSubview(authorNameLabel_Pane)
        infoCard_Pane.addSubview(dateLabel_Pane)

        // 标题色条 + 标题 + 正文
        infoCard_Pane.addSubview(titleAccentBar_Pane)
        setupTitleAccentGradient_Pane()
        infoCard_Pane.addSubview(titleLabel_Pane)
        infoCard_Pane.addSubview(contentLabel_Pane)
        infoCard_Pane.addSubview(contentDivider_Pane)

        // 互动行
        infoCard_Pane.addSubview(actionRow_Pane)
        actionRow_Pane.addSubview(likeButton_Pane)
        actionRow_Pane.addSubview(likeCountLabel_Pane)
        actionRow_Pane.addSubview(actionDivider_Pane)
        actionRow_Pane.addSubview(commentIconView_Pane)
        actionRow_Pane.addSubview(commentCountLabel_Pane)

        // 评论区
        contentView_Pane.addSubview(commentHeaderRow_Pane)
        commentHeaderRow_Pane.addSubview(commentSectionLabel_Pane)
        commentHeaderRow_Pane.addSubview(commentCountBadge_Pane)
        commentCountBadge_Pane.addSubview(commentBadgeLabel_Pane)
        setupCommentBadgeGradient_Pane()

        contentView_Pane.addSubview(emptyCommentCard_Pane)
        emptyCommentCard_Pane.addSubview(emptyCommentLabel_Pane)

        contentView_Pane.addSubview(commentTableView_Pane)
        commentTableView_Pane.dataSource = self
        commentTableView_Pane.delegate   = self

        // 底部评论输入栏
        view.addSubview(commentBar_Pane)
        commentBar_Pane.addSubview(commentBarDivider_Pane)
        commentBar_Pane.addSubview(commentInputCard_Pane)
        commentInputCard_Pane.addSubview(commentTextField_Pane)
        commentBar_Pane.addSubview(giftButton_Pane)
        commentBar_Pane.addSubview(commentSendButton_Pane)

        // 自定义导航栏（最上层）
        view.addSubview(navBar_Pane)
        navBar_Pane.addSubview(backButton_Pane)
        navBar_Pane.addSubview(actionButton_Pane)
        setupNavBarGradient_Pane()

        commentTextField_Pane.delegate = self
        setupConstraints_Pane()
        updateActionButtonIcon_Pane()
        fillCommentBarAvatar_Pane()
    }

    // MARK: - 渐变装饰初始化

    private func setupNavBarGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.clear.cgColor]
        gl_pane.startPoint = CGPoint(x: 0.5, y: 0)
        gl_pane.endPoint   = CGPoint(x: 0.5, y: 1)
        navBar_Pane.layer.insertSublayer(gl_pane, at: 0)
        navBarGradient_Pane = gl_pane
    }

    private func setupMediaMaskGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [
            UIColor.clear.cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.withAlphaComponent(0.6).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.cgColor
        ]
        gl_pane.locations  = [0, 0.7, 1]
        gl_pane.startPoint = CGPoint(x: 0.5, y: 0)
        gl_pane.endPoint   = CGPoint(x: 0.5, y: 1)
        mediaMask_Pane.layer.insertSublayer(gl_pane, at: 0)
        mediaMaskGradient_Pane = gl_pane
    }

    /// 卡片顶部微渐变（主色调 → 透明，增加层次感）
    private func setupCardTopAccent_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [
            ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.07).cgColor,
            UIColor.clear.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0.5, y: 0)
        gl_pane.endPoint   = CGPoint(x: 0.5, y: 1)
        gl_pane.cornerRadius = 32
        cardTopAccent_Pane.layer.insertSublayer(gl_pane, at: 0)
        cardTopAccentGradient_Pane = gl_pane
    }

    /// 头像渐变圆环
    private func setupAvatarRingGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        gl_pane.cornerRadius = 26
        avatarRing_Pane.layer.insertSublayer(gl_pane, at: 0)
        avatarRingGradient_Pane = gl_pane
    }

    /// 标题左侧渐变色条
    private func setupTitleAccentGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 0, y: 1)
        gl_pane.cornerRadius = 2
        titleAccentBar_Pane.layer.insertSublayer(gl_pane, at: 0)
        titleAccentGradient_Pane = gl_pane
    }

    /// 评论数徽章渐变背景
    private func setupCommentBadgeGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        gl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        commentCountBadge_Pane.layer.insertSublayer(gl_pane, at: 0)
        commentBadgeGradient_Pane = gl_pane
    }

    /// 更新右上角按钮图标
    private func updateActionButtonIcon_Pane() {
        guard let post_pane = post_Pane else { return }
        let isMine_pane = UserViewModel_Pane.shared_Pane.isCurrentUser_Pane(
            userId_pane: post_pane.titleUserId_Pane
        )
        let iconName_pane = isMine_pane ? "trash" : "ellipsis"
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        actionButton_Pane.setImage(
            UIImage(systemName: iconName_pane, withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
    }

    /// 输入栏左侧填充当前用户头像
    private func fillCommentBarAvatar_Pane() {
        // 输入栏头像已移除，无需填充
    }

    // MARK: - 约束

    private func setupConstraints_Pane() {
        let screenW_pane = UIScreen.main.bounds.width
        let mediaH_pane  = screenW_pane * 0.78

        scrollView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(commentBar_Pane.snp.top)
        }
        contentView_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 媒体区
        mediaView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(mediaH_pane)
        }
        mediaMask_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(mediaView_Pane)
            $0.height.equalTo(120)
        }
        themeTagView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalTo(mediaView_Pane.snp.bottom).offset(-60)
        }
        themeTagLabel_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }

        // 信息卡片（上浮于媒体区）
        infoCard_Pane.snp.makeConstraints {
            $0.top.equalTo(mediaView_Pane.snp.bottom).offset(-40)
            $0.leading.trailing.equalToSuperview()
        }
        cardTopAccent_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        dragIndicator_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
            $0.width.equalTo(36)
            $0.height.equalTo(4)
        }

        // 头像环（渐变圈）+ 头像
        avatarRing_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(18)
            $0.width.height.equalTo(52)
        }
        authorAvatarView_Pane.snp.makeConstraints {
            $0.center.equalTo(avatarRing_Pane)
            $0.width.height.equalTo(44)
        }
        authorNameLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(avatarRing_Pane.snp.trailing).offset(12)
            $0.top.equalTo(avatarRing_Pane).offset(6)
        }
        dateLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(authorNameLabel_Pane)
            $0.top.equalTo(authorNameLabel_Pane.snp.bottom).offset(3)
        }

        // 标题色条 + 标题
        titleAccentBar_Pane.snp.makeConstraints {
            $0.top.equalTo(avatarRing_Pane.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(4)
            $0.height.equalTo(26)
        }
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleAccentBar_Pane.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleAccentBar_Pane)
        }
        contentLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        contentDivider_Pane.snp.makeConstraints {
            $0.top.equalTo(contentLabel_Pane.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0.5)
        }

        // 互动行
        actionRow_Pane.snp.makeConstraints {
            $0.top.equalTo(contentDivider_Pane.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-20)
        }
        likeButton_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        likeCountLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(likeButton_Pane.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
        }
        actionDivider_Pane.snp.makeConstraints {
            $0.leading.equalTo(likeCountLabel_Pane.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(18)
        }
        commentIconView_Pane.snp.makeConstraints {
            $0.leading.equalTo(actionDivider_Pane.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        commentCountLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(commentIconView_Pane.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
        }

        // 评论区标题行
        commentHeaderRow_Pane.snp.makeConstraints {
            $0.top.equalTo(infoCard_Pane.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(32)
        }
        commentSectionLabel_Pane.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        commentCountBadge_Pane.snp.makeConstraints {
            $0.leading.equalTo(commentSectionLabel_Pane.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
        }
        commentBadgeLabel_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7))
        }

        // 空评论卡片
        emptyCommentCard_Pane.snp.makeConstraints {
            $0.top.equalTo(commentHeaderRow_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        emptyCommentLabel_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20))
        }

        // 评论 TableView
        commentTableView_Pane.snp.makeConstraints {
            $0.top.equalTo(commentHeaderRow_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            commentTVHeightCon_Pane = $0.height.equalTo(1).constraint
            $0.bottom.equalToSuperview().offset(-16)
        }

        // 底部评论栏
        commentBar_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            commentBarBottomCon_Pane = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            $0.height.equalTo(68)
        }
        commentBarDivider_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        commentSendButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(34)
        }
        giftButton_Pane.snp.makeConstraints {
            $0.trailing.equalTo(commentSendButton_Pane.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        commentInputCard_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalTo(giftButton_Pane.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
        commentTextField_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.top.bottom.equalToSuperview()
        }

        // 自定义导航栏
        navBar_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        actionButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
    }

    // MARK: - 数据填充

    private func fillData_Pane() {
        guard let p_pane = post_Pane else { return }

        let firstMedia_pane  = p_pane.titleMeidas_Pane.first
        // 自动检测是否为视频（Bundle 中存在对应视频文件则视为视频类型）
        let isVideo_pane = firstMedia_pane.map { MediaDisplayView_Pane.bundleVideoURL_Pane(named: $0) != nil } ?? false
        mediaView_Pane.configure_Pane(
            mediaPath_Pane: firstMedia_pane,
            isVideo_Pane: isVideo_pane
        )

        // 主题标签（有 theme 则显示）
        let theme_pane = p_pane.titleTheme_Pane
        themeTagView_Pane.isHidden  = theme_pane.isEmpty
        themeTagLabel_Pane.text     = theme_pane

        // 作者信息
        authorNameLabel_Pane.text = p_pane.titleUserName_Pane
        dateLabel_Pane.text       = p_pane.titleDate_Pane.isEmpty ? "Just now" : p_pane.titleDate_Pane
        let userHead_pane = UserViewModel_Pane.shared_Pane
            .getUserById_Pane(userId_pane: p_pane.titleUserId_Pane).userHead_Pane
        authorAvatarView_Pane.image = userHead_pane.flatMap { UIImage(named: $0) }

        titleLabel_Pane.text   = p_pane.title_Pane
        contentLabel_Pane.text = p_pane.titleContent_Pane

        updateLikeButton_Pane()

        let count_pane = p_pane.reviews_Pane.count
        commentCountLabel_Pane.text    = "\(count_pane)"
        commentBadgeLabel_Pane.text    = "\(count_pane)"

        let hasComments_pane = count_pane > 0
        emptyCommentCard_Pane.isHidden   = hasComments_pane
        commentTableView_Pane.isHidden   = !hasComments_pane

        commentTableView_Pane.reloadData()
    }

    private func updateLikeButton_Pane() {
        guard let p_pane = post_Pane else { return }
        let isLiked_pane = TitleViewModel_Pane.shared_Pane.isLikedPost_Pane(post_pane: p_pane)
        let iconName_pane = isLiked_pane ? "heart.fill" : "heart"
        let color_pane    = isLiked_pane
            ? UIColor(hexstring_Pane: "#FC8181")
            : ColorConfig_Pane.textPlaceholder_Pane
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        likeButton_Pane.setImage(
            UIImage(systemName: iconName_pane, withConfiguration: cfg_pane),
            for: .normal
        )
        likeButton_Pane.tintColor  = color_pane
        likeCountLabel_Pane.text   = "\(p_pane.likes_Pane)"
    }

    // MARK: - 通知监听

    private func setupNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Pane),
            name: TitleViewModel_Pane.titleStateDidChangeNotification_Pane,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Pane(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Pane(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func onDataChanged_Pane() {
        fillData_Pane()
        updateActionButtonIcon_Pane()
    }

    @objc private func keyboardWillShow_Pane(_ notification: Notification) {
        guard let kb_pane  = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let offset_pane = -(kb_pane.height - view.safeAreaInsets.bottom)
        commentBarBottomCon_Pane?.update(offset: offset_pane)
        UIView.animate(withDuration: dur_pane) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Pane(_ notification: Notification) {
        guard let dur_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        commentBarBottomCon_Pane?.update(offset: 0)
        UIView.animate(withDuration: dur_pane) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        actionButton_Pane.addTarget(self, action: #selector(actionTapped_Pane), for: .touchUpInside)
        likeButton_Pane.addTarget(self, action: #selector(likeTapped_Pane), for: .touchUpInside)
        commentSendButton_Pane.addTarget(self, action: #selector(sendCommentTapped_Pane), for: .touchUpInside)
        giftButton_Pane.addTarget(self, action: #selector(giftTapped_Pane), for: .touchUpInside)
        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Pane))
        tap_pane.cancelsTouchesInView = false
        scrollView_Pane.addGestureRecognizer(tap_pane)

        // 媒体区点击 → 全屏媒体浏览页
        let mediaTap_pane = UITapGestureRecognizer(target: self, action: #selector(mediaTapped_Pane))
        mediaView_Pane.isUserInteractionEnabled = true
        mediaView_Pane.addGestureRecognizer(mediaTap_pane)
    }

    /// 点击媒体区：以沉浸式全屏展示当前帖子媒体（自动检测视频/图片类型）
    @objc private func mediaTapped_Pane() {
        guard let path_pane = post_Pane?.titleMeidas_Pane.first, !path_pane.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let isVideo_pane = MediaDisplayView_Pane.bundleVideoURL_Pane(named: path_pane) != nil
        Navigation_Pane.toMediaPlayer_Pane(mediaPath_pane: path_pane, isVideo_pane: isVideo_pane, from_pane: self)
    }

    @objc private func backTapped_Pane() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func actionTapped_Pane() {
        guard let p_pane = post_Pane else { return }
        let isMine_pane = UserViewModel_Pane.shared_Pane.isCurrentUser_Pane(
            userId_pane: p_pane.titleUserId_Pane
        )
        if isMine_pane {
            ReportDeleteHelper_Pane.delete_Pane(post_Pane: p_pane, from: self) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            ReportDeleteHelper_Pane.report_Pane(post_Pane: p_pane, from: self)
        }
    }

    @objc private func likeTapped_Pane() {
        guard let p_pane = post_Pane else { return }
        TitleViewModel_Pane.shared_Pane.likePost_Pane(post_pane: p_pane)
    }

    @objc private func sendCommentTapped_Pane() {
        guard let p_pane    = post_Pane,
              let text_pane = commentTextField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text_pane.isEmpty
        else { return }
        commentTextField_Pane.text = nil
        view.endEditing(true)
        TitleViewModel_Pane.shared_Pane.releaseComment_Pane(
            post_pane: p_pane,
            content_pane: text_pane
        )
    }

    @objc private func dismissKeyboard_Pane() {
        view.endEditing(true)
    }

    /// 点击送礼按钮：以模态方式弹起礼物面板
    @objc private func giftTapped_Pane() {
        let giftVC_pane = GiftView_Pane()
        giftVC_pane.modalPresentationStyle = .overFullScreen
        giftVC_pane.modalTransitionStyle   = .crossDissolve
        present(giftVC_pane, animated: false)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension Detail_Pane: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        post_Pane?.reviews_Pane.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_pane = tableView.dequeueReusableCell(
            withIdentifier: DetailCommentCell_Pane.reuseId_Pane,
            for: indexPath
        ) as! DetailCommentCell_Pane

        guard let p_pane = post_Pane else { return cell_pane }
        let comment_pane = p_pane.reviews_Pane[indexPath.row]
        cell_pane.configure_Pane(
            comment_pane: comment_pane,
            post_pane: p_pane,
            from: self
        ) { [weak self] in
            self?.fillData_Pane()
        }
        return cell_pane
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Pane: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommentTapped_Pane()
        return true
    }
}

// MARK: - DetailCommentCell_Pane

/// 评论气泡 Cell
/// 核心作用：展示单条评论（头像渐变环 + 昵称 + 内容 + 时序序号），右上角含举报/删除按钮
private class DetailCommentCell_Pane: UITableViewCell {

    static let reuseId_Pane = "DetailCommentCell_Pane"

    // MARK: - 子视图

    private let card_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 20
        v.layer.shadowColor  = UIColor.black.withAlphaComponent(0.05).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        v.layer.shadowRadius  = 6
        return v
    }()

    /// 头像渐变环容器
    private let avatarRing_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        return v
    }()

    private var avatarRingGradient_Pane: CAGradientLayer?

    private let avatarView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode    = .scaleAspectFill
        iv.clipsToBounds  = true
        iv.layer.cornerRadius = 17
        iv.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        iv.layer.borderWidth = 1.5
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()

    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 评论序号标签（#1, #2…）
    private let indexLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = ColorConfig_Pane.primaryGradientStart_Pane
        return l
    }()

    private let contentLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 14)
        l.textColor     = ColorConfig_Pane.textSecondary_Pane
        l.numberOfLines = 0
        return l
    }()

    private var reportButton_Pane: UIButton?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        contentView.addSubview(card_Pane)
        card_Pane.addSubview(avatarRing_Pane)
        card_Pane.addSubview(avatarView_Pane)
        card_Pane.addSubview(nameLabel_Pane)
        card_Pane.addSubview(indexLabel_Pane)
        card_Pane.addSubview(contentLabel_Pane)

        card_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview().offset(-7)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        avatarRing_Pane.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(14)
            $0.width.height.equalTo(40)
        }
        avatarView_Pane.snp.makeConstraints {
            $0.center.equalTo(avatarRing_Pane)
            $0.width.height.equalTo(34)
        }
        nameLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(avatarRing_Pane.snp.trailing).offset(10)
            $0.top.equalTo(avatarRing_Pane).offset(4)
            $0.trailing.equalToSuperview().offset(-44)
        }
        indexLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Pane)
            $0.top.equalTo(nameLabel_Pane.snp.bottom).offset(2)
        }
        contentLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(avatarRing_Pane.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.bottom.equalToSuperview().offset(-14)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarRingGradient_Pane?.frame = avatarRing_Pane.bounds
    }

    // MARK: - 配置

    /// 填充评论数据并绑定举报/删除按钮
    func configure_Pane(
        comment_pane: Comment_Pane,
        post_pane: TitleModel_Pane,
        from viewController_pane: UIViewController,
        completion_pane: (() -> Void)? = nil
    ) {
        nameLabel_Pane.text    = comment_pane.commentUserName_Pane
        contentLabel_Pane.text = comment_pane.commentContent_Pane

        // 序号
        let idx_pane = (post_pane.reviews_Pane.firstIndex(where: {
            $0.commentId_Pane == comment_pane.commentId_Pane
        }) ?? 0) + 1
        indexLabel_Pane.text = "#\(idx_pane)"

        // 头像
        let head_pane = UserViewModel_Pane.shared_Pane
            .getUserById_Pane(userId_pane: comment_pane.commentUserId_Pane).userHead_Pane
        avatarView_Pane.image = head_pane.flatMap { UIImage(named: $0) }

        // 头像渐变环
        if avatarRingGradient_Pane == nil {
            let gl_pane = CAGradientLayer()
            gl_pane.colors     = [
                ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
                ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
            ]
            gl_pane.startPoint = CGPoint(x: 0, y: 0)
            gl_pane.endPoint   = CGPoint(x: 1, y: 1)
            gl_pane.cornerRadius = 20
            avatarRing_Pane.layer.insertSublayer(gl_pane, at: 0)
            avatarRingGradient_Pane = gl_pane
        }

        // 移除旧按钮
        reportButton_Pane?.removeFromSuperview()
        reportButton_Pane = nil

        let btn_pane = ReportDeleteHelper_Pane.createCommentReportButton_Pane(
            comment_Pane: comment_pane,
            post_Pane: post_pane,
            size_Pane: 18,
            color_Pane: ColorConfig_Pane.textPlaceholder_Pane,
            from: viewController_pane,
            completion_Pane: completion_pane
        )
        card_Pane.addSubview(btn_pane)
        btn_pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(26)
        }
        reportButton_Pane = btn_pane
    }
}
