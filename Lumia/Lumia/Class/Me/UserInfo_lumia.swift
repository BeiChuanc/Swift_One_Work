import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面

/// 用户中心页面视图控制器
/// 核心作用：展示他人个人资料、帖子列表，提供关注/取关、发起聊天、举报功能
/// 设计思路：
///   - 头部：渐变背景 + 统计卡（Posts/Following/Fans）+ 关注/消息按钮，明确约束头部高度
///   - 帖子列表：卡片式 UserInfoPostCell_Lumia（大缩略图 + 双统计数字）
///   - 举报按钮：右上角浮层（同 Detail 页风格）
///   - 未关注点击聊天：显示富 UI 底部弹窗 FollowFirstSheet_Lumia
class UserInfo_Lumia: UIViewController {

    // MARK: - 公开属性

    var userModel_Lumia: PrewUserModel_Lumia?
    var fromMessagePage_Lumia: Bool = false

    // MARK: - 私有属性

    private var userPosts_Lumia: [TitleModel_Lumia] = []
    private let headerHeight_Lumia: CGFloat = 400

    // MARK: - UI组件

    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.separatorStyle = .none
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tv_Lumia.contentInsetAdjustmentBehavior = .never
        return tv_Lumia
    }()

    private lazy var profileHeader_Lumia = UserInfoProfileHeader_Lumia(fromMessage: fromMessagePage_Lumia)

    private let backButton_Lumia = BackButton_Lumia()

    /// 举报按钮（右上角浮层，同 Detail 页风格）
    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        setupObservers_Lumia()
        loadData_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")

        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(
            UserInfoGridRowCell_Lumia.self,
            forCellReuseIdentifier: UserInfoGridRowCell_Lumia.reuseId_Lumia
        )

        profileHeader_Lumia.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight_Lumia)
        profileHeader_Lumia.onFollowTapped_Lumia = { [weak self] in self?.handleFollowTap_Lumia() }
        profileHeader_Lumia.onMessageTapped_Lumia = { [weak self] in self?.handleMessageTap_Lumia() }
        tableView_Lumia.tableHeaderView = profileHeader_Lumia

        // 返回按钮（左上角浮层）
        view.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        // 举报按钮（右上角浮层）
        view.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(38)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)
    }

    // MARK: - 数据加载

    private func loadData_Lumia() {
        guard let user_Lumia = userModel_Lumia else { return }
        // 从本地列表刷新用户模型（确保粉丝数是最新值）
        let freshUser_Lumia = LocalData_Lumia.shared_Lumia.userList_Lumia.first {
            $0.userId_Lumia == user_Lumia.userId_Lumia
        } ?? user_Lumia
        userModel_Lumia = freshUser_Lumia

        userPosts_Lumia = TitleViewModel_Lumia.shared_Lumia.getUserPosts_Lumia(user_lumia: freshUser_Lumia)
        let isFollowing_Lumia = UserViewModel_Lumia.shared_Lumia.isFollowing_Lumia(user_lumia: freshUser_Lumia)
        profileHeader_Lumia.configure_Lumia(
            user: freshUser_Lumia,
            isFollowing: isFollowing_Lumia,
            fromMessage: fromMessagePage_Lumia
        )
        tableView_Lumia.reloadData()
        profileHeader_Lumia.frame.size.height = headerHeight_Lumia
        tableView_Lumia.tableHeaderView = profileHeader_Lumia
    }

    // MARK: - 关注操作

    private func handleFollowTap_Lumia() {
        guard let user_Lumia = userModel_Lumia else { return }
        let isFollowing_Lumia = UserViewModel_Lumia.shared_Lumia.isFollowing_Lumia(user_lumia: user_Lumia)
        if isFollowing_Lumia && fromMessagePage_Lumia {
            showUnfollowConfirm_Lumia(user: user_Lumia)
        } else {
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.followUser_Lumia(user_lumia: user_Lumia)
            }
        }
    }

    private func showUnfollowConfirm_Lumia(user: PrewUserModel_Lumia) {
        let alert_Lumia = UIAlertController(
            title: "Unfollow",
            message: "Unfollowing will remove your chat history with \(user.userName_Lumia ?? "this user"). Continue?",
            preferredStyle: .alert
        )
        alert_Lumia.addAction(UIAlertAction(title: "Unfollow", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.followUser_Lumia(user_lumia: user)
                if let uid_Lumia = user.userId_Lumia {
                    MessageViewModel_Lumia.shared_Lumia.deleteUserMessages_Lumia(userId_lumia: uid_Lumia)
                }
            }
            Navigation_Lumia.toMessageList_Lumia()
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }

    // MARK: - 消息操作

    private func handleMessageTap_Lumia() {
        guard let user_Lumia = userModel_Lumia else { return }
        let isFollowing_Lumia = UserViewModel_Lumia.shared_Lumia.isFollowing_Lumia(user_lumia: user_Lumia)
        if !isFollowing_Lumia {
            // 未关注：显示富 UI 底部弹窗引导关注
            showFollowFirstSheet_Lumia(user: user_Lumia)
            return
        }
        showChatConfirmSheet_Lumia(user: user_Lumia)
    }

    /// 未关注时的引导弹窗
    private func showFollowFirstSheet_Lumia(user: PrewUserModel_Lumia) {
        let sheet_Lumia = FollowFirstSheet_Lumia(user: user)
        sheet_Lumia.onFollowTapped_Lumia = { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.followUser_Lumia(user_lumia: user)
            }
        }
        sheet_Lumia.modalPresentationStyle = .overFullScreen
        present(sheet_Lumia, animated: false)
    }

    private func showChatConfirmSheet_Lumia(user: PrewUserModel_Lumia) {
        let sheet_Lumia = ChatConfirmSheet_Lumia(user: user)
        sheet_Lumia.onConfirmed_Lumia = { Navigation_Lumia.toMessageUser_Lumia(with: user) }
        sheet_Lumia.modalPresentationStyle = .overFullScreen
        present(sheet_Lumia, animated: false)
    }

    // MARK: - 举报

    @objc private func handleReport_Lumia() {
        guard let user_Lumia = userModel_Lumia else { return }
        ReportDeleteHelper_Lumia.block_Lumia(user_Lumia: user_Lumia, from: self) { [weak self] in
            Navigation_Lumia.popToSafeStateAfterBlock_Lumia(from: self ?? UIViewController())
        }
    }

    // MARK: - 通知

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleChange_Lumia),
            name: TitleViewModel_Lumia.titleStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleUserChange_Lumia() { loadData_Lumia() }
    @objc private func handleTitleChange_Lumia() { loadData_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITableViewDelegate & DataSource

extension UserInfo_Lumia: UITableViewDelegate, UITableViewDataSource {

    /// 两列网格：每行显示 2 条帖子，行数 = ceil(count/2)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts_Lumia.isEmpty ? 1 : Int(ceil(Double(userPosts_Lumia.count) / 2.0))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if userPosts_Lumia.isEmpty {
            return makeEmptyCell_Lumia(tableView, indexPath)
        }
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: UserInfoGridRowCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! UserInfoGridRowCell_Lumia

        let leftIndex_Lumia = indexPath.row * 2
        let leftPost_Lumia = userPosts_Lumia[leftIndex_Lumia]
        let rightPost_Lumia = leftIndex_Lumia + 1 < userPosts_Lumia.count ? userPosts_Lumia[leftIndex_Lumia + 1] : nil
        cell_Lumia.configure_Lumia(left: leftPost_Lumia, right: rightPost_Lumia, from: self)
        cell_Lumia.onPostTapped_Lumia = { [weak self] post_Lumia in
            Navigation_Lumia.toTitleDetail_Lumia(titleModel_lumia: post_Lumia)
        }
        return cell_Lumia
    }

    private func makeEmptyCell_Lumia(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = UITableViewCell()
        cell_Lumia.backgroundColor = .clear
        cell_Lumia.selectionStyle = .none

        let iconView_Lumia = UIImageView()
        iconView_Lumia.image = UIImage(systemName: "camera.on.rectangle")
        iconView_Lumia.tintColor = UIColor(hexstring_Lumia: "#B794F6", alpha_Lumia: 0.45)
        iconView_Lumia.contentMode = .scaleAspectFit
        cell_Lumia.contentView.addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }

        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "No posts yet."
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8060B0")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cell_Lumia.contentView.addSubview(lbl_Lumia)
        lbl_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if userPosts_Lumia.isEmpty { return UITableView.automaticDimension }
        // 卡片宽 = (屏幕 - 左右padding - 间距) / 2；高 = 图片 + 文字区
        let cardW_Lumia = (UIScreen.main.bounds.width - 16 * 2 - 10) / 2
        return cardW_Lumia * 0.72 + 80 + 12  // 图片区 + 文字区 + 上下padding
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - 用户中心 Profile Header

