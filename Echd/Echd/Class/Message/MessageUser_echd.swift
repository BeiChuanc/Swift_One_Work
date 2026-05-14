import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页
// 设计思路：
//   顶部采用深紫-靛蓝渐变 Header（圆弧底部），中心展示目标用户头像（带彩色环）、
//   昵称、在线绿点，右侧举报按钮；
//   消息区背景为极浅紫（#F0EDFF），气泡设计：
//     - 我发的：深紫-靛蓝渐变气泡 + 白色文字，右侧头像；
//     - 对方：白色气泡 + 紫色边框，左侧头像；
//   底部输入栏：输入框 + 渐变发送按钮（已移除视频通话相关组件）。

/// 与用户聊天页视图控制器
class MessageUser_Echd: UIViewController {

    // MARK: - 属性

    /// 聊天目标用户
    var userModel_Echd: PrewUserModel_Echd?

    // MARK: - UI组件 / NavBar

    private let navBar_Echd = UIView()
    private var navGradient_Echd: CAGradientLayer?
    private let backButton_Echd = BackButton_Echd()

    private let targetRingView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 22
        view_Echd.layer.borderWidth = 2
        view_Echd.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        return view_Echd
    }()

    private let targetAvatarView_Echd = UserAvatarView_Echd()

    private let onlineDot_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#10B981")
        view_Echd.layer.cornerRadius = 5.5
        view_Echd.layer.borderWidth = 1.5
        view_Echd.layer.borderColor = UIColor.white.cgColor
        return view_Echd
    }()

    private let targetNameLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_Echd.textColor = .white
        return label_Echd
    }()

    private let targetStatusLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.7)
        return label_Echd
    }()

    private let reportButton_Echd: UIButton = {
        let btn_Echd = ReportDeleteHelper_Echd.createUserReportButton_Echd(
            size_Echd: 36,
            backgroundColor_Echd: UIColor.white.withAlphaComponent(0.18),
            tintColor_Echd: .white
        )
        btn_Echd.layer.cornerRadius = 18
        return btn_Echd
    }()

    // MARK: - UI组件 / 消息列表

    private let tableView_Echd: UITableView = {
        let tv_Echd = UITableView()
        tv_Echd.separatorStyle = .none
        tv_Echd.backgroundColor = UIColor(hexstring_Echd: "#F0EDFF")
        tv_Echd.showsVerticalScrollIndicator = false
        tv_Echd.alwaysBounceVertical = true
        tv_Echd.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tv_Echd.register(ChatBubbleCell_Echd.self, forCellReuseIdentifier: ChatBubbleCell_Echd.identifier_Echd)
        return tv_Echd
    }()

    // MARK: - UI组件 / 底部输入栏

    private let inputBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: -3)
        view_Echd.layer.shadowRadius = 10
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    private let inputWrap_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#F3F4F6")
        view_Echd.layer.cornerRadius = 22
        return view_Echd
    }()

    private let messageTextField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Type a message..."
        tf_Echd.font = UIFont.systemFont(ofSize: 14)
        tf_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tf_Echd.backgroundColor = .clear
        tf_Echd.borderStyle = .none
        tf_Echd.autocorrectionType = .no
        return tf_Echd
    }()

    private let sendButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.tintColor = .white
        btn_Echd.layer.cornerRadius = 22
        btn_Echd.layer.masksToBounds = true
        return btn_Echd
    }()

    // sendGradient_Echd 已移除，改用 backgroundColor

    // MARK: - 私有属性

    private var messages_Echd: [MessageModel_Echd] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshMessages_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F0EDFF")
        setupUI_Echd()
        setupConstraints_Echd()
        setupKeyboardObservers_Echd()
        observeNotifications_Echd()
        fillUserInfo_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGradient_Echd?.frame = navBar_Echd.bounds
        applyNavArc_Echd()
        // sendButton 使用 backgroundColor，无需在此更新渐变 frame
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // NavBar
        navBar_Echd.clipsToBounds = true
        view.addSubview(navBar_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [UIColor(hexstring_Echd: "#7C3AED").cgColor, UIColor(hexstring_Echd: "#4F46E5").cgColor]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        navBar_Echd.layer.insertSublayer(grad_Echd, at: 0)
        navGradient_Echd = grad_Echd

        navBar_Echd.addSubview(backButton_Echd)
        navBar_Echd.addSubview(reportButton_Echd)

        // 用户信息整组水平居中：用容器包裹头像环 + 名字/状态，
        // 让容器的 centerX = navBar.centerX，而非仅头像环居中
        let userInfoContainer_Echd = UIView()
        userInfoContainer_Echd.isUserInteractionEnabled = true
        navBar_Echd.addSubview(userInfoContainer_Echd)
        userInfoContainer_Echd.addSubview(targetRingView_Echd)
        targetRingView_Echd.addSubview(targetAvatarView_Echd)
        userInfoContainer_Echd.addSubview(onlineDot_Echd)

        let textStack_Echd = UIStackView(arrangedSubviews: [targetNameLabel_Echd, targetStatusLabel_Echd])
        textStack_Echd.axis = .vertical
        textStack_Echd.spacing = 3
        textStack_Echd.alignment = .leading
        userInfoContainer_Echd.addSubview(textStack_Echd)

        // 容器内部布局：头像环在左，文字栈在右
        targetRingView_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        targetAvatarView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview(); make.width.height.equalTo(38)
        }
        onlineDot_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(targetRingView_Echd.snp.trailing).offset(1)
            make.bottom.equalTo(targetRingView_Echd.snp.bottom).offset(1)
            make.width.height.equalTo(11)
        }
        textStack_Echd.snp.makeConstraints { make in
            make.leading.equalTo(targetRingView_Echd.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        // 容器整体居中
        userInfoContainer_Echd.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton_Echd)
            make.leading.greaterThanOrEqualTo(backButton_Echd.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(reportButton_Echd.snp.leading).offset(-8)
        }

        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }

        let userTap_Echd = UITapGestureRecognizer(target: self, action: #selector(userAreaTapped_Echd))
        targetRingView_Echd.addGestureRecognizer(userTap_Echd)
        targetRingView_Echd.isUserInteractionEnabled = true
        let nameTap_Echd = UITapGestureRecognizer(target: self, action: #selector(userAreaTapped_Echd))
        targetNameLabel_Echd.isUserInteractionEnabled = true
        targetNameLabel_Echd.addGestureRecognizer(nameTap_Echd)

        reportButton_Echd.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_Echd = self.userModel_Echd else { return }
            ReportDeleteHelper_Echd.block_Echd(user_Echd: user_Echd, from: self) {
                Navigation_Echd.popToSafeStateAfterBlock_Echd(from: self)
            }
        }, for: .touchUpInside)

        // 消息列表
        view.addSubview(tableView_Echd)
        tableView_Echd.dataSource = self
        tableView_Echd.delegate = self
        let tapToDismiss_Echd = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Echd))
        tapToDismiss_Echd.cancelsTouchesInView = false
        tableView_Echd.addGestureRecognizer(tapToDismiss_Echd)

        // 底部输入栏（无视频通话按钮）
        view.addSubview(inputBar_Echd)
        inputBar_Echd.addSubview(inputWrap_Echd)
        inputWrap_Echd.addSubview(messageTextField_Echd)
        inputBar_Echd.addSubview(sendButton_Echd)

        // 使用 backgroundColor 代替 CAGradientLayer，避免 frame=zero 时遮住 imageView
        sendButton_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        sendButton_Echd.addTarget(self, action: #selector(sendTapped_Echd), for: .touchUpInside)
    }

    private func applyNavArc_Echd() {
        let w_Echd = navBar_Echd.bounds.width
        let h_Echd = navBar_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 16))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 16),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 14)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer()
        mask_Echd.path = path_Echd.cgPath
        navBar_Echd.layer.mask = mask_Echd
    }

    private func fillUserInfo_Echd() {
        guard let user_Echd = userModel_Echd else { return }
        targetAvatarView_Echd.configure_Echd(userId_Echd: user_Echd.userId_Echd ?? 0)
        targetNameLabel_Echd.text = user_Echd.userName_Echd ?? "Unknown"
        targetStatusLabel_Echd.text = user_Echd.userIntroduce_Echd ?? "Online ✦"
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        navBar_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
        reportButton_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Echd)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        // 用户信息约束已在 setupUI_Echd 的 userInfoContainer 内统一设置

        tableView_Echd.snp.makeConstraints { make in
            make.top.equalTo(navBar_Echd.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Echd.snp.top)
        }

        inputBar_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        // 输入框直接从 leading 开始（无视频通话按钮占位）
        inputWrap_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendButton_Echd.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(44)
        }
        messageTextField_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        sendButton_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(inputWrap_Echd)
            make.width.height.equalTo(44)
        }
    }

    // MARK: - 数据刷新

    private func refreshMessages_Echd() {
        guard let uid_Echd = userModel_Echd?.userId_Echd else { return }
        messages_Echd = MessageViewModel_Echd.shared_Echd.getMessagesWithUser_Echd(userId_echd: uid_Echd)
        tableView_Echd.reloadData()
        if !messages_Echd.isEmpty {
            tableView_Echd.scrollToRow(
                at: IndexPath(row: messages_Echd.count - 1, section: 0),
                at: .bottom, animated: true
            )
        }
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Echd() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Echd(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Echd(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow_Echd(_ notification: Notification) {
        guard let kbFrame_Echd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        UIView.animate(withDuration: 0.3) {
            self.inputBar_Echd.snp.updateConstraints { make in make.bottom.equalToSuperview().offset(-kbFrame_Echd.height) }
            self.view.layoutIfNeeded()
        }
        if !messages_Echd.isEmpty {
            tableView_Echd.scrollToRow(at: IndexPath(row: messages_Echd.count - 1, section: 0), at: .bottom, animated: true)
        }
    }

    @objc private func keyboardWillHide_Echd(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.inputBar_Echd.snp.updateConstraints { make in make.bottom.equalToSuperview() }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard_Echd() { view.endEditing(true) }

    // MARK: - 事件处理

    @objc private func userAreaTapped_Echd() {
        guard let user_Echd = userModel_Echd else { return }
        let vc_Echd = UserInfo_Echd()
        vc_Echd.userModel_Echd = user_Echd
        vc_Echd.isFromChat_Echd = true
        Navigation_Echd.push_Echd(to: vc_Echd)
    }

    @objc private func sendTapped_Echd() {
        guard let content_Echd = messageTextField_Echd.text,
              !content_Echd.trimmingCharacters(in: .whitespaces).isEmpty,
              let uid_Echd = userModel_Echd?.userId_Echd else { return }
        sendButton_Echd.animatePulse_Echd()
        messageTextField_Echd.text = nil
        Task { @MainActor in
            MessageViewModel_Echd.shared_Echd.sendMessage_Echd(
                message_echd: content_Echd, chatType_echd: .personal_echd, id_echd: uid_Echd
            )
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Echd),
            name: MessageViewModel_Echd.messageStateDidChangeNotification_Echd,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Echd() { refreshMessages_Echd() }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageUser_Echd: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Echd.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Echd = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell_Echd.identifier_Echd,
            for: indexPath
        ) as! ChatBubbleCell_Echd
        let msg_Echd = messages_Echd[indexPath.row]
        let currentUser_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        cell_Echd.configure_Echd(
            message_Echd: msg_Echd,
            currentUserHead_Echd: currentUser_Echd.userHead_Echd,
            targetUserId_Echd: userModel_Echd?.userId_Echd
        )
        return cell_Echd
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

// MARK: - 聊天气泡 Cell

/// 聊天消息气泡单元格
class ChatBubbleCell_Echd: UITableViewCell {

    static let identifier_Echd = "ChatBubbleCell_Echd"

    private let avatarView_Echd = UserAvatarView_Echd()

    private let bubbleView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 18
        view_Echd.layer.masksToBounds = true
        return view_Echd
    }()

    private var myGradient_Echd: CAGradientLayer?

    private let messageLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 14)
        label_Echd.numberOfLines = 0
        return label_Echd
    }()

    private let timeLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        return label_Echd
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Echd()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Echd() {
        contentView.addSubview(avatarView_Echd)
        contentView.addSubview(bubbleView_Echd)
        bubbleView_Echd.addSubview(messageLabel_Echd)
        contentView.addSubview(timeLabel_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [UIColor(hexstring_Echd: "#7C3AED").cgColor, UIColor(hexstring_Echd: "#6366F1").cgColor]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Echd.endPoint = CGPoint(x: 1, y: 0.5)
        bubbleView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        myGradient_Echd = grad_Echd

        messageLabel_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        myGradient_Echd?.frame = bubbleView_Echd.bounds
    }

    /// 根据消息模型配置气泡内容及头像布局
    /// - Parameters:
    ///   - message_Echd: 消息模型
    ///   - currentUserHead_Echd: 当前登录用户的头像标识（用于我方头像显示）
    ///   - targetUserId_Echd: 聊天对方的用户 ID（用于对方头像显示）
    func configure_Echd(message_Echd: MessageModel_Echd, currentUserHead_Echd: String?, targetUserId_Echd: Int?) {
        let isMine_Echd = message_Echd.isMine_Echd ?? false

        messageLabel_Echd.text = message_Echd.content_Echd ?? ""
        timeLabel_Echd.text = message_Echd.time_Echd ?? ""

        avatarView_Echd.snp.removeConstraints()
        bubbleView_Echd.snp.removeConstraints()
        timeLabel_Echd.snp.removeConstraints()
        messageLabel_Echd.snp.removeConstraints()
        messageLabel_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }

        if isMine_Echd {
            // 我方气泡：渐变背景，白色文字，右对齐
            myGradient_Echd?.isHidden = false
            bubbleView_Echd.backgroundColor = .clear
            bubbleView_Echd.layer.masksToBounds = true  // 确保渐变不超出圆角边界
            bubbleView_Echd.layer.borderWidth = 0
            bubbleView_Echd.layer.shadowOpacity = 0
            messageLabel_Echd.textColor = .white

            avatarView_Echd.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.trailing.equalToSuperview().offset(-14)
                make.width.height.equalTo(34)
            }
            bubbleView_Echd.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.trailing.equalTo(avatarView_Echd.snp.leading).offset(-8)
                make.leading.greaterThanOrEqualToSuperview().offset(70)
                make.bottom.equalToSuperview().offset(-6)
            }
            timeLabel_Echd.snp.makeConstraints { make in
                make.bottom.equalTo(bubbleView_Echd.snp.bottom).offset(-2)
                make.trailing.equalTo(bubbleView_Echd.snp.leading).offset(-6)
            }

            if let uid_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd().userId_Echd {
                avatarView_Echd.configure_Echd(userId_Echd: uid_Echd)
            } else {
                avatarView_Echd.setDefaultAvatar_Echd(color_Echd: UIColor(hexstring_Echd: "#7C3AED"))
            }

        } else {
            // 对方气泡：白色背景 + 紫色边框，左对齐
            myGradient_Echd?.isHidden = true
            bubbleView_Echd.backgroundColor = .white
            bubbleView_Echd.layer.masksToBounds = false  // 允许阴影显示
            bubbleView_Echd.layer.borderWidth = 1
            bubbleView_Echd.layer.borderColor = UIColor(hexstring_Echd: "#EDE9FE").cgColor
            bubbleView_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.08).cgColor
            bubbleView_Echd.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Echd.layer.shadowRadius = 6
            bubbleView_Echd.layer.shadowOpacity = 1
            messageLabel_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")

            avatarView_Echd.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.leading.equalToSuperview().offset(14)
                make.width.height.equalTo(34)
            }
            bubbleView_Echd.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.leading.equalTo(avatarView_Echd.snp.trailing).offset(8)
                make.trailing.lessThanOrEqualToSuperview().offset(-70)
                make.bottom.equalToSuperview().offset(-6)
            }
            timeLabel_Echd.snp.makeConstraints { make in
                make.bottom.equalTo(bubbleView_Echd.snp.bottom).offset(-2)
                make.leading.equalTo(bubbleView_Echd.snp.trailing).offset(6)
            }

            // 显示聊天对方的头像
            if let uid_Echd = targetUserId_Echd {
                avatarView_Echd.configure_Echd(userId_Echd: uid_Echd)
            } else {
                avatarView_Echd.setDefaultAvatar_Echd(color_Echd: UIColor(hexstring_Echd: "#9CA3AF"))
            }
        }
    }
}
