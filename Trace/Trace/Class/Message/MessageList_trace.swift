import UIKit
import SnapKit

// MARK: - 消息列表 Section

private enum MsgListSection_Trace: Int, CaseIterable {
    case header_trace   = 0  // 顶部描述区
    case discover_trace = 1
    case chats_trace    = 2
}

// MARK: - 消息列表页

/// 消息列表页视图控制器
/// 核心作用：展示「Discover People」推荐用户横向卡片 + 「Conversations」聊天记录列表
/// 设计思路：UICollectionView Compositional Layout 两分区，推荐用户水平滚动，聊天列表垂直排布
/// 关键属性：chatUsers_Trace（有聊天记录的用户），allUsers_Trace（推荐用户列表）
class MessageList_Trace: UIViewController {
    
    // MARK: - 私有属性
    
    private var allUsers_Trace: [PrewUserModel_Trace] = []
    private var chatUsers_Trace: [PrewUserModel_Trace] = []
    
    // MARK: - UI 组件
    
    private lazy var collectionView_Trace: UICollectionView = {
        let cv_Trace = UICollectionView(frame: .zero, collectionViewLayout: createLayout_Trace())
        cv_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        cv_Trace.showsVerticalScrollIndicator = false
        cv_Trace.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        cv_Trace.dataSource = self
        cv_Trace.delegate = self
        cv_Trace.register(MsgHeaderDescCell_Trace.self, forCellWithReuseIdentifier: MsgHeaderDescCell_Trace.reuseId_Trace)
        cv_Trace.register(MsgDiscoverCell_Trace.self, forCellWithReuseIdentifier: MsgDiscoverCell_Trace.reuseId_Trace)
        cv_Trace.register(MsgChatRowCell_Trace.self, forCellWithReuseIdentifier: MsgChatRowCell_Trace.reuseId_Trace)
        cv_Trace.register(MsgChatEmptyCell_Trace.self, forCellWithReuseIdentifier: MsgChatEmptyCell_Trace.reuseId_Trace)
        cv_Trace.register(MsgSectionHeaderView_Trace.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MsgSectionHeaderView_Trace.reuseId_Trace)
        return cv_Trace
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation_Trace()
        setupUI_Trace()
        subscribeNotifications_Trace()
        loadData_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 覆盖 navigationController 内部状态
        // 直接设置 navigationBar.isHidden 无法覆盖 setNavigationBarHidden 设置的状态
        navigationController?.setNavigationBarHidden(false, animated: animated)
        loadData_Trace()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // push 到 MessageUser 时不隐藏（两者都需要导航栏可见）
        // 当导航栈 pop 回 TabBar 时由 TabBar.viewWillAppear 负责隐藏
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 导航栏配置
    
    private func setupNavigation_Trace() {
        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: ColorConfig_Trace.textPrimary_Trace
        ]
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(handleComposeTap_Trace)
        )
        navigationController?.navigationBar.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        view.addSubview(collectionView_Trace)
        collectionView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
    
    // MARK: - 数据加载
    
    private func loadData_Trace() {
        allUsers_Trace = LocalData_Trace.shared_Trace.userList_Trace
        chatUsers_Trace = MessageViewModel_Trace.shared_Trace.getChatUsers_Trace()
        collectionView_Trace.reloadData()
    }
    
    private func subscribeNotifications_Trace() {
        // 聊天记录变化（发消息/清空等）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMsgStateChange_Trace),
            name: MessageViewModel_Trace.messageStateDidChangeNotification_Trace,
            object: nil
        )
        // 用户状态变化（举报/拉黑后异步移除完成）→ 重载推荐用户列表
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Trace),
            name: UserViewModel_Trace.userStateDidChangeNotification_Trace,
            object: nil
        )
    }
    
    // MARK: - Compositional Layout
    
    private func createLayout_Trace() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex_trace, _ in
            guard let self = self,
                  let section_trace = MsgListSection_Trace(rawValue: sectionIndex_trace) else { return nil }
            switch section_trace {
            case .header_trace:   return self.createHeaderDescSection_Trace()
            case .discover_trace: return self.createDiscoverSection_Trace()
            case .chats_trace:    return self.createChatsSection_Trace()
            }
        }
    }
    
    /// 顶部描述区分区（固定高度 90pt）
    private func createHeaderDescSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 4, trailing: 20)
        return section_Trace
    }
    
    /// 推荐用户横向滑动分区（每卡 160pt 宽 × 200pt 高）
    private func createDiscoverSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(200))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(200)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.orthogonalScrollingBehavior = .continuous
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 8, trailing: 20)
        section_Trace.interGroupSpacing = 12
        
        let header_Trace = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section_Trace.boundarySupplementaryItems = [header_Trace]
        return section_Trace
    }
    
    /// 聊天列表分区（全宽，72pt 每行）
    private func createChatsSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(72))
        )
        let group_Trace = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(72)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let header_Trace = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section_Trace.boundarySupplementaryItems = [header_Trace]
        return section_Trace
    }
    
    // MARK: - 事件处理
    
    @objc private func handleComposeTap_Trace() {
        // 暂时跳转到第一个推荐用户
        if let firstUser_Trace = allUsers_Trace.first {
            Navigation_Trace.toMessageUser_Trace(with: firstUser_Trace)
        }
    }
    
    @objc private func handleMsgStateChange_Trace() {
        loadData_Trace()
    }
    
    /// 用户状态变化通知（举报/拉黑后触发），重新加载推荐用户列表以移除已屏蔽用户
    @objc private func handleUserStateChange_Trace() {
        loadData_Trace()
    }
}

