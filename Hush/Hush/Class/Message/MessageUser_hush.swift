import UIKit
import SnapKit

// MARK: - 消息气泡单元格

/// 聊天消息气泡单元格
/// 功能：我的消息右对齐（主渐变背景），对方消息左对齐（白色卡片背景）
/// 关键属性：isMine_Hush 决定气泡样式与对齐方向
class MessageBubbleCell_Hush: UITableViewCell {

    static let reuseId_Hush = "MessageBubbleCell_Hush"

    // MARK: - UI 组件

    private let bubbleView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private var bubbleGradient_Hush: CAGradientLayer?

    private let contentLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.numberOfLines = 0
        return lbl
    }()

    private let timeLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10)
        lbl.textColor = ColorConfig_Hush.textPlaceholder_Hush
        return lbl
    }()

    // 约束引用，用于切换左右对齐
    private var bubbleLeading_Hush: Constraint?
    private var bubbleTrailing_Hush: Constraint?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradient_Hush?.frame = bubbleView_Hush.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(bubbleView_Hush)
        bubbleView_Hush.addSubview(contentLabel_Hush)
        contentView.addSubview(timeLabel_Hush)

        bubbleView_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().inset(6)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            bubbleLeading_Hush = make.leading.equalToSuperview().offset(16).constraint
            bubbleTrailing_Hush = make.trailing.equalToSuperview().inset(16).constraint
        }
        bubbleLeading_Hush?.deactivate()

        contentLabel_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        timeLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(bubbleView_Hush.snp.bottom).offset(4)
            make.trailing.equalTo(bubbleView_Hush)
            make.bottom.equalToSuperview().inset(2)
        }

        // 添加渐变层（初始为我的消息样式）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
                       ColorConfig_Hush.primaryGradientEnd_Hush.cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint = CGPoint(x: 1, y: 0.5)
        bubbleView_Hush.layer.insertSublayer(grad, at: 0)
        bubbleGradient_Hush = grad
    }

    // MARK: - 数据配置

    /// 配置消息气泡内容
    /// - Parameters:
    ///   - message_hush: 消息数据模型
    ///   - isMine_hush: 是否是自己发送的消息（影响气泡样式和对齐方向）
    func configure_Hush(message_hush: MessageModel_Hush, isMine_hush: Bool) {
        contentLabel_Hush.text = message_hush.content_Hush ?? ""
        timeLabel_Hush.text = message_hush.time_Hush ?? ""

        if isMine_hush {
            // 我的消息：右对齐，主渐变背景，白色文字
            bubbleLeading_Hush?.deactivate()
            bubbleTrailing_Hush?.activate()
            bubbleGradient_Hush?.isHidden = false
            bubbleView_Hush.backgroundColor = .clear
            bubbleView_Hush.layer.borderWidth = 0
            contentLabel_Hush.textColor = .white
            timeLabel_Hush.textAlignment = .right
        } else {
            // 对方消息：左对齐，白色背景，深色文字，边框
            bubbleTrailing_Hush?.deactivate()
            bubbleLeading_Hush?.activate()
            bubbleGradient_Hush?.isHidden = true
            bubbleView_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
            bubbleView_Hush.layer.borderWidth = 1
            bubbleView_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
            contentLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
            timeLabel_Hush.textAlignment = .left
            timeLabel_Hush.snp.remakeConstraints { make in
                make.top.equalTo(bubbleView_Hush.snp.bottom).offset(4)
                make.leading.equalTo(bubbleView_Hush)
                make.bottom.equalToSuperview().inset(2)
            }
        }
    }
}

// MARK: - 导航栏用户信息卡片视图

/// 导航栏居中展示的用户信息卡片
/// 功能：在聊天页顶部居中展示聊天对象的头像、昵称、简介片段，可点击进入用户中心
/// 关键属性：onTapped_Hush（点击回调）
class UserNavCardView_Hush: UIView {

    // MARK: - 回调

    var onTapped_Hush: (() -> Void)?

    // MARK: - UI 组件

