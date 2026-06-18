import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录页视图控制器
/// 核心作用：提供用户名/密码登录入口及 Apple 登录，校验输入合法性后调用 loginById_Sylva
/// 设计思路：森林绿渐变背景，卡片式输入区，叶片装饰
class Login_Sylva: UIViewController {

    // MARK: - 私有属性

    /// 背景渐变视图
    private let gradientBgView_Sylva = UIView()

    /// 装饰叶片图标
    private let leafIcon_Sylva = UIImageView()

    /// 应用标题
    private let appTitleLabel_Sylva = UILabel()

    /// 副标题
    private let subtitleLabel_Sylva = UILabel()

    /// 白色卡片容器
    private let cardView_Sylva = UIView()

    /// 用户名输入框
    private let usernameField_Sylva = UITextField()

    /// 密码输入框
    private let passwordField_Sylva = UITextField()

    /// 登录按钮
    private let loginButton_Sylva = UIButton(type: .system)

    /// Apple 登录按钮（延迟初始化，需要 self 引用）
    private var appleLoginView_Sylva: AppleLoginBt_Sylva!
    
    /// Apple 登录管理器
    private var appleLoginManager_Sylva: AppleLoginManager_Sylva!

    /// 协议标签
    private var protocolLabel_Sylva: UILabel?

