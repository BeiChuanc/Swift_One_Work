import UIKit
import SnapKit

// MARK: 用户聊天页面

/// 与用户聊天页面
/// 功能：顶部导航区展示对方用户信息（可点击进入用户中心）、消息气泡列表、底部输入框
/// 设计：海军蓝渐变导航区 + 浅蓝背景聊天区 + 蓝色我方气泡 + 白色对方气泡 + 蓝色发送按钮
class MessageUser_Ornit: UIViewController {

    // MARK: - 公共属性

    /// 聊天对象的用户模型（由跳转方赋值）
    var userModel_Ornit: PrewUserModel_Ornit?

    // MARK: - 私有数据属性

    /// 当前聊天消息列表
    private var messages_Ornit: [MessageModel_Ornit] = []

    // MARK: - 导航区组件

    /// 顶部渐变导航区容器
    private let navBar_Ornit = UIView()

    /// 导航区渐变图层（viewDidLayoutSubviews 中同步 frame）
    private var navGradient_Ornit: CAGradientLayer?

    /// 返回按钮
    private var backButton_Ornit: BackButton_Ornit?

    /// 用户信息横向卡片（头像 + 姓名 + 简介，可点击）
    private let userCard_Ornit = UIView()
    private let cardAvatarView_Ornit = UserAvatarView_Ornit()

