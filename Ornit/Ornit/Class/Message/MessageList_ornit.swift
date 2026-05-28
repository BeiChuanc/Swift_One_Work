import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面
/// 功能：展示与当前登录用户有聊天记录的所有用户列表，点击进入聊天详情页面
/// 设计：海军蓝渐变 Header（含对话数量气泡）+ 白色卡片列表（带在线状态指示、未读徽标）
class MessageList_Ornit: UIViewController {

    // MARK: - 数据属性

    /// 有聊天记录的用户列表
    private var chatUsers_Ornit: [PrewUserModel_Ornit] = []

    // MARK: - Header 组件

    /// 顶部渐变 Header 容器
    private let headerView_Ornit = UIView()

    /// Header 渐变图层（viewDidLayoutSubviews 中同步 frame）
    private var headerGradient_Ornit: CAGradientLayer?

    /// 主标题标签
    private let titleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Messages"
        label_ornit.font = UIFont.systemFont(ofSize: 32, weight: .black)
        label_ornit.textColor = .white
        return label_ornit
    }()

    /// 副标题标签
    private let subtitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Your conversations"
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.75)
        return label_ornit
    }()

    /// 对话数量气泡容器
    private let statsBubble_Ornit = UIView()

    /// 对话数量标签
    private let statsLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_ornit.textColor = .white
        return label_ornit
    }()

    // MARK: - 内容区组件

    /// 消息用户列表
    private let tableView_Ornit: UITableView = {
        let tv_ornit = UITableView(frame: .zero, style: .plain)
        tv_ornit.backgroundColor = .clear
        tv_ornit.separatorStyle = .none
        tv_ornit.showsVerticalScrollIndicator = false
        tv_ornit.register(
            MessageListCell_Ornit.self,
            forCellReuseIdentifier: MessageListCell_Ornit.reuseId_Ornit
        )
        return tv_ornit
    }()

    /// 空状态视图
    private let emptyView_Ornit = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMessage_Ornit
        setupHeaderView_Ornit()
        setupTableView_Ornit()
        setupEmptyView_Ornit()
        setupNotifications_Ornit()
        loadData_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Ornit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    /// 注册消息状态变更通知，消息收发时刷新列表
    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Ornit),
            name: MessageViewModel_Ornit.messageStateDidChangeNotification_Ornit,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Ornit() {
        loadData_Ornit()
    }

    // MARK: - 数据加载

    /// 从 ViewModel 加载有聊天记录的用户列表并刷新视图
    private func loadData_Ornit() {
        chatUsers_Ornit = MessageViewModel_Ornit.shared_Ornit.getChatUsers_Ornit()
        statsLabel_Ornit.text = "\(chatUsers_Ornit.count) Chats"
        tableView_Ornit.reloadData()

        let hasData_ornit = !chatUsers_Ornit.isEmpty
        emptyView_Ornit.isHidden = hasData_ornit
        tableView_Ornit.isHidden = !hasData_ornit
    }

    // MARK: - UI 搭建

    /// 构建顶部渐变 Header（海军蓝渐变 + 装饰圆 + 消息图标 + 统计气泡）
    private func setupHeaderView_Ornit() {
        view.addSubview(headerView_Ornit)

        // 深海军蓝 → 明亮蓝渐变
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.messageGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.messageGradientEnd_Ornit.cgColor
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

        // 左下角小装饰圆
        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        deco2_ornit.layer.cornerRadius = 44
        headerView_Ornit.addSubview(deco2_ornit)

        // 右下中等装饰圆
        let deco3_ornit = UIView()
        deco3_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco3_ornit.layer.cornerRadius = 50
        headerView_Ornit.addSubview(deco3_ornit)

        headerView_Ornit.addSubview(titleLabel_Ornit)
        headerView_Ornit.addSubview(subtitleLabel_Ornit)

        // 装饰消息图标（半透明）
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        let msgIcon_ornit = UIImageView(
            image: UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: iconConfig_ornit)
        )
        msgIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.15)
        headerView_Ornit.addSubview(msgIcon_ornit)

        // 统计气泡（毛玻璃风格）
        statsBubble_Ornit.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        statsBubble_Ornit.layer.cornerRadius = 14
        statsBubble_Ornit.layer.borderWidth = 1
        statsBubble_Ornit.layer.borderColor = UIColor.white.withValues(alpha: 0.28).cgColor
        headerView_Ornit.addSubview(statsBubble_Ornit)
        statsBubble_Ornit.addSubview(statsLabel_Ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(172)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(52)
            make_ornit.top.equalToSuperview().offset(-30)
            make_ornit.width.height.equalTo(144)
        }

        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-18)
            make_ornit.bottom.equalToSuperview().offset(28)
            make_ornit.width.height.equalTo(88)
        }

        deco3_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-60)
            make_ornit.bottom.equalToSuperview().offset(34)
            make_ornit.width.height.equalTo(100)
        }

        titleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalToSuperview().offset(58)
        }

        subtitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(titleLabel_Ornit.snp.bottom).offset(4)
        }

        msgIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-18)
            make_ornit.centerY.equalTo(titleLabel_Ornit).offset(-2)
            make_ornit.width.height.equalTo(52)
        }

        statsBubble_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(subtitleLabel_Ornit.snp.bottom).offset(10)
            make_ornit.height.equalTo(28)
        }

        statsLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerY.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview().inset(12)
        }
    }

    /// 构建消息用户列表，底部加内边距避免 Tab Bar 遮挡
    private func setupTableView_Ornit() {
        view.addSubview(tableView_Ornit)
        tableView_Ornit.dataSource = self
        tableView_Ornit.delegate = self
        // 底部留出 Tab Bar 高度 + 安全距离
        tableView_Ornit.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        tableView_Ornit.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        tableView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
    }

    /// 构建无聊天记录时的空状态视图
    private func setupEmptyView_Ornit() {
        emptyView_Ornit.isHidden = true
        view.addSubview(emptyView_Ornit)

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.35)
        emptyView_Ornit.addSubview(iconView_ornit)

        let emptyTitle_ornit = UILabel()
        emptyTitle_ornit.text = "No messages yet"
        emptyTitle_ornit.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        emptyTitle_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        emptyTitle_ornit.textAlignment = .center
        emptyView_Ornit.addSubview(emptyTitle_ornit)

        let emptyHint_ornit = UILabel()
        emptyHint_ornit.text = "Follow someone to start chatting"
        emptyHint_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        emptyHint_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        emptyHint_ornit.textAlignment = .center
        emptyView_Ornit.addSubview(emptyHint_ornit)

        emptyView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.equalTo(260)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.centerX.equalToSuperview()
            make_ornit.width.height.equalTo(72)
        }

        emptyTitle_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(iconView_ornit.snp.bottom).offset(18)
            make_ornit.centerX.equalToSuperview()
        }

        emptyHint_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(emptyTitle_ornit.snp.bottom).offset(8)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Ornit: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Ornit.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_ornit = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Ornit.reuseId_Ornit,
            for: indexPath
        ) as! MessageListCell_Ornit
        cell_ornit.configure_Ornit(user_ornit: chatUsers_Ornit[indexPath.row])
        return cell_ornit
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Ornit.toMessageUser_Ornit(with: chatUsers_Ornit[indexPath.row])
    }
}

