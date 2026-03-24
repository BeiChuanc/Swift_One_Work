import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 消息列表页

/// 消息列表页面
/// 核心作用：展示推荐用户横向列表和存在聊天记录的用户会话列表
/// 设计思路：沉浸式渐变头部，推荐用户横向大卡片，聊天记录带颜色标识
/// 关键属性/方法：
///   - suggestedUsers_Base_one：推荐用户数据（来自LocalData）
///   - chatUsers_Base_one：有聊天记录的用户（来自MessageViewModel）
///   - reloadData_Base_one()：响应通知刷新所有数据
class MessageList_Base_one: UIViewController {

    // MARK: - 私有数据属性

    /// 推荐用户列表（排除当前登录用户）
    private var suggestedUsers_Base_one: [PrewUserModel_Base_one] = []

    /// 有聊天记录的用户列表
    private var chatUsers_Base_one: [PrewUserModel_Base_one] = []

    // MARK: - UI组件 - 主滚动容器

    /// 主滚动视图
    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        /// 禁止系统自动追加安全区 inset，避免顶部出现多余空白
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    /// 内容容器
    private let contentContainer_Base_one = UIView()

    // MARK: - UI组件 - 顶部头部

    /// 头部渐变卡片容器（圆角底部）
    /// 兜底背景色：渐变图层未就绪时保持主题色可见
    private let headerCard_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.primaryGradientStart_Base_one
        v.layer.cornerRadius = 36
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// 头部渐变图层（延迟创建）
    private var headerGradient_Base_one: CAGradientLayer?

