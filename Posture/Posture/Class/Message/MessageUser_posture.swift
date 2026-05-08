import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页面

/// 与用户聊天页面控制器
/// 核心作用：展示指定用户聊天记录，支持发送消息和进入用户中心。
/// 设计思路：消息数据来自 `MessageViewModel_Posture`，页面监听通知响应刷新。
/// 关键属性：`messagesStackView_Posture` 渲染气泡，`inputField_Posture` 输入消息。
/// 关键方法：`sendMessage_Posture()` 发送消息，`reloadMessages_Posture()` 刷新聊天记录。
@MainActor
class MessageUser_Posture: UIViewController {
    
    /// 聊天用户
    var userModel_Posture: PrewUserModel_Posture?

    /// 消息滚动容器
    private let scrollView_Posture = UIScrollView()

    /// 消息列表
    private let messagesStackView_Posture = UIStackView()

    /// 输入框
    private let inputField_Posture = UITextField()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        reloadMessages_Posture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observeMessageState_Posture()
        reloadMessages_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 搭建聊天 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        let backButton_Posture = UIButton(type: .system)
        backButton_Posture.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton_Posture.tintColor = ColorConfig_Posture.textPrimary_Posture
        backButton_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)

        let reportButton_Posture = ReportDeleteHelper_Posture.createUserReportButton_Posture(size_Posture: 42, backgroundColor_Posture: ColorConfig_Posture.cardBackground_Posture, tintColor_Posture: ColorConfig_Posture.textSecondary_Posture, withShadow_Posture: true)
        reportButton_Posture.addAction(UIAction { [weak self] _ in
            guard let self_Posture = self, let user_Posture = self_Posture.userModel_Posture else { return }
            ReportDeleteHelper_Posture.block_Posture(user_Posture: user_Posture, from: self_Posture)
        }, for: .touchUpInside)

        let userCard_Posture = createUserCard_Posture()
        let inputBar_Posture = createInputBar_Posture()

        view.addSubview(backButton_Posture)
        view.addSubview(userCard_Posture)
        view.addSubview(reportButton_Posture)
        view.addSubview(scrollView_Posture)
        view.addSubview(inputBar_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        contentView_Posture.addSubview(messagesStackView_Posture)
        messagesStackView_Posture.axis = .vertical
        messagesStackView_Posture.spacing = 10

        backButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(42)
        }
        userCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(210)
            make.height.equalTo(72)
        }
        reportButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(42)
        }
        inputBar_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(58)
        }
        scrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(userCard_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Posture.snp.top).offset(-12)
        }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }
        messagesStackView_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    /// 创建顶部用户卡片
    /// - Parameters: 无
    /// - Returns: UIView - 用户卡片
    /// - Throws: 无
    private func createUserCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 24
        let avatar_Posture = UserAvatarView_Posture()
        let name_Posture = UILabel()
        name_Posture.text = userModel_Posture?.userName_Posture ?? "User"
        name_Posture.font = .systemFont(ofSize: 15, weight: .bold)
        name_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        let intro_Posture = UILabel()
        intro_Posture.text = userModel_Posture?.userIntroduce_Posture ?? "Posture friend"
        intro_Posture.font = .systemFont(ofSize: 11, weight: .medium)
        intro_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        intro_Posture.numberOfLines = 1
        avatar_Posture.configure_Posture(userId_Posture: userModel_Posture?.userId_Posture ?? 0)
        card_Posture.addSubview(avatar_Posture)
        card_Posture.addSubview(name_Posture)
        card_Posture.addSubview(intro_Posture)
        avatar_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        name_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(avatar_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
        }
        intro_Posture.snp.makeConstraints { make in
            make.top.equalTo(name_Posture.snp.bottom).offset(4)
            make.leading.trailing.equalTo(name_Posture)
        }
        card_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserInfo_Posture)))
        return card_Posture
    }

    /// 创建输入栏
    /// - Parameters: 无
    /// - Returns: UIView - 输入栏
    /// - Throws: 无
    private func createInputBar_Posture() -> UIView {
        let bar_Posture = UIView()
        bar_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        bar_Posture.layer.cornerRadius = 24
        inputField_Posture.placeholder = "Message"
        inputField_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        let sendButton_Posture = UIButton(type: .system)
        sendButton_Posture.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton_Posture.tintColor = .white
        sendButton_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        sendButton_Posture.layer.cornerRadius = 18
        sendButton_Posture.addAction(UIAction { [weak self] _ in self?.sendMessage_Posture() }, for: .touchUpInside)
        bar_Posture.addSubview(inputField_Posture)
        bar_Posture.addSubview(sendButton_Posture)
        inputField_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(sendButton_Posture.snp.leading).offset(-8)
        }
        sendButton_Posture.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(36)
        }
        return bar_Posture
    }

    /// 监听消息变化
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func observeMessageState_Posture() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleMessageState_Posture), name: MessageViewModel_Posture.messageStateDidChangeNotification_Posture, object: nil)
    }

    /// 消息变化回调
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handleMessageState_Posture() {
        reloadMessages_Posture()
    }

    /// 刷新消息
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func reloadMessages_Posture() {
        guard let userId_Posture = userModel_Posture?.userId_Posture, isViewLoaded else { return }
        messagesStackView_Posture.arrangedSubviews.forEach { view_Posture in
            messagesStackView_Posture.removeArrangedSubview(view_Posture)
            view_Posture.removeFromSuperview()
        }
        let messages_Posture = MessageViewModel_Posture.shared_Posture.getMessagesWithUser_Posture(userId_posture: userId_Posture)
        messages_Posture.forEach { message_Posture in
            messagesStackView_Posture.addArrangedSubview(MessageBubble_Posture(message_Posture: message_Posture))
        }
    }

    /// 发送消息
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func sendMessage_Posture() {
        guard let userId_Posture = userModel_Posture?.userId_Posture else { return }
        let text_Posture = (inputField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_Posture.isEmpty else { return }
        inputField_Posture.text = nil
        MessageViewModel_Posture.shared_Posture.sendMessage_Posture(message_posture: text_Posture, chatType_posture: .personal_posture, id_posture: userId_Posture)
    }

    /// 打开用户中心
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func openUserInfo_Posture() {
        guard let userModel_Posture else { return }
        Navigation_Posture.toUserInfo_Posture(with: userModel_Posture)
    }
}

/// 聊天气泡
/// 核心作用：展示单条聊天消息。
/// 设计思路：根据是否为当前用户消息控制左右对齐和颜色。
/// 关键属性：内部 `label_Posture` 展示消息文本。
/// 关键方法：初始化时传入消息模型。
@MainActor
private class MessageBubble_Posture: UIView {
    init(message_Posture: MessageModel_Posture) {
        super.init(frame: .zero)
        let label_Posture = UILabel()
        label_Posture.text = message_Posture.content_Posture
        label_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        label_Posture.numberOfLines = 0
        label_Posture.textColor = message_Posture.isMine_Posture == true ? .white : ColorConfig_Posture.textPrimary_Posture
        let bubble_Posture = UIView()
        bubble_Posture.backgroundColor = message_Posture.isMine_Posture == true ? ColorConfig_Posture.primaryGradientStart_Posture : ColorConfig_Posture.cardBackground_Posture
        bubble_Posture.layer.cornerRadius = 18
        addSubview(bubble_Posture)
        bubble_Posture.addSubview(label_Posture)
        bubble_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.76)
            if message_Posture.isMine_Posture == true {
                make.trailing.equalToSuperview()
            } else {
                make.leading.equalToSuperview()
            }
        }
        label_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
