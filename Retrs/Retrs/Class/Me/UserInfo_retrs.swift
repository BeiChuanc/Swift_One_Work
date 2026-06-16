import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面 - 重构版

/// 用户中心控制器
/// 核心作用：展示他人用户信息（头像、昵称、简介、关注/粉丝/发布数），支持关注、发消息、举报
/// 设计思路：渐变头部（与应用主题统一）+ 三格统计卡 + 操作按钮行 + 帖子列表
class UserInfo_Retrs: UIViewController {

    // MARK: - 属性

    var userModel_Retrs: PrewUserModel_Retrs?
    var fromChat_Retrs: Bool = false

    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs
    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 渐变头部
    private let headerView_Retrs      = UIView()
    private let headerGradLayer_Retrs = CAGradientLayer()
    private let backBtn_Retrs         = UIButton(type: .system)
    private let reportBtn_Retrs: UIButton = ReportDeleteHelper_Retrs.createUserReportButton_Retrs(
        size_Retrs: 36, tintColor_Retrs: .white, withShadow_Retrs: false
    )
    private let avatarView_Retrs   = UserAvatarView_Retrs()
    private let nameLabel_Retrs    = UILabel()
    private let introLabel_Retrs   = UILabel()

    /// 三格统计卡
    private let statsWrap_Retrs      = UIStackView()
    private let followCountLabel_Retrs = UILabel()
    private let fansCountLabel_Retrs   = UILabel()
    private let postsCountLabel_Retrs  = UILabel()

    /// 操作按钮行
    private let followBtn_Retrs  = UIButton(type: .system)
    private let followGradLayer_Retrs = CAGradientLayer()
    private let messageBtn_Retrs = UIButton(type: .system)

