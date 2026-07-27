import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面视图控制器
/// 核心作用：展示与登录用户存在聊天记录的会话列表，并推荐可发起互动的用户
/// 设计思路：
///   - 顶部改为与发现页/发布页一致的紫粉渐变横幅，统一全 App 主要入口页面的强调色视觉基调
///   - 推荐用户区与聊天列表分别收纳进独立的白色圆角卡片容器，卡片头部使用彩色图标徽标区分分区，
///     丰富信息层次的同时避免内容"裸露"在浅紫背景上
///   - 推荐用户头像与聊天行头像均叠加按索引轮换的强调色描边，呼应发现页帖子卡片的色带轮换逻辑
///   - 聊天行展示对方最新消息预览（若为我方发送则加前缀区分）、时间与跳转箭头，
///     若最新消息来自对方则叠加强调色圆点提示，形成更接近真实聊天应用的信息密度
///   - 数据随 MessageViewModel_Orna / UserViewModel_Orna 状态变化响应式刷新
class MessageList_Orna: UIViewController {

    /// 强调色候选池（与发现页帖子卡片色带保持一致，串联全 App 统一又富有层次的色彩节奏）
    private static let accentColorPool_Orna: [String] = ["#7B61FF", "#FF6B9D", "#FF9A6C", "#5B8DEF", "#B794F6"]

    // MARK: - UI · 顶部渐变横幅

