import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录页面
/// 核心作用：提供用户名/密码登录、Apple 登录及跳转注册
/// 设计思路：全屏渐变背景 + 毛玻璃卡片表单，现代简洁
class Login_Somnia: UIViewController {

    // MARK: - 私有属性

    /// Apple 登录管理器
    private var appleManager_Somnia: AppleLoginManager_Somnia?

    // MARK: - UI组件

    /// 渐变背景层
    private var _gradientLayer_Somnia: CAGradientLayer?

    /// 顶部装饰圆圈
    private let topCircle_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 120
        return v
    }()

    private let bottomCircle_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 160
        return v
    }()

    /// App 图标
    private let logoView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "moon.stars.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// App 名称
    private let appNameLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Somnia"
        lbl.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let sloganLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Dream together, connect deeper"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        return lbl
    }()

    /// 表单卡片
    private let formCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        v.layer.cornerRadius = 28
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 20
        v.layer.shadowOpacity = 0.12
        return v
    }()

    /// 用户名输入框
    private let usernameField_Somnia = AuthTextField_Somnia(
        placeholder_Somnia: "Username",
        icon_Somnia: "person",
        isSecure_Somnia: false
    )

    /// 密码输入框
    private let passwordField_Somnia = AuthTextField_Somnia(
        placeholder_Somnia: "Password",
        icon_Somnia: "lock",
        isSecure_Somnia: true
    )

    /// 登录按钮
    private let loginButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        return btn
    }()

    /// 登录按钮渐变层
    private var loginGradient_Somnia: CAGradientLayer?

    /// 没有账号 → 去注册
    private let registerLink_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let attrs_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: ColorConfig_Somnia.textSecondary_Somnia
        ]
        let linkAttrs_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: ColorConfig_Somnia.primaryGradientStart_Somnia
        ]
        let str_Somnia = NSMutableAttributedString(string: "Don't have an account? ", attributes: attrs_Somnia)
        str_Somnia.append(NSAttributedString(string: "Sign Up", attributes: linkAttrs_Somnia))
        btn.setAttributedTitle(str_Somnia, for: .normal)
        return btn
    }()

    /// 分割线
    private let dividerView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.divider_Somnia
        return v
    }()

    private let dividerLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "or"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        lbl.textAlignment = .center
        return lbl
    }()

    /// Apple 登录按钮
    private lazy var appleButton_Somnia: AppleLoginBt_Somnia = {
        return AppleLoginBt_Somnia { [weak self] in
            self?.handleAppleLogin_Somnia()
        }
    }()

    /// 右上角关闭按钮（点击关闭登录页）
    private let closeButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 19
        return btn
    }()

    /// 协议文本
    private lazy var protocolLabel_Somnia: UILabel = {
        return ProtocolHelper_Somnia.createProtocolTextLabel_Somnia(
            firstContent_Somnia: "terms.png",
            secondContent_Somnia: "privacy.png",
            config_Somnia: .light_Somnia(),
            from: self
        )
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _gradientLayer_Somnia?.frame = view.bounds
        loginGradient_Somnia?.frame = loginButton_Somnia.bounds
    }

    // MARK: - 私有方法 - UI设置

    private func setupUI_Somnia() {
        // 渐变背景
        let gradient_Somnia = CAGradientLayer()
        gradient_Somnia.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        gradient_Somnia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Somnia.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient_Somnia, at: 0)
        _gradientLayer_Somnia = gradient_Somnia

        view.addSubview(topCircle_Somnia)
        view.addSubview(bottomCircle_Somnia)
        view.addSubview(closeButton_Somnia)
        view.addSubview(logoView_Somnia)
        view.addSubview(appNameLabel_Somnia)
        view.addSubview(sloganLabel_Somnia)
        view.addSubview(formCard_Somnia)

        formCard_Somnia.addSubview(usernameField_Somnia)
        formCard_Somnia.addSubview(passwordField_Somnia)
        formCard_Somnia.addSubview(loginButton_Somnia)
        formCard_Somnia.addSubview(registerLink_Somnia)
        formCard_Somnia.addSubview(dividerView_Somnia)
        formCard_Somnia.addSubview(dividerLabel_Somnia)
        formCard_Somnia.addSubview(appleButton_Somnia)
        formCard_Somnia.addSubview(protocolLabel_Somnia)

        // 装饰圆圈
        topCircle_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.left.equalToSuperview().offset(-60)
            make.width.height.equalTo(240)
        }

        bottomCircle_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(80)
            make.right.equalToSuperview().offset(80)
            make.width.height.equalTo(320)
        }

        // 关闭按钮固定在右上角安全区内
        closeButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(38)
        }

        logoView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        appNameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(logoView_Somnia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        sloganLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel_Somnia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        formCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(sloganLabel_Somnia.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }

        usernameField_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        passwordField_Somnia.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Somnia.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        loginButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Somnia.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        registerLink_Somnia.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Somnia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        dividerView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(registerLink_Somnia.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }

        dividerLabel_Somnia.snp.makeConstraints { make in
            make.center.equalTo(dividerView_Somnia)
            make.width.equalTo(36)
        }

        appleButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Somnia.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        protocolLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(appleButton_Somnia.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
        }

        // 设置登录按钮渐变
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let grad_Somnia = CAGradientLayer()
            grad_Somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 1, y: 0)
            grad_Somnia.frame = self.loginButton_Somnia.bounds
            self.loginButton_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
            self.loginGradient_Somnia = grad_Somnia
        }
    }

    private func setupActions_Somnia() {
        // 关闭按钮：关闭登录页
        closeButton_Somnia.addAction(UIAction { _ in
            Navigation_Somnia.dismiss_Somnia()
        }, for: .touchUpInside)

        loginButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleLogin_Somnia()
        }, for: .touchUpInside)

        registerLink_Somnia.addAction(UIAction { _ in
            Navigation_Somnia.toRegister_Somnia(style_somnia: .present_somnia)
        }, for: .touchUpInside)

        // 点击空白收键盘
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Somnia))
        tap_Somnia.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Somnia)
    }

    // MARK: - 私有方法 - 业务逻辑

    /// 处理登录
    private func handleLogin_Somnia() {
        let username_Somnia = usernameField_Somnia.text_Somnia.trimmingCharacters(in: .whitespaces)
        let password_Somnia = passwordField_Somnia.text_Somnia.trimmingCharacters(in: .whitespaces)

        // 非空校验
        guard !username_Somnia.isEmpty, !password_Somnia.isEmpty else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "Username and password cannot be empty")
            return
        }

        // 从本地数据中查找用户
        let matchedUser_Somnia = LocalData_Somnia.shared_Somnia.userList_Somnia
            .first { $0.userName_Somnia == username_Somnia }
        let userId_Somnia = matchedUser_Somnia?.userId_Somnia ?? 1

        Task { @MainActor in
            UserViewModel_Somnia.shared_Somnia.loginById_Somnia(userId_somnia: userId_Somnia)
        }
    }

    /// 处理 Apple 登录
    private func handleAppleLogin_Somnia() {
        appleManager_Somnia = AppleLoginManager_Somnia(viewController_Somnia: self)
        appleManager_Somnia?.startAppleLogin_Somnia(
            success_Somnia: { [weak self] _ in
                Task { @MainActor in
                    UserViewModel_Somnia.shared_Somnia.loginById_Somnia(userId_somnia: 1)
                }
            },
            failure_Somnia: { errorMsg_Somnia in
                Utils_Somnia.showError_Somnia(message_Somnia: errorMsg_Somnia)
            }
        )
    }

    @objc private func dismissKeyboard_Somnia() {
        view.endEditing(true)
    }
}

