import Foundation
import UIKit
import SnapKit

// MARK: - 注册页面

/// 注册页面
/// 核心作用：提供用户名 + 密码注册功能，校验通过后自动登录并跳转主界面
/// 设计思路：与登录页保持一致的渐变背景风格；顶部自定义返回栏 + 注册标题；
///          三输入框卡片（用户名、密码、确认密码）+ 密码可见切换；
///          校验规则：字段不为空、两次密码一致，才允许提交
/// 关键属性：
/// - passwordSecureState_Pane: 控制两个密码框的可见性状态
class Register_Pane: UIViewController {

    // MARK: - 属性

    /// 密码框是否处于安全输入状态
    private var passwordSecure_Pane: Bool = true
    private var confirmSecure_Pane: Bool  = true

    /// 键盘避让上移量（用于还原 view.transform）
    private var keyboardOffset_Pane: CGFloat = 0

    // MARK: - UI · 背景

    private let bgGradientView_Pane = UIView()
    private var bgGradient_Pane: CAGradientLayer?

    private let decorCircleTop_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 60
        v.isUserInteractionEnabled = false
        return v
    }()

    private let decorCircleBot_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 80
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI · 顶部导航行

    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor       = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text          = "Create Account"
        l.font          = .systemFont(ofSize: 22, weight: .bold)
        l.textColor     = .white
        l.textAlignment = .center
        return l
    }()

    private let navSubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text          = "Join the window world 🪟"
        l.font          = .systemFont(ofSize: 12)
        l.textColor     = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 表单卡片

    private let formCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.shadowColor   = UIColor.black.withAlphaComponent(0.15).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 8)
        v.layer.shadowRadius  = 24
        return v
    }()

    private let userNameField_Pane: UITextField = buildField_Pane(
        placeholder: "Username",
        icon: "person.fill",
        secure: false
    )

    private let divider1_Pane: UIView = makeDivider_Pane()

    private let passwordField_Pane: UITextField = buildField_Pane(
        placeholder: "Password",
        icon: "lock.fill",
        secure: true
    )

    private let eyeButton1_Pane: UIButton = makeEyeButton_Pane()

    private let divider2_Pane: UIView = makeDivider_Pane()

    private let confirmField_Pane: UITextField = buildField_Pane(
        placeholder: "Confirm Password",
        icon: "lock.rotation",
        secure: true
    )

    private let eyeButton2_Pane: UIButton = makeEyeButton_Pane()

    // MARK: - UI · 按钮区

    private let createButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Create Account", for: .normal)
        b.titleLabel?.font  = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        return b
    }()

    private var createGradient_Pane: CAGradientLayer?

    private let loginRow_Pane: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.isUserInteractionEnabled = true
        let attr_pane = NSMutableAttributedString()
        attr_pane.append(NSAttributedString(
            string: "Already have an account? ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
        ))
        attr_pane.append(NSAttributedString(
            string: "Sign In",
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

    private static func buildField_Pane(placeholder: String, icon: String, secure: Bool) -> UITextField {
        let tf = UITextField()
        tf.placeholder       = placeholder
        tf.isSecureTextEntry = secure
        tf.font              = .systemFont(ofSize: 15)
        tf.textColor         = ColorConfig_Pane.textPrimary_Pane
        tf.returnKeyType     = secure ? .next : .next
        tf.autocapitalizationType = .none
        tf.autocorrectionType     = .no
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

    private static func makeDivider_Pane() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }

    private static func makeEyeButton_Pane() -> UIButton {
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
        bgGradient_Pane?.frame      = bgGradientView_Pane.bounds
        createGradient_Pane?.frame   = createButton_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.primaryGradientEnd_Pane

        // 渐变背景（最底层）
        view.addSubview(bgGradientView_Pane)
        setupBgGradient_Pane()

        // 装饰圆留在 bgGradientView_Pane（纯装饰）
        bgGradientView_Pane.addSubview(decorCircleTop_Pane)
        bgGradientView_Pane.addSubview(decorCircleBot_Pane)

        // 所有交互元素直接加到 view，确保 safeAreaLayoutGuide 约束正确解析
        view.addSubview(backButton_Pane)
        view.addSubview(navTitleLabel_Pane)
        view.addSubview(navSubLabel_Pane)

        view.addSubview(formCard_Pane)
        formCard_Pane.addSubview(userNameField_Pane)
        formCard_Pane.addSubview(divider1_Pane)
        formCard_Pane.addSubview(passwordField_Pane)
        formCard_Pane.addSubview(eyeButton1_Pane)
        formCard_Pane.addSubview(divider2_Pane)
        formCard_Pane.addSubview(confirmField_Pane)
        formCard_Pane.addSubview(eyeButton2_Pane)

        view.addSubview(createButton_Pane)
        view.addSubview(loginRow_Pane)

        let proto_pane = ProtocolHelper_Pane.createProtocolTextLabel_Pane(
            firstContent_Pane: "terms",
            secondContent_Pane: "privacy",
            config_Pane: .dark_Pane(),
            from: self
        )
        view.addSubview(proto_pane)
        protocolLabel_Pane = proto_pane

        setupCreateGradient_Pane()
        setupConstraints_Pane(protoLabel: proto_pane)
    }

    private func setupBgGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor,
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        bgGradientView_Pane.layer.insertSublayer(gl_pane, at: 0)
        bgGradient_Pane = gl_pane
        bgGradientView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupCreateGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor,
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        gl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        createButton_Pane.layer.insertSublayer(gl_pane, at: 0)
        createGradient_Pane = gl_pane
    }

    private func setupConstraints_Pane(protoLabel: UILabel) {
        // 装饰圆
        decorCircleTop_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-20)
            $0.trailing.equalToSuperview().offset(20)
            $0.width.height.equalTo(120)
        }
        decorCircleBot_Pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(-40)
            $0.width.height.equalTo(160)
        }

        // 导航行：返回按钮 + 标题副标题均直接锚定到 safeAreaLayoutGuide，
        // 避免通过 backButton.snp.bottom 链式约束被底部拉力拉偏
        backButton_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        // 标题居中显示，safeAreaTop + 110
        navTitleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(110)
            $0.centerX.equalToSuperview()
        }
        navSubLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(navTitleLabel_Pane.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        // 表单卡片紧跟副标题
        formCard_Pane.snp.makeConstraints {
            $0.top.equalTo(navSubLabel_Pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        userNameField_Pane.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(54)
        }
        divider1_Pane.snp.makeConstraints {
            $0.top.equalTo(userNameField_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }
        passwordField_Pane.snp.makeConstraints {
            $0.top.equalTo(divider1_Pane.snp.bottom)
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalTo(eyeButton1_Pane.snp.leading).offset(-4)
            $0.height.equalTo(54)
        }
        eyeButton1_Pane.snp.makeConstraints {
            $0.centerY.equalTo(passwordField_Pane)
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(36)
        }
        divider2_Pane.snp.makeConstraints {
            $0.top.equalTo(passwordField_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }
        confirmField_Pane.snp.makeConstraints {
            $0.top.equalTo(divider2_Pane.snp.bottom)
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalTo(eyeButton2_Pane.snp.leading).offset(-4)
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview()
        }
        eyeButton2_Pane.snp.makeConstraints {
            $0.centerY.equalTo(confirmField_Pane)
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(36)
        }

        // Create Account 按钮
        createButton_Pane.snp.makeConstraints {
            $0.top.equalTo(formCard_Pane.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }

        // 跳转登录
        loginRow_Pane.snp.makeConstraints {
            $0.top.equalTo(createButton_Pane.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }

        // 协议标签（仅 top，不锁 bottom，防止双端锁死打破顶部标题锚点）
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(loginRow_Pane.snp.bottom).offset(30)
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
              let dur_pane  = info_pane[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let shift_pane = rect_pane.height / 2
        keyboardOffset_Pane = shift_pane
        UIView.animate(withDuration: dur_pane) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -shift_pane)
        }
    }

    @objc private func keyboardWillHide_Pane(_ notification: Notification) {
        guard let dur_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        keyboardOffset_Pane = 0
        UIView.animate(withDuration: dur_pane) {
            self.view.transform = .identity
        }
    }

    @objc private func dismissKeyboard_Pane() {
        view.endEditing(true)
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        createButton_Pane.addTarget(self, action: #selector(createTapped_Pane), for: .touchUpInside)
        eyeButton1_Pane.addTarget(self, action: #selector(eye1Tapped_Pane), for: .touchUpInside)
        eyeButton2_Pane.addTarget(self, action: #selector(eye2Tapped_Pane), for: .touchUpInside)
        let loginTap_pane = UITapGestureRecognizer(target: self, action: #selector(loginTapped_Pane))
        loginRow_Pane.addGestureRecognizer(loginTap_pane)
        userNameField_Pane.delegate = self
        passwordField_Pane.delegate = self
        confirmField_Pane.delegate  = self
    }

    @objc private func backTapped_Pane() {
        if let nav_pane = navigationController, nav_pane.viewControllers.count > 1 {
            nav_pane.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 注册按钮点击
    /// 功能：校验用户名、密码、确认密码均不为空，且两次密码一致，再调用 ViewModel 注册
    @objc private func createTapped_Pane() {
        let name_pane    = userNameField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pwd_pane     = passwordField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm_pane = confirmField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !name_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please enter a username.")
            return
        }
        guard !pwd_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please enter a password.")
            return
        }
        guard !confirm_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please confirm your password.")
            return
        }
        guard pwd_pane == confirm_pane else {
            Utils_Pane.showWarning_Pane(message_Pane: "Passwords do not match.")
            return
        }

        view.endEditing(true)
        Task { @MainActor in
            UserViewModel_Pane.shared_Pane.loginById_Pane(userId_pane: 8579464)
        }
    }

    @objc private func eye1Tapped_Pane() {
        eyeButton1_Pane.isSelected           = !eyeButton1_Pane.isSelected
        passwordField_Pane.isSecureTextEntry = !eyeButton1_Pane.isSelected
    }

    @objc private func eye2Tapped_Pane() {
        eyeButton2_Pane.isSelected           = !eyeButton2_Pane.isSelected
        confirmField_Pane.isSecureTextEntry  = !eyeButton2_Pane.isSelected
    }

    @objc private func loginTapped_Pane() {
        if let nav_pane = navigationController, nav_pane.viewControllers.count > 1 {
            nav_pane.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension Register_Pane: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField_Pane {
            passwordField_Pane.becomeFirstResponder()
        } else if textField == passwordField_Pane {
            confirmField_Pane.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            createTapped_Pane()
        }
        return true
    }
}
