import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天

/// 与用户聊天页面
/// 功能：展示聊天消息，支持发送消息、视频通话、举报用户
/// 设计：现代化聊天UI，顶部用户信息卡片，气泡消息布局，丰富的交互元素
class MessageUser_Glasspaint: UIViewController {
    
    // MARK: - 属性
    
    /// 聊天用户
    var userModel_Glasspaint: PrewUserModel_Glasspaint?
    
    /// 消息列表
    private var messages_Glasspaint: [MessageModel_Glasspaint] = []
    
    // MARK: - UI组件
    
    // 顶部用户信息区域
    private let userInfoContainer_Glasspaint = UIView()
    private let userInfoGradientLayer_Glasspaint = CAGradientLayer()
    private let userAvatarContainer_Glasspaint = UIView()
    private let userAvatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let avatarGlowLayer_Glasspaint = CAGradientLayer()
    private let userNameLabel_Glasspaint = UILabel()
    private let userBioLabel_Glasspaint = UILabel()
    private let onlineStatusView_Glasspaint = UIView()
    
    // 消息列表
    private let messageTableView_Glasspaint = UITableView()
    
    // 输入区域
    private let inputContainer_Glasspaint = UIView()
    private let inputGradientLayer_Glasspaint = CAGradientLayer()
    private let inputTextView_Glasspaint = UITextView()
    private let inputPlaceholderLabel_Glasspaint = UILabel()
    private let sendButton_Glasspaint = UIButton(type: .system)
    private let videoCallButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar_Glasspaint()
        setupUI_Glasspaint()
        loadMessages_Glasspaint()
        setupNotifications_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userInfoGradientLayer_Glasspaint.frame = userInfoContainer_Glasspaint.bounds
        inputGradientLayer_Glasspaint.frame = inputContainer_Glasspaint.bounds
        avatarGlowLayer_Glasspaint.frame = userAvatarContainer_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 导航栏设置
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        // 确保导航栏显示
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // 设置标题
        title = "Chat"
        
