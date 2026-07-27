import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面视图控制器

/// 消息列表页面视图控制器
/// 功能：上方横向展示推荐创作者，下方列表展示有聊天记录的用户；响应式刷新
/// 设计：渐变导航 + 装饰气泡 + 精美推荐创作者卡片 + 精美会话列表 + 进场动画
/// 逻辑：监听 MessageViewModel/UserViewModel 通知驱动刷新
class MessageList_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary    = UIColor(hexstring_Maki: "#FF8C00")
        static let bg         = UIColor(hexstring_Maki: "#FFFBF4")
        static let card       = UIColor.white
        static let tp         = UIColor(hexstring_Maki: "#1A0A00")
        static let ts         = UIColor(hexstring_Maki: "#8B7355")
        static let suggCellId = "MsgSuggCell_Maki"
        static let chatCellId = "MsgChatCell_Maki"
        static let rowH: CGFloat = 82
    }

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 顶部导航区

    private let navArea_Maki = UIView()
    private let navGrad_Maki = CAGradientLayer()
    private let navBubble1_Maki = UIView()
    private let navBubble2_Maki = UIView()

    // MARK: - UI 属性 / 推荐创作者区

    private let suggSection_Maki = UIView()
    private let suggTitleLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "People You May Know"
        lb_maki.font = .systemFont(ofSize: 16, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        return lb_maki
    }()
    private lazy var suggCV_Maki: UICollectionView = {
        let layout_maki = UICollectionViewFlowLayout()
        layout_maki.scrollDirection = .horizontal
        layout_maki.itemSize = CGSize(width: 80, height: 114)
        layout_maki.minimumInteritemSpacing = 8
        layout_maki.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv_maki = UICollectionView(frame: .zero, collectionViewLayout: layout_maki)
        cv_maki.backgroundColor = .clear
        cv_maki.showsHorizontalScrollIndicator = false
        cv_maki.dataSource = self
        cv_maki.delegate   = self
        cv_maki.tag = 10
        cv_maki.register(MsgSuggCell_Maki.self, forCellWithReuseIdentifier: K_Maki.suggCellId)
        return cv_maki
    }()

    // MARK: - UI 属性 / 会话列表区

    private let convSection_Maki = UIView()
    private let convTitleLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "Messages"
        lb_maki.font = .systemFont(ofSize: 16, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        return lb_maki
    }()
    /// 未读消息角标（右侧装饰性数量泡泡）
    private let unreadBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 10
        v_maki.isHidden = true
        return v_maki
    }()
    private let unreadCountLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 11, weight: .bold)
        lb_maki.textColor = .white
        return lb_maki
    }()
    /// convSection 底部由 tableView 驱动（有会话时激活）
    private var convBottomByTable_Maki: Constraint?
    /// convSection 底部由 emptyView 驱动（无会话时激活）
    private var convBottomByEmpty_Maki: Constraint?
    private let tableView_Maki: UITableView = {
        let tv_maki = UITableView()
        tv_maki.backgroundColor = .clear
        tv_maki.separatorStyle  = .none
        tv_maki.isScrollEnabled = false
        tv_maki.rowHeight       = K_Maki.rowH
        return tv_maki
    }()
    private var tableHeightRef_Maki: Constraint?

    // MARK: - UI 属性 / 空状态视图

    private let emptyView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.isHidden = true
        return v_maki
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
        bindNotifications_Maki()
        reloadAll_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAll_Maki()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGrad_Maki.frame = navArea_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UI 构建

extension MessageList_Maki {

