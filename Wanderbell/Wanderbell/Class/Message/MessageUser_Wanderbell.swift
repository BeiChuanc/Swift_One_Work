import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天

/// 与用户聊天页面
/// 核心功能：展示与指定用户的聊天记录，发送消息
/// 设计思路：现代化聊天界面，包含头像、消息气泡、输入框、视频通话按钮、举报按钮
/// 关键属性：
/// - userModel_Wanderbell: 聊天用户信息
/// - messagesList_Wanderbell: 消息列表
/// - messageInput_Wanderbell: 消息输入框
/// 关键方法：
/// - sendMessage_Wanderbell: 发送消息
/// - scrollToBottom_Wanderbell: 滚动到底部
class MessageUser_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    /// 聊天用户
    var userModel_Wanderbell: PrewUserModel_Wanderbell?
    
    /// 消息数据
    private var messages_Wanderbell: [MessageModel_Wanderbell] = []
    
    /// 当前用户头像
    private let currentUserAvatar_Wanderbell = "user_avatar"
    
    // MARK: - UI组件
    
    /// 表格视图
    private let tableView_Wanderbell: UITableView = {
        let tableView_wanderbell = UITableView()
        tableView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        tableView_wanderbell.separatorStyle = .none
        tableView_wanderbell.keyboardDismissMode = .interactive
        return tableView_wanderbell
    }()
    
    /// 输入框容器
    private let inputContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: -4)
        view_wanderbell.layer.shadowOpacity = 0.08
        view_wanderbell.layer.shadowRadius = 20
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.masksToBounds = true
        return view_wanderbell
    }()
    
    /// 输入框背景
    private let inputBackgroundView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        view_wanderbell.layer.cornerRadius = 24
        view_wanderbell.layer.borderWidth = 1.5
        view_wanderbell.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
        return view_wanderbell
    }()
    
    /// 消息输入框
    private let messageInputTextView_Wanderbell: UITextView = {
        let textView_wanderbell = UITextView()
        textView_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textView_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textView_wanderbell.backgroundColor = .clear
        textView_wanderbell.textContainerInset = UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4)
        textView_wanderbell.isScrollEnabled = false
        return textView_wanderbell
    }()
    
    /// 占位符标签
    private let placeholderLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Type a message..."
        label_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        return label_wanderbell
    }()
    
    /// 视频通话按钮
    private let videoCallButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.layer.cornerRadius = 26
        
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image_wanderbell = UIImage(systemName: "video.fill", withConfiguration: config_wanderbell)
        button_wanderbell.setImage(image_wanderbell, for: .normal)
        button_wanderbell.tintColor = .white
        
        return button_wanderbell
    }()
    
    /// 发送按钮
    private let sendButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.layer.cornerRadius = 26
        
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image_wanderbell = UIImage(systemName: "paperplane.fill", withConfiguration: config_wanderbell)
        button_wanderbell.setImage(image_wanderbell, for: .normal)
        button_wanderbell.tintColor = .white
        
        return button_wanderbell
    }()
    
    /// 空状态视图
    private let emptyStateView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .clear
        return view_wanderbell
    }()
    
    /// 输入框底部约束
    private var inputContainerBottomConstraint_Wanderbell: Constraint?
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupActions_Wanderbell()
        setupKeyboardObservers_Wanderbell()
        setupMessageObserver_Wanderbell()
        loadMessages_Wanderbell()
        updateButtonGradients_Wanderbell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateButtonGradients_Wanderbell()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        view.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        
        // 设置导航栏
        setupNavigationBar_Wanderbell()
        
        // 添加子视图
        view.addSubview(tableView_Wanderbell)
        view.addSubview(emptyStateView_Wanderbell)
        view.addSubview(inputContainerView_Wanderbell)
        
        // 输入框容器
        inputContainerView_Wanderbell.addSubview(inputBackgroundView_Wanderbell)
        inputBackgroundView_Wanderbell.addSubview(messageInputTextView_Wanderbell)
        inputBackgroundView_Wanderbell.addSubview(placeholderLabel_Wanderbell)
        inputContainerView_Wanderbell.addSubview(videoCallButton_Wanderbell)
        inputContainerView_Wanderbell.addSubview(sendButton_Wanderbell)
        
        // 设置空状态
        setupEmptyState_Wanderbell()
        
        // 设置表格
        tableView_Wanderbell.delegate = self
        tableView_Wanderbell.dataSource = self
        tableView_Wanderbell.register(MessageBubbleCell_Wanderbell.self, forCellReuseIdentifier: "MessageCell")
        
        setupConstraints_Wanderbell()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Wanderbell() {
        // 创建自定义标题视图（增加宽度以适应更长的用户名）
        let titleView_wanderbell = UIView()
        
        // 用户头像
        let avatarImageView_wanderbell = UIImageView()
        avatarImageView_wanderbell.contentMode = .scaleAspectFill
        avatarImageView_wanderbell.clipsToBounds = true
        avatarImageView_wanderbell.layer.cornerRadius = 18
        avatarImageView_wanderbell.layer.borderWidth = 2
        avatarImageView_wanderbell.layer.borderColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell.cgColor
        
        if let imageName_wanderbell = userModel_Wanderbell?.userHead_Wanderbell {
            avatarImageView_wanderbell.image = UIImage(named: imageName_wanderbell)
        }
        
        // 用户名标签
        let usernameLabel_wanderbell = UILabel()
        usernameLabel_wanderbell.text = userModel_Wanderbell?.userName_Wanderbell ?? "User"
        usernameLabel_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        usernameLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        usernameLabel_wanderbell.numberOfLines = 1
        usernameLabel_wanderbell.adjustsFontSizeToFitWidth = true
        usernameLabel_wanderbell.minimumScaleFactor = 0.8
        
        titleView_wanderbell.addSubview(avatarImageView_wanderbell)
        titleView_wanderbell.addSubview(usernameLabel_wanderbell)
        
        avatarImageView_wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        usernameLabel_wanderbell.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView_wanderbell.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.width.lessThanOrEqualTo(180)
        }
        
        // 设置titleView的整体尺寸
        titleView_wanderbell.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(250)
            make.height.equalTo(44)
        }
        
        navigationItem.titleView = titleView_wanderbell
        
        // 右侧举报按钮
        let reportButton_wanderbell = ReportDeleteHelper_Wanderbell.createUserReportButton_Wanderbell(
            size_wanderbell: 44,
            backgroundColor_wanderbell: ColorConfig_Wanderbell.backgroundPrimary_Wanderbell,
            tintColor_wanderbell: ColorConfig_Wanderbell.textPrimary_Wanderbell,
            withShadow_wanderbell: false
        )
        reportButton_wanderbell.addTarget(self, action: #selector(reportTapped_Wanderbell), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton_wanderbell)
        
        // 返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Wanderbell)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
    }
    
    /// 设置空状态
    private func setupEmptyState_Wanderbell() {
        // 图标容器
        let iconContainer_wanderbell = UIView()
        iconContainer_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.1)
        iconContainer_wanderbell.layer.cornerRadius = 60
        emptyStateView_Wanderbell.addSubview(iconContainer_wanderbell)
        
        // 聊天图标
        let iconImageView_wanderbell = UIImageView()
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        iconImageView_wanderbell.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: config_wanderbell)
        iconImageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        iconContainer_wanderbell.addSubview(iconImageView_wanderbell)
        
        // 标题
        let titleLabel_wanderbell = UILabel()
        titleLabel_wanderbell.text = "Start a conversation"
        titleLabel_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        titleLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        titleLabel_wanderbell.textAlignment = .center
        emptyStateView_Wanderbell.addSubview(titleLabel_wanderbell)
        
        // 副标题
        let subtitleLabel_wanderbell = UILabel()
        subtitleLabel_wanderbell.text = "Say hi to \(userModel_Wanderbell?.userName_Wanderbell ?? "user")"
        subtitleLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        subtitleLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        subtitleLabel_wanderbell.textAlignment = .center
        emptyStateView_Wanderbell.addSubview(subtitleLabel_wanderbell)
        
        // 快捷回复容器
        let quickRepliesStack_wanderbell = UIStackView()
        quickRepliesStack_wanderbell.axis = .horizontal
        quickRepliesStack_wanderbell.spacing = 10
        quickRepliesStack_wanderbell.distribution = .fillEqually
        emptyStateView_Wanderbell.addSubview(quickRepliesStack_wanderbell)
        
        let quickReplies_wanderbell = ["👋 Hi there!", "😊 How are you?", "💬 Let's chat"]
        for reply_wanderbell in quickReplies_wanderbell {
            let button_wanderbell = createQuickReplyButton_Wanderbell(text: reply_wanderbell)
            quickRepliesStack_wanderbell.addArrangedSubview(button_wanderbell)
        }
        
        // 约束
        iconContainer_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.width.height.equalTo(120)
        }
        
        iconImageView_wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        titleLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(iconContainer_wanderbell.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(40)
        }
        
        subtitleLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_wanderbell.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(40)
        }
        
        quickRepliesStack_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_wanderbell.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
    }
    
    /// 创建快捷回复按钮
    private func createQuickReplyButton_Wanderbell(text: String) -> UIButton {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setTitle(text, for: .normal)
        button_wanderbell.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button_wanderbell.setTitleColor(ColorConfig_Wanderbell.primaryGradientStart_Wanderbell, for: .normal)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.1)
        button_wanderbell.layer.cornerRadius = 18
        button_wanderbell.layer.borderWidth = 1.5
        button_wanderbell.layer.borderColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.3).cgColor
        button_wanderbell.addTarget(self, action: #selector(quickReplyTapped_Wanderbell(_:)), for: .touchUpInside)
        return button_wanderbell
    }
    
    /// 更新按钮渐变
    private func updateButtonGradients_Wanderbell() {
        // 视频通话按钮渐变
        videoCallButton_Wanderbell.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let videoGradient_wanderbell = CAGradientLayer()
        videoGradient_wanderbell.frame = videoCallButton_Wanderbell.bounds
        videoGradient_wanderbell.colors = [
            UIColor(hexstring_Wanderbell: "#00D97E").cgColor,
            UIColor(hexstring_Wanderbell: "#00B4A8").cgColor
        ]
        videoGradient_wanderbell.startPoint = CGPoint(x: 0, y: 0.5)
        videoGradient_wanderbell.endPoint = CGPoint(x: 1, y: 0.5)
        videoGradient_wanderbell.cornerRadius = 26
        videoCallButton_Wanderbell.layer.insertSublayer(videoGradient_wanderbell, at: 0)
        
        // 发送按钮渐变
        sendButton_Wanderbell.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let sendGradient_wanderbell = CAGradientLayer()
        sendGradient_wanderbell.frame = sendButton_Wanderbell.bounds
        sendGradient_wanderbell.colors = [
            ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor,
            ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.cgColor
        ]
        sendGradient_wanderbell.startPoint = CGPoint(x: 0, y: 0)
        sendGradient_wanderbell.endPoint = CGPoint(x: 1, y: 1)
        sendGradient_wanderbell.cornerRadius = 26
        sendButton_Wanderbell.layer.insertSublayer(sendGradient_wanderbell, at: 0)
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        // 表格视图
        tableView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(inputContainerView_Wanderbell.snp.top)
        }
        
        // 空状态视图
        emptyStateView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalTo(tableView_Wanderbell)
        }
        
        // 输入框容器
        inputContainerView_Wanderbell.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            inputContainerBottomConstraint_Wanderbell = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        
        // 输入框背景
        inputBackgroundView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.right.equalTo(videoCallButton_Wanderbell.snp.left).offset(-12)
        }
        
        // 消息输入框
        messageInputTextView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(24)
            make.height.lessThanOrEqualTo(120)
        }
        
        // 占位符
        placeholderLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(messageInputTextView_Wanderbell).offset(4)
            make.top.equalTo(messageInputTextView_Wanderbell).offset(12)
        }
        
        // 视频通话按钮
        videoCallButton_Wanderbell.snp.makeConstraints { make in
            make.right.equalTo(sendButton_Wanderbell.snp.left).offset(-10)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(52)
        }
        
        // 发送按钮
        sendButton_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(52)
        }
    }
    
    /// 设置事件
    private func setupActions_Wanderbell() {
        sendButton_Wanderbell.addTarget(self, action: #selector(sendMessage_Wanderbell), for: .touchUpInside)
        videoCallButton_Wanderbell.addTarget(self, action: #selector(videoCallTapped_Wanderbell), for: .touchUpInside)
        messageInputTextView_Wanderbell.delegate = self
        
        // 点击手势关闭键盘
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Wanderbell))
        tapGesture_wanderbell.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    /// 设置键盘监听
    private func setupKeyboardObservers_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Wanderbell(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Wanderbell(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// 设置消息状态监听
    /// 功能：监听 MessageViewModel 的消息状态变化
    private func setupMessageObserver_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Wanderbell),
            name: MessageViewModel_Wanderbell.messageStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 数据加载
    
    /// 加载消息
    /// 功能：从 MessageViewModel 获取与当前用户的聊天记录
    private func loadMessages_Wanderbell() {
        guard let userId_wanderbell = userModel_Wanderbell?.userId_Wanderbell else {
            messages_Wanderbell = []
            updateEmptyStateVisibility_Wanderbell()
            return
        }
        
        // 从 MessageViewModel 获取消息列表
        messages_Wanderbell = MessageViewModel_Wanderbell.shared_Wanderbell.getMessagesWithUser_Wanderbell(
            userId_wanderbell: userId_wanderbell
        )
        
        updateEmptyStateVisibility_Wanderbell()
        tableView_Wanderbell.reloadData()
    }
    
    /// 更新空状态可见性
    private func updateEmptyStateVisibility_Wanderbell() {
        emptyStateView_Wanderbell.isHidden = !messages_Wanderbell.isEmpty
    }
    
    // MARK: - 事件处理
    
    /// 返回按钮点击
    @objc private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Wanderbell.block_Wanderbell(
            user_wanderbell: userModel_wanderbell,
            from: self
        ) { [weak self] in
            // 拉黑成功后返回
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 发送消息
    /// 功能：通过 MessageViewModel 发送消息，会自动处理回复
    @objc private func sendMessage_Wanderbell() {
        // 优先判断是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            // 延迟跳转到登录页面
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
            }
            return
        }
        
        guard let text_wanderbell = messageInputTextView_Wanderbell.text,
              !text_wanderbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let userId_wanderbell = userModel_Wanderbell?.userId_Wanderbell else {
            return
        }
        
        // 按钮动画
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton_Wanderbell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.sendButton_Wanderbell.transform = .identity
            }
        }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
        
        // 通过 MessageViewModel 发送消息
        MessageViewModel_Wanderbell.shared_Wanderbell.sendMessage_Wanderbell(
            message_wanderbell: text_wanderbell,
            chatType_wanderbell: .personal_wanderbell,
            id_wanderbell: userId_wanderbell
        )
        
        // 清空输入框
        messageInputTextView_Wanderbell.text = ""
        placeholderLabel_Wanderbell.isHidden = false
        
        // 重新加载消息（会在通知回调中自动刷新）
        loadMessages_Wanderbell()
        scrollToBottom_Wanderbell()
    }
    
    /// 处理消息状态变化
    /// 功能：当 MessageViewModel 的消息状态改变时（如收到新消息），自动刷新列表
    @objc private func handleMessageStateChange_Wanderbell() {
        loadMessages_Wanderbell()
        scrollToBottom_Wanderbell()
    }
    
    /// 视频通话按钮点击
    @objc private func videoCallTapped_Wanderbell() {
        // 按钮动画
        UIView.animate(withDuration: 0.1, animations: {
            self.videoCallButton_Wanderbell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.videoCallButton_Wanderbell.transform = .identity
            }
        }
        
        // 跳转到视频通话页面
        let videoChatVC_wanderbell = VideoChat_Wanderbell()
        videoChatVC_wanderbell.userModel_Wanderbell = userModel_Wanderbell
        videoChatVC_wanderbell.modalPresentationStyle = .fullScreen
        present(videoChatVC_wanderbell, animated: true)
    }
    
    /// 快捷回复点击
    /// 功能：点击快捷回复按钮时，自动填充并发送消息
    @objc private func quickReplyTapped_Wanderbell(_ sender: UIButton) {
        // 优先判断是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            // 延迟跳转到登录页面
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
            }
            return
        }
        guard let text_wanderbell = sender.title(for: .normal),
              let userId_wanderbell = userModel_Wanderbell?.userId_Wanderbell else { return }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
        
        // 直接通过 MessageViewModel 发送
        MessageViewModel_Wanderbell.shared_Wanderbell.sendMessage_Wanderbell(
            message_wanderbell: text_wanderbell,
            chatType_wanderbell: .personal_wanderbell,
            id_wanderbell: userId_wanderbell
        )
        
        // 消息会通过通知自动刷新
    }
    
    /// 关闭键盘
    @objc private func dismissKeyboard_Wanderbell() {
        view.endEditing(true)
    }
    
    /// 键盘显示
    @objc private func keyboardWillShow_Wanderbell(_ notification: Notification) {
        guard let keyboardFrame_wanderbell = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_wanderbell = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight_wanderbell = keyboardFrame_wanderbell.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration_wanderbell) {
            self.inputContainerBottomConstraint_Wanderbell?.update(offset: -keyboardHeight_wanderbell)
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom_Wanderbell()
    }
    
    /// 键盘隐藏
    @objc private func keyboardWillHide_Wanderbell(_ notification: Notification) {
        guard let duration_wanderbell = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration_wanderbell) {
            self.inputContainerBottomConstraint_Wanderbell?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 辅助方法
    
    /// 滚动到底部
    private func scrollToBottom_Wanderbell() {
        guard !messages_Wanderbell.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath_wanderbell = IndexPath(row: self.messages_Wanderbell.count - 1, section: 0)
            self.tableView_Wanderbell.scrollToRow(at: indexPath_wanderbell, at: .bottom, animated: true)
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MessageUser_Wanderbell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Wanderbell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_wanderbell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageBubbleCell_Wanderbell
        let message_wanderbell = messages_Wanderbell[indexPath.row]
        cell_wanderbell.configure_Wanderbell(with: message_wanderbell, userAvatar: userModel_Wanderbell?.userHead_Wanderbell)
        return cell_wanderbell
    }
}

