import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面 - 重构版 v2

/// 消息列表控制器
/// 核心作用：渐变头部（含在线人数）+ 横向推荐用户（含在线状态点）+ 纵向会话卡片
/// 设计思路：薰衣草紫 → 天空蓝渐变色系，与首页/我的页统一；卡片层次感、在线指示点、
///           渐变圆环头像、消息徽章等元素丰富视觉细节
class MessageList_Retrs: UIViewController {

    // MARK: - 属性

    private let messageVM_Retrs = MessageViewModel_Retrs.shared_Retrs
    private let userVM_Retrs    = UserViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 渐变头部
    private let headerView_Retrs       = UIView()
    private let headerGradLayer_Retrs  = CAGradientLayer()
    private let headerTitleLabel_Retrs = UILabel()
    private let headerSubLabel_Retrs   = UILabel()
    private let onlineBadge_Retrs      = UIView()
    private let onlineLabel_Retrs      = UILabel()

    /// 推荐用户区
    private let sectionRecommend_Retrs = UIView()
    private let recommendCollection_Retrs: UICollectionView = {
        let layout_Retrs = UICollectionViewFlowLayout()
        layout_Retrs.scrollDirection = .horizontal
        layout_Retrs.minimumLineSpacing = 14
        layout_Retrs.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return UICollectionView(frame: .zero, collectionViewLayout: layout_Retrs)
    }()

    /// 会话列表区
    private let sectionConversation_Retrs = UIView()
    private let chatTableView_Retrs       = UITableView()

