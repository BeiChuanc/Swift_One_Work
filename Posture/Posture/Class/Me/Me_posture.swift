import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面控制器
/// 核心作用：展示当前登录用户的资料、统计、帖子/喜欢列表，并提供编辑资料、设置入口。
/// 设计思路：页面整体由渐变头图英雄区、统计行、Tab 切换器、帖子列表四部分构成，
///          数据从 `UserViewModel_Posture` 和 `TitleViewModel_Posture` 读取，通过通知自动刷新。
/// 关键属性：`postsCountLabel_Posture` 等统计标签，`tabMyPostsBtn_Posture` / `tabLikesBtn_Posture` Tab 按钮，
///          `postStackView_Posture` 渲染帖子列表。
/// 关键方法：`reloadUserState_Posture()` 刷新资料与统计，`renderPosts_Posture()` 渲染帖子卡片。
@MainActor
class Me_Posture: UIViewController {

    // MARK: - 外部传入

    var meModel_Posture: LoginUserModel_Posture?

    // MARK: - 存储属性

    /// 页面滚动容器
    private let scrollView_Posture = UIScrollView()

    /// 内容总栈
    private let contentStackView_Posture = UIStackView()

    /// 用户头像组件
    private let avatarView_Posture = CurrentUserAvatarView_Posture()

    /// 用户名称标签
    private let nameLabel_Posture = UILabel()

    /// 用户简介标签
    private let introLabel_Posture = UILabel()

    /// 头像彩色光环（渐变边框）
    private let avatarRingView_Posture = UIView()

    // 统计数值标签
    private let postsCountLabel_Posture  = UILabel()
    private let likesCountLabel_Posture  = UILabel()
    private let followCountLabel_Posture = UILabel()

    // Tab 切换按钮
    private let tabMyPostsBtn_Posture = UIButton(type: .system)
    private let tabLikesBtn_Posture   = UIButton(type: .system)

    /// 帖子/喜欢列表容器
    private let postStackView_Posture = UIStackView()

    /// 当前展示类型（false = 发布，true = 喜欢）
    private var showLikes_Posture = false

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUserState_Posture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observeState_Posture()
        reloadUserState_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建页面主体 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        setupBackgroundGlows_Posture()

        scrollView_Posture.showsVerticalScrollIndicator = false
        scrollView_Posture.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        contentView_Posture.addSubview(contentStackView_Posture)

        contentStackView_Posture.axis = .vertical
        contentStackView_Posture.spacing = 0

