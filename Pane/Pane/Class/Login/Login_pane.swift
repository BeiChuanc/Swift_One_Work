import Foundation
import UIKit
import SnapKit

// MARK: - 登录页面

/// 登录页面
/// 核心作用：提供账号密码登录、Apple 登录两种方式，校验通过后跳转主界面
/// 设计思路：全屏渐变背景 + 浮动装饰圆 + 应用 Logo 区 + 白色磨砂卡片表单；
///          键盘弹出时整体上移，表单始终可见
/// 关键属性：
/// - appleLoginManager_Pane: Apple 登录管理器（持有强引用，防止被释放）
/// - bottomConstraint_Pane: 表单卡片底部约束，用于键盘避让动画
class Login_Pane: UIViewController {

    // MARK: - 属性

    /// Apple 登录管理器（强持有）
    private var appleLoginManager_Pane: AppleLoginManager_Pane?

    /// 记录键盘弹出前的 view 原始位移（用于键盘避让还原）
    private var keyboardOffset_Pane: CGFloat = 0

    // MARK: - UI · 关闭按钮（右上角，用于 modal 场景关闭登录页）

    private let closeButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        b.setImage(
            UIImage(systemName: "xmark", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor       = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        b.layer.cornerRadius = 18
        return b
    }()

    // MARK: - UI · 背景

    private let bgGradientView_Pane = UIView()
    private var bgGradient_Pane: CAGradientLayer?

    private let decorCircleTop_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 70
        v.isUserInteractionEnabled = false
        return v
    }()

