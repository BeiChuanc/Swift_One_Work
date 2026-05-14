import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天页面

/// 与用户聊天页面
/// 核心功能：单对单文字聊天，支持发送消息、视频通话入口、用户信息卡片跳转、举报用户
/// 设计思路：
///   - 顶部固定卡片展示聊天对象信息，点击可进入用户中心（isFromChat=true）
///   - 右上角举报按钮（ReportDeleteHelper）
///   - 中间消息列表（TableView），自动滚到底部
///   - 底部输入栏：文本框 + 视频通话按钮 + 发送按钮
/// 关键属性：
///   - userModel_Clara: 当前聊天的用户模型
/// 关键方法：
///   - sendMessage_Clara: 读取输入框文字 → 调用 MessageViewModel → 滚动到底部
///   - navigateToUserInfo_Clara: 进入用户中心（标记 isFromChat=true）
class MessageUser_Clara: UIViewController {

    // MARK: - 属性

    var userModel_Clara: PrewUserModel_Clara?

    // MARK: - UI 组件

    // 顶部用户信息卡片
    private let userCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        v.isUserInteractionEnabled = true
        return v
    }()

    private let cardAvatarView_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    private let cardNameLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Clara.textPrimary_Clara
        return l
    }()

    private let cardBioLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        l.numberOfLines = 1
        return l
    }()

    private let cardChevron_Clara: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = ColorConfig_Clara.textPlaceholder_Clara
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // 消息列表
    private let tableView_Clara: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(MsgBubbleCell_Clara.self, forCellReuseIdentifier: MsgBubbleCell_Clara.reuseId_Clara)
        tv.keyboardDismissMode = .interactive
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 18, right: 0)
        return tv
    }()

    // 底部输入栏容器
    private let inputBar_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let inputPanel_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 24
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        return v
    }()

    private let inputField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.rightViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()

    private let sendButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        return btn
    }()

    private let emptyStateView_Clara: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // 底部安全区占位（适配有 Home 键的设备）
    private let inputBarBottomSpacer_Clara = UIView()
    private var inputBarBottomConstraint_Clara: Constraint?

    // MARK: - 数据

    private var messages_Clara: [MessageModel_Clara] = []

    // MARK: - 生命周期

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateThemeBackgroundFrame_Clara()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        refreshMessages_Clara()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupNavigationBar_Clara()
        setupUserCard_Clara()
        setupTableView_Clara()
        setupEmptyState_Clara()
        setupInputBar_Clara()
        setupNotifications_Clara()
        setupKeyboardObservers_Clara()
        loadUserInfo_Clara()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom_Clara(animated: false)
    }

    // MARK: - 导航栏

    private func setupNavigationBar_Clara() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Clara)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Clara.textPrimary_Clara

        // 右侧举报按钮
        let reportBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        reportBtn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        reportBtn.tintColor = ColorConfig_Clara.textSecondary_Clara
        reportBtn.addTarget(self, action: #selector(reportTapped_Clara), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportBtn)
    }

    // MARK: - UI 搭建

    /// 搭建顶部用户信息卡片（卡片式展示，点击进入用户中心）
    private func setupUserCard_Clara() {
        view.addSubview(userCard_Clara)
        userCard_Clara.layer.cornerRadius = 22
        userCard_Clara.layer.borderWidth = 1
        userCard_Clara.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        userCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(76)
        }

        userCard_Clara.addSubview(cardAvatarView_Clara)
        cardAvatarView_Clara.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        userCard_Clara.addSubview(cardChevron_Clara)
        cardChevron_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let textStack = UIStackView(arrangedSubviews: [cardNameLabel_Clara, cardBioLabel_Clara])
        textStack.axis = .vertical
        textStack.spacing = 3
        userCard_Clara.addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.left.equalTo(cardAvatarView_Clara.snp.right).offset(12)
            make.right.equalTo(cardChevron_Clara.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Clara))
        userCard_Clara.addGestureRecognizer(tap)
    }

    /// 搭建消息列表
    private func setupTableView_Clara() {
        view.addSubview(tableView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        tableView_Clara.backgroundColor = .clear
        tableView_Clara.snp.makeConstraints { make in
            make.top.equalTo(userCard_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        tableView_Clara.delegate = self
        tableView_Clara.dataSource = self
    }

    /// 搭建消息空态视图
    private func setupEmptyState_Clara() {
        view.addSubview(emptyStateView_Clara)
        emptyStateView_Clara.snp.makeConstraints { make in
            make.center.equalTo(tableView_Clara)
            make.width.equalTo(240)
        }

        let iconBg = UIView()
        iconBg.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.10)
        iconBg.layer.cornerRadius = 46
        emptyStateView_Clara.addSubview(iconBg)
        iconBg.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }

        let icon = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        icon.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg)
        icon.tintColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.55)
        iconBg.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }

        let titleLabel = UILabel()
        titleLabel.text = "No Messages Yet"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLabel.textAlignment = .center
        emptyStateView_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBg.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }

        let subLabel = UILabel()
        subLabel.text = "Say hello and start the conversation"
        subLabel.font = UIFont.systemFont(ofSize: 13)
        subLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        subLabel.textAlignment = .center
        emptyStateView_Clara.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }

    /// 搭建底部输入栏
    private func setupInputBar_Clara() {
        view.addSubview(inputBar_Clara)
        inputBar_Clara.snp.makeConstraints { make in
            make.top.equalTo(tableView_Clara.snp.bottom)
            make.left.right.equalToSuperview()
            inputBarBottomConstraint_Clara = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
        }

        let divider = UIView()
        divider.backgroundColor = ColorConfig_Clara.divider_Clara
        inputBar_Clara.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        inputBar_Clara.addSubview(inputPanel_Clara)
        inputPanel_Clara.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(10)
        }

        inputPanel_Clara.addSubview(sendButton_Clara)
        sendButton_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        sendButton_Clara.addTarget(self, action: #selector(sendTapped_Clara), for: .touchUpInside)

        inputPanel_Clara.addSubview(inputField_Clara)
        inputField_Clara.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(sendButton_Clara.snp.left).offset(-8)
            make.top.bottom.equalToSuperview().inset(10)
        }
        inputField_Clara.delegate = self
    }

    // MARK: - 数据加载

    private func loadUserInfo_Clara() {
        guard let user = userModel_Clara, let uid = user.userId_Clara else { return }
        cardAvatarView_Clara.configure_Clara(userId_Clara: uid)
        cardNameLabel_Clara.text = user.userName_Clara ?? "User"
        cardBioLabel_Clara.text = user.userIntroduce_Clara ?? "Tap to view profile details"
    }

    private func refreshMessages_Clara() {
        guard let user = userModel_Clara, let uid = user.userId_Clara else { return }
        messages_Clara = MessageViewModel_Clara.shared_Clara.getMessagesWithUser_Clara(userId_clara: uid)
        emptyStateView_Clara.isHidden = !messages_Clara.isEmpty
        tableView_Clara.isHidden = messages_Clara.isEmpty
        tableView_Clara.reloadData()
        scrollToBottom_Clara(animated: false)
    }

    /// 滚动到消息列表底部
    private func scrollToBottom_Clara(animated: Bool) {
        guard !messages_Clara.isEmpty else { return }
        let indexPath = IndexPath(row: messages_Clara.count - 1, section: 0)
        tableView_Clara.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    // MARK: - 通知

    private func setupNotifications_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageChange_Clara),
            name: MessageViewModel_Clara.messageStateDidChangeNotification_Clara,
            object: nil
        )
    }

    @objc private func handleMessageChange_Clara() {
        refreshMessages_Clara()
        scrollToBottom_Clara(animated: true)
    }

    // MARK: - 键盘监听

    private func setupKeyboardObservers_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange_Clara(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChange_Clara(_ notification: Notification) {
        guard let info = notification.userInfo,
              let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }

        let keyboardHeight = max(0, view.frame.height - endFrame.origin.y)
        let safeBottom = view.safeAreaInsets.bottom
        let offset = keyboardHeight > 0 ? keyboardHeight - safeBottom : 0

        inputBarBottomConstraint_Clara?.update(offset: -offset)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        if keyboardHeight > 0 {
            scrollToBottom_Clara(animated: true)
        }
    }

    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    /// 点击用户卡片进入用户中心（isFromChat = true）
    @objc private func cardTapped_Clara() {
        guard let user = userModel_Clara else { return }
        let userInfoVC = UserInfo_Clara()
        userInfoVC.userModel_Clara = user
        userInfoVC.isFromChat_Clara = true
        Navigation_Clara.push_Clara(to: userInfoVC)
    }

    /// 发送消息
    @objc private func sendTapped_Clara() {
        guard let uid = userModel_Clara?.userId_Clara else { return }
        let text = inputField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        inputField_Clara.text = ""
        MessageViewModel_Clara.shared_Clara.sendMessage_Clara(
            message_clara: text,
            chatType_clara: .personal_clara,
            id_clara: uid
        )
    }

    /// 举报用户
    @objc private func reportTapped_Clara() {
        guard let user = userModel_Clara else { return }
        ReportDeleteHelper_Clara.block_Clara(user_Clara: user, from: self) { [weak self] in
            guard let self = self else { return }
            Navigation_Clara.popToSafeStateAfterBlock_Clara(from: self)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableView 代理

extension MessageUser_Clara: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Clara.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MsgBubbleCell_Clara.reuseId_Clara,
            for: indexPath
        ) as! MsgBubbleCell_Clara
        cell.configure_Clara(message_Clara: messages_Clara[indexPath.row], chatUser_Clara: userModel_Clara)
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Clara: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Clara()
        return true
    }
}