    /// 前往注册按钮
    private let toRegisterButton_Sylva = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        appleLoginManager_Sylva = AppleLoginManager_Sylva(viewController_Sylva: self)
        appleLoginView_Sylva = AppleLoginBt_Sylva(onTap_Sylva: { [weak self] in
            guard let self_sylva = self else { return }
            self_sylva.appleLoginManager_Sylva.startAppleLogin_Sylva(
                success_Sylva: { userAcc_sylva in
                    let userId_sylva = abs(userAcc_sylva.hashValue) % 90000 + 10000
                    self_sylva.dismiss(animated: true) {
                        UserViewModel_Sylva.shared_Sylva.loginById_Sylva(userId_sylva: userId_sylva)
                    }
                },
                failure_Sylva: { _ in }
            )
        })
        setupGradientBg_Sylva()
        setupDecoration_Sylva()
        setupCard_Sylva()
        setupCloseButton_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        cardView_Sylva.animateSlideInFromBottom_Sylva()
    }

    // MARK: - UI 搭建

    /// 渐变背景
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

    /// 顶部装饰（叶片 + 标题）
    private func setupDecoration_Sylva() {
        leafIcon_Sylva.image = UIImage(systemName: "leaf.fill")
        leafIcon_Sylva.tintColor = UIColor.white.withAlphaComponent(0.9)
        leafIcon_Sylva.contentMode = .scaleAspectFit
        view.addSubview(leafIcon_Sylva)
        leafIcon_Sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }

        appTitleLabel_Sylva.text = "Sylva"
        appTitleLabel_Sylva.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        appTitleLabel_Sylva.textColor = .white
        appTitleLabel_Sylva.textAlignment = .center
        view.addSubview(appTitleLabel_Sylva)
        appTitleLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(leafIcon_Sylva.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        subtitleLabel_Sylva.text = "Plant trees. Build futures."
        subtitleLabel_Sylva.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel_Sylva.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel_Sylva.textAlignment = .center
        view.addSubview(subtitleLabel_Sylva)
        subtitleLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(appTitleLabel_Sylva.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    /// 白色登录卡片
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
            make.top.equalTo(subtitleLabel_Sylva.snp.bottom).offset(36)
        }

        let welcomeLabel_Sylva = UILabel()
        welcomeLabel_Sylva.text = "Welcome Back"
        welcomeLabel_Sylva.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        cardView_Sylva.addSubview(welcomeLabel_Sylva)
        welcomeLabel_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalToSuperview().offset(28)
        }

        // 用户名输入框
        configureTextField_Sylva(
            textField: usernameField_Sylva,
            placeholder: "Username",
            icon: "person.fill"
        )
        cardView_Sylva.addSubview(usernameField_Sylva)
        usernameField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel_Sylva.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(52)
        }

        // 密码输入框
        configureTextField_Sylva(
            textField: passwordField_Sylva,
            placeholder: "Password",
            icon: "lock.fill",
            isSecure: true
        )
        cardView_Sylva.addSubview(passwordField_Sylva)
        passwordField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Sylva.snp.bottom).offset(14)
            make.leading.trailing.height.equalTo(usernameField_Sylva)
        }

        // 登录按钮
        loginButton_Sylva.setTitle("Sign In", for: .normal)
        loginButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        loginButton_Sylva.setTitleColor(.white, for: .normal)
        loginButton_Sylva.layer.cornerRadius = 16
        applyGreenGradient_Sylva(to: loginButton_Sylva)
        loginButton_Sylva.addTarget(self, action: #selector(loginTapped_Sylva), for: .touchUpInside)
        cardView_Sylva.addSubview(loginButton_Sylva)
        loginButton_Sylva.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Sylva.snp.bottom).offset(20)
            make.leading.trailing.height.equalTo(usernameField_Sylva)
        }

        // Apple 登录
        cardView_Sylva.addSubview(appleLoginView_Sylva)
        appleLoginView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Sylva.snp.bottom).offset(14)
            make.leading.trailing.height.equalTo(loginButton_Sylva)
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
        self.protocolLabel_Sylva = protocolLabel_sylva
        cardView_Sylva.addSubview(protocolLabel_sylva)
        protocolLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(appleLoginView_Sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
        }

        // 前往注册
        let noAccountLabel_Sylva = UILabel()
        noAccountLabel_Sylva.text = "Don't have an account?"
        noAccountLabel_Sylva.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        noAccountLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        cardView_Sylva.addSubview(noAccountLabel_Sylva)
        noAccountLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(protocolLabel_sylva.snp.bottom).offset(16)
            make.centerX.equalToSuperview().offset(-30)
        }

        toRegisterButton_Sylva.setTitle("Register", for: .normal)
        toRegisterButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        toRegisterButton_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#40916C"), for: .normal)
        toRegisterButton_Sylva.addTarget(self, action: #selector(toRegisterTapped_Sylva), for: .touchUpInside)
        cardView_Sylva.addSubview(toRegisterButton_Sylva)
        toRegisterButton_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(noAccountLabel_Sylva.snp.trailing).offset(4)
            make.centerY.equalTo(noAccountLabel_Sylva)
        }
    }

    /// 右上角关闭按钮
    private func setupCloseButton_Sylva() {
        let closeBtn_Sylva = UIButton(type: .system)
        let config_sylva = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        closeBtn_Sylva.setImage(UIImage(systemName: "xmark", withConfiguration: config_sylva), for: .normal)
        closeBtn_Sylva.tintColor = UIColor.white.withAlphaComponent(0.8)
        closeBtn_Sylva.addTarget(self, action: #selector(closeTapped_Sylva), for: .touchUpInside)
        view.addSubview(closeBtn_Sylva)
        closeBtn_Sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 辅助方法

    /// 配置通用输入框样式
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

        // 左侧图标
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

    /// 为按钮添加绿色渐变背景
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
        // 插入到 titleLabel 图层下方，保证文字可见
        if let titleLayer_sylva = button_Sylva.titleLabel?.layer {
            button_Sylva.layer.insertSublayer(gradient_sylva, below: titleLayer_sylva)
        } else {
            button_Sylva.layer.insertSublayer(gradient_sylva, at: 0)
        }
        DispatchQueue.main.async { gradient_sylva.frame = button_Sylva.bounds }
    }

    // MARK: - 事件处理

    @objc private func loginTapped_Sylva() {
        loginButton_Sylva.animatePressDown_Sylva { [weak self] in
            self?.loginButton_Sylva.animatePressUp_Sylva()
        }

        let username_sylva = usernameField_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_sylva = passwordField_Sylva.text ?? ""

        guard !username_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please enter your username")
            usernameField_Sylva.animateShake_Sylva()
            return
        }
        guard !password_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please enter your password")
            passwordField_Sylva.animateShake_Sylva()
            return
        }

        // 根据用户名查找或生成 userId，再调用统一登录方法
        let userId_sylva = UserViewModel_Sylva.shared_Sylva.findUserIdByName_Sylva(name_sylva: username_sylva)
            ?? UserViewModel_Sylva.shared_Sylva.registerUser_Sylva(userName_sylva: username_sylva, userPwd_sylva: password_sylva)
        
        dismiss(animated: true) {
            UserViewModel_Sylva.shared_Sylva.loginById_Sylva(userId_sylva: userId_sylva)
        }
    }

    @objc private func toRegisterTapped_Sylva() {
        Navigation_Sylva.toRegister_Sylva(style_sylva: .push_sylva)
    }

    @objc private func closeTapped_Sylva() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension Login_Sylva: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
