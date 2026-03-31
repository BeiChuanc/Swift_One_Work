import Foundation
import UIKit
import SnapKit

// MARK: - 与用户聊天页面

/// 与用户聊天界面
/// 核心功能：渐变沉浸式顶部导航（头像+昵称+简介）+ 气泡消息列表 + 动效输入工具栏
/// 设计思路：
///   顶部 - 紫蓝渐变背景，装饰散点，头像渐变环，举报/返回圆形按钮
///   消息 - 渐变发送气泡（左尖角/右尖角），日期分组分割线，"typing…" 动效
///   输入栏 - 圆角输入框 + 脉冲视频按钮 + 渐变发送按钮
/// 关键属性：
///   - userModel_Flick: 聊天对象
///   - messages_Flick: 当前会话消息数组
class MessageUser_Flick: UIViewController {

    // MARK: - 公共属性

    /// 由导航管理器注入的聊天对象
    var userModel_Flick: PrewUserModel_Flick?

    // MARK: - 数据

    private var messages_Flick: [MessageModel_Flick] = []

    // MARK: - 顶部导航 UI

    /// 渐变装饰顶部容器
    private let navContainerView_Flick: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    private var navGradientLayer_Flick: CAGradientLayer?

    /// 左上装饰圆
    private let navDecorCircle1_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.08)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 右下装饰圆
    private let navDecorCircle2_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰散点图标
    private let navDecorSparkle_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.2)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 返回按钮（白色圆形背景）
    private let backButton_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withValues(alpha: 0.2)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 举报按钮（白色圆形背景）
    private lazy var reportButton_Flick: UIButton = {
        let btn = ReportDeleteHelper_Flick.createUserReportButton_Flick(
            size_Flick: 36,
            backgroundColor_Flick: UIColor.white.withValues(alpha: 0.2),
            tintColor_Flick: .white,
            withShadow_Flick: false
        )
        return btn
    }()

    /// 用户信息居中容器（头像 + 昵称 + 简介）
    private let userInfoView_Flick = UIView()

    /// 头像外层渐变环
    private let avatarRingView_Flick: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        return v
    }()

    private let avatarRingGradient_Flick = CAGradientLayer()

    /// 白色间隔环
    private let avatarGapRing_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.3)
        v.layer.cornerRadius = 27
        return v
    }()

    /// 用户头像
    private let headerAvatarView_Flick: UserAvatarView_Flick = {
        let v = UserAvatarView_Flick()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    /// 用户昵称
    private let userNameLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.15
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    /// 用户简介
    private let userBioLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = UIColor.white.withValues(alpha: 0.75)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    /// 在线状态胶囊
    private let onlinePill_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.2)
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withValues(alpha: 0.35).cgColor
        return v
    }()

    private let onlineDotLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "● Online"
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor(hexstring_Flick: "#68D391")
        return label
    }()

    // MARK: - 消息列表

    private let messagesTableView_Flick: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    // MARK: - 输入栏

    /// 底部输入栏容器
    private let inputBarView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -3)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        return v
    }()

    /// 输入栏顶部渐变分割线
    private let inputDividerView_Flick: UIView = {
        let v = UIView()
        return v
    }()

    private let inputDividerGradient_Flick = CAGradientLayer()

    /// 消息输入框（圆角背景 + 内边距）
    private let messageTextField_Flick: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        tf.layer.cornerRadius = 22
        tf.layer.borderWidth = 1.5
        tf.layer.borderColor = ColorConfig_Flick.border_Flick.cgColor
        tf.font = .systemFont(ofSize: 15)
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        tf.rightViewMode = .always
        return tf
    }()

    /// 视频通话按钮（脉冲环动画）
    private let videoChatButton_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "video.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Flick.primaryGradientStart_Flick
        btn.layer.cornerRadius = 20
        return btn
    }()

    /// 视频按钮脉冲环
    private let videoPulseRing_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderWidth = 2
        v.layer.borderColor = ColorConfig_Flick.primaryGradientStart_Flick.cgColor
        v.layer.cornerRadius = 24
        v.alpha = 0
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 发送按钮（渐变）
    private let sendButton_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = ColorConfig_Flick.primaryGradientStart_Flick.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.35
        btn.layer.shadowRadius = 8
        return btn
    }()

    private let sendGradient_Flick = CAGradientLayer()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshMessages_Flick()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        setupConstraints_Flick()
        setupActions_Flick()
        setupObservers_Flick()
        loadUserInfo_Flick()
        refreshMessages_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavGradient_Flick()
        updateNavDecorLayout_Flick()
        updateAvatarRingGradient_Flick()
        updateSendGradient_Flick()
        updateInputDividerGradient_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVideoPulseAnimation_Flick()
        animateNavEntrance_Flick()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVideoPulseAnimation_Flick()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        // 顶部导航
        view.addSubview(navContainerView_Flick)
        navContainerView_Flick.addSubview(navDecorCircle1_Flick)
        navContainerView_Flick.addSubview(navDecorCircle2_Flick)
        navContainerView_Flick.addSubview(navDecorSparkle_Flick)
        navContainerView_Flick.addSubview(backButton_Flick)
        navContainerView_Flick.addSubview(reportButton_Flick)
        navContainerView_Flick.addSubview(userInfoView_Flick)

        // 用户信息（头像环 + 昵称 + 简介 + 在线 Pill）
        userInfoView_Flick.addSubview(avatarRingView_Flick)
        avatarRingView_Flick.addSubview(avatarGapRing_Flick)
        avatarGapRing_Flick.addSubview(headerAvatarView_Flick)
        userInfoView_Flick.addSubview(userNameLabel_Flick)
        userInfoView_Flick.addSubview(userBioLabel_Flick)
        userInfoView_Flick.addSubview(onlinePill_Flick)
        onlinePill_Flick.addSubview(onlineDotLabel_Flick)

        // 消息列表
        view.addSubview(messagesTableView_Flick)
        messagesTableView_Flick.delegate = self
        messagesTableView_Flick.dataSource = self
        messagesTableView_Flick.register(
            MsgBubbleCell_Flick.self,
            forCellReuseIdentifier: MsgBubbleCell_Flick.reuseID_Flick
        )
        messagesTableView_Flick.register(
            MsgDateSeparatorCell_Flick.self,
            forCellReuseIdentifier: MsgDateSeparatorCell_Flick.reuseID_Flick
        )

        // 输入栏
        view.addSubview(inputBarView_Flick)
        inputBarView_Flick.addSubview(inputDividerView_Flick)
        inputBarView_Flick.addSubview(messageTextField_Flick)
        inputBarView_Flick.addSubview(videoPulseRing_Flick)
        inputBarView_Flick.addSubview(videoChatButton_Flick)
        inputBarView_Flick.addSubview(sendButton_Flick)
    }

    private func setupConstraints_Flick() {
        // 顶部导航（覆盖状态栏，向下延伸 126pt 到安全区）
        navContainerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(126)
        }

        backButton_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(36)
        }

        reportButton_Flick.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(36)
        }

        userInfoView_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.left.greaterThanOrEqualTo(backButton_Flick.snp.right).offset(8)
            make.right.lessThanOrEqualTo(reportButton_Flick.snp.left).offset(-8)
        }

        avatarRingView_Flick.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        avatarGapRing_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(54)
        }

        headerAvatarView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }

        userNameLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Flick.snp.bottom).offset(4)
            make.left.right.centerX.equalToSuperview()
        }

        userBioLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Flick.snp.bottom).offset(2)
            make.left.right.centerX.equalToSuperview()
        }

        onlinePill_Flick.snp.makeConstraints { make in
            make.top.equalTo(userBioLabel_Flick.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        onlineDotLabel_Flick.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.left.right.equalToSuperview().inset(8)
        }

        // 消息列表
        messagesTableView_Flick.snp.makeConstraints { make in
            make.top.equalTo(navContainerView_Flick.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBarView_Flick.snp.top)
        }

        // 输入栏
        inputBarView_Flick.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(68)
        }

        inputDividerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1.5)
        }

        videoChatButton_Flick.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        videoPulseRing_Flick.snp.makeConstraints { make in
            make.center.equalTo(videoChatButton_Flick)
            make.width.height.equalTo(48)
        }

        sendButton_Flick.snp.makeConstraints { make in
            make.right.equalTo(videoChatButton_Flick.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        messageTextField_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalTo(sendButton_Flick.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    // MARK: - 渐变 & 装饰

    private func updateNavGradient_Flick() {
        navGradientLayer_Flick?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        gradient.frame = navContainerView_Flick.bounds
        gradient.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        navContainerView_Flick.layer.insertSublayer(gradient, at: 0)
        navGradientLayer_Flick = gradient
    }

    private func updateNavDecorLayout_Flick() {
        let w = navContainerView_Flick.bounds.width
        let h = navContainerView_Flick.bounds.height
        navDecorCircle1_Flick.frame = CGRect(x: -30, y: -30, width: 120, height: 120)
        navDecorCircle1_Flick.layer.cornerRadius = 60
        navDecorCircle2_Flick.frame = CGRect(x: w - 60, y: h - 20, width: 100, height: 100)
        navDecorCircle2_Flick.layer.cornerRadius = 50
        navDecorSparkle_Flick.frame = CGRect(x: w - 52, y: 44, width: 28, height: 28)
    }

    private func updateAvatarRingGradient_Flick() {
        avatarRingGradient_Flick.removeFromSuperlayer()
        avatarRingGradient_Flick.frame = avatarRingView_Flick.bounds
        avatarRingGradient_Flick.cornerRadius = 30
        avatarRingGradient_Flick.colors = [
            UIColor.white.withValues(alpha: 0.6).cgColor,
            UIColor.white.withValues(alpha: 0.2).cgColor
        ]
        avatarRingGradient_Flick.startPoint = CGPoint(x: 0, y: 0)
        avatarRingGradient_Flick.endPoint = CGPoint(x: 1, y: 1)
        avatarRingView_Flick.layer.insertSublayer(avatarRingGradient_Flick, at: 0)
    }

    private func updateSendGradient_Flick() {
        sendGradient_Flick.removeFromSuperlayer()
        sendGradient_Flick.frame = sendButton_Flick.bounds
        sendGradient_Flick.cornerRadius = 22
        sendGradient_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        sendGradient_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        sendGradient_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        sendButton_Flick.layer.insertSublayer(sendGradient_Flick, at: 0)
    }

    private func updateInputDividerGradient_Flick() {
        inputDividerGradient_Flick.removeFromSuperlayer()
        inputDividerGradient_Flick.frame = inputDividerView_Flick.bounds
        inputDividerGradient_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.3).cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.withValues(alpha: 0.3).cgColor
        ]
        inputDividerGradient_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        inputDividerGradient_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        inputDividerView_Flick.layer.insertSublayer(inputDividerGradient_Flick, at: 0)
    }

    // MARK: - 入场动画

    private func animateNavEntrance_Flick() {
        userInfoView_Flick.alpha = 0
        userInfoView_Flick.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

        UIView.animate(
            withDuration: AnimationConfig_Flick.durationSpring_Flick,
            delay: 0.1,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
            initialSpringVelocity: 0.5
        ) {
            self.userInfoView_Flick.alpha = 1
            self.userInfoView_Flick.transform = .identity
        }

        inputBarView_Flick.transform = CGAffineTransform(translationX: 0, y: 60)
        inputBarView_Flick.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Flick.durationSpring_Flick,
            delay: 0.15,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
            initialSpringVelocity: 0.5
        ) {
            self.inputBarView_Flick.transform = .identity
            self.inputBarView_Flick.alpha = 1
        }
    }

    // MARK: - 视频按钮脉冲动画

    private func startVideoPulseAnimation_Flick() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.4
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.7
        opacityAnimation.toValue = 0.0
        let group = CAAnimationGroup()
        group.animations = [pulseAnimation, opacityAnimation]
        group.duration = 1.4
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        videoPulseRing_Flick.layer.add(group, forKey: "videoPulse_Flick")
        videoPulseRing_Flick.alpha = 0.7
    }

    private func stopVideoPulseAnimation_Flick() {
        videoPulseRing_Flick.layer.removeAllAnimations()
    }

    // MARK: - 数据加载

    private func loadUserInfo_Flick() {
        guard let user = userModel_Flick else { return }
        userNameLabel_Flick.text = user.userName_Flick
        userBioLabel_Flick.text = user.userIntroduce_Flick ?? "✨ Sharing stories"
        if let uid = user.userId_Flick {
            headerAvatarView_Flick.configure_Flick(userId_Flick: uid)
        }
    }

    private func refreshMessages_Flick() {
        guard let uid = userModel_Flick?.userId_Flick else { return }
        messages_Flick = MessageViewModel_Flick.shared_Flick.getMessagesWithUser_Flick(userId_flick: uid)
        messagesTableView_Flick.reloadData()
        scrollToBottom_Flick(animated: false)
    }

    private func scrollToBottom_Flick(animated: Bool) {
        guard !messages_Flick.isEmpty else { return }
        let indexPath = IndexPath(row: messages_Flick.count - 1, section: 0)
        messagesTableView_Flick.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    // MARK: - 事件绑定

    private func setupActions_Flick() {
        backButton_Flick.addTarget(self, action: #selector(handleBack_Flick), for: .touchUpInside)
        sendButton_Flick.addTarget(self, action: #selector(handleSend_Flick), for: .touchUpInside)
        videoChatButton_Flick.addTarget(self, action: #selector(handleVideoChat_Flick), for: .touchUpInside)
        reportButton_Flick.addTarget(self, action: #selector(handleReport_Flick), for: .touchUpInside)
    }

    @objc private func handleBack_Flick() {
        backButton_Flick.animatePressDown_Flick { [weak self] in
            self?.backButton_Flick.animatePressUp_Flick()
            Navigation_Flick.pop_Flick()
        }
    }

    @objc private func handleSend_Flick() {
        guard let text = messageTextField_Flick.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let uid = userModel_Flick?.userId_Flick else { return }

        // 发送按钮弹性动画
        sendButton_Flick.animatePulse_Flick()

        messageTextField_Flick.text = ""
        // 输入框边框高亮反馈
        messageTextField_Flick.layer.borderColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.5).cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.messageTextField_Flick.layer.borderColor = ColorConfig_Flick.border_Flick.cgColor
        }

        MessageViewModel_Flick.shared_Flick.sendMessage_Flick(
            message_flick: text,
            chatType_flick: .personal_flick,
            id_flick: uid
        )
    }

    @objc private func handleVideoChat_Flick() {
        guard let user = userModel_Flick else { return }
        videoChatButton_Flick.animatePulse_Flick()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            Navigation_Flick.toVideoChat_Flick(with: user)
        }
    }

    @objc private func handleReport_Flick() {
        guard let user = userModel_Flick else { return }
        ReportDeleteHelper_Flick.block_Flick(user_Flick: user, from: self) { [weak self] in
            Navigation_Flick.pop_Flick()
        }
    }

    // MARK: - 通知监听

    private func setupObservers_Flick() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageChange_Flick),
            name: MessageViewModel_Flick.messageStateDidChangeNotification_Flick,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow_Flick(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide_Flick(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleMessageChange_Flick() {
        refreshMessages_Flick()
        scrollToBottom_Flick(animated: true)
    }

    @objc private func handleKeyboardWillShow_Flick(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let extraInset = keyboardFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.additionalSafeAreaInsets.bottom = extraInset
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.scrollToBottom_Flick(animated: true)
        }
    }

    @objc private func handleKeyboardWillHide_Flick(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        UIView.animate(withDuration: duration) {
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageUser_Flick: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Flick.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages_Flick[indexPath.row]

        // 每隔5条消息插入一个时间分割行（用 row 索引模拟）
        if indexPath.row % 5 == 0 && indexPath.row > 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MsgDateSeparatorCell_Flick.reuseID_Flick,
                for: indexPath
            ) as! MsgDateSeparatorCell_Flick
            cell.configure_Flick(time_Flick: msg.time_Flick ?? "")
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: MsgBubbleCell_Flick.reuseID_Flick,
            for: indexPath
        ) as! MsgBubbleCell_Flick
        cell.configure_Flick(message_Flick: msg, chatUser_Flick: userModel_Flick)
        return cell
    }
}

