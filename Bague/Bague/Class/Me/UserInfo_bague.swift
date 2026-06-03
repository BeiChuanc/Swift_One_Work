import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心视图控制器
/// 功能：展示其他用户信息，支持关注/取消关注，消息入口，举报功能，帖子列表展示
/// 设计：三色渐变头部、半透明胶囊按钮、渐变头像环、彩色统计卡片、帖子彩色口音条卡片
class UserInfo_Bague: UIViewController {

    // MARK: - 属性

    var userModel_Bague: PrewUserModel_Bague?
    /// 是否从聊天页进入（为 true 时隐藏消息按钮）
    var fromChat_Bague: Bool = false

    // MARK: - UI 组件（滚动容器）

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Bague = UIView()

    // MARK: - 头部区域

    private let headerView_Bague = UIView()
    private var headerGradient_Bague: CAGradientLayer?

    /// 头部装饰：大圆
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰：闪光图标
    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = UIColor.white.withAlphaComponent(0.16)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 返回按钮（半透明胶囊）
    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    /// 举报按钮（半透明胶囊）
    private let reportBtn_Bague = ReportDeleteHelper_Bague.createUserReportButton_Bague(
        size_Bague: 36,
        backgroundColor_Bague: UIColor.white.withAlphaComponent(0.22),
        tintColor_Bague: .white,
        withShadow_Bague: false
    )

    // MARK: - 头像区域

