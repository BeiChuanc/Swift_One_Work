import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页面

/// 与用户聊天页面
/// 核心作用：承载与指定用户的单聊互动、视频通话入口和跳转用户中心
/// 设计思路：顶部信息卡 + 中部消息流 + 底部输入工具栏，所有状态均由消息视图模型驱动
class MessageUser_Epoch: UIViewController {
    
    /// 聊天用户
    var userModel_Epoch: PrewUserModel_Epoch?

    /// 背景装饰
    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    /// 聊天消息
    private var messages_Epoch: [MessageModel_Epoch] = []

    /// 顶部信息卡
    private let headerCardButton_Epoch = UIButton(type: .custom)

    /// 头像
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 名称
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 简介
    private let introLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 举报按钮
    private lazy var reportButton_Epoch: UIButton = {
        let button_Epoch = ReportDeleteHelper_Epoch.createUserReportButton_Epoch(
            size_Epoch: 34,
            backgroundColor_Epoch: ColorConfig_Epoch.backgroundPrimary_Epoch,
            tintColor_Epoch: ColorConfig_Epoch.textPrimary_Epoch,
            withShadow_Epoch: false
        )
        return button_Epoch
    }()

    /// 消息表格
    private let tableView_Epoch: UITableView = {
        let tableView_Epoch = UITableView(frame: .zero, style: .plain)
        tableView_Epoch.backgroundColor = .clear
        tableView_Epoch.separatorStyle = .none
        tableView_Epoch.showsVerticalScrollIndicator = false
        tableView_Epoch.rowHeight = UITableView.automaticDimension
        tableView_Epoch.estimatedRowHeight = 72
        return tableView_Epoch
    }()

    /// 输入容器
    private let composerView_Epoch = UIView()

    /// 输入框
    private let inputTextField_Epoch: UITextField = {
        let textField_Epoch = UITextField()
        textField_Epoch.placeholder = "Type a message"
        textField_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textField_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return textField_Epoch
    }()

    /// 发送按钮
    private let sendButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Send")

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Epoch(scrollToBottom_Epoch: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch(scrollToBottom_Epoch: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 构建界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch

        let backButton_epoch = UIButton(type: .system)
        backButton_epoch.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton_epoch.tintColor = ColorConfig_Epoch.textPrimary_Epoch
        backButton_epoch.addTarget(self, action: #selector(backTapped_Epoch), for: .touchUpInside)

        let headerCard_epoch = SurfaceCardView_Epoch()

        composerView_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        composerView_Epoch.layer.cornerRadius = 24
        composerView_Epoch.layer.borderWidth = 1
        composerView_Epoch.layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor

        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(backButton_epoch)
        view.addSubview(headerCard_epoch)
        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerCard_epoch.addSubview(headerCardButton_Epoch)
        headerCard_epoch.addSubview(avatarView_Epoch)
        headerCard_epoch.addSubview(nameLabel_Epoch)
        headerCard_epoch.addSubview(introLabel_Epoch)
        headerCard_epoch.addSubview(reportButton_Epoch)
        view.addSubview(tableView_Epoch)
        view.addSubview(composerView_Epoch)
        composerView_Epoch.addSubview(inputTextField_Epoch)
        composerView_Epoch.addSubview(sendButton_Epoch)

        backButton_epoch.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(18)
            make.width.height.equalTo(32)
        }

        headerCard_epoch.snp.makeConstraints { make in
            make.top.equalTo(backButton_epoch.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(16)
            make.width.height.equalTo(58)
        }

        reportButton_Epoch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }

        nameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalTo(avatarView_Epoch.snp.right).offset(14)
            make.right.lessThanOrEqualTo(reportButton_Epoch.snp.left).offset(-10)
        }

        introLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Epoch.snp.bottom).offset(6)
            make.left.equalTo(nameLabel_Epoch)
            make.right.lessThanOrEqualTo(reportButton_Epoch.snp.left).offset(-10)
            make.bottom.lessThanOrEqualToSuperview().offset(-18)
        }

        headerCardButton_Epoch.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(introLabel_Epoch.snp.right)
        }

        composerView_Epoch.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(64)
        }

        sendButton_Epoch.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().inset(8)
            make.width.equalTo(90)
        }

        inputTextField_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.right.equalTo(sendButton_Epoch.snp.left).offset(-10)
        }

        tableView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(headerCard_epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(composerView_Epoch.snp.top).offset(-10)
        }

        tableView_Epoch.register(MessageBubbleCell_Epoch.self, forCellReuseIdentifier: "MessageBubbleCell_Epoch")
        tableView_Epoch.dataSource = self
        tableView_Epoch.delegate = self
        inputTextField_Epoch.delegate = self
        headerCardButton_Epoch.addTarget(self, action: #selector(headerTapped_Epoch), for: .touchUpInside)
        reportButton_Epoch.addTarget(self, action: #selector(reportTapped_Epoch), for: .touchUpInside)
        sendButton_Epoch.addTarget(self, action: #selector(sendTapped_Epoch), for: .touchUpInside)
    }

    /// 注册通知
    private func setupNotifications_Epoch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: MessageViewModel_Epoch.messageStateDidChangeNotification_Epoch,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    /// 刷新数据
    /// - Parameter scrollToBottom_Epoch: 是否滚动到底部
    private func reloadData_Epoch(scrollToBottom_Epoch: Bool) {
        guard let userModel_Epoch = userModel_Epoch, let userId_epoch = userModel_Epoch.userId_Epoch else { return }
        self.userModel_Epoch = UserViewModel_Epoch.shared_Epoch.getUserById_Epoch(userId_epoch: userId_epoch)
        guard let refreshedUser_epoch = self.userModel_Epoch else { return }

        MessageViewModel_Epoch.shared_Epoch.startConversationIfNeeded_Epoch(userId_epoch: userId_epoch)
        messages_Epoch = MessageViewModel_Epoch.shared_Epoch.getMessagesWithUser_Epoch(userId_epoch: userId_epoch)
        nameLabel_Epoch.text = refreshedUser_epoch.userName_Epoch
        introLabel_Epoch.text = refreshedUser_epoch.userIntroduce_Epoch
        avatarView_Epoch.configure_Epoch(userId_Epoch: userId_epoch)
        tableView_Epoch.reloadData()
        if scrollToBottom_Epoch {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToBottom_Epoch()
            }
        }
    }

    /// 滚动到底部
    private func scrollToBottom_Epoch() {
        guard !messages_Epoch.isEmpty else { return }
        let indexPath_epoch = IndexPath(row: messages_Epoch.count - 1, section: 0)
        tableView_Epoch.scrollToRow(at: indexPath_epoch, at: .bottom, animated: true)
    }

    /// 发送消息
    private func submitMessage_Epoch() {
        guard let userId_epoch = userModel_Epoch?.userId_Epoch else { return }
        let text_epoch = inputTextField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_epoch.isEmpty else { return }
        MessageViewModel_Epoch.shared_Epoch.sendMessage_Epoch(
            message_epoch: text_epoch,
            chatType_epoch: .personal_epoch,
            id_epoch: userId_epoch
        )
        inputTextField_Epoch.text = nil
        reloadData_Epoch(scrollToBottom_Epoch: true)
    }

    /// 返回
    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch()
    }

    /// 打开用户中心
    @objc private func headerTapped_Epoch() {
        guard let userModel_Epoch = userModel_Epoch else { return }
        Navigation_Epoch.toUserInfo_Epoch(with: userModel_Epoch, entrySource_epoch: .message_epoch)
    }

    /// 举报用户
    @objc private func reportTapped_Epoch() {
        guard let userModel_Epoch = userModel_Epoch else { return }
        ReportDeleteHelper_Epoch.block_Epoch(user_Epoch: userModel_Epoch, from: self) {
            Navigation_Epoch.switchToTabbar_Epoch(animated: true, selectedIndex_epoch: 3)
        }
    }

    /// 发送按钮
    @objc private func sendTapped_Epoch() {
        submitMessage_Epoch()
    }

    /// 状态变化
    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch(scrollToBottom_Epoch: false)
    }
}

