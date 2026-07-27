import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页面视图控制器
/// 核心作用：收集用户名、密码与确认密码完成本地演示注册，并直接登录进入应用
/// 设计思路：
///   - 与登录页共享同一套视觉语言：柔和渐变背景 + 摆件光晕装饰圆，强调色改为粉紫渐变
///     （FF6B9D → 7B61FF）以区分登录/注册两个场景，同时保持品牌统一感
///   - 头部徽标同样采用白色描边"悬浮徽章"造型，投影更立体
///   - 用户名/密码/确认密码卡片式输入框统一描边，聚焦时描边切换为强调色
///   - 注册主按钮采用粉紫品牌渐变 + 投影，替代原本的纯色背景
///   - 顶部左上角返回按钮，返回登录页
///   - 注册与登录一样统一走 UserViewModel_Orna.loginById_Orna
///     （本地演示环境下用户名经 LocalData_Orna 解析为稳定 ID 即完成"注册"）
class Register_Orna: UIViewController, UITextFieldDelegate {

    // MARK: - UI · 背景装饰

    /// 全屏柔和渐变背景（淡粉紫 → 白），替代原本单调的纯白底色
    private let backgroundGradientLayer_Orna: CAGradientLayer = {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#FFF0F6").cgColor,
            UIColor.white.cgColor
        ]
        layer_orna.locations = [0, 0.45]
        return layer_orna
    }()

    /// 装饰性光晕圆：低透明度大圆点，呼应"桌面摆件"发光摆件的意象
    private let decorCircleTop_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.10)
        return v
    }()

    private let decorCircleBottom_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.09)
        return v
    }()

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#FF6B9D").cgColor
        b.layer.shadowOpacity = 0.12
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    // MARK: - UI · 头部装饰

    /// 徽标外层白色描边容器，营造"悬浮徽章"层叠效果
    private let logoRingView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Orna: "#FF6B9D").cgColor
        v.layer.shadowOpacity = 0.25
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 20
        return v
    }()

    private let logoBadgeView_Orna: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var logoGradientLayer_Orna: CAGradientLayer?

    private let logoIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "gift.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Create Account"
        l.font = .systemFont(ofSize: 25, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "🎁 Start collecting your own ornaments"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 输入区

    private let usernameField_Orna = Register_Orna.makeInputField_Orna(icon_orna: "person.fill", placeholder_orna: "Username")
    private let passwordField_Orna = Register_Orna.makeInputField_Orna(icon_orna: "lock.fill", placeholder_orna: "Password", isSecure_orna: true)
    private let confirmPasswordField_Orna = Register_Orna.makeInputField_Orna(icon_orna: "lock.rotation", placeholder_orna: "Confirm Password", isSecure_orna: true)

    // MARK: - UI · 操作区

    private let registerButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Sign Up", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.layer.cornerRadius = 24
        b.layer.shadowColor = UIColor(hexstring_Orna: "#FF6B9D").cgColor
        b.layer.shadowOpacity = 0.3
        b.layer.shadowOffset = CGSize(width: 0, height: 8)
        b.layer.shadowRadius = 14
        return b
    }()

    private var registerButtonGradientLayer_Orna: CAGradientLayer?

    private lazy var protocolLabel_Orna: UILabel = ProtocolHelper_Orna.createProtocolTextLabel_Orna(
        firstProtocol_Orna: .terms_Orna,
        firstContent_Orna: "terms.png",
        secondProtocol_Orna: .privacy_Orna,
        secondContent_Orna: "privacy.png",
        config_Orna: ProtocolHelper_Orna.ProtocolTextConfig_Orna(
            textColor_Orna: UIColor(hexstring_Orna: "#B5AFCB"),
            linkColor_Orna: UIColor(hexstring_Orna: "#7B61FF"),
            fontSize_Orna: 12,
            hasUnderline_Orna: true
        ),
        from: self
    )

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(backgroundGradientLayer_Orna, at: 0)
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Orna.frame = view.bounds
        logoGradientLayer_Orna?.frame = logoBadgeView_Orna.bounds
        registerButtonGradientLayer_Orna?.frame = registerButton_Orna.bounds
        logoRingView_Orna.layer.cornerRadius = logoRingView_Orna.bounds.width / 2
        logoBadgeView_Orna.layer.cornerRadius = logoBadgeView_Orna.bounds.width / 2
        decorCircleTop_Orna.layer.cornerRadius = decorCircleTop_Orna.bounds.width / 2
        decorCircleBottom_Orna.layer.cornerRadius = decorCircleBottom_Orna.bounds.width / 2
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(decorCircleTop_Orna)
        view.addSubview(decorCircleBottom_Orna)

        view.addSubview(backButton_Orna)

        view.addSubview(logoRingView_Orna)
        logoRingView_Orna.addSubview(logoBadgeView_Orna)
        setupLogoGradient_Orna()
        logoBadgeView_Orna.addSubview(logoIconView_Orna)
        view.addSubview(titleLabel_Orna)
        view.addSubview(subtitleLabel_Orna)

        view.addSubview(usernameField_Orna)
        view.addSubview(passwordField_Orna)
        view.addSubview(confirmPasswordField_Orna)
        usernameField_Orna.delegate = self
        passwordField_Orna.delegate = self
        confirmPasswordField_Orna.delegate = self

        view.addSubview(registerButton_Orna)
        setupRegisterButtonGradient_Orna()
        view.addSubview(protocolLabel_Orna)
    }

    private func setupLogoGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#FF6B9D").cgColor,
            UIColor(hexstring_Orna: "#7B61FF").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        logoBadgeView_Orna.layer.insertSublayer(layer_orna, at: 0)
        logoGradientLayer_Orna = layer_orna
    }

    /// 注册主按钮粉紫品牌渐变背景，替代原纯色背板，与登录页按钮方向相反以作场景区分
    private func setupRegisterButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#FF6B9D").cgColor,
            UIColor(hexstring_Orna: "#7B61FF").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        registerButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        registerButtonGradientLayer_Orna = layer_orna
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        decorCircleTop_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-60)
            $0.trailing.equalToSuperview().offset(70)
            $0.width.height.equalTo(220)
        }
        decorCircleBottom_Orna.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(-90)
            $0.width.height.equalTo(200)
        }

        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }

        logoRingView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(92)
        }
        logoBadgeView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(76)
        }
        logoIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(logoRingView_Orna.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }

        usernameField_Orna.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel_Orna.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        passwordField_Orna.snp.makeConstraints {
            $0.top.equalTo(usernameField_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        confirmPasswordField_Orna.snp.makeConstraints {
            $0.top.equalTo(passwordField_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        registerButton_Orna.snp.makeConstraints {
            $0.top.equalTo(confirmPasswordField_Orna.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        protocolLabel_Orna.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        registerButton_Orna.addTarget(self, action: #selector(handleRegisterTapped_Orna), for: .touchUpInside)
    }

    // MARK: - UITextFieldDelegate

    /// 输入框获得焦点时描边切换为强调色，提供清晰的聚焦反馈
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.5).cgColor
        }
    }

    /// 输入框失去焦点时描边恢复为默认浅紫色
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 注册按钮点击：校验非空与两次密码一致后，解析用户名为ID并登录
    @objc private func handleRegisterTapped_Orna() {
        let username_orna = (usernameField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password_orna = (passwordField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword_orna = (confirmPasswordField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !username_orna.isEmpty, !password_orna.isEmpty else {
            Load_Orna.showWarning_Orna(message_Orna: "Please enter both username and password.")
            return
        }
        guard password_orna == confirmPassword_orna else {
            Load_Orna.showWarning_Orna(message_Orna: "Passwords do not match.")
            return
        }

        let userId_orna = LocalData_Orna.shared_Orna.resolveUserId_Orna(byName: username_orna)
        UserViewModel_Orna.shared_Orna.loginById_Orna(userId_orna: userId_orna, userName_orna: username_orna)
    }

    // MARK: - 工具方法

    /// 创建统一样式的圆角卡片输入框（浅紫底 + 描边，聚焦时描边切换为强调色）
    private static func makeInputField_Orna(icon_orna: String, placeholder_orna: String, isSecure_orna: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = placeholder_orna
        tf.isSecureTextEntry = isSecure_orna
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = UIColor(hexstring_Orna: "#8B87A0")
        iconView_orna.contentMode = .scaleAspectFit
        let container_orna = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        container_orna.addSubview(iconView_orna)
        iconView_orna.frame = CGRect(x: 16, y: 2, width: 16, height: 16)
        tf.leftView = container_orna
        tf.leftViewMode = .always
        return tf
    }
}
