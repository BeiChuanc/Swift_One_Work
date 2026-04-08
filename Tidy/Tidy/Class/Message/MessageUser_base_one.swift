import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 与用户聊天页

/// 与用户聊天页面
/// 核心作用：与指定用户进行单对单文字聊天，支持消息发送和展示
/// 设计思路：
///   顶部自定义导航（返回 + 用户信息水平布局居中 + 举报）
///   中间消息气泡列表，底部输入栏（视频聊天 + 发送）
/// 关键属性/方法：
///   - userModel_Base_one：当前聊天用户（由导航层注入）
///   - messages_Base_one：消息列表（从MessageViewModel获取）
///   - sendMessage_Base_one()：发送消息
class MessageUser_Base_one: UIViewController {

    // MARK: - 公开属性

    /// 当前聊天的用户模型（由导航层注入）
    var userModel_Base_one: PrewUserModel_Base_one?

    // MARK: - 私有数据属性

    /// 当前聊天消息列表
    private var messages_Base_one: [MessageModel_Base_one] = []

    // MARK: - UI组件 - 自定义顶部导航区

    /// 顶部导航白色容器（带底部阴影）
    private let navBarView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    /// 导航区底部微阴影分割线
    private let navShadowLine_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()

    /// 返回按钮组件
    private let backBtn_Base_one = BackButton_Base_one()

    /// 导航区中间信息水平容器（头像 + 文字竖向栈）
    private let navCenterView_Base_one: UIView = UIView()

