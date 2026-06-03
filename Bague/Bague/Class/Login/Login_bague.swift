import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录视图控制器
/// 功能：用户名/密码登录、Apple 登录、协议展示、跳转注册
/// 设计：渐变背景、毛玻璃卡片输入框、弹性动画、优雅的视觉层次
class Login_Bague: UIViewController {

    // MARK: - UI 组件

    /// 顶部渐变背景层
    private var bgGradientLayer_Bague: CAGradientLayer?

    /// 顶部装饰圆（大）
    private let bgCircleLarge_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 160
        return v
    }()

    /// 顶部装饰圆（小）
    private let bgCircleSmall_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 90
        return v
    }()

    /// 关闭按钮
    private let closeBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        return btn
    }()

    /// 顶部 Logo 图标
    private let logoIconView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.layer.cornerRadius = 30
        return v
    }()

    private let logoIconImage_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bag.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 标题标签
    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Sign in to discover your perfect bag"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()

    /// 表单卡片容器
    private let formCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 32
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 24
        return v
    }()

    /// 用户名输入框容器
    private let usernameBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague
        v.layer.cornerRadius = 16
        return v
    }()

    private let usernameIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = ColorConfig_Bague.primaryGradientStart_Bague
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let usernameField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        return tf
    }()

    /// 密码输入框容器
    private let passwordBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague
        v.layer.cornerRadius = 16
        return v
    }()

    private let passwordIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.fill")
        iv.tintColor = ColorConfig_Bague.primaryGradientStart_Bague
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let passwordField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        return tf
    }()

    /// 密码可见切换按钮
    private let eyeBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        btn.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Bague.textPlaceholder_Bague
        return btn
    }()

    /// 登录按钮
    private let loginBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = ColorConfig_Bague.primaryGradientStart_Bague.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 12
        return btn
    }()

    private var loginBtnGradient_Bague: CAGradientLayer?

    /// 分割线
    private let dividerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        return v
    }()

    private let dividerLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "or"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()

    /// Apple 登录按钮
    private lazy var appleLoginView_Bague: AppleLoginBt_Bague = {
        return AppleLoginBt_Bague { [weak self] in
            self?.handleAppleLogin_Bague()
        }
    }()
    
    /// Apple 登录管理器
    private var appleLoginManager_Bague: AppleLoginManager_Bague?

    /// 没有账号标签
    private let noAccountLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        return label
    }()

    private let registerBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn.tintColor = ColorConfig_Bague.primaryGradientStart_Bague
        return btn
    }()

    /// 协议文本
    private var protocolLabel_Bague: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Bague()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.primaryGradientStart_Bague

        // 背景装饰
        view.addSubview(bgCircleLarge_Bague)
        view.addSubview(bgCircleSmall_Bague)

        // 关闭按钮
        view.addSubview(closeBtn_Bague)
        closeBtn_Bague.addTarget(self, action: #selector(closeTapped_Bague), for: .touchUpInside)

        // Logo 区域
        view.addSubview(logoIconView_Bague)
        logoIconView_Bague.addSubview(logoIconImage_Bague)
        view.addSubview(titleLabel_Bague)
        view.addSubview(subtitleLabel_Bague)

        // 表单卡片
        view.addSubview(formCard_Bague)

        // 用户名输入
        formCard_Bague.addSubview(usernameBg_Bague)
        usernameBg_Bague.addSubview(usernameIcon_Bague)
        usernameBg_Bague.addSubview(usernameField_Bague)
        usernameField_Bague.delegate = self

        // 密码输入
        formCard_Bague.addSubview(passwordBg_Bague)
        passwordBg_Bague.addSubview(passwordIcon_Bague)
        passwordBg_Bague.addSubview(passwordField_Bague)
        passwordBg_Bague.addSubview(eyeBtn_Bague)
        passwordField_Bague.delegate = self
        eyeBtn_Bague.addTarget(self, action: #selector(togglePassword_Bague), for: .touchUpInside)

        // 登录按钮
        formCard_Bague.addSubview(loginBtn_Bague)
        loginBtn_Bague.addTarget(self, action: #selector(loginTapped_Bague), for: .touchUpInside)
        loginBtn_Bague.addTarget(self, action: #selector(loginBtnPressDown_Bague), for: .touchDown)
        loginBtn_Bague.addTarget(self, action: #selector(loginBtnPressUp_Bague), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        // 分割线
        formCard_Bague.addSubview(dividerView_Bague)
        formCard_Bague.addSubview(dividerLabel_Bague)

        // Apple 登录
        formCard_Bague.addSubview(appleLoginView_Bague)

        // 没有账号 区域
        formCard_Bague.addSubview(noAccountLabel_Bague)
        formCard_Bague.addSubview(registerBtn_Bague)
        registerBtn_Bague.addTarget(self, action: #selector(registerTapped_Bague), for: .touchUpInside)

        // 协议
        let protocol_bague = ProtocolHelper_Bague.createProtocolTextLabel_Bague(
            firstContent_Bague: "terms.png",
            secondContent_Bague: "privacy.png",
            config_Bague: ProtocolHelper_Bague.ProtocolTextConfig_Bague.light_Bague(),
            from: self
        )
        formCard_Bague.addSubview(protocol_bague)
        protocolLabel_Bague = protocol_bague
    }

    private func setupConstraints_Bague() {
        let screenW = APPSCREEN_Bague.WIDTH_Bague

        bgCircleLarge_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(320)
            make.top.equalToSuperview().offset(-80)
            make.trailing.equalToSuperview().offset(60)
        }

        bgCircleSmall_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(180)
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(-40)
        }

        closeBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }

        logoIconView_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.height.equalTo(60)
        }

        logoIconImage_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }

        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Bague.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        subtitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Bague.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
        }

        formCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Bague.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        usernameBg_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        usernameIcon_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        usernameField_Bague.snp.makeConstraints { make in
            make.leading.equalTo(usernameIcon_Bague.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        passwordBg_Bague.snp.makeConstraints { make in
            make.top.equalTo(usernameBg_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        passwordIcon_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        eyeBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        passwordField_Bague.snp.makeConstraints { make in
            make.leading.equalTo(passwordIcon_Bague.snp.trailing).offset(12)
            make.trailing.equalTo(eyeBtn_Bague.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        loginBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(passwordBg_Bague.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        dividerView_Bague.snp.makeConstraints { make in
            make.top.equalTo(loginBtn_Bague.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }

        dividerLabel_Bague.snp.makeConstraints { make in
            make.center.equalTo(dividerView_Bague)
            make.width.equalTo(30)
        }

        appleLoginView_Bague.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Bague.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        noAccountLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(appleLoginView_Bague.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(-30)
        }

        registerBtn_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(noAccountLabel_Bague)
            make.leading.equalTo(noAccountLabel_Bague.snp.trailing).offset(6)
        }

        protocolLabel_Bague?.snp.makeConstraints { make in
            make.top.equalTo(noAccountLabel_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }

    // MARK: - 渐变更新

    private func updateGradients_Bague() {
        // 背景渐变
        bgGradientLayer_Bague?.removeFromSuperlayer()
        let bg = UIColor.createPrimaryGradientLayer_Bague(frame_Bague: view.bounds)
        view.layer.insertSublayer(bg, at: 0)
        bgGradientLayer_Bague = bg

        // 登录按钮渐变
        loginBtnGradient_Bague?.removeFromSuperlayer()
        let btnGrad = UIColor.createPrimaryGradientLayer_Bague(frame_Bague: loginBtn_Bague.bounds)
        btnGrad.cornerRadius = 22
        loginBtn_Bague.layer.insertSublayer(btnGrad, at: 0)
        loginBtnGradient_Bague = btnGrad
    }

    // MARK: - 动画

    private func animateEntrance_Bague() {
        formCard_Bague.transform = CGAffineTransform(translationX: 0, y: 60)
        formCard_Bague.alpha = 0
        logoIconView_Bague.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        logoIconView_Bague.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.logoIconView_Bague.transform = .identity
            self.logoIconView_Bague.alpha = 1
        }

        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.formCard_Bague.transform = .identity
            self.formCard_Bague.alpha = 1
        }
    }

    // MARK: - 事件处理

    /// 处理 Apple 登录
    private func handleAppleLogin_Bague() {
        appleLoginManager_Bague = AppleLoginManager_Bague(viewController_Bague: self)
        appleLoginManager_Bague?.startAppleLogin_Bague(
            success_Bague: { [weak self] userId_bague in
                Task { @MainActor in
                    // Apple 登录成功，使用固定 ID 10 登录（本地演示）
                    UserViewModel_Bague.shared_Bague.loginById_Bague(userId_bague: 999999)
                }
            },
            failure_Bague: { [weak self] errorMsg_bague in
                Utils_Bague.showError_Bague(message_Bague: "Apple Sign In failed")
            }
        )
    }
    
    @objc private func closeTapped_Bague() {
        closeBtn_Bague.animatePulse_Bague()
        Navigation_Bague.dismiss_Bague()
    }

    @objc private func togglePassword_Bague() {
        passwordField_Bague.isSecureTextEntry.toggle()
        let iconName = passwordField_Bague.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        eyeBtn_Bague.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
    }

    @objc private func loginBtnPressDown_Bague() {
        loginBtn_Bague.animatePressDown_Bague()
    }

    @objc private func loginBtnPressUp_Bague() {
        loginBtn_Bague.animatePressUp_Bague()
    }

    @objc private func loginTapped_Bague() {
        view.endEditing(true)

        guard let username_bague = usernameField_Bague.text, !username_bague.isEmpty else {
            usernameField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please enter your username")
            return
        }

        guard let password_bague = passwordField_Bague.text, !password_bague.isEmpty else {
            passwordField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please enter your password")
            return
        }

        Task { @MainActor in
            UserViewModel_Bague.shared_Bague.loginById_Bague(userId_bague: 8418582)
        }
    }

    @objc private func registerTapped_Bague() {
        registerBtn_Bague.animatePulse_Bague()
        Navigation_Bague.toRegister_Bague(style_bague: .push_bague)
    }
}

// MARK: - UITextFieldDelegate

extension Login_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Bague {
            passwordField_Bague.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginTapped_Bague()
        }
        return true
    }
}