    private let heroCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        return v
    }()

    private var heroGradientLayer_Orna: CAGradientLayer?

    private let heroIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let heroTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Messages"
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let heroSubtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Catch up with your desk friends"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 推荐用户卡片

    private let recommendCardView_Orna = MessageList_Orna.makeCardContainer_Orna()

    private let recommendScrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let recommendStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        return sv
    }()

    // MARK: - UI · 聊天列表卡片

    /// 聊天列表分区头（图标徽标 + "Chats" 标题），持有为属性以便在约束搭建阶段被 chatListStack_Orna 引用
    private lazy var chatHeader_Orna: UIView = makeSectionHeader_Orna(
        icon_orna: "message.fill", text_orna: "Chats", accentColorHex_orna: "#FF6B9D"
    )

    private let chatListStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    private let emptyCardView_Orna = MessageList_Orna.makeCardContainer_Orna()

    private let emptyIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.badge.person.crop"))
        iv.tintColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "No conversations yet.\nFollow someone and say hi!"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradientLayer_Orna?.frame = heroCardView_Orna.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(heroCardView_Orna)
        heroCardView_Orna.addSubview(heroIconView_Orna)
        heroCardView_Orna.addSubview(heroTitleLabel_Orna)
        heroCardView_Orna.addSubview(heroSubtitleLabel_Orna)
        setupHeroGradient_Orna()

        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        // 推荐用户卡片
        contentView_Orna.addSubview(recommendCardView_Orna)
        let recommendHeader_orna = makeSectionHeader_Orna(
            icon_orna: "sparkles", text_orna: "Suggested Wanderers", accentColorHex_orna: "#7B61FF"
        )
        recommendCardView_Orna.addSubview(recommendHeader_orna)
        recommendCardView_Orna.addSubview(recommendScrollView_Orna)
        recommendScrollView_Orna.addSubview(recommendStack_Orna)
        recommendHeader_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        recommendScrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(recommendHeader_orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(92)
        }
        recommendStack_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.height.equalToSuperview()
        }

        // 聊天列表卡片头
        contentView_Orna.addSubview(chatHeader_Orna)
        contentView_Orna.addSubview(chatListStack_Orna)
        contentView_Orna.addSubview(emptyCardView_Orna)
        emptyCardView_Orna.addSubview(emptyIconView_Orna)
        emptyCardView_Orna.addSubview(emptyLabel_Orna)
        emptyIconView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        emptyLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(emptyIconView_Orna.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }

    /// 搭建横幅紫粉渐变，呼应发现页横幅与首页签到卡片的强调色
    private func setupHeroGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor,
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        heroCardView_Orna.layer.insertSublayer(layer_orna, at: 0)
        heroGradientLayer_Orna = layer_orna
    }

    /// 搭建卡片统一的白色圆角容器，呼应发布页三个输入卡片的视觉语言
    private static func makeCardContainer_Orna() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }

    /// 搭建卡片头部图标徽标 + 分区标题，用于区分推荐用户区与聊天列表区并丰富色彩层次
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - text_orna: 分区标题文本
    /// - accentColorHex_orna: 该分区的强调色（十六进制）
    private func makeSectionHeader_Orna(icon_orna: String, text_orna: String, accentColorHex_orna: String) -> UIView {
        let container_orna = UIView()
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)

        let badge_orna = UIView()
        badge_orna.backgroundColor = accentColor_orna.withAlphaComponent(0.15)
        badge_orna.layer.cornerRadius = 14

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = accentColor_orna
        iconView_orna.contentMode = .scaleAspectFit

        let label_orna = UILabel()
        label_orna.text = text_orna
        label_orna.font = .systemFont(ofSize: 14, weight: .bold)
        label_orna.textColor = UIColor(hexstring_Orna: "#2D2A3D")

        container_orna.addSubview(badge_orna)
        badge_orna.addSubview(iconView_orna)
        container_orna.addSubview(label_orna)

        badge_orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        label_orna.snp.makeConstraints {
            $0.leading.equalTo(badge_orna.snp.trailing).offset(8)
            $0.centerY.equalTo(badge_orna)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        return container_orna
    }

    private func setupConstraints_Orna() {
        heroCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(92)
        }
        heroIconView_Orna.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        heroTitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
        }
        heroSubtitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(heroTitleLabel_Orna)
            $0.top.equalTo(heroTitleLabel_Orna.snp.bottom).offset(6)
            $0.trailing.lessThanOrEqualTo(heroIconView_Orna.snp.leading).offset(-12)
        }

        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(heroCardView_Orna.snp.bottom).offset(18)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        recommendCardView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        chatHeader_Orna.snp.makeConstraints {
            $0.top.equalTo(recommendCardView_Orna.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        chatListStack_Orna.snp.makeConstraints {
            $0.top.equalTo(chatHeader_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            // 底部预留悬浮导航栏遮挡高度，确保内容可以完全滚动到导航栏上方，不被其遮盖
            $0.bottom.equalToSuperview().offset(-TabBar_Orna.floatingBarClearance_Orna)
        }
        emptyCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(chatHeader_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    // MARK: - 状态监听

    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: MessageViewModel_Orna.messageStateDidChangeNotification_Orna, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna, object: nil
        )
    }

    // MARK: - 数据刷新

    @objc private func refreshAll_Orna() {
        refreshRecommendations_Orna()
        refreshChatList_Orna()
    }

    /// 刷新推荐用户横向列表（排除当前登录用户），头像描边按索引轮换强调色以丰富色彩层次
    private func refreshRecommendations_Orna() {
        recommendStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let users_orna = UserViewModel_Orna.shared_Orna.getUserFollowRanking_Orna().filter {
            guard let uid_orna = $0.userId_Orna else { return true }
            return !UserViewModel_Orna.shared_Orna.isCurrentUser_Orna(userId_orna: uid_orna)
        }
        for (index_orna, user_orna) in users_orna.enumerated() {
            let accentColor_orna = Self.accentColorPool_Orna[index_orna % Self.accentColorPool_Orna.count]
            let item_orna = RecommendedUserView_Orna()
            item_orna.configure_Orna(user_orna: user_orna, accentColorHex_orna: accentColor_orna)
            item_orna.onTapped_Orna = {
                Navigation_Orna.toUserInfo_Orna(with: user_orna)
            }
            recommendStack_Orna.addArrangedSubview(item_orna)
        }
    }

    /// 刷新聊天会话列表：每条会话展示为独立卡片，头像描边按索引轮换强调色，
    /// 最新消息来自对方时叠加强调色圆点提示，营造更贴近真实聊天应用的信息密度
    private func refreshChatList_Orna() {
        chatListStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let chatUsers_orna = MessageViewModel_Orna.shared_Orna.getChatUsers_Orna()
        emptyCardView_Orna.isHidden = !chatUsers_orna.isEmpty
        chatListStack_Orna.isHidden = chatUsers_orna.isEmpty

        for (index_orna, user_orna) in chatUsers_orna.enumerated() {
            guard let userId_orna = user_orna.userId_Orna else { continue }
            let lastMessage_orna = MessageViewModel_Orna.shared_Orna.getLastMessageWithUser_Orna(userId_orna: userId_orna)
            let accentColor_orna = Self.accentColorPool_Orna[index_orna % Self.accentColorPool_Orna.count]
            let row_orna = ChatRowView_Orna()
            row_orna.configure_Orna(user_orna: user_orna, lastMessage_orna: lastMessage_orna, accentColorHex_orna: accentColor_orna)
            row_orna.onTapped_Orna = {
                Navigation_Orna.toMessageUser_Orna(with: user_orna)
            }
            chatListStack_Orna.addArrangedSubview(row_orna)
        }
    }
}

// MARK: - 推荐用户视图

/// 推荐用户小卡片视图（头像 + 昵称，纵向排列）
/// 头像描边使用外部传入的强调色，与聊天列表的色彩轮换逻辑保持统一
private class RecommendedUserView_Orna: UIView {

    /// 点击回调
    var onTapped_Orna: (() -> Void)?

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        v.layer.borderWidth = 2
        return v
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatarView_Orna)
        addSubview(nameLabel_Orna)
        avatarView_Orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.bottom).offset(6)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(70)
        }
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置推荐用户信息
    /// 参数：
    /// - user_orna: 推荐用户数据
    /// - accentColorHex_orna: 头像描边强调色（十六进制）
    func configure_Orna(user_orna: PrewUserModel_Orna, accentColorHex_orna: String) {
        if let userId_orna = user_orna.userId_Orna {
            avatarView_Orna.configure_Orna(userId_Orna: userId_orna)
        }
        nameLabel_Orna.text = user_orna.userName_Orna
        avatarView_Orna.layer.borderColor = UIColor(hexstring_Orna: accentColorHex_orna).withAlphaComponent(0.5).cgColor
    }

    @objc private func handleTap_Orna() {
        onTapped_Orna?()
    }
}

