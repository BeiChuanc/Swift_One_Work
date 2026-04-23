import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天界面
/// 核心作用：提供两人实时聊天界面，包含消息列表、输入框和视频通话入口
/// 设计思路：
///   - 沉浸式渐变顶栏（紧贴屏幕顶部，波浪底边）+ 头像 + 用户名 + 简介 + 返回/举报按钮
///   - UITableView 展示消息气泡（自己：右侧渐变气泡；对方：左侧白色气泡 + 头像）
///   - 底部输入栏（上方两角圆角 + 渐变发送按钮容器 + 视频通话按钮）
/// 联动逻辑：
///   - 从该页进入用户中心并取消关注 → 自动返回消息列表
///   - 响应 messageStateDidChangeNotification_Nest 实时更新消息
class MessageUser_Nest: UIViewController {

    // MARK: - 外部注入
    var userModel_Nest: PrewUserModel_Nest?

    // MARK: - 数据
    private var messages_Nest: [MessageModel_Nest] = []

    // MARK: - UI 组件

    /// 沉浸式渐变顶栏
    private let navBar_Nest = MsgUserNavBar_Nest()

    /// 消息列表
    private let tableView_Nest: UITableView = {
        let tv_Nest = UITableView(frame: .zero, style: .plain)
        tv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tv_Nest.separatorStyle  = .none
        tv_Nest.showsVerticalScrollIndicator = false
        tv_Nest.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv_Nest.register(MsgBubbleCell_Nest.self, forCellReuseIdentifier: MsgBubbleCell_Nest.reuseId_Nest)
        return tv_Nest
    }()

    // MARK: 底部输入栏

    private let inputBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 22
        v_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset  = CGSize(width: 0, height: -3)
        v_Nest.layer.shadowRadius  = 10
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    private let inputField_Nest: UITextField = {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = "Message..."
        tf_Nest.font = UIFont.systemFont(ofSize: 15)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tf_Nest.layer.cornerRadius = 20
        tf_Nest.layer.borderWidth  = 1.2
        tf_Nest.layer.borderColor  = ColorConfig_Nest.border_Nest.cgColor
        let pad_Nest = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf_Nest.leftView = pad_Nest
        tf_Nest.leftViewMode = .always
        tf_Nest.returnKeyType = .send
        return tf_Nest
    }()