    private let containerView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v.layer.cornerRadius = 22
        v.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.12
        return v
    }()

    /// 头像渐变环
    private let avatarRingView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        return v
    }()
    private var navCardRingGradient_Hush: CAGradientLayer?

    private let avatarView_Hush: UserAvatarView_Hush = {
        let v = UserAvatarView_Hush()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private let nameLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        return lbl
    }()

    private let bioLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.textColor = ColorConfig_Hush.textSecondary_Hush
        return lbl
    }()

    private let chevronView_Hush: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        addSubview(containerView_Hush)
        containerView_Hush.addSubview(avatarRingView_Hush)
        avatarRingView_Hush.addSubview(avatarView_Hush)
        containerView_Hush.addSubview(nameLabel_Hush)
        containerView_Hush.addSubview(bioLabel_Hush)
        containerView_Hush.addSubview(chevronView_Hush)

        containerView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 渐变环
        let ringGrad_Hush = CAGradientLayer()
        ringGrad_Hush.colors = [ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
                                ColorConfig_Hush.primaryGradientEnd_Hush.cgColor]
        ringGrad_Hush.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Hush.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Hush.cornerRadius = 18
        avatarRingView_Hush.layer.insertSublayer(ringGrad_Hush, at: 0)
        navCardRingGradient_Hush = ringGrad_Hush

        avatarRingView_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        avatarView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        chevronView_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        nameLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Hush.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalTo(chevronView_Hush.snp.leading).inset(-4)
        }
        bioLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_Hush)
            make.top.equalTo(nameLabel_Hush.snp.bottom).offset(2)
            make.trailing.equalTo(nameLabel_Hush)
            make.bottom.equalToSuperview().inset(8)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        containerView_Hush.addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        navCardRingGradient_Hush?.frame = avatarRingView_Hush.bounds
    }

    // MARK: - 数据配置

    /// 配置卡片内容
    /// - Parameter user_hush: 聊天对象用户模型
    func configure_Hush(user_hush: PrewUserModel_Hush) {
        if let userId = user_hush.userId_Hush {
            avatarView_Hush.configure_Hush(userId_Hush: userId)
        }
        nameLabel_Hush.text = user_hush.userName_Hush ?? "User"
        let bio = user_hush.userIntroduce_Hush?.isEmpty == false
            ? user_hush.userIntroduce_Hush!
            : "Tap to view profile"
        // 截断简介显示
        bioLabel_Hush.text = bio.count > 20 ? String(bio.prefix(20)) + "..." : bio
    }

    // MARK: - 事件处理

    @objc private func handleTap_Hush() {
        containerView_Hush.animatePressDown_Hush {
            self.containerView_Hush.animatePressUp_Hush {
                self.onTapped_Hush?()
            }
        }
    }
}

// MARK: - 聊天界面视图控制器

/// 私信聊天界面
/// 功能：展示与指定用户的聊天记录，支持发送消息、视频通话占位、点击用户卡片进入用户中心
/// 设计：自定义顶部导航（用户卡片居中）+ UITableView 消息列表 + 底部输入栏
/// 关键属性：userModel_Hush（聊天对象）
/// 监听：MessageViewModel 状态通知实时刷新消息
class MessageUser_Hush: UIViewController {

    // MARK: - 外部属性

    var userModel_Hush: PrewUserModel_Hush?

    // MARK: - 私有属性

    private var messages_Hush: [MessageModel_Hush] = []

    /// 底部输入栏相对安全区的底部约束偏移（键盘弹起时更新）
    private var inputContainerBottomOffset_Hush: Constraint?

    // MARK: - UI 组件

