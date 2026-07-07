import Foundation
import UIKit
import SnapKit

// MARK: - 聊天用户列表 Cell（重构版）

/// 聊天用户列表单元格（重构版）
/// 核心作用：展示有聊天记录的用户信息，包含渐变光圈头像、昵称、消息预览和时间戳
/// 设计思路：
///   - 外层阴影容器 + 内部卡片（#1C1C35，圆角 16pt，clipsToBounds）
///   - 头像带三色渐变光圈（紫→蓝→粉），3pt 边框宽度
///   - 自己发送的消息预览自动加紫色 "You:" 前缀（富文本）
///   - 右侧时间 + 细箭头图标提示可点击
class ChatUserCell_Lens: UITableViewCell {

    // MARK: - 静态标识

    static let reuseId_Lens = "ChatUserCell_Lens"

    // MARK: - UI 组件：卡片骨架

    /// 外层阴影容器（不 clipsToBounds，承载外投影）
    private let shadowContainer_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.28
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    /// 卡片主体（clipsToBounds）
    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    // MARK: - UI 组件：头像区

    /// 渐变光圈容器（clipsToBounds + cornerRadius = 27）
    private let avatarRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 27
        v.clipsToBounds = true
        return v
    }()

    /// 用户头像
    private let avatarView_Lens = UserAvatarView_Lens()

    // MARK: - UI 组件：文字区

    /// 用户昵称
    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 1
        return l
    }()

    /// 最后一条消息预览（支持富文本 "You:" 前缀）
    private let lastMessageLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(white: 1, alpha: 0.5)
        l.numberOfLines = 1
        return l
    }()

    /// 名称 + 预览纵向堆叠
    private lazy var textStack_Lens: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameLabel_Lens, lastMessageLabel_Lens])
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()

    // MARK: - UI 组件：右侧区

    /// 消息时间（右对齐）
    private let timeLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(white: 1, alpha: 0.35)
        l.font = .systemFont(ofSize: 11)
        l.textAlignment = .right
        return l
    }()

    /// 进入指示箭头
    private let chevronView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg_Lens)
        iv.tintColor = UIColor(white: 1, alpha: 0.2)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新阴影路径（性能优化）
        shadowContainer_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer_Lens.bounds,
            cornerRadius: 16
        ).cgPath
        // 同步头像光圈渐变层尺寸
        if let ringLayer_Lens = avatarRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = avatarRingView_Lens.bounds
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(shadowContainer_Lens)
        shadowContainer_Lens.addSubview(cardView_Lens)
        cardView_Lens.addSubview(avatarRingView_Lens)
        avatarRingView_Lens.addSubview(avatarView_Lens)
        cardView_Lens.addSubview(textStack_Lens)
        cardView_Lens.addSubview(timeLabel_Lens)
        cardView_Lens.addSubview(chevronView_Lens)

        setupAvatarRingGradient_Lens()
        setupConstraints_Lens()
    }

    /// 构建头像三色渐变光圈（紫→蓝→粉）
    private func setupAvatarRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#C77DFF").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 27
        avatarRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    private func setupConstraints_Lens() {
        shadowContainer_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 头像光圈
        avatarRingView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(54)
        }
        // 头像（3pt 内边距形成光圈宽度）
        avatarView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
        }

        // 进入箭头
        chevronView_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        // 时间（箭头左侧）
        timeLabel_Lens.snp.makeConstraints {
            $0.trailing.equalTo(chevronView_Lens.snp.leading).offset(-6)
            $0.top.equalToSuperview().offset(19)
            $0.width.lessThanOrEqualTo(72)
        }
        timeLabel_Lens.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel_Lens.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 文字堆叠（头像右侧到时间左侧）
        textStack_Lens.snp.makeConstraints {
            $0.leading.equalTo(avatarRingView_Lens.snp.trailing).offset(12)
            $0.trailing.equalTo(timeLabel_Lens.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - 配置

    /// 配置 Cell 展示内容
    /// - Parameters:
    ///   - user_lens: 有聊天记录的用户信息
    ///   - lastMessage_lens: 该用户的最后一条消息，nil 时显示空
    func configure_Lens(user_lens: PrewUserModel_Lens, lastMessage_lens: MessageModel_Lens?) {
        if let userId_Lens = user_lens.userId_Lens {
            avatarView_Lens.configure_Lens(userId_Lens: userId_Lens)
        }
        nameLabel_Lens.text = user_lens.userName_Lens ?? "User"
        timeLabel_Lens.text = lastMessage_lens?.time_Lens ?? ""

        // 自己发送的消息加紫色 "You:" 前缀
        if let isMine_Lens = lastMessage_lens?.isMine_Lens, isMine_Lens,
           let content_Lens = lastMessage_lens?.content_Lens {
            let attrs_Lens = NSMutableAttributedString(
                string: "You:  ",
                attributes: [
                    .foregroundColor: UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.85),
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium)
                ]
            )
            attrs_Lens.append(NSAttributedString(
                string: content_Lens,
                attributes: [
                    .foregroundColor: UIColor(white: 1, alpha: 0.45),
                    .font: UIFont.systemFont(ofSize: 13)
                ]
            ))
            lastMessageLabel_Lens.attributedText = attrs_Lens
        } else {
            lastMessageLabel_Lens.attributedText = nil
            lastMessageLabel_Lens.text = lastMessage_lens?.content_Lens ?? ""
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel_Lens.text = nil
        lastMessageLabel_Lens.text = nil
        lastMessageLabel_Lens.attributedText = nil
        timeLabel_Lens.text = nil
    }
}

