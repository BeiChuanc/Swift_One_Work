import Foundation
import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页面
/// 核心功能：提供用户名 + 密码 + 确认密码注册流程
/// 设计思路：与登录页风格统一，辅助渐变色区别视觉；
///           注册时校验输入非空且两次密码一致，通过 UserViewModel.loginById_Clara 完成注册并登录
/// 关键方法：
/// - registerTapped_Clara: 三重校验（用户名非空、密码非空、密码一致）→ 调用 ViewModel
class Register_Clara: UIViewController {

    // MARK: - UI 组件

    private let gradientBgView_Clara = UIView()
    private var gradientBgLayer_Clara: CAGradientLayer?

    private let logoContainer_Clara = UIView()

    private let logoIconView_Clara: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 52, weight: .medium)
        iv.image = UIImage(systemName: "sparkles", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Create Account"
        l.font = UIFont(name: "AvenirNext-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Join the warmth community"
        l.font = UIFont.systemFont(ofSize: 14, weight: .light)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        return l
    }()

    /// 顶部注册角标
    private let createBadgeLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Start Here"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        return l
    }()

    private let formCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 20
        return v
    }()

    private let usernameField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        return tf
    }()

    private let passwordField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.isSecureTextEntry = true
        tf.returnKeyType = .next
        return tf
    }()

    private let confirmPasswordField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    private let registerButton_Clara: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Create Account", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        return btn
    }()

    private let loginPromptView_Clara: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        return v
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupGradientBackground_Clara()
        setupBackButton_Clara()
        setupLogoArea_Clara()
        setupFormCard_Clara()
        setupProtocolLabel_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 辅助渐变色（玫瑰粉到珊瑚橙）区别于登录页
        if let gl = gradientBgLayer_Clara {
            gl.frame = gradientBgView_Clara.bounds
        } else {
            let gl = UIColor.createSecondaryGradientLayer_Clara(frame_Clara: gradientBgView_Clara.bounds)
            gradientBgView_Clara.layer.insertSublayer(gl, at: 0)
            gradientBgLayer_Clara = gl
        }
        // 注册按钮渐变
        registerButton_Clara.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let btnGl = UIColor.createSecondaryGradientLayer_Clara(frame_Clara: registerButton_Clara.bounds)
        btnGl.cornerRadius = 22
        registerButton_Clara.layer.insertSublayer(btnGl, at: 0)
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - UI 搭建

    private func setupGradientBackground_Clara() {
        view.addSubview(gradientBgView_Clara)
        gradientBgView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.48)
        }

        // 装饰圆增强顶部层次
        let largeCircle = UIView()
        largeCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        largeCircle.layer.cornerRadius = 72
        gradientBgView_Clara.addSubview(largeCircle)
        largeCircle.snp.makeConstraints { make in
            make.width.height.equalTo(144)
            make.left.equalToSuperview().offset(-34)
            make.top.equalToSuperview().offset(62)
        }

        let smallCircle = UIView()
        smallCircle.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        smallCircle.layer.cornerRadius = 38
        gradientBgView_Clara.addSubview(smallCircle)
        smallCircle.snp.makeConstraints { make in
            make.width.height.equalTo(76)
            make.right.equalToSuperview().inset(-14)
            make.bottom.equalToSuperview().offset(18)
        }
    }

    /// 搭建顶部返回按钮
    private func setupBackButton_Clara() {
        let backBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        backBtn.tintColor = .white
        backBtn.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        backBtn.layer.cornerRadius = 18
        backBtn.layer.borderWidth = 1
        backBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        backBtn.addTarget(self, action: #selector(loginTapped_Clara), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
    }

    private func setupLogoArea_Clara() {
        view.addSubview(logoContainer_Clara)
        logoContainer_Clara.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            make.centerX.equalToSuperview()
        }

        logoContainer_Clara.addSubview(createBadgeLabel_Clara)
        logoContainer_Clara.addSubview(logoIconView_Clara)
        logoContainer_Clara.addSubview(titleLabel_Clara)
        logoContainer_Clara.addSubview(subtitleLabel_Clara)

        let firstPill = makeFeaturePill_Clara(text_Clara: "Safe sign up")
        let secondPill = makeFeaturePill_Clara(text_Clara: "Create profile")
        logoContainer_Clara.addSubview(firstPill)
        logoContainer_Clara.addSubview(secondPill)

        createBadgeLabel_Clara.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(94)
            make.height.equalTo(24)
        }

        logoIconView_Clara.snp.makeConstraints { make in
            make.top.equalTo(createBadgeLabel_Clara.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }
        titleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        subtitleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Clara.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        firstPill.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Clara.snp.bottom).offset(12)
            make.right.equalTo(logoContainer_Clara.snp.centerX).offset(-6)
            make.height.equalTo(26)
            make.bottom.equalToSuperview()
        }
        secondPill.snp.makeConstraints { make in
            make.top.equalTo(firstPill.snp.top)
            make.left.equalTo(logoContainer_Clara.snp.centerX).offset(6)
            make.height.equalTo(26)
            make.bottom.equalToSuperview()
        }
    }

    private func setupFormCard_Clara() {
        view.addSubview(formCard_Clara)
        formCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(logoContainer_Clara.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
        }

        let formTitleLabel = UILabel()
        formTitleLabel.text = "Create your account"
        formTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        formTitleLabel.textColor = ColorConfig_Clara.textPrimary_Clara

        let formSubtitleLabel = UILabel()
        formSubtitleLabel.text = "Set up your identity and start sharing with the community."
        formSubtitleLabel.font = UIFont.systemFont(ofSize: 13)
        formSubtitleLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        formSubtitleLabel.numberOfLines = 2

        formCard_Clara.addSubview(formTitleLabel)
        formCard_Clara.addSubview(formSubtitleLabel)
        formTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.right.equalToSuperview().inset(20)
        }
        formSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(formTitleLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
        }

        let userRow = makeInputRow_Clara(icon: "person.fill", field: usernameField_Clara, showDivider: true)
        let pwdRow = makeInputRow_Clara(icon: "lock.fill", field: passwordField_Clara, showDivider: true)
        let confirmRow = makeInputRow_Clara(icon: "lock.rotation", field: confirmPasswordField_Clara, showDivider: false)

        formCard_Clara.addSubview(userRow)
        formCard_Clara.addSubview(pwdRow)
        formCard_Clara.addSubview(confirmRow)

        userRow.snp.makeConstraints { make in
            make.top.equalTo(formSubtitleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        pwdRow.snp.makeConstraints { make in
            make.top.equalTo(userRow.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        confirmRow.snp.makeConstraints { make in
            make.top.equalTo(pwdRow.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }

        usernameField_Clara.delegate = self
        passwordField_Clara.delegate = self
        confirmPasswordField_Clara.delegate = self

        formCard_Clara.addSubview(registerButton_Clara)
        registerButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(confirmRow.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        registerButton_Clara.addTarget(self, action: #selector(registerTapped_Clara), for: .touchUpInside)

        // 已有账号跳登录
        setupLoginPrompt_Clara()
    }

    private func setupLoginPrompt_Clara() {
        formCard_Clara.addSubview(loginPromptView_Clara)
        loginPromptView_Clara.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Clara.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(22)
        }

        let haveLabel = UILabel()
        haveLabel.text = "Already have an account? "
        haveLabel.font = UIFont.systemFont(ofSize: 13)
        haveLabel.textColor = ColorConfig_Clara.textSecondary_Clara

        let loginLabel = UILabel()
        loginLabel.text = "Sign In"
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        loginLabel.textColor = ColorConfig_Clara.secondaryGradientStart_Clara

        loginPromptView_Clara.addSubview(haveLabel)
        loginPromptView_Clara.addSubview(loginLabel)

        haveLabel.snp.makeConstraints { make in make.left.top.bottom.equalToSuperview() }
        loginLabel.snp.makeConstraints { make in
            make.left.equalTo(haveLabel.snp.right)
            make.top.bottom.right.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(loginTapped_Clara))
        loginPromptView_Clara.addGestureRecognizer(tap)
    }

    private func setupProtocolLabel_Clara() {
        let label = ProtocolHelper_Clara.createProtocolTextLabel_Clara(
            firstContent_Clara: "terms.png",
            secondContent_Clara: "privacy.png",
            config_Clara: ProtocolHelper_Clara.ProtocolTextConfig_Clara.light_Clara(),
            from: self
        )
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(formCard_Clara.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(30)
        }
    }

    /// 创建带图标的输入行
    private func makeInputRow_Clara(icon: String, field: UITextField, showDivider: Bool) -> UIView {
        let row = UIView()
        let iconView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: cfg)
        iconView.tintColor = ColorConfig_Clara.secondaryGradientStart_Clara
        iconView.contentMode = .scaleAspectFit

        row.addSubview(iconView)
        row.addSubview(field)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        field.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }

        if showDivider {
            let div = UIView()
            div.backgroundColor = ColorConfig_Clara.divider_Clara
            row.addSubview(div)
            div.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
        return row
    }

    /// 创建顶部功能胶囊标签
    /// - Parameter text_Clara: 展示文案
    /// - Returns: 配置完成的胶囊标签
    private func makeFeaturePill_Clara(text_Clara: String) -> UILabel {
        let label = UILabel()
        label.text = "  \(text_Clara)  "
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        label.layer.cornerRadius = 13
        label.clipsToBounds = true
        return label
    }

    // MARK: - 事件响应

    /// 注册按钮点击（三重校验后调用 ViewModel）
    @objc private func registerTapped_Clara() {
        view.endEditing(true)

        let username = usernameField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm = confirmPasswordField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !username.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please enter a username")
            return
        }
        guard !password.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please enter a password")
            return
        }
        guard password == confirm else {
            Utils_Clara.showWarning_Clara(message_Clara: "Passwords do not match")
            return
        }

        UserViewModel_Clara.shared_Clara.loginById_Clara(userId_clara: 8454127)
    }

    @objc private func loginTapped_Clara() {
        if let navigationController = navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else if let navigationController = navigationController,
                  navigationController.presentingViewController != nil {
            navigationController.dismiss(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension Register_Clara: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Clara {
            passwordField_Clara.becomeFirstResponder()
        } else if textField == passwordField_Clara {
            confirmPasswordField_Clara.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            registerTapped_Clara()
        }
        return true
    }
}
