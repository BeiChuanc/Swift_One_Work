import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面

/// 用户中心页面（预制用户）
/// 核心功能：展示指定用户的个人信息、帖子列表，提供关注/取消关注、进入聊天、举报等操作
/// 设计思路：渐变头部卡片 + 操作按钮区 + 帖子网格；
///           isFromChat_Clara 控制从聊天进入时的特殊布局（隐藏消息按钮、关注按钮居中）
/// 关键属性：
/// - userModel_Clara: 展示的用户模型
/// - isFromChat_Clara: 是否从聊天界面进入（影响按钮布局及取消关注后的行为）
/// 关键方法：
/// - refreshFollowState_Clara: 同步关注状态到 UI
/// - handleFollowTap_Clara: 关注/取消关注逻辑
/// - handleMessageTap_Clara: 消息按钮弹窗逻辑（校验是否已关注）
class UserInfo_Clara: UIViewController {

    // MARK: - 属性

    /// 展示的用户模型
    var userModel_Clara: PrewUserModel_Clara?

    /// 是否从聊天界面进入（隐藏消息按钮、关注按钮居中、取消关注时返回消息列表）
    var isFromChat_Clara: Bool = false

    // MARK: - UI 组件

    /// 外层滚动视图
    private let scrollView_Clara: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Clara = UIView()

