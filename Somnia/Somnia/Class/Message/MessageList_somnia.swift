import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面

/// 消息列表页面
/// 核心作用：展示当前登录用户所有有聊天记录的会话列表，支持点击进入聊天、左滑删除
/// 设计思路：三色渐变圆角头部 + 浮动粒子 + "RECENT CHATS"分组行（含计数角标）+ 卡片 Cell 进场动画
class MessageList_Somnia: UIViewController {

    // MARK: - 私有属性

    /// 有聊天记录的用户列表
    private var chatUsers_Somnia: [PrewUserModel_Somnia] = []

    // MARK: - UI 组件 — 头部

    /// 渐变头部容器（底部双圆角）
    private let headerContainer_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    private var headerGradient_Somnia: CAGradientLayer?

    /// 顶部小标签行（YOUR CONVERSATIONS）
    private let headerTagLabel_Somnia: UILabel = {
        let lbl = UILabel()
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .kern: 2.0
        ]
        lbl.attributedText = NSAttributedString(string: "YOUR CONVERSATIONS", attributes: attrs)
        return lbl
    }()

    /// 标题左侧渐变装饰竖条
    private let titleAccentBar_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2.5
        v.clipsToBounds = true
        return v
    }()

    private var titleAccentBarGrad_Somnia: CAGradientLayer?

    /// 主标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Messages"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .white
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOpacity = 0.14
        lbl.layer.shadowRadius = 4
        return lbl
    }()

    /// 副标题（会话数量 + 图标内联）
    private let subtitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.78)
        return lbl
    }()


    /// 浮动粒子视图数组
    private var particleViews_Somnia: [UIView] = []

    // MARK: - UI 组件 — 分组标题行

    /// 分组标题容器（RECENT CHATS + 计数角标）
    private let sectionView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// "RECENT CHATS" 标签
    private let sectionLabel_Somnia: UILabel = {
        let lbl = UILabel()
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: ColorConfig_Somnia.textSecondary_Somnia,
            .kern: 1.3
        ]
        lbl.attributedText = NSAttributedString(string: "RECENT CHATS", attributes: attrs)
        return lbl
    }()

    /// 会话计数角标（薰衣草色系）
    private let sectionCountBadge_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        lbl.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.12)
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        return lbl
    }()

    /// 分隔线
    private let sectionDivider_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.divider_Somnia
        return v
    }()

    // MARK: - UI 组件 — 列表与空状态

    private let tableView_Somnia: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
        return tv
    }()

    private let emptyStateView_Somnia: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconView_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 44
        return v
    }()

    private var emptyIconGradient_Somnia: CAGradientLayer?

    private let emptySymbol_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyTitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "No conversations yet"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.textAlignment = .center
        return lbl
    }()

    private let emptyDescLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start chatting with someone\nand your conversations will appear here ✨"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Somnia()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        setupUI_Somnia()
        setupTableView_Somnia()
        observeMessageState_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayout_Somnia()
    }

    // MARK: - 消息状态监听

    /// 注册消息状态变化通知
    private func observeMessageState_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Somnia),
            name: MessageViewModel_Somnia.messageStateDidChangeNotification_Somnia,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Somnia() {
        reloadData_Somnia()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 数据加载

    /// 刷新会话列表数据
    func reloadData_Somnia() {
        chatUsers_Somnia = MessageViewModel_Somnia.shared_Somnia.getChatUsers_Somnia()
        updateSubtitle_Somnia()
        updateEmptyState_Somnia()
        tableView_Somnia.reloadData()
    }

    /// 更新副标题与分组计数角标
    private func updateSubtitle_Somnia() {
        let count = chatUsers_Somnia.count
        let text = count == 0
            ? "💬  No active chats  ·  Start a new one"
            : "💬  \(count) active conversation\(count > 1 ? "s" : "")  ·  Stay in touch"
        subtitleLabel_Somnia.text = text
        sectionCountBadge_Somnia.text = "  \(count)  "
    }

    /// 切换空状态与列表可见性
    private func updateEmptyState_Somnia() {
        let isEmpty = chatUsers_Somnia.isEmpty
        if isEmpty && emptyStateView_Somnia.isHidden {
            emptyStateView_Somnia.isHidden = false
            emptyStateView_Somnia.animateSpringScaleIn_Somnia(delay_Somnia: 0.1)
        } else if !isEmpty {
            emptyStateView_Somnia.isHidden = true
        }
        tableView_Somnia.isHidden = isEmpty
        sectionView_Somnia.isHidden = isEmpty
    }

    // MARK: - UI 搭建

    private func setupUI_Somnia() {
        view.addSubview(headerContainer_Somnia)
        headerContainer_Somnia.addSubview(headerTagLabel_Somnia)
        headerContainer_Somnia.addSubview(titleAccentBar_Somnia)
        headerContainer_Somnia.addSubview(titleLabel_Somnia)
        headerContainer_Somnia.addSubview(subtitleLabel_Somnia)
        view.addSubview(sectionView_Somnia)
        sectionView_Somnia.addSubview(sectionLabel_Somnia)
        sectionView_Somnia.addSubview(sectionCountBadge_Somnia)
        sectionView_Somnia.addSubview(sectionDivider_Somnia)

        view.addSubview(tableView_Somnia)

        view.addSubview(emptyStateView_Somnia)
        emptyStateView_Somnia.addSubview(emptyIconView_Somnia)
        emptyIconView_Somnia.addSubview(emptySymbol_Somnia)
        emptyStateView_Somnia.addSubview(emptyTitleLabel_Somnia)
        emptyStateView_Somnia.addSubview(emptyDescLabel_Somnia)

        setupConstraints_Somnia()
        setupParticles_Somnia()
    }

    private func setupConstraints_Somnia() {
        headerContainer_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(180)
        }

        // 顶部小标签行
        headerTagLabel_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }

        // 标题左侧渐变竖条
        titleAccentBar_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(headerTagLabel_Somnia.snp.bottom).offset(8)
            make.width.equalTo(5)
            make.height.equalTo(38)
        }

        // 主标题（竖条右侧对齐）
        titleLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(titleAccentBar_Somnia.snp.right).offset(10)
            make.centerY.equalTo(titleAccentBar_Somnia)
        }

        // 副标题
        subtitleLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Somnia)
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(5)
        }

        // ── 分组标题行 ──
        sectionView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Somnia.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(36)
        }

        sectionLabel_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.centerY.equalToSuperview()
        }

        sectionCountBadge_Somnia.snp.makeConstraints { make in
            make.left.equalTo(sectionLabel_Somnia.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        sectionDivider_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        tableView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(sectionView_Somnia.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        emptyStateView_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.snp.centerY).offset(40)
            make.width.equalTo(280)
        }

        emptyIconView_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(88)
        }

        emptySymbol_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(42)
        }

        emptyTitleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Somnia.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }

        emptyDescLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupTableView_Somnia() {
        tableView_Somnia.delegate = self
        tableView_Somnia.dataSource = self
        tableView_Somnia.register(MessageListCell_Somnia.self,
                                  forCellReuseIdentifier: MessageListCell_Somnia.reuseId_Somnia)
        tableView_Somnia.rowHeight = 96
    }

    // MARK: - 渐变图层更新

    private func updateGradientLayout_Somnia() {
        // 三色渐变头部
        if headerGradient_Somnia == nil {
            let g = CAGradientLayer()
            g.colors = [
                UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            g.locations = [0.0, 0.45, 1.0]
            g.startPoint = CGPoint(x: 0.1, y: 0)
            g.endPoint   = CGPoint(x: 0.9, y: 1)
            headerContainer_Somnia.layer.insertSublayer(g, at: 0)
            headerGradient_Somnia = g
        }
        headerGradient_Somnia?.frame = headerContainer_Somnia.bounds

        // 标题左侧装饰竖条渐变（白色半透明渐变）
        if titleAccentBarGrad_Somnia == nil {
            let ag = CAGradientLayer()
            ag.colors = [
                UIColor.white.withAlphaComponent(0.95).cgColor,
                UIColor.white.withAlphaComponent(0.35).cgColor
            ]
            ag.startPoint = CGPoint(x: 0, y: 0)
            ag.endPoint   = CGPoint(x: 0, y: 1)
            ag.cornerRadius = titleAccentBar_Somnia.layer.cornerRadius
            titleAccentBar_Somnia.layer.insertSublayer(ag, at: 0)
            titleAccentBarGrad_Somnia = ag
        }
        titleAccentBarGrad_Somnia?.frame = titleAccentBar_Somnia.bounds

        // 空状态图标渐变
        if emptyIconGradient_Somnia == nil {
            let ig = CAGradientLayer()
            ig.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            ig.startPoint = CGPoint(x: 0, y: 0)
            ig.endPoint   = CGPoint(x: 1, y: 1)
            ig.cornerRadius = 44
            emptyIconView_Somnia.layer.insertSublayer(ig, at: 0)
            emptyIconGradient_Somnia = ig
        }
        emptyIconGradient_Somnia?.frame = emptyIconView_Somnia.bounds
    }

    // MARK: - 浮动粒子装饰

    private func setupParticles_Somnia() {
        let configs: [(CGFloat, CGFloat, CGFloat)] = [
            (0.82, 0.18, 20),
            (0.72, 0.55, 12),
            (0.88, 0.42,  8),
            (0.15, 0.35, 14),
            (0.25, 0.72, 10),
            (0.65, 0.78,  6)
        ]
        for (idx, cfg) in configs.enumerated() {
            let bubble = UIView()
            bubble.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            bubble.layer.cornerRadius = cfg.2 / 2
            headerContainer_Somnia.addSubview(bubble)
            bubble.snp.makeConstraints { make in
                make.width.height.equalTo(cfg.2)
                make.centerX.equalToSuperview().multipliedBy(cfg.0 * 2)
                make.centerY.equalToSuperview().multipliedBy(cfg.1 * 2)
            }
            particleViews_Somnia.append(bubble)
            startFloatAnimation_Somnia(view_somnia: bubble, delay_somnia: Double(idx) * 0.4)
        }
    }

    /// 单个气泡浮动动画
    private func startFloatAnimation_Somnia(view_somnia: UIView, delay_somnia: TimeInterval) {
        UIView.animate(
            withDuration: 2.2 + delay_somnia * 0.3,
            delay: delay_somnia,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                view_somnia.transform = CGAffineTransform(translationX: 0, y: -10)
                    .concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
            },
            completion: nil
        )
    }
}

