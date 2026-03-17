import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天页面

/// 与用户聊天界面
/// 核心作用：展示聊天气泡列表，支持发送消息、举报/拉黑用户
/// 设计思路：隐藏系统导航栏，自定义顶部栏（返回 + 用户头像/昵称/简介居中 + 举报）；
///          所有内容从 safeAreaLayoutGuide.top 向下定位，避免侵入状态栏；
///          消息气泡：己方渐变右对齐，对方白卡左对齐
/// 关键属性：
/// - userModel_Pane: 当前聊天用户
/// - messages_Pane: 当前会话消息列表
/// - inputBarBottomCon_Pane: 输入栏底部约束（键盘联动）
class MessageUser_Pane: UIViewController {

    // MARK: - 属性

    /// 当前聊天用户
    var userModel_Pane: PrewUserModel_Pane?

    /// 当前会话消息列表
    private var messages_Pane: [MessageModel_Pane] = []

    // MARK: - UI · 顶部导航栏

    /// 自定义导航栏容器（延伸至屏幕顶部，内容从安全区域向下布局）
    private let navBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        return v
    }()

    /// 导航栏微渐变装饰图层
    private var navBarGradient_Pane: CAGradientLayer?

    /// 返回按钮
    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let img_pane = UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
            .withRenderingMode(.alwaysTemplate)
        b.setImage(img_pane, for: .normal)
        b.tintColor = ColorConfig_Pane.textPrimary_Pane
        b.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        b.layer.cornerRadius = 18
        return b
    }()

    /// 用户头像（导航栏居中）
    private let navAvatarView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        iv.layer.borderWidth = 2
        iv.layer.borderColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.5).cgColor
        return iv
    }()

    /// 用户昵称
    private let navNameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        l.textAlignment = .center
        return l
    }()

    /// 用户简介
    private let navIntroLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 举报/拉黑按钮（右上角）
    private lazy var reportButton_Pane: UIButton = {
        ReportDeleteHelper_Pane.createUserReportButton_Pane(
            size_Pane: 36,
            backgroundColor_Pane: ColorConfig_Pane.backgroundSecondary_Pane,
            tintColor_Pane: ColorConfig_Pane.textSecondary_Pane,
            withShadow_Pane: false
        )
    }()

    /// 导航栏底部分割线
    private let navDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    // MARK: - UI · 聊天背景装饰

    /// 聊天区域顶部装饰圆（薰衣草紫，增加空间感）
    private let bgDecorCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.06)
        v.layer.cornerRadius = 60
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI · 消息列表

    /// 消息气泡 TableView
    private lazy var messageTableView_Pane: UITableView = {
        let tv_pane = UITableView(frame: .zero, style: .plain)
        tv_pane.backgroundColor             = .clear
        tv_pane.separatorStyle              = .none
        tv_pane.showsVerticalScrollIndicator = false
        tv_pane.keyboardDismissMode         = .onDrag
        tv_pane.contentInset                = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tv_pane.estimatedRowHeight          = 64
        tv_pane.rowHeight                   = UITableView.automaticDimension
        tv_pane.register(
            MsgBubbleCell_Pane.self,
            forCellReuseIdentifier: MsgBubbleCell_Pane.reuseId_Pane
        )
        return tv_pane
    }()

    // MARK: - UI · 底部输入栏

    /// 输入栏外层容器
    private let inputBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        return v
    }()

    /// 输入栏顶部分割线
    private let inputDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    /// 输入框背景卡片
    private let inputCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        v.layer.cornerRadius = 20
        v.layer.borderWidth  = 1
        v.layer.borderColor  = ColorConfig_Pane.border_Pane.cgColor
        return v
    }()

    /// 消息输入框
    private let inputTextField_Pane: UITextField = {
        let tf = UITextField()
        tf.placeholder  = "Type a message..."
        tf.font         = .systemFont(ofSize: 15)
        tf.textColor    = ColorConfig_Pane.textPrimary_Pane
        tf.tintColor    = ColorConfig_Pane.primaryGradientStart_Pane
        tf.returnKeyType = .send
        tf.backgroundColor = .clear
        return tf
    }()

    /// 发送按钮（纯色背景 + tintColor 白色，确保图标在任何情况下可见）
    private let sendButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        b.setImage(
            UIImage(systemName: "paperplane.fill", withConfiguration: cfg_pane),
            for: .normal
        )
        b.tintColor       = .white
        b.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane
        b.layer.cornerRadius = 18
        b.clipsToBounds = true
        return b
    }()

    /// 输入栏底部约束（键盘弹出时动态更新）
    private var inputBarBottomCon_Pane: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
        setupNotifications_Pane()
        loadMessages_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBarGradient_Pane?.frame = navBar_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        // 聊天区背景装饰
        view.addSubview(bgDecorCircle_Pane)

        // 消息列表
        view.addSubview(messageTableView_Pane)

        // 输入栏
        view.addSubview(inputBar_Pane)
        inputBar_Pane.addSubview(inputDivider_Pane)
        inputBar_Pane.addSubview(inputCard_Pane)
        inputCard_Pane.addSubview(inputTextField_Pane)
        inputBar_Pane.addSubview(sendButton_Pane)

        // 导航栏（覆盖在最上层）
        view.addSubview(navBar_Pane)
        navBar_Pane.addSubview(backButton_Pane)
        navBar_Pane.addSubview(navAvatarView_Pane)
        navBar_Pane.addSubview(navNameLabel_Pane)
        navBar_Pane.addSubview(navIntroLabel_Pane)
        navBar_Pane.addSubview(reportButton_Pane)
        navBar_Pane.addSubview(navDivider_Pane)

        setupNavBarGradient_Pane()
        setupConstraints_Pane()
        fillUserInfo_Pane()

        messageTableView_Pane.dataSource = self
        messageTableView_Pane.delegate   = self
        inputTextField_Pane.delegate     = self
    }

    /// 导航栏微渐变（与背景融合，增加层次感）
    private func setupNavBarGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.secondaryGradientEnd_Pane.alpha_Pane(0.2).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        navBar_Pane.layer.insertSublayer(gl_pane, at: 0)
        navBarGradient_Pane = gl_pane
    }

    /// 填充顶部用户信息
    private func fillUserInfo_Pane() {
        guard let user_pane = userModel_Pane else { return }
        navNameLabel_Pane.text  = user_pane.userName_Pane
        navIntroLabel_Pane.text = user_pane.userIntroduce_Pane
        if let head_pane = user_pane.userHead_Pane {
            navAvatarView_Pane.image = UIImage(named: head_pane)
        }
    }

    /// 布局约束 — 所有内容元素从 safeAreaLayoutGuide.snp.top 向下定位，不侵入状态栏
    private func setupConstraints_Pane() {
        // 导航栏从屏幕顶延伸，底部 = safeArea.top + 90
        navBar_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
        }

        // 返回按钮：safeArea.top + 12，左侧
        backButton_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.width.height.equalTo(36)
        }

        // 举报按钮：safeArea.top + 12，右侧
        reportButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.width.height.equalTo(36)
        }

        // 头像：safeArea.top + 8，水平居中
        navAvatarView_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.width.height.equalTo(36)
        }

        // 昵称：头像下方，左右限于按钮内侧
        navNameLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(navAvatarView_Pane.snp.bottom).offset(4)
            $0.leading.greaterThanOrEqualTo(backButton_Pane.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualTo(reportButton_Pane.snp.leading).offset(-6)
        }

        // 简介：昵称下方
        navIntroLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(navNameLabel_Pane.snp.bottom).offset(2)
            $0.leading.greaterThanOrEqualTo(backButton_Pane.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualTo(reportButton_Pane.snp.leading).offset(-6)
        }

        // 分割线：导航栏底部
        navDivider_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        // 背景装饰圆：聊天区右上角
        bgDecorCircle_Pane.snp.makeConstraints {
            $0.top.equalTo(navBar_Pane.snp.bottom).offset(-20)
            $0.trailing.equalToSuperview().offset(30)
            $0.width.height.equalTo(120)
        }

        // 消息列表：导航栏底部 → 输入栏顶部
        messageTableView_Pane.snp.makeConstraints {
            $0.top.equalTo(navBar_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputBar_Pane.snp.top)
        }

        // 输入栏
        inputBar_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            inputBarBottomCon_Pane = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            $0.height.equalTo(66)
        }
        inputDivider_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        inputCard_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(sendButton_Pane.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
        inputTextField_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.top.bottom.equalToSuperview()
        }
        sendButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }
    }

    // MARK: - 数据加载

    /// 加载当前会话消息
    private func loadMessages_Pane() {
        guard let userId_pane = userModel_Pane?.userId_Pane else { return }
        messages_Pane = MessageViewModel_Pane.shared_Pane.getMessagesWithUser_Pane(userId_pane: userId_pane)
        messageTableView_Pane.reloadData()
        scrollToBottom_Pane(animated_pane: false)
    }

    /// 滚动至消息底部
    /// - Parameter animated_pane: 是否动画滚动
    private func scrollToBottom_Pane(animated_pane: Bool) {
        guard !messages_Pane.isEmpty else { return }
        let ip_pane = IndexPath(row: messages_Pane.count - 1, section: 0)
        messageTableView_Pane.scrollToRow(at: ip_pane, at: .bottom, animated: animated_pane)
    }

    // MARK: - 通知注册

    private func setupNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMessageStateChanged_Pane),
            name: MessageViewModel_Pane.messageStateDidChangeNotification_Pane,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Pane(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Pane(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 消息状态变更：重新加载消息
    @objc private func onMessageStateChanged_Pane() {
        loadMessages_Pane()
    }

    /// 键盘弹出：输入栏上移
    @objc private func keyboardWillShow_Pane(_ notification: Notification) {
        guard let kbFrame_pane  = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let offset_pane = kbFrame_pane.height - view.safeAreaInsets.bottom
        inputBarBottomCon_Pane?.update(offset: -offset_pane)
        UIView.animate(withDuration: duration_pane) { self.view.layoutIfNeeded() }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration_pane) {
            self.scrollToBottom_Pane(animated_pane: true)
        }
    }

    /// 键盘收起：输入栏复位
    @objc private func keyboardWillHide_Pane(_ notification: Notification) {
        guard let duration_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        inputBarBottomCon_Pane?.update(offset: 0)
        UIView.animate(withDuration: duration_pane) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        sendButton_Pane.addTarget(self, action: #selector(sendTapped_Pane), for: .touchUpInside)
        reportButton_Pane.addTarget(self, action: #selector(reportTapped_Pane), for: .touchUpInside)
    }

    @objc private func backTapped_Pane() {
        navigationController?.popViewController(animated: true)
    }

    /// 发送消息：读取输入框文本 → 调用 ViewModel → 清空输入框
    @objc private func sendTapped_Pane() {
        guard let text_pane    = inputTextField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text_pane.isEmpty,
              let userId_pane  = userModel_Pane?.userId_Pane
        else { return }
        inputTextField_Pane.text = nil
        MessageViewModel_Pane.shared_Pane.sendMessage_Pane(
            message_pane: text_pane,
            chatType_pane: .personal_pane,
            id_pane: userId_pane
        )
    }

    /// 举报/拉黑当前聊天用户，成功后返回上一页
    @objc private func reportTapped_Pane() {
        guard let user_pane = userModel_Pane else { return }
        ReportDeleteHelper_Pane.block_Pane(user_Pane: user_pane, from: self) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageUser_Pane: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Pane.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_pane = tableView.dequeueReusableCell(
            withIdentifier: MsgBubbleCell_Pane.reuseId_Pane,
            for: indexPath
        ) as! MsgBubbleCell_Pane
        cell_pane.configure_Pane(
            message_pane: messages_Pane[indexPath.row],
            peerHead_pane: userModel_Pane?.userHead_Pane,
            maxBubbleWidth_pane: view.bounds.width * 0.65
        )
        return cell_pane
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Pane: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Pane()
        return true
    }
}

// MARK: - MsgBubbleCell_Pane

/// 消息气泡 Cell
/// 核心作用：区分己方（右渐变气泡，无头像）和对方（左白卡气泡 + 头像）
/// 设计思路：通过 remakeConstraints 动态切换左右布局，避免约束冲突；
///          己方气泡使用 .custom 渐变图层确保白色图标可正常显示
private class MsgBubbleCell_Pane: UITableViewCell {

    static let reuseId_Pane = "MsgBubbleCell_Pane"

    // MARK: - 子视图

    /// 对方头像
    private let avatarView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 17
        iv.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        iv.layer.borderWidth = 1.5
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()

    /// 气泡容器
    private let bubbleView_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    /// 消息文本
    private let msgLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.numberOfLines = 0
        return l
    }()

    /// 时间标签
    private let timeLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    /// 己方气泡渐变图层
    private var bubbleGradient_Pane: CAGradientLayer?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        contentView.addSubview(avatarView_Pane)
        contentView.addSubview(bubbleView_Pane)
        bubbleView_Pane.addSubview(msgLabel_Pane)
        contentView.addSubview(timeLabel_Pane)

        msgLabel_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradient_Pane?.frame = bubbleView_Pane.bounds
    }

    // MARK: - 配置

    /// 渲染消息气泡
    /// - Parameters:
    ///   - message_pane: 消息模型
    ///   - peerHead_pane: 对方头像名称（isMine=false 时显示）
    ///   - maxBubbleWidth_pane: 气泡最大宽度（防止文字撑满全屏）
    func configure_Pane(
        message_pane: MessageModel_Pane,
        peerHead_pane: String?,
        maxBubbleWidth_pane: CGFloat
    ) {
        msgLabel_Pane.text  = message_pane.content_Pane
        timeLabel_Pane.text = message_pane.time_Pane
        if message_pane.isMine_Pane == true {
            renderMine_Pane(maxWidth_pane: maxBubbleWidth_pane)
        } else {
            renderPeer_Pane(head_pane: peerHead_pane, maxWidth_pane: maxBubbleWidth_pane)
        }
    }

    /// 己方气泡（右侧渐变背景，白色文字）
    private func renderMine_Pane(maxWidth_pane: CGFloat) {
        avatarView_Pane.isHidden = true
        msgLabel_Pane.textColor  = .white

        bubbleGradient_Pane?.removeFromSuperlayer()
        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        bubbleView_Pane.layer.insertSublayer(gl_pane, at: 0)
        bubbleGradient_Pane = gl_pane
        bubbleView_Pane.backgroundColor  = .clear
        bubbleView_Pane.layer.borderWidth = 0

        avatarView_Pane.snp.remakeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(8)
            $0.width.height.equalTo(0)
        }
        bubbleView_Pane.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.lessThanOrEqualTo(maxWidth_pane)
        }
        timeLabel_Pane.snp.remakeConstraints {
            $0.top.equalTo(bubbleView_Pane.snp.bottom).offset(4)
            $0.trailing.equalTo(bubbleView_Pane)
            $0.bottom.equalToSuperview().offset(-6)
        }
        timeLabel_Pane.textAlignment = .right
    }

    /// 对方气泡（左侧白卡 + 头像）
    private func renderPeer_Pane(head_pane: String?, maxWidth_pane: CGFloat) {
        avatarView_Pane.isHidden = false
        msgLabel_Pane.textColor  = ColorConfig_Pane.textPrimary_Pane

        if let head_pane = head_pane {
            avatarView_Pane.image = UIImage(named: head_pane)
        }

        bubbleGradient_Pane?.removeFromSuperlayer()
        bubbleGradient_Pane = nil
        bubbleView_Pane.backgroundColor  = ColorConfig_Pane.cardBackground_Pane
        bubbleView_Pane.layer.borderWidth = 1
        bubbleView_Pane.layer.borderColor = ColorConfig_Pane.border_Pane.cgColor

        avatarView_Pane.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(8)
            $0.width.height.equalTo(34)
        }
        bubbleView_Pane.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(avatarView_Pane.snp.trailing).offset(8)
            $0.width.lessThanOrEqualTo(maxWidth_pane)
        }
        timeLabel_Pane.snp.remakeConstraints {
            $0.top.equalTo(bubbleView_Pane.snp.bottom).offset(4)
            $0.leading.equalTo(bubbleView_Pane)
            $0.bottom.equalToSuperview().offset(-6)
        }
        timeLabel_Pane.textAlignment = .left
    }
}