// MARK: - 消息气泡 Cell

/// 消息气泡单元格
/// 功能：根据 isMine 区分左侧（对方）/ 右侧（自己）气泡，展示消息内容和时间
class MsgBubbleCell_Clara: UITableViewCell {

    static let reuseId_Clara = "MsgBubbleCell_Clara"

    // MARK: - UI

    private let avatarView_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let bubbleView_Clara: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = false
        return v
    }()

    private let messageLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.numberOfLines = 0
        return l
    }()

    private let timeLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        return l
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Clara()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Clara() {
        contentView.addSubview(avatarView_Clara)
        contentView.addSubview(bubbleView_Clara)
        bubbleView_Clara.addSubview(messageLabel_Clara)
        contentView.addSubview(timeLabel_Clara)

        messageLabel_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }

    /// 配置气泡（isMine 决定左右对齐与颜色）
    func configure_Clara(message_Clara: MessageModel_Clara, chatUser_Clara: PrewUserModel_Clara?) {
        let isMine = message_Clara.isMine_Clara ?? false
        let text = message_Clara.content_Clara ?? ""
        timeLabel_Clara.text = message_Clara.time_Clara ?? ""

        messageLabel_Clara.text = text

        // 重置约束
        avatarView_Clara.snp.removeConstraints()
        bubbleView_Clara.snp.removeConstraints()
        timeLabel_Clara.snp.removeConstraints()
        messageLabel_Clara.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }

        if isMine {
            // 右侧（自己）：高亮主色气泡
            bubbleView_Clara.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
            messageLabel_Clara.textColor = .white
            avatarView_Clara.isHidden = true
            bubbleView_Clara.layer.shadowColor = ColorConfig_Clara.primaryGradientStart_Clara.cgColor
            bubbleView_Clara.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Clara.layer.shadowOpacity = 0.32
            bubbleView_Clara.layer.shadowRadius = 8

            bubbleView_Clara.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.bottom.equalToSuperview().inset(6)
                make.right.equalToSuperview().inset(16)
                make.left.greaterThanOrEqualToSuperview().offset(60)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.68)
            }
            timeLabel_Clara.snp.makeConstraints { make in
                make.right.equalTo(bubbleView_Clara.snp.right)
                make.top.equalTo(bubbleView_Clara.snp.bottom).offset(2)
                make.bottom.equalToSuperview().inset(2)
            }
        } else {
            // 左侧（对方）：白色卡片气泡
            bubbleView_Clara.backgroundColor = ColorConfig_Clara.cardBackground_Clara.withAlphaComponent(0.94)
            messageLabel_Clara.textColor = ColorConfig_Clara.textPrimary_Clara
            avatarView_Clara.isHidden = false
            bubbleView_Clara.layer.borderWidth = 1
            bubbleView_Clara.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor

            if let uid = chatUser_Clara?.userId_Clara {
                avatarView_Clara.configure_Clara(userId_Clara: uid)
            }
            avatarView_Clara.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(12)
                make.top.equalToSuperview().offset(6)
                make.width.height.equalTo(32)
            }
            bubbleView_Clara.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.bottom.equalToSuperview().inset(6)
                make.left.equalTo(avatarView_Clara.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().inset(60)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.68)
            }
            // 气泡添加轻阴影
            bubbleView_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
            bubbleView_Clara.layer.shadowOffset = CGSize(width: 0, height: 1)
            bubbleView_Clara.layer.shadowOpacity = 1
            bubbleView_Clara.layer.shadowRadius = 4

            timeLabel_Clara.snp.makeConstraints { make in
                make.left.equalTo(bubbleView_Clara.snp.left)
                make.top.equalTo(bubbleView_Clara.snp.bottom).offset(2)
                make.bottom.equalToSuperview().inset(2)
            }
        }
    }
}