// MARK: - UITextViewDelegate

extension MessageUser_Wanderbell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel_Wanderbell.isHidden = !textView.text.isEmpty
        
        // 动态调整高度
        let size_wanderbell = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        textView.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(min(max(size_wanderbell.height, 24), 120))
        }
    }
}

// MARK: - 消息气泡Cell

/// 消息气泡Cell
/// 功能：展示单条消息的气泡样式
class MessageBubbleCell_Wanderbell: UITableViewCell {
    
    // MARK: - UI组件
    
    /// 对方头像（使用UIImageView）
    private let otherAvatarImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.layer.cornerRadius = 19
        return imageView_wanderbell
    }()
    
    /// 我的头像（使用通用头像组件）
    private let myAvatarView_Wanderbell: UserAvatarView_Wanderbell = {
        let avatarView_wanderbell = UserAvatarView_Wanderbell()
        return avatarView_wanderbell
    }()
    
    /// 消息气泡
    private let bubbleView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 20
        return view_wanderbell
    }()
    
    /// 消息文本
    private let messageLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        label_wanderbell.numberOfLines = 0
        return label_wanderbell
    }()
    
    /// 时间标签
    private let timeLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 渐变图层
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Wanderbell?.frame = bubbleView_Wanderbell.bounds
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(otherAvatarImageView_Wanderbell)
        contentView.addSubview(myAvatarView_Wanderbell)
        contentView.addSubview(bubbleView_Wanderbell)
        bubbleView_Wanderbell.addSubview(messageLabel_Wanderbell)
        contentView.addSubview(timeLabel_Wanderbell)
    }
    
    // MARK: - 配置
    
    func configure_Wanderbell(with message: MessageModel_Wanderbell, userAvatar: String?) {
        messageLabel_Wanderbell.text = message.content_Wanderbell
        timeLabel_Wanderbell.text = message.time_Wanderbell
        
        // 移除旧的约束
        otherAvatarImageView_Wanderbell.snp.removeConstraints()
        myAvatarView_Wanderbell.snp.removeConstraints()
        bubbleView_Wanderbell.snp.removeConstraints()
        messageLabel_Wanderbell.snp.removeConstraints()
        timeLabel_Wanderbell.snp.removeConstraints()
        
        let isMine_wanderbell = message.isMine_Wanderbell ?? false
        
        if isMine_wanderbell {
            // 我的消息（右侧）- 使用登录用户头像组件
            otherAvatarImageView_Wanderbell.isHidden = true
            myAvatarView_Wanderbell.isHidden = false
            
            // 配置我的头像为当前登录用户
            let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
            myAvatarView_Wanderbell.configure_Wanderbell(userId_wanderbell: currentUser_wanderbell.userId_Wanderbell ?? 0)
            
            messageLabel_Wanderbell.textColor = .white
            
            // 设置渐变背景
            gradientLayer_Wanderbell?.removeFromSuperlayer()
            let gradient_wanderbell = CAGradientLayer()
            gradient_wanderbell.colors = [
                ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor,
                ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.cgColor
            ]
            gradient_wanderbell.startPoint = CGPoint(x: 0, y: 0)
            gradient_wanderbell.endPoint = CGPoint(x: 1, y: 1)
            gradient_wanderbell.cornerRadius = 20
            bubbleView_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
            gradientLayer_Wanderbell = gradient_wanderbell
            
            // 约束
            myAvatarView_Wanderbell.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalTo(bubbleView_Wanderbell)
                make.width.height.equalTo(38)
            }
            
            bubbleView_Wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.right.equalTo(myAvatarView_Wanderbell.snp.left).offset(-10)
                make.left.greaterThanOrEqualToSuperview().offset(80)
            }
            
            messageLabel_Wanderbell.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18))
            }
            
            timeLabel_Wanderbell.snp.makeConstraints { make in
                make.top.equalTo(bubbleView_Wanderbell.snp.bottom).offset(6)
                make.right.equalTo(bubbleView_Wanderbell).offset(-4)
                make.bottom.equalToSuperview().offset(-8)
            }
            
        } else {
            // 对方消息（左侧）- 使用UIImageView
            otherAvatarImageView_Wanderbell.isHidden = false
            myAvatarView_Wanderbell.isHidden = true
            
            if let avatar_wanderbell = userAvatar {
                otherAvatarImageView_Wanderbell.image = UIImage(named: avatar_wanderbell)
            }
            messageLabel_Wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
            
            // 设置白色背景
            gradientLayer_Wanderbell?.removeFromSuperlayer()
            bubbleView_Wanderbell.backgroundColor = .white
            bubbleView_Wanderbell.layer.shadowColor = UIColor.black.cgColor
            bubbleView_Wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
            bubbleView_Wanderbell.layer.shadowOpacity = 0.08
            bubbleView_Wanderbell.layer.shadowRadius = 12
            
            // 约束
            otherAvatarImageView_Wanderbell.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.bottom.equalTo(bubbleView_Wanderbell)
                make.width.height.equalTo(38)
            }
            
            bubbleView_Wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.left.equalTo(otherAvatarImageView_Wanderbell.snp.right).offset(10)
                make.right.lessThanOrEqualToSuperview().offset(-80)
            }
            
            messageLabel_Wanderbell.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18))
            }
            
            timeLabel_Wanderbell.snp.makeConstraints { make in
                make.top.equalTo(bubbleView_Wanderbell.snp.bottom).offset(6)
                make.left.equalTo(bubbleView_Wanderbell).offset(4)
                make.bottom.equalToSuperview().offset(-8)
            }
        }
    }
}
