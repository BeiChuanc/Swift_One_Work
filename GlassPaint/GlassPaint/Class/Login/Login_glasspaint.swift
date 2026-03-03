import Foundation
import UIKit
import SnapKit
import AuthenticationServices

// MARK: 登录页

/// 登录页面
/// 功能：提供用户登录功能，支持用户名密码登录和Apple登录
/// 设计：现代化登录界面，渐变背景，卡片式表单
class Login_Glasspaint: UIViewController {
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle1_Glasspaint = UIView()
    private let decorCircle2_Glasspaint = UIView()
    
    // Logo区域
    private let logoContainer_Glasspaint = UIView()
    private let logoImageView_Glasspaint = UIImageView()
    private let appTitleLabel_Glasspaint = UILabel()
    private let appSubtitleLabel_Glasspaint = UILabel()
    
    // 表单卡片
    private let formCard_Glasspaint = UIView()
    private let formGradientLayer_Glasspaint = CAGradientLayer()
    
    // 用户名输入
    private let usernameContainer_Glasspaint = UIView()
    private let usernameIconView_Glasspaint = UIImageView()
    private let usernameTextField_Glasspaint = UITextField()
    private let usernameDivider_Glasspaint = UIView()
    
    // 密码输入
    private let passwordContainer_Glasspaint = UIView()
    private let passwordIconView_Glasspaint = UIImageView()
    private let passwordTextField_Glasspaint = UITextField()
    private let passwordToggleButton_Glasspaint = UIButton(type: .system)
    private let passwordDivider_Glasspaint = UIView()
    
    // 登录按钮
    private let loginButton_Glasspaint = UIButton(type: .system)
    private let loginGradientLayer_Glasspaint = CAGradientLayer()
    
    // Apple登录按钮（自定义组件）
    private var appleLoginButton_Glasspaint: AppleLoginBt_Glasspaint!
    
    // Apple登录管理器
    private var appleLoginManager_Glasspaint: AppleLoginManager_Glasspaint?
    
    // 注册提示
    private let registerContainer_Glasspaint = UIView()
    private let registerPromptLabel_Glasspaint = UILabel()
    private let registerButton_Glasspaint = UIButton(type: .system)
    
    // 协议
    private var protocolLabel_Glasspaint: UILabel!
    