// MARK: - 推荐用户横向滚动项视图（重构版）

/// 推荐用户单个展示项（重构版）
/// 核心作用：展示用户圆形头像（带彩虹渐变光环）与昵称，点击跳转用户中心
/// 设计思路：
///   - 深色卡片背景（#161626，圆角 14pt）+ 外投影
///   - 彩虹七色渐变光环（64pt）+ 深色内圆背景（58pt）+ 头像
///   - 昵称（12pt medium）+ 底部 "View Profile" 小箭头标识
class RecommendedUserItemView_Lens: UIView {

    // MARK: - 属性

    /// 点击回调
    var onTap_Lens: (() -> Void)?

    /// 渐变光环层引用（layoutSubviews 更新 frame）
    private var gradientRingLayer_Lens: CAGradientLayer?

    // MARK: - UI 组件

    /// 卡片主体（带阴影，不 clipsToBounds）
    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.07).cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        return v
    }()

    /// 彩虹渐变光环外容器（clipsToBounds + 圆形）
    private let ringContainerView_Lens: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    /// 深色内背景（营造光环间距）
    private let innerBgView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        v.clipsToBounds = true
        return v
    }()

    /// 用户头像
    private let avatarView_Lens = UserAvatarView_Lens()

    /// 用户昵称
    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// "View Profile" 小箭头提示行
    private let profileHintView_Lens: UIView = {
        let v = UIView()
        return v
    }()

    private let profileHintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Profile"
        l.font = .systemFont(ofSize: 9, weight: .medium)
        l.textColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.8)
        l.textAlignment = .right
        return l
    }()

    private let profileHintIcon_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 7, weight: .semibold)
        iv.image = UIImage(systemName: "arrow.up.right", withConfiguration: cfg_Lens)
        iv.tintColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.8)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
        setupGesture_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        ringContainerView_Lens.layer.cornerRadius = ringContainerView_Lens.bounds.width / 2
        innerBgView_Lens.layer.cornerRadius = innerBgView_Lens.bounds.width / 2
        gradientRingLayer_Lens?.frame = ringContainerView_Lens.bounds
        // 同步阴影路径（性能优化）
        cardView_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: cardView_Lens.bounds,
            cornerRadius: 14
        ).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        addSubview(cardView_Lens)
        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 彩虹渐变光环
        let gradientLayer_Lens = CAGradientLayer()
        gradientLayer_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#FFB347").cgColor,
            UIColor(hexstring_Lens: "#FF6B6B").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        gradientLayer_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradientRingLayer_Lens = gradientLayer_Lens
        ringContainerView_Lens.layer.addSublayer(gradientLayer_Lens)

        // 光环 → 内背景 → 头像
        cardView_Lens.addSubview(ringContainerView_Lens)
        ringContainerView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
        }

        ringContainerView_Lens.addSubview(innerBgView_Lens)
        innerBgView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(58)
        }

        innerBgView_Lens.addSubview(avatarView_Lens)
        avatarView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }

        // 昵称
        cardView_Lens.addSubview(nameLabel_Lens)
        nameLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(ringContainerView_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(4)
        }

        // "Profile →" 提示行
        cardView_Lens.addSubview(profileHintView_Lens)
        profileHintView_Lens.addSubview(profileHintLabel_Lens)
        profileHintView_Lens.addSubview(profileHintIcon_Lens)
        profileHintView_Lens.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Lens.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
        }
        profileHintLabel_Lens.snp.makeConstraints {
            $0.leading.centerY.top.bottom.equalToSuperview()
        }
        profileHintIcon_Lens.snp.makeConstraints {
            $0.leading.equalTo(profileHintLabel_Lens.snp.trailing).offset(2)
            $0.centerY.trailing.equalToSuperview()
            $0.width.height.equalTo(9)
        }
    }

    private func setupGesture_Lens() {
        let tap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lens))
        addGestureRecognizer(tap_Lens)
        isUserInteractionEnabled = true
    }

    // MARK: - 公共方法

    /// 配置推荐用户数据
    /// - Parameter user_lens: 目标用户信息
    func configure_Lens(user_lens: PrewUserModel_Lens) {
        if let userId_Lens = user_lens.userId_Lens {
            avatarView_Lens.configure_Lens(userId_Lens: userId_Lens)
        }
        nameLabel_Lens.text = user_lens.userName_Lens ?? "User"
    }

    // MARK: - 事件处理

    @objc private func handleTap_Lens() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.transform = .identity }
        }
        onTap_Lens?()
    }
}

