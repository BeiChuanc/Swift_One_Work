import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天页面视图控制器

/// 与用户聊天页面视图控制器
/// 功能：顶部用户信息卡、消息气泡列表、底部输入框 + 发送按钮
/// 设计：渐变用户卡片（头像 + 名称 + 简介）+ 精美气泡（有尾角、投影）+ 橙色发送按钮
/// 逻辑：取消关注后返回消息列表并移除会话；举报用户后安全导航
class MessageUser_Maki: UIViewController {

    // MARK: - 对外属性
    var userModel_Maki: PrewUserModel_Maki?

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary  = UIColor(hexstring_Maki: "#FF8C00")
        static let bg       = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp       = UIColor(hexstring_Maki: "#1A0A00")
        static let ts       = UIColor(hexstring_Maki: "#8B7355")
        static let mineBg   = UIColor(hexstring_Maki: "#FF8C00")
        static let otherBg  = UIColor.white
        static let cellId   = "MsgBubbleCell_Maki"
    }

    // MARK: - UI 属性 / 顶部用户卡片

    private let userCard_Maki = UIView()
    private let userCardGrad_Maki = CAGradientLayer()
    private let cardAvatarRing_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v_maki.layer.cornerRadius = 26
        return v_maki
    }()
    private let cardAvatarView_Maki = UserAvatarView_Maki()
    private let cardNameLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont(name: "Georgia-Bold", size: 16)
            ?? .systemFont(ofSize: 16, weight: .bold)
        lb_maki.textColor = .white
        return lb_maki
    }()
    private let cardBioLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12, weight: .light)
        lb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
        lb_maki.numberOfLines = 1
        return lb_maki
    }()
    /// 在线装饰绿点
    private let onlineDot_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#52C41A")
        v_maki.layer.cornerRadius = 5
        v_maki.layer.borderWidth = 1.5
        v_maki.layer.borderColor = UIColor.white.cgColor
        return v_maki
    }()

    // MARK: - UI 属性 / 消息列表

    private let tableView_Maki: UITableView = {
        let tv_maki = UITableView()
        tv_maki.backgroundColor    = .clear
        tv_maki.separatorStyle     = .none
        tv_maki.keyboardDismissMode = .onDrag
        return tv_maki
    }()

    // MARK: - UI 属性 / 底部输入区

    private let inputBar_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: -2)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let inputTF_Maki: UITextField = {
        let tf_maki = UITextField()
        tf_maki.placeholder = "Type a message..."
        tf_maki.font = .systemFont(ofSize: 15)
        tf_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        tf_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF5E8")
        tf_maki.layer.cornerRadius = 20
        tf_maki.layer.borderWidth  = 1
        tf_maki.layer.borderColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.2).cgColor
        tf_maki.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf_maki.leftViewMode = .always
        tf_maki.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf_maki.rightViewMode = .always
        tf_maki.returnKeyType = .send
        return tf_maki
    }()
    private let sendBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        btn_maki.layer.cornerRadius = 18
        btn_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.4).cgColor
        btn_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn_maki.layer.shadowRadius = 6
        btn_maki.layer.shadowOpacity = 1
        return btn_maki
    }()
    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        setupNavBar_Maki()
        buildUI_Maki()
        bindKeyboard_Maki()
        bindNotifications_Maki()
        reloadMessages_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadMessages_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userCardGrad_Maki.frame = userCard_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - 导航栏（自定义，隐藏系统导航栏）

extension MessageUser_Maki {

    private func setupNavBar_Maki() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - UI 构建

extension MessageUser_Maki {

    private func buildUI_Maki() {
        buildUserCard_Maki()
        buildInputBar_Maki()
        buildMessageList_Maki()
    }

    /// 构建顶部渐变用户信息卡（返回 + 头像 + 名字 + 简介 + 举报按钮）
    private func buildUserCard_Maki() {
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        // 渐变背景
        userCardGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        userCardGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        userCardGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        userCard_Maki.layer.insertSublayer(userCardGrad_Maki, at: 0)

        // 圆角装饰气泡
        let bubble_maki = UIView()
        bubble_maki.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        bubble_maki.layer.cornerRadius = 40
        userCard_Maki.addSubview(bubble_maki)

        view.addSubview(userCard_Maki)
        userCard_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        bubble_maki.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.trailing.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(-10)
        }

