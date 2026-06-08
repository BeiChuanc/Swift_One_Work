import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页

/// 帖子详情页面
/// 功能：展示帖子完整信息（媒体、标题、内容、发布者、点赞、评论）
/// 设计：沉浸式全出血 Hero 媒体 + 白色浮动内容卡 + 渐变头像评论区 + 固定底部输入栏
/// 关键属性：titleModel_Hush（接收的帖子模型，数据变化时通过 titleId 重新查询最新数据）
class Detail_Hush: UIViewController {

    // MARK: - 外部属性

    /// 接收的帖子模型（由导航层传入）
    var titleModel_Hush: TitleModel_Hush?

    // MARK: - UI 组件 - 主滚动容器

    private let _scrollView_Hush: UIScrollView = {
        let sv_hush = UIScrollView()
        sv_hush.showsVerticalScrollIndicator = false
        sv_hush.alwaysBounceVertical = true
        sv_hush.contentInsetAdjustmentBehavior = .never
        return sv_hush
    }()
    private let _contentView_Hush = UIView()

    // MARK: - UI 组件 - Hero 媒体区

    /// Hero 容器（全出血，延伸至状态栏后方）
    private let _heroContainer_Hush = UIView()

    /// 媒体展示组件
    private let _mediaView_Hush = MediaDisplayView_Hush()

    /// 底部渐变遮罩（增强与内容卡的过渡感）
    private let _heroGradientOverlay_Hush = UIView()
    private var _heroOverlayLayer_Hush: CAGradientLayer?

    // MARK: - UI 组件 - 浮动返回按钮

