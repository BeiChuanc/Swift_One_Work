import UIKit
import SnapKit

// MARK: - 聊天气泡类型

private enum BubbleType_Trace {
    case mine_trace
    case theirs_trace
}

// MARK: - 用户聊天页

/// 与用户聊天视图控制器
/// 核心作用：展示与指定用户的双向对话气泡，支持文字发送、视频聊天入口、举报/删除操作
/// 设计思路：自定义导航标题（头像+昵称+简介），UITableView 气泡列表，底部输入条
/// 关键属性：userModel_Trace（聊天对象），messages_Trace（消息列表）
class MessageUser_Trace: UIViewController {
    
    // MARK: - 公共属性
    
    /// 聊天用户模型（由外部传入）
    var userModel_Trace: PrewUserModel_Trace?
    
    // MARK: - 私有属性
    
    private var messages_Trace: [MessageModel_Trace] = []
    
    /// 输入条底部约束（键盘联动）
    private var inputBarBottomConstraint_Trace: Constraint?
    
    // MARK: - UI 组件
    
    private lazy var tableView_Trace: UITableView = {
        let tv_Trace = UITableView()
        tv_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        tv_Trace.separatorStyle = .none
        tv_Trace.showsVerticalScrollIndicator = false
        tv_Trace.estimatedRowHeight = 60
        tv_Trace.rowHeight = UITableView.automaticDimension
        tv_Trace.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 80, right: 0)
        tv_Trace.dataSource = self
        tv_Trace.register(MsgBubbleCell_Trace.self, forCellReuseIdentifier: MsgBubbleCell_Trace.reuseId_Trace)
        tv_Trace.keyboardDismissMode = .onDrag
        return tv_Trace
    }()
    
    // --- 输入条 ---
    
    private let inputBarContainer_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.masksToBounds = false   // 保留阴影
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Trace.layer.shadowRadius = 12
        v_Trace.layer.shadowOpacity = 0.08
        return v_Trace
    }()
    
    /// 输入框（圆角 + 浅灰背景 + 细边框，与白色输入条形成层次对比）
    private let inputField_Trace: UITextField = {
        let tf_Trace = UITextField()
        tf_Trace.placeholder = "Type a message..."
        tf_Trace.font = UIFont.systemFont(ofSize: 15)
        tf_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        tf_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        tf_Trace.layer.cornerRadius = 21
        tf_Trace.layer.masksToBounds = true
        tf_Trace.layer.borderWidth = 0.5
        tf_Trace.layer.borderColor = ColorConfig_Trace.border_Trace.cgColor
        tf_Trace.returnKeyType = .send
        let leftPad_Trace = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 42))
        tf_Trace.leftView = leftPad_Trace
        tf_Trace.leftViewMode = .always
        let rightPad_Trace = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 42))
        tf_Trace.rightView = rightPad_Trace
        tf_Trace.rightViewMode = .always
        return tf_Trace
    }()
    
    /// 视频聊天按钮（圆形浅色背景）
    private lazy var videoCallBtn_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.layer.cornerRadius = 21
        btn_Trace.layer.masksToBounds = true
        btn_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.10)
        btn_Trace.addTarget(self, action: #selector(handleVideoCall_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    /// 视频图标（叠在按钮上方，避免背景色遮挡）
    private let videoIconIV_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iv_Trace.image = UIImage(systemName: "video.fill", withConfiguration: cfg_Trace)
        iv_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        iv_Trace.contentMode = .scaleAspectFit
        iv_Trace.isUserInteractionEnabled = false
        return iv_Trace
    }()
    
    /// 发送按钮（渐变背景，图标以子视图方式置于渐变层之上）
    private lazy var sendBtn_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.layer.cornerRadius = 21
        btn_Trace.layer.masksToBounds = true
        btn_Trace.addTarget(self, action: #selector(handleSend_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    /// 发送按钮内箭头图标（叠在渐变层上方）
    private let sendIconIV_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        iv_Trace.image = UIImage(systemName: "arrow.up", withConfiguration: cfg_Trace)
        iv_Trace.tintColor = .white
        iv_Trace.contentMode = .scaleAspectFit
        iv_Trace.isUserInteractionEnabled = false
        return iv_Trace
    }()
    
    private let sendGradLayer_Trace = CAGradientLayer()
    
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation_Trace()
        setupUI_Trace()
        subscribeNotifications_Trace()
        loadMessages_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setNavigationBarHidden 才能真正覆盖 navigationController 内部隐藏状态
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 消息栈内页面均需要导航栏可见，此处不隐藏
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendGradLayer_Trace.frame = sendBtn_Trace.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 导航栏配置
    
    /// 自定义居中标题视图：头像 + 昵称 + 简介
    private func setupNavigation_Trace() {
        navigationController?.navigationBar.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        
        // 返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBack_Trace)
        )
        
        // 举报按钮：使用 ReportDeleteHelper_Trace 统一样式创建，wrap 进 customView
        let reportBtn_Trace = ReportDeleteHelper_Trace.createUserReportButton_Trace(
            size_Trace: 34,
            backgroundColor_Trace: ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.10),
            tintColor_Trace: ColorConfig_Trace.primaryGradientStart_Trace,
            withShadow_Trace: false
        )
        reportBtn_Trace.addTarget(self, action: #selector(handleReport_Trace), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportBtn_Trace)
        
        // 自定义居中标题视图
        let titleView_Trace = buildNavTitleView_Trace()
        navigationItem.titleView = titleView_Trace
    }
    
    /// 构建导航居中标题视图（头像 + 昵称 + 简介）
    /// 注意：titleView 必须有明确 frame，否则 UINavigationBar 无法为其分配空间导致不显示
    private func buildNavTitleView_Trace() -> UIView {
        // 固定容器尺寸，确保 UINavigationBar 能正确布局 titleView
        let container_Trace = UIView(frame: CGRect(x: 0, y: 0, width: 220, height: 44))

        // 使用 UserAvatarView_Trace 展示聊天对象头像
        let avatarView_Trace = UserAvatarView_Trace()
        avatarView_Trace.configure_Trace(userId_Trace: userModel_Trace?.userId_Trace ?? 0)

        let nameLabel_Trace = UILabel()
        nameLabel_Trace.text = userModel_Trace?.userName_Trace ?? "User"
        nameLabel_Trace.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        nameLabel_Trace.textColor = ColorConfig_Trace.textPrimary_Trace

        let bioLabel_Trace = UILabel()
        bioLabel_Trace.text = userModel_Trace?.userIntroduce_Trace ?? ""
        bioLabel_Trace.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        bioLabel_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        bioLabel_Trace.numberOfLines = 1

        let textStack_Trace = UIStackView(arrangedSubviews: [nameLabel_Trace, bioLabel_Trace])
        textStack_Trace.axis = .vertical
        textStack_Trace.spacing = 1
        textStack_Trace.alignment = .leading

        let hStack_Trace = UIStackView(arrangedSubviews: [avatarView_Trace, textStack_Trace])
        hStack_Trace.axis = .horizontal
        hStack_Trace.spacing = 8
        hStack_Trace.alignment = .center

        container_Trace.addSubview(hStack_Trace)
        // 水平铺满容器，垂直居中；avatarView 固定 36×36
        hStack_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        avatarView_Trace.snp.makeConstraints { make in make.width.height.equalTo(36) }

        return container_Trace
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        
        view.addSubview(tableView_Trace)
        tableView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        setupInputBar_Trace()
    }
    
    /// 搭建底部输入条
    /// 布局（左→右）：[16] [输入框 flex] [10] [视频按钮 42×42] [8] [发送按钮 42×42] [16]
    private func setupInputBar_Trace() {
        view.addSubview(inputBarContainer_Trace)
        inputBarContainer_Trace.addSubview(inputField_Trace)
        inputBarContainer_Trace.addSubview(videoCallBtn_Trace)
        videoCallBtn_Trace.addSubview(videoIconIV_Trace)
        inputBarContainer_Trace.addSubview(sendBtn_Trace)
        sendBtn_Trace.addSubview(sendIconIV_Trace)
        
        // 左右各 16pt 外边距，底部距安全区 12pt，圆角卡片悬浮效果
        inputBarContainer_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            inputBarBottomConstraint_Trace = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12).constraint
            make.height.equalTo(56)
        }
        
        // 发送按钮（右侧 16pt，垂直居中，42×42）
        sendBtn_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }
        // 视频按钮（发送按钮左侧 8pt）
        videoCallBtn_Trace.snp.makeConstraints { make in
            make.trailing.equalTo(sendBtn_Trace.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }
        // 输入框（左 16pt，右到视频按钮左侧 10pt，高 42pt）
        inputField_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(videoCallBtn_Trace.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(42)
        }
        
        // 视频图标居中
        videoIconIV_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 发送按钮渐变层 + 图标（图标叠在渐变层上方）
        sendGradLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        sendGradLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        sendGradLayer_Trace.endPoint   = CGPoint(x: 1, y: 1)
        sendGradLayer_Trace.cornerRadius = 21
        sendBtn_Trace.layer.insertSublayer(sendGradLayer_Trace, at: 0)
        sendIconIV_Trace.snp.makeConstraints { make in make.center.equalToSuperview() }
        
        inputField_Trace.delegate = self
        tableView_Trace.contentInset.bottom = 80
    }
    
    // MARK: - 数据加载
    
    private func loadMessages_Trace() {
        guard let userId_Trace = userModel_Trace?.userId_Trace else { return }
        messages_Trace = MessageViewModel_Trace.shared_Trace.getMessagesWithUser_Trace(userId_trace: userId_Trace)
        tableView_Trace.reloadData()
        scrollToBottom_Trace(animated: false)
    }
    
    private func subscribeNotifications_Trace() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleMsgStateChange_Trace), name: MessageViewModel_Trace.messageStateDidChangeNotification_Trace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Trace(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Trace(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 滚动到最后一条消息
    private func scrollToBottom_Trace(animated: Bool) {
        guard !messages_Trace.isEmpty else { return }
        let indexPath_Trace = IndexPath(row: messages_Trace.count - 1, section: 0)
        tableView_Trace.scrollToRow(at: indexPath_Trace, at: .bottom, animated: animated)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleBack_Trace() {
        Navigation_Trace.pop_Trace()
    }
    
    /// 举报/操作弹窗
    /// - AI 对话：仅提供清空聊天记录入口
    /// - 真实用户：通过 ReportDeleteHelper_Trace.block_Trace 统一处理举报/拉黑流程
    @objc private func handleReport_Trace() {
        let isAssistant_Trace = (userModel_Trace?.userId_Trace == nil || userModel_Trace?.userId_Trace == 0)

        if isAssistant_Trace {
            // AI 对话专属：清空聊天记录
            let alert_Trace = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert_Trace.addAction(UIAlertAction(title: "Clear Chat History", style: .destructive) { [weak self] _ in
                MessageViewModel_Trace.shared_Trace.clearAiChat_Trace()
                self?.loadMessages_Trace()
            })
            alert_Trace.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            if let popover_Trace = alert_Trace.popoverPresentationController {
                popover_Trace.barButtonItem = navigationItem.rightBarButtonItem
            }
            present(alert_Trace, animated: true)
        } else {
            // 真实用户：使用 ReportDeleteHelper_Trace 统一举报/拉黑流程，完成后返回上页
            guard let user_Trace = userModel_Trace else { return }
            ReportDeleteHelper_Trace.block_Trace(user_Trace: user_Trace, from: self) {
                Navigation_Trace.pop_Trace()
            }
        }
    }
    
    @objc private func handleVideoCall_Trace() {
        guard let user_Trace = userModel_Trace else { return }
        videoCallBtn_Trace.animatePressDown_Trace {
            self.videoCallBtn_Trace.animatePressUp_Trace()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Navigation_Trace.toVideoChat_Trace(with: user_Trace)
    }
    
    @objc private func handleSend_Trace() {
        guard let text_Trace = inputField_Trace.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text_Trace.isEmpty else { return }
        guard let userId_Trace = userModel_Trace?.userId_Trace else { return }
        
        inputField_Trace.text = ""
        
        MessageViewModel_Trace.shared_Trace.sendMessage_Trace(
            message_trace: text_Trace,
            chatType_trace: .personal_trace,
            id_trace: userId_Trace
        )
        
        let generator_Trace = UIImpactFeedbackGenerator(style: .light)
        generator_Trace.impactOccurred()
        sendBtn_Trace.animatePulse_Trace()
    }
    
    @objc private func handleMsgStateChange_Trace() {
        guard let userId_Trace = userModel_Trace?.userId_Trace else { return }
        messages_Trace = MessageViewModel_Trace.shared_Trace.getMessagesWithUser_Trace(userId_trace: userId_Trace)
        tableView_Trace.reloadData()
        scrollToBottom_Trace(animated: true)
    }
    
    // MARK: - 键盘处理
    
    @objc private func keyboardWillShow_Trace(_ notification: Notification) {
        guard let keyboardFrame_Trace = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Trace = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        // 键盘弹出时保持 12pt 底部间距
        let offset_Trace = -(keyboardFrame_Trace.height - view.safeAreaInsets.bottom) - 12
        inputBarBottomConstraint_Trace?.update(offset: offset_Trace)
        
        UIView.animate(withDuration: duration_Trace) {
            self.view.layoutIfNeeded()
        }
        tableView_Trace.contentInset.bottom = keyboardFrame_Trace.height + 8
        scrollToBottom_Trace(animated: true)
    }
    
    @objc private func keyboardWillHide_Trace(_ notification: Notification) {
        guard let duration_Trace = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        // 键盘收起恢复 -12pt 底部间距
        inputBarBottomConstraint_Trace?.update(offset: -12)
        UIView.animate(withDuration: duration_Trace) {
            self.view.layoutIfNeeded()
        }
        tableView_Trace.contentInset.bottom = 80
    }
}

// MARK: - UITableViewDataSource

extension MessageUser_Trace: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Trace.isEmpty ? 1 : messages_Trace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages_Trace.isEmpty {
            let cell_Trace = UITableViewCell()
            cell_Trace.backgroundColor = .clear
            cell_Trace.selectionStyle = .none
            let lbl_Trace = UILabel()
            lbl_Trace.text = "Say hello to \(userModel_Trace?.userName_Trace ?? "them") 👋"
            lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            lbl_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
            lbl_Trace.textAlignment = .center
            cell_Trace.contentView.addSubview(lbl_Trace)
            lbl_Trace.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(40)
                make.top.equalToSuperview().offset(40)
                make.bottom.equalToSuperview().offset(-20)
            }
            return cell_Trace
        }
        
        let cell_Trace = tableView.dequeueReusableCell(withIdentifier: MsgBubbleCell_Trace.reuseId_Trace, for: indexPath) as! MsgBubbleCell_Trace
        cell_Trace.configure_Trace(
            message_trace: messages_Trace[indexPath.row],
            senderUserId_trace: userModel_Trace?.userId_Trace ?? 0
        )
        return cell_Trace
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Trace: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Trace()
        return true
    }
}

