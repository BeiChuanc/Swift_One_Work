import Foundation
import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页视图控制器
/// 核心作用：提供用户名 + 密码登录、Apple 登录，展示协议链接
/// 设计思路：
///   - 暖橙→珊瑚红渐变背景 + 右侧装饰气泡，与发布页风格一致
///   - 品牌区：镜头光圈图标 + 标题 + 副标题，居中布局
///   - 白色底部大卡片：顶部橙色渐变细条 + 输入框（淡紫背景）+ 主渐变登录按钮
class Login_Lumia: UIViewController {

    // MARK: - 私有属性

    private var appleLoginManager_Lumia: AppleLoginManager_Lumia?

    // MARK: - UI组件

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        sv_Lumia.alwaysBounceVertical = false
        sv_Lumia.keyboardDismissMode = .onDrag
        return sv_Lumia
    }()

    private let contentView_Lumia = UIView()

    private let bgView_Lumia = UIView()
    private var bgGradient_Lumia: CAGradientLayer?

    /// 关闭按钮（同发布页风格：半透明白色圆形）
    private let closeButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn_Lumia
    }()

    private let brandView_Lumia = UIView()

    private let cameraIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.aperture")
        iv_Lumia.tintColor = .white
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let brandTitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "LUMIA"
        let attrs_Lumia: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "AvenirNext-Bold", size: 32) ?? UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor.white,
            .kern: 5.0
        ]
        lbl_Lumia.attributedText = NSAttributedString(string: "LUMIA", attributes: attrs_Lumia)
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let brandSubtitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Your personal film diary"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    /// 登录卡片（底部大圆角白卡）
    private let loginCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 32
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Lumia.layer.shadowColor = UIColor.black.cgColor
        v_Lumia.layer.shadowOpacity = 0.10
        v_Lumia.layer.shadowRadius = 20
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: -6)
        return v_Lumia
    }()

    /// 卡片顶部渐变细条（与背景渐变色系一致）
    private let cardAccentBar_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 2
        return v_Lumia
    }()

    private let cardTitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Sign In"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1008")
        return lbl_Lumia
    }()

    private let cardSubtitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Welcome back, film explorer"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A08060")
        return lbl_Lumia
    }()

    private let nameField_Lumia: LoginInputField_Lumia = {
        let f_Lumia = LoginInputField_Lumia(placeholder: "Username", icon: "person.fill", isSecure: false)
        f_Lumia.textField_Lumia.returnKeyType = .next
        return f_Lumia
    }()

    private let passwordField_Lumia: LoginInputField_Lumia = {
        let f_Lumia = LoginInputField_Lumia(placeholder: "Password", icon: "lock.fill", isSecure: true)
        f_Lumia.textField_Lumia.returnKeyType = .done
        return f_Lumia
    }()

    private let loginButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        btn_Lumia.setTitle("Sign In", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.layer.cornerRadius = 26
        btn_Lumia.clipsToBounds = true
        return btn_Lumia
    }()

    private let registerButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let text_Lumia = "Don't have an account?  Sign Up"
        let attributed_Lumia = NSMutableAttributedString(string: text_Lumia)
        let fullRange_Lumia = NSRange(text_Lumia.startIndex..., in: text_Lumia)
        attributed_Lumia.addAttribute(.foregroundColor, value: UIColor(hexstring_Lumia: "#A08060"), range: fullRange_Lumia)
        if let signUpRange_Lumia = text_Lumia.range(of: "Sign Up") {
            let nsRange_Lumia = NSRange(signUpRange_Lumia, in: text_Lumia)
            attributed_Lumia.addAttribute(.foregroundColor, value: UIColor(hexstring_Lumia: "#E8614A"), range: nsRange_Lumia)
            attributed_Lumia.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange_Lumia)
        }
        btn_Lumia.setAttributedTitle(attributed_Lumia, for: .normal)
        return btn_Lumia
    }()

    private let orLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "─────  or continue with  ─────"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C0A890")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private lazy var appleLoginView_Lumia: AppleLoginBt_Lumia = {
        let v_Lumia = AppleLoginBt_Lumia(onTap_Lumia: { [weak self] in
            self?.handleAppleLogin_Lumia()
        })
        return v_Lumia
    }()

    private var protocolLabel_Lumia: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Lumia?.frame = bgView_Lumia.bounds
        // 卡片顶部渐变色条 frame
        cardAccentBar_Lumia.layer.sublayers?.compactMap { $0 as? CAGradientLayer }.forEach {
            $0.frame = cardAccentBar_Lumia.bounds
        }
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#F6A623")

        // 渐变背景（与发布页颜色一致）
        view.addSubview(bgView_Lumia)
        bgView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#E8614A").cgColor,
            UIColor(hexstring_Lumia: "#C54E8A").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        bgView_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        bgGradient_Lumia = gradient_Lumia

        // 右上装饰气泡
        [makeDecoBubble_Lumia(size: 110, alpha: 0.09),
         makeDecoBubble_Lumia(size: 60, alpha: 0.12),
         makeDecoBubble_Lumia(size: 36, alpha: 0.08)].enumerated().forEach { idx_Lumia, bubble_Lumia in
            view.addSubview(bubble_Lumia)
            let offsets: [(CGFloat, CGFloat)] = [(UIScreen.main.bounds.width - 55, -30),
                                                  (UIScreen.main.bounds.width - 80, 80),
                                                  (-18, 60)]
            bubble_Lumia.frame = CGRect(x: offsets[idx_Lumia].0, y: offsets[idx_Lumia].1,
                                        width: [110, 60, 36][idx_Lumia], height: [110, 60, 36][idx_Lumia])
        }

        // 关闭按钮
        view.addSubview(closeButton_Lumia)
        closeButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(38)
        }
        closeButton_Lumia.addTarget(self, action: #selector(handleClose_Lumia), for: .touchUpInside)

        // 品牌区域
        view.addSubview(brandView_Lumia)
        brandView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(closeButton_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        brandView_Lumia.addSubview(cameraIcon_Lumia)
        cameraIcon_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(58)
        }

        brandView_Lumia.addSubview(brandTitle_Lumia)
        brandTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cameraIcon_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        brandView_Lumia.addSubview(brandSubtitle_Lumia)
        brandSubtitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(brandTitle_Lumia.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 登录卡片
        view.addSubview(loginCard_Lumia)
        loginCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(brandView_Lumia.snp.bottom).offset(28)
            make.leading.trailing.bottom.equalToSuperview()
        }

        setupLoginCard_Lumia()
    }

    private func makeDecoBubble_Lumia(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Lumia.layer.cornerRadius = size / 2
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }

    private func setupLoginCard_Lumia() {
        // 顶部渐变色条（3pt）
        loginCard_Lumia.addSubview(cardAccentBar_Lumia)
        cardAccentBar_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(48)
            make.height.equalTo(4)
        }
        cardAccentBar_Lumia.layer.cornerRadius = 2
        let accentGrad_Lumia = CAGradientLayer()
        accentGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#E8614A").cgColor
        ]
        accentGrad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        accentGrad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        accentGrad_Lumia.cornerRadius = 2
        cardAccentBar_Lumia.layer.insertSublayer(accentGrad_Lumia, at: 0)

        loginCard_Lumia.addSubview(cardTitle_Lumia)
        cardTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cardAccentBar_Lumia.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(28)
        }

        loginCard_Lumia.addSubview(cardSubtitle_Lumia)
        cardSubtitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cardTitle_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(cardTitle_Lumia)
        }

        loginCard_Lumia.addSubview(nameField_Lumia)
        nameField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cardSubtitle_Lumia.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        nameField_Lumia.textField_Lumia.delegate = self

        loginCard_Lumia.addSubview(passwordField_Lumia)
        passwordField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameField_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        passwordField_Lumia.textField_Lumia.delegate = self

        loginCard_Lumia.addSubview(loginButton_Lumia)
        loginButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Lumia.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        let gradientBtn_Lumia = UIColor.createPrimaryGradientLayer_Lumia(
            frame_Lumia: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 52)
        )
        gradientBtn_Lumia.cornerRadius = 26
        loginButton_Lumia.layer.insertSublayer(gradientBtn_Lumia, at: 0)
        loginButton_Lumia.addTarget(self, action: #selector(handleLogin_Lumia), for: .touchUpInside)

        loginCard_Lumia.addSubview(registerButton_Lumia)
        registerButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Lumia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        registerButton_Lumia.addTarget(self, action: #selector(handleRegister_Lumia), for: .touchUpInside)

        loginCard_Lumia.addSubview(orLabel_Lumia)
        orLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Lumia.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

        loginCard_Lumia.addSubview(appleLoginView_Lumia)
        appleLoginView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(orLabel_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        let protocol_Lumia = ProtocolHelper_Lumia.createProtocolTextLabel_Lumia(
            firstContent_Lumia: "terms_image",
            secondContent_Lumia: "privacy_image",
            config_Lumia: .light_Lumia(),
            from: self
        )
        loginCard_Lumia.addSubview(protocol_Lumia)
        protocol_Lumia.snp.makeConstraints { make in
            make.top.equalTo(appleLoginView_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-40)
        }
        protocolLabel_Lumia = protocol_Lumia
    }

    // MARK: - 事件处理

    @objc private func handleClose_Lumia() { Navigation_Lumia.dismiss_Lumia() }

    @objc private func handleLogin_Lumia() {
        let name_Lumia = nameField_Lumia.textField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pwd_Lumia = passwordField_Lumia.textField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !name_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please enter your username.")
            nameField_Lumia.shake_Lumia()
            return
        }
        guard !pwd_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please enter your password.")
            passwordField_Lumia.shake_Lumia()
            return
        }

        view.endEditing(true)
        loginButton_Lumia.animatePressDown_Lumia { self.loginButton_Lumia.animatePressUp_Lumia() }
        Task { @MainActor in
            UserViewModel_Lumia.shared_Lumia.loginById_Lumia(userId_lumia: 56164)
        }
    }

    @objc private func handleRegister_Lumia() {
        Navigation_Lumia.toRegister_Lumia(style_lumia: .push_lumia)
    }

    private func handleAppleLogin_Lumia() {
        let manager_Lumia = AppleLoginManager_Lumia(viewController_Lumia: self)
        appleLoginManager_Lumia = manager_Lumia
        manager_Lumia.startAppleLogin_Lumia(
            success_Lumia: { [weak self] _ in
                Task { @MainActor in
                    UserViewModel_Lumia.shared_Lumia.loginById_Lumia(userId_lumia: 999999)
                }
            },
            failure_Lumia: { message_Lumia in
                if message_Lumia != "Authorization canceled" {
                    Utils_Lumia.showError_Lumia(message_Lumia: message_Lumia)
                }
            }
        )
    }
}