    private var recommendUsers_Retrs: [PrewUserModel_Retrs] = []
    private var chatUsers_Retrs: [PrewUserModel_Retrs]      = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData_Retrs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupRecommendSection_Retrs()
        setupConversationSection_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        reloadData_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.backgroundColor = .clear
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
        contentView_Retrs.backgroundColor = .clear
    }

    // MARK: - 渐变头部

    /// 头部：薰衣草紫渐变 + 标题 + 副标题 + 在线人数徽章 + 气泡装饰
    private func setupHeaderView_Retrs() {
        headerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 30
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡
        addDecorBubble_Retrs(alpha_Retrs: 0.13, size_Retrs: 150, top_Retrs: -40, right_Retrs: 20)
        addDecorBubble_Retrs(alpha_Retrs: 0.08, size_Retrs: 85,  bottom_Retrs: 18, left_Retrs: -22)
        addDecorBubble_Retrs(alpha_Retrs: 0.06, size_Retrs: 52,  bottom_Retrs: -8, right_Retrs: 70)

        // 右侧消息图标（带半透明白色圆角背景）
        let iconBg_Retrs = UIView()
        iconBg_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconBg_Retrs.layer.cornerRadius = 26
        iconBg_Retrs.layer.borderWidth  = 1
        iconBg_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        headerView_Retrs.addSubview(iconBg_Retrs)

        let msgIcon_Retrs = UIImageView(
            image: UIImage(systemName: "bubble.left.and.bubble.right.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
        )
        msgIcon_Retrs.tintColor = UIColor.white.withAlphaComponent(0.92)
        msgIcon_Retrs.contentMode = .scaleAspectFit
        iconBg_Retrs.addSubview(msgIcon_Retrs)

        // 主标题
        headerTitleLabel_Retrs.text = "Messages"
        headerTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 30, weight: .black)
        headerTitleLabel_Retrs.textColor = .white
        headerView_Retrs.addSubview(headerTitleLabel_Retrs)

        // 副标题
        headerSubLabel_Retrs.text = "Stay connected with your people"
        headerSubLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        headerSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.75)
        headerView_Retrs.addSubview(headerSubLabel_Retrs)

        // 在线人数徽章（绿点 + 数字）
        onlineBadge_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        onlineBadge_Retrs.layer.cornerRadius = 12
        headerView_Retrs.addSubview(onlineBadge_Retrs)

        let greenDot_Retrs = UIView()
        greenDot_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#68D391")
        greenDot_Retrs.layer.cornerRadius = 4
        onlineBadge_Retrs.addSubview(greenDot_Retrs)
        greenDot_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        onlineLabel_Retrs.text = "0 online"
        onlineLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        onlineLabel_Retrs.textColor = .white
        onlineBadge_Retrs.addSubview(onlineLabel_Retrs)
        onlineLabel_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(greenDot_Retrs.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }

        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        iconBg_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.top.equalToSuperview().offset(safeTop_Retrs + 16)
            make.trailing.equalToSuperview().offset(-22)
        }
        msgIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }
        headerTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Retrs)
            make.leading.equalToSuperview().offset(22)
        }
        headerSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Retrs.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }
        onlineBadge_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerSubLabel_Retrs.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(22)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 向头部添加装饰气泡
    private func addDecorBubble_Retrs(alpha_Retrs: CGFloat, size_Retrs: CGFloat,
                                       top_Retrs: CGFloat? = nil, bottom_Retrs: CGFloat? = nil,
                                       left_Retrs: CGFloat? = nil, right_Retrs: CGFloat? = nil) {
        let b_Retrs = UIView()
        b_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha_Retrs)
        b_Retrs.layer.cornerRadius = size_Retrs / 2
        headerView_Retrs.addSubview(b_Retrs)
        b_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size_Retrs)
            if let t = top_Retrs    { make.top.equalToSuperview().offset(t) }
            if let b = bottom_Retrs { make.bottom.equalToSuperview().offset(b) }
            if let l = left_Retrs   { make.leading.equalToSuperview().offset(l) }
            if let r = right_Retrs  { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 推荐用户区

    private func setupRecommendSection_Retrs() {
        sectionRecommend_Retrs.backgroundColor = .clear
        contentView_Retrs.addSubview(sectionRecommend_Retrs)

        // 区块标题行 + "View All" 链接
        let headerRow_Retrs = makeListSectionHeader_Retrs(
            title_Retrs: "People You May Know",
            icon_Retrs: "person.2.fill",
            accent_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs
        )
        sectionRecommend_Retrs.addSubview(headerRow_Retrs)
        headerRow_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }

        recommendCollection_Retrs.backgroundColor = .clear
        recommendCollection_Retrs.showsHorizontalScrollIndicator = false
        recommendCollection_Retrs.register(RecommendUserCell_Retrs.self,
                                           forCellWithReuseIdentifier: "RecommendUserCell_Retrs")
        recommendCollection_Retrs.dataSource = self
        recommendCollection_Retrs.delegate   = self
        sectionRecommend_Retrs.addSubview(recommendCollection_Retrs)
        recommendCollection_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerRow_Retrs.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(108)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 会话列表区

    private func setupConversationSection_Retrs() {
        sectionConversation_Retrs.backgroundColor = .clear
        contentView_Retrs.addSubview(sectionConversation_Retrs)

        let headerRow_Retrs = makeListSectionHeader_Retrs(
            title_Retrs: "Conversations",
            icon_Retrs: "message.fill",
            accent_Retrs: ColorConfig_Retrs.primaryGradientEnd_Retrs
        )
        sectionConversation_Retrs.addSubview(headerRow_Retrs)
        headerRow_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }

        chatTableView_Retrs.backgroundColor = .clear
        chatTableView_Retrs.separatorStyle  = .none
        chatTableView_Retrs.isScrollEnabled = false
        chatTableView_Retrs.register(ChatListCell_Retrs.self, forCellReuseIdentifier: "ChatListCell_Retrs")
        chatTableView_Retrs.dataSource = self
        chatTableView_Retrs.delegate   = self
        sectionConversation_Retrs.addSubview(chatTableView_Retrs)
        chatTableView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerRow_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
            make.bottom.equalToSuperview()
        }
    }

    /// 创建区块标题行（渐变圆点 + 标题 + 图标）
    /// - Parameters:
    ///   - title_Retrs: 区块标题文本
    ///   - icon_Retrs: SF Symbol 名称
    ///   - accent_Retrs: 强调色
    /// - Returns: 配置好的标题行视图
    private func makeListSectionHeader_Retrs(title_Retrs: String, icon_Retrs: String,
                                              accent_Retrs: UIColor) -> UIView {
        let row_Retrs = UIView()

        // 渐变小圆点
        let dotBg_Retrs = MsgGradView_Retrs(
            colors_Retrs: [ColorConfig_Retrs.primaryGradientStart_Retrs,
                           ColorConfig_Retrs.primaryGradientEnd_Retrs],
            start_Retrs: CGPoint(x: 0, y: 0.5),
            end_Retrs: CGPoint(x: 1, y: 0.5)
        )
        dotBg_Retrs.layer.cornerRadius = 3
        dotBg_Retrs.clipsToBounds = true
        row_Retrs.addSubview(dotBg_Retrs)
        dotBg_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(6)
        }

        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Retrs.textColor = accent_Retrs
        row_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(dotBg_Retrs.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        let iv_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        )
        iv_Retrs.tintColor = accent_Retrs.withAlphaComponent(0.5)
        iv_Retrs.contentMode = .scaleAspectFit
        row_Retrs.addSubview(iv_Retrs)
        iv_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(lbl_Retrs.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
            make.trailing.equalToSuperview()
        }
        return row_Retrs
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width

        scrollView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        sectionRecommend_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview()
        }
        sectionConversation_Retrs.snp.makeConstraints { make in
            make.top.equalTo(sectionRecommend_Retrs.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - 数据加载

    /// 刷新推荐用户列表、会话列表，并更新在线人数徽章
    private func reloadData_Retrs() {
        let allUsers_Retrs  = LocalData_Retrs.shared_Retrs.userList_Retrs
        let currentId_Retrs = userVM_Retrs.getCurrentUser_Retrs().userId_Retrs ?? 0
        recommendUsers_Retrs = allUsers_Retrs.filter { $0.userId_Retrs != currentId_Retrs }
        recommendCollection_Retrs.reloadData()

        // 在线人数：取推荐用户数的随机子集模拟在线状态
        let onlineCount_Retrs = min(recommendUsers_Retrs.count, max(2, recommendUsers_Retrs.count * 2 / 3))
        onlineLabel_Retrs.text = "\(onlineCount_Retrs) online"

        chatUsers_Retrs = messageVM_Retrs.getChatUsers_Retrs()
        chatTableView_Retrs.reloadData()
        updateTableHeight_Retrs()
    }

    private func updateTableHeight_Retrs() {
        let rowH_Retrs: CGFloat = chatUsers_Retrs.isEmpty ? 140 : 86
        let h_Retrs = max(CGFloat(max(chatUsers_Retrs.count, 1)) * rowH_Retrs + 16, 140)
        chatTableView_Retrs.snp.updateConstraints { make in make.height.equalTo(h_Retrs) }
    }

    // MARK: - 通知

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: MessageViewModel_Retrs.messageStateDidChangeNotification_Retrs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: UserViewModel_Retrs.userStateDidChangeNotification_Retrs, object: nil)
    }

    @objc private func onStateChange_Retrs() {
        reloadData_Retrs()
    }
}

