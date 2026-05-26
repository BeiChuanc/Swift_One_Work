import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表视图控制器
/// 功能：响应式展示与登录用户存在聊天记录的用户列表，点击进入对话
/// 设计：全屏沉浸式渐变头部（圆角底部）+ 多色渐变头像环 + 彩色时间胶囊 + 卡片动效
/// 响应：监听 MessageViewModel 通知实时刷新列表
class MessageList_Niche: UIViewController {

    // MARK: - 私有属性

    private var _chatUsers_niche: [PrewUserModel_Niche] = []

    /// 每行卡片循环使用的渐变色对（start, end）
    private let _gradPairs_niche: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Niche: "#B794F6"), UIColor(hexstring_Niche: "#90CDF4")),
        (UIColor(hexstring_Niche: "#FF6B9D"), UIColor(hexstring_Niche: "#FBB6CE")),
        (UIColor(hexstring_Niche: "#4ECDC4"), UIColor(hexstring_Niche: "#74B9FF")),
        (UIColor(hexstring_Niche: "#FDCB6E"), UIColor(hexstring_Niche: "#FD79A8")),
        (UIColor(hexstring_Niche: "#55EFC4"), UIColor(hexstring_Niche: "#74B9FF")),
        (UIColor(hexstring_Niche: "#A29BFE"), UIColor(hexstring_Niche: "#D4B8FF")),
        (UIColor(hexstring_Niche: "#FF8C00"), UIColor(hexstring_Niche: "#FFD700"))
    ]

    // MARK: - UI 组件 / 头部

    /// 渐变头部视图（圆角底部）
    private let _headerView_niche = UIView()

    /// 装饰性大气泡 1（右上）
    private let _orb1_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.12)
        v_niche.layer.cornerRadius = 60
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 装饰性大气泡 2（左中）
    private let _orb2_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        v_niche.layer.cornerRadius = 44
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()


    /// 页面大图标
    private let _pageIconView_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        iv_niche.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = UIColor.white.withValues(alpha: 0.6)
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    /// 页面主标题
    private let _titleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Messages"
        l_niche.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        l_niche.textColor = .white
        return l_niche
    }()

    /// 会话数量标签
    private let _countLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.75)
        return l_niche
    }()

    /// 底部浮动装饰条
    private let _headerDecorBar_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.15)
        v_niche.layer.cornerRadius = 2
        return v_niche
    }()

    // MARK: - UI 组件 / 列表

    private lazy var _tableView_niche: UITableView = {
        let tv_niche = UITableView(frame: .zero, style: .plain)
        tv_niche.backgroundColor = .clear
        tv_niche.separatorStyle = .none
        tv_niche.showsVerticalScrollIndicator = false
        tv_niche.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        tv_niche.register(MessageListCell_Niche.self, forCellReuseIdentifier: MessageListCell_Niche.reuseId_Niche)
        tv_niche.dataSource = self
        tv_niche.delegate = self
        return tv_niche
    }()

    private let _emptyContainer_niche = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        setupObservers_Niche()
        refreshData_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshData_Niche()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F0EEFF")

        // ── 沉浸式渐变头部 ──
        view.addSubview(_headerView_niche)
        _headerView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }

        // 装饰气泡（右上）
        _headerView_niche.addSubview(_orb1_niche)
        _orb1_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-24)
            make.trailing.equalToSuperview().offset(18)
            make.width.height.equalTo(120)
        }

        // 装饰气泡（左中）
        _headerView_niche.addSubview(_orb2_niche)
        _orb2_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(-20)
            make.width.height.equalTo(88)
        }

        // 图标
        _headerView_niche.addSubview(_pageIconView_niche)
        _pageIconView_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(22)
            make.width.height.equalTo(28)
        }

        // 主标题
        _headerView_niche.addSubview(_titleLabel_niche)
        _titleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_pageIconView_niche.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(22)
        }

        // 会话数量
        _headerView_niche.addSubview(_countLabel_niche)
        _countLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_niche.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }

        // 底部装饰条
        _headerView_niche.addSubview(_headerDecorBar_niche)
        _headerDecorBar_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(3)
        }

        // ── 列表 ──
        view.addSubview(_tableView_niche)
        _tableView_niche.snp.makeConstraints { make in
            make.top.equalTo(_headerView_niche.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        // ── 空状态 ──
        buildEmptyState_Niche()
        view.bringSubviewToFront(_emptyContainer_niche)
    }

    private func buildEmptyState_Niche() {
        view.addSubview(_emptyContainer_niche)
        _emptyContainer_niche.isHidden = true
        _emptyContainer_niche.snp.makeConstraints { make in
            make.center.equalTo(_tableView_niche)
            make.width.equalToSuperview().multipliedBy(0.72)
        }

        let iconBg_niche = UIView()
        iconBg_niche.layer.cornerRadius = 40
        _emptyContainer_niche.addSubview(iconBg_niche)
        iconBg_niche.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        DispatchQueue.main.async {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: iconBg_niche.bounds)
            grad_niche.cornerRadius = 40
            iconBg_niche.layer.insertSublayer(grad_niche, at: 0)
        }

        let emptyIV_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        emptyIV_niche.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg_niche)
        emptyIV_niche.tintColor = .white
        emptyIV_niche.contentMode = .scaleAspectFit
        iconBg_niche.addSubview(emptyIV_niche)
        emptyIV_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(38)
        }

        let emptyTitle_niche = UILabel()
        emptyTitle_niche.text = "No conversations yet"
        emptyTitle_niche.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        emptyTitle_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        emptyTitle_niche.textAlignment = .center
        _emptyContainer_niche.addSubview(emptyTitle_niche)
        emptyTitle_niche.snp.makeConstraints { make in
            make.top.equalTo(iconBg_niche.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
        }

        let emptyHint_niche = UILabel()
        emptyHint_niche.text = "Follow someone and start a chat\nto see messages here"
        emptyHint_niche.font = UIFont.systemFont(ofSize: 13)
        emptyHint_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        emptyHint_niche.textAlignment = .center
        emptyHint_niche.numberOfLines = 2
        _emptyContainer_niche.addSubview(emptyHint_niche)
        emptyHint_niche.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle_niche.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 渐变

    private func refreshHeaderGradient_Niche() {
        _headerView_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_headerView_niche.bounds.isEmpty else { return }

        // 主渐变（左上→右下，增加方向感）
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _headerView_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#9B59B6").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#74B9FF").cgColor
        ]
        grad_niche.locations = [0, 0.5, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 1)
        // 底部圆角
        grad_niche.cornerRadius = 32
        grad_niche.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        _headerView_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    // MARK: - 数据

    private func setupObservers_Niche() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Niche),
            name: MessageViewModel_Niche.messageStateDidChangeNotification_Niche,
            object: nil
        )
    }

    @objc private func handleDataChange_Niche() {
        refreshData_Niche()
    }

    private func refreshData_Niche() {
        _chatUsers_niche = MessageViewModel_Niche.shared_Niche.getChatUsers_Niche()
        let isEmpty_niche = _chatUsers_niche.isEmpty
        _emptyContainer_niche.isHidden = !isEmpty_niche
        _tableView_niche.isHidden = isEmpty_niche

        let count_niche = _chatUsers_niche.count
        _countLabel_niche.text = count_niche == 0
            ? "No active conversations"
            : "\(count_niche) conversation\(count_niche > 1 ? "s" : "") active"

        _tableView_niche.reloadData()
    }
}

