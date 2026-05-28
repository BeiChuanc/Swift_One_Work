import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心页面
/// 功能：展示指定用户信息，提供关注/消息操作，展示该用户发布的帖子列表（含媒体预览）
/// isFromChat_Ornit = true 时：隐藏消息按钮，关注按钮居中，取消关注后返回消息列表并删除聊天记录
/// 设计：深紫渐变 Header + 操作按钮 + 帖子卡片列表（含媒体）+ 自定义底部聊天确认卡片
class UserInfo_Ornit: UIViewController {

    // MARK: - 公共属性

    /// 展示的用户模型（由导航传入）
    var userModel_Ornit: PrewUserModel_Ornit?

    /// 是否从聊天页进入（控制消息按钮显隐及取消关注逻辑）
    var isFromChat_Ornit: Bool = false

    // MARK: - 私有数据属性

    private var isFollowing_Ornit: Bool {
        guard let user_ornit = userModel_Ornit else { return false }
        return UserViewModel_Ornit.shared_Ornit.isFollowing_Ornit(user_ornit: user_ornit)
    }

    private var userPosts_Ornit: [TitleModel_Ornit] {
        guard let user_ornit = userModel_Ornit else { return [] }
        return TitleViewModel_Ornit.shared_Ornit.getUserPosts_Ornit(user_ornit: user_ornit)
    }

    /// 聊天确认底部卡片引用（用于移除和动画）
    private var chatSheetOverlay_Ornit: UIView?

    // MARK: - 容器组件

    private let scrollView_Ornit = UIScrollView()
    private let contentView_Ornit = UIView()

    // MARK: - Header 组件

    private let headerView_Ornit = UIView()
    private var headerGradient_Ornit: CAGradientLayer?

    private lazy var avatarView_Ornit: UserAvatarView_Ornit = {
        let av_ornit = UserAvatarView_Ornit()
        av_ornit.layer.borderWidth = 4
        av_ornit.layer.borderColor = UIColor.white.cgColor
        return av_ornit
    }()

