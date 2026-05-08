import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心页面控制器
/// 核心作用：展示指定用户的渐变头图资料、关注与聊天入口、帖子列表。
/// 设计思路：页面分为渐变英雄头图区、悬浮操作卡、帖子列表三部分；
///          关注、聊天、举报删除逻辑走现有 ViewModel、导航和助手类。
/// 关键属性：`followButton_Posture`、`statsPostsLabel_Posture` 等在 `refreshUI_Posture()` 中响应式更新。
/// 关键方法：`refreshUI_Posture()` 刷新资料，`handleMessageTap_Posture()` 执行聊天确认流程。
@MainActor
class UserInfo_Posture: UIViewController {

    // MARK: - 外部传入

    var userModel_Posture: PrewUserModel_Posture?

    // MARK: - 存储属性（需在 refreshUI 中更新）

    private let avatarView_Posture   = UserAvatarView_Posture()
    private let nameLabel_Posture    = UILabel()
    private let introLabel_Posture   = UILabel()
    private let followButton_Posture = UIButton(type: .system)
    private let followingChip_Posture = UIView()

    private let statsPostsLabel_Posture  = UILabel()
    private let statsFansLabel_Posture   = UILabel()
    private let statsFollowLabel_Posture = UILabel()

    private let postStackView_Posture = UIStackView()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshUI_Posture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observeState_Posture()
        refreshUI_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建用户中心完整 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        setupBackgroundGlows_Posture()

        // 滚动容器
        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = false
        scrollView_Posture.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        scrollView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        // 各区块
        let heroSection_Posture   = buildHeroSection_Posture()
        let actionCard_Posture    = buildActionCard_Posture()
        let postsSection_Posture  = buildPostsSection_Posture()

        contentView_Posture.addSubview(heroSection_Posture)

