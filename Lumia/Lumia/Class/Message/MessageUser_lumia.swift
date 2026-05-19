import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天页面

/// 与用户聊天视图控制器
/// 核心作用：与指定用户的私聊界面，顶部渐变栏显示用户信息，底部输入栏发送消息
/// 设计思路：
///   - 顶部：玫瑰粉→珊瑚红渐变顶栏（与消息列表页一致），嵌入半透明用户信息卡
///   - 消息气泡：我方使用主渐变（紫→蓝），对方使用白色+轻紫调阴影
///   - 底部输入栏：白色背景，渐变圆形发送按钮，视频通话按钮使用主渐变色
class MessageUser_Lumia: UIViewController {

    // MARK: - 公开属性

    var userModel_Lumia: PrewUserModel_Lumia?

    // MARK: - 私有属性

    private var messages_Lumia: [MessageModel_Lumia] = []

    // MARK: - UI组件

    private let topBar_Lumia = UIView()
    private var topGradient_Lumia: CAGradientLayer?
    private let backButton_Lumia = BackButton_Lumia()

    /// 用户信息卡（半透明白色，嵌在渐变顶栏中央）
    private let userCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_Lumia.layer.cornerRadius = 22
        v_Lumia.layer.borderWidth = 1
        v_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v_Lumia
    }()

    private let cardAvatar_Lumia = UserAvatarView_Lumia()

    private let cardNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let cardIntroLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10.5, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl_Lumia.numberOfLines = 1
        return lbl_Lumia
    }()

    /// 举报按钮（同款半透明圆形）
    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor
        return btn_Lumia
    }()

    /// 消息列表
    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.separatorStyle = .none
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FFF0F5")
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.keyboardDismissMode = .onDrag
        tv_Lumia.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return tv_Lumia
    }()

    /// 底部输入栏
    private let inputBar_Lumia = UIView()
    private var inputBarBottom_Lumia: Constraint?

    private let inputField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.placeholder = "Type a message..."
        tf_Lumia.font = UIFont.systemFont(ofSize: 15)
        tf_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FFF0F5")
        tf_Lumia.layer.cornerRadius = 22
        tf_Lumia.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf_Lumia.leftViewMode = .always
        tf_Lumia.returnKeyType = .send
        return tf_Lumia
    }()

    /// 发送按钮（实色背景，避免 CAGradientLayer 遮挡图标内容层问题）
    private let sendButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Lumia.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F093FB")
        btn_Lumia.layer.cornerRadius = 20
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        setupKeyboardObservers_Lumia()
        setupObservers_Lumia()
        loadMessages_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadMessages_Lumia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradient_Lumia?.frame = topBar_Lumia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#FFF0F5")
        setupTopBar_Lumia()
        setupTableView_Lumia()
        setupInputBar_Lumia()
    }

    /// 配置渐变顶栏（与消息列表页同款：玫瑰粉→珊瑚红）
    private func setupTopBar_Lumia() {
        view.addSubview(topBar_Lumia)
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F093FB").cgColor,
            UIColor(hexstring_Lumia: "#F5576C").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        topBar_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        topBar_Lumia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topBar_Lumia.layer.cornerRadius = 24
        topGradient_Lumia = gradient_Lumia

        // 返回按钮
        topBar_Lumia.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        // 举报按钮
        topBar_Lumia.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backButton_Lumia)
            make.width.height.equalTo(38)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)

        // 用户信息卡（顶栏居中）
        topBar_Lumia.addSubview(userCard_Lumia)
        userCard_Lumia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton_Lumia)
            make.height.equalTo(44)
            make.width.equalTo(180)
        }

        cardAvatar_Lumia.layer.cornerRadius = 15
        cardAvatar_Lumia.clipsToBounds = true
        userCard_Lumia.addSubview(cardAvatar_Lumia)
        cardAvatar_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }

        let nameStack_Lumia = UIStackView(arrangedSubviews: [cardNameLabel_Lumia, cardIntroLabel_Lumia])
        nameStack_Lumia.axis = .vertical
        nameStack_Lumia.spacing = 1
        userCard_Lumia.addSubview(nameStack_Lumia)
        nameStack_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(cardAvatar_Lumia.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }

        let cardTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Lumia))
        userCard_Lumia.addGestureRecognizer(cardTap_Lumia)
        userCard_Lumia.isUserInteractionEnabled = true
    }

    private func setupTableView_Lumia() {
        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(MessageBubbleCell_Lumia.self, forCellReuseIdentifier: MessageBubbleCell_Lumia.reuseId_Lumia)
    }

    private func setupInputBar_Lumia() {
        view.addSubview(inputBar_Lumia)
        inputBar_Lumia.backgroundColor = .white
        inputBar_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#F5576C").cgColor
        inputBar_Lumia.layer.shadowOpacity = 0.10
        inputBar_Lumia.layer.shadowRadius = 10
        inputBar_Lumia.layer.shadowOffset = CGSize(width: 0, height: -3)
        inputBar_Lumia.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(tableView_Lumia.snp.bottom)
            inputBarBottom_Lumia = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        // 发送按钮（实色背景，无 CAGradientLayer）
        inputBar_Lumia.addSubview(sendButton_Lumia)
        sendButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        sendButton_Lumia.addTarget(self, action: #selector(handleSend_Lumia), for: .touchUpInside)

        // 输入框（从边缘开始，不再为视频按钮留空间）
        inputBar_Lumia.addSubview(inputField_Lumia)
        inputField_Lumia.delegate = self
        inputField_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton_Lumia.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.greaterThanOrEqualTo(44)
        }
    }

    // MARK: - 数据加载

    private func loadMessages_Lumia() {
        guard let user_Lumia = userModel_Lumia, let uid_Lumia = user_Lumia.userId_Lumia else { return }
        cardAvatar_Lumia.configure_Lumia(userId_Lumia: uid_Lumia)
        cardNameLabel_Lumia.text = user_Lumia.userName_Lumia ?? "User"
        cardIntroLabel_Lumia.text = user_Lumia.userIntroduce_Lumia ?? "Film photographer"
        messages_Lumia = MessageViewModel_Lumia.shared_Lumia.getMessagesWithUser_Lumia(userId_lumia: uid_Lumia)
        tableView_Lumia.reloadData()
        scrollToBottom_Lumia(animated: false)
    }

    private func scrollToBottom_Lumia(animated: Bool) {
        guard messages_Lumia.count > 0 else { return }
        tableView_Lumia.scrollToRow(at: IndexPath(row: messages_Lumia.count - 1, section: 0), at: .bottom, animated: animated)
    }

    // MARK: - 通知监听

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMessageChange_Lumia),
            name: MessageViewModel_Lumia.messageStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleMessageChange_Lumia() {
        guard let user_Lumia = userModel_Lumia, let uid_Lumia = user_Lumia.userId_Lumia else { return }
        messages_Lumia = MessageViewModel_Lumia.shared_Lumia.getMessagesWithUser_Lumia(userId_lumia: uid_Lumia)
        tableView_Lumia.reloadData()
        scrollToBottom_Lumia(animated: true)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 键盘监听

    private func setupKeyboardObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillShow_Lumia(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillHide_Lumia(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func handleKeyboardWillShow_Lumia(_ notification: Notification) {
        guard let keyboardFrame_Lumia = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Lumia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight_Lumia = keyboardFrame_Lumia.height - view.safeAreaInsets.bottom
        inputBarBottom_Lumia?.update(offset: -keyboardHeight_Lumia)
        UIView.animate(withDuration: duration_Lumia) { self.view.layoutIfNeeded() }
        scrollToBottom_Lumia(animated: true)
    }

    @objc private func handleKeyboardWillHide_Lumia(_ notification: Notification) {
        guard let duration_Lumia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottom_Lumia?.update(offset: 0)
        UIView.animate(withDuration: duration_Lumia) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件处理

    @objc private func handleSend_Lumia() {
        let text_Lumia = inputField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Lumia.isEmpty, let uid_Lumia = userModel_Lumia?.userId_Lumia else { return }
        inputField_Lumia.text = ""
        sendButton_Lumia.animatePulse_Lumia()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task { @MainActor in
            MessageViewModel_Lumia.shared_Lumia.sendMessage_Lumia(
                message_lumia: text_Lumia, chatType_lumia: .personal_lumia, id_lumia: uid_Lumia
            )
        }
    }

    @objc private func handleCardTap_Lumia() {
        guard let user_Lumia = userModel_Lumia else { return }
        Navigation_Lumia.toUserInfo_Lumia(with: user_Lumia, fromMessage_lumia: true)
    }

    @objc private func handleReport_Lumia() {
        guard let user_Lumia = userModel_Lumia else { return }
        ReportDeleteHelper_Lumia.block_Lumia(user_Lumia: user_Lumia, from: self) { [weak self] in
            Navigation_Lumia.popToSafeStateAfterBlock_Lumia(from: self ?? UIViewController())
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension MessageUser_Lumia: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Lumia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! MessageBubbleCell_Lumia
        let msg_Lumia = messages_Lumia[indexPath.row]
        let avatarPath_Lumia: String? = msg_Lumia.isMine_Lumia == true
            ? UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia().userHead_Lumia
            : userModel_Lumia?.userHead_Lumia
        cell_Lumia.configure_Lumia(message: msg_Lumia, avatarPath: avatarPath_Lumia)
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Lumia()
        return true
    }
}

// MARK: - 消息气泡 Cell

/// 消息气泡 Cell
/// 核心作用：展示单条消息，我方/对方使用不同颜色方案
/// 设计思路：
///   - 我方：主渐变（薰衣草紫→天空蓝）气泡 + 白色文字，右对齐
///   - 对方：白色气泡 + 轻紫调阴影 + 深色文字，左对齐
///   - 头像 36pt，带小渐变环装饰
private class MessageBubbleCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "MessageBubbleCell_Lumia"

    private let bubbleView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 18
        return v_Lumia
    }()
    private var bubbleGradient_Lumia: CAGradientLayer?

    private let messageLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()

    private let timeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C4A8C8")
        return lbl_Lumia
    }()

    private let avatarView_Lumia = UserAvatarView_Lumia()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradient_Lumia?.frame = bubbleView_Lumia.bounds
    }

    private func setupLayout_Lumia() {
        avatarView_Lumia.layer.cornerRadius = 18
        avatarView_Lumia.clipsToBounds = true
        contentView.addSubview(avatarView_Lumia)
        contentView.addSubview(bubbleView_Lumia)
        bubbleView_Lumia.addSubview(messageLabel_Lumia)
        contentView.addSubview(timeLabel_Lumia)

        avatarView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(36)
        }

        messageLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    func configure_Lumia(message: MessageModel_Lumia, avatarPath: String?) {
        messageLabel_Lumia.text = message.content_Lumia ?? ""
        timeLabel_Lumia.text = message.time_Lumia ?? ""

        // 移除旧渐变
        bubbleGradient_Lumia?.removeFromSuperlayer()
        bubbleGradient_Lumia = nil

        let isMine_Lumia = message.isMine_Lumia == true

        if isMine_Lumia {
            // 我方：主渐变气泡（薰衣草紫→天空蓝）+ 白色文字
            avatarView_Lumia.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.trailing.equalToSuperview().offset(-12)
                make.width.height.equalTo(36)
            }
            bubbleView_Lumia.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
                make.trailing.equalTo(avatarView_Lumia.snp.leading).offset(-8)
            }
            timeLabel_Lumia.snp.remakeConstraints { make in
                make.top.equalTo(bubbleView_Lumia.snp.bottom).offset(3)
                make.bottom.equalToSuperview().offset(-6)
                make.trailing.equalTo(bubbleView_Lumia)
            }

            let grad_Lumia = CAGradientLayer()
            grad_Lumia.colors = [
                ColorConfig_Lumia.primaryGradientStart_Lumia.cgColor,
                ColorConfig_Lumia.primaryGradientEnd_Lumia.cgColor
            ]
            grad_Lumia.startPoint = CGPoint(x: 0, y: 0)
            grad_Lumia.endPoint = CGPoint(x: 1, y: 1)
            grad_Lumia.cornerRadius = 18
            bubbleView_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
            bubbleGradient_Lumia = grad_Lumia
            bubbleView_Lumia.layer.shadowOpacity = 0
            messageLabel_Lumia.textColor = .white
        } else {
            // 对方：白色气泡 + 轻紫调阴影 + 深色文字
            avatarView_Lumia.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.leading.equalToSuperview().offset(12)
                make.width.height.equalTo(36)
            }
            bubbleView_Lumia.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
                make.leading.equalTo(avatarView_Lumia.snp.trailing).offset(8)
            }
            timeLabel_Lumia.snp.remakeConstraints { make in
                make.top.equalTo(bubbleView_Lumia.snp.bottom).offset(3)
                make.bottom.equalToSuperview().offset(-6)
                make.leading.equalTo(bubbleView_Lumia)
            }

            bubbleView_Lumia.backgroundColor = .white
            bubbleView_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#D4A8E8").cgColor
            bubbleView_Lumia.layer.shadowOpacity = 0.18
            bubbleView_Lumia.layer.shadowRadius = 8
            bubbleView_Lumia.layer.shadowOffset = CGSize(width: 0, height: 2)
            messageLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1040")
        }

        // 加载头像
        if let path_Lumia = avatarPath {
            avatarView_Lumia.loadAvatarFromPath_Lumia(
                path_Lumia: path_Lumia,
                defaultColor_Lumia: ColorConfig_Lumia.primaryGradientStart_Lumia
            )
        } else {
            avatarView_Lumia.setDefaultAvatar_Lumia(color_Lumia: ColorConfig_Lumia.primaryGradientStart_Lumia)
        }
    }
}