        // 设置导航栏颜色
        navigationController?.navigationBar.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 自定义返回按钮
        let backConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let backButton_glasspaint = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left", withConfiguration: backConfig_glasspaint),
            style: .plain,
            target: self,
            action: #selector(handleBack_Glasspaint)
        )
        navigationItem.leftBarButtonItem = backButton_glasspaint
        
        // 右侧举报按钮
        let reportConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let reportButton_glasspaint = UIBarButtonItem(
            image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: reportConfig_glasspaint),
            style: .plain,
            target: self,
            action: #selector(handleReport_Glasspaint)
        )
        navigationItem.rightBarButtonItem = reportButton_glasspaint
    }
    
    /// 返回
    @objc private func handleBack_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 用户信息区域
        setupUserInfoSection_Glasspaint()
        
        // 消息列表
        setupMessageList_Glasspaint()
        
        // 输入区域
        setupInputSection_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
    }
    
    /// 设置用户信息区域
    private func setupUserInfoSection_Glasspaint() {
        view.addSubview(userInfoContainer_Glasspaint)
        userInfoContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        userInfoContainer_Glasspaint.layer.cornerRadius = 20
        userInfoContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        userInfoContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        userInfoContainer_Glasspaint.layer.shadowRadius = 12
        userInfoContainer_Glasspaint.layer.shadowOpacity = 0.12
        
        // 渐变背景
        userInfoGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        userInfoGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        userInfoGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        userInfoGradientLayer_Glasspaint.cornerRadius = 20
        userInfoContainer_Glasspaint.layer.insertSublayer(userInfoGradientLayer_Glasspaint, at: 0)
        
        // 头像容器
        userInfoContainer_Glasspaint.addSubview(userAvatarContainer_Glasspaint)
        userAvatarContainer_Glasspaint.layer.cornerRadius = 31
        userAvatarContainer_Glasspaint.layer.masksToBounds = true
        
        // 头像光晕效果
        avatarGlowLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.2).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.05).cgColor
        ]
        avatarGlowLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        avatarGlowLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        userAvatarContainer_Glasspaint.layer.addSublayer(avatarGlowLayer_Glasspaint)
        
        // 头像
        userAvatarContainer_Glasspaint.addSubview(userAvatarView_Glasspaint)
        
        // 在线状态指示器
        userAvatarContainer_Glasspaint.addSubview(onlineStatusView_Glasspaint)
        onlineStatusView_Glasspaint.backgroundColor = UIColor.systemGreen
        onlineStatusView_Glasspaint.layer.cornerRadius = 7
        onlineStatusView_Glasspaint.layer.borderWidth = 2
        onlineStatusView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 用户名
        userInfoContainer_Glasspaint.addSubview(userNameLabel_Glasspaint)
        userNameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        userNameLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        userNameLabel_Glasspaint.textAlignment = .center
        
        // 简介
        userInfoContainer_Glasspaint.addSubview(userBioLabel_Glasspaint)
        userBioLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        userBioLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        userBioLabel_Glasspaint.textAlignment = .center
        userBioLabel_Glasspaint.numberOfLines = 0
        
        // 配置用户信息
        if let user_glasspaint = userModel_Glasspaint {
            userNameLabel_Glasspaint.text = user_glasspaint.userName_Glasspaint
            userBioLabel_Glasspaint.text = user_glasspaint.userIntroduce_Glasspaint ?? "Glass painting enthusiast"
            
            // 配置头像
            if let userId_glasspaint = user_glasspaint.userId_Glasspaint {
                userAvatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: userId_glasspaint)
            }
        }
    }
    
    /// 设置消息列表
    private func setupMessageList_Glasspaint() {
        view.addSubview(messageTableView_Glasspaint)
        messageTableView_Glasspaint.delegate = self
        messageTableView_Glasspaint.dataSource = self
        messageTableView_Glasspaint.backgroundColor = .clear
        messageTableView_Glasspaint.separatorStyle = .none
        messageTableView_Glasspaint.register(MessageCell_Glasspaint.self, forCellReuseIdentifier: "MessageCell")
        messageTableView_Glasspaint.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        // 添加点击手势隐藏键盘
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard_Glasspaint))
        messageTableView_Glasspaint.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 设置输入区域
    private func setupInputSection_Glasspaint() {
        view.addSubview(inputContainer_Glasspaint)
        inputContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        inputContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        inputContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: -3)
        inputContainer_Glasspaint.layer.shadowRadius = 10
        inputContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 输入区渐变层
        inputGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.03).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        inputGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        inputGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0)
        inputContainer_Glasspaint.layer.insertSublayer(inputGradientLayer_Glasspaint, at: 0)
        
        // 视频通话按钮
        inputContainer_Glasspaint.addSubview(videoCallButton_Glasspaint)
        let videoConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        videoCallButton_Glasspaint.setImage(UIImage(systemName: "video.fill", withConfiguration: videoConfig_glasspaint), for: .normal)
        videoCallButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        videoCallButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.12)
        videoCallButton_Glasspaint.layer.cornerRadius = 24
        videoCallButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        videoCallButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        videoCallButton_Glasspaint.layer.shadowRadius = 6
        videoCallButton_Glasspaint.layer.shadowOpacity = 0.2
        videoCallButton_Glasspaint.addTarget(self, action: #selector(handleVideoCall_Glasspaint), for: .touchUpInside)
        
        // 输入框
        inputContainer_Glasspaint.addSubview(inputTextView_Glasspaint)
        inputTextView_Glasspaint.delegate = self
        inputTextView_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        inputTextView_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        inputTextView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        inputTextView_Glasspaint.layer.cornerRadius = 24
        inputTextView_Glasspaint.layer.borderWidth = 1.5
        inputTextView_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15).cgColor
        inputTextView_Glasspaint.textContainerInset = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        
        // 占位符
        inputTextView_Glasspaint.addSubview(inputPlaceholderLabel_Glasspaint)
        inputPlaceholderLabel_Glasspaint.text = "Type a message..."
        inputPlaceholderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        inputPlaceholderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.6)
        
        // 发送按钮
        inputContainer_Glasspaint.addSubview(sendButton_Glasspaint)
        let sendConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        sendButton_Glasspaint.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: sendConfig_glasspaint), for: .normal)
        sendButton_Glasspaint.tintColor = .white
        sendButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        sendButton_Glasspaint.layer.cornerRadius = 24
        sendButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        sendButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 3)
        sendButton_Glasspaint.layer.shadowRadius = 8
        sendButton_Glasspaint.layer.shadowOpacity = 0.35
        sendButton_Glasspaint.addTarget(self, action: #selector(handleSend_Glasspaint), for: .touchUpInside)
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        // 用户信息区域
        userInfoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.right.equalToSuperview().inset(24)
        }
        
        userAvatarContainer_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(62)
        }
        
        userAvatarView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        // 为 UserAvatarView 添加边框和圆角
        userAvatarView_Glasspaint.layer.cornerRadius = 28
        userAvatarView_Glasspaint.layer.masksToBounds = true
        userAvatarView_Glasspaint.layer.borderWidth = 2.5
        userAvatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        onlineStatusView_Glasspaint.snp.makeConstraints { make in
            make.right.bottom.equalTo(userAvatarView_Glasspaint).offset(2)
            make.width.height.equalTo(14)
        }
        
        userNameLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userAvatarContainer_Glasspaint.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(28)
        }
        
        userBioLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Glasspaint.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(32)
            make.bottom.equalToSuperview().offset(-28)
        }
        
        // 输入区域
        inputContainer_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        
        videoCallButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        inputTextView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(videoCallButton_Glasspaint.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(48)
        }
        
        inputPlaceholderLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(14)
        }
        
        sendButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(inputTextView_Glasspaint.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        // 消息列表
        messageTableView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userInfoContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputContainer_Glasspaint.snp.top)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载消息
    private func loadMessages_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint,
              let userId_glasspaint = user_glasspaint.userId_Glasspaint else { return }
        
        messages_Glasspaint = MessageViewModel_Glasspaint.shared_Glasspaint.getMessagesWithUser_Glasspaint(userId_glasspaint: userId_glasspaint)
        messageTableView_Glasspaint.reloadData()
        scrollToBottom_Glasspaint(animated: false)
    }
    
    /// 滚动到底部
    /// 参数：
    /// - animated: 是否动画
    private func scrollToBottom_Glasspaint(animated: Bool) {
        guard messages_Glasspaint.count > 0 else { return }
        
        let indexPath_glasspaint = IndexPath(row: messages_Glasspaint.count - 1, section: 0)
        messageTableView_Glasspaint.scrollToRow(at: indexPath_glasspaint, at: .bottom, animated: animated)
    }
    
    /// 设置通知
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Glasspaint),
            name: MessageViewModel_Glasspaint.messageStateDidChangeNotification_Glasspaint,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Glasspaint),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Glasspaint),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - 事件处理
    
    /// 处理发送消息
    @objc private func handleSend_Glasspaint() {
        guard let text_glasspaint = inputTextView_Glasspaint.text, !text_glasspaint.isEmpty else {
            return
        }
        
        guard let user_glasspaint = userModel_Glasspaint,
              let userId_glasspaint = user_glasspaint.userId_Glasspaint else { return }
        
        // 发送消息
        MessageViewModel_Glasspaint.shared_Glasspaint.sendMessage_Glasspaint(
            message_glasspaint: text_glasspaint,
            chatType_glasspaint: .personal_glasspaint,
            id_glasspaint: userId_glasspaint
        )
        
        // 清空输入框
        inputTextView_Glasspaint.text = ""
        inputPlaceholderLabel_Glasspaint.isHidden = false
        
        // 发送按钮动画
        UIView.animate(withDuration: 0.2, animations: {
            self.sendButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.sendButton_Glasspaint.transform = .identity
            }
        }
    }
    
    /// 处理视频通话
    @objc private func handleVideoCall_Glasspaint() {
        // 视频通话按钮动画
        UIView.animate(withDuration: 0.2, animations: {
            self.videoCallButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.videoCallButton_Glasspaint.transform = .identity
            }
        }
        
        // 打开视频通话界面
        let videoVC_glasspaint = VideoChat_Glasspaint()
        videoVC_glasspaint.userModel_Glasspaint = userModel_Glasspaint
        videoVC_glasspaint.modalPresentationStyle = .fullScreen
        present(videoVC_glasspaint, animated: true)
    }
    
    /// 处理举报
    @objc private func handleReport_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        
        // 调用举报功能
        ReportDeleteHelper_Glasspaint.block_Glasspaint(
            user_Glasspaint: user_glasspaint,
            from: self
        ) { [weak self] in
            // 举报成功后返回上一页
            Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "User reported successfully", delay_Glasspaint: 1.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    /// 隐藏键盘
    @objc private func hideKeyboard_Glasspaint() {
        view.endEditing(true)
    }
    
    /// 处理消息状态变化
    @objc private func handleMessageStateChange_Glasspaint() {
        loadMessages_Glasspaint()
    }
    
    /// 键盘将要显示
    @objc private func keyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight_glasspaint = keyboardFrame_glasspaint.height
        inputContainer_Glasspaint.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-keyboardHeight_glasspaint)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom_Glasspaint(animated: true)
    }
    
    /// 键盘将要隐藏
    @objc private func keyboardWillHide_Glasspaint(_ notification: Notification) {
        inputContainer_Glasspaint.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension MessageUser_Glasspaint: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Glasspaint.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_glasspaint = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell_Glasspaint
        cell_glasspaint.configure_Glasspaint(with: messages_Glasspaint[indexPath.row])
        return cell_glasspaint
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITextViewDelegate

extension MessageUser_Glasspaint: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        inputPlaceholderLabel_Glasspaint.isHidden = !textView.text.isEmpty
    }
}