    /// 头部装饰气泡1
    private let decoBubble1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰气泡2
    private let decoBubble2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 36
        return v
    }()

    /// 页面主标题
    private let pageTitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Messages"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        return l
    }()

    /// 头部副标题
    private let pageSubtitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Stay connected with the world"
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return l
    }()

    /// 头部消息图标装饰
    private let headerIconView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.layer.cornerRadius = 22
        return v
    }()

    private let headerIconImage_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI组件 - 推荐用户横向区域

    /// 推荐区块标题行
    private let suggestedHeaderRow_Base_one: UIView = UIView()

    /// 推荐区块标题
    private let suggestedTitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Suggested"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return l
    }()

    /// 推荐用户数量胶囊角标
    private let suggestedCountBadge_Base_one: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textAlignment = .center
        l.layer.cornerRadius = 11
        l.clipsToBounds = true
        return l
    }()

    /// 推荐用户横向滚动视图
    private let suggestedScrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    /// 推荐用户横向StackView
    private let suggestedStackView_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        return sv
    }()

    // MARK: - UI组件 - 聊天记录区域

    /// 聊天标题行
    private let chatsHeaderRow_Base_one: UIView = UIView()

    /// 聊天记录区块标题
    private let chatsTitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Recent Chats"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return l
    }()

    /// 聊天记录列表容器
    private let chatsContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 聊天记录TableView（嵌入容器卡片）
    private let chatsTableView_Base_one: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ChatListCell_Base_one.self, forCellReuseIdentifier: ChatListCell_Base_one.reuseId_Base_one)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.rowHeight = 80
        tv.layer.cornerRadius = 24
        return tv
    }()

    /// 空状态视图（无聊天记录时显示）
    private let emptyChatsView_Base_one: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyChatsIconBg_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()

    private var emptyIconBgGradient_Base_one: CAGradientLayer?

    private let emptyChatsIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyChatsLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "No conversations yet"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = ColorConfig_Base_one.textPrimary_Base_one
        l.textAlignment = .center
        return l
    }()

    private let emptyChatsSubLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Start chatting with someone above ✨"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Base_one()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        setupConstraints_Base_one()
        observeStateChanges_Base_one()
        reloadData_Base_one()
        /// 强制完成一次布局，使 ScrollView 内容 frame 就绪，渐变图层可立即创建
        view.layoutIfNeeded()
        updateHeaderGradient_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradient_Base_one()
        updateEmptyIconGradient_Base_one()
        updateSuggestedBadgeGradient_Base_one()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// ScrollView 内容在首次 viewDidLayoutSubviews 时 frame 可能未就绪
        /// 在视图完全出现后强制刷新渐变，确保头部首次显示正常
        updateHeaderGradient_Base_one()
    }

    // MARK: - UI搭建

    /// 搭建所有UI组件
    private func setupUI_Base_one() {
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one

        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentContainer_Base_one)

        /// 头部渐变卡片
        contentContainer_Base_one.addSubview(headerCard_Base_one)
        headerCard_Base_one.addSubview(decoBubble1_Base_one)
        headerCard_Base_one.addSubview(decoBubble2_Base_one)
        headerCard_Base_one.addSubview(pageTitleLabel_Base_one)
        headerCard_Base_one.addSubview(pageSubtitleLabel_Base_one)
        headerCard_Base_one.addSubview(headerIconView_Base_one)
        headerIconView_Base_one.addSubview(headerIconImage_Base_one)

        /// 推荐用户区域
        contentContainer_Base_one.addSubview(suggestedHeaderRow_Base_one)
        suggestedHeaderRow_Base_one.addSubview(suggestedTitleLabel_Base_one)
        suggestedHeaderRow_Base_one.addSubview(suggestedCountBadge_Base_one)
        contentContainer_Base_one.addSubview(suggestedScrollView_Base_one)
        suggestedScrollView_Base_one.addSubview(suggestedStackView_Base_one)

        /// 聊天记录区域
        contentContainer_Base_one.addSubview(chatsHeaderRow_Base_one)
        chatsHeaderRow_Base_one.addSubview(chatsTitleLabel_Base_one)
        contentContainer_Base_one.addSubview(chatsContainer_Base_one)
        chatsContainer_Base_one.addSubview(chatsTableView_Base_one)
        chatsContainer_Base_one.addSubview(emptyChatsView_Base_one)
        emptyChatsView_Base_one.addSubview(emptyChatsIconBg_Base_one)
        emptyChatsIconBg_Base_one.addSubview(emptyChatsIcon_Base_one)
        emptyChatsView_Base_one.addSubview(emptyChatsLabel_Base_one)
        emptyChatsView_Base_one.addSubview(emptyChatsSubLabel_Base_one)

        chatsTableView_Base_one.delegate = self
        chatsTableView_Base_one.dataSource = self
    }

    // MARK: - 约束布局

    /// 设置SnapKit约束
    private func setupConstraints_Base_one() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentContainer_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }

        /// 头部卡片（高度减小）
        headerCard_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 90)
        }

        decoBubble1_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(140)
        }

        decoBubble2_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(30)
            make.width.height.equalTo(110)
        }

        /// 消息图标装饰（右侧独立锚定）
        headerIconView_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(44)
        }

        headerIconImage_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        pageTitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalTo(pageSubtitleLabel_Base_one.snp.top).offset(-4)
        }

        pageSubtitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-18)
        }

        /// 推荐标题行
        suggestedHeaderRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Base_one.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        suggestedTitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        suggestedCountBadge_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(suggestedTitleLabel_Base_one.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(26)
        }

        /// 推荐用户滚动区域
        suggestedScrollView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(suggestedHeaderRow_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(112)
        }

        suggestedStackView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(suggestedScrollView_Base_one)
        }

        /// 聊天标题行
        chatsHeaderRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(suggestedScrollView_Base_one.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        chatsTitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        /// 聊天记录容器
        chatsContainer_Base_one.snp.makeConstraints { make in
            make.top.equalTo(chatsHeaderRow_Base_one.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-100)
        }

        chatsTableView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyChatsView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(180)
        }

        emptyChatsIconBg_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.width.height.equalTo(72)
        }

        emptyChatsIcon_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }

        emptyChatsLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(emptyChatsIconBg_Base_one.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        emptyChatsSubLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(emptyChatsLabel_Base_one.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 渐变更新

    /// 更新头部渐变
    private func updateHeaderGradient_Base_one() {
        guard headerCard_Base_one.bounds.width > 0 else { return }
        if headerGradient_Base_one == nil {
            let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: headerCard_Base_one.bounds)
            grad.cornerRadius = 36
            grad.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            headerCard_Base_one.layer.insertSublayer(grad, at: 0)
            headerGradient_Base_one = grad
        } else {
            headerGradient_Base_one?.frame = headerCard_Base_one.bounds
        }
    }

    /// 更新空状态图标背景渐变
    private func updateEmptyIconGradient_Base_one() {
        guard emptyChatsIconBg_Base_one.bounds.width > 0,
              emptyIconBgGradient_Base_one == nil else { return }
        let grad = UIColor.createSecondaryGradientLayer_Base_one(frame_Base_one: emptyChatsIconBg_Base_one.bounds)
        grad.cornerRadius = 36
        emptyChatsIconBg_Base_one.layer.insertSublayer(grad, at: 0)
        emptyIconBgGradient_Base_one = grad
    }

    /// 更新推荐数量角标渐变背景
    private func updateSuggestedBadgeGradient_Base_one() {
        guard suggestedCountBadge_Base_one.bounds.width > 0,
              suggestedCountBadge_Base_one.layer.sublayers?.contains(where: { $0 is CAGradientLayer }) != true else { return }
        let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: suggestedCountBadge_Base_one.bounds)
        grad.cornerRadius = 11
        suggestedCountBadge_Base_one.layer.insertSublayer(grad, at: 0)
    }

    // MARK: - 响应式状态监听

    /// 注册通知，响应用户和消息状态变化
    private func observeStateChanges_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Base_one),
            name: MessageViewModel_Base_one.messageStateDidChangeNotification_Base_one, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Base_one),
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one, object: nil
        )
    }

    @objc private func handleStateChange_Base_one() {
        reloadData_Base_one()
    }

    // MARK: - 数据刷新

    /// 重新加载所有数据并更新UI
    private func reloadData_Base_one() {
        let currentUserId = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one().userId_Base_one ?? 0
        suggestedUsers_Base_one = LocalData_Base_one.shared_Base_one.userList_Base_one.filter {
            $0.userId_Base_one != currentUserId
        }
        chatUsers_Base_one = MessageViewModel_Base_one.shared_Base_one.getChatUsers_Base_one()

        refreshSuggestedUsers_Base_one()
        suggestedCountBadge_Base_one.text = "  \(suggestedUsers_Base_one.count)  "
        chatsTableView_Base_one.reloadData()
        updateChatsHeight_Base_one()
        updateEmptyState_Base_one()
    }

    /// 刷新推荐用户横向卡片列表
    private func refreshSuggestedUsers_Base_one() {
        suggestedStackView_Base_one.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for user in suggestedUsers_Base_one {
            let item = makeSuggestedCard_Base_one(user: user)
            suggestedStackView_Base_one.addArrangedSubview(item)
        }
    }

    /// 更新聊天TableView高度
    private func updateChatsHeight_Base_one() {
        let tableHeight = max(180, CGFloat(chatUsers_Base_one.count) * 80)
        chatsTableView_Base_one.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(tableHeight)
        }
    }

    /// 更新空状态视图显示
    private func updateEmptyState_Base_one() {
        let isEmpty = chatUsers_Base_one.isEmpty
        emptyChatsView_Base_one.isHidden = !isEmpty
        chatsTableView_Base_one.isHidden = isEmpty
        if isEmpty { emptyChatsView_Base_one.animateFadeIn_Base_one() }
    }

    // MARK: - 推荐用户卡片创建

    /// 创建推荐用户卡片（带头像、昵称和简介）
    /// - Parameter user: 用户模型
    /// - Returns: 完整卡片视图
    private func makeSuggestedCard_Base_one(user: PrewUserModel_Base_one) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 1
        card.isUserInteractionEnabled = true

        /// 渐变环背景（头像外圈）
        let ringView = UIView()
        ringView.layer.cornerRadius = 28
        ringView.clipsToBounds = true
        card.addSubview(ringView)

        let ringGrad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: CGRect(x: 0, y: 0, width: 56, height: 56))
        ringGrad.cornerRadius = 28
        ringView.layer.addSublayer(ringGrad)

        /// UserAvatarView_Base_one 头像组件
        let avatarView = UserAvatarView_Base_one()
        avatarView.layer.cornerRadius = 23
        avatarView.clipsToBounds = true
        ringView.addSubview(avatarView)

        /// 在线状态小绿点
        let dotView = UIView()
        dotView.backgroundColor = UIColor(hexstring_Base_one: "#48BB78")
        dotView.layer.cornerRadius = 6
        dotView.layer.borderWidth = 2
        dotView.layer.borderColor = UIColor.white.cgColor
        card.addSubview(dotView)

        /// 昵称标签（截断保护）
        let nameLabel = UILabel()
        nameLabel.text = user.userName_Base_one ?? "User"
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        nameLabel.textColor = ColorConfig_Base_one.textPrimary_Base_one
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        card.addSubview(nameLabel)

        /// 约束
        ringView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        avatarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(46)
        }

        dotView.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(ringView).offset(2)
            make.width.height.equalTo(14)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(ringView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().offset(-12)
        }

        card.snp.makeConstraints { make in
            make.width.equalTo(90)
        }

        /// 配置头像
        if let userId = user.userId_Base_one {
            avatarView.configure_Base_one(userId_Base_one: userId)
        }

        /// 点击跳转聊天
        let tap = SuggestedUserTap_Base_one(userModel: user, target: self, action: #selector(suggestedUserTapped_Base_one(_:)))
        card.addGestureRecognizer(tap)

        return card
    }

    @objc private func suggestedUserTapped_Base_one(_ gesture: SuggestedUserTap_Base_one) {
        guard let user = gesture.userModel_Base_one else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let card = gesture.view {
            card.animatePressDown_Base_one { card.animatePressUp_Base_one() }
        }
        /// 点击推荐用户进入用户中心页面
        Navigation_Base_one.toUserInfo_Base_one(with: user)
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Base_one: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Base_one.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatListCell_Base_one.reuseId_Base_one, for: indexPath
        ) as! ChatListCell_Base_one
        let user = chatUsers_Base_one[indexPath.row]
        let lastMsg = MessageViewModel_Base_one.shared_Base_one.getLastMessageWithUser_Base_one(
            userId_base_one: user.userId_Base_one ?? 0
        )
        cell.configure_Base_one(user: user, lastMessage: lastMsg, colorIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = chatUsers_Base_one[indexPath.row]
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Base_one.toMessageUser_Base_one(with: user)
    }
}

