import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 个人主页标签枚举
private enum ProfileTab_Orna {
    /// 我发布的帖子
    case posts_Orna
    /// 我喜欢的帖子
    case liked_Orna
}

/// 我的页面视图控制器
/// 核心作用：展示当前登录用户的资料、数据统计，并支持在"我发布的"与"我喜欢的"帖子间切换浏览
/// 设计思路：
///   - 顶部渐变资料卡改用与发现页/发布页/消息页横幅一致的紫粉渐变（#7B61FF → #FF6B9D），
///     统一全 App 主要入口页面的强调色视觉基调
///   - 资料卡内新增"摆件收藏数"与"连续签到天数"两个徽标胶囊，将首页摆件收藏/签到闭环功能
///     的真实数据延伸展示到个人资料页，丰富信息层次的同时强化"桌面摆件"主题的沉浸感
///   - 数据统计行：关注 / 喜欢 / 发布三项数据
///   - 自定义胶囊分段控件切换"我的帖子"与"我喜欢的"，左右边距与资料卡保持一致（均为 20），
///     选中态仅通过背板颜色填充呈现，不叠加系统默认选中样式
///   - 帖子列表复用 PostCardView_Orna，右上角自带举报/删除按钮；列表为空时展示统一风格的
///     缺省态卡片（EmptyStateView_Orna），避免大片空白区域显得过于空旷
///   - 头像/编辑资料按钮直接进入修改资料页，无需预先校验登录状态（保存时仍会校验并引导登录）
/// 关键属性：
///   - meModel_Orna: 外部可注入的用户模型（预留，默认读取当前登录用户）
///   - selectedTab_Orna: 当前选中的标签
class Me_Orna: UIViewController {

    /// 外部注入的用户模型（预留字段，默认使用当前登录用户数据）
    var meModel_Orna: LoginUserModel_Orna?

    // MARK: - 数据

    private var selectedTab_Orna: ProfileTab_Orna = .posts_Orna

    // MARK: - UI · 容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 资料卡

    private let headerCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()

    private var headerGradientLayer_Orna: CAGradientLayer?

    private lazy var avatarView_Orna: CurrentUserAvatarView_Orna = {
        let v = CurrentUserAvatarView_Orna()
        v.layer.cornerRadius = 38
        v.clipsToBounds = true
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        v.onTapped_Orna = { [weak self] in
            self?.handleAvatarTapped_Orna()
        }
        return v
    }()

    // MARK: - UI · 操作按钮组（修改资料 / 设置）

