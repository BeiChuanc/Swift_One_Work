import Foundation
import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页面
/// 核心功能：提供用户名+密码登录，以及跳转注册页的入口
/// 设计思路：全屏渐变背景，白色磨砂卡片承载表单；
///           登录时优先校验输入非空，通过 UserViewModel.loginById_Clara 执行登录
/// 关键方法：
/// - loginTapped_Clara: 校验 → 调用 ViewModel 登录
class Login_Clara: UIViewController {

    // MARK: - UI 组件

    /// 全屏渐变背景
    private let gradientBgView_Clara = UIView()
    private var gradientBgLayer_Clara: CAGradientLayer?

    /// 顶部 Logo 与 App 名
    private let logoContainer_Clara = UIView()

    private let logoIconView_Clara: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 52, weight: .medium)
        iv.image = UIImage(systemName: "flame.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let appNameLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Clara"
        l.font = UIFont(name: "AvenirNext-Bold", size: 38) ?? UIFont.systemFont(ofSize: 38, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let taglineLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Warmth around every fire"
        l.font = UIFont.systemFont(ofSize: 14, weight: .light)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        return l
    }()

    /// 顶部欢迎角标
    private let welcomeBadgeLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Welcome Back"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        return l
    }()

    /// 表单卡片
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

    /// 用户名输入框
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

    /// 密码输入框
    private let passwordField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    /// 登录按钮
    private let loginButton_Clara: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        return btn
    }()

    /// 注册跳转按钮
    private let registerPromptView_Clara: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 协议标签
    private var protocolLabel_Clara: UILabel?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupGradientBackground_Clara()
        setupCloseButton_Clara()
        setupLogoArea_Clara()
        setupFormCard_Clara()
        setupProtocolLabel_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gl = gradientBgLayer_Clara {
            gl.frame = gradientBgView_Clara.bounds
        } else {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: gradientBgView_Clara.bounds)
            gradientBgView_Clara.layer.insertSublayer(gl, at: 0)
            gradientBgLayer_Clara = gl
        }
        // 登录按钮渐变
        loginButton_Clara.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let btnGl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: loginButton_Clara.bounds)
        btnGl.cornerRadius = 22
        loginButton_Clara.layer.insertSublayer(btnGl, at: 0)
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - UI 搭建

    /// 搭建全屏渐变背景
    private func setupGradientBackground_Clara() {
        view.addSubview(gradientBgView_Clara)
        gradientBgView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.52)
        }

        // 装饰圆增强顶部层次
        let largeCircle = UIView()
        largeCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        largeCircle.layer.cornerRadius = 74
        gradientBgView_Clara.addSubview(largeCircle)
        largeCircle.snp.makeConstraints { make in
            make.width.height.equalTo(148)
            make.right.equalToSuperview().inset(-34)
            make.top.equalToSuperview().offset(56)
        }

        let smallCircle = UIView()
        smallCircle.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        smallCircle.layer.cornerRadius = 42
        gradientBgView_Clara.addSubview(smallCircle)
        smallCircle.snp.makeConstraints { make in
            make.width.height.equalTo(84)
            make.left.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(16)
        }
    }

    /// 搭建顶部关闭按钮
    private func setupCloseButton_Clara() {
        let closeBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        closeBtn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        closeBtn.tintColor = .white
        closeBtn.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        closeBtn.layer.cornerRadius = 18
        closeBtn.layer.borderWidth = 1
        closeBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        closeBtn.addTarget(self, action: #selector(closeTapped_Clara), for: .touchUpInside)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
    }

    /// 搭建 Logo + AppName 区域
    private func setupLogoArea_Clara() {
        view.addSubview(logoContainer_Clara)
        logoContainer_Clara.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(36)
            make.centerX.equalToSuperview()
        }

        logoContainer_Clara.addSubview(welcomeBadgeLabel_Clara)
        logoContainer_Clara.addSubview(logoIconView_Clara)
        logoContainer_Clara.addSubview(appNameLabel_Clara)
        logoContainer_Clara.addSubview(taglineLabel_Clara)

        let firstPill = makeFeaturePill_Clara(text_Clara: "Private chats")
        let secondPill = makeFeaturePill_Clara(text_Clara: "Fresh moments")
        logoContainer_Clara.addSubview(firstPill)
        logoContainer_Clara.addSubview(secondPill)

        welcomeBadgeLabel_Clara.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(112)
            make.height.equalTo(24)
        }

        logoIconView_Clara.snp.makeConstraints { make in
            make.top.equalTo(welcomeBadgeLabel_Clara.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        appNameLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        taglineLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel_Clara.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        firstPill.snp.makeConstraints { make in
            make.top.equalTo(taglineLabel_Clara.snp.bottom).offset(12)
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

    /// 搭建白色表单卡片（输入框 + 按钮）
    private func setupFormCard_Clara() {
        view.addSubview(formCard_Clara)
        formCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(logoContainer_Clara.snp.bottom).offset(36)
            make.left.right.equalToSuperview().inset(24)
        }

        let formTitleLabel = UILabel()
        formTitleLabel.text = "Sign in to continue"
        formTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        formTitleLabel.textColor = ColorConfig_Clara.textPrimary_Clara

        let formSubtitleLabel = UILabel()
        formSubtitleLabel.text = "Access your chats, profile and moments in one place."
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

        // 用户名行
        let userRow = makeInputRow_Clara(icon: "person.fill", field: usernameField_Clara, showDivider: true)
        formCard_Clara.addSubview(userRow)
        userRow.snp.makeConstraints { make in
            make.top.equalTo(formSubtitleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.height.equalTo(58)
        }
        usernameField_Clara.delegate = self

        // 密码行
        let pwdRow = makeInputRow_Clara(icon: "lock.fill", field: passwordField_Clara, showDivider: false)
        formCard_Clara.addSubview(pwdRow)
        pwdRow.snp.makeConstraints { make in
            make.top.equalTo(userRow.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(58)
        }
        passwordField_Clara.delegate = self

        // 登录按钮
        formCard_Clara.addSubview(loginButton_Clara)
        loginButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(pwdRow.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        loginButton_Clara.addTarget(self, action: #selector(loginTapped_Clara), for: .touchUpInside)

        // 注册跳转提示
        setupRegisterPrompt_Clara()
    }

    /// 搭建注册跳转提示行
    private func setupRegisterPrompt_Clara() {
        formCard_Clara.addSubview(registerPromptView_Clara)
        registerPromptView_Clara.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Clara.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(22)
        }

        let noAccountLabel = UILabel()
        noAccountLabel.text = "Don't have an account? "
        noAccountLabel.font = UIFont.systemFont(ofSize: 13)
        noAccountLabel.textColor = ColorConfig_Clara.textSecondary_Clara

        let registerLabel = UILabel()
        registerLabel.text = "Sign Up"
        registerLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        registerLabel.textColor = ColorConfig_Clara.primaryGradientStart_Clara

        registerPromptView_Clara.addSubview(noAccountLabel)
        registerPromptView_Clara.addSubview(registerLabel)

        noAccountLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        registerLabel.snp.makeConstraints { make in
            make.left.equalTo(noAccountLabel.snp.right)
            make.top.bottom.right.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(registerTapped_Clara))
        registerPromptView_Clara.addGestureRecognizer(tap)
    }

    /// 搭建协议标签（置于卡片下方）
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
        protocolLabel_Clara = label
    }

    /// 创建带图标的输入行
    private func makeInputRow_Clara(icon: String, field: UITextField, showDivider: Bool) -> UIView {
        let row = UIView()
        let iconView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: cfg)
        iconView.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
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

    /// 登录按钮点击（校验非空后调用 ViewModel）
    @objc private func loginTapped_Clara() {
        view.endEditing(true)

        let username = usernameField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !username.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please enter your username")
            return
        }
        guard !password.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please enter your password")
            return
        }

        // 使用用户名哈希值作为模拟 userId（项目本地数据无真实服务器）
        let mockId = abs(username.hashValue) % 100 + 1
        UserViewModel_Clara.shared_Clara.loginById_Clara(userId_clara: mockId)
    }

    @objc private func registerTapped_Clara() {
        Navigation_Clara.toRegister_Clara(style_clara: .push_clara)
    }

    /// 顶部关闭按钮点击事件
    @objc private func closeTapped_Clara() {
        if let navigationController = navigationController,
           navigationController.viewControllers.first == self,
           navigationController.presentingViewController != nil {
            navigationController.dismiss(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension Login_Clara: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Clara {
            passwordField_Clara.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginTapped_Clara()
        }
        return true
    }
}
