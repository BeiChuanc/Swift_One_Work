import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面控制器
/// 核心作用：响应式展示与登录用户存在聊天记录的用户列表，支持进入会话。
/// 设计思路：数据从 `MessageViewModel_Posture` 获取，通过通知响应刷新；
///          页面由渐变头图、背景光晕、筛选胶囊行和会话卡片列表构成。
/// 关键属性：`chatStackView_Posture` 渲染会话行，`users_Posture` 保存当前会话用户。
/// 关键方法：`reloadChats_Posture()` 刷新列表。
@MainActor
class MessageList_Posture: UIViewController {

    // MARK: - 属性

    /// 滚动容器
    private let scrollView_Posture = UIScrollView()

    /// 会话列表栈
    private let chatStackView_Posture = UIStackView()

    /// 当前会话用户
    private var users_Posture: [PrewUserModel_Posture] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadChats_Posture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observeMessageState_Posture()
        reloadChats_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建消息列表主体 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        setupBackgroundGlows_Posture()

        let headerCard_Posture = buildHeaderCard_Posture()
        let filterRow_Posture  = buildFilterChipsRow_Posture()

        view.addSubview(headerCard_Posture)
        view.addSubview(filterRow_Posture)
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        contentView_Posture.addSubview(chatStackView_Posture)

        scrollView_Posture.showsVerticalScrollIndicator = false
        chatStackView_Posture.axis = .vertical
        chatStackView_Posture.spacing = 14

