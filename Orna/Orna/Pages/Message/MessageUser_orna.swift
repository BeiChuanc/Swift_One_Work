import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页面

/// 与用户聊天页面视图控制器
/// 核心作用：展示与指定用户的聊天记录，支持发送文本消息、发起视频通话、举报用户
/// 设计思路：
///   - 页面底色改为淡紫色（呼应消息列表/帖子详情等页面），承载消息气泡的"聊天壁纸"基调，
///     顶部工具条按钮与用户信息卡片改为白色背板 + 投影，在淡紫背景上清晰浮起
///   - 顶部卡片展示对方头像（描边环）/昵称/简介，点击卡片以"聊天入口"身份进入用户中心
///     （隐藏消息按钮、关注按钮居中；若在此取消关注会自动清空聊天记录并返回消息列表）
///   - 右上角举报按钮复用 ReportDeleteHelper_Orna 拉黑流程，成功后返回消息列表
///   - 消息气泡列表随 MessageViewModel_Orna 状态变化响应式刷新：本人消息使用紫粉渐变气泡右对齐，
///     对方消息使用白色描边气泡 + 头像左对齐，均带投影提升层次；无消息时展示统一风格缺省态
///   - 底部输入栏白色背板铺满至屏幕真正底部边缘，输入框聚焦时描边切换强调色，
///     发送按钮采用品牌渐变、视频通话按钮采用玫红强调色以作功能区分
/// 关键属性：
///   - userModel_Orna: 聊天对象用户模型
class MessageUser_Orna: UIViewController, UITextFieldDelegate {

