import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页视图控制器
/// 核心作用：提供新用户注册功能，校验用户名/密码/确认密码后创建账号并登录
/// 设计思路：与登录页同风格的绿色主题，顶部返回按钮，卡片式表单
class Register_Sylva: UIViewController {

    // MARK: - 私有属性

    /// 背景渐变视图
    private let gradientBgView_Sylva = UIView()

    /// 白色卡片容器
    private let cardView_Sylva = UIView()

    /// 用户名输入框
    private let usernameField_Sylva = UITextField()

    /// 密码输入框
    private let passwordField_Sylva = UITextField()

    /// 确认密码输入框
    private let confirmPasswordField_Sylva = UITextField()

    /// 注册按钮
    private let registerButton_Sylva = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBg_Sylva()
        setupDecoration_Sylva()
        setupCard_Sylva()
        setupBackButton_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        cardView_Sylva.animateSlideInFromBottom_Sylva()
    }

    // MARK: - UI 搭建

    private func setupGradientBg_Sylva() {
        view.backgroundColor = UIColor(hexstring_Sylva: "#1B4332")
        let gradient_sylva = CAGradientLayer()
        gradient_sylva.frame = view.bounds
        gradient_sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#40916C").cgColor,
            UIColor(hexstring_Sylva: "#74C69D").cgColor
        ]
        gradient_sylva.locations = [0, 0.55, 1]
        gradient_sylva.startPoint = CGPoint(x: 0.2, y: 0)
        gradient_sylva.endPoint = CGPoint(x: 0.8, y: 1)
        view.layer.insertSublayer(gradient_sylva, at: 0)
    }

    private func setupDecoration_Sylva() {
        let iconView_sylva = UIImageView(image: UIImage(systemName: "person.badge.plus"))
        iconView_sylva.tintColor = UIColor.white.withAlphaComponent(0.9)
        iconView_sylva.contentMode = .scaleAspectFit
        view.addSubview(iconView_sylva)
        iconView_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }

        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Join Sylva"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        titleLabel_sylva.textColor = .white
        titleLabel_sylva.textAlignment = .center
        view.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(iconView_sylva.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        let subtitleLabel_sylva = UILabel()
        subtitleLabel_sylva.text = "Start your green journey today"
        subtitleLabel_sylva.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel_sylva.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel_sylva.textAlignment = .center
        view.addSubview(subtitleLabel_sylva)
        subtitleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    private func setupCard_Sylva() {
        cardView_Sylva.backgroundColor = .white
        cardView_Sylva.layer.cornerRadius = 30
        cardView_Sylva.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView_Sylva.layer.shadowColor = UIColor.black.cgColor
        cardView_Sylva.layer.shadowOpacity = 0.15
        cardView_Sylva.layer.shadowRadius = 20
        view.addSubview(cardView_Sylva)
        cardView_Sylva.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.centerY).offset(-60)
        }

        let createLabel_sylva = UILabel()
        createLabel_sylva.text = "Create Account"
        createLabel_sylva.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        createLabel_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        cardView_Sylva.addSubview(createLabel_sylva)
        createLabel_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalToSuperview().offset(28)
        }

        // 用户名
        configureTextField_Sylva(textField: usernameField_Sylva, placeholder: "Username", icon: "person.fill")
        cardView_Sylva.addSubview(usernameField_Sylva)
        usernameField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(createLabel_sylva.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(52)
        }

        // 密码
        configureTextField_Sylva(textField: passwordField_Sylva, placeholder: "Password", icon: "lock.fill", isSecure: true)
        cardView_Sylva.addSubview(passwordField_Sylva)
        passwordField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Sylva.snp.bottom).offset(14)
            make.leading.trailing.height.equalTo(usernameField_Sylva)
        }

        // 确认密码
        configureTextField_Sylva(textField: confirmPasswordField_Sylva, placeholder: "Confirm Password", icon: "lock.rotation", isSecure: true)
        cardView_Sylva.addSubview(confirmPasswordField_Sylva)
        confirmPasswordField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Sylva.snp.bottom).offset(14)
            make.leading.trailing.height.equalTo(usernameField_Sylva)
        }

        // 注册按钮
        registerButton_Sylva.setTitle("Create Account", for: .normal)
        registerButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        registerButton_Sylva.setTitleColor(.white, for: .normal)
        registerButton_Sylva.layer.cornerRadius = 16
        applyGreenGradient_Sylva(to: registerButton_Sylva)
        registerButton_Sylva.addTarget(self, action: #selector(registerTapped_Sylva), for: .touchUpInside)
        cardView_Sylva.addSubview(registerButton_Sylva)
        registerButton_Sylva.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField_Sylva.snp.bottom).offset(20)
            make.leading.trailing.height.equalTo(usernameField_Sylva)
        }

        // 协议
        let protocolLabel_sylva = ProtocolHelper_Sylva.createProtocolTextLabel_Sylva(
            firstProtocol_Sylva: .terms_Sylva,
            firstContent_Sylva: "tt",
            secondProtocol_Sylva: .privacy_Sylva,
            secondContent_Sylva: "data",
            config_Sylva: .light_Sylva(),
            from: self
        )
        cardView_Sylva.addSubview(protocolLabel_sylva)
        protocolLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
            make.bottom.lessThanOrEqualToSuperview().offset(-24)
        }
    }

    /// 左上角返回按钮
    private func setupBackButton_Sylva() {
        let backBtn_Sylva = UIButton(type: .system)
        let config_sylva = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        backBtn_Sylva.setImage(UIImage(systemName: "arrow.left", withConfiguration: config_sylva), for: .normal)
        backBtn_Sylva.tintColor = UIColor.white.withAlphaComponent(0.9)
        backBtn_Sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        view.addSubview(backBtn_Sylva)
        backBtn_Sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 辅助方法

    private func configureTextField_Sylva(textField: UITextField, placeholder: String, icon: String, isSecure: Bool = false) {
        textField.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        textField.layer.cornerRadius = 14
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hexstring_Sylva: "#95D5B2").cgColor
        textField.isSecureTextEntry = isSecure
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = ColorConfig_Sylva.textPrimary_Sylva
        textField.returnKeyType = .done
        textField.delegate = self

        let iconContainer_sylva = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        let iconView_sylva = UIImageView(image: UIImage(systemName: icon))
        iconView_sylva.tintColor = UIColor(hexstring_Sylva: "#52B788")
        iconView_sylva.contentMode = .scaleAspectFit
        iconView_sylva.frame = CGRect(x: 12, y: 14, width: 20, height: 22)
        iconContainer_sylva.addSubview(iconView_sylva)
        textField.leftView = iconContainer_sylva
        textField.leftViewMode = .always
        textField.setPlaceholder_Sylva(placeholder_Sylva: placeholder, color_Sylva: ColorConfig_Sylva.textPlaceholder_Sylva)
        textField.setRightPadding_Sylva(padding_Sylva: 16)
    }

    private func applyGreenGradient_Sylva(to button_Sylva: UIButton) {
        button_Sylva.layoutIfNeeded()
        let gradient_sylva = CAGradientLayer()
        gradient_sylva.colors = [
            UIColor(hexstring_Sylva: "#2D6A4F").cgColor,
            UIColor(hexstring_Sylva: "#52B788").cgColor
        ]
        gradient_sylva.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_sylva.endPoint = CGPoint(x: 1, y: 0.5)
        gradient_sylva.cornerRadius = 16
        if let titleLayer_sylva = button_Sylva.titleLabel?.layer {
            button_Sylva.layer.insertSublayer(gradient_sylva, below: titleLayer_sylva)
        } else {
            button_Sylva.layer.insertSublayer(gradient_sylva, at: 0)
        }
        DispatchQueue.main.async { gradient_sylva.frame = button_Sylva.bounds }
    }

    // MARK: - 事件

    @objc private func registerTapped_Sylva() {
        registerButton_Sylva.animatePressDown_Sylva { [weak self] in
            self?.registerButton_Sylva.animatePressUp_Sylva()
        }

        let username_sylva = usernameField_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_sylva = passwordField_Sylva.text ?? ""
        let confirm_sylva = confirmPasswordField_Sylva.text ?? ""

        guard !username_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please enter a username")
            usernameField_Sylva.animateShake_Sylva(); return
        }
        guard !password_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please enter a password")
            passwordField_Sylva.animateShake_Sylva(); return
        }
        guard password_sylva == confirm_sylva else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Passwords do not match")
            confirmPasswordField_Sylva.animateShake_Sylva(); return
        }

        // 注册并登录
        let newUserId_sylva = UserViewModel_Sylva.shared_Sylva.registerUser_Sylva(
            userName_sylva: username_sylva,
            userPwd_sylva: password_sylva
        )
        navigationController?.popViewController(animated: true)
        UserViewModel_Sylva.shared_Sylva.loginById_Sylva(userId_sylva: newUserId_sylva)
    }

    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension Register_Sylva: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
