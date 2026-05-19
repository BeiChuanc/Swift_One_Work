import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面

/// 消息列表视图控制器
/// 核心作用：展示所有与当前登录用户存在聊天记录的会话列表
/// 设计思路：
///   - 顶栏：玫瑰粉→珊瑚红渐变 + 大标题 + 统计胶囊 + 多个装饰气泡，视觉层次丰富
///   - 列表区域：浅粉背景 + 卡片式会话行（渐变卡背景 + 渐变头像环 + 简介文字 + 在线点 + 未读徽章）
///   - 空状态：中央大图标 + 粉色标题 + 引导文案
/// 关键属性：
///   - chatUsers_Lumia: 有聊天记录的用户数据
class MessageList_Lumia: UIViewController {

    // MARK: - 私有属性

    private var chatUsers_Lumia: [PrewUserModel_Lumia] = []

    // MARK: - UI组件

    private let topBar_Lumia = UIView()
    private var topGradient_Lumia: CAGradientLayer?

    /// chat.bubble 图标（白色）
    private let bubbleIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iv_Lumia.tintColor = UIColor.white.withAlphaComponent(0.90)
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    /// 页面主标题
    private let pageTitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Messages"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    /// 会话数量副标题
    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.75)
        return lbl_Lumia
    }()

    /// 会话总数徽章（白色胶囊）
    private let countBadge_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v_Lumia.layer.cornerRadius = 12
        v_Lumia.layer.borderWidth = 1
        v_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.40).cgColor
        return v_Lumia
    }()

    private let countBadgeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Lumia.textColor = .white
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    /// 列表视图（浅粉背景）
    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.separatorStyle = .none
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FFF0F5")
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return tv_Lumia
    }()

    private let emptyView_Lumia = UIView()

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradient_Lumia?.frame = topBar_Lumia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#FFF0F5")
        setupTopBar_Lumia()
        setupTableView_Lumia()
        setupEmptyView_Lumia()
    }

    /// 配置顶部渐变栏
    /// 玫瑰粉→珊瑚红渐变，底部圆角 24，含装饰气泡、图标、标题、计数徽章
    private func setupTopBar_Lumia() {
        view.addSubview(topBar_Lumia)
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        topBar_Lumia.clipsToBounds = true

        // 渐变背景
        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F093FB").cgColor,
            UIColor(hexstring_Lumia: "#F5576C").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        topBar_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        topBar_Lumia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topBar_Lumia.layer.cornerRadius = 28
        topGradient_Lumia = gradient_Lumia

        // 装饰气泡 1：右上大圆
        let bubble1_Lumia = makeDecoBubble_Lumia(size: 100, alpha: 0.10)
        topBar_Lumia.addSubview(bubble1_Lumia)
        bubble1_Lumia.frame = CGRect(x: UIScreen.main.bounds.width - 60, y: -30, width: 100, height: 100)

        // 装饰气泡 2：右侧中圆
        let bubble2_Lumia = makeDecoBubble_Lumia(size: 66, alpha: 0.13)
        topBar_Lumia.addSubview(bubble2_Lumia)
        bubble2_Lumia.frame = CGRect(x: UIScreen.main.bounds.width - 90, y: 50, width: 66, height: 66)

        // 装饰气泡 3：中右小圆
        let bubble3_Lumia = makeDecoBubble_Lumia(size: 40, alpha: 0.09)
        topBar_Lumia.addSubview(bubble3_Lumia)
        bubble3_Lumia.frame = CGRect(x: UIScreen.main.bounds.width - 160, y: 20, width: 40, height: 40)

        // 气泡图标 + 标题（同行）
        topBar_Lumia.addSubview(bubbleIcon_Lumia)
        bubbleIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.width.height.equalTo(26)
        }

        topBar_Lumia.addSubview(pageTitleLabel_Lumia)
        pageTitleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(bubbleIcon_Lumia)
            make.leading.equalTo(bubbleIcon_Lumia.snp.trailing).offset(8)
        }

        // 会话计数徽章（标题右侧）
        topBar_Lumia.addSubview(countBadge_Lumia)
        countBadge_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(pageTitleLabel_Lumia)
            make.leading.equalTo(pageTitleLabel_Lumia.snp.trailing).offset(10)
            make.height.equalTo(24)
        }
        countBadge_Lumia.addSubview(countBadgeLabel_Lumia)
        countBadgeLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }

        // 副标题
        topBar_Lumia.addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(bubbleIcon_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(bubbleIcon_Lumia)
        }
    }

    /// 创建装饰气泡（半透明白色圆形）
    private func makeDecoBubble_Lumia(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Lumia.layer.cornerRadius = size / 2
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }

    /// 配置列表视图及段头
    private func setupTableView_Lumia() {
        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(
            MessageListCell_Lumia.self,
            forCellReuseIdentifier: MessageListCell_Lumia.reuseId_Lumia
        )

        // 自定义段头
        let header_Lumia = buildSectionHeader_Lumia()
        tableView_Lumia.tableHeaderView = header_Lumia
    }

    /// 构建段头视图（"Recent Chats" 标题 + 粉色装饰线）
    private func buildSectionHeader_Lumia() -> UIView {
        let container_Lumia = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        container_Lumia.backgroundColor = .clear

        let label_Lumia = UILabel()
        label_Lumia.text = "Recent Chats"
        label_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Lumia.textColor = UIColor(hexstring_Lumia: "#D0336A")
        container_Lumia.addSubview(label_Lumia)
        label_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        // 小装饰圆点
        let dot_Lumia = UIView()
        dot_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F093FB")
        dot_Lumia.layer.cornerRadius = 3
        container_Lumia.addSubview(dot_Lumia)
        dot_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(label_Lumia.snp.trailing).offset(6)
            make.centerY.equalTo(label_Lumia)
            make.width.height.equalTo(6)
        }

        return container_Lumia
    }

    /// 配置空状态视图
    private func setupEmptyView_Lumia() {
        view.addSubview(emptyView_Lumia)
        emptyView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }
        emptyView_Lumia.isHidden = true

        let iconBg_Lumia = UIView()
        iconBg_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F5576C", alpha_Lumia: 0.08)
        iconBg_Lumia.layer.cornerRadius = 44
        emptyView_Lumia.addSubview(iconBg_Lumia)
        iconBg_Lumia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }

        let iconView_Lumia = UIImageView()
        iconView_Lumia.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iconView_Lumia.tintColor = UIColor(hexstring_Lumia: "#F5576C", alpha_Lumia: 0.50)
        iconView_Lumia.contentMode = .scaleAspectFit
        iconBg_Lumia.addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        let emptyLabel_Lumia = UILabel()
        emptyLabel_Lumia.text = "No messages yet"
        emptyLabel_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        emptyLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#C0305A")
        emptyLabel_Lumia.textAlignment = .center
        emptyView_Lumia.addSubview(emptyLabel_Lumia)
        emptyLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Lumia.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        let hintLabel_Lumia = UILabel()
        hintLabel_Lumia.text = "Follow a user and start chatting!"
        hintLabel_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        hintLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#F093FB", alpha_Lumia: 0.85)
        hintLabel_Lumia.textAlignment = .center
        emptyView_Lumia.addSubview(hintLabel_Lumia)
        hintLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 加载聊天用户列表并刷新顶栏统计、列表
    private func loadData_Lumia() {
        if UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia {
            chatUsers_Lumia = MessageViewModel_Lumia.shared_Lumia.getChatUsers_Lumia()
            let count_Lumia = chatUsers_Lumia.count
            subtitleLabel_Lumia.text = "\(count_Lumia) conversation\(count_Lumia == 1 ? "" : "s")"
            countBadgeLabel_Lumia.text = "\(count_Lumia)"
        } else {
            chatUsers_Lumia = []
            subtitleLabel_Lumia.text = "Login to view messages"
            countBadgeLabel_Lumia.text = "0"
        }
        tableView_Lumia.reloadData()
        emptyView_Lumia.isHidden = !chatUsers_Lumia.isEmpty
        tableView_Lumia.isHidden = chatUsers_Lumia.isEmpty
    }

    // MARK: - 通知监听

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMessageChange_Lumia),
            name: MessageViewModel_Lumia.messageStateDidChangeNotification_Lumia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleMessageChange_Lumia() { loadData_Lumia() }
    @objc private func handleUserChange_Lumia() { loadData_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITableViewDelegate & DataSource

extension MessageList_Lumia: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Lumia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! MessageListCell_Lumia
        let user_Lumia = chatUsers_Lumia[indexPath.row]
        let lastMsg_Lumia = MessageViewModel_Lumia.shared_Lumia.getLastMessageWithUser_Lumia(
            userId_lumia: user_Lumia.userId_Lumia ?? 0
        )
        cell_Lumia.configure_Lumia(user: user_Lumia, lastMessage: lastMsg_Lumia)
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Lumia.toMessageUser_Lumia(with: chatUsers_Lumia[indexPath.row])
    }

    /// 左滑删除会话
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction_Lumia = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion_Lumia in
            guard let self = self else { completion_Lumia(false); return }
            if let uid_Lumia = self.chatUsers_Lumia[indexPath.row].userId_Lumia {
                Task { @MainActor in
                    MessageViewModel_Lumia.shared_Lumia.deleteUserMessages_Lumia(userId_lumia: uid_Lumia)
                }
            }
            completion_Lumia(true)
        }
        deleteAction_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F5576C")
        deleteAction_Lumia.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction_Lumia])
    }
}