    /// 构建全部 UI 层级
    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildNavArea_Maki()
        buildSuggSection_Maki()
        buildConvSection_Maki()
    }

    /// 构建顶部渐变导航区
    /// 包含：渐变背景、装饰气泡、消息图标、标题、副标题、新建聊天按钮
    private func buildNavArea_Maki() {
        navGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        navGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        navGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        navArea_Maki.layer.insertSublayer(navGrad_Maki, at: 0)
        contentView_Maki.addSubview(navArea_Maki)

        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        navArea_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(statusH_maki + 120)
        }

        // 右上角装饰气泡（大）
        navBubble1_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        navBubble1_Maki.layer.cornerRadius = 55
        navArea_Maki.addSubview(navBubble1_Maki)
        navBubble1_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-22)
        }
        // 左下角装饰气泡（小）
        navBubble2_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        navBubble2_Maki.layer.cornerRadius = 35
        navArea_Maki.addSubview(navBubble2_Maki)
        navBubble2_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.leading.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(18)
        }

        // 消息气泡装饰图标
        let iconIV_maki = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        iconIV_maki.tintColor = UIColor.white.withAlphaComponent(0.3)
        iconIV_maki.contentMode = .scaleAspectFit
        navArea_Maki.addSubview(iconIV_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(statusH_maki + 14)
            make.width.height.equalTo(22)
        }

        // 主标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Messages"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 26)
            ?? .systemFont(ofSize: 26, weight: .bold)
        titleLb_maki.textColor = .white
        navArea_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(10)
            make.centerY.equalTo(iconIV_maki)
        }

        // 副标题
        let subLb_maki = UILabel()
        subLb_maki.text = "Connect with makers around you"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
        navArea_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(5)
        }

        // 在线用户数装饰标签
        let onlineLb_maki = UILabel()
        onlineLb_maki.font = .systemFont(ofSize: 11, weight: .medium)
        onlineLb_maki.textColor = UIColor.white.withAlphaComponent(0.85)

        let onlineDot_maki = UIView()
        onlineDot_maki.backgroundColor = UIColor(hexstring_Maki: "#52C41A")
        onlineDot_maki.layer.cornerRadius = 4

        let creators_maki = LocalData_Maki.shared_Maki.userList_Maki
        onlineLb_maki.text = "\(creators_maki.count) creators online"

        navArea_Maki.addSubview(onlineDot_maki)
        navArea_Maki.addSubview(onlineLb_maki)
        onlineDot_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalTo(subLb_maki.snp.bottom).offset(10)
            make.width.height.equalTo(8)
        }
        onlineLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(onlineDot_maki.snp.trailing).offset(6)
            make.centerY.equalTo(onlineDot_maki)
        }

        // 底部圆角过渡条
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 22
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navArea_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(28)
        }
    }

    /// 构建推荐创作者区（区块标题 + 横向集合视图）
    private func buildSuggSection_Maki() {
        contentView_Maki.addSubview(suggSection_Maki)
        suggSection_Maki.snp.makeConstraints { make in
            make.top.equalTo(navArea_Maki.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
        }

        // 区块标题行（图标 + 文字 + 右侧"See All"）
        let sectionHeader_maki = buildSectionHeader_Maki(
            iconName_maki: "person.2.fill",
            title_maki: "People You May Know"
        )
        suggSection_Maki.addSubview(sectionHeader_maki)
        sectionHeader_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        suggSection_Maki.addSubview(suggCV_Maki)
        suggCV_Maki.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(114)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    /// 构建会话列表区（区块标题 + TableView + 空状态）
    private func buildConvSection_Maki() {
        // 区块分隔线
        let divider_maki = UIView()
        divider_maki.backgroundColor = UIColor(hexstring_Maki: "#F0EDE6")
        contentView_Maki.addSubview(divider_maki)
        divider_maki.snp.makeConstraints { make in
            make.top.equalTo(suggSection_Maki.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        contentView_Maki.addSubview(convSection_Maki)
        convSection_Maki.snp.makeConstraints { make in
            make.top.equalTo(divider_maki.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 区块标题行（带未读数角标）
        let sectionHeader_maki = buildSectionHeader_Maki(
            iconName_maki: "bubble.left.and.bubble.right.fill",
            title_maki: "Recent Chats"
        )
        convSection_Maki.addSubview(sectionHeader_maki)
        sectionHeader_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
        }

        // 未读角标（装饰性）
        unreadBadge_Maki.addSubview(unreadCountLb_Maki)
        convSection_Maki.addSubview(unreadBadge_Maki)
        unreadCountLb_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        unreadBadge_Maki.snp.makeConstraints { make in
            make.leading.equalTo(sectionHeader_maki.snp.trailing).offset(8)
            make.centerY.equalTo(sectionHeader_maki)
            make.height.equalTo(20)
        }

        // TableView
        tableView_Maki.dataSource = self
        tableView_Maki.delegate   = self
        tableView_Maki.register(MsgChatCell_Maki.self, forCellReuseIdentifier: K_Maki.chatCellId)
        convSection_Maki.addSubview(tableView_Maki)
        tableView_Maki.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_maki.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            tableHeightRef_Maki = make.height.equalTo(0).constraint
            // 有会话时由此约束驱动 convSection 底部
            convBottomByTable_Maki = make.bottom.equalToSuperview().offset(-100).constraint
        }
        // 初始无会话，暂不激活 table 底部约束
        convBottomByTable_Maki?.isActive = false

        // 空状态视图
        buildEmptyView_Maki()
        convSection_Maki.addSubview(emptyView_Maki)
        emptyView_Maki.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_maki.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            // 无会话时由此约束驱动 convSection 底部
            convBottomByEmpty_Maki = make.bottom.equalToSuperview().offset(-50).constraint
        }
        // 初始激活 empty 底部约束
        convBottomByEmpty_Maki?.isActive = true
    }

    /// 构建区块标题行（SF Symbol 图标 + 文字）
    /// - Parameters:
    ///   - iconName_maki: SF Symbol 图标名
    ///   - title_maki: 标题文字
    private func buildSectionHeader_Maki(iconName_maki: String, title_maki: String) -> UIView {
        let wrap_maki = UIView()
        let iconIV_maki = UIImageView(image: UIImage(systemName: iconName_maki))
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        let lb_maki = UILabel()
        lb_maki.text = title_maki
        lb_maki.font = .systemFont(ofSize: 16, weight: .bold)
        lb_maki.textColor = K_Maki.tp
        wrap_maki.addSubview(iconIV_maki)
        wrap_maki.addSubview(lb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        lb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(7)
            make.centerY.trailing.equalToSuperview()
        }
        return wrap_maki
    }

    /// 构建精美空状态占位视图（卡片内嵌内容，约束清晰）
    private func buildEmptyView_Maki() {
        // 白色卡片铺满 emptyView
        let card_maki = UIView()
        card_maki.backgroundColor = .white
        card_maki.layer.cornerRadius = 20
        card_maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.1).cgColor
        card_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_maki.layer.shadowRadius = 12
        card_maki.layer.shadowOpacity = 1
        emptyView_Maki.addSubview(card_maki)
        card_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 内容全部在 card 内部
        let iconLb_maki = UILabel()
        iconLb_maki.text = "💬"
        iconLb_maki.font = .systemFont(ofSize: 52)
        iconLb_maki.textAlignment = .center

        let titleLb_maki = UILabel()
        titleLb_maki.text = "No conversations yet"
        titleLb_maki.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLb_maki.textColor = K_Maki.tp
        titleLb_maki.textAlignment = .center

        let subLb_maki = UILabel()
        subLb_maki.text = "Start by following a creator\nand send them a message!"
        subLb_maki.font = .systemFont(ofSize: 13)
        subLb_maki.textColor = K_Maki.ts
        subLb_maki.textAlignment = .center
        subLb_maki.numberOfLines = 2

        card_maki.addSubview(iconLb_maki)
        card_maki.addSubview(titleLb_maki)
        card_maki.addSubview(subLb_maki)

        iconLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
        }
        titleLb_maki.snp.makeConstraints { make in
            make.top.equalTo(iconLb_maki.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        subLb_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-32)
        }
    }
}

