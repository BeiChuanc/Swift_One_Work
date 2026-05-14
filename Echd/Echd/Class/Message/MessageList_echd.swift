import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面
// 设计思路：
//   顶部采用与 Discover/Release 统一的深紫-靛蓝渐变 Header（含圆弧底部）；
//   Header 下方增加"活跃联系人"横向头像条，快速定位最近聊天用户；
//   主列表使用卡片式 Cell：头像带彩色渐变环、左侧 accent 竖条区分层次、
//   未读气泡、消息预览、相对时间显示；
//   整体色调与 Discover/Release 保持一致（深紫-靛蓝主色系）。
// 关键属性：
//   chatUsers_Echd        — 有聊天记录的用户列表
//   activeStripAccents    — 活跃条头像环颜色循环数组

/// 消息列表页视图控制器
class MessageList_Echd: UIViewController {

    // MARK: - UI组件 / Header

    /// 顶部渐变 Header 容器
    private let headerContainer_Echd = UIView()

    /// Header 渐变图层
    private var headerGradient_Echd: CAGradientLayer?

    /// 页面标题
    private let titleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Messages"
        label_Echd.font = UIFont.systemFont(ofSize: 34, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    /// 副标题
    private let subTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Stay connected 💬"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.75)
        return label_Echd
    }()

