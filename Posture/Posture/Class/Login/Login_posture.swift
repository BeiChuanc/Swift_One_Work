import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录页面控制器
/// 核心作用：提供用户名、密码、注册跳转、Apple 登录和协议入口。
/// 设计思路：页面只做输入校验，真正登录统一调用 `UserViewModel_Posture.loginById_Posture`。
/// UI 层分为全屏渐变背景区、顶部品牌区、表单卡片区三部分，整体可滚动。
/// 关键属性：`nameField_Posture` 和 `passwordField_Posture` 收集输入，`appleManager_Posture` 保持 Apple 登录管理器生命周期。
/// 关键方法：`handleLogin_Posture()` 完成空值校验并登录。
@MainActor
class Login_Posture: UIViewController {

    // MARK: - 属性

    private let nameField_Posture     = UITextField()
    private let passwordField_Posture = UITextField()
    private var appleManager_Posture: AppleLoginManager_Posture?

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

    /// 搭建登录页完整 UI
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

        // 关闭按钮
        let closeBtn_Posture = buildCircleIconButton_Posture(icon: "xmark", tint: .white, bgAlpha: 0.22)
        closeBtn_Posture.addAction(UIAction { _ in Navigation_Posture.dismiss_Posture() }, for: .touchUpInside)
        view.addSubview(closeBtn_Posture)
        closeBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().inset(18)
            make.width.height.equalTo(44)
        }

        // 品牌区
        let brandSection_Posture = buildBrandSection_Posture()
        let formCard_Posture     = buildFormCard_Posture()

        contentView_Posture.addSubview(brandSection_Posture)
        contentView_Posture.addSubview(formCard_Posture)

        brandSection_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        formCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(brandSection_Posture.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 区块构建

    /// 搭建全屏渐变背景
    private func setupFullGradientBg_Posture() {
        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            ColorConfig_Posture.accentIndigo_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor,
            ColorConfig_Posture.backgroundPrimary_Posture.cgColor
        ]
        grad_Posture.locations = [0, 0.3, 0.55, 1.0]
        grad_Posture.startPoint = CGPoint(x: 0.2, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 0.8, y: 1)
        grad_Posture.frame = UIScreen.main.bounds
        view.layer.insertSublayer(grad_Posture, at: 0)

        // 装饰泡泡
        let bubbles_Posture: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (120, -40, 30, 0.12), (80, -20, 180, 0.09), (60, 200, 60, 0.08)
        ]
        bubbles_Posture.forEach { cfg_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = UIColor.white.withAlphaComponent(cfg_Posture.3)
            blob_Posture.layer.cornerRadius = cfg_Posture.0 / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 1)
            blob_Posture.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(cfg_Posture.1)
                make.top.equalToSuperview().offset(cfg_Posture.2)
                make.width.height.equalTo(cfg_Posture.0)
            }
        }
    }

    /// 构建顶部品牌区（App 图标 + 标题 + 副标题）
    /// - Parameters: 无
    /// - Returns: UIView - 品牌区视图
    /// - Throws: 无
    private func buildBrandSection_Posture() -> UIView {
        let container_Posture = UIView()

        // App 图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconBg_Posture.layer.cornerRadius = 32

        let iconView_Posture = UIImageView(image: UIImage(systemName: "figure.core.training"))
        iconView_Posture.tintColor = .white
        iconView_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }

        let appName_Posture = UILabel()
        appName_Posture.text = "Posture"
        appName_Posture.font = .systemFont(ofSize: 13, weight: .heavy)
        appName_Posture.textColor = UIColor.white.withAlphaComponent(0.7)
        appName_Posture.textAlignment = .center

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Welcome Back"
        titleLabel_Posture.font = .systemFont(ofSize: 36, weight: .heavy)
        titleLabel_Posture.textColor = .white
        titleLabel_Posture.textAlignment = .center

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "Keep your posture journey moving."
        subtitleLabel_Posture.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitleLabel_Posture.textAlignment = .center

        container_Posture.addSubview(iconBg_Posture)
        container_Posture.addSubview(appName_Posture)
        container_Posture.addSubview(titleLabel_Posture)
        container_Posture.addSubview(subtitleLabel_Posture)

        let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 70)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        appName_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(appName_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }

        return container_Posture
    }

    /// 构建表单卡片（输入区 + 按钮 + 协议）
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

        // 拖动把手
        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 3

        // 输入行
        let nameRow_Posture    = buildInputRow_Posture(icon: "person.fill",    iconColor: ColorConfig_Posture.accentIndigo_Posture, field: nameField_Posture,     placeholder: "Username")
        let passwordRow_Posture = buildInputRow_Posture(icon: "lock.fill",      iconColor: ColorConfig_Posture.accentTeal_Posture,   field: passwordField_Posture,  placeholder: "Password", secure: true)

        // 登录按钮
        let loginBtn_Posture = buildGradientButton_Posture(
            title: "Sign In",
            icon: "arrow.right.circle.fill",
            colors: [ColorConfig_Posture.accentIndigo_Posture, ColorConfig_Posture.primaryGradientStart_Posture]
        )
        // buildGradientButton_Posture 返回 UIView 容器，内层 UIButton 才支持 addAction
        loginBtn_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginTapped_Posture)))

        // 注册引导
        let registerBtn_Posture = UIButton(type: .system)
        registerBtn_Posture.setTitle("No account?  Create one →", for: .normal)
        registerBtn_Posture.setTitleColor(ColorConfig_Posture.accentIndigo_Posture, for: .normal)
        registerBtn_Posture.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        registerBtn_Posture.addAction(UIAction { _ in Navigation_Posture.toRegister_Posture(style_posture: .push_posture) }, for: .touchUpInside)

        // 分割线
        let orView_Posture = buildOrDivider_Posture()

        // Apple 登录
        let appleBtn_Posture = AppleLoginBt_Posture { [weak self] in self?.handleAppleLogin_Posture() }

        // 协议
        let protocolLabel_Posture = ProtocolHelper_Posture.createProtocolTextLabel_Posture(firstContent_Posture: "terms.png", secondContent_Posture: "privacy.png", from: self)

        [handle_Posture, nameRow_Posture, passwordRow_Posture, loginBtn_Posture,
         registerBtn_Posture, orView_Posture, appleBtn_Posture, protocolLabel_Posture
        ].forEach { card_Posture.addSubview($0) }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        nameRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        passwordRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameRow_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalTo(nameRow_Posture)
        }
        loginBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(passwordRow_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalTo(nameRow_Posture)
            make.height.equalTo(58)
        }
        registerBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(loginBtn_Posture.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
        orView_Posture.snp.makeConstraints { make in
            make.top.equalTo(registerBtn_Posture.snp.bottom).offset(18)
            make.leading.trailing.equalTo(nameRow_Posture)
            make.height.equalTo(20)
        }
        appleBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(orView_Posture.snp.bottom).offset(18)
            make.leading.trailing.equalTo(nameRow_Posture)
            make.height.equalTo(54)
        }
        protocolLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_Posture.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(22)
        }

        return card_Posture
    }

    // MARK: - 辅助视图

    /// 构建带图标标签的输入行
    /// - Parameters:
    ///   - icon: SF Symbols 图标名
    ///   - iconColor: 图标颜色
    ///   - field: 输入框
    ///   - placeholder: 占位文本
    ///   - secure: 是否密码
    /// - Returns: UIView - 输入行
    /// - Throws: 无
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

    /// 构建 OR 分割线
    private func buildOrDivider_Posture() -> UIView {
        let container_Posture = UIView()
        let leftLine_Posture  = UIView()
        let rightLine_Posture = UIView()
        let orLabel_Posture   = UILabel()

        leftLine_Posture.backgroundColor  = ColorConfig_Posture.divider_Posture
        rightLine_Posture.backgroundColor = ColorConfig_Posture.divider_Posture
        orLabel_Posture.text = "or continue with"
        orLabel_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        orLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        orLabel_Posture.textAlignment = .center

        container_Posture.addSubview(leftLine_Posture)
        container_Posture.addSubview(orLabel_Posture)
        container_Posture.addSubview(rightLine_Posture)

        orLabel_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        leftLine_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(orLabel_Posture.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        rightLine_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(orLabel_Posture.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        return container_Posture
    }

    /// 构建渐变填充按钮
    private func buildGradientButton_Posture(title: String, icon: String, colors: [UIColor]) -> UIView {
        let container_Posture = UIView()
        container_Posture.layer.cornerRadius = 29
        container_Posture.clipsToBounds = true
        container_Posture.layer.shadowColor  = colors.first?.withAlphaComponent(0.4).cgColor ?? UIColor.clear.cgColor
        container_Posture.layer.shadowOpacity = 1
        container_Posture.layer.shadowRadius  = 16
        container_Posture.layer.shadowOffset  = CGSize(width: 0, height: 8)

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
        // 内层 UIButton 仅作视觉展示，不拦截触摸，由容器手势识别器处理点击
        btn_Posture.isUserInteractionEnabled = false
        container_Posture.addSubview(btn_Posture)
        btn_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        DispatchQueue.main.async {
            grad_Posture.frame = container_Posture.bounds
        }

        return container_Posture
    }

    /// 构建圆形图标按钮
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

    /// 登录按钮点击（通过手势触发，兼容渐变 UIView 容器）
    @objc private func loginTapped_Posture() { handleLogin_Posture() }

    /// 执行登录
    private func handleLogin_Posture() {
        let name_Posture     = (nameField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password_Posture = (passwordField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name_Posture.isEmpty, !password_Posture.isEmpty else {
            Utils_Posture.showWarning_Posture(message_Posture: "Username and password are required.")
            return
        }
        UserViewModel_Posture.shared_Posture.loginById_Posture(userId_posture: 88215)
    }

    /// 执行 Apple 登录
    private func handleAppleLogin_Posture() {
        appleManager_Posture = AppleLoginManager_Posture(viewController_Posture: self)
        appleManager_Posture?.startAppleLogin_Posture(success_Posture: { account_Posture in
            UserViewModel_Posture.shared_Posture.loginById_Posture(userId_posture: 9999)
        }, failure_Posture: { message_Posture in
            Utils_Posture.showError_Posture(message_Posture: message_Posture)
        })
    }
}
