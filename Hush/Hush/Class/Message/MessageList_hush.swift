import UIKit
import SnapKit

// MARK: - 消息列表单元格

/// 消息列表单元格
/// 功能：左侧带渐变环头像，右侧显示用户名、最后消息预览、时间戳
/// 设计：卡片式，渐变头像环 + 在线指示点 + 橙色时间戳 + 消息预览图标
class MessageListCell_Hush: UITableViewCell {

    static let reuseId_Hush = "MessageListCell_Hush"

    // MARK: - UI 组件

    /// 卡片容器（圆角 + 阴影）
    private let cardView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.07
        v.layer.masksToBounds = false
        return v
    }()

    /// 头像渐变环容器
    private let avatarRingView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 30
        v.clipsToBounds = false
        return v
    }()

    /// 渐变环图层（橙→红）
    private var ringGradientLayer_Hush: CAGradientLayer?

    /// 头像白色内圆（镂空渐变环）
    private let avatarInnerView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    /// 头像组件
    private let avatarView_Hush: UserAvatarView_Hush = {
        let v = UserAvatarView_Hush()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    /// 在线状态指示点（绿色）
    private let onlineDot_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Hush: "#48BB78")
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户名标签
    private let nameLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        return lbl
    }()

    /// 时间戳标签（橙色主色调）
    private let timeLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = ColorConfig_Hush.primaryGradientStart_Hush
        lbl.textAlignment = .right
        return lbl
    }()

    /// 消息预览图标
    private let previewIconView_Hush: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.fill", withConfiguration: cfg))
        iv.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 最后消息内容预览
    private let lastMsgLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = ColorConfig_Hush.textSecondary_Hush
        lbl.numberOfLines = 1
        return lbl
    }()

    /// 卡片左侧渐变装饰条
    private let accentStrip_Hush = UIView()
    private var accentStripGradient_Hush: CAGradientLayer?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        ringGradientLayer_Hush?.frame = avatarRingView_Hush.bounds
        accentStripGradient_Hush?.frame = accentStrip_Hush.bounds
        // 更新卡片阴影路径
        cardView_Hush.layer.shadowPath = UIBezierPath(
            roundedRect: cardView_Hush.bounds, cornerRadius: 18
        ).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView_Hush)

        // 左侧渐变色条
        accentStrip_Hush.layer.cornerRadius = 2
        cardView_Hush.addSubview(accentStrip_Hush)
        let stripGrad_Hush = CAGradientLayer()
        stripGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        stripGrad_Hush.startPoint = CGPoint(x: 0.5, y: 0)
        stripGrad_Hush.endPoint = CGPoint(x: 0.5, y: 1)
        accentStrip_Hush.layer.addSublayer(stripGrad_Hush)
        accentStripGradient_Hush = stripGrad_Hush

        // 头像渐变环
        cardView_Hush.addSubview(avatarRingView_Hush)
        let ringGrad_Hush = CAGradientLayer()
        ringGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        ringGrad_Hush.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Hush.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Hush.cornerRadius = 30
        avatarRingView_Hush.layer.insertSublayer(ringGrad_Hush, at: 0)
        ringGradientLayer_Hush = ringGrad_Hush

        // 内圆（白色镂空）
        avatarRingView_Hush.addSubview(avatarInnerView_Hush)
        avatarInnerView_Hush.addSubview(avatarView_Hush)

        // 在线点
        cardView_Hush.addSubview(onlineDot_Hush)

        // 文字区域
        cardView_Hush.addSubview(nameLabel_Hush)
        cardView_Hush.addSubview(timeLabel_Hush)
        cardView_Hush.addSubview(previewIconView_Hush)
        cardView_Hush.addSubview(lastMsgLabel_Hush)

        // 约束
        cardView_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().inset(7)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        accentStrip_Hush.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        avatarRingView_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        avatarInnerView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(52)
        }
        avatarView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
        onlineDot_Hush.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRingView_Hush.snp.trailing).offset(1)
            make.bottom.equalTo(avatarRingView_Hush.snp.bottom).offset(1)
            make.width.height.equalTo(12)
        }
        timeLabel_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(18)
            make.width.greaterThanOrEqualTo(36)
        }
        nameLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Hush.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(18)
            make.trailing.equalTo(timeLabel_Hush.snp.leading).offset(-8)
        }
        previewIconView_Hush.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_Hush)
            make.top.equalTo(nameLabel_Hush.snp.bottom).offset(6)
            make.width.height.equalTo(13)
        }
        lastMsgLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(previewIconView_Hush.snp.trailing).offset(5)
            make.centerY.equalTo(previewIconView_Hush)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(18)
        }
    }

    // MARK: - 数据配置

    /// 配置单元格内容
    /// - Parameters:
    ///   - user_hush: 聊天对象用户
    ///   - lastMessage_hush: 最后一条消息（可为 nil）
    func configure_Hush(user_hush: PrewUserModel_Hush, lastMessage_hush: MessageModel_Hush?) {
        if let userId = user_hush.userId_Hush {
            avatarView_Hush.configure_Hush(userId_Hush: userId)
        }
        nameLabel_Hush.text = user_hush.userName_Hush ?? "User"
        lastMsgLabel_Hush.text = lastMessage_hush?.content_Hush ?? "No messages yet"
        timeLabel_Hush.text = lastMessage_hush?.time_Hush ?? ""

        // 在线状态（装饰性，奇数 userId 显示）
        let isOnline = (user_hush.userId_Hush ?? 0) % 2 != 0
        onlineDot_Hush.isHidden = !isOnline

        // 有消息时预览图标使用橙色，无消息时用灰色
        if lastMessage_hush != nil {
            previewIconView_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.6)
        } else {
            previewIconView_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        }
    }

    // MARK: - 选中高亮动画

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardView_Hush.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            self.cardView_Hush.layer.shadowOpacity = highlighted ? 0.03 : 0.07
        }
    }
}

