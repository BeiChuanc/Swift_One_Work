import Foundation
import UIKit
import SnapKit

// MARK: 用户聊天界面 - 重构版

/// 与用户聊天控制器
/// 核心作用：展示对方用户信息，支持发送文字消息、视频通话、举报，实时更新消息列表
/// 设计思路：渐变头部（头像 + 昵称 + 简介）+ 消息气泡列表 + 底部输入工具栏
class MessageUser_Retrs: UIViewController {

    // MARK: - 属性

    var userModel_Retrs: PrewUserModel_Retrs?

    private let messageVM_Retrs = MessageViewModel_Retrs.shared_Retrs
    private let userVM_Retrs    = UserViewModel_Retrs.shared_Retrs

    private var messages_Retrs: [MessageModel_Retrs] = []

    /// 渐变头部卡
    private let headerCard_Retrs      = UIView()
    private let headerGradLayer_Retrs = CAGradientLayer()
    private let backBtn_Retrs         = UIButton(type: .system)
    private let reportBtn_Retrs: UIButton = ReportDeleteHelper_Retrs.createUserReportButton_Retrs(
        size_Retrs: 32, tintColor_Retrs: .white, withShadow_Retrs: false
    )
    private let avatarRingView_Retrs  = MsgUserGradRing_Retrs()
    private let avatarView_Retrs      = UserAvatarView_Retrs()
    private let nameLabel_Retrs       = UILabel()
    private let introLabel_Retrs      = UILabel()
    private let onlineDot_Retrs       = UIView()

    /// 消息列表
    private let tableView_Retrs = UITableView()