        // 操作卡叠加在英雄图底部
        let actionWrapper_Posture = UIView()
        actionWrapper_Posture.addSubview(actionCard_Posture)
        actionCard_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-24)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-4)
        }
        contentView_Posture.addSubview(actionWrapper_Posture)
        contentView_Posture.addSubview(postsSection_Posture)

        heroSection_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        actionWrapper_Posture.snp.makeConstraints { make in
            make.top.equalTo(heroSection_Posture.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        postsSection_Posture.snp.makeConstraints { make in
            make.top.equalTo(actionWrapper_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-130)
        }

        // 悬浮按钮（z-order 高于滚动内容）
        let backButton_Posture = buildFloatingIconButton_Posture(
            icon: "chevron.left",
            tint: ColorConfig_Posture.textPrimary_Posture
        )
        backButton_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)

        let reportButton_Posture = ReportDeleteHelper_Posture.createUserReportButton_Posture(
            size_Posture: 44,
            backgroundColor_Posture: UIColor.white.withAlphaComponent(0.22),
            tintColor_Posture: .white,
            withShadow_Posture: false
        )
        reportButton_Posture.addAction(UIAction { [weak self] _ in
            guard let self_Posture = self, let user_Posture = self_Posture.userModel_Posture else { return }
            ReportDeleteHelper_Posture.block_Posture(user_Posture: user_Posture, from: self_Posture)
        }, for: .touchUpInside)

        view.addSubview(backButton_Posture)
        view.addSubview(reportButton_Posture)

        backButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        reportButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().inset(18)
            make.width.height.equalTo(44)
        }
    }

    // MARK: - 区块构建

    /// 搭建背景光晕
    private func setupBackgroundGlows_Posture() {
        [
            (ColorConfig_Posture.accentCyan_Posture.withAlphaComponent(0.13),    CGFloat(180), true,   50.0, 260.0),
            (ColorConfig_Posture.secondaryGradientStart_Posture.withAlphaComponent(0.12), CGFloat(140), false, -40.0, 500.0),
            (ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.1),     CGFloat(120), true,   44.0, 620.0),
        ].forEach { cfg_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = cfg_Posture.0
            blob_Posture.layer.cornerRadius = cfg_Posture.1 / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 0)
            blob_Posture.snp.makeConstraints { make in
                if cfg_Posture.2 { make.trailing.equalToSuperview().offset(cfg_Posture.3)
                } else { make.leading.equalToSuperview().offset(cfg_Posture.3) }
                make.top.equalToSuperview().offset(cfg_Posture.4)
                make.width.height.equalTo(cfg_Posture.1)
            }
        }
    }

    /// 构建英雄头图区（渐变背景 + 头像 + 名字 + 简介 + 统计行 + Following 徽章）
    /// - Parameters: 无
    /// - Returns: UIView - 英雄头图视图
    /// - Throws: 无
    private func buildHeroSection_Posture() -> UIView {
        let hero_Posture = UIView()
        hero_Posture.layer.cornerRadius = 40
        hero_Posture.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        hero_Posture.clipsToBounds = true

        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            UIColor(hexstring_Posture: "#00B4D8").cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            UIColor(hexstring_Posture: "#48CAE4").cgColor
        ]
        grad_Posture.startPoint = CGPoint(x: 0, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 1, y: 1)
        hero_Posture.layer.insertSublayer(grad_Posture, at: 0)

        // 装饰泡泡
        let bubble1_Posture = makeDecorCircle_Posture(size: 110, alpha: 0.11)
        let bubble2_Posture = makeDecorCircle_Posture(size: 65, alpha: 0.09)

        // 头像外环
        let ringView_Posture = UIView()
        ringView_Posture.backgroundColor = .white
        ringView_Posture.layer.cornerRadius = 60

        let innerRing_Posture = UIView()
        innerRing_Posture.backgroundColor = UIColor(hexstring_Posture: "#00B4D8")
        innerRing_Posture.layer.cornerRadius = 56
        ringView_Posture.addSubview(innerRing_Posture)
        innerRing_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(112)
        }

        avatarView_Posture.layer.cornerRadius = 50
        avatarView_Posture.clipsToBounds = true
        ringView_Posture.addSubview(avatarView_Posture)
        avatarView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        // 用户名
        nameLabel_Posture.font = .systemFont(ofSize: 26, weight: .heavy)
        nameLabel_Posture.textColor = .white
        nameLabel_Posture.textAlignment = .center

        // 简介
        introLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        introLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)
        introLabel_Posture.textAlignment = .center
        introLabel_Posture.numberOfLines = 2

        // Following 徽章（关注后才显示）
        followingChip_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        followingChip_Posture.layer.cornerRadius = 15
        followingChip_Posture.isHidden = true

        let chipIcon_Posture = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        chipIcon_Posture.tintColor = ColorConfig_Posture.accentMint_Posture
        chipIcon_Posture.contentMode = .scaleAspectFit
        let chipLabel_Posture = UILabel()
        chipLabel_Posture.text = "Following"
        chipLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        chipLabel_Posture.textColor = .white
        followingChip_Posture.addSubview(chipIcon_Posture)
        followingChip_Posture.addSubview(chipLabel_Posture)
        chipIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        chipLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(chipIcon_Posture.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        // 统计行
        let statsRow_Posture = buildHeroStatsRow_Posture()

        hero_Posture.addSubview(bubble1_Posture)
        hero_Posture.addSubview(bubble2_Posture)
        hero_Posture.addSubview(ringView_Posture)
        hero_Posture.addSubview(nameLabel_Posture)
        hero_Posture.addSubview(introLabel_Posture)
        hero_Posture.addSubview(followingChip_Posture)
        hero_Posture.addSubview(statsRow_Posture)

        let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44

        bubble1_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(32)
            make.top.equalToSuperview().offset(safeTop_Posture + 10)
            make.width.height.equalTo(110)
        }
        bubble2_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-22)
            make.bottom.equalToSuperview().offset(28)
            make.width.height.equalTo(65)
        }
        ringView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 62)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        nameLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(ringView_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        introLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        followingChip_Posture.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Posture.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        statsRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(followingChip_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-32)
        }

        DispatchQueue.main.async { grad_Posture.frame = hero_Posture.bounds }
        return hero_Posture
    }

    /// 构建英雄区统计行（帖子 / 粉丝 / 关注）
    /// - Parameters: 无
    /// - Returns: UIView - 统计行
    /// - Throws: 无
    private func buildHeroStatsRow_Posture() -> UIView {
        let row_Posture = UIView()

        let divider1_Posture = makeStatsDivider_Posture()
        let divider2_Posture = makeStatsDivider_Posture()

        let postsItem_Posture  = makeHeroStatItem_Posture(label: statsPostsLabel_Posture,  caption: "Posts")
        let fansItem_Posture   = makeHeroStatItem_Posture(label: statsFansLabel_Posture,   caption: "Fans")
        let followItem_Posture = makeHeroStatItem_Posture(label: statsFollowLabel_Posture, caption: "Following")

        [postsItem_Posture, divider1_Posture, fansItem_Posture, divider2_Posture, followItem_Posture].forEach {
            row_Posture.addSubview($0)
        }

        postsItem_Posture.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.333)
        }
        divider1_Posture.snp.makeConstraints { make in
            make.leading.equalTo(postsItem_Posture.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        fansItem_Posture.snp.makeConstraints { make in
            make.leading.equalTo(divider1_Posture.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.334)
        }
        divider2_Posture.snp.makeConstraints { make in
            make.leading.equalTo(fansItem_Posture.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        followItem_Posture.snp.makeConstraints { make in
            make.leading.equalTo(divider2_Posture.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }

        row_Posture.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        return row_Posture
    }

    /// 创建单个英雄统计项
    private func makeHeroStatItem_Posture(label: UILabel, caption: String) -> UIView {
        let v_Posture = UIView()
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "0"

        let capLabel_Posture = UILabel()
        capLabel_Posture.text = caption
        capLabel_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        capLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.72)
        capLabel_Posture.textAlignment = .center

        v_Posture.addSubview(label)
        v_Posture.addSubview(capLabel_Posture)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.trailing.equalToSuperview()
        }
        capLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview()
        }
        return v_Posture
    }

    /// 创建统计分割线
    private func makeStatsDivider_Posture() -> UIView {
        let v_Posture = UIView()
        v_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return v_Posture
    }

    /// 构建悬浮操作卡（关注 + 消息）
    /// - Parameters: 无
    /// - Returns: UIView - 操作卡
    /// - Throws: 无
    private func buildActionCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 28
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 18
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 10)

        followButton_Posture.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        followButton_Posture.layer.cornerRadius = 22
        followButton_Posture.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        followButton_Posture.addAction(UIAction { [weak self] _ in self?.handleFollowTap_Posture() }, for: .touchUpInside)

        let messageButton_Posture = UIButton(type: .system)
        messageButton_Posture.setTitle("  Message", for: .normal)
        messageButton_Posture.setImage(UIImage(systemName: "message.fill"), for: .normal)
        messageButton_Posture.tintColor = .white
        messageButton_Posture.setTitleColor(.white, for: .normal)
        messageButton_Posture.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        messageButton_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        messageButton_Posture.layer.cornerRadius = 22
        messageButton_Posture.addAction(UIAction { [weak self] _ in self?.handleMessageTap_Posture() }, for: .touchUpInside)

        let stack_Posture = UIStackView(arrangedSubviews: [followButton_Posture, messageButton_Posture])
        stack_Posture.axis = .horizontal
        stack_Posture.spacing = 12
        stack_Posture.distribution = .fillEqually

        card_Posture.addSubview(stack_Posture)
        stack_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
        }

        return card_Posture
    }

    /// 构建帖子列表区块
    /// - Parameters: 无
    /// - Returns: UIView - 帖子列表容器
    /// - Throws: 无
    private func buildPostsSection_Posture() -> UIView {
        let wrapper_Posture = UIView()

        let headerLabel_Posture = UILabel()
        headerLabel_Posture.text = "Posture Stories"
        headerLabel_Posture.font = .systemFont(ofSize: 20, weight: .heavy)
        headerLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let dotView_Posture = UIView()
        dotView_Posture.backgroundColor = UIColor(hexstring_Posture: "#00B4D8")
        dotView_Posture.layer.cornerRadius = 5

        postStackView_Posture.axis = .vertical
        postStackView_Posture.spacing = 14

        wrapper_Posture.addSubview(dotView_Posture)
        wrapper_Posture.addSubview(headerLabel_Posture)
        wrapper_Posture.addSubview(postStackView_Posture)

        dotView_Posture.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(10)
        }
        headerLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(dotView_Posture)
            make.leading.equalTo(dotView_Posture.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
        }
        postStackView_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerLabel_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return wrapper_Posture
    }

    /// 创建悬浮图标按钮
    private func buildFloatingIconButton_Posture(icon: String, tint: UIColor) -> UIButton {
        let btn_Posture = UIButton(type: .system)
        btn_Posture.setImage(UIImage(systemName: icon), for: .normal)
        btn_Posture.tintColor = tint
        btn_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        btn_Posture.layer.cornerRadius = 22
        btn_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        btn_Posture.layer.shadowOpacity = 1
        btn_Posture.layer.shadowRadius  = 8
        btn_Posture.layer.shadowOffset  = CGSize(width: 0, height: 4)
        return btn_Posture
    }

    /// 创建装饰圆
    private func makeDecorCircle_Posture(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Posture = UIView()
        v_Posture.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Posture.layer.cornerRadius = size / 2
        v_Posture.isUserInteractionEnabled = false
        return v_Posture
    }

    // MARK: - 数据刷新

    /// 监听状态变化
    private func observeState_Posture() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange_Posture), name: UserViewModel_Posture.userStateDidChangeNotification_Posture, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange_Posture), name: TitleViewModel_Posture.titleStateDidChangeNotification_Posture, object: nil)
    }

    @objc private func handleStateChange_Posture() { refreshUI_Posture() }

    /// 刷新页面数据与样式
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func refreshUI_Posture() {
        guard let user_Posture = userModel_Posture, isViewLoaded else { return }

        avatarView_Posture.configure_Posture(userId_Posture: user_Posture.userId_Posture ?? 0)
        nameLabel_Posture.text  = user_Posture.userName_Posture ?? "User"
        introLabel_Posture.text = user_Posture.userIntroduce_Posture ?? "Sharing mindful posture habits."

        // 统计
        let postsCount_Posture = TitleViewModel_Posture.shared_Posture.getUserPosts_Posture(user_posture: user_Posture).count
        statsPostsLabel_Posture.text  = "\(postsCount_Posture)"
        statsFansLabel_Posture.text   = "\(user_Posture.userFans_Posture ?? 0)"
        statsFollowLabel_Posture.text = "\(user_Posture.userFollow_Posture ?? 0)"

        // 关注状态
        let following_Posture = UserViewModel_Posture.shared_Posture.isFollowing_Posture(user_posture: user_Posture)
        followingChip_Posture.isHidden = !following_Posture

        followButton_Posture.setTitle(following_Posture ? "  Following" : "  Follow", for: .normal)
        followButton_Posture.setImage(UIImage(systemName: following_Posture ? "checkmark" : "plus"), for: .normal)
        followButton_Posture.tintColor = following_Posture ? .white : UIColor(hexstring_Posture: "#00B4D8")
        followButton_Posture.setTitleColor(following_Posture ? .white : UIColor(hexstring_Posture: "#00B4D8"), for: .normal)
        followButton_Posture.backgroundColor = following_Posture
            ? UIColor(hexstring_Posture: "#00B4D8")
            : UIColor(hexstring_Posture: "#00B4D8").withAlphaComponent(0.12)

        renderPosts_Posture(user_Posture: user_Posture)
    }

    /// 渲染用户帖子列表
    /// - Parameter user_Posture: 用户模型
    /// - Returns: Void
    /// - Throws: 无
    private func renderPosts_Posture(user_Posture: PrewUserModel_Posture) {
        postStackView_Posture.arrangedSubviews.forEach { view_Posture in
            postStackView_Posture.removeArrangedSubview(view_Posture)
            view_Posture.removeFromSuperview()
        }

        let posts_Posture = TitleViewModel_Posture.shared_Posture.getUserPosts_Posture(user_posture: user_Posture)

        guard !posts_Posture.isEmpty else {
            postStackView_Posture.addArrangedSubview(makeEmptyPosts_Posture())
            return
        }

        posts_Posture.enumerated().forEach { index_Posture, post_Posture in
            let card_Posture = UserInfoPostCard_Posture()
            card_Posture.configure_Posture(post_posture: post_Posture, index_posture: index_Posture, parent_Posture: self)
            postStackView_Posture.addArrangedSubview(card_Posture)
            card_Posture.animateSlideInFromBottom_Posture(delay_Posture: Double(index_Posture) * 0.05)
        }
    }

    /// 创建空帖子状态
    private func makeEmptyPosts_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 26

        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = UIColor(hexstring_Posture: "#00B4D8").withAlphaComponent(0.12)
        iconBg_Posture.layer.cornerRadius = 32

        let icon_Posture = UIImageView(image: UIImage(systemName: "text.bubble"))
        icon_Posture.tintColor = UIColor(hexstring_Posture: "#00B4D8")
        icon_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(icon_Posture)
        icon_Posture.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(28) }

        let label_Posture = UILabel()
        label_Posture.text = "No posture stories yet."
        label_Posture.font = .systemFont(ofSize: 15, weight: .semibold)
        label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        label_Posture.textAlignment = .center

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(label_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        label_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        card_Posture.snp.makeConstraints { make in make.height.equalTo(140) }
        return card_Posture
    }

    // MARK: - 事件处理

    /// 处理关注点击
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func handleFollowTap_Posture() {
        guard let user_Posture = userModel_Posture else { return }
        UserViewModel_Posture.shared_Posture.followUser_Posture(user_posture: user_Posture)
        refreshUI_Posture()
    }

    /// 处理消息点击
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func handleMessageTap_Posture() {
        guard let user_Posture = userModel_Posture else { return }
        guard UserViewModel_Posture.shared_Posture.isFollowing_Posture(user_posture: user_Posture) else {
            Utils_Posture.showWarning_Posture(message_Posture: "Follow this user before messaging.")
            return
        }
        let alert_Posture = UIAlertController(
            title: "Start Chat",
            message: "\(user_Posture.userName_Posture ?? "User") · \(user_Posture.userIntroduce_Posture ?? "Posture friend")",
            preferredStyle: .actionSheet
        )
        alert_Posture.addAction(UIAlertAction(title: "Enter Chat", style: .default) { _ in
            Navigation_Posture.toMessageUser_Posture(with: user_Posture)
        })
        alert_Posture.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Posture, animated: true)
    }
}