        scrollView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }
        contentStackView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 各区块
        let heroSection_Posture = buildHeroSection_Posture()
        let statsCard_Posture   = buildStatsCard_Posture()
        let tabBar_Posture      = buildTabBar_Posture()
        let postSection_Posture = buildPostSection_Posture()

        contentStackView_Posture.addArrangedSubview(heroSection_Posture)

        // 统计卡片叠加在英雄图底部（上移 26pt）
        let statsWrapper_Posture = UIView()
        statsWrapper_Posture.backgroundColor = .clear
        statsWrapper_Posture.addSubview(statsCard_Posture)
        statsCard_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-26)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-2)
        }
        contentStackView_Posture.addArrangedSubview(statsWrapper_Posture)

        contentStackView_Posture.setCustomSpacing(18, after: statsWrapper_Posture)
        contentStackView_Posture.addArrangedSubview(tabBar_Posture)
        contentStackView_Posture.setCustomSpacing(14, after: tabBar_Posture)
        contentStackView_Posture.addArrangedSubview(postSection_Posture)

        postStackView_Posture.axis = .vertical
        postStackView_Posture.spacing = 14
    }

    /// 搭建背景光晕装饰
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupBackgroundGlows_Posture() {
        [
            (ColorConfig_Posture.accentFuchsia_Posture.withAlphaComponent(0.14), 200, -60.0,  -40.0),
            (ColorConfig_Posture.accentIndigo_Posture.withAlphaComponent(0.12),  160,  52.0,  220.0),
            (ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.13),    130, -44.0,  500.0),
        ].forEach { cfg_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = cfg_Posture.0
            blob_Posture.layer.cornerRadius = CGFloat(cfg_Posture.1) / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 0)
            blob_Posture.snp.makeConstraints { make in
                if cfg_Posture.2 < 0 {
                    make.leading.equalToSuperview().offset(cfg_Posture.2)
                } else {
                    make.trailing.equalToSuperview().offset(cfg_Posture.2)
                }
                make.top.equalToSuperview().offset(cfg_Posture.3)
                make.width.height.equalTo(CGFloat(cfg_Posture.1))
            }
        }
    }

    // MARK: - 区块构建

    /// 构建英雄头图区（渐变背景 + 头像 + 名称 + 简介 + 设置按钮）
    /// - Parameters: 无
    /// - Returns: UIView - 英雄头图视图
    /// - Throws: 无
    private func buildHeroSection_Posture() -> UIView {
        let hero_Posture = UIView()
        hero_Posture.layer.cornerRadius = 40
        hero_Posture.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        hero_Posture.clipsToBounds = true

        // 渐变层：品红→薰衣草→靛蓝
        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            ColorConfig_Posture.accentFuchsia_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.accentIndigo_Posture.cgColor
        ]
        grad_Posture.startPoint = CGPoint(x: 0, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 1, y: 1)
        hero_Posture.layer.insertSublayer(grad_Posture, at: 0)

        // 装饰泡泡
        let bubble1_Posture = makeDecorBubble_Posture(size: 120, alpha: 0.12)
        let bubble2_Posture = makeDecorBubble_Posture(size: 70,  alpha: 0.09)

        // 设置按钮
        let settingsBtn_Posture = UIButton(type: .system)
        settingsBtn_Posture.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsBtn_Posture.tintColor = UIColor.white.withAlphaComponent(0.88)
        settingsBtn_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        settingsBtn_Posture.layer.cornerRadius = 22
        settingsBtn_Posture.addAction(UIAction { _ in Navigation_Posture.toSetting_Posture() }, for: .touchUpInside)

        // 头像环（渐变边框效果：外层纯白，内层深色，中间头像）
        avatarRingView_Posture.backgroundColor = .white
        avatarRingView_Posture.layer.cornerRadius = 58
        let ringInner_Posture = UIView()
        ringInner_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        ringInner_Posture.layer.cornerRadius = 54
        avatarRingView_Posture.addSubview(ringInner_Posture)
        ringInner_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(108)
        }
        avatarView_Posture.loadCurrentUserAvatar_Posture()
        avatarRingView_Posture.addSubview(avatarView_Posture)
        avatarView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        // 相机编辑按钮叠加在头像右下角
        let editOverlayBtn_Posture = UIButton(type: .system)
        editOverlayBtn_Posture.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        editOverlayBtn_Posture.tintColor = .white
        editOverlayBtn_Posture.backgroundColor = ColorConfig_Posture.accentIndigo_Posture
        editOverlayBtn_Posture.layer.cornerRadius = 17
        editOverlayBtn_Posture.layer.borderWidth = 2.5
        editOverlayBtn_Posture.layer.borderColor = UIColor.white.cgColor
        editOverlayBtn_Posture.addAction(UIAction { _ in Navigation_Posture.toEditInfo_Posture() }, for: .touchUpInside)

        // 名字
        nameLabel_Posture.font = .systemFont(ofSize: 24, weight: .heavy)
        nameLabel_Posture.textColor = .white
        nameLabel_Posture.textAlignment = .center

        // 简介
        introLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        introLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)
        introLabel_Posture.textAlignment = .center
        introLabel_Posture.numberOfLines = 2

        // 身份徽章
        let badgeView_Posture = buildIdentityBadge_Posture()

        hero_Posture.addSubview(bubble1_Posture)
        hero_Posture.addSubview(bubble2_Posture)
        hero_Posture.addSubview(settingsBtn_Posture)
        hero_Posture.addSubview(avatarRingView_Posture)
        hero_Posture.addSubview(editOverlayBtn_Posture)
        hero_Posture.addSubview(nameLabel_Posture)
        hero_Posture.addSubview(introLabel_Posture)
        hero_Posture.addSubview(badgeView_Posture)

        let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44

        bubble1_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-38)
            make.top.equalToSuperview().offset(safeTop_Posture + 10)
            make.width.height.equalTo(120)
        }
        bubble2_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(-40)
            make.width.height.equalTo(70)
        }
        settingsBtn_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 14)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(44)
        }
        avatarRingView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 62)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(116)
        }
        editOverlayBtn_Posture.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarRingView_Posture).inset(0)
            make.width.height.equalTo(34)
        }
        nameLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        introLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        badgeView_Posture.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Posture.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-38)
            make.height.equalTo(32)
        }

        DispatchQueue.main.async {
            grad_Posture.frame = hero_Posture.bounds
        }

        return hero_Posture
    }

    /// 构建身份徽章（Posture Achiever 等）
    /// - Parameters: 无
    /// - Returns: UIView - 身份徽章视图
    /// - Throws: 无
    private func buildIdentityBadge_Posture() -> UIView {
        let badge_Posture = UIView()
        badge_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        badge_Posture.layer.cornerRadius = 16

        let icon_Posture = UIImageView(image: UIImage(systemName: "star.fill"))
        icon_Posture.tintColor = ColorConfig_Posture.accentAmber_Posture
        icon_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = "Posture Achiever"
        label_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        label_Posture.textColor = .white

        badge_Posture.addSubview(icon_Posture)
        badge_Posture.addSubview(label_Posture)

        icon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(icon_Posture.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }

        return badge_Posture
    }

    /// 构建统计行卡片（帖子数 / 喜欢数 / 关注数）
    /// - Parameters: 无
    /// - Returns: UIView - 三栏统计卡片
    /// - Throws: 无
    private func buildStatsCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 28
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 18
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 10)

        let stack_Posture = UIStackView()
        stack_Posture.axis = .horizontal
        stack_Posture.distribution = .fillEqually

        let items_Posture: [(UILabel, String, String, UIColor)] = [
            (postsCountLabel_Posture,  "0", "Posts",     ColorConfig_Posture.accentIndigo_Posture),
            (likesCountLabel_Posture,  "0", "Liked",     ColorConfig_Posture.secondaryGradientStart_Posture),
            (followCountLabel_Posture, "0", "Following", ColorConfig_Posture.accentTeal_Posture),
        ]

        items_Posture.enumerated().forEach { idx_Posture, item_Posture in
            stack_Posture.addArrangedSubview(makeStatItem_Posture(
                countLabel: item_Posture.0,
                initialValue: item_Posture.1,
                caption: item_Posture.2,
                accentColor: item_Posture.3,
                showDivider: idx_Posture < 2
            ))
        }

        card_Posture.addSubview(stack_Posture)
        stack_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(18)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        return card_Posture
    }

    /// 创建单个统计项
    /// - Parameters:
    ///   - countLabel: 数值标签（存储引用）
    ///   - initialValue: 初始文字
    ///   - caption: 说明文字
    ///   - accentColor: 强调色
    ///   - showDivider: 是否显示右侧分割线
    /// - Returns: UIView - 统计项视图
    /// - Throws: 无
    private func makeStatItem_Posture(countLabel: UILabel, initialValue: String, caption: String, accentColor: UIColor, showDivider: Bool) -> UIView {
        let container_Posture = UIView()

        countLabel.text = initialValue
        countLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        countLabel.textColor = accentColor
        countLabel.textAlignment = .center

        let captionLabel_Posture = UILabel()
        captionLabel_Posture.text = caption
        captionLabel_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        captionLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        captionLabel_Posture.textAlignment = .center

        let dot_Posture = UIView()
        dot_Posture.backgroundColor = accentColor
        dot_Posture.layer.cornerRadius = 4

        container_Posture.addSubview(dot_Posture)
        container_Posture.addSubview(countLabel)
        container_Posture.addSubview(captionLabel_Posture)

        dot_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(8)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(dot_Posture.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        captionLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        if showDivider {
            let divider_Posture = UIView()
            divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture
            container_Posture.addSubview(divider_Posture)
            divider_Posture.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(1)
                make.height.equalTo(44)
            }
        }

        return container_Posture
    }

    /// 构建 Tab 切换行
    /// - Parameters: 无
    /// - Returns: UIView - Tab 行容器
    /// - Throws: 无
    private func buildTabBar_Posture() -> UIView {
        let wrapper_Posture = UIView()
        wrapper_Posture.backgroundColor = .clear

        let bg_Posture = UIView()
        bg_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        bg_Posture.layer.cornerRadius = 24
        bg_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        bg_Posture.layer.shadowOpacity = 1
        bg_Posture.layer.shadowRadius  = 12
        bg_Posture.layer.shadowOffset  = CGSize(width: 0, height: 6)

        configureTabButton_Posture(tabMyPostsBtn_Posture, title: "My Posts", icon: "rectangle.stack.fill", accentColor: ColorConfig_Posture.accentIndigo_Posture, selected: true)
        configureTabButton_Posture(tabLikesBtn_Posture,   title: "Liked",    icon: "heart.fill",           accentColor: ColorConfig_Posture.secondaryGradientStart_Posture, selected: false)

        tabMyPostsBtn_Posture.addAction(UIAction { [weak self] _ in
            guard let self_Posture = self else { return }
            self_Posture.showLikes_Posture = false
            self_Posture.updateTabAppearance_Posture()
            self_Posture.renderPosts_Posture()
        }, for: .touchUpInside)

        tabLikesBtn_Posture.addAction(UIAction { [weak self] _ in
            guard let self_Posture = self else { return }
            self_Posture.showLikes_Posture = true
            self_Posture.updateTabAppearance_Posture()
            self_Posture.renderPosts_Posture()
        }, for: .touchUpInside)

        bg_Posture.addSubview(tabMyPostsBtn_Posture)
        bg_Posture.addSubview(tabLikesBtn_Posture)

        wrapper_Posture.addSubview(bg_Posture)
        bg_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        tabMyPostsBtn_Posture.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(6)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }
        tabLikesBtn_Posture.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(6)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }

        return wrapper_Posture
    }

    /// 配置 Tab 按钮样式
    /// - Parameters:
    ///   - button: 目标按钮
    ///   - title: 标题
    ///   - icon: 图标名
    ///   - accentColor: 主题色
    ///   - selected: 是否选中
    /// - Returns: Void
    /// - Throws: 无
    private func configureTabButton_Posture(_ button: UIButton, title: String, icon: String, accentColor: UIColor, selected: Bool) {
        button.setTitle("  \(title)", for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.layer.cornerRadius = 20
        button.backgroundColor = selected ? accentColor : .clear
        button.tintColor = selected ? .white : ColorConfig_Posture.textSecondary_Posture
        button.setTitleColor(selected ? .white : ColorConfig_Posture.textSecondary_Posture, for: .normal)
    }

    /// 更新 Tab 选中样式
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func updateTabAppearance_Posture() {
        let isLikes_Posture = showLikes_Posture
        configureTabButton_Posture(tabMyPostsBtn_Posture, title: "My Posts", icon: "rectangle.stack.fill", accentColor: ColorConfig_Posture.accentIndigo_Posture, selected: !isLikes_Posture)
        configureTabButton_Posture(tabLikesBtn_Posture,   title: "Liked",    icon: "heart.fill",           accentColor: ColorConfig_Posture.secondaryGradientStart_Posture, selected: isLikes_Posture)
    }

    /// 构建帖子列表区块（包含 postStackView_Posture）
    /// - Parameters: 无
    /// - Returns: UIView - 帖子区块容器
    /// - Throws: 无
    private func buildPostSection_Posture() -> UIView {
        let wrapper_Posture = UIView()
        wrapper_Posture.backgroundColor = .clear
        wrapper_Posture.addSubview(postStackView_Posture)
        postStackView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-130)
        }
        return wrapper_Posture
    }

    // MARK: - 数据刷新

    /// 监听状态变化
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func observeState_Posture() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange_Posture), name: UserViewModel_Posture.userStateDidChangeNotification_Posture, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange_Posture), name: TitleViewModel_Posture.titleStateDidChangeNotification_Posture, object: nil)
    }

    /// 响应状态变化
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handleStateChange_Posture() {
        reloadUserState_Posture()
    }

    /// 刷新用户状态与统计
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func reloadUserState_Posture() {
        let user_Posture = meModel_Posture ?? UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        nameLabel_Posture.text  = user_Posture.userName_Posture ?? "Guest"
        introLabel_Posture.text = user_Posture.userIntroduce_Posture ?? "Better posture starts with one mindful break."
        avatarView_Posture.loadCurrentUserAvatar_Posture()

        postsCountLabel_Posture.text  = "\(user_Posture.userPosts_Posture.count)"
        likesCountLabel_Posture.text  = "\(user_Posture.userLike_Posture.count)"
        followCountLabel_Posture.text = "\(user_Posture.userFollow_Posture.count)"

        renderPosts_Posture()
    }

    /// 渲染帖子列表
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func renderPosts_Posture() {
        postStackView_Posture.arrangedSubviews.forEach { view_Posture in
            postStackView_Posture.removeArrangedSubview(view_Posture)
            view_Posture.removeFromSuperview()
        }

        let user_Posture = meModel_Posture ?? UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        let posts_Posture = showLikes_Posture ? user_Posture.userLike_Posture : user_Posture.userPosts_Posture

        guard !posts_Posture.isEmpty else {
            postStackView_Posture.addArrangedSubview(makeEmptyState_Posture())
            return
        }

        posts_Posture.enumerated().forEach { index_Posture, post_Posture in
            let card_Posture = MePostCard_Posture()
            card_Posture.configure_Posture(post_posture: post_Posture, index_posture: index_Posture, parent_Posture: self)
            postStackView_Posture.addArrangedSubview(card_Posture)
            card_Posture.animateSlideInFromBottom_Posture(delay_Posture: Double(index_Posture) * 0.05)
        }
    }

    // MARK: - 辅助视图

    /// 创建装饰泡泡
    /// - Parameters:
    ///   - size: 尺寸
    ///   - alpha: 透明度
    /// - Returns: UIView - 装饰圆
    /// - Throws: 无
    private func makeDecorBubble_Posture(size: CGFloat, alpha: CGFloat) -> UIView {
        let view_Posture = UIView()
        view_Posture.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view_Posture.layer.cornerRadius = size / 2
        view_Posture.isUserInteractionEnabled = false
        return view_Posture
    }

    /// 创建空状态视图
    /// - Parameters: 无
    /// - Returns: UIView - 空状态卡片
    /// - Throws: 无
    private func makeEmptyState_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 28

        let accentColor_Posture = showLikes_Posture
            ? ColorConfig_Posture.secondaryGradientStart_Posture
            : ColorConfig_Posture.accentIndigo_Posture

        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = accentColor_Posture.withAlphaComponent(0.12)
        iconBg_Posture.layer.cornerRadius = 34

        let iconView_Posture = UIImageView(image: UIImage(systemName: showLikes_Posture ? "heart.circle.fill" : "square.and.pencil"))
        iconView_Posture.tintColor = accentColor_Posture
        iconView_Posture.contentMode = .scaleAspectFit

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = showLikes_Posture ? "No Liked Posts" : "No Posts Yet"
        titleLabel_Posture.font = .systemFont(ofSize: 17, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.textAlignment = .center

        let subLabel_Posture = UILabel()
        subLabel_Posture.text = showLikes_Posture
            ? "Tap the heart on any post to save it here."
            : "Publish your first posture story from the + tab."
        subLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        subLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        subLabel_Posture.textAlignment = .center
        subLabel_Posture.numberOfLines = 2

        iconBg_Posture.addSubview(iconView_Posture)
        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(subLabel_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(68)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        subLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-28)
        }

        return card_Posture
    }
}