// MARK: - CollectionView（推荐用户）

extension MessageList_Retrs: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recommendUsers_Retrs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Retrs = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecommendUserCell_Retrs", for: indexPath) as! RecommendUserCell_Retrs
        cell_Retrs.configure_Retrs(user_Retrs: recommendUsers_Retrs[indexPath.item],
                                   isOnline_Retrs: indexPath.item % 3 != 2)
        return cell_Retrs
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 76, height: 108)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Retrs.toUserInfo_Retrs(with: recommendUsers_Retrs[indexPath.item])
    }
}

// MARK: - TableView（会话列表）

extension MessageList_Retrs: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(chatUsers_Retrs.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatUsers_Retrs.isEmpty {
            return EmptyConversationCell_Retrs(style: .default, reuseIdentifier: nil)
        }
        let cell_Retrs = tableView.dequeueReusableCell(
            withIdentifier: "ChatListCell_Retrs", for: indexPath) as! ChatListCell_Retrs
        let user_Retrs    = chatUsers_Retrs[indexPath.row]
        let lastMsg_Retrs = messageVM_Retrs.getLastMessageWithUser_Retrs(
            userId_retrs: user_Retrs.userId_Retrs ?? 0)
        cell_Retrs.configure_Retrs(user_Retrs: user_Retrs, lastMessage_Retrs: lastMsg_Retrs)
        return cell_Retrs
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatUsers_Retrs.isEmpty ? 140 : 86
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !chatUsers_Retrs.isEmpty else { return }
        Navigation_Retrs.toMessageUser_Retrs(with: chatUsers_Retrs[indexPath.row])
    }
}