    /// 视频通话按钮（渐变圆形容器）
    private let videoCallContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientEnd_Nest.withAlphaComponent(0.12)
        v_Nest.layer.cornerRadius = 20
        return v_Nest
    }()

    private let videoCallBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn_Nest.setImage(UIImage(systemName: "video.fill", withConfiguration: cfg_Nest), for: .normal)
        btn_Nest.tintColor = ColorConfig_Nest.primaryGradientEnd_Nest
        btn_Nest.backgroundColor = .clear
        return btn_Nest
    }()

    /// 发送按钮（使用容器避免 CAGradientLayer 遮挡图标）
    private let sendContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest
        v_Nest.layer.cornerRadius = 20
        return v_Nest
    }()

    private let sendBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_Nest.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Nest), for: .normal)
        btn_Nest.tintColor = .white
        btn_Nest.backgroundColor = .clear
        return btn_Nest
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        buildNavBar_Nest()
        buildTableView_Nest()
        buildInputBar_Nest()
        setupNotifications_Nest()
        setupKeyboardObserver_Nest()
        loadData_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Nest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBar_Nest.updateLayout_Nest()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 布局搭建

    private func buildNavBar_Nest() {
        view.addSubview(navBar_Nest)
        navBar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(110)
        }
        navBar_Nest.onBack_Nest   = { [weak self] in Navigation_Nest.pop_Nest(from: self) }
        navBar_Nest.onReport_Nest = { [weak self] in self?.onReportTapped_Nest() }
        navBar_Nest.onAvatarTap_Nest = { [weak self] in self?.onAvatarAreaTapped_Nest() }
    }

    private func buildTableView_Nest() {
        tableView_Nest.dataSource = self
        tableView_Nest.delegate   = self
        view.addSubview(tableView_Nest)
        // inputBar 尚未加入视图层级，bottom 先约束到 view 底部
        // 待 buildInputBar_Nest 将 inputBar 加入后再 remakeConstraints
        tableView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(navBar_Nest.snp.bottom)
            make_Nest.leading.trailing.equalToSuperview()
            make_Nest.bottom.equalToSuperview()
        }

        let tap_Nest = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Nest))
        tap_Nest.cancelsTouchesInView = false
        tableView_Nest.addGestureRecognizer(tap_Nest)
    }

    private func buildInputBar_Nest() {
        // 视频通话按钮
        videoCallContainer_Nest.addSubview(videoCallBtn_Nest)
        videoCallBtn_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        videoCallBtn_Nest.addTarget(self, action: #selector(onVideoCallTapped_Nest), for: .touchUpInside)

        // 发送按钮
        sendContainer_Nest.addSubview(sendBtn_Nest)
        sendBtn_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        sendBtn_Nest.addTarget(self, action: #selector(onSendTapped_Nest), for: .touchUpInside)

        inputBar_Nest.addSubview(videoCallContainer_Nest)
        inputBar_Nest.addSubview(inputField_Nest)
        inputBar_Nest.addSubview(sendContainer_Nest)
        view.addSubview(inputBar_Nest)

        // inputBar 已加入视图层级，重建 tableView 底部约束贴合 inputBar 顶部
        tableView_Nest.snp.remakeConstraints { make_Nest in
            make_Nest.top.equalTo(navBar_Nest.snp.bottom)
            make_Nest.leading.trailing.equalToSuperview()
            make_Nest.bottom.equalTo(inputBar_Nest.snp.top)
        }

        inputBar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.trailing.bottom.equalToSuperview()
            make_Nest.height.equalTo(66)
        }
        videoCallContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.centerY.equalToSuperview().offset(-2)
            make_Nest.width.height.equalTo(40)
        }
        sendContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.centerY.equalToSuperview().offset(-2)
            make_Nest.width.height.equalTo(40)
        }
        inputField_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(videoCallContainer_Nest.snp.trailing).offset(10)
            make_Nest.trailing.equalTo(sendContainer_Nest.snp.leading).offset(-10)
            make_Nest.centerY.equalTo(videoCallContainer_Nest)
            make_Nest.height.equalTo(40)
        }

        inputField_Nest.delegate = self
    }

    // MARK: - 通知 & 键盘

    private func setupNotifications_Nest() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChanged_Nest),
            name: MessageViewModel_Nest.messageStateDidChangeNotification_Nest, object: nil
        )
    }

    private func setupKeyboardObserver_Nest() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardShow_Nest(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardHide_Nest(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 数据加载

    private func loadData_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        navBar_Nest.configure_Nest(user: user_Nest)
        messages_Nest = MessageViewModel_Nest.shared_Nest.getMessagesWithUser_Nest(
            userId_nest: user_Nest.userId_Nest ?? 0
        )
        tableView_Nest.reloadData()
        scrollToBottom_Nest()
    }

    private func scrollToBottom_Nest() {
        guard !messages_Nest.isEmpty else { return }
        tableView_Nest.scrollToRow(
            at: IndexPath(row: messages_Nest.count - 1, section: 0),
            at: .bottom, animated: true
        )
    }

    // MARK: - 发送消息

    private func sendMessage_Nest() {
        guard let text_Nest = inputField_Nest.text,
              !text_Nest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let user_Nest = userModel_Nest,
              let uid_Nest = user_Nest.userId_Nest
        else { return }
        inputField_Nest.text = nil
        sendContainer_Nest.animatePressDown_Nest { self.sendContainer_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task {
            MessageViewModel_Nest.shared_Nest.sendMessage_Nest(
                message_nest: text_Nest, chatType_nest: .personal_nest, id_nest: uid_Nest
            )
        }
    }

    // MARK: - 事件

    private func onAvatarAreaTapped_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        let vc_Nest = UserInfo_Nest()
        vc_Nest.userModel_Nest   = user_Nest
        vc_Nest.isFromChat_Nest  = true
        vc_Nest.hideMessageBtn_Nest = true
        vc_Nest.onUnfollowed_Nest = { [weak self] in
            guard let self else { return }
            Navigation_Nest.popToRoot_Nest(from: self)
        }
        navigationController?.pushViewController(vc_Nest, animated: true)
    }

    private func onReportTapped_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        ReportDeleteHelper_Nest.block_Nest(user_Nest: user_Nest, from: self) { [weak self] in
            Navigation_Nest.pop_Nest(from: self)
        }
    }

    @objc private func onSendTapped_Nest()     { sendMessage_Nest() }
    @objc private func onVideoCallTapped_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        Navigation_Nest.toVideoChat_Nest(with: user_Nest)
    }
    @objc private func onStateChanged_Nest() { loadData_Nest() }
    @objc private func dismissKeyboard_Nest() { view.endEditing(true) }

    @objc private func onKeyboardShow_Nest(_ notification: Notification) {
        guard let kbFrame_Nest = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Nest = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        UIView.animate(withDuration: duration_Nest) {
            self.inputBar_Nest.snp.updateConstraints { make_Nest in
                make_Nest.bottom.equalToSuperview().offset(-kbFrame_Nest.height)
            }
            self.view.layoutIfNeeded()
        }
        scrollToBottom_Nest()
    }

    @objc private func onKeyboardHide_Nest(_ notification: Notification) {
        guard let duration_Nest = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        UIView.animate(withDuration: duration_Nest) {
            self.inputBar_Nest.snp.updateConstraints { make_Nest in
                make_Nest.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Nest: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages_Nest.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Nest = tableView.dequeueReusableCell(
            withIdentifier: MsgBubbleCell_Nest.reuseId_Nest, for: indexPath
        ) as? MsgBubbleCell_Nest else { return UITableViewCell() }
        cell_Nest.configure_Nest(
            message: messages_Nest[indexPath.row],
            otherUserId: userModel_Nest?.userId_Nest ?? 0
        )
        return cell_Nest
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 64 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Nest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage_Nest(); return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            textField.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            textField.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        }
    }
}