        // 返回按钮
        let backBtn_maki = UIButton(type: .system)
        backBtn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backBtn_maki.tintColor = .white
        backBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_maki.layer.cornerRadius = 18
        backBtn_maki.layer.borderWidth = 1.5
        backBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backBtn_maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)
        userCard_Maki.addSubview(backBtn_maki)
        backBtn_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(36)
        }

        // 举报按钮
        let reportBtn_maki = UIButton(type: .system)
        reportBtn_maki.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        reportBtn_maki.tintColor = .white
        reportBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        reportBtn_maki.layer.cornerRadius = 18
        reportBtn_maki.layer.borderWidth = 1.5
        reportBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        reportBtn_maki.addTarget(self, action: #selector(onReportUser_Maki), for: .touchUpInside)
        userCard_Maki.addSubview(reportBtn_maki)
        reportBtn_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backBtn_maki)
            make.width.height.equalTo(36)
        }

        // 头像光晕圈
        userCard_Maki.addSubview(cardAvatarRing_Maki)
        cardAvatarRing_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(statusH_maki + 56)
            make.width.height.equalTo(52)
        }

        // 头像
        cardAvatarView_Maki.layer.cornerRadius = 20
        cardAvatarView_Maki.clipsToBounds = true
        cardAvatarView_Maki.layer.borderWidth = 2.5
        cardAvatarView_Maki.layer.borderColor = UIColor.white.cgColor
        userCard_Maki.addSubview(cardAvatarView_Maki)
        cardAvatarView_Maki.snp.makeConstraints { make in
            make.center.equalTo(cardAvatarRing_Maki)
            make.width.height.equalTo(40)
        }

        // 在线绿点
        userCard_Maki.addSubview(onlineDot_Maki)
        onlineDot_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.trailing.equalTo(cardAvatarView_Maki.snp.trailing).offset(1)
            make.bottom.equalTo(cardAvatarView_Maki.snp.bottom).offset(1)
        }

        // 名字 + 简介
        userCard_Maki.addSubview(cardNameLb_Maki)
        cardNameLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(cardAvatarRing_Maki.snp.trailing).offset(12)
            make.top.equalTo(cardAvatarRing_Maki).offset(4)
            make.trailing.equalTo(reportBtn_maki.snp.leading).offset(-8)
        }
        userCard_Maki.addSubview(cardBioLb_Maki)
        cardBioLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(cardNameLb_Maki)
            make.top.equalTo(cardNameLb_Maki.snp.bottom).offset(3)
            make.trailing.equalTo(cardNameLb_Maki)
        }

        // 底部圆角过渡条（驱动 userCard 高度）
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 18
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        userCard_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(cardBioLb_Maki.snp.bottom).offset(12)
            make.height.equalTo(22)
            make.bottom.equalToSuperview()
        }

        // 填充用户数据
        if let user_maki = userModel_Maki {
            cardAvatarView_Maki.configure_Maki(userId_Maki: user_maki.userId_Maki ?? 0)
            cardNameLb_Maki.text = user_maki.userName_Maki
            cardBioLb_Maki.text = user_maki.userIntroduce_Maki?.isEmpty == false
                ? user_maki.userIntroduce_Maki
                : "Craft · Create · Share"
        }

        // 点击卡片进入用户主页
        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onUserCardTap_Maki))
        userCard_Maki.isUserInteractionEnabled = true
        userCard_Maki.addGestureRecognizer(tap_maki)
    }

    /// 构建底部输入区（输入框 + 发送按钮）
    private func buildInputBar_Maki() {
        view.addSubview(inputBar_Maki)
        inputBar_Maki.addSubview(inputTF_Maki)
        inputBar_Maki.addSubview(sendBtn_Maki)
        inputBar_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(64)
        }
        sendBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        inputTF_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendBtn_Maki.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(42)
        }
        sendBtn_Maki.addTarget(self, action: #selector(onSend_Maki), for: .touchUpInside)
        inputTF_Maki.delegate = self
    }

    /// 构建消息列表 TableView
    private func buildMessageList_Maki() {
        tableView_Maki.dataSource = self
        tableView_Maki.delegate   = self
        tableView_Maki.register(MsgBubbleCell_Maki.self, forCellReuseIdentifier: K_Maki.cellId)
        view.addSubview(tableView_Maki)
        tableView_Maki.snp.makeConstraints { make in
            make.top.equalTo(userCard_Maki.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Maki.snp.top)
        }
    }
}

