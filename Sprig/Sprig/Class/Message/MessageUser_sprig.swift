import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页面

/// 与用户聊天页面
/// 功能：展示与指定用户的对话记录，支持发送文字消息和发起视频通话
/// 设计：现代气泡式聊天界面，顶部居中显示聊天对象信息，右上角举报按钮
/// 关键属性：userModel_Sprig 由上一页传入，消息变更通过 NotificationCenter 响应
class MessageUser_Sprig: UIViewController {

    // MARK: - 外部属性

    /// 聊天目标用户（由导航器注入）
    var userModel_Sprig: PrewUserModel_Sprig?

    // MARK: - 私有属性

    /// 消息数据列表
    private var messages_Sprig: [MessageModel_Sprig] = []

    /// 键盘当前高度
    private var keyboardHeight_Sprig: CGFloat = 0

    // MARK: - UI组件 - 顶部导航栏

    /// 自定义导航栏容器（渐变背景）
    private let navBarView_Sprig: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    /// 导航栏渐变图层
    private let navGradientLayer_Sprig = CAGradientLayer()

    /// 导航栏居中标题（显示聊天对象姓名）
    private let navTitleLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 返回按钮
    private let backButton_Sprig = BackButton_Sprig()

    /// 更多操作按钮（右上角）
    private let reportButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        return btn
    }()

    // MARK: - UI组件 - 用户信息卡片

    /// 用户信息卡片（浮于消息区上方，渐变背景）
    private let userInfoCard_Sprig: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 0.2
        v.clipsToBounds = false
        return v
    }()

    /// 卡片渐变图层
    private let cardGradientLayer_Sprig = CAGradientLayer()

    /// 卡片头像
    private let cardAvatarView_Sprig: UserAvatarView_Sprig = {
        let av = UserAvatarView_Sprig()
        av.layer.cornerRadius = 30
        av.clipsToBounds = true
        av.layer.borderWidth = 3
        av.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        return av
    }()

    /// 卡片用户名
    private let cardNameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 卡片简介（单行截断）
    private let cardBioLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    /// 在线状态指示点
    private let cardStatusDot_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1)
        v.layer.cornerRadius = 5
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 在线状态文字
    private let cardStatusLabel_Sprig: UILabel = {
        let l = UILabel()
        l.text = "Active now"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        return l
    }()

    /// 卡片装饰圆（右上）
    private let cardDecorCircle_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 40
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI组件 - 消息列表

    /// 消息列表滚动视图
    private let messageScrollView_Sprig: UIScrollView = {
        let sv_Sprig = UIScrollView()
        sv_Sprig.showsVerticalScrollIndicator = false
        sv_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        sv_Sprig.alwaysBounceVertical = true
        return sv_Sprig
    }()

    /// 消息内容容器（垂直堆叠）
    private let messageContentView_Sprig = UIView()

    /// 消息气泡垂直堆叠视图
    private let messageBubbleStack_Sprig: UIStackView = {
        let sv_Sprig = UIStackView()
        sv_Sprig.axis = .vertical
        sv_Sprig.spacing = 10
        sv_Sprig.alignment = .fill
        return sv_Sprig
    }()

    // MARK: - UI组件 - 底部输入栏

    /// 底部输入栏容器
    private let inputBarView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = .white
        view_Sprig.layer.shadowColor = UIColor.black.cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: -2)
        view_Sprig.layer.shadowRadius = 6
        view_Sprig.layer.shadowOpacity = 0.07
        return view_Sprig
    }()

    /// 分割线
    private let inputDivider_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig
        return view_Sprig
    }()

    /// 消息输入框容器（圆角背景）
    private let inputContainer_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        view_Sprig.layer.cornerRadius = 22
        view_Sprig.layer.borderWidth = 1.5
        view_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        return view_Sprig
    }()

    /// 消息输入框
    private let messageInputField_Sprig: UITextField = {
        let tf_Sprig = UITextField()
        tf_Sprig.placeholder = "Say something..."
        tf_Sprig.font = UIFont.systemFont(ofSize: 15)
        tf_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        tf_Sprig.returnKeyType = .send
        tf_Sprig.backgroundColor = .clear
        return tf_Sprig
    }()

    /// 视频通话按钮
    private let videoCallButton_Sprig: UIButton = {
        let btn_Sprig = UIButton(type: .system)
        let config_Sprig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn_Sprig.setImage(UIImage(systemName: "video.fill", withConfiguration: config_Sprig), for: .normal)
        btn_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        btn_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.12)
        btn_Sprig.layer.cornerRadius = 22
        return btn_Sprig
    }()

    /// 发送按钮
    private let sendButton_Sprig: UIButton = {
        let btn_Sprig = UIButton(type: .system)
        let config_Sprig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn_Sprig.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config_Sprig), for: .normal)
        btn_Sprig.tintColor = .white
        btn_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        btn_Sprig.layer.cornerRadius = 22
        return btn_Sprig
    }()

    /// 输入栏底部约束（用于键盘弹出时上移）
    private var inputBarBottomConstraint_Sprig: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Sprig()
        setupUserInfo_Sprig()
        setupObservers_Sprig()
        loadMessages_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步渐变图层 frame
        navGradientLayer_Sprig.frame = navBarView_Sprig.bounds
        let cardBounds = CGRect(x: 0, y: 0,
                                width: userInfoCard_Sprig.bounds.width,
                                height: userInfoCard_Sprig.bounds.height)
        cardGradientLayer_Sprig.frame = cardBounds
        cardGradientLayer_Sprig.cornerRadius = 20
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageInputField_Sprig.resignFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI构建

    /// 搭建整体页面 UI
    private func setupUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        setupNavBar_Sprig()
        setupUserInfoCard_Sprig()
        setupMessageArea_Sprig()
        setupInputBar_Sprig()
    }

    /// 搭建顶部自定义导航栏（渐变背景，仅含标题与操作按钮）
    private func setupNavBar_Sprig() {
        view.addSubview(navBarView_Sprig)

        // 渐变背景
        navGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        navGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        navGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        navBarView_Sprig.layer.insertSublayer(navGradientLayer_Sprig, at: 0)

        navBarView_Sprig.addSubview(backButton_Sprig)
        navBarView_Sprig.addSubview(navTitleLabel_Sprig)
        navBarView_Sprig.addSubview(reportButton_Sprig)

        let safeTop_Sprig = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 44

        navBarView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.left.right.equalToSuperview()
            make_Sprig.height.equalTo(safeTop_Sprig + 52)
        }

        // 返回按钮（白色图标）
        backButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(16)
            make_Sprig.bottom.equalToSuperview().offset(-8)
            make_Sprig.width.height.equalTo(44)
        }
        backButton_Sprig.onTapped_Sprig = { [weak self] in
            Navigation_Sprig.pop_Sprig()
        }

        // 标题居中
        navTitleLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerX.equalToSuperview()
            make_Sprig.centerY.equalTo(backButton_Sprig)
            make_Sprig.left.greaterThanOrEqualTo(backButton_Sprig.snp.right).offset(8)
            make_Sprig.right.lessThanOrEqualTo(reportButton_Sprig.snp.left).offset(-8)
        }

        // 右侧操作按钮
        reportButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.right.equalToSuperview().offset(-16)
            make_Sprig.centerY.equalTo(backButton_Sprig)
            make_Sprig.width.height.equalTo(44)
        }
        reportButton_Sprig.addAction(UIAction { [weak self] _ in
            self?.handleReportTap_Sprig()
        }, for: .touchUpInside)
    }

    /// 搭建用户信息浮卡（导航栏下方，渐变背景卡片）
    private func setupUserInfoCard_Sprig() {
        view.addSubview(userInfoCard_Sprig)

        // 卡片渐变图层（稍深，与导航栏形成层次）
        cardGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        ]
        cardGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        cardGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        userInfoCard_Sprig.layer.insertSublayer(cardGradientLayer_Sprig, at: 0)

        // 装饰圆（右上角）
        userInfoCard_Sprig.addSubview(cardDecorCircle_Sprig)
        cardDecorCircle_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.width.height.equalTo(80)
            make_Sprig.right.equalToSuperview().offset(16)
            make_Sprig.top.equalToSuperview().offset(-16)
        }

        // 头像（左侧）
        userInfoCard_Sprig.addSubview(cardAvatarView_Sprig)
        cardAvatarView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(18)
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.width.height.equalTo(60)
        }

        // 右侧信息区
        userInfoCard_Sprig.addSubview(cardNameLabel_Sprig)
        userInfoCard_Sprig.addSubview(cardBioLabel_Sprig)

        // 状态行（点 + 文字）
        let statusRow_Sprig = UIView()
        userInfoCard_Sprig.addSubview(statusRow_Sprig)
        statusRow_Sprig.addSubview(cardStatusDot_Sprig)
        statusRow_Sprig.addSubview(cardStatusLabel_Sprig)

        cardStatusDot_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.centerY.equalToSuperview()
            make_Sprig.width.height.equalTo(10)
        }
        cardStatusLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(cardStatusDot_Sprig.snp.right).offset(6)
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.right.equalToSuperview()
            make_Sprig.top.bottom.equalToSuperview()
        }

        cardNameLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(cardAvatarView_Sprig.snp.right).offset(16)
            make_Sprig.right.equalToSuperview().offset(-20)
            make_Sprig.top.equalToSuperview().offset(18)
        }
        cardBioLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.right.equalTo(cardNameLabel_Sprig)
            make_Sprig.top.equalTo(cardNameLabel_Sprig.snp.bottom).offset(5)
        }
        statusRow_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(cardNameLabel_Sprig)
            make_Sprig.top.equalTo(cardBioLabel_Sprig.snp.bottom).offset(7)
            make_Sprig.height.equalTo(16)
            make_Sprig.bottom.equalToSuperview().offset(-18)
        }

        userInfoCard_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(navBarView_Sprig.snp.bottom).offset(12)
            make_Sprig.left.equalToSuperview().offset(16)
            make_Sprig.right.equalToSuperview().offset(-16)
        }
    }

    /// 搭建消息列表区域
    private func setupMessageArea_Sprig() {
        view.addSubview(messageScrollView_Sprig)
        messageScrollView_Sprig.addSubview(messageContentView_Sprig)
        messageContentView_Sprig.addSubview(messageBubbleStack_Sprig)

        messageScrollView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(userInfoCard_Sprig.snp.bottom).offset(8)
            make_Sprig.left.right.equalToSuperview()
        }

        messageContentView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.edges.equalToSuperview()
            make_Sprig.width.equalTo(messageScrollView_Sprig)
        }

        messageBubbleStack_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(16)
            make_Sprig.left.right.equalToSuperview()
            make_Sprig.bottom.equalToSuperview().offset(-16)
        }
    }

    /// 搭建底部输入栏
    private func setupInputBar_Sprig() {
        view.addSubview(inputBarView_Sprig)
        inputBarView_Sprig.addSubview(inputDivider_Sprig)
        inputBarView_Sprig.addSubview(inputContainer_Sprig)
        inputContainer_Sprig.addSubview(messageInputField_Sprig)
        inputBarView_Sprig.addSubview(videoCallButton_Sprig)
        inputBarView_Sprig.addSubview(sendButton_Sprig)

        inputBarView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.right.equalToSuperview()
            inputBarBottomConstraint_Sprig = make_Sprig.bottom.equalToSuperview().constraint
            make_Sprig.height.equalTo(90)
        }

        // 补全 messageScrollView 的底部约束
        messageScrollView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.bottom.equalTo(inputBarView_Sprig.snp.top)
        }

        inputDivider_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.left.right.equalToSuperview()
            make_Sprig.height.equalTo(0.5)
        }

        // 发送按钮（右侧）
        sendButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerY.equalToSuperview().offset(-5)
            make_Sprig.right.equalToSuperview().offset(-16)
            make_Sprig.width.height.equalTo(44)
        }
        sendButton_Sprig.addAction(UIAction { [weak self] _ in
            self?.handleSendMessage_Sprig()
        }, for: .touchUpInside)

        // 视频通话按钮（发送按钮左侧）
        videoCallButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerY.equalTo(sendButton_Sprig)
            make_Sprig.right.equalTo(sendButton_Sprig.snp.left).offset(-10)
            make_Sprig.width.height.equalTo(44)
        }
        videoCallButton_Sprig.addAction(UIAction { [weak self] _ in
            self?.handleVideoCallTap_Sprig()
        }, for: .touchUpInside)

        // 输入框容器
        inputContainer_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerY.equalTo(sendButton_Sprig)
            make_Sprig.left.equalToSuperview().offset(16)
            make_Sprig.right.equalTo(videoCallButton_Sprig.snp.left).offset(-10)
            make_Sprig.height.equalTo(44)
        }

        messageInputField_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(14)
            make_Sprig.right.equalToSuperview().offset(-14)
            make_Sprig.centerY.equalToSuperview()
        }
        messageInputField_Sprig.delegate = self
        messageInputField_Sprig.addLeftPadding_Sprig(2)
    }

    // MARK: - 数据设置

    /// 设置用户信息展示（填充导航栏标题与用户信息卡片）
    private func setupUserInfo_Sprig() {
        guard let user_Sprig = userModel_Sprig else { return }

        // 导航栏标题显示用户名
        navTitleLabel_Sprig.text = user_Sprig.userName_Sprig ?? "Chat"

        // 卡片内容
        cardNameLabel_Sprig.text = user_Sprig.userName_Sprig ?? "User"
        cardBioLabel_Sprig.text = user_Sprig.userIntroduce_Sprig ?? "🌸 Sprig flower keeper"

        if let uid_Sprig = user_Sprig.userId_Sprig {
            cardAvatarView_Sprig.configure_Sprig(userId_Sprig: uid_Sprig)
        }
    }

    /// 注册消息/用户状态通知和键盘通知
    private func setupObservers_Sprig() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMessageStateChanged_Sprig),
            name: MessageViewModel_Sprig.messageStateDidChangeNotification_Sprig,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Sprig(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Sprig(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // 点击背景收起键盘
        let tap_Sprig = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sprig))
        tap_Sprig.cancelsTouchesInView = false
        messageScrollView_Sprig.addGestureRecognizer(tap_Sprig)
    }

    /// 加载消息列表数据
    private func loadMessages_Sprig() {
        guard let uid_Sprig = userModel_Sprig?.userId_Sprig else { return }
        messages_Sprig = MessageViewModel_Sprig.shared_Sprig.getMessagesWithUser_Sprig(userId_sprig: uid_Sprig)
        rebuildMessageBubbles_Sprig()
        scrollToBottom_Sprig(animated: false)
    }

    /// 重新渲染所有消息气泡
    private func rebuildMessageBubbles_Sprig() {
        messageBubbleStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for msg_Sprig in messages_Sprig {
            let bubble_Sprig = buildMessageBubble_Sprig(message_Sprig: msg_Sprig)
            messageBubbleStack_Sprig.addArrangedSubview(bubble_Sprig)
        }
    }

    // MARK: - 气泡构建

    /// 构建单条消息气泡视图
    /// - Parameter message_Sprig: 消息模型
    /// - Returns: 配置好的气泡容器视图
    private func buildMessageBubble_Sprig(message_Sprig: MessageModel_Sprig) -> UIView {
        let isMine_Sprig = message_Sprig.isMine_Sprig ?? false
        let containerRow_Sprig = UIView()

        // 头像
        let avatarView_Sprig = UserAvatarView_Sprig()
        avatarView_Sprig.layer.cornerRadius = 18
        avatarView_Sprig.clipsToBounds = true
        containerRow_Sprig.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.bottom.equalToSuperview()
            make_Sprig.width.height.equalTo(36)
            if isMine_Sprig {
                make_Sprig.right.equalToSuperview().offset(-16)
            } else {
                make_Sprig.left.equalToSuperview().offset(16)
            }
        }

        // 加载头像
        if isMine_Sprig {
            let curUser_Sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()
            if let uid_Sprig = curUser_Sprig.userId_Sprig {
                avatarView_Sprig.configure_Sprig(userId_Sprig: uid_Sprig)
            }
        } else {
            if let uid_Sprig = userModel_Sprig?.userId_Sprig {
                avatarView_Sprig.configure_Sprig(userId_Sprig: uid_Sprig)
            }
        }

        // 气泡内容
        let bubbleContainer_Sprig = UIView()
        bubbleContainer_Sprig.layer.cornerRadius = 18
        bubbleContainer_Sprig.clipsToBounds = true

        if isMine_Sprig {
            // 自己的消息 - 渐变气泡
            let gradientLayer_Sprig = CAGradientLayer()
            gradientLayer_Sprig.colors = [
                ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
                ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
            ]
            gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
            bubbleContainer_Sprig.layer.insertSublayer(gradientLayer_Sprig, at: 0)

            // 布局后更新渐变尺寸
            DispatchQueue.main.async {
                gradientLayer_Sprig.frame = bubbleContainer_Sprig.bounds
            }
        } else {
            // 对方消息 - 白色气泡
            bubbleContainer_Sprig.backgroundColor = .white
            bubbleContainer_Sprig.layer.shadowColor = UIColor.black.cgColor
            bubbleContainer_Sprig.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleContainer_Sprig.layer.shadowRadius = 4
            bubbleContainer_Sprig.layer.shadowOpacity = 0.07
            bubbleContainer_Sprig.clipsToBounds = false
        }

        let messageTextLabel_Sprig = UILabel()
        messageTextLabel_Sprig.text = message_Sprig.content_Sprig ?? ""
        messageTextLabel_Sprig.font = UIFont.systemFont(ofSize: 15)
        messageTextLabel_Sprig.textColor = isMine_Sprig ? .white : ColorConfig_Sprig.textPrimary_Sprig
        messageTextLabel_Sprig.numberOfLines = 0
        messageTextLabel_Sprig.lineBreakMode = .byWordWrapping

        bubbleContainer_Sprig.addSubview(messageTextLabel_Sprig)
        containerRow_Sprig.addSubview(bubbleContainer_Sprig)

        messageTextLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(10)
            make_Sprig.bottom.equalToSuperview().offset(-10)
            make_Sprig.left.equalToSuperview().offset(14)
            make_Sprig.right.equalToSuperview().offset(-14)
        }

        let maxWidth_Sprig = APPSCREEN_Sprig.WIDTH_Sprig * 0.62

        bubbleContainer_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview()
            make_Sprig.bottom.equalTo(avatarView_Sprig)
            make_Sprig.width.lessThanOrEqualTo(maxWidth_Sprig)
            if isMine_Sprig {
                make_Sprig.right.equalTo(avatarView_Sprig.snp.left).offset(-10)
            } else {
                make_Sprig.left.equalTo(avatarView_Sprig.snp.right).offset(10)
            }
        }

        // 时间标签
        if let time_Sprig = message_Sprig.time_Sprig, !time_Sprig.isEmpty {
            let timeLabel_Sprig = UILabel()
            timeLabel_Sprig.text = time_Sprig
            timeLabel_Sprig.font = UIFont.systemFont(ofSize: 10)
            timeLabel_Sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
            containerRow_Sprig.addSubview(timeLabel_Sprig)
            timeLabel_Sprig.snp.makeConstraints { make_Sprig in
                make_Sprig.bottom.equalTo(bubbleContainer_Sprig.snp.top).offset(-3)
                if isMine_Sprig {
                    make_Sprig.right.equalTo(bubbleContainer_Sprig)
                } else {
                    make_Sprig.left.equalTo(bubbleContainer_Sprig)
                }
            }
        }

        return containerRow_Sprig
    }

    // MARK: - 消息发送

    /// 处理发送消息操作
    private func handleSendMessage_Sprig() {
        guard let text_Sprig = messageInputField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text_Sprig.isEmpty,
              let uid_Sprig = userModel_Sprig?.userId_Sprig else { return }

        // 发送按钮弹性动画
        sendButton_Sprig.animatePulse_Sprig()

        // 触觉反馈
        let generator_Sprig = UIImpactFeedbackGenerator(style: .light)
        generator_Sprig.impactOccurred()

        messageInputField_Sprig.text = ""
        MessageViewModel_Sprig.shared_Sprig.sendMessage_Sprig(
            message_sprig: text_Sprig,
            chatType_sprig: .personal_sprig,
            id_sprig: uid_Sprig
        )
    }

    /// 滚动到消息列表底部
    /// - Parameter animated: 是否使用动画
    private func scrollToBottom_Sprig(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let contentHeight_Sprig = self.messageScrollView_Sprig.contentSize.height
            let frameHeight_Sprig = self.messageScrollView_Sprig.frame.height
            if contentHeight_Sprig > frameHeight_Sprig {
                let offset_Sprig = CGPoint(x: 0, y: contentHeight_Sprig - frameHeight_Sprig)
                self.messageScrollView_Sprig.setContentOffset(offset_Sprig, animated: animated)
            }
        }
    }

    // MARK: - 事件处理

    /// 点击举报按钮
    private func handleReportTap_Sprig() {
        guard let user_Sprig = userModel_Sprig else { return }

        // 举报按钮动画
        reportButton_Sprig.animatePulse_Sprig()

        ReportDeleteHelper_Sprig.block_Sprig(user_Sprig: user_Sprig, from: self) { [weak self] in
            // 举报成功后返回上一页
            Navigation_Sprig.pop_Sprig()
        }
    }

    /// 视频通话按钮点击：进入 VideoChat_Sprig 视频通话界面
    /// 以 overFullScreen + crossDissolve 方式模态展示，挂断后自动 dismiss 回本页
    private func handleVideoCallTap_Sprig() {
        videoCallButton_Sprig.animatePulse_Sprig()
        let generator_Sprig = UIImpactFeedbackGenerator(style: .medium)
        generator_Sprig.impactOccurred()

        let videoVC_Sprig = VideoChat_Sprig()
        videoVC_Sprig.userModel_Sprig = userModel_Sprig
        videoVC_Sprig.modalPresentationStyle = .overFullScreen
        videoVC_Sprig.modalTransitionStyle   = .crossDissolve
        present(videoVC_Sprig, animated: true)
    }

    /// 消息状态变更通知回调
    @objc private func onMessageStateChanged_Sprig() {
        guard let uid_Sprig = userModel_Sprig?.userId_Sprig else { return }
        messages_Sprig = MessageViewModel_Sprig.shared_Sprig.getMessagesWithUser_Sprig(userId_sprig: uid_Sprig)
        rebuildMessageBubbles_Sprig()
        scrollToBottom_Sprig(animated: true)
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Sprig() {
        view.endEditing(true)
    }

    // MARK: - 键盘处理

    /// 键盘弹出 - 上移输入栏
    @objc private func keyboardWillShow_Sprig(_ notification_Sprig: Notification) {
        guard let userInfo_Sprig = notification_Sprig.userInfo,
              let keyboardFrame_Sprig = userInfo_Sprig[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Sprig = userInfo_Sprig[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        keyboardHeight_Sprig = keyboardFrame_Sprig.height
        inputBarBottomConstraint_Sprig?.update(offset: -keyboardHeight_Sprig)

        UIView.animate(withDuration: duration_Sprig) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.scrollToBottom_Sprig(animated: true)
        }
    }

    /// 键盘收起 - 恢复输入栏
    @objc private func keyboardWillHide_Sprig(_ notification_Sprig: Notification) {
        guard let duration_Sprig = notification_Sprig.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        keyboardHeight_Sprig = 0
        inputBarBottomConstraint_Sprig?.update(offset: 0)

        UIView.animate(withDuration: duration_Sprig) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Sprig: UITextFieldDelegate {

    /// 点击键盘 Return 键发送消息
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage_Sprig()
        return true
    }

    /// 输入框激活时更新边框颜色
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.inputContainer_Sprig.layer.borderColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        }
    }

    /// 输入框失活时恢复边框颜色
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.inputContainer_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        }
    }
}