// MARK: - 推荐用户单元格

/// 推荐用户横向单元格
/// 功能：渐变圆环头像 + 昵称 + 渐变"Chat"胶囊按钮
class RecommendUserCell_Retrs: UICollectionViewCell {

    private let ringView_Retrs   = MsgGradRingView_Retrs()
    private let avatarView_Retrs = UserAvatarView_Retrs()
    private let nameLabel_Retrs  = UILabel()
    private let chatTagView_Retrs = MsgGradView_Retrs(
        colors_Retrs: [ColorConfig_Retrs.primaryGradientStart_Retrs,
                       ColorConfig_Retrs.primaryGradientEnd_Retrs],
        start_Retrs: CGPoint(x: 0, y: 0.5),
        end_Retrs: CGPoint(x: 1, y: 0.5)
    )
    private let chatTagLabel_Retrs = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        // 渐变圆环（外框）
        contentView.addSubview(ringView_Retrs)
        ringView_Retrs.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(62)
        }

        // 头像
        contentView.addSubview(avatarView_Retrs)
        avatarView_Retrs.snp.makeConstraints { make in
            make.center.equalTo(ringView_Retrs)
            make.width.height.equalTo(54)
        }

        // 昵称（单行截断）
        nameLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        nameLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        nameLabel_Retrs.textAlignment = .center
        nameLabel_Retrs.numberOfLines = 1
        nameLabel_Retrs.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel_Retrs)
        nameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(ringView_Retrs.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(2)
        }

        // 渐变"Chat"胶囊
        chatTagView_Retrs.layer.cornerRadius = 9
        chatTagView_Retrs.clipsToBounds = true
        contentView.addSubview(chatTagView_Retrs)
        chatTagView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Retrs.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
            make.width.equalTo(38)
        }

        chatTagLabel_Retrs.text = "Chat"
        chatTagLabel_Retrs.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        chatTagLabel_Retrs.textColor = .white
        chatTagLabel_Retrs.textAlignment = .center
        chatTagView_Retrs.addSubview(chatTagLabel_Retrs)
        chatTagLabel_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 配置单元格数据
    /// - Parameter user_Retrs: 用户模型
    func configure_Retrs(user_Retrs: PrewUserModel_Retrs, isOnline_Retrs: Bool) {
        avatarView_Retrs.configure_Retrs(userId_Retrs: user_Retrs.userId_Retrs ?? 0)
        nameLabel_Retrs.text = user_Retrs.userName_Retrs ?? ""
    }
}

// MARK: - 会话列表单元格

/// 会话列表行单元格
/// 功能：白色卡片（带色调阴影）+ 渐变圆环头像 + 在线点 + 昵称/时间 + 消息预览 + 箭头
class ChatListCell_Retrs: UITableViewCell {

