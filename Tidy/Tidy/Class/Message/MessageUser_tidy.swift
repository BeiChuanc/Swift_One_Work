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
///   - userModel_Tidy：当前聊天用户（由导航层注入）
///   - messages_Tidy：消息列表（从MessageViewModel获取）
///   - sendMessage_Tidy()：发送消息
class MessageUser_Tidy: UIViewController {

    // MARK: - 公开属性

    /// 当前聊天的用户模型（由导航层注入）
    var userModel_Tidy: PrewUserModel_Tidy?

    // MARK: - 私有数据属性

    /// 当前聊天消息列表
    private var messages_Tidy: [MessageModel_Tidy] = []

    // MARK: - UI组件 - 自定义顶部导航区

    /// 顶部导航白色容器（带底部阴影）
    private let navBarView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    /// 导航区底部微阴影分割线
    private let navShadowLine_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()

    /// 返回按钮组件
    private let backBtn_Tidy = BackButton_Tidy()

    /// 导航区中间信息水平容器（头像 + 文字竖向栈）
    private let navCenterView_Tidy: UIView = UIView()

    /// 用户头像（UserAvatarView_Tidy 组件）
    private let navAvatarView_Tidy: UserAvatarView_Tidy = {
        let v = UserAvatarView_Tidy()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    /// 头像渐变光环
    private let navAvatarRing_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    private var navAvatarRingGradient_Tidy: CAGradientLayer?

    /// 在线状态绿点（头像右下角）
    private let navOnlineDot_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#48BB78")
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户昵称
    private let navNameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return l
    }()