        headerCard_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        filterRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(38)
        }

        scrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(filterRow_Posture.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        chatStackView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-130)
        }
    }

    /// 搭建背景光晕装饰
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupBackgroundGlows_Posture() {
        let glow1_Posture = makeGlowBlob_Posture(
            color: ColorConfig_Posture.accentIndigo_Posture.withAlphaComponent(0.14),
            size: 180
        )
        let glow2_Posture = makeGlowBlob_Posture(
            color: ColorConfig_Posture.secondaryGradientStart_Posture.withAlphaComponent(0.13),
            size: 140
        )
        let glow3_Posture = makeGlowBlob_Posture(
            color: ColorConfig_Posture.accentTeal_Posture.withAlphaComponent(0.12),
            size: 120
        )
        view.insertSubview(glow1_Posture, at: 0)
        view.insertSubview(glow2_Posture, at: 0)
        view.insertSubview(glow3_Posture, at: 0)

        glow1_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(60)
            make.width.height.equalTo(180)
        }
        glow2_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(300)
            make.leading.equalToSuperview().offset(-50)
            make.width.height.equalTo(140)
        }
        glow3_Posture.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-100)
            make.trailing.equalToSuperview().offset(44)
            make.width.height.equalTo(120)
        }
    }

    // MARK: - 区块构建

    /// 构建顶部渐变头图卡片
    /// - Parameters: 无
    /// - Returns: UIView - 渐变头图卡片
    /// - Throws: 无
    private func buildHeaderCard_Posture() -> UIView {
        let container_Posture = UIView()
        container_Posture.backgroundColor = .clear

        let gradientCard_Posture = UIView()
        gradientCard_Posture.layer.cornerRadius = 36
        gradientCard_Posture.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientCard_Posture.clipsToBounds = true

        let gradientLayer_Posture = CAGradientLayer()
        gradientLayer_Posture.colors = [
            ColorConfig_Posture.accentIndigo_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.accentTeal_Posture.cgColor
        ]
        gradientLayer_Posture.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Posture.endPoint   = CGPoint(x: 1, y: 1)
        gradientCard_Posture.layer.insertSublayer(gradientLayer_Posture, at: 0)

        // 大背景装饰气泡
        let bubbleA_Posture = makeDecorationBubble_Posture(size: 100, alpha: 0.12)
        let bubbleB_Posture = makeDecorationBubble_Posture(size: 60, alpha: 0.1)

        // 图标
        let iconContainer_Posture = UIView()
        iconContainer_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconContainer_Posture.layer.cornerRadius = 26

        let iconView_Posture = UIImageView(image: UIImage(systemName: "message.fill"))
        iconView_Posture.tintColor = .white
        iconView_Posture.contentMode = .scaleAspectFit

        iconContainer_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Messages"
        titleLabel_Posture.font = .systemFont(ofSize: 32, weight: .heavy)
        titleLabel_Posture.textColor = .white

        // 副标题
        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "Your posture connections"
        subtitleLabel_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)

        // 在线人数胶囊
        let onlineChip_Posture = buildOnlineChip_Posture()

        gradientCard_Posture.addSubview(bubbleA_Posture)
        gradientCard_Posture.addSubview(bubbleB_Posture)
        gradientCard_Posture.addSubview(iconContainer_Posture)
        gradientCard_Posture.addSubview(titleLabel_Posture)
        gradientCard_Posture.addSubview(subtitleLabel_Posture)
        gradientCard_Posture.addSubview(onlineChip_Posture)

        bubbleA_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-18)
            make.width.height.equalTo(100)
        }
        bubbleB_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-28)
            make.bottom.equalToSuperview().offset(20)
            make.width.height.equalTo(60)
        }
        iconContainer_Posture.snp.makeConstraints { make in
            let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44
            make.top.equalToSuperview().offset(safeTop_Posture + 16)
            make.leading.equalToSuperview().offset(22)
            make.width.height.equalTo(52)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconContainer_Posture.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().inset(22)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel_Posture)
        }
        onlineChip_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(18)
            make.leading.equalTo(titleLabel_Posture)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(32)
        }

        container_Posture.addSubview(gradientCard_Posture)
        gradientCard_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        DispatchQueue.main.async {
            gradientLayer_Posture.frame = gradientCard_Posture.bounds
        }

        return container_Posture
    }

    /// 构建在线状态胶囊
    /// - Parameters: 无
    /// - Returns: UIView - 在线胶囊
    /// - Throws: 无
    private func buildOnlineChip_Posture() -> UIView {
        let chip_Posture = UIView()
        chip_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        chip_Posture.layer.cornerRadius = 16

        let dot_Posture = UIView()
        dot_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture
        dot_Posture.layer.cornerRadius = 5

        let label_Posture = UILabel()
        label_Posture.text = "Active Community"
        label_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        label_Posture.textColor = .white

        chip_Posture.addSubview(dot_Posture)
        chip_Posture.addSubview(label_Posture)

        dot_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }
        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(dot_Posture.snp.trailing).offset(7)
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }

        return chip_Posture
    }

    /// 构建筛选胶囊行
    /// - Parameters: 无
    /// - Returns: UIView - 筛选胶囊横向行
    /// - Throws: 无
    private func buildFilterChipsRow_Posture() -> UIView {
        let container_Posture = UIScrollView()
        container_Posture.showsHorizontalScrollIndicator = false
        container_Posture.alwaysBounceHorizontal = true

        let stack_Posture = UIStackView()
        stack_Posture.axis = .horizontal
        stack_Posture.spacing = 10

        let chips_Posture: [(String, String, Int)] = [
            ("All",         "tray.fill",             0),
            ("Following",   "person.2.fill",          2),
            ("Unread",      "envelope.badge.fill",    3),
            ("Pinned",      "pin.fill",               4),
        ]

        chips_Posture.enumerated().forEach { idx_Posture, chip_Posture in
            let isFirst_Posture = idx_Posture == 0
            stack_Posture.addArrangedSubview(makeFilterChip_Posture(
                title: chip_Posture.0,
                icon: chip_Posture.1,
                colorIndex: chip_Posture.2,
                selected: isFirst_Posture
            ))
        }

        container_Posture.addSubview(stack_Posture)
        stack_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        return container_Posture
    }

    /// 创建单个筛选胶囊
    /// - Parameters:
    ///   - title: 标题文字
    ///   - icon: SF Symbols 名称
    ///   - colorIndex: 调色盘索引
    ///   - selected: 是否选中状态
    /// - Returns: UIView - 胶囊视图
    /// - Throws: 无
    private func makeFilterChip_Posture(title: String, icon: String, colorIndex: Int, selected: Bool) -> UIView {
        let colors_Posture = ColorConfig_Posture.chipColors_Posture(at: colorIndex)
        let chip_Posture = UIView()
        chip_Posture.backgroundColor = selected ? colors_Posture.tint : colors_Posture.bg
        chip_Posture.layer.cornerRadius = 19

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = selected ? .white : colors_Posture.tint
        iconView_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = title
        label_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        label_Posture.textColor = selected ? .white : colors_Posture.tint

        chip_Posture.addSubview(iconView_Posture)
        chip_Posture.addSubview(label_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Posture.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }
        chip_Posture.snp.makeConstraints { make in
            make.height.equalTo(38)
        }

        return chip_Posture
    }

    // MARK: - 数据刷新

    /// 监听消息状态
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func observeMessageState_Posture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageState_Posture),
            name: MessageViewModel_Posture.messageStateDidChangeNotification_Posture,
            object: nil
        )
    }

    /// 消息状态变化回调
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handleMessageState_Posture() {
        reloadChats_Posture()
    }

    /// 刷新会话列表
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func reloadChats_Posture() {
        users_Posture = MessageViewModel_Posture.shared_Posture.getChatUsers_Posture()

        chatStackView_Posture.arrangedSubviews.forEach { view_Posture in
            chatStackView_Posture.removeArrangedSubview(view_Posture)
            view_Posture.removeFromSuperview()
        }

        guard !users_Posture.isEmpty else {
            chatStackView_Posture.addArrangedSubview(makeEmptyState_Posture())
            return
        }

        users_Posture.enumerated().forEach { index_Posture, user_Posture in
            let row_Posture = MsgConversationRow_Posture()
            row_Posture.configure_Posture(user_Posture: user_Posture, index_Posture: index_Posture)
            row_Posture.onTap_Posture = { selected_Posture in
                Navigation_Posture.toMessageUser_Posture(with: selected_Posture)
            }
            chatStackView_Posture.addArrangedSubview(row_Posture)
            row_Posture.animateSlideInFromBottom_Posture(delay_Posture: Double(index_Posture) * 0.05)
        }
    }

    // MARK: - 辅助视图

    /// 创建背景光晕圆
    /// - Parameters:
    ///   - color: 光晕颜色
    ///   - size: 圆的尺寸
    /// - Returns: UIView - 光晕视图
    /// - Throws: 无
    private func makeGlowBlob_Posture(color: UIColor, size: CGFloat) -> UIView {
        let view_Posture = UIView()
        view_Posture.backgroundColor = color
        view_Posture.layer.cornerRadius = size / 2
        view_Posture.isUserInteractionEnabled = false
        return view_Posture
    }

    /// 创建头图装饰泡泡
    /// - Parameters:
    ///   - size: 尺寸
    ///   - alpha: 透明度
    /// - Returns: UIView - 装饰圆视图
    /// - Throws: 无
    private func makeDecorationBubble_Posture(size: CGFloat, alpha: CGFloat) -> UIView {
        let view_Posture = UIView()
        view_Posture.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view_Posture.layer.cornerRadius = size / 2
        view_Posture.isUserInteractionEnabled = false
        return view_Posture
    }

    /// 构建空状态视图
    /// - Parameters: 无
    /// - Returns: UIView - 精美空状态
    /// - Throws: 无
    private func makeEmptyState_Posture() -> UIView {
        let container_Posture = UIView()
        container_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        container_Posture.layer.cornerRadius = 32
        container_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        container_Posture.layer.shadowOpacity = 1
        container_Posture.layer.shadowRadius = 16
        container_Posture.layer.shadowOffset = CGSize(width: 0, height: 8)

        // 图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = ColorConfig_Posture.accentIndigoLight_Posture
        iconBg_Posture.layer.cornerRadius = 36

        let iconView_Posture = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        iconView_Posture.tintColor = ColorConfig_Posture.accentIndigo_Posture
        iconView_Posture.contentMode = .scaleAspectFit

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "No Conversations Yet"
        titleLabel_Posture.font = .systemFont(ofSize: 18, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.textAlignment = .center

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "Follow someone on their profile page\nand start a posture conversation."
        subtitleLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        subtitleLabel_Posture.textAlignment = .center
        subtitleLabel_Posture.numberOfLines = 2

        // 提示胶囊
        let tipChip_Posture = UIView()
        tipChip_Posture.backgroundColor = ColorConfig_Posture.accentTealLight_Posture
        tipChip_Posture.layer.cornerRadius = 18

        let tipIcon_Posture = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        tipIcon_Posture.tintColor = ColorConfig_Posture.accentTeal_Posture
        tipIcon_Posture.contentMode = .scaleAspectFit

        let tipLabel_Posture = UILabel()
        tipLabel_Posture.text = "Go to Discover to find people"
        tipLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        tipLabel_Posture.textColor = ColorConfig_Posture.accentTeal_Posture

        tipChip_Posture.addSubview(tipIcon_Posture)
        tipChip_Posture.addSubview(tipLabel_Posture)

        iconBg_Posture.addSubview(iconView_Posture)
        container_Posture.addSubview(iconBg_Posture)
        container_Posture.addSubview(titleLabel_Posture)
        container_Posture.addSubview(subtitleLabel_Posture)
        container_Posture.addSubview(tipChip_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(42)
        }
        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        tipIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        tipLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(tipIcon_Posture.snp.trailing).offset(7)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        tipChip_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(38)
        }

        return container_Posture
    }
}