// MARK: - UICollectionViewDataSource

extension MessageList_Trace: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MsgListSection_Trace.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sec_Trace = MsgListSection_Trace(rawValue: section) else { return 0 }
        switch sec_Trace {
        case .header_trace:   return 1
        case .discover_trace: return allUsers_Trace.count
        case .chats_trace:    return max(1, chatUsers_Trace.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sec_Trace = MsgListSection_Trace(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sec_Trace {
        case .header_trace:
            return collectionView.dequeueReusableCell(withReuseIdentifier: MsgHeaderDescCell_Trace.reuseId_Trace, for: indexPath)
            
        case .discover_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: MsgDiscoverCell_Trace.reuseId_Trace, for: indexPath) as! MsgDiscoverCell_Trace
            cell_Trace.configure_Trace(user_trace: allUsers_Trace[indexPath.item])
            cell_Trace.onMessageTapped_Trace = { [weak self] user_trace in
                Navigation_Trace.toMessageUser_Trace(with: user_trace)
            }
            cell_Trace.onReportTapped_Trace = { [weak self] user_trace in
                guard let self = self else { return }
                // 调用统一举报/拉黑流程，确认后从推荐列表移除并刷新
                ReportDeleteHelper_Trace.block_Trace(user_Trace: user_trace, from: self) { [weak self] in
                    guard let self = self else { return }
                    self.allUsers_Trace.removeAll { $0.userId_Trace == user_trace.userId_Trace }
                    self.collectionView_Trace.reloadSections(IndexSet(integer: MsgListSection_Trace.discover_trace.rawValue))
                }
            }
            return cell_Trace
            
        case .chats_trace:
            if chatUsers_Trace.isEmpty {
                return collectionView.dequeueReusableCell(withReuseIdentifier: MsgChatEmptyCell_Trace.reuseId_Trace, for: indexPath)
            }
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: MsgChatRowCell_Trace.reuseId_Trace, for: indexPath) as! MsgChatRowCell_Trace
            let user_Trace = chatUsers_Trace[indexPath.item]
            let lastMsg_Trace = MessageViewModel_Trace.shared_Trace.getLastMessageWithUser_Trace(userId_trace: user_Trace.userId_Trace ?? 0)
            cell_Trace.configure_Trace(user_trace: user_Trace, lastMessage_trace: lastMsg_Trace)
            return cell_Trace
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header_Trace = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MsgSectionHeaderView_Trace.reuseId_Trace, for: indexPath) as! MsgSectionHeaderView_Trace
        guard let sec_Trace = MsgListSection_Trace(rawValue: indexPath.section) else { return header_Trace }
        switch sec_Trace {
        case .header_trace:
            break
        case .discover_trace:
            header_Trace.configure_Trace(title_trace: "Discover People", subtitle_trace: "\(allUsers_Trace.count) creators")
        case .chats_trace:
            let count_Trace = chatUsers_Trace.count
            header_Trace.configure_Trace(title_trace: "Conversations", subtitle_trace: count_Trace > 0 ? "\(count_Trace) active" : "No chats yet")
        }
        return header_Trace
    }
}

// MARK: - UICollectionViewDelegate

extension MessageList_Trace: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sec_Trace = MsgListSection_Trace(rawValue: indexPath.section),
              sec_Trace == .chats_trace,
              !chatUsers_Trace.isEmpty else { return }
        Navigation_Trace.toMessageUser_Trace(with: chatUsers_Trace[indexPath.item])
    }
}

// MARK: - Section Header 视图