// MARK: - UITableViewDataSource

extension MessageList_Somnia: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatUsers_Somnia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Somnia.reuseId_Somnia,
            for: indexPath
        ) as? MessageListCell_Somnia else { return UITableViewCell() }

        let user = chatUsers_Somnia[indexPath.row]
        let lastMsg = MessageViewModel_Somnia.shared_Somnia.getLastMessageWithUser_Somnia(
            userId_somnia: user.userId_Somnia ?? 0
        )
        cell.configure_Somnia(user_somnia: user, lastMessage_somnia: lastMsg)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MessageList_Somnia: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Navigation_Somnia.toMessageUser_Somnia(with: chatUsers_Somnia[indexPath.row])
    }

    /// 左滑删除会话
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, done in
            self?.deleteConversation_Somnia(at: indexPath)
            done(true)
        }
        action.image = UIImage(systemName: "trash.fill",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        action.backgroundColor = UIColor(hexstring_Somnia: "#FC8181")
        return UISwipeActionsConfiguration(actions: [action])
    }

    /// 删除指定索引的会话记录
    private func deleteConversation_Somnia(at indexPath: IndexPath) {
        guard indexPath.row < chatUsers_Somnia.count else { return }
        let user = chatUsers_Somnia[indexPath.row]
        guard let userId = user.userId_Somnia else { return }
        MessageViewModel_Somnia.shared_Somnia.deleteUserMessages_Somnia(userId_somnia: userId)
        chatUsers_Somnia.remove(at: indexPath.row)
        tableView_Somnia.deleteRows(at: [indexPath], with: .left)
        updateSubtitle_Somnia()
        updateEmptyState_Somnia()
    }

    /// Cell 出现时的错落进场动画
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delay = Double(indexPath.row) * AnimationConfig_Somnia.delayShort_Somnia
        cell.transform = CGAffineTransform(translationX: 40, y: 0)
        cell.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Somnia.durationSpring_Somnia,
            delay: delay,
            usingSpringWithDamping: AnimationConfig_Somnia.springDampingNormal_Somnia,
            initialSpringVelocity: AnimationConfig_Somnia.springVelocity_Somnia,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                cell.transform = .identity
                cell.alpha = 1
            },
            completion: nil
        )
    }
}
