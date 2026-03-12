import Foundation
import UIKit
import SnapKit

// MARK: 消息列表

/// 消息列表页面
/// 设计风格：浅色清新主题 + 深色渐变英雄 Header + 推荐用户横向滑动区 + 聊天记录列表
/// 布局层次：Header → ScrollView（推荐用户区 → 聊天记录区）
/// 响应式：通过 NotificationCenter 监听 MessageViewModel/UserViewModel 变化自动刷新
class MessageList_Doze: UIViewController {

    // MARK: - 状态

    /// 当前展示的推荐用户（排除已有聊天记录的用户）
    private var suggestedUsers_Doze: [PrewUserModel_Doze] = []

    /// 当前有聊天记录的用户列表
    private var chatUsers_Doze: [PrewUserModel_Doze] = []

    // MARK: - Header 区域

    private let headerBgView_Doze: UIView = {
        let v = UIView()
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        return v
    }()

    private let headerGradientLayer_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#2D1B69").cgColor,
            UIColor(hexstring_Doze: "#1A3A6E").cgColor,
            UIColor(hexstring_Doze: "#0E2A5A").cgColor
        ]
        gl.locations = [0, 0.55, 1.0]
        gl.startPoint = CGPoint(x: 0.1, y: 0)
        gl.endPoint = CGPoint(x: 0.9, y: 1)
        return gl
    }()

    /// Header 右上装饰氛围圆
    private let headerDeco1_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.18)
        v.layer.cornerRadius = 60
        v.isUserInteractionEnabled = false
        return v
    }()

    /// Header 左下装饰氛围圆
    private let headerDeco2_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#90CDF4").withAlphaComponent(0.14)
        v.layer.cornerRadius = 40
        v.isUserInteractionEnabled = false
        return v
    }()

    /// Header 右侧月亮装饰图标
    private let headerMoonIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight)
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.10)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    private let pageTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Messages"
        lbl.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        lbl.textColor = .white
        return lbl
    }()

    private let pageSubtitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Connect with pet lovers"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.65)
        return lbl
    }()

    /// 未读消息角标（动态显示）
    private let unreadBadge_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#FF6B9D")
        v.layer.cornerRadius = 10
        v.isHidden = true
        return v
    }()

    private let unreadCountLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 主滚动区

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let scrollContent_Doze = UIView()

    // MARK: - 推荐用户区（响应式横向滑动包裹）

    private let suggestedSectionView_Doze = UIView()

    private let suggestedTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Suggested"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    private let suggestedCountLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        return lbl
    }()

    private let suggestedScrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sv.backgroundColor = .clear
        return sv
    }()

    private let suggestedStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.alignment = .center
        return sv
    }()

    // MARK: - 聊天记录区

    private let chatsSectionView_Doze = UIView()

    private let chatsTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Chats"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    private let chatsCountLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        return lbl
    }()

    /// 聊天记录列表容器（响应式纵向堆叠）
    private let chatsListStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .fill
        return sv
    }()

    /// 无聊天记录空状态视图
    private let chatsEmptyView_Doze: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Doze.backgroundPrimary_Doze
        setupHeader_Doze()
        setupScrollView_Doze()
        setupSuggestedSection_Doze()
        setupChatsSection_Doze()
        loadData_Doze()
        observeNotifications_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Doze()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Doze.frame = headerBgView_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Header 搭建

    private func setupHeader_Doze() {
        view.addSubview(headerBgView_Doze)
        headerBgView_Doze.layer.addSublayer(headerGradientLayer_Doze)
        headerBgView_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(165)
        }

        // 装饰圆1（右上）
        headerBgView_Doze.addSubview(headerDeco1_Doze)
        headerDeco1_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(120)
        }

        // 装饰圆2（左下）
        headerBgView_Doze.addSubview(headerDeco2_Doze)
        headerDeco2_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
        }

        // 右侧装饰图标
        headerBgView_Doze.addSubview(headerMoonIcon_Doze)
        headerMoonIcon_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview().offset(8)
            make.width.height.equalTo(70)
        }

        // 主标题
        headerBgView_Doze.addSubview(pageTitleLabel_Doze)
        pageTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(62)
        }

        // 副标题
        headerBgView_Doze.addSubview(pageSubtitleLabel_Doze)
        pageSubtitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(pageTitleLabel_Doze.snp.bottom).offset(5)
        }

        // 未读消息数角标（副标题旁）
        headerBgView_Doze.addSubview(unreadBadge_Doze)
        unreadBadge_Doze.addSubview(unreadCountLabel_Doze)
        unreadBadge_Doze.snp.makeConstraints { make in
            make.left.equalTo(pageSubtitleLabel_Doze.snp.right).offset(8)
            make.centerY.equalTo(pageSubtitleLabel_Doze)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(20)
        }
        unreadCountLabel_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(6)
        }
    }

    // MARK: - ScrollView 搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(headerBgView_Doze.snp.bottom).offset(-10)
            make.left.right.bottom.equalToSuperview()
        }

        scrollView_Doze.addSubview(scrollContent_Doze)
        scrollContent_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - 推荐用户区搭建

    private func setupSuggestedSection_Doze() {
        scrollContent_Doze.addSubview(suggestedSectionView_Doze)
        suggestedSectionView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.right.equalToSuperview()
        }

        // 区块标题行
        let barGl = makeAccentBar_Doze()
        suggestedSectionView_Doze.addSubview(barGl)
        barGl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
        }

        suggestedSectionView_Doze.addSubview(suggestedTitleLabel_Doze)
        suggestedTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(barGl.snp.right).offset(10)
            make.centerY.equalTo(barGl)
        }

        suggestedSectionView_Doze.addSubview(suggestedCountLabel_Doze)
        suggestedCountLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(suggestedTitleLabel_Doze.snp.right).offset(8)
            make.centerY.equalTo(suggestedTitleLabel_Doze)
        }

        // 横向滑动容器
        suggestedSectionView_Doze.addSubview(suggestedScrollView_Doze)
        suggestedScrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(barGl.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalToSuperview()
        }

        suggestedScrollView_Doze.addSubview(suggestedStack_Doze)
        suggestedStack_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    // MARK: - 聊天记录区搭建

    private func setupChatsSection_Doze() {
        scrollContent_Doze.addSubview(chatsSectionView_Doze)
        chatsSectionView_Doze.snp.makeConstraints { make in
            make.top.equalTo(suggestedSectionView_Doze.snp.bottom).offset(28)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }

        // 区块标题行
        let barGl = makeAccentBar_Doze()
        chatsSectionView_Doze.addSubview(barGl)
        barGl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
        }

        chatsSectionView_Doze.addSubview(chatsTitleLabel_Doze)
        chatsTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(barGl.snp.right).offset(10)
            make.centerY.equalTo(barGl)
        }

        chatsSectionView_Doze.addSubview(chatsCountLabel_Doze)
        chatsCountLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(chatsTitleLabel_Doze.snp.right).offset(8)
            make.centerY.equalTo(chatsTitleLabel_Doze)
        }

        // 聊天记录列表
        chatsSectionView_Doze.addSubview(chatsListStack_Doze)
        chatsListStack_Doze.snp.makeConstraints { make in
            make.top.equalTo(barGl.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 空状态视图
        chatsSectionView_Doze.addSubview(chatsEmptyView_Doze)
        chatsEmptyView_Doze.snp.makeConstraints { make in
            make.top.equalTo(barGl.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(140)
        }
        buildEmptyState_Doze()
    }

    // MARK: - 辅助：渐变竖条装饰
    /// 创建左侧渐变色竖条并返回 UIView
    private func makeAccentBar_Doze() -> UIView {
        let bar = UIView()
        bar.layer.cornerRadius = 2
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 0, y: 1)
        gl.cornerRadius = 2
        bar.layer.insertSublayer(gl, at: 0)
        DispatchQueue.main.async { gl.frame = bar.bounds }
        return bar
    }

    /// 构建空状态视图
    private func buildEmptyState_Doze() {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .thin)
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.textPlaceholder_Doze
        iv.contentMode = .scaleAspectFit
        chatsEmptyView_Doze.addSubview(iv)

        let lbl = UILabel()
        lbl.text = "No conversations yet"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.textAlignment = .center
        chatsEmptyView_Doze.addSubview(lbl)

        let sub = UILabel()
        sub.text = "Start chatting with pet lovers above!"
        sub.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        sub.textColor = ColorConfig_Doze.textPlaceholder_Doze
        sub.textAlignment = .center
        sub.numberOfLines = 2
        chatsEmptyView_Doze.addSubview(sub)

        iv.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }
        lbl.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        sub.snp.makeConstraints { make in
            make.top.equalTo(lbl.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    private func loadData_Doze() {
        refreshAll_Doze()
    }

    /// 全量刷新：推荐用户 + 聊天记录
    private func refreshAll_Doze() {
        let allUsers = LocalData_Doze.shared_Doze.userList_Doze
        chatUsers_Doze = MessageViewModel_Doze.shared_Doze.getChatUsers_Doze()
        let chatIds = Set(chatUsers_Doze.compactMap { $0.userId_Doze })
        let currentId = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze().userId_Doze ?? 0
        // 推荐用户：排除已有聊天记录的用户 + 排除自己
        suggestedUsers_Doze = allUsers.filter { u in
            guard let uid = u.userId_Doze else { return false }
            return !chatIds.contains(uid) && uid != currentId
        }

        rebuildSuggestedSection_Doze()
        rebuildChatsList_Doze()
    }

    // MARK: - 重建推荐用户区

    private func rebuildSuggestedSection_Doze() {
        suggestedStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        suggestedCountLabel_Doze.text = "\(suggestedUsers_Doze.count) people"

        for user in suggestedUsers_Doze {
            let card = makeSuggestedUserCard_Doze(user_doze: user)
            suggestedStack_Doze.addArrangedSubview(card)
        }

        // 无推荐用户时显示占位
        if suggestedUsers_Doze.isEmpty {
            let placeholder = UILabel()
            placeholder.text = "All users added!"
            placeholder.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            placeholder.textColor = ColorConfig_Doze.textPlaceholder_Doze
            suggestedStack_Doze.addArrangedSubview(placeholder)
        }
    }

    /// 构建推荐用户卡片（响应式包裹：宽度自适应内容）
    /// - Parameter user_doze: 用户模型
    /// - Returns: 带头像+名称+简介+消息按钮的卡片视图
    private func makeSuggestedUserCard_Doze(user_doze: PrewUserModel_Doze) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 1
        card.snp.makeConstraints { make in
            make.width.equalTo(100)
        }

        // 头像容器（圆形裁剪，确保头像为正圆）
        let avatarWrap = UIView()
        avatarWrap.layer.cornerRadius = 30
        avatarWrap.clipsToBounds = true
        card.addSubview(avatarWrap)
        avatarWrap.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        let avatarView = UserAvatarView_Doze()
        avatarView.configure_Doze(userId_Doze: user_doze.userId_Doze ?? 0)
        avatarWrap.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 在线状态指示点（放在 card 上，避免被 avatarWrap 裁剪）
        let onlineDot = UIView()
        onlineDot.backgroundColor = UIColor(hexstring_Doze: "#48BB78")
        onlineDot.layer.cornerRadius = 6
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor.white.cgColor
        card.addSubview(onlineDot)
        onlineDot.snp.makeConstraints { make in
            make.right.equalTo(avatarWrap.snp.right).offset(2)
            make.bottom.equalTo(avatarWrap.snp.bottom).offset(2)
            make.width.height.equalTo(12)
        }

        // 用户名
        let nameLbl = UILabel()
        nameLbl.text = user_doze.userName_Doze ?? "User"
        nameLbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLbl.textColor = ColorConfig_Doze.textPrimary_Doze
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 1
        nameLbl.lineBreakMode = .byTruncatingTail
        card.addSubview(nameLbl)
        nameLbl.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(6)
        }

        // "Chat" 渐变小按钮（wrapper 包裹，防止渐变遮挡文字）
        let chatBtnWrap = UIView()
        chatBtnWrap.layer.cornerRadius = 12
        chatBtnWrap.clipsToBounds = true
        let gl = CAGradientLayer()
        gl.colors = [ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
                     ColorConfig_Doze.primaryGradientEnd_Doze.cgColor]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        gl.cornerRadius = 12
        chatBtnWrap.layer.addSublayer(gl)
        let chatBtn = UIButton(type: .custom)
        chatBtn.setTitle("Chat", for: .normal)
        chatBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        chatBtn.setTitleColor(.white, for: .normal)
        chatBtn.backgroundColor = .clear
        chatBtn.tag = user_doze.userId_Doze ?? 0
        chatBtn.addTarget(self, action: #selector(suggestedUserTapped_Doze(_:)), for: .touchUpInside)
        chatBtnWrap.addSubview(chatBtn)
        chatBtn.snp.makeConstraints { make in make.edges.equalToSuperview() }
        card.addSubview(chatBtnWrap)
        chatBtnWrap.snp.makeConstraints { make in
            make.top.equalTo(nameLbl.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(26)
            make.bottom.equalToSuperview().offset(-14)
        }
        DispatchQueue.main.async { gl.frame = chatBtnWrap.bounds }

        // 整卡点击也跳转
        let tap = UITapGestureRecognizer(target: self, action: #selector(suggestedCardTapped_Doze(_:)))
        card.tag = user_doze.userId_Doze ?? 0
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true

        return card
    }

    // MARK: - 重建聊天记录区

    private func rebuildChatsList_Doze() {
        chatsListStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chatsCountLabel_Doze.text = "\(chatUsers_Doze.count) active"

        let hasChatHistory = !chatUsers_Doze.isEmpty
        chatsEmptyView_Doze.isHidden = hasChatHistory
        chatsListStack_Doze.isHidden = !hasChatHistory

        for user in chatUsers_Doze {
            let row = makeChatRow_Doze(user_doze: user)
            chatsListStack_Doze.addArrangedSubview(row)
        }
    }

    /// 构建聊天记录行
    /// - Parameter user_doze: 聊天用户
    /// - Returns: 完整聊天行视图
    private func makeChatRow_Doze(user_doze: PrewUserModel_Doze) -> UIView {
        let userId = user_doze.userId_Doze ?? 0
        let lastMsg = MessageViewModel_Doze.shared_Doze.getLastMessageWithUser_Doze(userId_doze: userId)

        let container = UIView()
        container.backgroundColor = .clear
        container.snp.makeConstraints { make in make.height.equalTo(76) }
        container.tag = userId
        let tap = UITapGestureRecognizer(target: self, action: #selector(chatRowTapped_Doze(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true

        // 内层白色卡片（带微阴影）
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = 1
        container.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(16)
        }

        // 头像
        let avatarView = UserAvatarView_Doze()
        avatarView.configure_Doze(userId_Doze: userId)
        avatarView.layer.cornerRadius = 24
        avatarView.clipsToBounds = true
        card.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }

        // 左侧渐变圆环（对话氛围）
        let ringLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 24, y: 24), radius: 25,
                                      startAngle: 0, endAngle: .pi * 2, clockwise: true)
        ringLayer.path = circlePath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.3).cgColor
        ringLayer.lineWidth = 1.5
        avatarView.layer.addSublayer(ringLayer)

        // 用户名
        let nameLbl = UILabel()
        nameLbl.text = user_doze.userName_Doze ?? "User"
        nameLbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLbl.textColor = ColorConfig_Doze.textPrimary_Doze
        card.addSubview(nameLbl)
        nameLbl.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(12)
            make.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-60)
        }

        // 最后一条消息摘要
        let previewLbl = UILabel()
        previewLbl.text = lastMsg?.content_Doze ?? "Say hello 👋"
        previewLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        previewLbl.textColor = lastMsg == nil
            ? ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.7)
            : ColorConfig_Doze.textSecondary_Doze
        previewLbl.numberOfLines = 1
        previewLbl.lineBreakMode = .byTruncatingTail
        card.addSubview(previewLbl)
        previewLbl.snp.makeConstraints { make in
            make.left.equalTo(nameLbl)
            make.top.equalTo(nameLbl.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-60)
        }

        // 时间标签
        let timeLbl = UILabel()
        timeLbl.text = lastMsg?.time_Doze ?? ""
        timeLbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        timeLbl.textColor = ColorConfig_Doze.textPlaceholder_Doze
        timeLbl.textAlignment = .right
        card.addSubview(timeLbl)
        timeLbl.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(15)
        }

        // 进入箭头
        let arrowIv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        arrowIv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        arrowIv.tintColor = ColorConfig_Doze.textPlaceholder_Doze
        card.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        return container
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        let views: [UIView] = [headerBgView_Doze, suggestedSectionView_Doze, chatsSectionView_Doze]
        views.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        for (i, v) in views.enumerated() {
            UIView.animate(withDuration: 0.46, delay: Double(i) * 0.08,
                           usingSpringWithDamping: 0.82, initialSpringVelocity: 0.3,
                           options: [.curveEaseOut]) {
                v.alpha = 1; v.transform = .identity
            }
        }
    }

    // MARK: - 事件处理

    /// 推荐用户卡片整体点击（跳转聊天）
    @objc private func suggestedCardTapped_Doze(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let user = suggestedUsers_Doze.first(where: { $0.userId_Doze == view.tag }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.toMessageUser_Doze(with: user)
    }

    /// 推荐用户 Chat 按钮点击
    @objc private func suggestedUserTapped_Doze(_ sender: UIButton) {
        guard let user = suggestedUsers_Doze.first(where: { $0.userId_Doze == sender.tag }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.toMessageUser_Doze(with: user)
    }

    /// 聊天记录行点击
    @objc private func chatRowTapped_Doze(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let user = chatUsers_Doze.first(where: { $0.userId_Doze == view.tag }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.toMessageUser_Doze(with: user)
    }

    // MARK: - 通知监听

    private func observeNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Doze),
            name: MessageViewModel_Doze.messageStateDidChangeNotification_Doze,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Doze),
            name: UserViewModel_Doze.userStateDidChangeNotification_Doze,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Doze() {
        refreshAll_Doze()
    }

    @objc private func handleUserStateChange_Doze() {
        refreshAll_Doze()
    }
}