/// 用户中心头部视图
/// 核心作用：头像光环 + 用户名 + 简介 + 统计卡 + 关注/消息按钮
/// 设计思路：渐变背景 240pt + 统计卡（Posts/Following/Fans）叠在渐变底部 + 按钮区在卡下方
private class UserInfoProfileHeader_Lumia: UIView {

    var onFollowTapped_Lumia: (() -> Void)?
    var onMessageTapped_Lumia: (() -> Void)?

    private var isFromMessage_Lumia: Bool = false
    private var gradientLayer_Lumia: CAGradientLayer?
    private var followBtnGradient_Lumia: CAGradientLayer?

    private let bgView_Lumia = UIView()

    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 47
        v_Lumia.layer.borderWidth = 3.5
        v_Lumia.layer.borderColor = UIColor.white.cgColor
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#6A40C0").cgColor
        v_Lumia.layer.shadowOpacity = 0.22
        v_Lumia.layer.shadowRadius = 14
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let avatarView_Lumia: UserAvatarView_Lumia = {
        let v_Lumia = UserAvatarView_Lumia()
        v_Lumia.layer.cornerRadius = 40
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()

    private let userNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        lbl_Lumia.textColor = .white
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let introLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.80)
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let statsCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        v_Lumia.layer.shadowOpacity = 0.14
        v_Lumia.layer.shadowRadius = 14
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let postsStatView_Lumia = UserStatItem_Lumia(label: "Posts")
    private let followingStatView_Lumia = UserStatItem_Lumia(label: "Following")
    private let fansStatView_Lumia = UserStatItem_Lumia(label: "Fans")

