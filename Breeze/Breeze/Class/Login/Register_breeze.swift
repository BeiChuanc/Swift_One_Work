import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页
/// 核心作用：用户名 + 密码 + 确认密码注册；校验通过后调用 ViewModel 完成账号建立
/// 设计思路：渐变品牌头部（与登录页同款）+ 白色上浮内容卡 + 三个输入框 + 渐变注册按钮
class Register_Breeze: UIViewController {
    
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
        v_breeze.layer.cornerRadius = 80
        return v_breeze
    }()
    
    private let decorSmall_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_breeze.layer.cornerRadius = 44
        return v_breeze
    }()
    
    /// 返回按钮（白色半透明圆形）
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    private let logoView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        iv_breeze.image = UIImage(systemName: "tent.2.circle.fill", withConfiguration: config_breeze)
        iv_breeze.tintColor = .white
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    private let heroTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Create Account"
        label_breeze.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        label_breeze.textColor = .white
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    private let heroSubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Join the Breeze camping community"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
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
    
    private let cardTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Sign Up"
        label_breeze.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    private let cardSubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Create your free account in seconds"
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
    
    private let confirmPasswordCard_Breeze = AuthFieldCard_Breeze(
        placeholder_breeze: "Confirm Password",
        icon_breeze: "lock.rotation",
        secure_breeze: true
    )
    
    private let registerButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.setTitle("Sign Up", for: .normal)
        btn_breeze.setTitleColor(.white, for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_breeze.layer.cornerRadius = 26
        btn_breeze.layer.shadowColor = ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor
        btn_breeze.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_breeze.layer.shadowRadius = 14
        btn_breeze.layer.shadowOpacity = 0.36
        return btn_breeze
    }()
    
    private var registerGradient_Breeze: CAGradientLayer?
    
    /// "已有账号？登录" 跳转按钮
    private let loginButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let attr_breeze = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: ColorConfig_Breeze.textSecondary_Breeze,
                         .font: UIFont.systemFont(ofSize: 14, weight: .regular)]
        )
        attr_breeze.append(NSAttributedString(
            string: "Log In",
            attributes: [.foregroundColor: ColorConfig_Breeze.primaryGradientStart_Breeze,
                         .font: UIFont.systemFont(ofSize: 14, weight: .bold)]
        ))
        btn_breeze.setAttributedTitle(attr_breeze, for: .normal)
        return btn_breeze
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
        refreshRegisterButtonGradient_Breeze()
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
        heroView_Breeze.addSubview(backButton_Breeze)
        heroView_Breeze.addSubview(logoView_Breeze)
        heroView_Breeze.addSubview(heroTitle_Breeze)
        heroView_Breeze.addSubview(heroSubtitle_Breeze)
        
        heroView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.34)
        }
        
        decorLarge_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.right.equalToSuperview().offset(44)
            make.top.equalToSuperview().offset(-34)
        }
        decorSmall_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(88)
            make.left.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(16)
        }
        
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        
        logoView_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-14)
            make.width.height.equalTo(56)
        }
        heroTitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(logoView_Breeze.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        heroSubtitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroTitle_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
        }
        
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
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
        scrollContent_Breeze.addSubview(confirmPasswordCard_Breeze)
        scrollContent_Breeze.addSubview(registerButton_Breeze)
        scrollContent_Breeze.addSubview(loginButton_Breeze)
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
            make.top.equalTo(cardSubtitle_Breeze.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        passwordCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(usernameCard_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        confirmPasswordCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(passwordCard_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        registerButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordCard_Breeze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        loginButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Breeze.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }
        protocolLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Breeze.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        registerButton_Breeze.addTarget(self, action: #selector(handleRegister_Breeze), for: .touchUpInside)
        loginButton_Breeze.addTarget(self, action: #selector(handleGoLogin_Breeze), for: .touchUpInside)
    }
    
    private func refreshRegisterButtonGradient_Breeze() {
        guard !registerButton_Breeze.bounds.isEmpty else { return }
        registerGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: registerButton_Breeze.bounds)
        gradient_breeze.cornerRadius = registerButton_Breeze.layer.cornerRadius
        registerButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        registerGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 事件
    
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleGoLogin_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleRegister_Breeze() {
        let username_breeze = usernameCard_Breeze.inputText_Breeze.trimmingCharacters(in: .whitespacesAndNewlines)
        let password_breeze = passwordCard_Breeze.inputText_Breeze
        let confirm_breeze = confirmPasswordCard_Breeze.inputText_Breeze
        
        guard !username_breeze.isEmpty else {
            usernameCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please enter a username")
            return
        }
        guard !password_breeze.isEmpty else {
            passwordCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please enter a password")
            return
        }
        guard !confirm_breeze.isEmpty else {
            confirmPasswordCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please confirm your password")
            return
        }
        guard password_breeze == confirm_breeze else {
            confirmPasswordCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Passwords do not match")
            return
        }
        
        view.endEditing(true)
        UserViewModel_Breeze.shared_Breeze.loginById_Breeze(
            userId_breeze: 5558613,
            userName_breeze: username_breeze
        )
    }
}
