import Foundation
import UIKit
import SnapKit

// MARK: - 登录输入框通用组件

/// 登录/注册通用输入框组件
/// 核心作用：带左侧渐变图标、焦点高亮边框、可选密码明暗切换的输入框
/// 关键属性：textField_Trace（外部访问输入内容），isPasswordField_Trace（是否密码模式）
class LoginFieldView_Trace: UIView {

    // MARK: - UI 组件

    /// 整体容器（圆角 + 边框 + 背景色）
    private let containerView_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = true
        return v
    }()

    /// 左侧图标渐变容器
    private let iconBgView_Trace: UIView = {
        let v = UIView()
        return v
    }()

    private let iconView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        return iv
    }()

    /// 输入框（外部可读写）
    let textField_Trace: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Trace.textPrimary_Trace
        tf.backgroundColor = .clear
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()

    /// 密码明暗切换按钮
    private let toggleButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        return btn
    }()

    // MARK: - 属性

    /// 是否为密码输入框
    var isPasswordField_Trace: Bool = false {
        didSet {
            textField_Trace.isSecureTextEntry = isPasswordField_Trace
            toggleButton_Trace.isHidden = !isPasswordField_Trace
            updateToggleIcon_Trace()
        }
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        addSubview(containerView_Trace)
        containerView_Trace.addSubview(iconBgView_Trace)
        iconBgView_Trace.addSubview(iconView_Trace)
        containerView_Trace.addSubview(textField_Trace)
        containerView_Trace.addSubview(toggleButton_Trace)

        containerView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconBgView_Trace.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(50)
        }

        iconView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        textField_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBgView_Trace.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(toggleButton_Trace.snp.leading)
        }

        toggleButton_Trace.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(48)
        }

        toggleButton_Trace.addTarget(self, action: #selector(handleToggle_Trace), for: .touchUpInside)
    }

    // MARK: - 公共方法

    /// 配置输入框外观
    /// - Parameters:
    ///   - placeholder_trace: 占位文字
    ///   - iconName_trace: SF Symbol 图标名
    ///   - isPassword_trace: 是否密码模式
    ///   - bgColor_trace: 背景色
    func configure_Trace(
        placeholder_trace: String,
        iconName_trace: String,
        isPassword_trace: Bool = false,
        bgColor_trace: UIColor = UIColor(hexstring_Trace: "#F5EEFF")
    ) {
        let cfg_trace = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView_Trace.image = UIImage(systemName: iconName_trace, withConfiguration: cfg_trace)
        textField_Trace.placeholder = placeholder_trace

        containerView_Trace.backgroundColor = bgColor_trace
        containerView_Trace.layer.borderColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.2).cgColor
        containerView_Trace.layer.borderWidth = 1

        isPasswordField_Trace = isPassword_trace
    }

    /// 设置输入框焦点样式
    /// - Parameter focused_trace: 是否获得焦点
    func setFocused_Trace(_ focused_trace: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.containerView_Trace.layer.borderColor = focused_trace
                ? ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.6).cgColor
                : ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.2).cgColor
            self.containerView_Trace.layer.borderWidth = focused_trace ? 1.5 : 1
        }
    }

    // MARK: - 私有方法

    private func updateToggleIcon_Trace() {
        let iconName_trace = textField_Trace.isSecureTextEntry ? "eye.slash" : "eye"
        let cfg_trace = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        toggleButton_Trace.setImage(UIImage(systemName: iconName_trace, withConfiguration: cfg_trace), for: .normal)
    }

    @objc private func handleToggle_Trace() {
        textField_Trace.isSecureTextEntry.toggle()
        updateToggleIcon_Trace()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - 登录页面

/// 登录页面
/// 核心作用：提供账号/密码登录、Apple 登录入口，以及跳转注册页的链接
/// 设计思路：全屏渐变背景 + 顶部品牌区 + 白色浮动表单卡片 + 底部协议文本
/// 关键方法：
///   - validateAndLogin_Trace()：校验输入并调用 UserViewModel 登录
///   - handleAppleLogin_Trace()：发起 Apple 登录流程
class Login_Trace: UIViewController {

    // MARK: - UI 组件

    // MARK: 背景 & 装饰

    private let bgGradientLayer_Trace = CAGradientLayer()

    private let decorCircle1_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 110
        return v
    }()

    private let decorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 80
        return v
    }()

    private let decorCircle3_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 55
        return v
    }()

    // MARK: 关闭按钮（模态弹出时可关闭）

    private let closeButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 22
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        btn.layer.borderWidth = 1
        return btn
    }()

    // MARK: 品牌区

    private let brandView_Trace = UIView()

    private let brandIconView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 44, weight: .thin)
        iv.image = UIImage(systemName: "sparkles", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let brandTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Trace"
        lbl.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let brandTaglineLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your moments. Your story."
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: 表单卡片

    private let formCardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 26
        v.layer.shadowColor = UIColor(hexstring_Trace: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 24
        v.layer.shadowOpacity = 0.18
        v.layer.masksToBounds = false
        return v
    }()

    private let cardTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome Back 👋"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl
    }()

    private let cardSubtitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign in to continue your journey"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        return lbl
    }()

    private let usernameField_Trace = LoginFieldView_Trace()
    private let passwordField_Trace = LoginFieldView_Trace()

    /// 登录主按钮（渐变背景）
    private let loginButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Login In", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.alpha = 0.55
        btn.isEnabled = false
        return btn
    }()

    private let loginGradientLayer_Trace = CAGradientLayer()

    // MARK: OR 分割线

    private let orContainerView_Trace = UIView()

    private let orLeftLine_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    private let orRightLine_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    private let orLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "or"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        return lbl
    }()

    // MARK: Apple 登录（逻辑全部由组件内部处理）

    private lazy var appleLoginView_Trace: AppleLoginBt_Trace = AppleLoginBt_Trace(
        from: self,
        success_Trace: { _ in
            // Apple 授权成功后自动登录
            UserViewModel_Trace.shared_Trace.loginById_Trace(userId_trace: 99999)
        },
        failure_Trace: { errorMsg_trace in
            Utils_Trace.showError_Trace(message_Trace: errorMsg_trace)
        }
    )

    // MARK: 注册引导 & 协议

    private let signUpLinkLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true

        let attrs_trace: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.85)
        ]
        let linkAttrs_trace: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let str_trace = NSMutableAttributedString(string: "Don't have an account? ", attributes: attrs_trace)
        str_trace.append(NSAttributedString(string: "Sign Up", attributes: linkAttrs_trace))
        lbl.attributedText = str_trace
        return lbl
    }()

    private var protocolLabel_Trace: UILabel?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        bindActions_Trace()
        registerKeyboard_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradientLayer_Trace.frame = view.bounds
        loginGradientLayer_Trace.frame = loginButton_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        // 背景渐变（紫 → 蓝绿）
        bgGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#4DB8D4").cgColor
        ]
        bgGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        bgGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(bgGradientLayer_Trace, at: 0)

        // 登录按钮渐变
        loginGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#4DB8D4").cgColor
        ]
        loginGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0.5)
        loginGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 0.5)
        loginGradientLayer_Trace.cornerRadius = 15
        loginButton_Trace.layer.insertSublayer(loginGradientLayer_Trace, at: 0)

        // 装饰圆
        view.addSubview(decorCircle1_Trace)
        view.addSubview(decorCircle2_Trace)
        view.addSubview(decorCircle3_Trace)

        // 关闭按钮
        view.addSubview(closeButton_Trace)

        // 品牌区
        view.addSubview(brandView_Trace)
        brandView_Trace.addSubview(brandIconView_Trace)
        brandView_Trace.addSubview(brandTitleLabel_Trace)
        brandView_Trace.addSubview(brandTaglineLabel_Trace)

        // 表单卡片
        view.addSubview(formCardView_Trace)
        formCardView_Trace.addSubview(cardTitleLabel_Trace)
        formCardView_Trace.addSubview(cardSubtitleLabel_Trace)
        formCardView_Trace.addSubview(usernameField_Trace)
        formCardView_Trace.addSubview(passwordField_Trace)
        formCardView_Trace.addSubview(loginButton_Trace)
        formCardView_Trace.addSubview(orContainerView_Trace)
        orContainerView_Trace.addSubview(orLeftLine_Trace)
        orContainerView_Trace.addSubview(orLabel_Trace)
        orContainerView_Trace.addSubview(orRightLine_Trace)
        formCardView_Trace.addSubview(appleLoginView_Trace)

        // 底部
        view.addSubview(signUpLinkLabel_Trace)

        // 协议文本
        let protocol_trace = ProtocolHelper_Trace.createProtocolTextLabel_Trace(
            firstContent_Trace: "terms.png",
            secondContent_Trace: "privacy.png",
            config_Trace: .dark_Trace(),
            from: self
        )
        protocolLabel_Trace = protocol_trace
        view.addSubview(protocol_trace)

        // 输入框配置
        usernameField_Trace.configure_Trace(
            placeholder_trace: "Username",
            iconName_trace: "person.fill",
            isPassword_trace: false
        )
        passwordField_Trace.configure_Trace(
            placeholder_trace: "Password",
            iconName_trace: "lock.fill",
            isPassword_trace: true
        )

        buildConstraints_Trace()
    }

    private func buildConstraints_Trace() {
        // 装饰圆
        decorCircle1_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.trailing.equalToSuperview().offset(60)
            make.width.height.equalTo(220)
        }
        decorCircle2_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(-60)
            make.width.height.equalTo(160)
        }
        decorCircle3_Trace.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.centerY).offset(40)
            make.trailing.equalToSuperview().offset(-30)
            make.width.height.equalTo(110)
        }

        // 关闭按钮（44pt 符合 HIG 最小触控区域）
        closeButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }

        // 品牌区（居中偏上）
        brandView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            make.leading.trailing.equalToSuperview()
        }

        brandIconView_Trace.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        brandTitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(brandIconView_Trace.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        brandTaglineLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(brandTitleLabel_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 表单卡片（紧跟品牌区下方）
        formCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(brandView_Trace.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        cardTitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.leading.equalToSuperview().offset(22)
        }

        cardSubtitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel_Trace.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }

        usernameField_Trace.snp.makeConstraints { make in
            make.top.equalTo(cardSubtitleLabel_Trace.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        passwordField_Trace.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        loginButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Trace.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        // OR 分割线
        orContainerView_Trace.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Trace.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(18)
        }

        orLeftLine_Trace.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(orLabel_Trace.snp.leading).offset(-10)
            make.height.equalTo(0.5)
        }

        orLabel_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        orRightLine_Trace.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(orLabel_Trace.snp.trailing).offset(10)
            make.height.equalTo(0.5)
        }

        // Apple 登录
        appleLoginView_Trace.snp.makeConstraints { make in
            make.top.equalTo(orContainerView_Trace.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-22)
        }

        // 注册链接
        signUpLinkLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(formCardView_Trace.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        // 协议文本紧跟注册链接下方，不锚定到屏幕底部
        protocolLabel_Trace?.snp.makeConstraints { make in
            make.top.equalTo(signUpLinkLabel_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        // 关闭按钮
        closeButton_Trace.addTarget(self, action: #selector(handleClose_Trace), for: .touchUpInside)

        // 登录按钮
        loginButton_Trace.addTarget(self, action: #selector(validateAndLogin_Trace), for: .touchUpInside)

        // 输入框 delegate
        usernameField_Trace.textField_Trace.delegate = self
        passwordField_Trace.textField_Trace.delegate = self

        // 监听输入变化以更新按钮状态
        usernameField_Trace.textField_Trace.addTarget(
            self, action: #selector(fieldsChanged_Trace), for: .editingChanged
        )
        passwordField_Trace.textField_Trace.addTarget(
            self, action: #selector(fieldsChanged_Trace), for: .editingChanged
        )

        // 注册链接点击
        let tapGesture_trace = UITapGestureRecognizer(target: self, action: #selector(handleSignUpTap_Trace))
        signUpLinkLabel_Trace.addGestureRecognizer(tapGesture_trace)

        // 背景点击收键盘
        let bgTap_trace = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Trace))
        view.addGestureRecognizer(bgTap_trace)
    }

    // MARK: - 键盘处理

    private func registerKeyboard_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardShow_Trace(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardHide_Trace),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleKeyboardShow_Trace(_ noti: Notification) {
        guard let frame_trace = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardTop_trace = view.bounds.height - frame_trace.height
        let cardBottom_trace = formCardView_Trace.frame.maxY + 16
        if cardBottom_trace > keyboardTop_trace {
            let offset_trace = cardBottom_trace - keyboardTop_trace
            UIView.animate(withDuration: 0.28) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -offset_trace)
            }
        }
    }

    @objc private func handleKeyboardHide_Trace() {
        UIView.animate(withDuration: 0.28) {
            self.view.transform = .identity
        }
    }

    @objc private func dismissKeyboard_Trace() {
        view.endEditing(true)
    }

    // MARK: - 事件处理

    /// 关闭登录页
    @objc private func handleClose_Trace() {
        closeButton_Trace.animatePulse_Trace()
        if presentingViewController != nil {
            Navigation_Trace.dismiss_Trace()
        } else {
            Navigation_Trace.pop_Trace()
        }
    }

    /// 监听输入变化，动态更新登录按钮可用状态
    @objc private func fieldsChanged_Trace() {
        let usernameOk_trace = !(usernameField_Trace.textField_Trace.text?.isEmpty ?? true)
        let passwordOk_trace = !(passwordField_Trace.textField_Trace.text?.isEmpty ?? true)
        let canLogin_trace = usernameOk_trace && passwordOk_trace

        loginButton_Trace.isEnabled = canLogin_trace
        UIView.animate(withDuration: 0.2) {
            self.loginButton_Trace.alpha = canLogin_trace ? 1.0 : 0.55
        }
    }

    /// 校验并执行登录
    @objc private func validateAndLogin_Trace() {
        view.endEditing(true)

        let username_trace = usernameField_Trace.textField_Trace.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_trace = passwordField_Trace.textField_Trace.text ?? ""

        // 二次防御：非空校验（按钮已通过 isEnabled 控制，此处为额外保护）
        guard !username_trace.isEmpty else {
            usernameField_Trace.textField_Trace.animateShake_Trace()
            Utils_Trace.showWarning_Trace(message_Trace: "Please enter your username.")
            return
        }
        guard !password_trace.isEmpty else {
            passwordField_Trace.textField_Trace.animateShake_Trace()
            Utils_Trace.showWarning_Trace(message_Trace: "Please enter your password.")
            return
        }

        loginButton_Trace.animatePressDown_Trace {
            self.loginButton_Trace.animatePressUp_Trace()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UserViewModel_Trace.shared_Trace.loginById_Trace(userId_trace: 895125)
    }

    /// 跳转注册页
    @objc private func handleSignUpTap_Trace() {
        Navigation_Trace.toRegister_Trace(style_trace: .push_trace)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension Login_Trace: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameField_Trace.textField_Trace {
            usernameField_Trace.setFocused_Trace(true)
        } else {
            passwordField_Trace.setFocused_Trace(true)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameField_Trace.textField_Trace {
            usernameField_Trace.setFocused_Trace(false)
        } else {
            passwordField_Trace.setFocused_Trace(false)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Trace.textField_Trace {
            passwordField_Trace.textField_Trace.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            validateAndLogin_Trace()
        }
        return true
    }
}
