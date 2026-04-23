import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面
/// 核心作用：展示当前登录用户的全部聊天会话列表，响应式更新
/// 设计思路：
///   - 沉浸式渐变 Header：图标徽章 + 大标题 + 会话数胶囊 + 多层装饰气泡 + 波浪底边
///   - Stories 风格活跃用户横向滚动区（带脉冲动画绿点）
///   - "Recent Chats" 分区标题栏（渐变小圆点 + 数量标签）
///   - 富化 Cell：渐变头像环、未读左侧强调条、按时间着色、按压反馈动画
/// 关键方法：
///   - loadData_Nest：从 MessageViewModel 拉取最新用户列表并刷新
///   - 监听 messageStateDidChangeNotification_Nest 实现响应式刷新
class MessageList_Nest: UIViewController {

    // MARK: - 数据

    /// 全量聊天用户（来自 MessageViewModel）
    private var allChatUsers_Nest: [PrewUserModel_Nest] = []
    /// 已执行入场动画的 indexPath 集合，防止滚动时重复触发
    private var animatedRows_Nest: Set<IndexPath> = []

    // MARK: - UI 组件

    private let headerView_Nest = MessageHeaderView_Nest()

    private let activeSectionView_Nest = ActiveSectionHeaderView_Nest()

    private let activeUsersCV_Nest: UICollectionView = {
        let layout_Nest = UICollectionViewFlowLayout()
        layout_Nest.scrollDirection = .horizontal
        layout_Nest.minimumInteritemSpacing = 2
        layout_Nest.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        let cv_Nest = UICollectionView(frame: .zero, collectionViewLayout: layout_Nest)
        cv_Nest.backgroundColor = .clear
        cv_Nest.showsHorizontalScrollIndicator = false
        cv_Nest.register(ActiveUserCell_Nest.self, forCellWithReuseIdentifier: ActiveUserCell_Nest.reuseId_Nest)
        return cv_Nest
    }()

    private let recentSectionView_Nest = RecentChatsSectionView_Nest()

    private let tableView_Nest: UITableView = {
        let tv_Nest = UITableView(frame: .zero, style: .plain)
        tv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tv_Nest.separatorStyle = .none
        tv_Nest.showsVerticalScrollIndicator = false
        tv_Nest.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
        tv_Nest.register(ChatUserCell_Nest.self, forCellReuseIdentifier: ChatUserCell_Nest.reuseId_Nest)
        return tv_Nest
    }()

    private let emptyView_Nest: MessageEmptyView_Nest = {
        let v_Nest = MessageEmptyView_Nest()
        v_Nest.isHidden = true
        return v_Nest
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Nest()
        setupConstraints_Nest()
        setupNotifications_Nest()
        loadData_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Nest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView_Nest.updateCurvedMask_Nest()
    }

    // MARK: - UI 构建

    private func setupUI_Nest() {
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest

        view.addSubview(headerView_Nest)
        view.addSubview(activeSectionView_Nest)
        view.addSubview(activeUsersCV_Nest)
        view.addSubview(recentSectionView_Nest)
        view.addSubview(tableView_Nest)
        view.addSubview(emptyView_Nest)

        tableView_Nest.dataSource = self
        tableView_Nest.delegate = self
        activeUsersCV_Nest.dataSource = self
        activeUsersCV_Nest.delegate = self
    }

