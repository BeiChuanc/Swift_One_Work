import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 消息列表页

/// 消息列表页面
/// 核心作用：展示推荐用户横向列表和存在聊天记录的用户会话列表
/// 设计思路：沉浸式渐变头部，推荐用户横向大卡片，聊天记录带颜色标识
/// 关键属性/方法：
///   - suggestedUsers_Tidy：推荐用户数据（来自LocalData）
///   - chatUsers_Tidy：有聊天记录的用户（来自MessageViewModel）
///   - reloadData_Tidy()：响应通知刷新所有数据
class MessageList_Tidy: UIViewController {

    // MARK: - 私有数据属性

    /// 推荐用户列表（排除当前登录用户）
    private var suggestedUsers_Tidy: [PrewUserModel_Tidy] = []

    /// 有聊天记录的用户列表
    private var chatUsers_Tidy: [PrewUserModel_Tidy] = []

    // MARK: - UI组件 - 主滚动容器

    /// 主滚动视图
    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        /// 禁止系统自动追加安全区 inset，避免顶部出现多余空白
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    /// 内容容器
    private let contentContainer_Tidy = UIView()

    // MARK: - UI组件 - 顶部头部

    /// 头部渐变卡片容器（圆角底部）
    /// 兜底背景色：渐变图层未就绪时保持主题色可见
    private let headerCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        v.layer.cornerRadius = 36
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// 头部渐变图层（延迟创建）
    private var headerGradient_Tidy: CAGradientLayer?