// MARK: - UITableViewDataSource

extension MessageUser_Epoch: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Epoch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_epoch = tableView.dequeueReusableCell(withIdentifier: "MessageBubbleCell_Epoch", for: indexPath) as? MessageBubbleCell_Epoch else {
            return UITableViewCell()
        }
        cell_epoch.configure_Epoch(message_epoch: messages_Epoch[indexPath.row])
        return cell_epoch
    }
}

// MARK: - UITableViewDelegate

extension MessageUser_Epoch: UITableViewDelegate {}

// MARK: - UITextFieldDelegate

extension MessageUser_Epoch: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitMessage_Epoch()
        return true
    }
}

// MARK: - 消息气泡单元格

/// 消息气泡单元格
private final class MessageBubbleCell_Epoch: UITableViewCell {

    /// 气泡背景
    private let bubbleView_Epoch = UIView()

    /// 消息文本
    private let messageLabel_Epoch = UILabel()

    /// 时间标签
    private let timeLabel_Epoch = UILabel()

    /// 左对齐约束
    private var leftAlignConstraint_Epoch: Constraint?

    /// 右对齐约束
    private var rightAlignConstraint_Epoch: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView_Epoch.layer.cornerRadius = 18
        messageLabel_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        messageLabel_Epoch.numberOfLines = 0
        timeLabel_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        timeLabel_Epoch.textColor = ColorConfig_Epoch.textPlaceholder_Epoch

        contentView.addSubview(bubbleView_Epoch)
        bubbleView_Epoch.addSubview(messageLabel_Epoch)
        contentView.addSubview(timeLabel_Epoch)

        bubbleView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.greaterThanOrEqualToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            self.leftAlignConstraint_Epoch = make.left.equalToSuperview().offset(16).constraint
            self.rightAlignConstraint_Epoch = make.right.equalToSuperview().offset(-16).constraint
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
        }

        messageLabel_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }

        timeLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(bubbleView_Epoch.snp.bottom).offset(4)
            make.left.right.equalTo(bubbleView_Epoch)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置消息样式
    /// - Parameter message_epoch: 消息模型
    func configure_Epoch(message_epoch: MessageModel_Epoch) {
        let isMine_epoch = message_epoch.isMine_Epoch ?? false
        bubbleView_Epoch.backgroundColor = isMine_epoch
            ? ColorConfig_Epoch.primaryGradientStart_Epoch
            : ColorConfig_Epoch.backgroundSecondary_Epoch
        messageLabel_Epoch.textColor = isMine_epoch ? .white : ColorConfig_Epoch.textPrimary_Epoch
        messageLabel_Epoch.text = message_epoch.content_Epoch
        timeLabel_Epoch.text = message_epoch.time_Epoch
        if isMine_epoch {
            leftAlignConstraint_Epoch?.deactivate()
            rightAlignConstraint_Epoch?.activate()
        } else {
            rightAlignConstraint_Epoch?.deactivate()
            leftAlignConstraint_Epoch?.activate()
        }
        timeLabel_Epoch.textAlignment = isMine_epoch ? .right : .left
    }
}