// MARK: - 数据刷新

extension MessageUser_Maki {

    private func reloadMessages_Maki() {
        tableView_Maki.reloadData()
        scrollToBottom_Maki()
    }

    private func scrollToBottom_Maki() {
        guard let userId_maki = userModel_Maki?.userId_Maki else { return }
        let count_maki = MessageViewModel_Maki.shared_Maki.getMessagesWithUser_Maki(userId_maki: userId_maki).count
        guard count_maki > 0 else { return }
        tableView_Maki.scrollToRow(at: IndexPath(row: count_maki - 1, section: 0), at: .bottom, animated: true)
    }
}

// MARK: - 键盘

extension MessageUser_Maki {

    private func bindKeyboard_Maki() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardChange_Maki(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
    }

    @objc private func onKeyboardChange_Maki(_ notification: Notification) {
        guard let kbFrame_maki = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_maki = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let kbH_maki = max(0, view.frame.height - kbFrame_maki.origin.y)
        UIView.animate(withDuration: duration_maki) {
            self.inputBar_Maki.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-kbH_maki)
            }
            self.view.layoutIfNeeded()
        }
        scrollToBottom_Maki()
    }
}

// MARK: - 通知

extension MessageUser_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(self, selector: #selector(onMsgChange_Maki),
            name: MessageViewModel_Maki.messageStateDidChangeNotification_Maki, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki, object: nil)
    }

    @objc private func onMsgChange_Maki() { reloadMessages_Maki() }

    /// 用户状态变化：检查是否取消关注，若取消则清除会话并返回
    @objc private func onUserChange_Maki() {
        guard let user_maki = userModel_Maki else { return }
        if !UserViewModel_Maki.shared_Maki.isFollowing_Maki(user_maki: user_maki) {
            MessageViewModel_Maki.shared_Maki.deleteUserMessages_Maki(userId_maki: user_maki.userId_Maki ?? 0)
            Navigation_Maki.pop_Maki()
        }
    }
}

// MARK: - 事件响应

extension MessageUser_Maki {

    @objc private func onBack_Maki() { Navigation_Maki.pop_Maki() }

    @objc private func onUserCardTap_Maki() {
        guard let user_maki = userModel_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toUserInfo_Maki(with: user_maki)
    }

    @objc private func onSend_Maki() {
        let text_maki = inputTF_Maki.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_maki.isEmpty, let userId_maki = userModel_Maki?.userId_Maki else { return }
        inputTF_Maki.text = nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // 发送按钮弹性动画
        UIView.animate(withDuration: 0.1, animations: {
            self.sendBtn_Maki.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.6, options: [],
                animations: { self.sendBtn_Maki.transform = .identity }
            )
        })
        MessageViewModel_Maki.shared_Maki.sendMessage_Maki(
            message_maki: text_maki, chatType_maki: .personal_maki, id_maki: userId_maki
        )
    }

    @objc private func onReportUser_Maki() {
        guard let user_maki = userModel_Maki else { return }
        UIAlertController.report_Maki(with: true) { [weak self] in
            guard let self else { return }
            MessageViewModel_Maki.shared_Maki.deleteUserMessages_Maki(userId_maki: user_maki.userId_Maki ?? 0)
            UserViewModel_Maki.shared_Maki.reportUser_Maki(user_maki: user_maki)
            Navigation_Maki.popToSafeStateAfterBlock_Maki(from: self)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension MessageUser_Maki: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userId_maki = userModel_Maki?.userId_Maki else { return 0 }
        return MessageViewModel_Maki.shared_Maki.getMessagesWithUser_Maki(userId_maki: userId_maki).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_maki = tableView.dequeueReusableCell(
            withIdentifier: K_Maki.cellId, for: indexPath
        ) as! MsgBubbleCell_Maki
        guard let userId_maki = userModel_Maki?.userId_Maki else { return cell_maki }
        let msgs_maki = MessageViewModel_Maki.shared_Maki.getMessagesWithUser_Maki(userId_maki: userId_maki)
        guard indexPath.row < msgs_maki.count else { return cell_maki }
        cell_maki.configure_Maki(msg_maki: msgs_maki[indexPath.row], otherUserId_maki: userId_maki)
        return cell_maki
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 64 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Maki: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSend_Maki(); return true
    }
}

