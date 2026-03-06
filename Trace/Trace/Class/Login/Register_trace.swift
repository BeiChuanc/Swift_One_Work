import Foundation
import UIKit
import SnapKit

// MARK: - 注册页面

/// 注册页面
/// 核心作用：提供新账号注册入口，包含用户名、密码、确认密码输入和协议文本
/// 设计思路：与登录页同款全屏渐变背景 + 顶部文案区 + 白色浮动表单卡片
/// 关键方法：
///   - validateAndRegister_Trace()：校验三项输入并调用 UserViewModel 注册
class Register_Trace: UIViewController {

    // MARK: - UI 组件

    // MARK: 背景 & 装饰

    private let bgGradientLayer_Trace = CAGradientLayer()

    private let decorCircle1_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 100
        return v
    }()

    private let decorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 70
        return v
    }()

    private let decorCircle3_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 45
        return v
    }()

    // MARK: 返回按钮

    private let backButton_Trace = BackButton_Trace()

    // MARK: 顶部文案区

    private let headerView_Trace = UIView()

    private let headerIconView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 36, weight: .thin)
        iv.image = UIImage(systemName: "person.badge.plus", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let headerTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create Account"
        lbl.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let headerSubtitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Join and start leaving your trace"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.8)
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

    private let usernameField_Trace = LoginFieldView_Trace()
    private let passwordField_Trace = LoginFieldView_Trace()
    private let confirmPasswordField_Trace = LoginFieldView_Trace()

    /// 密码强度提示（密码不一致时显示）
    private let passwordHintLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = UIColor(hexstring_Trace: "#FC8181")
        lbl.isHidden = true
        lbl.text = "Passwords do not match"
        return lbl
    }()

    /// 注册主按钮（渐变背景）
    private let registerButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Create Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.alpha = 0.55
        btn.isEnabled = false
        return btn
    }()

    private let registerGradientLayer_Trace = CAGradientLayer()

    // MARK: 登录引导 & 协议

    private let signInLinkLabel_Trace: UILabel = {
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
        let str_trace = NSMutableAttributedString(string: "Already have an account? ", attributes: attrs_trace)
        str_trace.append(NSAttributedString(string: "Sign In", attributes: linkAttrs_trace))
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
        registerGradientLayer_Trace.frame = registerButton_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        // 背景渐变（玫瑰粉 → 紫）
        bgGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#F6A0C0").cgColor,
            UIColor(hexstring_Trace: "#B794F6").cgColor
        ]
        bgGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        bgGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(bgGradientLayer_Trace, at: 0)

        // 注册按钮渐变
        registerGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#F6A0C0").cgColor,
            UIColor(hexstring_Trace: "#B794F6").cgColor
        ]
        registerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0.5)
        registerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 0.5)
        registerGradientLayer_Trace.cornerRadius = 15
        registerButton_Trace.layer.insertSublayer(registerGradientLayer_Trace, at: 0)

        // 装饰圆
        view.addSubview(decorCircle1_Trace)
        view.addSubview(decorCircle2_Trace)
        view.addSubview(decorCircle3_Trace)

        // 返回按钮
        view.addSubview(backButton_Trace)

        // 头部文案
        view.addSubview(headerView_Trace)
        headerView_Trace.addSubview(headerIconView_Trace)
        headerView_Trace.addSubview(headerTitleLabel_Trace)
        headerView_Trace.addSubview(headerSubtitleLabel_Trace)

        // 表单卡片
        view.addSubview(formCardView_Trace)
        formCardView_Trace.addSubview(usernameField_Trace)
        formCardView_Trace.addSubview(passwordField_Trace)
        formCardView_Trace.addSubview(confirmPasswordField_Trace)
        formCardView_Trace.addSubview(passwordHintLabel_Trace)
        formCardView_Trace.addSubview(registerButton_Trace)

        // 底部
        view.addSubview(signInLinkLabel_Trace)

        // 协议文本（白色主题）
        let protocol_trace = ProtocolHelper_Trace.createProtocolTextLabel_Trace(
            firstContent_Trace: "terms.png",
            secondContent_Trace: "privacy.png",
            config_Trace: .dark_Trace(),
            from: self
        )
        protocolLabel_Trace = protocol_trace
        view.addSubview(protocol_trace)

        // 配置输入框
        usernameField_Trace.configure_Trace(
            placeholder_trace: "Username",
            iconName_trace: "person.fill",
            isPassword_trace: false,
            bgColor_trace: UIColor(hexstring_Trace: "#FFF0F5")
        )
        passwordField_Trace.configure_Trace(
            placeholder_trace: "Password",
            iconName_trace: "lock.fill",
            isPassword_trace: true,
            bgColor_trace: UIColor(hexstring_Trace: "#FFF0F5")
        )
        confirmPasswordField_Trace.configure_Trace(
            placeholder_trace: "Confirm Password",
            iconName_trace: "lock.shield.fill",
            isPassword_trace: true,
            bgColor_trace: UIColor(hexstring_Trace: "#FFF0F5")
        )

        buildConstraints_Trace()
    }

    private func buildConstraints_Trace() {
        // 装饰圆
        decorCircle1_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(50)
            make.width.height.equalTo(200)
        }
        decorCircle2_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(-50)
            make.width.height.equalTo(140)
        }
        decorCircle3_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(90)
        }

        // 返回按钮
        backButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        // 头部文案（居中布局）
        headerView_Trace.snp.makeConstraints { make in
            make.top.equalTo(backButton_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        headerIconView_Trace.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }

        headerTitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerIconView_Trace.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        headerSubtitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Trace.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 表单卡片（紧跟头部下方）
        formCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerView_Trace.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        usernameField_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        passwordField_Trace.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        confirmPasswordField_Trace.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
        }

        passwordHintLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField_Trace.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(22)
        }

        registerButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(passwordHintLabel_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-22)
        }

        // 登录链接
        signInLinkLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(formCardView_Trace.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        // 协议文本紧跟登录链接下方，不锚定到屏幕底部
        protocolLabel_Trace?.snp.makeConstraints { make in
            make.top.equalTo(signInLinkLabel_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        backButton_Trace.onTapped_Trace = {
            Navigation_Trace.pop_Trace()
        }

        registerButton_Trace.addTarget(self, action: #selector(validateAndRegister_Trace), for: .touchUpInside)

        usernameField_Trace.textField_Trace.delegate = self
        passwordField_Trace.textField_Trace.delegate = self
        confirmPasswordField_Trace.textField_Trace.delegate = self

        // 监听输入变化
        [usernameField_Trace, passwordField_Trace, confirmPasswordField_Trace].forEach { field_trace in
            field_trace.textField_Trace.addTarget(
                self, action: #selector(fieldsChanged_Trace), for: .editingChanged
            )
        }

        // 登录链接
        let tapGesture_trace = UITapGestureRecognizer(target: self, action: #selector(handleSignInTap_Trace))
        signInLinkLabel_Trace.addGestureRecognizer(tapGesture_trace)

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

    /// 监听输入变化，动态更新注册按钮可用状态，并实时校验密码一致性
    @objc private func fieldsChanged_Trace() {
        let username_trace = usernameField_Trace.textField_Trace.text ?? ""
        let password_trace = passwordField_Trace.textField_Trace.text ?? ""
        let confirm_trace = confirmPasswordField_Trace.textField_Trace.text ?? ""

        let allFilled_trace = !username_trace.isEmpty && !password_trace.isEmpty && !confirm_trace.isEmpty

        // 密码一致性提示（两个密码框都有内容时才校验）
        if !confirm_trace.isEmpty {
            let mismatch_trace = password_trace != confirm_trace
            passwordHintLabel_Trace.isHidden = !mismatch_trace

            // 确认密码框边框变红提示
            confirmPasswordField_Trace.setFocused_Trace(!mismatch_trace)
            if mismatch_trace {
                UIView.animate(withDuration: 0.2) {
                    self.confirmPasswordField_Trace.layer.borderColor =
                        UIColor(hexstring_Trace: "#FC8181").withAlphaComponent(0.6).cgColor
                }
            }
        } else {
            passwordHintLabel_Trace.isHidden = true
        }

        let passwordsMatch_trace = password_trace == confirm_trace
        let canRegister_trace = allFilled_trace && passwordsMatch_trace

        registerButton_Trace.isEnabled = canRegister_trace
        UIView.animate(withDuration: 0.2) {
            self.registerButton_Trace.alpha = canRegister_trace ? 1.0 : 0.55
        }
    }

    /// 校验并执行注册
    @objc private func validateAndRegister_Trace() {
        view.endEditing(true)

        let username_trace = usernameField_Trace.textField_Trace.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_trace = passwordField_Trace.textField_Trace.text ?? ""
        let confirm_trace = confirmPasswordField_Trace.textField_Trace.text ?? ""

        // 用户名非空
        guard !username_trace.isEmpty else {
            usernameField_Trace.textField_Trace.animateShake_Trace()
            Utils_Trace.showWarning_Trace(message_Trace: "Please enter a username.")
            return
        }

        // 密码非空
        guard !password_trace.isEmpty else {
            passwordField_Trace.textField_Trace.animateShake_Trace()
            Utils_Trace.showWarning_Trace(message_Trace: "Please enter a password.")
            return
        }

        // 密码一致性
        guard password_trace == confirm_trace else {
            confirmPasswordField_Trace.textField_Trace.animateShake_Trace()
            Utils_Trace.showWarning_Trace(message_Trace: "Passwords do not match.")
            return
        }

        registerButton_Trace.animatePressDown_Trace {
            self.registerButton_Trace.animatePressUp_Trace()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UserViewModel_Trace.shared_Trace.loginById_Trace(userId_trace: 888842)
    }

    /// 返回登录页
    @objc private func handleSignInTap_Trace() {
        Navigation_Trace.pop_Trace()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension Register_Trace: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameField_Trace.textField_Trace {
            usernameField_Trace.setFocused_Trace(true)
        } else if textField == passwordField_Trace.textField_Trace {
            passwordField_Trace.setFocused_Trace(true)
        } else {
            confirmPasswordField_Trace.setFocused_Trace(true)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameField_Trace.textField_Trace {
            usernameField_Trace.setFocused_Trace(false)
        } else if textField == passwordField_Trace.textField_Trace {
            passwordField_Trace.setFocused_Trace(false)
        } else {
            confirmPasswordField_Trace.setFocused_Trace(false)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Trace.textField_Trace {
            passwordField_Trace.textField_Trace.becomeFirstResponder()
        } else if textField == passwordField_Trace.textField_Trace {
            confirmPasswordField_Trace.textField_Trace.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            validateAndRegister_Trace()
        }
        return true
    }
}