    private func setupConstraints_Nest() {
        headerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(148)
        }
        activeSectionView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(headerView_Nest.snp.bottom).offset(16)
            make_Nest.leading.equalToSuperview().offset(18)
            make_Nest.trailing.equalToSuperview().offset(-18)
            make_Nest.height.equalTo(20)
        }
        activeUsersCV_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(activeSectionView_Nest.snp.bottom).offset(12)
            make_Nest.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(96)
        }
        recentSectionView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(activeUsersCV_Nest.snp.bottom).offset(14)
            make_Nest.leading.equalToSuperview().offset(18)
            make_Nest.trailing.equalToSuperview().offset(-18)
            make_Nest.height.equalTo(32)
        }
        tableView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(recentSectionView_Nest.snp.bottom).offset(2)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }
        emptyView_Nest.snp.makeConstraints { make_Nest in
            // 锚定在整个 view 的可用区域正中，避免受 tableView 是否可见影响定位
            make_Nest.centerX.equalToSuperview()
            make_Nest.centerY.equalToSuperview().offset(60)
            make_Nest.width.equalTo(260)
        }
    }

    // MARK: - 通知

    private func setupNotifications_Nest() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChanged_Nest),
            name: MessageViewModel_Nest.messageStateDidChangeNotification_Nest,
            object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 数据

    private func loadData_Nest() {
        allChatUsers_Nest = MessageViewModel_Nest.shared_Nest.getChatUsers_Nest()
        animatedRows_Nest.removeAll()
        tableView_Nest.reloadData()
        activeUsersCV_Nest.reloadData()

        // 同步更新各区域
        headerView_Nest.updateCount_Nest(count_Nest: allChatUsers_Nest.count)
        recentSectionView_Nest.updateCount_Nest(count_Nest: allChatUsers_Nest.count)

        let hasUsers_Nest = !allChatUsers_Nest.isEmpty
        activeSectionView_Nest.isHidden = !hasUsers_Nest
        activeUsersCV_Nest.isHidden = !hasUsers_Nest
        recentSectionView_Nest.isHidden = !hasUsers_Nest
        // tableView 始终可见，空态覆盖层通过 emptyView 呈现，避免隐藏 tableView 导致居中锚点失效
        emptyView_Nest.isHidden = hasUsers_Nest
    }

    @objc private func onStateChanged_Nest() { loadData_Nest() }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageList_Nest: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChatUsers_Nest.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Nest = tableView.dequeueReusableCell(
            withIdentifier: ChatUserCell_Nest.reuseId_Nest,
            for: indexPath
        ) as? ChatUserCell_Nest else { return UITableViewCell() }
        let user_Nest = allChatUsers_Nest[indexPath.row]
        let lastMsg_Nest = MessageViewModel_Nest.shared_Nest.getLastMessageWithUser_Nest(
            userId_nest: user_Nest.userId_Nest ?? 0
        )
        cell_Nest.configure_Nest(user: user_Nest, lastMessage: lastMsg_Nest)
        return cell_Nest
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !animatedRows_Nest.contains(indexPath) else { return }
        animatedRows_Nest.insert(indexPath)
        cell.animateSlideInFromBottom_Nest(
            offset_Nest: 24,
            delay_Nest: Double(indexPath.row) * AnimationConfig_Nest.delayShort_Nest
        )
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Nest.toMessageUser_Nest(with: allChatUsers_Nest[indexPath.row])
    }
}

// MARK: - UICollectionView DataSource & Delegate（活跃用户横向区）

extension MessageList_Nest: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allChatUsers_Nest.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Nest = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActiveUserCell_Nest.reuseId_Nest,
            for: indexPath
        ) as? ActiveUserCell_Nest else { return UICollectionViewCell() }
        cell_Nest.configure_Nest(user: allChatUsers_Nest[indexPath.row])
        return cell_Nest
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 68, height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Nest.toMessageUser_Nest(with: allChatUsers_Nest[indexPath.row])
    }
}

// MARK: - MessageHeaderView_Nest
/// 消息列表顶部沉浸式渐变 Header
/// 设计要点：
///   - 左侧：图标徽章 + "Messages" 大标题 + 会话数量胶囊
///   - 装饰层：大/中/小三层半透明圆形气泡，形成空间纵深
///   - 波浪曲线底边，与下方背景色平滑衔接
private class MessageHeaderView_Nest: UIView {

    private var gradientLayer_Nest: CAGradientLayer?

    // 图标徽章背景
    private let iconBadge_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v_Nest.layer.cornerRadius = 12
        return v_Nest
    }()

    private let iconImageView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "message.fill")
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Messages"
        lbl_Nest.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()

    /// 会话数量胶囊标签
    private let countPill_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 11
        return v_Nest
    }()

    private let countLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.9)
        return lbl_Nest
    }()

    // 三层装饰气泡，制造层次景深感
    private let bubble1_Nest: UIView = makeDecorationBubble_Nest(size: 130, alpha: 0.07)
    private let bubble2_Nest: UIView = makeDecorationBubble_Nest(size: 80, alpha: 0.1)
    private let bubble3_Nest: UIView = makeDecorationBubble_Nest(size: 44, alpha: 0.13)

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeDecorationBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        // 气泡装饰层（最底部）
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)

        // 图标徽章
        addSubview(iconBadge_Nest)
        iconBadge_Nest.addSubview(iconImageView_Nest)

        // 标题
        addSubview(titleLabel_Nest)

        // 数量胶囊
        countPill_Nest.addSubview(countLabel_Nest)
        addSubview(countPill_Nest)

        // 装饰气泡布局（右上 + 右中 + 左下角）
        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-30)
            make_Nest.trailing.equalToSuperview().offset(30)
            make_Nest.width.height.equalTo(130)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(40)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.width.height.equalTo(80)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(10)
            make_Nest.leading.equalToSuperview().offset(-10)
            make_Nest.width.height.equalTo(44)
        }

        // 图标徽章
        iconBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.bottom.equalTo(titleLabel_Nest.snp.top).offset(-8)
            make_Nest.width.equalTo(34)
            make_Nest.height.equalTo(28)
        }
        iconImageView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(16)
        }

        // 标题
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.bottom.equalToSuperview().offset(-24)
        }

        // 数量胶囊
        countLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(10)
            make_Nest.trailing.equalToSuperview().offset(-10)
            make_Nest.centerY.equalToSuperview()
        }
        countPill_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLabel_Nest.snp.trailing).offset(10)
            make_Nest.centerY.equalTo(titleLabel_Nest)
            make_Nest.height.equalTo(22)
        }
    }

    /// 刷新渐变 frame 与波浪底边蒙版，在 viewDidLayoutSubviews 后调用
    func updateCurvedMask_Nest() {
        gradientLayer_Nest?.frame = bounds

        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 18))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - 18),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + 22)
        )
        path_Nest.close()

        let shapeMask_Nest = CAShapeLayer()
        shapeMask_Nest.path = path_Nest.cgPath
        layer.mask = shapeMask_Nest
    }

    /// 更新胶囊内的会话数量文本
    /// - Parameter count_Nest: 当前会话总数
    func updateCount_Nest(count_Nest: Int) {
        countLabel_Nest.text = count_Nest == 0 ? "Empty" : "\(count_Nest) chats"
    }
}

