import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表视图控制器
/// 功能：响应式展示与登录用户存在聊天记录的用户列表，点击进入聊天详情
/// 设计：三色渐变头部（与全局色系统一）、丰富卡片行、彩色头像环、在线状态、调和配色
class MessageList_Bague: UIViewController {

    // MARK: - UI 组件（头部）

    private let headerView_Bague = UIView()
    private var headerGradient_Bague: CAGradientLayer?

    /// 主标题
    private let headerTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Messages"
        label.font = UIFont.systemFont(ofSize: 32, weight: .black)
        label.textColor = .white
        return label
    }()

    /// 副标题
    private let headerSubtitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Your conversations"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        return label
    }()

    /// 对话数量徽章
    private let countBadge_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 13
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v
    }()

    private let countLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    /// 头部装饰：大消息图标
    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "message.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.16)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部装饰：半透明大圆
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰：小星形图标
    private let headerDecorStar_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.13)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI 组件（列表）

    private let tableView_Bague: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        return tv
    }()

    // MARK: - 空状态视图

    private let emptyView_Bague: UIView = {
        let v = UIView()
        v.isHidden = true
        v.alpha = 0
        return v
    }()

    private let emptyIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 54, weight: .light)
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Bague.primaryGradientStart_Bague.withAlphaComponent(0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "No Messages Yet"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.textAlignment = .center
        return label
    }()

    private let emptySubtitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Start a conversation with someone you follow"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // MARK: - 数据

    private var chatUsers_Bague: [PrewUserModel_Bague] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
        reloadData_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        // 头部
        view.addSubview(headerView_Bague)
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        headerView_Bague.addSubview(headerDecorStar_Bague)
        headerView_Bague.addSubview(headerTitleLabel_Bague)
        headerView_Bague.addSubview(headerSubtitle_Bague)
        headerView_Bague.addSubview(countBadge_Bague)
        countBadge_Bague.addSubview(countLabel_Bague)

        // 列表
        view.addSubview(tableView_Bague)
        tableView_Bague.dataSource = self
        tableView_Bague.delegate = self
        tableView_Bague.register(MessageListCell_Bague.self, forCellReuseIdentifier: "MessageListCell_Bague")

        // 空状态
        view.addSubview(emptyView_Bague)
        emptyView_Bague.addSubview(emptyIcon_Bague)
        emptyView_Bague.addSubview(emptyTitleLabel_Bague)
        emptyView_Bague.addSubview(emptySubtitleLabel_Bague)
    }

    private func setupConstraints_Bague() {
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(210)
        }
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-15)
            make.width.height.equalTo(100)
        }
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(72)
        }
        headerDecorStar_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-100)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.width.height.equalTo(20)
        }
        headerTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        // 对话数量徽章：与标题右端对齐
        countBadge_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(headerTitleLabel_Bague)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(26)
        }
        countLabel_Bague.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        headerSubtitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Bague.snp.bottom).offset(5)
            make.leading.equalTo(headerTitleLabel_Bague)
            make.trailing.lessThanOrEqualTo(countBadge_Bague.snp.leading).offset(-8)
        }
        tableView_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerView_Bague.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyView_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tableView_Bague).offset(-20)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        emptyIcon_Bague.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(76)
        }
        emptyTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        emptySubtitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Bague.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 渐变

    /// 头部三色斜角渐变：深紫 → 天空蓝 → 薄荷绿，与全局色系统一
    private func updateGradient_Bague() {
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
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        [MessageViewModel_Bague.messageStateDidChangeNotification_Bague,
         UserViewModel_Bague.userStateDidChangeNotification_Bague].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(dataChanged_Bague),
                name: $0,
                object: nil
            )
        }
    }

    @objc private func dataChanged_Bague() { reloadData_Bague() }

    private func reloadData_Bague() {
        Task { @MainActor in
            chatUsers_Bague = MessageViewModel_Bague.shared_Bague.getChatUsers_Bague()
            countLabel_Bague.text = "✦ \(chatUsers_Bague.count)"
            tableView_Bague.reloadData()
            updateEmptyState_Bague()
        }
    }

    /// 控制空状态视图的显示与隐藏（淡入淡出）
    private func updateEmptyState_Bague() {
        let isEmpty_bague = chatUsers_Bague.isEmpty
        if isEmpty_bague {
            emptyView_Bague.isHidden = false
            UIView.animate(withDuration: 0.28) { self.emptyView_Bague.alpha = 1 }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.emptyView_Bague.alpha = 0
            } completion: { _ in
                self.emptyView_Bague.isHidden = true
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Bague: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Bague.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_bague = tableView.dequeueReusableCell(
            withIdentifier: "MessageListCell_Bague",
            for: indexPath
        ) as! MessageListCell_Bague
        let user_bague = chatUsers_Bague[indexPath.row]
        let lastMsg_bague = MessageViewModel_Bague.shared_Bague
            .getLastMessageWithUser_Bague(userId_bague: user_bague.userId_Bague ?? 0)
        cell_bague.configure_Bague(
            user_bague: user_bague,
            lastMessage_bague: lastMsg_bague,
            index_bague: indexPath.row
        )
        return cell_bague
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user_bague = chatUsers_Bague[indexPath.row]
        Navigation_Bague.toMessageUser_Bague(with: user_bague)
    }
}

