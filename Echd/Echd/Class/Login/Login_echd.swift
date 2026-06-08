import Foundation
import UIKit
import SnapKit

// MARK: 登录页
// 设计思路：采用渐变背景、浮动卡片式布局，顶部有关闭按钮，表单包含用户名/密码输入框，底部有Apple登录和协议文本。

/// 登录页视图控制器
class Login_Echd: UIViewController {
    
    // MARK: - UI组件
    
    /// 背景渐变视图
    private let bgGradientView_Echd = UIView()
    
    /// 顶部关闭按钮
    private let closeButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .system)
        let config_Echd = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "xmark", withConfiguration: config_Echd), for: .normal)
        btn_Echd.tintColor = .white
        btn_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        btn_Echd.layer.cornerRadius = 18
        return btn_Echd
    }()
    
    /// 顶部图标
    private let logoIconView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        iv_Echd.image = UIImage(systemName: "flame.fill")
        iv_Echd.tintColor = UIColor(hexstring_Echd: "#FFD700")
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()
    
    /// 标题
    private let titleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Welcome Back"
        label_Echd.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()
    
    /// 副标题
    private let subTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Sign in to catch the sparks"
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
    
    /// 用户名容器
    private let usernameContainer_Echd = UIView()
    
    /// 密码输入框
    private let passwordField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Password"
        tf_Echd.font = UIFont.systemFont(ofSize: 15)
        tf_Echd.textColor = ColorConfig_Echd.textPrimary_Echd
        tf_Echd.isSecureTextEntry = true
        tf_Echd.autocorrectionType = .no
        return tf_Echd
    }()
    
    /// 密码容器
    private let passwordContainer_Echd = UIView()
    
    /// 登录按钮
    private let loginButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle("Sign In", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn_Echd.layer.cornerRadius = 14
        return btn_Echd
    }()
    
    /// 登录按钮渐变图层
    private var loginGradientLayer_Echd: CAGradientLayer?
    
    /// 注册入口标签
    private let signUpLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        let normalAttr_Echd: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Echd.textSecondary_Echd,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        let linkAttr_Echd: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Echd.primaryGradientStart_Echd,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attrStr_Echd = NSMutableAttributedString(string: "Don't have an account? ", attributes: normalAttr_Echd)
        attrStr_Echd.append(NSAttributedString(string: "Sign Up", attributes: linkAttr_Echd))
        label_Echd.attributedText = attrStr_Echd
        label_Echd.textAlignment = .center
        label_Echd.isUserInteractionEnabled = true
        return label_Echd
    }()
    
    /// Apple登录按钮
    private var appleLoginBt_Echd: AppleLoginBt_Echd?
    
    /// Apple登录管理器
    private var appleLoginManager_Echd: AppleLoginManager_Echd?
    
    /// 协议文本标签
    private var protocolLabel_Echd: UILabel?
    
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
        loginGradientLayer_Echd?.frame = loginButton_Echd.bounds
        // 设置圆角
        loginButton_Echd.layer.masksToBounds = true
    }
    
    // MARK: - UI设置
    
    private func setupUI_Echd() {
        // 渐变背景
        view.addSubview(bgGradientView_Echd)
        let gradLayer_Echd = CAGradientLayer()
        gradLayer_Echd.colors = [
            ColorConfig_Echd.primaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.primaryGradientEnd_Echd.cgColor
        ]
        gradLayer_Echd.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Echd.endPoint = CGPoint(x: 1, y: 1)
        bgGradientView_Echd.layer.insertSublayer(gradLayer_Echd, at: 0)
        bgGradientView_Echd.layer.masksToBounds = true
        
        // 动态更新渐变图层尺寸
        DispatchQueue.main.async {
            gradLayer_Echd.frame = self.bgGradientView_Echd.bounds
        }
        
        // 关闭按钮
        view.addSubview(closeButton_Echd)
        closeButton_Echd.addTarget(self, action: #selector(closeTapped_Echd), for: .touchUpInside)
        
        // Logo和标题
        view.addSubview(logoIconView_Echd)
        view.addSubview(titleLabel_Echd)
        view.addSubview(subTitleLabel_Echd)
        
        // 表单卡片
        view.addSubview(formCardView_Echd)
        
        // 用户名输入框
        setupInputContainer_Echd(
            container_Echd: usernameContainer_Echd,
            field_Echd: usernameField_Echd,
            iconName_Echd: "person.fill",
            in_Echd: formCardView_Echd
        )
        
        // 密码输入框
        setupInputContainer_Echd(
            container_Echd: passwordContainer_Echd,
            field_Echd: passwordField_Echd,
            iconName_Echd: "lock.fill",
            in_Echd: formCardView_Echd
        )
        
        // 登录按钮
        formCardView_Echd.addSubview(loginButton_Echd)
        let loginGrad_Echd = CAGradientLayer()
        loginGrad_Echd.colors = [
            ColorConfig_Echd.primaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.primaryGradientEnd_Echd.cgColor
        ]
        loginGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        loginGrad_Echd.endPoint = CGPoint(x: 1, y: 0)
        loginGradientLayer_Echd = loginGrad_Echd
        loginButton_Echd.layer.insertSublayer(loginGrad_Echd, at: 0)
        loginButton_Echd.addTarget(self, action: #selector(loginTapped_Echd), for: .touchUpInside)
        
        // 注册入口
        formCardView_Echd.addSubview(signUpLabel_Echd)
        let signUpTap_Echd = UITapGestureRecognizer(target: self, action: #selector(signUpTapped_Echd))
        signUpLabel_Echd.addGestureRecognizer(signUpTap_Echd)
        
        // 分隔线
        let dividerView_Echd = createDividerView_Echd()
        formCardView_Echd.addSubview(dividerView_Echd)
        dividerView_Echd.snp.makeConstraints { make in
            make.top.equalTo(signUpLabel_Echd.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
        
        // Apple登录按钮
        let appleBtn_Echd = AppleLoginBt_Echd(onTap_Echd: { [weak self] in
            self?.handleAppleLogin_Echd()
        })
        appleLoginBt_Echd = appleBtn_Echd
        formCardView_Echd.addSubview(appleBtn_Echd)
        appleBtn_Echd.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Echd.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        // 协议文本
        let protocolLbl_Echd = ProtocolHelper_Echd.createProtocolTextLabel_Echd(
            firstContent_Echd: "terms.png",
            secondContent_Echd: "privacy.png",
            config_Echd: ProtocolHelper_Echd.ProtocolTextConfig_Echd.light_Echd(),
            from: self
        )
        protocolLabel_Echd = protocolLbl_Echd
        formCardView_Echd.addSubview(protocolLbl_Echd)
        protocolLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    /// 创建输入容器视图
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
        icon_Echd.tintColor = ColorConfig_Echd.primaryGradientStart_Echd
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
    
    /// 创建分隔线视图
    private func createDividerView_Echd() -> UIView {
        let containerView_Echd = UIView()
        
        let leftLine_Echd = UIView()
        leftLine_Echd.backgroundColor = ColorConfig_Echd.divider_Echd
        containerView_Echd.addSubview(leftLine_Echd)
        
        let orLabel_Echd = UILabel()
        orLabel_Echd.text = "or continue with"
        orLabel_Echd.font = UIFont.systemFont(ofSize: 12)
        orLabel_Echd.textColor = ColorConfig_Echd.textPlaceholder_Echd
        containerView_Echd.addSubview(orLabel_Echd)
        
        let rightLine_Echd = UIView()
        rightLine_Echd.backgroundColor = ColorConfig_Echd.divider_Echd
        containerView_Echd.addSubview(rightLine_Echd)
        
        orLabel_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        leftLine_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(orLabel_Echd.snp.leading).offset(-10)
            make.height.equalTo(1)
        }
        rightLine_Echd.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(orLabel_Echd.snp.trailing).offset(10)
            make.height.equalTo(1)
        }
        
        return containerView_Echd
    }
    
    // MARK: - 约束布局
    
    private func setupConstraints_Echd() {
        bgGradientView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(280)
        }
        
        closeButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        
        logoIconView_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
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
            make.top.equalTo(subTitleLabel_Echd.snp.bottom).offset(30)
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
        
        loginButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Echd.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        signUpLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Echd.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - 事件处理
    
    /// 关闭按钮点击
    @objc private func closeTapped_Echd() {
        closeButton_Echd.animatePressDown_Echd {
            self.closeButton_Echd.animatePressUp_Echd()
        }
        Navigation_Echd.dismiss_Echd()
    }
    
    /// 登录按钮点击
    @objc private func loginTapped_Echd() {
        loginButton_Echd.animatePressDown_Echd {
            self.loginButton_Echd.animatePressUp_Echd()
        }
        
        // 校验输入非空
        guard let username_Echd = usernameField_Echd.text, !username_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            usernameContainer_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Username cannot be empty")
            return
        }
        guard let password_Echd = passwordField_Echd.text, !password_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            passwordContainer_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Password cannot be empty")
            return
        }
        
        // 使用用户ID登录（本地逻辑：根据用户名匹配ID）
        let userId_Echd = resolveUserId_Echd(username_Echd: username_Echd)
        Task { @MainActor in
            UserViewModel_Echd.shared_Echd.loginById_Echd(userId_echd: userId_Echd)
        }
    }
    
    /// 注册入口点击
    @objc private func signUpTapped_Echd() {
        Navigation_Echd.toRegister_Echd(style_echd: .push_echd)
    }
    
    /// 处理Apple登录
    private func handleAppleLogin_Echd() {
        appleLoginManager_Echd = AppleLoginManager_Echd(viewController_Echd: self)
        appleLoginManager_Echd?.startAppleLogin_Echd(
            success_Echd: { [weak self] _ in
                guard let self = self else { return }
                // 使用Apple登录ID登录
                let userId_Echd = Int(Date().timeIntervalSince1970) % 100 + 1
                Task { @MainActor in
                    UserViewModel_Echd.shared_Echd.loginById_Echd(userId_echd: userId_Echd)
                }
            },
            failure_Echd: { errorMsg_Echd in
                if errorMsg_Echd != "Authorization canceled" {
                    Utils_Echd.showError_Echd(message_Echd: errorMsg_Echd)
                }
            }
        )
    }
    
    /// 根据用户名解析登录ID（本地数据匹配）
    private func resolveUserId_Echd(username_Echd: String) -> Int {
        let users_Echd = LocalData_Echd.shared_Echd.userList_Echd
        if let matched_Echd = users_Echd.first(where: {
            $0.userName_Echd?.lowercased() == username_Echd.lowercased()
        }) {
            return matched_Echd.userId_Echd ?? 1
        }
        // 未匹配时生成一个唯一ID
        return abs(username_Echd.hashValue) % 1000 + 100
    }
}