    /// 头像渐变环
    private let avatarRing_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 52
        return v
    }()

    private var avatarRingGradient_Bague: CAGradientLayer?

    private let avatarContainerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 46
        return v
    }()

    private let avatarView_Bague = UserAvatarView_Bague()

    // MARK: - 用户信息

    private let nameLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.textAlignment = .center
        return label
    }()

    private let bioLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    // MARK: - 统计卡片

    private let statsCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    private let statsRow_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        return sv
    }()

    private let followStatView_Bague = UserInfoStatView_Bague(
        title: "Following",
        accentColor: UIColor(hexstring_Bague: "#5AADEC")
    )
    private let fansStatView_Bague = UserInfoStatView_Bague(
        title: "Followers",
        accentColor: UIColor(hexstring_Bague: "#F07DAD")
    )
    private let postsStatView_Bague = UserInfoStatView_Bague(
        title: "Posts",
        accentColor: UIColor(hexstring_Bague: "#9B72F5")
    )

    // MARK: - 操作按钮行

    private let actionRow_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        // .fill 让按钮高度撑满 StackView 高度（52pt），避免 .center 时按钮被压缩到固有高度
        sv.alignment = .fill
        sv.distribution = .fillEqually
        return sv
    }()

    /// 关注按钮：使用纯色背景，避免 CAGradientLayer 在 StackView 首次布局时 frame 为零的问题
    private let followBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 22
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(hexstring_Bague: "#9B72F5")
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#9B72F5").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.35
        btn.layer.shadowRadius = 10
        return btn
    }()

    /// 消息按钮：天空蓝实心，白色图标和文字，视觉对比清晰
    private let messageBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "message.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Message", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(hexstring_Bague: "#5AADEC")
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#5AADEC").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 10
        return btn
    }()

    // MARK: - 帖子区域

    private let postsSectionRow_Bague: UIView = {
        let v = UIView()
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iv.image = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5")
        iv.contentMode = .scaleAspectFit
        let lbl = UILabel()
        lbl.text = "POSTS"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = UIColor(hexstring_Bague: "#9B72F5")
        v.addSubview(iv)
        v.addSubview(lbl)
        iv.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        lbl.snp.makeConstraints { make in
            make.leading.equalTo(iv.snp.trailing).offset(6)
            make.centerY.top.bottom.trailing.equalToSuperview()
        }
        return v
    }()

    private let postsContainer_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()

    private let emptyPostsView_Bague: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyPostsIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        iv.image = UIImage(systemName: "tray.fill", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyPostsLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "No posts yet"
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        return label
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
        loadData_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        updateFollowButton_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient_Bague()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        scrollView_Bague.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView_Bague.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)
        contentView_Bague.addSubview(headerView_Bague)

        // 头部装饰与按钮
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        headerView_Bague.addSubview(backBtn_Bague)
        headerView_Bague.addSubview(reportBtn_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)
        reportBtn_Bague.addTarget(self, action: #selector(reportTapped_Bague), for: .touchUpInside)

        // 头像渐变环
        contentView_Bague.addSubview(avatarRing_Bague)
        avatarRing_Bague.addSubview(avatarContainerView_Bague)
        avatarContainerView_Bague.addSubview(avatarView_Bague)

        // 用户信息
        contentView_Bague.addSubview(nameLabel_Bague)
        contentView_Bague.addSubview(bioLabel_Bague)

        // 统计卡片
        contentView_Bague.addSubview(statsCard_Bague)
        statsCard_Bague.addSubview(statsRow_Bague)
        statsRow_Bague.addArrangedSubview(followStatView_Bague)
        statsRow_Bague.addArrangedSubview(postsStatView_Bague)
        statsRow_Bague.addArrangedSubview(fansStatView_Bague)

        // 操作按钮行
        contentView_Bague.addSubview(actionRow_Bague)
        if fromChat_Bague {
            actionRow_Bague.addArrangedSubview(followBtn_Bague)
        } else {
            actionRow_Bague.addArrangedSubview(followBtn_Bague)
            actionRow_Bague.addArrangedSubview(messageBtn_Bague)
        }
        followBtn_Bague.addTarget(self, action: #selector(followTapped_Bague), for: .touchUpInside)
        messageBtn_Bague.addTarget(self, action: #selector(messageTapped_Bague), for: .touchUpInside)

        // 帖子区域
        contentView_Bague.addSubview(postsSectionRow_Bague)
        contentView_Bague.addSubview(postsContainer_Bague)
        contentView_Bague.addSubview(emptyPostsView_Bague)
        emptyPostsView_Bague.addSubview(emptyPostsIcon_Bague)
        emptyPostsView_Bague.addSubview(emptyPostsLabel_Bague)
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-15)
            make.width.height.equalTo(100)
        }
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }
        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        reportBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }

        // 头像渐变环
        avatarRing_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerView_Bague.snp.bottom).offset(-44)
            make.width.height.equalTo(100)
        }
        avatarContainerView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }
        avatarView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview().inset(4) }

        nameLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bioLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Bague.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        // 统计卡片
        statsCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Bague.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(72)
        }
        statsRow_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        // 操作按钮
        actionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Bague.snp.bottom).offset(16)
            if fromChat_Bague {
                make.centerX.equalToSuperview()
                make.width.equalTo(160)
            } else {
                make.leading.trailing.equalToSuperview().inset(20)
            }
            make.height.equalTo(52)
        }

        // 帖子区域
        postsSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Bague.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        postsContainer_Bague.snp.makeConstraints { make in
            make.top.equalTo(postsSectionRow_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-100)
        }
        emptyPostsView_Bague.snp.makeConstraints { make in
            make.top.equalTo(postsSectionRow_Bague.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-100)
        }
        emptyPostsIcon_Bague.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        emptyPostsLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyPostsIcon_Bague.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 渐变

    private func updateGradient_Bague() {
        // 头部三色渐变
        headerGradient_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = headerView_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        grad_bague.locations = [0.0, 0.55, 1.0]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 28
        grad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(grad_bague, at: 0)
        headerGradient_Bague = grad_bague

        // 头像渐变环
        avatarRingGradient_Bague?.removeFromSuperlayer()
        let ring_bague = CAGradientLayer()
        ring_bague.frame = avatarRing_Bague.bounds
        ring_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor
        ]
        ring_bague.startPoint = CGPoint(x: 0, y: 0)
        ring_bague.endPoint = CGPoint(x: 1, y: 1)
        ring_bague.cornerRadius = 52
        avatarRing_Bague.layer.insertSublayer(ring_bague, at: 0)
        avatarRingGradient_Bague = ring_bague
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        [UserViewModel_Bague.userStateDidChangeNotification_Bague,
         TitleViewModel_Bague.titleStateDidChangeNotification_Bague].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(dataChanged_Bague),
                name: $0,
                object: nil
            )
        }
    }

    @objc private func dataChanged_Bague() {
        loadData_Bague()
        updateFollowButton_Bague()
    }

    // MARK: - 数据加载

    private func loadData_Bague() {
        guard let user_bague = userModel_Bague else { return }

        avatarView_Bague.configure_Bague(userId_Bague: user_bague.userId_Bague ?? 0)
        nameLabel_Bague.text = user_bague.userName_Bague ?? "Unknown"
        bioLabel_Bague.text = user_bague.userIntroduce_Bague ?? "No bio yet"

        let allPosts_bague = TitleViewModel_Bague.shared_Bague.getPosts_Bague()
        let userPosts_bague = allPosts_bague.filter { $0.titleUserId_Bague == user_bague.userId_Bague }
        followStatView_Bague.updateValue_Bague(String(user_bague.userFollow_Bague ?? 0))
        fansStatView_Bague.updateValue_Bague(String(user_bague.userFans_Bague ?? 0))
        postsStatView_Bague.updateValue_Bague(String(userPosts_bague.count))

        refreshPostsList_Bague(posts: userPosts_bague)
        updateFollowButton_Bague()
    }

    /// 根据关注状态切换按钮纯色样式，无需 CAGradientLayer，保证任意时机正确显示
    private func updateFollowButton_Bague() {
        let isFollowing_bague = checkIsFollowing_Bague()
        if isFollowing_bague {
            // 已关注：浅紫描边空心
            followBtn_Bague.setTitle("Followed ✓", for: .normal)
            followBtn_Bague.setTitleColor(UIColor(hexstring_Bague: "#9B72F5"), for: .normal)
            followBtn_Bague.backgroundColor = UIColor(hexstring_Bague: "#F0E8FF")
            followBtn_Bague.layer.borderWidth = 1.5
            followBtn_Bague.layer.borderColor = UIColor(hexstring_Bague: "#C4ABFF").cgColor
            followBtn_Bague.layer.shadowOpacity = 0
        } else {
            // 未关注：紫色实心
            followBtn_Bague.setTitle("Follow", for: .normal)
            followBtn_Bague.setTitleColor(.white, for: .normal)
            followBtn_Bague.backgroundColor = UIColor(hexstring_Bague: "#9B72F5")
            followBtn_Bague.layer.borderWidth = 0
            followBtn_Bague.layer.shadowColor = UIColor(hexstring_Bague: "#9B72F5").cgColor
            followBtn_Bague.layer.shadowOpacity = 0.35
        }
    }

    private func checkIsFollowing_Bague() -> Bool {
        guard let targetId_bague = userModel_Bague?.userId_Bague else { return false }
        let currentUser_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        return currentUser_bague.userFollow_Bague.contains { $0.userId_Bague == targetId_bague }
    }

    private func refreshPostsList_Bague(posts: [TitleModel_Bague]) {
        postsContainer_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if posts.isEmpty {
            emptyPostsView_Bague.isHidden = false
        } else {
            emptyPostsView_Bague.isHidden = true
            posts.prefix(10).enumerated().forEach { idx, post in
                let card_bague = UserInfoPostCard_Bague(post_bague: post, index_bague: idx, viewController_bague: self)
                postsContainer_Bague.addArrangedSubview(card_bague)
                card_bague.alpha = 0
                UIView.animate(withDuration: 0.3, delay: Double(idx) * 0.04) {
                    card_bague.alpha = 1
                }
            }
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }

    @objc private func reportTapped_Bague() {
        guard let user_bague = userModel_Bague else { return }
        ReportDeleteHelper_Bague.block_Bague(user_Bague: user_bague, from: self) {
            Navigation_Bague.popToSafeStateAfterBlock_Bague(from: self)
        }
    }

    @objc private func followTapped_Bague() {
        guard UserViewModel_Bague.shared_Bague.isLoggedIn_Bague else {
            Navigation_Bague.toLogin_Bague()
            return
        }
        guard let user_bague = userModel_Bague else { return }

        followBtn_Bague.animatePulse_Bague()

        let wasFollowing_bague = checkIsFollowing_Bague()
        Task { @MainActor in
            // 必须先更新粉丝数，再调用 followUser_Bague
            // 原因：followUser_Bague 内部同步发通知 → loadData_Bague 立即被触发并读取 userFans_Bague
            // 若更新在后，loadData 读到的仍是旧值，导致界面显示反向或无变化
            let currentFans_bague = user_bague.userFans_Bague ?? 0
            user_bague.userFans_Bague = wasFollowing_bague
                ? max(0, currentFans_bague - 1)   // 已关注 → 取消关注 → 粉丝 -1
                : currentFans_bague + 1             // 未关注 → 关注 → 粉丝 +1
            UserViewModel_Bague.shared_Bague.followUser_Bague(user_bague: user_bague)
        }

        if fromChat_Bague && wasFollowing_bague {
            if let userId_bague = user_bague.userId_Bague {
                Task { @MainActor in
                    MessageViewModel_Bague.shared_Bague.deleteUserMessages_Bague(userId_bague: userId_bague)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                Navigation_Bague.popToRoot_Bague()
            }
        }
    }

    @objc private func messageTapped_Bague() {
        guard UserViewModel_Bague.shared_Bague.isLoggedIn_Bague else {
            Navigation_Bague.toLogin_Bague()
            return
        }
        guard let user_bague = userModel_Bague else { return }

        if !checkIsFollowing_Bague() {
            Utils_Bague.showWarning_Bague(message_Bague: "Please follow this user first before messaging")
            return
        }
        showEnterChatConfirm_Bague(user_bague: user_bague)
    }

    private func showEnterChatConfirm_Bague(user_bague: PrewUserModel_Bague) {
        let sheet_bague = ChatConfirmSheet_Bague(user_bague: user_bague)
        sheet_bague.onConfirm_Bague = { [weak self] in
            guard let self = self else { return }
            Navigation_Bague.toMessageUser_Bague(with: user_bague, style_bague: .push_bague)
        }
        sheet_bague.modalPresentationStyle = .overFullScreen
        sheet_bague.modalTransitionStyle = .crossDissolve
        present(sheet_bague, animated: true)
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - 统计视图

/// 用户数据统计视图，带彩色强调数字
class UserInfoStatView_Bague: UIView {

    private let valueLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let titleLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = ColorConfig_Bague.textSecondary_Bague
        l.textAlignment = .center
        return l
    }()

    private let separator_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        return v
    }()

    init(title: String, accentColor: UIColor = ColorConfig_Bague.textPrimary_Bague) {
        super.init(frame: .zero)
        titleLabel_Bague.text = title
        valueLabel_Bague.textColor = accentColor
        addSubview(valueLabel_Bague)
        addSubview(titleLabel_Bague)
        addSubview(separator_Bague)
        valueLabel_Bague.snp.makeConstraints { make in make.top.centerX.equalToSuperview() }
        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Bague.snp.bottom).offset(3)
            make.centerX.bottom.equalToSuperview()
        }
        separator_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func updateValue_Bague(_ value: String) {
        valueLabel_Bague.text = value
    }
}

