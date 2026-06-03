import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册视图控制器
/// 功能：新用户注册，包含用户名、密码、确认密码验证、协议确认
/// 设计：辅助渐变背景（玫瑰粉→珊瑚橙）、圆角卡片表单、弹性动画
class Register_Bague: UIViewController {

    // MARK: - UI 组件

    /// 背景渐变层
    private var bgGradientLayer_Bague: CAGradientLayer?

    /// 背景装饰圆
    private let bgDecorView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 140
        return v
    }()

    private let bgDecorView2_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 100
        return v
    }()

    /// 返回按钮
    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        return btn
    }()

    /// 标题区域
    private let logoIconView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.layer.cornerRadius = 28
        return v
    }()

    private let logoIconImg_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.badge.plus")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Join the Bague community today"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()

    /// 表单卡片
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

    /// 用户名输入
    private let usernameBg_Bague = RegisterInputBg_Bague()
    private let usernameIcon_Bague: UIImageView = makeFieldIcon_Bague("person.fill")
    private let usernameField_Bague: UITextField = makeInputField_Bague(
        placeholder: "Username", keyboardType: .default, returnKey: .next)

    /// 密码输入
    private let passwordBg_Bague = RegisterInputBg_Bague()
    private let passwordIcon_Bague: UIImageView = makeFieldIcon_Bague("lock.fill")
    private let passwordField_Bague: UITextField = makeInputField_Bague(
        placeholder: "Password", keyboardType: .default, returnKey: .next, secure: true)

    private let eyeBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        btn.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Bague.textPlaceholder_Bague
        return btn
    }()

    /// 确认密码输入
    private let confirmBg_Bague = RegisterInputBg_Bague()
    private let confirmIcon_Bague: UIImageView = makeFieldIcon_Bague("checkmark.shield.fill")
    private let confirmField_Bague: UITextField = makeInputField_Bague(
        placeholder: "Confirm Password", keyboardType: .default, returnKey: .done, secure: true)

    private let confirmEyeBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        btn.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Bague.textPlaceholder_Bague
        return btn
    }()

    /// 注册按钮
    private let registerBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Create Account", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = ColorConfig_Bague.secondaryGradientStart_Bague.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 12
        return btn
    }()

    private var registerBtnGradient_Bague: CAGradientLayer?

    /// 协议
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
        view.backgroundColor = ColorConfig_Bague.secondaryGradientStart_Bague

        view.addSubview(bgDecorView_Bague)
        view.addSubview(bgDecorView2_Bague)
        view.addSubview(backBtn_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        view.addSubview(logoIconView_Bague)
        logoIconView_Bague.addSubview(logoIconImg_Bague)
        view.addSubview(titleLabel_Bague)
        view.addSubview(subtitleLabel_Bague)
        view.addSubview(formCard_Bague)

        // 用户名
        formCard_Bague.addSubview(usernameBg_Bague)
        usernameBg_Bague.addSubview(usernameIcon_Bague)
        usernameBg_Bague.addSubview(usernameField_Bague)
        usernameField_Bague.delegate = self

        // 密码
        formCard_Bague.addSubview(passwordBg_Bague)
        passwordBg_Bague.addSubview(passwordIcon_Bague)
        passwordBg_Bague.addSubview(passwordField_Bague)
        passwordBg_Bague.addSubview(eyeBtn_Bague)
        passwordField_Bague.delegate = self
        eyeBtn_Bague.addTarget(self, action: #selector(togglePassword_Bague), for: .touchUpInside)

        // 确认密码
        formCard_Bague.addSubview(confirmBg_Bague)
        confirmBg_Bague.addSubview(confirmIcon_Bague)
        confirmBg_Bague.addSubview(confirmField_Bague)
        confirmBg_Bague.addSubview(confirmEyeBtn_Bague)
        confirmField_Bague.delegate = self
        confirmEyeBtn_Bague.addTarget(self, action: #selector(toggleConfirmPassword_Bague), for: .touchUpInside)

        // 注册按钮
        formCard_Bague.addSubview(registerBtn_Bague)
        registerBtn_Bague.addTarget(self, action: #selector(registerTapped_Bague), for: .touchUpInside)
        registerBtn_Bague.addTarget(self, action: #selector(btnPressDown_Bague), for: .touchDown)
        registerBtn_Bague.addTarget(self, action: #selector(btnPressUp_Bague), for: [.touchUpInside, .touchUpOutside, .touchCancel])

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
        bgDecorView_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(280)
            make.top.equalToSuperview().offset(-60)
            make.trailing.equalToSuperview().offset(50)
        }

        bgDecorView2_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.bottom.equalTo(formCard_Bague.snp.top).offset(40)
            make.leading.equalToSuperview().offset(-50)
        }

        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }

        logoIconView_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            make.width.height.equalTo(56)
        }

        logoIconImg_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Bague.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        subtitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Bague.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        formCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Bague.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }

        usernameBg_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
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

        confirmBg_Bague.snp.makeConstraints { make in
            make.top.equalTo(passwordBg_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        confirmIcon_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        confirmEyeBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        confirmField_Bague.snp.makeConstraints { make in
            make.leading.equalTo(confirmIcon_Bague.snp.trailing).offset(12)
            make.trailing.equalTo(confirmEyeBtn_Bague.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        registerBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(confirmBg_Bague.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        protocolLabel_Bague?.snp.makeConstraints { make in
            make.top.equalTo(registerBtn_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }

    // MARK: - 渐变更新

    private func updateGradients_Bague() {
        bgGradientLayer_Bague?.removeFromSuperlayer()
        let bg = UIColor.createSecondaryGradientLayer_Bague(frame_Bague: view.bounds)
        view.layer.insertSublayer(bg, at: 0)
        bgGradientLayer_Bague = bg

        registerBtnGradient_Bague?.removeFromSuperlayer()
        let btnGrad = UIColor.createSecondaryGradientLayer_Bague(frame_Bague: registerBtn_Bague.bounds)
        btnGrad.cornerRadius = 22
        registerBtn_Bague.layer.insertSublayer(btnGrad, at: 0)
        registerBtnGradient_Bague = btnGrad
    }

    // MARK: - 动画

    private func animateEntrance_Bague() {
        formCard_Bague.transform = CGAffineTransform(translationX: 0, y: 80)
        formCard_Bague.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.15, usingSpringWithDamping: 0.78,
                       initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.formCard_Bague.transform = .identity
            self.formCard_Bague.alpha = 1
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() {
        backBtn_Bague.animatePulse_Bague()
        Navigation_Bague.pop_Bague()
    }

    @objc private func togglePassword_Bague() {
        passwordField_Bague.isSecureTextEntry.toggle()
        let iconName = passwordField_Bague.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        eyeBtn_Bague.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
    }

    @objc private func toggleConfirmPassword_Bague() {
        confirmField_Bague.isSecureTextEntry.toggle()
        let iconName = confirmField_Bague.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        confirmEyeBtn_Bague.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
    }

    @objc private func btnPressDown_Bague() { registerBtn_Bague.animatePressDown_Bague() }
    @objc private func btnPressUp_Bague() { registerBtn_Bague.animatePressUp_Bague() }

    @objc private func registerTapped_Bague() {
        view.endEditing(true)

        guard let username_bague = usernameField_Bague.text, !username_bague.isEmpty else {
            usernameField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please enter a username")
            return
        }

        guard let password_bague = passwordField_Bague.text, !password_bague.isEmpty else {
            passwordField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please enter a password")
            return
        }

        guard let confirm_bague = confirmField_Bague.text, !confirm_bague.isEmpty else {
            confirmField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please confirm your password")
            return
        }

        guard password_bague == confirm_bague else {
            confirmField_Bague.animateShake_Bague()
            passwordField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Passwords do not match")
            return
        }

        Task { @MainActor in
            UserViewModel_Bague.shared_Bague.loginById_Bague(userId_bague: 8418583)
        }
    }
}

// MARK: - UITextFieldDelegate

extension Register_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Bague {
            passwordField_Bague.becomeFirstResponder()
        } else if textField == passwordField_Bague {
            confirmField_Bague.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            registerTapped_Bague()
        }
        return true
    }
}

// MARK: - 辅助工厂方法

/// 创建输入框背景
private class RegisterInputBg_Bague: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague
        layer.cornerRadius = 16
    }
    required init?(coder: NSCoder) { fatalError() }
}

/// 创建图标视图
private func makeFieldIcon_Bague(_ systemName: String) -> UIImageView {
    let iv = UIImageView()
    iv.image = UIImage(systemName: systemName)
    iv.tintColor = ColorConfig_Bague.secondaryGradientStart_Bague
    iv.contentMode = .scaleAspectFit
    return iv
}

/// 创建输入框
private func makeInputField_Bague(
    placeholder: String,
    keyboardType: UIKeyboardType,
    returnKey: UIReturnKeyType,
    secure: Bool = false
) -> UITextField {
    let tf = UITextField()
    tf.placeholder = placeholder
    tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    tf.textColor = ColorConfig_Bague.textPrimary_Bague
    tf.keyboardType = keyboardType
    tf.returnKeyType = returnKey
    tf.isSecureTextEntry = secure
    tf.autocapitalizationType = .none
    tf.autocorrectionType = .no
    tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
    return tf
}