// MARK: - 数据刷新

extension MessageList_Maki {

    /// 刷新推荐创作者和会话列表，更新未读角标
    private func reloadAll_Maki() {
        suggCV_Maki.reloadData()

        let chats_maki = MessageViewModel_Maki.shared_Maki.getChatUsers_Maki()
        let hasChats_maki = !chats_maki.isEmpty

        emptyView_Maki.isHidden  = hasChats_maki
        tableView_Maki.isHidden  = !hasChats_maki
        tableView_Maki.reloadData()

        if hasChats_maki {
            // 有会话：tableView 驱动 convSection 底部
            tableHeightRef_Maki?.update(offset: CGFloat(chats_maki.count) * K_Maki.rowH + 8)
            convBottomByTable_Maki?.isActive = true
            convBottomByEmpty_Maki?.isActive = false
        } else {
            // 无会话：emptyView 驱动 convSection 底部，tableView 高度归零
            tableHeightRef_Maki?.update(offset: 0)
            convBottomByTable_Maki?.isActive = false
            convBottomByEmpty_Maki?.isActive = true
        }

        // 更新装饰性未读角标
        if hasChats_maki {
            unreadBadge_Maki.isHidden = false
            unreadCountLb_Maki.text = "\(chats_maki.count)"
        } else {
            unreadBadge_Maki.isHidden = true
        }
    }
}

