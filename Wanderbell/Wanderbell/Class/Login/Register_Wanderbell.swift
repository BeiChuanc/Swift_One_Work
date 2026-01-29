import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页面
/// 核心功能：提供用户注册功能
/// 设计思路：现代化UI设计，丰富的视觉元素，支持用户名密码注册
/// 关键属性：
/// - usernameTextField_Wanderbell: 用户名输入框
/// - passwordTextField_Wanderbell: 密码输入框
/// - confirmPasswordTextField_Wanderbell: 确认密码输入框
/// - registerButton_Wanderbell: 注册按钮
/// 关键方法：
/// - validateInput_Wanderbell: 验证输入（检查空值和密码一致性）
/// - handleRegister_Wanderbell: 处理注册逻辑
class Register_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    /// 渐变图层
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    // MARK: - UI组件
    
    /// 滚动视图
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.keyboardDismissMode = .interactive
        return scrollView_wanderbell
    }()
    
    /// 内容容器
    private let contentView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// 顶部装饰容器
    private let topDecorView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// Logo图标
    private let logoIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "star.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// Logo标题
    private let logoLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Create Account"
        label_wanderbell.font = FontConfig_Wanderbell.largeTitle_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 副标题
    private let subtitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Join us and start your journey"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 表单容器
    private let formContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 24
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 10)
        view_wanderbell.layer.shadowOpacity = 0.1
        view_wanderbell.layer.shadowRadius = 20
        return view_wanderbell
    }()
    
    /// 用户名输入框容器
    private let usernameContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        view_wanderbell.layer.cornerRadius = 12
        view_wanderbell.layer.borderWidth = 1
        view_wanderbell.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
        return view_wanderbell
    }()
    
    /// 用户名图标
    private let usernameIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "person.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 用户名输入框
    private let usernameTextField_Wanderbell: UITextField = {
        let textField_wanderbell = UITextField()
        textField_wanderbell.placeholder = "Username"
        textField_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textField_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textField_wanderbell.borderStyle = .none
        textField_wanderbell.autocapitalizationType = .none
        textField_wanderbell.autocorrectionType = .no
        return textField_wanderbell
    }()
    
    /// 密码输入框容器
    private let passwordContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        view_wanderbell.layer.cornerRadius = 12
        view_wanderbell.layer.borderWidth = 1
        view_wanderbell.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
        return view_wanderbell
    }()
    
    /// 密码图标
    private let passwordIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "lock.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 密码输入框
    private let passwordTextField_Wanderbell: UITextField = {
        let textField_wanderbell = UITextField()
        textField_wanderbell.placeholder = "Password"
        textField_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textField_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textField_wanderbell.borderStyle = .none
        textField_wanderbell.isSecureTextEntry = true
        textField_wanderbell.autocapitalizationType = .none
        textField_wanderbell.autocorrectionType = .no
        return textField_wanderbell
    }()
    
    /// 确认密码输入框容器
    private let confirmPasswordContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        view_wanderbell.layer.cornerRadius = 12
        view_wanderbell.layer.borderWidth = 1
        view_wanderbell.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
        return view_wanderbell
    }()
    
    /// 确认密码图标
    private let confirmPasswordIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "lock.shield.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 确认密码输入框
    private let confirmPasswordTextField_Wanderbell: UITextField = {
        let textField_wanderbell = UITextField()
        textField_wanderbell.placeholder = "Confirm Password"
        textField_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textField_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textField_wanderbell.borderStyle = .none
        textField_wanderbell.isSecureTextEntry = true
        textField_wanderbell.autocapitalizationType = .none
        textField_wanderbell.autocorrectionType = .no
        return textField_wanderbell
    }()
    
    /// 注册按钮
    private let registerButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setTitle("Sign Up", for: .normal)
        button_wanderbell.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button_wanderbell.setTitleColor(.white, for: .normal)
        button_wanderbell.layer.cornerRadius = 14
        button_wanderbell.layer.masksToBounds = true
        button_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell.cgColor
        button_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
        button_wanderbell.layer.shadowOpacity = 0.3
        button_wanderbell.layer.shadowRadius = 8
        return button_wanderbell
    }()
    
    /// 协议文本
    private var protocolLabel_Wanderbell: UILabel?
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupActions_Wanderbell()
        setupKeyboardObservers_Wanderbell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变图层
        gradientLayer_Wanderbell?.frame = topDecorView_Wanderbell.bounds
        
        // 更新注册按钮渐变
        updateRegisterButtonGradient_Wanderbell()
    }
    
    deinit {
        // 移除键盘通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        view.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        title = "Sign Up"
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Wanderbell)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        
        // 添加子视图
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        // 顶部装饰
        contentView_Wanderbell.addSubview(topDecorView_Wanderbell)
        setupTopDecoration_Wanderbell()
        
        contentView_Wanderbell.addSubview(logoIconView_Wanderbell)
        contentView_Wanderbell.addSubview(logoLabel_Wanderbell)
        contentView_Wanderbell.addSubview(subtitleLabel_Wanderbell)
        
        // 表单容器
        contentView_Wanderbell.addSubview(formContainerView_Wanderbell)
        
        // 用户名输入
        formContainerView_Wanderbell.addSubview(usernameContainerView_Wanderbell)
        usernameContainerView_Wanderbell.addSubview(usernameIconView_Wanderbell)
        usernameContainerView_Wanderbell.addSubview(usernameTextField_Wanderbell)
        
        // 密码输入
        formContainerView_Wanderbell.addSubview(passwordContainerView_Wanderbell)
        passwordContainerView_Wanderbell.addSubview(passwordIconView_Wanderbell)
        passwordContainerView_Wanderbell.addSubview(passwordTextField_Wanderbell)
        
        // 确认密码输入
        formContainerView_Wanderbell.addSubview(confirmPasswordContainerView_Wanderbell)
        confirmPasswordContainerView_Wanderbell.addSubview(confirmPasswordIconView_Wanderbell)
        confirmPasswordContainerView_Wanderbell.addSubview(confirmPasswordTextField_Wanderbell)
        
        // 注册按钮
        formContainerView_Wanderbell.addSubview(registerButton_Wanderbell)
        
        // 创建协议文本
        protocolLabel_Wanderbell = ProtocolHelper_Wanderbell.createProtocolTextLabel_Wanderbell(
            firstProtocol_wanderbell: .terms_Wanderbell,
            firstContent_wanderbell: "terms.png",
            secondProtocol_wanderbell: .privacy_Wanderbell,
            secondContent_wanderbell: "privacy.png",
            config_wanderbell: .light_Wanderbell(),
            from: self
        )
        contentView_Wanderbell.addSubview(protocolLabel_Wanderbell!)
        
        setupConstraints_Wanderbell()
        addAnimations_Wanderbell()
    }
    
    /// 设置顶部装饰
    private func setupTopDecoration_Wanderbell() {
        // 创建渐变图层
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.colors = [
            ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell.withAlphaComponent(0.15).cgColor,
            ColorConfig_Wanderbell.secondaryGradientEnd_Wanderbell.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 1)
        topDecorView_Wanderbell.layer.addSublayer(gradientLayer_wanderbell)
        gradientLayer_Wanderbell = gradientLayer_wanderbell
    }
    
    /// 更新注册按钮渐变
    private func updateRegisterButtonGradient_Wanderbell() {
        // 移除旧的渐变层
        registerButton_Wanderbell.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // 创建新的渐变层
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.frame = registerButton_Wanderbell.bounds
        gradientLayer_wanderbell.colors = [
            ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell.cgColor,
            ColorConfig_Wanderbell.secondaryGradientEnd_Wanderbell.cgColor
        ]
        gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer_wanderbell.cornerRadius = 14
        registerButton_Wanderbell.layer.insertSublayer(gradientLayer_wanderbell, at: 0)
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        let screenWidth_wanderbell = UIScreen.main.bounds.width
        let horizontalPadding_wanderbell: CGFloat = 24
        
        // 滚动视图
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 内容容器
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenWidth_wanderbell)
        }
        
        // 顶部装饰
        topDecorView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(250)
        }
        
        // Logo图标
        logoIconView_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        // Logo标题
        logoLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
        }
        
        // 副标题
        subtitleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(logoLabel_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
        }
        
        // 表单容器
        formContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Wanderbell.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
        }
        
        // 用户名输入框容器
        usernameContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // 用户名图标
        usernameIconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 用户名输入框
        usernameTextField_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(usernameIconView_Wanderbell.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        // 密码输入框容器
        passwordContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(usernameContainerView_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // 密码图标
        passwordIconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 密码输入框
        passwordTextField_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(passwordIconView_Wanderbell.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        // 确认密码输入框容器
        confirmPasswordContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(passwordContainerView_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // 确认密码图标
        confirmPasswordIconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 确认密码输入框
        confirmPasswordTextField_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(confirmPasswordIconView_Wanderbell.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        // 注册按钮
        registerButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordContainerView_Wanderbell.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        // 协议文本
        protocolLabel_Wanderbell?.snp.makeConstraints { make in
            make.top.equalTo(formContainerView_Wanderbell.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    /// 添加动画
    private func addAnimations_Wanderbell() {
        // Logo图标缩放动画
        let scaleAnimation_wanderbell = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation_wanderbell.fromValue = 1.0
        scaleAnimation_wanderbell.toValue = 1.2
        scaleAnimation_wanderbell.duration = 1.5
        scaleAnimation_wanderbell.autoreverses = true
        scaleAnimation_wanderbell.repeatCount = .infinity
        logoIconView_Wanderbell.layer.add(scaleAnimation_wanderbell, forKey: "scale")
        
        // 元素淡入动画
        let views_wanderbell: [UIView] = [
            logoIconView_Wanderbell,
            logoLabel_Wanderbell,
            subtitleLabel_Wanderbell,
            formContainerView_Wanderbell
        ]
        
        for (index_wanderbell, view_wanderbell) in views_wanderbell.enumerated() {
            view_wanderbell.alpha = 0
            view_wanderbell.transform = CGAffineTransform(translationX: 0, y: 30)
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index_wanderbell) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: .curveEaseOut
            ) {
                view_wanderbell.alpha = 1
                view_wanderbell.transform = .identity
            }
        }
    }
    
    /// 设置事件
    private func setupActions_Wanderbell() {
        registerButton_Wanderbell.addTarget(self, action: #selector(handleRegister_Wanderbell), for: .touchUpInside)
        
        // 输入框聚焦效果
        usernameTextField_Wanderbell.addTarget(self, action: #selector(textFieldDidBeginEditing_Wanderbell(_:)), for: .editingDidBegin)
        usernameTextField_Wanderbell.addTarget(self, action: #selector(textFieldDidEndEditing_Wanderbell(_:)), for: .editingDidEnd)
        passwordTextField_Wanderbell.addTarget(self, action: #selector(textFieldDidBeginEditing_Wanderbell(_:)), for: .editingDidBegin)
        passwordTextField_Wanderbell.addTarget(self, action: #selector(textFieldDidEndEditing_Wanderbell(_:)), for: .editingDidEnd)
        confirmPasswordTextField_Wanderbell.addTarget(self, action: #selector(textFieldDidBeginEditing_Wanderbell(_:)), for: .editingDidBegin)
        confirmPasswordTextField_Wanderbell.addTarget(self, action: #selector(textFieldDidEndEditing_Wanderbell(_:)), for: .editingDidEnd)
        
        // 添加点击手势关闭键盘
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Wanderbell))
        view.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    /// 设置键盘监听
    private func setupKeyboardObservers_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Wanderbell(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Wanderbell(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - 事件处理
    
    /// 返回按钮点击
    @objc private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 注册按钮点击
    /// 功能：验证输入并执行注册逻辑
    @objc private func handleRegister_Wanderbell() {
        // 验证输入
        guard validateInput_Wanderbell() else {
            return
        }
        
        // 按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.registerButton_Wanderbell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.registerButton_Wanderbell.transform = .identity
            }
        }
        
        // 获取用户名和密码
        let username_wanderbell = usernameTextField_Wanderbell.text ?? ""
        let password_wanderbell = passwordTextField_Wanderbell.text ?? ""
        
        print("✅ 注册 - 用户名：\(username_wanderbell)，密码：\(password_wanderbell)")
        
        // 关闭键盘
        view.endEditing(true)
        
        // 这里可以调用实际的注册接口
        // 注册成功后自动登录
        let userId_wanderbell = Int.random(in: 1000...9999)
        
        // 显示成功提示
        Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Registration successful!")
        
        // 延迟登录并跳转
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8秒
            
            // 调用登录
            UserViewModel_Wanderbell.shared_Wanderbell.loginById_Wanderbell(userId_wanderbell: userId_wanderbell)
        }
    }
    
    /// 关闭键盘
    @objc private func dismissKeyboard_Wanderbell() {
        view.endEditing(true)
    }
    
    /// 输入框开始编辑
    @objc private func textFieldDidBeginEditing_Wanderbell(_ textField: UITextField) {
        let containerView_wanderbell: UIView?
        
        if textField == usernameTextField_Wanderbell {
            containerView_wanderbell = usernameContainerView_Wanderbell
        } else if textField == passwordTextField_Wanderbell {
            containerView_wanderbell = passwordContainerView_Wanderbell
        } else if textField == confirmPasswordTextField_Wanderbell {
            containerView_wanderbell = confirmPasswordContainerView_Wanderbell
        } else {
            return
        }
        
        // 高亮边框动画
        UIView.animate(withDuration: 0.3) {
            containerView_wanderbell?.layer.borderColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell.cgColor
            containerView_wanderbell?.layer.borderWidth = 2
            containerView_wanderbell?.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    /// 输入框结束编辑
    @objc private func textFieldDidEndEditing_Wanderbell(_ textField: UITextField) {
        let containerView_wanderbell: UIView?
        
        if textField == usernameTextField_Wanderbell {
            containerView_wanderbell = usernameContainerView_Wanderbell
        } else if textField == passwordTextField_Wanderbell {
            containerView_wanderbell = passwordContainerView_Wanderbell
        } else if textField == confirmPasswordTextField_Wanderbell {
            containerView_wanderbell = confirmPasswordContainerView_Wanderbell
        } else {
            return
        }
        
        // 恢复边框动画
        UIView.animate(withDuration: 0.3) {
            containerView_wanderbell?.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
            containerView_wanderbell?.layer.borderWidth = 1
            containerView_wanderbell?.transform = .identity
        }
    }
    
    /// 键盘显示
    @objc private func keyboardWillShow_Wanderbell(_ notification: Notification) {
        guard let keyboardFrame_wanderbell = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight_wanderbell = keyboardFrame_wanderbell.height
        scrollView_Wanderbell.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight_wanderbell, right: 0)
    }
    
    /// 键盘隐藏
    @objc private func keyboardWillHide_Wanderbell(_ notification: Notification) {
        scrollView_Wanderbell.contentInset = .zero
    }
    
    // MARK: - 验证方法
    
    /// 验证输入
    /// 功能：检查用户名、密码是否为空，以及两次密码是否一致
    /// 返回值：Bool - 验证是否通过
    private func validateInput_Wanderbell() -> Bool {
        let username_wanderbell = usernameTextField_Wanderbell.text ?? ""
        let password_wanderbell = passwordTextField_Wanderbell.text ?? ""
        let confirmPassword_wanderbell = confirmPasswordTextField_Wanderbell.text ?? ""
        
        // 检查用户名
        if username_wanderbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Utils_Wanderbell.showWarning_Wanderbell(message_wanderbell: "Please enter username")
            return false
        }
        
        // 检查密码
        if password_wanderbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Utils_Wanderbell.showWarning_Wanderbell(message_wanderbell: "Please enter password")
            return false
        }
        
        // 检查确认密码
        if confirmPassword_wanderbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Utils_Wanderbell.showWarning_Wanderbell(message_wanderbell: "Please confirm password")
            return false
        }
        
        // 检查两次密码是否一致
        if password_wanderbell != confirmPassword_wanderbell {
            Utils_Wanderbell.showWarning_Wanderbell(message_wanderbell: "Passwords do not match")
            return false
        }
        
        // 检查密码长度（可选）
        if password_wanderbell.count < 6 {
            Utils_Wanderbell.showWarning_Wanderbell(message_wanderbell: "Password must be at least 6 characters")
            return false
        }
        
        return true
    }
}