// MARK: - 消息气泡 Cell

/// 单条消息气泡 Cell
/// 功能：根据 isMine_Trace 区分左（对方）/右（自己）气泡，展示头像、文字内容、时间
private class MsgBubbleCell_Trace: UITableViewCell {
    
    static let reuseId_Trace = "MsgBubbleCell_Trace"
    
    // MARK: - UI 组件

    /// 发送方头像（对方消息时显示；UserAvatarView_Trace 自动加载）
    private let avatarView_Trace = UserAvatarView_Trace()
    
    /// 气泡容器
    private let bubbleView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.layer.cornerRadius = 18
        v_Trace.layer.masksToBounds = true
        return v_Trace
    }()
    
    private let bubbleGrad_Trace = CAGradientLayer()
    
    private let messageLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl_Trace.numberOfLines = 0
        return lbl_Trace
    }()
    
    private let timeLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
        return lbl_Trace
    }()
    
    // MARK: - 约束引用（用于切换左右对齐）
    
    private var mineConstraints_Trace: [Constraint] = []
    private var theirsConstraints_Trace: [Constraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Trace() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(avatarView_Trace)
        contentView.addSubview(bubbleView_Trace)
        bubbleView_Trace.addSubview(messageLabel_Trace)
        contentView.addSubview(timeLabel_Trace)

        // 气泡渐变（自己气泡专用）
        bubbleGrad_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        bubbleGrad_Trace.startPoint = CGPoint(x: 0, y: 0)
        bubbleGrad_Trace.endPoint = CGPoint(x: 1, y: 1)
        bubbleGrad_Trace.cornerRadius = 18
        
        // 头像基础约束
        avatarView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(36)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        
        // 气泡基础约束
        bubbleView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
        }
        messageLabel_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        
        // 时间标签
        timeLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(bubbleView_Trace.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGrad_Trace.frame = bubbleView_Trace.bounds
    }
    
    /// 配置气泡数据
    /// - Parameters:
    ///   - message_trace: 消息模型
    ///   - senderUserId_trace: 对方用户 ID（用于加载头像，自己的消息隐藏头像）
    func configure_Trace(message_trace: MessageModel_Trace, senderUserId_trace: Int) {
        let isMine_Trace = message_trace.isMine_Trace ?? false
        messageLabel_Trace.text = message_trace.content_Trace ?? ""
        timeLabel_Trace.text = message_trace.time_Trace ?? ""
        // 对方气泡才加载头像，自己的气泡隐藏，无需配置
        if !isMine_Trace {
            avatarView_Trace.configure_Trace(userId_Trace: senderUserId_trace)
        }
        
        // 根据是否本人决定气泡样式
        if isMine_Trace {
            // 右侧：渐变气泡，隐藏头像
            avatarView_Trace.isHidden = true
            messageLabel_Trace.textColor = .white
            bubbleView_Trace.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            bubbleView_Trace.layer.insertSublayer(bubbleGrad_Trace, at: 0)
            bubbleView_Trace.backgroundColor = .clear
            
            // 右对齐约束
            bubbleView_Trace.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.lessThanOrEqualToSuperview().offset(-24)
                make.trailing.equalToSuperview().offset(-16)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            }
            timeLabel_Trace.snp.remakeConstraints { make in
                make.top.equalTo(bubbleView_Trace.snp.bottom).offset(3)
                make.trailing.equalTo(bubbleView_Trace)
                make.bottom.equalToSuperview().offset(-4)
            }
        } else {
            // 左侧：白色气泡 + 头像
            avatarView_Trace.isHidden = false
            messageLabel_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
            bubbleGrad_Trace.removeFromSuperlayer()
            bubbleView_Trace.backgroundColor = .white
            bubbleView_Trace.layer.shadowColor = UIColor.black.cgColor
            bubbleView_Trace.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Trace.layer.shadowRadius = 6
            bubbleView_Trace.layer.shadowOpacity = 0.06
            bubbleView_Trace.layer.masksToBounds = false
            
            // 左对齐约束
            avatarView_Trace.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.top.equalToSuperview().offset(8)
                make.width.height.equalTo(36)
                make.bottom.lessThanOrEqualToSuperview().offset(-24)
            }
            bubbleView_Trace.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.lessThanOrEqualToSuperview().offset(-24)
                make.leading.equalTo(avatarView_Trace.snp.trailing).offset(8)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            }
            timeLabel_Trace.snp.remakeConstraints { make in
                make.top.equalTo(bubbleView_Trace.snp.bottom).offset(3)
                make.leading.equalTo(bubbleView_Trace)
                make.bottom.equalToSuperview().offset(-4)
            }
        }
    }
}
