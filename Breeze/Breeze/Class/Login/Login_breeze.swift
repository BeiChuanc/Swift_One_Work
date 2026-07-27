import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录页
/// 核心作用：用户名 + 密码登录，支持 Apple 登录；校验通过后调用 ViewModel 完成登录
/// 设计思路：渐变品牌头部（与全局同款）+ 白色上浮内容卡 + 渐变登录按钮 + Apple 登录
/// 关键属性：appleLoginManager_Breeze 苹果登录管理器；各输入卡片使用 AuthFieldCard_Breeze
class Login_Breeze: UIViewController {
    
    // MARK: - 属性
    
    private lazy var appleLoginManager_Breeze = AppleLoginManager_Breeze(viewController_Breeze: self)
    
    // MARK: - UI：渐变头部
    
    private let heroView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var heroGradient_Breeze: CAGradientLayer?
    
    private let decorLarge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_breeze.layer.cornerRadius = 90
        return v_breeze
    }()
    
    private let decorSmall_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_breeze.layer.cornerRadius = 50
        return v_breeze
    }()
    
    /// 关闭按钮（白色半透明圆形）
    private let closeButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "xmark", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    private let logoView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 52, weight: .medium)
        iv_breeze.image = UIImage(systemName: "leaf.circle.fill", withConfiguration: config_breeze)
        iv_breeze.tintColor = .white
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    private let heroTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Breeze"
        label_breeze.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        label_breeze.textColor = .white
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    private let heroSubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Your outdoor camping community"
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.85)
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    // MARK: - UI：上浮内容卡
    
    private let contentCard_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        v_breeze.layer.cornerRadius = 30
        v_breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_breeze
    }()
    
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsVerticalScrollIndicator = false
        sv_breeze.backgroundColor = .clear
        sv_breeze.keyboardDismissMode = .onDrag
        return sv_breeze
    }()
    
    private let scrollContent_Breeze = UIView()
    
    /// 欢迎标题（卡片内）
    private let cardTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Welcome back"
        label_breeze.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    private let cardSubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Sign in to share your camping moments"
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }()
    
    private let usernameCard_Breeze = AuthFieldCard_Breeze(
        placeholder_breeze: "Username",
        icon_breeze: "person.fill",
        secure_breeze: false
    )
    
    private let passwordCard_Breeze = AuthFieldCard_Breeze(
        placeholder_breeze: "Password",
        icon_breeze: "lock.fill",
        secure_breeze: true
    )
    
    private let loginButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.setTitle("Log In", for: .normal)
        btn_breeze.setTitleColor(.white, for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_breeze.layer.cornerRadius = 26
        btn_breeze.layer.shadowColor = ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor
        btn_breeze.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_breeze.layer.shadowRadius = 14
        btn_breeze.layer.shadowOpacity = 0.36
        return btn_breeze
    }()
    
    private var loginGradient_Breeze: CAGradientLayer?
    
    private let registerButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let attr_breeze = NSMutableAttributedString(
            string: "No account? ",
            attributes: [.foregroundColor: ColorConfig_Breeze.textSecondary_Breeze,
                         .font: UIFont.systemFont(ofSize: 14, weight: .regular)]
        )
        attr_breeze.append(NSAttributedString(
            string: "Sign up",
            attributes: [.foregroundColor: ColorConfig_Breeze.primaryGradientStart_Breeze,
                         .font: UIFont.systemFont(ofSize: 14, weight: .bold)]
        ))
        btn_breeze.setAttributedTitle(attr_breeze, for: .normal)
        return btn_breeze
    }()
    
    private lazy var appleLoginButton_Breeze: AppleLoginBt_Breeze = {
        return AppleLoginBt_Breeze { [weak self] in
            self?.handleAppleLogin_Breeze()
        }
    }()
    
    private lazy var protocolLabel_Breeze: UILabel = {
        return ProtocolHelper_Breeze.createProtocolTextLabel_Breeze(
            firstProtocol_Breeze: .terms_Breeze,
            firstContent_Breeze: "terms.png",
            secondProtocol_Breeze: .privacy_Breeze,
            secondContent_Breeze: "privacy.png",
            from: self
        )
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeroGradient_Breeze()
        refreshLoginButtonGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeroView_Breeze()
        setupContentCard_Breeze()
    }
    
    private func setupHeroView_Breeze() {
        view.addSubview(heroView_Breeze)
        heroView_Breeze.addSubview(decorLarge_Breeze)
        heroView_Breeze.addSubview(decorSmall_Breeze)
        heroView_Breeze.addSubview(closeButton_Breeze)
        heroView_Breeze.addSubview(logoView_Breeze)
        heroView_Breeze.addSubview(heroTitle_Breeze)
        heroView_Breeze.addSubview(heroSubtitle_Breeze)
        
        heroView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.40)
        }
        
        decorLarge_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(180)
            make.right.equalToSuperview().offset(50)
            make.top.equalToSuperview().offset(-40)
        }
        decorSmall_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.left.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(20)
        }
        
        closeButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        
        logoView_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(64)
        }
        heroTitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(logoView_Breeze.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        heroSubtitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroTitle_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
        }
        
        closeButton_Breeze.addTarget(self, action: #selector(handleClose_Breeze), for: .touchUpInside)
    }
    
    private func refreshHeroGradient_Breeze() {
        heroGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: heroView_Breeze.bounds)
        heroView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        heroGradient_Breeze = gradient_breeze
    }
    
    private func setupContentCard_Breeze() {
        view.addSubview(contentCard_Breeze)
        contentCard_Breeze.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(scrollContent_Breeze)
        
        contentCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroView_Breeze.snp.bottom).offset(-28)
            make.left.right.bottom.equalToSuperview()
        }
        scrollView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollContent_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        scrollContent_Breeze.addSubview(cardTitle_Breeze)
        scrollContent_Breeze.addSubview(cardSubtitle_Breeze)
        scrollContent_Breeze.addSubview(usernameCard_Breeze)
        scrollContent_Breeze.addSubview(passwordCard_Breeze)
        scrollContent_Breeze.addSubview(loginButton_Breeze)
        scrollContent_Breeze.addSubview(registerButton_Breeze)
        scrollContent_Breeze.addSubview(appleLoginButton_Breeze)
        scrollContent_Breeze.addSubview(protocolLabel_Breeze)
        
        cardTitle_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(24)
        }
        cardSubtitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(cardTitle_Breeze.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        usernameCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(cardSubtitle_Breeze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        passwordCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(usernameCard_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        loginButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(passwordCard_Breeze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        registerButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Breeze.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }
        appleLoginButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        protocolLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton_Breeze.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        loginButton_Breeze.addTarget(self, action: #selector(handleLogin_Breeze), for: .touchUpInside)
        registerButton_Breeze.addTarget(self, action: #selector(handleRegister_Breeze), for: .touchUpInside)
    }
    
    private func refreshLoginButtonGradient_Breeze() {
        guard !loginButton_Breeze.bounds.isEmpty else { return }
        loginGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: loginButton_Breeze.bounds)
        gradient_breeze.cornerRadius = loginButton_Breeze.layer.cornerRadius
        loginButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        loginGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 事件
    
    @objc private func handleClose_Breeze() {
        dismiss(animated: true)
    }
    
    @objc private func handleLogin_Breeze() {
        let username_breeze = usernameCard_Breeze.inputText_Breeze.trimmingCharacters(in: .whitespacesAndNewlines)
        let password_breeze = passwordCard_Breeze.inputText_Breeze
        
        guard !username_breeze.isEmpty else {
            usernameCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please enter your username")
            return
        }
        guard !password_breeze.isEmpty else {
            passwordCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please enter your password")
            return
        }
        
        view.endEditing(true)
        UserViewModel_Breeze.shared_Breeze.loginById_Breeze(
            userId_breeze: 5558612,
            userName_breeze: username_breeze
        )
    }
    
    @objc private func handleRegister_Breeze() {
        Navigation_Breeze.toRegister_Breeze(style_breeze: .push_breeze)
    }
    
    private func handleAppleLogin_Breeze() {
        appleLoginManager_Breeze.startAppleLogin_Breeze(success_Breeze: { [weak self] account_breeze in
            guard self != nil else { return }
            UserViewModel_Breeze.shared_Breeze.loginById_Breeze(userId_breeze: 99999)
        }, failure_Breeze: { error_breeze in
            Utils_Breeze.showError_Breeze(message_Breeze: error_breeze)
        })
    }
}

// MARK: - 认证输入框卡片

/// 认证输入框卡片
/// 核心作用：统一生成登录/注册页带图标的白色卡片输入框
/// 关键属性：inputText_Breeze 获取当前输入内容
class AuthFieldCard_Breeze: UIView {
    
    private let iconView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    private let textField_Breeze: UITextField = {
        let field_breeze = UITextField()
        field_breeze.font = UIFont.systemFont(ofSize: 15)
        field_breeze.backgroundColor = .clear
        field_breeze.borderStyle = .none
        field_breeze.autocapitalizationType = .none
        field_breeze.autocorrectionType = .no
        return field_breeze
    }()
    
    /// 获取当前输入的文本内容
    var inputText_Breeze: String { textField_Breeze.text ?? "" }
    
    /// 初始化认证输入框卡片
    /// - Parameters:
    ///   - placeholder_breeze: 占位文字
    ///   - icon_breeze: 左侧 SF Symbol 图标名
    ///   - secure_breeze: 是否密码模式
    init(placeholder_breeze: String, icon_breeze: String, secure_breeze: Bool) {
        super.init(frame: .zero)
        
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView_Breeze.image = UIImage(systemName: icon_breeze, withConfiguration: config_breeze)
        
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 15)
        ]
        textField_Breeze.attributedPlaceholder = NSAttributedString(string: placeholder_breeze, attributes: attrs_breeze)
        textField_Breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        textField_Breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        textField_Breeze.isSecureTextEntry = secure_breeze
        
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI_Breeze() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.09
        
        addSubview(iconView_Breeze)
        addSubview(textField_Breeze)
        
        iconView_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        textField_Breeze.snp.makeConstraints { make in
            make.left.equalTo(iconView_Breeze.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - 保留旧工厂别名（向下兼容 Register 页）

/// 旧版输入框工厂（兼容 Register 页现有调用）
enum AuthFieldFactory_Breeze {
    
    /// 生成统一风格输入框（内部代理到 AuthFieldCard_Breeze）
    static func makeField_Breeze(placeholder_breeze: String, icon_breeze: String, secure_breeze: Bool) -> UITextField {
        let textField_breeze = UITextField()
        textField_breeze.placeholder = placeholder_breeze
        textField_breeze.font = UIFont.systemFont(ofSize: 15)
        textField_breeze.backgroundColor = .white
        textField_breeze.layer.cornerRadius = 16
        textField_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        textField_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        textField_breeze.layer.shadowRadius = 8
        textField_breeze.layer.shadowOpacity = 0.09
        textField_breeze.isSecureTextEntry = secure_breeze
        textField_breeze.autocapitalizationType = .none
        textField_breeze.autocorrectionType = .no
        textField_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        textField_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        
        let container_breeze = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 54))
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iv_breeze = UIImageView(image: UIImage(systemName: icon_breeze, withConfiguration: config_breeze))
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        iv_breeze.frame = CGRect(x: 14, y: 17, width: 20, height: 20)
        container_breeze.addSubview(iv_breeze)
        textField_breeze.leftView = container_breeze
        textField_breeze.leftViewMode = .always
        
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 15)
        ]
        textField_breeze.attributedPlaceholder = NSAttributedString(string: placeholder_breeze, attributes: attrs_breeze)
        return textField_breeze
    }
}
