import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页（Premium 森系版）

/// 消息列表视图控制器
/// 核心作用：展示推荐用户 + 会话列表，实时响应消息/用户状态变化
/// 设计思路：深绿沉浸式 Hero（含搜索栏）+ 单色绿系 Story 环 + 彩带左条会话卡片
class MessageList_Sylva: UIViewController {

    // MARK: - 私有属性

    private let scrollView_Sylva = UIScrollView()
    private let contentView_Sylva = UIView()
    private let recommendScrollView_Sylva = UIScrollView()
    private let recommendStack_Sylva = UIStackView()
    private var chatTableView_Sylva: UITableView!
    private let emptyConvView_Sylva = UIView()

    /// Hero 渐变层（需在 layoutSubviews 更新 frame）
    private let heroView_Sylva = UIView()
    private let heroGradient_Sylva = CAGradientLayer()
    /// 渐变层的底部圆角 mask（只裁切渐变层，不影响子视图）
    private let heroGradientMask_Sylva = CAShapeLayer()

    /// 副标题动态内容
    private let heroSubLabel_Sylva = UILabel()

    private var chatUsers_Sylva: [PrewUserModel_Sylva] = []
    private var recommendUsers_Sylva: [PrewUserModel_Sylva] = []

    /// 单色绿系 Story 环颜色（由深到浅，优雅统一）
    private let storyRingColors_Sylva: [UIColor] = [
        UIColor(hexstring_Sylva: "#1B4332"),
        UIColor(hexstring_Sylva: "#2D6A4F"),
        UIColor(hexstring_Sylva: "#40916C"),
        UIColor(hexstring_Sylva: "#52B788"),
        UIColor(hexstring_Sylva: "#74C69D"),
        UIColor(hexstring_Sylva: "#95D5B2")
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupScrollView_Sylva()
        setupHeroHeader_Sylva()
        setupStorySection_Sylva()
        setupConversationSection_Sylva()
        observeNotifications_Sylva()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds_sylva = heroView_Sylva.bounds
        heroGradient_Sylva.frame = bounds_sylva
        // 只对渐变层做底部圆角 mask，heroView 的子视图不受裁切影响
        let path_sylva = UIBezierPath(
            roundedRect: bounds_sylva,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 28, height: 28)
        )
        heroGradientMask_Sylva.path = path_sylva.cgPath
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshData_Sylva()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupScrollView_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        scrollView_Sylva.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)
        scrollView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }

    /// 搭建沉浸式 Hero 头部（渐变 + 在线数据 + 搜索栏）
    private func setupHeroHeader_Sylva() {
        // 渐变：由左上深绿到右下中绿
        heroGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#2D6A4F").cgColor
        ]
        heroGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        heroGradient_Sylva.endPoint   = CGPoint(x: 1, y: 1)
        // 将 mask 挂到渐变层，而非 heroView：
        // 渐变层有底部圆角视觉，但 heroView 不设 clipsToBounds，子视图不被裁切
        heroGradient_Sylva.mask = heroGradientMask_Sylva
        heroView_Sylva.layer.insertSublayer(heroGradient_Sylva, at: 0)

        // heroView 不设圆角也不裁切，避免遮挡底部内容
        contentView_Sylva.addSubview(heroView_Sylva)
        heroView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 160)
        }

        // 右上角半透明装饰圆（几何感）
        let deco1_sylva = UIView()
        deco1_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        deco1_sylva.layer.cornerRadius = 55
        heroView_Sylva.addSubview(deco1_sylva)
        deco1_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview().offset(20)
            make.width.height.equalTo(110)
        }

        let deco2_sylva = UIView()
        deco2_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        deco2_sylva.layer.cornerRadius = 40
        heroView_Sylva.addSubview(deco2_sylva)
        deco2_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-40)
            make.width.height.equalTo(80)
        }

        // 主标题
        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Messages"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        titleLabel_sylva.textColor = .white
        heroView_Sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(view.safeAreaInsets.top + 16)
        }

        // 副标题（在线人数）
        heroSubLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        heroSubLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#95D5B2")
        heroView_Sylva.addSubview(heroSubLabel_Sylva)
        heroSubLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_sylva)
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(4)
        }

        // 在线指示器（薄荷绿点 + 标签）
        let onlinePill_sylva = UIView()
        onlinePill_sylva.backgroundColor = UIColor(hexstring_Sylva: "#52B788").withAlphaComponent(0.25)
        onlinePill_sylva.layer.cornerRadius = 12
        onlinePill_sylva.layer.borderWidth = 1
        onlinePill_sylva.layer.borderColor = UIColor(hexstring_Sylva: "#52B788").withAlphaComponent(0.5).cgColor
        heroView_Sylva.addSubview(onlinePill_sylva)

        let onlineDot_sylva = UIView()
        onlineDot_sylva.backgroundColor = UIColor(hexstring_Sylva: "#52B788")
        onlineDot_sylva.layer.cornerRadius = 4
        onlinePill_sylva.addSubview(onlineDot_sylva)

        let onlineLabel_sylva = UILabel()
        onlineLabel_sylva.text = "5 online"
        onlineLabel_sylva.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        onlineLabel_sylva.textColor = UIColor(hexstring_Sylva: "#52B788")
        onlinePill_sylva.addSubview(onlineLabel_sylva)

        onlinePill_sylva.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_sylva)
            make.top.equalTo(heroSubLabel_Sylva.snp.bottom).offset(10)
            make.height.equalTo(24)
        }
        onlineDot_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        onlineLabel_sylva.snp.makeConstraints { make in
            make.leading.equalTo(onlineDot_sylva.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }

        // 搜索提示框（白色半透明胶囊）
        let searchBar_sylva = UIView()
        searchBar_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        searchBar_sylva.layer.cornerRadius = 14
        searchBar_sylva.layer.borderWidth = 1
        searchBar_sylva.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        heroView_Sylva.addSubview(searchBar_sylva)
        searchBar_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(42)
        }

        let searchIcon_sylva = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon_sylva.tintColor = UIColor.white.withAlphaComponent(0.6)
        searchIcon_sylva.contentMode = .scaleAspectFit
        searchBar_sylva.addSubview(searchIcon_sylva)
        searchIcon_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        let searchHint_sylva = UILabel()
        searchHint_sylva.text = "Search conversations..."
        searchHint_sylva.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        searchHint_sylva.textColor = UIColor.white.withAlphaComponent(0.5)
        searchBar_sylva.addSubview(searchHint_sylva)
        searchHint_sylva.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_sylva.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }

    /// 搭建单色绿系 Story 环推荐区
    private func setupStorySection_Sylva() {
        let sectionLabel_sylva = makeSectionLabel_Sylva("People You May Know")
        contentView_Sylva.addSubview(sectionLabel_sylva)
        sectionLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(heroView_Sylva.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        recommendScrollView_Sylva.showsHorizontalScrollIndicator = false
        recommendScrollView_Sylva.clipsToBounds = false
        recommendScrollView_Sylva.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        contentView_Sylva.addSubview(recommendScrollView_Sylva)
        recommendScrollView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_sylva.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(108)
        }

        recommendStack_Sylva.axis = .horizontal
        recommendStack_Sylva.spacing = 14
        recommendStack_Sylva.alignment = .center
        recommendScrollView_Sylva.addSubview(recommendStack_Sylva)
        recommendStack_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    /// 搭建会话列表区（含空状态）
    private func setupConversationSection_Sylva() {
        let sectionLabel_sylva = makeSectionLabel_Sylva("Conversations")
        contentView_Sylva.addSubview(sectionLabel_sylva)
        sectionLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(recommendScrollView_Sylva.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }

        // 空状态视图
        setupEmptyConversation_Sylva()
        contentView_Sylva.addSubview(emptyConvView_Sylva)
        emptyConvView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(140)
        }

        chatTableView_Sylva = UITableView()
        chatTableView_Sylva.backgroundColor = .clear
        chatTableView_Sylva.separatorStyle = .none
        chatTableView_Sylva.isScrollEnabled = false
        chatTableView_Sylva.dataSource = self
        chatTableView_Sylva.delegate   = self
        chatTableView_Sylva.register(ChatListCell_Sylva.self, forCellReuseIdentifier: ChatListCell_Sylva.reuseId_Sylva)
        contentView_Sylva.addSubview(chatTableView_Sylva)
        chatTableView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_sylva.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    /// 搭建空状态卡片（无会话时展示）
    private func setupEmptyConversation_Sylva() {
        emptyConvView_Sylva.backgroundColor = .white
        emptyConvView_Sylva.layer.cornerRadius = 18
        emptyConvView_Sylva.layer.shadowColor = UIColor.black.cgColor
        emptyConvView_Sylva.layer.shadowOpacity = 0.05
        emptyConvView_Sylva.layer.shadowRadius = 10
        emptyConvView_Sylva.layer.shadowOffset = CGSize(width: 0, height: 3)

        let iconView_sylva = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        iconView_sylva.tintColor = UIColor(hexstring_Sylva: "#B7E4C7")
        iconView_sylva.contentMode = .scaleAspectFit
        emptyConvView_Sylva.addSubview(iconView_sylva)
        iconView_sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.width.height.equalTo(36)
        }

        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "No conversations yet"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel_sylva.textColor = UIColor(hexstring_Sylva: "#2D6A4F")
        titleLabel_sylva.textAlignment = .center
        emptyConvView_Sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(iconView_sylva.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let subLabel_sylva = UILabel()
        subLabel_sylva.text = "Connect with someone from above to start"
        subLabel_sylva.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subLabel_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        subLabel_sylva.textAlignment = .center
        emptyConvView_Sylva.addSubview(subLabel_sylva)
        subLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 辅助

    private func makeSectionLabel_Sylva(_ text: String) -> UILabel {
        let label_sylva = UILabel()
        label_sylva.text = text
        label_sylva.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        return label_sylva
    }

    /// 构建单色绿系 Story 卡片
    private func makeStoryCard_Sylva(user_sylva: PrewUserModel_Sylva, idx_sylva: Int) -> UIView {
        let container_sylva = UIView()
        container_sylva.isUserInteractionEnabled = true

        // 深绿系外环（越靠后越浅）
        let ringColor_sylva = storyRingColors_Sylva[idx_sylva % storyRingColors_Sylva.count]
        let ringView_sylva  = UIView()
        ringView_sylva.backgroundColor = ringColor_sylva
        ringView_sylva.layer.cornerRadius = 32
        container_sylva.addSubview(ringView_sylva)

        // 白色内圈（制造环形）
        let innerView_sylva = UIView()
        innerView_sylva.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        innerView_sylva.layer.cornerRadius = 28.5
        container_sylva.addSubview(innerView_sylva)

        // 头像
        let avatarView_sylva = UserAvatarView_Sylva()
        avatarView_sylva.configure_Sylva(userId_Sylva: user_sylva.userId_Sylva ?? 0)
        avatarView_sylva.layer.cornerRadius = 25
        avatarView_sylva.layer.masksToBounds = true
        container_sylva.addSubview(avatarView_sylva)

        // 绿点
        let dot_sylva = UIView()
        dot_sylva.backgroundColor = UIColor(hexstring_Sylva: "#52B788")
        dot_sylva.layer.cornerRadius = 5.5
        dot_sylva.layer.borderWidth = 2
        dot_sylva.layer.borderColor = UIColor(hexstring_Sylva: "#F7FAFA").cgColor
        container_sylva.addSubview(dot_sylva)

        // 名称
        let nameLabel_sylva = UILabel()
        nameLabel_sylva.text = user_sylva.userName_Sylva ?? ""
        nameLabel_sylva.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        nameLabel_sylva.textColor = UIColor(hexstring_Sylva: "#2D6A4F")
        nameLabel_sylva.textAlignment = .center
        nameLabel_sylva.numberOfLines = 1
        container_sylva.addSubview(nameLabel_sylva)

        ringView_sylva.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        innerView_sylva.snp.makeConstraints { make in
            make.center.equalTo(ringView_sylva)
            make.width.height.equalTo(57)
        }
        avatarView_sylva.snp.makeConstraints { make in
            make.center.equalTo(ringView_sylva)
            make.width.height.equalTo(50)
        }
        dot_sylva.snp.makeConstraints { make in
            make.trailing.equalTo(ringView_sylva.snp.trailing).offset(1)
            make.bottom.equalTo(ringView_sylva.snp.bottom).offset(1)
            make.width.height.equalTo(11)
        }
        nameLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(ringView_sylva.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(storyTapped_Sylva(_:)))
        container_sylva.addGestureRecognizer(tap_sylva)
        container_sylva.tag = user_sylva.userId_Sylva ?? 0
        return container_sylva
    }

    // MARK: - 数据刷新

    private func refreshData_Sylva() {
        recommendUsers_Sylva = UserViewModel_Sylva.shared_Sylva.getRecommendUsers_Sylva()
        chatUsers_Sylva      = MessageViewModel_Sylva.shared_Sylva.getChatUsers_Sylva()
        refreshStoryList_Sylva()
        refreshChatList_Sylva()
        let count_sylva = chatUsers_Sylva.count
        heroSubLabel_Sylva.text = count_sylva > 0
            ? "\(count_sylva) conversations waiting for you"
            : "Ready to connect with nature lovers?"
    }

    private func refreshStoryList_Sylva() {
        recommendStack_Sylva.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx_sylva, user_sylva) in recommendUsers_Sylva.enumerated() {
            let card_sylva = makeStoryCard_Sylva(user_sylva: user_sylva, idx_sylva: idx_sylva)
            recommendStack_Sylva.addArrangedSubview(card_sylva)
            card_sylva.snp.makeConstraints { make in make.width.equalTo(72) }
            card_sylva.animateSpringScaleIn_Sylva(delay_Sylva: 0.05 * Double(idx_sylva))
        }
        let trail_sylva = UIView()
        trail_sylva.snp.makeConstraints { make in make.width.equalTo(4) }
        recommendStack_Sylva.addArrangedSubview(trail_sylva)
    }

    private func refreshChatList_Sylva() {
        let hasConv_sylva = !chatUsers_Sylva.isEmpty
        emptyConvView_Sylva.isHidden = hasConv_sylva
        chatTableView_Sylva.reloadData()
        let height_sylva = hasConv_sylva ? CGFloat(chatUsers_Sylva.count) * 86 : 0
        chatTableView_Sylva.snp.updateConstraints { make in make.height.equalTo(height_sylva) }
    }

    // MARK: - 通知

    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onMessageStateChanged_Sylva),
            name: MessageViewModel_Sylva.messageStateDidChangeNotification_Sylva, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserStateChanged_Sylva),
            name: UserViewModel_Sylva.userStateDidChangeNotification_Sylva, object: nil
        )
    }

    @objc private func onMessageStateChanged_Sylva() {
        chatUsers_Sylva = MessageViewModel_Sylva.shared_Sylva.getChatUsers_Sylva()
        refreshChatList_Sylva()
    }
    @objc private func onUserStateChanged_Sylva() { refreshData_Sylva() }

    @objc private func storyTapped_Sylva(_ gesture: UITapGestureRecognizer) {
        guard let view_sylva = gesture.view else { return }
        let user_sylva = UserViewModel_Sylva.shared_Sylva.getUserById_Sylva(userId_sylva: view_sylva.tag)
        view_sylva.animatePulse_Sylva()
        Navigation_Sylva.toUserInfo_Sylva(with: user_sylva)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Sylva: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Sylva.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_sylva = tableView.dequeueReusableCell(
            withIdentifier: ChatListCell_Sylva.reuseId_Sylva, for: indexPath
        ) as? ChatListCell_Sylva else { return UITableViewCell() }
        let user_sylva   = chatUsers_Sylva[indexPath.row]
        let lastMsg_sylva = MessageViewModel_Sylva.shared_Sylva.getLastMessageWithUser_Sylva(userId_sylva: user_sylva.userId_Sylva ?? 0)
        let ringColor_sylva = storyRingColors_Sylva[indexPath.row % storyRingColors_Sylva.count]
        cell_sylva.configure_Sylva(user_sylva: user_sylva, lastMessage_sylva: lastMsg_sylva, accentColor_sylva: ringColor_sylva)
        return cell_sylva
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 86 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Sylva.toMessageUser_Sylva(with: chatUsers_Sylva[indexPath.row])
    }
}