// MARK: - 帖子卡片

/// 用户中心帖子卡片（带彩色口音条和调和配色）
class UserInfoPostCard_Bague: UIView {

    private let post_Bague: TitleModel_Bague
    private weak var vc_Bague: UIViewController?

    private static let accentTints_Bague: [UIColor] = [
        UIColor(hexstring_Bague: "#9B72F5"),
        UIColor(hexstring_Bague: "#5AADEC"),
        UIColor(hexstring_Bague: "#F07DAD"),
        UIColor(hexstring_Bague: "#3DC9A6"),
        UIColor(hexstring_Bague: "#F5A623"),
        UIColor(hexstring_Bague: "#F07060"),
    ]

    private static let accentBg_Bague: [UIColor] = [
        UIColor(hexstring_Bague: "#EDD9FF"),
        UIColor(hexstring_Bague: "#D0EDFF"),
        UIColor(hexstring_Bague: "#FFD9EE"),
        UIColor(hexstring_Bague: "#D4F7ED"),
        UIColor(hexstring_Bague: "#FFF0D0"),
        UIColor(hexstring_Bague: "#FFE4D9"),
    ]

    init(post_bague: TitleModel_Bague, index_bague: Int, viewController_bague: UIViewController) {
        self.post_Bague = post_bague
        self.vc_Bague = viewController_bague
        super.init(frame: .zero)
        setupUI_Bague(index_bague: index_bague)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague(index_bague: Int) {
        let colorIdx_bague = index_bague % UserInfoPostCard_Bague.accentTints_Bague.count
        let tint_bague = UserInfoPostCard_Bague.accentTints_Bague[colorIdx_bague]
        let bgColor_bague = UserInfoPostCard_Bague.accentBg_Bague[colorIdx_bague]

        let card_bague = UIView()
        card_bague.backgroundColor = .white
        card_bague.layer.cornerRadius = 20
        card_bague.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        card_bague.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_bague.layer.shadowOpacity = 0.1
        card_bague.layer.shadowRadius = 10
        addSubview(card_bague)
        card_bague.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let mediaIV_bague = UIImageView()
        mediaIV_bague.contentMode = .scaleAspectFill
        mediaIV_bague.clipsToBounds = true
        mediaIV_bague.layer.cornerRadius = 16
        mediaIV_bague.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card_bague.addSubview(mediaIV_bague)

        let mediaName_bague = post_Bague.titleMeidas_Bague.first ?? ""
        if let img_bague = UIImage(named: mediaName_bague) {
            mediaIV_bague.image = img_bague
        } else {
            mediaIV_bague.backgroundColor = bgColor_bague
            mediaIV_bague.image = UIImage(systemName: "bag.fill")
            mediaIV_bague.tintColor = tint_bague.withAlphaComponent(0.55)
            mediaIV_bague.contentMode = .scaleAspectFit
        }

        // 左侧彩色口音条
        let accentBar_bague = UIView()
        accentBar_bague.backgroundColor = tint_bague
        accentBar_bague.layer.cornerRadius = 2
        accentBar_bague.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        card_bague.addSubview(accentBar_bague)

        let titleLbl_bague = UILabel()
        titleLbl_bague.text = post_Bague.title_Bague
        titleLbl_bague.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLbl_bague.textColor = ColorConfig_Bague.textPrimary_Bague
        card_bague.addSubview(titleLbl_bague)

        let contentLbl_bague = UILabel()
        contentLbl_bague.text = post_Bague.titleContent_Bague
        contentLbl_bague.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLbl_bague.textColor = ColorConfig_Bague.textSecondary_Bague
        contentLbl_bague.numberOfLines = 2
        card_bague.addSubview(contentLbl_bague)

        // 点赞徽章
        let likesChip_bague = UIView()
        likesChip_bague.backgroundColor = tint_bague.withAlphaComponent(0.12)
        likesChip_bague.layer.cornerRadius = 10
        card_bague.addSubview(likesChip_bague)

        let likesLbl_bague = UILabel()
        likesLbl_bague.text = "♥ \(post_Bague.likes_Bague)"
        likesLbl_bague.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        likesLbl_bague.textColor = tint_bague
        likesChip_bague.addSubview(likesLbl_bague)

        if let vc_bague = vc_Bague {
            let btn_bague = ReportDeleteHelper_Bague.createPostReportButton_Bague(
                post_Bague: post_Bague,
                size_Bague: 14,
                color_Bague: ColorConfig_Bague.textSecondary_Bague,
                from: vc_bague
            )
            card_bague.addSubview(btn_bague)
            btn_bague.snp.makeConstraints { make in
                make.top.equalTo(mediaIV_bague.snp.bottom).offset(12)
                make.trailing.equalToSuperview().offset(-12)
                make.width.height.equalTo(26)
            }
        }

        mediaIV_bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(170)
        }
        accentBar_bague.snp.makeConstraints { make in
            make.top.equalTo(mediaIV_bague.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        titleLbl_bague.snp.makeConstraints { make in
            make.top.equalTo(mediaIV_bague.snp.bottom).offset(12)
            make.leading.equalTo(accentBar_bague.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-44)
        }
        contentLbl_bague.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_bague.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        likesChip_bague.snp.makeConstraints { make in
            make.top.equalTo(contentLbl_bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(20)
        }
        likesLbl_bague.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }

        let tap_bague = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Bague))
        card_bague.addGestureRecognizer(tap_bague)
        card_bague.isUserInteractionEnabled = true
    }