    private let nameLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label_ornit.textColor = .white
        label_ornit.textAlignment = .center
        return label_ornit
    }()

    private let bioLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.8)
        label_ornit.numberOfLines = 2
        label_ornit.textAlignment = .center
        return label_ornit
    }()

    private let statsRow_Ornit = UIStackView()

    // MARK: - 操作按钮组件

    private let followButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_ornit.layer.cornerRadius = 20
        btn_ornit.layer.masksToBounds = true
        return btn_ornit
    }()

    private var followGradient_Ornit: CAGradientLayer?

    private let messageButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_ornit.setImage(
            UIImage(systemName: "message.fill", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.setTitle("  Message", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_ornit.tintColor = ColorConfig_Ornit.messageAccent_Ornit
        btn_ornit.setTitleColor(ColorConfig_Ornit.messageAccent_Ornit, for: .normal)
        btn_ornit.backgroundColor = .white
        btn_ornit.layer.cornerRadius = 20
        btn_ornit.layer.borderWidth = 1.5
        btn_ornit.layer.borderColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.4).cgColor
        return btn_ornit
    }()

    // MARK: - 帖子列表组件

    private let postsTitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        return label_ornit
    }()

    private let postsStack_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .vertical
        sv_ornit.spacing = 14
        return sv_ornit
    }()

    private let emptyView_Ornit = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        setupScrollView_Ornit()
        setupHeaderView_Ornit()
        setupActionButtons_Ornit()
        setupPostsList_Ornit()
        setupReportButton_Ornit()
        setupNotifications_Ornit()
        refreshUI_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshUI_Ornit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
        avatarView_Ornit.layer.cornerRadius = avatarView_Ornit.bounds.width / 2
        followGradient_Ornit?.frame = followButton_Ornit.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Ornit),
            name: UserViewModel_Ornit.userStateDidChangeNotification_Ornit,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Ornit),
            name: TitleViewModel_Ornit.titleStateDidChangeNotification_Ornit,
            object: nil
        )
    }

    @objc private func handleStateChange_Ornit() { refreshUI_Ornit() }
    @objc private func handleTitleStateChange_Ornit() { refreshPostsList_Ornit() }

    // MARK: - 数据刷新

    private func refreshUI_Ornit() {
        guard let user_ornit = userModel_Ornit else { return }
        avatarView_Ornit.configure_Ornit(userId_Ornit: user_ornit.userId_Ornit ?? 0)
        nameLabel_Ornit.text = user_ornit.userName_Ornit ?? "User"
        bioLabel_Ornit.text = user_ornit.userIntroduce_Ornit ?? "Birdwatching enthusiast"
        refreshStats_Ornit(user_ornit: user_ornit)
        refreshFollowButton_Ornit()
        refreshPostsList_Ornit()
    }

    private func refreshStats_Ornit(user_ornit: PrewUserModel_Ornit) {
        statsRow_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let items_ornit: [(String, Int)] = [
            ("Posts", userPosts_Ornit.count),
            ("Following", user_ornit.userFollow_Ornit ?? 0),
            ("Fans", user_ornit.userFans_Ornit ?? 0)
        ]
        for (i_ornit, (title_ornit, count_ornit)) in items_ornit.enumerated() {
            statsRow_Ornit.addArrangedSubview(makeStatView_Ornit(title_ornit: title_ornit, count_ornit: count_ornit))
            if i_ornit < items_ornit.count - 1 {
                let div_ornit = UIView()
                div_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.3)
                div_ornit.snp.makeConstraints { make_ornit in make_ornit.width.equalTo(1) }
                statsRow_Ornit.addArrangedSubview(div_ornit)
            }
        }
    }

    private func refreshFollowButton_Ornit() {
        followGradient_Ornit?.removeFromSuperlayer()
        followGradient_Ornit = nil

        if isFollowing_Ornit {
            // 已关注：白色背景 + 紫色边框文字
            followButton_Ornit.setTitle("Followed", for: .normal)
            followButton_Ornit.setTitleColor(ColorConfig_Ornit.meAccent_Ornit, for: .normal)
            followButton_Ornit.backgroundColor = .white
            followButton_Ornit.layer.borderWidth = 1.5
            followButton_Ornit.layer.borderColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.4).cgColor
        } else {
            // 未关注：深紫 → 鲜亮紫渐变填充，白色文字
            followButton_Ornit.setTitle("Follow", for: .normal)
            followButton_Ornit.setTitleColor(.white, for: .normal)
            // 必须清空白色背景，否则渐变层被遮住
            followButton_Ornit.backgroundColor = .clear
            followButton_Ornit.layer.borderWidth = 0
            let gradient_ornit = CAGradientLayer()
            gradient_ornit.colors = [
                ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
                ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
            ]
            gradient_ornit.startPoint = CGPoint(x: 0, y: 0.5)
            gradient_ornit.endPoint = CGPoint(x: 1, y: 0.5)
            gradient_ornit.cornerRadius = followButton_Ornit.layer.cornerRadius
            followButton_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
            followGradient_Ornit = gradient_ornit
            // 如果 bounds 已有效，立即设置 frame；否则等 viewDidLayoutSubviews 更新
            if followButton_Ornit.bounds != .zero {
                gradient_ornit.frame = followButton_Ornit.bounds
            }
        }
    }

    private func refreshPostsList_Ornit() {
        postsStack_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts_ornit = userPosts_Ornit
        postsTitleLabel_Ornit.text = "Sightings (\(posts_ornit.count))"
        emptyView_Ornit.isHidden = !posts_ornit.isEmpty
        for post_ornit in posts_ornit {
            postsStack_Ornit.addArrangedSubview(makePostCell_Ornit(post_ornit: post_ornit))
        }
    }

    // MARK: - UI 搭建

    private func setupScrollView_Ornit() {
        scrollView_Ornit.showsVerticalScrollIndicator = false
        scrollView_Ornit.contentInsetAdjustmentBehavior = .never
        scrollView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)
        scrollView_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }
        contentView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.width.equalToSuperview()
        }
    }

    private func setupHeaderView_Ornit() {
        contentView_Ornit.addSubview(headerView_Ornit)

        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit
        headerView_Ornit.layer.cornerRadius = 28
        headerView_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Ornit.clipsToBounds = true

        // 右上角大装饰圆
        let deco1_ornit = UIView()
        deco1_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        deco1_ornit.layer.cornerRadius = 72
        headerView_Ornit.addSubview(deco1_ornit)

        // 左下小装饰圆
        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco2_ornit.layer.cornerRadius = 46
        headerView_Ornit.addSubview(deco2_ornit)

        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in Navigation_Ornit.pop_Ornit(from: self) }
        headerView_Ornit.addSubview(backView_ornit)
        headerView_Ornit.addSubview(avatarView_Ornit)
        headerView_Ornit.addSubview(nameLabel_Ornit)
        headerView_Ornit.addSubview(bioLabel_Ornit)

        statsRow_Ornit.axis = .horizontal
        statsRow_Ornit.alignment = .center
        statsRow_Ornit.spacing = 16
        statsRow_Ornit.distribution = .equalSpacing

        let statsBg_ornit = UIView()
        statsBg_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.14)
        statsBg_ornit.layer.cornerRadius = 16
        headerView_Ornit.addSubview(statsBg_ornit)
        headerView_Ornit.addSubview(statsRow_Ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(296)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(52)
            make_ornit.top.equalToSuperview().offset(-30)
            make_ornit.width.height.equalTo(144)
        }
        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-20)
            make_ornit.bottom.equalToSuperview().offset(28)
            make_ornit.width.height.equalTo(92)
        }

        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(38)
        }
        avatarView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(88)
        }
        nameLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(avatarView_Ornit.snp.bottom).offset(12)
        }
        bioLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(nameLabel_Ornit.snp.bottom).offset(5)
            make_ornit.leading.equalToSuperview().offset(36)
            make_ornit.trailing.equalToSuperview().offset(-36)
        }
        statsBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(bioLabel_Ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.trailing.equalToSuperview().offset(-24)
            make_ornit.height.equalTo(56)
            make_ornit.bottom.equalToSuperview().offset(-16)
        }
        statsRow_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalTo(statsBg_ornit)
            make_ornit.leading.equalTo(statsBg_ornit).offset(20)
            make_ornit.trailing.equalTo(statsBg_ornit).offset(-20)
        }
    }

    private func setupActionButtons_Ornit() {
        let followWrapper_ornit = UIView()
        followWrapper_ornit.layer.cornerRadius = 20
        followWrapper_ornit.layer.shadowColor = ColorConfig_Ornit.meGradientEnd_Ornit.withValues(alpha: 0.35).cgColor
        followWrapper_ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        followWrapper_ornit.layer.shadowOpacity = 1
        followWrapper_ornit.layer.shadowRadius = 10
        contentView_Ornit.addSubview(followWrapper_ornit)
        followWrapper_ornit.addSubview(followButton_Ornit)
        followButton_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }
        followButton_Ornit.addTarget(self, action: #selector(followTapped_Ornit), for: .touchUpInside)
        messageButton_Ornit.addTarget(self, action: #selector(messageTapped_Ornit), for: .touchUpInside)

        if isFromChat_Ornit {
            followWrapper_ornit.snp.makeConstraints { make_ornit in
                make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(20)
                make_ornit.centerX.equalToSuperview()
                make_ornit.width.equalTo(160)
                make_ornit.height.equalTo(42)
            }
        } else {
            let btnW_ornit = (APPSCREEN_Ornit.WIDTH_Ornit - 52) / 2
            followWrapper_ornit.snp.makeConstraints { make_ornit in
                make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(20)
                make_ornit.leading.equalToSuperview().offset(20)
                make_ornit.width.equalTo(btnW_ornit)
                make_ornit.height.equalTo(42)
            }

            let msgWrapper_ornit = UIView()
            msgWrapper_ornit.layer.cornerRadius = 20
            msgWrapper_ornit.layer.shadowColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.2).cgColor
            msgWrapper_ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
            msgWrapper_ornit.layer.shadowOpacity = 1
            msgWrapper_ornit.layer.shadowRadius = 10
            contentView_Ornit.addSubview(msgWrapper_ornit)
            msgWrapper_ornit.addSubview(messageButton_Ornit)
            messageButton_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }
            msgWrapper_ornit.snp.makeConstraints { make_ornit in
                make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(20)
                make_ornit.trailing.equalToSuperview().offset(-20)
                make_ornit.width.equalTo(btnW_ornit)
                make_ornit.height.equalTo(42)
            }
        }
    }

    private func setupPostsList_Ornit() {
        contentView_Ornit.addSubview(postsTitleLabel_Ornit)
        contentView_Ornit.addSubview(postsStack_Ornit)
        setupEmptyView_Ornit()
        contentView_Ornit.addSubview(emptyView_Ornit)

        postsTitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(84)
            make_ornit.leading.equalToSuperview().offset(20)
        }
        postsStack_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(postsTitleLabel_Ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-20)
        }
        emptyView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(postsTitleLabel_Ornit.snp.bottom).offset(30)
            make_ornit.centerX.equalToSuperview()
            make_ornit.width.equalTo(200)
        }
    }

    private func setupEmptyView_Ornit() {
        emptyView_Ornit.isHidden = true
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        let icon_ornit = UIImageView(
            image: UIImage(systemName: "tray", withConfiguration: iconConfig_ornit)
        )
        icon_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.3)
        icon_ornit.contentMode = .scaleAspectFit
        emptyView_Ornit.addSubview(icon_ornit)

        let label_ornit = UILabel()
        label_ornit.text = "No sightings yet"
        label_ornit.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .center
        emptyView_Ornit.addSubview(label_ornit)

        icon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.centerX.equalToSuperview()
            make_ornit.width.height.equalTo(52)
        }
        label_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(icon_ornit.snp.bottom).offset(10)
            make_ornit.centerX.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
    }

    private func setupReportButton_Ornit() {
        guard let user_ornit = userModel_Ornit else { return }
        guard !UserViewModel_Ornit.shared_Ornit.isCurrentUser_Ornit(userId_ornit: user_ornit.userId_Ornit ?? -1) else { return }

        let reportBtn_ornit = ReportDeleteHelper_Ornit.createUserReportButton_Ornit(
            size_Ornit: 36,
            backgroundColor_Ornit: UIColor.white.withValues(alpha: 0.2),
            tintColor_Ornit: .white
        )
        headerView_Ornit.addSubview(reportBtn_ornit)
        reportBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(36)
        }
        reportBtn_ornit.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_ornit = self.userModel_Ornit else { return }
            ReportDeleteHelper_Ornit.block_Ornit(user_Ornit: user_ornit, from: self) { [weak self] in
                guard let self = self else { return }
                Navigation_Ornit.popToSafeStateAfterBlock_Ornit(from: self)
            }
        }, for: .touchUpInside)
    }

    // MARK: - 辅助方法

    private func makeStatView_Ornit(title_ornit: String, count_ornit: Int) -> UIView {
        let container_ornit = UIView()
        let countLabel_ornit = UILabel()
        countLabel_ornit.text = "\(count_ornit)"
        countLabel_ornit.font = UIFont.systemFont(ofSize: 18, weight: .black)
        countLabel_ornit.textColor = .white
        countLabel_ornit.textAlignment = .center
        container_ornit.addSubview(countLabel_ornit)

        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = title_ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.78)
        titleLabel_ornit.textAlignment = .center
        container_ornit.addSubview(titleLabel_ornit)

        countLabel_ornit.snp.makeConstraints { make_ornit in make_ornit.top.centerX.equalToSuperview() }
        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(countLabel_ornit.snp.bottom).offset(2)
            make_ornit.centerX.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
        return container_ornit
    }

    /// 创建帖子卡片（含 MediaDisplayView 媒体预览 + 标题 + 内容 + 点赞数）
    /// - Parameter post_ornit: 帖子数据模型
    /// - Returns: 完整的帖子卡片 UIView
    private func makePostCell_Ornit(post_ornit: TitleModel_Ornit) -> UIView {
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 18
        card_ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.12).cgColor
        card_ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_ornit.layer.shadowOpacity = 1
        card_ornit.layer.shadowRadius = 8

        // 媒体预览区（使用 MediaDisplayView_Ornit，自动处理图片/视频/占位）
        let mediaView_ornit = MediaDisplayView_Ornit()
        mediaView_ornit.layer.cornerRadius = 18
        mediaView_ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mediaView_ornit.clipsToBounds = true
        mediaView_ornit.configure_Ornit(mediaPath_Ornit: post_ornit.titleMeidas_Ornit.first)
        card_ornit.addSubview(mediaView_ornit)

        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = post_ornit.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        card_ornit.addSubview(titleLabel_ornit)

        let contentLabel_ornit = UILabel()
        contentLabel_ornit.text = post_ornit.titleContent_Ornit
        contentLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        contentLabel_ornit.numberOfLines = 2
        card_ornit.addSubview(contentLabel_ornit)

        // 底部信息行：点赞数 + 评论数
        let bottomRow_ornit = UIView()
        card_ornit.addSubview(bottomRow_ornit)

        let likeLabel_ornit = UILabel()
        likeLabel_ornit.text = "♥ \(post_ornit.likes_Ornit)"
        likeLabel_ornit.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likeLabel_ornit.textColor = UIColor(hexstring_Ornit: "#EC4899")
        bottomRow_ornit.addSubview(likeLabel_ornit)

        let commentConfig_ornit = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        let commentIcon_ornit = UIImageView(
            image: UIImage(systemName: "bubble.left.fill", withConfiguration: commentConfig_ornit)
        )
        commentIcon_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.5)
        bottomRow_ornit.addSubview(commentIcon_ornit)

        let commentCount_ornit = UILabel()
        commentCount_ornit.text = "\(post_ornit.reviews_Ornit.count)"
        commentCount_ornit.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        commentCount_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        bottomRow_ornit.addSubview(commentCount_ornit)

        let reportBtn_ornit = ReportDeleteHelper_Ornit.createPostReportButton_Ornit(
            post_Ornit: post_ornit,
            size_Ornit: 14,
            color_Ornit: ColorConfig_Ornit.textSecondary_Ornit,
            from: self,
            completion_Ornit: { [weak self] in self?.refreshPostsList_Ornit() }
        )
        card_ornit.addSubview(reportBtn_ornit)

        // 约束
        mediaView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(160)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(mediaView_ornit.snp.bottom).offset(12)
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalToSuperview().offset(-36)
        }

        contentLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(5)
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalToSuperview().offset(-14)
        }

        bottomRow_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(contentLabel_ornit.snp.bottom).offset(10)
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.bottom.equalToSuperview().offset(-14)
            make_ornit.height.equalTo(20)
        }

        likeLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.centerY.equalToSuperview()
        }

        commentIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(likeLabel_ornit.snp.trailing).offset(14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(13)
        }

        commentCount_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(commentIcon_ornit.snp.trailing).offset(4)
            make_ornit.centerY.equalToSuperview()
        }

        reportBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-10)
            make_ornit.top.equalTo(mediaView_ornit.snp.bottom).offset(10)
            make_ornit.width.height.equalTo(24)
        }

        card_ornit.isUserInteractionEnabled = true
        card_ornit.tag = post_ornit.titleId_Ornit
        card_ornit.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(postCellTapped_Ornit(_:)))
        )

        return card_ornit
    }

    // MARK: - 自定义底部聊天确认卡片

    /// 展示自定义底部滑入聊天确认卡（替代原生 UIAlertController）
    /// - Parameter user_ornit: 目标用户模型
    private func showChatConfirmSheet_Ornit(user_ornit: PrewUserModel_Ornit) {
        // 移除旧卡片（防止重复）
        chatSheetOverlay_Ornit?.removeFromSuperview()

        // 半透明遮罩层
        let overlay_ornit = UIView()
        overlay_ornit.backgroundColor = UIColor.black.withValues(alpha: 0.45)
        overlay_ornit.alpha = 0
        view.addSubview(overlay_ornit)
        chatSheetOverlay_Ornit = overlay_ornit

        overlay_ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }

        // 底部白色卡片（上圆角）
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 28
        card_ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_ornit.addSubview(card_ornit)

        // 拖动把手
        let handle_ornit = UIView()
        handle_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        handle_ornit.layer.cornerRadius = 2.5
        card_ornit.addSubview(handle_ornit)

        // 用户头像（大头像居中）
        let avatarView_ornit = UserAvatarView_Ornit()
        if let uid_ornit = user_ornit.userId_Ornit {
            avatarView_ornit.configure_Ornit(userId_Ornit: uid_ornit)
        }
        avatarView_ornit.layer.borderWidth = 3
        avatarView_ornit.layer.borderColor = ColorConfig_Ornit.meGradientEnd_Ornit.withValues(alpha: 0.4).cgColor
        avatarView_ornit.layer.cornerRadius = 30
        card_ornit.addSubview(avatarView_ornit)

        // 用户名
        let nameLabel_ornit = UILabel()
        nameLabel_ornit.text = user_ornit.userName_Ornit ?? "User"
        nameLabel_ornit.font = UIFont.systemFont(ofSize: 18, weight: .black)
        nameLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        nameLabel_ornit.textAlignment = .center
        card_ornit.addSubview(nameLabel_ornit)

        // 简介
        let bioLabel_ornit = UILabel()
        bioLabel_ornit.text = user_ornit.userIntroduce_Ornit ?? "Birdwatching enthusiast"
        bioLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bioLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        bioLabel_ornit.textAlignment = .center
        bioLabel_ornit.numberOfLines = 2
        card_ornit.addSubview(bioLabel_ornit)

        // 提示文字
        let hintLabel_ornit = UILabel()
        hintLabel_ornit.text = "Start a private conversation"
        hintLabel_ornit.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        hintLabel_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        hintLabel_ornit.textAlignment = .center
        card_ornit.addSubview(hintLabel_ornit)

        // 开始聊天按钮（蓝色渐变）
        let startChatBtn_ornit = UIView()
        startChatBtn_ornit.layer.cornerRadius = 16
        startChatBtn_ornit.layer.shadowColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.4).cgColor
        startChatBtn_ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        startChatBtn_ornit.layer.shadowOpacity = 1
        startChatBtn_ornit.layer.shadowRadius = 10
        card_ornit.addSubview(startChatBtn_ornit)

        let startChatInner_ornit = UIButton(type: .custom)
        let chatGrad_ornit = CAGradientLayer()
        chatGrad_ornit.colors = [
            ColorConfig_Ornit.messageGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.messageGradientEnd_Ornit.cgColor
        ]
        chatGrad_ornit.startPoint = CGPoint(x: 0, y: 0.5)
        chatGrad_ornit.endPoint = CGPoint(x: 1, y: 0.5)
        chatGrad_ornit.cornerRadius = 16
        startChatInner_ornit.layer.insertSublayer(chatGrad_ornit, at: 0)
        startChatInner_ornit.layer.cornerRadius = 16
        startChatInner_ornit.layer.masksToBounds = true

        let btnIconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        startChatInner_ornit.setImage(
            UIImage(systemName: "message.fill", withConfiguration: btnIconConfig_ornit),
            for: .normal
        )
        startChatInner_ornit.setTitle("  Start Chat", for: .normal)
        startChatInner_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        startChatInner_ornit.tintColor = .white
        startChatInner_ornit.setTitleColor(.white, for: .normal)
        startChatBtn_ornit.addSubview(startChatInner_ornit)

        // 取消按钮（轻描）
        let cancelBtn_ornit = UIButton(type: .system)
        cancelBtn_ornit.setTitle("Cancel", for: .normal)
        cancelBtn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cancelBtn_ornit.tintColor = ColorConfig_Ornit.textSecondary_Ornit
        card_ornit.addSubview(cancelBtn_ornit)

        // 约束
        card_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.bottom.equalToSuperview()
        }

        handle_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(12)
            make_ornit.centerX.equalToSuperview()
            make_ornit.width.equalTo(40)
            make_ornit.height.equalTo(5)
        }

        avatarView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(28)
            make_ornit.centerX.equalToSuperview()
            make_ornit.width.height.equalTo(60)
        }

        nameLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(avatarView_ornit.snp.bottom).offset(14)
            make_ornit.leading.trailing.equalToSuperview().inset(24)
        }

        bioLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(nameLabel_ornit.snp.bottom).offset(6)
            make_ornit.leading.trailing.equalToSuperview().inset(24)
        }

        hintLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(bioLabel_ornit.snp.bottom).offset(10)
            make_ornit.centerX.equalToSuperview()
        }

        startChatBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(hintLabel_ornit.snp.bottom).offset(20)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(52)
        }
        startChatInner_ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }

        cancelBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(startChatBtn_ornit.snp.bottom).offset(10)
            make_ornit.centerX.equalToSuperview()
            make_ornit.bottom.equalTo(card_ornit.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make_ornit.height.equalTo(44)
        }

        // 布局完成后更新渐变 frame
        view.layoutIfNeeded()
        chatGrad_ornit.frame = startChatInner_ornit.bounds

        // 滑入动画
        card_ornit.transform = CGAffineTransform(translationX: 0, y: 320)
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            overlay_ornit.alpha = 1
            card_ornit.transform = .identity
        }

        // 按钮事件
        startChatInner_ornit.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.dismissChatSheet_Ornit {
                Navigation_Ornit.toMessageUser_Ornit(with: user_ornit)
            }
        }, for: .touchUpInside)

        cancelBtn_ornit.addAction(UIAction { [weak self] _ in
            self?.dismissChatSheet_Ornit(completion_ornit: nil)
        }, for: .touchUpInside)

        // 点击遮罩关闭
        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(dismissChatSheetTap_Ornit))
        overlay_ornit.addGestureRecognizer(tap_ornit)
    }

    /// 动画收起聊天确认卡片
    /// - Parameter completion_ornit: 收起完成后执行的回调
    private func dismissChatSheet_Ornit(completion_ornit: (() -> Void)?) {
        guard let overlay_ornit = chatSheetOverlay_Ornit else {
            completion_ornit?()
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            overlay_ornit.alpha = 0
            overlay_ornit.subviews.first?.transform = CGAffineTransform(translationX: 0, y: 280)
        }) { [weak self] _ in
            overlay_ornit.removeFromSuperview()
            self?.chatSheetOverlay_Ornit = nil
            completion_ornit?()
        }
    }

    @objc private func dismissChatSheetTap_Ornit() {
        dismissChatSheet_Ornit(completion_ornit: nil)
    }

    // MARK: - 事件处理

    @objc private func followTapped_Ornit() {
        guard let user_ornit = userModel_Ornit else { return }

        // 未登录时 followUser_Ornit 内部会弹登录提示并 return，此处提前拦截避免后续数据误更新
        guard UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit else {
            UserViewModel_Ornit.shared_Ornit.followUser_Ornit(user_ornit: user_ornit)
            return
        }

        let wasFollowing_ornit = isFollowing_Ornit
        UserViewModel_Ornit.shared_Ornit.followUser_Ornit(user_ornit: user_ornit)

        // 已登录才同步目标用户 Fans 数量（本地即时更新，不依赖服务端）
        let delta_ornit = wasFollowing_ornit ? -1 : 1
        userModel_Ornit?.userFans_Ornit = max(0, (user_ornit.userFans_Ornit ?? 0) + delta_ornit)

        // 直接刷新按钮状态和统计行，不只依赖通知回调
        refreshFollowButton_Ornit()
        if let updated_ornit = userModel_Ornit {
            refreshStats_Ornit(user_ornit: updated_ornit)
        }

        // 从聊天页取消关注 → 返回消息列表并删除聊天记录
        if isFromChat_Ornit && wasFollowing_ornit {
            if let uid_ornit = user_ornit.userId_Ornit {
                MessageViewModel_Ornit.shared_Ornit.deleteUserMessages_Ornit(userId_ornit: uid_ornit)
            }
            if let nav_ornit = navigationController {
                let lists_ornit = nav_ornit.viewControllers.filter { $0 is MessageList_Ornit }
                if let listVC_ornit = lists_ornit.last {
                    nav_ornit.popToViewController(listVC_ornit, animated: true)
                    return
                }
            }
            Navigation_Ornit.pop_Ornit(from: self)
        }
    }

    @objc private func messageTapped_Ornit() {
        guard let user_ornit = userModel_Ornit else { return }
        guard isFollowing_Ornit else {
            Utils_Ornit.showInfo_Ornit(message_Ornit: "Follow this user to send a message")
            return
        }
        showChatConfirmSheet_Ornit(user_ornit: user_ornit)
    }

    @objc private func postCellTapped_Ornit(_ gesture: UITapGestureRecognizer) {
        guard let card_ornit = gesture.view,
              let post_ornit = userPosts_Ornit.first(where: { $0.titleId_Ornit == card_ornit.tag }) else { return }
        Navigation_Ornit.toTitleDetail_Ornit(titleModel_ornit: post_ornit)
    }
}
