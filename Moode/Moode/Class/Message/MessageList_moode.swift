import Foundation
import UIKit
import SnapKit

// MARK: 消息列表

/// 消息列表页面
/// 功能：展示推荐用户横滑 Story 圈 + 会话列表
/// 设计：紧凑渐变 Header（含搜索按钮）+ Story 头像圈横滑 + 平铺会话行
/// 数据：UserViewModel（推荐）+ MessageViewModel（聊天记录）
class MessageList_Moode: UIViewController {

    // MARK: - Header 相关

    private let headerView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.clipsToBounds = false
        return v_Moode
    }()

    private var headerGradient_Moode: CAGradientLayer?

    /// 右侧装饰圆
    private let headerCircle1_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v_Moode.layer.cornerRadius = 52
        return v_Moode
    }()

    private let headerCircle2_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v_Moode.layer.cornerRadius = 32
        return v_Moode
    }()

    private let pageTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Messages"
        l_Moode.font = .systemFont(ofSize: 24, weight: .heavy)
        l_Moode.textColor = .white
        return l_Moode
    }()

    private let pageSubtitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Connect with your mood community"
        l_Moode.font = .systemFont(ofSize: 12, weight: .medium)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.72)
        return l_Moode
    }()

    /// 右上角搜索按钮
    private let searchBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn_Moode.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn_Moode.layer.cornerRadius = 18
        return btn_Moode
    }()

    // MARK: - 主滚动区

    private let scrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsVerticalScrollIndicator = false
        sv_Moode.backgroundColor = .clear
        sv_Moode.contentInsetAdjustmentBehavior = .never
        return sv_Moode
    }()

    private let scrollContent_Moode = UIView()

    // MARK: - 推荐用户区

    private let suggestedCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 20
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#8B5CF6").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 14
        v_Moode.layer.shadowOpacity = 0.08
        return v_Moode
    }()

    private let suggestedTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "People You May Know"
        l_Moode.font = .systemFont(ofSize: 13, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let suggestedCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 10, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#7C6FF7")
        l_Moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        l_Moode.textAlignment = .center
        l_Moode.layer.cornerRadius = 8
        l_Moode.clipsToBounds = true
        return l_Moode
    }()

    private let suggestedScrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsHorizontalScrollIndicator = false
        sv_Moode.backgroundColor = .clear
        return sv_Moode
    }()

    private let suggestedStack_Moode: UIStackView = {
        let sv_Moode = UIStackView()
        sv_Moode.axis = .horizontal
        sv_Moode.spacing = 16
        sv_Moode.alignment = .top
        return sv_Moode
    }()

    // MARK: - 聊天列表区

    private let chatsSectionRow_Moode = UIView()

    private let chatsTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Recent Chats"
        l_Moode.font = .systemFont(ofSize: 13, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let chatsCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 10, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#48BB78")
        l_Moode.backgroundColor = UIColor(hexstring_Moode: "#E6FFF2")
        l_Moode.textAlignment = .center
        l_Moode.layer.cornerRadius = 8
        l_Moode.clipsToBounds = true
        return l_Moode
    }()

    private let tableView_Moode: UITableView = {
        let tv_Moode = UITableView(frame: .zero, style: .plain)
        tv_Moode.backgroundColor = .clear
        tv_Moode.separatorStyle = .none
        tv_Moode.rowHeight = 78
        tv_Moode.showsVerticalScrollIndicator = false
        tv_Moode.isScrollEnabled = false
        tv_Moode.register(ChatRow_Moode.self, forCellReuseIdentifier: ChatRow_Moode.reuseId_Moode)
        return tv_Moode
    }()

    private var tableHeightConstraint_Moode: Constraint?

    // MARK: - 空状态

    private let emptyView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 20
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#A78BFA").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 12
        v_Moode.layer.shadowOpacity = 0.06
        v_Moode.isHidden = true
        return v_Moode
    }()

    private let emptyEmojiLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "💬"
        l_Moode.font = .systemFont(ofSize: 42)
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let emptyTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "No conversations yet"
        l_Moode.font = .systemFont(ofSize: 15, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let emptySubLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Tap someone above to start chatting"
        l_Moode.font = .systemFont(ofSize: 12.5)
        l_Moode.textColor = UIColor(hexstring_Moode: "#9B9BC0")
        l_Moode.textAlignment = .center
        l_Moode.numberOfLines = 2
        return l_Moode
    }()

    // MARK: - 数据

    private var chatUsers_Moode: [PrewUserModel_Moode] = []
    private var recommendUsers_Moode: [PrewUserModel_Moode] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Moode()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        setupHeader_Moode()
        setupScrollView_Moode()
        setupSuggestedSection_Moode()
        setupChatsSection_Moode()
        observeNotifications_Moode()
        reloadData_Moode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradient_Moode()
    }

    // MARK: - 布局：Header

    private func setupHeader_Moode() {
        view.addSubview(headerView_Moode)
        // 底部锚定在安全区顶部再向下 72pt，确保在刘海屏上紧凑
        headerView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(72)
        }

        headerView_Moode.addSubview(headerCircle1_Moode)
        headerCircle1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(32)
            make.top.equalToSuperview().offset(-22)
            make.width.height.equalTo(104)
        }

        headerView_Moode.addSubview(headerCircle2_Moode)
        headerCircle2_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-48)
            make.bottom.equalToSuperview().offset(18)
            make.width.height.equalTo(64)
        }

        // 搜索按钮右上角
        headerView_Moode.addSubview(searchBtn_Moode)
        searchBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(36)
        }

        headerView_Moode.addSubview(pageTitleLabel_Moode)
        pageTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        }

        headerView_Moode.addSubview(pageSubtitleLabel_Moode)
        pageSubtitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(pageTitleLabel_Moode.snp.bottom).offset(3)
        }
    }

    // MARK: - 布局：滚动容器

    private func setupScrollView_Moode() {
        view.addSubview(scrollView_Moode)
        scrollView_Moode.snp.makeConstraints { make in
            make.top.equalTo(headerView_Moode.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView_Moode.addSubview(scrollContent_Moode)
        scrollContent_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }
    }

    // MARK: - 布局：推荐用户区

    private func setupSuggestedSection_Moode() {
        scrollContent_Moode.addSubview(suggestedCard_Moode)
        suggestedCard_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        // 卡片标题行
        let titleRow_Moode = UIView()
        suggestedCard_Moode.addSubview(titleRow_Moode)
        titleRow_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }

        titleRow_Moode.addSubview(suggestedTitleLabel_Moode)
        suggestedTitleLabel_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }

        titleRow_Moode.addSubview(suggestedCountLabel_Moode)
        suggestedCountLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(suggestedTitleLabel_Moode.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(24)
        }

        // 横向滚动区：Story 圈
        suggestedCard_Moode.addSubview(suggestedScrollView_Moode)
        suggestedScrollView_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleRow_Moode.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            // 精确高度：头像环(56) + 间距(5) + 名字(13) = 74 + 上下各 8 = 16
            make.height.equalTo(90)
            make.bottom.equalToSuperview().offset(-12)
        }

        suggestedScrollView_Moode.addSubview(suggestedStack_Moode)
        suggestedStack_Moode.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }

    // MARK: - 布局：聊天列表区

    private func setupChatsSection_Moode() {
        scrollContent_Moode.addSubview(chatsSectionRow_Moode)
        chatsSectionRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(suggestedCard_Moode.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }

        chatsSectionRow_Moode.addSubview(chatsTitleLabel_Moode)
        chatsTitleLabel_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }

        chatsSectionRow_Moode.addSubview(chatsCountLabel_Moode)
        chatsCountLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(chatsTitleLabel_Moode.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(24)
        }

        // 列表（定义 scrollContent_Moode 底部）
        scrollContent_Moode.addSubview(tableView_Moode)
        tableView_Moode.snp.makeConstraints { make in
            make.top.equalTo(chatsSectionRow_Moode.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            tableHeightConstraint_Moode = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview().offset(-8)
        }
        tableView_Moode.dataSource = self
        tableView_Moode.delegate = self

        // 空状态（叠加在列表区域上方，高度固定，不参与 scrollContent 底部定义）
        scrollContent_Moode.addSubview(emptyView_Moode)
        emptyView_Moode.snp.makeConstraints { make in
            make.top.equalTo(chatsSectionRow_Moode.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(160)
        }
        setupEmptyContent_Moode()
    }

    private func setupEmptyContent_Moode() {
        emptyView_Moode.addSubview(emptyEmojiLabel_Moode)
        emptyEmojiLabel_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
        }
        emptyView_Moode.addSubview(emptyTitleLabel_Moode)
        emptyTitleLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyEmojiLabel_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        emptyView_Moode.addSubview(emptySubLabel_Moode)
        emptySubLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Moode.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    // MARK: - 渐变

    private func updateHeaderGradient_Moode() {
        if headerGradient_Moode == nil {
            let grad_Moode = CAGradientLayer()
            grad_Moode.colors = [
                UIColor(hexstring_Moode: "#9B72F5").cgColor,
                UIColor(hexstring_Moode: "#7B8FF0").cgColor
            ]
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 1, y: 1)
            headerView_Moode.layer.insertSublayer(grad_Moode, at: 0)
            headerGradient_Moode = grad_Moode
        }
        headerGradient_Moode?.frame = headerView_Moode.bounds
    }

    // MARK: - 数据刷新

    private func reloadData_Moode() {
        Task { @MainActor in
            let currentId_Moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode().userId_Moode ?? 0
            recommendUsers_Moode = LocalData_Moode.shared_Moode.userList_Moode.filter {
                $0.userId_Moode != currentId_Moode
            }
            chatUsers_Moode = MessageViewModel_Moode.shared_Moode.getChatUsers_Moode()

            suggestedCountLabel_Moode.text = " \(recommendUsers_Moode.count) "
            chatsCountLabel_Moode.text = " \(chatUsers_Moode.count) "

            buildStoryItems_Moode()

            let isEmpty_Moode = chatUsers_Moode.isEmpty
            emptyView_Moode.isHidden = !isEmpty_Moode
            tableView_Moode.isHidden = isEmpty_Moode

            if isEmpty_Moode {
                // 空状态时，tableView 高度撑开 scrollContent，确保空状态视图完整显示
                tableHeightConstraint_Moode?.update(offset: 184)
            } else {
                tableView_Moode.reloadData()
                tableView_Moode.layoutIfNeeded()
                tableHeightConstraint_Moode?.update(offset: tableView_Moode.contentSize.height)
            }
        }
    }

    // MARK: - Story 圈构建

    private func buildStoryItems_Moode() {
        suggestedStack_Moode.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for user_Moode in recommendUsers_Moode {
            let item_Moode = buildStoryItem_Moode(user_moode: user_Moode)
            suggestedStack_Moode.addArrangedSubview(item_Moode)
        }
    }

    /// Story 圈单项：渐变环 + UserAvatarView + 昵称
    private func buildStoryItem_Moode(user_moode: PrewUserModel_Moode) -> UIView {
        let uid_moode = user_moode.userId_Moode ?? 0

        let container_Moode = UIView()
        container_Moode.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        container_Moode.accessibilityIdentifier = "\(uid_moode)"
        container_Moode.isUserInteractionEnabled = true

        // 颜色配置（5 色循环）
        let palettes_Moode: [(UIColor, UIColor)] = [
            (UIColor(hexstring_Moode: "#A78BFA"), UIColor(hexstring_Moode: "#7B8FF0")),
            (UIColor(hexstring_Moode: "#F687B3"), UIColor(hexstring_Moode: "#FC8181")),
            (UIColor(hexstring_Moode: "#68D391"), UIColor(hexstring_Moode: "#4FD1C5")),
            (UIColor(hexstring_Moode: "#F6AD55"), UIColor(hexstring_Moode: "#ED8936")),
            (UIColor(hexstring_Moode: "#63B3ED"), UIColor(hexstring_Moode: "#9B72F5"))
        ]
        let (c1_moode, c2_moode) = palettes_Moode[uid_moode % palettes_Moode.count]

        // 渐变环（56×56，用 evenOdd mask 挖出 50×50 内圆）
        let ringView_Moode = UIView()
        ringView_Moode.backgroundColor = .clear
        container_Moode.addSubview(ringView_Moode)
        ringView_Moode.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        let ringGrad_Moode = CAGradientLayer()
        ringGrad_Moode.colors = [c1_moode.cgColor, c2_moode.cgColor]
        ringGrad_Moode.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Moode.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Moode.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        ringGrad_Moode.cornerRadius = 28

        let maskPath_Moode = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 56, height: 56))
        maskPath_Moode.append(UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 50, height: 50)))
        let maskLayer_Moode = CAShapeLayer()
        maskLayer_Moode.path = maskPath_Moode.cgPath
        maskLayer_Moode.fillRule = .evenOdd
        ringGrad_Moode.mask = maskLayer_Moode
        ringView_Moode.layer.addSublayer(ringGrad_Moode)

        // 头像（50×50，内嵌 3pt）
        let avatar_Moode = UserAvatarView_Moode()
        avatar_Moode.configure_Moode(userId_Moode: uid_moode)
        ringView_Moode.addSubview(avatar_Moode)
        avatar_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }

        // 昵称
        let nameLabel_Moode = UILabel()
        nameLabel_Moode.text = user_moode.userName_Moode ?? "User"
        nameLabel_Moode.font = .systemFont(ofSize: 10.5, weight: .semibold)
        nameLabel_Moode.textColor = UIColor(hexstring_Moode: "#3D3D5C")
        nameLabel_Moode.textAlignment = .center
        nameLabel_Moode.lineBreakMode = .byTruncatingTail
        container_Moode.addSubview(nameLabel_Moode)
        nameLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(ringView_Moode.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 点击手势
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleStoryTapped_Moode(_:)))
        container_Moode.addGestureRecognizer(tap_Moode)

        return container_Moode
    }

    // MARK: - 通知监听

    private func observeNotifications_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDataChanged_Moode),
            name: MessageViewModel_Moode.messageStateDidChangeNotification_Moode, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDataChanged_Moode),
            name: UserViewModel_Moode.userStateDidChangeNotification_Moode, object: nil
        )
    }

    // MARK: - 事件处理

    @objc private func handleStoryTapped_Moode(_ gesture_moode: UITapGestureRecognizer) {
        guard let view_moode = gesture_moode.view,
              let idStr_Moode = view_moode.accessibilityIdentifier,
              let uid_moode = Int(idStr_Moode),
              let user_Moode = LocalData_Moode.shared_Moode.userList_Moode.first(where: {
                  $0.userId_Moode == uid_moode
              }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1,
                       animations: { view_moode.transform = CGAffineTransform(scaleX: 0.90, y: 0.90) },
                       completion: { _ in
            UIView.animate(withDuration: 0.22, delay: 0,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5) {
                view_moode.transform = .identity
            }
            Navigation_Moode.toMessageUser_Moode(with: user_Moode)
        })
    }

    @objc private func handleDataChanged_Moode() {
        reloadData_Moode()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableView DataSource & Delegate

extension MessageList_Moode: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatUsers_Moode.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Moode = tableView.dequeueReusableCell(
            withIdentifier: ChatRow_Moode.reuseId_Moode, for: indexPath
        ) as? ChatRow_Moode else { return UITableViewCell() }
        let user_Moode = chatUsers_Moode[indexPath.row]
        let lastMsg_Moode = MessageViewModel_Moode.shared_Moode.getLastMessageWithUser_Moode(
            userId_moode: user_Moode.userId_Moode ?? 0
        )
        cell_Moode.configure_Moode(user_moode: user_Moode,
                                   lastMessage_moode: lastMsg_Moode,
                                   index_moode: indexPath.row)
        return cell_Moode
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user_Moode = chatUsers_Moode[indexPath.row]
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.toMessageUser_Moode(with: user_Moode)
    }
}