    /// Header 右侧装饰图标
    private let headerDecoIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 42, weight: .thin)
        iv_Echd.image = UIImage(systemName: "message.circle", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - UI组件 / 活跃联系人横向条

    /// 活跃联系人区域背景卡片
    private let activeStripCard_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 20
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.1).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Echd.layer.shadowRadius = 12
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// "Active Now" 标签
    private let activeLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Active Now"
        label_Echd.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        return label_Echd
    }()

    /// 在线数量标签
    private let activeCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        return label_Echd
    }()

    /// 活跃用户头像横向滚动视图
    private let activeScrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsHorizontalScrollIndicator = false
        sv_Echd.alwaysBounceHorizontal = true
        return sv_Echd
    }()

    /// 活跃用户头像 StackView
    private let activeAvatarStack_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .horizontal
        sv_Echd.spacing = 16
        sv_Echd.alignment = .center
        return sv_Echd
    }()

    // MARK: - UI组件 / 列表与空态

    /// 会话列表
    private let tableView_Echd: UITableView = {
        let tv_Echd = UITableView()
        tv_Echd.separatorStyle = .none
        tv_Echd.backgroundColor = .clear
        tv_Echd.showsVerticalScrollIndicator = false
        tv_Echd.alwaysBounceVertical = true
        tv_Echd.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tv_Echd.register(MessageListCell_Echd.self, forCellReuseIdentifier: MessageListCell_Echd.identifier_Echd)
        return tv_Echd
    }()

    /// 空状态容器
    private let emptyStateView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.isHidden = true
        return view_Echd
    }()

    // MARK: - 私有属性

    /// 有聊天记录的用户列表
    private var chatUsers_Echd: [PrewUserModel_Echd] = []

    /// 活跃联系人头像环颜色循环（与 Discover 卡片一致）
    private let activeAccentColors_Echd: [UIColor] = [
        UIColor(hexstring_Echd: "#7C3AED"),
        UIColor(hexstring_Echd: "#EC4899"),
        UIColor(hexstring_Echd: "#10B981"),
        UIColor(hexstring_Echd: "#F59E0B"),
        UIColor(hexstring_Echd: "#6366F1"),
        UIColor(hexstring_Echd: "#F43F5E")
    ]

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshChatList_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        setupEmptyState_Echd()
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerContainer_Echd.bounds
        applyHeaderArc_Echd()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // Header
        headerContainer_Echd.clipsToBounds = true
        view.addSubview(headerContainer_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerContainer_Echd.layer.insertSublayer(grad_Echd, at: 0)
        headerGradient_Echd = grad_Echd

        headerContainer_Echd.addSubview(titleLabel_Echd)
        headerContainer_Echd.addSubview(subTitleLabel_Echd)
        headerContainer_Echd.addSubview(headerDecoIcon_Echd)

        // 活跃联系人条
        view.addSubview(activeStripCard_Echd)
        activeStripCard_Echd.addSubview(activeLabel_Echd)
        activeStripCard_Echd.addSubview(activeCountLabel_Echd)
        activeStripCard_Echd.addSubview(activeScrollView_Echd)
        activeScrollView_Echd.addSubview(activeAvatarStack_Echd)

        // 列表与空态
        view.addSubview(tableView_Echd)
        view.addSubview(emptyStateView_Echd)
        tableView_Echd.dataSource = self
        tableView_Echd.delegate = self
    }

    /// Header 底部圆弧遮罩
    private func applyHeaderArc_Echd() {
        let w_Echd = headerContainer_Echd.bounds.width
        let h_Echd = headerContainer_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 20))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 20),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 20)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer()
        mask_Echd.path = path_Echd.cgPath
        headerContainer_Echd.layer.mask = mask_Echd
    }

    /// 配置空状态视图内容
    private func setupEmptyState_Echd() {
        let circleBg_Echd = UIView()
        circleBg_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.08)
        circleBg_Echd.layer.cornerRadius = 52
        emptyStateView_Echd.addSubview(circleBg_Echd)

        let iconIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 36, weight: .thin)
        iconIV_Echd.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg_Echd)
        iconIV_Echd.tintColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.5)
        iconIV_Echd.contentMode = .scaleAspectFit
        emptyStateView_Echd.addSubview(iconIV_Echd)

        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = "No conversations yet"
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl_Echd.textColor = UIColor(hexstring_Echd: "#374151")
        titleLbl_Echd.textAlignment = .center
        emptyStateView_Echd.addSubview(titleLbl_Echd)

        let descLbl_Echd = UILabel()
        descLbl_Echd.text = "Start chatting with someone\nfrom their profile ✨"
        descLbl_Echd.font = UIFont.systemFont(ofSize: 13)
        descLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        descLbl_Echd.textAlignment = .center
        descLbl_Echd.numberOfLines = 0
        emptyStateView_Echd.addSubview(descLbl_Echd)

        circleBg_Echd.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }
        iconIV_Echd.snp.makeConstraints { make in
            make.center.equalTo(circleBg_Echd)
            make.width.height.equalTo(48)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(circleBg_Echd.snp.bottom).offset(20)
            make.leading.trailing.centerX.equalToSuperview()
        }
        descLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(8)
            make.leading.trailing.centerX.bottom.equalToSuperview()
        }
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        headerContainer_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        titleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(22)
            make.trailing.lessThanOrEqualTo(headerDecoIcon_Echd.snp.leading).offset(-10)
        }
        subTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }
        headerDecoIcon_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(8)
            make.width.height.equalTo(120)
        }

        // 活跃联系人卡片
        activeStripCard_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Echd.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(90)
        }
        activeLabel_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        activeCountLabel_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(activeLabel_Echd)
            make.leading.equalTo(activeLabel_Echd.snp.trailing).offset(6)
        }
        activeScrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(activeLabel_Echd.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        activeAvatarStack_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 会话列表
        tableView_Echd.snp.makeConstraints { make in
            make.top.equalTo(activeStripCard_Echd.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 空态居中（在列表区域内）
        emptyStateView_Echd.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 活跃联系人条构建

    /// 构建横向活跃联系人头像条
    /// - Parameter users: 联系人列表（取前 8 个展示）
    private func buildActiveStrip_Echd(users: [PrewUserModel_Echd]) {
        activeAvatarStack_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let displayUsers_Echd = Array(users.prefix(8))
        activeCountLabel_Echd.text = "\(displayUsers_Echd.count) online"

        for (idx_Echd, user_Echd) in displayUsers_Echd.enumerated() {
            let itemView_Echd = buildActiveAvatarItem_Echd(
                user: user_Echd,
                accentColor: activeAccentColors_Echd[idx_Echd % activeAccentColors_Echd.count]
            )
            activeAvatarStack_Echd.addArrangedSubview(itemView_Echd)
        }

        // 无用户时显示占位提示
        if displayUsers_Echd.isEmpty {
            let placeholderLabel_Echd = UILabel()
            placeholderLabel_Echd.text = "No active contacts"
            placeholderLabel_Echd.font = UIFont.systemFont(ofSize: 12)
            placeholderLabel_Echd.textColor = UIColor(hexstring_Echd: "#D1D5DB")
            activeAvatarStack_Echd.addArrangedSubview(placeholderLabel_Echd)
            activeCountLabel_Echd.text = ""
        }
    }

    /// 构建单个活跃头像项（头像 + 在线绿点 + 用户名）
    /// - Parameters:
    ///   - user: 用户数据
    ///   - accentColor: 头像环颜色
    private func buildActiveAvatarItem_Echd(user: PrewUserModel_Echd, accentColor: UIColor) -> UIView {
        let container_Echd = UIView()

        // 彩色渐变环背景
        let ringView_Echd = UIView()
        ringView_Echd.layer.cornerRadius = 24
        ringView_Echd.layer.borderWidth = 2.5
        ringView_Echd.layer.borderColor = accentColor.cgColor
        container_Echd.addSubview(ringView_Echd)

        // 头像
        let avatar_Echd = UserAvatarView_Echd()
        avatar_Echd.configure_Echd(userId_Echd: user.userId_Echd ?? 0)
        container_Echd.addSubview(avatar_Echd)

        // 在线绿点
        let dot_Echd = UIView()
        dot_Echd.backgroundColor = UIColor(hexstring_Echd: "#10B981")
        dot_Echd.layer.cornerRadius = 5
        dot_Echd.layer.borderWidth = 1.5
        dot_Echd.layer.borderColor = UIColor.white.cgColor
        container_Echd.addSubview(dot_Echd)

        // 用户名（截断显示）
        let nameLabel_Echd = UILabel()
        let fullName_Echd = user.userName_Echd ?? ""
        nameLabel_Echd.text = fullName_Echd.count > 6
            ? String(fullName_Echd.prefix(5)) + "…"
            : fullName_Echd
        nameLabel_Echd.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        nameLabel_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        nameLabel_Echd.textAlignment = .center
        container_Echd.addSubview(nameLabel_Echd)

        ringView_Echd.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }
        avatar_Echd.snp.makeConstraints { make in
            make.center.equalTo(ringView_Echd)
            make.width.height.equalTo(42)
        }
        dot_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(ringView_Echd.snp.trailing).offset(1)
            make.bottom.equalTo(ringView_Echd.snp.bottom).offset(1)
            make.width.height.equalTo(10)
        }
        nameLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(ringView_Echd.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
        container_Echd.snp.makeConstraints { make in
            make.width.equalTo(52)
        }

        // 点击头像进入聊天
        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(activeAvatarTapped_Echd(_:)))
        container_Echd.addGestureRecognizer(tap_Echd)
        container_Echd.tag = user.userId_Echd ?? 0

        return container_Echd
    }

    // MARK: - 数据刷新

    /// 刷新聊天列表与活跃联系人条
    private func refreshChatList_Echd() {
        chatUsers_Echd = MessageViewModel_Echd.shared_Echd.getChatUsers_Echd()

        let isEmpty_Echd = chatUsers_Echd.isEmpty
        emptyStateView_Echd.isHidden = !isEmpty_Echd
        tableView_Echd.isHidden = isEmpty_Echd

        buildActiveStrip_Echd(users: chatUsers_Echd)

        if !isEmpty_Echd {
            tableView_Echd.reloadData()
        }
    }

    // MARK: - 事件处理

    /// 活跃联系人头像点击，跳转聊天
    @objc private func activeAvatarTapped_Echd(_ gesture: UITapGestureRecognizer) {
        guard let uid_Echd = gesture.view?.tag,
              let user_Echd = chatUsers_Echd.first(where: { $0.userId_Echd == uid_Echd }) else { return }
        Navigation_Echd.toMessageUser_Echd(with: user_Echd, style_echd: .push_echd)
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Echd),
            name: MessageViewModel_Echd.messageStateDidChangeNotification_Echd,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Echd() {
        refreshChatList_Echd()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageList_Echd: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Echd.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Echd = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Echd.identifier_Echd,
            for: indexPath
        ) as! MessageListCell_Echd

        let user_Echd = chatUsers_Echd[indexPath.row]
        let lastMsg_Echd = MessageViewModel_Echd.shared_Echd.getLastMessageWithUser_Echd(
            userId_echd: user_Echd.userId_Echd ?? 0
        )
        let accent_Echd = MessageListCell_Echd.accentColors_Echd[indexPath.row % MessageListCell_Echd.accentColors_Echd.count]
        cell_Echd.configure_Echd(user_Echd: user_Echd, lastMessage_Echd: lastMsg_Echd, accentColor_Echd: accent_Echd)
        return cell_Echd
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user_Echd = chatUsers_Echd[indexPath.row]
        Navigation_Echd.toMessageUser_Echd(with: user_Echd, style_echd: .push_echd)
    }
}