    /// 头部装饰气泡1
    private let decoBubble1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰气泡2
    private let decoBubble2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 36
        return v
    }()

    /// 页面主标题
    private let pageTitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Messages"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        return l
    }()

    /// 头部副标题
    private let pageSubtitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Stay connected with the world"
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return l
    }()

    /// 头部消息图标装饰
    private let headerIconView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.layer.cornerRadius = 22
        return v
    }()

    private let headerIconImage_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI组件 - 推荐用户横向区域

    /// 推荐区块标题行
    private let suggestedHeaderRow_Tidy: UIView = UIView()

    /// 推荐区块标题
    private let suggestedTitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Suggested"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return l
    }()

    /// 推荐用户数量胶囊角标
    private let suggestedCountBadge_Tidy: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textAlignment = .center
        l.layer.cornerRadius = 11
        l.clipsToBounds = true
        return l
    }()

    /// 推荐用户横向滚动视图
    private let suggestedScrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    /// 推荐用户横向StackView
    private let suggestedStackView_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        return sv
    }()

    // MARK: - UI组件 - 聊天记录区域

    /// 聊天标题行
    private let chatsHeaderRow_Tidy: UIView = UIView()

    /// 聊天记录区块标题
    private let chatsTitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Recent Chats"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return l
    }()

    /// 聊天记录列表容器
    private let chatsContainer_Tidy: UIView = {
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
    private let chatsTableView_Tidy: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ChatListCell_Tidy.self, forCellReuseIdentifier: ChatListCell_Tidy.reuseId_Tidy)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.rowHeight = 80
        tv.layer.cornerRadius = 24
        return tv
    }()

    /// 空状态视图（无聊天记录时显示）
    private let emptyChatsView_Tidy: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyChatsIconBg_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()

    private var emptyIconBgGradient_Tidy: CAGradientLayer?

    private let emptyChatsIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyChatsLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "No conversations yet"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        l.textAlignment = .center
        return l
    }()

    private let emptyChatsSubLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Start chatting with someone above ✨"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Tidy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        setupConstraints_Tidy()
        observeStateChanges_Tidy()
        reloadData_Tidy()
        /// 强制完成一次布局，使 ScrollView 内容 frame 就绪，渐变图层可立即创建
        view.layoutIfNeeded()
        updateHeaderGradient_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradient_Tidy()
        updateEmptyIconGradient_Tidy()
        updateSuggestedBadgeGradient_Tidy()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// ScrollView 内容在首次 viewDidLayoutSubviews 时 frame 可能未就绪
        /// 在视图完全出现后强制刷新渐变，确保头部首次显示正常
        updateHeaderGradient_Tidy()
    }

    // MARK: - UI搭建

    /// 搭建所有UI组件
    private func setupUI_Tidy() {
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy

        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentContainer_Tidy)

        /// 头部渐变卡片
        contentContainer_Tidy.addSubview(headerCard_Tidy)
        headerCard_Tidy.addSubview(decoBubble1_Tidy)
        headerCard_Tidy.addSubview(decoBubble2_Tidy)
        headerCard_Tidy.addSubview(pageTitleLabel_Tidy)
        headerCard_Tidy.addSubview(pageSubtitleLabel_Tidy)
        headerCard_Tidy.addSubview(headerIconView_Tidy)
        headerIconView_Tidy.addSubview(headerIconImage_Tidy)

        /// 推荐用户区域
        contentContainer_Tidy.addSubview(suggestedHeaderRow_Tidy)
        suggestedHeaderRow_Tidy.addSubview(suggestedTitleLabel_Tidy)
        suggestedHeaderRow_Tidy.addSubview(suggestedCountBadge_Tidy)
        contentContainer_Tidy.addSubview(suggestedScrollView_Tidy)
        suggestedScrollView_Tidy.addSubview(suggestedStackView_Tidy)

        /// 聊天记录区域
        contentContainer_Tidy.addSubview(chatsHeaderRow_Tidy)
        chatsHeaderRow_Tidy.addSubview(chatsTitleLabel_Tidy)
        contentContainer_Tidy.addSubview(chatsContainer_Tidy)
        chatsContainer_Tidy.addSubview(chatsTableView_Tidy)
        chatsContainer_Tidy.addSubview(emptyChatsView_Tidy)
        emptyChatsView_Tidy.addSubview(emptyChatsIconBg_Tidy)
        emptyChatsIconBg_Tidy.addSubview(emptyChatsIcon_Tidy)
        emptyChatsView_Tidy.addSubview(emptyChatsLabel_Tidy)
        emptyChatsView_Tidy.addSubview(emptyChatsSubLabel_Tidy)

        chatsTableView_Tidy.delegate = self
        chatsTableView_Tidy.dataSource = self
    }

    // MARK: - 约束布局

    /// 设置SnapKit约束
    private func setupConstraints_Tidy() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentContainer_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }

        /// 头部卡片（高度减小）
        headerCard_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 90)
        }

        decoBubble1_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(140)
        }

        decoBubble2_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(30)
            make.width.height.equalTo(110)
        }

        /// 消息图标装饰（右侧独立锚定）
        headerIconView_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(44)
        }

        headerIconImage_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        pageTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalTo(pageSubtitleLabel_Tidy.snp.top).offset(-4)
        }

        pageSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-18)
        }

        /// 推荐标题行
        suggestedHeaderRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Tidy.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        suggestedTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        suggestedCountBadge_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(suggestedTitleLabel_Tidy.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(26)
        }

        /// 推荐用户滚动区域
        suggestedScrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(suggestedHeaderRow_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(112)
        }

        suggestedStackView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(suggestedScrollView_Tidy)
        }

        /// 聊天标题行
        chatsHeaderRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(suggestedScrollView_Tidy.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        chatsTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        /// 聊天记录容器
        chatsContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(chatsHeaderRow_Tidy.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-100)
        }

        chatsTableView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyChatsView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(180)
        }

        emptyChatsIconBg_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.width.height.equalTo(72)
        }

        emptyChatsIcon_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }

        emptyChatsLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emptyChatsIconBg_Tidy.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        emptyChatsSubLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emptyChatsLabel_Tidy.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 渐变更新

    /// 更新头部渐变
    private func updateHeaderGradient_Tidy() {
        guard headerCard_Tidy.bounds.width > 0 else { return }
        if headerGradient_Tidy == nil {
            let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: headerCard_Tidy.bounds)
            grad.cornerRadius = 36
            grad.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            headerCard_Tidy.layer.insertSublayer(grad, at: 0)
            headerGradient_Tidy = grad
        } else {
            headerGradient_Tidy?.frame = headerCard_Tidy.bounds
        }
    }

    /// 更新空状态图标背景渐变
    private func updateEmptyIconGradient_Tidy() {
        guard emptyChatsIconBg_Tidy.bounds.width > 0,
              emptyIconBgGradient_Tidy == nil else { return }
        let grad = UIColor.createSecondaryGradientLayer_Tidy(frame_Tidy: emptyChatsIconBg_Tidy.bounds)
        grad.cornerRadius = 36
        emptyChatsIconBg_Tidy.layer.insertSublayer(grad, at: 0)
        emptyIconBgGradient_Tidy = grad
    }

    /// 更新推荐数量角标渐变背景
    private func updateSuggestedBadgeGradient_Tidy() {
        guard suggestedCountBadge_Tidy.bounds.width > 0,
              suggestedCountBadge_Tidy.layer.sublayers?.contains(where: { $0 is CAGradientLayer }) != true else { return }
        let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: suggestedCountBadge_Tidy.bounds)
        grad.cornerRadius = 11
        suggestedCountBadge_Tidy.layer.insertSublayer(grad, at: 0)
    }

    // MARK: - 响应式状态监听

    /// 注册通知，响应用户和消息状态变化
    private func observeStateChanges_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Tidy),
            name: MessageViewModel_Tidy.messageStateDidChangeNotification_Tidy, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy, object: nil
        )
    }

    @objc private func handleStateChange_Tidy() {
        reloadData_Tidy()
    }

    // MARK: - 数据刷新

    /// 重新加载所有数据并更新UI
    private func reloadData_Tidy() {
        let currentUserId = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy().userId_Tidy ?? 0
        suggestedUsers_Tidy = LocalData_Tidy.shared_Tidy.userList_Tidy.filter {
            $0.userId_Tidy != currentUserId
        }
        chatUsers_Tidy = MessageViewModel_Tidy.shared_Tidy.getChatUsers_Tidy()

        refreshSuggestedUsers_Tidy()
        suggestedCountBadge_Tidy.text = "  \(suggestedUsers_Tidy.count)  "
        chatsTableView_Tidy.reloadData()
        updateChatsHeight_Tidy()
        updateEmptyState_Tidy()
    }

    /// 刷新推荐用户横向卡片列表
    private func refreshSuggestedUsers_Tidy() {
        suggestedStackView_Tidy.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for user in suggestedUsers_Tidy {
            let item = makeSuggestedCard_Tidy(user: user)
            suggestedStackView_Tidy.addArrangedSubview(item)
        }
    }

    /// 更新聊天TableView高度
    private func updateChatsHeight_Tidy() {
        let tableHeight = max(180, CGFloat(chatUsers_Tidy.count) * 80)
        chatsTableView_Tidy.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(tableHeight)
        }
    }

    /// 更新空状态视图显示
    private func updateEmptyState_Tidy() {
        let isEmpty = chatUsers_Tidy.isEmpty
        emptyChatsView_Tidy.isHidden = !isEmpty
        chatsTableView_Tidy.isHidden = isEmpty
        if isEmpty { emptyChatsView_Tidy.animateFadeIn_Tidy() }
    }

    // MARK: - 推荐用户卡片创建

    /// 创建推荐用户卡片（带头像、昵称和简介）
    /// - Parameter user: 用户模型
    /// - Returns: 完整卡片视图
    private func makeSuggestedCard_Tidy(user: PrewUserModel_Tidy) -> UIView {
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

        let ringGrad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: CGRect(x: 0, y: 0, width: 56, height: 56))
        ringGrad.cornerRadius = 28
        ringView.layer.addSublayer(ringGrad)

        /// UserAvatarView_Tidy 头像组件
        let avatarView = UserAvatarView_Tidy()
        avatarView.layer.cornerRadius = 23
        avatarView.clipsToBounds = true
        ringView.addSubview(avatarView)

        /// 在线状态小绿点
        let dotView = UIView()
        dotView.backgroundColor = UIColor(hexstring_Tidy: "#48BB78")
        dotView.layer.cornerRadius = 6
        dotView.layer.borderWidth = 2
        dotView.layer.borderColor = UIColor.white.cgColor
        card.addSubview(dotView)

        /// 昵称标签（截断保护）
        let nameLabel = UILabel()
        nameLabel.text = user.userName_Tidy ?? "User"
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        nameLabel.textColor = ColorConfig_Tidy.textPrimary_Tidy
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
        if let userId = user.userId_Tidy {
            avatarView.configure_Tidy(userId_Tidy: userId)
        }

        /// 点击跳转聊天
        let tap = SuggestedUserTap_Tidy(userModel: user, target: self, action: #selector(suggestedUserTapped_Tidy(_:)))
        card.addGestureRecognizer(tap)

        return card
    }

    @objc private func suggestedUserTapped_Tidy(_ gesture: SuggestedUserTap_Tidy) {
        guard let user = gesture.userModel_Tidy else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let card = gesture.view {
            card.animatePressDown_Tidy { card.animatePressUp_Tidy() }
        }
        /// 点击推荐用户进入用户中心页面
        Navigation_Tidy.toUserInfo_Tidy(with: user)
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Tidy: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Tidy.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatListCell_Tidy.reuseId_Tidy, for: indexPath
        ) as! ChatListCell_Tidy
        let user = chatUsers_Tidy[indexPath.row]
        let lastMsg = MessageViewModel_Tidy.shared_Tidy.getLastMessageWithUser_Tidy(
            userId_tidy: user.userId_Tidy ?? 0
        )
        cell.configure_Tidy(user: user, lastMessage: lastMsg, colorIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = chatUsers_Tidy[indexPath.row]
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Tidy.toMessageUser_Tidy(with: user)
    }
}

