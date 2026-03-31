import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面
/// 功能：展示推荐用户横向滚动卡片和存在聊天记录的用户列表
/// 设计：渐变顶栏 + 推荐用户卡片区域 + 最近聊天行列表
/// 关键属性：通过 NotificationCenter 响应消息/用户状态变更，自动刷新 UI
class MessageList_Sprig: UIViewController {

    // MARK: - 属性

    /// 推荐用户列表（本地所有用户）
    private var recommendUsers_Sprig: [PrewUserModel_Sprig] = []

    /// 有聊天记录的用户列表
    private var chatUsers_Sprig: [PrewUserModel_Sprig] = []

    // MARK: - UI组件

    /// 顶部渐变标题容器
    private let headerView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.layer.cornerRadius = 32
        view_Sprig.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view_Sprig.clipsToBounds = true
        return view_Sprig
    }()

    /// 渐变图层
    private var headerGradient_Sprig: CAGradientLayer?

    /// 页面主标题
    private let titleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Messages"
        label_Sprig.font = UIFont.systemFont(ofSize: 30, weight: .black)
        label_Sprig.textColor = .white
        return label_Sprig
    }()

    /// 副标题
    private let subtitleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Connect with your sparks ✨"
        label_Sprig.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Sprig.textColor = UIColor.white.withAlphaComponent(0.85)
        return label_Sprig
    }()

    /// 主滚动视图
    private let mainScrollView_Sprig: UIScrollView = {
        let sv_Sprig = UIScrollView()
        sv_Sprig.showsVerticalScrollIndicator = false
        sv_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        sv_Sprig.alwaysBounceVertical = true
        return sv_Sprig
    }()

    /// 滚动内容容器
    private let scrollContentView_Sprig = UIView()

    /// "People You May Know" 区块标题
    private let recommendSectionLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "People You May Know"
        label_Sprig.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        return label_Sprig
    }()

    /// 推荐用户横向滚动视图
    private let recommendScrollView_Sprig: UIScrollView = {
        let sv_Sprig = UIScrollView()
        sv_Sprig.showsHorizontalScrollIndicator = false
        sv_Sprig.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sv_Sprig.decelerationRate = .fast
        return sv_Sprig
    }()

    /// 推荐用户横向堆叠视图
    private let recommendStackView_Sprig: UIStackView = {
        let sv_Sprig = UIStackView()
        sv_Sprig.axis = .horizontal
        sv_Sprig.spacing = 14
        sv_Sprig.alignment = .fill
        return sv_Sprig
    }()

    /// "Recent Chats" 区块标题
    private let chatSectionLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Recent Chats"
        label_Sprig.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        return label_Sprig
    }()

    /// 空聊天状态容器
    private let emptyChatContainer_Sprig: UIView = UIView()

    /// 空状态图标
    private let emptyIconView_Sprig: UIImageView = {
        let iv_Sprig = UIImageView()
        iv_Sprig.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iv_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.4)
        iv_Sprig.contentMode = .scaleAspectFit
        return iv_Sprig
    }()

    /// 空状态提示文字
    private let emptyTipLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "No chats yet\nTap a friend above to start talking!"
        label_Sprig.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        label_Sprig.textAlignment = .center
        label_Sprig.numberOfLines = 2
        return label_Sprig
    }()

    /// 聊天用户列表垂直堆叠容器
    private let chatListStackView_Sprig: UIStackView = {
        let sv_Sprig = UIStackView()
        sv_Sprig.axis = .vertical
        sv_Sprig.spacing = 0
        return sv_Sprig
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAllData_Sprig()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Sprig()
        setupObservers_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步渐变图层尺寸
        headerGradient_Sprig?.frame = headerView_Sprig.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI构建

    /// 搭建整体页面 UI
    private func setupUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        setupHeaderView_Sprig()
        setupScrollContent_Sprig()
    }

    /// 搭建顶部渐变标题栏
    private func setupHeaderView_Sprig() {
        view.addSubview(headerView_Sprig)

        // 渐变图层
        let gradient_Sprig = CAGradientLayer()
        gradient_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        gradient_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradient_Sprig.endPoint = CGPoint(x: 1, y: 1)
        headerGradient_Sprig = gradient_Sprig
        headerView_Sprig.layer.insertSublayer(gradient_Sprig, at: 0)

        headerView_Sprig.addSubview(titleLabel_Sprig)
        headerView_Sprig.addSubview(subtitleLabel_Sprig)

        headerView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.left.right.equalToSuperview()
            make_Sprig.height.equalTo(150)
        }

        titleLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(24)
            make_Sprig.bottom.equalToSuperview().offset(-32)
        }

        subtitleLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(titleLabel_Sprig)
            make_Sprig.top.equalTo(titleLabel_Sprig.snp.bottom).offset(4)
        }
    }

    /// 搭建主滚动内容区域
    private func setupScrollContent_Sprig() {
        view.addSubview(mainScrollView_Sprig)
        mainScrollView_Sprig.addSubview(scrollContentView_Sprig)

        mainScrollView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(headerView_Sprig.snp.bottom)
            make_Sprig.left.right.bottom.equalToSuperview()
        }

        scrollContentView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.edges.equalToSuperview()
            make_Sprig.width.equalTo(mainScrollView_Sprig)
        }

        // 推荐用户区块
        scrollContentView_Sprig.addSubview(recommendSectionLabel_Sprig)
        scrollContentView_Sprig.addSubview(recommendScrollView_Sprig)
        recommendScrollView_Sprig.addSubview(recommendStackView_Sprig)

        recommendSectionLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(22)
            make_Sprig.left.equalToSuperview().offset(22)
        }

        recommendScrollView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(recommendSectionLabel_Sprig.snp.bottom).offset(14)
            make_Sprig.left.right.equalToSuperview()
            make_Sprig.height.equalTo(152)
        }

        recommendStackView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.edges.equalToSuperview()
            make_Sprig.height.equalTo(recommendScrollView_Sprig)
        }

        // 最近聊天区块标题
        scrollContentView_Sprig.addSubview(chatSectionLabel_Sprig)
        chatSectionLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(recommendScrollView_Sprig.snp.bottom).offset(26)
            make_Sprig.left.equalToSuperview().offset(22)
        }

        // 空状态视图
        scrollContentView_Sprig.addSubview(emptyChatContainer_Sprig)
        emptyChatContainer_Sprig.addSubview(emptyIconView_Sprig)
        emptyChatContainer_Sprig.addSubview(emptyTipLabel_Sprig)

        emptyChatContainer_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(chatSectionLabel_Sprig.snp.bottom).offset(20)
            make_Sprig.centerX.equalToSuperview()
        }

        emptyIconView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.centerX.equalToSuperview()
            make_Sprig.width.height.equalTo(50)
        }

        emptyTipLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(emptyIconView_Sprig.snp.bottom).offset(12)
            make_Sprig.centerX.equalToSuperview()
            make_Sprig.bottom.equalToSuperview()
        }

        // 聊天列表容器
        scrollContentView_Sprig.addSubview(chatListStackView_Sprig)
        chatListStackView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(chatSectionLabel_Sprig.snp.bottom).offset(8)
            make_Sprig.left.right.equalToSuperview()
            make_Sprig.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 数据刷新

    /// 注册通知观察者，响应消息/用户状态变更
    private func setupObservers_Sprig() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMessageStateChanged_Sprig),
            name: MessageViewModel_Sprig.messageStateDidChangeNotification_Sprig,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserStateChanged_Sprig),
            name: UserViewModel_Sprig.userStateDidChangeNotification_Sprig,
            object: nil
        )
    }

    /// 刷新全部数据
    private func reloadAllData_Sprig() {
        recommendUsers_Sprig = LocalData_Sprig.shared_Sprig.userList_Sprig
        chatUsers_Sprig = MessageViewModel_Sprig.shared_Sprig.getChatUsers_Sprig()
        refreshRecommendSection_Sprig()
        refreshChatSection_Sprig()
    }

    /// 刷新推荐用户区块
    private func refreshRecommendSection_Sprig() {
        recommendStackView_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for user_Sprig in recommendUsers_Sprig {
            let card_Sprig = buildRecommendCard_Sprig(user_Sprig: user_Sprig)
            recommendStackView_Sprig.addArrangedSubview(card_Sprig)
        }
    }

    /// 刷新最近聊天区块
    private func refreshChatSection_Sprig() {
        chatListStackView_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let isEmpty_Sprig = chatUsers_Sprig.isEmpty
        emptyChatContainer_Sprig.isHidden = !isEmpty_Sprig

        for user_Sprig in chatUsers_Sprig {
            let row_Sprig = buildChatRow_Sprig(user_Sprig: user_Sprig)
            chatListStackView_Sprig.addArrangedSubview(row_Sprig)
        }
    }

    // MARK: - 卡片/行构建

    /// 构建推荐用户卡片（头像 + 姓名，无简介和按钮，整卡可点击）
    /// - Parameter user_Sprig: 用户模型
    /// - Returns: 配置好的卡片视图
    private func buildRecommendCard_Sprig(user_Sprig: PrewUserModel_Sprig) -> UIView {
        let card_Sprig = UIView()
        card_Sprig.backgroundColor = .white
        card_Sprig.layer.cornerRadius = 22
        card_Sprig.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        card_Sprig.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_Sprig.layer.shadowRadius = 14
        card_Sprig.layer.shadowOpacity = 0.16
        card_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.width.equalTo(110)
        }

        // ── 全卡渐变背景（从主色渐变到偏紫蓝）──
        let bgGrad_Sprig = CAGradientLayer()
        bgGrad_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        bgGrad_Sprig.startPoint = CGPoint(x: 0, y: 0)
        bgGrad_Sprig.endPoint = CGPoint(x: 1, y: 1)
        bgGrad_Sprig.cornerRadius = 22
        card_Sprig.layer.insertSublayer(bgGrad_Sprig, at: 0)
        DispatchQueue.main.async { bgGrad_Sprig.frame = card_Sprig.bounds }

        // ── 右上角装饰圆（透明白色光晕）──
        let glowCircle_Sprig = UIView()
        glowCircle_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        glowCircle_Sprig.layer.cornerRadius = 36
        glowCircle_Sprig.isUserInteractionEnabled = false
        card_Sprig.addSubview(glowCircle_Sprig)
        glowCircle_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.width.height.equalTo(72)
            make_Sprig.right.equalToSuperview().offset(18)
            make_Sprig.top.equalToSuperview().offset(-18)
        }

        // ── 左下角小装饰圆 ──
        let smallCircle_Sprig = UIView()
        smallCircle_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        smallCircle_Sprig.layer.cornerRadius = 20
        smallCircle_Sprig.isUserInteractionEnabled = false
        card_Sprig.addSubview(smallCircle_Sprig)
        smallCircle_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.width.height.equalTo(40)
            make_Sprig.left.equalToSuperview().offset(-10)
            make_Sprig.bottom.equalToSuperview().offset(10)
        }

        // ── 头像外层渐变环（白色半透明环） ──
        let avatarRing_Sprig = UIView()
        avatarRing_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        avatarRing_Sprig.layer.cornerRadius = 34
        card_Sprig.addSubview(avatarRing_Sprig)
        avatarRing_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerX.equalToSuperview()
            make_Sprig.top.equalToSuperview().offset(18)
            make_Sprig.width.height.equalTo(68)
        }

        // ── 头像 ──
        let avatarView_Sprig = UserAvatarView_Sprig()
        avatarView_Sprig.layer.cornerRadius = 28
        avatarView_Sprig.clipsToBounds = true
        avatarView_Sprig.layer.borderWidth = 2.5
        avatarView_Sprig.layer.borderColor = UIColor.white.cgColor
        card_Sprig.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.center.equalTo(avatarRing_Sprig)
            make_Sprig.width.height.equalTo(56)
        }
        if let uid_Sprig = user_Sprig.userId_Sprig {
            avatarView_Sprig.configure_Sprig(userId_Sprig: uid_Sprig)
        }

        // ── 头像右下角花朵徽章 ──
        let badgeContainer_Sprig = UIView()
        badgeContainer_Sprig.backgroundColor = .white
        badgeContainer_Sprig.layer.cornerRadius = 10
        badgeContainer_Sprig.layer.shadowColor = UIColor.black.cgColor
        badgeContainer_Sprig.layer.shadowOpacity = 0.1
        badgeContainer_Sprig.layer.shadowRadius = 3
        badgeContainer_Sprig.layer.shadowOffset = CGSize(width: 0, height: 1)
        card_Sprig.addSubview(badgeContainer_Sprig)
        badgeContainer_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.width.height.equalTo(20)
            make_Sprig.right.equalTo(avatarView_Sprig.snp.right).offset(2)
            make_Sprig.bottom.equalTo(avatarView_Sprig.snp.bottom).offset(2)
        }

        let badgeIcon_Sprig = UILabel()
        badgeIcon_Sprig.text = "🌸"
        badgeIcon_Sprig.font = .systemFont(ofSize: 10)
        badgeIcon_Sprig.textAlignment = .center
        badgeContainer_Sprig.addSubview(badgeIcon_Sprig)
        badgeIcon_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.center.equalToSuperview()
        }

        // ── 昵称（白色加粗）──
        let nameLabel_Sprig = UILabel()
        nameLabel_Sprig.text = user_Sprig.userName_Sprig ?? "User"
        nameLabel_Sprig.font = .systemFont(ofSize: 13, weight: .bold)
        nameLabel_Sprig.textColor = .white
        nameLabel_Sprig.textAlignment = .center
        nameLabel_Sprig.numberOfLines = 1
        nameLabel_Sprig.lineBreakMode = .byTruncatingTail
        card_Sprig.addSubview(nameLabel_Sprig)
        nameLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(avatarRing_Sprig.snp.bottom).offset(10)
            make_Sprig.left.equalToSuperview().offset(8)
            make_Sprig.right.equalToSuperview().offset(-8)
            make_Sprig.bottom.equalToSuperview().offset(-16)
        }

        // ── 整张卡片可点击，导航到聊天页 ──
        let tap_Sprig = UITapGestureRecognizer()
        tap_Sprig.addTarget(self, action: #selector(handleCardAreaTap_Sprig(_:)))
        card_Sprig.isUserInteractionEnabled = true
        card_Sprig.addGestureRecognizer(tap_Sprig)
        card_Sprig.tag = user_Sprig.userId_Sprig ?? 0

        return card_Sprig
    }

    /// 构建聊天用户行
    /// - Parameter user_Sprig: 用户模型
    /// - Returns: 配置好的行视图
    private func buildChatRow_Sprig(user_Sprig: PrewUserModel_Sprig) -> UIView {
        let row_Sprig = UIView()
        row_Sprig.backgroundColor = .white

        // 分割线
        let divider_Sprig = UIView()
        divider_Sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig
        row_Sprig.addSubview(divider_Sprig)
        divider_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.bottom.right.equalToSuperview()
            make_Sprig.left.equalToSuperview().offset(82)
            make_Sprig.height.equalTo(0.5)
        }

        // 头像
        let avatarView_Sprig = UserAvatarView_Sprig()
        avatarView_Sprig.layer.cornerRadius = 27
        avatarView_Sprig.clipsToBounds = true
        row_Sprig.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.left.equalToSuperview().offset(16)
            make_Sprig.width.height.equalTo(54)
        }
        if let uid_Sprig = user_Sprig.userId_Sprig {
            avatarView_Sprig.configure_Sprig(userId_Sprig: uid_Sprig)
        }

        // 昵称
        let nameLabel_Sprig = UILabel()
        nameLabel_Sprig.text = user_Sprig.userName_Sprig ?? "User"
        nameLabel_Sprig.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        row_Sprig.addSubview(nameLabel_Sprig)

        // 最后一条消息预览
        let lastMsgText_Sprig: String
        if let uid_Sprig = user_Sprig.userId_Sprig,
           let lastMsg_Sprig = MessageViewModel_Sprig.shared_Sprig.getLastMessageWithUser_Sprig(userId_sprig: uid_Sprig) {
            lastMsgText_Sprig = lastMsg_Sprig.content_Sprig ?? "..."
        } else {
            lastMsgText_Sprig = "Tap to start chatting"
        }

        let previewLabel_Sprig = UILabel()
        previewLabel_Sprig.text = lastMsgText_Sprig
        previewLabel_Sprig.font = UIFont.systemFont(ofSize: 13)
        previewLabel_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        previewLabel_Sprig.numberOfLines = 1
        row_Sprig.addSubview(previewLabel_Sprig)

        // 消息气泡指示点（有消息则显示渐变点）
        let dotView_Sprig = UIView()
        dotView_Sprig.layer.cornerRadius = 5
        dotView_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        dotView_Sprig.isHidden = true
        row_Sprig.addSubview(dotView_Sprig)

        // 箭头图标
        let arrowIcon_Sprig = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowIcon_Sprig.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        arrowIcon_Sprig.contentMode = .scaleAspectFit
        row_Sprig.addSubview(arrowIcon_Sprig)
        arrowIcon_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.right.equalToSuperview().offset(-16)
            make_Sprig.width.height.equalTo(16)
        }

        nameLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(avatarView_Sprig.snp.right).offset(14)
            make_Sprig.top.equalToSuperview().offset(17)
            make_Sprig.right.equalTo(arrowIcon_Sprig.snp.left).offset(-10)
        }

        previewLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(nameLabel_Sprig)
            make_Sprig.top.equalTo(nameLabel_Sprig.snp.bottom).offset(4)
            make_Sprig.right.equalTo(arrowIcon_Sprig.snp.left).offset(-10)
            make_Sprig.bottom.equalToSuperview().offset(-17)
        }

        dotView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerY.equalTo(nameLabel_Sprig)
            make_Sprig.right.equalTo(arrowIcon_Sprig.snp.left).offset(-8)
            make_Sprig.width.height.equalTo(10)
        }

        // 点击整行进入聊天
        row_Sprig.isUserInteractionEnabled = true
        row_Sprig.tag = user_Sprig.userId_Sprig ?? 0
        let tap_Sprig = UITapGestureRecognizer()
        tap_Sprig.addTarget(self, action: #selector(handleRowTap_Sprig(_:)))
        row_Sprig.addGestureRecognizer(tap_Sprig)

        return row_Sprig
    }

    // MARK: - 事件处理

    /// 消息状态变更通知回调
    @objc private func onMessageStateChanged_Sprig() {
        reloadAllData_Sprig()
    }

    /// 用户状态变更通知回调
    @objc private func onUserStateChanged_Sprig() {
        reloadAllData_Sprig()
    }

    /// 推荐卡片整体点击 - 跳转用户中心页
    @objc private func handleCardAreaTap_Sprig(_ gesture_Sprig: UITapGestureRecognizer) {
        guard let uid_Sprig = gesture_Sprig.view?.tag,
              let user_Sprig = LocalData_Sprig.shared_Sprig.userList_Sprig.first(where: { $0.userId_Sprig == uid_Sprig }) else { return }
        // 推荐用户卡片点击后进入该用户的用户中心页
        Navigation_Sprig.toUserInfo_Sprig(with: user_Sprig)
    }

    /// 聊天行点击 - 跳转聊天页
    @objc private func handleRowTap_Sprig(_ gesture_Sprig: UITapGestureRecognizer) {
        guard let uid_Sprig = gesture_Sprig.view?.tag,
              let user_Sprig = LocalData_Sprig.shared_Sprig.userList_Sprig.first(where: { $0.userId_Sprig == uid_Sprig }) else { return }
        Navigation_Sprig.toMessageUser_Sprig(with: user_Sprig)
    }
}