    /// 承载"修改用户信息"与"设置"两个入口的整合卡片容器
    /// 设计思路：此前两按钮分别悬浮在资料卡的不同角落，彼此毫无关联，视觉上显得零散；
    /// 现改为整合进同一张白色圆角卡片，中间以竖向分割线区隔为对等的左右两个入口，
    /// 卡片左右边距与下方切换栏保持完全一致（均为 20，宽度对齐），上下间距同样与切换栏
    /// 保持一致（均为 10），使两组件在视觉上呈现统一的宽度与节奏感
    private let actionButtonsCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        return v
    }()

    /// 修改用户信息入口按钮（整合卡片左半区，图标 + 文案）
    private let editButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config_orna.title = "Edit Profile"
        config_orna.imagePadding = 6
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: "#7B61FF")
        config_orna.contentInsets = .zero
        config_orna.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing_orna = incoming
            outgoing_orna.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing_orna
        }
        b.configuration = config_orna
        return b
    }()

    /// 卡片中间的竖向分割线，用于区隔两个入口按钮
    private let actionDividerView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        return v
    }()

    /// 设置入口按钮（整合卡片右半区，图标 + 文案）
    private let settingsButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config_orna.title = "Settings"
        config_orna.imagePadding = 6
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: "#7B61FF")
        config_orna.contentInsets = .zero
        config_orna.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing_orna = incoming
            outgoing_orna.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing_orna
        }
        b.configuration = config_orna
        return b
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 21, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let bioLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.numberOfLines = 2
        return l
    }()

    /// 摆件收藏数 / 连续签到天数徽标胶囊行，衔接首页摆件主题闭环功能的真实数据
    private let badgesRow_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()

    private let ornamentBadgeView_Orna = BadgeChipView_Orna()
    private let streakBadgeView_Orna = BadgeChipView_Orna()

    private let statsRow_Orna: UIView = UIView()

    private let followStatView_Orna = ProfileStatItemView_Orna()
    private let likeStatView_Orna = ProfileStatItemView_Orna()
    private let postStatView_Orna = ProfileStatItemView_Orna()

    // MARK: - UI · 分段控件

    private let segmentControl_Orna = PillSegmentControl_Orna(titles_Orna: ["My Posts", "Liked"])

    // MARK: - UI · 列表

    private let listStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    /// 帖子列表缺省态卡片：以图标徽标 + 标题 + 描述取代原先单薄的纯文字提示，
    /// 填补列表区域的大片空白，丰富"我的"页面的视觉层次
    private let emptyStateView_Orna = EmptyStateView_Orna()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Orna?.frame = headerCardView_Orna.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(headerCardView_Orna)
        setupHeaderGradient_Orna()
        headerCardView_Orna.addSubview(avatarView_Orna)
        headerCardView_Orna.addSubview(nameLabel_Orna)
        headerCardView_Orna.addSubview(bioLabel_Orna)
        headerCardView_Orna.addSubview(badgesRow_Orna)
        badgesRow_Orna.addArrangedSubview(ornamentBadgeView_Orna)
        badgesRow_Orna.addArrangedSubview(streakBadgeView_Orna)
        headerCardView_Orna.addSubview(statsRow_Orna)

        statsRow_Orna.addSubview(followStatView_Orna)
        statsRow_Orna.addSubview(likeStatView_Orna)
        statsRow_Orna.addSubview(postStatView_Orna)

        // 修改资料 / 设置整合卡片：悬浮于切换栏正上方
        contentView_Orna.addSubview(actionButtonsCardView_Orna)
        actionButtonsCardView_Orna.addSubview(editButton_Orna)
        actionButtonsCardView_Orna.addSubview(actionDividerView_Orna)
        actionButtonsCardView_Orna.addSubview(settingsButton_Orna)

        contentView_Orna.addSubview(segmentControl_Orna)
        contentView_Orna.addSubview(listStack_Orna)
        contentView_Orna.addSubview(emptyStateView_Orna)
    }

    /// 资料卡紫粉渐变背景，与发现页/发布页/消息页横幅保持同一强调色，统一全 App 主要入口的视觉基调
    private func setupHeaderGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        headerCardView_Orna.layer.insertSublayer(layer_orna, at: 0)
        headerGradientLayer_Orna = layer_orna
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        scrollView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        headerCardView_Orna.snp.makeConstraints {
            // 注意：顶部安全区锚点必须取自 contentView_Orna（滚动内容自身），而非 view（控制器根视图）。
            // 若跨越 UIScrollView 边界直接锚定到 view.safeAreaLayoutGuide，Auto Layout 会在每次布局时
            // 将该视图强制拉回相对屏幕的固定位置，导致 scrollView 内容整体无法真正滚动。
            $0.top.equalTo(contentView_Orna.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        avatarView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(76)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna)
            $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        bioLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(6)
            $0.leading.equalTo(nameLabel_Orna)
            $0.trailing.equalToSuperview().offset(-16)
        }
        badgesRow_Orna.snp.makeConstraints {
            $0.top.equalTo(bioLabel_Orna.snp.bottom).offset(10)
            $0.leading.equalTo(nameLabel_Orna)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.height.equalTo(26)
        }
        statsRow_Orna.snp.makeConstraints {
            $0.top.equalTo(badgesRow_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-22)
            $0.height.equalTo(48)
        }
        followStatView_Orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(likeStatView_Orna)
        }
        likeStatView_Orna.snp.makeConstraints {
            $0.leading.equalTo(followStatView_Orna.snp.trailing)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(postStatView_Orna)
        }
        postStatView_Orna.snp.makeConstraints {
            $0.leading.equalTo(likeStatView_Orna.snp.trailing)
            $0.trailing.top.bottom.equalToSuperview()
        }

        // 修改资料 / 设置整合卡片：左右边距与下方切换栏保持完全一致（均为 20，宽度对齐），
        // 上下间距同样与切换栏保持一致（均为 10）
        actionButtonsCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(headerCardView_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
        }
        editButton_Orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(actionDividerView_Orna.snp.leading)
        }
        actionDividerView_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(20)
        }
        // 分割线水平居中于卡片，左右两侧按钮由此天然获得完全对等的宽度，无需额外约束
        settingsButton_Orna.snp.makeConstraints {
            $0.leading.equalTo(actionDividerView_Orna.snp.trailing)
            $0.trailing.top.bottom.equalToSuperview()
        }

        // 与资料卡保持一致的左右边距（均为 20），取代原先固定 200 宽度导致的左右间距不对称；
        // 顶部与整合操作卡片保持 10 的间距，使其固定悬浮于切换栏正上方
        segmentControl_Orna.snp.makeConstraints {
            $0.top.equalTo(actionButtonsCardView_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        listStack_Orna.snp.makeConstraints {
            $0.top.equalTo(segmentControl_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            // 底部预留悬浮导航栏遮挡高度，确保内容可以完全滚动到导航栏上方，不被其遮盖
            $0.bottom.equalToSuperview().offset(-TabBar_Orna.floatingBarClearance_Orna)
        }
        emptyStateView_Orna.snp.makeConstraints {
            $0.top.equalTo(segmentControl_Orna.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        settingsButton_Orna.addTarget(self, action: #selector(handleSettingsTapped_Orna), for: .touchUpInside)
        editButton_Orna.addTarget(self, action: #selector(handleEditTapped_Orna), for: .touchUpInside)
        segmentControl_Orna.onSelectionChanged_Orna = { [weak self] index_orna in
            self?.selectedTab_Orna = index_orna == 0 ? .posts_Orna : .liked_Orna
            self?.refreshList_Orna()
        }
    }

    /// 监听用户与帖子状态变化，实时刷新资料与列表
    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: TitleViewModel_Orna.titleStateDidChangeNotification_Orna, object: nil
        )
    }

    // MARK: - 数据刷新

    @objc private func refreshAll_Orna() {
        let user_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        let isLoggedIn_orna = UserViewModel_Orna.shared_Orna.isLoggedIn_Orna

        nameLabel_Orna.text = isLoggedIn_orna ? (user_orna.userName_Orna ?? "Wanderer") : "Guest"
        bioLabel_Orna.text = isLoggedIn_orna
            ? ((user_orna.userIntroduce_Orna?.isEmpty == false) ? user_orna.userIntroduce_Orna : "No bio yet — tell others about your desk!")
            : "Log in to build your own ornament collection"

        followStatView_Orna.configure_Orna(count_orna: user_orna.userFollow_Orna.count, title_orna: "Following")
        likeStatView_Orna.configure_Orna(count_orna: user_orna.userLike_Orna.count, title_orna: "Liked")
        postStatView_Orna.configure_Orna(count_orna: user_orna.userPosts_Orna.count, title_orna: "Posts")

        // 徽标胶囊：将首页摆件收藏/签到闭环功能的真实数据延伸展示到个人资料页
        let ownedOrnamentsCount_orna = UserViewModel_Orna.shared_Orna.getOwnedOrnaments_Orna().count
        let checkInStreak_orna = UserViewModel_Orna.shared_Orna.getCheckInStreak_Orna()
        ornamentBadgeView_Orna.configure_Orna(icon_orna: "gift.fill", text_orna: "\(ownedOrnamentsCount_orna) Collected")
        streakBadgeView_Orna.configure_Orna(icon_orna: "flame.fill", text_orna: "\(checkInStreak_orna) Day Streak")

        refreshList_Orna()
    }

    /// 根据当前选中标签刷新帖子列表
    private func refreshList_Orna() {
        segmentControl_Orna.setSelectedIndex_Orna(selectedTab_Orna == .posts_Orna ? 0 : 1)
        listStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let user_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        let posts_orna = selectedTab_Orna == .posts_Orna ? user_orna.userPosts_Orna : user_orna.userLike_Orna

        emptyStateView_Orna.isHidden = !posts_orna.isEmpty
        if selectedTab_Orna == .posts_Orna {
            emptyStateView_Orna.configure_Orna(
                icon_orna: "square.stack.3d.up.slash.fill",
                title_orna: "No posts yet",
                subtitle_orna: "Share your first desk moment with the community"
            )
        } else {
            emptyStateView_Orna.configure_Orna(
                icon_orna: "heart.slash.fill",
                title_orna: "No likes yet",
                subtitle_orna: "Explore the community and like what inspires you"
            )
        }

        for post_orna in posts_orna.reversed() {
            let card_orna = PostCardView_Orna()
            card_orna.configure_Orna(post_orna: post_orna, from: self, showAuthor_orna: false, mediaHeight_orna: 170) { [weak self] in
                self?.refreshAll_Orna()
            }
            listStack_Orna.addArrangedSubview(card_orna)
        }
    }

    // MARK: - 事件处理

    @objc private func handleSettingsTapped_Orna() {
        Navigation_Orna.toSetting_Orna()
    }

    @objc private func handleEditTapped_Orna() {
        handleAvatarTapped_Orna()
    }

    /// 处理头像/编辑点击：直接进入修改资料页，无需预先校验登录状态
    /// （未登录时资料页展示访客默认数据，实际保存修改时仍会在 EditInfo_Orna 内校验登录并引导登录）
    private func handleAvatarTapped_Orna() {
        Navigation_Orna.toEditInfo_Orna()
    }
}

// MARK: - 徽标胶囊视图

/// 徽标胶囊视图（图标 + 文案，白色半透明背景）
/// 核心作用：以轻量胶囊形式在渐变资料卡上展示摆件收藏数、连续签到天数等强调数据，
///           丰富信息层次的同时不干扰主视觉（头像/昵称/统计行）
private class BadgeChipView_Orna: UIView {

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let textLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.18)
        layer.cornerRadius = 13

        addSubview(iconView_Orna)
        addSubview(textLabel_Orna)
        iconView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        textLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(iconView_Orna.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置徽标图标与文案
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - text_orna: 展示文案
    func configure_Orna(icon_orna: String, text_orna: String) {
        iconView_Orna.image = UIImage(systemName: icon_orna)
        textLabel_Orna.text = text_orna
    }
}