// MARK: - UITableViewDataSource / Delegate

extension MessageList_Niche: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _chatUsers_niche.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_niche = tableView.dequeueReusableCell(
            withReuseIdentifier: MessageListCell_Niche.reuseId_Niche,
            for: indexPath
        ) as? MessageListCell_Niche else {
            return UITableViewCell()
        }
        let user_niche    = _chatUsers_niche[indexPath.row]
        let lastMsg_niche = MessageViewModel_Niche.shared_Niche.getLastMessageWithUser_Niche(
            userId_niche: user_niche.userId_Niche ?? 0
        )
        let pair_niche = _gradPairs_niche[indexPath.row % _gradPairs_niche.count]
        cell_niche.configure_Niche(user: user_niche, lastMessage: lastMsg_niche, gradStart: pair_niche.0, gradEnd: pair_niche.1)
        return cell_niche
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 96 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Niche.toMessageUser_Niche(with: _chatUsers_niche[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: -20, y: 0)
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationSpring_Niche,
            delay: Double(indexPath.row % 5) * 0.06,
            usingSpringWithDamping: AnimationConfig_Niche.springDampingNormal_Niche,
            initialSpringVelocity: AnimationConfig_Niche.springVelocity_Niche,
            options: [.allowUserInteraction]
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}