/// 消息列表分区标题视图
private class MsgSectionHeaderView_Trace: UICollectionReusableView {
    
    static let reuseId_Trace = "MsgSectionHeaderView_Trace"
    
    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()
    
    private let subtitleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel_Trace)
        addSubview(subtitleLabel_Trace)
        titleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-4)
        }
        subtitleLabel_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel_Trace)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Trace(title_trace: String, subtitle_trace: String) {
        titleLabel_Trace.text = title_trace
        subtitleLabel_Trace.text = subtitle_trace
    }
}

// MARK: - 推荐用户卡片 Cell

/// 推荐用户卡片 Cell（Discover People 横向区）
/// 功能：展示用户头像（渐变圆环）、昵称、简介、Message 按钮，右上角举报按钮
private class MsgDiscoverCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "MsgDiscoverCell_Trace"
    
    private var user_Trace: PrewUserModel_Trace?
    /// 点击 Message 按钮的回调，参数为对应用户模型
    var onMessageTapped_Trace: ((PrewUserModel_Trace) -> Void)?
    /// 点击举报按钮的回调，参数为对应用户模型
    var onReportTapped_Trace: ((PrewUserModel_Trace) -> Void)?
    
    private let cardView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Trace.layer.shadowRadius = 12
        v_Trace.layer.shadowOpacity = 0.07
        return v_Trace
    }()
    
    /// 用户头像（UserAvatarView_Trace 自动加载真实头像）
    private let avatarView_Trace = UserAvatarView_Trace()
    
    private let nameLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl_Trace.textAlignment = .center
        lbl_Trace.numberOfLines = 1
        return lbl_Trace
    }()
    
    private let bioLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl_Trace.textAlignment = .center
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    private lazy var messageBtn_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.setTitle("Message", for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn_Trace.setTitleColor(ColorConfig_Trace.primaryGradientStart_Trace, for: .normal)
        btn_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.1)
        btn_Trace.layer.cornerRadius = 12
        btn_Trace.layer.masksToBounds = true
        btn_Trace.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        btn_Trace.addTarget(self, action: #selector(handleMessageTap_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    /// 右上角举报按钮（椭圆三点图标，使用 ReportDeleteHelper_Trace 统一风格）
    private lazy var reportBtn_Trace: UIButton = {
        let btn_Trace = ReportDeleteHelper_Trace.createUserReportButton_Trace(
            size_Trace: 26,
            backgroundColor_Trace: ColorConfig_Trace.textSecondary_Trace.withAlphaComponent(0.08),
            tintColor_Trace: ColorConfig_Trace.textSecondary_Trace,
            withShadow_Trace: false
        )
        btn_Trace.addTarget(self, action: #selector(handleReportTap_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Trace() {
        contentView.addSubview(cardView_Trace)
        cardView_Trace.addSubview(avatarView_Trace)
        cardView_Trace.addSubview(nameLabel_Trace)
        cardView_Trace.addSubview(bioLabel_Trace)
        cardView_Trace.addSubview(messageBtn_Trace)
        cardView_Trace.addSubview(reportBtn_Trace)

        cardView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        // 举报按钮固定在卡片右上角
        reportBtn_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        avatarView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        nameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        bioLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Trace.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        messageBtn_Trace.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(bioLabel_Trace.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-14)
            make.centerX.equalToSuperview()
        }
    }

    func configure_Trace(user_trace: PrewUserModel_Trace) {
        user_Trace = user_trace
        avatarView_Trace.configure_Trace(userId_Trace: user_trace.userId_Trace ?? 0)
        nameLabel_Trace.text = user_trace.userName_Trace ?? "User"
        bioLabel_Trace.text = user_trace.userIntroduce_Trace ?? ""
    }
    
    @objc private func handleMessageTap_Trace() {
        guard let user_Trace = user_Trace else { return }
        messageBtn_Trace.animatePressDown_Trace { self.messageBtn_Trace.animatePressUp_Trace() }
        onMessageTapped_Trace?(user_Trace)
    }
    
    /// 举报按钮点击：通知外部处理举报/拉黑逻辑
    @objc private func handleReportTap_Trace() {
        guard let user_Trace = user_Trace else { return }
        onReportTapped_Trace?(user_Trace)
    }
}

// MARK: - 聊天记录行 Cell

