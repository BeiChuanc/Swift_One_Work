import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天

/// 与指定用户的聊天界面
/// 功能：顶部导航（用户信息靠左）+ 消息气泡（带双方头像）+ 底部输入行
/// 设计：左对齐用户信息导航 + 头像气泡流 + 渐变输入栏
/// 逻辑：登录用户信息 + 聊天对象信息 → 气泡展示 → 发送消息 → 视频通话 → 举报删除
class MessageUser_Moode: UIViewController {

    // MARK: - 外部属性

    var userModel_Moode: PrewUserModel_Moode?

    // MARK: - 顶部导航栏

    private let navBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        return v_Moode
    }()

    private var navBarGradient_Moode: CAGradientLayer?

    /// 返回按钮
    private let backBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn_Moode.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = UIColor(hexstring_Moode: "#6C5CE7")
        btn_Moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        btn_Moode.layer.cornerRadius = 16
        return btn_Moode
    }()

    /// 用户头像（靠左，紧贴返回按钮）
    private let navAvatarView_Moode = UserAvatarView_Moode()

    /// 用户昵称
    private let navNameLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 15, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    /// 用户简介/状态
    private let navBioLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11)
        l_Moode.textColor = UIColor(hexstring_Moode: "#9B9BC0")
        l_Moode.lineBreakMode = .byTruncatingTail
        return l_Moode
    }()

    /// 在线状态绿点
    private let onlineDot_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#48BB78")
        v_Moode.layer.cornerRadius = 4
        v_Moode.layer.borderWidth = 1.5
        v_Moode.layer.borderColor = UIColor.white.cgColor
        return v_Moode
    }()

    /// 举报按钮（由 ReportDeleteHelper_Moode 在布局阶段创建）
    private var reportBtn_Moode = UIButton()

    /// 导航栏底部分隔线（极淡渐变）
    private let navDivider_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        return v_Moode
    }()

    // MARK: - 消息列表

    private let tableView_Moode: UITableView = {
        let tv_Moode = UITableView(frame: .zero, style: .plain)
        tv_Moode.backgroundColor = .clear
        tv_Moode.separatorStyle = .none
        tv_Moode.showsVerticalScrollIndicator = false
        tv_Moode.estimatedRowHeight = 70
        tv_Moode.rowHeight = UITableView.automaticDimension
        tv_Moode.register(MsgBubbleCell_Moode.self, forCellReuseIdentifier: MsgBubbleCell_Moode.reuseId_Moode)
        return tv_Moode
    }()

    // MARK: - 空状态

    private let emptyChatView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.isHidden = true
        return v_Moode
    }()

    private let emptyChatEmoji_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "👋"
        l_Moode.font = .systemFont(ofSize: 48)
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let emptyChatTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Start the conversation!"
        l_Moode.font = .systemFont(ofSize: 15, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#6C5CE7")
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let emptyChatSubLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Say hello and share your mood ✨"
        l_Moode.font = .systemFont(ofSize: 13)
        l_Moode.textColor = UIColor(hexstring_Moode: "#9B9BC0")
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    // MARK: - 底部输入栏

    private let inputBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#A78BFA").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_Moode.layer.shadowRadius = 14
        v_Moode.layer.shadowOpacity = 0.10
        return v_Moode
    }()

    private let inputContainer_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#F5F3FF")
        v_Moode.layer.cornerRadius = 22
        v_Moode.layer.borderWidth = 1
        v_Moode.layer.borderColor = UIColor(hexstring_Moode: "#EDE9FF").cgColor
        return v_Moode
    }()

    private let inputField_Moode: UITextField = {
        let tf_Moode = UITextField()
        tf_Moode.placeholder = "Type a mood message..."
        tf_Moode.font = .systemFont(ofSize: 14)
        tf_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        tf_Moode.backgroundColor = .clear
        tf_Moode.returnKeyType = .send
        return tf_Moode
    }()

    private let videoBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn_Moode.setImage(UIImage(systemName: "video.fill", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = UIColor(hexstring_Moode: "#7C6FF7")
        btn_Moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        btn_Moode.layer.cornerRadius = 22
        return btn_Moode
    }()

    private let sendBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.layer.cornerRadius = 22
        btn_Moode.clipsToBounds = true
        return btn_Moode
    }()

    private var sendBtnGradient_Moode: CAGradientLayer?
    private var inputBarBottomConstraint_Moode: Constraint?

    // MARK: - 数据

    private var messages_Moode: [MessageModel_Moode] = []

    /// 当前登录用户 ID（用于气泡头像）
    private var currentUserId_Moode: Int = 0
    /// 聊天对象 ID（用于气泡头像）
    private var otherUserId_Moode: Int = 0

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadMessages_Moode()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F3FF")
        currentUserId_Moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode().userId_Moode ?? 0
        otherUserId_Moode = userModel_Moode?.userId_Moode ?? 0
        setupNavBar_Moode()
        setupBackground_Moode()
        setupTableView_Moode()
        setupEmptyView_Moode()
        setupInputBar_Moode()
        setupKeyboardObserver_Moode()
        configureUserInfo_Moode()
        observeNotifications_Moode()
        reloadMessages_Moode()
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleBgTapped_Moode))
        tap_Moode.cancelsTouchesInView = false
        tableView_Moode.addGestureRecognizer(tap_Moode)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSendBtnGradient_Moode()
    }

    // MARK: - 布局：背景装饰

    /// 添加轻量背景装饰圆（营造层次感）
    private func setupBackground_Moode() {
        let circle1_Moode = UIView()
        circle1_Moode.backgroundColor = UIColor(hexstring_Moode: "#A78BFA").withAlphaComponent(0.06)
        circle1_Moode.layer.cornerRadius = 80
        view.insertSubview(circle1_Moode, at: 0)
        circle1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(50)
            make.top.equalToSuperview().offset(120)
            make.width.height.equalTo(160)
        }

        let circle2_Moode = UIView()
        circle2_Moode.backgroundColor = UIColor(hexstring_Moode: "#68D391").withAlphaComponent(0.05)
        circle2_Moode.layer.cornerRadius = 60
        view.insertSubview(circle2_Moode, at: 0)
        circle2_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-160)
            make.width.height.equalTo(120)
        }
    }

    // MARK: - 布局：导航栏

    private func setupNavBar_Moode() {
        view.addSubview(navBar_Moode)
        navBar_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(58)
        }

        // 返回按钮
        navBar_Moode.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(32)
        }
        backBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // 头像（紧贴返回按钮右侧）
        navBar_Moode.addSubview(navAvatarView_Moode)
        navAvatarView_Moode.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Moode.snp.right).offset(10)
            make.centerY.equalTo(backBtn_Moode)
            make.width.height.equalTo(34)
        }

        // 在线绿点（头像右下角）
        navBar_Moode.addSubview(onlineDot_Moode)
        onlineDot_Moode.snp.makeConstraints { make in
            make.right.equalTo(navAvatarView_Moode).offset(1)
            make.bottom.equalTo(navAvatarView_Moode).offset(1)
            make.width.height.equalTo(8)
        }

        // 举报按钮（右侧）— 使用 ReportDeleteHelper_Moode 统一创建，保证视觉与行为一致
        // 必须在 navBioLabel 约束之前 addSubview，否则 right 锚点无公共祖先
        reportBtn_Moode = ReportDeleteHelper_Moode.createUserReportButton_Moode(
            size_Moode: 32,
            backgroundColor_Moode: UIColor(hexstring_Moode: "#EDE9FF"),
            tintColor_Moode: UIColor(hexstring_Moode: "#6C5CE7")
        )
        navBar_Moode.addSubview(reportBtn_Moode)
        reportBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(backBtn_Moode)
            make.width.height.equalTo(32)
        }
        // 点击触发 ReportDeleteHelper_Moode 的拉黑/举报流程，举报成功后返回上一级
        reportBtn_Moode.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_Moode = self.userModel_Moode else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            ReportDeleteHelper_Moode.block_Moode(user_Moode: user_Moode, from: self) {
                Navigation_Moode.pop_Moode()
            }
        }, for: .touchUpInside)

        // 昵称 + 简介（头像右侧竖排，右边界受 reportBtn 约束）
        navBar_Moode.addSubview(navNameLabel_Moode)
        navNameLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(navAvatarView_Moode.snp.right).offset(8)
            make.bottom.equalTo(navAvatarView_Moode.snp.centerY).offset(-1)
            make.right.lessThanOrEqualTo(reportBtn_Moode.snp.left).offset(-8)
        }

        navBar_Moode.addSubview(navBioLabel_Moode)
        navBioLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(navAvatarView_Moode.snp.right).offset(8)
            make.top.equalTo(navAvatarView_Moode.snp.centerY).offset(2)
            make.right.lessThanOrEqualTo(reportBtn_Moode.snp.left).offset(-8)
        }

        // 底部分隔线
        navBar_Moode.addSubview(navDivider_Moode)
        navDivider_Moode.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    // MARK: - 布局：消息列表

    private func setupTableView_Moode() {
        view.addSubview(tableView_Moode)
        tableView_Moode.snp.makeConstraints { make in
            make.top.equalTo(navBar_Moode.snp.bottom)
            make.left.right.equalToSuperview()
        }
        tableView_Moode.dataSource = self
        tableView_Moode.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    // MARK: - 布局：空状态

    private func setupEmptyView_Moode() {
        view.addSubview(emptyChatView_Moode)
        emptyChatView_Moode.addSubview(emptyChatEmoji_Moode)
        emptyChatView_Moode.addSubview(emptyChatTitleLabel_Moode)
        emptyChatView_Moode.addSubview(emptyChatSubLabel_Moode)

        emptyChatView_Moode.snp.makeConstraints { make in
            make.center.equalTo(tableView_Moode)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        emptyChatEmoji_Moode.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        emptyChatTitleLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyChatEmoji_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        emptyChatSubLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyChatTitleLabel_Moode.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 布局：输入栏

    private func setupInputBar_Moode() {
        view.addSubview(inputBar_Moode)
        inputBar_Moode.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottomConstraint_Moode = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.height.equalTo(68)
        }

        inputBar_Moode.addSubview(sendBtn_Moode)
        sendBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview().offset(-2)
            make.width.height.equalTo(44)
        }
        sendBtn_Moode.addTarget(self, action: #selector(handleSend_Moode), for: .touchUpInside)

        inputBar_Moode.addSubview(videoBtn_Moode)
        videoBtn_Moode.snp.makeConstraints { make in
            make.right.equalTo(sendBtn_Moode.snp.left).offset(-8)
            make.centerY.equalToSuperview().offset(-2)
            make.width.height.equalTo(44)
        }
        videoBtn_Moode.addTarget(self, action: #selector(handleVideoCall_Moode), for: .touchUpInside)

        inputBar_Moode.addSubview(inputContainer_Moode)
        inputContainer_Moode.addSubview(inputField_Moode)
        inputField_Moode.delegate = self

        inputContainer_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalTo(videoBtn_Moode.snp.left).offset(-8)
            make.centerY.equalToSuperview().offset(-2)
            make.height.equalTo(44)
        }
        inputField_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        tableView_Moode.snp.makeConstraints { make in
            make.bottom.equalTo(inputBar_Moode.snp.top)
        }
    }

    // MARK: - 键盘监听

    private func setupKeyboardObserver_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillShow_Moode(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillHide_Moode(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 样式更新

    private func updateSendBtnGradient_Moode() {
        if sendBtnGradient_Moode == nil {
            let grad_Moode = CAGradientLayer()
            grad_Moode.colors = [
                UIColor(hexstring_Moode: "#A78BFA").cgColor,
                UIColor(hexstring_Moode: "#6C5CE7").cgColor
            ]
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 1, y: 1)
            sendBtn_Moode.layer.insertSublayer(grad_Moode, at: 0)
            sendBtnGradient_Moode = grad_Moode
        }
        sendBtnGradient_Moode?.frame = sendBtn_Moode.bounds
    }

    // MARK: - 数据填充

    private func configureUserInfo_Moode() {
        guard let user_Moode = userModel_Moode else { return }
        navNameLabel_Moode.text = user_Moode.userName_Moode ?? "User"
        navBioLabel_Moode.text = user_Moode.userIntroduce_Moode ?? "Online"
        navAvatarView_Moode.configure_Moode(userId_Moode: user_Moode.userId_Moode ?? 0)
    }

    // MARK: - 数据刷新

    private func reloadMessages_Moode() {
        guard let uid_Moode = userModel_Moode?.userId_Moode else { return }
        messages_Moode = MessageViewModel_Moode.shared_Moode.getMessagesWithUser_Moode(userId_moode: uid_Moode)
        emptyChatView_Moode.isHidden = !messages_Moode.isEmpty
        tableView_Moode.reloadData()
        scrollToBottom_Moode(animated: false)
    }

    private func scrollToBottom_Moode(animated: Bool) {
        guard !messages_Moode.isEmpty else { return }
        tableView_Moode.scrollToRow(
            at: IndexPath(row: messages_Moode.count - 1, section: 0),
            at: .bottom, animated: animated
        )
    }

    // MARK: - 通知监听

    private func observeNotifications_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMessagesChanged_Moode),
            name: MessageViewModel_Moode.messageStateDidChangeNotification_Moode, object: nil
        )
    }

    // MARK: - 事件处理

    @objc private func handleBack_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.pop_Moode()
    }


    private func deleteConversation_Moode() {
        guard let uid_Moode = userModel_Moode?.userId_Moode else { return }
        Task { @MainActor in
            MessageViewModel_Moode.shared_Moode.deleteUserMessages_Moode(userId_moode: uid_Moode)
            Navigation_Moode.pop_Moode()
        }
    }

    /// 点击视频按钮 → 弹起 VideoChat_Moode
    @objc private func handleVideoCall_Moode() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let vc_Moode = VideoChat_Moode()
        vc_Moode.userModel_Moode = userModel_Moode
        vc_Moode.modalPresentationStyle = .fullScreen
        present(vc_Moode, animated: true)
    }

    @objc private func handleSend_Moode() {
        guard let text_Moode = inputField_Moode.text?.trimmingCharacters(in: .whitespaces),
              !text_Moode.isEmpty,
              let uid_Moode = userModel_Moode?.userId_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        sendBtn_Moode.animatePressDown_Moode { self.sendBtn_Moode.animatePressUp_Moode() }
        inputField_Moode.text = ""
        Task { @MainActor in
            MessageViewModel_Moode.shared_Moode.sendMessage_Moode(
                message_moode: text_Moode,
                chatType_moode: .personal_moode,
                id_moode: uid_Moode
            )
        }
    }

    @objc private func handleBgTapped_Moode() { view.endEditing(true) }

    @objc private func handleMessagesChanged_Moode() {
        reloadMessages_Moode()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom_Moode(animated: true)
        }
    }

    @objc private func handleKeyboardWillShow_Moode(_ notification_moode: Notification) {
        guard let kbFrame_moode = notification_moode.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_moode = notification_moode.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let offset_moode = -(kbFrame_moode.height - view.safeAreaInsets.bottom)
        inputBarBottomConstraint_Moode?.update(offset: offset_moode)
        UIView.animate(withDuration: duration_moode) { self.view.layoutIfNeeded() }
        scrollToBottom_Moode(animated: true)
    }

    @objc private func handleKeyboardWillHide_Moode(_ notification_moode: Notification) {
        guard let duration_moode = notification_moode.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottomConstraint_Moode?.update(offset: 0)
        UIView.animate(withDuration: duration_moode) { self.view.layoutIfNeeded() }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Moode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Moode()
        return true
    }
}