// MARK: - 自定义点击手势（携带用户模型）

/// 携带用户模型的点击手势（推荐卡片使用）
private class SuggestedUserTap_Tidy: UITapGestureRecognizer {
    var userModel_Tidy: PrewUserModel_Tidy?
    convenience init(userModel: PrewUserModel_Tidy, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.userModel_Tidy = userModel
    }
}

// MARK: - 聊天列表Cell

/// 聊天列表Cell
/// 功能：展示用户头像（带渐变环）、昵称、最后一条消息预览及时间
/// 设计：左侧彩色竖条区分不同用户，右侧箭头提示，在线绿点
class ChatListCell_Tidy: UITableViewCell {

    static let reuseId_Tidy = "ChatListCell_Tidy"

    /// 头像外圈渐变环容器
    private let avatarRingView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradient_Tidy: CAGradientLayer?

    /// UserAvatarView_Tidy 头像组件
    private let avatarView_Tidy: UserAvatarView_Tidy = {
        let v = UserAvatarView_Tidy()
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        return v
    }()

    /// 在线状态绿点
    private let onlineDot_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#48BB78")
        v.layer.cornerRadius = 7
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 左侧彩色细条（视觉区分）
    private let accentBar_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    private var accentBarGradient_Tidy: CAGradientLayer?