// MARK: - 消息列表单元格

/// 消息列表单元格
/// 功能：展示对话用户头像、姓名、最后一条消息预览、时间、在线状态
/// 设计：白色卡片+彩色左口音条+调和阴影+在线绿点+按压缩放动画
class MessageListCell_Bague: UITableViewCell {

    /// 调和配色：6 组口音色，与发现页卡片色系统一
    private static let accentTints_Bague: [UIColor] = [
        UIColor(hexstring_Bague: "#9B72F5"),
        UIColor(hexstring_Bague: "#5AADEC"),
        UIColor(hexstring_Bague: "#F07DAD"),
        UIColor(hexstring_Bague: "#3DC9A6"),
        UIColor(hexstring_Bague: "#F5A623"),
        UIColor(hexstring_Bague: "#F07060"),
    ]

    private let cardView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    /// 左侧彩色口音条
    private let accentBar_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    private let avatarView_Bague = UserAvatarView_Bague()

    /// 在线绿点
    private let onlineDot_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#3DC9A6")
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    private let nameLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        return label
    }()

    private let lastMsgLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let timeLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        return label
    }()

    private let arrowIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Bague.textPlaceholder_Bague
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView_Bague)
        cardView_Bague.addSubview(accentBar_Bague)
        cardView_Bague.addSubview(avatarView_Bague)
        cardView_Bague.addSubview(onlineDot_Bague)
        cardView_Bague.addSubview(nameLabel_Bague)
        cardView_Bague.addSubview(lastMsgLabel_Bague)
        cardView_Bague.addSubview(timeLabel_Bague)
        cardView_Bague.addSubview(arrowIcon_Bague)

        cardView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-6)
        }
        accentBar_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(36)
        }
        avatarView_Bague.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Bague.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        onlineDot_Bague.snp.makeConstraints { make in
            make.trailing.equalTo(avatarView_Bague.snp.trailing).offset(2)
            make.bottom.equalTo(avatarView_Bague.snp.bottom).offset(2)
            make.width.height.equalTo(12)
        }
        nameLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Bague).offset(6)
            make.leading.equalTo(avatarView_Bague.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel_Bague.snp.leading).offset(-8)
        }
        lastMsgLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Bague.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Bague)
            make.trailing.equalTo(arrowIcon_Bague.snp.leading).offset(-8)
        }
        timeLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Bague)
            make.trailing.equalToSuperview().offset(-14)
        }
        arrowIcon_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(lastMsgLabel_Bague)
            make.trailing.equalToSuperview().offset(-14)
            make.width.equalTo(8)
            make.height.equalTo(14)
        }
    }

    /// 配置单元格
    /// - Parameters:
    ///   - user_bague: 对话用户数据
    ///   - lastMessage_bague: 最后一条消息
    ///   - index_bague: 行序号，用于调色盘取色
    func configure_Bague(user_bague: PrewUserModel_Bague, lastMessage_bague: MessageModel_Bague?, index_bague: Int) {
        avatarView_Bague.configure_Bague(userId_Bague: user_bague.userId_Bague ?? 0)
        nameLabel_Bague.text = user_bague.userName_Bague ?? "Unknown"
        lastMsgLabel_Bague.text = lastMessage_bague?.content_Bague ?? "Start a conversation"
        timeLabel_Bague.text = lastMessage_bague?.time_Bague ?? ""

        // 彩色左口音条（6 组调和色循环）
        let tint_bague = MessageListCell_Bague.accentTints_Bague[index_bague % MessageListCell_Bague.accentTints_Bague.count]
        accentBar_Bague.backgroundColor = tint_bague
        accentBar_Bague.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        // 奇数用户显示在线绿点
        onlineDot_Bague.isHidden = (user_bague.userId_Bague ?? 0) % 2 == 0
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardView_Bague.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            self.cardView_Bague.alpha = highlighted ? 0.92 : 1.0
        }
    }
}