// MARK: - 聊天行 Cell

/// 会话列表行 Cell
/// 功能：头像（UserAvatarView）+ 昵称 + 消息摘要 + 时间 + 彩色左侧竖线
class ChatRow_Moode: UITableViewCell {

    static let reuseId_Moode = "ChatRow_Moode"

    // MARK: - UI

    private let rowBg_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 16
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#9B72F5").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Moode.layer.shadowRadius = 8
        v_Moode.layer.shadowOpacity = 0.07
        return v_Moode
    }()

    /// 左侧彩色竖线（随用户 id 变色）
    private let sideBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 2.5
        return v_Moode
    }()

    private let avatarView_Moode = UserAvatarView_Moode()

    private let nameLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 14.5, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let previewLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 12.5)
        l_Moode.textColor = UIColor(hexstring_Moode: "#9B9BC0")
        l_Moode.lineBreakMode = .byTruncatingTail
        return l_Moode
    }()

    private let timeLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11)
        l_Moode.textColor = UIColor(hexstring_Moode: "#C0BDDB")
        l_Moode.textAlignment = .right
        return l_Moode
    }()

    private let chevronIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
        iv_Moode.image = UIImage(systemName: "chevron.right", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = UIColor(hexstring_Moode: "#D5D2EE")
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Moode()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.14) {
            self.rowBg_Moode.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            self.rowBg_Moode.alpha = highlighted ? 0.88 : 1.0
        }
    }

    // MARK: - 布局

    private func setupUI_Moode() {
        contentView.addSubview(rowBg_Moode)
        rowBg_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-4)
        }

        rowBg_Moode.addSubview(sideBar_Moode)
        sideBar_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(34)
        }

        rowBg_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.left.equalTo(sideBar_Moode.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(46)
        }

        rowBg_Moode.addSubview(chevronIcon_Moode)
        chevronIcon_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }

        rowBg_Moode.addSubview(timeLabel_Moode)
        timeLabel_Moode.snp.makeConstraints { make in
            make.right.equalTo(chevronIcon_Moode.snp.left).offset(-6)
            make.top.equalToSuperview().offset(17)
        }

        rowBg_Moode.addSubview(nameLabel_Moode)
        nameLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Moode.snp.right).offset(10)
            make.right.equalTo(timeLabel_Moode.snp.left).offset(-6)
            make.top.equalToSuperview().offset(15)
        }

        rowBg_Moode.addSubview(previewLabel_Moode)
        previewLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Moode.snp.right).offset(10)
            make.right.equalTo(chevronIcon_Moode.snp.left).offset(-6)
            make.top.equalTo(nameLabel_Moode.snp.bottom).offset(4)
        }
    }

    // MARK: - 数据绑定

    /// 配置 Cell 数据：用户信息、最后一条消息、行索引（用于颜色）
    func configure_Moode(user_moode: PrewUserModel_Moode,
                         lastMessage_moode: MessageModel_Moode?,
                         index_moode: Int) {
        nameLabel_Moode.text = user_moode.userName_Moode ?? "User"
        avatarView_Moode.configure_Moode(userId_Moode: user_moode.userId_Moode ?? 0)

        let barColors_moode: [UIColor] = [
            UIColor(hexstring_Moode: "#A78BFA"),
            UIColor(hexstring_Moode: "#F687B3"),
            UIColor(hexstring_Moode: "#68D391"),
            UIColor(hexstring_Moode: "#F6AD55"),
            UIColor(hexstring_Moode: "#63B3ED")
        ]
        sideBar_Moode.backgroundColor = barColors_moode[index_moode % barColors_moode.count]

        if let msg_Moode = lastMessage_moode {
            let prefix_Moode = (msg_Moode.isMine_Moode == true) ? "You: " : ""
            previewLabel_Moode.text = prefix_Moode + (msg_Moode.content_Moode ?? "")
            timeLabel_Moode.text = msg_Moode.time_Moode ?? ""
        } else {
            previewLabel_Moode.text = "Say hi 👋"
            timeLabel_Moode.text = ""
        }
    }
}