// MARK: - 用户中心帖子卡片

/// 用户中心帖子卡片
/// 核心作用：展示用户帖子摘要，含彩色左条、芯片元信息和举报/删除入口。
/// 设计思路：按 index 从调色盘取色，点赞/评论数通过芯片展示，报告操作复用助手类。
/// 关键属性：`stripeView_Posture` 为彩色左条，`chipsStack_Posture` 为底部元信息区。
/// 关键方法：`configure_Posture(post_posture:index_posture:parent_Posture:)`。
@MainActor
private class UserInfoPostCard_Posture: UIView {

    private let cardView_Posture      = UIView()
    private let stripeView_Posture    = UIView()
    private let titleLabel_Posture    = UILabel()
    private let contentLabel_Posture  = UILabel()
    private let chipsStack_Posture    = UIStackView()
    private var reportButton_Posture: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCardUI_Posture() {
        addSubview(cardView_Posture)
        cardView_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        cardView_Posture.layer.cornerRadius = 26
        cardView_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        cardView_Posture.layer.shadowOpacity = 1
        cardView_Posture.layer.shadowRadius  = 14
        cardView_Posture.layer.shadowOffset  = CGSize(width: 0, height: 8)
        cardView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

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

    /// 绑定帖子数据并应用调色盘颜色
    /// - Parameters:
    ///   - post_posture: 帖子模型
    ///   - index_posture: 列表索引
    ///   - parent_Posture: 父页面，用于举报/删除弹窗
    /// - Returns: Void
    /// - Throws: 无
    func configure_Posture(post_posture: TitleModel_Posture, index_posture: Int, parent_Posture: UIViewController) {
        let palette_Posture = ColorConfig_Posture.cardAccentPalette_Posture[index_posture % ColorConfig_Posture.cardAccentPalette_Posture.count]
        stripeView_Posture.backgroundColor = palette_Posture.main
        cardView_Posture.layer.shadowColor = palette_Posture.shadow.cgColor

        titleLabel_Posture.text   = post_posture.title_Posture
        contentLabel_Posture.text = post_posture.titleContent_Posture

        chipsStack_Posture.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chipsStack_Posture.addArrangedSubview(makeChip_Posture("heart.fill",       "\(post_posture.likes_Posture)",           ColorConfig_Posture.secondaryGradientStart_Posture))
        chipsStack_Posture.addArrangedSubview(makeChip_Posture("bubble.left.fill", "\(post_posture.reviews_Posture.count)", ColorConfig_Posture.accentIndigo_Posture))
        chipsStack_Posture.addArrangedSubview(makeChip_Posture("photo.fill",       post_posture.titleMeidas_Posture.isEmpty ? "Text" : "Media", palette_Posture.main))

        reportButton_Posture?.removeFromSuperview()
        let btn_Posture = ReportDeleteHelper_Posture.createPostReportButton_Posture(
            post_Posture: post_posture, size_Posture: 16,
            color_Posture: ColorConfig_Posture.textSecondary_Posture, from: parent_Posture
        )
        cardView_Posture.addSubview(btn_Posture)
        btn_Posture.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(14)
            make.width.height.equalTo(32)
        }
        reportButton_Posture = btn_Posture
    }

    /// 创建元信息芯片
    private func makeChip_Posture(_ icon: String, _ text: String, _ color: UIColor) -> UIView {
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
        chip_Posture.snp.makeConstraints { make in make.height.equalTo(26) }
        return chip_Posture
    }
}