    /// 关注按钮（渐变填充 / 描边 + 紫色文字）
    private let followButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("  Follow", for: .normal)
        btn_Lumia.setTitle("  Followed", for: .selected)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn_Lumia.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.setImage(UIImage(systemName: "person.fill.checkmark", withConfiguration: cfg_Lumia), for: .selected)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#6A40C0"), for: .selected)
        btn_Lumia.tintColor = .white
        btn_Lumia.layer.cornerRadius = 20
        btn_Lumia.clipsToBounds = true
        return btn_Lumia
    }()

    private let messageButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#8A5CC8")
        btn_Lumia.backgroundColor = .white
        btn_Lumia.layer.cornerRadius = 20
        btn_Lumia.layer.borderWidth = 1.5
        btn_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#8A5CC8", alpha_Lumia: 0.30).cgColor
        btn_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#8A5CC8").cgColor
        btn_Lumia.layer.shadowOpacity = 0.15
        btn_Lumia.layer.shadowRadius = 6
        btn_Lumia.layer.shadowOffset = CGSize(width: 0, height: 2)
        return btn_Lumia
    }()

    init(fromMessage: Bool = false) {
        self.isFromMessage_Lumia = fromMessage
        super.init(frame: .zero)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Lumia?.frame = bgView_Lumia.bounds
        followBtnGradient_Lumia?.frame = followButton_Lumia.bounds
    }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")

        // 渐变背景：增高至 260pt，为用户名 + 两行简介留出充足空间，避免被悬浮统计卡遮盖
        addSubview(bgView_Lumia)
        bgView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
        }
        bgView_Lumia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bgView_Lumia.layer.cornerRadius = 30
        bgView_Lumia.clipsToBounds = true

        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#8A5CC8").cgColor,
            UIColor(hexstring_Lumia: "#4A86D4").cgColor,
            UIColor(hexstring_Lumia: "#2AA8E8").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        bgView_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        gradientLayer_Lumia = gradient_Lumia

        // 装饰气泡
        let b1 = makeDecoBubble_Lumia(size: 90, alpha: 0.09)
        bgView_Lumia.addSubview(b1)
        b1.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: -30, width: 90, height: 90)
        let b2 = makeDecoBubble_Lumia(size: 50, alpha: 0.11)
        bgView_Lumia.addSubview(b2)
        b2.frame = CGRect(x: -18, y: 80, width: 50, height: 50)

        // 头像光环
        bgView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(94)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(5) }

        bgView_Lumia.addSubview(userNameLabel_Lumia)
        userNameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Lumia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        bgView_Lumia.addSubview(introLabel_Lumia)
        introLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Lumia.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
            // statsCard 以 offset(-22) 悬浮叠在 bgView 底部，留出足够间距避免遮盖简介文字
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }

        // 悬浮统计卡（叠在渐变底部 22pt）
        addSubview(statsCard_Lumia)
        statsCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(bgView_Lumia.snp.bottom).offset(-22)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(64)
        }

        let d1 = makeStatDivider_Lumia()
        let d2 = makeStatDivider_Lumia()
        let stack_Lumia = UIStackView(arrangedSubviews: [postsStatView_Lumia, d1, followingStatView_Lumia, d2, fansStatView_Lumia])
        stack_Lumia.axis = .horizontal
        stack_Lumia.distribution = .fill
        stack_Lumia.alignment = .center
        statsCard_Lumia.addSubview(stack_Lumia)
        stack_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        d1.snp.makeConstraints { make in make.width.equalTo(1); make.height.equalTo(30) }
        d2.snp.makeConstraints { make in make.width.equalTo(1); make.height.equalTo(30) }
        postsStatView_Lumia.snp.makeConstraints { make in make.width.equalTo(fansStatView_Lumia) }
        followingStatView_Lumia.snp.makeConstraints { make in make.width.equalTo(fansStatView_Lumia) }

        // 按钮行：关注 + 消息，均为等宽 44pt 高，横向排列
        let btnRow_Lumia = UIView()
        addSubview(btnRow_Lumia)
        btnRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }

        if isFromMessage_Lumia {
            // 从消息页进入：只显示关注按钮，居中全宽
            btnRow_Lumia.addSubview(followButton_Lumia)
            followButton_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else {
            // 普通进入：关注按钮占剩余空间，消息按钮 52pt 宽
            btnRow_Lumia.addSubview(messageButton_Lumia)
            messageButton_Lumia.snp.makeConstraints { make in
                make.trailing.top.bottom.equalToSuperview()
                make.width.equalTo(52)
            }
            messageButton_Lumia.addTarget(self, action: #selector(handleMessage_Lumia), for: .touchUpInside)

            btnRow_Lumia.addSubview(followButton_Lumia)
            followButton_Lumia.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.trailing.equalTo(messageButton_Lumia.snp.leading).offset(-12)
            }
        }
        followButton_Lumia.addTarget(self, action: #selector(handleFollow_Lumia), for: .touchUpInside)
        applyFollowStyle_Lumia(following: false)
    }

    private func makeDecoBubble_Lumia(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Lumia.layer.cornerRadius = size / 2
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }

    private func makeStatDivider_Lumia() -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#D8CCEE")
        return v_Lumia
    }

    private func applyFollowStyle_Lumia(following: Bool) {
        followBtnGradient_Lumia?.removeFromSuperlayer()
        followBtnGradient_Lumia = nil

        if following {
            followButton_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")
            followButton_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#6A40C0"), for: .selected)
            followButton_Lumia.tintColor = UIColor(hexstring_Lumia: "#6A40C0")
            followButton_Lumia.layer.borderWidth = 1.5
            followButton_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        } else {
            followButton_Lumia.backgroundColor = .clear
            followButton_Lumia.tintColor = .white
            followButton_Lumia.layer.borderWidth = 0
            let grad_Lumia = CAGradientLayer()
            grad_Lumia.colors = [
                UIColor(hexstring_Lumia: "#8A5CC8").cgColor,
                UIColor(hexstring_Lumia: "#4A86D4").cgColor
            ]
            grad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
            grad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
            grad_Lumia.cornerRadius = 20
            followButton_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
            followBtnGradient_Lumia = grad_Lumia
            DispatchQueue.main.async { grad_Lumia.frame = self.followButton_Lumia.bounds }
        }
    }

    func configure_Lumia(user: PrewUserModel_Lumia, isFollowing: Bool, fromMessage: Bool) {
        if let uid_Lumia = user.userId_Lumia {
            avatarView_Lumia.configure_Lumia(userId_Lumia: uid_Lumia)
        }
        userNameLabel_Lumia.text = user.userName_Lumia ?? "User"
        introLabel_Lumia.text = user.userIntroduce_Lumia ?? "Film photographer"
        followButton_Lumia.isSelected = isFollowing
        applyFollowStyle_Lumia(following: isFollowing)

        let postCount_Lumia = TitleViewModel_Lumia.shared_Lumia.getUserPosts_Lumia(user_lumia: user).count
        postsStatView_Lumia.setValue_Lumia("\(postCount_Lumia)")
        followingStatView_Lumia.setValue_Lumia("\(user.userFollow_Lumia ?? 0)")
        fansStatView_Lumia.setValue_Lumia("\(user.userFans_Lumia ?? 0)")
    }

    @objc private func handleFollow_Lumia() {
        followButton_Lumia.animatePulse_Lumia()
        onFollowTapped_Lumia?()
    }

    @objc private func handleMessage_Lumia() { onMessageTapped_Lumia?() }
}