// MARK: - 消息列表 Cell

/// 消息列表单元格
/// 设计：渐变色头像环 + 名称 + 消息预览 + 彩色时间胶囊 + 卡片彩色阴影
/// 布局：先全部 addSubview，再统一设置约束（避免公共祖先崩溃）
class MessageListCell_Niche: UITableViewCell {

    static let reuseId_Niche = "MessageListCell_Niche"

    // MARK: - 私有

    private var _gradStart_niche: UIColor = ColorConfig_Niche.primaryGradientStart_Niche
    private var _gradEnd_niche:   UIColor = ColorConfig_Niche.primaryGradientEnd_Niche
    private var _avatarGradLayer_niche: CAGradientLayer?
    private var _timePillGradLayer_niche: CAGradientLayer?

    // MARK: - 子视图

    /// 卡片容器
    private let _card_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 20
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 5)
        v_niche.layer.shadowRadius = 14
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    /// 头像渐变外环
    private let _avatarRing_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 30
        return v_niche
    }()

    /// 头像
    private let _avatarView_niche = UserAvatarView_Niche()

    /// 活跃指示点（头像右下角的小圆点）
    private let _activeDot_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor(hexstring_Niche: "#2ECC71")
        v_niche.layer.cornerRadius = 6
        v_niche.layer.borderWidth = 2
        v_niche.layer.borderColor = UIColor.white.cgColor
        return v_niche
    }()

    /// 用户名
    private let _nameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        return l_niche
    }()

    /// 消息预览文字
    private let _previewLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 13)
        l_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        l_niche.lineBreakMode = .byTruncatingTail
        return l_niche
    }()

    /// 时间胶囊容器（渐变背景）
    private let _timePill_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 10
        v_niche.layer.masksToBounds = true
        return v_niche
    }()

    /// 时间文字
    private let _timeLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        return l_niche
    }()

    /// 进入图标（渐变色）
    private let _arrowView_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        iv_niche.image = UIImage(systemName: "chevron.right.circle.fill", withConfiguration: cfg_niche)
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Niche()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _avatarGradLayer_niche?.frame  = _avatarRing_niche.bounds
        _timePillGradLayer_niche?.frame = _timePill_niche.bounds
    }

    private func setupCellUI_Niche() {
        backgroundColor = .clear
        selectionStyle = .none

        // 卡片
        contentView.addSubview(_card_niche)
        _card_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-5)
        }

        // 先全部 addSubview 到 _card_niche，再统一设约束
        _card_niche.addSubview(_avatarRing_niche)
        _avatarRing_niche.addSubview(_avatarView_niche)
        _card_niche.addSubview(_activeDot_niche)
        _card_niche.addSubview(_timePill_niche)
        _card_niche.addSubview(_arrowView_niche)
        _card_niche.addSubview(_nameLabel_niche)
        _card_niche.addSubview(_previewLabel_niche)
        _timePill_niche.addSubview(_timeLabel_niche)

        // 头像外环
        _avatarRing_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        // 头像（内缩留出渐变外环）
        _avatarView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }

        // 活跃指示点（头像右下角）
        _activeDot_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_avatarRing_niche.snp.trailing).offset(-2)
            make.bottom.equalTo(_avatarRing_niche.snp.bottom).offset(-2)
            make.width.height.equalTo(12)
        }

        // 右侧进入图标
        _arrowView_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        // 时间胶囊
        _timePill_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_arrowView_niche.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        _timeLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        // 用户名
        _nameLabel_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(_avatarRing_niche.snp.trailing).offset(14)
            make.trailing.lessThanOrEqualTo(_timePill_niche.snp.leading).offset(-8)
        }

        // 消息预览
        _previewLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_nameLabel_niche.snp.bottom).offset(6)
            make.leading.equalTo(_avatarRing_niche.snp.trailing).offset(14)
            make.trailing.equalTo(_arrowView_niche.snp.leading).offset(-8)
        }
    }

    // MARK: - 配置

    /// 配置单元格
    /// - Parameters:
    ///   - user: 用户模型
    ///   - lastMessage: 最后一条消息
    ///   - gradStart: 渐变色起始
    ///   - gradEnd: 渐变色结束
    func configure_Niche(
        user: PrewUserModel_Niche,
        lastMessage: MessageModel_Niche?,
        gradStart: UIColor,
        gradEnd: UIColor
    ) {
        _gradStart_niche = gradStart
        _gradEnd_niche   = gradEnd

        _avatarView_niche.configure_Niche(userId_Niche: user.userId_Niche ?? 0)
        _nameLabel_niche.text    = user.userName_Niche ?? "User"
        _previewLabel_niche.text = lastMessage?.content_Niche ?? "Start chatting with them..."
        _timeLabel_niche.text    = lastMessage?.time_Niche ?? ""

        // 活跃点颜色跟随主题色
        _activeDot_niche.backgroundColor = gradStart

        // 箭头图标颜色
        _arrowView_niche.tintColor = gradStart

        // 卡片彩色阴影
        _card_niche.layer.shadowColor = gradStart.withValues(alpha: 0.22).cgColor

        // 头像渐变外环
        rebuildAvatarRingGrad_Niche()

        // 时间胶囊渐变
        rebuildTimePillGrad_Niche()
    }

    private func rebuildAvatarRingGrad_Niche() {
        _avatarGradLayer_niche?.removeFromSuperlayer()
        let grad_niche = CAGradientLayer()
        grad_niche.cornerRadius = 30
        grad_niche.colors = [_gradStart_niche.cgColor, _gradEnd_niche.cgColor]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint   = CGPoint(x: 1, y: 1)
        _avatarRing_niche.layer.insertSublayer(grad_niche, at: 0)
        _avatarGradLayer_niche = grad_niche
    }

    private func rebuildTimePillGrad_Niche() {
        _timePillGradLayer_niche?.removeFromSuperlayer()
        let grad_niche = CAGradientLayer()
        grad_niche.cornerRadius = 10
        grad_niche.colors = [_gradStart_niche.cgColor, _gradEnd_niche.cgColor]
        grad_niche.startPoint = CGPoint(x: 0, y: 0.5)
        grad_niche.endPoint   = CGPoint(x: 1, y: 0.5)
        _timePill_niche.layer.insertSublayer(grad_niche, at: 0)
        _timePillGradLayer_niche = grad_niche
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _nameLabel_niche.text    = nil
        _previewLabel_niche.text = nil
        _timeLabel_niche.text    = nil
    }
}

// MARK: - UITableView dequeueReusableCell 修正

private extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(
        withReuseIdentifier identifier: String,
        for indexPath: IndexPath
    ) -> T? {
        dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
    }
}