// MARK: - 会话列表 Cell

/// 会话列表单元格
/// 核心作用：白卡 + 深绿渐变左竖条 + 头像（带在线点）+ 名称/预览/时间/角标
class ChatListCell_Sylva: UITableViewCell {

    static let reuseId_Sylva = "ChatListCell_Sylva"

    private let cardView_Sylva     = UIView()
    private let accentBar_Sylva    = UIView()
    private let avatarView_Sylva   = UserAvatarView_Sylva()
    private let onlineDot_Sylva    = UIView()
    private let nameLabel_Sylva    = UILabel()
    private let previewLabel_Sylva = UILabel()
    private let timeLabel_Sylva    = UILabel()
    private let unreadBadge_Sylva  = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor  = .clear
        selectionStyle   = .none
        setupUI_Sylva()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Sylva() {
        // 白色卡片
        cardView_Sylva.backgroundColor = .white
        cardView_Sylva.layer.cornerRadius = 18
        cardView_Sylva.layer.shadowColor  = UIColor.black.cgColor
        cardView_Sylva.layer.shadowOpacity = 0.05
        cardView_Sylva.layer.shadowRadius  = 10
        cardView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: 3)
        contentView.addSubview(cardView_Sylva)
        cardView_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 左竖条 + 头像 + 在线点 + 名称 + 预览 + 时间 + 角标
        accentBar_Sylva.layer.cornerRadius = 3
        avatarView_Sylva.layer.cornerRadius = 24
        avatarView_Sylva.layer.masksToBounds = true
        onlineDot_Sylva.layer.cornerRadius = 6
        onlineDot_Sylva.backgroundColor  = UIColor(hexstring_Sylva: "#52B788")
        onlineDot_Sylva.layer.borderWidth = 2
        onlineDot_Sylva.layer.borderColor = UIColor.white.cgColor
        nameLabel_Sylva.font    = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        previewLabel_Sylva.font   = UIFont.systemFont(ofSize: 13)
        previewLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        previewLabel_Sylva.numberOfLines = 1
        timeLabel_Sylva.font  = UIFont.systemFont(ofSize: 11)
        timeLabel_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        unreadBadge_Sylva.layer.cornerRadius = 5