// MARK: - MsgBubbleCell_Maki（消息气泡 Cell）

/// 消息气泡表格 Cell
/// 功能：根据 isMine 展示右侧橙色气泡（我）或左侧白色气泡（对方）；带时间戳
/// 设计：气泡有非对称圆角（尾角效果）+ 对方气泡带阴影 + 时间戳对齐
final class MsgBubbleCell_Maki: UITableViewCell {

    // MARK: UI 子视图

    private let bubbleView_Maki: UIView = {
        let v_maki = UIView()
        return v_maki
    }()
    private let msgLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 15)
        lb_maki.numberOfLines = 0
        return lb_maki
    }()
    private let timeLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 10)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355").withAlphaComponent(0.7)
        return lb_maki
    }()
    private var leadingConstraint_Maki: Constraint?
    private var trailingConstraint_Maki: Constraint?

    // MARK: 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        contentView.addSubview(bubbleView_Maki)
        bubbleView_Maki.addSubview(msgLabel_Maki)
        contentView.addSubview(timeLabel_Maki)

        bubbleView_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalTo(timeLabel_Maki.snp.top).offset(-4)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            leadingConstraint_Maki  = make.leading.equalToSuperview().offset(16).constraint
            trailingConstraint_Maki = make.trailing.equalToSuperview().offset(-16).constraint
        }
        leadingConstraint_Maki?.deactivate()
        trailingConstraint_Maki?.deactivate()

        msgLabel_Maki.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        timeLabel_Maki.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: 配置

    func configure_Maki(msg_maki: MessageModel_Maki, otherUserId_maki: Int) {
        let isMine_maki = msg_maki.isMine_Maki ?? false
        msgLabel_Maki.text  = msg_maki.content_Maki
        timeLabel_Maki.text = msg_maki.time_Maki

        if isMine_maki {
            // 我的消息：右侧橙色气泡，右下角无圆角（尾角效果）
            bubbleView_Maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
            bubbleView_Maki.layer.cornerRadius = 18
            bubbleView_Maki.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner
            ]
            bubbleView_Maki.layer.shadowOpacity = 0
            msgLabel_Maki.textColor = .white
            leadingConstraint_Maki?.deactivate()
            trailingConstraint_Maki?.activate()
            timeLabel_Maki.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-6)
                make.trailing.equalTo(bubbleView_Maki)
            }
        } else {
            // 对方消息：左侧白色气泡 + 阴影，左下角无圆角（尾角效果）
            bubbleView_Maki.backgroundColor = .white
            bubbleView_Maki.layer.cornerRadius = 18
            bubbleView_Maki.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner
            ]
            bubbleView_Maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.07).cgColor
            bubbleView_Maki.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Maki.layer.shadowRadius = 5
            bubbleView_Maki.layer.shadowOpacity = 1
            msgLabel_Maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
            trailingConstraint_Maki?.deactivate()
            leadingConstraint_Maki?.activate()
            timeLabel_Maki.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-6)
                make.leading.equalTo(bubbleView_Maki)
            }
        }
    }
}
