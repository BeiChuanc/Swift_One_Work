import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页面

/// 与用户聊天页面
/// 功能：顶部渐变导航集成用户信息卡；消息气泡列表；底部浮动输入栏
/// 设计：
///   • 渐变导航区（自管理渐变 + 装饰圆 + 白色用户信息）
///   • 气泡 Cell：己方深渐变 + 白色文字；对方暖白卡片 + 小头像
///   • 浮动输入栏：顶部圆角 + 渐变发送按钮 + 键盘跟随
class MessageUser_Vestir: UIViewController {

    // MARK: - 属性

    var userModel_Vestir: PrewUserModel_Vestir?
    private var messages_Vestir: [MessageModel_Vestir] = []

    // MARK: - 渐变导航区

    /// 导航区阴影容器（不裁剪）
    private let navShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#6B21A8").cgColor
        v_Vestir.layer.shadowOpacity = 0.32
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 20
        return v_Vestir
    }()

    /// 渐变导航背景卡（自管理，下方双角圆角 24pt）
    private let navCard_Vestir = MessageUserNavCard_Vestir()

    /// 装饰圆（右上，白色 11% alpha）
    private let navDecoCircle_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.11)
        v_Vestir.layer.cornerRadius = 45
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 返回按钮（白色半透明圆形背景）
    private lazy var backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir),
            for: .normal
        )
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    // MARK: - 用户信息（集成在导航区）

    /// 用户头像（白色边框环，集成在渐变背景上）
    private let navAvatarView_Vestir: UserAvatarView_Vestir = {
        let av_Vestir = UserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 20
        av_Vestir.clipsToBounds = true
        av_Vestir.layer.borderWidth = 2
        av_Vestir.layer.borderColor = UIColor(white: 1.0, alpha: 0.85).cgColor
        return av_Vestir
    }()

    /// 用户名（白色，15pt semibold）
    private let navNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    /// 在线状态圆点（绿色，内联在名字行旁）
    private let navOnlineDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#22C55E")
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    /// 用户简介（白色，11pt，68% alpha）
    private let navBioLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.68)
        lbl_Vestir.numberOfLines = 1
        return lbl_Vestir
    }()

    /// 导航右侧 chevron（点击进入用户详情）
    private let navChevron_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        iv_Vestir.image = UIImage(systemName: "chevron.right")
        iv_Vestir.tintColor = UIColor(white: 1.0, alpha: 0.55)
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()

    /// 用户信息点击区域（覆盖头像+名字+bio区域）
    private let userInfoTapArea_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.isUserInteractionEnabled = true
        return v_Vestir
    }()

    /// 举报按钮
    private var reportBtn_Vestir: UIButton?

    // MARK: - 消息 TableView

    private lazy var tableView_Vestir: UITableView = {
        let tv_Vestir = UITableView()
        tv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tv_Vestir.separatorStyle = .none
        tv_Vestir.showsVerticalScrollIndicator = false
        tv_Vestir.register(
            ChatBubbleCell_Vestir.self,
            forCellReuseIdentifier: ChatBubbleCell_Vestir.reuseId_Vestir
        )
        tv_Vestir.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return tv_Vestir
    }()

    // MARK: - 浮动输入栏

    /// 输入栏容器（顶部双角圆角，白色，上方阴影）
    private let inputBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 24
        v_Vestir.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.10
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: -4)
        v_Vestir.layer.shadowRadius = 12
        return v_Vestir
    }()

    /// 文字输入框（暖白背景，渐变左侧图标）
    private let inputField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Type a message..."
        tf_Vestir.font = UIFont.systemFont(ofSize: 15)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 20
        tf_Vestir.setLeftPadding_Vestir(
            icon: "pencil",
            tintColor: ColorConfig_Vestir.primaryGradientStart_Vestir
        )
        tf_Vestir.returnKeyType = .send
        return tf_Vestir
    }()

    /// 发送按钮容器（渐变圆形，白色箭头图标）
    private let sendBtnView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let sendGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        return g_Vestir
    }()

    private lazy var sendBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_Vestir.setImage(
            UIImage(systemName: "arrow.up", withConfiguration: cfg_Vestir),
            for: .normal
        )
        btn_Vestir.tintColor = .white
        btn_Vestir.addTarget(self, action: #selector(sendTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
        loadData_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Vestir()
        registerKeyboard_Vestir()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboard_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendGradLayer_Vestir.frame = sendBtnView_Vestir.bounds
        if navShadow_Vestir.bounds.width > 0 {
            navShadow_Vestir.layer.shadowPath = UIBezierPath(
                roundedRect: navShadow_Vestir.bounds, cornerRadius: 0
            ).cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        navShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 70)
        }
        inputBar_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.bottom + 70)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        // 渐变导航区
        view.addSubview(navShadow_Vestir)
        navShadow_Vestir.addSubview(navCard_Vestir)
        navCard_Vestir.addSubview(navDecoCircle_Vestir)
        navCard_Vestir.addSubview(backBtn_Vestir)
        navCard_Vestir.addSubview(navAvatarView_Vestir)
        navCard_Vestir.addSubview(navNameLabel_Vestir)
        navCard_Vestir.addSubview(navOnlineDot_Vestir)
        navCard_Vestir.addSubview(navBioLabel_Vestir)
        navCard_Vestir.addSubview(navChevron_Vestir)
        navCard_Vestir.addSubview(userInfoTapArea_Vestir)

        // 举报按钮
        let reportButton_Vestir = ReportDeleteHelper_Vestir.createUserReportButton_Vestir(
            size_Vestir: 36,
            tintColor_Vestir: UIColor(white: 1.0, alpha: 0.85),
            withShadow_Vestir: false
        )
        reportButton_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.20)
        reportButton_Vestir.layer.cornerRadius = 16
        reportButton_Vestir.clipsToBounds = true
        reportButton_Vestir.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_Vestir = self.userModel_Vestir else { return }
            ReportDeleteHelper_Vestir.block_Vestir(user_Vestir: user_Vestir, from: self) {
                Navigation_Vestir.popToSafeStateAfterBlock_Vestir(from: self)
            }
        }, for: UIControl.Event.touchUpInside)
        navCard_Vestir.addSubview(reportButton_Vestir)
        reportBtn_Vestir = reportButton_Vestir

        // 消息列表
        view.addSubview(tableView_Vestir)
        tableView_Vestir.dataSource = self
        tableView_Vestir.delegate = self

        // 发送按钮渐变
        sendBtnView_Vestir.layer.insertSublayer(sendGradLayer_Vestir, at: 0)

        // 输入栏
        view.addSubview(inputBar_Vestir)
        inputBar_Vestir.addSubview(inputField_Vestir)
        inputBar_Vestir.addSubview(sendBtnView_Vestir)
        sendBtnView_Vestir.addSubview(sendBtn_Vestir)

        // 手势
        let cardTap_Vestir = UITapGestureRecognizer(
            target: self, action: #selector(userCardTapped_Vestir)
        )
        userInfoTapArea_Vestir.addGestureRecognizer(cardTap_Vestir)

        inputField_Vestir.delegate = self
    }

    private func setupConstraints_Vestir() {
        // ─── 渐变导航区 ───
        navShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 70)
        }

        navCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navDecoCircle_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-22)
        }

        backBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }

        reportBtn_Vestir?.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(backBtn_Vestir)
            make.width.height.equalTo(32)
        }

        navAvatarView_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(backBtn_Vestir.snp.trailing).offset(10)
            make.centerY.equalTo(backBtn_Vestir)
            make.width.height.equalTo(40)
        }

        navNameLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navAvatarView_Vestir.snp.trailing).offset(10)
            make.top.equalTo(navAvatarView_Vestir.snp.top).offset(2)
        }

        navOnlineDot_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navNameLabel_Vestir.snp.trailing).offset(6)
            make.centerY.equalTo(navNameLabel_Vestir)
            make.width.height.equalTo(8)
        }

        navBioLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navNameLabel_Vestir)
            make.top.equalTo(navNameLabel_Vestir.snp.bottom).offset(2)
            make.trailing.lessThanOrEqualTo(reportBtn_Vestir?.snp.leading ?? navCard_Vestir.snp.trailing).offset(-8)
        }

        navChevron_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navNameLabel_Vestir.snp.trailing).offset(18)
            make.centerY.equalTo(navAvatarView_Vestir)
            make.width.height.equalTo(12)
        }

        userInfoTapArea_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navAvatarView_Vestir)
            make.trailing.equalTo(navChevron_Vestir.snp.trailing)
            make.top.bottom.equalTo(navAvatarView_Vestir).inset(-4)
        }

        // ─── 输入栏 ───
        inputBar_Vestir.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.bottom + 70)
        }

        inputField_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendBtnView_Vestir.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(44)
        }

        sendBtnView_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(inputField_Vestir)
            make.width.height.equalTo(40)
        }

        sendBtn_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // ─── 消息列表 ───
        tableView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(navShadow_Vestir.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Vestir.snp.top)
        }
    }

    // MARK: - 键盘跟随

    private func registerKeyboard_Vestir() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Vestir(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Vestir(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    private func unregisterKeyboard_Vestir() {
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow_Vestir(_ notification: Notification) {
        guard let kbFrame_Vestir = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? CGRect else { return }
        let offset_Vestir = kbFrame_Vestir.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.inputBar_Vestir.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-offset_Vestir)
            }
            self.view.layoutIfNeeded()
        }
        scrollToBottom_Vestir(animated: true)
    }

    @objc private func keyboardWillHide_Vestir(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.inputBar_Vestir.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 数据加载

    private func loadData_Vestir() {
        guard let user_Vestir = userModel_Vestir else { return }
        navAvatarView_Vestir.configure_Vestir(userId_Vestir: user_Vestir.userId_Vestir ?? 0)
        navNameLabel_Vestir.text = user_Vestir.userName_Vestir ?? "User"
        navBioLabel_Vestir.text = user_Vestir.userIntroduce_Vestir ?? "Fashion lover ✦"

        messages_Vestir = MessageViewModel_Vestir.shared_Vestir.getMessagesWithUser_Vestir(
            userId_vestir: user_Vestir.userId_Vestir ?? 0
        )
        tableView_Vestir.reloadData()
        scrollToBottom_Vestir(animated: false)
    }

    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Vestir),
            name: MessageViewModel_Vestir.messageStateDidChangeNotification_Vestir,
            object: nil
        )
    }

    @objc private func onDataChanged_Vestir() {
        guard let user_Vestir = userModel_Vestir else { return }
        messages_Vestir = MessageViewModel_Vestir.shared_Vestir.getMessagesWithUser_Vestir(
            userId_vestir: user_Vestir.userId_Vestir ?? 0
        )
        tableView_Vestir.reloadData()
        scrollToBottom_Vestir(animated: true)
    }

    private func scrollToBottom_Vestir(animated: Bool) {
        guard !messages_Vestir.isEmpty else { return }
        let lastIndex_Vestir = IndexPath(row: messages_Vestir.count - 1, section: 0)
        tableView_Vestir.scrollToRow(at: lastIndex_Vestir, at: .bottom, animated: animated)
    }

    // MARK: - 事件处理

    @objc private func backTapped_Vestir() {
        Navigation_Vestir.pop_Vestir()
    }

    @objc private func userCardTapped_Vestir() {
        guard let user_Vestir = userModel_Vestir else { return }
        let userInfoVC_Vestir = UserInfo_Vestir()
        userInfoVC_Vestir.userModel_Vestir = user_Vestir
        userInfoVC_Vestir.hideMessageButton_Vestir = true

        userInfoVC_Vestir.onUnfollowFromChat_Vestir = { [weak self] in
            guard let self = self, let user_Vestir = self.userModel_Vestir else { return }
            Task { @MainActor in
                MessageViewModel_Vestir.shared_Vestir.deleteUserMessages_Vestir(
                    userId_vestir: user_Vestir.userId_Vestir ?? 0
                )
            }
            if let nav_Vestir = self.navigationController {
                for vc_Vestir in nav_Vestir.viewControllers.reversed() {
                    if let _ = vc_Vestir as? MessageList_Vestir {
                        nav_Vestir.popToViewController(vc_Vestir, animated: true)
                        return
                    }
                }
                nav_Vestir.popToRootViewController(animated: true)
            }
        }
        Navigation_Vestir.push_Vestir(to: userInfoVC_Vestir)
    }

    @objc private func sendTapped_Vestir() {
        sendMessage_Vestir()
    }

    private func sendMessage_Vestir() {
        guard
            let text_Vestir = inputField_Vestir.text,
            !text_Vestir.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            inputField_Vestir.animateShake_Vestir()
            return
        }
        guard let user_Vestir = userModel_Vestir else { return }
        Task { @MainActor in
            MessageViewModel_Vestir.shared_Vestir.sendMessage_Vestir(
                message_vestir: text_Vestir,
                chatType_vestir: .personal_vestir,
                id_vestir: user_Vestir.userId_Vestir ?? 0
            )
        }
        inputField_Vestir.text = ""
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Vestir: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Vestir.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Vestir = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell_Vestir.reuseId_Vestir,
            for: indexPath
        ) as? ChatBubbleCell_Vestir else {
            return UITableViewCell()
        }
        cell_Vestir.configure_Vestir(
            message_vestir: messages_Vestir[indexPath.row],
            chatUser_vestir: userModel_Vestir
        )
        return cell_Vestir
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Vestir: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage_Vestir()
        return false
    }
}

