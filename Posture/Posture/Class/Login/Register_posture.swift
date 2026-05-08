import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页面控制器
/// 核心作用：提供用户名、密码、确认密码注册入口和协议提示。
/// 设计思路：本地注册只做输入校验，通过用户 ID 登录方法进入应用，保持登录逻辑统一。
/// UI 层分为暖色渐变背景区、顶部品牌区、表单卡片区三部分，整体可滚动。
/// 关键属性：三个输入框收集注册信息。
/// 关键方法：`handleRegister_Posture()` 完成注册校验并调用登录。
@MainActor
class Register_Posture: UIViewController {

    // MARK: - 属性

    private let nameField_Posture     = UITextField()
    private let passwordField_Posture = UITextField()
    private let confirmField_Posture  = UITextField()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Posture))
        tap_Posture.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Posture)
    }

    // MARK: - UI 搭建

    /// 搭建注册页完整 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        setupFullGradientBg_Posture()

        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = false
        scrollView_Posture.keyboardDismissMode = .interactive
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        scrollView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        // 返回按钮
        let backBtn_Posture = buildCircleIconButton_Posture(icon: "chevron.left", tint: .white, bgAlpha: 0.22)
        backBtn_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)
        view.addSubview(backBtn_Posture)
        backBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }

        let brandSection_Posture = buildBrandSection_Posture()
        let formCard_Posture     = buildFormCard_Posture()

        contentView_Posture.addSubview(brandSection_Posture)
        contentView_Posture.addSubview(formCard_Posture)

        brandSection_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        formCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(brandSection_Posture.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 区块构建

    /// 搭建暖色渐变背景（珊瑚→品红→靛蓝）
    private func setupFullGradientBg_Posture() {
        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            ColorConfig_Posture.accentCoral_Posture.cgColor,
            ColorConfig_Posture.accentFuchsia_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.backgroundPrimary_Posture.cgColor
        ]
        grad_Posture.locations = [0, 0.28, 0.52, 1.0]
        grad_Posture.startPoint = CGPoint(x: 0.3, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 0.7, y: 1)
        grad_Posture.frame = UIScreen.main.bounds
        view.layer.insertSublayer(grad_Posture, at: 0)

        let bubbles_Posture: [(CGFloat, CGFloat, CGFloat, CGFloat, Bool)] = [
            (100, -30, 50, 0.13, false), (70, -20, 160, 0.09, true), (55, 180, 90, 0.08, false)
        ]
        bubbles_Posture.forEach { cfg_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = UIColor.white.withAlphaComponent(cfg_Posture.3)
            blob_Posture.layer.cornerRadius = cfg_Posture.0 / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 1)
            blob_Posture.snp.makeConstraints { make in
                if cfg_Posture.4 { make.trailing.equalToSuperview().offset(cfg_Posture.1)
                } else { make.leading.equalToSuperview().offset(cfg_Posture.1) }
                make.top.equalToSuperview().offset(cfg_Posture.2)
                make.width.height.equalTo(cfg_Posture.0)
            }
        }
    }

    /// 构建顶部品牌区
    /// - Parameters: 无
    /// - Returns: UIView - 品牌区视图
    /// - Throws: 无
    private func buildBrandSection_Posture() -> UIView {
        let container_Posture = UIView()

        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconBg_Posture.layer.cornerRadius = 32

        let iconView_Posture = UIImageView(image: UIImage(systemName: "person.badge.plus.fill"))
        iconView_Posture.tintColor = .white
        iconView_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(38)
        }

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Join the Community"
        titleLabel_Posture.font = .systemFont(ofSize: 34, weight: .heavy)
        titleLabel_Posture.textColor = .white
        titleLabel_Posture.textAlignment = .center
        titleLabel_Posture.numberOfLines = 2

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "Build better posture with people who get it."
        subtitleLabel_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitleLabel_Posture.textAlignment = .center
        subtitleLabel_Posture.numberOfLines = 2

        // 特色胶囊行
        let chipStack_Posture = UIStackView()
        chipStack_Posture.axis = .horizontal
        chipStack_Posture.spacing = 10
        chipStack_Posture.alignment = .center
        [("figure.cooldown", "Neck"), ("chair", "Desk"), ("figure.core.training", "Core")].forEach { chip_Posture in
            chipStack_Posture.addArrangedSubview(makeBrandChip_Posture(icon: chip_Posture.0, title: chip_Posture.1))
        }

        container_Posture.addSubview(iconBg_Posture)
        container_Posture.addSubview(titleLabel_Posture)
        container_Posture.addSubview(subtitleLabel_Posture)
        container_Posture.addSubview(chipStack_Posture)

        let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 62)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        chipStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }

        return container_Posture
    }

    /// 构建品牌特色胶囊
    private func makeBrandChip_Posture(icon: String, title: String) -> UIView {
        let chip_Posture = UIView()
        chip_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        chip_Posture.layer.cornerRadius = 16

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = .white
        iconView_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = title
        label_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        label_Posture.textColor = .white

        chip_Posture.addSubview(iconView_Posture)
        chip_Posture.addSubview(label_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Posture.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        chip_Posture.snp.makeConstraints { make in make.height.equalTo(32) }
        return chip_Posture
    }

    /// 构建表单卡片（三个输入框 + 注册按钮 + 协议）
    /// - Parameters: 无
    /// - Returns: UIView - 表单卡片
    /// - Throws: 无
    private func buildFormCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        card_Posture.layer.cornerRadius = 44
        card_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card_Posture.layer.shadowColor  = UIColor.black.withAlphaComponent(0.18).cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 30
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: -12)

        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 3

        // 标题
        let sectionLabel_Posture = UILabel()
        sectionLabel_Posture.text = "Create Account"
        sectionLabel_Posture.font = .systemFont(ofSize: 24, weight: .heavy)
        sectionLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 步骤说明
        let stepLabel_Posture = UILabel()
        stepLabel_Posture.text = "Fill in the details below to get started."
        stepLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        stepLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 输入行
        let nameRow_Posture    = buildInputRow_Posture(icon: "person.fill",     iconColor: ColorConfig_Posture.accentFuchsia_Posture, field: nameField_Posture,     placeholder: "Username")
        let passwordRow_Posture = buildInputRow_Posture(icon: "lock.fill",       iconColor: ColorConfig_Posture.accentCoral_Posture,   field: passwordField_Posture,  placeholder: "Password",         secure: true)
        let confirmRow_Posture  = buildInputRow_Posture(icon: "lock.rotation",   iconColor: ColorConfig_Posture.accentAmber_Posture,   field: confirmField_Posture,   placeholder: "Confirm Password", secure: true)

        // 注册按钮
        let registerBtn_Posture = buildGradientButton_Posture(
            title: "Create Account",
            icon: "sparkles",
            colors: [ColorConfig_Posture.accentCoral_Posture, ColorConfig_Posture.accentFuchsia_Posture]
        )
        if let btn_Posture = registerBtn_Posture.subviews.first as? UIButton {
            btn_Posture.addAction(UIAction { [weak self] _ in self?.handleRegister_Posture() }, for: .touchUpInside)
        }
        registerBtn_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registerTapped_Posture)))

        // 协议
        let protocolLabel_Posture = ProtocolHelper_Posture.createProtocolTextLabel_Posture(firstContent_Posture: "terms.png", secondContent_Posture: "privacy.png", from: self)

        // 已有账号链接
        let loginLink_Posture = UIButton(type: .system)
        loginLink_Posture.setTitle("Already have an account?  Sign in →", for: .normal)
        loginLink_Posture.setTitleColor(ColorConfig_Posture.accentFuchsia_Posture, for: .normal)
        loginLink_Posture.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        loginLink_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)

        [handle_Posture, sectionLabel_Posture, stepLabel_Posture,
         nameRow_Posture, passwordRow_Posture, confirmRow_Posture,
         registerBtn_Posture, loginLink_Posture, protocolLabel_Posture
        ].forEach { card_Posture.addSubview($0) }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        sectionLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        stepLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_Posture.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        nameRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepLabel_Posture.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        passwordRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameRow_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalTo(nameRow_Posture)
        }
        confirmRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(passwordRow_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalTo(nameRow_Posture)
        }
        registerBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(confirmRow_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalTo(nameRow_Posture)
            make.height.equalTo(58)
        }
        loginLink_Posture.snp.makeConstraints { make in
            make.top.equalTo(registerBtn_Posture.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
        protocolLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(loginLink_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview().inset(22)
        }

        return card_Posture
    }

    // MARK: - 辅助视图

    private func buildInputRow_Posture(icon: String, iconColor: UIColor, field: UITextField, placeholder: String, secure: Bool = false) -> UIView {
        let container_Posture = UIView()
        container_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        container_Posture.layer.cornerRadius = 22
        container_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        container_Posture.layer.shadowOpacity = 1
        container_Posture.layer.shadowRadius  = 10
        container_Posture.layer.shadowOffset  = CGSize(width: 0, height: 5)

        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = iconColor.withAlphaComponent(0.12)
        iconBg_Posture.layer.cornerRadius = 18

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = iconColor
        iconView_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(17)
        }

        field.placeholder = placeholder
        field.font = .systemFont(ofSize: 15, weight: .semibold)
        field.textColor = ColorConfig_Posture.textPrimary_Posture
        field.backgroundColor = .clear
        field.isSecureTextEntry = secure

        container_Posture.addSubview(iconBg_Posture)
        container_Posture.addSubview(field)

        iconBg_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        field.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview()
        }
        container_Posture.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        return container_Posture
    }

    private func buildGradientButton_Posture(title: String, icon: String, colors: [UIColor]) -> UIView {
        let container_Posture = UIView()
        container_Posture.layer.cornerRadius = 29
        container_Posture.clipsToBounds = true

        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = colors.map { $0.cgColor }
        grad_Posture.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Posture.endPoint   = CGPoint(x: 1, y: 0.5)
        container_Posture.layer.insertSublayer(grad_Posture, at: 0)

        let btn_Posture = UIButton(type: .system)
        btn_Posture.setTitle("  \(title)", for: .normal)
        btn_Posture.setImage(UIImage(systemName: icon), for: .normal)
        btn_Posture.tintColor = .white
        btn_Posture.setTitleColor(.white, for: .normal)
        btn_Posture.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        container_Posture.addSubview(btn_Posture)
        btn_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        DispatchQueue.main.async { grad_Posture.frame = container_Posture.bounds }
        return container_Posture
    }

    private func buildCircleIconButton_Posture(icon: String, tint: UIColor, bgAlpha: CGFloat) -> UIButton {
        let btn_Posture = UIButton(type: .system)
        btn_Posture.setImage(UIImage(systemName: icon), for: .normal)
        btn_Posture.tintColor = tint
        btn_Posture.backgroundColor = UIColor.white.withAlphaComponent(bgAlpha)
        btn_Posture.layer.cornerRadius = 22
        return btn_Posture
    }

    // MARK: - 事件

    @objc private func dismissKeyboard_Posture() { view.endEditing(true) }

    /// 注册按钮点击（通过手势触发，兼容渐变容器）
    @objc private func registerTapped_Posture() { handleRegister_Posture() }

    /// 执行注册
    private func handleRegister_Posture() {
        let name_Posture     = (nameField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password_Posture = (passwordField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let confirm_Posture  = (confirmField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name_Posture.isEmpty, !password_Posture.isEmpty else {
            Utils_Posture.showWarning_Posture(message_Posture: "Username and password are required.")
            return
        }
        guard password_Posture == confirm_Posture else {
            Utils_Posture.showWarning_Posture(message_Posture: "Passwords do not match.")
            return
        }
        UserViewModel_Posture.shared_Posture.loginById_Posture(userId_posture: abs(name_Posture.hashValue % 9000) + 100)
    }
}