// MARK: - UITextFieldDelegate

extension Login_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField_Lumia.textField_Lumia {
            passwordField_Lumia.textField_Lumia.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleLogin_Lumia()
        }
        return true
    }
}

// MARK: - 登录输入框组件

/// 登录/注册输入框组件（带图标 + 背景 + 边框）
/// 设计：淡紫背景 + 紫色调边框 + 图标，与渐变卡片视觉协调
class LoginInputField_Lumia: UIView {

    let textField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1008")
        tf_Lumia.autocorrectionType = .no
        tf_Lumia.autocapitalizationType = .none
        return tf_Lumia
    }()

    init(placeholder: String, icon: String, isSecure: Bool) {
        super.init(frame: .zero)
        backgroundColor = UIColor(hexstring_Lumia: "#FAF8FF")
        layer.cornerRadius = 16
        layer.borderWidth = 1.2
        layer.borderColor = UIColor(hexstring_Lumia: "#D8CCEE").cgColor

        let iconCfg_Lumia = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iconView_Lumia = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconCfg_Lumia))
        iconView_Lumia.tintColor = UIColor(hexstring_Lumia: "#A090C8")
        iconView_Lumia.contentMode = .scaleAspectFit
        addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        textField_Lumia.placeholder = placeholder
        textField_Lumia.isSecureTextEntry = isSecure
        let attrs_Lumia = [NSAttributedString.Key.foregroundColor: UIColor(hexstring_Lumia: "#C0B0D8")]
        textField_Lumia.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attrs_Lumia)
        addSubview(textField_Lumia)
        textField_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Lumia.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func shake_Lumia() {
        animateShake_Lumia()
        layer.borderColor = UIColor(hexstring_Lumia: "#E53E3E").cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.layer.borderColor = UIColor(hexstring_Lumia: "#D8CCEE").cgColor
        }
    }
}