// MARK: - 消息列表视图控制器

/// 消息列表页面
/// 功能：展示当前用户所有的私信对话列表，点击进入具体聊天页面
/// 设计：大标题导航栏 + 会话数统计 + 装饰图标 + 卡片式列表 + 丰富空状态
/// 监听：MessageViewModel + UserViewModel 状态通知，实时刷新
class MessageList_Hush: UIViewController {

    // MARK: - 私有属性

    private var chatUsers_Hush: [PrewUserModel_Hush] = []

    // MARK: - 导航栏组件

    private let navBarView_Hush = UIView()

    /// 顶部橙红渐变色条
    private let navTopBand_Hush = UIView()
    private var navTopBandGrad_Hush: CAGradientLayer?

    private let backButton_Hush = BackButton_Hush()

    /// 大标题
    private let navTitleLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.text = "Messages"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .black)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        return lbl
    }()

    /// 副标题（会话数）
    private let navSubtitleLabel_Hush = UILabel()

    /// 装饰气泡图标（右侧，低透明度）
    private let bubbleDecorView_Hush: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 52, weight: .ultraLight)
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: cfg))
        iv.tintColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.14)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 底部渐变分割线
    private let navDividerView_Hush = UIView()
    private var navDividerGrad_Hush: CAGradientLayer?

    // MARK: - 内容区组件

    private lazy var tableView_Hush: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 92
        tv.dataSource = self
        tv.delegate = self
        tv.register(MessageListCell_Hush.self, forCellReuseIdentifier: MessageListCell_Hush.reuseId_Hush)
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0)
        return tv
    }()

    private let emptyView_Hush: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        setupNotifications_Hush()
        updateData_Hush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navTopBandGrad_Hush?.frame = navTopBand_Hush.bounds
        navDividerGrad_Hush?.frame = navDividerView_Hush.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        setupNavBar_Hush()
        setupTableAndEmpty_Hush()
    }

    /// 构建富有编辑感的顶部导航栏
    /// 设计：顶部橙红色条 + 大标题 + 副标题 + 右侧装饰气泡 + 渐变分割线
    private func setupNavBar_Hush() {
        navBarView_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view.addSubview(navBarView_Hush)

        // 顶部橙红渐变色条（4pt 高）
        navBarView_Hush.addSubview(navTopBand_Hush)
        let topGrad_Hush = CAGradientLayer()
        topGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        topGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        topGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        navTopBand_Hush.layer.addSublayer(topGrad_Hush)
        navTopBandGrad_Hush = topGrad_Hush

        // 返回按钮
        navBarView_Hush.addSubview(backButton_Hush)
        let showBack = (navigationController?.viewControllers.count ?? 0) > 1
        backButton_Hush.isHidden = !showBack
        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }

        // 装饰气泡图标（右侧）
        navBarView_Hush.addSubview(bubbleDecorView_Hush)

        // 大标题
        navBarView_Hush.addSubview(navTitleLabel_Hush)

        // 副标题（会话数，富文本）
        navBarView_Hush.addSubview(navSubtitleLabel_Hush)
        _updateSubtitle_Hush(count: 0)

        // 渐变分割线（橙→红→透明）
        navBarView_Hush.addSubview(navDividerView_Hush)
        let divGrad_Hush = CAGradientLayer()
        divGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
            UIColor.clear.cgColor
        ]
        divGrad_Hush.locations = [0, 0.5, 1]
        divGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        divGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        navDividerView_Hush.layer.addSublayer(divGrad_Hush)
        navDividerGrad_Hush = divGrad_Hush

        // 约束
        navBarView_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(96)
        }
        navTopBand_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        backButton_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(navTitleLabel_Hush)
            make.width.height.equalTo(36)
        }
        bubbleDecorView_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(navTitleLabel_Hush)
            make.width.height.equalTo(58)
        }
        navTitleLabel_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(navSubtitleLabel_Hush.snp.top).offset(-2)
            make.trailing.lessThanOrEqualTo(bubbleDecorView_Hush.snp.leading).offset(-8)
        }
        navSubtitleLabel_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(navDividerView_Hush.snp.top).offset(-10)
        }
        navDividerView_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.bottom.equalToSuperview()
            make.height.equalTo(1.5)
        }
    }

    /// 更新副标题会话数
    private func _updateSubtitle_Hush(count: Int) {
        let attrs_Hush = NSMutableAttributedString()
        attrs_Hush.append(NSAttributedString(
            string: "▌ ",
            attributes: [.foregroundColor: ColorConfig_Hush.primaryGradientStart_Hush,
                         .font: UIFont.systemFont(ofSize: 12, weight: .black)]
        ))
        let countText_Hush = count == 0 ? "No active conversations" : "\(count) conversation\(count > 1 ? "s" : "")"
        attrs_Hush.append(NSAttributedString(
            string: countText_Hush,
            attributes: [.foregroundColor: ColorConfig_Hush.textSecondary_Hush,
                         .font: UIFont.systemFont(ofSize: 12, weight: .medium)]
        ))
        navSubtitleLabel_Hush.attributedText = attrs_Hush
    }

    /// 构建表格和空状态视图
    private func setupTableAndEmpty_Hush() {
        view.addSubview(tableView_Hush)
        tableView_Hush.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(emptyView_Hush)
        emptyView_Hush.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        setupEmptyView_Hush()
    }

    /// 构建富有设计感的空状态视图
    private func setupEmptyView_Hush() {
        // 大号装饰图标（带浅橙背景圆圈）
        let iconContainer_Hush = UIView()
        iconContainer_Hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.08)
        iconContainer_Hush.layer.cornerRadius = 48
        emptyView_Hush.addSubview(iconContainer_Hush)

        let iconCfg_Hush = UIImage.SymbolConfiguration(pointSize: 38, weight: .thin)
        let iconView_Hush = UIImageView(
            image: UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: iconCfg_Hush)
        )
        iconView_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.7)
        iconView_Hush.contentMode = .scaleAspectFit
        iconContainer_Hush.addSubview(iconView_Hush)

        let titleLabel_Hush = UILabel()
        titleLabel_Hush.text = "No Messages Yet"
        titleLabel_Hush.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        titleLabel_Hush.textAlignment = .center
        emptyView_Hush.addSubview(titleLabel_Hush)

        let subLabel_Hush = UILabel()
        subLabel_Hush.text = "Follow a photographer and\nstart your first conversation"
        subLabel_Hush.font = UIFont.systemFont(ofSize: 14)
        subLabel_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        subLabel_Hush.textAlignment = .center
        subLabel_Hush.numberOfLines = 2
        emptyView_Hush.addSubview(subLabel_Hush)

        // 装饰性三个点（...）底部
        let dotRow_Hush = UIView()
        emptyView_Hush.addSubview(dotRow_Hush)
        for i in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = i == 1
                ? ColorConfig_Hush.primaryGradientStart_Hush
                : ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.3)
            dot.layer.cornerRadius = i == 1 ? 5 : 4
            dotRow_Hush.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                let size = i == 1 ? 10 : 8
                make.width.height.equalTo(size)
                make.leading.equalToSuperview().offset(i * 18)
            }
        }

        // 约束
        iconContainer_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-56)
            make.width.height.equalTo(96)
        }
        iconView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(52)
        }
        titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(iconContainer_Hush.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        subLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Hush.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        dotRow_Hush.snp.makeConstraints { make in
            make.top.equalTo(subLabel_Hush.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(10)
        }
    }

    // MARK: - 通知监听

    private func setupNotifications_Hush() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Hush),
            name: MessageViewModel_Hush.messageStateDidChangeNotification_Hush, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Hush),
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush, object: nil
        )
    }

    @objc private func handleStateChange_Hush() {
        updateData_Hush()
    }

    // MARK: - 数据更新

    /// 刷新消息列表：未登录时展示空状态，已登录时展示会话列表
    private func updateData_Hush() {
        guard UserViewModel_Hush.shared_Hush.isLoggedIn_Hush else {
            chatUsers_Hush = []
            _updateSubtitle_Hush(count: 0)
            emptyView_Hush.isHidden = false
            tableView_Hush.isHidden = true
            return
        }

        chatUsers_Hush = MessageViewModel_Hush.shared_Hush.getChatUsers_Hush()
        _updateSubtitle_Hush(count: chatUsers_Hush.count)

        if chatUsers_Hush.isEmpty {
            emptyView_Hush.isHidden = false
            tableView_Hush.isHidden = true
        } else {
            emptyView_Hush.isHidden = true
            tableView_Hush.isHidden = false
        }

        tableView_Hush.reloadData()
    }
}

// MARK: - UITableView 数据源与代理

extension MessageList_Hush: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatUsers_Hush.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Hush.reuseId_Hush,
            for: indexPath
        ) as! MessageListCell_Hush
        let user = chatUsers_Hush[indexPath.row]
        let lastMessage = MessageViewModel_Hush.shared_Hush.getLastMessageWithUser_Hush(
            userId_hush: user.userId_Hush ?? 0
        )
        cell.configure_Hush(user_hush: user, lastMessage_hush: lastMessage)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard UserViewModel_Hush.shared_Hush.isLoggedIn_Hush else {
            Navigation_Hush.toLogin_Hush(style_hush: .present_hush)
            return
        }
        let user = chatUsers_Hush[indexPath.row]
        Navigation_Hush.toMessageUser_Hush(with: user, style_hush: .push_hush, animated_hush: true, completion_hush: nil)
    }

    /// 左滑删除会话
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }
            if let userId = self.chatUsers_Hush[indexPath.row].userId_Hush {
                MessageViewModel_Hush.shared_Hush.deleteUserMessages_Hush(userId_hush: userId)
            }
            completion(true)
        }
        deleteAction.backgroundColor = ColorConfig_Hush.primaryGradientEnd_Hush
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