    // 顶部导航栏
    private let navBarView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        return v
    }()

    private let backButton_Hush = BackButton_Hush()

    /// 导航栏居中用户信息卡片
    private let userNavCard_Hush = UserNavCardView_Hush()

    /// 右上角拉黑按钮
    private let blockButton_Hush: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        btn.tintColor = ColorConfig_Hush.textSecondary_Hush
        btn.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        btn.layer.cornerRadius = 18
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.layer.shadowOpacity = 1
        return btn
    }()

    /// 导航栏底部渐变分割线
    private let navDivider_Hush = UIView()
    private var navDividerGrad_Hush: CAGradientLayer?

    /// 消息列表
    private lazy var tableView_Hush: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.dataSource = self
        tv.delegate = self
        tv.register(MessageBubbleCell_Hush.self, forCellReuseIdentifier: MessageBubbleCell_Hush.reuseId_Hush)
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.keyboardDismissMode = .interactive
        return tv
    }()

    /// 底部输入栏容器
    private let inputContainerView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.backgroundSecondary_Hush
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 消息输入框
    private let messageTextField_Hush: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Hush.textPrimary_Hush
        tf.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.rightViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()

    /// 发送按钮（橙色实底圆形，避免渐变层遮盖图标）
    private let sendButton_Hush: UIButton = {
        let btn = UIButton()
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = false
        btn.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowOpacity = 0.35
        btn.layer.shadowRadius = 6
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        setupNotifications_Hush()
        updateMessages_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navDividerGrad_Hush?.frame = navDivider_Hush.bounds
        // 更新发送按钮阴影路径
        sendButton_Hush.layer.shadowPath = UIBezierPath(ovalIn: sendButton_Hush.bounds).cgPath
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏系统导航栏，避免与自定义导航栏双层叠加
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        // 离开时恢复系统导航栏
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush

        // 顶部导航栏
        view.addSubview(navBarView_Hush)
        navBarView_Hush.addSubview(backButton_Hush)
        navBarView_Hush.addSubview(userNavCard_Hush)
        navBarView_Hush.addSubview(blockButton_Hush)
        navBarView_Hush.addSubview(navDivider_Hush)

        navBarView_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        backButton_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        blockButton_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        userNavCard_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backButton_Hush.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(blockButton_Hush.snp.leading).inset(-8)
            make.height.equalTo(40)
        }
        navDivider_Hush.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        // 导航栏渐变分割线
        let navGrad = CAGradientLayer()
        navGrad.colors = [ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
                          ColorConfig_Hush.primaryGradientEnd_Hush.cgColor]
        navGrad.startPoint = CGPoint(x: 0, y: 0.5)
        navGrad.endPoint = CGPoint(x: 1, y: 0.5)
        navDivider_Hush.layer.addSublayer(navGrad)
        navDividerGrad_Hush = navGrad

        // 配置用户信息卡片
        if let user = userModel_Hush {
            userNavCard_Hush.configure_Hush(user_hush: user)
        }

        // 用户卡片点击：进入用户中心（fromChat: true）
        userNavCard_Hush.onTapped_Hush = { [weak self] in
            self?.navigateToUserInfo_hush()
        }

        // 返回与举报按钮
        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }
        blockButton_Hush.addTarget(self, action: #selector(handleBlockTapped_Hush), for: .touchUpInside)

        // 消息列表
        view.addSubview(tableView_Hush)

        // 底部输入栏（无视频通话按钮）
        view.addSubview(inputContainerView_Hush)
        inputContainerView_Hush.addSubview(messageTextField_Hush)
        inputContainerView_Hush.addSubview(sendButton_Hush)

        inputContainerView_Hush.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            inputContainerBottomOffset_Hush = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        sendButton_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        messageTextField_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton_Hush.snp.leading).inset(-8)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }

        tableView_Hush.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Hush.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView_Hush.snp.top)
        }

        sendButton_Hush.addTarget(self, action: #selector(handleSendMessage_Hush), for: .touchUpInside)
        messageTextField_Hush.delegate = self
    }

    // MARK: - 通知监听

    private func setupNotifications_Hush() {
        // 消息状态通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Hush),
            name: MessageViewModel_Hush.messageStateDidChangeNotification_Hush,
            object: nil
        )
        // 键盘弹出通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow_Hush(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide_Hush),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Hush() {
        updateMessages_Hush()
    }

    // MARK: - 键盘适配

    @objc private func handleKeyboardWillShow_Hush(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let safeAreaBottom = view.safeAreaInsets.bottom
        let keyboardHeight = keyboardFrame.height - safeAreaBottom

        UIView.animate(withDuration: duration) {
            self.inputContainerBottomOffset_Hush?.update(offset: -keyboardHeight)
            self.view.layoutIfNeeded()
        }
        scrollToBottom_Hush(animated: true)
    }

    @objc private func handleKeyboardWillHide_Hush() {
        UIView.animate(withDuration: 0.25) {
            self.inputContainerBottomOffset_Hush?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 数据更新

    private func updateMessages_Hush() {
        guard let userId = userModel_Hush?.userId_Hush else { return }
        messages_Hush = MessageViewModel_Hush.shared_Hush.getMessagesWithUser_Hush(userId_hush: userId)
        tableView_Hush.reloadData()
        scrollToBottom_Hush(animated: false)
    }

    /// 滚动到消息列表底部（最新消息）
    private func scrollToBottom_Hush(animated: Bool) {
        guard !messages_Hush.isEmpty else { return }
        let lastIndex = IndexPath(row: messages_Hush.count - 1, section: 0)
        tableView_Hush.scrollToRow(at: lastIndex, at: .bottom, animated: animated)
    }

    // MARK: - 事件处理

    /// 发送消息
    @objc private func handleSendMessage_Hush() {
        guard let text = messageTextField_Hush.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty,
              let userId = userModel_Hush?.userId_Hush else { return }

        messageTextField_Hush.text = ""
        sendButton_Hush.animatePressDown_Hush {
            self.sendButton_Hush.animatePressUp_Hush(completion_Hush: nil)
        }
        MessageViewModel_Hush.shared_Hush.sendMessage_Hush(
            message_hush: text,
            chatType_hush: .personal_hush,
            id_hush: userId
        )
    }

    /// 拉黑/举报用户
    @objc private func handleBlockTapped_Hush() {
        guard let user = userModel_Hush else { return }
        blockButton_Hush.animatePressDown_Hush {
            self.blockButton_Hush.animatePressUp_Hush(completion_Hush: nil)
        }
        ReportDeleteHelper_Hush.block_Hush(user_Hush: user, from: self) { [weak self] in
            guard let self = self else { return }
            Navigation_Hush.popToSafeStateAfterBlock_Hush(from: self)
        }
    }

    /// 点击用户卡片进入用户中心（fromChat: true）
    private func navigateToUserInfo_hush() {
        guard let user = userModel_Hush else { return }
        let userInfoVC = UserInfo_Hush()
        userInfoVC.userModel_Hush = user
        userInfoVC.fromChat_Hush = true
        // 设置取消关注回调：取消关注后删除消息记录并返回消息列表
        userInfoVC.onUnfollowInChatContext_Hush = { [weak self] in
            self?.handleUnfollowInChatContext_hush()
        }
        Navigation_Hush.push_Hush(to: userInfoVC, animated: true, from: self)
    }

    /// 从聊天进入用户中心后取消关注的处理
    /// 功能：删除与该用户的所有聊天记录，弹出导航栈至消息列表
    func handleUnfollowInChatContext_hush() {
        guard let userId = userModel_Hush?.userId_Hush else { return }

        // 删除与该用户的聊天记录
        MessageViewModel_Hush.shared_Hush.deleteUserMessages_Hush(userId_hush: userId)
        print("已删除用户 \(userId) 的聊天记录，即将返回消息列表")

        // 弹出导航栈至 MessageList（含当前 UserInfo 和 MessageUser）
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let nav = self.navigationController else { return }
            if let messageListVC = nav.viewControllers.first(where: { $0 is MessageList_Hush }) {
                nav.popToViewController(messageListVC, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: - UITableView 数据源与代理

extension MessageUser_Hush: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Hush.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell_Hush.reuseId_Hush,
            for: indexPath
        ) as! MessageBubbleCell_Hush
        let msg = messages_Hush[indexPath.row]
        let isMine = msg.isMine_Hush ?? true
        cell.configure_Hush(message_hush: msg, isMine_hush: isMine)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 点击消息行收起键盘
        view.endEditing(true)
    }
}

// MARK: - UITextField 代理

extension MessageUser_Hush: UITextFieldDelegate {

    /// 点击键盘 Return 键发送消息
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage_Hush()
        return true
    }
}