// MARK: - 消息气泡 Cell

/// 渐变气泡 Cell
/// 功能：自己发出 → 右侧渐变气泡；对方发出 → 左侧白色带阴影气泡
/// 使用 snp.remakeConstraints 在 configure 时动态切换方向
private class MsgBubbleCell_Flick: UITableViewCell {

    static let reuseID_Flick = "MsgBubbleCell_Flick"

    private let avatarView_Flick = UserAvatarView_Flick()

    private let bubbleView_Flick: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.layer.cornerCurve = .continuous
        return v
    }()

    /// 发送气泡渐变层
    private let bubbleGradient_Flick = CAGradientLayer()

    private let messageLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCellUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(avatarView_Flick)
        contentView.addSubview(bubbleView_Flick)
        contentView.addSubview(timeLabel_Flick)
        bubbleView_Flick.addSubview(messageLabel_Flick)

        messageLabel_Flick.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(14)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView_Flick.layer.cornerRadius = avatarView_Flick.bounds.width / 2
        avatarView_Flick.clipsToBounds = true
    }

    func configure_Flick(message_Flick: MessageModel_Flick, chatUser_Flick: PrewUserModel_Flick?) {
        let isMine = message_Flick.isMine_Flick ?? false
        messageLabel_Flick.text = message_Flick.content_Flick
        timeLabel_Flick.text = message_Flick.time_Flick

        if isMine {
            // 自己：右侧渐变气泡
            bubbleGradient_Flick.removeFromSuperlayer()
            bubbleGradient_Flick.cornerRadius = 18
            bubbleGradient_Flick.colors = [
                ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
                ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
            ]
            bubbleGradient_Flick.startPoint = CGPoint(x: 0, y: 0.5)
            bubbleGradient_Flick.endPoint = CGPoint(x: 1, y: 0.5)
            bubbleGradient_Flick.frame = CGRect(x: 0, y: 0, width: 260, height: 60)
            bubbleView_Flick.layer.insertSublayer(bubbleGradient_Flick, at: 0)
            bubbleView_Flick.layer.shadowOpacity = 0
            messageLabel_Flick.textColor = .white

            avatarView_Flick.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-8)
                make.right.equalToSuperview().offset(-14)
                make.width.height.equalTo(32)
            }
            bubbleView_Flick.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.right.equalTo(avatarView_Flick.snp.left).offset(-8)
                make.left.greaterThanOrEqualToSuperview().offset(60)
                make.bottom.equalTo(timeLabel_Flick.snp.top).offset(-4)
            }
            timeLabel_Flick.snp.remakeConstraints { make in
                make.right.equalTo(avatarView_Flick.snp.left).offset(-6)
                make.bottom.equalToSuperview().offset(-4)
            }

            let cu = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
            if let uid = cu.userId_Flick { avatarView_Flick.configure_Flick(userId_Flick: uid) }

        } else {
            // 对方：左侧白色带阴影
            bubbleGradient_Flick.removeFromSuperlayer()
            bubbleView_Flick.backgroundColor = .white
            bubbleView_Flick.layer.shadowColor = UIColor.black.withValues(alpha: 0.08).cgColor
            bubbleView_Flick.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Flick.layer.shadowOpacity = 1
            bubbleView_Flick.layer.shadowRadius = 6
            messageLabel_Flick.textColor = ColorConfig_Flick.textPrimary_Flick

            avatarView_Flick.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(-8)
                make.left.equalToSuperview().offset(14)
                make.width.height.equalTo(32)
            }
            bubbleView_Flick.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.left.equalTo(avatarView_Flick.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().offset(-60)
                make.bottom.equalTo(timeLabel_Flick.snp.top).offset(-4)
            }
            timeLabel_Flick.snp.remakeConstraints { make in
                make.left.equalTo(avatarView_Flick.snp.right).offset(8)
                make.bottom.equalToSuperview().offset(-4)
            }

            if let uid = chatUser_Flick?.userId_Flick { avatarView_Flick.configure_Flick(userId_Flick: uid) }
        }
    }
}