// MARK: - ActiveSectionHeaderView_Nest
/// "Active Now" 区标题行
/// 展示：脉冲绿点 + "Active Now" 文字
private class ActiveSectionHeaderView_Nest: UIView {

    private let pulseDot_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#48BB78")
        v_Nest.layer.cornerRadius = 5
        return v_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Active Now"
        lbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView_Nest()
        startPulse_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView_Nest() {
        addSubview(pulseDot_Nest)
        addSubview(titleLabel_Nest)

        pulseDot_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(10)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(pulseDot_Nest.snp.trailing).offset(6)
            make_Nest.centerY.equalToSuperview()
        }
    }

    /// 绿点持续脉冲缩放动画，强调"在线"概念
    private func startPulse_Nest() {
        UIView.animate(
            withDuration: 1.2,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                self.pulseDot_Nest.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.pulseDot_Nest.alpha = 0.5
            }
        )
    }
}

// MARK: - RecentChatsSectionView_Nest
/// "Recent Chats" 区块标题行
/// 展示：左侧渐变小圆点 + 标题 + 右侧数量徽章
private class RecentChatsSectionView_Nest: UIView {

    private let dotView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 4
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var dotGradient_Nest: CAGradientLayer?

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Recent Chats"
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let countBadge_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.12)
        v_Nest.layer.cornerRadius = 9
        return v_Nest
    }()

    private let countLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.primaryGradientStart_Nest
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        dotGradient_Nest?.frame = dotView_Nest.bounds
    }

    private func setupView_Nest() {
        addSubview(dotView_Nest)
        addSubview(titleLabel_Nest)
        countBadge_Nest.addSubview(countLabel_Nest)
        addSubview(countBadge_Nest)

        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        dotView_Nest.layer.insertSublayer(gl_Nest, at: 0)
        dotGradient_Nest = gl_Nest

        dotView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(8)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(dotView_Nest.snp.trailing).offset(8)
            make_Nest.centerY.equalToSuperview()
        }
        countLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(8)
            make_Nest.trailing.equalToSuperview().offset(-8)
            make_Nest.centerY.equalToSuperview()
        }
        countBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLabel_Nest.snp.trailing).offset(8)
            make_Nest.centerY.equalToSuperview()
            make_Nest.height.equalTo(18)
        }
    }

    /// 更新徽章数量文本
    /// - Parameter count_Nest: 当前聊天用户总数
    func updateCount_Nest(count_Nest: Int) {
        countLabel_Nest.text = "\(count_Nest)"
    }
}

// MARK: - ActiveUserCell_Nest
/// 活跃用户横向滚动条中的单个用户头像 Cell
/// 展示：渐变边框环头像 + 绿色在线点 + 用户名截断
private class ActiveUserCell_Nest: UICollectionViewCell {

    static let reuseId_Nest = "ActiveUserCell_Nest"

    private let ringContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 30
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var ringGradient_Nest: CAGradientLayer?

    private let avatarWrapper_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        v_Nest.layer.cornerRadius = 25
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let avatarView_Nest = UserAvatarView_Nest()

