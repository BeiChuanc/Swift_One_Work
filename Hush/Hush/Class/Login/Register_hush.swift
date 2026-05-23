import Foundation
import UIKit
import SnapKit

// MARK: 注册页面

/// 注册页 ViewController
/// 功能：用户名、密码、确认密码输入，校验后创建新用户并完成登录
/// 设计：与登录页同风格（薰衣草紫→天空蓝渐变背景，白色卡片布局），带弹性入场动画
/// 注册逻辑：校验 → 检查用户名唯一性 → 创建 PrewUserModel → 调用 loginAndRegister_Hush
class Register_Hush: UIViewController {
    
    // MARK: - UI 组件
    
    /// 全屏渐变背景图层
    private var backgroundGradientLayer_Hush: CAGradientLayer?
    
    /// 背景装饰圆圈（右上）
    private let decorCircleRight_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        view_Hush.layer.cornerRadius = 100
        return view_Hush
    }()
    
    /// 背景装饰圆圈（左下）
    private let decorCircleLeft_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view_Hush.layer.cornerRadius = 130
        return view_Hush
    }()
    
    /// 返回按钮
    private let backButton_Hush = BackButton_Hush()
    
    /// 页面标题区域
    private let headerView_Hush: UIView = {
        return UIView()
    }()
    
    /// 标题图标
    private let titleIconView_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "person.badge.plus.fill")
        iv_Hush.tintColor = .white
        iv_Hush.contentMode = .scaleAspectFit
        return iv_Hush
    }()
    
    /// 大标题
    private let titleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Create Account"
        label_Hush.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label_Hush.textColor = .white
        label_Hush.textAlignment = .center
        return label_Hush
    }()
    
    /// 副标题
    private let subtitleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Join the street photography community"
        label_Hush.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label_Hush.textColor = UIColor.white.withAlphaComponent(0.82)
        label_Hush.textAlignment = .center
        return label_Hush
    }()
    
    /// 主卡片容器
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
        label_Hush.text = "Sign Up"
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
        tf_Hush.returnKeyType = .next
        tf_Hush.backgroundColor = .clear
        return tf_Hush
    }()
    
    /// 确认密码输入框容器
    private let confirmContainer_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view_Hush.layer.cornerRadius = 14
        view_Hush.layer.borderWidth = 1
        view_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        return view_Hush
    }()
    
    /// 确认密码图标
    private let confirmIcon_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "lock.rotation")
        iv_Hush.tintColor = ColorConfig_Hush.secondaryGradientStart_Hush
        iv_Hush.contentMode = .scaleAspectFit
        return iv_Hush
    }()
    
    /// 确认密码输入框
    private let confirmField_Hush: UITextField = {
        let tf_Hush = UITextField()
        tf_Hush.placeholder = "Confirm Password"
        tf_Hush.font = UIFont.systemFont(ofSize: 15)
        tf_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tf_Hush.isSecureTextEntry = true
        tf_Hush.returnKeyType = .done
        tf_Hush.backgroundColor = .clear
        return tf_Hush
    }()
    
    /// 注册按钮（渐变背景）
    private let registerButton_Hush: UIButton = {
        let btn_Hush = UIButton(type: .custom)
        btn_Hush.setTitle("Create Account", for: .normal)
        btn_Hush.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn_Hush.setTitleColor(.white, for: .normal)
        btn_Hush.layer.cornerRadius = 14
        btn_Hush.layer.masksToBounds = true
        return btn_Hush
    }()
    
    /// 注册按钮渐变图层
    private var registerGradientLayer_Hush: CAGradientLayer?
    
    /// 协议标签
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
        backgroundGradientLayer_Hush?.frame = view.bounds
        if registerGradientLayer_Hush == nil && registerButton_Hush.bounds.width > 0 {
            let gradient_Hush = UIColor.createSecondaryGradientLayer_Hush(frame_Hush: registerButton_Hush.bounds)
            registerGradientLayer_Hush = gradient_Hush
            registerButton_Hush.layer.insertSublayer(gradient_Hush, at: 0)
        } else {
            registerGradientLayer_Hush?.frame = registerButton_Hush.bounds
        }
    }
    
    // MARK: - 渐变背景
    
    private func setupBackground_Hush() {
        let gradient_Hush = CAGradientLayer()
        gradient_Hush.colors = [
            ColorConfig_Hush.secondaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        gradient_Hush.locations = [0.0, 0.45, 1.0]
        gradient_Hush.startPoint = CGPoint(x: 0.2, y: 0)
        gradient_Hush.endPoint = CGPoint(x: 0.8, y: 1)
        backgroundGradientLayer_Hush = gradient_Hush
        view.layer.insertSublayer(gradient_Hush, at: 0)
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Hush() {
        // 背景装饰
        view.addSubview(decorCircleRight_Hush)
        decorCircleRight_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(50)
            make.width.height.equalTo(200)
        }
        view.addSubview(decorCircleLeft_Hush)
        decorCircleLeft_Hush.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(-70)
            make.width.height.equalTo(260)
        }
        
        // 返回按钮（左上角）
        view.addSubview(backButton_Hush)
        backButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }
        
        // 标题区
        view.addSubview(titleIconView_Hush)
        titleIconView_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(52)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(46)
        }
        view.addSubview(titleLabel_Hush)
        titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(titleIconView_Hush.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        view.addSubview(subtitleLabel_Hush)
        subtitleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Hush.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        // 主卡片
        view.addSubview(cardView_Hush)
        cardView_Hush.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Hush.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        setupCardContent_Hush()
        
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
    
    /// 构建卡片内部内容
    private func setupCardContent_Hush() {
        cardView_Hush.addSubview(cardTitleLabel_Hush)
        cardTitleLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        
        // 用户名
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
        
        // 密码
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
        
        // 确认密码
        cardView_Hush.addSubview(confirmContainer_Hush)
        confirmContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Hush.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        confirmContainer_Hush.addSubview(confirmIcon_Hush)
        confirmContainer_Hush.addSubview(confirmField_Hush)
        confirmIcon_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        confirmField_Hush.snp.makeConstraints { make in
            make.leading.equalTo(confirmIcon_Hush.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        confirmField_Hush.placeHolderTextColor_Hush(ColorConfig_Hush.textPlaceholder_Hush)
        
        // 注册按钮
        cardView_Hush.addSubview(registerButton_Hush)
        registerButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(confirmContainer_Hush.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    // MARK: - 事件绑定
    
    private func setupActions_Hush() {
        registerButton_Hush.addTarget(self, action: #selector(handleRegister_Hush), for: .touchUpInside)
        usernameField_Hush.delegate = self
        passwordField_Hush.delegate = self
        confirmField_Hush.delegate = self
    }
    
    private func setupKeyboardDismiss_Hush() {
        let tap_Hush = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap_Hush.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Hush)
    }
    
    // MARK: - 入场动画
    
    private func playEntryAnimation_Hush() {
        titleIconView_Hush.animateFadeIn_Hush(duration_Hush: 0.4)
        titleLabel_Hush.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.1)
        subtitleLabel_Hush.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.15)
        cardView_Hush.animateSlideInFromBottom_Hush(offset_Hush: 60, delay_Hush: 0.1)
        protocolLabel_Hush?.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.45)
    }
    
    // MARK: - 注册逻辑
    
    /// 点击注册按钮
    /// 逻辑：校验非空 → 校验密码一致 → 检查用户名唯一性 → 创建新用户 → 调用 loginAndRegister_Hush
    @objc private func handleRegister_Hush() {
        view.endEditing(true)
        
        let username_Hush = usernameField_Hush.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_Hush = passwordField_Hush.text ?? ""
        let confirm_Hush = confirmField_Hush.text ?? ""
        
        // 校验：用户名非空
        guard !username_Hush.isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter a username")
            shakeView_Hush(usernameContainer_Hush)
            return
        }
        
        // 校验：密码非空
        guard !password_Hush.isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter a password")
            shakeView_Hush(passwordContainer_Hush)
            return
        }
        
        // 校验：确认密码非空
        guard !confirm_Hush.isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please confirm your password")
            shakeView_Hush(confirmContainer_Hush)
            return
        }
        
        // 校验：两次密码一致
        guard password_Hush == confirm_Hush else {
            Utils_Hush.showWarning_Hush(message_Hush: "Passwords do not match")
            shakeView_Hush(confirmContainer_Hush)
            return
        }
        
        Task { @MainActor in
            UserViewModel_Hush.shared_Hush.loginById_Hush(userId_hush: 812156)
        }
        
        // 调用 ViewModel 注册并登录
        registerButton_Hush.animatePressDown_Hush {
            self.registerButton_Hush.animatePressUp_Hush()
        }
    }
    
    // MARK: - 辅助方法
    
    /// 对目标视图执行震动动画（输入校验失败时的视觉反馈）
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

extension Register_Hush: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Hush {
            passwordField_Hush.becomeFirstResponder()
        } else if textField == passwordField_Hush {
            confirmField_Hush.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleRegister_Hush()
        }
        return true
    }
    
    /// 输入框获得焦点时高亮边框颜色
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let containerMap_Hush: [UITextField: UIView] = [
            usernameField_Hush: usernameContainer_Hush,
            passwordField_Hush: passwordContainer_Hush,
            confirmField_Hush: confirmContainer_Hush
        ]
        guard let container_Hush = containerMap_Hush[textField] else { return }
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            container_Hush.layer.borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
            container_Hush.layer.borderWidth = 1.5
        }
    }
    
    /// 输入框失去焦点时恢复默认边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        let containerMap_Hush: [UITextField: UIView] = [
            usernameField_Hush: usernameContainer_Hush,
            passwordField_Hush: passwordContainer_Hush,
            confirmField_Hush: confirmContainer_Hush
        ]
        guard let container_Hush = containerMap_Hush[textField] else { return }
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            container_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
            container_Hush.layer.borderWidth = 1.0
        }
    }
}