// MARK: - 消息列表 Cell

/// 消息列表单元格
/// 设计：左侧 accent 竖条 + 彩色头像环 + 消息预览 + 相对时间 + 未读气泡
class MessageListCell_Echd: UITableViewCell {

    static let identifier_Echd = "MessageListCell_Echd"

    /// Cell accent 颜色池（与 Discover 保持一致）
    static let accentColors_Echd: [UIColor] = [
        UIColor(hexstring_Echd: "#7C3AED"),
        UIColor(hexstring_Echd: "#EC4899"),
        UIColor(hexstring_Echd: "#10B981"),
        UIColor(hexstring_Echd: "#F59E0B"),
        UIColor(hexstring_Echd: "#6366F1"),
        UIColor(hexstring_Echd: "#F43F5E")
    ]

    // MARK: - UI组件

    /// 卡片容器
    private let cardView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 18
        view_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Echd.layer.shadowRadius = 10
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 左侧 accent 竖条
    private let accentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 2.5
        return view_Echd
    }()

    /// 头像圆环容器（提供彩色边框效果）
    private let avatarRingView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 27
        view_Echd.layer.borderWidth = 2.5
        return view_Echd
    }()

    /// 头像视图
    private let avatarView_Echd = UserAvatarView_Echd()

    /// 在线状态绿点
    private let onlineDot_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#10B981")
        view_Echd.layer.cornerRadius = 6
        view_Echd.layer.borderWidth = 2
        view_Echd.layer.borderColor = UIColor.white.cgColor
        return view_Echd
    }()

    /// 用户昵称
    private let userNameLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#111827")
        return label_Echd
    }()

    /// 最后一条消息预览
    private let lastMessageLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 13)
        label_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        label_Echd.numberOfLines = 1
        return label_Echd
    }()

    /// 时间标签
    private let timeLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        label_Echd.textAlignment = .right
        return label_Echd
    }()

    /// 未读消息气泡
    private let unreadBadge_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        view_Echd.layer.cornerRadius = 9
        view_Echd.isHidden = true
        return view_Echd
    }()

    /// 未读数量标签
    private let unreadLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 右侧箭头图标
    private let arrowIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv_Echd.image = UIImage(systemName: "chevron.right", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = UIColor(hexstring_Echd: "#D1D5DB")
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Echd()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 点击高亮

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.12) {
            self.cardView_Echd.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            self.cardView_Echd.alpha = highlighted ? 0.92 : 1
        }
    }

    // MARK: - UI布局

    private func setupUI_Echd() {
        contentView.addSubview(cardView_Echd)
        cardView_Echd.addSubview(accentBar_Echd)
        cardView_Echd.addSubview(avatarRingView_Echd)
        avatarRingView_Echd.addSubview(avatarView_Echd)
        cardView_Echd.addSubview(onlineDot_Echd)
        cardView_Echd.addSubview(userNameLabel_Echd)
        cardView_Echd.addSubview(lastMessageLabel_Echd)
        cardView_Echd.addSubview(timeLabel_Echd)
        cardView_Echd.addSubview(unreadBadge_Echd)
        unreadBadge_Echd.addSubview(unreadLabel_Echd)
        cardView_Echd.addSubview(arrowIcon_Echd)

        cardView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-5)
        }
        accentBar_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.width.equalTo(5)
            make.height.equalTo(34)
        }
        avatarRingView_Echd.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Echd.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(54)
        }
        avatarView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        onlineDot_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRingView_Echd.snp.trailing).offset(1)
            make.bottom.equalTo(avatarRingView_Echd.snp.bottom).offset(1)
            make.width.height.equalTo(12)
        }
        arrowIcon_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }
        timeLabel_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(arrowIcon_Echd.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(70)
        }
        unreadBadge_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(arrowIcon_Echd.snp.leading).offset(-6)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(18)
        }
        unreadLabel_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        }
        userNameLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Echd.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalTo(timeLabel_Echd.snp.leading).offset(-8)
        }
        lastMessageLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Echd.snp.trailing).offset(12)
            make.top.equalTo(userNameLabel_Echd.snp.bottom).offset(5)
            make.trailing.equalTo(unreadBadge_Echd.snp.leading).offset(-8)
        }
    }

    // MARK: - 数据配置

    /// 配置单元格内容
    /// - Parameters:
    ///   - user_Echd: 用户数据
    ///   - lastMessage_Echd: 最后一条消息（可为 nil）
    ///   - accentColor_Echd: 当前 Cell 的 accent 颜色
    func configure_Echd(user_Echd: PrewUserModel_Echd, lastMessage_Echd: MessageModel_Echd?, accentColor_Echd: UIColor) {
        avatarView_Echd.configure_Echd(userId_Echd: user_Echd.userId_Echd ?? 0)
        userNameLabel_Echd.text = user_Echd.userName_Echd ?? "Unknown"

        // accent 颜色应用到竖条和头像环
        accentBar_Echd.backgroundColor = accentColor_Echd
        avatarRingView_Echd.layer.borderColor = accentColor_Echd.withAlphaComponent(0.5).cgColor
        unreadBadge_Echd.backgroundColor = accentColor_Echd

        // 消息内容与时间
        if let msg_Echd = lastMessage_Echd {
            lastMessageLabel_Echd.text = msg_Echd.content_Echd
            timeLabel_Echd.text = msg_Echd.time_Echd

            // 用消息 ID 奇偶模拟未读状态（奇数显示未读气泡）
            let msgId_Echd = msg_Echd.messageId_Echd ?? 0
            let hasUnread_Echd = (msgId_Echd % 2 != 0)
            unreadBadge_Echd.isHidden = !hasUnread_Echd
            if hasUnread_Echd {
                unreadLabel_Echd.text = "\(msgId_Echd % 9 + 1)"
            }
            lastMessageLabel_Echd.font = hasUnread_Echd
                ? UIFont.systemFont(ofSize: 13, weight: .semibold)
                : UIFont.systemFont(ofSize: 13)
            lastMessageLabel_Echd.textColor = hasUnread_Echd
                ? UIColor(hexstring_Echd: "#374151")
                : UIColor(hexstring_Echd: "#6B7280")
        } else {
            lastMessageLabel_Echd.text = "Start a conversation..."
            lastMessageLabel_Echd.font = UIFont.systemFont(ofSize: 13)
            lastMessageLabel_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
            timeLabel_Echd.text = ""
            unreadBadge_Echd.isHidden = true
        }
    }
}
