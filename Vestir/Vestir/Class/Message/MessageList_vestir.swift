import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面
/// 功能：展示与登录用户有聊天记录的用户列表，点击进入聊天页
/// 设计：
///   • 深渐变头部（自管理 CAGradientLayer + 装饰圆 + 会话数徽章）
///   • 卡片式列表行（紫调阴影 + 渐变环头像 + 在线绿点 + 最后消息 + 时间）
///   • 精致空态（渐变图标 + 标题 + 引导文字）
class MessageList_Vestir: UIViewController {

    // MARK: - 私有属性

    private var chatUsers_Vestir: [PrewUserModel_Vestir] = []

    // MARK: - 渐变头部组件

    /// 头部阴影容器（不裁剪，仅承载紫色投影）
    private let headerShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#6B21A8").cgColor
        v_Vestir.layer.shadowOpacity = 0.32
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 20
        return v_Vestir
    }()

    /// 头部渐变背景卡（自管理，下方双角圆角 28pt）
    private let headerCard_Vestir = MessageListHeaderCard_Vestir()

    /// 装饰圆 1（右上，白色 11% alpha）
    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.11)
        v_Vestir.layer.cornerRadius = 50
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 装饰圆 2（左下，天蓝 20% alpha）
    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#93C5FD", alpha_Vestir: 0.22)
        v_Vestir.layer.cornerRadius = 33
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 头部主标题 "Messages"
    private let headerTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Messages"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    /// 头部副标题
    private let headerSubtitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Your fashion community  ✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.68)
        return lbl_Vestir
    }()

    /// 会话数量磨砂徽章（白色 18% alpha 背景）
    private let headerCountBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.18)
        lbl_Vestir.layer.cornerRadius = 12
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.isHidden = true
        return lbl_Vestir
    }()

    // MARK: - 列表

    private lazy var tableView_Vestir: UITableView = {
        let tv_Vestir = UITableView()
        tv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tv_Vestir.separatorStyle = .none
        tv_Vestir.showsVerticalScrollIndicator = false
        tv_Vestir.register(
            MessageListCell_Vestir.self,
            forCellReuseIdentifier: MessageListCell_Vestir.reuseId_Vestir
        )
        tv_Vestir.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        return tv_Vestir
    }()

    // MARK: - 空态

    private let emptyView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.isHidden = true
        return v_Vestir
    }()

    private let emptyIconView_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 54, weight: .thin)
        iv_Vestir.image = UIImage(
            systemName: "bubble.left.and.bubble.right.fill",
            withConfiguration: cfg_Vestir
        )
        iv_Vestir.tintColor = ColorConfig_Vestir.primaryGradientStart_Vestir.withAlphaComponent(0.32)
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()

    private let emptyTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "No Conversations Yet"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let emptyLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Follow creators and start chatting\nabout your fashion inspirations!"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.numberOfLines = 2
        return lbl_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
        loadData_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if headerShadow_Vestir.bounds.width > 0 {
            let path_Vestir = UIBezierPath(
                roundedRect: headerShadow_Vestir.bounds, cornerRadius: 0
            )
            headerShadow_Vestir.layer.shadowPath = path_Vestir.cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 100)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        view.addSubview(headerShadow_Vestir)
        headerShadow_Vestir.addSubview(headerCard_Vestir)
        headerCard_Vestir.addSubview(decoCircle1_Vestir)
        headerCard_Vestir.addSubview(decoCircle2_Vestir)
        headerCard_Vestir.addSubview(headerSubtitleLabel_Vestir)
        headerCard_Vestir.addSubview(headerTitleLabel_Vestir)
        headerCard_Vestir.addSubview(headerCountBadge_Vestir)

        view.addSubview(tableView_Vestir)
        tableView_Vestir.dataSource = self
        tableView_Vestir.delegate = self

        view.addSubview(emptyView_Vestir)
        emptyView_Vestir.addSubview(emptyIconView_Vestir)
        emptyView_Vestir.addSubview(emptyTitleLabel_Vestir)
        emptyView_Vestir.addSubview(emptyLabel_Vestir)
    }

    private func setupConstraints_Vestir() {
        // 头部
        headerShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 100)
        }

        headerCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-24)
        }

        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(66)
            make.leading.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(18)
        }

        headerSubtitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(headerTitleLabel_Vestir.snp.top).offset(-3)
        }

        headerTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-18)
        }

        headerCountBadge_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(headerTitleLabel_Vestir)
            make.height.equalTo(28)
        }

        // 列表：从头部底边开始
        tableView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerShadow_Vestir.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 空态：列表区域居中
        emptyView_Vestir.snp.makeConstraints { make in
            make.center.equalTo(tableView_Vestir)
            make.width.equalTo(260)
        }

        emptyIconView_Vestir.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }

        emptyTitleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Vestir.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        emptyLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Vestir.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    private func loadData_Vestir() {
        chatUsers_Vestir = MessageViewModel_Vestir.shared_Vestir.getChatUsers_Vestir()
        tableView_Vestir.reloadData()

        let isEmpty_Vestir = chatUsers_Vestir.isEmpty
        emptyView_Vestir.isHidden = !isEmpty_Vestir

        let count_Vestir = chatUsers_Vestir.count
        if count_Vestir > 0 {
            headerCountBadge_Vestir.text = "  \(count_Vestir) chats  "
            headerCountBadge_Vestir.isHidden = false
        } else {
            headerCountBadge_Vestir.isHidden = true
        }

        if isEmpty_Vestir {
            emptyView_Vestir.animateFadeIn_Vestir(delay_Vestir: 0.2)
        }
    }

    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Vestir),
            name: MessageViewModel_Vestir.messageStateDidChangeNotification_Vestir,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir,
            object: nil
        )
    }

    @objc private func onDataChanged_Vestir() {
        loadData_Vestir()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Vestir: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Vestir.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Vestir = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Vestir.reuseId_Vestir,
            for: indexPath
        ) as? MessageListCell_Vestir else {
            return UITableViewCell()
        }
        let user_Vestir = chatUsers_Vestir[indexPath.row]
        let lastMsg_Vestir = MessageViewModel_Vestir.shared_Vestir.getLastMessageWithUser_Vestir(
            userId_vestir: user_Vestir.userId_Vestir ?? 0
        )
        cell_Vestir.configure_Vestir(user_vestir: user_Vestir, lastMessage_vestir: lastMsg_Vestir)
        return cell_Vestir
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }

    /// 入场动画：从底部弹入 + 缩放，交错延迟营造流动感
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 18).scaledBy(x: 0.96, y: 0.96)
        UIView.animate(
            withDuration: 0.38,
            delay: Double(indexPath.row) * 0.04,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user_Vestir = chatUsers_Vestir[indexPath.row]
        Navigation_Vestir.toMessageUser_Vestir(with: user_Vestir, style_vestir: .push_vestir)
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let user_Vestir = chatUsers_Vestir[indexPath.row]
        Task { @MainActor in
            MessageViewModel_Vestir.shared_Vestir.deleteUserMessages_Vestir(
                userId_vestir: user_Vestir.userId_Vestir ?? 0
            )
        }
    }

    func tableView(
        _ tableView: UITableView,
        titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath
    ) -> String? {
        return "Delete"
    }
}