// MARK: - 进场动画

extension MessageList_Maki {

    /// 进场动画：推荐区 + 会话列表依次从下弹入
    private func playEntranceAnimation_Maki() {
        let targets_maki: [UIView] = [suggSection_Maki, convSection_Maki]
        for (i_maki, v_maki) in targets_maki.enumerated() {
            v_maki.alpha = 0
            v_maki.transform = CGAffineTransform(translationX: 0, y: 24)
            UIView.animate(
                withDuration: 0.44,
                delay: Double(i_maki) * 0.1,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    v_maki.alpha = 1
                    v_maki.transform = .identity
                }
            )
        }
    }
}

// MARK: - 通知绑定

extension MessageList_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChange_Maki),
            name: MessageViewModel_Maki.messageStateDidChangeNotification_Maki, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki, object: nil)
    }

    @objc private func onDataChange_Maki() { reloadAll_Maki() }
}

// MARK: - UICollectionViewDataSource & Delegate（推荐创作者）

extension MessageList_Maki: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        LocalData_Maki.shared_Maki.userList_Maki.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_maki = collectionView.dequeueReusableCell(
            withReuseIdentifier: K_Maki.suggCellId,
            for: indexPath
        ) as! MsgSuggCell_Maki
        cell_maki.configure_Maki(user_maki: LocalData_Maki.shared_Maki.userList_Maki[indexPath.item])
        return cell_maki
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let user_maki = LocalData_Maki.shared_Maki.userList_Maki[indexPath.item]
        Navigation_Maki.toUserInfo_Maki(with: user_maki)
    }
}

// MARK: - UITableViewDataSource & Delegate（会话列表）

extension MessageList_Maki: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MessageViewModel_Maki.shared_Maki.getChatUsers_Maki().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_maki = tableView.dequeueReusableCell(
            withIdentifier: K_Maki.chatCellId,
            for: indexPath
        ) as! MsgChatCell_Maki
        let user_maki    = MessageViewModel_Maki.shared_Maki.getChatUsers_Maki()[indexPath.row]
        let lastMsg_maki = MessageViewModel_Maki.shared_Maki.getLastMessageWithUser_Maki(
            userId_maki: user_maki.userId_Maki ?? 0
        )
        cell_maki.configure_Maki(user_maki: user_maki, lastMessage_maki: lastMsg_maki?.content_Maki ?? "")
        return cell_maki
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        K_Maki.rowH
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let user_maki = MessageViewModel_Maki.shared_Maki.getChatUsers_Maki()[indexPath.row]
        Navigation_Maki.toMessageUser_Maki(with: user_maki)
    }
}

// MARK: - MsgSuggCell_Maki（推荐创作者 Cell）

/// 推荐创作者横向 Cell
/// 功能：白色小卡片 + 彩色渐变头像背景 + 头像 + 用户初始字母 + 用户名 + "Say hi" 标签
final class MsgSuggCell_Maki: UICollectionViewCell {

    // MARK: UI 子视图

