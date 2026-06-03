import Foundation
import UIKit
import SnapKit

// MARK: 用户聊天界面

/// 与用户聊天视图控制器
/// 功能：展示聊天消息、发送消息、顶部卡片展示聊天对象信息、举报按钮
/// 设计：渐变顶部导航区、柔和背景渐变、调和气泡配色（我方辅助色/对方浅紫）、精致输入栏
class MessageUser_Bague: UIViewController {

    // MARK: - 属性

    /// 聊天对象用户数据
    var userModel_Bague: PrewUserModel_Bague?

    // MARK: - UI 组件（顶部导航区）

    /// 顶部渐变导航背景
    private let navBgView_Bague = UIView()
    private var navGradient_Bague: CAGradientLayer?

    /// 返回按钮（半透明胶囊）
    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    /// 顶部用户信息卡片（头像 + 姓名 + bio，居中）
    private let topCardView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v
    }()

    private let topAvatarView_Bague = UserAvatarView_Bague()

    private let topNameLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let topBioLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    /// 举报/更多按钮
    private let reportBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    // MARK: - UI 组件（消息列表）

    private let tableView_Bague: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.keyboardDismissMode = .interactive
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return tv
    }()

    // MARK: - UI 组件（输入栏）

    private let inputContainer_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 12
        return v
    }()

    private let inputBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#F5F0FF")
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1.2
        v.layer.borderColor = UIColor(hexstring_Bague: "#D4C4FF").cgColor
        return v
    }()

    private let inputField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        tf.returnKeyType = .send
        return tf
    }()

    private let sendBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 20
        return btn
    }()

    private var sendBtnGradient_Bague: CAGradientLayer?

    // MARK: - 数据

    private var messages_Bague: [MessageModel_Bague] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
        loadData_Bague()
        setupKeyboardObservers_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        // 背景：极浅灰到浅紫的轻柔渐变
        view.backgroundColor = UIColor(hexstring_Bague: "#F8F5FF")

        // 顶部导航区背景
        view.addSubview(navBgView_Bague)

        // 顶部控件
        view.addSubview(backBtn_Bague)
        view.addSubview(topCardView_Bague)
        topCardView_Bague.addSubview(topAvatarView_Bague)
        topCardView_Bague.addSubview(topNameLabel_Bague)
        topCardView_Bague.addSubview(topBioLabel_Bague)
        view.addSubview(reportBtn_Bague)

        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)
        reportBtn_Bague.addTarget(self, action: #selector(reportTapped_Bague), for: .touchUpInside)

        let cardTap_bague = UITapGestureRecognizer(target: self, action: #selector(topCardTapped_Bague))
        topCardView_Bague.addGestureRecognizer(cardTap_bague)
        topCardView_Bague.isUserInteractionEnabled = true

        // 消息列表
        view.addSubview(tableView_Bague)
        tableView_Bague.dataSource = self
        tableView_Bague.delegate = self
        tableView_Bague.register(MyChatCell_Bague.self, forCellReuseIdentifier: "MyChatCell_Bague")
        tableView_Bague.register(OtherChatCell_Bague.self, forCellReuseIdentifier: "OtherChatCell_Bague")

        // 输入栏
        view.addSubview(inputContainer_Bague)
        inputContainer_Bague.addSubview(inputBg_Bague)
        inputBg_Bague.addSubview(inputField_Bague)
        inputBg_Bague.addSubview(sendBtn_Bague)
        inputField_Bague.delegate = self
        sendBtn_Bague.addTarget(self, action: #selector(sendTapped_Bague), for: .touchUpInside)

        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Bague))
        bgTap_bague.cancelsTouchesInView = false
        view.addGestureRecognizer(bgTap_bague)
    }

    private func setupConstraints_Bague() {
        // 顶部渐变背景（延伸到 safeArea 之上）
        navBgView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(72)
        }

        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        // 用户卡片居中
        topCardView_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(APPSCREEN_Bague.WIDTH_Bague - 130)
            make.height.equalTo(56)
        }
        topAvatarView_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        topNameLabel_Bague.snp.makeConstraints { make in
            make.leading.equalTo(topAvatarView_Bague.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-12)
        }
        topBioLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(topNameLabel_Bague.snp.bottom).offset(2)
            make.leading.equalTo(topNameLabel_Bague)
            make.trailing.equalToSuperview().offset(-12)
        }

        // 右侧举报按钮
        reportBtn_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(topCardView_Bague)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }

        // 消息列表
        tableView_Bague.snp.makeConstraints { make in
            make.top.equalTo(topCardView_Bague.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainer_Bague.snp.top)
        }

        // 输入栏
        inputContainer_Bague.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-4)
            make.height.equalTo(68)
        }
        inputBg_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        sendBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        inputField_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalTo(sendBtn_Bague.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 渐变

    /// 更新顶部导航区渐变（三色斜角，与全局色系统一）和发送按钮渐变
    private func updateGradients_Bague() {
        navGradient_Bague?.removeFromSuperlayer()
        let nav_bague = CAGradientLayer()
        nav_bague.frame = navBgView_Bague.bounds
        nav_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        nav_bague.locations = [0.0, 0.6, 1.0]
        nav_bague.startPoint = CGPoint(x: 0, y: 0)
        nav_bague.endPoint = CGPoint(x: 1, y: 1)
        navBgView_Bague.layer.insertSublayer(nav_bague, at: 0)
        navGradient_Bague = nav_bague

        // 发送按钮：玫瑰粉 → 珊瑚橙（与发布页按钮同色系）
        sendBtnGradient_Bague?.removeFromSuperlayer()
        let btn_bague = CAGradientLayer()
        btn_bague.frame = sendBtn_Bague.bounds
        btn_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        btn_bague.startPoint = CGPoint(x: 0, y: 0)
        btn_bague.endPoint = CGPoint(x: 1, y: 1)
        btn_bague.cornerRadius = 20
        sendBtn_Bague.layer.insertSublayer(btn_bague, at: 0)
        sendBtnGradient_Bague = btn_bague
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataChanged_Bague),
            name: MessageViewModel_Bague.messageStateDidChangeNotification_Bague,
            object: nil
        )
    }

    @objc private func dataChanged_Bague() { loadData_Bague() }

    private func loadData_Bague() {
        guard let user_bague = userModel_Bague else { return }

        topAvatarView_Bague.configure_Bague(userId_Bague: user_bague.userId_Bague ?? 0)
        topNameLabel_Bague.text = user_bague.userName_Bague ?? "Unknown"
        topBioLabel_Bague.text = user_bague.userIntroduce_Bague ?? "Bag enthusiast"

        messages_Bague = MessageViewModel_Bague.shared_Bague
            .getMessagesWithUser_Bague(userId_bague: user_bague.userId_Bague ?? 0)

        tableView_Bague.reloadData()
        scrollToBottom_Bague()
    }

    private func scrollToBottom_Bague() {
        guard !messages_Bague.isEmpty else { return }
        let indexPath_bague = IndexPath(row: messages_Bague.count - 1, section: 0)
        tableView_Bague.scrollToRow(at: indexPath_bague, at: .bottom, animated: true)
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Bague(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Bague(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow_Bague(_ notification: Notification) {
        guard let frame_bague = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.inputContainer_Bague.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                    .offset(-(frame_bague.height - self.view.safeAreaInsets.bottom + 4))
            }
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration_bague) {
            self.scrollToBottom_Bague()
        }
    }

    @objc private func keyboardWillHide_Bague(_ notification: Notification) {
        guard let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.inputContainer_Bague.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-4)
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard_Bague() {
        view.endEditing(true)
    }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() {
        Navigation_Bague.pop_Bague()
    }

    @objc private func topCardTapped_Bague() {
        topCardView_Bague.animatePulse_Bague()
        guard let user_bague = userModel_Bague else { return }
        Navigation_Bague.toUserInfoFromChat_Bague(with: user_bague)
    }

    @objc private func reportTapped_Bague() {
        guard let user_bague = userModel_Bague else { return }
        ReportDeleteHelper_Bague.block_Bague(user_Bague: user_bague, from: self) {
            Navigation_Bague.popToSafeStateAfterBlock_Bague(from: self)
        }
    }

    @objc private func sendTapped_Bague() {
        guard let text_bague = inputField_Bague.text, !text_bague.isEmpty else {
            inputField_Bague.animateShake_Bague()
            return
        }
        guard let userId_bague = userModel_Bague?.userId_Bague else { return }

        inputField_Bague.text = ""
        sendBtn_Bague.animatePulse_Bague()

        Task { @MainActor in
            MessageViewModel_Bague.shared_Bague.sendMessage_Bague(
                message_bague: text_bague,
                chatType_bague: .personal_bague,
                id_bague: userId_bague
            )
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Bague: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Bague.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg_bague = messages_Bague[indexPath.row]
        if msg_bague.isMine_Bague == true {
            let cell_bague = tableView.dequeueReusableCell(
                withIdentifier: "MyChatCell_Bague",
                for: indexPath
            ) as! MyChatCell_Bague
            cell_bague.configure_Bague(message_bague: msg_bague)
            return cell_bague
        } else {
            let cell_bague = tableView.dequeueReusableCell(
                withIdentifier: "OtherChatCell_Bague",
                for: indexPath
            ) as! OtherChatCell_Bague
            let userId_bague = userModel_Bague?.userId_Bague ?? 0
            cell_bague.configure_Bague(message_bague: msg_bague, userId_bague: userId_bague)
            return cell_bague
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Bague()
        return true
    }
}

// MARK: - 渐变气泡视图（我方消息专用）

/// 以 CAGradientLayer 作为 backing layer 的气泡视图
/// 好处：渐变层与 view.bounds 自动同步，无需手动管理 frame，彻底避免渐变不渲染的问题
private class MyChatBubbleView_Bague: UIView {

    /// 将 backing layer 替换为 CAGradientLayer
    override class var layerClass: AnyClass { CAGradientLayer.self }

    /// 类型安全的渐变层访问
    var gradientLayer_Bague: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置渐变颜色、方向及圆角（发送方：右下角无圆角作为尾巴）
    private func setupLayer_Bague() {
        gradientLayer_Bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        gradientLayer_Bague.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Bague.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 18
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
    }
}

// MARK: - 我方消息气泡单元格

/// 我方发出的消息气泡（右对齐，玫瑰粉→珊瑚橙辅助渐变）
/// 气泡使用 MyChatBubbleView_Bague，渐变自动随 bounds 变化，无需 layoutSubviews 干预
class MyChatCell_Bague: UITableViewCell {

    /// 渐变气泡容器，backing layer 即为 CAGradientLayer
    private let bubbleView_Bague = MyChatBubbleView_Bague()

    private let msgLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(bubbleView_Bague)
        bubbleView_Bague.addSubview(msgLabel_Bague)
        contentView.addSubview(timeLabel_Bague)

        bubbleView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.greaterThanOrEqualToSuperview().offset(80)
        }
        msgLabel_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        timeLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(bubbleView_Bague.snp.bottom).offset(3)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    func configure_Bague(message_bague: MessageModel_Bague) {
        msgLabel_Bague.text = message_bague.content_Bague
        timeLabel_Bague.text = message_bague.time_Bague
    }
}

// MARK: - 对方消息气泡单元格

/// 对方发出的消息气泡（左对齐，浅紫色背景，文字深色）
class OtherChatCell_Bague: UITableViewCell {

    private let avatarView_Bague = UserAvatarView_Bague()

    private let bubbleView_Bague: UIView = {
        let v = UIView()
        // 浅紫色气泡，与全局色系调和
        v.backgroundColor = UIColor(hexstring_Bague: "#EDE8FF")
        v.layer.cornerRadius = 18
        v.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        v.layer.shadowColor = UIColor(hexstring_Bague: "#9B72F5").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 6
        return v
    }()

    private let msgLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(hexstring_Bague: "#4A3080")
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(avatarView_Bague)
        contentView.addSubview(bubbleView_Bague)
        bubbleView_Bague.addSubview(msgLabel_Bague)
        contentView.addSubview(timeLabel_Bague)

        avatarView_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }
        bubbleView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(avatarView_Bague.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-80)
        }
        msgLabel_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        timeLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(bubbleView_Bague.snp.bottom).offset(3)
            make.leading.equalTo(bubbleView_Bague)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    func configure_Bague(message_bague: MessageModel_Bague, userId_bague: Int) {
        avatarView_Bague.configure_Bague(userId_Bague: userId_bague)
        msgLabel_Bague.text = message_bague.content_Bague
        timeLabel_Bague.text = message_bague.time_Bague
    }
}
