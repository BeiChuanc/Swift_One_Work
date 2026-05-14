import Foundation
import UIKit
import SnapKit

// MARK: 注册页
// 设计思路：简洁现代的注册表单，顶部左上角返回按钮，表单包含用户名/密码/确认密码输入框，底部有协议文本。

/// 注册页视图控制器
class Register_Echd: UIViewController {
    
    // MARK: - UI组件
    
    /// 背景渐变视图
    private let bgGradientView_Echd = UIView()
    
    /// 返回按钮
    private let backButton_Echd = BackButton_Echd()
    
    /// 顶部图标
    private let logoIconView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        iv_Echd.image = UIImage(systemName: "sparkles")
        iv_Echd.tintColor = UIColor(hexstring_Echd: "#FFD700")
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()
    
    /// 标题
    private let titleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Create Account"
        label_Echd.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()
    
    /// 副标题
    private let subTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Join and drift through time"
        label_Echd.font = UIFont.systemFont(ofSize: 14)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Echd.textAlignment = .center
        return label_Echd
    }()
    
    /// 表单卡片
    private let formCardView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 28
        view_Echd.layer.shadowColor = UIColor.black.cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 8)
        view_Echd.layer.shadowRadius = 20
        view_Echd.layer.shadowOpacity = 0.15
        return view_Echd
    }()
    
    /// 用户名输入框容器
    private let usernameContainer_Echd = UIView()
    
    /// 用户名输入框
    private let usernameField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Username"
        tf_Echd.font = UIFont.systemFont(ofSize: 15)
        tf_Echd.textColor = ColorConfig_Echd.textPrimary_Echd
        tf_Echd.autocorrectionType = .no
        tf_Echd.autocapitalizationType = .none
        return tf_Echd
    }()
    
    /// 密码输入框容器
    private let passwordContainer_Echd = UIView()
    
    /// 密码输入框
    private let passwordField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Password"
        tf_Echd.font = UIFont.systemFont(ofSize: 15)
        tf_Echd.textColor = ColorConfig_Echd.textPrimary_Echd
        tf_Echd.isSecureTextEntry = true
        return tf_Echd
    }()
    
    /// 确认密码输入框容器
    private let confirmPasswordContainer_Echd = UIView()
    
    /// 确认密码输入框
    private let confirmPasswordField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Confirm Password"
        tf_Echd.font = UIFont.systemFont(ofSize: 15)
        tf_Echd.textColor = ColorConfig_Echd.textPrimary_Echd
        tf_Echd.isSecureTextEntry = true
        return tf_Echd
    }()
    
    /// 注册按钮
    private let registerButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle("Create Account", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn_Echd.layer.cornerRadius = 14
        return btn_Echd
    }()
    
    /// 注册按钮渐变
    private var registerGradientLayer_Echd: CAGradientLayer?
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI_Echd()
        setupConstraints_Echd()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerGradientLayer_Echd?.frame = registerButton_Echd.bounds
        registerButton_Echd.layer.masksToBounds = true
    }
    
    // MARK: - UI设置
    
    private func setupUI_Echd() {
        // 渐变背景
        view.addSubview(bgGradientView_Echd)
        let gradLayer_Echd = CAGradientLayer()
        gradLayer_Echd.colors = [
            ColorConfig_Echd.secondaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.primaryGradientStart_Echd.cgColor
        ]
        gradLayer_Echd.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Echd.endPoint = CGPoint(x: 1, y: 1)
        bgGradientView_Echd.layer.insertSublayer(gradLayer_Echd, at: 0)
        bgGradientView_Echd.layer.masksToBounds = true
        DispatchQueue.main.async {
            gradLayer_Echd.frame = self.bgGradientView_Echd.bounds
        }
        
        // 返回按钮
        view.addSubview(backButton_Echd)
        backButton_Echd.onTapped_Echd = { [weak self] in
            Navigation_Echd.pop_Echd()
        }
        
        // Logo和标题
        view.addSubview(logoIconView_Echd)
        view.addSubview(titleLabel_Echd)
        view.addSubview(subTitleLabel_Echd)
        
        // 表单卡片
        view.addSubview(formCardView_Echd)
        
        // 输入框
        setupInputContainer_Echd(container_Echd: usernameContainer_Echd, field_Echd: usernameField_Echd, iconName_Echd: "person.fill", in_Echd: formCardView_Echd)
        setupInputContainer_Echd(container_Echd: passwordContainer_Echd, field_Echd: passwordField_Echd, iconName_Echd: "lock.fill", in_Echd: formCardView_Echd)
        setupInputContainer_Echd(container_Echd: confirmPasswordContainer_Echd, field_Echd: confirmPasswordField_Echd, iconName_Echd: "lock.rotation", in_Echd: formCardView_Echd)
        
        // 注册按钮
        formCardView_Echd.addSubview(registerButton_Echd)
        let regGrad_Echd = CAGradientLayer()
        regGrad_Echd.colors = [
            ColorConfig_Echd.secondaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.primaryGradientStart_Echd.cgColor
        ]
        regGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        regGrad_Echd.endPoint = CGPoint(x: 1, y: 0)
        registerGradientLayer_Echd = regGrad_Echd
        registerButton_Echd.layer.insertSublayer(regGrad_Echd, at: 0)
        registerButton_Echd.addTarget(self, action: #selector(registerTapped_Echd), for: .touchUpInside)
        
        // 协议文本
        let protocolLbl_Echd = ProtocolHelper_Echd.createProtocolTextLabel_Echd(
            firstContent_Echd: "terms",
            secondContent_Echd: "privacy",
            config_Echd: ProtocolHelper_Echd.ProtocolTextConfig_Echd.light_Echd(),
            from: self
        )
        formCardView_Echd.addSubview(protocolLbl_Echd)
        protocolLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    /// 设置输入容器视图
    private func setupInputContainer_Echd(
        container_Echd: UIView,
        field_Echd: UITextField,
        iconName_Echd: String,
        in_Echd parentView: UIView
    ) {
        container_Echd.backgroundColor = ColorConfig_Echd.backgroundPrimary_Echd
        container_Echd.layer.cornerRadius = 12
        parentView.addSubview(container_Echd)
        
        let icon_Echd = UIImageView()
        let config_Echd = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        icon_Echd.image = UIImage(systemName: iconName_Echd, withConfiguration: config_Echd)
        icon_Echd.tintColor = ColorConfig_Echd.secondaryGradientStart_Echd
        icon_Echd.contentMode = .scaleAspectFit
        container_Echd.addSubview(icon_Echd)
        container_Echd.addSubview(field_Echd)
        
        icon_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        field_Echd.snp.makeConstraints { make in
            make.leading.equalTo(icon_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.top.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 约束布局
    
    private func setupConstraints_Echd() {
        bgGradientView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(270)
        }
        
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        logoIconView_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(45)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        titleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Echd.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Echd.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        formCardView_Echd.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel_Echd.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        usernameContainer_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        passwordContainer_Echd.snp.makeConstraints { make in
            make.top.equalTo(usernameContainer_Echd.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        confirmPasswordContainer_Echd.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Echd.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        registerButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordContainer_Echd.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
    }
    
    // MARK: - 事件处理
    
    /// 注册按钮点击
    @objc private func registerTapped_Echd() {
        registerButton_Echd.animatePressDown_Echd {
            self.registerButton_Echd.animatePressUp_Echd()
        }
        
        // 校验用户名非空
        guard let username_Echd = usernameField_Echd.text, !username_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            usernameContainer_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Username cannot be empty")
            return
        }
        // 校验密码非空
        guard let password_Echd = passwordField_Echd.text, !password_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            passwordContainer_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Password cannot be empty")
            return
        }
        // 校验确认密码非空
        guard let confirmPwd_Echd = confirmPasswordField_Echd.text, !confirmPwd_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            confirmPasswordContainer_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Please confirm your password")
            return
        }
        // 校验密码一致
        guard password_Echd == confirmPwd_Echd else {
            confirmPasswordContainer_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Passwords do not match")
            return
        }
        
        // 注册成功，使用用户名生成唯一ID并登录
        let userId_Echd = abs(username_Echd.hashValue) % 1000 + 100
        Task { @MainActor in
            UserViewModel_Echd.shared_Echd.loginById_Echd(userId_echd: userId_Echd)
        }
    }
}
