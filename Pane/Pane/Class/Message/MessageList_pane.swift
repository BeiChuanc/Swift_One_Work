import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面

/// 消息列表页面
/// 核心作用：展示推荐用户（横向滚动，使用 UserAvatarView_Pane）
///          + 存在聊天记录的会话用户（纵向列表，响应式刷新）
/// 设计思路：暖色调渐变头部 + 圆润卡片会话行 + 在线状态指示；
///          监听 MessageViewModel 状态通知实现实时更新
class MessageList_Pane: UIViewController {

    // MARK: - 属性

    /// 推荐用户列表（来自本地预制数据）
    private var recommendUsers_Pane: [PrewUserModel_Pane] = []

    /// 有聊天记录的用户列表（来自 MessageViewModel）
    private var chatUsers_Pane: [PrewUserModel_Pane] = []

    // MARK: - UI · 头部

    /// 头部容器
    private let headerView_Pane = UIView()

    /// 头部渐变背景图层
    private var headerGradient_Pane: CAGradientLayer?

    /// 页面主标题
    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Messages"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 副标题
    private let subtitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Stay connected ✨"
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    /// 头部装饰圆 — 大（薰衣草紫）
    private let decorBigDot_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.14)
        v.layer.cornerRadius = 30
        return v
    }()

    /// 头部装饰圆 — 小（玫瑰粉）
    private let decorSmallDot_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.secondaryGradientStart_Pane.alpha_Pane(0.2)
        v.layer.cornerRadius = 18
        return v
    }()

    /// 头部分割线
    private let headerDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    // MARK: - UI · 推荐用户

    /// "Suggested" 区块标题
    private let suggestedLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Suggested"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 推荐用户横向 CollectionView
    private lazy var recommendCV_Pane: UICollectionView = {
        let layout_pane = UICollectionViewFlowLayout()
        layout_pane.scrollDirection     = .horizontal
        layout_pane.itemSize            = CGSize(width: 72, height: 96)
        layout_pane.minimumLineSpacing  = 12
        layout_pane.sectionInset        = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv_pane = UICollectionView(frame: .zero, collectionViewLayout: layout_pane)
        cv_pane.backgroundColor               = .clear
        cv_pane.showsHorizontalScrollIndicator = false
        cv_pane.register(
            MsgRecommendCell_Pane.self,
            forCellWithReuseIdentifier: MsgRecommendCell_Pane.reuseId_Pane
        )
        return cv_pane
    }()

    // MARK: - UI · 聊天列表

    /// "Chats" 区块标题行（含计数徽章）
    private let chatsTitleRow_Pane = UIView()

    private let chatsLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Chats"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 聊天数量徽章
    private let chatsBadge_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.isHidden = true
        return l
    }()

    /// 会话列表 TableView
    private lazy var chatTableView_Pane: UITableView = {
        let tv_pane = UITableView(frame: .zero, style: .plain)
        tv_pane.backgroundColor           = .clear
        tv_pane.separatorStyle            = .none
        tv_pane.showsVerticalScrollIndicator = false
        tv_pane.register(
            MsgSessionCell_Pane.self,
            forCellReuseIdentifier: MsgSessionCell_Pane.reuseId_Pane
        )
        return tv_pane
    }()

    // MARK: - UI · 空状态

    /// 无聊天记录时的空状态视图
    private let emptyView_Pane: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "💬"
        l.font = .systemFont(ofSize: 52)
        l.textAlignment = .center
        return l
    }()

    private let emptyTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "No conversations yet"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.textAlignment = .center
        return l
    }()

    private let emptySubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Say hi to someone above!"
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupDelegates_Pane()
        setupNotification_Pane()
        loadData_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshChatList_Pane()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 头部渐变跟随 frame 更新
        headerGradient_Pane?.frame = headerView_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        // 头部
        view.addSubview(headerView_Pane)
        headerView_Pane.addSubview(decorBigDot_Pane)
        headerView_Pane.addSubview(decorSmallDot_Pane)
        headerView_Pane.addSubview(titleLabel_Pane)
        headerView_Pane.addSubview(subtitleLabel_Pane)
        headerView_Pane.addSubview(headerDivider_Pane)

        // 推荐用户
        view.addSubview(suggestedLabel_Pane)
        view.addSubview(recommendCV_Pane)

        // 聊天区块标题行
        view.addSubview(chatsTitleRow_Pane)
        chatsTitleRow_Pane.addSubview(chatsLabel_Pane)
        chatsTitleRow_Pane.addSubview(chatsBadge_Pane)

        // 聊天列表
        view.addSubview(chatTableView_Pane)

        // 空状态
        view.addSubview(emptyView_Pane)
        emptyView_Pane.addSubview(emptyIconLabel_Pane)
        emptyView_Pane.addSubview(emptyTitleLabel_Pane)
        emptyView_Pane.addSubview(emptySubLabel_Pane)

        setupHeaderGradient_Pane()
        setupConstraints_Pane()
    }

    /// 头部微渐变背景（从暖奶白到微透明，增加层次感）
    private func setupHeaderGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.secondaryGradientEnd_Pane.alpha_Pane(0.25).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane
    }

    /// 布局约束
    private func setupConstraints_Pane() {
        headerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(72)
        }
        decorBigDot_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(60)
        }
        decorSmallDot_Pane.snp.makeConstraints {
            $0.top.equalTo(decorBigDot_Pane.snp.bottom).offset(4)
            $0.trailing.equalTo(decorBigDot_Pane.snp.leading).offset(-6)
            $0.width.height.equalTo(36)
        }
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        subtitleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleLabel_Pane)
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(3)
        }
        headerDivider_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        // 推荐用户
        suggestedLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        recommendCV_Pane.snp.makeConstraints {
            $0.top.equalTo(suggestedLabel_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(96)
        }

        // 聊天区块
        chatsTitleRow_Pane.snp.makeConstraints {
            $0.top.equalTo(recommendCV_Pane.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(22)
        }
        chatsLabel_Pane.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        chatsBadge_Pane.snp.makeConstraints {
            $0.leading.equalTo(chatsLabel_Pane.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(20)
        }
        chatTableView_Pane.snp.makeConstraints {
            $0.top.equalTo(chatsTitleRow_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyView_Pane.snp.makeConstraints {
            $0.edges.equalTo(chatTableView_Pane)
        }
        emptyIconLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
        }
        emptyTitleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(emptyIconLabel_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        emptySubLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel_Pane.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    /// 设置代理
    private func setupDelegates_Pane() {
        recommendCV_Pane.dataSource = self
        recommendCV_Pane.delegate   = self
        chatTableView_Pane.dataSource = self
        chatTableView_Pane.delegate   = self
    }

    // MARK: - 数据加载

    /// 初始化加载所有数据
    private func loadData_Pane() {
        recommendUsers_Pane = Array(LocalData_Pane.shared_Pane.userList_Pane.prefix(10))
        recommendCV_Pane.reloadData()
        refreshChatList_Pane()
    }

    /// 刷新会话列表及徽章
    private func refreshChatList_Pane() {
        chatUsers_Pane = MessageViewModel_Pane.shared_Pane.getChatUsers_Pane()
        chatTableView_Pane.reloadData()
        let count_pane = chatUsers_Pane.count
        emptyView_Pane.isHidden  = count_pane > 0
        chatsBadge_Pane.isHidden = count_pane == 0
        chatsBadge_Pane.text     = "\(count_pane)"
    }

    // MARK: - 通知

    private func setupNotification_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMessageStateChanged_Pane),
            name: MessageViewModel_Pane.messageStateDidChangeNotification_Pane,
            object: nil
        )
    }

    /// 消息状态变更 → 刷新会话列表
    @objc private func onMessageStateChanged_Pane() {
        refreshChatList_Pane()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension MessageList_Pane: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendUsers_Pane.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_pane = collectionView.dequeueReusableCell(
            withReuseIdentifier: MsgRecommendCell_Pane.reuseId_Pane,
            for: indexPath
        ) as! MsgRecommendCell_Pane
        cell_pane.configure_Pane(user_pane: recommendUsers_Pane[indexPath.item])
        return cell_pane
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Pane.toMessageUser_Pane(with: recommendUsers_Pane[indexPath.item])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageList_Pane: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Pane.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_pane = tableView.dequeueReusableCell(
            withIdentifier: MsgSessionCell_Pane.reuseId_Pane,
            for: indexPath
        ) as! MsgSessionCell_Pane
        let user_pane    = chatUsers_Pane[indexPath.row]
        let lastMsg_pane = MessageViewModel_Pane.shared_Pane.getLastMessageWithUser_Pane(
            userId_pane: user_pane.userId_Pane ?? 0
        )
        cell_pane.configure_Pane(user_pane: user_pane, lastMessage_pane: lastMsg_pane)
        return cell_pane
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Pane.toMessageUser_Pane(with: chatUsers_Pane[indexPath.row])
    }
}

// MARK: - MsgRecommendCell_Pane

/// 推荐用户 Cell（横向滚动）
/// 核心作用：使用 UserAvatarView_Pane 展示用户头像（自带在线状态指示 + 默认颜色区分）
///          + 昵称截断显示；点击跳转聊天页
private class MsgRecommendCell_Pane: UICollectionViewCell {

    static let reuseId_Pane = "MsgRecommendCell_Pane"

    /// UserAvatarView 头像组件（支持 assets / 本地文件 / 网络 / 默认彩色占位）
    private let avatarView_Pane = UserAvatarView_Pane()

    /// 昵称
    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.textAlignment = .center
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(avatarView_Pane)
        contentView.addSubview(nameLabel_Pane)

        avatarView_Pane.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        nameLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(avatarView_Pane.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置推荐用户数据
    /// - Parameter user_pane: 预制用户模型
    func configure_Pane(user_pane: PrewUserModel_Pane) {
        nameLabel_Pane.text = user_pane.userName_Pane
        // UserAvatarView_Pane 通过 userId 自动加载头像并区分颜色
        avatarView_Pane.configure_Pane(userId_Pane: user_pane.userId_Pane ?? 0)
    }
}

// MARK: - MsgSessionCell_Pane

/// 聊天会话 Cell（纵向列表）
/// 核心作用：卡片式布局展示用户头像（渐变细环）、昵称、最后消息预览、时间
/// 关键属性：
/// - cardView_Pane: 圆角阴影卡片容器
/// - lastMsgLabel_Pane: 最后一条消息预览（单行截断）
private class MsgSessionCell_Pane: UITableViewCell {

    static let reuseId_Pane = "MsgSessionCell_Pane"

    /// 卡片容器
    private let cardView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 20
        v.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 3)
        v.layer.shadowRadius  = 8
        return v
    }()

    /// 渐变外环容器
    private let ringView_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    private var ringGradient_Pane: CAGradientLayer?

    /// 头像
    private let avatarImageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        iv.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        return iv
    }()

    /// 昵称
    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 最后一条消息预览
    private let lastMsgLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.numberOfLines = 1
        return l
    }()

    /// 时间
    private let timeLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .right
        return l
    }()

    /// 未读消息装饰点
    private let unreadDot_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane
        v.layer.cornerRadius = 4
        v.isHidden = true
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        contentView.addSubview(cardView_Pane)
        cardView_Pane.addSubview(ringView_Pane)
        ringView_Pane.addSubview(avatarImageView_Pane)
        cardView_Pane.addSubview(nameLabel_Pane)
        cardView_Pane.addSubview(lastMsgLabel_Pane)
        cardView_Pane.addSubview(timeLabel_Pane)
        cardView_Pane.addSubview(unreadDot_Pane)

        cardView_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        ringView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(52)
        }
        avatarImageView_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        nameLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(ringView_Pane.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalTo(timeLabel_Pane.snp.leading).offset(-8)
        }
        lastMsgLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Pane)
            $0.top.equalTo(nameLabel_Pane.snp.bottom).offset(4)
            $0.trailing.equalTo(unreadDot_Pane.snp.leading).offset(-8)
        }
        timeLabel_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(16)
            $0.width.equalTo(44)
        }
        unreadDot_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-18)
            $0.centerY.equalTo(lastMsgLabel_Pane)
            $0.width.height.equalTo(8)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 绘制渐变细环
        ringGradient_Pane?.removeFromSuperlayer()
        let gl_pane = CAGradientLayer()
        gl_pane.frame        = ringView_Pane.bounds
        gl_pane.colors       = [
            ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.75).cgColor,
            ColorConfig_Pane.secondaryGradientStart_Pane.alpha_Pane(0.75).cgColor
        ]
        gl_pane.startPoint   = CGPoint(x: 0, y: 0)
        gl_pane.endPoint     = CGPoint(x: 1, y: 1)
        gl_pane.cornerRadius = 26
        ringView_Pane.layer.insertSublayer(gl_pane, at: 0)
        ringGradient_Pane = gl_pane
    }

    /// 配置会话 Cell
    /// - Parameters:
    ///   - user_pane: 对话用户模型
    ///   - lastMessage_pane: 最后一条消息（可为空）
    func configure_Pane(user_pane: PrewUserModel_Pane, lastMessage_pane: MessageModel_Pane?) {
        nameLabel_Pane.text    = user_pane.userName_Pane
        lastMsgLabel_Pane.text = lastMessage_pane?.content_Pane ?? "Say hi 👋"
        timeLabel_Pane.text    = lastMessage_pane?.time_Pane ?? ""
        if let head_pane = user_pane.userHead_Pane {
            avatarImageView_Pane.image = UIImage(named: head_pane)
        }
    }
}
