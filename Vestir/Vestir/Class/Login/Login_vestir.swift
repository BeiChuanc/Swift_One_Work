import Foundation
import UIKit
import SnapKit

// MARK: 登录页面

/// 登录页面
/// 功能：用户名/密码登录、Apple 登录入口，含协议文本与关闭按钮
/// 设计：
///   • 深玫瑰→紫罗兰→靛蓝全屏沉浸渐变（自管理）
///   • 三颗装饰浮动圆，营造时尚层次感
///   • 品牌 Logo + 大标题 + 双语副标题
///   • 磨砂白卡片（暖色输入框 + 渐变按钮 + "or" 分隔行）
class Login_Vestir: UIViewController {

    // MARK: - 渐变背景（自管理）

    private let bgCard_Vestir = LoginBgGradient_Vestir()

    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.09)
        v_Vestir.layer.cornerRadius = 72
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FDA4AF", alpha_Vestir: 0.18)
        v_Vestir.layer.cornerRadius = 46
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let decoCircle3_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#C4B5FD", alpha_Vestir: 0.20)
        v_Vestir.layer.cornerRadius = 30
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    // MARK: - 顶部品牌区

    private let closeBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let logoIconView_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        iv_Vestir.image = UIImage(systemName: "tshirt.fill", withConfiguration: cfg_Vestir)
        iv_Vestir.tintColor = UIColor(white: 1.0, alpha: 0.92)
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()

    private let appNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Vestir"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let titleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Welcome back ✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.78)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // MARK: - 登录卡片

    private let cardView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.96)
        v_Vestir.layer.cornerRadius = 30
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#BE185D").cgColor
        v_Vestir.layer.shadowOpacity = 0.22
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 10)
        v_Vestir.layer.shadowRadius = 28
        return v_Vestir
    }()

    private let cardTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Sign In"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#BE185D")
        return lbl_Vestir
    }()

    private let usernameField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Username"
        tf_Vestir.font = UIFont.systemFont(ofSize: 15)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 14
        tf_Vestir.setLeftPadding_Vestir(icon: "person.fill", tintColor: UIColor(hexstring_Vestir: "#BE185D"))
        tf_Vestir.autocapitalizationType = .none
        tf_Vestir.autocorrectionType = .no
        return tf_Vestir
    }()

    private let passwordField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Password"
        tf_Vestir.font = UIFont.systemFont(ofSize: 15)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 14
        tf_Vestir.setLeftPadding_Vestir(icon: "lock.fill", tintColor: UIColor(hexstring_Vestir: "#7C3AED"))
        tf_Vestir.isSecureTextEntry = true
        return tf_Vestir
    }()

    private let loginBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("Sign In", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.layer.cornerRadius = 26
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let loginGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#BE185D").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        g_Vestir.cornerRadius = 26
        return g_Vestir
    }()

    // "Or continue with" 分隔行
    private let orRow_Vestir: UIView = UIView()
    private let orLineLeft_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
        return v_Vestir
    }()
    private let orLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "or"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        return lbl_Vestir
    }()
    private let orLineRight_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
        return v_Vestir
    }()

    private lazy var appleLoginBtn_Vestir: AppleLoginBt_Vestir = {
        return AppleLoginBt_Vestir(onTap_Vestir: { [weak self] in
            self?.handleAppleLogin_Vestir()
        })
    }()

    private let registerLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.isUserInteractionEnabled = true
        let attrStr_Vestir = NSMutableAttributedString(
            string: "Don't have an account?  ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: ColorConfig_Vestir.textSecondary_Vestir
            ]
        )
        attrStr_Vestir.append(NSAttributedString(
            string: "Sign Up",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor(hexstring_Vestir: "#BE185D"),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        lbl_Vestir.attributedText = attrStr_Vestir
        return lbl_Vestir
    }()

    private var protocolLabel_Vestir: UILabel?
    private var appleManager_Vestir: AppleLoginManager_Vestir?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        setupActions_Vestir()
        animateIn_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginGradLayer_Vestir.frame = loginBtn_Vestir.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = UIColor(hexstring_Vestir: "#BE185D")

        view.addSubview(bgCard_Vestir)
        bgCard_Vestir.addSubview(decoCircle1_Vestir)
        bgCard_Vestir.addSubview(decoCircle2_Vestir)
        bgCard_Vestir.addSubview(decoCircle3_Vestir)

        view.addSubview(closeBtn_Vestir)
        view.addSubview(logoIconView_Vestir)
        view.addSubview(appNameLabel_Vestir)
        view.addSubview(titleLabel_Vestir)

        view.addSubview(cardView_Vestir)
        cardView_Vestir.addSubview(cardTitleLabel_Vestir)
        cardView_Vestir.addSubview(usernameField_Vestir)
        cardView_Vestir.addSubview(passwordField_Vestir)
        cardView_Vestir.addSubview(loginBtn_Vestir)
        loginBtn_Vestir.layer.insertSublayer(loginGradLayer_Vestir, at: 0)
        cardView_Vestir.addSubview(orRow_Vestir)
        orRow_Vestir.addSubview(orLineLeft_Vestir)
        orRow_Vestir.addSubview(orLabel_Vestir)
        orRow_Vestir.addSubview(orLineRight_Vestir)
        cardView_Vestir.addSubview(appleLoginBtn_Vestir)
        cardView_Vestir.addSubview(registerLabel_Vestir)

        let protoLabel_Vestir = ProtocolHelper_Vestir.createProtocolTextLabel_Vestir(
            firstContent_Vestir: "terms",
            secondContent_Vestir: "privacy",
            config_Vestir: .light_Vestir(),
            from: self
        )
        protocolLabel_Vestir = protoLabel_Vestir
        cardView_Vestir.addSubview(protoLabel_Vestir)
    }

    private func setupConstraints_Vestir() {
        bgCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(144)
            make.trailing.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(-36)
        }
        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(92)
            make.leading.equalToSuperview().offset(-28)
            make.top.equalToSuperview().offset(220)
        }
        decoCircle3_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(180)
        }

        closeBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(32)
        }

        logoIconView_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            make.width.height.equalTo(52)
        }

        appNameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Vestir.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        titleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel_Vestir.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        cardView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Vestir.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-16)
        }

        cardTitleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.leading.equalToSuperview().offset(22)
        }

        usernameField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel_Vestir.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        passwordField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Vestir.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        loginBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Vestir.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        orRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(loginBtn_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(16)
        }
        orLineLeft_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
            make.trailing.equalTo(orLabel_Vestir.snp.leading).offset(-10)
        }
        orLabel_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        orLineRight_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
            make.leading.equalTo(orLabel_Vestir.snp.trailing).offset(10)
        }

        appleLoginBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(orRow_Vestir.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
        }

        registerLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(appleLoginBtn_Vestir.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        if let lbl_Vestir = protocolLabel_Vestir {
            lbl_Vestir.snp.makeConstraints { make in
                make.top.equalTo(registerLabel_Vestir.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(18)
                make.bottom.equalToSuperview().offset(-22)
            }
        }
    }

    private func setupActions_Vestir() {
        closeBtn_Vestir.addTarget(self, action: #selector(closeTapped_Vestir), for: .touchUpInside)
        loginBtn_Vestir.addTarget(self, action: #selector(loginTapped_Vestir), for: .touchUpInside)
        let tap_Vestir = UITapGestureRecognizer(target: self, action: #selector(registerTapped_Vestir))
        registerLabel_Vestir.addGestureRecognizer(tap_Vestir)
    }

    private func animateIn_Vestir() {
        cardView_Vestir.alpha = 0
        appNameLabel_Vestir.alpha = 0
        titleLabel_Vestir.alpha = 0
        logoIconView_Vestir.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.08, options: .curveEaseOut) {
            self.logoIconView_Vestir.alpha = 1
            self.appNameLabel_Vestir.alpha = 1
            self.titleLabel_Vestir.alpha = 1
        }
        cardView_Vestir.animateSlideInFromBottom_Vestir(offset_Vestir: 60, delay_Vestir: 0.18)
    }

    // MARK: - 事件处理

    @objc private func closeTapped_Vestir() {
        closeBtn_Vestir.animatePressDown_Vestir {
            self.closeBtn_Vestir.animatePressUp_Vestir { Navigation_Vestir.dismiss_Vestir() }
        }
    }

    @objc private func loginTapped_Vestir() {
        loginBtn_Vestir.animatePressDown_Vestir { self.loginBtn_Vestir.animatePressUp_Vestir() }
        guard
            let username_vestir = usernameField_Vestir.text, !username_vestir.isEmpty,
            let password_vestir = passwordField_Vestir.text, !password_vestir.isEmpty
        else {
            usernameField_Vestir.animateShake_Vestir()
            passwordField_Vestir.animateShake_Vestir()
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please fill in all fields")
            return
        }
        Task { @MainActor in
            UserViewModel_Vestir.shared_Vestir.loginById_Vestir(userId_vestir: 8456645)
        }
    }

    @objc private func registerTapped_Vestir() {
        Navigation_Vestir.toRegister_Vestir(style_vestir: .push_vestir)
    }

    private func handleAppleLogin_Vestir() {
        appleManager_Vestir = AppleLoginManager_Vestir(viewController_Vestir: self)
        appleManager_Vestir?.startAppleLogin_Vestir(
            success_Vestir: { _ in
                Task { @MainActor in
                    UserViewModel_Vestir.shared_Vestir.loginById_Vestir(userId_vestir: 10)
                }
            },
            failure_Vestir: { errMsg_vestir in
                Utils_Vestir.showError_Vestir(message_Vestir: errMsg_vestir)
            }
        )
    }
}

// MARK: - 登录页渐变背景（深玫瑰→紫罗兰→靛蓝）

fileprivate final class LoginBgGradient_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#BE185D").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g.locations = [0, 0.50, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}