    /// 用户头像（UserAvatarView_Base_one 组件）
    private let navAvatarView_Base_one: UserAvatarView_Base_one = {
        let v = UserAvatarView_Base_one()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    /// 头像渐变光环
    private let navAvatarRing_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    private var navAvatarRingGradient_Base_one: CAGradientLayer?

    /// 在线状态绿点（头像右下角）
    private let navOnlineDot_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Base_one: "#48BB78")
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户昵称
    private let navNameLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return l
    }()

    /// 用户简介
    private let navBioLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.numberOfLines = 1
        return l
    }()

    /// 名称+简介竖向栈
    private let navTextStack_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .leading
        return sv
    }()

    /// 举报按钮（右上角）
    private let reportBtn_Base_one: UIButton = ReportDeleteHelper_Base_one.createUserReportButton_Base_one(
        size_Base_one: 38,
        backgroundColor_Base_one: ColorConfig_Base_one.backgroundPrimary_Base_one,
        tintColor_Base_one: ColorConfig_Base_one.textSecondary_Base_one,
        withShadow_Base_one: false
    )

    // MARK: - UI组件 - 消息背景装饰

    /// 消息区域背景（渐变浅色）
    private let msgBgView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        return v
    }()

    // MARK: - UI组件 - 消息气泡列表

    /// 消息气泡列表 TableView
    private let tableView_Base_one: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(MessageBubbleCell_Base_one.self, forCellReuseIdentifier: MessageBubbleCell_Base_one.reuseId_Base_one)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tv.keyboardDismissMode = .interactive
        return tv
    }()

    // MARK: - UI组件 - 底部输入栏

    /// 输入栏主容器（白色，顶部圆角）
    private let inputBarView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 输入框胶囊背景
    private let inputContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        return v
    }()

    /// 文本输入框
    private let inputTextField_Base_one: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Type a message...",
            attributes: [.foregroundColor: ColorConfig_Base_one.textPlaceholder_Base_one]
        )
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.borderStyle = .none
        tf.returnKeyType = .send
        return tf
    }()

    /// 发送按钮（主渐变背景）
    private let sendBtn_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "arrow.up", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    /// 发送按钮渐变图层（延迟创建）
    private var sendGradient_Base_one: CAGradientLayer?

    // MARK: - 约束引用

    /// 输入栏底部约束（键盘弹出时更新）
    private var inputBarBottomConstraint_Base_one: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        setupConstraints_Base_one()
        setupActions_Base_one()
        setupKeyboard_Base_one()
        configureUserInfo_Base_one()
        observeMessages_Base_one()
        reloadMessages_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateButtonGradients_Base_one()
        updateNavAvatarRing_Base_one()
    }

    // MARK: - UI搭建

    private func setupUI_Base_one() {
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one

        /// 消息背景
        view.addSubview(msgBgView_Base_one)

        /// 消息列表
        view.addSubview(tableView_Base_one)
        tableView_Base_one.delegate = self
        tableView_Base_one.dataSource = self

        /// 输入栏
        view.addSubview(inputBarView_Base_one)
        inputBarView_Base_one.addSubview(inputContainer_Base_one)
        inputContainer_Base_one.addSubview(inputTextField_Base_one)
        inputBarView_Base_one.addSubview(sendBtn_Base_one)
        inputTextField_Base_one.delegate = self

        /// 导航栏（最后添加，覆盖在最上层）
        view.addSubview(navBarView_Base_one)
        navBarView_Base_one.addSubview(backBtn_Base_one)

        /// 导航中心区（头像环 + 头像 + 文字）
        navBarView_Base_one.addSubview(navCenterView_Base_one)
        navCenterView_Base_one.addSubview(navAvatarRing_Base_one)
        navAvatarRing_Base_one.addSubview(navAvatarView_Base_one)
        navCenterView_Base_one.addSubview(navOnlineDot_Base_one)
        navTextStack_Base_one.addArrangedSubview(navNameLabel_Base_one)
        navTextStack_Base_one.addArrangedSubview(navBioLabel_Base_one)
        navCenterView_Base_one.addSubview(navTextStack_Base_one)

        navBarView_Base_one.addSubview(reportBtn_Base_one)
        navBarView_Base_one.addSubview(navShadowLine_Base_one)
    }

    // MARK: - 约束布局

    private func setupConstraints_Base_one() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        let safeBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 34

        /// 消息区域背景
        msgBgView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 导航栏
        navBarView_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 64)
        }

        backBtn_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(44)
        }

        reportBtn_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(38)
        }

        /// 导航中心视图（水平布局：头像 + 文字）
        /// centerY 与返回按钮对齐，保证用户信息和返回/举报按钮处于同一水平线
        navCenterView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn_Base_one)
            make.leading.greaterThanOrEqualTo(backBtn_Base_one.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualTo(reportBtn_Base_one.snp.leading).offset(-6)
        }

        navAvatarRing_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        navAvatarView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        navOnlineDot_Base_one.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(navAvatarRing_Base_one).offset(1)
            make.width.height.equalTo(14)
        }

        navTextStack_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(navAvatarRing_Base_one.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        navShadowLine_Base_one.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        /// 消息列表
        tableView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Base_one.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView_Base_one.snp.top)
        }

        /// 底部输入栏
        inputBarView_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            inputBarBottomConstraint_Base_one = make.bottom.equalToSuperview().constraint
        }

        sendBtn_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-(12 + safeBottom))
            make.width.height.equalTo(48)
        }

        inputContainer_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendBtn_Base_one.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-(12 + safeBottom))
            make.height.greaterThanOrEqualTo(48)
        }

        inputTextField_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 操作绑定

    private func setupActions_Base_one() {
        backBtn_Base_one.onTapped_Base_one = { Navigation_Base_one.pop_Base_one() }
        reportBtn_Base_one.addTarget(self, action: #selector(reportTapped_Base_one), for: .touchUpInside)
        sendBtn_Base_one.addTarget(self, action: #selector(sendTapped_Base_one), for: .touchUpInside)

        /// 点击空白收起键盘
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Base_one))
        bgTap.cancelsTouchesInView = false
        tableView_Base_one.addGestureRecognizer(bgTap)
    }

    @objc private func dismissKeyboard_Base_one() {
        view.endEditing(true)
    }

    // MARK: - 键盘处理

    private func setupKeyboard_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChange_Base_one(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Base_one(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillChange_Base_one(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardH = UIScreen.main.bounds.height - frame.origin.y
        inputBarBottomConstraint_Base_one?.update(offset: -keyboardH)
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        scrollToBottom_Base_one(animated: true)
    }

    @objc private func keyboardWillHide_Base_one(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        inputBarBottomConstraint_Base_one?.update(offset: 0)
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    // MARK: - 用户信息配置

    /// 配置顶部导航区的用户信息
    private func configureUserInfo_Base_one() {
        guard let user = userModel_Base_one else { return }
        navNameLabel_Base_one.text = user.userName_Base_one ?? "User"
        navBioLabel_Base_one.text = user.userIntroduce_Base_one ?? "Online"
        if let userId = user.userId_Base_one {
            navAvatarView_Base_one.configure_Base_one(userId_Base_one: userId)
        }
    }

    // MARK: - 渐变更新

    /// 更新发送按钮渐变图层（布局后调用）
    private func updateButtonGradients_Base_one() {
        if sendGradient_Base_one == nil && sendBtn_Base_one.bounds.width > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: sendBtn_Base_one.bounds)
            sendBtn_Base_one.layer.insertSublayer(grad, at: 0)
            sendGradient_Base_one = grad
        } else {
            sendGradient_Base_one?.frame = sendBtn_Base_one.bounds
        }
    }

    /// 更新头像渐变光环（布局后调用）
    private func updateNavAvatarRing_Base_one() {
        guard navAvatarRing_Base_one.bounds.width > 0,
              navAvatarRingGradient_Base_one == nil else { return }
        let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: navAvatarRing_Base_one.bounds)
        grad.cornerRadius = 25
        navAvatarRing_Base_one.layer.insertSublayer(grad, at: 0)
        navAvatarRingGradient_Base_one = grad
    }

    // MARK: - 消息监听

    private func observeMessages_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMessageChange_Base_one),
            name: MessageViewModel_Base_one.messageStateDidChangeNotification_Base_one, object: nil
        )
    }

    @objc private func handleMessageChange_Base_one() {
        reloadMessages_Base_one()
    }

    // MARK: - 数据刷新

    /// 从ViewModel重新加载消息列表
    private func reloadMessages_Base_one() {
        guard let userId = userModel_Base_one?.userId_Base_one else { return }
        messages_Base_one = MessageViewModel_Base_one.shared_Base_one.getMessagesWithUser_Base_one(userId_base_one: userId)
        tableView_Base_one.reloadData()
        scrollToBottom_Base_one(animated: false)
    }

    /// 滚动到消息列表底部
    private func scrollToBottom_Base_one(animated: Bool) {
        guard !messages_Base_one.isEmpty else { return }
        let indexPath = IndexPath(row: messages_Base_one.count - 1, section: 0)
        DispatchQueue.main.async {
            self.tableView_Base_one.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    // MARK: - 事件处理

    /// 点击举报按钮
    @objc private func reportTapped_Base_one() {
        guard let user = userModel_Base_one else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        reportBtn_Base_one.animatePressDown_Base_one {
            self.reportBtn_Base_one.animatePressUp_Base_one()
        }
        // 等待 ActionSheet dismiss 动画完成（约 0.3s）后再 pop，
        // 避免 pop 与 modal 收起动画并发导致生命周期乱序、导航栏状态异常
        ReportDeleteHelper_Base_one.block_Base_one(user_Base_one: user, from: self) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func sendTapped_Base_one() {
        sendMessage_Base_one()
    }

    // MARK: - 发送消息

    /// 获取输入内容并调用ViewModel发送消息
    private func sendMessage_Base_one() {
        let text = inputTextField_Base_one.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty, let userId = userModel_Base_one?.userId_Base_one else { return }

        inputTextField_Base_one.text = ""
        sendBtn_Base_one.animatePressDown_Base_one { self.sendBtn_Base_one.animatePressUp_Base_one() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        Task { @MainActor in
            MessageViewModel_Base_one.shared_Base_one.sendMessage_Base_one(
                message_base_one: text,
                chatType_base_one: .personal_base_one,
                id_base_one: userId
            )
        }
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Base_one: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Base_one.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell_Base_one.reuseId_Base_one, for: indexPath
        ) as! MessageBubbleCell_Base_one
        cell.configure_Base_one(message: messages_Base_one[indexPath.row], partnerUser: userModel_Base_one)
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 68 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Base_one: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage_Base_one()
        return false
    }

    /// 输入框获得焦点时高亮边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputContainer_Base_one.layer.borderColor = ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.5).cgColor
        }
    }

    /// 输入框失去焦点时恢复边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputContainer_Base_one.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        }
    }
}