// MARK: - 会话行组件

/// 精美会话行
/// 核心作用：展示单条会话条目，包括彩色头像圈、名称、消息摘要、时间、在线点和未读徽章。
/// 设计思路：每行按 index 从调色盘取色，点击通过回调交给页面处理导航。
/// 关键属性：彩色 `ringView_Posture` 包裹头像，`unreadBadge_Posture` 展示未读提示。
/// 关键方法：`configure_Posture(user_Posture:index_Posture:)` 绑定数据与颜色。
@MainActor
private class MsgConversationRow_Posture: UIView {

    // MARK: - 子视图

    /// 卡片容器
    private let cardView_Posture = UIView()

    /// 头像颜色环
    private let ringView_Posture = UIView()

    /// 用户头像
    private let avatarView_Posture = UserAvatarView_Posture()

    /// 在线指示点
    private let onlineDot_Posture = UIView()

    /// 名称
    private let nameLabel_Posture = UILabel()

    /// 消息预览
    private let messageLabel_Posture = UILabel()

    /// 时间
    private let timeLabel_Posture = UILabel()

    /// 未读徽章
    private let unreadBadge_Posture = UIView()
    private let unreadLabel_Posture = UILabel()

    /// 右侧箭头
    private let chevronView_Posture = UIImageView()