// MARK: - 日期分割 Cell

/// 消息时间分组分割线 Cell
/// 功能：展示时间字符串，两侧带渐变淡出线
private class MsgDateSeparatorCell_Flick: UITableViewCell {

    static let reuseID_Flick = "MsgDateSeparatorCell_Flick"

    private let pillView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.12)
        v.layer.cornerRadius = 10
        return v
    }()

    private let timeLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.8)
        label.textAlignment = .center
        return label
    }()

    /// 左侧渐变淡出线
    private let leftLine_Flick: UIView = UIView()
    private let leftLineGradient_Flick = CAGradientLayer()

    /// 右侧渐变淡出线
    private let rightLine_Flick: UIView = UIView()
    private let rightLineGradient_Flick = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCellUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(leftLine_Flick)
        contentView.addSubview(rightLine_Flick)
        contentView.addSubview(pillView_Flick)
        pillView_Flick.addSubview(timeLabel_Flick)

        pillView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        timeLabel_Flick.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(12)
        }

        leftLine_Flick.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(pillView_Flick.snp.left).offset(-10)
            make.height.equalTo(1)
        }

        rightLine_Flick.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(pillView_Flick.snp.right).offset(10)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 左侧渐变线（从透明到颜色）
        leftLineGradient_Flick.removeFromSuperlayer()
        leftLineGradient_Flick.frame = leftLine_Flick.bounds
        leftLineGradient_Flick.colors = [
            UIColor.clear.cgColor,
            ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.2).cgColor
        ]
        leftLineGradient_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        leftLineGradient_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        leftLine_Flick.layer.insertSublayer(leftLineGradient_Flick, at: 0)

        // 右侧渐变线（从颜色到透明）
        rightLineGradient_Flick.removeFromSuperlayer()
        rightLineGradient_Flick.frame = rightLine_Flick.bounds
        rightLineGradient_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.2).cgColor,
            UIColor.clear.cgColor
        ]
        rightLineGradient_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        rightLineGradient_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        rightLine_Flick.layer.insertSublayer(rightLineGradient_Flick, at: 0)
    }

    func configure_Flick(time_Flick: String) {
        timeLabel_Flick.text = time_Flick.isEmpty ? "Today" : time_Flick
    }
}