        cardView_Sylva.addSubview(accentBar_Sylva)
        cardView_Sylva.addSubview(avatarView_Sylva)
        cardView_Sylva.addSubview(onlineDot_Sylva)
        cardView_Sylva.addSubview(nameLabel_Sylva)
        cardView_Sylva.addSubview(previewLabel_Sylva)
        cardView_Sylva.addSubview(timeLabel_Sylva)
        cardView_Sylva.addSubview(unreadBadge_Sylva)

        accentBar_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        avatarView_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        onlineDot_Sylva.snp.makeConstraints { make in
            make.trailing.equalTo(avatarView_Sylva.snp.trailing).offset(2)
            make.bottom.equalTo(avatarView_Sylva.snp.bottom).offset(2)
            make.width.height.equalTo(12)
        }
        timeLabel_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(18)
        }
        unreadBadge_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(10)
        }
        nameLabel_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(avatarView_Sylva.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel_Sylva.snp.leading).offset(-8)
        }
        previewLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Sylva.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel_Sylva)
            make.trailing.equalTo(unreadBadge_Sylva.snp.leading).offset(-6)
        }
    }

    func configure_Sylva(
        user_sylva: PrewUserModel_Sylva,
        lastMessage_sylva: MessageModel_Sylva?,
        accentColor_sylva: UIColor
    ) {
        avatarView_Sylva.configure_Sylva(userId_Sylva: user_sylva.userId_Sylva ?? 0)
        nameLabel_Sylva.text    = user_sylva.userName_Sylva ?? ""
        previewLabel_Sylva.text = lastMessage_sylva?.content_Sylva ?? "Start a conversation"
        timeLabel_Sylva.text    = lastMessage_sylva?.time_Sylva ?? ""
        accentBar_Sylva.backgroundColor   = accentColor_sylva
        unreadBadge_Sylva.backgroundColor = accentColor_sylva
        unreadBadge_Sylva.isHidden = (lastMessage_sylva == nil)
    }
}