    /// 聊天用户
    var userModel_Orna: PrewUserModel_Orna?

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    private lazy var reportButton_Orna: UIButton = {
        let b = ReportDeleteHelper_Orna.createUserReportButton_Orna(
            size_Orna: 36,
            backgroundColor_Orna: .white,
            tintColor_Orna: UIColor(hexstring_Orna: "#2D2A3D")
        )
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    // MARK: - UI · 用户信息卡片

    private let userCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.isUserInteractionEnabled = true
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 14
        return v
    }()

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.22).cgColor
        return v
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let bioLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.numberOfLines = 1
        return l
    }()

    private let cardChevron_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(hexstring_Orna: "#B5AFCB")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI · 消息列表

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let messagesStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    /// 无消息记录时的统一风格缺省态
    private let emptyStateView_Orna: EmptyStateView_Orna = {
        let v = EmptyStateView_Orna()
        v.configure_Orna(
            icon_orna: "bubble.left.and.bubble.right.fill",
            title_orna: "No messages yet",
            subtitle_orna: "Say hi and start the conversation!"
        )
        return v
    }()

    // MARK: - UI · 底部输入栏

    private let inputBarView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: -3)
        v.layer.shadowRadius = 10
        return v
    }()

    private let inputField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 14, weight: .regular)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "Type a message..."
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 20
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
        let padding_orna = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftView = padding_orna
        tf.leftViewMode = .always
        return tf
    }()

    /// 视频通话按钮：采用玫红强调色区别于发送按钮的品牌紫，便于两种操作一目了然
    private let videoCallButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(systemName: "video.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: "#FF6B9D")
        config_orna.contentInsets = .zero
        b.configuration = config_orna
        b.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.12)
        b.layer.cornerRadius = 20
        return b
    }()

    /// 发送按钮：采用 UIButton.Configuration 承载图标，确保图标稳定渲染在自定义渐变背板之上
    private let sendButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        config_orna.baseForegroundColor = .white
        config_orna.contentInsets = .zero
        b.configuration = config_orna
        b.layer.cornerRadius = 20
        b.clipsToBounds = true
        return b
    }()

    private var sendButtonGradientLayer_Orna: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendButtonGradientLayer_Orna?.frame = sendButton_Orna.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(backButton_Orna)
        view.addSubview(reportButton_Orna)

        view.addSubview(userCardView_Orna)
        userCardView_Orna.addSubview(avatarView_Orna)
        userCardView_Orna.addSubview(nameLabel_Orna)
        userCardView_Orna.addSubview(bioLabel_Orna)
        userCardView_Orna.addSubview(cardChevron_Orna)

        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(messagesStack_Orna)
        view.addSubview(emptyStateView_Orna)

        view.addSubview(inputBarView_Orna)
        inputBarView_Orna.addSubview(inputField_Orna)
        inputBarView_Orna.addSubview(videoCallButton_Orna)
        inputBarView_Orna.addSubview(sendButton_Orna)
        setupSendButtonGradient_Orna()
        inputField_Orna.delegate = self
    }

    /// 发送按钮紫粉渐变背景，与全 App 主要 CTA 按钮保持同一强调色
    private func setupSendButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        sendButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        sendButtonGradientLayer_Orna = layer_orna
    }

    private func setupConstraints_Orna() {
        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        reportButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(36)
        }

        userCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
        avatarView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(52)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalTo(cardChevron_Orna.snp.leading).offset(-8)
        }
        bioLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Orna)
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(4)
            $0.trailing.equalTo(cardChevron_Orna.snp.leading).offset(-8)
        }
        cardChevron_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }

        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(userCardView_Orna.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputBarView_Orna.snp.top)
        }
        messagesStack_Orna.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.width.equalToSuperview().offset(-40)
        }
        emptyStateView_Orna.snp.makeConstraints {
            $0.center.equalTo(scrollView_Orna)
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        // 输入栏白色背板铺满至屏幕真正底部边缘（而非止步于安全区），消除底部因安全区
        // 预留区域露出淡紫背景而产生的空隙；输入框与操作按钮则仍锚定在安全区之上
        inputBarView_Orna.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        inputField_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.height.equalTo(40)
        }
        videoCallButton_Orna.snp.makeConstraints {
            $0.leading.equalTo(inputField_Orna.snp.trailing).offset(10)
            $0.centerY.equalTo(inputField_Orna)
            $0.width.height.equalTo(40)
        }
        sendButton_Orna.snp.makeConstraints {
            $0.leading.equalTo(videoCallButton_Orna.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(inputField_Orna)
            $0.width.height.equalTo(40)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        reportButton_Orna.addTarget(self, action: #selector(handleReportTapped_Orna), for: .touchUpInside)
        sendButton_Orna.addTarget(self, action: #selector(handleSendTapped_Orna), for: .touchUpInside)
        videoCallButton_Orna.addTarget(self, action: #selector(handleVideoCallTapped_Orna), for: .touchUpInside)
        inputField_Orna.addTarget(self, action: #selector(handleSendTapped_Orna), for: .editingDidEndOnExit)

        let cardTap_orna = UITapGestureRecognizer(target: self, action: #selector(handleCardTapped_Orna))
        userCardView_Orna.addGestureRecognizer(cardTap_orna)
    }

    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: MessageViewModel_Orna.messageStateDidChangeNotification_Orna, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna, object: nil
        )
    }

    // MARK: - UITextFieldDelegate

    /// 输入框获得焦点时描边切换为强调色，提供清晰的聚焦反馈
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputField_Orna.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.5).cgColor
            self.inputField_Orna.backgroundColor = .white
        }
    }

    /// 输入框失去焦点时描边恢复为默认浅紫色
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputField_Orna.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
            self.inputField_Orna.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        }
    }

    // MARK: - 数据刷新

    @objc private func refreshAll_Orna() {
        guard let user_orna = userModel_Orna, let userId_orna = user_orna.userId_Orna else { return }

        avatarView_Orna.configure_Orna(userId_Orna: userId_orna)
        nameLabel_Orna.text = user_orna.userName_Orna
        bioLabel_Orna.text = (user_orna.userIntroduce_Orna?.isEmpty == false) ? user_orna.userIntroduce_Orna : "This wanderer hasn't written a bio yet."

        refreshMessages_Orna(userId_orna: userId_orna)
    }

    /// 刷新消息气泡列表，本人消息右对齐，对方消息左对齐并附带头像
    private func refreshMessages_Orna(userId_orna: Int) {
        messagesStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let messages_orna = MessageViewModel_Orna.shared_Orna.getMessagesWithUser_Orna(userId_orna: userId_orna)

        emptyStateView_Orna.isHidden = !messages_orna.isEmpty
        scrollView_Orna.isHidden = messages_orna.isEmpty

        for message_orna in messages_orna {
            let bubble_orna = MessageBubbleView_Orna()
            bubble_orna.configure_Orna(message_orna: message_orna, otherUserId_orna: userId_orna)
            messagesStack_Orna.addArrangedSubview(bubble_orna)
        }

        // 滚动到底部展示最新消息
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let bottomOffset_orna = CGPoint(
                x: 0,
                y: max(0, self.scrollView_Orna.contentSize.height - self.scrollView_Orna.bounds.height)
            )
            self.scrollView_Orna.setContentOffset(bottomOffset_orna, animated: false)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 点击用户信息卡片：以"聊天入口"身份进入用户中心（隐藏消息按钮，关注按钮居中）
    @objc private func handleCardTapped_Orna() {
        guard let user_orna = userModel_Orna else { return }
        Navigation_Orna.toUserInfo_Orna(with: user_orna, isFromChat_orna: true)
    }

    /// 举报按钮点击：拉黑该用户，成功后返回消息列表
    @objc private func handleReportTapped_Orna() {
        guard let user_orna = userModel_Orna else { return }
        ReportDeleteHelper_Orna.block_Orna(user_Orna: user_orna, from: self) { [weak self] in
            guard let self else { return }
            Navigation_Orna.popToMessageListAfterUnfollow_Orna(from: self)
        }
    }

    /// 发送按钮点击：校验非空后发送文本消息
    @objc private func handleSendTapped_Orna() {
        guard let userId_orna = userModel_Orna?.userId_Orna else { return }
        let text_orna = (inputField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_orna.isEmpty else { return }

        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }

        MessageViewModel_Orna.shared_Orna.sendMessage_Orna(message_orna: text_orna, chatType_orna: .personal_orna, id_orna: userId_orna)
        inputField_Orna.text = ""
    }

    /// 视频通话按钮点击
    @objc private func handleVideoCallTapped_Orna() {
        guard let user_orna = userModel_Orna else { return }
        Navigation_Orna.toVideoChat_Orna(with: user_orna)
    }
}