    /// 底部输入工具栏
    private let inputBar_Retrs   = UIView()
    private let inputWrap_Retrs  = UIView()
    private let inputField_Retrs = UITextField()
    private let sendBtn_Retrs    = UIButton(type: .system)
    private let sendGradLayer_Retrs   = CAGradientLayer()
    private let videoBtn_Retrs   = UIButton(type: .system)
    private var inputBarBottomConstraint_Retrs: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Retrs: "#F3F0FA")
        setupHeaderCard_Retrs()
        setupTableView_Retrs()
        setupInputBar_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        reloadMessages_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        tableView_Retrs.addGestureRecognizer(tap_Retrs)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMessages_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerCard_Retrs.bounds
        sendGradLayer_Retrs.frame   = sendBtn_Retrs.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 渐变头部卡

    private func setupHeaderCard_Retrs() {
        // 渐变（比主页更柔和：加深透明度）
        headerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.9).cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.withAlphaComponent(0.85).cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerCard_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerCard_Retrs.layer.cornerRadius = 24
        headerCard_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerCard_Retrs.clipsToBounds = true
        view.addSubview(headerCard_Retrs)

        // 返回按钮（半透明白色圆形）
        backBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_Retrs.layer.cornerRadius = 17
        backBtn_Retrs.layer.borderWidth  = 1
        backBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        backBtn_Retrs.setImage(
            UIImage(systemName: "arrow.left",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)),
            for: .normal
        )
        backBtn_Retrs.tintColor = .white
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        headerCard_Retrs.addSubview(backBtn_Retrs)

        // 举报按钮（半透明白色圆形）
        reportBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        reportBtn_Retrs.layer.cornerRadius = 17
        reportBtn_Retrs.layer.borderWidth  = 1
        reportBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        reportBtn_Retrs.addTarget(self, action: #selector(reportTapped_Retrs), for: .touchUpInside)
        headerCard_Retrs.addSubview(reportBtn_Retrs)

        // 渐变圆环头像
        headerCard_Retrs.addSubview(avatarRingView_Retrs)
        headerCard_Retrs.addSubview(avatarView_Retrs)
        avatarView_Retrs.layer.cornerRadius = 26
        avatarView_Retrs.clipsToBounds = true
        let avatarTap_Retrs = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Retrs))
        avatarView_Retrs.addGestureRecognizer(avatarTap_Retrs)
        avatarView_Retrs.isUserInteractionEnabled = true

        // 在线绿点
        onlineDot_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#68D391")
        onlineDot_Retrs.layer.cornerRadius = 5
        onlineDot_Retrs.layer.borderWidth  = 2
        onlineDot_Retrs.layer.borderColor  = UIColor.white.cgColor
        headerCard_Retrs.addSubview(onlineDot_Retrs)

        // 昵称
        nameLabel_Retrs.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel_Retrs.textColor = .white
        headerCard_Retrs.addSubview(nameLabel_Retrs)

        // 简介
        introLabel_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        introLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.78)
        introLabel_Retrs.numberOfLines = 1
        headerCard_Retrs.addSubview(introLabel_Retrs)
    }

    // MARK: - 消息列表

    private func setupTableView_Retrs() {
        tableView_Retrs.backgroundColor = .clear
        tableView_Retrs.separatorStyle  = .none
        tableView_Retrs.register(MsgBubbleCell_Retrs.self, forCellReuseIdentifier: "MsgBubbleCell_Retrs")
        tableView_Retrs.dataSource = self
        tableView_Retrs.delegate   = self
        view.addSubview(tableView_Retrs)
    }

    // MARK: - 底部输入工具栏

    private func setupInputBar_Retrs() {
        inputBar_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        inputBar_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        inputBar_Retrs.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputBar_Retrs.layer.shadowOpacity = 1
        inputBar_Retrs.layer.shadowRadius  = 8
        view.addSubview(inputBar_Retrs)

        // 视频通话按钮（渐变圆形背景）
        let videoBg_Retrs = UIView()
        videoBg_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.1)
        videoBg_Retrs.layer.cornerRadius = 18
        inputBar_Retrs.addSubview(videoBg_Retrs)
        videoBtn_Retrs.setImage(
            UIImage(systemName: "video.fill",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)),
            for: .normal
        )
        videoBtn_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        videoBtn_Retrs.addTarget(self, action: #selector(videoCallTapped_Retrs), for: .touchUpInside)
        videoBg_Retrs.addSubview(videoBtn_Retrs)
        videoBtn_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
        videoBg_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        // 输入框容器（浅紫背景）
        inputWrap_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        inputWrap_Retrs.layer.cornerRadius = 20
        inputBar_Retrs.addSubview(inputWrap_Retrs)

        inputField_Retrs.placeholder = "Type a message..."
        inputField_Retrs.font = UIFont.systemFont(ofSize: 14)
        inputField_Retrs.backgroundColor = .clear
        inputField_Retrs.returnKeyType = .send
        inputField_Retrs.delegate = self
        let lp_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 40))
        inputField_Retrs.leftView = lp_Retrs
        inputField_Retrs.leftViewMode = .always
        inputWrap_Retrs.addSubview(inputField_Retrs)
        inputField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 渐变发送按钮
        sendGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        sendGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        sendGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        sendGradLayer_Retrs.cornerRadius = 18
        sendBtn_Retrs.layer.insertSublayer(sendGradLayer_Retrs, at: 0)
        sendBtn_Retrs.layer.cornerRadius = 18
        sendBtn_Retrs.clipsToBounds = true
        let sendIconIV_Retrs = UIImageView(
            image: UIImage(systemName: "paperplane.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        )
        sendIconIV_Retrs.tintColor = .white
        sendIconIV_Retrs.contentMode = .scaleAspectFit
        sendIconIV_Retrs.isUserInteractionEnabled = false
        sendBtn_Retrs.addSubview(sendIconIV_Retrs)
        sendIconIV_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        sendBtn_Retrs.addTarget(self, action: #selector(sendTapped_Retrs), for: .touchUpInside)
        inputBar_Retrs.addSubview(sendBtn_Retrs)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        headerCard_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop_Retrs + 72)
        }
        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(34)
        }
        reportBtn_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(34)
        }
        avatarRingView_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.leading.equalTo(backBtn_Retrs.snp.trailing).offset(10)
            make.width.height.equalTo(54)
        }
        avatarView_Retrs.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Retrs)
            make.width.height.equalTo(46)
        }
        onlineDot_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.trailing.equalTo(avatarRingView_Retrs).offset(1)
            make.bottom.equalTo(avatarRingView_Retrs).offset(1)
        }
        nameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Retrs)
            make.leading.equalTo(avatarRingView_Retrs.snp.trailing).offset(10)
            make.trailing.equalTo(reportBtn_Retrs.snp.leading).offset(-8)
        }
        introLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Retrs.snp.bottom).offset(3)
            make.leading.equalTo(nameLabel_Retrs)
            make.trailing.equalTo(nameLabel_Retrs)
        }

        tableView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Retrs.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Retrs.snp.top)
        }

        inputBar_Retrs.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(68)
            inputBarBottomConstraint_Retrs = make.bottom.equalToSuperview().constraint
        }
        sendBtn_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        inputWrap_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalTo(sendBtn_Retrs.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    // MARK: - 数据

    private func fillUserInfo_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        avatarView_Retrs.configure_Retrs(userId_Retrs: user_Retrs.userId_Retrs ?? 0)
        nameLabel_Retrs.text  = user_Retrs.userName_Retrs ?? ""
        introLabel_Retrs.text = user_Retrs.userIntroduce_Retrs ?? "CCD Photography Enthusiast"
    }

    private func reloadMessages_Retrs() {
        fillUserInfo_Retrs()
        guard let uid_Retrs = userModel_Retrs?.userId_Retrs else { return }
        messages_Retrs = messageVM_Retrs.getMessagesWithUser_Retrs(userId_retrs: uid_Retrs)
        tableView_Retrs.reloadData()
        scrollToBottom_Retrs()
    }

    private func scrollToBottom_Retrs() {
        guard messages_Retrs.count > 0 else { return }
        tableView_Retrs.scrollToRow(at: IndexPath(row: messages_Retrs.count - 1, section: 0),
                                    at: .bottom, animated: true)
    }

    // MARK: - 通知

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(self, selector: #selector(onMsgChange_Retrs),
            name: MessageViewModel_Retrs.messageStateDidChangeNotification_Retrs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Retrs(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Retrs(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func onMsgChange_Retrs() { reloadMessages_Retrs() }

    @objc private func keyboardWillShow_Retrs(_ notification: Notification) {
        guard let frame_Retrs = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        inputBarBottomConstraint_Retrs?.update(offset: -frame_Retrs.height)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Retrs(_ notification: Notification) {
        inputBarBottomConstraint_Retrs?.update(offset: 0)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件

    @objc private func backTapped_Retrs()     { Navigation_Retrs.pop_Retrs() }
    @objc private func dismissKeyboard_Retrs() { view.endEditing(true) }

    @objc private func avatarTapped_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        let vc_Retrs = UserInfo_Retrs()
        vc_Retrs.userModel_Retrs = user_Retrs
        vc_Retrs.fromChat_Retrs  = true
        Navigation_Retrs.push_Retrs(to: vc_Retrs)
    }

    @objc private func reportTapped_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        ReportDeleteHelper_Retrs.block_Retrs(user_Retrs: user_Retrs, from: self) { [weak self] in
            Navigation_Retrs.popToSafeStateAfterBlock_Retrs(from: self ?? UIViewController())
        }
    }

    @objc private func videoCallTapped_Retrs() {
        guard let user_Retrs = userModel_Retrs else { return }
        let vc_Retrs = VideoChat_Retrs()
        vc_Retrs.userModel_Retrs = user_Retrs
        vc_Retrs.modalPresentationStyle = .fullScreen
        present(vc_Retrs, animated: true)
    }

    @objc private func sendTapped_Retrs() {
        let text_Retrs = inputField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Retrs.isEmpty, let uid_Retrs = userModel_Retrs?.userId_Retrs else { return }
        sendBtn_Retrs.animatePulse_Retrs()
        messageVM_Retrs.sendMessage_Retrs(message_retrs: text_Retrs, chatType_retrs: .personal_retrs, id_retrs: uid_Retrs)
        inputField_Retrs.text = ""
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Retrs: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Retrs(); return true
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Retrs: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages_Retrs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Retrs = tableView.dequeueReusableCell(
            withIdentifier: "MsgBubbleCell_Retrs", for: indexPath) as! MsgBubbleCell_Retrs
        cell_Retrs.configure_Retrs(message_Retrs: messages_Retrs[indexPath.row])
        return cell_Retrs
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - 消息气泡单元格

/// 消息气泡单元格
/// 功能：我的消息 → 右侧渐变气泡；对方消息 → 左侧白色卡片气泡
class MsgBubbleCell_Retrs: UITableViewCell {

    private let bubbleView_Retrs   = UIView()
    private let bubbleGrad_Retrs   = CAGradientLayer()
    private let msgLabel_Retrs     = UILabel()
    private let timeLabel_Retrs    = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        // 气泡容器
        bubbleView_Retrs.layer.cornerRadius = 18
        bubbleView_Retrs.clipsToBounds = false
        contentView.addSubview(bubbleView_Retrs)

        // 渐变层（我的消息用）
        bubbleGrad_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        bubbleGrad_Retrs.startPoint = CGPoint(x: 0, y: 0)
        bubbleGrad_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        bubbleGrad_Retrs.cornerRadius = 18

        msgLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        msgLabel_Retrs.numberOfLines = 0
        bubbleView_Retrs.addSubview(msgLabel_Retrs)
        msgLabel_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }

        timeLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        timeLabel_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        contentView.addSubview(timeLabel_Retrs)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGrad_Retrs.frame = bubbleView_Retrs.bounds
    }

    func configure_Retrs(message_Retrs: MessageModel_Retrs) {
        let isMine_Retrs = message_Retrs.isMine_Retrs ?? false
        msgLabel_Retrs.text = message_Retrs.content_Retrs ?? ""
        timeLabel_Retrs.text = message_Retrs.time_Retrs ?? ""

        if isMine_Retrs {
            // 右侧渐变气泡
            bubbleView_Retrs.layer.insertSublayer(bubbleGrad_Retrs, at: 0)
            bubbleView_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
                .withAlphaComponent(0.2).cgColor
            bubbleView_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
            bubbleView_Retrs.layer.shadowOpacity = 1
            bubbleView_Retrs.layer.shadowRadius  = 8
            msgLabel_Retrs.textColor = .white
            bubbleView_Retrs.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.trailing.equalToSuperview().offset(-16)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.65)
                make.bottom.equalToSuperview().offset(-6)
            }
            timeLabel_Retrs.snp.remakeConstraints { make in
                make.trailing.equalTo(bubbleView_Retrs.snp.leading).offset(-6)
                make.centerY.equalTo(bubbleView_Retrs)
            }
        } else {
            // 左侧白色卡片气泡
            bubbleGrad_Retrs.removeFromSuperlayer()
            bubbleView_Retrs.backgroundColor = .white
            bubbleView_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
                .withAlphaComponent(0.08).cgColor
            bubbleView_Retrs.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Retrs.layer.shadowOpacity = 1
            bubbleView_Retrs.layer.shadowRadius  = 6
            msgLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
            bubbleView_Retrs.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.leading.equalToSuperview().offset(16)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.65)
                make.bottom.equalToSuperview().offset(-6)
            }
            timeLabel_Retrs.snp.remakeConstraints { make in
                make.leading.equalTo(bubbleView_Retrs.snp.trailing).offset(6)
                make.centerY.equalTo(bubbleView_Retrs)
            }
        }
    }
}

// MARK: - 渐变圆环辅助视图（聊天头像）

/// 聊天页头像渐变圆环
class MsgUserGradRing_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        gradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
        let w_Retrs: CGFloat = 3
        let outer_Retrs = UIBezierPath(ovalIn: bounds)
        let inner_Retrs = UIBezierPath(ovalIn: bounds.insetBy(dx: w_Retrs, dy: w_Retrs))
        outer_Retrs.append(inner_Retrs)
        outer_Retrs.usesEvenOddFillRule = true
        let mask_Retrs = CAShapeLayer()
        mask_Retrs.path = outer_Retrs.cgPath
        mask_Retrs.fillRule = .evenOdd
        gradLayer_Retrs.mask = mask_Retrs
    }
}