    /// 顶部装饰色条
    private let topStripe_Posture = UIView()

    /// 当前用户数据
    private var user_Posture: PrewUserModel_Posture?

    /// 点击回调
    var onTap_Posture: ((PrewUserModel_Posture) -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 搭建会话行 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        addSubview(cardView_Posture)
        cardView_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        cardView_Posture.layer.cornerRadius = 26
        cardView_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        cardView_Posture.layer.shadowOpacity = 1
        cardView_Posture.layer.shadowRadius = 14
        cardView_Posture.layer.shadowOffset = CGSize(width: 0, height: 8)

        cardView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 顶部左侧装饰色条
        topStripe_Posture.layer.cornerRadius = 3
        cardView_Posture.addSubview(topStripe_Posture)

        // 头像环
        ringView_Posture.layer.cornerRadius = 32
        ringView_Posture.layer.borderWidth = 2.5
        cardView_Posture.addSubview(ringView_Posture)
        ringView_Posture.addSubview(avatarView_Posture)

        // 在线点
        onlineDot_Posture.layer.cornerRadius = 7
        onlineDot_Posture.layer.borderWidth = 2
        onlineDot_Posture.layer.borderColor = UIColor.white.cgColor
        cardView_Posture.addSubview(onlineDot_Posture)

        // 文字
        nameLabel_Posture.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        cardView_Posture.addSubview(nameLabel_Posture)

        messageLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        messageLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        messageLabel_Posture.numberOfLines = 1
        cardView_Posture.addSubview(messageLabel_Posture)

        timeLabel_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        timeLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        timeLabel_Posture.textAlignment = .right
        cardView_Posture.addSubview(timeLabel_Posture)

        // 未读徽章
        unreadBadge_Posture.layer.cornerRadius = 11
        unreadBadge_Posture.clipsToBounds = true
        unreadLabel_Posture.font = .systemFont(ofSize: 10, weight: .heavy)
        unreadLabel_Posture.textColor = .white
        unreadLabel_Posture.textAlignment = .center
        unreadBadge_Posture.addSubview(unreadLabel_Posture)
        cardView_Posture.addSubview(unreadBadge_Posture)

        // 箭头
        chevronView_Posture.image = UIImage(systemName: "chevron.right")
        chevronView_Posture.contentMode = .scaleAspectFit
        chevronView_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        cardView_Posture.addSubview(chevronView_Posture)

        // 约束
        snp.makeConstraints { make in make.height.equalTo(100) }

        topStripe_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(ringView_Posture)
            make.width.equalTo(4)
            make.height.equalTo(44)
        }