    private let onlineDot_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#48BB78")
        v_Nest.layer.cornerRadius = 6
        v_Nest.layer.borderWidth = 2.5
        v_Nest.layer.borderColor = UIColor.white.cgColor
        return v_Nest
    }()

    private let nameLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.textAlignment = .center
        lbl_Nest.numberOfLines = 1
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        ringGradient_Nest?.frame = ringContainer_Nest.bounds
    }

    private func setupCellUI_Nest() {
        contentView.addSubview(ringContainer_Nest)
        ringContainer_Nest.addSubview(avatarWrapper_Nest)
        avatarWrapper_Nest.addSubview(avatarView_Nest)
        contentView.addSubview(onlineDot_Nest)
        contentView.addSubview(nameLabel_Nest)

        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        ringContainer_Nest.layer.insertSublayer(gl_Nest, at: 0)
        ringGradient_Nest = gl_Nest

        ringContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(2)
            make_Nest.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(60)
        }
        avatarWrapper_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(50)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        onlineDot_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalTo(ringContainer_Nest.snp.bottom).offset(-1)
            make_Nest.trailing.equalTo(ringContainer_Nest.snp.trailing).offset(-1)
            make_Nest.width.height.equalTo(12)
        }
        nameLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(ringContainer_Nest.snp.bottom).offset(7)
            make_Nest.leading.trailing.equalToSuperview()
        }
    }

    func configure_Nest(user: PrewUserModel_Nest) {
        avatarView_Nest.configure_Nest(userId_Nest: user.userId_Nest ?? 0)
        let name_Nest = user.userName_Nest ?? "User"
        nameLabel_Nest.text = name_Nest.count > 7 ? String(name_Nest.prefix(6)) + "…" : name_Nest
    }
}

// MARK: - ChatUserCell_Nest
/// 消息列表单行 Cell
/// 设计要点：
///   - 卡片容器：圆角 + 轻阴影，视觉浮起感
///   - 渐变边框头像环 + 绿色在线点
///   - 未读状态：左侧渐变强调条 + 名字加粗 + 时间着色为主题紫
///   - 按压时 cardView 执行缩放反馈动画
private class ChatUserCell_Nest: UITableViewCell {

    static let reuseId_Nest = "ChatUserCell_Nest"

    // MARK: 卡片

    private let cardView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 20
        v_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_Nest.layer.shadowRadius = 12
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    // MARK: 左侧未读强调条（渐变）