// MARK: - 消息列表 Cell

/// 消息列表联系人卡片 Cell
/// 功能：展示用户头像（含在线指示点）、昵称、最新消息预览、时间戳、未读数徽标
/// 设计：白色圆角卡片 + 蓝色调阴影，视觉层次清晰
class MessageListCell_Ornit: UITableViewCell {

    static let reuseId_Ornit = "MessageListCell_Ornit"

    // MARK: - UI 组件

    /// 白色卡片容器
    private let cardView_Ornit = UIView()

    /// 用户头像
    private let avatarView_Ornit = UserAvatarView_Ornit()

    /// 在线状态指示点（绿色小圆点，头像右下角）
    private let onlineDot_Ornit: UIView = {
        let v_ornit = UIView()
        v_ornit.backgroundColor = UIColor(hexstring_Ornit: "#22C55E")
        v_ornit.layer.cornerRadius = 5
        v_ornit.layer.borderWidth = 2
        v_ornit.layer.borderColor = UIColor.white.cgColor
        return v_ornit
    }()

    /// 用户昵称
    private let nameLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        return label_ornit
    }()

    /// 最新消息预览
    private let lastMessageLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        label_ornit.numberOfLines = 1
        return label_ornit
    }()

    /// 消息时间戳
    private let timeLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .right
        return label_ornit
    }()

    /// 右侧导航箭头图标
    private let chevronIcon_Ornit: UIImageView = {
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let iv_ornit = UIImageView(
            image: UIImage(systemName: "chevron.right", withConfiguration: config_ornit)
        )
        iv_ornit.tintColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.4)
        iv_ornit.contentMode = .scaleAspectFit
        return iv_ornit
    }()

    /// 未读消息数徽标
    private let badgeView_Ornit: UIView = {
        let v_ornit = UIView()
        v_ornit.backgroundColor = ColorConfig_Ornit.messageAccent_Ornit
        v_ornit.layer.cornerRadius = 9
        v_ornit.isHidden = true
        return v_ornit
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Ornit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 搭建

    private func setupUI_Ornit() {
        backgroundColor = .clear
        selectionStyle = .none

        // 卡片：白色背景 + 蓝色调阴影
        cardView_Ornit.backgroundColor = .white
        cardView_Ornit.layer.cornerRadius = 18
        cardView_Ornit.layer.shadowColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.1).cgColor
        cardView_Ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView_Ornit.layer.shadowOpacity = 1
        cardView_Ornit.layer.shadowRadius = 8
        contentView.addSubview(cardView_Ornit)

        cardView_Ornit.addSubview(avatarView_Ornit)
        cardView_Ornit.addSubview(onlineDot_Ornit)
        cardView_Ornit.addSubview(nameLabel_Ornit)
        cardView_Ornit.addSubview(lastMessageLabel_Ornit)
        cardView_Ornit.addSubview(timeLabel_Ornit)
        cardView_Ornit.addSubview(chevronIcon_Ornit)
        cardView_Ornit.addSubview(badgeView_Ornit)

        cardView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(5)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-5)
        }

        avatarView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(50)
        }

        // 在线指示点固定在头像右下角
        onlineDot_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalTo(avatarView_Ornit.snp.trailing).offset(1)
            make_ornit.bottom.equalTo(avatarView_Ornit.snp.bottom).offset(1)
            make_ornit.width.height.equalTo(10)
        }

        timeLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalTo(chevronIcon_Ornit.snp.leading).offset(-6)
            make_ornit.top.equalToSuperview().offset(18)
            make_ornit.width.lessThanOrEqualTo(70)
        }

        chevronIcon_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(14)
        }

        nameLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatarView_Ornit.snp.trailing).offset(12)
            make_ornit.top.equalToSuperview().offset(17)
            make_ornit.trailing.equalTo(timeLabel_Ornit.snp.leading).offset(-6)
        }

        lastMessageLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatarView_Ornit.snp.trailing).offset(12)
            make_ornit.top.equalTo(nameLabel_Ornit.snp.bottom).offset(5)
            make_ornit.trailing.equalTo(chevronIcon_Ornit.snp.leading).offset(-8)
        }

        badgeView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalTo(chevronIcon_Ornit.snp.leading).offset(-6)
            make_ornit.bottom.equalToSuperview().offset(-18)
            make_ornit.width.height.equalTo(18)
        }
    }

    // MARK: - 数据配置

    /// 配置 Cell 显示内容
    /// - Parameter user_ornit: 联系人用户模型
    func configure_Ornit(user_ornit: PrewUserModel_Ornit) {
        guard let uid_ornit = user_ornit.userId_Ornit else { return }

        avatarView_Ornit.configure_Ornit(userId_Ornit: uid_ornit)
        nameLabel_Ornit.text = user_ornit.userName_Ornit ?? "User"

        if let lastMsg_ornit = MessageViewModel_Ornit.shared_Ornit.getLastMessageWithUser_Ornit(userId_ornit: uid_ornit) {
            lastMessageLabel_Ornit.text = lastMsg_ornit.content_Ornit ?? ""
            timeLabel_Ornit.text = lastMsg_ornit.time_Ornit ?? ""
        } else {
            lastMessageLabel_Ornit.text = "Say hello! 👋"
            timeLabel_Ornit.text = ""
        }
    }
}