    /// 渐变头部容器
    private let headerView_Clara = UIView()
    private var gradientLayer_Clara: CAGradientLayer?
    private weak var reportButton_Clara: UIButton?
    private let profileInfoCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        return v
    }()
    private let actionPanel_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.82)
        v.layer.cornerRadius = 26
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 22
        return v
    }()
    private let postsContainerCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.76)
        v.layer.cornerRadius = 28
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 18
        return v
    }()

    /// 头像视图
    private let avatarView_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 44
        v.clipsToBounds = true
        return v
    }()

    /// 用户名
    private let nameLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 简介
    private let bioLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 头部角标
    private let profileBadgeLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Creator Profile"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        l.textAlignment = .center
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        return l
    }()

    /// 粉丝/关注数量行
    private let statsRow_Clara = UIView()
    private let followLabel_Clara = UILabel()
    private let fansLabel_Clara = UILabel()
    private let postsLabel_Clara = UILabel()

    /// 关注按钮
    private let followButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 20
        return btn
    }()

    /// 消息按钮（从聊天进入时隐藏）
    private let messageButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Message", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(ColorConfig_Clara.primaryGradientStart_Clara, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = ColorConfig_Clara.primaryGradientStart_Clara.cgColor
        return btn
    }()

    /// 帖子集合视图
    private lazy var collectionView_Clara: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(UserInfoPostCell_Clara.self, forCellWithReuseIdentifier: UserInfoPostCell_Clara.reuseId_Clara)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    /// 空状态标签
    private let emptyLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "No posts yet"
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    // MARK: - 数据

    private var userPosts_Clara: [TitleModel_Clara] = []
    private var collectionHeightConstraint_Clara: Constraint?
    /// 聊天确认弹窗遮罩标签（用于避免重复弹出）
    private let chatConfirmOverlayTag_Clara: Int = 95271
    private let postsSectionTitleLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Moments"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Clara.textPrimary_Clara
        return l
    }()
    private let postsSectionSubtitleLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "A closer look at recent shares"
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        return l
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用自定义悬浮按钮，隐藏系统导航栏避免覆盖头图
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshFollowState_Clara()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupScrollView_Clara()
        setupHeader_Clara()
        setupActionButtons_Clara()
        setupPostsGrid_Clara()
        setupFloatingNavigationButtons_Clara()
        loadUserData_Clara()
        setupNotifications_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayer_Clara()
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - 自定义悬浮导航按钮

    /// 添加悬浮返回按钮和更多操作按钮
    private func setupFloatingNavigationButtons_Clara() {
        let backBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        backBtn.tintColor = .white
        backBtn.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        backBtn.layer.cornerRadius = 18
        backBtn.layer.borderWidth = 1
        backBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor
        backBtn.addTarget(self, action: #selector(backTapped_Clara), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        let reportBtn = UIButton(type: .system)
        let reportCfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        reportBtn.setImage(UIImage(systemName: "ellipsis", withConfiguration: reportCfg), for: .normal)
        reportBtn.tintColor = .white
        reportBtn.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        reportBtn.layer.cornerRadius = 18
        reportBtn.layer.borderWidth = 1
        reportBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor
        reportBtn.addTarget(self, action: #selector(reportUserTapped_Clara), for: .touchUpInside)
        view.addSubview(reportBtn)
        reportBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
        reportButton_Clara = reportBtn
    }

    // MARK: - UI 搭建

    private func setupScrollView_Clara() {
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(contentView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        scrollView_Clara.backgroundColor = .clear
        contentView_Clara.backgroundColor = .clear
        scrollView_Clara.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    /// 搭建渐变头部（头像、用户名、简介、数据统计行）
    private func setupHeader_Clara() {
        contentView_Clara.addSubview(headerView_Clara)
        headerView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(356)
        }

        // 装饰圆，增加层次感
        let rightCircle = UIView()
        rightCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        rightCircle.layer.cornerRadius = 70
        headerView_Clara.addSubview(rightCircle)
        rightCircle.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.right.equalToSuperview().inset(-36)
            make.top.equalToSuperview().offset(-28)
        }

        let leftCircle = UIView()
        leftCircle.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        leftCircle.layer.cornerRadius = 48
        headerView_Clara.addSubview(leftCircle)
        leftCircle.snp.makeConstraints { make in
            make.width.height.equalTo(96)
            make.left.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-10)
        }

        let avatarHaloView_Clara = UIView()
        avatarHaloView_Clara.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        avatarHaloView_Clara.layer.cornerRadius = 52
        headerView_Clara.addSubview(avatarHaloView_Clara)
        avatarHaloView_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.height.equalTo(104)
        }

        headerView_Clara.addSubview(avatarView_Clara)
        avatarView_Clara.layer.borderWidth = 4
        avatarView_Clara.layer.borderColor = UIColor.white.withAlphaComponent(0.92).cgColor
        avatarView_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.width.height.equalTo(88)
        }

        headerView_Clara.addSubview(profileInfoCard_Clara)
        profileInfoCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }

        profileInfoCard_Clara.addSubview(profileBadgeLabel_Clara)
        profileBadgeLabel_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
            make.width.equalTo(116)
            make.height.equalTo(24)
        }

        profileInfoCard_Clara.addSubview(nameLabel_Clara)
        nameLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(profileBadgeLabel_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        profileInfoCard_Clara.addSubview(bioLabel_Clara)
        bioLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Clara.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(30)
        }

        // 粉丝/关注数据行
        setupStatsRow_Clara()
    }

    /// 搭建关注数 / 粉丝数 / 帖子数统计行
    private func setupStatsRow_Clara() {
        profileInfoCard_Clara.addSubview(statsRow_Clara)
        statsRow_Clara.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Clara.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(14)
        }

        for label in [followLabel_Clara, fansLabel_Clara, postsLabel_Clara] {
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textColor = UIColor.white.withAlphaComponent(0.90)
            label.textAlignment = .center
            label.backgroundColor = UIColor.white.withAlphaComponent(0.16)
            label.layer.cornerRadius = 14
            label.clipsToBounds = true
            statsRow_Clara.addSubview(label)
        }

        followLabel_Clara.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(92)
            make.height.equalTo(52)
        }
        fansLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(followLabel_Clara.snp.right).offset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(92)
        }
        postsLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(fansLabel_Clara.snp.right).offset(10)
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(92)
            make.height.equalTo(52)
        }
    }

    /// 搭建关注按钮和消息按钮
    private func setupActionButtons_Clara() {
        contentView_Clara.addSubview(actionPanel_Clara)
        actionPanel_Clara.addSubview(followButton_Clara)
        actionPanel_Clara.addSubview(messageButton_Clara)

        followButton_Clara.addTarget(self, action: #selector(followTapped_Clara), for: .touchUpInside)
        messageButton_Clara.addTarget(self, action: #selector(messageTapped_Clara), for: .touchUpInside)

        if isFromChat_Clara {
            // 从聊天进入：关注按钮居中，消息按钮隐藏
            messageButton_Clara.isHidden = true
            actionPanel_Clara.snp.makeConstraints { make in
                make.top.equalTo(headerView_Clara.snp.bottom).offset(-10)
                make.centerX.equalToSuperview()
                make.width.equalTo(198)
                make.height.equalTo(74)
            }
            followButton_Clara.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
            }
        } else {
            // 普通进入：关注 + 消息并排显示
            actionPanel_Clara.snp.makeConstraints { make in
                make.top.equalTo(headerView_Clara.snp.bottom).offset(-10)
                make.left.right.equalToSuperview().inset(18)
                make.height.equalTo(74)
            }
            followButton_Clara.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(14)
                make.width.equalTo(148)
                make.height.equalTo(44)
            }
            messageButton_Clara.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().inset(14)
                make.width.equalTo(148)
                make.height.equalTo(44)
            }
        }

        followButton_Clara.layer.cornerRadius = 22
        messageButton_Clara.layer.cornerRadius = 22
        followButton_Clara.layer.shadowColor = UIColor.black.cgColor
        followButton_Clara.layer.shadowOffset = CGSize(width: 0, height: 6)
        followButton_Clara.layer.shadowOpacity = 0.14
        followButton_Clara.layer.shadowRadius = 12
        messageButton_Clara.layer.shadowColor = UIColor.black.cgColor
        messageButton_Clara.layer.shadowOffset = CGSize(width: 0, height: 6)
        messageButton_Clara.layer.shadowOpacity = 0.10
        messageButton_Clara.layer.shadowRadius = 10
    }

    /// 搭建帖子网格区域
    private func setupPostsGrid_Clara() {
        contentView_Clara.addSubview(postsContainerCard_Clara)
        postsContainerCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(actionPanel_Clara.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(20)
        }

        postsContainerCard_Clara.addSubview(postsSectionTitleLabel_Clara)
        postsSectionTitleLabel_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(16)
        }

        postsContainerCard_Clara.addSubview(postsSectionSubtitleLabel_Clara)
        postsSectionSubtitleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(postsSectionTitleLabel_Clara.snp.bottom).offset(4)
            make.left.equalTo(postsSectionTitleLabel_Clara)
        }

        postsContainerCard_Clara.addSubview(emptyLabel_Clara)
        emptyLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(postsSectionSubtitleLabel_Clara.snp.bottom).offset(34)
            make.centerX.equalToSuperview()
        }

        postsContainerCard_Clara.addSubview(collectionView_Clara)
        collectionView_Clara.snp.makeConstraints { make in
            make.top.equalTo(postsSectionSubtitleLabel_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(10)
            collectionHeightConstraint_Clara = make.height.equalTo(400).constraint
            make.bottom.equalToSuperview().inset(12)
        }
    }

    // MARK: - 渐变

    private func updateGradientLayer_Clara() {
        if let gl = gradientLayer_Clara {
            gl.frame = headerView_Clara.bounds
        } else {
            let gl = UIColor.createSecondaryGradientLayer_Clara(frame_Clara: headerView_Clara.bounds)
            headerView_Clara.layer.insertSublayer(gl, at: 0)
            gradientLayer_Clara = gl
        }
    }

    // MARK: - 数据加载

    /// 加载用户信息与帖子
    private func loadUserData_Clara() {
        guard let user = userModel_Clara, let uid = user.userId_Clara else { return }

        // 配置头像
        avatarView_Clara.configure_Clara(userId_Clara: uid)
        nameLabel_Clara.text = user.userName_Clara ?? "User"
        bioLabel_Clara.text = user.userIntroduce_Clara ?? "No bio yet"
        followLabel_Clara.text = "Following\n\(user.userFollow_Clara ?? 0)"
        fansLabel_Clara.text = "Fans\n\(user.userFans_Clara ?? 0)"
        postsLabel_Clara.text = "Posts\n\(userPosts_Clara.count)"
        followLabel_Clara.numberOfLines = 2
        fansLabel_Clara.numberOfLines = 2
        postsLabel_Clara.numberOfLines = 2

        // 关注状态
        refreshFollowState_Clara()

        // 加载该用户的帖子
        userPosts_Clara = TitleViewModel_Clara.shared_Clara.getUserPosts_Clara(user_clara: user)
        postsLabel_Clara.text = "Posts\n\(userPosts_Clara.count)"
        postsSectionTitleLabel_Clara.text = "Moments · \(userPosts_Clara.count)"
        postsSectionSubtitleLabel_Clara.text = userPosts_Clara.isEmpty
            ? "No shared moments yet"
            : "Tap a card to open a shared moment"
        updatePostsGrid_Clara()
    }

    /// 更新帖子网格布局
    private func updatePostsGrid_Clara() {
        emptyLabel_Clara.isHidden = !userPosts_Clara.isEmpty
        collectionView_Clara.isHidden = userPosts_Clara.isEmpty
        collectionView_Clara.reloadData()
        postsLabel_Clara.text = "Posts\n\(userPosts_Clara.count)"
        postsSectionTitleLabel_Clara.text = "Moments · \(userPosts_Clara.count)"
        postsSectionSubtitleLabel_Clara.text = userPosts_Clara.isEmpty
            ? "No shared moments yet"
            : "Tap a card to open a shared moment"

        let cols: CGFloat = 3
        let side = (UIScreen.main.bounds.width - 20 - 12) / cols
        let rows = ceil(CGFloat(userPosts_Clara.count) / cols)
        let h = max(rows * (side + 6), 220)
        collectionHeightConstraint_Clara?.update(offset: h)
        scrollView_Clara.layoutIfNeeded()
    }

    /// 同步关注按钮状态
    private func refreshFollowState_Clara() {
        guard let user = userModel_Clara else { return }
        let following = UserViewModel_Clara.shared_Clara.isFollowing_Clara(user_clara: user)
        if following {
            followButton_Clara.setTitle("Followed", for: .normal)
            followButton_Clara.setTitleColor(.white, for: .normal)
            followButton_Clara.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
        } else {
            followButton_Clara.setTitle("Follow", for: .normal)
            followButton_Clara.setTitleColor(.white, for: .normal)
            followButton_Clara.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.75)
        }
    }

    // MARK: - 通知

    private func setupNotifications_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Clara),
            name: UserViewModel_Clara.userStateDidChangeNotification_Clara,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Clara),
            name: TitleViewModel_Clara.titleStateDidChangeNotification_Clara,
            object: nil
        )
    }

    @objc private func handleUserStateChange_Clara() {
        if let user = userModel_Clara {
            fansLabel_Clara.text = "Fans\n\(user.userFans_Clara ?? 0)"
        }
        refreshFollowState_Clara()
    }

    @objc private func handleTitleStateChange_Clara() {
        guard let user = userModel_Clara else { return }
        userPosts_Clara = TitleViewModel_Clara.shared_Clara.getUserPosts_Clara(user_clara: user)
        updatePostsGrid_Clara()
    }

    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    /// 关注/取消关注
    @objc private func followTapped_Clara() {
        guard let user = userModel_Clara, let uid = user.userId_Clara else { return }
        let wasFollowing = UserViewModel_Clara.shared_Clara.isFollowing_Clara(user_clara: user)
        UserViewModel_Clara.shared_Clara.followUser_Clara(user_clara: user)

        if wasFollowing && isFromChat_Clara {
            // 从聊天进入时取消关注：删除聊天记录并返回消息列表
            MessageViewModel_Clara.shared_Clara.deleteUserMessages_Clara(userId_clara: uid)
            // 弹回到消息列表（安全导航）
            Navigation_Clara.popToSafeStateAfterBlock_Clara(from: self)
        }
    }

    /// 消息按钮：判断是否已关注，已关注则弹出确认对话框进入聊天
    @objc private func messageTapped_Clara() {
        guard let user = userModel_Clara else { return }
        let isFollowing = UserViewModel_Clara.shared_Clara.isFollowing_Clara(user_clara: user)

        if isFollowing {
            // 已关注：弹出确认进入聊天对话框
            showEnterChatConfirm_Clara(user: user)
        } else {
            // 未关注：提示先关注
            let alert = UIAlertController(
                title: "Follow Required",
                message: "You need to follow \(user.userName_Clara ?? "this user") before starting a chat.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    /// 显示进入聊天确认底部弹窗（展示头像、昵称、简介，确认后跳转）
    private func showEnterChatConfirm_Clara(user: PrewUserModel_Clara) {
        // 防止重复弹出
        guard view.viewWithTag(chatConfirmOverlayTag_Clara) == nil else { return }

        let overlayView = UIView()
        overlayView.tag = chatConfirmOverlayTag_Clara
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let cardView = UIView()
        cardView.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        cardView.layer.cornerRadius = 24
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.clipsToBounds = true
        overlayView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        let indicator = UIView()
        indicator.backgroundColor = ColorConfig_Clara.divider_Clara
        indicator.layer.cornerRadius = 2.5
        cardView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(5)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Start a Conversation"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(indicator.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
        }

        let avatarView = UserAvatarView_Clara()
        avatarView.layer.cornerRadius = 32
        avatarView.clipsToBounds = true
        if let uid = user.userId_Clara {
            avatarView.configure_Clara(userId_Clara: uid)
        }
        cardView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        let nameLabel = UILabel()
        nameLabel.text = user.userName_Clara ?? "User"
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        nameLabel.textAlignment = .center
        cardView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        let bioLabel = UILabel()
        bioLabel.text = (user.userIntroduce_Clara?.isEmpty == false)
            ? user.userIntroduce_Clara
            : "No bio provided"
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 2
        cardView.addSubview(bioLabel)
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(24)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Confirm to enter chat"
        hintLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        hintLabel.textColor = ColorConfig_Clara.textPlaceholder_Clara
        hintLabel.textAlignment = .center
        cardView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        cardView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(14)
        }

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(ColorConfig_Clara.textSecondary_Clara, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        cancelButton.layer.cornerRadius = 14

        let enterButton = UIButton(type: .system)
        enterButton.setTitle("Enter Chat", for: .normal)
        enterButton.setTitleColor(.white, for: .normal)
        enterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        enterButton.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
        enterButton.layer.cornerRadius = 14

        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(enterButton)

        // 点击遮罩关闭
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissChatConfirmSheet_Clara))
        overlayView.addGestureRecognizer(dismissTap)

        // 避免点击卡片本身触发 dismiss
        let cardTap = UITapGestureRecognizer()
        cardView.addGestureRecognizer(cardTap)

        cancelButton.addAction(UIAction { [weak self] _ in
            self?.dismissChatConfirmSheet_Clara()
        }, for: .touchUpInside)

        enterButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.dismissChatConfirmSheet_Clara()
            Navigation_Clara.toMessageUser_Clara(with: user, style_clara: .push_clara)
        }, for: .touchUpInside)

        // 进入动画
        cardView.transform = CGAffineTransform(translationX: 0, y: 24)
        UIView.animate(withDuration: 0.22) {
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.30)
            cardView.transform = .identity
        }
    }

    /// 关闭聊天确认底部弹窗
    @objc private func dismissChatConfirmSheet_Clara() {
        guard let overlayView = view.viewWithTag(chatConfirmOverlayTag_Clara),
              let cardView = overlayView.subviews.first else { return }
        UIView.animate(withDuration: 0.20, animations: {
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            cardView.transform = CGAffineTransform(translationX: 0, y: 24)
        }, completion: { _ in
            overlayView.removeFromSuperview()
        })
    }

    /// 举报用户（弹出操作表，确认后执行拉黑）
    @objc private func reportUserTapped_Clara() {
        guard let user = userModel_Clara else { return }
        ReportDeleteHelper_Clara.block_Clara(user_Clara: user, from: self) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                Navigation_Clara.popToSafeStateAfterBlock_Clara(from: self)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionView 代理

extension UserInfo_Clara: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts_Clara.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserInfoPostCell_Clara.reuseId_Clara,
            for: indexPath
        ) as! UserInfoPostCell_Clara
        let post = userPosts_Clara[indexPath.item]
        cell.configure_Clara(post_Clara: post, viewController_Clara: self) { [weak self] in
            guard let self = self, let user = self.userModel_Clara else { return }
            self.userPosts_Clara = TitleViewModel_Clara.shared_Clara.getUserPosts_Clara(user_clara: user)
            self.updatePostsGrid_Clara()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (collectionView.bounds.width - 12) / 3
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = userPosts_Clara[indexPath.item]
        Navigation_Clara.toTitleDetail_Clara(titleModel_clara: post)
    }
}

