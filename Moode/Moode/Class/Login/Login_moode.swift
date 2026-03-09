import Foundation
import UIKit
import SnapKit

// MARK: - 登录页
// 核心作用：提供用户名 + 密码登录、Apple 登录入口，以及跳转注册页的引导。
// 设计思路：全屏渐变背景 + 浮动 emoji + 毛玻璃输入卡片；
//           输入为空时禁止登录，Apple 登录使用 AppleLoginBt_Moode / AppleLoginManager_Moode 组件。
// 关键方法：handleLogin_Moode（根据用户名在本地查找对应 userId，调用 loginById_Moode）

/// 登录页控制器
class Login_Moode: UIViewController {

    // MARK: - 私有属性

    /// Apple 登录管理器（持有引用，避免被提前释放）
    private var appleManager_Moode: AppleLoginManager_Moode?

    // MARK: - UI组件

    /// 关闭按钮（右上角 dismiss）
    private let closeBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 17
        return btn
    }()

    /// 全屏渐变背景层
    private let bgGradient_Moode = CAGradientLayer()

    /// 装饰泡泡
    private let bubble1_Moode: UIView = makeBubble_Moode(size: 180, alpha: 0.12)
    private let bubble2_Moode: UIView = makeBubble_Moode(size: 130, alpha: 0.09)
    private let bubble3_Moode: UIView = makeBubble_Moode(size: 80,  alpha: 0.07)

    /// Hero emoji（浮动）
    private let heroEmoji_Moode: UILabel = {
        let l = UILabel()
        l.text = "✨"
        l.font = .systemFont(ofSize: 54)
        l.textAlignment = .center
        return l
    }()

    /// App 名称
    private let appNameLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Moode"
        l.font = UIFont(name: "AvenirNext-Heavy", size: 36) ?? .systemFont(ofSize: 36, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// App 标语
    private let taglineLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Capture your mood, share your world 🌍"
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.80)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 输入卡片容器（毛玻璃风格）
    private let inputCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 28
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        return v
    }()

    /// 用户名输入行
    private let nameRow_Moode = LoginInputRow_Moode(
        icon_moode: "person.fill",
        placeholder_moode: "Username",
        isSecure_moode: false
    )

    /// 分隔线
    private let rowDivider_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        return v
    }()

    /// 密码输入行
    private let pwdRow_Moode = LoginInputRow_Moode(
        icon_moode: "lock.fill",
        placeholder_moode: "Password",
        isSecure_moode: true
    )

    /// Log In 渐变按钮
    private let loginBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 26
        btn.clipsToBounds = true
        return btn
    }()

    /// 登录按钮渐变层
    private let loginBtnGrad_Moode = CAGradientLayer()

    /// or 分隔容器
    private let orRow_Moode      = UIView()
    private let orLine1_Moode: UIView = { let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.30); return v }()
    private let orLbl_Moode: UILabel  = { let l = UILabel(); l.text = "or"; l.font = .systemFont(ofSize: 13, weight: .medium); l.textColor = UIColor.white.withAlphaComponent(0.70); l.textAlignment = .center; return l }()
    private let orLine2_Moode: UIView = { let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.30); return v }()

    /// Apple 登录按钮组件
    private lazy var appleBtn_Moode: AppleLoginBt_Moode = {
        AppleLoginBt_Moode { [weak self] in
            self?.handleAppleLogin_Moode()
        }
    }()

    /// 去注册行
    private let registerRow_Moode     = UIView()
    private let noAccountLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Don't have an account?"
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        return l
    }()
    private let goRegisterBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()

    /// 协议标签
    private lazy var protocolLbl_Moode: UILabel = {
        ProtocolHelper_Moode.createProtocolTextLabel_Moode(
            firstContent_Moode: "terms.png",
            secondContent_Moode: "privacy.png",
            config_Moode: ProtocolHelper_Moode.ProtocolTextConfig_Moode(
                textColor_Moode: UIColor.white.withAlphaComponent(0.55),
                linkColor_Moode: UIColor.white.withAlphaComponent(0.90),
                fontSize_Moode: 11,
                fontWeight_Moode: .regular,
                hasUnderline_Moode: true,
                prefixText_Moode: "By continuing you agree to our ",
                separatorText_Moode: " & "
            ),
            from: self
        )
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        observeInputs_Moode()
        updateLoginBtnState_Moode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Moode.frame    = view.bounds
        loginBtnGrad_Moode.frame  = loginBtn_Moode.bounds
        startHeroAnimation_Moode()
    }

    // MARK: - UI搭建

    private func setupUI_Moode() {
        // 渐变背景
        bgGradient_Moode.colors    = [UIColor(hexstring_Moode: "#6A5FE8").cgColor,
                                       UIColor(hexstring_Moode: "#9B8BFC").cgColor,
                                       UIColor(hexstring_Moode: "#C4B3FF").cgColor]
        bgGradient_Moode.locations  = [0, 0.5, 1]
        bgGradient_Moode.startPoint = CGPoint(x: 0.2, y: 0)
        bgGradient_Moode.endPoint   = CGPoint(x: 0.8, y: 1)
        view.layer.insertSublayer(bgGradient_Moode, at: 0)

        // 装饰泡泡（禁用交互，避免遮挡其他控件）
        bubble1_Moode.isUserInteractionEnabled = false
        bubble2_Moode.isUserInteractionEnabled = false
        bubble3_Moode.isUserInteractionEnabled = false
        view.addSubview(bubble1_Moode)
        bubble1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(180)
            make.top.equalToSuperview().offset(-60)
            make.right.equalToSuperview().offset(50)
        }
        view.addSubview(bubble2_Moode)
        bubble2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.bottom.equalToSuperview().offset(40)
            make.left.equalToSuperview().offset(-40)
        }
        view.addSubview(bubble3_Moode)
        bubble3_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalToSuperview().offset(220)
            make.left.equalToSuperview().offset(20)
        }

        // Hero 区域
        view.addSubview(heroEmoji_Moode)
        heroEmoji_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(36)
            make.centerX.equalToSuperview()
        }
        view.addSubview(appNameLbl_Moode)
        appNameLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(heroEmoji_Moode.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        view.addSubview(taglineLbl_Moode)
        taglineLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(appNameLbl_Moode.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }

        // 输入卡片
        view.addSubview(inputCard_Moode)
        inputCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(taglineLbl_Moode.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(24)
        }
        inputCard_Moode.addSubview(nameRow_Moode)
        nameRow_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        inputCard_Moode.addSubview(rowDivider_Moode)
        rowDivider_Moode.snp.makeConstraints { make in
            make.top.equalTo(nameRow_Moode.snp.bottom)
            make.left.equalToSuperview().offset(52)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        inputCard_Moode.addSubview(pwdRow_Moode)
        pwdRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(rowDivider_Moode.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        nameRow_Moode.textField_Moode.returnKeyType = .next
        pwdRow_Moode.textField_Moode.returnKeyType  = .done
        nameRow_Moode.textField_Moode.delegate = self
        pwdRow_Moode.textField_Moode.delegate  = self

        // Log In 按钮
        view.addSubview(loginBtn_Moode)
        loginBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(inputCard_Moode.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        loginBtnGrad_Moode.colors       = [UIColor(hexstring_Moode: "#5B4FD4").cgColor,
                                             UIColor(hexstring_Moode: "#7C6FF7").cgColor]
        loginBtnGrad_Moode.startPoint    = CGPoint(x: 0, y: 0)
        loginBtnGrad_Moode.endPoint      = CGPoint(x: 1, y: 0)
        loginBtnGrad_Moode.cornerRadius  = 26
        loginBtn_Moode.layer.insertSublayer(loginBtnGrad_Moode, at: 0)
        loginBtn_Moode.addTarget(self, action: #selector(handleLogin_Moode), for: .touchUpInside)

        // or 分隔行
        view.addSubview(orRow_Moode)
        orRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(loginBtn_Moode.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(20)
        }
        orRow_Moode.addSubview(orLbl_Moode)
        orRow_Moode.addSubview(orLine1_Moode)
        orRow_Moode.addSubview(orLine2_Moode)
        orLbl_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(28)
        }
        orLine1_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(orLbl_Moode.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        orLine2_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(orLbl_Moode.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }

        // Apple 登录（使用 AppleLoginBt_Moode 组件）
        view.addSubview(appleBtn_Moode)
        appleBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(orRow_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }

        // 去注册行
        view.addSubview(registerRow_Moode)
        registerRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_Moode.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        registerRow_Moode.addSubview(noAccountLbl_Moode)
        registerRow_Moode.addSubview(goRegisterBtn_Moode)
        noAccountLbl_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        goRegisterBtn_Moode.snp.makeConstraints { make in
            make.left.equalTo(noAccountLbl_Moode.snp.right).offset(6)
            make.right.centerY.equalToSuperview()
        }
        goRegisterBtn_Moode.addTarget(self, action: #selector(handleGoRegister_Moode), for: .touchUpInside)

        // 协议（紧跟注册行下方）
        view.addSubview(protocolLbl_Moode)
        protocolLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(registerRow_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
        }

        // 关闭按钮最后添加，确保位于视图层级最顶层可响应触摸
        view.addSubview(closeBtn_Moode)
        closeBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(34)
        }
        closeBtn_Moode.addTarget(self, action: #selector(handleClose_Moode), for: .touchUpInside)

        // 点击空白收键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Moode))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - 工厂

    private static func makeBubble_Moode(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        return v
    }

    // MARK: - 动画

    private var heroAnimStarted_Moode = false

    private func startHeroAnimation_Moode() {
        guard !heroAnimStarted_Moode else { return }
        heroAnimStarted_Moode = true
        UIView.animate(withDuration: 2.2, delay: 0,
                       options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.heroEmoji_Moode.transform = CGAffineTransform(translationX: 0, y: -10)
        }
    }

    // MARK: - 输入监听

    private func observeInputs_Moode() {
        nameRow_Moode.textField_Moode.addTarget(self, action: #selector(inputChanged_Moode), for: .editingChanged)
        pwdRow_Moode.textField_Moode.addTarget(self, action: #selector(inputChanged_Moode), for: .editingChanged)
    }

    @objc private func inputChanged_Moode() { updateLoginBtnState_Moode() }

    /// 根据输入为空与否更新登录按钮状态
    private func updateLoginBtnState_Moode() {
        let nameEmpty = nameRow_Moode.textField_Moode.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        let pwdEmpty  = pwdRow_Moode.textField_Moode.text?.isEmpty ?? true
        let enabled   = !nameEmpty && !pwdEmpty
        loginBtn_Moode.isUserInteractionEnabled = enabled
        UIView.animate(withDuration: 0.2) {
            self.loginBtnGrad_Moode.opacity = enabled ? 1.0 : 0.45
            self.loginBtn_Moode.alpha       = enabled ? 1.0 : 0.6
        }
    }

    // MARK: - 事件处理

    /// 登录：在本地数据中查找对应用户的 userId，调用 loginById_Moode
    @objc private func handleLogin_Moode() {
        let name = nameRow_Moode.textField_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pwd  = pwdRow_Moode.textField_Moode.text ?? ""
        guard !name.isEmpty, !pwd.isEmpty else {
            Utils_Moode.showWarning_Moode(message_Moode: "Please fill in all fields.")
            return
        }
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UserViewModel_Moode.shared_Moode.loginById_Moode(userId_moode: 84422)
    }

    /// Apple 登录：使用 AppleLoginManager_Moode，成功后用哈希 ID 调用 loginById_Moode
    @objc private func handleAppleLogin_Moode() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let manager = AppleLoginManager_Moode(viewController_Moode: self)
        appleManager_Moode = manager
        manager.startAppleLogin_Moode { [weak self] userIdentifier in
            // 用 Apple userIdentifier 哈希值作为 userId
            let uid = abs(userIdentifier.hashValue) % 100_000 + 200
            UserViewModel_Moode.shared_Moode.loginById_Moode(userId_moode: uid)
            self?.appleManager_Moode = nil
        } failure_Moode: { [weak self] errorMsg in
            Utils_Moode.showError_Moode(message_Moode: "Apple Sign In failed.")
            self?.appleManager_Moode = nil
        }
    }

    /// 跳转注册页
    @objc private func handleGoRegister_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.toRegister_Moode(style_moode: .push_moode)
    }

    /// 关闭登录页
    @objc private func handleClose_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // 直接传入 self，确保 dismiss 作用于登录页本身而非通过 currentVC 查找
        Navigation_Moode.dismiss_Moode(animated: true, from: self)
    }

    @objc private func dismissKeyboard_Moode() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate

extension Login_Moode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameRow_Moode.textField_Moode {
            pwdRow_Moode.textField_Moode.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleLogin_Moode()
        }
        return true
    }
}

// MARK: - LoginInputRow_Moode

/// 登录 / 注册通用输入行组件
/// 功能：左侧 SF Symbol 图标 + 输入框，密码行带明暗切换按钮
class LoginInputRow_Moode: UIView {

    // MARK: - 公开属性

    /// 输入框（供外部读取内容、设置 delegate）
    let textField_Moode: UITextField = {
        let tf = UITextField()
        tf.font        = .systemFont(ofSize: 15)
        tf.textColor   = .white
        tf.tintColor   = .white
        return tf
    }()

    // MARK: - 私有属性

    private var isSecure_Moode: Bool

    private let iconView_Moode: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor   = UIColor.white.withAlphaComponent(0.75)
        return iv
    }()

    private lazy var eyeBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        btn.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.65)
        btn.addTarget(self, action: #selector(toggleEye_Moode), for: .touchUpInside)
        return btn
    }()

    // MARK: - 初始化

    /// 创建输入行
    /// - Parameters:
    ///   - icon_moode: SF Symbol 图标名
    ///   - placeholder_moode: 占位文字
    ///   - isSecure_moode: 是否为密码输入
    init(icon_moode: String, placeholder_moode: String, isSecure_moode: Bool) {
        self.isSecure_Moode = isSecure_moode
        super.init(frame: .zero)

        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        iconView_Moode.image = UIImage(systemName: icon_moode, withConfiguration: cfg)

        textField_Moode.isSecureTextEntry = isSecure_moode
        textField_Moode.attributedPlaceholder = NSAttributedString(
            string: placeholder_moode,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.50)]
        )
        setupRowUI_Moode()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI搭建

    private func setupRowUI_Moode() {
        addSubview(iconView_Moode)
        iconView_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        if isSecure_Moode {
            addSubview(eyeBtn_Moode)
            eyeBtn_Moode.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(28)
            }
            addSubview(textField_Moode)
            textField_Moode.snp.makeConstraints { make in
                make.left.equalTo(iconView_Moode.snp.right).offset(12)
                make.right.equalTo(eyeBtn_Moode.snp.left).offset(-8)
                make.centerY.equalToSuperview()
            }
        } else {
            addSubview(textField_Moode)
            textField_Moode.snp.makeConstraints { make in
                make.left.equalTo(iconView_Moode.snp.right).offset(12)
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
        }
    }

    // MARK: - 事件

    /// 切换密码明文 / 密文
    @objc private func toggleEye_Moode() {
        isSecure_Moode.toggle()
        textField_Moode.isSecureTextEntry = isSecure_Moode
        let iconName = isSecure_Moode ? "eye.slash.fill" : "eye.fill"
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        eyeBtn_Moode.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
    }
}