// MARK: - 消息列表 Cell

/// 消息列表 Cell
/// 设计：紫调阴影白色卡片 + 渐变环绕头像（紫→蓝渐变外框）+ 绿色在线圆点
///       名称（15pt semibold）+ 最后消息（13pt 截断）+ 时间（右对齐，小字）
class MessageListCell_Vestir: UITableViewCell {

    static let reuseId_Vestir = "MessageListCell_Vestir"

    // MARK: - 卡片容器（紫调阴影）

    private let cardView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 18
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.14
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Vestir.layer.shadowRadius = 12
        return v_Vestir
    }()

    // MARK: - 渐变环头像

    /// 头像渐变外环（54pt，渐变背景 + clipsToBounds）
    private let avatarRing_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 27
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// 渐变环背景图层（紫→蓝）
    private let ringGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    /// 头像视图（46pt，内嵌在渐变环中）
    private let avatarView_Vestir: UserAvatarView_Vestir = {
        let av_Vestir = UserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 23
        av_Vestir.clipsToBounds = true
        return av_Vestir
    }()

    // MARK: - 在线圆点（绿色，白色边框）

    private let onlineDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#22C55E")
        v_Vestir.layer.cornerRadius = 6
        v_Vestir.layer.borderWidth = 2
        v_Vestir.layer.borderColor = ColorConfig_Vestir.backgroundSecondary_Vestir.cgColor
        return v_Vestir
    }()

    // MARK: - 文字区域

    private let nameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    private let lastMsgLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.numberOfLines = 1
        return lbl_Vestir
    }()

    private let timeLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        return lbl_Vestir
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Vestir()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ringGradLayer_Vestir.frame = avatarRing_Vestir.bounds
        ringGradLayer_Vestir.cornerRadius = avatarRing_Vestir.layer.cornerRadius
    }

    private func setupUI_Vestir() {
        contentView.addSubview(cardView_Vestir)
        cardView_Vestir.addSubview(avatarRing_Vestir)
        avatarRing_Vestir.layer.insertSublayer(ringGradLayer_Vestir, at: 0)
        avatarRing_Vestir.addSubview(avatarView_Vestir)
        cardView_Vestir.addSubview(onlineDot_Vestir)
        cardView_Vestir.addSubview(nameLabel_Vestir)
        cardView_Vestir.addSubview(lastMsgLabel_Vestir)
        cardView_Vestir.addSubview(timeLabel_Vestir)

        cardView_Vestir.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        avatarRing_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(54)
        }

        avatarView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(46)
        }

        onlineDot_Vestir.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRing_Vestir.snp.trailing).offset(1)
            make.bottom.equalTo(avatarRing_Vestir.snp.bottom).offset(1)
            make.width.height.equalTo(12)
        }

        nameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(avatarRing_Vestir.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel_Vestir.snp.leading).offset(-8)
        }

        lastMsgLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Vestir.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Vestir)
            make.trailing.equalToSuperview().offset(-14)
        }

        timeLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Vestir)
            make.trailing.equalToSuperview().offset(-14)
        }
    }

    func configure_Vestir(
        user_vestir: PrewUserModel_Vestir,
        lastMessage_vestir: MessageModel_Vestir?
    ) {
        avatarView_Vestir.configure_Vestir(userId_Vestir: user_vestir.userId_Vestir ?? 0)
        nameLabel_Vestir.text = user_vestir.userName_Vestir ?? "User"
        lastMsgLabel_Vestir.text = lastMessage_vestir?.content_Vestir ?? "Tap to chat ✨"
        timeLabel_Vestir.text = lastMessage_vestir?.time_Vestir ?? ""
    }
}

// MARK: - 消息列表头部渐变背景视图

/// 自管理渐变的消息列表头部（深紫→靛蓝→湛蓝，下方双角圆角 28pt）
fileprivate final class MessageListHeaderCard_Vestir: UIView {

    private let gradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradLayer_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 28
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Vestir.frame = bounds
    }
}