// MARK: - 用户中心帖子 Cell

/// 用户中心帖子缩略图单元格
/// 功能：展示帖子媒体缩略图，右上角提供举报或删除按钮
class UserInfoPostCell_Clara: UICollectionViewCell {

    static let reuseId_Clara = "UserInfoPostCell_Clara"

    private let cardView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 12
        return v
    }()
    private let mediaView_Clara = MediaDisplayView_Clara()
    private let mediaOverlayView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.10)
        v.layer.cornerRadius = 14
        v.isUserInteractionEnabled = false
        return v
    }()
    private let mediaTypeLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        l.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        l.textAlignment = .center
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        return l
    }()
    private weak var actionButton_Clara: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView_Clara)
        cardView_Clara.addSubview(mediaView_Clara)
        cardView_Clara.addSubview(mediaOverlayView_Clara)
        cardView_Clara.addSubview(mediaTypeLabel_Clara)
        cardView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        mediaView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mediaOverlayView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mediaTypeLabel_Clara.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(52)
        }
        mediaView_Clara.layer.cornerRadius = 14
        mediaView_Clara.clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置单元格
    func configure_Clara(
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        let mediaPath = post_Clara.titleMeidas_Clara.first
        let isVideo = mediaPath?.hasSuffix(".mp4") == true || mediaPath?.hasSuffix(".mov") == true
        mediaView_Clara.configure_Clara(mediaPath_Clara: mediaPath, isVideo_Clara: isVideo)
        mediaTypeLabel_Clara.text = isVideo ? "  VIDEO  " : "  PHOTO  "

        actionButton_Clara?.removeFromSuperview()
        let btn = ReportDeleteHelper_Clara.createPostReportButton_Clara(
            post_Clara: post_Clara,
            size_Clara: 16,
            color_Clara: .white,
            from: viewController_Clara,
            completion_Clara: completion_Clara
        )
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        btn.layer.cornerRadius = 11
        cardView_Clara.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
            make.width.height.equalTo(26)
        }
        actionButton_Clara = btn
    }
}