    private let cardNameLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_ornit.textColor = .white
        return label_ornit
    }()

    private let cardBioLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.75)
        label_ornit.numberOfLines = 1
        return label_ornit
    }()

    // MARK: - 消息列表组件

    /// 聊天气泡 TableView
    private let tableView_Ornit: UITableView = {
        let tv_ornit = UITableView(frame: .zero, style: .plain)
        tv_ornit.backgroundColor = .clear
        tv_ornit.separatorStyle = .none
        tv_ornit.showsVerticalScrollIndicator = false
        tv_ornit.keyboardDismissMode = .interactive
        tv_ornit.register(
            ChatBubbleCell_Ornit.self,
            forCellReuseIdentifier: ChatBubbleCell_Ornit.reuseId_Ornit
        )
        return tv_ornit
    }()

    // MARK: - 输入区组件

    /// 底部输入区容器（白色背景，顶部阴影线）
    private let inputContainer_Ornit = UIView()

    /// 消息输入框（蓝色浅背景胶囊样式）
    private let inputField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Type a message..."
        tf_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.backgroundColor = ColorConfig_Ornit.backgroundMessage_Ornit
        tf_ornit.layer.cornerRadius = 20
        tf_ornit.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf_ornit.leftViewMode = .always
        tf_ornit.returnKeyType = .send
        return tf_ornit
    }()

    /// 发送按钮（蓝色圆形 + 箭头图标）
    private let sendButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        btn_ornit.setImage(
            UIImage(systemName: "arrow.up", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = .white
        btn_ornit.backgroundColor = ColorConfig_Ornit.messageAccent_Ornit
        btn_ornit.layer.cornerRadius = 20
        return btn_ornit
    }()

    /// 输入区底部约束（键盘弹起时动态更新）
    private var inputBottomConstraint_Ornit: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMessage_Ornit
        setupNavBar_Ornit()
        setupTableView_Ornit()
        setupInputBar_Ornit()
        setupNotifications_Ornit()
        loadData_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGradient_Ornit?.frame = navBar_Ornit.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageChange_Ornit),
            name: MessageViewModel_Ornit.messageStateDidChangeNotification_Ornit,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Ornit(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Ornit(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleMessageChange_Ornit() {
        loadData_Ornit()
    }

    @objc private func keyboardWillShow_Ornit(_ notification: Notification) {
        guard let frame_ornit = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration_ornit = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: duration_ornit) {
            self.inputBottomConstraint_Ornit?.update(offset: -frame_ornit.height + self.view.safeAreaInsets.bottom)
            self.view.layoutIfNeeded()
        }
        scrollToBottom_Ornit(animated: true)
    }

    @objc private func keyboardWillHide_Ornit(_ notification: Notification) {
        let duration_ornit = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: duration_ornit) {
            self.inputBottomConstraint_Ornit?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 数据加载

    /// 从 ViewModel 加载当前会话消息并滚动到底部
    private func loadData_Ornit() {
        guard let uid_ornit = userModel_Ornit?.userId_Ornit else { return }
        messages_Ornit = MessageViewModel_Ornit.shared_Ornit.getMessagesWithUser_Ornit(userId_ornit: uid_ornit)
        tableView_Ornit.reloadData()
        if !messages_Ornit.isEmpty {
            scrollToBottom_Ornit(animated: false)
        }
    }

    /// 滚动到最新一条消息
    private func scrollToBottom_Ornit(animated: Bool) {
        guard !messages_Ornit.isEmpty else { return }
        let indexPath_ornit = IndexPath(row: messages_Ornit.count - 1, section: 0)
        tableView_Ornit.scrollToRow(at: indexPath_ornit, at: .bottom, animated: animated)
    }

    // MARK: - UI 搭建

    /// 构建顶部渐变导航区（海军蓝渐变 + 返回键 + 用户卡片 + 视频通话 + 举报按钮）
    private func setupNavBar_Ornit() {
        view.addSubview(navBar_Ornit)

        // 海军蓝 → 明亮蓝渐变，与消息列表 Header 保持一致
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.messageGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.messageGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        navBar_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        navGradient_Ornit = gradient_ornit

        navBar_Ornit.layer.cornerRadius = 24
        navBar_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navBar_Ornit.clipsToBounds = true

        // 装饰圆（右上角）
        let deco_ornit = UIView()
        deco_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.06)
        deco_ornit.layer.cornerRadius = 56
        navBar_Ornit.addSubview(deco_ornit)

        // 返回按钮
        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in
            Navigation_Ornit.pop_Ornit(from: self)
        }
        navBar_Ornit.addSubview(backView_ornit)
        backButton_Ornit = backView_ornit

        // 举报按钮
        let reportBtn_ornit = ReportDeleteHelper_Ornit.createUserReportButton_Ornit(
            size_Ornit: 36,
            backgroundColor_Ornit: UIColor.white.withValues(alpha: 0.2),
            tintColor_Ornit: .white
        )
        navBar_Ornit.addSubview(reportBtn_ornit)

        // 用户信息卡片（横向：头像 + 姓名 + 简介）
        navBar_Ornit.addSubview(userCard_Ornit)
        userCard_Ornit.isUserInteractionEnabled = true
        userCard_Ornit.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(userCardTapped_Ornit))
        )

        // 头像外环（白色半透明边框营造质感）
        let avatarRing_ornit = UIView()
        avatarRing_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.2)
        avatarRing_ornit.layer.cornerRadius = 23
        userCard_Ornit.addSubview(avatarRing_ornit)

        userCard_Ornit.addSubview(cardAvatarView_Ornit)
        userCard_Ornit.addSubview(cardNameLabel_Ornit)
        userCard_Ornit.addSubview(cardBioLabel_Ornit)

        // 约束
        navBar_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(138)
        }

        deco_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(40)
            make_ornit.top.equalToSuperview().offset(-20)
            make_ornit.width.height.equalTo(112)
        }

        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.top.equalToSuperview().offset(54)
            make_ornit.width.height.equalTo(38)
        }

        reportBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.centerY.equalTo(backView_ornit)
            make_ornit.width.height.equalTo(36)
        }

        userCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(backView_ornit.snp.trailing).offset(8)
            make_ornit.trailing.equalTo(reportBtn_ornit.snp.leading).offset(-8)
            make_ornit.centerY.equalTo(backView_ornit)
        }

        avatarRing_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(46)
        }

        cardAvatarView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(3)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(40)
        }

        cardNameLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatarRing_ornit.snp.trailing).offset(10)
            make_ornit.trailing.equalToSuperview()
            make_ornit.bottom.equalTo(userCard_Ornit.snp.centerY).offset(-1)
        }

        cardBioLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatarRing_ornit.snp.trailing).offset(10)
            make_ornit.trailing.equalToSuperview()
            make_ornit.top.equalTo(userCard_Ornit.snp.centerY).offset(2)
        }

        // 配置用户信息
        if let uid_ornit = userModel_Ornit?.userId_Ornit {
            cardAvatarView_Ornit.configure_Ornit(userId_Ornit: uid_ornit)
        }
        cardNameLabel_Ornit.text = userModel_Ornit?.userName_Ornit ?? "User"
        cardBioLabel_Ornit.text = userModel_Ornit?.userIntroduce_Ornit ?? "Birdwatching enthusiast"

        // 举报按钮事件
        reportBtn_ornit.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_ornit = self.userModel_Ornit else { return }
            ReportDeleteHelper_Ornit.block_Ornit(user_Ornit: user_ornit, from: self) { [weak self] in
                guard let self = self else { return }
                Navigation_Ornit.popToSafeStateAfterBlock_Ornit(from: self)
            }
        }, for: .touchUpInside)
    }

    /// 构建聊天气泡 TableView
    private func setupTableView_Ornit() {
        view.addSubview(tableView_Ornit)
        tableView_Ornit.dataSource = self
        tableView_Ornit.delegate = self
        tableView_Ornit.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        tableView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(navBar_Ornit.snp.bottom).offset(4)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
    }

    /// 构建底部输入区（白色容器 + 胶囊输入框 + 蓝色发送按钮）
    private func setupInputBar_Ornit() {
        inputContainer_Ornit.backgroundColor = .white
        inputContainer_Ornit.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        inputContainer_Ornit.layer.shadowOffset = CGSize(width: 0, height: -3)
        inputContainer_Ornit.layer.shadowOpacity = 1
        inputContainer_Ornit.layer.shadowRadius = 8
        view.addSubview(inputContainer_Ornit)

        // 顶部分割线
        let topLine_ornit = UIView()
        topLine_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        inputContainer_Ornit.addSubview(topLine_ornit)

        inputContainer_Ornit.addSubview(inputField_Ornit)
        inputContainer_Ornit.addSubview(sendButton_Ornit)

        inputContainer_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(62)
            inputBottomConstraint_Ornit = make_ornit.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
        }

        topLine_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(0.5)
        }

        sendButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(40)
        }

        inputField_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalTo(sendButton_Ornit.snp.leading).offset(-10)
            make_ornit.centerY.equalToSuperview()
            make_ornit.height.equalTo(40)
        }

        inputField_Ornit.delegate = self
        sendButton_Ornit.addTarget(self, action: #selector(sendTapped_Ornit), for: .touchUpInside)

        let dismissTap_ornit = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Ornit))
        dismissTap_ornit.cancelsTouchesInView = false
        tableView_Ornit.addGestureRecognizer(dismissTap_ornit)
    }

    // MARK: - 事件处理

    /// 点击用户信息卡片，跳转到用户中心页面
    @objc private func userCardTapped_Ornit() {
        guard let user_ornit = userModel_Ornit else { return }
        Navigation_Ornit.toUserInfo_Ornit(with: user_ornit, isFromChat_ornit: true)
    }

    /// 点击发送按钮或键盘 Return 键，发送消息
    @objc private func sendTapped_Ornit() {
        guard let text_ornit = inputField_Ornit.text?.trimmingCharacters(in: .whitespaces),
              !text_ornit.isEmpty,
              let uid_ornit = userModel_Ornit?.userId_Ornit else { return }

        inputField_Ornit.text = ""
        MessageViewModel_Ornit.shared_Ornit.sendMessage_Ornit(
            message_ornit: text_ornit,
            chatType_ornit: .personal_ornit,
            id_ornit: uid_ornit
        )
    }

    /// 点击消息列表空白区域，收起键盘
    @objc private func dismissKeyboard_Ornit() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Ornit: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Ornit.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_ornit = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell_Ornit.reuseId_Ornit,
            for: indexPath
        ) as! ChatBubbleCell_Ornit
        cell_ornit.configure_Ornit(message_ornit: messages_Ornit[indexPath.row])
        return cell_ornit
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Ornit: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Ornit()
        return true
    }
}