    /// 外层白色卡片（圆角 + 阴影）
    private let cardView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 16
        v_maki.layer.shadowColor = UIColor(hexstring_Maki: "#CC6600").withAlphaComponent(0.1).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    /// 头像背景彩色圆（根据用户ID赋色）
    private let avatarBg_Maki: UIView = {
        let v_maki = UIView()
        v_maki.layer.cornerRadius = 28
        v_maki.clipsToBounds = true
        return v_maki
    }()
    /// 用户头像（叠加在彩色背景上）
    private let avatarView_Maki = UserAvatarView_Maki()
    /// 在线绿点（装饰性）
    private let onlineDot_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#52C41A")
        v_maki.layer.cornerRadius = 5
        v_maki.layer.borderWidth = 1.5
        v_maki.layer.borderColor = UIColor.white.cgColor
        return v_maki
    }()
    /// 用户名
    private let nameLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 11, weight: .semibold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        lb_maki.textAlignment = .center
        lb_maki.numberOfLines = 1
        lb_maki.adjustsFontSizeToFitWidth = true
        lb_maki.minimumScaleFactor = 0.75
        return lb_maki
    }()
    /// "Say hi 👋" 引导标签
    private let sayHiLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "Say hi 👋"
        lb_maki.font = .systemFont(ofSize: 9, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        lb_maki.textAlignment = .center
        return lb_maki
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: UI 搭建

    private func setupUI_Maki() {
        contentView.addSubview(cardView_Maki)
        cardView_Maki.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)) }

        // 彩色头像背景圆
        cardView_Maki.addSubview(avatarBg_Maki)
        avatarBg_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        // 头像（圆形，铺满彩色背景）
        cardView_Maki.addSubview(avatarView_Maki)
        avatarView_Maki.snp.makeConstraints { make in
            make.center.equalTo(avatarBg_Maki)
            make.width.height.equalTo(56)
        }

        // 在线绿点
        cardView_Maki.addSubview(onlineDot_Maki)
        onlineDot_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.trailing.equalTo(avatarView_Maki.snp.trailing).offset(1)
            make.bottom.equalTo(avatarView_Maki.snp.bottom).offset(1)
        }

        // 用户名
        cardView_Maki.addSubview(nameLb_Maki)
        nameLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Maki.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview().inset(4)
        }

        // Say hi 标签
        cardView_Maki.addSubview(sayHiLb_Maki)
        sayHiLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(nameLb_Maki.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    // MARK: 配置

    /// 配置推荐用户 Cell
    func configure_Maki(user_maki: PrewUserModel_Maki) {
        avatarView_Maki.configure_Maki(userId_Maki: user_maki.userId_Maki ?? 0)
        nameLb_Maki.text = user_maki.userName_Maki
        // 彩色背景根据用户ID选色
        let colors_maki: [UIColor] = [
            UIColor(hexstring_Maki: "#FFF3E0"),
            UIColor(hexstring_Maki: "#F3E5F5"),
            UIColor(hexstring_Maki: "#E3F2FD"),
            UIColor(hexstring_Maki: "#E8F5E9"),
            UIColor(hexstring_Maki: "#FBE9E7")
        ]
        avatarBg_Maki.backgroundColor = colors_maki[(user_maki.userId_Maki ?? 0) % colors_maki.count]
        onlineDot_Maki.isHidden = (user_maki.userId_Maki ?? 0) % 2 == 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLb_Maki.text = nil
        onlineDot_Maki.isHidden = false
    }
}

// MARK: - MsgChatCell_Maki（会话列表 Cell）

/// 会话列表 Cell
/// 功能：彩色边框头像 + 用户名 + 最后一条消息预览 + 时间戳 + 未读角标
/// 设计：白色圆角卡片 + 橙色阴影；聚焦时轻微缩放反馈
final class MsgChatCell_Maki: UITableViewCell {

    // MARK: UI 子视图

