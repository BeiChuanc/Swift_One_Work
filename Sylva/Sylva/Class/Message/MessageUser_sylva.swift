import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天页（视觉增强版）

/// 聊天视图控制器
/// 核心作用：与特定用户即时聊天，支持发消息、视频通话及拉黑举报
/// 设计思路：深绿渐变沉浸式导航栏 + 点阵纹理背景 + 渐变绿气泡 vs 白卡气泡 + 彩色输入栏
class MessageUser_Sylva: UIViewController {

    // MARK: - 公开属性

    var userModel_Sylva: PrewUserModel_Sylva?

    // MARK: - 私有属性

    /// 导航栏渐变区
    private let navBarView_Sylva = UIView()
    private let navGradient_Sylva = CAGradientLayer()

    /// 消息 TableView
    private var messageTableView_Sylva: UITableView!

    /// 底部输入栏
    private let inputBar_Sylva = UIView()
    private let messageInput_Sylva = UITextField()
    private let sendButton_Sylva = UIButton(type: .system)
    private let videoCallButton_Sylva = UIButton(type: .system)

    private var messages_Sylva: [MessageModel_Sylva] = []
    private var inputBarBottomConstraint_Sylva: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Sylva()
        setupNavBar_Sylva()
        setupInputBar_Sylva()         // 先布局输入栏，messageTableView 才能引用其 snp.top
        setupMessageTableView_Sylva()
        observeNotifications_Sylva()
        refreshMessages_Sylva()

        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sylva))
        tap_sylva.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_sylva)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGradient_Sylva.frame = navBarView_Sylva.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建聊天区背景（极淡绿点阵纹理）
    private func setupBackground_Sylva() {
        // 主背景色：极淡绿
        view.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")

        // 点阵装饰层（CAShapeLayer 绘制）
        let dotsLayer_sylva = CAShapeLayer()
        let dotsPath_sylva = UIBezierPath()
        let spacing_sylva: CGFloat = 22
        let dotRadius_sylva: CGFloat = 1.5
        let cols_sylva = Int(APPSCREEN_Sylva.WIDTH_Sylva / spacing_sylva) + 1
        let rows_sylva = Int(APPSCREEN_Sylva.HEIGHT_Sylva / spacing_sylva) + 1
        for row_sylva in 0..<rows_sylva {
            for col_sylva in 0..<cols_sylva {
                let x_sylva = CGFloat(col_sylva) * spacing_sylva
                let y_sylva = CGFloat(row_sylva) * spacing_sylva
                dotsPath_sylva.append(UIBezierPath(
                    ovalIn: CGRect(x: x_sylva, y: y_sylva, width: dotRadius_sylva * 2, height: dotRadius_sylva * 2)
                ))
            }
        }
        dotsLayer_sylva.path = dotsPath_sylva.cgPath
        dotsLayer_sylva.fillColor = UIColor(hexstring_Sylva: "#95D5B2").withAlphaComponent(0.35).cgColor
        view.layer.insertSublayer(dotsLayer_sylva, at: 0)
    }

    /// 搭建渐变导航栏（集成用户信息）
    private func setupNavBar_Sylva() {
        // 渐变：深绿 → 中绿
        navGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#40916C").cgColor
        ]
        navGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        navGradient_Sylva.endPoint = CGPoint(x: 1, y: 1)
        navBarView_Sylva.layer.insertSublayer(navGradient_Sylva, at: 0)

        // 底部圆角（仅底部两角）
        navBarView_Sylva.layer.cornerRadius = 20
        navBarView_Sylva.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navBarView_Sylva.clipsToBounds = true
        view.addSubview(navBarView_Sylva)
        navBarView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 固定 120pt 覆盖所有机型安全区（Dynamic Island ~59pt），确保内容在可见区下方
            make.height.equalTo(120)
        }

        // 返回按钮（白色半透明圆形）
        let backBtn_sylva = UIButton(type: .system)
        let backCfg_sylva = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backBtn_sylva.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_sylva), for: .normal)
        backBtn_sylva.tintColor = .white
        backBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backBtn_sylva.layer.cornerRadius = 18
        backBtn_sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        navBarView_Sylva.addSubview(backBtn_sylva)

        // 用户头像（白色边框圆形）
        let avatarView_sylva = UserAvatarView_Sylva()
        if let userId_sylva = userModel_Sylva?.userId_Sylva {
            avatarView_sylva.configure_Sylva(userId_Sylva: userId_sylva)
        }
        avatarView_sylva.layer.cornerRadius = 22
        avatarView_sylva.layer.masksToBounds = true
        avatarView_sylva.layer.borderWidth = 2.5
        avatarView_sylva.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        navBarView_Sylva.addSubview(avatarView_sylva)

        // 用户名（白色，居中显示）
        let nameLabel_sylva = UILabel()
        nameLabel_sylva.text = userModel_Sylva?.userName_Sylva ?? "Chat"
        nameLabel_sylva.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        nameLabel_sylva.textColor = .white
        navBarView_Sylva.addSubview(nameLabel_sylva)

        // 视频通话按钮（白色半透明圆形）
        let videoBtn_sylva = UIButton(type: .system)
        let videoCfg_sylva = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        videoBtn_sylva.setImage(UIImage(systemName: "video.fill", withConfiguration: videoCfg_sylva), for: .normal)
        videoBtn_sylva.tintColor = .white
        videoBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        videoBtn_sylva.layer.cornerRadius = 18
        videoBtn_sylva.addTarget(self, action: #selector(videoCallTapped_Sylva), for: .touchUpInside)
        navBarView_Sylva.addSubview(videoBtn_sylva)

        // 举报按钮（白色半透明圆形）
        let reportBtn_sylva = UIButton(type: .system)
        let reportCfg_sylva = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        reportBtn_sylva.setImage(UIImage(systemName: "ellipsis", withConfiguration: reportCfg_sylva), for: .normal)
        reportBtn_sylva.tintColor = .white
        reportBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        reportBtn_sylva.layer.cornerRadius = 18
        reportBtn_sylva.addAction(UIAction { [weak self] _ in
            guard let self_sylva = self, let user_sylva = self_sylva.userModel_Sylva else { return }
            ReportDeleteHelper_Sylva.block_Sylva(user_Sylva: user_sylva, from: self_sylva) {
                Navigation_Sylva.popToSafeStateAfterBlock_Sylva(from: self_sylva)
            }
        }, for: .touchUpInside)
        navBarView_Sylva.addSubview(reportBtn_sylva)

        // 统一约束（所有视图已加入 navBarView）
        backBtn_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(36)
        }
        avatarView_sylva.snp.makeConstraints { make in
            make.leading.equalTo(backBtn_sylva.snp.trailing).offset(10)
            make.centerY.equalTo(backBtn_sylva)
            make.width.height.equalTo(44)
        }
        nameLabel_sylva.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_sylva.snp.trailing).offset(10)
            make.centerY.equalTo(avatarView_sylva)
        }
        reportBtn_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(backBtn_sylva)
            make.width.height.equalTo(36)
        }
        videoBtn_sylva.snp.makeConstraints { make in
            make.trailing.equalTo(reportBtn_sylva.snp.leading).offset(-10)
            make.centerY.equalTo(backBtn_sylva)
            make.width.height.equalTo(36)
        }

        // 点击头像进入用户主页
        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Sylva))
        avatarView_sylva.isUserInteractionEnabled = true
        avatarView_sylva.addGestureRecognizer(tap_sylva)
    }

    private func setupMessageTableView_Sylva() {
        messageTableView_Sylva = UITableView()
        messageTableView_Sylva.backgroundColor = .clear
        messageTableView_Sylva.separatorStyle = .none
        messageTableView_Sylva.dataSource = self
        messageTableView_Sylva.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        messageTableView_Sylva.register(
            MessageBubbleCell_Sylva.self,
            forCellReuseIdentifier: MessageBubbleCell_Sylva.reuseId_Sylva
        )
        view.addSubview(messageTableView_Sylva)
        messageTableView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Sylva.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Sylva.snp.top)
        }
    }

    private func setupInputBar_Sylva() {
        // 毛玻璃效果底部栏
        inputBar_Sylva.backgroundColor = .white
        inputBar_Sylva.layer.shadowColor = UIColor.black.cgColor
        inputBar_Sylva.layer.shadowOpacity = 0.1
        inputBar_Sylva.layer.shadowRadius = 12
        inputBar_Sylva.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.addSubview(inputBar_Sylva)
        inputBar_Sylva.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            // safeAreaInsets.bottom 在 viewDidLoad 时为 0，改用 safeAreaLayoutGuide 锚定底部即可
            make.height.equalTo(64)
            inputBarBottomConstraint_Sylva = make.bottom.equalTo(view.snp.bottom).constraint
        }

        // 输入框（圆角胶囊，淡绿背景）
        messageInput_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        messageInput_Sylva.layer.cornerRadius = 20
        messageInput_Sylva.layer.borderWidth = 1.5
        messageInput_Sylva.layer.borderColor = UIColor(hexstring_Sylva: "#95D5B2").cgColor
        messageInput_Sylva.font = UIFont.systemFont(ofSize: 15)
        messageInput_Sylva.setPlaceholder_Sylva(
            placeholder_Sylva: "Type a message...",
            color_Sylva: ColorConfig_Sylva.textPlaceholder_Sylva
        )
        messageInput_Sylva.setLeftPadding_Sylva(padding_Sylva: 16)
        messageInput_Sylva.setRightPadding_Sylva(padding_Sylva: 12)
        messageInput_Sylva.returnKeyType = .send
        messageInput_Sylva.delegate = self
        inputBar_Sylva.addSubview(messageInput_Sylva)

        // 发送按钮（深绿圆形，带阴影光晕）
        let sendCfg_sylva = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        sendButton_Sylva.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: sendCfg_sylva), for: .normal)
        sendButton_Sylva.tintColor = .white
        sendButton_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
        sendButton_Sylva.layer.cornerRadius = 20
        sendButton_Sylva.layer.shadowColor = UIColor(hexstring_Sylva: "#40916C").cgColor
        sendButton_Sylva.layer.shadowOpacity = 0.45
        sendButton_Sylva.layer.shadowRadius = 8
        sendButton_Sylva.layer.shadowOffset = CGSize(width: 0, height: 4)
        sendButton_Sylva.addTarget(self, action: #selector(sendTapped_Sylva), for: .touchUpInside)
        inputBar_Sylva.addSubview(sendButton_Sylva)

        // 统一约束（视频通话按钮已移除，输入框从左侧 16pt 开始）
        sendButton_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(40)
        }
        messageInput_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton_Sylva.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(40)
        }
    }

    // MARK: - 数据

    private func refreshMessages_Sylva() {
        guard let userId_sylva = userModel_Sylva?.userId_Sylva else { return }
        messages_Sylva = MessageViewModel_Sylva.shared_Sylva.getMessagesWithUser_Sylva(userId_sylva: userId_sylva)
        messageTableView_Sylva.reloadData()
        scrollToBottom_Sylva()
    }

    private func scrollToBottom_Sylva() {
        guard messages_Sylva.count > 0 else { return }
        messageTableView_Sylva.scrollToRow(
            at: IndexPath(row: messages_Sylva.count - 1, section: 0),
            at: .bottom, animated: true
        )
    }

    // MARK: - 通知

    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onMessageStateChanged_Sylva),
            name: MessageViewModel_Sylva.messageStateDidChangeNotification_Sylva, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Sylva(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Sylva(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func onMessageStateChanged_Sylva() { refreshMessages_Sylva() }

    @objc private func keyboardWillShow_Sylva(_ notification: Notification) {
        guard let info_sylva = notification.userInfo,
              let frame_sylva = info_sylva[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_sylva = info_sylva[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        inputBarBottomConstraint_Sylva?.update(offset: -frame_sylva.height)
        UIView.animate(withDuration: duration_sylva) { self.view.layoutIfNeeded() }
        scrollToBottom_Sylva()
    }

    @objc private func keyboardWillHide_Sylva(_ notification: Notification) {
        guard let duration_sylva = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        inputBarBottomConstraint_Sylva?.update(offset: 0)
        UIView.animate(withDuration: duration_sylva) { self.view.layoutIfNeeded() }
    }

    @objc private func dismissKeyboard_Sylva() { view.endEditing(true) }

    // MARK: - 事件

    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func avatarTapped_Sylva() {
        guard let user_sylva = userModel_Sylva else { return }
        let vc_sylva = UserInfo_Sylva()
        vc_sylva.userModel_Sylva = user_sylva
        vc_sylva.showMessageButton_Sylva = false
        vc_sylva.fromMessage_Sylva = true
        navigationController?.pushViewController(vc_sylva, animated: true)
    }

    @objc private func sendTapped_Sylva() {
        let text_sylva = messageInput_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_sylva.isEmpty, let userId_sylva = userModel_Sylva?.userId_Sylva else { return }
        sendButton_Sylva.animatePulse_Sylva()
        messageInput_Sylva.text = ""
        MessageViewModel_Sylva.shared_Sylva.sendMessage_Sylva(
            message_sylva: text_sylva,
            chatType_sylva: .personal_sylva,
            id_sylva: userId_sylva
        )
    }

    @objc private func videoCallTapped_Sylva() {
        guard let user_sylva = userModel_Sylva else { return }
        videoCallButton_Sylva.animatePulse_Sylva()
        let vc_sylva = VideoChat_Sylva()
        vc_sylva.userModel_Sylva = user_sylva
        vc_sylva.modalPresentationStyle = .fullScreen
        present(vc_sylva, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MessageUser_Sylva: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Sylva.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_sylva = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell_Sylva.reuseId_Sylva, for: indexPath
        ) as? MessageBubbleCell_Sylva else { return UITableViewCell() }
        cell_sylva.configure_Sylva(
            message_sylva: messages_Sylva[indexPath.row],
            partnerUser_sylva: userModel_Sylva
        )
        return cell_sylva
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Sylva: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Sylva()
        return true
    }
}

// MARK: - 消息气泡 Cell

/// 消息气泡单元格
/// 核心作用：我方绿色渐变气泡（右对齐）vs 对方白色卡片气泡（左对齐）
/// 设计思路：渐变绿气泡带光晕阴影；白色气泡带细边框轻阴影；时间内嵌底部半透明
class MessageBubbleCell_Sylva: UITableViewCell {

    static let reuseId_Sylva = "MessageBubbleCell_Sylva"

    private let bubbleView_Sylva = UIView()
    /// 我方气泡渐变层
    private let bubbleGradient_Sylva = CAGradientLayer()
    private let messageLabel_Sylva = UILabel()
    private let timeLabel_Sylva = UILabel()
    private let avatarView_Sylva = UserAvatarView_Sylva()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Sylva()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 渐变层 frame 跟随气泡尺寸更新
        bubbleGradient_Sylva.frame = bubbleView_Sylva.bounds
        bubbleGradient_Sylva.cornerRadius = bubbleView_Sylva.layer.cornerRadius
    }

    private func setupUI_Sylva() {
        // 头像
        avatarView_Sylva.layer.cornerRadius = 17
        avatarView_Sylva.layer.masksToBounds = true
        contentView.addSubview(avatarView_Sylva)
        avatarView_Sylva.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.width.height.equalTo(34)
        }

        // 气泡视图
        bubbleView_Sylva.layer.cornerRadius = 20
        contentView.addSubview(bubbleView_Sylva)

        // 渐变层（我方使用，对方隐藏）
        bubbleGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        bubbleGradient_Sylva.endPoint = CGPoint(x: 1, y: 1)
        bubbleGradient_Sylva.cornerRadius = 20
        bubbleView_Sylva.layer.insertSublayer(bubbleGradient_Sylva, at: 0)

        // 消息文字
        messageLabel_Sylva.numberOfLines = 0
        messageLabel_Sylva.font = UIFont.systemFont(ofSize: 15)
        bubbleView_Sylva.addSubview(messageLabel_Sylva)

        // 时间
        timeLabel_Sylva.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        bubbleView_Sylva.addSubview(timeLabel_Sylva)

        // 内部约束
        messageLabel_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.width.lessThanOrEqualTo(APPSCREEN_Sylva.WIDTH_Sylva * 0.62)
        }
        timeLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(messageLabel_Sylva.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configure_Sylva(message_sylva: MessageModel_Sylva, partnerUser_sylva: PrewUserModel_Sylva?) {
        let isMine_sylva = message_sylva.isMine_Sylva ?? true
        messageLabel_Sylva.text = message_sylva.content_Sylva
        timeLabel_Sylva.text = message_sylva.time_Sylva

        if isMine_sylva {
            // 我方：右对齐，深绿渐变气泡
            let currentUser_sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
            avatarView_Sylva.configure_Sylva(userId_Sylva: currentUser_sylva.userId_Sylva ?? 0)

            // 渐变绿色
            bubbleGradient_Sylva.colors = [
                UIColor(hexstring_Sylva: "#52B788").cgColor,
                UIColor(hexstring_Sylva: "#1B4332").cgColor
            ]
            bubbleGradient_Sylva.isHidden = false
            bubbleView_Sylva.backgroundColor = .clear
            bubbleView_Sylva.layer.borderWidth = 0
            bubbleView_Sylva.layer.shadowColor = UIColor(hexstring_Sylva: "#40916C").cgColor
            bubbleView_Sylva.layer.shadowOpacity = 0.3
            bubbleView_Sylva.layer.shadowRadius = 8
            bubbleView_Sylva.layer.shadowOffset = CGSize(width: 0, height: 4)

            messageLabel_Sylva.textColor = .white
            timeLabel_Sylva.textColor = UIColor.white.withAlphaComponent(0.6)

            avatarView_Sylva.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().offset(-10)
                make.bottom.equalToSuperview().offset(-6)
                make.width.height.equalTo(34)
            }
            bubbleView_Sylva.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
                make.trailing.equalTo(avatarView_Sylva.snp.leading).offset(-8)
            }
        } else {
            // 对方：左对齐，白色卡片气泡
            avatarView_Sylva.configure_Sylva(userId_Sylva: partnerUser_sylva?.userId_Sylva ?? 0)

            bubbleGradient_Sylva.isHidden = true
            bubbleView_Sylva.backgroundColor = .white
            bubbleView_Sylva.layer.borderWidth = 1
            bubbleView_Sylva.layer.borderColor = UIColor(hexstring_Sylva: "#E2E8F0").cgColor
            bubbleView_Sylva.layer.shadowColor = UIColor.black.cgColor
            bubbleView_Sylva.layer.shadowOpacity = 0.06
            bubbleView_Sylva.layer.shadowRadius = 6
            bubbleView_Sylva.layer.shadowOffset = CGSize(width: 0, height: 2)

            messageLabel_Sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
            timeLabel_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva

            avatarView_Sylva.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-6)
                make.width.height.equalTo(34)
            }
            bubbleView_Sylva.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
                make.leading.equalTo(avatarView_Sylva.snp.trailing).offset(8)
            }
        }
    }
}