// MARK: - 消息Cell

/// 消息Cell
/// 设计：现代化气泡样式，渐变背景，阴影效果
class MessageCell_Glasspaint: UITableViewCell {
    
    private let bubbleView_Glasspaint = UIView()
    private let bubbleGradientLayer_Glasspaint = CAGradientLayer()
    private let messageLabel_Glasspaint = UILabel()
    private let timeLabel_Glasspaint = UILabel()
    private let statusIconView_Glasspaint = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradientLayer_Glasspaint.frame = bubbleView_Glasspaint.bounds
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bubbleView_Glasspaint)
        bubbleView_Glasspaint.layer.cornerRadius = 20
        bubbleView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        bubbleView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView_Glasspaint.layer.shadowRadius = 6
        bubbleView_Glasspaint.layer.shadowOpacity = 0.1
        
        bubbleView_Glasspaint.addSubview(messageLabel_Glasspaint)
        messageLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel_Glasspaint.numberOfLines = 0
        
        contentView.addSubview(timeLabel_Glasspaint)
        timeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        timeLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        contentView.addSubview(statusIconView_Glasspaint)
        let statusConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        statusIconView_Glasspaint.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: statusConfig_glasspaint)
        statusIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        statusIconView_Glasspaint.contentMode = .scaleAspectFit
    }
    
    /// 配置Cell
    /// 参数：
    /// - message_glasspaint: 消息数据
    func configure_Glasspaint(with message_glasspaint: MessageModel_Glasspaint) {
        messageLabel_Glasspaint.text = message_glasspaint.content_Glasspaint ?? ""
        timeLabel_Glasspaint.text = message_glasspaint.time_Glasspaint ?? ""
        
        // 移除旧约束
        bubbleView_Glasspaint.snp.removeConstraints()
        messageLabel_Glasspaint.snp.removeConstraints()
        timeLabel_Glasspaint.snp.removeConstraints()
        statusIconView_Glasspaint.snp.removeConstraints()
        
        // 移除渐变层
        bubbleGradientLayer_Glasspaint.removeFromSuperlayer()
        
        if message_glasspaint.isMine_Glasspaint == true {
            // 我的消息 - 右侧渐变气泡
            bubbleView_Glasspaint.backgroundColor = .clear
            messageLabel_Glasspaint.textColor = .white
            
            // 添加渐变层
            bubbleGradientLayer_Glasspaint.colors = [
                ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
                ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
            ]
            bubbleGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
            bubbleGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
            bubbleGradientLayer_Glasspaint.cornerRadius = 20
            bubbleView_Glasspaint.layer.insertSublayer(bubbleGradientLayer_Glasspaint, at: 0)
            
            bubbleView_Glasspaint.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-6)
                make.width.lessThanOrEqualTo(260)
            }
            
            messageLabel_Glasspaint.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
            }
            
            statusIconView_Glasspaint.snp.makeConstraints { make in
                make.right.equalTo(bubbleView_Glasspaint.snp.left).offset(-6)
                make.bottom.equalTo(bubbleView_Glasspaint)
                make.width.height.equalTo(12)
            }
            
            timeLabel_Glasspaint.snp.makeConstraints { make in
                make.right.equalTo(statusIconView_Glasspaint.snp.left).offset(-4)
                make.bottom.equalTo(bubbleView_Glasspaint)
            }
            
            statusIconView_Glasspaint.isHidden = false
            
        } else {
            // 对方消息 - 左侧灰色气泡
            bubbleView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
            messageLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
            
            bubbleView_Glasspaint.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.left.equalToSuperview().offset(16)
                make.bottom.equalToSuperview().offset(-6)
                make.width.lessThanOrEqualTo(260)
            }
            
            messageLabel_Glasspaint.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
            }
            
            timeLabel_Glasspaint.snp.makeConstraints { make in
                make.left.equalTo(bubbleView_Glasspaint.snp.right).offset(8)
                make.bottom.equalTo(bubbleView_Glasspaint)
            }
            
            statusIconView_Glasspaint.isHidden = true
        }
    }
}