    // 关闭按钮
    private let closeButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginManager_Glasspaint()
        setupUI_Glasspaint()
        setupKeyboardObservers_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        formGradientLayer_Glasspaint.frame = formCard_Glasspaint.bounds
        loginGradientLayer_Glasspaint.frame = loginButton_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置Apple登录管理器
    private func setupAppleLoginManager_Glasspaint() {
        appleLoginManager_Glasspaint = AppleLoginManager_Glasspaint(viewController_Glasspaint: self)
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.keyboardDismissMode = .interactive
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // Logo区域
        contentView_Glasspaint.addSubview(logoContainer_Glasspaint)
        setupLogoSection_Glasspaint()
        
        // 表单卡片
        contentView_Glasspaint.addSubview(formCard_Glasspaint)
        setupFormCard_Glasspaint()
        
        // 登录按钮
        contentView_Glasspaint.addSubview(loginButton_Glasspaint)
        setupLoginButton_Glasspaint()
        
        // Apple登录按钮（初始化自定义组件）
        appleLoginButton_Glasspaint = AppleLoginBt_Glasspaint(onTap_Glasspaint: { [weak self] in
            self?.handleAppleLogin_Glasspaint()
        })
        contentView_Glasspaint.addSubview(appleLoginButton_Glasspaint)
        
        // 注册提示
        contentView_Glasspaint.addSubview(registerContainer_Glasspaint)
        setupRegisterSection_Glasspaint()
        
        // 协议（使用ProtocolHelper创建）
        protocolLabel_Glasspaint = ProtocolHelper_Glasspaint.createProtocolTextLabel_Glasspaint(
            firstProtocol_Glasspaint: .terms_Glasspaint,
            firstContent_Glasspaint: "terms",
            secondProtocol_Glasspaint: .privacy_Glasspaint,
            secondContent_Glasspaint: "privacy",
            config_Glasspaint: ProtocolHelper_Glasspaint.ProtocolTextConfig_Glasspaint(
                textColor_Glasspaint: ColorConfig_Glasspaint.textSecondary_Glasspaint,
                linkColor_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint,
                fontSize_Glasspaint: 12,
                fontWeight_Glasspaint: .regular,
                hasUnderline_Glasspaint: true,
                prefixText_Glasspaint: "By continuing, you agree to our ",
                separatorText_Glasspaint: " & "
            ),
            from: self
        )
        contentView_Glasspaint.addSubview(protocolLabel_Glasspaint)
        
        // 关闭按钮（放在最后，确保在最上层）
        view.addSubview(closeButton_Glasspaint)
        setupCloseButton_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
        
        // 添加点击手势关闭键盘
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Glasspaint))
        tapGesture_glasspaint.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        // 装饰圆圈1
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        decorCircle1_Glasspaint.layer.cornerRadius = 150
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-100)
            make.right.equalToSuperview().offset(50)
            make.width.height.equalTo(300)
        }
        
        // 装饰圆圈2
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        decorCircle2_Glasspaint.layer.cornerRadius = 100
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(-40)
            make.width.height.equalTo(200)
        }
        
        // 旋转动画
        let rotation1_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation1_glasspaint.fromValue = 0
        rotation1_glasspaint.toValue = Double.pi * 2
        rotation1_glasspaint.duration = 50
        rotation1_glasspaint.repeatCount = .infinity
        decorCircle1_Glasspaint.layer.add(rotation1_glasspaint, forKey: "rotation1")
        
        let rotation2_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation2_glasspaint.fromValue = 0
        rotation2_glasspaint.toValue = -Double.pi * 2
        rotation2_glasspaint.duration = 60
        rotation2_glasspaint.repeatCount = .infinity
        decorCircle2_Glasspaint.layer.add(rotation2_glasspaint, forKey: "rotation2")
    }
    
    /// 设置Logo区域
    private func setupLogoSection_Glasspaint() {
        // Logo图标
        logoContainer_Glasspaint.addSubview(logoImageView_Glasspaint)
        let logoConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        logoImageView_Glasspaint.image = UIImage(systemName: "paintpalette.fill", withConfiguration: logoConfig_glasspaint)
        logoImageView_Glasspaint.tintColor = .white
        logoImageView_Glasspaint.contentMode = .scaleAspectFit
        
        // App标题
        logoContainer_Glasspaint.addSubview(appTitleLabel_Glasspaint)
        appTitleLabel_Glasspaint.text = "GlassPaint"
        appTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        appTitleLabel_Glasspaint.textColor = .white
        appTitleLabel_Glasspaint.textAlignment = .center
        
        // 副标题
        logoContainer_Glasspaint.addSubview(appSubtitleLabel_Glasspaint)
        appSubtitleLabel_Glasspaint.text = "Welcome Back"
        appSubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        appSubtitleLabel_Glasspaint.textColor = UIColor.white.withAlphaComponent(0.9)
        appSubtitleLabel_Glasspaint.textAlignment = .center
        
        // 布局
        logoImageView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        appTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(logoImageView_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        appSubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(appTitleLabel_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置表单卡片
    private func setupFormCard_Glasspaint() {
        formCard_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        formCard_Glasspaint.layer.cornerRadius = 24
        formCard_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        formCard_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 8)
        formCard_Glasspaint.layer.shadowRadius = 20
        formCard_Glasspaint.layer.shadowOpacity = 0.15
        
        // 渐变背景
        formGradientLayer_Glasspaint.colors = [
            UIColor.white.cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        formGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        formGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        formGradientLayer_Glasspaint.cornerRadius = 24
        formCard_Glasspaint.layer.insertSublayer(formGradientLayer_Glasspaint, at: 0)
        
        // 用户名输入
        formCard_Glasspaint.addSubview(usernameContainer_Glasspaint)
        setupUsernameInput_Glasspaint()
        
        // 密码输入
        formCard_Glasspaint.addSubview(passwordContainer_Glasspaint)
        setupPasswordInput_Glasspaint()
    }
    
    /// 设置用户名输入
    private func setupUsernameInput_Glasspaint() {
        // 图标
        usernameContainer_Glasspaint.addSubview(usernameIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        usernameIconView_Glasspaint.image = UIImage(systemName: "person.fill", withConfiguration: iconConfig_glasspaint)
        usernameIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        usernameIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 输入框
        usernameContainer_Glasspaint.addSubview(usernameTextField_Glasspaint)
        usernameTextField_Glasspaint.placeholder = "Username"
        usernameTextField_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        usernameTextField_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        usernameTextField_Glasspaint.autocapitalizationType = .none
        usernameTextField_Glasspaint.autocorrectionType = .no
        
        // 分隔线
        usernameContainer_Glasspaint.addSubview(usernameDivider_Glasspaint)
        usernameDivider_Glasspaint.backgroundColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.2)
        
        // 布局
        usernameIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        usernameTextField_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(usernameIconView_Glasspaint.snp.right).offset(16)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        usernameDivider_Glasspaint.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    /// 设置密码输入
    private func setupPasswordInput_Glasspaint() {
        // 图标
        passwordContainer_Glasspaint.addSubview(passwordIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        passwordIconView_Glasspaint.image = UIImage(systemName: "lock.fill", withConfiguration: iconConfig_glasspaint)
        passwordIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        passwordIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 输入框
        passwordContainer_Glasspaint.addSubview(passwordTextField_Glasspaint)
        passwordTextField_Glasspaint.placeholder = "Password"
        passwordTextField_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        passwordTextField_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        passwordTextField_Glasspaint.isSecureTextEntry = true
        passwordTextField_Glasspaint.autocapitalizationType = .none
        passwordTextField_Glasspaint.autocorrectionType = .no
        
        // 显示/隐藏密码按钮
        passwordContainer_Glasspaint.addSubview(passwordToggleButton_Glasspaint)
        let toggleConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        passwordToggleButton_Glasspaint.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: toggleConfig_glasspaint), for: .normal)
        passwordToggleButton_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        passwordToggleButton_Glasspaint.addTarget(self, action: #selector(handlePasswordToggle_Glasspaint), for: .touchUpInside)
        
        // 分隔线
        passwordContainer_Glasspaint.addSubview(passwordDivider_Glasspaint)
        passwordDivider_Glasspaint.backgroundColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.2)
        
        // 布局
        passwordIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        passwordTextField_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(passwordIconView_Glasspaint.snp.right).offset(16)
            make.right.equalTo(passwordToggleButton_Glasspaint.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        passwordToggleButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        passwordDivider_Glasspaint.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    /// 设置登录按钮
    private func setupLoginButton_Glasspaint() {
        loginButton_Glasspaint.setTitle("Log In", for: .normal)
        loginButton_Glasspaint.setTitleColor(.white, for: .normal)
        loginButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        loginButton_Glasspaint.layer.cornerRadius = 25
        loginButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        loginButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        loginButton_Glasspaint.layer.shadowRadius = 12
        loginButton_Glasspaint.layer.shadowOpacity = 0.4
        
        // 渐变背景
        loginGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
        ]
        loginGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
        loginGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
        loginGradientLayer_Glasspaint.cornerRadius = 25
        loginButton_Glasspaint.layer.insertSublayer(loginGradientLayer_Glasspaint, at: 0)
        
        loginButton_Glasspaint.addTarget(self, action: #selector(handleLogin_Glasspaint), for: .touchUpInside)
    }
    
    /// 设置关闭按钮
    private func setupCloseButton_Glasspaint() {
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        closeButton_Glasspaint.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config_glasspaint), for: .normal)
        closeButton_Glasspaint.tintColor = .white
        closeButton_Glasspaint.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        closeButton_Glasspaint.layer.cornerRadius = 20
        closeButton_Glasspaint.addTarget(self, action: #selector(handleClose_Glasspaint), for: .touchUpInside)
    }
    
    /// 设置注册提示区域
    private func setupRegisterSection_Glasspaint() {
        // 提示文本
        registerContainer_Glasspaint.addSubview(registerPromptLabel_Glasspaint)
        registerPromptLabel_Glasspaint.text = "Don't have an account?"
        registerPromptLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        registerPromptLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 注册按钮
        registerContainer_Glasspaint.addSubview(registerButton_Glasspaint)
        registerButton_Glasspaint.setTitle("Sign Up", for: .normal)
        registerButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.primaryGradientStart_Glasspaint, for: .normal)
        registerButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        registerButton_Glasspaint.addTarget(self, action: #selector(handleRegister_Glasspaint), for: .touchUpInside)
        
        // 布局
        registerPromptLabel_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        
        registerButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(registerPromptLabel_Glasspaint.snp.right).offset(8)
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        // 关闭按钮
        closeButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }
        
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // Logo区域
        logoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 表单卡片
        formCard_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(logoContainer_Glasspaint.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        usernameContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        
        passwordContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(usernameContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        // 登录按钮
        loginButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(formCard_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // Apple登录按钮
        appleLoginButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // 注册提示
        registerContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton_Glasspaint.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        // 协议
        protocolLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(registerContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - 键盘处理
    
    /// 设置键盘观察者
    private func setupKeyboardObservers_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Glasspaint),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Glasspaint),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// 键盘显示
    @objc private func keyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInset_glasspaint = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame_glasspaint.height, right: 0)
        scrollView_Glasspaint.contentInset = contentInset_glasspaint
        scrollView_Glasspaint.scrollIndicatorInsets = contentInset_glasspaint
    }
    
    /// 键盘隐藏
    @objc private func keyboardWillHide_Glasspaint(_ notification: Notification) {
        scrollView_Glasspaint.contentInset = .zero
        scrollView_Glasspaint.scrollIndicatorInsets = .zero
    }
    
    /// 关闭键盘
    @objc private func dismissKeyboard_Glasspaint() {
        view.endEditing(true)
    }
    
    // MARK: - 事件处理
    
    /// 关闭页面
    @objc private func handleClose_Glasspaint() {
        dismiss(animated: true)
    }
    
    /// 密码显示/隐藏切换
    @objc private func handlePasswordToggle_Glasspaint() {
        passwordTextField_Glasspaint.isSecureTextEntry.toggle()
        
        let toggleConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconName_glasspaint = passwordTextField_Glasspaint.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        passwordToggleButton_Glasspaint.setImage(UIImage(systemName: iconName_glasspaint, withConfiguration: toggleConfig_glasspaint), for: .normal)
    }
    
    /// 处理登录
    @objc private func handleLogin_Glasspaint() {
        // 关闭键盘
        view.endEditing(true)
        
        // 获取输入
        let username_glasspaint = usernameTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password_glasspaint = passwordTextField_Glasspaint.text ?? ""
        
        // 验证输入
        if username_glasspaint.isEmpty {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Please enter your username")
            return
        }
        
        if password_glasspaint.isEmpty {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Please enter your password")
            return
        }
        
        // 登录动画
        UIView.animate(withDuration: 0.1, animations: {
            self.loginButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.loginButton_Glasspaint.transform = .identity
            }
        }
        
        // 执行登录
        performLogin_Glasspaint(username: username_glasspaint, password: password_glasspaint)
    }
    
    /// 执行登录
    /// 参数：
    /// - username: 用户名
    /// - password: 密码
    private func performLogin_Glasspaint(username: String, password: String) {
        // 模拟登录延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // 调用登录方法
            UserViewModel_Glasspaint.shared_Glasspaint.loginById_Glasspaint(
                userId_glasspaint: 85698
            )
            
            // 清空输入框
            self?.usernameTextField_Glasspaint.text = ""
            self?.passwordTextField_Glasspaint.text = ""
        }
    }
    
    /// 处理Apple登录
    @objc private func handleAppleLogin_Glasspaint() {
        
        appleLoginManager_Glasspaint?.startAppleLogin_Glasspaint(
            success_Glasspaint: { userAccount_glasspaint in
                print("✅ Apple登录成功，用户账号：\(userAccount_glasspaint)")
                
                // 模拟登录延迟
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UserViewModel_Glasspaint.shared_Glasspaint.loginById_Glasspaint(
                        userId_glasspaint: 99999
                    )
                }
            },
            failure_Glasspaint: { errorMessage_glasspaint in
                print("❌ Apple登录失败：\(errorMessage_glasspaint)")
                
                Utils_Glasspaint.dismissLoading_Glasspaint()
                
                // 只在非取消的情况下显示错误提示
                if errorMessage_glasspaint != "Authorization canceled" {
                    Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Login failed: \(errorMessage_glasspaint)")
                }
            }
        )
    }
    
    /// 处理注册
    @objc private func handleRegister_Glasspaint() {
        let registerVC_glasspaint = Register_Glasspaint()
        navigationController?.pushViewController(registerVC_glasspaint, animated: true)
    }
}