// MARK: - 统计数据项

private class UserStatItem_Lumia: UIView {

    private let valueLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1040")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.text = "0"
        return lbl_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#9070C0")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    init(label: String) {
        super.init(frame: .zero)
        titleLabel_Lumia.text = label
        addSubview(valueLabel_Lumia)
        addSubview(titleLabel_Lumia)
        valueLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.centerX.equalToSuperview()
        }
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Lumia.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setValue_Lumia(_ v: String) { valueLabel_Lumia.text = v }
}

// MARK: - 两列网格行 Cell

/// 帖子列表两列网格行 Cell
/// 核心作用：每行并排展示两张帖子迷你卡片，每卡右上角带举报按钮
/// 设计：媒体图（上方约 72%）+ 标题（1行）+ 点赞/评论统计 + 举报按钮悬浮右上角
private class UserInfoGridRowCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "UserInfoGridRowCell_Lumia"

    var onPostTapped_Lumia: ((TitleModel_Lumia) -> Void)?

    private let leftCard_Lumia = UserInfoPostMiniCard_Lumia()
    private let rightCard_Lumia = UserInfoPostMiniCard_Lumia()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(leftCard_Lumia)
        contentView.addSubview(rightCard_Lumia)

        leftCard_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-6)
            make.trailing.equalTo(contentView.snp.centerX).offset(-5)
        }
        rightCard_Lumia.snp.makeConstraints { make in
            make.top.bottom.equalTo(leftCard_Lumia)
            make.leading.equalTo(contentView.snp.centerX).offset(5)
            make.trailing.equalToSuperview().offset(-16)
        }

        leftCard_Lumia.onTapped_Lumia = { [weak self] post_Lumia in self?.onPostTapped_Lumia?(post_Lumia) }
        rightCard_Lumia.onTapped_Lumia = { [weak self] post_Lumia in self?.onPostTapped_Lumia?(post_Lumia) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置左右两张卡片；right 为 nil 时隐藏右卡
    func configure_Lumia(left: TitleModel_Lumia, right: TitleModel_Lumia?, from vc: UIViewController) {
        leftCard_Lumia.configure_Lumia(post: left, from: vc)
        leftCard_Lumia.isHidden = false

        if let right_Lumia = right {
            rightCard_Lumia.configure_Lumia(post: right_Lumia, from: vc)
            rightCard_Lumia.isHidden = false
        } else {
            rightCard_Lumia.isHidden = true
        }
    }
}

