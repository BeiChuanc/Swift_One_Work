import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录页面视图控制器
/// 核心作用：收集用户名与密码完成本地演示登录，并提供注册入口、Apple 登录与协议入口
/// 设计思路：
///   - 背景采用淡紫到白色的柔和渐变，叠加两枚低透明度的"摆件光晕"装饰圆，
///     呼应桌面摆件主题，避免纯白背景显得单调空旷
///   - 头部徽标改为白色描边 + 强调色投影的"悬浮徽章"造型，强化品牌辨识度
///   - 用户名/密码卡片式输入框统一描边，聚焦时描边切换为强调色提供清晰反馈
///   - 登录主按钮采用紫粉品牌渐变 + 投影，替代原本的纯色背景，视觉分量更突出
///   - 分割线由"横线 + or + 横线"组成，替代孤立漂浮的文字，过渡更自然
///   - 登录统一走 UserViewModel_Orna.loginById_Orna：先通过 LocalData_Orna 将用户名解析为稳定 ID
///   - 底部协议文案使用 ProtocolHelper_Orna 展示 Assets 中的条款配图
/// 关键属性：
///   - appleLoginManager_Orna: 持有 Apple 登录管理器，避免授权回调前被释放
class Login_Orna: UIViewController, UITextFieldDelegate {

    /// Apple 登录管理器（需要强引用，避免授权流程中途被释放）
    private var appleLoginManager_Orna: AppleLoginManager_Orna?

    // MARK: - UI · 背景装饰

