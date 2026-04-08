import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天

/// 与用户聊天页面
/// 核心作用：与指定用户进行一对一文字聊天
/// 设计思路：顶部渐变导航栏 + 居中用户信息卡片（可点击进入用户中心）+ 气泡消息列表 + 底部输入栏
/// 关键属性：userModel_Somnia（聊天对象）
class MessageUser_Somnia: UIViewController {

    // MARK: - 属性

    var userModel_Somnia: PrewUserModel_Somnia?

    // MARK: - 私有属性

    private var _messages_Somnia: [MessageModel_Somnia] = []

    // MARK: - UI组件

    private var _navGradient_Somnia: CAGradientLayer?

    /// 自定义导航栏
    private let navBar_Somnia: UIView = {
        let v = UIView()
        return v
    }()

    private let backButton_Somnia = BackButton_Somnia()

    /// 右上角举报按钮
    private let reportButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    /// 顶部用户信息卡片（居中，可点击）
    private let userCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.08
        v.isUserInteractionEnabled = true
        return v
    }()

    private let cardAvatarView_Somnia = UserAvatarView_Somnia()

    private let cardNameLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        return lbl
    }()

    private let cardIntroLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.numberOfLines = 1
        return lbl
    }()

    private let cardArrow_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 消息列表
    private let tableView_Somnia: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return tv
    }()

    /// 底部输入区域
    private let inputBar_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.06
        return v
    }()

    private let messageTextField_Somnia: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tf.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        return tf
    }()

    private let sendButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 20
        btn.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        return btn
    }()

    /// 键盘底部约束
    private var inputBarBottom_Somnia: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshMessages_Somnia()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
        setupKeyboardObservers_Somnia()
        setupNotifications_Somnia()
        refreshMessages_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _navGradient_Somnia?.frame = navBar_Somnia.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - 私有方法 - UI设置

    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        view.addSubview(navBar_Somnia)
        navBar_Somnia.addSubview(backButton_Somnia)
        navBar_Somnia.addSubview(reportButton_Somnia)
        view.addSubview(userCard_Somnia)
        userCard_Somnia.addSubview(cardAvatarView_Somnia)
        userCard_Somnia.addSubview(cardNameLabel_Somnia)
        userCard_Somnia.addSubview(cardIntroLabel_Somnia)
        userCard_Somnia.addSubview(cardArrow_Somnia)
        view.addSubview(tableView_Somnia)
        view.addSubview(inputBar_Somnia)
        inputBar_Somnia.addSubview(messageTextField_Somnia)
        inputBar_Somnia.addSubview(sendButton_Somnia)

        // 导航栏渐变
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 0)
        navBar_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        _navGradient_Somnia = grad_Somnia

        navBar_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
        }

        backButton_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        reportButton_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Somnia)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }

        userCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(navBar_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(72)
        }

        cardAvatarView_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(46)
        }

        cardNameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(cardAvatarView_Somnia.snp.right).offset(12)
            make.right.equalTo(cardArrow_Somnia.snp.left).offset(-8)
        }

        cardIntroLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(cardNameLabel_Somnia.snp.bottom).offset(4)
            make.left.equalTo(cardAvatarView_Somnia.snp.right).offset(12)
            make.right.equalTo(cardArrow_Somnia.snp.left).offset(-8)
        }

        cardArrow_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        inputBar_Somnia.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottom_Somnia = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.height.equalTo(70)
        }

        messageTextField_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalTo(sendButton_Somnia.snp.left).offset(-10)
        }

        sendButton_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        tableView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(userCard_Somnia.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar_Somnia.snp.top)
        }

        tableView_Somnia.delegate = self
        tableView_Somnia.dataSource = self
        tableView_Somnia.register(ChatBubbleCell_Somnia.self, forCellReuseIdentifier: "ChatBubbleCell_Somnia")

        // 填充用户信息卡片
        if let user_Somnia = userModel_Somnia {
            if let uid_Somnia = user_Somnia.userId_Somnia {
                cardAvatarView_Somnia.configure_Somnia(userId_Somnia: uid_Somnia)
            }
            cardNameLabel_Somnia.text = user_Somnia.userName_Somnia ?? "User"
            cardIntroLabel_Somnia.text = user_Somnia.userIntroduce_Somnia ?? "Tap to view profile"
        }
    }

    private func setupActions_Somnia() {
        backButton_Somnia.onTapped_Somnia = {
            Navigation_Somnia.pop_Somnia()
        }

        reportButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleReport_Somnia()
        }, for: .touchUpInside)

        // 点击用户卡片 → 进入用户中心（不显示消息按钮）
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Somnia))
        userCard_Somnia.addGestureRecognizer(tap_Somnia)

        sendButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.sendMessage_Somnia()
        }, for: .touchUpInside)

        messageTextField_Somnia.addTarget(self, action: #selector(handleReturn_Somnia), for: .editingDidEndOnExit)

        let bgTap_Somnia = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Somnia))
        bgTap_Somnia.cancelsTouchesInView = false
        tableView_Somnia.addGestureRecognizer(bgTap_Somnia)
    }

    private func setupNotifications_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageChange_Somnia),
            name: MessageViewModel_Somnia.messageStateDidChangeNotification_Somnia,
            object: nil
        )
    }

    private func setupKeyboardObservers_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Somnia(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Somnia(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - 私有方法 - 数据

    private func refreshMessages_Somnia() {
        guard let uid_Somnia = userModel_Somnia?.userId_Somnia else { return }
        _messages_Somnia = MessageViewModel_Somnia.shared_Somnia.getMessagesWithUser_Somnia(userId_somnia: uid_Somnia)
        tableView_Somnia.reloadData()
        scrollToBottom_Somnia()
    }

    private func scrollToBottom_Somnia() {
        guard !_messages_Somnia.isEmpty else { return }
        let indexPath_Somnia = IndexPath(row: _messages_Somnia.count - 1, section: 0)
        tableView_Somnia.scrollToRow(at: indexPath_Somnia, at: .bottom, animated: true)
    }

    // MARK: - 私有方法 - 事件处理

    /// 发送消息
    private func sendMessage_Somnia() {
        let text_Somnia = messageTextField_Somnia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Somnia.isEmpty, let uid_Somnia = userModel_Somnia?.userId_Somnia else { return }

        Task { @MainActor in
            MessageViewModel_Somnia.shared_Somnia.sendMessage_Somnia(
                message_somnia: text_Somnia,
                chatType_somnia: .personal_somnia,
                id_somnia: uid_Somnia
            )
        }
        messageTextField_Somnia.text = ""
    }

    /// 处理举报用户
    private func handleReport_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        ReportDeleteHelper_Somnia.block_Somnia(user_Somnia: user_Somnia, from: self) { [weak self] in
            Navigation_Somnia.popToSafeStateAfterBlock_Somnia(from: self ?? UIViewController())
        }
    }

    @objc private func handleCardTap_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        let userInfoVC_Somnia = UserInfo_Somnia()
        userInfoVC_Somnia.userModel_Somnia = user_Somnia
        userInfoVC_Somnia.isFromMessageChat_Somnia = true
        Navigation_Somnia.push_Somnia(to: userInfoVC_Somnia)
    }

    @objc private func handleReturn_Somnia() { sendMessage_Somnia() }
    @objc private func dismissKeyboard_Somnia() { view.endEditing(true) }
    @objc private func handleMessageChange_Somnia() { refreshMessages_Somnia() }

    // MARK: - 键盘处理

    @objc private func keyboardWillShow_Somnia(_ notification: Notification) {
        guard let info_Somnia = notification.userInfo,
              let frame_Somnia = info_Somnia[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Somnia = info_Somnia[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight_Somnia = frame_Somnia.height - view.safeAreaInsets.bottom
        inputBarBottom_Somnia?.update(offset: -keyboardHeight_Somnia)
        UIView.animate(withDuration: duration_Somnia) { self.view.layoutIfNeeded() }
        scrollToBottom_Somnia()
    }

    @objc private func keyboardWillHide_Somnia(_ notification: Notification) {
        guard let duration_Somnia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottom_Somnia?.update(offset: 0)
        UIView.animate(withDuration: duration_Somnia) { self.view.layoutIfNeeded() }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension MessageUser_Somnia: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _messages_Somnia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Somnia = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell_Somnia", for: indexPath) as! ChatBubbleCell_Somnia
        guard indexPath.row < _messages_Somnia.count else { return cell_Somnia }
        let msg_Somnia = _messages_Somnia[indexPath.row]
        let avatarPath_Somnia = msg_Somnia.isMine_Somnia == true
            ? UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia().userHead_Somnia
            : userModel_Somnia?.userHead_Somnia
        cell_Somnia.configure_Somnia(
            message_Somnia: msg_Somnia,
            avatarPath_Somnia: avatarPath_Somnia
        )
        return cell_Somnia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - 聊天气泡单元格

/// 聊天气泡单元格
/// 功能：展示发送方/接收方的消息气泡，左右布局区分
private class ChatBubbleCell_Somnia: UITableViewCell {

    private let bubbleView_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        return v
    }()

    private let messageLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.numberOfLines = 0
        return lbl
    }()

    private let timeLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        return lbl
    }()

    private let avatarView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        return iv
    }()

    private var bubbleLeading_Somnia: Constraint?
    private var bubbleTrailing_Somnia: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Somnia() {
        contentView.addSubview(avatarView_Somnia)
        contentView.addSubview(bubbleView_Somnia)
        bubbleView_Somnia.addSubview(messageLabel_Somnia)
        contentView.addSubview(timeLabel_Somnia)

        avatarView_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(36)
        }

        bubbleView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(timeLabel_Somnia.snp.top).offset(-4)
            make.width.lessThanOrEqualTo(260)
            bubbleLeading_Somnia = make.left.equalTo(avatarView_Somnia.snp.right).offset(8).constraint
            bubbleTrailing_Somnia = make.right.equalToSuperview().offset(-60).constraint
        }

        messageLabel_Somnia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(14)
        }

        timeLabel_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.left.equalTo(bubbleView_Somnia)
        }
    }

    /// 配置气泡单元格
    /// - Parameters:
    ///   - message_Somnia: 消息数据
    ///   - avatarPath_Somnia: 头像资源路径
    func configure_Somnia(message_Somnia: MessageModel_Somnia, avatarPath_Somnia: String?) {
        let isMine_Somnia = message_Somnia.isMine_Somnia == true
        messageLabel_Somnia.text = message_Somnia.content_Somnia
        timeLabel_Somnia.text = message_Somnia.time_Somnia

        if isMine_Somnia {
            // 自己发出的消息：右对齐，蓝紫渐变气泡
            bubbleView_Somnia.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia
            messageLabel_Somnia.textColor = .white
            avatarView_Somnia.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-8)
                make.right.equalToSuperview().offset(-16)
                make.width.height.equalTo(36)
            }
            bubbleView_Somnia.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalTo(timeLabel_Somnia.snp.top).offset(-4)
                make.width.lessThanOrEqualTo(260)
                make.right.equalTo(avatarView_Somnia.snp.left).offset(-8)
            }
            timeLabel_Somnia.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-6)
                make.right.equalTo(bubbleView_Somnia)
            }
        } else {
            // 对方消息：左对齐，白色气泡
            bubbleView_Somnia.backgroundColor = .white
            messageLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
            avatarView_Somnia.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-8)
                make.left.equalToSuperview().offset(16)
                make.width.height.equalTo(36)
            }
            bubbleView_Somnia.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalTo(timeLabel_Somnia.snp.top).offset(-4)
                make.width.lessThanOrEqualTo(260)
                make.left.equalTo(avatarView_Somnia.snp.right).offset(8)
            }
            timeLabel_Somnia.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-6)
                make.left.equalTo(bubbleView_Somnia)
            }
        }

        // 加载头像
        if let path_Somnia = avatarPath_Somnia, let img_Somnia = UIImage(named: path_Somnia) {
            avatarView_Somnia.image = img_Somnia
        } else {
            avatarView_Somnia.image = UIImage(systemName: "person.circle.fill")
            avatarView_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        }
    }
}