// MARK: - 帖子迷你卡片

/// 帖子迷你卡片（用于两列网格）
/// 包含：媒体图、标题、心形+评论统计、右上角举报按钮
private class UserInfoPostMiniCard_Lumia: UIView {

    var onTapped_Lumia: ((TitleModel_Lumia) -> Void)?

    private var post_Lumia: TitleModel_Lumia?
    private weak var fromVC_Lumia: UIViewController?

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 16
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        v_Lumia.layer.shadowOpacity = 0.10
        v_Lumia.layer.shadowRadius = 10
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let mediaView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 16
        mv_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A1030")
        lbl_Lumia.numberOfLines = 1
        return lbl_Lumia
    }()

    private let likeIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv_Lumia.tintColor = ColorConfig_Lumia.secondaryGradientStart_Lumia
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let likeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A090C0")
        return lbl_Lumia
    }()

    private let commentIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "bubble.left.fill"))
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#90CDF4")
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let commentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A090C0")
        return lbl_Lumia
    }()

    /// 举报按钮（右上角叠加）
    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn_Lumia.layer.cornerRadius = 12
        return btn_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }

        cardView_Lumia.addSubview(mediaView_Lumia)
        mediaView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.60)
        }

        // 举报按钮悬浮于媒体右上角
        cardView_Lumia.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.width.height.equalTo(24)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)

        cardView_Lumia.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Lumia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        cardView_Lumia.addSubview(likeIcon_Lumia)
        likeIcon_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel_Lumia)
            make.width.height.equalTo(11)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        cardView_Lumia.addSubview(likeLabel_Lumia)
        likeLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(likeIcon_Lumia.snp.trailing).offset(3)
        }

        cardView_Lumia.addSubview(commentIcon_Lumia)
        commentIcon_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(likeLabel_Lumia.snp.trailing).offset(8)
            make.width.height.equalTo(11)
        }

        cardView_Lumia.addSubview(commentLabel_Lumia)
        commentLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(commentIcon_Lumia.snp.trailing).offset(3)
        }

        // 点击卡片进详情
        let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia))
        cardView_Lumia.addGestureRecognizer(tap_Lumia)
        cardView_Lumia.isUserInteractionEnabled = true
    }

    func configure_Lumia(post: TitleModel_Lumia, from vc: UIViewController) {
        self.post_Lumia = post
        self.fromVC_Lumia = vc
        mediaView_Lumia.configure_Lumia(mediaPath_Lumia: post.titleMeidas_Lumia.first)
        titleLabel_Lumia.text = post.title_Lumia
        likeLabel_Lumia.text = "\(post.likes_Lumia)"
        commentLabel_Lumia.text = "\(post.reviews_Lumia.count)"
    }

    @objc private func handleTap_Lumia() {
        guard let post_Lumia = post_Lumia else { return }
        onTapped_Lumia?(post_Lumia)
    }

    @objc private func handleReport_Lumia() {
        guard let post_Lumia = post_Lumia, let vc_Lumia = fromVC_Lumia else { return }
        let isMyPost_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(userId_lumia: post_Lumia.titleUserId_Lumia)
        if isMyPost_Lumia {
            ReportDeleteHelper_Lumia.delete_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        } else {
            ReportDeleteHelper_Lumia.report_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        }
    }
}

// MARK: - 用户中心帖子 Cell（保留备用）