/// 聊天记录列表行 Cell
/// 功能：展示用户头像、昵称、最后一条消息内容、消息时间、未读标记
private class MsgChatRowCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "MsgChatRowCell_Trace"
    
    /// 用户头像（UserAvatarView_Trace 自动加载真实头像）
    private let avatarView_Trace = UserAvatarView_Trace()
    
    private let nameLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()
    
    private let lastMsgLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl_Trace.numberOfLines = 1
        return lbl_Trace
    }()
    
    private let timeLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()
    
    private let divider_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = ColorConfig_Trace.divider_Trace
        return v_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Trace() {
        contentView.backgroundColor = .white
        contentView.addSubview(avatarView_Trace)
        contentView.addSubview(nameLabel_Trace)
        contentView.addSubview(lastMsgLabel_Trace)
        contentView.addSubview(timeLabel_Trace)
        contentView.addSubview(divider_Trace)

        avatarView_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        timeLabel_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(16)
        }
        nameLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Trace.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel_Trace.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(14)
        }
        lastMsgLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_Trace)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(nameLabel_Trace.snp.bottom).offset(4)
        }
        divider_Trace.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_Trace)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func configure_Trace(user_trace: PrewUserModel_Trace, lastMessage_trace: MessageModel_Trace?) {
        avatarView_Trace.configure_Trace(userId_Trace: user_trace.userId_Trace ?? 0)
        nameLabel_Trace.text = user_trace.userName_Trace ?? "User"
        if let msg_Trace = lastMessage_trace {
            let prefix_Trace = (msg_Trace.isMine_Trace == true) ? "You: " : ""
            lastMsgLabel_Trace.text = "\(prefix_Trace)\(msg_Trace.content_Trace ?? "")"
            timeLabel_Trace.text = msg_Trace.time_Trace ?? ""
        } else {
            lastMsgLabel_Trace.text = "Start a conversation"
            timeLabel_Trace.text = ""
        }
    }
}

// MARK: - 聊天列表空状态 Cell

private class MsgChatEmptyCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "MsgChatEmptyCell_Trace"
    
    private let iconView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        iv_Trace.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: config_Trace)
        iv_Trace.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    private let hintLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "No conversations yet.\nDiscover people above and start chatting!"
        lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl_Trace.textAlignment = .center
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconView_Trace)
        contentView.addSubview(hintLabel_Trace)
        iconView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        hintLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(iconView_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 消息列表顶部描述 Cell

/// 消息列表顶部描述区 Cell
/// 核心作用：以图标 + 主标题 + 副标题 + 徽章行形式，传达「消息」功能的主题氛围
/// 设计思路：与发布页顶部描述保持统一风格，无卡片背景，轻量融入页面
private class MsgHeaderDescCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "MsgHeaderDescCell_Trace"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    /// 搭建描述区布局：图标圆 + 主标题 + 副标题 + 徽章行
    private func setupUI_Trace() {
        
        // 图标背景圆
        let iconBg_Trace = UIView()
        iconBg_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.12)
        iconBg_Trace.layer.cornerRadius = 24
        
        let iconIV_Trace = UIImageView()
        let iconCfg_Trace = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconIV_Trace.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: iconCfg_Trace)
        iconIV_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        iconIV_Trace.contentMode = .scaleAspectFit
        
        // 主标题
        let titleLbl_Trace = UILabel()
        titleLbl_Trace.text = "Your Connections"
        titleLbl_Trace.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        
        // 副标题
        let subLbl_Trace = UILabel()
        subLbl_Trace.text = "Discover new voices, start a conversation, and keep every trace alive."
        subLbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subLbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        subLbl_Trace.numberOfLines = 2
        
        // 徽章行
        let badgeStack_Trace = UIStackView()
        badgeStack_Trace.axis = .horizontal
        badgeStack_Trace.spacing = 6
        badgeStack_Trace.alignment = .center
        ["✦ Discover", "✦ Connect", "✦ Resonate"].forEach { text_trace in
            let badge_Trace = UILabel()
            badge_Trace.text = text_trace
            badge_Trace.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
            badge_Trace.textColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.7)
            badgeStack_Trace.addArrangedSubview(badge_Trace)
        }
        
        contentView.addSubview(iconBg_Trace)
        iconBg_Trace.addSubview(iconIV_Trace)
        contentView.addSubview(titleLbl_Trace)
        contentView.addSubview(subLbl_Trace)
        contentView.addSubview(badgeStack_Trace)
        
        iconBg_Trace.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(48)
        }
        iconIV_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLbl_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Trace.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.equalTo(iconBg_Trace.snp.top).offset(2)
        }
        subLbl_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Trace.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLbl_Trace.snp.bottom).offset(4)
        }
        badgeStack_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Trace.snp.trailing).offset(12)
            make.top.equalTo(subLbl_Trace.snp.bottom).offset(6)
        }
    }
}
