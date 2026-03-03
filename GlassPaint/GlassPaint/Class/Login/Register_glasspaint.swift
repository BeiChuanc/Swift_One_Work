import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页面
/// 功能：提供用户注册功能
/// 设计：现代化注册界面，渐变背景，卡片式表单
class Register_Glasspaint: UIViewController {
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle1_Glasspaint = UIView()
    private let decorCircle2_Glasspaint = UIView()
    
    // 顶部区域
    private let headerContainer_Glasspaint = UIView()
    private let headerIconView_Glasspaint = UIImageView()
    private let headerTitleLabel_Glasspaint = UILabel()
    private let headerSubtitleLabel_Glasspaint = UILabel()
    
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
    
    // 确认密码输入
    private let confirmPasswordContainer_Glasspaint = UIView()
    private let confirmPasswordIconView_Glasspaint = UIImageView()
    private let confirmPasswordTextField_Glasspaint = UITextField()
    private let confirmPasswordToggleButton_Glasspaint = UIButton(type: .system)
    private let confirmPasswordDivider_Glasspaint = UIView()
    
    // 注册按钮
    private let registerButton_Glasspaint = UIButton(type: .system)
    private let registerGradientLayer_Glasspaint = CAGradientLayer()
    
    // 协议
    private var protocolLabel_Glasspaint: UILabel!
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupKeyboardObservers_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        formGradientLayer_Glasspaint.frame = formCard_Glasspaint.bounds
        registerGradientLayer_Glasspaint.frame = registerButton_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        title = "Sign Up"
        
        // 设置返回按钮
        setupNavigationBar_Glasspaint()
        
        // 背景渐变
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.keyboardDismissMode = .interactive
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 顶部区域
        contentView_Glasspaint.addSubview(headerContainer_Glasspaint)
        setupHeaderSection_Glasspaint()
        
        // 表单卡片
        contentView_Glasspaint.addSubview(formCard_Glasspaint)
        setupFormCard_Glasspaint()
        
        // 注册按钮
        contentView_Glasspaint.addSubview(registerButton_Glasspaint)
        setupRegisterButton_Glasspaint()
        
        // 协议（使用ProtocolHelper创建）
        protocolLabel_Glasspaint = ProtocolHelper_Glasspaint.createProtocolTextLabel_Glasspaint(
            firstProtocol_Glasspaint: .terms_Glasspaint,
            firstContent_Glasspaint: "terms.png",
            secondProtocol_Glasspaint: .privacy_Glasspaint,
            secondContent_Glasspaint: "privacy.png",
            config_Glasspaint: ProtocolHelper_Glasspaint.ProtocolTextConfig_Glasspaint(
                textColor_Glasspaint: ColorConfig_Glasspaint.textSecondary_Glasspaint,
                linkColor_Glasspaint: ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint,
                fontSize_Glasspaint: 12,
                fontWeight_Glasspaint: .regular,
                hasUnderline_Glasspaint: true,
                prefixText_Glasspaint: "By signing up, you agree to our ",
                separatorText_Glasspaint: " & "
            ),
            from: self
        )
        contentView_Glasspaint.addSubview(protocolLabel_Glasspaint)
        
        // 设置约束
        setupConstraints_Glasspaint()
        