    /// 用户简介
    private let navBioLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.numberOfLines = 1
        return l
    }()

    /// 名称+简介竖向栈
    private let navTextStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .leading
        return sv
    }()

    /// 举报按钮（右上角）
    private let reportBtn_Tidy: UIButton = ReportDeleteHelper_Tidy.createUserReportButton_Tidy(
        size_Tidy: 38,
        backgroundColor_Tidy: ColorConfig_Tidy.backgroundPrimary_Tidy,
        tintColor_Tidy: ColorConfig_Tidy.textSecondary_Tidy,
        withShadow_Tidy: false
    )

    // MARK: - UI组件 - 消息背景装饰

    /// 消息区域背景（渐变浅色）
    private let msgBgView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return v
    }()

    // MARK: - UI组件 - 消息气泡列表

    /// 消息气泡列表 TableView
    private let tableView_Tidy: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(MessageBubbleCell_Tidy.self, forCellReuseIdentifier: MessageBubbleCell_Tidy.reuseId_Tidy)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tv.keyboardDismissMode = .interactive
        return tv
    }()

    // MARK: - UI组件 - 底部输入栏

    /// 输入栏主容器（白色，顶部圆角）
    private let inputBarView_Tidy: UIView = {
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
    private let inputContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        return v
    }()

    /// 文本输入框
    private let inputTextField_Tidy: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Type a message...",
            attributes: [.foregroundColor: ColorConfig_Tidy.textPlaceholder_Tidy]
        )
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.borderStyle = .none
        tf.returnKeyType = .send
        return tf
    }()

    /// 发送按钮（主渐变背景）
    private let sendBtn_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "arrow.up", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    /// 发送按钮渐变图层（延迟创建）
    private var sendGradient_Tidy: CAGradientLayer?

    // MARK: - 约束引用

    /// 输入栏底部约束（键盘弹出时更新）
    private var inputBarBottomConstraint_Tidy: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        setupConstraints_Tidy()
        setupActions_Tidy()
        setupKeyboard_Tidy()
        configureUserInfo_Tidy()
        observeMessages_Tidy()
        reloadMessages_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateButtonGradients_Tidy()
        updateNavAvatarRing_Tidy()
    }

    // MARK: - UI搭建

    private func setupUI_Tidy() {
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy

        /// 消息背景
        view.addSubview(msgBgView_Tidy)

        /// 消息列表
        view.addSubview(tableView_Tidy)
        tableView_Tidy.delegate = self
        tableView_Tidy.dataSource = self

        /// 输入栏
        view.addSubview(inputBarView_Tidy)
        inputBarView_Tidy.addSubview(inputContainer_Tidy)
        inputContainer_Tidy.addSubview(inputTextField_Tidy)
        inputBarView_Tidy.addSubview(sendBtn_Tidy)
        inputTextField_Tidy.delegate = self

        /// 导航栏（最后添加，覆盖在最上层）
        view.addSubview(navBarView_Tidy)
        navBarView_Tidy.addSubview(backBtn_Tidy)

        /// 导航中心区（头像环 + 头像 + 文字）
        navBarView_Tidy.addSubview(navCenterView_Tidy)
        navCenterView_Tidy.addSubview(navAvatarRing_Tidy)
        navAvatarRing_Tidy.addSubview(navAvatarView_Tidy)
        navCenterView_Tidy.addSubview(navOnlineDot_Tidy)
        navTextStack_Tidy.addArrangedSubview(navNameLabel_Tidy)
        navTextStack_Tidy.addArrangedSubview(navBioLabel_Tidy)
        navCenterView_Tidy.addSubview(navTextStack_Tidy)

        navBarView_Tidy.addSubview(reportBtn_Tidy)
        navBarView_Tidy.addSubview(navShadowLine_Tidy)
    }

    // MARK: - 约束布局

    private func setupConstraints_Tidy() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        let safeBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 34

        /// 消息区域背景
        msgBgView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 导航栏
        navBarView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 64)
        }

        backBtn_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(44)
        }

        reportBtn_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(38)
        }

        /// 导航中心视图（水平布局：头像 + 文字）
        /// centerY 与返回按钮对齐，保证用户信息和返回/举报按钮处于同一水平线
        navCenterView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn_Tidy)
            make.leading.greaterThanOrEqualTo(backBtn_Tidy.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualTo(reportBtn_Tidy.snp.leading).offset(-6)
        }

        navAvatarRing_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        navAvatarView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        navOnlineDot_Tidy.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(navAvatarRing_Tidy).offset(1)
            make.width.height.equalTo(14)
        }

        navTextStack_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(navAvatarRing_Tidy.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        navShadowLine_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        /// 消息列表
        tableView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Tidy.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView_Tidy.snp.top)
        }

        /// 底部输入栏
        inputBarView_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            inputBarBottomConstraint_Tidy = make.bottom.equalToSuperview().constraint
        }

        sendBtn_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-(12 + safeBottom))
            make.width.height.equalTo(48)
        }

        inputContainer_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendBtn_Tidy.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-(12 + safeBottom))
            make.height.greaterThanOrEqualTo(48)
        }

        inputTextField_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 操作绑定

    private func setupActions_Tidy() {
        backBtn_Tidy.onTapped_Tidy = { Navigation_Tidy.pop_Tidy() }
        reportBtn_Tidy.addTarget(self, action: #selector(reportTapped_Tidy), for: .touchUpInside)
        sendBtn_Tidy.addTarget(self, action: #selector(sendTapped_Tidy), for: .touchUpInside)

        /// 点击空白收起键盘
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Tidy))
        bgTap.cancelsTouchesInView = false
        tableView_Tidy.addGestureRecognizer(bgTap)
    }

    @objc private func dismissKeyboard_Tidy() {
        view.endEditing(true)
    }

    // MARK: - 键盘处理

    private func setupKeyboard_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChange_Tidy(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Tidy(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillChange_Tidy(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardH = UIScreen.main.bounds.height - frame.origin.y
        inputBarBottomConstraint_Tidy?.update(offset: -keyboardH)
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        scrollToBottom_Tidy(animated: true)
    }

    @objc private func keyboardWillHide_Tidy(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        inputBarBottomConstraint_Tidy?.update(offset: 0)
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    // MARK: - 用户信息配置

    /// 配置顶部导航区的用户信息
    private func configureUserInfo_Tidy() {
        guard let user = userModel_Tidy else { return }
        navNameLabel_Tidy.text = user.userName_Tidy ?? "User"
        navBioLabel_Tidy.text = user.userIntroduce_Tidy ?? "Online"
        if let userId = user.userId_Tidy {
            navAvatarView_Tidy.configure_Tidy(userId_Tidy: userId)
        }
    }

    // MARK: - 渐变更新

    /// 更新发送按钮渐变图层（布局后调用）
    private func updateButtonGradients_Tidy() {
        if sendGradient_Tidy == nil && sendBtn_Tidy.bounds.width > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: sendBtn_Tidy.bounds)
            sendBtn_Tidy.layer.insertSublayer(grad, at: 0)
            sendGradient_Tidy = grad
        } else {
            sendGradient_Tidy?.frame = sendBtn_Tidy.bounds
        }
    }

    /// 更新头像渐变光环（布局后调用）
    private func updateNavAvatarRing_Tidy() {
        guard navAvatarRing_Tidy.bounds.width > 0,
              navAvatarRingGradient_Tidy == nil else { return }
        let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: navAvatarRing_Tidy.bounds)
        grad.cornerRadius = 25
        navAvatarRing_Tidy.layer.insertSublayer(grad, at: 0)
        navAvatarRingGradient_Tidy = grad
    }

    // MARK: - 消息监听

    private func observeMessages_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMessageChange_Tidy),
            name: MessageViewModel_Tidy.messageStateDidChangeNotification_Tidy, object: nil
        )
    }

    @objc private func handleMessageChange_Tidy() {
        reloadMessages_Tidy()
    }

    // MARK: - 数据刷新

    /// 从ViewModel重新加载消息列表
    private func reloadMessages_Tidy() {
        guard let userId = userModel_Tidy?.userId_Tidy else { return }
        messages_Tidy = MessageViewModel_Tidy.shared_Tidy.getMessagesWithUser_Tidy(userId_tidy: userId)
        tableView_Tidy.reloadData()
        scrollToBottom_Tidy(animated: false)
    }

    /// 滚动到消息列表底部
    private func scrollToBottom_Tidy(animated: Bool) {
        guard !messages_Tidy.isEmpty else { return }
        let indexPath = IndexPath(row: messages_Tidy.count - 1, section: 0)
        DispatchQueue.main.async {
            self.tableView_Tidy.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    // MARK: - 事件处理

    /// 点击举报按钮
    @objc private func reportTapped_Tidy() {
        guard let user = userModel_Tidy else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        reportBtn_Tidy.animatePressDown_Tidy {
            self.reportBtn_Tidy.animatePressUp_Tidy()
        }
        // 等待 ActionSheet dismiss 动画完成（约 0.3s）后再 pop，
        // 避免 pop 与 modal 收起动画并发导致生命周期乱序、导航栏状态异常
        ReportDeleteHelper_Tidy.block_Tidy(user_Tidy: user, from: self) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func sendTapped_Tidy() {
        sendMessage_Tidy()
    }

    // MARK: - 发送消息

    /// 获取输入内容并调用ViewModel发送消息
    private func sendMessage_Tidy() {
        let text = inputTextField_Tidy.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty, let userId = userModel_Tidy?.userId_Tidy else { return }

        inputTextField_Tidy.text = ""
        sendBtn_Tidy.animatePressDown_Tidy { self.sendBtn_Tidy.animatePressUp_Tidy() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        Task { @MainActor in
            MessageViewModel_Tidy.shared_Tidy.sendMessage_Tidy(
                message_tidy: text,
                chatType_tidy: .personal_tidy,
                id_tidy: userId
            )
        }
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Tidy: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Tidy.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell_Tidy.reuseId_Tidy, for: indexPath
        ) as! MessageBubbleCell_Tidy
        cell.configure_Tidy(message: messages_Tidy[indexPath.row], partnerUser: userModel_Tidy)
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 68 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Tidy: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage_Tidy()
        return false
    }

    /// 输入框获得焦点时高亮边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputContainer_Tidy.layer.borderColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.5).cgColor
        }
    }

    /// 输入框失去焦点时恢复边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputContainer_Tidy.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        }
    }
}