// MARK: - 消息气泡视图

/// 消息气泡视图
/// 核心作用：根据消息归属方自动切换左右对齐、配色与是否展示头像
/// 设计思路：本人消息使用紫粉渐变气泡右对齐（不展示头像，与输入者身份呼应）；
///           对方消息使用白色描边气泡 + 头像左对齐，头像复用聊天对象的用户头像组件
private class MessageBubbleView_Orna: UIView {

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private let bubbleView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 6
        return v
    }()

    private var bubbleGradientLayer_Orna: CAGradientLayer?

    private let contentLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    private let timeLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#B5AFCB")
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatarView_Orna)
        addSubview(bubbleView_Orna)
        bubbleView_Orna.addSubview(contentLabel_Orna)
        addSubview(timeLabel_Orna)

        avatarView_Orna.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        contentLabel_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleGradientLayer_Orna?.frame = bubbleView_Orna.bounds
    }

    /// 配置消息内容、头像与对齐方式
    /// 参数：
    /// - message_orna: 消息数据模型
    /// - otherUserId_orna: 对方用户ID（1对1 聊天中，所有"非本人"消息均来自该用户，用于展示头像）
    func configure_Orna(message_orna: MessageModel_Orna, otherUserId_orna: Int) {
        let isMine_orna = message_orna.isMine_Orna ?? false
        contentLabel_Orna.text = message_orna.content_Orna
        timeLabel_Orna.text = message_orna.time_Orna

        bubbleGradientLayer_Orna?.removeFromSuperlayer()
        bubbleGradientLayer_Orna = nil
        bubbleView_Orna.layer.borderWidth = 0

        if isMine_orna {
            avatarView_Orna.isHidden = true
            let layer_orna = CAGradientLayer()
            layer_orna.colors = [
                UIColor(hexstring_Orna: "#7B61FF").cgColor,
                UIColor(hexstring_Orna: "#FF6B9D").cgColor
            ]
            layer_orna.startPoint = CGPoint(x: 0, y: 0)
            layer_orna.endPoint = CGPoint(x: 1, y: 1)
            bubbleView_Orna.layer.insertSublayer(layer_orna, at: 0)
            bubbleGradientLayer_Orna = layer_orna
            contentLabel_Orna.textColor = .white

            bubbleView_Orna.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
                $0.trailing.equalToSuperview()
            }
            timeLabel_Orna.snp.remakeConstraints {
                $0.top.equalTo(bubbleView_Orna.snp.bottom).offset(4)
                $0.trailing.bottom.equalToSuperview()
            }
        } else {
            avatarView_Orna.isHidden = false
            avatarView_Orna.configure_Orna(userId_Orna: otherUserId_orna)
            bubbleView_Orna.backgroundColor = .white
            bubbleView_Orna.layer.borderWidth = 1
            bubbleView_Orna.layer.borderColor = UIColor(hexstring_Orna: "#F0EDFC").cgColor
            contentLabel_Orna.textColor = UIColor(hexstring_Orna: "#2D2A3D")

            bubbleView_Orna.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.width.lessThanOrEqualToSuperview().multipliedBy(0.68)
                $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(8)
            }
            timeLabel_Orna.snp.remakeConstraints {
                $0.top.equalTo(bubbleView_Orna.snp.bottom).offset(4)
                $0.leading.equalTo(bubbleView_Orna)
                $0.bottom.equalToSuperview()
            }
        }
    }
}