    /// 自定义悬浮返回按钮（覆盖在 Hero 上）
    private let _backButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .system)
        let cfg_hush = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        bt_hush.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_hush), for: .normal)
        bt_hush.tintColor = .white
        bt_hush.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        bt_hush.layer.cornerRadius = 18
        bt_hush.clipsToBounds = true
        return bt_hush
    }()

    /// 右上角更多操作按钮（举报/删除）
    private let _moreButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .system)
        let cfg_hush = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        bt_hush.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_hush), for: .normal)
        bt_hush.tintColor = .white
        bt_hush.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        bt_hush.layer.cornerRadius = 18
        bt_hush.clipsToBounds = true
        return bt_hush
    }()

    // MARK: - UI 组件 - 浮动内容卡

    /// 白色内容卡（顶部圆角 26pt，与 Hero 底部重叠 32pt）
    private let _contentCard_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        v_hush.layer.cornerRadius = 26
        v_hush.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_hush
    }()

    // MARK: - UI 组件 - 作者行

    private let _authorRowView_Hush = UIView()
    private let _authorAvatarView_Hush = UserAvatarView_Hush()
    private let _authorNameLabel_Hush = UILabel()

    // MARK: - UI 组件 - 帖子正文

    /// 帖子标题
    private let _titleLabel_Hush = UILabel()
    /// 帖子内容
    private let _contentLabel_Hush = UILabel()

    // MARK: - UI 组件 - 互动统计行

    private let _engagementRow_Hush = UIView()
    /// 点赞按钮+数字容器
    private let _likePill_Hush = UIView()
    private let _likeButton_Hush = UIButton(type: .system)
    private let _likeCountLabel_Hush = UILabel()
    /// 评论数容器
    private let _commentPill_Hush = UIView()
    private let _commentCountLabel_Hush = UILabel()

    // MARK: - UI 组件 - 评论区

    private let _commentsHeaderView_Hush = UIView()
    private let _commentCountBadge_Hush = UILabel()
    private let _commentsStackView_Hush: UIStackView = {
        let sv_hush = UIStackView()
        sv_hush.axis = .vertical
        sv_hush.spacing = 0
        return sv_hush
    }()

    // MARK: - UI 组件 - 底部评论输入栏

    private let _commentBarView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.backgroundSecondary_Hush
        v_hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v_hush.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_hush.layer.shadowOpacity = 1
        v_hush.layer.shadowRadius = 10
        return v_hush
    }()
    private let _commentField_Hush: UITextField = {
        let tf_hush = UITextField()
        tf_hush.placeholder = "Add a comment..."
        tf_hush.font = .systemFont(ofSize: 14)
        tf_hush.backgroundColor = UIColor(hexstring_Hush: "#F4F1EC")
        tf_hush.layer.cornerRadius = 22
        tf_hush.addLeftPadding_Hush(16)
        tf_hush.returnKeyType = .send
        return tf_hush
    }()
    private let _sendButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .custom)
        let cfg_hush = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        bt_hush.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_hush), for: .normal)
        bt_hush.tintColor = .white
        bt_hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush
        bt_hush.layer.cornerRadius = 22
        bt_hush.clipsToBounds = true
        return bt_hush
    }()

    /// 送礼按钮（使用 gift_btn 图标，与发送按钮等大）
    private let _giftButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .custom)
        bt_hush.setImage(UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        bt_hush.imageView?.contentMode = .scaleAspectFit
        bt_hush.clipsToBounds = true
        return bt_hush
    }()

    // MARK: - 内部状态

    private var _commentBarBottomConstraint_Hush: Constraint?

    /// 当前媒体路径缓存（点击媒体区时传入全屏播放页）
    private var _currentMediaPath_Hush: String?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI_Hush()
        _setupConstraints_Hush()
        _setupNotifications_Hush()
        _reloadData_Hush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏系统导航栏，改用自定义悬浮按钮
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _heroOverlayLayer_Hush?.frame = _heroGradientOverlay_Hush.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 设置

    private func _setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush

        // ── 滚动容器 ──
        view.addSubview(_scrollView_Hush)
        _scrollView_Hush.addSubview(_contentView_Hush)

        // ── Hero 媒体区 ──
        _heroContainer_Hush.clipsToBounds = true
        _contentView_Hush.addSubview(_heroContainer_Hush)

        _mediaView_Hush.layer.cornerRadius = 0
        _mediaView_Hush.clipsToBounds = true
        _heroContainer_Hush.addSubview(_mediaView_Hush)

        // Hero 底部渐变遮罩
        let overlay_hush = CAGradientLayer()
        overlay_hush.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.18).cgColor,
            UIColor.black.withAlphaComponent(0.52).cgColor,
        ]
        overlay_hush.locations = [0.0, 0.6, 1.0]
        overlay_hush.startPoint = CGPoint(x: 0.5, y: 0)
        overlay_hush.endPoint = CGPoint(x: 0.5, y: 1)
        _heroGradientOverlay_Hush.layer.insertSublayer(overlay_hush, at: 0)
        _heroOverlayLayer_Hush = overlay_hush
        _heroContainer_Hush.addSubview(_heroGradientOverlay_Hush)

        // 媒体区点击 → 进入全屏媒体浏览页
        let mediaTap_Hush = UITapGestureRecognizer(target: self, action: #selector(_mediaTapped_Hush))
        _heroContainer_Hush.addGestureRecognizer(mediaTap_Hush)
        _heroContainer_Hush.isUserInteractionEnabled = true

        // ── 浮动返回 / 更多按钮 ──
        view.addSubview(_backButton_Hush)
        view.addSubview(_moreButton_Hush)
        _backButton_Hush.addTarget(self, action: #selector(_backTapped_Hush), for: .touchUpInside)
        _moreButton_Hush.addTarget(self, action: #selector(_moreTapped_Hush), for: .touchUpInside)

        // ── 浮动内容卡 ──
        _contentView_Hush.addSubview(_contentCard_Hush)

        // 作者行（头像 + 名字 + 跳转提示）
        _setupAuthorRow_Hush()

        // 帖子标题
        _titleLabel_Hush.font = .systemFont(ofSize: 22, weight: .bold)
        _titleLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _titleLabel_Hush.numberOfLines = 0
        _contentCard_Hush.addSubview(_titleLabel_Hush)

        // 帖子内容
        _contentLabel_Hush.font = .systemFont(ofSize: 15, weight: .regular)
        _contentLabel_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        _contentLabel_Hush.numberOfLines = 0
        _contentLabel_Hush.lineBreakMode = .byWordWrapping
        _contentCard_Hush.addSubview(_contentLabel_Hush)

        // 互动统计行
        _setupEngagementRow_Hush()

        // 评论区标题
        _setupCommentsHeader_Hush()

        // 评论列表
        _contentCard_Hush.addSubview(_commentsStackView_Hush)

        // ── 底部评论输入栏 ──
        _commentBarView_Hush.addSubview(_commentField_Hush)
        _commentBarView_Hush.addSubview(_giftButton_Hush)
        _commentBarView_Hush.addSubview(_sendButton_Hush)
        view.addSubview(_commentBarView_Hush)

        _commentField_Hush.delegate = self
        _giftButton_Hush.addTarget(self, action: #selector(_giftTapped_Hush), for: .touchUpInside)
        _sendButton_Hush.addTarget(self, action: #selector(_sendCommentTapped_Hush), for: .touchUpInside)
    }

    /// 构建作者信息行
    private func _setupAuthorRow_Hush() {
        _contentCard_Hush.addSubview(_authorRowView_Hush)
        _authorRowView_Hush.backgroundColor = .white
        _authorRowView_Hush.layer.cornerRadius = 18
        _authorRowView_Hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        _authorRowView_Hush.layer.shadowOffset = CGSize(width: 0, height: 3)
        _authorRowView_Hush.layer.shadowRadius = 8
        _authorRowView_Hush.layer.shadowOpacity = 1
        _authorRowView_Hush.isUserInteractionEnabled = true
        let tap_hush = UITapGestureRecognizer(target: self, action: #selector(_authorTapped_Hush))
        _authorRowView_Hush.addGestureRecognizer(tap_hush)

        // 渐变头像环
        let ringView_hush = UIView()
        ringView_hush.layer.cornerRadius = 25
        ringView_hush.clipsToBounds = true
        let ringGrad_hush = CAGradientLayer()
        ringGrad_hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
        ]
        ringGrad_hush.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_hush.endPoint = CGPoint(x: 1, y: 1)
        ringView_hush.layer.insertSublayer(ringGrad_hush, at: 0)
        _authorRowView_Hush.addSubview(ringView_hush)

        _authorAvatarView_Hush.layer.cornerRadius = 21
        _authorAvatarView_Hush.clipsToBounds = true
        _authorAvatarView_Hush.isUserInteractionEnabled = false
        ringView_hush.addSubview(_authorAvatarView_Hush)

        _authorNameLabel_Hush.font = .systemFont(ofSize: 15, weight: .bold)
        _authorNameLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _authorNameLabel_Hush.isUserInteractionEnabled = false
        _authorRowView_Hush.addSubview(_authorNameLabel_Hush)

        let profileHint_hush = UILabel()
        profileHint_hush.text = "View Profile  →"
        profileHint_hush.font = .systemFont(ofSize: 11, weight: .medium)
        profileHint_hush.textColor = ColorConfig_Hush.primaryGradientStart_Hush
        _authorRowView_Hush.addSubview(profileHint_hush)

        let chevron_hush = UIImageView()
        chevron_hush.image = UIImage(systemName: "chevron.right")
        chevron_hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        chevron_hush.contentMode = .scaleAspectFit
        _authorRowView_Hush.addSubview(chevron_hush)

        ringView_hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        ringGrad_hush.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        _authorAvatarView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(42)
        }
        _authorNameLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(ringView_hush.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
        }
        profileHint_hush.snp.makeConstraints { make in
            make.leading.equalTo(_authorNameLabel_Hush)
            make.top.equalTo(_authorNameLabel_Hush.snp.bottom).offset(3)
        }
        chevron_hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }

    /// 构建互动统计行（点赞 + 评论数）
    private func _setupEngagementRow_Hush() {
        _contentCard_Hush.addSubview(_engagementRow_Hush)
        _engagementRow_Hush.backgroundColor = .white
        _engagementRow_Hush.layer.cornerRadius = 16
        _engagementRow_Hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        _engagementRow_Hush.layer.shadowOffset = CGSize(width: 0, height: 2)
        _engagementRow_Hush.layer.shadowRadius = 6
        _engagementRow_Hush.layer.shadowOpacity = 1

        // 点赞 Pill
        _contentCard_Hush.addSubview(_likePill_Hush)
        _engagementRow_Hush.addSubview(_likePill_Hush)

        let heartCfg_hush = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        _likeButton_Hush.setImage(UIImage(systemName: "heart", withConfiguration: heartCfg_hush), for: .normal)
        _likeButton_Hush.setImage(UIImage(systemName: "heart.fill", withConfiguration: heartCfg_hush), for: .selected)
        _likeButton_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        _likeButton_Hush.addTarget(self, action: #selector(_likeTapped_Hush), for: .touchUpInside)
        _likePill_Hush.addSubview(_likeButton_Hush)

        _likeCountLabel_Hush.font = .systemFont(ofSize: 15, weight: .bold)
        _likeCountLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _likePill_Hush.addSubview(_likeCountLabel_Hush)

        // 评论数 Pill
        _engagementRow_Hush.addSubview(_commentPill_Hush)
        let commentIcon_hush = UIImageView()
        let commentCfg_hush = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        commentIcon_hush.image = UIImage(systemName: "bubble.left.fill", withConfiguration: commentCfg_hush)
        commentIcon_hush.tintColor = UIColor(hexstring_Hush: "#3A3D8F")
        _commentPill_Hush.addSubview(commentIcon_hush)

        _commentCountLabel_Hush.font = .systemFont(ofSize: 15, weight: .bold)
        _commentCountLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _commentPill_Hush.addSubview(_commentCountLabel_Hush)

        // 分割线（竖向）
        let separator_hush = UIView()
        separator_hush.backgroundColor = ColorConfig_Hush.divider_Hush
        _engagementRow_Hush.addSubview(separator_hush)

        _likeButton_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        _likeCountLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(_likeButton_Hush.snp.trailing).offset(2)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }
        separator_hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(24)
        }
        commentIcon_hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        _commentCountLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(commentIcon_hush.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }

        _likePill_Hush.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(separator_hush.snp.leading)
        }
        _commentPill_Hush.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(separator_hush.snp.trailing)
        }
    }

    /// 构建评论区标题 Header
    private func _setupCommentsHeader_Hush() {
        _contentCard_Hush.addSubview(_commentsHeaderView_Hush)

        let titleLb_hush = UILabel()
        titleLb_hush.text = "Discussion"
        titleLb_hush.font = .systemFont(ofSize: 17, weight: .bold)
        titleLb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _commentsHeaderView_Hush.addSubview(titleLb_hush)

        _commentCountBadge_Hush.font = .systemFont(ofSize: 11, weight: .bold)
        _commentCountBadge_Hush.textColor = ColorConfig_Hush.primaryGradientStart_Hush
        _commentCountBadge_Hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.1)
        _commentCountBadge_Hush.layer.cornerRadius = 10
        _commentCountBadge_Hush.clipsToBounds = true
        _commentCountBadge_Hush.textAlignment = .center
        _commentsHeaderView_Hush.addSubview(_commentCountBadge_Hush)

        titleLb_hush.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        _commentCountBadge_Hush.snp.makeConstraints { make in
            make.leading.equalTo(titleLb_hush.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(28)
        }
    }

    // MARK: - 约束布局

    private func _setupConstraints_Hush() {
        let topInset_hush = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        let heroHeight_hush: CGFloat = 360 + topInset_hush

        // 滚动容器：顶部延伸至屏幕最顶端（覆盖状态栏，实现沉浸式 Hero）
        // 底部锚定到评论输入栏顶部，避免输入栏和 TabBar 遮挡内容导致无法滚动到底
        _scrollView_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_commentBarView_Hush.snp.top)
        }
        _contentView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(_scrollView_Hush)
        }

        // Hero 区
        _heroContainer_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(heroHeight_hush)
        }
        _mediaView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        _heroGradientOverlay_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 悬浮返回按钮
        _backButton_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topInset_hush + 10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        _moreButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(_backButton_Hush)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }

        // 浮动内容卡（与 Hero 底部重叠 32pt）
        // bottom 必须锚定到 contentView.bottom，否则 contentView 高度无法推导
        // 导致 scrollView.contentSize = 0，任何滑动都会弹回
        _contentCard_Hush.snp.makeConstraints { make in
            make.top.equalTo(_heroContainer_Hush.snp.bottom).offset(-32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 帖子标题（顶部 28pt 内边距）
        _titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 作者行
        _authorRowView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_Hush.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(72)
        }

        // 帖子内容文本
        _contentLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_authorRowView_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 互动统计行
        _engagementRow_Hush.snp.makeConstraints { make in
            make.top.equalTo(_contentLabel_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(52)
        }

        // 分割线（评论区上方）
        let divider_hush = UIView()
        divider_hush.backgroundColor = ColorConfig_Hush.divider_Hush
        _contentCard_Hush.addSubview(divider_hush)
        divider_hush.snp.makeConstraints { make in
            make.top.equalTo(_engagementRow_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }

        // 评论区标题
        _commentsHeaderView_Hush.snp.makeConstraints { make in
            make.top.equalTo(divider_hush.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }

        // 评论堆叠（底部 -32 提供底部留白，ScrollView 已正确锚定到输入栏顶部）
        _commentsStackView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_commentsHeaderView_Hush.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-32)
        }

        // 底部评论输入栏
        _commentBarView_Hush.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
            _commentBarBottomConstraint_Hush = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        _commentField_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(_giftButton_Hush.snp.leading).offset(-10)
            make.height.equalTo(44)
        }
        // 送礼按钮：位于发送按钮左侧 10pt，大小与发送按钮相同
        _giftButton_Hush.snp.makeConstraints { make in
            make.trailing.equalTo(_sendButton_Hush.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        _sendButton_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        // 键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillShow_Hush(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillHide_Hush(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - 通知观察

    private func _setupNotifications_Hush() {
        NotificationCenter.default.addObserver(self, selector: #selector(_dataDidChange_Hush),
                                               name: TitleViewModel_Hush.titleStateDidChangeNotification_Hush, object: nil)
    }

    // MARK: - 数据刷新

    @objc private func _dataDidChange_Hush() {
        if let currentId_Hush = titleModel_Hush?.titleId_Hush {
            let latest_Hush = TitleViewModel_Hush.shared_Hush.getPosts_Hush().first { $0.titleId_Hush == currentId_Hush }
            if let post_hush = latest_Hush {
                titleModel_Hush = post_hush
            } else {
                Navigation_Hush.pop_Hush(animated: true, from: self)
                return
            }
        }
        _reloadData_Hush()
    }

    private func _reloadData_Hush() {
        guard let post_Hush = titleModel_Hush else { return }

        // 媒体（缓存路径供点击全屏使用）
        _currentMediaPath_Hush = post_Hush.titleMeidas_Hush.first
        _mediaView_Hush.configure_Hush(mediaPath_Hush: _currentMediaPath_Hush, isVideo_Hush: false)

        // 作者
        _authorAvatarView_Hush.configure_Hush(userId_Hush: post_Hush.titleUserId_Hush)
        _authorNameLabel_Hush.text = post_Hush.titleUserName_Hush

        // 标题 & 内容
        _titleLabel_Hush.text = post_Hush.title_Hush
        _contentLabel_Hush.text = post_Hush.titleContent_Hush

        // 点赞状态
        let isLiked_Hush = TitleViewModel_Hush.shared_Hush.isLikedPost_Hush(post_hush: post_Hush)
        _likeButton_Hush.isSelected = isLiked_Hush
        _likeButton_Hush.tintColor = isLiked_Hush
            ? ColorConfig_Hush.primaryGradientStart_Hush
            : ColorConfig_Hush.textPlaceholder_Hush
        _likeCountLabel_Hush.text = "\(post_Hush.likes_Hush)"
        _likeCountLabel_Hush.textColor = isLiked_Hush
            ? ColorConfig_Hush.primaryGradientStart_Hush
            : ColorConfig_Hush.textPrimary_Hush

        // 评论数徽章
        let count_hush = post_Hush.reviews_Hush.count
        _commentCountLabel_Hush.text = "\(count_hush)"
        _commentCountBadge_Hush.text = "  \(count_hush)  "

        // 更多操作按钮（通过 ReportDeleteHelper 绑定举报/删除事件）
        _rebuildMoreButton_Hush(post_Hush: post_Hush)

        // 重建评论列表
        _rebuildComments_Hush(post_Hush: post_Hush)
    }

    /// 绑定更多操作按钮的点击事件（举报/删除）
    private func _rebuildMoreButton_Hush(post_Hush: TitleModel_Hush) {
        // 复用 ReportDeleteHelper 的 ActionSheet 逻辑，通过自定义按钮触发
        _moreButton_Hush.removeTarget(nil, action: nil, for: .allEvents)
        _moreButton_Hush.addTarget(self, action: #selector(_moreTapped_Hush), for: .touchUpInside)
    }

    /// 清空并重建评论列表
    private func _rebuildComments_Hush(post_Hush: TitleModel_Hush) {
        _commentsStackView_Hush.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if post_Hush.reviews_Hush.isEmpty {
            let wrap_Hush = UIView()
            let lb_Hush = UILabel()
            lb_Hush.text = "No comments yet. Be the first ✨"
            lb_Hush.font = .systemFont(ofSize: 14)
            lb_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
            lb_Hush.textAlignment = .center
            wrap_Hush.addSubview(lb_Hush)
            lb_Hush.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16))
            }
            _commentsStackView_Hush.addArrangedSubview(wrap_Hush)
            return
        }

        let activeIds_Hush = Set(LocalData_Hush.shared_Hush.userList_Hush.compactMap { $0.userId_Hush })
        let meId_Hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush().userId_Hush ?? 0

        for (idx_hush, comment_Hush) in post_Hush.reviews_Hush.enumerated() {
            guard activeIds_Hush.contains(comment_Hush.commentUserId_Hush)
                  || comment_Hush.commentUserId_Hush == meId_Hush else { continue }
            let view_hush = _makeCommentView_Hush(comment_Hush: comment_Hush, post_Hush: post_Hush, index_hush: idx_hush)
            _commentsStackView_Hush.addArrangedSubview(view_hush)
        }
    }

    /// 创建单条评论视图（渐变头像 + 白色圆角卡片）
    private func _makeCommentView_Hush(comment_Hush: Comment_Hush, post_Hush: TitleModel_Hush, index_hush: Int) -> UIView {
        let palettes_hush: [(String, String)] = [
            ("#FF6B35", "#C0392B"), ("#3A3D8F", "#6C5CE7"), ("#00B894", "#0D3D2E"),
            ("#F9C784", "#E17055"), ("#FD79A8", "#E84393"), ("#74B9FF", "#0984E3"),
            ("#55EFC4", "#00B894"), ("#A29BFE", "#6C5CE7"),
        ]
        let palette_hush = palettes_hush[index_hush % palettes_hush.count]

        let wrapper_Hush = UIView()
        wrapper_Hush.backgroundColor = .clear

        // 卡片容器
        let card_Hush = UIView()
        card_Hush.backgroundColor = .white
        card_Hush.layer.cornerRadius = 18
        card_Hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        card_Hush.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_Hush.layer.shadowRadius = 8
        card_Hush.layer.shadowOpacity = 1
        wrapper_Hush.addSubview(card_Hush)
        card_Hush.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // 渐变头像
        let avatarContainer_Hush = UIView()
        avatarContainer_Hush.layer.cornerRadius = 22
        avatarContainer_Hush.clipsToBounds = true
        let avatarGrad_hush = CAGradientLayer()
        avatarGrad_hush.colors = [
            UIColor(hexstring_Hush: palette_hush.0).cgColor,
            UIColor(hexstring_Hush: palette_hush.1).cgColor,
        ]
        avatarGrad_hush.startPoint = CGPoint(x: 0, y: 0)
        avatarGrad_hush.endPoint = CGPoint(x: 1, y: 1)
        avatarContainer_Hush.layer.insertSublayer(avatarGrad_hush, at: 0)
        card_Hush.addSubview(avatarContainer_Hush)

        let avatarLabel_Hush = UILabel()
        avatarLabel_Hush.text = String(comment_Hush.commentUserName_Hush.prefix(1)).uppercased()
        avatarLabel_Hush.font = .systemFont(ofSize: 16, weight: .bold)
        avatarLabel_Hush.textColor = .white
        avatarLabel_Hush.textAlignment = .center
        avatarContainer_Hush.addSubview(avatarLabel_Hush)

        // 用户名
        let nameLabel_Hush = UILabel()
        nameLabel_Hush.text = comment_Hush.commentUserName_Hush
        nameLabel_Hush.font = .systemFont(ofSize: 13, weight: .bold)
        nameLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        card_Hush.addSubview(nameLabel_Hush)

        // 评论内容
        let contentLabel_Hush = UILabel()
        contentLabel_Hush.text = comment_Hush.commentContent_Hush
        contentLabel_Hush.font = .systemFont(ofSize: 13, weight: .regular)
        contentLabel_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        contentLabel_Hush.numberOfLines = 0
        card_Hush.addSubview(contentLabel_Hush)

        // 举报/删除按钮
        let reportBtn_Hush = ReportDeleteHelper_Hush.createCommentReportButton_Hush(
            comment_Hush: comment_Hush, post_Hush: post_Hush,
            size_Hush: 13, color_Hush: ColorConfig_Hush.textPlaceholder_Hush, from: self
        )
        card_Hush.addSubview(reportBtn_Hush)

        avatarContainer_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(44)
        }
        avatarGrad_hush.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        avatarLabel_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reportBtn_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        nameLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Hush)
            make.leading.equalTo(avatarContainer_Hush.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(reportBtn_Hush.snp.leading).offset(-6)
        }
        contentLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Hush.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel_Hush)
            make.trailing.equalToSuperview().offset(-50)
            make.bottom.equalToSuperview().inset(14)
        }

        return wrapper_Hush
    }

    // MARK: - 事件处理

    /// 点击媒体区，进入全屏媒体浏览页（图片缩放 / 视频播放）
    @objc private func _mediaTapped_Hush() {
        guard let path_Hush = _currentMediaPath_Hush, !path_Hush.isEmpty else { return }
        // 按压反馈
        _heroContainer_Hush.springScaleAnimate_Hush()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            Navigation_Hush.toMediaPlayer_Hush(mediaPath_hush: path_Hush, isVideo_hush: false)
        }
    }

    @objc private func _backTapped_Hush() {
        Navigation_Hush.pop_Hush(animated: true, from: self)
    }

    @objc private func _moreTapped_Hush() {
        guard let post_Hush = titleModel_Hush else { return }
        // 通过 ReportDeleteHelper 展示举报/删除选项
        let btn_Hush = ReportDeleteHelper_Hush.createPostReportButton_Hush(
            post_Hush: post_Hush, size_Hush: 18,
            color_Hush: ColorConfig_Hush.textPrimary_Hush, from: self
        ) { [weak self] in
            Navigation_Hush.pop_Hush(animated: true, from: self)
        }
        // 模拟触发按钮点击以展示 ActionSheet
        btn_Hush.sendActions(for: .touchUpInside)
    }

    @objc private func _authorTapped_Hush() {
        guard let post_Hush = titleModel_Hush else { return }
        let user_Hush = UserViewModel_Hush.shared_Hush.getUserById_Hush(userId_hush: post_Hush.titleUserId_Hush)
        Navigation_Hush.toUserInfo_Hush(with: user_Hush, fromChat_hush: false, style_hush: .push_hush, animated_hush: true)
    }

    @objc private func _likeTapped_Hush() {
        guard let post_Hush = titleModel_Hush else { return }
        _likeButton_Hush.animatePulse_Hush()
        TitleViewModel_Hush.shared_Hush.likePost_Hush(post_hush: post_Hush)
    }

    /// 点击送礼按钮，以半透明遮罩方式弹出礼物选择页
    @objc private func _giftTapped_Hush() {
        let giftVC_hush = GiftPage_Hush()
        giftVC_hush.modalPresentationStyle = .overFullScreen
        giftVC_hush.modalTransitionStyle = .crossDissolve
        Navigation_Hush.present_Hush(viewController: giftVC_hush, animated: true, from: self)
    }

    @objc private func _sendCommentTapped_Hush() {
        _submitComment_Hush()
    }

    private func _submitComment_Hush() {
        guard let post_Hush = titleModel_Hush else { return }
        let text_Hush = _commentField_Hush.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Hush.isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter a comment.")
            return
        }
        _commentField_Hush.text = nil
        _commentField_Hush.resignFirstResponder()
        TitleViewModel_Hush.shared_Hush.releaseComment_Hush(post_hush: post_Hush, content_hush: text_Hush)
    }

    @objc private func _keyboardWillShow_Hush(_ notification: Notification) {
        guard let frame_Hush = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Hush = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let inset_Hush = frame_Hush.height - view.safeAreaInsets.bottom
        _commentBarBottomConstraint_Hush?.update(offset: -inset_Hush)
        UIView.animate(withDuration: duration_Hush) { self.view.layoutIfNeeded() }
    }

    @objc private func _keyboardWillHide_Hush(_ notification: Notification) {
        guard let duration_Hush = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        _commentBarBottomConstraint_Hush?.update(offset: 0)
        UIView.animate(withDuration: duration_Hush) { self.view.layoutIfNeeded() }
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Hush: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _submitComment_Hush(); return true
    }
}
