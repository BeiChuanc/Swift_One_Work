import UIKit
import SnapKit

// MARK: 登录页

/// 登录页
/// 功能：提供用户名+密码登录、Apple 登录入口，展示协议链接，校验输入非空
/// 设计：深紫→靛蓝→天蓝三色渐变全屏背景 + 顶部品牌区（App 名 + 鸟类图标群）+ 底部白色浮起表单卡片
class Login_Ornit: UIViewController {

    // MARK: - UI 组件

    /// 全屏渐变背景图层
    private var backgroundGradient_Ornit: CAGradientLayer?

    /// 顶部品牌插画区
    private let brandView_Ornit = UIView()

    /// 关闭按钮（右上角半透明圆形）
    private let closeButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_ornit.setImage(
            UIImage(systemName: "xmark", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = .white
        btn_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.2)
        btn_ornit.layer.cornerRadius = 18
        return btn_ornit
    }()

    /// 白色表单卡片（底部浮起，上圆角）
    private let formCard_Ornit = UIView()

    /// 表单标题
    private let appTitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Welcome Back"
        label_ornit.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        return label_ornit
    }()

    /// 表单副标题
    private let appSubtitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Sign in to continue birding"
        label_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        return label_ornit
    }()

    /// 用户名输入框
    private let usernameField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Username"
        tf_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.backgroundColor = .clear
        tf_ornit.autocapitalizationType = .none
        tf_ornit.autocorrectionType = .no
        tf_ornit.returnKeyType = .next
        return tf_ornit
    }()

    /// 密码输入框
    private let passwordField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Password"
        tf_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.backgroundColor = .clear
        tf_ornit.isSecureTextEntry = true
        tf_ornit.returnKeyType = .done
        return tf_ornit
    }()

    /// 密码可见切换按钮
    private let eyeButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        btn_ornit.setImage(
            UIImage(systemName: "eye.slash.fill", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = ColorConfig_Ornit.textPlaceholder_Ornit
        return btn_ornit
    }()

    /// 登录按钮（渐变 + 阴影）
    private let loginButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.setTitle("Sign In", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_ornit.setTitleColor(.white, for: .normal)
        btn_ornit.layer.cornerRadius = 16
        btn_ornit.layer.masksToBounds = true
        return btn_ornit
    }()

    /// 登录按钮渐变图层
    private var loginGradient_Ornit: CAGradientLayer?

    /// Apple 登录组件
    private var appleLoginView_Ornit: AppleLoginBt_Ornit?

    /// "OR" 分割线容器
    private let dividerContainer_Ornit = UIView()

    /// 跳转注册按钮
    private let registerButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        let attrStr_ornit = NSMutableAttributedString(
            string: "No account? ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: ColorConfig_Ornit.textSecondary_Ornit
            ]
        )
        attrStr_ornit.append(NSAttributedString(
            string: "Register",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: ColorConfig_Ornit.meAccent_Ornit
            ]
        ))
        btn_ornit.setAttributedTitle(attrStr_ornit, for: .normal)
        return btn_ornit
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Ornit()
        setupBrandView_Ornit()
        setupCloseButton_Ornit()
        setupFormCard_Ornit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient_Ornit?.frame = view.bounds
        loginGradient_Ornit?.frame = loginButton_Ornit.bounds
    }

    // MARK: - UI 搭建

    /// 构建全屏三色渐变背景（深紫 → 靛蓝 → 天蓝）
    private func setupBackground_Ornit() {
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor,
            ColorConfig_Ornit.messageGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.locations = [0, 0.5, 1]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient_ornit, at: 0)
        backgroundGradient_Ornit = gradient_ornit
    }

    /// 构建顶部品牌区（App 名 + 标语 + 鸟类图标群 + 装饰圆）
    private func setupBrandView_Ornit() {
        view.addSubview(brandView_Ornit)

        // 背景装饰大圆（右上角）
        let decoBig_ornit = UIView()
        decoBig_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.06)
        decoBig_ornit.layer.cornerRadius = 80
        brandView_Ornit.addSubview(decoBig_ornit)

        // 背景装饰小圆（左下角）
        let decoSmall_ornit = UIView()
        decoSmall_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        decoSmall_ornit.layer.cornerRadius = 48
        brandView_Ornit.addSubview(decoSmall_ornit)

        // App 名称
        let appNameLabel_ornit = UILabel()
        appNameLabel_ornit.text = "Ornit"
        appNameLabel_ornit.font = UIFont.systemFont(ofSize: 42, weight: .black)
        appNameLabel_ornit.textColor = .white
        brandView_Ornit.addSubview(appNameLabel_ornit)

        // App 标语
        let taglineLabel_ornit = UILabel()
        taglineLabel_ornit.text = "Track every sighting"
        taglineLabel_ornit.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        taglineLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.78)
        brandView_Ornit.addSubview(taglineLabel_ornit)

        // 主鸟图标
        let birdConfig_ornit = UIImage.SymbolConfiguration(pointSize: 44, weight: .thin)
        let birdIcon_ornit = UIImageView(
            image: UIImage(systemName: "bird.fill", withConfiguration: birdConfig_ornit)
        )
        birdIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.9)
        brandView_Ornit.addSubview(birdIcon_ornit)

        // 辅助：望远镜图标
        let binoConfig_ornit = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        let binoIcon_ornit = UIImageView(
            image: UIImage(systemName: "binoculars", withConfiguration: binoConfig_ornit)
        )
        binoIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.5)
        brandView_Ornit.addSubview(binoIcon_ornit)

        // 辅助：叶片图标
        let leafConfig_ornit = UIImage.SymbolConfiguration(pointSize: 18, weight: .light)
        let leafIcon_ornit = UIImageView(
            image: UIImage(systemName: "leaf.fill", withConfiguration: leafConfig_ornit)
        )
        leafIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.4)
        brandView_Ornit.addSubview(leafIcon_ornit)

        brandView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            // 固定高度与 formCard 的 top offset 一致，避免跨层级约束错误
            make_ornit.height.equalTo(220)
        }

        decoBig_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(50)
            make_ornit.top.equalToSuperview().offset(-30)
            make_ornit.width.height.equalTo(160)
        }

        decoSmall_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-24)
            make_ornit.bottom.equalToSuperview().offset(24)
            make_ornit.width.height.equalTo(96)
        }

        birdIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-32)
            make_ornit.centerY.equalToSuperview().offset(-10)
            make_ornit.width.height.equalTo(62)
        }

        appNameLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.centerY.equalToSuperview().offset(-8)
        }

        taglineLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.top.equalTo(appNameLabel_ornit.snp.bottom).offset(5)
        }

        binoIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(taglineLabel_ornit.snp.trailing).offset(16)
            make_ornit.centerY.equalTo(taglineLabel_ornit)
            make_ornit.width.height.equalTo(30)
        }

        leafIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.top.equalTo(taglineLabel_ornit.snp.bottom).offset(6)
            make_ornit.width.height.equalTo(24)
        }
    }

    /// 构建右上角关闭按钮
    private func setupCloseButton_Ornit() {
        view.addSubview(closeButton_Ornit)
        closeButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(36)
        }
        closeButton_Ornit.addTarget(self, action: #selector(closeTapped_Ornit), for: .touchUpInside)
    }

    /// 构建底部白色浮起表单卡片
    private func setupFormCard_Ornit() {
        formCard_Ornit.backgroundColor = .white
        formCard_Ornit.layer.cornerRadius = 32
        formCard_Ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        formCard_Ornit.layer.shadowColor = UIColor.black.cgColor
        formCard_Ornit.layer.shadowOpacity = 0.12
        formCard_Ornit.layer.shadowRadius = 24
        view.addSubview(formCard_Ornit)

        formCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.bottom.equalToSuperview()
            make_ornit.top.equalToSuperview().offset(220)
        }

        // 表单标题
        formCard_Ornit.addSubview(appTitleLabel_Ornit)
        formCard_Ornit.addSubview(appSubtitleLabel_Ornit)

        appTitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(32)
            make_ornit.leading.equalToSuperview().offset(28)
        }

        appSubtitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(appTitleLabel_Ornit.snp.bottom).offset(5)
            make_ornit.leading.equalToSuperview().offset(28)
        }

        // 用户名输入框
        let userContainer_ornit = setupInputField_Ornit(
            textField_ornit: usernameField_Ornit,
            iconName_ornit: "person.fill",
            topAnchor_ornit: appSubtitleLabel_Ornit.snp.bottom,
            topOffset_ornit: 28
        )

        // 密码输入框
        let passContainer_ornit = setupInputField_Ornit(
            textField_ornit: passwordField_Ornit,
            iconName_ornit: "lock.fill",
            topAnchor_ornit: userContainer_ornit.snp.bottom,
            topOffset_ornit: 14
        )

        // 密码可见切换按钮
        let eyeContainer_ornit = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        eyeContainer_ornit.addSubview(eyeButton_Ornit)
        eyeButton_Ornit.frame = eyeContainer_ornit.bounds
        passwordField_Ornit.rightView = eyeContainer_ornit
        passwordField_Ornit.rightViewMode = .always
        eyeButton_Ornit.addTarget(self, action: #selector(togglePasswordVisibility_Ornit), for: .touchUpInside)

        // 登录按钮（含渐变 wrapper 阴影）
        let loginWrapper_ornit = UIView()
        loginWrapper_ornit.layer.cornerRadius = 16
        loginWrapper_ornit.layer.shadowColor = ColorConfig_Ornit.meGradientEnd_Ornit.withValues(alpha: 0.45).cgColor
        loginWrapper_ornit.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginWrapper_ornit.layer.shadowOpacity = 1
        loginWrapper_ornit.layer.shadowRadius = 14
        formCard_Ornit.addSubview(loginWrapper_ornit)
        loginWrapper_ornit.addSubview(loginButton_Ornit)

        let btnGrad_ornit = CAGradientLayer()
        btnGrad_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        btnGrad_ornit.startPoint = CGPoint(x: 0, y: 0.5)
        btnGrad_ornit.endPoint = CGPoint(x: 1, y: 0.5)
        loginButton_Ornit.layer.insertSublayer(btnGrad_ornit, at: 0)
        // 立即设置 frame，确保按钮初始即可见
        btnGrad_ornit.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 56, height: 54)
        loginGradient_Ornit = btnGrad_ornit

        loginWrapper_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(passContainer_ornit.snp.bottom).offset(28)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.height.equalTo(54)
        }
        loginButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        loginButton_Ornit.addTarget(self, action: #selector(loginTapped_Ornit), for: .touchUpInside)

        // "OR" 分割线
        setupDivider_Ornit(topAnchor_ornit: loginWrapper_ornit.snp.bottom)

        // Apple 登录
        let appleView_ornit = AppleLoginBt_Ornit(onTap_Ornit: { [weak self] in
            self?.handleAppleLogin_Ornit()
        })
        appleLoginView_Ornit = appleView_ornit
        formCard_Ornit.addSubview(appleView_ornit)
        appleView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(dividerContainer_Ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.height.equalTo(50)
        }

        // 注册跳转按钮
        formCard_Ornit.addSubview(registerButton_Ornit)
        registerButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(appleView_ornit.snp.bottom).offset(16)
            make_ornit.centerX.equalToSuperview()
        }

        // 协议文本
        let protocolLabel_ornit = ProtocolHelper_Ornit.createProtocolTextLabel_Ornit(
            firstContent_Ornit: "terms.png",
            secondContent_Ornit: "privacy.png",
            config_Ornit: .light_Ornit(),
            from: self
        )
        formCard_Ornit.addSubview(protocolLabel_ornit)
        protocolLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(registerButton_Ornit.snp.bottom).offset(12)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
        }

        usernameField_Ornit.delegate = self
        passwordField_Ornit.delegate = self
        registerButton_Ornit.addTarget(self, action: #selector(registerTapped_Ornit), for: .touchUpInside)
    }

    /// 创建带图标的输入框容器（浅色背景 + 紫色图标 + 细边框）
    /// - Parameters:
    ///   - textField_ornit: 输入框
    ///   - iconName_ornit: SF Symbol 图标名
    ///   - topAnchor_ornit: 上方约束锚点
    ///   - topOffset_ornit: 上方间距
    /// - Returns: 容器 UIView（用于链式约束）
    @discardableResult
    private func setupInputField_Ornit(
        textField_ornit: UITextField,
        iconName_ornit: String,
        topAnchor_ornit: ConstraintRelatableTarget,
        topOffset_ornit: CGFloat
    ) -> UIView {
        let container_ornit = UIView()
        container_ornit.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        container_ornit.layer.cornerRadius = 14
        container_ornit.layer.borderWidth = 1
        container_ornit.layer.borderColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.1).cgColor
        formCard_Ornit.addSubview(container_ornit)

        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: iconName_ornit, withConfiguration: config_ornit)
        )
        iconView_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit
        iconView_ornit.contentMode = .scaleAspectFit
        container_ornit.addSubview(iconView_ornit)

        container_ornit.addSubview(textField_ornit)

        container_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(topAnchor_ornit).offset(topOffset_ornit)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.height.equalTo(54)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(18)
        }

        textField_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(iconView_ornit.snp.trailing).offset(10)
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.centerY.equalToSuperview()
        }

        return container_ornit
    }

    /// 构建 "OR" 分割线
    private func setupDivider_Ornit(topAnchor_ornit: ConstraintRelatableTarget) {
        formCard_Ornit.addSubview(dividerContainer_Ornit)

        let leftLine_ornit = UIView()
        leftLine_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        dividerContainer_Ornit.addSubview(leftLine_ornit)

        let orLabel_ornit = UILabel()
        orLabel_ornit.text = "OR"
        orLabel_ornit.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        orLabel_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        dividerContainer_Ornit.addSubview(orLabel_ornit)

        let rightLine_ornit = UIView()
        rightLine_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        dividerContainer_Ornit.addSubview(rightLine_ornit)

        dividerContainer_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(topAnchor_ornit).offset(20)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.height.equalTo(20)
        }

        orLabel_ornit.snp.makeConstraints { make_ornit in make_ornit.center.equalToSuperview() }
        leftLine_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview()
            make_ornit.trailing.equalTo(orLabel_ornit.snp.leading).offset(-12)
            make_ornit.centerY.equalToSuperview()
            make_ornit.height.equalTo(0.5)
        }
        rightLine_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(orLabel_ornit.snp.trailing).offset(12)
            make_ornit.trailing.equalToSuperview()
            make_ornit.centerY.equalToSuperview()
            make_ornit.height.equalTo(0.5)
        }
    }

    // MARK: - 事件处理

    @objc private func closeTapped_Ornit() {
        Navigation_Ornit.dismiss_Ornit(from: self)
    }

    @objc private func togglePasswordVisibility_Ornit() {
        passwordField_Ornit.isSecureTextEntry.toggle()
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let iconName_ornit = passwordField_Ornit.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        eyeButton_Ornit.setImage(UIImage(systemName: iconName_ornit, withConfiguration: config_ornit), for: .normal)
    }

    /// 登录按钮点击 — 校验输入后执行登录
    @objc private func loginTapped_Ornit() {
        let username_ornit = usernameField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_ornit = passwordField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !username_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please enter your username")
            return
        }
        guard !password_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please enter your password")
            return
        }

        UIView.animate(withDuration: 0.1, animations: {
            self.loginButton_Ornit.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) { self.loginButton_Ornit.transform = .identity }
        }

        UserViewModel_Ornit.shared_Ornit.loginById_Ornit(userId_ornit: 845142)
    }

    private func handleAppleLogin_Ornit() {
        UserViewModel_Ornit.shared_Ornit.loginById_Ornit(userId_ornit: 9999)
    }

    @objc private func registerTapped_Ornit() {
        Navigation_Ornit.toRegister_Ornit(style_ornit: .push_ornit)
    }
}

// MARK: - UITextFieldDelegate

extension Login_Ornit: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Ornit {
            passwordField_Ornit.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginTapped_Ornit()
        }
        return true
    }
}