// MARK: - 自定义点击手势（携带用户模型）

/// 携带用户模型的点击手势（推荐卡片使用）
private class SuggestedUserTap_Base_one: UITapGestureRecognizer {
    var userModel_Base_one: PrewUserModel_Base_one?
    convenience init(userModel: PrewUserModel_Base_one, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.userModel_Base_one = userModel
    }
}

// MARK: - 聊天列表Cell

/// 聊天列表Cell
/// 功能：展示用户头像（带渐变环）、昵称、最后一条消息预览及时间
/// 设计：左侧彩色竖条区分不同用户，右侧箭头提示，在线绿点
class ChatListCell_Base_one: UITableViewCell {

    static let reuseId_Base_one = "ChatListCell_Base_one"

    /// 头像外圈渐变环容器
    private let avatarRingView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradient_Base_one: CAGradientLayer?

    /// UserAvatarView_Base_one 头像组件
    private let avatarView_Base_one: UserAvatarView_Base_one = {
        let v = UserAvatarView_Base_one()
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        return v
    }()

    /// 在线状态绿点
    private let onlineDot_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Base_one: "#48BB78")
        v.layer.cornerRadius = 7
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 左侧彩色细条（视觉区分）
    private let accentBar_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    private var accentBarGradient_Base_one: CAGradientLayer?

    /// 用户昵称
    private let nameLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return l
    }()

    /// 最后一条消息预览
    private let lastMsgLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.numberOfLines = 1
        return l
    }()

    /// 时间标签
    private let timeLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return l
    }()

    /// 右侧箭头
    private let arrowIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 底部分割线
    private let divider_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Base_one()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI搭建

    private func setupCellUI_Base_one() {
        contentView.addSubview(accentBar_Base_one)
        contentView.addSubview(avatarRingView_Base_one)
        avatarRingView_Base_one.addSubview(avatarView_Base_one)
        contentView.addSubview(onlineDot_Base_one)
        contentView.addSubview(nameLabel_Base_one)
        contentView.addSubview(lastMsgLabel_Base_one)
        contentView.addSubview(timeLabel_Base_one)
        contentView.addSubview(arrowIcon_Base_one)
        contentView.addSubview(divider_Base_one)

        accentBar_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(40)
        }

        avatarRingView_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Base_one.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        avatarView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }

        onlineDot_Base_one.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarRingView_Base_one).offset(2)
            make.width.height.equalTo(16)
        }

        arrowIcon_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        timeLabel_Base_one.snp.makeConstraints { make in
            make.trailing.equalTo(arrowIcon_Base_one.snp.leading).offset(-6)
            make.top.equalToSuperview().offset(18)
        }

        nameLabel_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(avatarRingView_Base_one.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel_Base_one.snp.leading).offset(-8)
        }

        lastMsgLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Base_one.snp.bottom).offset(5)
            make.leading.equalTo(avatarRingView_Base_one.snp.trailing).offset(12)
            make.trailing.equalTo(arrowIcon_Base_one.snp.leading).offset(-8)
        }

        divider_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Base_one.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    // MARK: - 配置数据

    /// 配置Cell内容
    /// - Parameters:
    ///   - user: 用户模型
    ///   - lastMessage: 最后一条消息
    ///   - colorIndex: 颜色索引（用于左侧彩条和渐变环颜色区分）
    func configure_Base_one(user: PrewUserModel_Base_one, lastMessage: MessageModel_Base_one?, colorIndex: Int) {
        nameLabel_Base_one.text = user.userName_Base_one ?? "User"
        lastMsgLabel_Base_one.text = lastMessage?.content_Base_one ?? "Tap to start chatting..."
        timeLabel_Base_one.text = lastMessage?.time_Base_one ?? ""

        if let userId = user.userId_Base_one {
            avatarView_Base_one.configure_Base_one(userId_Base_one: userId)
        }

        /// 根据索引选择渐变颜色（主渐变或辅助渐变交替）
        let usePrimary = colorIndex % 2 == 0

        /// 头像渐变环
        avatarRingGradient_Base_one?.removeFromSuperlayer()
        let ringGrad = usePrimary
            ? UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: avatarRingView_Base_one.bounds)
            : UIColor.createSecondaryGradientLayer_Base_one(frame_Base_one: avatarRingView_Base_one.bounds)
        ringGrad.cornerRadius = 30
        avatarRingView_Base_one.layer.insertSublayer(ringGrad, at: 0)
        avatarRingGradient_Base_one = ringGrad

        /// 左侧细条渐变
        accentBarGradient_Base_one?.removeFromSuperlayer()
        let barGrad = usePrimary
            ? UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: accentBar_Base_one.bounds)
            : UIColor.createSecondaryGradientLayer_Base_one(frame_Base_one: accentBar_Base_one.bounds)
        barGrad.cornerRadius = 2
        accentBar_Base_one.layer.insertSublayer(barGrad, at: 0)
        accentBarGradient_Base_one = barGrad
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarRingGradient_Base_one?.frame = avatarRingView_Base_one.bounds
        accentBarGradient_Base_one?.frame = accentBar_Base_one.bounds
    }
}