// MARK: - 聊天会话行视图

/// 聊天会话行视图（头像 + 昵称 + 最新消息预览 + 时间 + 跳转箭头）
/// 独立卡片样式呼应发布页输入卡片的视觉语言；最新消息来自对方时叠加强调色圆点提示
private class ChatRowView_Orna: UIView {

    /// 点击回调
    var onTapped_Orna: (() -> Void)?

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        v.layer.borderWidth = 2
        return v
    }()

    /// 最新消息来自对方时的提示圆点
    private let unreadDotView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 4
        v.isHidden = true
        return v
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let previewLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.numberOfLines = 1
        return l
    }()

    private let timeLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#B5AFCB")
        return l
    }()

    private let chevronView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(hexstring_Orna: "#B5AFCB")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8

        addSubview(avatarView_Orna)
        addSubview(nameLabel_Orna)
        addSubview(previewLabel_Orna)
        addSubview(unreadDotView_Orna)
        addSubview(timeLabel_Orna)
        addSubview(chevronView_Orna)

        avatarView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
        chevronView_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(11)
        }
        timeLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.top).offset(2)
            $0.trailing.equalTo(chevronView_Orna.snp.leading).offset(-8)
        }
        unreadDotView_Orna.snp.makeConstraints {
            $0.centerY.equalTo(timeLabel_Orna)
            $0.trailing.equalTo(timeLabel_Orna.snp.leading).offset(-6)
            $0.width.height.equalTo(8)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.top).offset(2)
            $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(unreadDotView_Orna.snp.leading).offset(-8)
        }
        previewLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel_Orna)
            $0.trailing.equalTo(chevronView_Orna.snp.leading).offset(-8)
        }

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置聊天行信息
    /// 参数：
    /// - user_orna: 会话对方用户数据
    /// - lastMessage_orna: 最新消息（可能为空）
    /// - accentColorHex_orna: 头像描边与提示圆点的强调色（十六进制）
    func configure_Orna(user_orna: PrewUserModel_Orna, lastMessage_orna: MessageModel_Orna?, accentColorHex_orna: String) {
        if let userId_orna = user_orna.userId_Orna {
            avatarView_Orna.configure_Orna(userId_Orna: userId_orna)
        }
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)
        avatarView_Orna.layer.borderColor = accentColor_orna.withAlphaComponent(0.5).cgColor
        unreadDotView_Orna.backgroundColor = accentColor_orna

        nameLabel_Orna.text = user_orna.userName_Orna
        if let lastMessage_orna {
            let isMine_orna = lastMessage_orna.isMine_Orna ?? false
            previewLabel_Orna.text = isMine_orna
                ? "You: \(lastMessage_orna.content_Orna ?? "")"
                : (lastMessage_orna.content_Orna ?? "Say hello 👋")
            // 最新消息来自对方时叠加强调色圆点，提示存在待查看的新回复
            unreadDotView_Orna.isHidden = isMine_orna
        } else {
            previewLabel_Orna.text = "Say hello 👋"
            unreadDotView_Orna.isHidden = true
        }
        timeLabel_Orna.text = lastMessage_orna?.time_Orna ?? ""
    }

    @objc private func handleTap_Orna() {
        onTapped_Orna?()
    }
}
