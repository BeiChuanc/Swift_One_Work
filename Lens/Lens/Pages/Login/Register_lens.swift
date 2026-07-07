import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页面控制器（重构版）
/// 核心作用：提供用户名/密码注册入口，注册后自动完成模拟登录
/// 设计思路：
///   - 与登录页一致的径向光晕 + 彩虹 Logo 光圈 + 三层渐变 Header
///   - 悬浮圆角表单卡片，输入框带图标与聚焦高亮
///   - 渐变注册按钮
class Register_Lens: UIViewController {

    // MARK: - 渐变层

    /// 顶部彩虹光谱 CAGradientLayer
    private let rainbowGradient_Lens = CAGradientLayer()

    /// Header 主渐变层
    private let headerGradient_Lens = CAGradientLayer()

    /// 注册按钮渐变层
    private let registerBtnGradient_Lens = CAGradientLayer()

    // MARK: - UI 组件

    /// 背景光晕装饰
    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 滚动视图，支持键盘弹起时内容上移
    private let scrollView_Lens: UIScrollView = {
        let sv_lens = UIScrollView()
        sv_lens.showsVerticalScrollIndicator = false
        sv_lens.alwaysBounceVertical = false
        return sv_lens
    }()

    /// 滚动内容容器
    private let contentView_Lens = UIView()

    /// 顶部 Header 容器
    private let headerView_Lens: UIView = {
        let view_lens = UIView()
        view_lens.clipsToBounds = true
        return view_lens
    }()

    /// 顶部彩虹动画条
    private let rainbowBar_Lens = UIView()

    /// 棱镜 Logo 彩虹光圈
    private let logoRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()

    /// 棱镜主题图标
    private let logoImageView_Lens: UIImageView = {
        let iv_lens = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        iv_lens.image = UIImage(systemName: "person.badge.plus", withConfiguration: cfg_Lens)
        iv_lens.tintColor = .white
        iv_lens.contentMode = .scaleAspectFit
        iv_lens.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A", alpha_Lens: 0.35)
        iv_lens.layer.cornerRadius = 36
        iv_lens.clipsToBounds = true
        return iv_lens
    }()

    /// 主标题
    private let titleLabel_Lens: UILabel = {
        let label_lens = UILabel()
        label_lens.text = "Create Account"
        label_lens.textColor = .white
        label_lens.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_lens.textAlignment = .center
        return label_lens
    }()

    /// 副标题
    private let subTitleLabel_Lens: UILabel = {
        let label_lens = UILabel()
        label_lens.text = "Join the Prism World"
        label_lens.textColor = UIColor.white.withAlphaComponent(0.7)
        label_lens.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_lens.textAlignment = .center
        return label_lens
    }()

    /// 卡片容器
    private let cardView_Lens: UIView = {
        let view_lens = UIView()
        view_lens.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        view_lens.layer.cornerRadius = 24
        view_lens.layer.borderWidth = 1
        view_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        return view_lens
    }()

