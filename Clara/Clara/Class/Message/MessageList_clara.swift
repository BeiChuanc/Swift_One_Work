import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面

/// 消息列表页面
/// 核心功能：响应式展示与当前登录用户存在聊天记录的所有用户
/// 设计思路：顶部渐变 Banner（含会话图标）→ 卡片式 TableView；
///           Cell 展示渐变光环头像、在线指示点、用户名、消息预览、时间、未读角标
/// 关键方法：
/// - refreshChatUsers_Clara: 从 MessageViewModel 拉取有聊天记录的用户并刷新列表
class MessageList_Clara: UIViewController {

    // MARK: - UI 组件

    /// 顶部渐变 Banner
    private let bannerView_Clara = UIView()

    /// Banner 渐变图层
    private var bannerGl_Clara: CAGradientLayer?

    /// 聊天用户列表
    private let tableView_Clara: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(ChatUserCell_Clara.self, forCellReuseIdentifier: ChatUserCell_Clara.reuseId_Clara)
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        return tv
    }()

    /// 空状态视图
    private let emptyView_Clara: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 数据

    /// 当前展示的聊天用户列表
    private var chatUsers_Clara: [PrewUserModel_Clara] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 完全隐藏导航栏，与 Home/Me 保持一致，使用自定义返回按钮
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshChatUsers_Clara()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupBackButton_Clara()
        setupBanner_Clara()
        setupTableView_Clara()
        setupEmptyView_Clara()
        setupNotifications_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gl = bannerGl_Clara {
            gl.frame = bannerView_Clara.bounds
        } else if bannerView_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: bannerView_Clara.bounds)
            bannerView_Clara.layer.insertSublayer(gl, at: 0)
            bannerGl_Clara = gl
        }
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - 自定义返回按钮

    /// 添加悬浮于渐变 Banner 之上的自定义返回按钮
    private func setupBackButton_Clara() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        btn.addTarget(self, action: #selector(backTapped_Clara), for: .touchUpInside)
    }

    // MARK: - UI 搭建

    /// 顶部渐变 Banner（含丰富标题区：主副标题 + 功能标签行 + 装饰圆圈 + 会话图标）
    private func setupBanner_Clara() {
        view.addSubview(bannerView_Clara)
        bannerView_Clara.layer.cornerRadius = 28
        bannerView_Clara.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bannerView_Clara.clipsToBounds = true
        // 高度覆盖安全区 + 88pt 内容区（标题 + 副标题两行）
        bannerView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(88)
        }

        // 大装饰圆（右上角）
        let bigCircle = UIView()
        bigCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        bigCircle.layer.cornerRadius = 55
        bannerView_Clara.addSubview(bigCircle)
        bigCircle.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.right.equalToSuperview().inset(-24)
            make.top.equalToSuperview().inset(-22)
        }

        // 小装饰圆（左下）
        let smallCircle = UIView()
        smallCircle.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        smallCircle.layer.cornerRadius = 34
        bannerView_Clara.addSubview(smallCircle)
        smallCircle.snp.makeConstraints { make in
            make.width.height.equalTo(68)
            make.left.equalToSuperview().inset(-18)
            make.bottom.equalToSuperview().inset(-20)
        }

        // 会话主图标（右侧装饰）
        let chatIconView = UIImageView()
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        chatIconView.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: iconCfg)
        chatIconView.tintColor = UIColor.white.withAlphaComponent(0.65)
        bannerView_Clara.addSubview(chatIconView)
        chatIconView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.width.height.equalTo(28)
        }

        // ── 主标题
        let titleLabel = UILabel()
        titleLabel.text = "Messages"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = .white
        bannerView_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(72)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }

        // ── 副标题描述
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Connect with the people who matter"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.80)
        bannerView_Clara.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
    }

    // 占位方法（保留签名避免编译报错，实际已移除 Chip 标签行）
    private func makeBannerChip_Clara(icon: String, text: String) -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        chip.layer.cornerRadius = 13
        chip.layer.borderWidth = 0.5
        chip.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor

        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
        iv.image = UIImage(systemName: icon, withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit

        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = .white

        chip.addSubview(iv)
        chip.addSubview(lbl)
        iv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        lbl.snp.makeConstraints { make in
            make.left.equalTo(iv.snp.right).offset(5)
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        return chip
    }

    private func setupTableView_Clara() {
        view.addSubview(tableView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        tableView_Clara.backgroundColor = .clear
        tableView_Clara.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Clara.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        tableView_Clara.delegate = self
        tableView_Clara.dataSource = self
    }

    /// 空状态视图（带图标背景圆圈）
    private func setupEmptyView_Clara() {
        view.addSubview(emptyView_Clara)
        emptyView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(240)
        }

        let bgCircle = UIView()
        bgCircle.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.08)
        bgCircle.layer.cornerRadius = 50
        emptyView_Clara.addSubview(bgCircle)
        bgCircle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(100)
        }

        let icon = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        icon.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg)
        icon.tintColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.5)
        icon.contentMode = .scaleAspectFit
        bgCircle.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }

        let titleLbl = UILabel()
        titleLbl.text = "No Conversations Yet"
        titleLbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLbl.textAlignment = .center

        let subtitleLbl = UILabel()
        subtitleLbl.text = "Follow someone and start a chat to see it here"
        subtitleLbl.font = UIFont.systemFont(ofSize: 13)
        subtitleLbl.textColor = ColorConfig_Clara.textSecondary_Clara
        subtitleLbl.textAlignment = .center
        subtitleLbl.numberOfLines = 2

        emptyView_Clara.addSubview(titleLbl)
        emptyView_Clara.addSubview(subtitleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(bgCircle.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        subtitleLbl.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据刷新

    /// 从 MessageViewModel 刷新有聊天记录的用户列表
    private func refreshChatUsers_Clara() {
        chatUsers_Clara = MessageViewModel_Clara.shared_Clara.getChatUsers_Clara()
        updateEmptyState_Clara()
        tableView_Clara.reloadData()
    }

    /// 更新空状态视图显隐
    private func updateEmptyState_Clara() {
        let isEmpty = chatUsers_Clara.isEmpty
        emptyView_Clara.isHidden = !isEmpty
        tableView_Clara.isHidden = isEmpty
    }

    // MARK: - 通知

    private func setupNotifications_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Clara),
            name: MessageViewModel_Clara.messageStateDidChangeNotification_Clara,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Clara),
            name: UserViewModel_Clara.userStateDidChangeNotification_Clara,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Clara() {
        refreshChatUsers_Clara()
    }

    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableView 代理

