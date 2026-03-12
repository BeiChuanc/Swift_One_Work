import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天

/// 与用户聊天页面
/// 设计风格：浅紫清新主题 + 渐变 NavBar + 全幅用户信息横幅卡 + 气泡消息流 + 富交互底部输入栏
/// 布局层次：NavBar（返回 + 举报） → 用户信息横幅卡（头像 / 标签 / Bio） → 消息 ScrollView → 底部输入栏
/// 逻辑：通过 MessageViewModel 收发消息，NotificationCenter 驱动 UI 更新
class MessageUser_Doze: UIViewController {

    // MARK: - 数据

    /// 聊天用户（由调用方传入）
    var userModel_Doze: PrewUserModel_Doze?

    // MARK: - 顶部导航栏

    private let navBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        return v
    }()


    /// 返回按钮（圆形背景）
    private let backButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Doze.textPrimary_Doze
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 用户昵称（NavBar 中心）
    private let navUserNameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        lbl.textAlignment = .center
        return lbl
    }()

    /// NavBar 标题行（用户名 + 在线绿点）
    private let navTitleRow_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
    }()

    /// NavBar 在线绿点
    private let navOnlineDot_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#48BB78")
        v.layer.cornerRadius = 4.5
        return v
    }()

    /// 举报按钮（NavBar 右上角）
    private lazy var reportButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Doze.textSecondary_Doze
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: - 用户信息横幅卡

    /// 整体卡容器（含阴影）
    private let userInfoCard_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Doze: "#7B5EA7").withAlphaComponent(0.12).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 18
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 卡顶部渐变横幅（header band）
    private let cardBannerView_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    private let cardBannerGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor,
            UIColor(hexstring_Doze: "#9F7AEA").cgColor
        ]
        gl.locations = [0, 0.55, 1]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    /// 横幅装饰圆1（右上）
    private let bannerDeco1_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 36
        return v
    }()

    /// 横幅装饰圆2（左下）
    private let bannerDeco2_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 24
        return v
    }()

    /// 横幅右侧装饰图标
    private let bannerIconView_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iv.image = UIImage(systemName: "pawprint.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.3)
        return iv
    }()

    /// 头像外圈渐变圆环容器
    private let cardAvatarContainer_Doze: UIView = {
        let v = UIView()
        return v
    }()

    private let cardAvatarView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 34
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = UIColor(hexstring_Doze: "#EDE7FB")
        return iv
    }()

    /// 在线状态 Badge
    private let onlineBadge_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#48BB78")
        v.layer.cornerRadius = 7
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户信息卡名称
    private let cardUserNameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        lbl.textAlignment = .center
        return lbl
    }()

    /// 用户信息卡简介
    private let cardUserBioLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 标签行（Chip 容器）
    private let tagRowStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .equalSpacing
        return sv
    }()

    // MARK: - 消息滚动区

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let messagesStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        return sv
    }()

    // MARK: - 底部输入栏

    private let inputBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    /// 输入栏顶部渐变细线装饰
    private let inputBarTopLine_Doze: UIView = {
        let v = UIView()
        return v
    }()

    private let inputBarTopLineGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.4).cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.withAlphaComponent(0.4).cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        return gl
    }()

    private let inputContainer_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F3F1FB")
        v.layer.cornerRadius = 24
        return v
    }()

    private let inputTextField_Doze: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Say something cute...",
            attributes: [.foregroundColor: ColorConfig_Doze.textPlaceholder_Doze]
        )
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Doze.textPrimary_Doze
        tf.returnKeyType = .send
        tf.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        return tf
    }()

    /// 发送按钮渐变包装容器
    private let sendButtonWrapper_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    private let sendBtnGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    /// 发送按钮（透明背景，图标在渐变层之上）
    private let sendButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .clear
        return btn
    }()

    /// 视频聊天按钮（渐变 pill 容器 + 图标）
    private let videoChatWrapper_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hexstring_Doze: "#EDE7FB")
        return v
    }()

    private let videoChatButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "video.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        btn.backgroundColor = .clear
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        setupNavBar_Doze()
        setupUserInfoCard_Doze()
        setupScrollView_Doze()
        setupInputBar_Doze()
        setupKeyboardHandling_Doze()
        loadMessages_Doze()
        observeNotifications_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardBannerGradient_Doze.frame = cardBannerView_Doze.bounds
        sendBtnGradient_Doze.frame = sendButtonWrapper_Doze.bounds
        inputBarTopLineGradient_Doze.frame = inputBarTopLine_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - NavBar 搭建

    private func setupNavBar_Doze() {
        view.addSubview(navBar_Doze)
        navBar_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        // 返回按钮
        navBar_Doze.addSubview(backButton_Doze)
        backButton_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        backButton_Doze.addTarget(self, action: #selector(handleBack_Doze), for: .touchUpInside)

        // 中间标题行（用户名 + 在线绿点）
        navTitleRow_Doze.addArrangedSubview(navUserNameLabel_Doze)
        navTitleRow_Doze.addArrangedSubview(navOnlineDot_Doze)
        navOnlineDot_Doze.snp.makeConstraints { make in make.width.height.equalTo(9) }
        navUserNameLabel_Doze.text = userModel_Doze?.userName_Doze ?? ""
        navBar_Doze.addSubview(navTitleRow_Doze)
        navTitleRow_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(60)
            make.right.lessThanOrEqualToSuperview().offset(-60)
        }

        // 举报按钮
        navBar_Doze.addSubview(reportButton_Doze)
        reportButton_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        reportButton_Doze.addTarget(self, action: #selector(handleReport_Doze), for: .touchUpInside)

    }

    // MARK: - 用户信息横幅卡搭建

    private func setupUserInfoCard_Doze() {
        view.addSubview(userInfoCard_Doze)
        userInfoCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        // 渐变横幅（card 顶部 banner，高度 72）
        userInfoCard_Doze.addSubview(cardBannerView_Doze)
        cardBannerView_Doze.layer.addSublayer(cardBannerGradient_Doze)
        cardBannerView_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(72)
        }

        // 横幅装饰圆1
        cardBannerView_Doze.addSubview(bannerDeco1_Doze)
        bannerDeco1_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(-18)
            make.width.height.equalTo(72)
        }

        // 横幅装饰圆2
        cardBannerView_Doze.addSubview(bannerDeco2_Doze)
        bannerDeco2_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }

        // 横幅装饰爪印图标
        cardBannerView_Doze.addSubview(bannerIconView_Doze)
        bannerIconView_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }

        // 头像容器（垂直居中于 banner 底边）
        userInfoCard_Doze.addSubview(cardAvatarContainer_Doze)
        cardAvatarContainer_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(cardBannerView_Doze.snp.bottom)
            make.width.height.equalTo(76)
        }

        // 头像
        cardAvatarContainer_Doze.addSubview(cardAvatarView_Doze)
        cardAvatarView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(68)
        }

        // 在线状态点
        cardAvatarContainer_Doze.addSubview(onlineBadge_Doze)
        onlineBadge_Doze.snp.makeConstraints { make in
            make.right.equalTo(cardAvatarView_Doze).offset(2)
            make.bottom.equalTo(cardAvatarView_Doze).offset(2)
            make.width.height.equalTo(14)
        }

        // 头像脉冲光圈
        addAvatarRingAnim_Doze()

        // 用户名
        userInfoCard_Doze.addSubview(cardUserNameLabel_Doze)
        cardUserNameLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(cardAvatarContainer_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        // Bio
        userInfoCard_Doze.addSubview(cardUserBioLabel_Doze)
        cardUserBioLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(cardUserNameLabel_Doze.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
        }

        // 标签行
        userInfoCard_Doze.addSubview(tagRowStack_Doze)
        tagRowStack_Doze.snp.makeConstraints { make in
            make.top.equalTo(cardUserBioLabel_Doze.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }

        // 构建 Chip 标签
        tagRowStack_Doze.addArrangedSubview(makeTagChip_Doze(icon: "pawprint.fill", title: "Pet Lover", color: ColorConfig_Doze.primaryGradientStart_Doze))
        tagRowStack_Doze.addArrangedSubview(makeTagChip_Doze(icon: "moon.zzz.fill", title: "Sleep Tracker", color: UIColor(hexstring_Doze: "#9F7AEA")))

        // 填充用户数据
        if let user = userModel_Doze {
            cardUserNameLabel_Doze.text = user.userName_Doze ?? ""
            cardUserBioLabel_Doze.text = user.userIntroduce_Doze ?? "No bio yet"
            if let headName = user.userHead_Doze {
                cardAvatarView_Doze.image = UIImage(named: headName)
            }
        }
    }

    /// 构建标签 Chip
    /// - Parameters:
    ///   - icon: SF Symbol 名称
    ///   - title: 标签文本
    ///   - color: 主色
    private func makeTagChip_Doze(icon: String, title: String, color: UIColor) -> UIView {
        let chip = UIView()
        chip.backgroundColor = color.withAlphaComponent(0.1)
        chip.layer.cornerRadius = 12
        chip.layer.borderWidth = 1
        chip.layer.borderColor = color.withAlphaComponent(0.25).cgColor

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.alignment = .center
        chip.addSubview(row)
        row.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(10)
        }

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let iconIv = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconCfg))
        iconIv.tintColor = color
        iconIv.snp.makeConstraints { make in make.width.height.equalTo(13) }

        let lbl = UILabel()
        lbl.text = title
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = color

        row.addArrangedSubview(iconIv)
        row.addArrangedSubview(lbl)
        return chip
    }

    /// 头像外圈脉冲光圈动画
    private func addAvatarRingAnim_Doze() {
        let ringLayer = CAShapeLayer()
        let center = CGPoint(x: 38, y: 38)
        let path = UIBezierPath(arcCenter: center, radius: 37,
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)
        ringLayer.path = path.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.35).cgColor
        ringLayer.lineWidth = 2
        cardAvatarContainer_Doze.layer.insertSublayer(ringLayer, at: 0)

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 1.2
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.7
        opacityAnim.toValue = 0.0
        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 2.0
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        ringLayer.add(group, forKey: "ring_pulse_doze")
    }

    // MARK: - ScrollView 搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(userInfoCard_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }

        scrollView_Doze.addSubview(messagesStack_Doze)
        messagesStack_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    // MARK: - 底部输入栏搭建

    private func setupInputBar_Doze() {
        view.addSubview(inputBar_Doze)
        inputBar_Doze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(90)
        }

        // 输入栏顶部渐变装饰线
        inputBar_Doze.addSubview(inputBarTopLine_Doze)
        inputBarTopLine_Doze.layer.addSublayer(inputBarTopLineGradient_Doze)
        inputBarTopLine_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }

        // 更新 scrollView 底部约束
        scrollView_Doze.snp.makeConstraints { make in
            make.bottom.equalTo(inputBar_Doze.snp.top)
        }

        // 输入容器
        inputBar_Doze.addSubview(inputContainer_Doze)
        inputContainer_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(14)
            make.height.equalTo(48)
        }

        inputContainer_Doze.addSubview(inputTextField_Doze)
        inputTextField_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        inputTextField_Doze.delegate = self

        // 视频聊天按钮 wrapper + button
        inputBar_Doze.addSubview(videoChatWrapper_Doze)
        videoChatWrapper_Doze.snp.makeConstraints { make in
            make.left.equalTo(inputContainer_Doze.snp.right).offset(8)
            make.centerY.equalTo(inputContainer_Doze)
            make.width.height.equalTo(44)
        }
        videoChatWrapper_Doze.addSubview(videoChatButton_Doze)
        videoChatButton_Doze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        videoChatButton_Doze.addTarget(self, action: #selector(handleVideoChat_Doze), for: .touchUpInside)

        // 发送按钮 wrapper
        sendButtonWrapper_Doze.layer.addSublayer(sendBtnGradient_Doze)
        inputBar_Doze.addSubview(sendButtonWrapper_Doze)
        sendButtonWrapper_Doze.snp.makeConstraints { make in
            make.left.equalTo(videoChatWrapper_Doze.snp.right).offset(6)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(inputContainer_Doze)
            make.width.height.equalTo(44)
        }
        sendButtonWrapper_Doze.addSubview(sendButton_Doze)
        sendButton_Doze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        sendButton_Doze.addTarget(self, action: #selector(handleSend_Doze), for: .touchUpInside)

        // inputContainer 右侧紧贴 videoChat 左侧
        inputContainer_Doze.snp.makeConstraints { make in
            make.right.equalTo(videoChatWrapper_Doze.snp.left).offset(-8)
        }
    }

    // MARK: - 键盘避让

    private func setupKeyboardHandling_Doze() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Doze(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Doze(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Doze))
        tap.cancelsTouchesInView = false
        scrollView_Doze.addGestureRecognizer(tap)
    }

    // MARK: - 数据加载

    private func loadMessages_Doze() {
        rebuildMessages_Doze()
    }

    /// 重建消息气泡列表
    private func rebuildMessages_Doze() {
        messagesStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let userId = userModel_Doze?.userId_Doze else { return }
        let messages = MessageViewModel_Doze.shared_Doze.getMessagesWithUser_Doze(userId_doze: userId)

        if messages.isEmpty {
            let welcome = makeSystemBubble_Doze("👋 Say hello to \(userModel_Doze?.userName_Doze ?? "them")!")
            messagesStack_Doze.addArrangedSubview(welcome)
        }

        for msg in messages {
            let bubble = makeMessageBubble_Doze(message_doze: msg)
            messagesStack_Doze.addArrangedSubview(bubble)
        }

        scrollToBottom_Doze()
    }

    /// 构建系统提示气泡（居中渐变 pill）
    private func makeSystemBubble_Doze(_ text: String) -> UIView {
        let wrapper = UIView()

        // 渐变 pill 容器
        let pill = UIView()
        pill.layer.cornerRadius = 14
        pill.clipsToBounds = true
        let pillGl = CAGradientLayer()
        pillGl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.12).cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.withAlphaComponent(0.12).cgColor
        ]
        pillGl.startPoint = CGPoint(x: 0, y: 0.5)
        pillGl.endPoint = CGPoint(x: 1, y: 0.5)
        pillGl.cornerRadius = 14
        pill.layer.addSublayer(pillGl)
        DispatchQueue.main.async { pillGl.frame = pill.bounds }

        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = ColorConfig_Doze.primaryGradientStart_Doze
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        pill.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        wrapper.addSubview(pill)
        pill.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(40)
            make.right.lessThanOrEqualToSuperview().offset(-40)
            make.height.greaterThanOrEqualTo(36)
        }
        return wrapper
    }

    /// 构建消息气泡
    /// - Parameter message_doze: 消息数据模型
    /// - Returns: 气泡行视图（左侧他人/右侧我方）
    private func makeMessageBubble_Doze(message_doze: MessageModel_Doze) -> UIView {
        let isMine = message_doze.isMine_Doze == true
        let text = message_doze.content_Doze ?? ""
        let time = message_doze.time_Doze ?? ""

        let wrapper = UIView()

        // 气泡主体
        let bubble = UIView()
        bubble.layer.cornerRadius = 20
        bubble.clipsToBounds = true

        if isMine {
            // 我方气泡：渐变背景，右下角尖角
            let gl = CAGradientLayer()
            gl.colors = [
                ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
                ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
            ]
            gl.startPoint = CGPoint(x: 0, y: 0)
            gl.endPoint = CGPoint(x: 1, y: 1)
            gl.cornerRadius = 20
            bubble.layer.insertSublayer(gl, at: 0)
            DispatchQueue.main.async { gl.frame = bubble.bounds }
            bubble.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner
            ]
        } else {
            // 他人气泡：白色带柔和阴影，左下角尖角
            bubble.backgroundColor = .white
            bubble.layer.shadowColor = UIColor(hexstring_Doze: "#7B5EA7").withAlphaComponent(0.08).cgColor
            bubble.layer.shadowOffset = CGSize(width: 0, height: 3)
            bubble.layer.shadowRadius = 8
            bubble.layer.shadowOpacity = 1
            bubble.clipsToBounds = false
            bubble.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner
            ]
        }

        // 消息文本
        let textLbl = UILabel()
        textLbl.text = text
        textLbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLbl.textColor = isMine ? .white : ColorConfig_Doze.textPrimary_Doze
        textLbl.numberOfLines = 0
        textLbl.lineBreakMode = .byWordWrapping
        bubble.addSubview(textLbl)
        textLbl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        // 时间戳
        let timeLbl = UILabel()
        timeLbl.text = time
        timeLbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        timeLbl.textColor = ColorConfig_Doze.textPlaceholder_Doze

        wrapper.addSubview(bubble)
        wrapper.addSubview(timeLbl)

        let maxBubbleWidth = UIScreen.main.bounds.width * 0.66

        if isMine {
            bubble.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.right.equalToSuperview().offset(-16)
                make.left.greaterThanOrEqualToSuperview().offset(16 + UIScreen.main.bounds.width * 0.18)
                make.width.lessThanOrEqualTo(maxBubbleWidth)
            }
            timeLbl.snp.makeConstraints { make in
                make.top.equalTo(bubble.snp.bottom).offset(4)
                make.right.equalTo(bubble)
                make.bottom.equalToSuperview()
            }
        } else {
            // 他人小头像
            let avatarIv = UIImageView()
            avatarIv.contentMode = .scaleAspectFill
            avatarIv.clipsToBounds = true
            avatarIv.layer.cornerRadius = 16
            avatarIv.layer.borderWidth = 1.5
            avatarIv.layer.borderColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.2).cgColor
            avatarIv.backgroundColor = UIColor(hexstring_Doze: "#EDE7FB")
            if let headName = userModel_Doze?.userHead_Doze {
                avatarIv.image = UIImage(named: headName)
            }
            wrapper.addSubview(avatarIv)
            avatarIv.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.top.equalToSuperview()
                make.width.height.equalTo(32)
            }

            bubble.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalTo(avatarIv.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().offset(-UIScreen.main.bounds.width * 0.18)
                make.width.lessThanOrEqualTo(maxBubbleWidth)
            }
            timeLbl.snp.makeConstraints { make in
                make.top.equalTo(bubble.snp.bottom).offset(4)
                make.left.equalTo(bubble)
                make.bottom.equalToSuperview()
            }
        }

        return wrapper
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        let targets: [UIView] = [navBar_Doze, userInfoCard_Doze, scrollView_Doze, inputBar_Doze]
        targets.enumerated().forEach { idx, v in
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: idx % 2 == 0 ? 18 : -18)
        }
        for (i, v) in targets.enumerated() {
            UIView.animate(withDuration: 0.48, delay: Double(i) * 0.06,
                           usingSpringWithDamping: 0.82, initialSpringVelocity: 0.3,
                           options: [.curveEaseOut]) {
                v.alpha = 1; v.transform = .identity
            }
        }
    }

    // MARK: - 工具方法

    /// 滚动到最新消息
    private func scrollToBottom_Doze() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView_Doze.contentSize.height
                       - self.scrollView_Doze.bounds.height
                       + self.scrollView_Doze.contentInset.bottom)
            )
            self.scrollView_Doze.setContentOffset(bottomOffset, animated: true)
        }
    }

    // MARK: - 事件处理

    /// 返回上一页（push 方式进入，用 pop 返回）
    @objc private func handleBack_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        backButton_Doze.animatePressDown_Doze { self.backButton_Doze.animatePressUp_Doze() }
        Navigation_Doze.pop_Doze()
    }

    /// 举报用户（举报成功后 pop 返回上一级）
    @objc private func handleReport_Doze() {
        guard let user = userModel_Doze else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        ReportDeleteHelper_Doze.block_Doze(user_Doze: user, from: self) { [weak self] in
            Navigation_Doze.pop_Doze()
        }
    }

    /// 发送消息
    @objc private func handleSend_Doze() {
        guard let text = inputTextField_Doze.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty,
              let userId = userModel_Doze?.userId_Doze else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        sendButton_Doze.animatePressDown_Doze { self.sendButton_Doze.animatePressUp_Doze() }

        inputTextField_Doze.text = ""
        MessageViewModel_Doze.shared_Doze.sendMessage_Doze(
            message_doze: text,
            chatType_doze: .personal_doze,
            id_doze: userId
        )
    }

    /// 视频聊天按钮 → 进入 VideoChat_Doze
    @objc private func handleVideoChat_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        videoChatButton_Doze.animatePressDown_Doze { self.videoChatButton_Doze.animatePressUp_Doze() }

        let videoChatVC = VideoChat_Doze()
        videoChatVC.userModel_Doze = userModel_Doze
        videoChatVC.modalPresentationStyle = .fullScreen
        present(videoChatVC, animated: true)
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Doze() {
        view.endEditing(true)
    }

    // MARK: - 键盘通知

    @objc private func keyboardWillShow_Doze(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.inputBar_Doze.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-kbFrame.height)
            }
            self.view.layoutIfNeeded()
        }
        scrollToBottom_Doze()
    }

    @objc private func keyboardWillHide_Doze(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.inputBar_Doze.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageChange_Doze),
            name: MessageViewModel_Doze.messageStateDidChangeNotification_Doze,
            object: nil
        )
    }

    @objc private func handleMessageChange_Doze() {
        rebuildMessages_Doze()
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Doze: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Doze()
        return true
    }
}
