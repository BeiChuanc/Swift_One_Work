import Foundation
import UIKit
import SnapKit

// MARK: 登录页面

/// 登录页 ViewController
/// 功能：用户名+密码登录、Apple 登录、跳转注册、展示协议
/// 设计：全屏渐变背景（薰衣草紫→天空蓝），中央浮动白色卡片，丰富入场弹性动画
/// 登录逻辑：从 LocalData 中匹配用户名，找到后调用 UserViewModel 的 loginById_Hush 方法
class Login_Hush: UIViewController {
    
    // MARK: - 私有属性
    
    /// Apple 登录管理器（持有强引用，防止被释放）
    private var appleLoginManager_Hush: AppleLoginManager_Hush?
    
    // MARK: - UI 组件
    
    /// 全屏渐变背景层
    private var backgroundGradientLayer_Hush: CAGradientLayer?
    
    /// 背景装饰圆圈（上）
    private let decorCircleTop_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view_Hush.layer.cornerRadius = 120
        return view_Hush
    }()
    
    /// 背景装饰圆圈（下）
    private let decorCircleBottom_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        view_Hush.layer.cornerRadius = 100
        return view_Hush
    }()
    
    /// 右上角关闭按钮
    private let closeButton_Hush: UIButton = {
        let btn_Hush = UIButton(type: .system)
        let config_Hush = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_Hush.setImage(UIImage(systemName: "xmark", withConfiguration: config_Hush), for: .normal)
        btn_Hush.tintColor = .white
        btn_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_Hush.layer.cornerRadius = 18
        return btn_Hush
    }()
    
    /// 应用图标视图
    private let appIconView_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "camera.aperture")
        iv_Hush.tintColor = .white
        iv_Hush.contentMode = .scaleAspectFit
        return iv_Hush
    }()
    
    /// 应用名称标签
    private let appNameLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Hush"
        label_Hush.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label_Hush.textColor = .white
        label_Hush.textAlignment = .center
        return label_Hush
    }()
    
    /// 应用标语标签
    private let sloganLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Street photography, quietly."
        label_Hush.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label_Hush.textColor = UIColor.white.withAlphaComponent(0.85)
        label_Hush.textAlignment = .center
        return label_Hush
    }()
    
    /// 主卡片容器（白色圆角卡片）
    private let cardView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = .white
        view_Hush.layer.cornerRadius = 28
        view_Hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        view_Hush.layer.shadowOffset = CGSize(width: 0, height: 10)
        view_Hush.layer.shadowRadius = 24
        view_Hush.layer.shadowOpacity = 1.0
        return view_Hush
    }()
    
    /// 卡片标题
    private let cardTitleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Welcome Back"
        label_Hush.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        return label_Hush
    }()
    
    /// 用户名输入框容器
    private let usernameContainer_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view_Hush.layer.cornerRadius = 14
        view_Hush.layer.borderWidth = 1
        view_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        return view_Hush
    }()
    
    /// 用户名图标
    private let usernameIcon_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "person.fill")
        iv_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        iv_Hush.contentMode = .scaleAspectFit
        return iv_Hush
    }()
    
    /// 用户名输入框
    private let usernameField_Hush: UITextField = {
        let tf_Hush = UITextField()
        tf_Hush.placeholder = "Username"
        tf_Hush.font = UIFont.systemFont(ofSize: 15)
        tf_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tf_Hush.autocorrectionType = .no
        tf_Hush.autocapitalizationType = .none
        tf_Hush.returnKeyType = .next
        tf_Hush.backgroundColor = .clear
        return tf_Hush
    }()
    
    /// 密码输入框容器
    private let passwordContainer_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view_Hush.layer.cornerRadius = 14
        view_Hush.layer.borderWidth = 1
        view_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        return view_Hush
    }()
    
    /// 密码图标
    private let passwordIcon_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "lock.fill")
        iv_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        iv_Hush.contentMode = .scaleAspectFit
        return iv_Hush
    }()
    
    /// 密码输入框
    private let passwordField_Hush: UITextField = {
        let tf_Hush = UITextField()
        tf_Hush.placeholder = "Password"
        tf_Hush.font = UIFont.systemFont(ofSize: 15)
        tf_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tf_Hush.isSecureTextEntry = true
        tf_Hush.returnKeyType = .done
        tf_Hush.backgroundColor = .clear
        return tf_Hush
    }()
    
    /// 登录按钮（渐变背景）
    private let loginButton_Hush: UIButton = {
        let btn_Hush = UIButton(type: .custom)
        btn_Hush.setTitle("Sign In", for: .normal)
        btn_Hush.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn_Hush.setTitleColor(.white, for: .normal)
        btn_Hush.layer.cornerRadius = 14
        btn_Hush.layer.masksToBounds = true
        return btn_Hush
    }()
    
    /// 登录按钮渐变图层
    private var loginGradientLayer_Hush: CAGradientLayer?
    
    /// 跳转注册按钮
    private let registerButton_Hush: UIButton = {
        let btn_Hush = UIButton(type: .system)
        let attrStr_Hush = NSMutableAttributedString()
        attrStr_Hush.append(NSAttributedString(
            string: "Don't have an account? ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: ColorConfig_Hush.textSecondary_Hush
            ]
        ))
        attrStr_Hush.append(NSAttributedString(
            string: "Sign Up",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: ColorConfig_Hush.primaryGradientStart_Hush
            ]
        ))
        btn_Hush.setAttributedTitle(attrStr_Hush, for: .normal)
        return btn_Hush
    }()
    
    /// Apple 登录按钮
    private lazy var appleLoginButton_Hush: AppleLoginBt_Hush = {
        return AppleLoginBt_Hush(onTap_Hush: { [weak self] in
            self?.handleAppleLogin_Hush()
        })
    }()
    
    /// 分隔线容器（"or continue with"）
    private let dividerContainer_Hush: UIView = {
        return UIView()
    }()
    
    /// 左侧分隔线
    private let leftDivider_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.divider_Hush
        return view_Hush
    }()
    
    /// 分隔文本
    private let dividerLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "or"
        label_Hush.font = UIFont.systemFont(ofSize: 12)
        label_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        label_Hush.textAlignment = .center
        return label_Hush
    }()
    
    /// 右侧分隔线
    private let rightDivider_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.divider_Hush
        return view_Hush
    }()
    
    /// 协议文本标签
    private var protocolLabel_Hush: UILabel?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Hush()
        setupUI_Hush()
        setupActions_Hush()
        setupKeyboardDismiss_Hush()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntryAnimation_Hush()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新背景渐变图层尺寸
        backgroundGradientLayer_Hush?.frame = view.bounds
        // 更新登录按钮渐变图层（首次布局时创建，后续更新尺寸）
        if loginGradientLayer_Hush == nil && loginButton_Hush.bounds.width > 0 {
            let gradient_Hush = UIColor.createPrimaryGradientLayer_Hush(frame_Hush: loginButton_Hush.bounds)
            loginGradientLayer_Hush = gradient_Hush
            loginButton_Hush.layer.insertSublayer(gradient_Hush, at: 0)
        } else {
            loginGradientLayer_Hush?.frame = loginButton_Hush.bounds
        }
    }
    
    // MARK: - 背景渐变
    
    /// 搭建全屏渐变背景
    private func setupBackground_Hush() {
        let gradient_Hush = CAGradientLayer()
        gradient_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
            ColorConfig_Hush.secondaryGradientStart_Hush.withAlphaComponent(0.6).cgColor
        ]
        gradient_Hush.locations = [0.0, 0.6, 1.0]
        gradient_Hush.startPoint = CGPoint(x: 0, y: 0)
        gradient_Hush.endPoint = CGPoint(x: 1, y: 1)
        backgroundGradientLayer_Hush = gradient_Hush
        view.layer.insertSublayer(gradient_Hush, at: 0)
    }
    
    // MARK: - UI 搭建
    
    /// 构建主界面
    private func setupUI_Hush() {
        // 背景装饰圆
        view.addSubview(decorCircleTop_Hush)
        decorCircleTop_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.trailing.equalToSuperview().offset(60)
            make.width.height.equalTo(240)
        }
        view.addSubview(decorCircleBottom_Hush)
        decorCircleBottom_Hush.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(-60)
            make.width.height.equalTo(200)
        }
        
        // 关闭按钮
        view.addSubview(closeButton_Hush)
        closeButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        
        // 应用图标与名称
        view.addSubview(appIconView_Hush)
        appIconView_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        view.addSubview(appNameLabel_Hush)
        appNameLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(appIconView_Hush.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        view.addSubview(sloganLabel_Hush)
        sloganLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel_Hush.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        // 主卡片
        view.addSubview(cardView_Hush)
        cardView_Hush.snp.makeConstraints { make in
            make.top.equalTo(sloganLabel_Hush.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        setupCardContent_Hush()
        
        // 注册跳转按钮
        view.addSubview(registerButton_Hush)
        registerButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(cardView_Hush.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        // 协议标签
        let protocolLabel_Hush = ProtocolHelper_Hush.createProtocolTextLabel_Hush(
            firstProtocol_Hush: .terms_Hush,
            firstContent_Hush: "terms.png",
            secondProtocol_Hush: .privacy_Hush,
            secondContent_Hush: "privacy.png",
            config_Hush: .dark_Hush(),
            from: self
        )
        view.addSubview(protocolLabel_Hush)
        protocolLabel_Hush.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        self.protocolLabel_Hush = protocolLabel_Hush
    }
    
    /// 构建卡片内容
    private func setupCardContent_Hush() {
        // 卡片标题
        cardView_Hush.addSubview(cardTitleLabel_Hush)
        cardTitleLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        
        // 用户名输入框
        cardView_Hush.addSubview(usernameContainer_Hush)
        usernameContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        usernameContainer_Hush.addSubview(usernameIcon_Hush)
        usernameContainer_Hush.addSubview(usernameField_Hush)
        usernameIcon_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        usernameField_Hush.snp.makeConstraints { make in
            make.leading.equalTo(usernameIcon_Hush.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        usernameField_Hush.placeHolderTextColor_Hush(ColorConfig_Hush.textPlaceholder_Hush)
        
        // 密码输入框
        cardView_Hush.addSubview(passwordContainer_Hush)
        passwordContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(usernameContainer_Hush.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        passwordContainer_Hush.addSubview(passwordIcon_Hush)
        passwordContainer_Hush.addSubview(passwordField_Hush)
        passwordIcon_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        passwordField_Hush.snp.makeConstraints { make in
            make.leading.equalTo(passwordIcon_Hush.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        passwordField_Hush.placeHolderTextColor_Hush(ColorConfig_Hush.textPlaceholder_Hush)
        
        // 登录按钮
        cardView_Hush.addSubview(loginButton_Hush)
        loginButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        // 分隔线
        setupDivider_Hush()
        
        // Apple 登录按钮
        cardView_Hush.addSubview(appleLoginButton_Hush)
        appleLoginButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(dividerContainer_Hush.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    /// 搭建分隔线区域
    private func setupDivider_Hush() {
        cardView_Hush.addSubview(dividerContainer_Hush)
        dividerContainer_Hush.addSubview(leftDivider_Hush)
        dividerContainer_Hush.addSubview(dividerLabel_Hush)
        dividerContainer_Hush.addSubview(rightDivider_Hush)
        
        dividerContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        dividerLabel_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(30)
        }
        leftDivider_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(dividerLabel_Hush.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
        rightDivider_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(dividerLabel_Hush.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    // MARK: - 事件绑定
    
    private func setupActions_Hush() {
        closeButton_Hush.addTarget(self, action: #selector(handleClose_Hush), for: .touchUpInside)
        loginButton_Hush.addTarget(self, action: #selector(handleLogin_Hush), for: .touchUpInside)
        registerButton_Hush.addTarget(self, action: #selector(handleGoRegister_Hush), for: .touchUpInside)
        usernameField_Hush.delegate = self
        passwordField_Hush.delegate = self
    }
    
    /// 点击空白处关闭键盘
    private func setupKeyboardDismiss_Hush() {
        let tap_Hush = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap_Hush.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Hush)
    }
    
    // MARK: - 入场动画
    
    /// 执行卡片和元素入场动画
    private func playEntryAnimation_Hush() {
        // Logo 区域淡入
        appIconView_Hush.animateFadeIn_Hush(duration_Hush: 0.4)
        appNameLabel_Hush.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.1)
        sloganLabel_Hush.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.2)
        
        // 卡片从下方弹入
        cardView_Hush.animateSlideInFromBottom_Hush(offset_Hush: 60, delay_Hush: 0.1)
        
        // 注册按钮淡入
        registerButton_Hush.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.4)
        protocolLabel_Hush?.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.5)
    }
    
    // MARK: - 事件处理
    
    /// 关闭按钮点击
    @objc private func handleClose_Hush() {
        Navigation_Hush.dismiss_Hush(from: self)
    }
    
    /// 登录按钮点击
    /// 逻辑：校验非空 → 从 LocalData 匹配用户名 → 调用 loginById_Hush
    @objc private func handleLogin_Hush() {
        view.endEditing(true)
        
        let username_Hush = usernameField_Hush.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_Hush = passwordField_Hush.text ?? ""
        
        // 校验非空
        guard !username_Hush.isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter your username")
            shakeView_Hush(usernameContainer_Hush)
            return
        }
        guard !password_Hush.isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter your password")
            shakeView_Hush(passwordContainer_Hush)
            return
        }
        
        // 调用 ViewModel 登录
        Task { @MainActor in
            UserViewModel_Hush.shared_Hush.loginById_Hush(userId_hush: 812155)
        }
        
        // 登录按钮按压动画反馈
        loginButton_Hush.animatePressDown_Hush {
            self.loginButton_Hush.animatePressUp_Hush()
        }
    }
    
    /// 点击跳转注册
    @objc private func handleGoRegister_Hush() {
        Navigation_Hush.toRegister_Hush(style_hush: .push_hush)
    }
    
    /// 触发 Apple 登录流程
    private func handleAppleLogin_Hush() {
        appleLoginManager_Hush = AppleLoginManager_Hush(viewController_Hush: self)
        appleLoginManager_Hush?.startAppleLogin_Hush(
            success_Hush: { [weak self] _ in
                Task { @MainActor in
                    UserViewModel_Hush.shared_Hush.loginById_Hush(userId_hush: 99999)
                }
            },
            failure_Hush: { errorMsg_Hush in
                Utils_Hush.showError_Hush(message_Hush: errorMsg_Hush)
            }
        )
    }
    
    // MARK: - 辅助方法
    
    /// 对指定视图执行震动动画（输入校验失败时的视觉反馈）
    /// - Parameter view_Hush: 目标视图
    private func shakeView_Hush(_ view_Hush: UIView) {
        view_Hush.layer.borderColor = UIColor(hexstring_Hush: "#FC8181").cgColor
        view_Hush.animateShake_Hush()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIView.animate(withDuration: 0.3) {
                view_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension Login_Hush: UITextFieldDelegate {
    
    /// Return 键控制焦点流
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Hush {
            passwordField_Hush.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleLogin_Hush()
        }
        return true
    }
    
    /// 输入框获得焦点时高亮边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let container_Hush = textField == usernameField_Hush ? usernameContainer_Hush : passwordContainer_Hush
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            container_Hush.layer.borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
            container_Hush.layer.borderWidth = 1.5
        }
    }
    
    /// 输入框失去焦点时恢复边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        let container_Hush = textField == usernameField_Hush ? usernameContainer_Hush : passwordContainer_Hush
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            container_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
            container_Hush.layer.borderWidth = 1.0
        }
    }
}