    /// 帖子列表
    private let postsSectionLabel_Retrs = UILabel()
    private let tableView_Retrs = UITableView()
    private var userPosts_Retrs: [TitleModel_Retrs] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFollowButtonState_Retrs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupStatsRow_Retrs()
        setupActionButtons_Retrs()
        setupPostsSection_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        fillData_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
        followGradLayer_Retrs.frame = followBtn_Retrs.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
    }

    // MARK: - 渐变头部

    private func setupHeaderView_Retrs() {
        // 与应用主题一致：薰衣草紫 → 天空蓝
        headerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 30
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡
        addBubble_Retrs(alpha: 0.12, size: 150, top: -40, trailing: -20)
        addBubble_Retrs(alpha: 0.08, size: 80,  bottom: -10, leading: -20)

        // 返回按钮（半透明白色圆形）
        backBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_Retrs.layer.cornerRadius = 18
        backBtn_Retrs.layer.borderWidth  = 1
        backBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        backBtn_Retrs.setImage(
            UIImage(systemName: "arrow.left",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)),
            for: .normal
        )
        backBtn_Retrs.tintColor = .white
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(backBtn_Retrs)

        // 举报按钮（半透明白色圆形）
        reportBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        reportBtn_Retrs.layer.cornerRadius = 18
        reportBtn_Retrs.layer.borderWidth  = 1
        reportBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        reportBtn_Retrs.addTarget(self, action: #selector(reportTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(reportBtn_Retrs)

        // 大头像（白色描边）
        avatarView_Retrs.layer.borderWidth  = 4
        avatarView_Retrs.layer.borderColor  = UIColor.white.cgColor
        avatarView_Retrs.layer.cornerRadius = 46
        avatarView_Retrs.clipsToBounds = true
        headerView_Retrs.addSubview(avatarView_Retrs)

        // 昵称
        nameLabel_Retrs.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        nameLabel_Retrs.textColor = .white
        nameLabel_Retrs.textAlignment = .center
        headerView_Retrs.addSubview(nameLabel_Retrs)

        // 简介
        introLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        introLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.8)
        introLabel_Retrs.textAlignment = .center
        introLabel_Retrs.numberOfLines = 2
        headerView_Retrs.addSubview(introLabel_Retrs)

        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        reportBtn_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        avatarView_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 18)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }
        nameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        introLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Retrs.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func addBubble_Retrs(alpha: CGFloat, size: CGFloat,
                                  top: CGFloat? = nil, bottom: CGFloat? = nil,
                                  leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        let v_Retrs = UIView()
        v_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Retrs.layer.cornerRadius = size / 2
        headerView_Retrs.addSubview(v_Retrs)
        v_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            if let t = top     { make.top.equalToSuperview().offset(t) }
            if let b = bottom  { make.bottom.equalToSuperview().offset(b) }
            if let l = leading { make.leading.equalToSuperview().offset(l) }
            if let r = trailing { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 三格统计卡

    private func setupStatsRow_Retrs() {
        statsWrap_Retrs.axis = .horizontal
        statsWrap_Retrs.spacing = 10
        statsWrap_Retrs.distribution = .fillEqually
        contentView_Retrs.addSubview(statsWrap_Retrs)

        let items_Retrs: [(UILabel, String, String)] = [
            (followCountLabel_Retrs, "Following", "person.2.fill"),
            (fansCountLabel_Retrs,   "Followers", "person.fill"),
            (postsCountLabel_Retrs,  "Posts",     "photo.fill")
        ]
        items_Retrs.forEach { statsWrap_Retrs.addArrangedSubview(buildStatCard_Retrs($0.0, $0.1, $0.2)) }
    }

    private func buildStatCard_Retrs(_ numLbl_Retrs: UILabel, _ title_Retrs: String,
                                      _ icon_Retrs: String) -> UIView {
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 16
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Retrs.layer.shadowOpacity = 1
        card_Retrs.layer.shadowRadius  = 10

        let iv_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        )
        iv_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.5)
        iv_Retrs.contentMode = .scaleAspectFit
        card_Retrs.addSubview(iv_Retrs)
        iv_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(16)
        }

        numLbl_Retrs.font = UIFont.systemFont(ofSize: 18, weight: .black)
        numLbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        numLbl_Retrs.textAlignment = .center
        card_Retrs.addSubview(numLbl_Retrs)
        numLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iv_Retrs.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        lbl_Retrs.textAlignment = .center
        card_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(numLbl_Retrs.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        return card_Retrs
    }

    // MARK: - 操作按钮行

    private func setupActionButtons_Retrs() {
        // 关注按钮（渐变）
        followGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        followGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        followGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        followGradLayer_Retrs.cornerRadius = 22
        followBtn_Retrs.layer.insertSublayer(followGradLayer_Retrs, at: 0)
        followBtn_Retrs.layer.cornerRadius = 22
        followBtn_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.35).cgColor
        followBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        followBtn_Retrs.layer.shadowOpacity = 1
        followBtn_Retrs.layer.shadowRadius  = 10
        followBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        followBtn_Retrs.addTarget(self, action: #selector(followTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(followBtn_Retrs)

        if !fromChat_Retrs {
            // 消息按钮（白色描边）
            messageBtn_Retrs.setTitle("Message", for: .normal)
            messageBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            messageBtn_Retrs.setTitleColor(ColorConfig_Retrs.primaryGradientStart_Retrs, for: .normal)
            messageBtn_Retrs.backgroundColor = .white
            messageBtn_Retrs.layer.cornerRadius = 22
            messageBtn_Retrs.layer.borderWidth  = 1.5
            messageBtn_Retrs.layer.borderColor  = ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor
            messageBtn_Retrs.layer.shadowColor  = ColorConfig_Retrs.primaryGradientStart_Retrs
                .withAlphaComponent(0.12).cgColor
            messageBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
            messageBtn_Retrs.layer.shadowOpacity = 1
            messageBtn_Retrs.layer.shadowRadius  = 8
            messageBtn_Retrs.addTarget(self, action: #selector(messageTapped_Retrs), for: .touchUpInside)
            contentView_Retrs.addSubview(messageBtn_Retrs)
        }
    }

    // MARK: - 帖子列表区

    private func setupPostsSection_Retrs() {
        // 区块标题
        let dot_Retrs = UIView()
        dot_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        dot_Retrs.layer.cornerRadius = 3
        contentView_Retrs.addSubview(dot_Retrs)
        dot_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(6)
        }

        postsSectionLabel_Retrs.text = "Posts"
        postsSectionLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        postsSectionLabel_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        contentView_Retrs.addSubview(postsSectionLabel_Retrs)

        tableView_Retrs.backgroundColor = .clear
        tableView_Retrs.separatorStyle  = .none
        tableView_Retrs.isScrollEnabled = false
        tableView_Retrs.register(MePostCell_Retrs.self, forCellReuseIdentifier: "UserInfoPostCell_Retrs")
        tableView_Retrs.dataSource = self
        tableView_Retrs.delegate   = self
        contentView_Retrs.addSubview(tableView_Retrs)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width

        scrollView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        // 统计卡片（从 header 向上轻微重叠）
        statsWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(-10)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        let actionTop_Retrs = statsWrap_Retrs.snp.bottom
        if !fromChat_Retrs {
            followBtn_Retrs.snp.makeConstraints { make in
                make.top.equalTo(actionTop_Retrs).offset(18)
                make.leading.equalToSuperview().offset(18)
                make.width.equalTo((screenW_Retrs - 48) / 2)
                make.height.equalTo(48)
            }
            messageBtn_Retrs.snp.makeConstraints { make in
                make.top.equalTo(followBtn_Retrs)
                make.trailing.equalToSuperview().offset(-18)
                make.width.equalTo(followBtn_Retrs)
                make.height.equalTo(48)
            }
        } else {
            followBtn_Retrs.snp.makeConstraints { make in
                make.top.equalTo(actionTop_Retrs).offset(18)
                make.centerX.equalToSuperview()
                make.width.equalTo(180)
                make.height.equalTo(48)
            }
        }

        // 帖子区标题（利用 postsSectionLabel 的 superview dot）
        postsSectionLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(followBtn_Retrs.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(28)
        }
        // dot 约束（相对 postsSectionLabel）
        if let dot_Retrs = contentView_Retrs.subviews.first(where: { $0.layer.cornerRadius == 3 && $0.bounds.width == 0 }) {
            dot_Retrs.snp.makeConstraints { make in
                make.centerY.equalTo(postsSectionLabel_Retrs)
                make.leading.equalToSuperview().offset(20)
            }
        }
        tableView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(postsSectionLabel_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - 数据

    private func fillData_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        avatarView_Retrs.configure_Retrs(userId_Retrs: user_Retrs.userId_Retrs ?? 0)
        nameLabel_Retrs.text  = user_Retrs.userName_Retrs ?? "User"
        introLabel_Retrs.text = user_Retrs.userIntroduce_Retrs ?? "CCD Photography Enthusiast"
        followCountLabel_Retrs.text = "\(user_Retrs.userFollow_Retrs ?? 0)"
        fansCountLabel_Retrs.text   = "\(user_Retrs.userFans_Retrs ?? 0)"
        userPosts_Retrs = titleVM_Retrs.getUserPosts_Retrs(user_retrs: user_Retrs)
        postsCountLabel_Retrs.text  = "\(userPosts_Retrs.count)"
        tableView_Retrs.reloadData()
        updateTableHeight_Retrs()
        updateFollowButtonState_Retrs()
    }

    private func updateTableHeight_Retrs() {
        let h_Retrs = max(CGFloat(userPosts_Retrs.count) * 100, 100)
        tableView_Retrs.snp.updateConstraints { make in make.height.equalTo(h_Retrs) }
    }

    private func updateFollowButtonState_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        let isFollowing_Retrs = userVM_Retrs.isFollowing_Retrs(user_retrs: user_Retrs)
        if isFollowing_Retrs {
            followBtn_Retrs.setTitle("Following ✓", for: .normal)
            followBtn_Retrs.setTitleColor(ColorConfig_Retrs.textSecondary_Retrs, for: .normal)
            followGradLayer_Retrs.colors = [
                ColorConfig_Retrs.divider_Retrs.cgColor,
                ColorConfig_Retrs.divider_Retrs.cgColor
            ]
        } else {
            followBtn_Retrs.setTitle("Follow", for: .normal)
            followBtn_Retrs.setTitleColor(.white, for: .normal)
            followGradLayer_Retrs.colors = [
                ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
                ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
            ]
        }
    }

    // MARK: - 通知

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: UserViewModel_Retrs.userStateDidChangeNotification_Retrs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: TitleViewModel_Retrs.titleStateDidChangeNotification_Retrs, object: nil)
    }

    @objc private func onStateChange_Retrs() { fillData_Retrs() }

    // MARK: - 事件

    @objc private func backTapped_Retrs()   { Navigation_Retrs.pop_Retrs() }

    @objc private func reportTapped_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        ReportDeleteHelper_Retrs.block_Retrs(user_Retrs: user_Retrs, from: self) { [weak self] in
            Navigation_Retrs.popToSafeStateAfterBlock_Retrs(from: self ?? UIViewController())
        }
    }

    @objc private func followTapped_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        if !userVM_Retrs.isLoggedIn_Retrs {
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs); return
        }
        followBtn_Retrs.animatePulse_Retrs()
        let wasFollowing_Retrs = userVM_Retrs.isFollowing_Retrs(user_retrs: user_Retrs)
        userVM_Retrs.followUser_Retrs(user_retrs: user_Retrs)
        if fromChat_Retrs && wasFollowing_Retrs {
            if let uid_Retrs = user_Retrs.userId_Retrs {
                MessageViewModel_Retrs.shared_Retrs.deleteUserMessages_Retrs(userId_retrs: uid_Retrs)
            }
            Navigation_Retrs.toMessageList_Retrs(style_retrs: .push_retrs)
        }
    }

    @objc private func messageTapped_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        if !userVM_Retrs.isLoggedIn_Retrs {
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs); return
        }
        guard userVM_Retrs.isFollowing_Retrs(user_retrs: user_Retrs) else {
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please follow this user before messaging")
            return
        }
        showEnterChatConfirm_Retrs(user_Retrs: user_Retrs)
    }

    private func showEnterChatConfirm_Retrs(user_Retrs: PrewUserModel_Retrs) {
        // 遮罩层
        let overlay_Retrs = UIView()
        overlay_Retrs.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay_Retrs.alpha = 0
        guard let window_Retrs = view.window else { return }
        window_Retrs.addSubview(overlay_Retrs)
        overlay_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 底部弹窗容器
        let sheet_Retrs = UIView()
        sheet_Retrs.backgroundColor = .white
        sheet_Retrs.layer.cornerRadius = 28
        sheet_Retrs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet_Retrs.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        sheet_Retrs.layer.shadowOffset = CGSize(width: 0, height: -4)
        sheet_Retrs.layer.shadowOpacity = 1
        sheet_Retrs.layer.shadowRadius  = 20
        window_Retrs.addSubview(sheet_Retrs)
        sheet_Retrs.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 拖拽条
        let handle_Retrs = UIView()
        handle_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#E2E8F0")
        handle_Retrs.layer.cornerRadius = 2.5
        sheet_Retrs.addSubview(handle_Retrs)
        handle_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        // 头像渐变圆环 + 头像
        let ring_Retrs = UIView()
        ring_Retrs.backgroundColor = .clear
        sheet_Retrs.addSubview(ring_Retrs)
        ring_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        let ringGrad_Retrs = CAGradientLayer()
        ringGrad_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        ringGrad_Retrs.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        ring_Retrs.layer.addSublayer(ringGrad_Retrs)

        let avatarV_Retrs = UserAvatarView_Retrs()
        avatarV_Retrs.configure_Retrs(userId_Retrs: user_Retrs.userId_Retrs ?? 0)
        avatarV_Retrs.layer.cornerRadius = 36
        avatarV_Retrs.clipsToBounds = true
        sheet_Retrs.addSubview(avatarV_Retrs)
        avatarV_Retrs.snp.makeConstraints { make in
            make.center.equalTo(ring_Retrs)
            make.width.height.equalTo(70)
        }

        // 布局后更新圆环渐变 + mask
        DispatchQueue.main.async {
            ringGrad_Retrs.frame = ring_Retrs.bounds
            let outer_Retrs = UIBezierPath(ovalIn: ring_Retrs.bounds)
            let inner_Retrs = UIBezierPath(ovalIn: ring_Retrs.bounds.insetBy(dx: 3, dy: 3))
            outer_Retrs.append(inner_Retrs)
            outer_Retrs.usesEvenOddFillRule = true
            let mask_Retrs = CAShapeLayer()
            mask_Retrs.path     = outer_Retrs.cgPath
            mask_Retrs.fillRule = .evenOdd
            ringGrad_Retrs.mask = mask_Retrs
        }

        // 昵称
        let nameLbl_Retrs = UILabel()
        nameLbl_Retrs.text = user_Retrs.userName_Retrs ?? "User"
        nameLbl_Retrs.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLbl_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        nameLbl_Retrs.textAlignment = .center
        sheet_Retrs.addSubview(nameLbl_Retrs)
        nameLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(ring_Retrs.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        // 简介
        let introLbl_Retrs = UILabel()
        introLbl_Retrs.text = user_Retrs.userIntroduce_Retrs ?? "CCD Photography Enthusiast"
        introLbl_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        introLbl_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        introLbl_Retrs.textAlignment = .center
        introLbl_Retrs.numberOfLines = 2
        sheet_Retrs.addSubview(introLbl_Retrs)
        introLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_Retrs.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
        }

        // 渐变"Enter Chat"按钮
        let enterBtn_Retrs = UIButton(type: .system)
        let enterGrad_Retrs = CAGradientLayer()
        enterGrad_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        enterGrad_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        enterGrad_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        enterGrad_Retrs.cornerRadius = 26
        enterBtn_Retrs.layer.insertSublayer(enterGrad_Retrs, at: 0)
        enterBtn_Retrs.layer.cornerRadius = 26
        enterBtn_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.35).cgColor
        enterBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 5)
        enterBtn_Retrs.layer.shadowOpacity = 1
        enterBtn_Retrs.layer.shadowRadius  = 10
        enterBtn_Retrs.setTitle("Enter Chat", for: .normal)
        enterBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        enterBtn_Retrs.setTitleColor(.white, for: .normal)
        sheet_Retrs.addSubview(enterBtn_Retrs)
        enterBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(introLbl_Retrs.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        DispatchQueue.main.async { enterGrad_Retrs.frame = enterBtn_Retrs.bounds }

        // 取消按钮
        let cancelBtn_Retrs = UIButton(type: .system)
        cancelBtn_Retrs.setTitle("Cancel", for: .normal)
        cancelBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cancelBtn_Retrs.setTitleColor(ColorConfig_Retrs.textSecondary_Retrs, for: .normal)
        sheet_Retrs.addSubview(cancelBtn_Retrs)
        cancelBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(enterBtn_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-24)
        }

        // 弹窗入场动画
        sheet_Retrs.transform = CGAffineTransform(translationX: 0, y: 400)
        UIView.animate(withDuration: 0.38, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            overlay_Retrs.alpha = 1
            sheet_Retrs.transform = .identity
        }

        // 关闭动画
        let dismiss_Retrs: () -> Void = {
            UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseIn) {
                overlay_Retrs.alpha = 0
                sheet_Retrs.transform = CGAffineTransform(translationX: 0, y: 400)
            } completion: { _ in
                overlay_Retrs.removeFromSuperview()
                sheet_Retrs.removeFromSuperview()
            }
        }

        enterBtn_Retrs.addAction(UIAction { [weak self] _ in
            dismiss_Retrs()
            guard let self else { return }
            Navigation_Retrs.toMessageUser_Retrs(with: user_Retrs)
        }, for: .touchUpInside)

        cancelBtn_Retrs.addAction(UIAction { _ in dismiss_Retrs() }, for: .touchUpInside)

        let overlayTap_Retrs = UITapGestureRecognizer()
        _ = overlayTap_Retrs
        overlay_Retrs.addGestureRecognizer({
            let g_Retrs = BlockGesture_UserInfo_Retrs { dismiss_Retrs() }
            return g_Retrs
        }())
        overlay_Retrs.isUserInteractionEnabled = true
    }
}

// MARK: - UITableViewDataSource & Delegate

extension UserInfo_Retrs: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userPosts_Retrs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Retrs = tableView.dequeueReusableCell(
            withIdentifier: "UserInfoPostCell_Retrs", for: indexPath) as! MePostCell_Retrs
        cell_Retrs.configure_Retrs(post_Retrs: userPosts_Retrs[indexPath.row], from: self) { [weak self] in
            self?.fillData_Retrs()
        }
        return cell_Retrs
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Retrs.toTitleDetail_Retrs(titleModel_retrs: userPosts_Retrs[indexPath.row])
    }
}

// MARK: - 手势辅助（遮罩点击关闭）

private class BlockGesture_UserInfo_Retrs: UITapGestureRecognizer {
    private var block_Retrs: () -> Void
    init(_ block_Retrs: @escaping () -> Void) {
        self.block_Retrs = block_Retrs
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire_Retrs))
    }
    @objc private func fire_Retrs() { block_Retrs() }
}