extension MessageList_Clara: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Clara.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatUserCell_Clara.reuseId_Clara,
            for: indexPath
        ) as! ChatUserCell_Clara
        let user = chatUsers_Clara[indexPath.row]
        let lastMsg = MessageViewModel_Clara.shared_Clara.getLastMessageWithUser_Clara(
            userId_clara: user.userId_Clara ?? 0
        )
        cell.configure_Clara(user_Clara: user, lastMessage_Clara: lastMsg)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = chatUsers_Clara[indexPath.row]
        Navigation_Clara.toMessageUser_Clara(with: user)
    }
}

// MARK: - 聊天用户 Cell

/// 消息列表用户行单元格
/// 功能：展示渐变光环头像、在线指示点、用户名、最后一条消息预览、时间和未读消息角标
class ChatUserCell_Clara: UITableViewCell {

    static let reuseId_Clara = "ChatUserCell_Clara"

    // MARK: - UI

    /// 外层卡片
    private let cardView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 18
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        return v
    }()

    /// 头像渐变光环容器
    private let avatarRing_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 30
        return v
    }()

    /// 头像光环渐变图层
    private var avatarRingGl_Clara: CAGradientLayer?

    /// 头像视图
    private let avatarView_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 在线状态指示点
    private let onlineDot_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGreen
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户名标签
    private let nameLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l.textColor = ColorConfig_Clara.textPrimary_Clara
        return l
    }()

    /// 最后一条消息预览
    private let lastMsgLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        l.numberOfLines = 1
        return l
    }()

    /// 时间标签
    private let timeLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        l.textAlignment = .right
        return l
    }()

    /// 未读消息角标容器
    private let unreadBadge_Clara: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 9
        v.isHidden = true
        return v
    }()

    /// 未读角标渐变图层
    private var unreadBadgeGl_Clara: CAGradientLayer?

    /// 未读消息数字
    private let unreadCount_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Clara()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 延迟设置渐变（等布局稳定后）
        if avatarRingGl_Clara == nil && avatarRing_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: avatarRing_Clara.bounds)
            gl.cornerRadius = 30
            avatarRing_Clara.layer.insertSublayer(gl, at: 0)
            avatarRingGl_Clara = gl
        }
        if unreadBadgeGl_Clara == nil && !unreadBadge_Clara.isHidden && unreadBadge_Clara.bounds.width > 0 {
            let gl = UIColor.createSecondaryGradientLayer_Clara(frame_Clara: unreadBadge_Clara.bounds)
            gl.cornerRadius = 9
            unreadBadge_Clara.layer.insertSublayer(gl, at: 0)
            unreadBadgeGl_Clara = gl
        }
    }

    private func setupUI_Clara() {
        contentView.addSubview(cardView_Clara)
        cardView_Clara.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview().inset(16)
        }

        // 头像光环
        cardView_Clara.addSubview(avatarRing_Clara)
        avatarRing_Clara.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        // 头像（比光环小 10pt，留出光环宽度）
        cardView_Clara.addSubview(avatarView_Clara)
        avatarView_Clara.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Clara)
            make.width.height.equalTo(50)
        }

        // 在线指示点
        cardView_Clara.addSubview(onlineDot_Clara)
        onlineDot_Clara.snp.makeConstraints { make in
            make.right.equalTo(avatarView_Clara.snp.right).offset(1)
            make.bottom.equalTo(avatarView_Clara.snp.bottom).offset(1)
            make.width.height.equalTo(12)
        }

        // 时间（右上角）
        cardView_Clara.addSubview(timeLabel_Clara)
        timeLabel_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(14)
            make.top.equalToSuperview().offset(17)
            make.width.equalTo(52)
        }

        // 用户名
        cardView_Clara.addSubview(nameLabel_Clara)
        nameLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(avatarRing_Clara.snp.right).offset(12)
            make.right.equalTo(timeLabel_Clara.snp.left).offset(-8)
            make.top.equalToSuperview().offset(17)
        }

        // 最后消息预览
        cardView_Clara.addSubview(lastMsgLabel_Clara)
        lastMsgLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_Clara.snp.left)
            make.right.equalToSuperview().inset(46)
            make.top.equalTo(nameLabel_Clara.snp.bottom).offset(5)
        }

        // 未读角标
        cardView_Clara.addSubview(unreadBadge_Clara)
        unreadBadge_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(14)
            make.centerY.equalTo(lastMsgLabel_Clara)
            make.width.height.equalTo(18)
        }
        unreadBadge_Clara.addSubview(unreadCount_Clara)
        unreadCount_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    /// 配置单元格内容
    /// - Parameters:
    ///   - user_Clara: 聊天对象用户模型
    ///   - lastMessage_Clara: 最后一条消息（nil 时显示默认问候语）
    func configure_Clara(user_Clara: PrewUserModel_Clara, lastMessage_Clara: MessageModel_Clara?) {
        guard let uid = user_Clara.userId_Clara else { return }
        avatarView_Clara.configure_Clara(userId_Clara: uid)
        nameLabel_Clara.text = user_Clara.userName_Clara ?? "User"
        lastMsgLabel_Clara.text = lastMessage_Clara?.content_Clara ?? "Say hello 👋"
        timeLabel_Clara.text = lastMessage_Clara?.time_Clara ?? ""

        // 随机在线状态（预制数据无真实在线状态）
        onlineDot_Clara.backgroundColor = Bool.random() ? .systemGreen : .systemGray4

        // 随机未读角标（预制数据）
        let hasUnread = Bool.random()
        unreadBadge_Clara.isHidden = !hasUnread
        if hasUnread {
            unreadCount_Clara.text = "\(Int.random(in: 1...9))"
        }
    }
}