// MARK: - 帖子卡片组件

/// 我的页面帖子卡片
/// 核心作用：展示帖子标题、内容摘要、统计芯片（点赞/评论数）、分类标签，并提供举报/删除入口。
/// 设计思路：左侧彩色装饰条按 index 取色，卡片底部行展示元信息芯片，使布局信息层次清晰。
/// 关键属性：`stripeView_Posture` 为彩色左条，`chipsStack_Posture` 为底部元信息区。
/// 关键方法：`configure_Posture(post_posture:index_posture:parent_Posture:)` 绑定数据。
@MainActor
private class MePostCard_Posture: UIView {

    // MARK: - 子视图

    private let cardView_Posture    = UIView()
    private let stripeView_Posture  = UIView()
    private let titleLabel_Posture  = UILabel()
    private let contentLabel_Posture = UILabel()
    private let chipsStack_Posture  = UIStackView()
    private var reportButton_Posture: UIButton?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 搭建帖子卡片骨架
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        addSubview(cardView_Posture)
        cardView_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        cardView_Posture.layer.cornerRadius = 26
        cardView_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        cardView_Posture.layer.shadowOpacity = 1
        cardView_Posture.layer.shadowRadius  = 14
        cardView_Posture.layer.shadowOffset  = CGSize(width: 0, height: 8)
        cardView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 左侧彩色装饰条
        stripeView_Posture.layer.cornerRadius = 3
        cardView_Posture.addSubview(stripeView_Posture)