    private let cardView_Retrs     = UIView()
    private let ringView_Retrs     = MsgGradRingView_Retrs()
    private let avatarView_Retrs   = UserAvatarView_Retrs()
    private let onlineDot_Retrs    = UIView()
    private let nameLabel_Retrs    = UILabel()
    private let timeLabel_Retrs    = UILabel()
    private let lastMsgLabel_Retrs = UILabel()
    private let chevronView_Retrs  = UIImageView()
    private let msgDotView_Retrs   = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        // 白色卡片（薰衣草调阴影）
        cardView_Retrs.backgroundColor = .white
        cardView_Retrs.layer.cornerRadius = 20
        cardView_Retrs.clipsToBounds = false
        cardView_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.14).cgColor
        cardView_Retrs.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView_Retrs.layer.shadowOpacity = 1.0
        cardView_Retrs.layer.shadowRadius  = 14
        contentView.addSubview(cardView_Retrs)
        cardView_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        // 渐变圆环头像
        cardView_Retrs.addSubview(ringView_Retrs)
        ringView_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(58)
        }
        cardView_Retrs.addSubview(avatarView_Retrs)
        avatarView_Retrs.snp.makeConstraints { make in
            make.center.equalTo(ringView_Retrs)
            make.width.height.equalTo(50)
        }

        // 在线绿点
        onlineDot_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#68D391")
        onlineDot_Retrs.layer.cornerRadius = 6
        onlineDot_Retrs.layer.borderWidth  = 2
        onlineDot_Retrs.layer.borderColor  = UIColor.white.cgColor
        cardView_Retrs.addSubview(onlineDot_Retrs)
        onlineDot_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.trailing.equalTo(ringView_Retrs).offset(-1)
            make.bottom.equalTo(ringView_Retrs).offset(-1)
        }

        // 昵称（左）+ 时间（右）同行
        nameLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        nameLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        cardView_Retrs.addSubview(nameLabel_Retrs)
        nameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.leading.equalTo(ringView_Retrs.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-56)
        }

        timeLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        timeLabel_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        timeLabel_Retrs.textAlignment = .right
        cardView_Retrs.addSubview(timeLabel_Retrs)
        timeLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel_Retrs)
            make.trailing.equalToSuperview().offset(-14)
        }

        // 消息预览（单行截断）
        lastMsgLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lastMsgLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        lastMsgLabel_Retrs.numberOfLines = 1
        lastMsgLabel_Retrs.lineBreakMode = .byTruncatingTail
        cardView_Retrs.addSubview(lastMsgLabel_Retrs)
        lastMsgLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Retrs.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Retrs)
            make.trailing.equalToSuperview().offset(-38)
        }

        // 右侧箭头
        chevronView_Retrs.image = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        )
        chevronView_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.4)
        chevronView_Retrs.contentMode = .scaleAspectFit
        cardView_Retrs.addSubview(chevronView_Retrs)
        chevronView_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }

        // 消息指示点（右侧，有消息时显示）
        msgDotView_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        msgDotView_Retrs.layer.cornerRadius = 4
        cardView_Retrs.addSubview(msgDotView_Retrs)
        msgDotView_Retrs.snp.makeConstraints { make in
            make.trailing.equalTo(chevronView_Retrs.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
    }

    /// 配置单元格
    /// - Parameters:
    ///   - user_Retrs: 用户模型
    ///   - lastMessage_Retrs: 最后一条消息（nil 表示无消息）
    func configure_Retrs(user_Retrs: PrewUserModel_Retrs, lastMessage_Retrs: MessageModel_Retrs?) {
        avatarView_Retrs.configure_Retrs(userId_Retrs: user_Retrs.userId_Retrs ?? 0)
        nameLabel_Retrs.text    = user_Retrs.userName_Retrs ?? ""
        timeLabel_Retrs.text    = lastMessage_Retrs?.time_Retrs ?? ""
        lastMsgLabel_Retrs.text = lastMessage_Retrs?.content_Retrs ?? "No messages yet"
        // 有消息则显示指示点
        msgDotView_Retrs.isHidden   = lastMessage_Retrs == nil
        onlineDot_Retrs.isHidden    = (user_Retrs.userId_Retrs ?? 0) % 3 == 2
    }
}