// MARK: - 聊天气泡 Cell

/// 聊天气泡 Cell
/// 功能：根据 isMine 属性渲染左（对方白色气泡）/右（自己蓝色气泡）两种样式
/// 设计：我方 - 皇家蓝填充 + 白色文字；对方 - 白色背景 + 深色文字 + 蓝调阴影
class ChatBubbleCell_Ornit: UITableViewCell {

    static let reuseId_Ornit = "ChatBubbleCell_Ornit"

    // MARK: - UI 组件

    /// 气泡容器视图
    private let bubbleView_Ornit = UIView()

    /// 消息内容文字
    private let messageLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label_ornit.numberOfLines = 0
        return label_ornit
    }()

    /// 消息时间标签
    private let timeLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        return label_ornit
    }()

    /// 气泡左对齐约束（对方消息激活）
    private var bubbleLeadingConstraint_Ornit: Constraint?

    /// 气泡右对齐约束（自己消息激活）
    private var bubbleTrailingConstraint_Ornit: Constraint?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Ornit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Ornit() {
        backgroundColor = .clear
        selectionStyle = .none

        bubbleView_Ornit.layer.cornerRadius = 18
        contentView.addSubview(bubbleView_Ornit)
        bubbleView_Ornit.addSubview(messageLabel_Ornit)
        contentView.addSubview(timeLabel_Ornit)

        bubbleView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(4)
            make_ornit.bottom.equalTo(timeLabel_Ornit.snp.top).offset(-4)
            make_ornit.width.lessThanOrEqualTo(APPSCREEN_Ornit.WIDTH_Ornit * 0.68)
            bubbleLeadingConstraint_Ornit = make_ornit.leading.equalToSuperview().offset(16).constraint
            bubbleTrailingConstraint_Ornit = make_ornit.trailing.equalToSuperview().offset(-16).constraint
        }
        // 默认左对齐（对方消息），停用右对齐约束
        bubbleTrailingConstraint_Ornit?.deactivate()

        messageLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview().inset(UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16))
        }

        timeLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.bottom.equalToSuperview().offset(-4)
            make_ornit.leading.equalToSuperview().offset(16)
        }
    }

    // MARK: - 数据配置

    /// 根据消息方向配置气泡样式与对齐方式
    /// - Parameter message_ornit: 消息数据模型
    func configure_Ornit(message_ornit: MessageModel_Ornit) {
        let isMine_ornit = message_ornit.isMine_Ornit ?? false
        messageLabel_Ornit.text = message_ornit.content_Ornit ?? ""
        timeLabel_Ornit.text = message_ornit.time_Ornit ?? ""

        if isMine_ornit {
            // 我方消息：皇家蓝气泡 + 白色文字 + 右对齐
            bubbleView_Ornit.backgroundColor = ColorConfig_Ornit.messageAccent_Ornit
            bubbleView_Ornit.layer.shadowColor = UIColor.clear.cgColor
            bubbleView_Ornit.layer.shadowOpacity = 0
            messageLabel_Ornit.textColor = .white
            bubbleLeadingConstraint_Ornit?.deactivate()
            bubbleTrailingConstraint_Ornit?.activate()
            timeLabel_Ornit.snp.remakeConstraints { make_ornit in
                make_ornit.trailing.equalTo(bubbleView_Ornit.snp.trailing)
                make_ornit.bottom.equalToSuperview().offset(-4)
            }
        } else {
            // 对方消息：白色气泡 + 深色文字 + 蓝调阴影 + 左对齐
            bubbleView_Ornit.backgroundColor = .white
            bubbleView_Ornit.layer.shadowColor = ColorConfig_Ornit.messageAccent_Ornit.withValues(alpha: 0.1).cgColor
            bubbleView_Ornit.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Ornit.layer.shadowOpacity = 1
            bubbleView_Ornit.layer.shadowRadius = 6
            messageLabel_Ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
            bubbleTrailingConstraint_Ornit?.deactivate()
            bubbleLeadingConstraint_Ornit?.activate()
            timeLabel_Ornit.snp.remakeConstraints { make_ornit in
                make_ornit.leading.equalTo(bubbleView_Ornit.snp.leading)
                make_ornit.bottom.equalToSuperview().offset(-4)
            }
        }
    }
}