    /// 用户昵称
    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return l
    }()

    /// 最后一条消息预览
    private let lastMsgLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.numberOfLines = 1
        return l
    }()

    /// 时间标签
    private let timeLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return l
    }()

    /// 右侧箭头
    private let arrowIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 底部分割线
    private let divider_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Tidy()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI搭建

    private func setupCellUI_Tidy() {
        contentView.addSubview(accentBar_Tidy)
        contentView.addSubview(avatarRingView_Tidy)
        avatarRingView_Tidy.addSubview(avatarView_Tidy)
        contentView.addSubview(onlineDot_Tidy)
        contentView.addSubview(nameLabel_Tidy)
        contentView.addSubview(lastMsgLabel_Tidy)
        contentView.addSubview(timeLabel_Tidy)
        contentView.addSubview(arrowIcon_Tidy)
        contentView.addSubview(divider_Tidy)

        accentBar_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(40)
        }

        avatarRingView_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Tidy.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        avatarView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }

        onlineDot_Tidy.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarRingView_Tidy).offset(2)
            make.width.height.equalTo(16)
        }

        arrowIcon_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        timeLabel_Tidy.snp.makeConstraints { make in
            make.trailing.equalTo(arrowIcon_Tidy.snp.leading).offset(-6)
            make.top.equalToSuperview().offset(18)
        }

        nameLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(avatarRingView_Tidy.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel_Tidy.snp.leading).offset(-8)
        }

        lastMsgLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Tidy.snp.bottom).offset(5)
            make.leading.equalTo(avatarRingView_Tidy.snp.trailing).offset(12)
            make.trailing.equalTo(arrowIcon_Tidy.snp.leading).offset(-8)
        }

        divider_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Tidy.snp.trailing).offset(12)
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
    func configure_Tidy(user: PrewUserModel_Tidy, lastMessage: MessageModel_Tidy?, colorIndex: Int) {
        nameLabel_Tidy.text = user.userName_Tidy ?? "User"
        lastMsgLabel_Tidy.text = lastMessage?.content_Tidy ?? "Tap to start chatting..."
        timeLabel_Tidy.text = lastMessage?.time_Tidy ?? ""

        if let userId = user.userId_Tidy {
            avatarView_Tidy.configure_Tidy(userId_Tidy: userId)
        }

        /// 根据索引选择渐变颜色（主渐变或辅助渐变交替）
        let usePrimary = colorIndex % 2 == 0

        /// 头像渐变环
        avatarRingGradient_Tidy?.removeFromSuperlayer()
        let ringGrad = usePrimary
            ? UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: avatarRingView_Tidy.bounds)
            : UIColor.createSecondaryGradientLayer_Tidy(frame_Tidy: avatarRingView_Tidy.bounds)
        ringGrad.cornerRadius = 30
        avatarRingView_Tidy.layer.insertSublayer(ringGrad, at: 0)
        avatarRingGradient_Tidy = ringGrad

        /// 左侧细条渐变
        accentBarGradient_Tidy?.removeFromSuperlayer()
        let barGrad = usePrimary
            ? UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: accentBar_Tidy.bounds)
            : UIColor.createSecondaryGradientLayer_Tidy(frame_Tidy: accentBar_Tidy.bounds)
        barGrad.cornerRadius = 2
        accentBar_Tidy.layer.insertSublayer(barGrad, at: 0)
        accentBarGradient_Tidy = barGrad
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarRingGradient_Tidy?.frame = avatarRingView_Tidy.bounds
        accentBarGradient_Tidy?.frame = accentBar_Tidy.bounds
    }
}
