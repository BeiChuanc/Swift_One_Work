import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页（Premium 重构版）

/// 用户中心视图控制器
/// 核心作用：展示其他用户主页信息，支持关注/取关、发起聊天、举报
/// 设计思路：渐变 Hero（mask 仅裁渐变层）+ 装饰几何元素 + Pill 关注/消息按钮 + 帖子列表空状态
class UserInfo_Sylva: UIViewController {

    // MARK: - 公开属性

    var userModel_Sylva:        PrewUserModel_Sylva?
    var fromMessage_Sylva:      Bool = false
    var showMessageButton_Sylva: Bool = true

    // MARK: - 私有属性

    private let scrollView_Sylva  = UIScrollView()
    private let contentView_Sylva = UIView()

    private let headerView_Sylva       = UIView()
    private let headerGradient_Sylva   = CAGradientLayer()
    private let headerGradMask_Sylva   = CAShapeLayer()

    private let avatarView_Sylva       = UserAvatarView_Sylva()
    private let nameLabel_Sylva        = UILabel()
    private let introduceLabel_Sylva   = UILabel()
    private let statsRow_Sylva         = UIView()
    private let followButton_Sylva     = UIButton(type: .system)
    private let messageButton_Sylva    = UIButton(type: .system)

    private var postTableView_Sylva: UITableView!
    private let emptyPostView_Sylva    = UIView()
    private var userPosts_Sylva: [TitleModel_Sylva] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupScrollView_Sylva()
        setupHeader_Sylva()
        setupPostSection_Sylva()
        setupNavButtons_Sylva()
        observeNotifications_Sylva()
        refreshAll_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds_sylva = headerView_Sylva.bounds
        headerGradient_Sylva.frame = bounds_sylva
        let path_sylva = UIBezierPath(
            roundedRect: bounds_sylva,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 30, height: 30)
        )
        headerGradMask_Sylva.path = path_sylva.cgPath
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupScrollView_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        scrollView_Sylva.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)
        scrollView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }

    /// 搭建渐变 Hero 头部（渐变 mask 仅裁渐变层，子视图不被裁切）
    private func setupHeader_Sylva() {
        headerGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#40916C").cgColor
        ]
        headerGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Sylva.endPoint   = CGPoint(x: 1, y: 1)
        headerGradient_Sylva.mask       = headerGradMask_Sylva
        headerView_Sylva.layer.insertSublayer(headerGradient_Sylva, at: 0)
        contentView_Sylva.addSubview(headerView_Sylva)
        headerView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(360)
        }

        // 装饰圆
        let decoBig_sylva = UIView()
        decoBig_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        decoBig_sylva.layer.cornerRadius = 70
        headerView_Sylva.addSubview(decoBig_sylva)
        decoBig_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(-30)
            make.width.height.equalTo(140)
        }

        let decoSmall_sylva = UIView()
        decoSmall_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        decoSmall_sylva.layer.cornerRadius = 50
        headerView_Sylva.addSubview(decoSmall_sylva)
        decoSmall_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(20)
            make.width.height.equalTo(100)
        }

        // 头像（固定 80pt 偏移，覆盖所有机型安全区）
        avatarView_Sylva.layer.cornerRadius = 46
        avatarView_Sylva.layer.masksToBounds = true
        avatarView_Sylva.layer.borderWidth = 3.5
        avatarView_Sylva.layer.borderColor = UIColor.white.cgColor
        headerView_Sylva.addSubview(avatarView_Sylva)
        avatarView_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }

        // 用户名
        nameLabel_Sylva.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        nameLabel_Sylva.textColor = .white
        nameLabel_Sylva.textAlignment = .center
        headerView_Sylva.addSubview(nameLabel_Sylva)
        nameLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Sylva.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 简介
        introduceLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        introduceLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#95D5B2")
        introduceLabel_Sylva.textAlignment = .center
        introduceLabel_Sylva.numberOfLines = 2
        headerView_Sylva.addSubview(introduceLabel_Sylva)
        introduceLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Sylva.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }

        setupStatsRow_Sylva()
        setupActionButtons_Sylva()
    }

    /// 搭建统计数据行（带半透明 pill 背景 + 竖线分隔）
    private func setupStatsRow_Sylva() {
        headerView_Sylva.addSubview(statsRow_Sylva)
        statsRow_Sylva.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel_Sylva.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        let statsBg_sylva = UIView()
        statsBg_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        statsBg_sylva.layer.cornerRadius = 16
        statsRow_Sylva.addSubview(statsBg_sylva)
        statsBg_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let items_sylva = [(200, "Following"), (201, "Fans"), (202, "Posts")]
        let stack_sylva = UIStackView()
        stack_sylva.axis = .horizontal
        stack_sylva.distribution = .fillEqually
        statsRow_Sylva.addSubview(stack_sylva)
        stack_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        for (i_sylva, cfg_sylva) in items_sylva.enumerated() {
            let item_sylva = UIView()
            let numLbl_sylva = UILabel()
            numLbl_sylva.text = "0"
            numLbl_sylva.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
            numLbl_sylva.textColor = .white
            numLbl_sylva.textAlignment = .center
            numLbl_sylva.tag = cfg_sylva.0
            item_sylva.addSubview(numLbl_sylva)
            numLbl_sylva.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.centerX.equalToSuperview()
            }
            let titleLbl_sylva = UILabel()
            titleLbl_sylva.text = cfg_sylva.1
            titleLbl_sylva.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            titleLbl_sylva.textColor = UIColor.white.withAlphaComponent(0.65)
            titleLbl_sylva.textAlignment = .center
            item_sylva.addSubview(titleLbl_sylva)
            titleLbl_sylva.snp.makeConstraints { make in
                make.top.equalTo(numLbl_sylva.snp.bottom).offset(3)
                make.centerX.equalToSuperview()
            }
            stack_sylva.addArrangedSubview(item_sylva)

            if i_sylva < items_sylva.count - 1 {
                let div_sylva = UIView()
                div_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                statsRow_Sylva.addSubview(div_sylva)
                div_sylva.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.width.equalTo(1)
                    make.height.equalToSuperview().multipliedBy(0.5)
                    make.leading.equalToSuperview().offset(CGFloat(i_sylva + 1) * (view.bounds.width - 48) / 3)
                }
            }
        }
    }

    /// 搭建关注/消息按钮行
    private func setupActionButtons_Sylva() {
        followButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        followButton_Sylva.layer.cornerRadius = 18
        followButton_Sylva.addTarget(self, action: #selector(followTapped_Sylva), for: .touchUpInside)

        messageButton_Sylva.setTitle("Message", for: .normal)
        messageButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        messageButton_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#1B4332"), for: .normal)
        messageButton_Sylva.backgroundColor = .white
        messageButton_Sylva.layer.cornerRadius = 18
        messageButton_Sylva.layer.shadowColor  = UIColor.black.cgColor
        messageButton_Sylva.layer.shadowOpacity = 0.1
        messageButton_Sylva.layer.shadowRadius  = 6
        messageButton_Sylva.addTarget(self, action: #selector(messageTapped_Sylva), for: .touchUpInside)

        if !showMessageButton_Sylva {
            headerView_Sylva.addSubview(followButton_Sylva)
            followButton_Sylva.snp.makeConstraints { make in
                make.top.equalTo(statsRow_Sylva.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.width.equalTo(160)
                make.height.equalTo(38)
            }
        } else {
            headerView_Sylva.addSubview(followButton_Sylva)
            headerView_Sylva.addSubview(messageButton_Sylva)
            followButton_Sylva.snp.makeConstraints { make in
                make.top.equalTo(statsRow_Sylva.snp.bottom).offset(16)
                make.leading.equalToSuperview().offset(36)
                make.width.equalTo((APPSCREEN_Sylva.WIDTH_Sylva - 96) / 2)
                make.height.equalTo(38)
            }
            messageButton_Sylva.snp.makeConstraints { make in
                make.top.height.width.equalTo(followButton_Sylva)
                make.trailing.equalToSuperview().offset(-36)
            }
        }
        updateFollowButtonUI_Sylva()
    }

    /// 搭建帖子区（标题 + 列表 + 空状态）
    private func setupPostSection_Sylva() {
        let sectionLabel_sylva = UILabel()
        sectionLabel_sylva.text = "Posts"
        sectionLabel_sylva.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        sectionLabel_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        contentView_Sylva.addSubview(sectionLabel_sylva)
        sectionLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(headerView_Sylva.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        // 空状态卡片
        emptyPostView_Sylva.backgroundColor = .white
        emptyPostView_Sylva.layer.cornerRadius = 18
        emptyPostView_Sylva.layer.shadowColor   = UIColor.black.cgColor
        emptyPostView_Sylva.layer.shadowOpacity  = 0.05
        emptyPostView_Sylva.layer.shadowRadius   = 10
        emptyPostView_Sylva.isHidden = true
        contentView_Sylva.addSubview(emptyPostView_Sylva)
        emptyPostView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(130)
            // 不设 bottom 到 contentView：由 postTableView 唯一定义 contentView 底部
            // 避免两个视图同时锚定 contentView.bottom 产生冲突导致高度计算错误
        }

        let emptyIcon_sylva = UIImageView(image: UIImage(systemName: "tray"))
        emptyIcon_sylva.tintColor = UIColor(hexstring_Sylva: "#B7E4C7")
        emptyIcon_sylva.contentMode = .scaleAspectFit
        emptyPostView_Sylva.addSubview(emptyIcon_sylva)
        emptyIcon_sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(26)
            make.width.height.equalTo(32)
        }

        let emptyTitle_sylva = UILabel()
        emptyTitle_sylva.text = "No posts yet"
        emptyTitle_sylva.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        emptyTitle_sylva.textColor = UIColor(hexstring_Sylva: "#2D6A4F")
        emptyTitle_sylva.textAlignment = .center
        emptyPostView_Sylva.addSubview(emptyTitle_sylva)
        emptyTitle_sylva.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_sylva.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let emptySubtitle_sylva = UILabel()
        emptySubtitle_sylva.text = "This user hasn't shared a story yet"
        emptySubtitle_sylva.font = UIFont.systemFont(ofSize: 12)
        emptySubtitle_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        emptySubtitle_sylva.textAlignment = .center
        emptyPostView_Sylva.addSubview(emptySubtitle_sylva)
        emptySubtitle_sylva.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle_sylva.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 帖子 TableView
        postTableView_Sylva = UITableView()
        postTableView_Sylva.backgroundColor = .clear
        postTableView_Sylva.separatorStyle  = .none
        postTableView_Sylva.isScrollEnabled = false
        postTableView_Sylva.dataSource      = self
        postTableView_Sylva.delegate        = self
        postTableView_Sylva.register(MePostCell_Sylva.self, forCellReuseIdentifier: MePostCell_Sylva.reuseId_Sylva)
        contentView_Sylva.addSubview(postTableView_Sylva)
        postTableView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_sylva.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 搭建顶部浮层导航按钮（直接加到 view，用 safeAreaLayoutGuide）
    private func setupNavButtons_Sylva() {
        let backBtn_sylva = UIButton(type: .system)
        let backCfg_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn_sylva.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_sylva), for: .normal)
        backBtn_sylva.tintColor = .white
        backBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backBtn_sylva.layer.cornerRadius = 18
        backBtn_sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        view.addSubview(backBtn_sylva)
        backBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        let reportBtn_sylva = ReportDeleteHelper_Sylva.createUserReportButton_Sylva(
            size_Sylva: 36,
            backgroundColor_Sylva: UIColor.white.withAlphaComponent(0.18),
            tintColor_Sylva: .white
        )
        reportBtn_sylva.addAction(UIAction { [weak self] _ in
            guard let self_sylva = self, let user_sylva = self_sylva.userModel_Sylva else { return }
            ReportDeleteHelper_Sylva.block_Sylva(user_Sylva: user_sylva, from: self_sylva) {
                Navigation_Sylva.popToSafeStateAfterBlock_Sylva(from: self_sylva)
            }
        }, for: .touchUpInside)
        view.addSubview(reportBtn_sylva)
        reportBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 数据刷新

    private func refreshAll_Sylva() {
        guard let user_sylva = userModel_Sylva else { return }
        avatarView_Sylva.configure_Sylva(userId_Sylva: user_sylva.userId_Sylva ?? 0)
        nameLabel_Sylva.text      = user_sylva.userName_Sylva ?? ""
        introduceLabel_Sylva.text = user_sylva.userIntroduce_Sylva ?? "Plant a tree, grow a future."

        let counts_sylva = [user_sylva.userFollow_Sylva ?? 0, user_sylva.userFans_Sylva ?? 0, userPosts_Sylva.count]
        for (i_sylva, count_sylva) in counts_sylva.enumerated() {
            (statsRow_Sylva.viewWithTag(200 + i_sylva) as? UILabel)?.text = "\(count_sylva)"
        }

        userPosts_Sylva = TitleViewModel_Sylva.shared_Sylva.getUserPosts_Sylva(user_sylva: user_sylva)
        (statsRow_Sylva.viewWithTag(202) as? UILabel)?.text = "\(userPosts_Sylva.count)"

        let isEmpty_sylva = userPosts_Sylva.isEmpty
        emptyPostView_Sylva.isHidden  = !isEmpty_sylva
        postTableView_Sylva.isHidden  = isEmpty_sylva
        postTableView_Sylva.reloadData()
        // 空状态时给 tableView 160pt 高度，以便 emptyPostView（130pt）正常显示在 contentView frame 内
        // 有帖子时按每行 120pt 计算
        let h_sylva = isEmpty_sylva ? 160 : CGFloat(userPosts_Sylva.count) * 120
        postTableView_Sylva.snp.updateConstraints { make in make.height.equalTo(h_sylva) }

        updateFollowButtonUI_Sylva()
    }

    private func updateFollowButtonUI_Sylva() {
        guard let user_sylva = userModel_Sylva else { return }
        let isFollowing_sylva = UserViewModel_Sylva.shared_Sylva.isFollowing_Sylva(user_sylva: user_sylva)
        if isFollowing_sylva {
            followButton_Sylva.setTitle("Following ✓", for: .normal)
            followButton_Sylva.setTitleColor(.white, for: .normal)
            followButton_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
            followButton_Sylva.layer.borderWidth = 0
            followButton_Sylva.layer.shadowColor   = UIColor(hexstring_Sylva: "#40916C").cgColor
            followButton_Sylva.layer.shadowOpacity = 0.35
            followButton_Sylva.layer.shadowRadius  = 8
        } else {
            followButton_Sylva.setTitle("Follow", for: .normal)
            followButton_Sylva.setTitleColor(.white, for: .normal)
            followButton_Sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            followButton_Sylva.layer.borderWidth = 1.5
            followButton_Sylva.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
            followButton_Sylva.layer.shadowOpacity = 0
        }
    }

    // MARK: - 通知

    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserStateChanged_Sylva),
            name: UserViewModel_Sylva.userStateDidChangeNotification_Sylva, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleStateChanged_Sylva),
            name: TitleViewModel_Sylva.titleStateDidChangeNotification_Sylva, object: nil)
    }

    @objc private func onUserStateChanged_Sylva()  { updateFollowButtonUI_Sylva() }
    @objc private func onTitleStateChanged_Sylva()  { refreshAll_Sylva() }

    // MARK: - 事件

    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func followTapped_Sylva() {
        guard let user_sylva = userModel_Sylva else { return }
        followButton_Sylva.animatePulse_Sylva()
        let wasFollowing_sylva = UserViewModel_Sylva.shared_Sylva.isFollowing_Sylva(user_sylva: user_sylva)
        UserViewModel_Sylva.shared_Sylva.followUser_Sylva(user_sylva: user_sylva)
        updateFollowButtonUI_Sylva()
        if fromMessage_Sylva && wasFollowing_sylva {
            if let uid_sylva = user_sylva.userId_Sylva {
                MessageViewModel_Sylva.shared_Sylva.deleteUserMessages_Sylva(userId_sylva: uid_sylva)
            }
            navigationController?.popToRootViewController(animated: true)
        }
    }

    @objc private func messageTapped_Sylva() {
        guard let user_sylva = userModel_Sylva else { return }
        guard UserViewModel_Sylva.shared_Sylva.isFollowing_Sylva(user_sylva: user_sylva) else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Follow this user to start a conversation")
            return
        }
        let sheet_sylva = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet_sylva.message = "\(user_sylva.userName_Sylva ?? "")\n\(user_sylva.userIntroduce_Sylva ?? "No introduction")"
        sheet_sylva.addAction(UIAlertAction(title: "Start Chat", style: .default) { [weak self] _ in
            guard let self_sylva = self else { return }
            Navigation_Sylva.toMessageUser_Sylva(with: user_sylva)
        })
        sheet_sylva.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet_sylva, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension UserInfo_Sylva: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts_Sylva.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_sylva = tableView.dequeueReusableCell(
            withIdentifier: MePostCell_Sylva.reuseId_Sylva, for: indexPath
        ) as? MePostCell_Sylva else { return UITableViewCell() }
        cell_sylva.configure_Sylva(post_sylva: userPosts_Sylva[indexPath.row], viewController_sylva: self) { [weak self] in
            self?.refreshAll_Sylva()
        }
        return cell_sylva
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 112 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Sylva.toTitleDetail_Sylva(titleModel_sylva: userPosts_Sylva[indexPath.row])
    }
}
