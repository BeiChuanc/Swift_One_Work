import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页面
/// 核心作用：提供用户名/密码注册功能，含协议入口
/// 设计思路：与登录页同风格渐变背景，表单聚焦于三个输入项
class Register_Somnia: UIViewController {

    // MARK: - UI组件

    private var _gradientLayer_Somnia: CAGradientLayer?

    /// 左上角返回按钮（使用项目内置返回组件）
    private let backButton_Somnia = BackButton_Somnia()

    private let topCircle_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 100
        return v
    }()

    private let logoView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create Account"
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let subtitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Join the dream community"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        return lbl
    }()

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

    private let usernameField_Somnia = AuthTextField_Somnia(
        placeholder_Somnia: "Username",
        icon_Somnia: "person",
        isSecure_Somnia: false
    )

    private let passwordField_Somnia = AuthTextField_Somnia(
        placeholder_Somnia: "Password",
        icon_Somnia: "lock",
        isSecure_Somnia: true
    )

    private let confirmPasswordField_Somnia = AuthTextField_Somnia(
        placeholder_Somnia: "Confirm Password",
        icon_Somnia: "lock.shield",
        isSecure_Somnia: true
    )

    private let registerButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        return btn
    }()

    private var registerGradient_Somnia: CAGradientLayer?

    private let loginLink_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let attrs_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: ColorConfig_Somnia.textSecondary_Somnia
        ]
        let linkAttrs_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: ColorConfig_Somnia.primaryGradientStart_Somnia
        ]
        let str_Somnia = NSMutableAttributedString(string: "Already have an account? ", attributes: attrs_Somnia)
        str_Somnia.append(NSAttributedString(string: "Sign In", attributes: linkAttrs_Somnia))
        btn.setAttributedTitle(str_Somnia, for: .normal)
        return btn
    }()

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
        registerGradient_Somnia?.frame = registerButton_Somnia.bounds
    }

    // MARK: - 私有方法 - UI设置

    private func setupUI_Somnia() {
        // 渐变背景（辅助色系：玫瑰粉→珊瑚橙）
        let gradient_Somnia = CAGradientLayer()
        gradient_Somnia.colors = [
            ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.secondaryGradientEnd_Somnia.cgColor
        ]
        gradient_Somnia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Somnia.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient_Somnia, at: 0)
        _gradientLayer_Somnia = gradient_Somnia

        view.addSubview(topCircle_Somnia)
        view.addSubview(backButton_Somnia)
        view.addSubview(logoView_Somnia)
        view.addSubview(titleLabel_Somnia)
        view.addSubview(subtitleLabel_Somnia)
        view.addSubview(formCard_Somnia)

        formCard_Somnia.addSubview(usernameField_Somnia)
        formCard_Somnia.addSubview(passwordField_Somnia)
        formCard_Somnia.addSubview(confirmPasswordField_Somnia)
        formCard_Somnia.addSubview(registerButton_Somnia)
        formCard_Somnia.addSubview(loginLink_Somnia)
        formCard_Somnia.addSubview(protocolLabel_Somnia)

        topCircle_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(50)
            make.width.height.equalTo(200)
        }

        // 返回按钮固定在左上角安全区内
        backButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }

        logoView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(54)
        }

        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(logoView_Somnia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        subtitleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        formCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Somnia.snp.bottom).offset(28)
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

        confirmPasswordField_Somnia.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Somnia.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        registerButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField_Somnia.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        loginLink_Somnia.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Somnia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        protocolLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(loginLink_Somnia.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
        }

        // 注册按钮渐变
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let grad_Somnia = CAGradientLayer()
            grad_Somnia.colors = [
                ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.secondaryGradientEnd_Somnia.cgColor
            ]
            grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 1, y: 0)
            grad_Somnia.frame = self.registerButton_Somnia.bounds
            self.registerButton_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
            self.registerGradient_Somnia = grad_Somnia
        }
    }

    private func setupActions_Somnia() {
        // 返回按钮：关闭注册页
        backButton_Somnia.onTapped_Somnia = {
            Navigation_Somnia.dismiss_Somnia()
        }

        registerButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleRegister_Somnia()
        }, for: .touchUpInside)

        loginLink_Somnia.addAction(UIAction { _ in
            Navigation_Somnia.dismiss_Somnia()
        }, for: .touchUpInside)

        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Somnia))
        tap_Somnia.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Somnia)
    }

    // MARK: - 私有方法 - 业务逻辑

    /// 处理注册
    private func handleRegister_Somnia() {
        let username_Somnia = usernameField_Somnia.text_Somnia.trimmingCharacters(in: .whitespaces)
        let password_Somnia = passwordField_Somnia.text_Somnia.trimmingCharacters(in: .whitespaces)
        let confirm_Somnia = confirmPasswordField_Somnia.text_Somnia.trimmingCharacters(in: .whitespaces)

        // 非空校验
        guard !username_Somnia.isEmpty, !password_Somnia.isEmpty, !confirm_Somnia.isEmpty else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "All fields are required")
            return
        }

        // 密码一致性校验
        guard password_Somnia == confirm_Somnia else {
            Utils_Somnia.showError_Somnia(message_Somnia: "Passwords do not match")
            return
        }

        // 生成新用户 ID（本地数据末尾+1）
        let newId_Somnia = (LocalData_Somnia.shared_Somnia.userList_Somnia.last?.userId_Somnia ?? 10) + 1

        Task { @MainActor in
            UserViewModel_Somnia.shared_Somnia.loginById_Somnia(userId_somnia: newId_Somnia)
        }
    }

    @objc private func dismissKeyboard_Somnia() {
        view.endEditing(true)
    }
}