        // 添加点击手势关闭键盘
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Glasspaint))
        view.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        let backButton_glasspaint = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackTap_Glasspaint)
        )
        backButton_glasspaint.tintColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        navigationItem.leftBarButtonItem = backButton_glasspaint
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor
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
        decorCircle1_Glasspaint.layer.cornerRadius = 120
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-80)
            make.left.equalToSuperview().offset(-40)
            make.width.height.equalTo(240)
        }
        
        // 装饰圆圈2
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        decorCircle2_Glasspaint.layer.cornerRadius = 100
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(40)
            make.width.height.equalTo(200)
        }
        
        // 旋转动画
        let rotation1_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation1_glasspaint.fromValue = 0
        rotation1_glasspaint.toValue = Double.pi * 2
        rotation1_glasspaint.duration = 55
        rotation1_glasspaint.repeatCount = .infinity
        decorCircle1_Glasspaint.layer.add(rotation1_glasspaint, forKey: "rotation1")
        
        let rotation2_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation2_glasspaint.fromValue = 0
        rotation2_glasspaint.toValue = -Double.pi * 2
        rotation2_glasspaint.duration = 65
        rotation2_glasspaint.repeatCount = .infinity
        decorCircle2_Glasspaint.layer.add(rotation2_glasspaint, forKey: "rotation2")
    }
    
    /// 设置顶部区域
    private func setupHeaderSection_Glasspaint() {
        // 图标
        headerContainer_Glasspaint.addSubview(headerIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        headerIconView_Glasspaint.image = UIImage(systemName: "person.badge.plus.fill", withConfiguration: iconConfig_glasspaint)
        headerIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        headerIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        headerContainer_Glasspaint.addSubview(headerTitleLabel_Glasspaint)
        headerTitleLabel_Glasspaint.text = "Create Account"
        headerTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        headerTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        headerTitleLabel_Glasspaint.textAlignment = .center
        
        // 副标题
        headerContainer_Glasspaint.addSubview(headerSubtitleLabel_Glasspaint)
        headerSubtitleLabel_Glasspaint.text = "Join our creative community"
        headerSubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        headerSubtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        headerSubtitleLabel_Glasspaint.textAlignment = .center
        
        // 布局
        headerIconView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        headerTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerIconView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        
        headerSubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Glasspaint.snp.bottom).offset(8)
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
        
        // 确认密码输入
        formCard_Glasspaint.addSubview(confirmPasswordContainer_Glasspaint)
        setupConfirmPasswordInput_Glasspaint()
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
    
    /// 设置确认密码输入
    private func setupConfirmPasswordInput_Glasspaint() {
        // 图标
        confirmPasswordContainer_Glasspaint.addSubview(confirmPasswordIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        confirmPasswordIconView_Glasspaint.image = UIImage(systemName: "lock.fill", withConfiguration: iconConfig_glasspaint)
        confirmPasswordIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        confirmPasswordIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 输入框
        confirmPasswordContainer_Glasspaint.addSubview(confirmPasswordTextField_Glasspaint)
        confirmPasswordTextField_Glasspaint.placeholder = "Confirm Password"
        confirmPasswordTextField_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        confirmPasswordTextField_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        confirmPasswordTextField_Glasspaint.isSecureTextEntry = true
        confirmPasswordTextField_Glasspaint.autocapitalizationType = .none
        confirmPasswordTextField_Glasspaint.autocorrectionType = .no
        
        // 显示/隐藏密码按钮
        confirmPasswordContainer_Glasspaint.addSubview(confirmPasswordToggleButton_Glasspaint)
        let toggleConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        confirmPasswordToggleButton_Glasspaint.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: toggleConfig_glasspaint), for: .normal)
        confirmPasswordToggleButton_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        confirmPasswordToggleButton_Glasspaint.addTarget(self, action: #selector(handleConfirmPasswordToggle_Glasspaint), for: .touchUpInside)
        
        // 分隔线
        confirmPasswordContainer_Glasspaint.addSubview(confirmPasswordDivider_Glasspaint)
        confirmPasswordDivider_Glasspaint.backgroundColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.2)
        
        // 布局
        confirmPasswordIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        confirmPasswordTextField_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(confirmPasswordIconView_Glasspaint.snp.right).offset(16)
            make.right.equalTo(confirmPasswordToggleButton_Glasspaint.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        confirmPasswordToggleButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        confirmPasswordDivider_Glasspaint.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    /// 设置注册按钮
    private func setupRegisterButton_Glasspaint() {
        registerButton_Glasspaint.setTitle("Sign Up", for: .normal)
        registerButton_Glasspaint.setTitleColor(.white, for: .normal)
        registerButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        registerButton_Glasspaint.layer.cornerRadius = 25
        registerButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor
        registerButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        registerButton_Glasspaint.layer.shadowRadius = 12
        registerButton_Glasspaint.layer.shadowOpacity = 0.4
        
        // 渐变背景
        registerGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint.cgColor
        ]
        registerGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
        registerGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
        registerGradientLayer_Glasspaint.cornerRadius = 25
        registerButton_Glasspaint.layer.insertSublayer(registerGradientLayer_Glasspaint, at: 0)
        
        registerButton_Glasspaint.addTarget(self, action: #selector(handleRegister_Glasspaint), for: .touchUpInside)
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 顶部区域
        headerContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 表单卡片
        formCard_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Glasspaint.snp.bottom).offset(32)
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
        }
        
        confirmPasswordContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        // 注册按钮
        registerButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(formCard_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // 协议
        protocolLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Glasspaint.snp.bottom).offset(24)
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
    
    /// 返回
    @objc private func handleBackTap_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 密码显示/隐藏切换
    @objc private func handlePasswordToggle_Glasspaint() {
        passwordTextField_Glasspaint.isSecureTextEntry.toggle()
        
        let toggleConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconName_glasspaint = passwordTextField_Glasspaint.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        passwordToggleButton_Glasspaint.setImage(UIImage(systemName: iconName_glasspaint, withConfiguration: toggleConfig_glasspaint), for: .normal)
    }
    
    /// 确认密码显示/隐藏切换
    @objc private func handleConfirmPasswordToggle_Glasspaint() {
        confirmPasswordTextField_Glasspaint.isSecureTextEntry.toggle()
        
        let toggleConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconName_glasspaint = confirmPasswordTextField_Glasspaint.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        confirmPasswordToggleButton_Glasspaint.setImage(UIImage(systemName: iconName_glasspaint, withConfiguration: toggleConfig_glasspaint), for: .normal)
    }
    
    /// 处理注册
    @objc private func handleRegister_Glasspaint() {
        // 关闭键盘
        view.endEditing(true)
        
        // 获取输入
        let username_glasspaint = usernameTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password_glasspaint = passwordTextField_Glasspaint.text ?? ""
        let confirmPassword_glasspaint = confirmPasswordTextField_Glasspaint.text ?? ""
        
        // 验证输入
        if username_glasspaint.isEmpty {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Please enter your username")
            return
        }
        
        if password_glasspaint.isEmpty {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Please enter your password")
            return
        }
        
        if confirmPassword_glasspaint.isEmpty {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Please confirm your password")
            return
        }
        
        if password_glasspaint != confirmPassword_glasspaint {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Passwords do not match")
            return
        }
        
        // 注册动画
        UIView.animate(withDuration: 0.1, animations: {
            self.registerButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.registerButton_Glasspaint.transform = .identity
            }
        }
        
        // 执行注册
        performRegister_Glasspaint()
    }
    
    /// 执行注册
    /// 参数：
    /// - username: 用户名
    /// - password: 密码
    private func performRegister_Glasspaint() {
        // 调用登录方法
        UserViewModel_Glasspaint.shared_Glasspaint.loginById_Glasspaint(
            userId_glasspaint: 85697
        )
        
        // 延迟返回登录页
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