    private let decorCircleMid_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 50
        v.isUserInteractionEnabled = false
        return v
    }()

    private let decorCircleBot_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 40
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI · Logo 区域（三个元素独立约束，避免 UIView 容器高度歧义）

    private let logoIconView_Pane: UILabel = {
        let l = UILabel()
        l.text = "🪟"
        l.font = .systemFont(ofSize: 56)
        l.textAlignment = .center
        return l
    }()

    private let appNameLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Pane"
        l.font = UIFont(name: "Georgia-BoldItalic", size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let taglineLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Your window to the world ✨"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 表单卡片

    private let formCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.shadowColor  = UIColor.black.withAlphaComponent(0.15).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 8)
        v.layer.shadowRadius  = 24
        return v
    }()

    // 用户名输入行
    private let userNameField_Pane: UITextField = buildField_Pane(
        placeholder: "Username",
        icon: "person.fill",
        secure: false
    )

    private let fieldDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    // 密码输入行
    private let passwordField_Pane: UITextField = buildField_Pane(
        placeholder: "Password",
        icon: "lock.fill",
        secure: true
    )

    /// 密码显示/隐藏切换按钮
    private let eyeButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        b.setImage(
            UIImage(systemName: "eye.slash", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.setImage(
            UIImage(systemName: "eye", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .selected
        )
        b.tintColor = ColorConfig_Pane.textPlaceholder_Pane
        return b
    }()

    // MARK: - UI · 按钮区

    private let signInButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Sign In", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        return b
    }()

    private var signInGradient_Pane: CAGradientLayer?

    private let dividerRow_Pane = LoginDividerRow_Pane(text: "or continue with")

    private lazy var appleButton_Pane: AppleLoginBt_Pane = AppleLoginBt_Pane {
        [weak self] in self?.handleAppleLogin_Pane()
    }

    /// "没有账号？去注册" 行
    private let registerRow_Pane: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.isUserInteractionEnabled = true
        let attr_pane = NSMutableAttributedString()
        attr_pane.append(NSAttributedString(
            string: "Don't have an account? ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
        ))
        attr_pane.append(NSAttributedString(
            string: "Register",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        l.attributedText = attr_pane
        return l
    }()

    /// 协议标签
    private var protocolLabel_Pane: UILabel?

    // MARK: - 工厂方法

    /// 构建带图标的输入框
    private static func buildField_Pane(placeholder: String, icon: String, secure: Bool) -> UITextField {
        let tf = UITextField()
        tf.placeholder      = placeholder
        tf.isSecureTextEntry = secure
        tf.font             = .systemFont(ofSize: 15)
        tf.textColor        = ColorConfig_Pane.textPrimary_Pane
        tf.returnKeyType    = secure ? .done : .next
        tf.autocapitalizationType = .none
        tf.autocorrectionType     = .no

        // 左侧图标
        let iconContainer_pane = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iconView_pane = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg_pane)?
            .withRenderingMode(.alwaysTemplate))
        iconView_pane.tintColor   = ColorConfig_Pane.primaryGradientStart_Pane
        iconView_pane.contentMode = .scaleAspectFit
        iconView_pane.frame       = CGRect(x: 12, y: 12, width: 20, height: 20)
        iconContainer_pane.addSubview(iconView_pane)
        tf.leftView     = iconContainer_pane
        tf.leftViewMode = .always
        return tf
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
        setupKeyboard_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Pane?.frame    = bgGradientView_Pane.bounds
        signInGradient_Pane?.frame = signInButton_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane

        // 渐变背景（最底层，仅作视觉背景）
        view.addSubview(bgGradientView_Pane)
        setupBgGradient_Pane()

        // 装饰圆留在 bgGradientView_Pane 中（纯装饰，无交互）
        bgGradientView_Pane.addSubview(decorCircleTop_Pane)
        bgGradientView_Pane.addSubview(decorCircleMid_Pane)
        bgGradientView_Pane.addSubview(decorCircleBot_Pane)

        // 所有交互元素直接加到 view，避免跨层约束导致布局偏移
        // 关闭按钮
        view.addSubview(closeButton_Pane)

        // Logo 三元素直接加到 view（不用容器 UIView，消除高度歧义）
        view.addSubview(logoIconView_Pane)
        view.addSubview(appNameLabel_Pane)
        view.addSubview(taglineLabel_Pane)

        // 表单卡片
        view.addSubview(formCard_Pane)
        formCard_Pane.addSubview(userNameField_Pane)
        formCard_Pane.addSubview(fieldDivider_Pane)
        formCard_Pane.addSubview(passwordField_Pane)
        formCard_Pane.addSubview(eyeButton_Pane)

        // 按钮区
        view.addSubview(signInButton_Pane)
        view.addSubview(dividerRow_Pane)
        view.addSubview(appleButton_Pane)
        view.addSubview(registerRow_Pane)

        // 协议 Label
        let proto_pane = ProtocolHelper_Pane.createProtocolTextLabel_Pane(
            firstContent_Pane: "terms",
            secondContent_Pane: "privacy",
            config_Pane: .dark_Pane(),
            from: self
        )
        view.addSubview(proto_pane)
        protocolLabel_Pane = proto_pane

        setupSignInGradient_Pane()
        setupConstraints_Pane(protoLabel: proto_pane)
    }

    private func setupBgGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        bgGradientView_Pane.layer.insertSublayer(gl_pane, at: 0)
        bgGradient_Pane = gl_pane
        bgGradientView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupSignInGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        gl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        signInButton_Pane.layer.insertSublayer(gl_pane, at: 0)
        signInGradient_Pane = gl_pane
    }

    private func setupConstraints_Pane(protoLabel: UILabel) {
        // 装饰圆（在 bgGradientView_Pane 内，equalToSuperview = bgView）
        decorCircleTop_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-30)
            $0.trailing.equalToSuperview().offset(30)
            $0.width.height.equalTo(140)
        }
        decorCircleMid_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.leading.equalToSuperview().offset(-40)
            $0.width.height.equalTo(100)
        }
        decorCircleBot_Pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(80)
        }

        // 关闭按钮（右上角，距安全区顶部 14pt）
        closeButton_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(36)
        }

        // Logo 三元素独立约束：每个元素直接锚定到前一个元素，无容器歧义
        logoIconView_Pane.snp.makeConstraints {
            $0.top.equalTo(closeButton_Pane.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        appNameLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(logoIconView_Pane.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        taglineLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(appNameLabel_Pane.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        // 表单卡片紧跟 tagline 下方 24pt
        formCard_Pane.snp.makeConstraints {
            $0.top.equalTo(taglineLabel_Pane.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        userNameField_Pane.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(54)
        }
        fieldDivider_Pane.snp.makeConstraints {
            $0.top.equalTo(userNameField_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }
        passwordField_Pane.snp.makeConstraints {
            $0.top.equalTo(fieldDivider_Pane.snp.bottom)
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalTo(eyeButton_Pane.snp.leading).offset(-4)
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview()
        }
        eyeButton_Pane.snp.makeConstraints {
            $0.centerY.equalTo(passwordField_Pane)
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(36)
        }

        // Sign In 按钮
        signInButton_Pane.snp.makeConstraints {
            $0.top.equalTo(formCard_Pane.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }

        // 分隔行
        dividerRow_Pane.snp.makeConstraints {
            $0.top.equalTo(signInButton_Pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(20)
        }

        // Apple 登录按钮
        appleButton_Pane.snp.makeConstraints {
            $0.top.equalTo(dividerRow_Pane.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }

        // 注册跳转
        registerRow_Pane.snp.makeConstraints {
            $0.top.equalTo(appleButton_Pane.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        // 协议标签（仅 top 约束，不设 bottom，避免双端锁死导致 Auto Layout 打破顶部锚点）
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(registerRow_Pane.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    // MARK: - 键盘避让

    private func setupKeyboard_Pane() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Pane(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Pane(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Pane))
        tap_pane.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_pane)
    }

    @objc private func keyboardWillShow_Pane(_ notification: Notification) {
        guard let info_pane = notification.userInfo,
              let rect_pane = info_pane[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_pane = info_pane[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        // 用 view.transform 整体上移，避免与 Auto Layout 约束冲突
        let shift_pane = rect_pane.height / 2
        keyboardOffset_Pane = shift_pane
        UIView.animate(withDuration: duration_pane) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -shift_pane)
        }
    }

    @objc private func keyboardWillHide_Pane(_ notification: Notification) {
        guard let duration_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        keyboardOffset_Pane = 0
        UIView.animate(withDuration: duration_pane) {
            self.view.transform = .identity
        }
    }

    @objc private func dismissKeyboard_Pane() {
        view.endEditing(true)
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        closeButton_Pane.addTarget(self, action: #selector(closeTapped_Pane), for: .touchUpInside)
        signInButton_Pane.addTarget(self, action: #selector(signInTapped_Pane), for: .touchUpInside)
        eyeButton_Pane.addTarget(self, action: #selector(eyeTapped_Pane), for: .touchUpInside)
        let regTap_pane = UITapGestureRecognizer(target: self, action: #selector(registerTapped_Pane))
        registerRow_Pane.addGestureRecognizer(regTap_pane)
        userNameField_Pane.delegate = self
        passwordField_Pane.delegate = self
    }

    /// 关闭/收起登录页（modal 场景 dismiss，push 场景 pop）
    @objc private func closeTapped_Pane() {
        if let nav_pane = navigationController, nav_pane.viewControllers.count > 1 {
            nav_pane.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 登录按钮点击
    /// 功能：校验用户名和密码不为空后调用 ViewModel 登录方法
    @objc private func signInTapped_Pane() {
        let name_pane = userNameField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pwd_pane  = passwordField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !name_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please enter your username.")
            return
        }
        guard !pwd_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please enter your password.")
            return
        }
        view.endEditing(true)
        Task { @MainActor in
            UserViewModel_Pane.shared_Pane.loginById_Pane(userId_pane: 884545)
        }
    }

    /// 切换密码可见性
    @objc private func eyeTapped_Pane() {
        eyeButton_Pane.isSelected           = !eyeButton_Pane.isSelected
        passwordField_Pane.isSecureTextEntry = !eyeButton_Pane.isSelected
    }

    /// 跳转注册页
    @objc private func registerTapped_Pane() {
        Navigation_Pane.toRegister_Pane()
    }

    /// Apple 登录处理
    private func handleAppleLogin_Pane() {
        appleLoginManager_Pane = AppleLoginManager_Pane(viewController_Pane: self)
        appleLoginManager_Pane?.startAppleLogin_Pane(
            success_Pane: { [weak self] userName_pane in
                Task { @MainActor in
                    UserViewModel_Pane.shared_Pane.loginById_Pane(userId_pane: 99999)
                }
            },
            failure_Pane: { errorMsg_pane in
                print("Apple 登录失败：\(errorMsg_pane)")
            }
        )
    }
}

// MARK: - UITextFieldDelegate

extension Login_Pane: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField_Pane {
            passwordField_Pane.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signInTapped_Pane()
        }
        return true
    }
}

// MARK: - LoginDividerRow_Pane（分隔行组件）

/// 登录页"or continue with"分隔行
/// 核心作用：两侧为细线，中间为文本，用于分隔两种登录方式
private class LoginDividerRow_Pane: UIView {
    init(text: String) {
        super.init(frame: .zero)
        let leftLine_pane  = makeLine_Pane()
        let rightLine_pane = makeLine_Pane()
        let label_pane     = UILabel()
        label_pane.text      = text
        label_pane.font      = .systemFont(ofSize: 11)
        label_pane.textColor = UIColor.white.withAlphaComponent(0.7)
        addSubview(leftLine_pane)
        addSubview(label_pane)
        addSubview(rightLine_pane)
        label_pane.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        leftLine_pane.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(label_pane.snp.leading).offset(-10)
            $0.height.equalTo(0.5)
        }
        rightLine_pane.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(label_pane.snp.trailing).offset(10)
            $0.height.equalTo(0.5)
        }
    }
    private func makeLine_Pane() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        return v
    }
    required init?(coder: NSCoder) { fatalError() }
}