    private let usernameSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "USERNAME"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.85)
        return l
    }()

    private let passwordSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "PASSWORD"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.85)
        return l
    }()

    private let confirmSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "CONFIRM"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#6BCB77", alpha_Lens: 0.85)
        return l
    }()

    /// 注册按钮渐变背景
    private let registerBtnBgView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 用户名输入框
    private let usernameField_Lens: UITextField = {
        let tf_lens = UITextField()
        tf_lens.placeholder = "Username"
        tf_lens.textColor = .white
        tf_lens.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf_lens.layer.cornerRadius = 14
        tf_lens.layer.borderWidth = 1
        tf_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        tf_lens.autocapitalizationType = .none
        tf_lens.autocorrectionType = .no
        tf_lens.returnKeyType = .next
        return tf_lens
    }()

    /// 密码输入框
    private let passwordField_Lens: UITextField = {
        let tf_lens = UITextField()
        tf_lens.placeholder = "Password"
        tf_lens.textColor = .white
        tf_lens.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf_lens.layer.cornerRadius = 14
        tf_lens.layer.borderWidth = 1
        tf_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        tf_lens.isSecureTextEntry = true
        tf_lens.returnKeyType = .next
        return tf_lens
    }()

    /// 确认密码输入框
    private let confirmPasswordField_Lens: UITextField = {
        let tf_lens = UITextField()
        tf_lens.placeholder = "Confirm Password"
        tf_lens.textColor = .white
        tf_lens.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf_lens.layer.cornerRadius = 14
        tf_lens.layer.borderWidth = 1
        tf_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        tf_lens.isSecureTextEntry = true
        tf_lens.returnKeyType = .done
        return tf_lens
    }()

    /// 注册按钮（渐变背景）
    private let registerButton_Lens: UIButton = {
        let btn_lens = UIButton(type: .custom)
        btn_lens.setTitle("Sign Up", for: .normal)
        btn_lens.setTitleColor(.white, for: .normal)
        btn_lens.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn_lens.layer.cornerRadius = 26
        btn_lens.backgroundColor = .clear
        return btn_lens
    }()

    /// 底部协议文本标签
    private var protocolLabel_Lens: UILabel?

    /// 左上角返回按钮
    private let backButton_Lens: UIButton = {
        let btn_lens = UIButton(type: .custom)
        let config_lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn_lens.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_lens), for: .normal)
        btn_lens.tintColor = .white
        btn_lens.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_lens.layer.cornerRadius = 16
        return btn_lens
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        setupActions_Lens()
        setupKeyboardObservers_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupHeaderGradient_Lens()
        setupRegisterBtnGradient_Lens()
        setupRainbowAnimation_Lens()
        if let ringLayer_Lens = logoRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = logoRingView_Lens.bounds
        }
        registerBtnGradient_Lens.frame = registerBtnBgView_Lens.bounds
        registerBtnGradient_Lens.cornerRadius = registerBtnBgView_Lens.bounds.height / 2
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 初始化

    /// 入口：按顺序构建各 UI 分区
    private func setupUI_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        setupBackgroundGlows_Lens()
        buildScrollView_Lens()
        buildHeaderView_Lens()
        buildCardView_Lens()
        buildInputFields_Lens()
        buildRegisterButton_Lens()
        buildProtocolLabel_Lens()
        buildBackButton_Lens()
    }

    /// 构建背景径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.2).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1, y: 1)
        purple_Lens.frame = CGRect(x: -80, y: 80, width: 300, height: 300)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1, y: 1)
        let sw_Lens = UIScreen.main.bounds.width
        blue_Lens.frame = CGRect(x: sw_Lens - 100, y: 160, width: 240, height: 240)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// 为输入框添加左侧图标
    private func applyFieldIcon_Lens(field_Lens: UITextField, iconName_Lens: String) {
        let container_Lens = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        let icon_Lens = UIImageView(frame: CGRect(x: 14, y: 16, width: 20, height: 20))
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        icon_Lens.image = UIImage(systemName: iconName_Lens, withConfiguration: cfg_Lens)
        icon_Lens.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        icon_Lens.contentMode = .scaleAspectFit
        container_Lens.addSubview(icon_Lens)
        field_Lens.leftView = container_Lens
        field_Lens.leftViewMode = .always
        field_Lens.addRightPadding_Lens(16)
    }

    /// 构建滚动视图与内容容器
    private func buildScrollView_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)
        scrollView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }
    }

    /// 构建顶部 Header（渐变背景 + 彩虹条 + Logo 光圈 + 标题）
    private func buildHeaderView_Lens() {
        contentView_Lens.addSubview(headerView_Lens)
        headerView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(280)
        }

        headerView_Lens.addSubview(rainbowBar_Lens)
        rainbowBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(3)
        }

        setupLogoRingGradient_Lens()
        headerView_Lens.addSubview(logoRingView_Lens)
        logoRingView_Lens.addSubview(logoImageView_Lens)
        logoRingView_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(64)
            $0.width.height.equalTo(80)
        }
        logoImageView_Lens.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }

        headerView_Lens.addSubview(titleLabel_Lens)
        titleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoRingView_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        headerView_Lens.addSubview(subTitleLabel_Lens)
        subTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(8)
        }
    }

    /// 构建 Logo 彩虹光圈
    private func setupLogoRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 40
        gradient_Lens.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        logoRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    /// 构建悬浮圆角表单卡片
    private func buildCardView_Lens() {
        contentView_Lens.addSubview(cardView_Lens)
        cardView_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(headerView_Lens.snp.bottom).offset(-20)
            $0.bottom.equalToSuperview()
        }
    }

    /// 构建三个输入框（用户名、密码、确认密码）
    private func buildInputFields_Lens() {
        usernameField_Lens.placeHolderTextColor_Lens(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.32))
        passwordField_Lens.placeHolderTextColor_Lens(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.32))
        confirmPasswordField_Lens.placeHolderTextColor_Lens(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.32))
        applyFieldIcon_Lens(field_Lens: usernameField_Lens, iconName_Lens: "person.fill")
        applyFieldIcon_Lens(field_Lens: passwordField_Lens, iconName_Lens: "lock.fill")
        applyFieldIcon_Lens(field_Lens: confirmPasswordField_Lens, iconName_Lens: "checkmark.shield.fill")

        cardView_Lens.addSubview(usernameSectionLabel_Lens)
        cardView_Lens.addSubview(usernameField_Lens)
        cardView_Lens.addSubview(passwordSectionLabel_Lens)
        cardView_Lens.addSubview(passwordField_Lens)
        cardView_Lens.addSubview(confirmSectionLabel_Lens)
        cardView_Lens.addSubview(confirmPasswordField_Lens)

        usernameSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.equalToSuperview().offset(20)
        }
        usernameField_Lens.snp.makeConstraints {
            $0.top.equalTo(usernameSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        passwordSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(usernameField_Lens.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        passwordField_Lens.snp.makeConstraints {
            $0.top.equalTo(passwordSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        confirmSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(passwordField_Lens.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        confirmPasswordField_Lens.snp.makeConstraints {
            $0.top.equalTo(confirmSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }

    /// 构建注册按钮
    private func buildRegisterButton_Lens() {
        cardView_Lens.addSubview(registerBtnBgView_Lens)
        cardView_Lens.addSubview(registerButton_Lens)
        registerBtnBgView_Lens.layer.insertSublayer(registerBtnGradient_Lens, at: 0)
        registerBtnBgView_Lens.snp.makeConstraints {
            $0.top.equalTo(confirmPasswordField_Lens.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        registerButton_Lens.snp.makeConstraints {
            $0.edges.equalTo(registerBtnBgView_Lens)
        }
    }

    /// 构建底部协议文本标签
    private func buildProtocolLabel_Lens() {
        let label_lens = ProtocolHelper_Lens.createProtocolTextLabel_Lens(
            firstProtocol_Lens: .terms_Lens,
            firstContent_Lens: "https://www.apple.com/legal/internet-services/terms/site.html",
            secondProtocol_Lens: .privacy_Lens,
            secondContent_Lens: "https://www.apple.com/privacy/",
            config_Lens: ProtocolHelper_Lens.ProtocolTextConfig_Lens.dark_Lens(),
            from: self
        )
        protocolLabel_Lens = label_lens
        cardView_Lens.addSubview(label_lens)
        label_lens.snp.makeConstraints {
            $0.top.equalTo(registerBtnBgView_Lens.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    /// 构建左上角返回按钮（浮于 scrollView 之上）
    private func buildBackButton_Lens() {
        view.addSubview(backButton_Lens)
        backButton_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12)
        backButton_Lens.layer.cornerRadius = 18
        backButton_Lens.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().inset(16)
            $0.width.height.equalTo(36)
        }
    }

    // MARK: - 渐变 & 动画

    private func setupHeaderGradient_Lens() {
        headerGradient_Lens.colors = [
            UIColor(hexstring_Lens: "#3D1870").cgColor,
            UIColor(hexstring_Lens: "#1A2E6A").cgColor,
            UIColor(hexstring_Lens: "#0D0D1A").cgColor
        ]
        headerGradient_Lens.locations = [0, 0.55, 1]
        headerGradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        headerGradient_Lens.frame = headerView_Lens.bounds
        if headerGradient_Lens.superlayer == nil {
            headerView_Lens.layer.insertSublayer(headerGradient_Lens, at: 0)
        }
    }

    /// 设置注册按钮渐变层
    private func setupRegisterBtnGradient_Lens() {
        registerBtnGradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        registerBtnGradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        registerBtnGradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        if registerBtnGradient_Lens.superlayer == nil {
            registerBtnBgView_Lens.layer.insertSublayer(registerBtnGradient_Lens, at: 0)
        }
    }

    /// 设置彩虹光谱滚动动画，仅初始化一次
    private func setupRainbowAnimation_Lens() {
        guard rainbowGradient_Lens.superlayer == nil,
              rainbowBar_Lens.bounds.width > 0 else { return }

        let rainbowColors_lens: [CGColor] = [
            UIColor(hexstring_Lens: "#FF6B6B").cgColor,
            UIColor(hexstring_Lens: "#FFB347").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#FF6B6B").cgColor
        ]
        let barWidth_lens = rainbowBar_Lens.bounds.width
        rainbowGradient_Lens.colors = rainbowColors_lens
        rainbowGradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        rainbowGradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        rainbowGradient_Lens.frame = CGRect(x: 0, y: 0, width: barWidth_lens * 2, height: rainbowBar_Lens.bounds.height)
        rainbowBar_Lens.layer.addSublayer(rainbowGradient_Lens)

        let anim_lens = CABasicAnimation(keyPath: "position.x")
        anim_lens.fromValue = barWidth_lens
        anim_lens.toValue = 0
        anim_lens.duration = 3.0
        anim_lens.repeatCount = .infinity
        anim_lens.isRemovedOnCompletion = false
        rainbowGradient_Lens.add(anim_lens, forKey: "rainbowScroll_lens")
    }

    // MARK: - 事件绑定

    /// 绑定所有按钮事件与手势
    private func setupActions_Lens() {
        registerButton_Lens.addTarget(self, action: #selector(handleRegister_Lens), for: .touchUpInside)
        backButton_Lens.addTarget(self, action: #selector(handleBack_Lens), for: .touchUpInside)

        let bgTap_lens = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Lens))
        view.addGestureRecognizer(bgTap_lens)

        usernameField_Lens.delegate = self
        passwordField_Lens.delegate = self
        confirmPasswordField_Lens.delegate = self
    }

    // MARK: - 事件处理

    /// 处理注册逻辑
    /// 校验用户名非空 → 密码非空 → 两次密码一致 → 调用 loginById_Lens(userId_lens: 10) 模拟注册登录
    @objc private func handleRegister_Lens() {
        let username_lens = usernameField_Lens.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_lens = passwordField_Lens.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let confirmPwd_lens = confirmPasswordField_Lens.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !username_lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please enter your username")
            return
        }
        guard !password_lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please enter your password")
            return
        }
        guard !confirmPwd_lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please confirm your password")
            return
        }
        guard password_lens == confirmPwd_lens else {
            Load_Lens.showWarning_Lens(message_Lens: "Passwords do not match")
            // 高亮确认密码框边框提示用户
            confirmPasswordField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.8).cgColor
            return
        }

        // 恢复边框颜色
        confirmPasswordField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor

        // 模拟注册后自动登录，使用固定 userId_lens: 10
        UserViewModel_Lens.shared_Lens.loginById_Lens(userId_lens: 5554524)
    }

    /// 返回登录页
    @objc private func handleBack_Lens() {
        Navigation_Lens.pop_Lens()
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Lens() {
        view.endEditing(true)
    }

    // MARK: - 键盘监听

    /// 注册键盘弹出/收起通知
    private func setupKeyboardObservers_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Lens(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Lens(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 键盘弹出：调整 scrollView 底部内边距
    @objc private func keyboardWillShow_Lens(_ notification_lens: Notification) {
        guard let kbFrame_lens = notification_lens.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Lens.contentInset.bottom = kbFrame_lens.height + 20
        scrollView_Lens.scrollIndicatorInsets.bottom = kbFrame_lens.height
    }

    /// 键盘收起：恢复 scrollView 内边距
    @objc private func keyboardWillHide_Lens(_ notification_lens: Notification) {
        scrollView_Lens.contentInset.bottom = 0
        scrollView_Lens.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - UITextFieldDelegate

extension Register_Lens: UITextFieldDelegate {

    /// 用户名 → 密码 → 确认密码逐级聚焦；确认密码框按 Return 触发注册
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Lens {
            passwordField_Lens.becomeFirstResponder()
        } else if textField == passwordField_Lens {
            confirmPasswordField_Lens.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleRegister_Lens()
        }
        return true
    }

    /// 确认密码框开始编辑时重置边框颜色
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
        if textField == confirmPasswordField_Lens {
            confirmPasswordField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
        }
    }

    /// 失焦时恢复边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == confirmPasswordField_Lens,
           confirmPasswordField_Lens.layer.borderColor == UIColor(hexstring_Lens: "#FF6B6B").cgColor {
            return
        }
        textField.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
    }
}