    /// 全屏柔和渐变背景（淡紫 → 白），替代原本单调的纯白底色
    private let backgroundGradientLayer_Orna: CAGradientLayer = {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#F0EBFF").cgColor,
            UIColor.white.cgColor
        ]
        layer_orna.locations = [0, 0.45]
        return layer_orna
    }()

    /// 装饰性光晕圆：低透明度大圆点，呼应"桌面摆件"发光摆件的意象
    private let decorCircleTop_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.10)
        return v
    }()

    private let decorCircleBottom_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.08)
        return v
    }()

    // MARK: - UI · 顶部工具条

    private let closeButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.12
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    // MARK: - UI · 头部装饰

    /// 徽标外层白色描边容器，营造"悬浮徽章"层叠效果
    private let logoRingView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.25
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 20
        return v
    }()

    private let logoBadgeView_Orna: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var logoGradientLayer_Orna: CAGradientLayer?

    private let logoIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let welcomeLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Welcome Back"
        l.font = .systemFont(ofSize: 25, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "✨ Sign in to visit your desk"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 输入区

    private let usernameField_Orna = Login_Orna.makeInputField_Orna(icon_orna: "person.fill", placeholder_orna: "Username")
    private let passwordField_Orna = Login_Orna.makeInputField_Orna(icon_orna: "lock.fill", placeholder_orna: "Password", isSecure_orna: true)

    // MARK: - UI · 操作区

    private let loginButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Log In", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.layer.cornerRadius = 24
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.3
        b.layer.shadowOffset = CGSize(width: 0, height: 8)
        b.layer.shadowRadius = 14
        return b
    }()

    private var loginButtonGradientLayer_Orna: CAGradientLayer?

    private let signUpPromptButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let text_orna = "Don't have an account? Sign Up"
        let attr_orna = NSMutableAttributedString(
            string: text_orna,
            attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor(hexstring_Orna: "#8B87A0")]
        )
        attr_orna.addAttributes(
            [.font: UIFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor: UIColor(hexstring_Orna: "#7B61FF")],
            range: NSRange(location: text_orna.count - 8, length: 8)
        )
        b.setAttributedTitle(attr_orna, for: .normal)
        return b
    }()

    // MARK: - UI · 分割线（横线 + or + 横线）

    private let dividerLeftLine_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#EDE9FE")
        return v
    }()

    private let dividerRightLine_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#EDE9FE")
        return v
    }()

    private let dividerLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "or"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(hexstring_Orna: "#B5AFCB")
        l.textAlignment = .center
        return l
    }()

    private lazy var appleLoginButton_Orna = AppleLoginBt_Orna { [weak self] in
        self?.handleAppleLoginTapped_Orna()
    }

    private lazy var protocolLabel_Orna: UILabel = ProtocolHelper_Orna.createProtocolTextLabel_Orna(
        firstProtocol_Orna: .terms_Orna,
        firstContent_Orna: "terms.png",
        secondProtocol_Orna: .privacy_Orna,
        secondContent_Orna: "privacy.png",
        config_Orna: ProtocolHelper_Orna.ProtocolTextConfig_Orna(
            textColor_Orna: UIColor(hexstring_Orna: "#B5AFCB"),
            linkColor_Orna: UIColor(hexstring_Orna: "#7B61FF"),
            fontSize_Orna: 12,
            hasUnderline_Orna: true
        ),
        from: self
    )

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(backgroundGradientLayer_Orna, at: 0)
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Orna.frame = view.bounds
        logoGradientLayer_Orna?.frame = logoBadgeView_Orna.bounds
        loginButtonGradientLayer_Orna?.frame = loginButton_Orna.bounds
        logoRingView_Orna.layer.cornerRadius = logoRingView_Orna.bounds.width / 2
        logoBadgeView_Orna.layer.cornerRadius = logoBadgeView_Orna.bounds.width / 2
        decorCircleTop_Orna.layer.cornerRadius = decorCircleTop_Orna.bounds.width / 2
        decorCircleBottom_Orna.layer.cornerRadius = decorCircleBottom_Orna.bounds.width / 2
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(decorCircleTop_Orna)
        view.addSubview(decorCircleBottom_Orna)

        view.addSubview(closeButton_Orna)

        view.addSubview(logoRingView_Orna)
        logoRingView_Orna.addSubview(logoBadgeView_Orna)
        setupLogoGradient_Orna()
        logoBadgeView_Orna.addSubview(logoIconView_Orna)
        view.addSubview(welcomeLabel_Orna)
        view.addSubview(subtitleLabel_Orna)

        view.addSubview(usernameField_Orna)
        view.addSubview(passwordField_Orna)
        usernameField_Orna.delegate = self
        passwordField_Orna.delegate = self

        view.addSubview(loginButton_Orna)
        setupLoginButtonGradient_Orna()
        view.addSubview(signUpPromptButton_Orna)

        view.addSubview(dividerLeftLine_Orna)
        view.addSubview(dividerLabel_Orna)
        view.addSubview(dividerRightLine_Orna)
        view.addSubview(appleLoginButton_Orna)
        view.addSubview(protocolLabel_Orna)
    }

    private func setupLogoGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#B794F6").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        logoBadgeView_Orna.layer.insertSublayer(layer_orna, at: 0)
        logoGradientLayer_Orna = layer_orna
    }

    /// 登录主按钮紫粉品牌渐变背景，替代原纯色背板，与全 App 主要 CTA 视觉呼应
    private func setupLoginButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#9B7BFF").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        loginButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        loginButtonGradientLayer_Orna = layer_orna
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        decorCircleTop_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-60)
            $0.trailing.equalToSuperview().offset(70)
            $0.width.height.equalTo(220)
        }
        decorCircleBottom_Orna.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(-90)
            $0.width.height.equalTo(200)
        }

        closeButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }

        logoRingView_Orna.snp.makeConstraints {
            $0.top.equalTo(closeButton_Orna.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(92)
        }
        logoBadgeView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(76)
        }
        logoIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        welcomeLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(logoRingView_Orna.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel_Orna.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }

        usernameField_Orna.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel_Orna.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        passwordField_Orna.snp.makeConstraints {
            $0.top.equalTo(usernameField_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        loginButton_Orna.snp.makeConstraints {
            $0.top.equalTo(passwordField_Orna.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        signUpPromptButton_Orna.snp.makeConstraints {
            $0.top.equalTo(loginButton_Orna.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }

        dividerLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(signUpPromptButton_Orna.snp.bottom).offset(26)
            $0.centerX.equalToSuperview()
        }
        dividerLeftLine_Orna.snp.makeConstraints {
            $0.centerY.equalTo(dividerLabel_Orna)
            $0.trailing.equalTo(dividerLabel_Orna.snp.leading).offset(-12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(1)
        }
        dividerRightLine_Orna.snp.makeConstraints {
            $0.centerY.equalTo(dividerLabel_Orna)
            $0.leading.equalTo(dividerLabel_Orna.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(1)
        }
        appleLoginButton_Orna.snp.makeConstraints {
            $0.top.equalTo(dividerLabel_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        protocolLabel_Orna.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        closeButton_Orna.addTarget(self, action: #selector(handleCloseTapped_Orna), for: .touchUpInside)
        loginButton_Orna.addTarget(self, action: #selector(handleLoginTapped_Orna), for: .touchUpInside)
        signUpPromptButton_Orna.addTarget(self, action: #selector(handleSignUpTapped_Orna), for: .touchUpInside)
    }

    // MARK: - UITextFieldDelegate

    /// 输入框获得焦点时描边切换为强调色，提供清晰的聚焦反馈
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.5).cgColor
        }
    }

    /// 输入框失去焦点时描边恢复为默认浅紫色
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
        }
    }

    // MARK: - 事件处理

    @objc private func handleCloseTapped_Orna() {
        if presentingViewController != nil || navigationController?.presentingViewController != nil {
            Navigation_Orna.dismiss_Orna(from: self)
        } else {
            Navigation_Orna.pop_Orna(from: self)
        }
    }

    @objc private func handleSignUpTapped_Orna() {
        Navigation_Orna.toRegister_Orna(style_orna: .push_orna)
    }

    /// 登录按钮点击：校验非空后通过用户名解析ID并登录
    @objc private func handleLoginTapped_Orna() {
        let username_orna = (usernameField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password_orna = (passwordField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !username_orna.isEmpty, !password_orna.isEmpty else {
            Load_Orna.showWarning_Orna(message_Orna: "Please enter both username and password.")
            return
        }

        let userId_orna = LocalData_Orna.shared_Orna.resolveUserId_Orna(byName: username_orna)
        UserViewModel_Orna.shared_Orna.loginById_Orna(userId_orna: userId_orna, userName_orna: username_orna)
    }

    /// Apple 登录：授权成功后使用返回账号作为用户名解析ID登录
    private func handleAppleLoginTapped_Orna() {
        let manager_orna = AppleLoginManager_Orna(viewController_Orna: self)
        appleLoginManager_Orna = manager_orna
        manager_orna.startAppleLogin_Orna(
            success_Orna: { [weak self] account_orna in
                let userId_orna = LocalData_Orna.shared_Orna.resolveUserId_Orna(byName: account_orna)
                UserViewModel_Orna.shared_Orna.loginById_Orna(userId_orna: userId_orna, userName_orna: account_orna)
                self?.appleLoginManager_Orna = nil
            },
            failure_Orna: { [weak self] message_orna in
                Load_Orna.showError_Orna(message_Orna: message_orna)
                self?.appleLoginManager_Orna = nil
            }
        )
    }

    // MARK: - 工具方法

    /// 创建统一样式的圆角卡片输入框（浅紫底 + 描边，聚焦时描边切换为强调色）
    private static func makeInputField_Orna(icon_orna: String, placeholder_orna: String, isSecure_orna: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = placeholder_orna
        tf.isSecureTextEntry = isSecure_orna
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = UIColor(hexstring_Orna: "#8B87A0")
        iconView_orna.contentMode = .scaleAspectFit
        let container_orna = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        container_orna.addSubview(iconView_orna)
        iconView_orna.frame = CGRect(x: 16, y: 2, width: 16, height: 16)
        tf.leftView = container_orna
        tf.leftViewMode = .always
        return tf
    }
}