// MARK: - 消息列表页面（重构版）

/// 消息列表页面（重构版）
/// 核心作用：展示推荐用户横向区 + 聊天列表，无记录时显示空状态引导
/// 设计思路：
///   - 顶部固定导航栏：毛玻璃背景 + 彩虹光谱条 + 标题 + 动态副标题（会话数）
///   - 背景多层径向光晕渐变与发现页保持视觉一致
///   - 推荐区块和聊天区块各带渐变竖条标题装饰 + 中间梯度分隔线
///   - ChatUserCell 带渐变头像光圈 + 消息预览"You:"前缀 + 右箭头
/// 关键方法：
///   - loadData_Lens: 加载/刷新全部数据
///   - handleRecommendedUserTap_Lens: 点击推荐用户自动建立会话并跳转
class MessageList_Lens: UIViewController {

    // MARK: - 数据源

    /// 有聊天记录的用户列表
    private var chatUsers_Lens: [PrewUserModel_Lens] = []

    /// 推荐用户列表（最多展示 10 个）
    private var recommendedUsers_Lens: [PrewUserModel_Lens] = []

    // MARK: - UI 组件：背景装饰

    /// 多层径向光晕渐变背景（不响应触摸）
    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：导航栏

    /// 导航栏容器（固定在顶部，毛玻璃背景）
    private let navBarView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 毛玻璃背景层
    private let navBlurView_Lens: UIVisualEffectView = {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    }()