/// 用户中心帖子卡片 Cell
/// 核心作用：展示单条帖子，含大正方形缩略图、标题、内容摘要、点赞/评论统计
/// 设计思路：白色卡片 + 紫色调阴影 + 方形缩略图 + 渐变左色条
private class UserInfoPostCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "UserInfoPostCell_Lumia"

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 16
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        v_Lumia.layer.shadowOpacity = 0.10
        v_Lumia.layer.shadowRadius = 10
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let accentBar_Lumia = UIView()
    private var accentGradient_Lumia: CAGradientLayer?

    private let thumbView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 12
        mv_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A1030")
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let contentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8070A8")
        lbl_Lumia.numberOfLines = 1
        return lbl_Lumia
    }()

    private let likeIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv_Lumia.tintColor = ColorConfig_Lumia.secondaryGradientStart_Lumia
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let likeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A090C0")
        return lbl_Lumia
    }()

    private let commentIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "bubble.left.fill"))
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#90CDF4")
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let commentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A090C0")
        return lbl_Lumia
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        accentGradient_Lumia?.frame = accentBar_Lumia.bounds
    }

    private func setupUI_Lumia() {
        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }

        // 左侧渐变色条
        cardView_Lumia.addSubview(accentBar_Lumia)
        accentBar_Lumia.layer.cornerRadius = 2
        accentBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        accentBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        let grad_Lumia = CAGradientLayer()
        grad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#8A5CC8").cgColor,
            UIColor(hexstring_Lumia: "#4A86D4").cgColor
        ]
        grad_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        grad_Lumia.cornerRadius = 2
        accentBar_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
        accentGradient_Lumia = grad_Lumia

        // 缩略图（正方形，左侧）
        cardView_Lumia.addSubview(thumbView_Lumia)
        thumbView_Lumia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(accentBar_Lumia.snp.trailing)
            make.width.equalTo(118)
        }

        // 标题
        cardView_Lumia.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(thumbView_Lumia.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        // 内容摘要
        cardView_Lumia.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(6)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        // 统计行
        cardView_Lumia.addSubview(likeIcon_Lumia)
        likeIcon_Lumia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalTo(titleLabel_Lumia)
            make.width.height.equalTo(13)
        }
        cardView_Lumia.addSubview(likeLabel_Lumia)
        likeLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(likeIcon_Lumia.snp.trailing).offset(4)
        }
        cardView_Lumia.addSubview(commentIcon_Lumia)
        commentIcon_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(likeLabel_Lumia.snp.trailing).offset(12)
            make.width.height.equalTo(13)
        }
        cardView_Lumia.addSubview(commentLabel_Lumia)
        commentLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(commentIcon_Lumia.snp.trailing).offset(4)
        }
    }

    func configure_Lumia(post: TitleModel_Lumia) {
        thumbView_Lumia.configure_Lumia(mediaPath_Lumia: post.titleMeidas_Lumia.first)
        titleLabel_Lumia.text = post.title_Lumia
        contentLabel_Lumia.text = post.titleContent_Lumia
        likeLabel_Lumia.text = "\(post.likes_Lumia)"
        commentLabel_Lumia.text = "\(post.reviews_Lumia.count)"
    }
}

// MARK: - 未关注引导底部弹窗

/// 未关注时点击聊天的富 UI 底部弹窗
/// 核心作用：展示目标用户信息，引导关注后才能聊天
/// 设计要点：
///   - 所有按钮使用 UIButton(type: .custom) + backgroundColor 实色，
///     避免 iOS 15+ UIButton.Configuration 渲染机制与 CAGradientLayer 冲突导致按钮不可见
///   - 弹窗背景使用浅紫色渐变，整体配色与用户中心页协调
private class FollowFirstSheet_Lumia: UIViewController {

    var onFollowTapped_Lumia: (() -> Void)?
    private let user_Lumia: PrewUserModel_Lumia

    // MARK: - UI 组件