// MARK: - 空状态单元格

/// 无会话时的全幅空状态展示
class EmptyConversationCell_Retrs: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        // 浅紫卡片容器
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EFF3FF")
        card_Retrs.layer.cornerRadius = 20
        contentView.addSubview(card_Retrs)
        card_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        // 渐变图标背景
        let iconBg_Retrs = MsgGradView_Retrs(
            colors_Retrs: [ColorConfig_Retrs.primaryGradientStart_Retrs,
                           ColorConfig_Retrs.primaryGradientEnd_Retrs],
            start_Retrs: CGPoint(x: 0, y: 0), end_Retrs: CGPoint(x: 1, y: 1)
        )
        iconBg_Retrs.layer.cornerRadius = 28
        iconBg_Retrs.clipsToBounds = true
        card_Retrs.addSubview(iconBg_Retrs)
        iconBg_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(22)
            make.width.height.equalTo(56)
        }

        let iconIV_Retrs = UIImageView(
            image: UIImage(systemName: "bubble.left.and.bubble.right.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
        )
        iconIV_Retrs.tintColor = .white
        iconIV_Retrs.contentMode = .scaleAspectFit
        iconBg_Retrs.addSubview(iconIV_Retrs)
        iconIV_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        let titleLbl_Retrs = UILabel()
        titleLbl_Retrs.text = "No Conversations Yet"
        titleLbl_Retrs.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        titleLbl_Retrs.textAlignment = .center
        card_Retrs.addSubview(titleLbl_Retrs)
        titleLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Retrs.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        let subLbl_Retrs = UILabel()
        subLbl_Retrs.text = "Tap on someone's profile to start chatting"
        subLbl_Retrs.font = UIFont.systemFont(ofSize: 11)
        subLbl_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        subLbl_Retrs.textAlignment = .center
        card_Retrs.addSubview(subLbl_Retrs)
        subLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Retrs.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-22)
        }
    }
}

// MARK: - 渐变圆环辅助视图

/// 带中空 mask 的渐变圆环（环宽 4pt，薰衣草紫→天空蓝）
class MsgGradRingView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        gradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
        let ringWidth_Retrs: CGFloat = 3
        let outer_Retrs = UIBezierPath(ovalIn: bounds)
        let inner_Retrs = UIBezierPath(ovalIn: bounds.insetBy(dx: ringWidth_Retrs, dy: ringWidth_Retrs))
        outer_Retrs.append(inner_Retrs)
        outer_Retrs.usesEvenOddFillRule = true
        let mask_Retrs = CAShapeLayer()
        mask_Retrs.path     = outer_Retrs.cgPath
        mask_Retrs.fillRule = .evenOdd
        gradLayer_Retrs.mask = mask_Retrs
    }
}

// MARK: - 渐变填充辅助视图

/// 自动追踪父视图 bounds 的渐变 UIView
class MsgGradView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    /// - Parameters:
    ///   - colors_Retrs: 渐变颜色数组
    ///   - start_Retrs: 渐变起始点（归一化坐标）
    ///   - end_Retrs: 渐变结束点（归一化坐标）
    init(colors_Retrs: [UIColor], start_Retrs: CGPoint, end_Retrs: CGPoint) {
        super.init(frame: .zero)
        gradLayer_Retrs.colors     = colors_Retrs.map { $0.cgColor }
        gradLayer_Retrs.startPoint = start_Retrs
        gradLayer_Retrs.endPoint   = end_Retrs
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
    }
}