    /// 导航栏底部微渐变分隔线
    private let navBottomLine_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 彩虹光谱装饰条
    private let spectrumBarView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 页面大标题 "Messages"
    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Messages"
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 28)
        return l
    }()

    /// 副标题（动态展示会话数量）
    private let subtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Start a conversation"
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        l.font = .systemFont(ofSize: 13)
        return l
    }()

    // MARK: - UI 组件：推荐区块

    /// 推荐区块渐变竖条装饰
    private let recommendAccentBar_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 1.5
        return v
    }()

    /// 推荐区块标题
    private let recommendSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "People You May Know"
        l.textColor = UIColor(white: 1, alpha: 0.7)
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        return l
    }()

    /// 推荐用户横向滚动视图
    private let recommendScrollView_Lens: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    /// 推荐用户横向布局容器
    private let recommendStackView_Lens: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .top
        return sv
    }()

    // MARK: - UI 组件：区块分隔线

    /// 两个区块之间的梯度分隔线
    private let sectionDivider_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：聊天区块

    /// 聊天区块渐变竖条装饰
    private let chatsAccentBar_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 1.5
        return v
    }()

    /// 聊天区块标题
    private let chatsSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Chats"
        l.textColor = UIColor(white: 1, alpha: 0.7)
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        return l
    }()

    /// 聊天用户列表
    private lazy var tableView_Lens: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = 82
        tv.showsVerticalScrollIndicator = false
        tv.register(ChatUserCell_Lens.self, forCellReuseIdentifier: ChatUserCell_Lens.reuseId_Lens)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    /// 空状态引导视图（无聊天记录时显示）
    private let emptyStateView_Lens: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        setupUI_Lens()
        setupNotification_Lens()
        loadData_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步各渐变层尺寸
        spectrumBarView_Lens.layer.sublayers?.forEach { $0.frame = spectrumBarView_Lens.bounds }
        navBottomLine_Lens.layer.sublayers?.forEach { $0.frame = navBottomLine_Lens.bounds }
        recommendAccentBar_Lens.layer.sublayers?.forEach { $0.frame = recommendAccentBar_Lens.bounds }
        chatsAccentBar_Lens.layer.sublayers?.forEach { $0.frame = chatsAccentBar_Lens.bounds }
        sectionDivider_Lens.layer.sublayers?.forEach { $0.frame = sectionDivider_Lens.bounds }

        // 更新导航栏高度（依赖 safeAreaInsets）
        // 布局：彩虹条top(14) + 彩虹条高(4) + 间距(8) + 标题高(~33) + 间距(4) + 副标题高(~17) + 底部(8) = 88
        let navH_Lens = view.safeAreaInsets.top + 88
        navBarView_Lens.snp.updateConstraints { $0.height.equalTo(navH_Lens) }
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        // 背景光晕（最底层）
        view.addSubview(backgroundGlowView_Lens)
        setupBackgroundGlows_Lens()

        // 内容区组件（导航栏下方）
        view.addSubview(recommendAccentBar_Lens)
        view.addSubview(recommendSectionLabel_Lens)
        view.addSubview(recommendScrollView_Lens)
        recommendScrollView_Lens.addSubview(recommendStackView_Lens)
        view.addSubview(sectionDivider_Lens)
        view.addSubview(chatsAccentBar_Lens)
        view.addSubview(chatsSectionLabel_Lens)
        view.addSubview(tableView_Lens)
        view.addSubview(emptyStateView_Lens)

        // 导航栏（最顶层，覆盖背景）
        view.addSubview(navBarView_Lens)
        navBarView_Lens.addSubview(navBlurView_Lens)
        navBarView_Lens.addSubview(navBottomLine_Lens)
        navBarView_Lens.addSubview(spectrumBarView_Lens)
        navBarView_Lens.addSubview(titleLabel_Lens)
        navBarView_Lens.addSubview(subtitleLabel_Lens)

        setupSpectrumBar_Lens()
        setupNavBottomLine_Lens()
        setupAccentBars_Lens()
        setupSectionDivider_Lens()
        setupEmptyState_Lens()
        setupConstraints_Lens()
    }

    /// 构建背景多层径向光晕
    private func setupBackgroundGlows_Lens() {
        let purpleGlow_Lens = CAGradientLayer()
        purpleGlow_Lens.type = .radial
        purpleGlow_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.28).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purpleGlow_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purpleGlow_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purpleGlow_Lens.frame = CGRect(x: -80, y: -60, width: 300, height: 300)
        backgroundGlowView_Lens.layer.addSublayer(purpleGlow_Lens)

        let blueGlow_Lens = CAGradientLayer()
        blueGlow_Lens.type = .radial
        blueGlow_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.16).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blueGlow_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blueGlow_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let screenW_Lens = UIScreen.main.bounds.width
        blueGlow_Lens.frame = CGRect(x: screenW_Lens - 50, y: 40, width: 180, height: 180)
        backgroundGlowView_Lens.layer.addSublayer(blueGlow_Lens)
    }

    /// 构建彩虹光谱装饰条
    private func setupSpectrumBar_Lens() {
        let colors_Lens: [UIColor] = [
            UIColor(hexstring_Lens: "#FF6B6B"),
            UIColor(hexstring_Lens: "#FFB347"),
            UIColor(hexstring_Lens: "#FFD93D"),
            UIColor(hexstring_Lens: "#6BCB77"),
            UIColor(hexstring_Lens: "#4D96FF"),
            UIColor(hexstring_Lens: "#C77DFF")
        ]
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = colors_Lens.map { $0.cgColor }
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        gradient_Lens.cornerRadius = 2
        spectrumBarView_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 构建导航栏底部微渐变分隔线
    private func setupNavBottomLine_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0).cgColor,
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor,
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0).cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        navBottomLine_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 构建两个区块标题的渐变竖条（推荐=蓝色，聊天=紫色）
    private func setupAccentBars_Lens() {
        let makeGradient_Lens: (String, String) -> CAGradientLayer = { top, bottom in
            let g = CAGradientLayer()
            g.colors = [UIColor(hexstring_Lens: top).cgColor, UIColor(hexstring_Lens: bottom).cgColor]
            g.startPoint = CGPoint(x: 0.5, y: 0)
            g.endPoint = CGPoint(x: 0.5, y: 1)
            g.cornerRadius = 1.5
            return g
        }
        recommendAccentBar_Lens.layer.addSublayer(makeGradient_Lens("#4D96FF", "#7B2FF7"))
        chatsAccentBar_Lens.layer.addSublayer(makeGradient_Lens("#7B2FF7", "#C77DFF"))
    }

    /// 构建区块间水平渐变分隔线（两端淡入）
    private func setupSectionDivider_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0).cgColor,
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor,
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0).cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        sectionDivider_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 构建空状态引导 UI（图标 + 主标题 + 副标题）
    private func setupEmptyState_Lens() {
        let iconConfig_Lens = UIImage.SymbolConfiguration(pointSize: 46, weight: .light)
        let iconView_Lens = UIImageView(
            image: UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: iconConfig_Lens)
        )
        iconView_Lens.tintColor = UIColor(white: 1, alpha: 0.2)
        iconView_Lens.contentMode = .scaleAspectFit
        emptyStateView_Lens.addSubview(iconView_Lens)
        iconView_Lens.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }

        let mainTitleLabel_Lens = UILabel()
        mainTitleLabel_Lens.text = "No Messages Yet"
        mainTitleLabel_Lens.textColor = UIColor(white: 1, alpha: 0.5)
        mainTitleLabel_Lens.font = .boldSystemFont(ofSize: 17)
        mainTitleLabel_Lens.textAlignment = .center
        emptyStateView_Lens.addSubview(mainTitleLabel_Lens)
        mainTitleLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(iconView_Lens.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
        }

        let subTitleLabel_Lens = UILabel()
        subTitleLabel_Lens.text = "Tap someone above to start chatting"
        subTitleLabel_Lens.textColor = UIColor(white: 1, alpha: 0.3)
        subTitleLabel_Lens.font = .systemFont(ofSize: 13)
        subTitleLabel_Lens.textAlignment = .center
        subTitleLabel_Lens.numberOfLines = 0
        emptyStateView_Lens.addSubview(subTitleLabel_Lens)
        subTitleLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 约束

    private func setupConstraints_Lens() {
        // 背景光晕区域
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(260)
        }

        // 导航栏（初始高度，viewDidLayoutSubviews 更新）
        navBarView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
        navBlurView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        navBottomLine_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        // 彩虹条（贴安全区顶部 + 14pt）
        spectrumBarView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            $0.width.equalTo(36)
            $0.height.equalTo(4)
        }
        // 大标题
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(spectrumBarView_Lens.snp.bottom).offset(8)
        }
        // 副标题
        subtitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(4)
        }

        // 推荐区块（导航栏下方）
        recommendAccentBar_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(recommendSectionLabel_Lens)
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        recommendSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(navBarView_Lens.snp.bottom).offset(16)
            $0.leading.equalTo(recommendAccentBar_Lens.snp.trailing).offset(8)
        }
        recommendScrollView_Lens.snp.makeConstraints {
            $0.top.equalTo(recommendSectionLabel_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(130)
        }
        recommendStackView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        // 区块分隔线
        sectionDivider_Lens.snp.makeConstraints {
            $0.top.equalTo(recommendScrollView_Lens.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0.5)
        }

        // 聊天区块
        chatsAccentBar_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(chatsSectionLabel_Lens)
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        chatsSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(sectionDivider_Lens.snp.bottom).offset(14)
            $0.leading.equalTo(chatsAccentBar_Lens.snp.trailing).offset(8)
        }

        // 聊天列表（填满剩余空间）
        tableView_Lens.snp.makeConstraints {
            $0.top.equalTo(chatsSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        // 空状态（居中于列表区域）
        emptyStateView_Lens.snp.makeConstraints {
            $0.center.equalTo(tableView_Lens)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    // MARK: - 数据加载

    /// 加载并刷新页面全部数据
    private func loadData_Lens() {
        chatUsers_Lens = MessageViewModel_Lens.shared_Lens.getChatUsers_Lens()
        let allUsers_Lens = UserViewModel_Lens.shared_Lens.getUserFollowRanking_Lens()
        recommendedUsers_Lens = Array(allUsers_Lens.prefix(10))

        setupRecommendedUsers_Lens()
        tableView_Lens.reloadData()
        updateEmptyState_Lens()
        updateSubtitle_Lens()
    }

    /// 动态构建推荐用户横向滚动列表
    private func setupRecommendedUsers_Lens() {
        recommendStackView_Lens.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for user_Lens in recommendedUsers_Lens {
            let itemView_Lens = RecommendedUserItemView_Lens()
            itemView_Lens.configure_Lens(user_lens: user_Lens)
            itemView_Lens.snp.makeConstraints { $0.width.equalTo(82) }
            let capturedUser_Lens = user_Lens
            itemView_Lens.onTap_Lens = { [weak self] in
                self?.handleRecommendedUserTap_Lens(user_lens: capturedUser_Lens)
            }
            recommendStackView_Lens.addArrangedSubview(itemView_Lens)
        }
    }

    /// 根据聊天用户数量切换空状态与列表
    private func updateEmptyState_Lens() {
        let isEmpty_Lens = chatUsers_Lens.isEmpty
        emptyStateView_Lens.isHidden = !isEmpty_Lens
        tableView_Lens.isHidden = isEmpty_Lens
    }

    /// 更新副标题文字（反映当前会话数量）
    private func updateSubtitle_Lens() {
        let count_Lens = chatUsers_Lens.count
        subtitleLabel_Lens.text = count_Lens > 0
            ? "\(count_Lens) active conversation\(count_Lens > 1 ? "s" : "")"
            : "Start a conversation"
    }

    // MARK: - 通知注册

    private func setupNotification_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Lens),
            name: MessageViewModel_Lens.messageStateDidChangeNotification_Lens,
            object: nil
        )
    }

    // MARK: - 事件处理

    /// 点击推荐用户：跳转该用户的用户中心页面
    private func handleRecommendedUserTap_Lens(user_lens: PrewUserModel_Lens) {
        Navigation_Lens.toUserInfo_Lens(with: user_lens)
    }

    /// 响应消息状态变化通知，刷新列表
    @objc private func handleMessageStateChange_Lens() {
        loadData_Lens()
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageList_Lens: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatUsers_Lens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lens = tableView.dequeueReusableCell(
            withIdentifier: ChatUserCell_Lens.reuseId_Lens,
            for: indexPath
        ) as! ChatUserCell_Lens
        let user_Lens = chatUsers_Lens[indexPath.row]
        let lastMessage_Lens = user_Lens.userId_Lens.flatMap {
            MessageViewModel_Lens.shared_Lens.getLastMessageWithUser_Lens(userId_lens: $0)
        }
        cell_Lens.configure_Lens(user_lens: user_Lens, lastMessage_lens: lastMessage_Lens)
        return cell_Lens
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Navigation_Lens.toMessageUser_Lens(with: chatUsers_Lens[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        82
    }
}