// MARK: - 认证输入框公共组件

/// 带图标的输入框（登录/注册页复用）
/// 功能：展示左侧图标 + 输入区域，支持密码隐藏
class AuthTextField_Somnia: UIView {

    // MARK: - UI组件

    private let iconView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        return iv
    }()

    private let textField_Somnia: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tf.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()

    private let eyeButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let config_Somnia = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: config_Somnia), for: .normal)
        btn.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        return btn
    }()

    /// 是否为密码框
    private let isSecure_Somnia: Bool

    /// 获取输入内容
    var text_Somnia: String { textField_Somnia.text ?? "" }

    // MARK: - 初始化

    /// 初始化认证输入框
    /// - Parameters:
    ///   - placeholder_Somnia: 占位符文本
    ///   - icon_Somnia: SF Symbols 图标名
    ///   - isSecure_Somnia: 是否为密码输入框
    init(placeholder_Somnia: String, icon_Somnia: String, isSecure_Somnia: Bool) {
        self.isSecure_Somnia = isSecure_Somnia
        super.init(frame: .zero)

        let config_Somnia = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        iconView_Somnia.image = UIImage(systemName: icon_Somnia, withConfiguration: config_Somnia)
        textField_Somnia.placeholder = placeholder_Somnia
        textField_Somnia.isSecureTextEntry = isSecure_Somnia
        eyeButton_Somnia.isHidden = !isSecure_Somnia

        setupUI_Somnia()

        if isSecure_Somnia {
            eyeButton_Somnia.addAction(UIAction { [weak self] _ in
                self?.toggleSecure_Somnia()
            }, for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Somnia() {
        backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        layer.cornerRadius = 12

        addSubview(iconView_Somnia)
        addSubview(textField_Somnia)
        addSubview(eyeButton_Somnia)

        iconView_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        eyeButton_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }

        textField_Somnia.snp.makeConstraints { make in
            make.left.equalTo(iconView_Somnia.snp.right).offset(10)
            make.right.equalTo(eyeButton_Somnia.isHidden ? snp.right : eyeButton_Somnia.snp.left).offset(isSecure_Somnia ? 0 : -14)
            make.top.bottom.equalToSuperview()
        }
    }

    /// 切换密码显示/隐藏
    private func toggleSecure_Somnia() {
        textField_Somnia.isSecureTextEntry.toggle()
        let iconName_Somnia = textField_Somnia.isSecureTextEntry ? "eye.slash" : "eye"
        let config_Somnia = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        eyeButton_Somnia.setImage(UIImage(systemName: iconName_Somnia, withConfiguration: config_Somnia), for: .normal)
    }
}