    private let accentBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 2
        v_Nest.clipsToBounds = true
        v_Nest.isHidden = true
        return v_Nest
    }()

    private var accentGradient_Nest: CAGradientLayer?

    // MARK: 渐变头像环

    private let ringView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 30
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var ringGradient_Nest: CAGradientLayer?

    private let avatarWrapper_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.backgroundSecondary_Nest
        v_Nest.layer.cornerRadius = 25
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let avatarView_Nest = UserAvatarView_Nest()

    // MARK: 在线指示点

    private let onlineDot_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#48BB78")
        v_Nest.layer.cornerRadius = 6.5
        v_Nest.layer.borderWidth = 2.5
        v_Nest.layer.borderColor = UIColor.white.cgColor
        return v_Nest
    }()

    // MARK: 文本

    private let nameLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let lastMsgLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.numberOfLines = 1
        return lbl_Nest
    }()

    // MARK: 右侧

    private let timeLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .right
        return lbl_Nest
    }()

    /// 未读圆点（辅助渐变色：粉→橙）
    private let unreadDot_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 5
        v_Nest.clipsToBounds = true
        v_Nest.isHidden = true
        return v_Nest
    }()

    private var unreadDotGradient_Nest: CAGradientLayer?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupCellUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        ringGradient_Nest?.frame = ringView_Nest.bounds
        accentGradient_Nest?.frame = accentBar_Nest.bounds
        unreadDotGradient_Nest?.frame = unreadDot_Nest.bounds
    }

    // MARK: - UI 构建

    private func setupCellUI_Nest() {
        contentView.addSubview(cardView_Nest)
        cardView_Nest.addSubview(accentBar_Nest)
        cardView_Nest.addSubview(ringView_Nest)
        ringView_Nest.addSubview(avatarWrapper_Nest)
        avatarWrapper_Nest.addSubview(avatarView_Nest)
        cardView_Nest.addSubview(onlineDot_Nest)
        cardView_Nest.addSubview(nameLabel_Nest)
        cardView_Nest.addSubview(lastMsgLabel_Nest)
        cardView_Nest.addSubview(timeLabel_Nest)
        cardView_Nest.addSubview(unreadDot_Nest)

        // 渐变头像环
        let rgl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        ringView_Nest.layer.insertSublayer(rgl_Nest, at: 0)
        ringGradient_Nest = rgl_Nest

        // 左侧强调条渐变（主色系）
        let agl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        agl_Nest.startPoint = CGPoint(x: 0, y: 0)
        agl_Nest.endPoint = CGPoint(x: 0, y: 1)
        accentBar_Nest.layer.insertSublayer(agl_Nest, at: 0)
        accentGradient_Nest = agl_Nest

        // 未读点渐变（辅助色系：粉→橙）
        let udgl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        unreadDot_Nest.layer.insertSublayer(udgl_Nest, at: 0)
        unreadDotGradient_Nest = udgl_Nest

        cardView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(5)
            make_Nest.bottom.equalToSuperview().offset(-5)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
        }
        accentBar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(0)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.equalTo(4)
            make_Nest.height.equalTo(28)
        }
        ringView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(60)
        }
        avatarWrapper_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(50)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        onlineDot_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalTo(ringView_Nest.snp.bottom).offset(-1)
            make_Nest.trailing.equalTo(ringView_Nest.snp.trailing).offset(-1)
            make_Nest.width.height.equalTo(13)
        }
        nameLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(17)
            make_Nest.leading.equalTo(ringView_Nest.snp.trailing).offset(12)
            make_Nest.trailing.equalTo(timeLabel_Nest.snp.leading).offset(-6)
        }
        lastMsgLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLabel_Nest.snp.bottom).offset(5)
            make_Nest.leading.equalTo(nameLabel_Nest)
            make_Nest.trailing.equalTo(unreadDot_Nest.snp.leading).offset(-8)
        }
        timeLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLabel_Nest)
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.width.lessThanOrEqualTo(70)
        }
        unreadDot_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerY.equalTo(lastMsgLabel_Nest)
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.width.height.equalTo(10)
        }
    }

    // MARK: - 配置

    /// 填充单元格内容
    /// - Parameters:
    ///   - user: 聊天对象用户模型
    ///   - lastMessage: 与该用户最后一条消息（可为 nil）
    func configure_Nest(user: PrewUserModel_Nest, lastMessage: MessageModel_Nest?) {
        avatarView_Nest.configure_Nest(userId_Nest: user.userId_Nest ?? 0)
        nameLabel_Nest.text = user.userName_Nest ?? "User"

        if let msg_Nest = lastMessage {
            lastMsgLabel_Nest.text = msg_Nest.content_Nest ?? "Start a conversation"
            timeLabel_Nest.text = msg_Nest.time_Nest ?? ""
            // 对方最后发送 → 未读态：时间紫色 + 加粗名字 + 左侧强调条 + 未读点可见
            let isUnread_Nest = msg_Nest.isMine_Nest == false
            timeLabel_Nest.textColor = isUnread_Nest
                ? ColorConfig_Nest.primaryGradientStart_Nest
                : ColorConfig_Nest.textPlaceholder_Nest
            nameLabel_Nest.font = UIFont.systemFont(ofSize: 15, weight: isUnread_Nest ? .bold : .semibold)
            accentBar_Nest.isHidden = !isUnread_Nest
            unreadDot_Nest.isHidden = !isUnread_Nest
        } else {
            lastMsgLabel_Nest.text = "Say hello 👋"
            timeLabel_Nest.text = ""
            timeLabel_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
            nameLabel_Nest.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            accentBar_Nest.isHidden = true
            unreadDot_Nest.isHidden = true
        }
    }

    // MARK: - 按压反馈

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        highlighted ? cardView_Nest.animatePressDown_Nest() : cardView_Nest.animatePressUp_Nest()
    }
}

// MARK: - MessageEmptyView_Nest
/// 空态提示视图
/// 展示：上下浮动图标 + 主标题 + 副标题，无聊天记录时显示
private class MessageEmptyView_Nest: UIView {

    private let iconContainerView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
        v_Nest.layer.cornerRadius = 40
        return v_Nest
    }()

    private let iconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "No messages yet"
        lbl_Nest.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Follow someone and start\na conversation"
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.textAlignment = .center
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmptyUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { startFloatAnimation_Nest() }
    }

    private func setupEmptyUI_Nest() {
        addSubview(iconContainerView_Nest)
        iconContainerView_Nest.addSubview(iconView_Nest)
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)

        iconContainerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(80)
        }
        iconView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(40)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconContainerView_Nest.snp.bottom).offset(20)
            make_Nest.centerX.equalToSuperview()
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(8)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 图标容器整体上下浮动循环动画
    private func startFloatAnimation_Nest() {
        UIView.animate(
            withDuration: 1.8,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: { self.iconContainerView_Nest.transform = CGAffineTransform(translationX: 0, y: -12) }
        )
    }
}