// MARK: - 消息气泡Cell

/// 消息气泡Cell
/// 功能：展示单条消息气泡，我发送=渐变右对齐，对方=白色卡片左对齐+UserAvatarView头像
/// 设计：气泡尾角、渐变背景、时间标签、头像使用UserAvatarView_Base_one组件
class MessageBubbleCell_Base_one: UITableViewCell {

    static let reuseId_Base_one = "MessageBubbleCell_Base_one"

    // MARK: - UI组件

    /// 对方头像（我发送时隐藏），使用UserAvatarView_Base_one组件
    private let avatarView_Base_one: UserAvatarView_Base_one = {
        let v = UserAvatarView_Base_one()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    /// 消息气泡容器（含圆角和裁剪）
    private let bubbleView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    /// 气泡渐变图层（我发送时显示）
    private var bubbleGradient_Base_one: CAGradientLayer?

    /// 标记当前气泡是否为"我发送"样式，供 layoutSubviews 按需创建/隐藏渐变图层
    private var isMineStyle_Base_one: Bool = false

    /// 消息内容文本
    private let messageLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    /// 发送时间
    private let timeLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return l
    }()

    // MARK: - 动态布局约束引用

    private var avatarLeading_Base_one: Constraint?
    private var avatarTrailing_Base_one: Constraint?
    private var bubbleLeading_Base_one: Constraint?
    private var bubbleTrailing_Base_one: Constraint?
    private var timeLeading_Base_one: Constraint?
    private var timeTrailing_Base_one: Constraint?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Base_one()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI搭建