// MARK: - 消息气泡Cell

/// 消息气泡Cell
/// 功能：展示单条消息气泡，我发送=渐变右对齐，对方=白色卡片左对齐+UserAvatarView头像
/// 设计：气泡尾角、渐变背景、时间标签、头像使用UserAvatarView_Tidy组件
class MessageBubbleCell_Tidy: UITableViewCell {

    static let reuseId_Tidy = "MessageBubbleCell_Tidy"

    // MARK: - UI组件

    /// 对方头像（我发送时隐藏），使用UserAvatarView_Tidy组件
    private let avatarView_Tidy: UserAvatarView_Tidy = {
        let v = UserAvatarView_Tidy()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    /// 消息气泡容器（含圆角和裁剪）
    private let bubbleView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    /// 气泡渐变图层（我发送时显示）
    private var bubbleGradient_Tidy: CAGradientLayer?

    /// 标记当前气泡是否为"我发送"样式，供 layoutSubviews 按需创建/隐藏渐变图层
    private var isMineStyle_Tidy: Bool = false

    /// 消息内容文本
    private let messageLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    /// 发送时间
    private let timeLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return l
    }()

    // MARK: - 动态布局约束引用

    private var avatarLeading_Tidy: Constraint?
    private var avatarTrailing_Tidy: Constraint?
    private var bubbleLeading_Tidy: Constraint?
    private var bubbleTrailing_Tidy: Constraint?
    private var timeLeading_Tidy: Constraint?
    private var timeTrailing_Tidy: Constraint?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Tidy()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI搭建