// MARK: - 聊天气泡 Cell

/// 聊天气泡 Cell
/// 设计：
///   己方（右）：深紫→靛蓝→湛蓝渐变气泡 + 白色文字 + 圆角 18pt
///   对方（左）：暖白卡片 + 主文字色 + 紫调阴影 + 左侧小头像（28pt）
class ChatBubbleCell_Vestir: UITableViewCell {

    static let reuseId_Vestir = "ChatBubbleCell_Vestir"

    // MARK: - 气泡视图

    private let bubbleView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 18
        return v_Vestir
    }()

    /// 气泡渐变图层（己方使用深紫→靛蓝→湛蓝，对方使用纯白）
    private let bubbleGradient_Vestir = CAGradientLayer()

    private let messageLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl_Vestir.numberOfLines = 0
        return lbl_Vestir
    }()

    private let timeLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        return lbl_Vestir
    }()

    // MARK: - 对方头像（仅对方消息显示）

    private let otherAvatarView_Vestir: UserAvatarView_Vestir = {
        let av_Vestir = UserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 14
        av_Vestir.clipsToBounds = true
        av_Vestir.isHidden = true
        return av_Vestir
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Vestir()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradient_Vestir.frame = bubbleView_Vestir.bounds
    }

    private func setupUI_Vestir() {
        contentView.addSubview(otherAvatarView_Vestir)
        contentView.addSubview(bubbleView_Vestir)
        bubbleView_Vestir.layer.insertSublayer(bubbleGradient_Vestir, at: 0)
        bubbleView_Vestir.addSubview(messageLabel_Vestir)
        contentView.addSubview(timeLabel_Vestir)
    }

    // MARK: - 数据配置

    /// 配置气泡数据
    /// 参数：
    /// - message_vestir: 消息模型
    /// - chatUser_vestir: 聊天对象（对方），用于展示左侧头像
    func configure_Vestir(
        message_vestir: MessageModel_Vestir,
        chatUser_vestir: PrewUserModel_Vestir? = nil
    ) {
        let isMine_Vestir = message_vestir.isMine_Vestir ?? false
        messageLabel_Vestir.text = message_vestir.content_Vestir
        timeLabel_Vestir.text = message_vestir.time_Vestir

        // 清除旧约束
        bubbleView_Vestir.snp.removeConstraints()
        messageLabel_Vestir.snp.removeConstraints()
        timeLabel_Vestir.snp.removeConstraints()
        otherAvatarView_Vestir.snp.removeConstraints()

        // 重置气泡阴影（仅对方气泡有阴影）
        bubbleView_Vestir.layer.shadowOpacity = 0

        if isMine_Vestir {
            // ─── 己方气泡（右侧，深渐变）───
            bubbleGradient_Vestir.colors = [
                UIColor(hexstring_Vestir: "#6B21A8").cgColor,
                UIColor(hexstring_Vestir: "#4338CA").cgColor,
                UIColor(hexstring_Vestir: "#0369A1").cgColor
            ]
            bubbleGradient_Vestir.locations = [0, 0.52, 1.0]
            bubbleGradient_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
            bubbleGradient_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
            bubbleGradient_Vestir.cornerRadius = 18
            bubbleView_Vestir.layer.borderWidth = 0
            messageLabel_Vestir.textColor = .white
            otherAvatarView_Vestir.isHidden = true

            bubbleView_Vestir.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(5)
                make.trailing.equalToSuperview().offset(-16)
                make.leading.greaterThanOrEqualToSuperview().offset(80)
                make.bottom.equalToSuperview().offset(-4)
            }

            otherAvatarView_Vestir.snp.makeConstraints { make in
                make.width.height.equalTo(0)
                make.leading.equalToSuperview()
                make.top.equalToSuperview()
            }

        } else {
            // ─── 对方气泡（左侧，暖白卡片 + 头像）───
            bubbleGradient_Vestir.colors = [
                ColorConfig_Vestir.backgroundSecondary_Vestir.cgColor,
                ColorConfig_Vestir.backgroundSecondary_Vestir.cgColor
            ]
            bubbleGradient_Vestir.cornerRadius = 18
            // 暖调阴影
            bubbleView_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
            bubbleView_Vestir.layer.shadowOpacity = 0.10
            bubbleView_Vestir.layer.shadowOffset = CGSize(width: 0, height: 3)
            bubbleView_Vestir.layer.shadowRadius = 8
            bubbleView_Vestir.layer.borderWidth = 1
            bubbleView_Vestir.layer.borderColor = ColorConfig_Vestir.divider_Vestir.cgColor
            messageLabel_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir

            // 对方头像
            if let user_Vestir = chatUser_vestir, let uid_Vestir = user_Vestir.userId_Vestir {
                otherAvatarView_Vestir.configure_Vestir(userId_Vestir: uid_Vestir)
                otherAvatarView_Vestir.isHidden = false
            } else {
                otherAvatarView_Vestir.isHidden = true
            }

            let avatarLeading: CGFloat = otherAvatarView_Vestir.isHidden ? 16 : 46

            otherAvatarView_Vestir.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(12)
                make.bottom.equalTo(bubbleView_Vestir.snp.bottom)
                make.width.height.equalTo(otherAvatarView_Vestir.isHidden ? 0 : 28)
            }

            bubbleView_Vestir.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(5)
                make.leading.equalToSuperview().offset(avatarLeading)
                make.trailing.lessThanOrEqualToSuperview().offset(-80)
                make.bottom.equalToSuperview().offset(-4)
            }
        }

        messageLabel_Vestir.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        timeLabel_Vestir.snp.makeConstraints { make in
            if isMine_Vestir {
                make.trailing.equalTo(bubbleView_Vestir)
            } else {
                let avatarLeading: CGFloat = otherAvatarView_Vestir.isHidden ? 0 : 30
                make.leading.equalTo(bubbleView_Vestir).offset(avatarLeading == 0 ? 0 : -avatarLeading)
            }
            make.top.equalTo(bubbleView_Vestir.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
}

// MARK: - 聊天页导航区渐变背景视图

/// 自管理渐变的聊天页导航区（深紫→靛蓝→湛蓝，下方双角圆角 24pt）
fileprivate final class MessageUserNavCard_Vestir: UIView {

    private let gradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradLayer_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 24
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Vestir.frame = bounds
    }
}

// MARK: - UITableView 安全 dequeue 扩展

private extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(
        withIdentifier identifier: String,
        for indexPath: IndexPath
    ) -> T? {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
    }
}