// MARK: - UITableView DataSource

extension MessageUser_Moode: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages_Moode.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Moode = tableView.dequeueReusableCell(
            withIdentifier: MsgBubbleCell_Moode.reuseId_Moode, for: indexPath
        ) as? MsgBubbleCell_Moode else { return UITableViewCell() }
        cell_Moode.configure_Moode(
            message_moode: messages_Moode[indexPath.row],
            currentUserId_moode: currentUserId_Moode,
            otherUserId_moode: otherUserId_Moode
        )
        return cell_Moode
    }
}

// MARK: - 消息气泡 Cell

/// 消息气泡 Cell
/// 功能：双方头像（UserAvatarView）+ 气泡（渐变/白色）+ 时间戳
/// 布局：我方右对齐（头像在气泡右侧），对方左对齐（头像在气泡左侧）
class MsgBubbleCell_Moode: UITableViewCell {

    static let reuseId_Moode = "MsgBubbleCell_Moode"

    // MARK: - UI

    /// 我方头像（右侧）
    private let myAvatarView_Moode = UserAvatarView_Moode()
    /// 对方头像（左侧）
    private let otherAvatarView_Moode = UserAvatarView_Moode()

    private let bubbleView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 18
        return v_Moode
    }()

    private var bubbleGradient_Moode: CAGradientLayer?

    private let msgLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 14.5)
        l_Moode.numberOfLines = 0
        l_Moode.lineBreakMode = .byWordWrapping
        return l_Moode
    }()

    private let timeLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 9.5)
        l_Moode.textColor = UIColor(hexstring_Moode: "#BBBBDD")
        return l_Moode
    }()

    private var isMine_Moode: Bool = true

    // 约束引用（动态切换左右布局）
    private var bubbleRightToAvatar_Moode: Constraint?
    private var bubbleLeftToAvatar_Moode: Constraint?
    private var timeRight_Moode: Constraint?
    private var timeLeft_Moode: Constraint?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Moode()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBubbleGradient_Moode()
    }

    // MARK: - 布局

    private func setupUI_Moode() {
        // 两个头像均加入，通过 isHidden 切换
        contentView.addSubview(myAvatarView_Moode)
        contentView.addSubview(otherAvatarView_Moode)
        contentView.addSubview(bubbleView_Moode)
        bubbleView_Moode.addSubview(msgLabel_Moode)
        contentView.addSubview(timeLabel_Moode)

        // 我方头像：右侧固定
        myAvatarView_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(30)
        }

        // 对方头像：左侧固定
        otherAvatarView_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(30)
        }

        // 气泡约束：两套（右/左），通过 activate/deactivate 切换
        bubbleView_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualTo(contentView).multipliedBy(0.68)
            // 右对齐：气泡右 = 我方头像左 - 8
            bubbleRightToAvatar_Moode = make.right.equalTo(myAvatarView_Moode.snp.left).offset(-8).constraint
            // 左对齐：气泡左 = 对方头像右 + 8
            bubbleLeftToAvatar_Moode = make.left.equalTo(otherAvatarView_Moode.snp.right).offset(8).constraint
        }

        msgLabel_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }

        timeLabel_Moode.snp.makeConstraints { make in
            make.bottom.equalTo(bubbleView_Moode).offset(-2)
            timeRight_Moode = make.right.equalTo(bubbleView_Moode.snp.left).offset(-6).constraint
            timeLeft_Moode = make.left.equalTo(bubbleView_Moode.snp.right).offset(6).constraint
        }
    }

    // MARK: - 渐变

    private func updateBubbleGradient_Moode() {
        if isMine_Moode {
            if bubbleGradient_Moode == nil {
                let grad_Moode = CAGradientLayer()
                grad_Moode.colors = [
                    UIColor(hexstring_Moode: "#B794F6").cgColor,
                    UIColor(hexstring_Moode: "#6C5CE7").cgColor
                ]
                grad_Moode.startPoint = CGPoint(x: 0, y: 0)
                grad_Moode.endPoint = CGPoint(x: 1, y: 1)
                grad_Moode.cornerRadius = 18
                bubbleView_Moode.layer.insertSublayer(grad_Moode, at: 0)
                bubbleGradient_Moode = grad_Moode
            }
            bubbleGradient_Moode?.frame = bubbleView_Moode.bounds
        } else {
            bubbleGradient_Moode?.removeFromSuperlayer()
            bubbleGradient_Moode = nil
        }
    }

    // MARK: - 数据绑定

    /// 配置气泡内容、头像、时间戳，以及左右布局
    func configure_Moode(message_moode: MessageModel_Moode,
                         currentUserId_moode: Int,
                         otherUserId_moode: Int) {
        let mine_Moode = message_moode.isMine_Moode ?? true
        isMine_Moode = mine_Moode
        msgLabel_Moode.text = message_moode.content_Moode ?? ""
        timeLabel_Moode.text = message_moode.time_Moode ?? ""

        if mine_Moode {
            // 我方：气泡靠右，我方头像可见
            myAvatarView_Moode.isHidden = false
            otherAvatarView_Moode.isHidden = true
            myAvatarView_Moode.configure_Moode(userId_Moode: currentUserId_moode)

            bubbleView_Moode.backgroundColor = .clear
            bubbleView_Moode.layer.shadowOpacity = 0
            msgLabel_Moode.textColor = .white
            bubbleRightToAvatar_Moode?.activate()
            bubbleLeftToAvatar_Moode?.deactivate()
            timeRight_Moode?.activate()
            timeLeft_Moode?.deactivate()
        } else {
            // 对方：气泡靠左，对方头像可见
            myAvatarView_Moode.isHidden = true
            otherAvatarView_Moode.isHidden = false
            otherAvatarView_Moode.configure_Moode(userId_Moode: otherUserId_moode)

            bubbleView_Moode.backgroundColor = .white
            bubbleView_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#A78BFA").cgColor
            bubbleView_Moode.layer.shadowOffset = CGSize(width: 0, height: 3)
            bubbleView_Moode.layer.shadowRadius = 8
            bubbleView_Moode.layer.shadowOpacity = 0.12
            msgLabel_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
            bubbleLeftToAvatar_Moode?.activate()
            bubbleRightToAvatar_Moode?.deactivate()
            timeLeft_Moode?.activate()
            timeRight_Moode?.deactivate()
        }
        setNeedsLayout()
    }
}