    private let cardView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 16
        v_maki.layer.shadowColor = UIColor(hexstring_Maki: "#CC6600").withAlphaComponent(0.08).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    /// 头像（带彩色边框装饰）
    private let avatarView_Maki = UserAvatarView_Maki()
    /// 头像彩色边框容器
    private let avatarRing_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .clear
        v_maki.layer.borderWidth = 2
        v_maki.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.35).cgColor
        return v_maki
    }()
    /// 用户名
    private let nameLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 15, weight: .semibold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        return lb_maki
    }()
    /// 最后一条消息预览
    private let msgLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 13)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        lb_maki.numberOfLines = 1
        return lb_maki
    }()
    /// 时间戳（装饰性）
    private let timeLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 11)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355").withAlphaComponent(0.6)
        lb_maki.textAlignment = .right
        return lb_maki
    }()
    /// 未读消息角标（橙色圆形，装饰性）
    private let badgeDot_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 5
        return v_maki
    }()
    /// 右侧箭头指示
    private let chevron_Maki: UIImageView = {
        let iv_maki = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv_maki.tintColor = UIColor(hexstring_Maki: "#C0B4A0")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()

    // MARK: 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Maki()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarRing_Maki.layer.cornerRadius = avatarRing_Maki.bounds.width / 2
    }

    // MARK: UI 搭建

    private func setupUI_Maki() {
        contentView.addSubview(cardView_Maki)
        cardView_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-5)
        }

        // 头像环 + 头像
        cardView_Maki.addSubview(avatarRing_Maki)
        avatarRing_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
        cardView_Maki.addSubview(avatarView_Maki)
        avatarView_Maki.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Maki)
            make.width.height.equalTo(44)
        }

        // 时间戳 + 箭头（先布局，便于 nameLb trailing 参考）
        cardView_Maki.addSubview(chevron_Maki)
        chevron_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }

        cardView_Maki.addSubview(timeLb_Maki)
        timeLb_Maki.snp.makeConstraints { make in
            make.trailing.equalTo(chevron_Maki.snp.leading).offset(-6)
            make.top.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(60)
        }

        // 未读角标
        cardView_Maki.addSubview(badgeDot_Maki)
        badgeDot_Maki.snp.makeConstraints { make in
            make.trailing.equalTo(chevron_Maki.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(10)
        }

        // 用户名 + 消息预览
        cardView_Maki.addSubview(nameLb_Maki)
        nameLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(avatarRing_Maki.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalTo(timeLb_Maki.snp.leading).offset(-8)
        }
        cardView_Maki.addSubview(msgLb_Maki)
        msgLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(nameLb_Maki)
            make.top.equalTo(nameLb_Maki.snp.bottom).offset(4)
            make.trailing.equalTo(badgeDot_Maki.snp.leading).offset(-6)
        }
    }

    // MARK: 配置

    /// 配置会话 Cell 数据
    /// - Parameters:
    ///   - user_maki: 用户模型
    ///   - lastMessage_maki: 最后一条消息内容
    func configure_Maki(user_maki: PrewUserModel_Maki, lastMessage_maki: String) {
        avatarView_Maki.configure_Maki(userId_Maki: user_maki.userId_Maki ?? 0)
        nameLb_Maki.text = user_maki.userName_Maki
        msgLb_Maki.text  = lastMessage_maki.isEmpty ? "No messages yet" : lastMessage_maki

        // 时间戳装饰（使用当前时间格式）
        let fmt_maki = DateFormatter()
        fmt_maki.dateFormat = "HH:mm"
        timeLb_Maki.text = fmt_maki.string(from: Date())

        // 根据消息内容决定未读角标是否显示（有消息则显示）
        badgeDot_Maki.isHidden = lastMessage_maki.isEmpty

        // 头像圈颜色根据用户 ID 变化（与首页创作者颜色一致）
        let colors_maki: [UIColor] = [
            UIColor(hexstring_Maki: "#FF8C00"),
            UIColor(hexstring_Maki: "#9B59B6"),
            UIColor(hexstring_Maki: "#2980B9"),
            UIColor(hexstring_Maki: "#27AE60"),
            UIColor(hexstring_Maki: "#E74C3C")
        ]
        let color_maki = colors_maki[(user_maki.userId_Maki ?? 0) % colors_maki.count]
        avatarRing_Maki.layer.borderColor = color_maki.withAlphaComponent(0.4).cgColor
        badgeDot_Maki.backgroundColor = color_maki
    }

    // MARK: 点击动画

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardView_Maki.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLb_Maki.text  = nil
        msgLb_Maki.text   = nil
        timeLb_Maki.text  = nil
        badgeDot_Maki.isHidden = true
    }
}