    private func setupCellUI_Tidy() {
        contentView.addSubview(avatarView_Tidy)
        contentView.addSubview(bubbleView_Tidy)
        bubbleView_Tidy.addSubview(messageLabel_Tidy)
        contentView.addSubview(timeLabel_Tidy)

        avatarView_Tidy.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.width.height.equalTo(40)
            avatarLeading_Tidy = make.leading.equalToSuperview().offset(16).constraint
            avatarTrailing_Tidy = make.trailing.equalToSuperview().offset(-16).constraint
        }

        bubbleView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.72)
            bubbleLeading_Tidy = make.leading.equalTo(avatarView_Tidy.snp.trailing).offset(8).constraint
            bubbleTrailing_Tidy = make.trailing.equalTo(avatarView_Tidy.snp.leading).offset(-8).constraint
        }

        messageLabel_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }

        timeLabel_Tidy.snp.makeConstraints { make in
            make.bottom.equalTo(bubbleView_Tidy).offset(-2)
            timeLeading_Tidy = make.leading.equalTo(bubbleView_Tidy.snp.trailing).offset(6).constraint
            timeTrailing_Tidy = make.trailing.equalTo(bubbleView_Tidy.snp.leading).offset(-6).constraint
        }

        /// 默认左对齐布局（对方消息）
        avatarTrailing_Tidy?.deactivate()
        bubbleTrailing_Tidy?.deactivate()
        timeTrailing_Tidy?.deactivate()
    }

    // MARK: - 配置数据

    /// 配置气泡样式和内容
    /// - Parameters:
    ///   - message: 消息模型
    ///   - partnerUser: 聊天对方用户模型（用于头像）
    func configure_Tidy(message: MessageModel_Tidy, partnerUser: PrewUserModel_Tidy?) {
        let isMine = message.isMine_Tidy ?? false
        messageLabel_Tidy.text = message.content_Tidy ?? ""
        timeLabel_Tidy.text = message.time_Tidy ?? ""

        if isMine {
            applyMineBubbleStyle_Tidy()
            avatarView_Tidy.isHidden = true
        } else {
            applyTheirBubbleStyle_Tidy()
            avatarView_Tidy.isHidden = false
            /// 使用 UserAvatarView_Tidy 组件加载对方头像
            if let userId = partnerUser?.userId_Tidy {
                avatarView_Tidy.configure_Tidy(userId_Tidy: userId)
            }
        }
    }

    // MARK: - 气泡样式切换

    /// 切换为我发送的气泡样式（渐变背景，右对齐）
    /// 渐变图层通过 DispatchQueue.main.async 延迟到当前 RunLoop 结束后创建，
    /// 此时 TableView 已完成 Cell 布局，bubbleView bounds 必然为非零值
    private func applyMineBubbleStyle_Tidy() {
        isMineStyle_Tidy = true

        avatarLeading_Tidy?.deactivate()
        avatarTrailing_Tidy?.activate()
        bubbleLeading_Tidy?.deactivate()
        bubbleTrailing_Tidy?.activate()
        timeLeading_Tidy?.deactivate()
        timeTrailing_Tidy?.activate()

        bubbleView_Tidy.backgroundColor = .clear
        bubbleView_Tidy.layer.shadowOpacity = 0
        messageLabel_Tidy.textColor = .white

        /// 若渐变图层已存在（复用场景），同步帧并直接显示
        if let grad = bubbleGradient_Tidy {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            grad.frame = bubbleView_Tidy.bounds
            grad.isHidden = false
            CATransaction.commit()
            return
        }

        /// 首次创建：延迟到下一个 RunLoop，保证 bounds 已由 TableView 确定
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isMineStyle_Tidy else { return }
            self.createBubbleGradientIfNeeded_Tidy()
        }
    }

    /// 创建并显示气泡渐变图层（确保 bounds 非零时调用）
    private func createBubbleGradientIfNeeded_Tidy() {
        guard bubbleView_Tidy.bounds.width > 0 else { return }
        if bubbleGradient_Tidy == nil {
            let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: bubbleView_Tidy.bounds)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            bubbleView_Tidy.layer.insertSublayer(grad, at: 0)
            CATransaction.commit()
            bubbleGradient_Tidy = grad
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bubbleGradient_Tidy?.frame = bubbleView_Tidy.bounds
        bubbleGradient_Tidy?.isHidden = false
        CATransaction.commit()
    }

    /// 切换为对方发送的气泡样式（白色卡片，左对齐）
    private func applyTheirBubbleStyle_Tidy() {
        isMineStyle_Tidy = false

        avatarLeading_Tidy?.activate()
        avatarTrailing_Tidy?.deactivate()
        bubbleLeading_Tidy?.activate()
        bubbleTrailing_Tidy?.deactivate()
        timeLeading_Tidy?.activate()
        timeTrailing_Tidy?.deactivate()

        bubbleView_Tidy.backgroundColor = .white
        bubbleView_Tidy.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        bubbleView_Tidy.layer.shadowOffset = CGSize(width: 0, height: 3)
        bubbleView_Tidy.layer.shadowRadius = 8
        bubbleView_Tidy.layer.shadowOpacity = 1
        messageLabel_Tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy
        bubbleGradient_Tidy?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 屏幕旋转或尺寸变化时同步渐变帧
        guard isMineStyle_Tidy, let grad = bubbleGradient_Tidy,
              bubbleView_Tidy.bounds.width > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        grad.frame = bubbleView_Tidy.bounds
        CATransaction.commit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isMineStyle_Tidy = false
        bubbleGradient_Tidy?.isHidden = true
        avatarView_Tidy.isHidden = false
        /// 重置为左侧布局（对方消息），避免复用错位
        avatarLeading_Tidy?.activate()
        avatarTrailing_Tidy?.deactivate()
        bubbleLeading_Tidy?.activate()
        bubbleTrailing_Tidy?.deactivate()
        timeLeading_Tidy?.activate()
        timeTrailing_Tidy?.deactivate()
    }
}