// MARK: - 消息列表 Cell

/// 消息列表会话卡片 Cell
/// 核心作用：展示单条会话，含渐变卡背景、大号头像环、在线状态点、简介摘要、未读数字徽章
/// 设计思路：
///   - 卡片背景：白色→极浅粉渐变，区别于纯白卡片
///   - 头像区：62pt 渐变边框环 + 右下角在线绿点
///   - 文字区：用户名（粗）+ 个人简介（细，一行）+ 最后消息（灰，一行）
///   - 右侧：时间（顶部）+ 未读数字胶囊徽章（底部）
///   - 底部：极细渐变分隔线
private class MessageListCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "MessageListCell_Lumia"

    // MARK: - UI 组件

    /// 卡片容器（渐变背景 + 粉调阴影）
    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#F5576C").cgColor
        v_Lumia.layer.shadowOpacity = 0.12
        v_Lumia.layer.shadowRadius = 14
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 5)
        v_Lumia.clipsToBounds = false
        return v_Lumia
    }()

    /// 卡片渐变背景（白→极浅粉）
    private let cardBgView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()
    private var cardBgGradient_Lumia: CAGradientLayer?

    /// 底部分隔渐变线
    private let separatorLine_Lumia = UIView()
    private var separatorGradient_Lumia: CAGradientLayer?

    /// 头像外层渐变环（62pt）
    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 31
        return v_Lumia
    }()
    private var ringGradient_Lumia: CAGradientLayer?

    /// 头像视图
    private let avatarView_Lumia = UserAvatarView_Lumia()

    /// 在线状态绿点（头像右下角）
    private let onlineDot_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#4CD964")
        v_Lumia.layer.cornerRadius = 6
        v_Lumia.layer.borderWidth = 2
        v_Lumia.layer.borderColor = UIColor.white.cgColor
        return v_Lumia
    }()

    /// 用户名
    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1020")
        return lbl_Lumia
    }()

    /// 个人简介摘要（一行）
    private let introLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11.5, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C070A0")
        lbl_Lumia.numberOfLines = 1
        return lbl_Lumia
    }()

    /// 最后一条消息预览
    private let lastMsgLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A08090")
        lbl_Lumia.numberOfLines = 1
        return lbl_Lumia
    }()

    /// 消息时间（右上）
    private let timeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C8A0B8")
        lbl_Lumia.textAlignment = .right
        return lbl_Lumia
    }()

    /// 未读数字胶囊徽章（右下）
    private let unreadBadge_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 10
        v_Lumia.isHidden = true
        return v_Lumia
    }()
    private var badgeGradient_Lumia: CAGradientLayer?

    private let unreadCountLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Lumia.textColor = .white
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardBgGradient_Lumia?.frame = cardBgView_Lumia.bounds
        ringGradient_Lumia?.frame = avatarRing_Lumia.bounds
        badgeGradient_Lumia?.frame = unreadBadge_Lumia.bounds
        separatorGradient_Lumia?.frame = separatorLine_Lumia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        // ── 卡片容器 ──
        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }

        // 卡片渐变背景（白→极浅粉）
        cardView_Lumia.addSubview(cardBgView_Lumia)
        cardBgView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        let bgGrad_Lumia = CAGradientLayer()
        bgGrad_Lumia.colors = [
            UIColor.white.cgColor,
            UIColor(hexstring_Lumia: "#FFF0F5").cgColor
        ]
        bgGrad_Lumia.startPoint = CGPoint(x: 0, y: 0)
        bgGrad_Lumia.endPoint = CGPoint(x: 1, y: 1)
        bgGrad_Lumia.cornerRadius = 20
        cardBgView_Lumia.layer.insertSublayer(bgGrad_Lumia, at: 0)
        cardBgGradient_Lumia = bgGrad_Lumia

        // ── 头像渐变环 ──
        cardBgView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(62)
        }
        let ringGrad_Lumia = CAGradientLayer()
        ringGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F093FB").cgColor,
            UIColor(hexstring_Lumia: "#F5576C").cgColor,
            UIColor(hexstring_Lumia: "#FED7AA").cgColor
        ]
        ringGrad_Lumia.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Lumia.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Lumia.cornerRadius = 31
        avatarRing_Lumia.layer.insertSublayer(ringGrad_Lumia, at: 0)
        ringGradient_Lumia = ringGrad_Lumia

        // 头像（内缩 3pt 留出环宽）
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(3) }
        avatarView_Lumia.layer.cornerRadius = 28
        avatarView_Lumia.clipsToBounds = true

        // 在线绿点（头像右下角）
        cardBgView_Lumia.addSubview(onlineDot_Lumia)
        onlineDot_Lumia.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRing_Lumia).offset(1)
            make.bottom.equalTo(avatarRing_Lumia).offset(1)
            make.width.height.equalTo(12)
        }

        // ── 右侧：时间 ──
        cardBgView_Lumia.addSubview(timeLabel_Lumia)
        timeLabel_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(70)
        }

        // ── 未读数字徽章（右下，渐变胶囊）──
        cardBgView_Lumia.addSubview(unreadBadge_Lumia)
        unreadBadge_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(20)
        }
        unreadBadge_Lumia.addSubview(unreadCountLabel_Lumia)
        unreadCountLabel_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
        }
        let badgeGrad_Lumia = CAGradientLayer()
        badgeGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F093FB").cgColor,
            UIColor(hexstring_Lumia: "#F5576C").cgColor
        ]
        badgeGrad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        badgeGrad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        badgeGrad_Lumia.cornerRadius = 10
        unreadBadge_Lumia.layer.insertSublayer(badgeGrad_Lumia, at: 0)
        badgeGradient_Lumia = badgeGrad_Lumia

        // ── 文字区：用户名 ──
        cardBgView_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(avatarRing_Lumia.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel_Lumia.snp.leading).offset(-8)
        }

        // 简介摘要
        cardBgView_Lumia.addSubview(introLabel_Lumia)
        introLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Lumia)
            make.trailing.equalTo(timeLabel_Lumia.snp.leading).offset(-8)
        }

        // 消息预览
        cardBgView_Lumia.addSubview(lastMsgLabel_Lumia)
        lastMsgLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Lumia)
            make.trailing.equalTo(unreadBadge_Lumia.snp.leading).offset(-8)
        }

        // ── 底部极细渐变分隔线 ──
        cardBgView_Lumia.addSubview(separatorLine_Lumia)
        separatorLine_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(avatarRing_Lumia.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        let sepGrad_Lumia = CAGradientLayer()
        sepGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F093FB", alpha_Lumia: 0.30).cgColor,
            UIColor(hexstring_Lumia: "#F5576C", alpha_Lumia: 0.10).cgColor
        ]
        sepGrad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        sepGrad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        separatorLine_Lumia.layer.insertSublayer(sepGrad_Lumia, at: 0)
        separatorGradient_Lumia = sepGrad_Lumia
    }

    // MARK: - 数据绑定

    /// 配置 Cell 数据
    /// - Parameters:
    ///   - user: 聊天对象用户模型
    ///   - lastMessage: 最后一条消息（nil 则展示占位文字并隐藏徽章）
    func configure_Lumia(user: PrewUserModel_Lumia, lastMessage: MessageModel_Lumia?) {
        if let uid_Lumia = user.userId_Lumia {
            avatarView_Lumia.configure_Lumia(userId_Lumia: uid_Lumia)
        }
        nameLabel_Lumia.text = user.userName_Lumia ?? "User"
        // 展示用户简介（取前30字符）
        let intro_Lumia = user.userIntroduce_Lumia ?? ""
        introLabel_Lumia.text = intro_Lumia.isEmpty ? "Film photographer" : intro_Lumia

        if let msg_Lumia = lastMessage {
            lastMsgLabel_Lumia.text = msg_Lumia.content_Lumia ?? ""
            timeLabel_Lumia.text = msg_Lumia.time_Lumia ?? ""
            unreadBadge_Lumia.isHidden = false
            unreadCountLabel_Lumia.text = "1"
        } else {
            lastMsgLabel_Lumia.text = "Tap to start chatting"
            timeLabel_Lumia.text = ""
            unreadBadge_Lumia.isHidden = true
        }
    }
}