    private func setupCellUI_Base_one() {
        contentView.addSubview(avatarView_Base_one)
        contentView.addSubview(bubbleView_Base_one)
        bubbleView_Base_one.addSubview(messageLabel_Base_one)
        contentView.addSubview(timeLabel_Base_one)

        avatarView_Base_one.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.width.height.equalTo(40)
            avatarLeading_Base_one = make.leading.equalToSuperview().offset(16).constraint
            avatarTrailing_Base_one = make.trailing.equalToSuperview().offset(-16).constraint
        }

        bubbleView_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.72)
            bubbleLeading_Base_one = make.leading.equalTo(avatarView_Base_one.snp.trailing).offset(8).constraint
            bubbleTrailing_Base_one = make.trailing.equalTo(avatarView_Base_one.snp.leading).offset(-8).constraint
        }

        messageLabel_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }

        timeLabel_Base_one.snp.makeConstraints { make in
            make.bottom.equalTo(bubbleView_Base_one).offset(-2)
            timeLeading_Base_one = make.leading.equalTo(bubbleView_Base_one.snp.trailing).offset(6).constraint
            timeTrailing_Base_one = make.trailing.equalTo(bubbleView_Base_one.snp.leading).offset(-6).constraint
        }

        /// 默认左对齐布局（对方消息）
        avatarTrailing_Base_one?.deactivate()
        bubbleTrailing_Base_one?.deactivate()
        timeTrailing_Base_one?.deactivate()
    }

    // MARK: - 配置数据

    /// 配置气泡样式和内容
    /// - Parameters:
    ///   - message: 消息模型
    ///   - partnerUser: 聊天对方用户模型（用于头像）
    func configure_Base_one(message: MessageModel_Base_one, partnerUser: PrewUserModel_Base_one?) {
        let isMine = message.isMine_Base_one ?? false
        messageLabel_Base_one.text = message.content_Base_one ?? ""
        timeLabel_Base_one.text = message.time_Base_one ?? ""

        if isMine {
            applyMineBubbleStyle_Base_one()
            avatarView_Base_one.isHidden = true
        } else {
            applyTheirBubbleStyle_Base_one()
            avatarView_Base_one.isHidden = false
            /// 使用 UserAvatarView_Base_one 组件加载对方头像
            if let userId = partnerUser?.userId_Base_one {
                avatarView_Base_one.configure_Base_one(userId_Base_one: userId)
            }
        }
    }

    // MARK: - 气泡样式切换

    /// 切换为我发送的气泡样式（渐变背景，右对齐）
    /// 渐变图层通过 DispatchQueue.main.async 延迟到当前 RunLoop 结束后创建，
    /// 此时 TableView 已完成 Cell 布局，bubbleView bounds 必然为非零值
    private func applyMineBubbleStyle_Base_one() {
        isMineStyle_Base_one = true

        avatarLeading_Base_one?.deactivate()
        avatarTrailing_Base_one?.activate()
        bubbleLeading_Base_one?.deactivate()
        bubbleTrailing_Base_one?.activate()
        timeLeading_Base_one?.deactivate()
        timeTrailing_Base_one?.activate()

        bubbleView_Base_one.backgroundColor = .clear
        bubbleView_Base_one.layer.shadowOpacity = 0
        messageLabel_Base_one.textColor = .white

        /// 若渐变图层已存在（复用场景），同步帧并直接显示
        if let grad = bubbleGradient_Base_one {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            grad.frame = bubbleView_Base_one.bounds
            grad.isHidden = false
            CATransaction.commit()
            return
        }

        /// 首次创建：延迟到下一个 RunLoop，保证 bounds 已由 TableView 确定
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isMineStyle_Base_one else { return }
            self.createBubbleGradientIfNeeded_Base_one()
        }
    }

    /// 创建并显示气泡渐变图层（确保 bounds 非零时调用）
    private func createBubbleGradientIfNeeded_Base_one() {
        guard bubbleView_Base_one.bounds.width > 0 else { return }
        if bubbleGradient_Base_one == nil {
            let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: bubbleView_Base_one.bounds)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            bubbleView_Base_one.layer.insertSublayer(grad, at: 0)
            CATransaction.commit()
            bubbleGradient_Base_one = grad
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bubbleGradient_Base_one?.frame = bubbleView_Base_one.bounds
        bubbleGradient_Base_one?.isHidden = false
        CATransaction.commit()
    }

    /// 切换为对方发送的气泡样式（白色卡片，左对齐）
    private func applyTheirBubbleStyle_Base_one() {
        isMineStyle_Base_one = false

        avatarLeading_Base_one?.activate()
        avatarTrailing_Base_one?.deactivate()
        bubbleLeading_Base_one?.activate()
        bubbleTrailing_Base_one?.deactivate()
        timeLeading_Base_one?.activate()
        timeTrailing_Base_one?.deactivate()

        bubbleView_Base_one.backgroundColor = .white
        bubbleView_Base_one.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        bubbleView_Base_one.layer.shadowOffset = CGSize(width: 0, height: 3)
        bubbleView_Base_one.layer.shadowRadius = 8
        bubbleView_Base_one.layer.shadowOpacity = 1
        messageLabel_Base_one.textColor = ColorConfig_Base_one.textPrimary_Base_one
        bubbleGradient_Base_one?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 屏幕旋转或尺寸变化时同步渐变帧
        guard isMineStyle_Base_one, let grad = bubbleGradient_Base_one,
              bubbleView_Base_one.bounds.width > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        grad.frame = bubbleView_Base_one.bounds
        CATransaction.commit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isMineStyle_Base_one = false
        bubbleGradient_Base_one?.isHidden = true
        avatarView_Base_one.isHidden = false
        /// 重置为左侧布局（对方消息），避免复用错位
        avatarLeading_Base_one?.activate()
        avatarTrailing_Base_one?.deactivate()
        bubbleLeading_Base_one?.activate()
        bubbleTrailing_Base_one?.deactivate()
        timeLeading_Base_one?.activate()
        timeTrailing_Base_one?.deactivate()
    }
}