    @objc private func cardTapped_Bague() {
        animatePressDown_Bague {
            self.animatePressUp_Bague {
                Navigation_Bague.toTitleDetail_Bague(titleModel_bague: self.post_Bague)
            }
        }
    }
}

// MARK: - 进入聊天确认底部弹窗

/// 确认进入聊天的底部弹窗视图控制器
/// 设计：半透明遮罩 + 白色圆角卡片，渐变确认按钮
class ChatConfirmSheet_Bague: UIViewController {

    var onConfirm_Bague: (() -> Void)?

    private let user_Bague: PrewUserModel_Bague

    private let overlayView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let sheetView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let grabber_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        v.layer.cornerRadius = 2
        return v
    }()

    private let avatarView_Bague = UserAvatarView_Bague()

    private let nameLbl_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textColor = ColorConfig_Bague.textPrimary_Bague
        l.textAlignment = .center
        return l
    }()

    private let bioLbl_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = ColorConfig_Bague.textSecondary_Bague
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let infoLbl_Bague: UILabel = {
        let l = UILabel()
        l.text = "You are about to start a conversation with this user."
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = ColorConfig_Bague.textSecondary_Bague
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let confirmBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "message.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Start Chat", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 24
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#F07DAD").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 10
        return btn
    }()

    private var confirmBtnGradient_Bague: CAGradientLayer?

    private let cancelBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        btn.tintColor = ColorConfig_Bague.textSecondary_Bague
        return btn
    }()

    init(user_bague: PrewUserModel_Bague) {
        self.user_Bague = user_bague
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmBtnGradient_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = confirmBtn_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 0)
        grad_bague.cornerRadius = 24
        confirmBtn_Bague.layer.insertSublayer(grad_bague, at: 0)
        confirmBtnGradient_Bague = grad_bague
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView_Bague.animateSlideInFromBottom_Bague(offset_Bague: 60)
    }

    private func setupUI_Bague() {
        view.backgroundColor = .clear
        view.addSubview(overlayView_Bague)
        view.addSubview(sheetView_Bague)
        sheetView_Bague.addSubview(grabber_Bague)
        sheetView_Bague.addSubview(avatarView_Bague)
        sheetView_Bague.addSubview(nameLbl_Bague)
        sheetView_Bague.addSubview(bioLbl_Bague)
        sheetView_Bague.addSubview(infoLbl_Bague)
        sheetView_Bague.addSubview(confirmBtn_Bague)
        sheetView_Bague.addSubview(cancelBtn_Bague)

        avatarView_Bague.configure_Bague(userId_Bague: user_Bague.userId_Bague ?? 0)
        nameLbl_Bague.text = user_Bague.userName_Bague
        bioLbl_Bague.text = user_Bague.userIntroduce_Bague

        confirmBtn_Bague.addTarget(self, action: #selector(confirmTapped_Bague), for: .touchUpInside)
        cancelBtn_Bague.addTarget(self, action: #selector(cancelTapped_Bague), for: .touchUpInside)
        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(cancelTapped_Bague))
        overlayView_Bague.addGestureRecognizer(bgTap_bague)

        overlayView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        sheetView_Bague.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        grabber_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        avatarView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        nameLbl_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Bague.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        bioLbl_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_Bague.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        infoLbl_Bague.snp.makeConstraints { make in
            make.top.equalTo(bioLbl_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        confirmBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(infoLbl_Bague.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        cancelBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(confirmBtn_Bague.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    @objc private func confirmTapped_Bague() {
        dismiss(animated: true) { [weak self] in self?.onConfirm_Bague?() }
    }

    @objc private func cancelTapped_Bague() {
        dismiss(animated: true)
    }
}