        titleLabel_Posture.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 2
        cardView_Posture.addSubview(titleLabel_Posture)

        contentLabel_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        contentLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        contentLabel_Posture.numberOfLines = 2
        cardView_Posture.addSubview(contentLabel_Posture)

        chipsStack_Posture.axis = .horizontal
        chipsStack_Posture.spacing = 8
        cardView_Posture.addSubview(chipsStack_Posture)

        stripeView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(4)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(stripeView_Posture.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(52)
        }

        contentLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel_Posture)
            make.trailing.equalToSuperview().inset(18)
        }

        chipsStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Posture.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel_Posture)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - 数据绑定

    /// 绑定帖子数据并按 index 应用配色
    /// - Parameters:
    ///   - post_posture: 帖子模型
    ///   - index_posture: 列表索引，用于取色盘颜色
    ///   - parent_Posture: 父页面，用于弹出举报/删除弹窗
    /// - Returns: Void
    /// - Throws: 无
    func configure_Posture(post_posture: TitleModel_Posture, index_posture: Int, parent_Posture: UIViewController) {
        let palette_Posture = ColorConfig_Posture.cardAccentPalette_Posture[index_posture % ColorConfig_Posture.cardAccentPalette_Posture.count]

        stripeView_Posture.backgroundColor = palette_Posture.main
        cardView_Posture.layer.shadowColor = palette_Posture.shadow.cgColor

        titleLabel_Posture.text   = post_posture.title_Posture
        contentLabel_Posture.text = post_posture.titleContent_Posture

        // 底部芯片行
        chipsStack_Posture.arrangedSubviews.forEach { chip_Posture in
            chipsStack_Posture.removeArrangedSubview(chip_Posture)
            chip_Posture.removeFromSuperview()
        }
        chipsStack_Posture.addArrangedSubview(makeChip_Posture(icon: "heart.fill", text: "\(post_posture.likes_Posture)", color: ColorConfig_Posture.secondaryGradientStart_Posture))
        chipsStack_Posture.addArrangedSubview(makeChip_Posture(icon: "bubble.left.fill", text: "\(post_posture.reviews_Posture.count)", color: ColorConfig_Posture.accentIndigo_Posture))
        chipsStack_Posture.addArrangedSubview(makeChip_Posture(icon: "photo.fill", text: post_posture.titleMeidas_Posture.isEmpty ? "Text" : "Media", color: palette_Posture.main))

        // 举报/删除按钮
        reportButton_Posture?.removeFromSuperview()
        let btn_Posture = ReportDeleteHelper_Posture.createPostReportButton_Posture(
            post_Posture: post_posture,
            size_Posture: 16,
            color_Posture: ColorConfig_Posture.textSecondary_Posture,
            from: parent_Posture
        )
        cardView_Posture.addSubview(btn_Posture)
        btn_Posture.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(14)
            make.width.height.equalTo(32)
        }
        reportButton_Posture = btn_Posture
    }

    /// 创建元信息芯片
    /// - Parameters:
    ///   - icon: SF Symbols 图标名
    ///   - text: 显示文字
    ///   - color: 芯片颜色
    /// - Returns: UIView - 芯片视图
    /// - Throws: 无
    private func makeChip_Posture(icon: String, text: String, color: UIColor) -> UIView {
        let chip_Posture = UIView()
        chip_Posture.backgroundColor = color.withAlphaComponent(0.12)
        chip_Posture.layer.cornerRadius = 13

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = color
        iconView_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = text
        label_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        label_Posture.textColor = color

        chip_Posture.addSubview(iconView_Posture)
        chip_Posture.addSubview(label_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Posture.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        chip_Posture.snp.makeConstraints { make in
            make.height.equalTo(26)
        }

        return chip_Posture
    }
}
