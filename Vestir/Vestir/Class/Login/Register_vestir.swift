import Foundation
import UIKit
import SnapKit

// MARK: 注册页面

/// 注册页面
/// 功能：用户名/密码注册，含协议文本与返回按钮
/// 设计：
///   • 靛蓝→青绿全屏沉浸渐变（与登录页互补色，体现品牌系列感）
///   • 三颗装饰圆 + 品牌 Logo 标题
///   • 磨砂白卡片（三个输入框 + 渐变注册按钮）
class Register_Vestir: UIViewController {

    // MARK: - 渐变背景（自管理）

    private let bgCard_Vestir = RegisterBgGradient_Vestir()

    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.09)
        v_Vestir.layer.cornerRadius = 60
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#6EE7B7", alpha_Vestir: 0.18)
        v_Vestir.layer.cornerRadius = 44
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let decoCircle3_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#93C5FD", alpha_Vestir: 0.20)
        v_Vestir.layer.cornerRadius = 28
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    // MARK: - 顶部品牌区

    private lazy var backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    private let logoIconView_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        iv_Vestir.image = UIImage(systemName: "sparkles", withConfiguration: cfg_Vestir)
        iv_Vestir.tintColor = UIColor(white: 1.0, alpha: 0.90)
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()

    private let appNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Join Vestir"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let titleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Start your fashion journey today ✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.75)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // MARK: - 注册卡片

    private let cardView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.96)
        v_Vestir.layer.cornerRadius = 30
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#0F766E").cgColor
        v_Vestir.layer.shadowOpacity = 0.22
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 10)
        v_Vestir.layer.shadowRadius = 28
        return v_Vestir
    }()

    private let cardTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Create Account"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#0F766E")
        return lbl_Vestir
    }()

    private let usernameField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Username"
        tf_Vestir.font = UIFont.systemFont(ofSize: 15)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 14
        tf_Vestir.setLeftPadding_Vestir(icon: "person.fill", tintColor: UIColor(hexstring_Vestir: "#0F766E"))
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
        tf_Vestir.setLeftPadding_Vestir(icon: "lock.fill", tintColor: UIColor(hexstring_Vestir: "#1D4ED8"))
        tf_Vestir.isSecureTextEntry = true
        return tf_Vestir
    }()

    private let confirmPasswordField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Confirm Password"
        tf_Vestir.font = UIFont.systemFont(ofSize: 15)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 14
        tf_Vestir.setLeftPadding_Vestir(icon: "lock.shield.fill", tintColor: UIColor(hexstring_Vestir: "#3730A3"))
        tf_Vestir.isSecureTextEntry = true
        return tf_Vestir
    }()

    private let registerBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("Create Account", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.layer.cornerRadius = 26
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let registerGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#0F766E").cgColor,
            UIColor(hexstring_Vestir: "#1D4ED8").cgColor,
            UIColor(hexstring_Vestir: "#3730A3").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        g_Vestir.cornerRadius = 26
        return g_Vestir
    }()

    private var protocolLabel_Vestir: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        animateIn_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerGradLayer_Vestir.frame = registerBtn_Vestir.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = UIColor(hexstring_Vestir: "#0F766E")

        view.addSubview(bgCard_Vestir)
        bgCard_Vestir.addSubview(decoCircle1_Vestir)
        bgCard_Vestir.addSubview(decoCircle2_Vestir)
        bgCard_Vestir.addSubview(decoCircle3_Vestir)

        view.addSubview(backBtn_Vestir)
        view.addSubview(logoIconView_Vestir)
        view.addSubview(appNameLabel_Vestir)
        view.addSubview(titleLabel_Vestir)

        view.addSubview(cardView_Vestir)
        cardView_Vestir.addSubview(cardTitleLabel_Vestir)
        cardView_Vestir.addSubview(usernameField_Vestir)
        cardView_Vestir.addSubview(passwordField_Vestir)
        cardView_Vestir.addSubview(confirmPasswordField_Vestir)
        cardView_Vestir.addSubview(registerBtn_Vestir)
        registerBtn_Vestir.layer.insertSublayer(registerGradLayer_Vestir, at: 0)

        let protoLabel_Vestir = ProtocolHelper_Vestir.createProtocolTextLabel_Vestir(
            firstContent_Vestir: "terms",
            secondContent_Vestir: "privacy",
            config_Vestir: .light_Vestir(),
            from: self
        )
        protocolLabel_Vestir = protoLabel_Vestir
        cardView_Vestir.addSubview(protoLabel_Vestir)

        registerBtn_Vestir.addTarget(self, action: #selector(registerTapped_Vestir), for: .touchUpInside)
    }

    private func setupConstraints_Vestir() {
        bgCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.trailing.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-30)
        }
        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(88)
            make.leading.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(200)
        }
        decoCircle3_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(200)
        }

        backBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(32)
        }

        logoIconView_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(34)
            make.width.height.equalTo(48)
        }

        appNameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(logoIconView_Vestir.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        titleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel_Vestir.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        cardView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Vestir.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-16)
        }

        cardTitleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(22)
        }

        usernameField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        passwordField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(usernameField_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        confirmPasswordField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        registerBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField_Vestir.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        if let lbl_Vestir = protocolLabel_Vestir {
            lbl_Vestir.snp.makeConstraints { make in
                make.top.equalTo(registerBtn_Vestir.snp.bottom).offset(14)
                make.leading.trailing.equalToSuperview().inset(18)
                make.bottom.equalToSuperview().offset(-22)
            }
        }
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

    @objc private func backTapped_Vestir() { Navigation_Vestir.pop_Vestir() }

    @objc private func registerTapped_Vestir() {
        registerBtn_Vestir.animatePressDown_Vestir { self.registerBtn_Vestir.animatePressUp_Vestir() }
        guard
            let username_vestir = usernameField_Vestir.text, !username_vestir.isEmpty,
            let password_vestir = passwordField_Vestir.text, !password_vestir.isEmpty,
            let confirm_vestir = confirmPasswordField_Vestir.text, !confirm_vestir.isEmpty
        else {
            usernameField_Vestir.animateShake_Vestir()
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please fill in all fields")
            return
        }
        guard password_vestir == confirm_vestir else {
            confirmPasswordField_Vestir.animateShake_Vestir()
            Utils_Vestir.showError_Vestir(message_Vestir: "Passwords do not match")
            return
        }
        Task { @MainActor in
            UserViewModel_Vestir.shared_Vestir.loginById_Vestir(userId_vestir: 8456646)
        }
    }
}

// MARK: - 注册页渐变背景（靛蓝→青绿）

fileprivate final class RegisterBgGradient_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#3730A3").cgColor,
            UIColor(hexstring_Vestir: "#1D4ED8").cgColor,
            UIColor(hexstring_Vestir: "#0F766E").cgColor
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