    private let overlayView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v_Lumia
    }()

    private let sheetView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FAFAFE")
        v_Lumia.layer.cornerRadius = 32
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_Lumia
    }()

    private let dragHandle_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#D0C0F0")
        v_Lumia.layer.cornerRadius = 2.5
        return v_Lumia
    }()

    /// 头像外圈（渐变色用 layer.borderColor，不依赖 CAGradientLayer）
    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 44
        v_Lumia.layer.borderWidth = 3
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#8A5CC8").cgColor
        v_Lumia.backgroundColor = .white
        return v_Lumia
    }()

    private let avatarView_Lumia: UserAvatarView_Lumia = {
        let v_Lumia = UserAvatarView_Lumia()
        v_Lumia.layer.cornerRadius = 38
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()

    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A0840")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    /// 提示卡片（浅紫背景）
    private let hintCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F8")
        v_Lumia.layer.cornerRadius = 16
        return v_Lumia
    }()

    private let hintIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "person.badge.plus"))
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#8A5CC8")
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let hintLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#6040A0")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    /// 关注按钮：UIButton(type: .custom) + backgroundColor 实色，彻底规避 CAGradientLayer 不显示问题
    private let followButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Follow to Chat", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#8A5CC8")
        btn_Lumia.layer.cornerRadius = 24
        btn_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#8A5CC8").cgColor
        btn_Lumia.layer.shadowOpacity = 0.35
        btn_Lumia.layer.shadowRadius = 10
        btn_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return btn_Lumia
    }()

    /// 取消按钮：UIButton(type: .custom) + 透明背景
    private let cancelButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Maybe Later", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#9080C0"), for: .normal)
        btn_Lumia.backgroundColor = .clear
        return btn_Lumia
    }()

    // MARK: - 初始化

    init(user: PrewUserModel_Lumia) {
        self.user_Lumia = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        configureData_Lumia()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = .clear

        // 半透明背景遮罩
        view.addSubview(overlayView_Lumia)
        overlayView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        overlayView_Lumia.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleCancel_Lumia))
        )

        // 底部弹窗
        view.addSubview(sheetView_Lumia)
        sheetView_Lumia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(360)
        }
        sheetView_Lumia.transform = CGAffineTransform(translationX: 0, y: 400)

        // 拖动手柄
        sheetView_Lumia.addSubview(dragHandle_Lumia)
        dragHandle_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(5)
        }

        // 头像环 + 头像
        sheetView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(4) }

        // 用户名
        sheetView_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Lumia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        // 提示卡片（图标 + 说明文字）
        sheetView_Lumia.addSubview(hintCard_Lumia)
        hintCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(60)
        }

        hintCard_Lumia.addSubview(hintIcon_Lumia)
        hintIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        hintCard_Lumia.addSubview(hintLabel_Lumia)
        hintLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(hintIcon_Lumia.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        hintLabel_Lumia.textAlignment = .left

        // 关注按钮（实色背景，无 CAGradientLayer）
        sheetView_Lumia.addSubview(followButton_Lumia)
        followButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(hintCard_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        followButton_Lumia.addTarget(self, action: #selector(handleFollow_Lumia), for: .touchUpInside)

        // 取消按钮
        sheetView_Lumia.addSubview(cancelButton_Lumia)
        cancelButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(followButton_Lumia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        cancelButton_Lumia.addTarget(self, action: #selector(handleCancel_Lumia), for: .touchUpInside)
    }

    private func configureData_Lumia() {
        if let uid_Lumia = user_Lumia.userId_Lumia {
            avatarView_Lumia.configure_Lumia(userId_Lumia: uid_Lumia)
        }
        nameLabel_Lumia.text = user_Lumia.userName_Lumia ?? "User"
        hintLabel_Lumia.text = "Follow \(user_Lumia.userName_Lumia ?? "this user") first to send a message"
    }

    // MARK: - 动画

    private func showSheet_Lumia() {
        overlayView_Lumia.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationSpring_Lumia, delay: 0,
            usingSpringWithDamping: AnimationConfig_Lumia.springDampingHeavy_Lumia,
            initialSpringVelocity: AnimationConfig_Lumia.springVelocity_Lumia,
            options: .curveEaseOut
        ) {
            self.sheetView_Lumia.transform = .identity
            self.overlayView_Lumia.alpha = 1
        }
    }

    private func hideSheet_Lumia(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28, animations: {
            self.sheetView_Lumia.transform = CGAffineTransform(translationX: 0, y: 400)
            self.overlayView_Lumia.alpha = 0
        }) { _ in self.dismiss(animated: false, completion: completion) }
    }

    // MARK: - 事件

    @objc private func handleFollow_Lumia() {
        hideSheet_Lumia { [weak self] in self?.onFollowTapped_Lumia?() }
    }

    @objc private func handleCancel_Lumia() { hideSheet_Lumia() }
}

// MARK: - 聊天确认底部弹窗（已关注时使用）

/// 已关注用户后，点击消息按钮弹出的确认弹窗
/// 设计思路：
///   - 弹窗背景 `#FAFAFE`，与 FollowFirstSheet 统一风格
///   - 头像带绿色"在线"角标（表示可以聊天），更有活力
///   - 用户名 + 简介 + 简短的聊天引导提示卡
///   - 确认按钮：UIButton(type: .custom) + 实色背景，彻底避免 iOS 15+ UIButton.Configuration 遮挡渐变层问题
private class ChatConfirmSheet_Lumia: UIViewController {

    var onConfirmed_Lumia: (() -> Void)?
    private let user_Lumia: PrewUserModel_Lumia

    // MARK: - UI 组件

    private let overlayView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v_Lumia
    }()

    private let sheetView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FAFAFE")
        v_Lumia.layer.cornerRadius = 32
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_Lumia
    }()

    private let dragHandle_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#D0C0F0")
        v_Lumia.layer.cornerRadius = 2.5
        return v_Lumia
    }()

    /// 头像外圈（绿色"可聊天"指示）
    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 44
        v_Lumia.layer.borderWidth = 3
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#4CD964").cgColor
        v_Lumia.backgroundColor = .white
        return v_Lumia
    }()

    private let avatarView_Lumia: UserAvatarView_Lumia = {
        let v_Lumia = UserAvatarView_Lumia()
        v_Lumia.layer.cornerRadius = 38
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()

    /// 绿色在线指示点（右下角）
    private let onlineDot_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#4CD964")
        v_Lumia.layer.cornerRadius = 8
        v_Lumia.layer.borderWidth = 2.5
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#FAFAFE").cgColor
        return v_Lumia
    }()

    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A0840")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let introLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8070A0")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    /// 提示卡片（浅玫瑰粉背景）
    private let hintCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FFF0F5")
        v_Lumia.layer.cornerRadius = 16
        return v_Lumia
    }()

    private let hintIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "hand.raised.fill"))
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#E84393")
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let hintLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Be kind and respectful in your conversation"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C03070")
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    /// 确认按钮（UIButton(type:.custom) + 实色，确保 iOS 15+ 可见）
    private let confirmButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Start Chatting", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#8A5CC8")
        btn_Lumia.layer.cornerRadius = 26
        btn_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#8A5CC8").cgColor
        btn_Lumia.layer.shadowOpacity = 0.30
        btn_Lumia.layer.shadowRadius = 10
        btn_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return btn_Lumia
    }()

    /// 取消按钮（UIButton(type:.custom) + 透明背景）
    private let cancelButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Maybe Later", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#9080C0"), for: .normal)
        btn_Lumia.backgroundColor = .clear
        return btn_Lumia
    }()

    // MARK: - 初始化

    init(user: PrewUserModel_Lumia) {
        self.user_Lumia = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        configureData_Lumia()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = .clear

        view.addSubview(overlayView_Lumia)
        overlayView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        overlayView_Lumia.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleCancel_Lumia))
        )

        view.addSubview(sheetView_Lumia)
        sheetView_Lumia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(380)
        }
        sheetView_Lumia.transform = CGAffineTransform(translationX: 0, y: 420)

        // 拖动手柄
        sheetView_Lumia.addSubview(dragHandle_Lumia)
        dragHandle_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(5)
        }

        // 头像环（绿色边框）
        sheetView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(4) }

        // 在线指示点（右下角）
        sheetView_Lumia.addSubview(onlineDot_Lumia)
        onlineDot_Lumia.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRing_Lumia).offset(2)
            make.bottom.equalTo(avatarRing_Lumia).offset(2)
            make.width.height.equalTo(16)
        }

        // 用户名
        sheetView_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Lumia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        // 简介
        sheetView_Lumia.addSubview(introLabel_Lumia)
        introLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        // 提示卡片
        sheetView_Lumia.addSubview(hintCard_Lumia)
        hintCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        hintCard_Lumia.addSubview(hintIcon_Lumia)
        hintIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        hintCard_Lumia.addSubview(hintLabel_Lumia)
        hintLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(hintIcon_Lumia.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        // 确认按钮（实色 + 阴影，无 CAGradientLayer）
        sheetView_Lumia.addSubview(confirmButton_Lumia)
        confirmButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(hintCard_Lumia.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        confirmButton_Lumia.addTarget(self, action: #selector(handleConfirm_Lumia), for: .touchUpInside)

        // 取消按钮
        sheetView_Lumia.addSubview(cancelButton_Lumia)
        cancelButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(confirmButton_Lumia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        cancelButton_Lumia.addTarget(self, action: #selector(handleCancel_Lumia), for: .touchUpInside)
    }

    private func configureData_Lumia() {
        if let uid_Lumia = user_Lumia.userId_Lumia {
            avatarView_Lumia.configure_Lumia(userId_Lumia: uid_Lumia)
        }
        nameLabel_Lumia.text = user_Lumia.userName_Lumia ?? "User"
        let intro_Lumia = user_Lumia.userIntroduce_Lumia ?? ""
        introLabel_Lumia.text = intro_Lumia.isEmpty ? "Film photographer" : intro_Lumia
    }

    // MARK: - 动画

    private func showSheet_Lumia() {
        overlayView_Lumia.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Lumia.durationSpring_Lumia, delay: 0,
            usingSpringWithDamping: AnimationConfig_Lumia.springDampingHeavy_Lumia,
            initialSpringVelocity: AnimationConfig_Lumia.springVelocity_Lumia,
            options: .curveEaseOut
        ) {
            self.sheetView_Lumia.transform = .identity
            self.overlayView_Lumia.alpha = 1
        }
    }

    private func hideSheet_Lumia(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28, animations: {
            self.sheetView_Lumia.transform = CGAffineTransform(translationX: 0, y: 420)
            self.overlayView_Lumia.alpha = 0
        }) { _ in self.dismiss(animated: false, completion: completion) }
    }

    // MARK: - 事件

    @objc private func handleConfirm_Lumia() {
        hideSheet_Lumia { [weak self] in self?.onConfirmed_Lumia?() }
    }

    @objc private func handleCancel_Lumia() { hideSheet_Lumia() }
}