// MARK: - MsgUserNavBar_Nest
/// 聊天页沉浸式顶栏
/// 设计：主色渐变背景（紧贴屏幕顶部）+ 波浪底边 + 装饰气泡
/// 包含：返回按钮、渐变环头像 + 用户名 + 在线状态 + 简介、举报按钮
class MsgUserNavBar_Nest: UIView {

    var onBack_Nest:      (() -> Void)?
    var onReport_Nest:    (() -> Void)?
    var onAvatarTap_Nest: (() -> Void)?

    private var gradientLayer_Nest: CAGradientLayer?

    // 装饰气泡
    private let bubble1_Nest = MsgUserNavBar_Nest.makeBubble_Nest(size: 110, alpha: 0.08)
    private let bubble2_Nest = MsgUserNavBar_Nest.makeBubble_Nest(size: 60,  alpha: 0.10)

    // 返回按钮
    private let backBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()
    private let backIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    // 头像（渐变环）
    private let avatarRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 24
        v_Nest.clipsToBounds = true
        return v_Nest
    }()
    private var avatarRingGl_Nest: CAGradientLayer?
    private let avatarWhiteInner_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 21
        v_Nest.clipsToBounds = true
        return v_Nest
    }()
    private let avatarView_Nest = UserAvatarView_Nest()


    // 用户名 + 简介
    private let nameLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()
    private let bioLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 12)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl_Nest.numberOfLines = 1
        return lbl_Nest
    }()

    // 举报按钮
    private let reportBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()
    private let reportIcon_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "ellipsis", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)

        // 返回按钮
        backBtn_Nest.addSubview(backIcon_Nest)
        addSubview(backBtn_Nest)

        // 头像
        let gl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: CGRect(x: 0, y: 0, width: 48, height: 48))
        avatarRing_Nest.layer.insertSublayer(gl_Nest, at: 0)
        avatarRingGl_Nest = gl_Nest
        avatarRing_Nest.addSubview(avatarWhiteInner_Nest)
        avatarWhiteInner_Nest.addSubview(avatarView_Nest)
        addSubview(avatarRing_Nest)

        // 文字
        addSubview(nameLabel_Nest)
        addSubview(bioLabel_Nest)

        // 举报按钮
        reportBtn_Nest.addSubview(reportIcon_Nest)
        addSubview(reportBtn_Nest)

        // 气泡装饰
        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-20)
            make_Nest.trailing.equalToSuperview().offset(20)
            make_Nest.width.height.equalTo(110)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(15)
            make_Nest.trailing.equalToSuperview().offset(-70)
            make_Nest.width.height.equalTo(60)
        }

        // 返回
        backBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.width.height.equalTo(36)
        }
        backIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(15)
        }

        // 头像
        avatarRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(backBtn_Nest.snp.trailing).offset(10)
            make_Nest.centerY.equalTo(backBtn_Nest)
            make_Nest.width.height.equalTo(48)
        }
        avatarWhiteInner_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(42)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(36)
        }
        // 文字
        nameLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(avatarRing_Nest.snp.trailing).offset(10)
            make_Nest.top.equalTo(avatarRing_Nest).offset(4)
            make_Nest.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-8)
        }
        bioLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(nameLabel_Nest)
            make_Nest.top.equalTo(nameLabel_Nest.snp.bottom).offset(3)
            make_Nest.trailing.equalTo(nameLabel_Nest)
        }

        // 举报
        reportBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.centerY.equalTo(backBtn_Nest)
            make_Nest.width.height.equalTo(36)
        }
        reportIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.equalTo(26)
            make_Nest.height.equalTo(20)
        }

        // 手势
        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped_Nest)))
        reportBtn_Nest.isUserInteractionEnabled = true
        reportBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportTapped_Nest)))

        let avatarTap_Nest = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Nest))
        avatarRing_Nest.isUserInteractionEnabled = true
        avatarRing_Nest.addGestureRecognizer(avatarTap_Nest)
        nameLabel_Nest.isUserInteractionEnabled = true
        nameLabel_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Nest)))
    }

    /// 填充用户数据
    /// - Parameter user: 目标用户模型
    func configure_Nest(user: PrewUserModel_Nest) {
        avatarView_Nest.configure_Nest(userId_Nest: user.userId_Nest ?? 0)
        nameLabel_Nest.text = user.userName_Nest ?? "User"
        bioLabel_Nest.text  = user.userIntroduce_Nest?.isEmpty == false
            ? user.userIntroduce_Nest
            : "Tap to view profile"
    }

    /// 刷新渐变 frame + 波浪底边遮罩，在 viewDidLayoutSubviews 中调用
    func updateLayout_Nest() {
        gradientLayer_Nest?.frame = bounds
        avatarRingGl_Nest?.frame  = avatarRing_Nest.bounds

        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 12))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - 12),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + 18)
        )
        path_Nest.close()
        let mask_Nest = CAShapeLayer()
        mask_Nest.path = path_Nest.cgPath
        layer.mask = mask_Nest
    }

    @objc private func backTapped_Nest() {
        backBtn_Nest.animatePressDown_Nest { self.backBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onBack_Nest?()
    }

    @objc private func reportTapped_Nest() {
        reportBtn_Nest.animatePressDown_Nest { self.reportBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onReport_Nest?()
    }

    @objc private func avatarTapped_Nest() {
        avatarRing_Nest.animatePressDown_Nest { self.avatarRing_Nest.animatePressUp_Nest() }
        onAvatarTap_Nest?()
    }
}

// MARK: - MsgBubbleCell_Nest
/// 单条消息气泡 Cell
/// 自己发送：气泡靠右（主色渐变），白色文字，右侧无头像
/// 对方发送：气泡靠左（白色卡片），深色文字，左侧显示对方头像
private class MsgBubbleCell_Nest: UITableViewCell {

    static let reuseId_Nest = "MsgBubbleCell_Nest"

    private let avatarView_Nest = UserAvatarView_Nest()

    private let bubbleView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()
    private var bubbleGradient_Nest: CAGradientLayer?

    private let messageLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 15)
        lbl_Nest.numberOfLines = 0
        lbl_Nest.lineBreakMode = .byWordWrapping
        return lbl_Nest
    }()

    private let timeLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 10)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        return lbl_Nest
    }()

    private var bubbleLeading_Nest:  Constraint?
    private var bubbleTrailing_Nest: Constraint?
    private var avatarLeading_Nest:  Constraint?
    private var otherUserId_Nest: Int = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        buildCellUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildCellUI_Nest() {
        contentView.addSubview(avatarView_Nest)
        bubbleView_Nest.addSubview(messageLabel_Nest)
        contentView.addSubview(bubbleView_Nest)
        contentView.addSubview(timeLabel_Nest)

        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(8)
            avatarLeading_Nest = make_Nest.leading.equalToSuperview().offset(14).constraint
            make_Nest.width.height.equalTo(32)
        }

        bubbleView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(8)
            make_Nest.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            bubbleLeading_Nest  = make_Nest.leading.equalTo(avatarView_Nest.snp.trailing).offset(8).constraint
            bubbleTrailing_Nest = make_Nest.trailing.equalToSuperview().offset(-14).constraint
        }
        messageLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        timeLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(bubbleView_Nest.snp.bottom).offset(3)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.bottom.equalToSuperview().offset(-4)
        }

        bubbleLeading_Nest?.deactivate()
        bubbleTrailing_Nest?.deactivate()
    }

    /// 配置气泡内容
    /// - Parameters:
    ///   - message: 消息数据
    ///   - otherUserId: 对方用户 ID（用于展示对方头像）
    func configure_Nest(message: MessageModel_Nest, otherUserId: Int) {
        messageLabel_Nest.text = message.content_Nest
        timeLabel_Nest.text    = message.time_Nest

        if message.isMine_Nest == true {
            // 自己的消息：右侧渐变气泡，隐藏头像
            avatarView_Nest.isHidden = true
            bubbleLeading_Nest?.deactivate()
            bubbleTrailing_Nest?.activate()

            bubbleView_Nest.layer.sublayers?
                .filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
            gl_Nest.cornerRadius = 18
            bubbleView_Nest.layer.insertSublayer(gl_Nest, at: 0)
            bubbleGradient_Nest = gl_Nest

            bubbleView_Nest.backgroundColor = .clear
            messageLabel_Nest.textColor = .white
            timeLabel_Nest.textAlignment = .right
        } else {
            // 对方的消息：左侧白色气泡 + 头像
            avatarView_Nest.isHidden = false
            avatarView_Nest.configure_Nest(userId_Nest: otherUserId)
            bubbleTrailing_Nest?.deactivate()
            bubbleLeading_Nest?.activate()

            bubbleView_Nest.layer.sublayers?
                .filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            bubbleGradient_Nest = nil

            bubbleView_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
            bubbleView_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
            bubbleView_Nest.layer.shadowOffset  = CGSize(width: 0, height: 2)
            bubbleView_Nest.layer.shadowRadius  = 6
            bubbleView_Nest.layer.shadowOpacity = 1
            messageLabel_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
            timeLabel_Nest.textAlignment = .left
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradient_Nest?.frame = bubbleView_Nest.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleGradient_Nest = nil
        avatarView_Nest.isHidden = false
    }
}