        ringView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }

        avatarView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }

        onlineDot_Posture.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(ringView_Posture).inset(1)
            make.width.height.equalTo(14)
        }

        nameLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.equalTo(ringView_Posture.snp.trailing).offset(16)
            make.trailing.equalTo(timeLabel_Posture.snp.leading).offset(-8)
        }

        messageLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Posture.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel_Posture)
            make.trailing.equalTo(unreadBadge_Posture.snp.leading).offset(-8)
        }

        timeLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Posture)
            make.trailing.equalTo(chevronView_Posture.snp.leading).offset(-6)
            make.width.equalTo(46)
        }

        unreadBadge_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(messageLabel_Posture)
            make.trailing.equalTo(chevronView_Posture.snp.leading).offset(-8)
            make.width.greaterThanOrEqualTo(22)
            make.height.equalTo(22)
        }

        unreadLabel_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        chevronView_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(16)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture)))
    }

    // MARK: - 数据绑定

    /// 绑定用户数据并按 index 应用配色
    /// - Parameters:
    ///   - user_Posture: 用户模型
    ///   - index_Posture: 列表位置，用于调色盘取色
    /// - Returns: Void
    /// - Throws: 无
    func configure_Posture(user_Posture: PrewUserModel_Posture, index_Posture: Int) {
        self.user_Posture = user_Posture

        let palette_Posture = ColorConfig_Posture.cardAccentPalette_Posture[index_Posture % ColorConfig_Posture.cardAccentPalette_Posture.count]

        // 颜色主题
        ringView_Posture.layer.borderColor = palette_Posture.main.cgColor
        topStripe_Posture.backgroundColor  = palette_Posture.main
        unreadBadge_Posture.backgroundColor = palette_Posture.main
        cardView_Posture.layer.shadowColor  = palette_Posture.shadow.cgColor

        // 在线点颜色：奇数 in 偶数 away
        let isOnline_Posture = (index_Posture % 2 == 0)
        onlineDot_Posture.backgroundColor = isOnline_Posture ? ColorConfig_Posture.accentMint_Posture : ColorConfig_Posture.textPlaceholder_Posture

        // 头像
        avatarView_Posture.configure_Posture(userId_Posture: user_Posture.userId_Posture ?? 0)

        // 名称
        nameLabel_Posture.text = user_Posture.userName_Posture ?? "User"

        // 最后消息
        let last_Posture = MessageViewModel_Posture.shared_Posture.getLastMessageWithUser_Posture(userId_posture: user_Posture.userId_Posture ?? 0)
        if let last_Posture {
            let prefix_Posture = last_Posture.isMine_Posture == true ? "You: " : ""
            messageLabel_Posture.text = prefix_Posture + (last_Posture.content_Posture ?? "")
            timeLabel_Posture.text    = last_Posture.time_Posture ?? ""

            // 模拟未读：非自己发送的最后消息显示未读 badge
            let hasUnread_Posture = last_Posture.isMine_Posture != true
            unreadBadge_Posture.isHidden = !hasUnread_Posture
            unreadLabel_Posture.text = hasUnread_Posture ? "1" : ""
        } else {
            messageLabel_Posture.text = "Tap to start chatting."
            timeLabel_Posture.text = ""
            unreadBadge_Posture.isHidden = true
        }
    }

    // MARK: - 事件

    /// 处理行点击
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handleTap_Posture() {
        guard let user_Posture else { return }
        animatePressDown_Posture { [weak self] in
            self?.animatePressUp_Posture()
            self?.onTap_Posture?(user_Posture)
        }
    }
}
