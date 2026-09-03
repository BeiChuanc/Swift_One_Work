import Foundation
import UIKit
import SnapKit

// MARK: - 登录页视图控制器

/// 登录页视图控制器
/// 功能：用户名 + 密码登录、Apple 登录、协议展示；跳转注册页
/// 设计：顶部渐变装饰区（Logo + 装饰气泡）+ 精美表单卡片 + 渐变登录按钮 + 进场动画
/// 逻辑：登录仅调用 UserViewModel 的 loginById_Maki 方法
class Login_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
    }

    // MARK: - UI 属性 / 顶部装饰区

    private let topDecor_Maki = UIView()
    private let topGrad_Maki  = CAGradientLayer()

    // MARK: - UI 属性 / 表单区

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.keyboardDismissMode = .onDrag
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    /// 关闭按钮（右上角，毛玻璃风格）
    private let closeBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn_maki.tintColor = UIColor(hexstring_Maki: "#8B7355")
        btn_maki.backgroundColor = UIColor(hexstring_Maki: "#8B7355").withAlphaComponent(0.1)
        btn_maki.layer.cornerRadius = 16
        return btn_maki
    }()

    /// 用户名输入框
    private let usernameTF_Maki = LoginTextField_Maki(placeholder: "Username", icon: "person.fill")
    /// 密码输入框
    private let passwordTF_Maki = LoginTextField_Maki(placeholder: "Password", icon: "lock.fill", isSecure: true)

    /// 表单白色卡片
    private let formCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 24
        v_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_maki.layer.shadowRadius = 20
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    /// 去注册链接
    private let toRegisterBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        let attrs_maki: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hexstring_Maki: "#8B7355"),
            .font: UIFont.systemFont(ofSize: 13)
        ]
        let linkAttrs_maki: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hexstring_Maki: "#FF8C00"),
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]
        let text_maki = NSMutableAttributedString(string: "No account yet? ", attributes: attrs_maki)
        text_maki.append(NSAttributedString(string: "Sign up →", attributes: linkAttrs_maki))
        btn_maki.setAttributedTitle(text_maki, for: .normal)
        return btn_maki
    }()

    /// 登录按钮
    private let loginBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("  Log In", for: .normal)
        btn_maki.setImage(UIImage(systemName: "arrow.right.circle.fill"), for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.tintColor = .white
        btn_maki.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn_maki.layer.cornerRadius = 16
        btn_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.4).cgColor
        btn_maki.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_maki.layer.shadowRadius = 14
        btn_maki.layer.shadowOpacity = 1
        return btn_maki
    }()
    private let loginGrad_Maki = CAGradientLayer()

    /// Apple 登录管理器
    private var appleLoginBtn_Maki: AppleLoginBt_Maki?
    private var appleManager_Maki: AppleLoginManager_Maki?
    private var protocolLabel_Maki: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildDecorBackground_Maki()
        buildUI_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGrad_Maki.frame = topDecor_Maki.bounds
        loginGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 48 - 36, height: 54)
    }
}

// MARK: - 背景装饰

extension Login_Maki {

    /// 构建顶部装饰渐变区（暖橙渐变 + 多个装饰气泡 + Logo + 副标题）
    private func buildDecorBackground_Maki() {
        // 全屏浅渐变背景
        let bgGrad_maki = CAGradientLayer()
        bgGrad_maki.colors = [
            UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.06).cgColor,
            UIColor(hexstring_Maki: "#FFFBF4").cgColor
        ]
        bgGrad_maki.startPoint = CGPoint(x: 0.5, y: 0)
        bgGrad_maki.endPoint   = CGPoint(x: 0.5, y: 0.55)
        bgGrad_maki.frame      = view.bounds
        view.layer.insertSublayer(bgGrad_maki, at: 0)

        // 装饰气泡（右上大泡）
        let bubble1_maki = UIView()
        bubble1_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.08)
        bubble1_maki.layer.cornerRadius = 80
        view.addSubview(bubble1_maki)
        bubble1_maki.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.trailing.equalToSuperview().offset(50)
            make.top.equalToSuperview().offset(-50)
        }

        // 装饰气泡（左下小泡）
        let bubble2_maki = UIView()
        bubble2_maki.backgroundColor = UIColor(hexstring_Maki: "#FFD700").withAlphaComponent(0.07)
        bubble2_maki.layer.cornerRadius = 55
        view.addSubview(bubble2_maki)
        bubble2_maki.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.leading.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(30)
        }

        // 右下装饰气泡（中）
        let bubble3_maki = UIView()
        bubble3_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.04)
        bubble3_maki.layer.cornerRadius = 45
        view.addSubview(bubble3_maki)
        bubble3_maki.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.trailing.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-80)
        }
    }
}

// MARK: - UI 构建

extension Login_Maki {

    private func buildUI_Maki() {
        // ScrollView 容器（避免键盘遮挡）
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }

        // 关闭按钮（在 scrollView 之后添加，确保位于最上层不被遮挡）
        closeBtn_Maki.addTarget(self, action: #selector(onClose_Maki), for: .touchUpInside)
        view.addSubview(closeBtn_Maki)
        closeBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.width.height.equalTo(32)
        }

        buildLogoArea_Maki()
        buildFormCard_Maki()
        buildBottomArea_Maki()
    }

    /// 构建 Logo + 副标题区域
    private func buildLogoArea_Maki() {
        // Logo 光晕背景
        let logoGlow_maki = UIView()
        logoGlow_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.08)
        logoGlow_maki.layer.cornerRadius = 44
        contentView_Maki.addSubview(logoGlow_maki)
        logoGlow_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(64)
            make.width.height.equalTo(88)
        }

        // Logo 内圈橙色背景
        let logoCircle_maki = UIView()
        logoCircle_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.15)
        logoCircle_maki.layer.cornerRadius = 32
        contentView_Maki.addSubview(logoCircle_maki)
        logoCircle_maki.snp.makeConstraints { make in
            make.center.equalTo(logoGlow_maki)
            make.width.height.equalTo(64)
        }

        // Logo 星号图标
        let starLb_maki = UILabel()
        starLb_maki.text = "✦"
        starLb_maki.font = .systemFont(ofSize: 28, weight: .bold)
        starLb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        starLb_maki.textAlignment = .center
        contentView_Maki.addSubview(starLb_maki)
        starLb_maki.snp.makeConstraints { make in
            make.center.equalTo(logoGlow_maki)
        }

        // Maki 品牌文字
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Maki"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 32)
            ?? .systemFont(ofSize: 32, weight: .bold)
        titleLb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        titleLb_maki.textAlignment = .center
        contentView_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.top.equalTo(logoGlow_maki.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // Slogan
        let sloganLb_maki = UILabel()
        sloganLb_maki.text = "Craft · Create · Share"
        sloganLb_maki.font = .systemFont(ofSize: 13, weight: .light)
        sloganLb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        sloganLb_maki.textAlignment = .center
        contentView_Maki.addSubview(sloganLb_maki)
        sloganLb_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 欢迎文字
        let welcomeLb_maki = UILabel()
        welcomeLb_maki.text = "Welcome back, Maker"
        welcomeLb_maki.font = .systemFont(ofSize: 15, weight: .medium)
        welcomeLb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        welcomeLb_maki.textAlignment = .center
        contentView_Maki.addSubview(welcomeLb_maki)
        welcomeLb_maki.snp.makeConstraints { make in
            make.top.equalTo(sloganLb_maki.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    /// 构建表单卡片（用户名 + 密码 + 跳注册 + 登录按钮）
    private func buildFormCard_Maki() {
        contentView_Maki.addSubview(formCard_Maki)
        formCard_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(270)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 区块小标题
        let formTitle_maki = UILabel()
        formTitle_maki.text = "Sign in to your account"
        formTitle_maki.font = .systemFont(ofSize: 13, weight: .semibold)
        formTitle_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        formCard_Maki.addSubview(formTitle_maki)
        formTitle_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        // 输入框
        formCard_Maki.addSubview(usernameTF_Maki)
        formCard_Maki.addSubview(passwordTF_Maki)
        usernameTF_Maki.snp.makeConstraints { make in
            make.top.equalTo(formTitle_maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        passwordTF_Maki.snp.makeConstraints { make in
            make.top.equalTo(usernameTF_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        // 去注册链接
        formCard_Maki.addSubview(toRegisterBtn_Maki)
        toRegisterBtn_Maki.addTarget(self, action: #selector(onToRegister_Maki), for: .touchUpInside)
        toRegisterBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(passwordTF_Maki.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 登录按钮（渐变）
        loginGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#FF8C00").cgColor,
            UIColor(hexstring_Maki: "#E8650A").cgColor
        ]
        loginGrad_Maki.startPoint   = CGPoint(x: 0, y: 0.5)
        loginGrad_Maki.endPoint     = CGPoint(x: 1, y: 0.5)
        loginGrad_Maki.cornerRadius = 16
        loginBtn_Maki.layer.insertSublayer(loginGrad_Maki, at: 0)

        formCard_Maki.addSubview(loginBtn_Maki)
        loginBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(toRegisterBtn_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-20)
        }
        loginBtn_Maki.addTarget(self, action: #selector(onLogin_Maki), for: .touchUpInside)
    }

    /// 构建底部区域（分割线 + Apple 登录 + 协议文字）
    private func buildBottomArea_Maki() {
        // 精美分割线（两侧横线 + 中间文字）
        let dividerWrap_maki = UIView()
        let leftLine_maki    = UIView()
        let rightLine_maki   = UIView()
        let orLb_maki = UILabel()
        leftLine_maki.backgroundColor  = UIColor(hexstring_Maki: "#E8DDD0")
        rightLine_maki.backgroundColor = UIColor(hexstring_Maki: "#E8DDD0")
        orLb_maki.text = "or continue with"
        orLb_maki.font = .systemFont(ofSize: 12)
        orLb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")

        dividerWrap_maki.addSubview(leftLine_maki)
        dividerWrap_maki.addSubview(orLb_maki)
        dividerWrap_maki.addSubview(rightLine_maki)
        orLb_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        leftLine_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(orLb_maki.snp.leading).offset(-8)
            make.height.equalTo(1)
        }
        rightLine_maki.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(orLb_maki.snp.trailing).offset(8)
            make.height.equalTo(1)
        }

        contentView_Maki.addSubview(dividerWrap_maki)
        dividerWrap_maki.snp.makeConstraints { make in
            make.top.equalTo(formCard_Maki.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }

        // Apple 登录按钮
        let appleBtn_maki = AppleLoginBt_Maki { [weak self] in self?.onAppleLogin_Maki() }
        appleLoginBtn_Maki = appleBtn_maki
        contentView_Maki.addSubview(appleBtn_maki)
        appleBtn_maki.snp.makeConstraints { make in
            make.top.equalTo(dividerWrap_maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        // 协议标签
        let pLabel_maki = ProtocolHelper_Maki.createProtocolTextLabel_Maki(
            firstContent_Maki: "terms.png",
            secondContent_Maki: "privacy.png",
            config_Maki: .light_Maki(),
            from: self
        )
        protocolLabel_Maki = pLabel_maki
        contentView_Maki.addSubview(pLabel_maki)
        pLabel_maki.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_maki.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
}

// MARK: - 进场动画

extension Login_Maki {

    private func playEntranceAnimation_Maki() {
        [formCard_Maki].forEach { v_maki in
            v_maki.alpha = 0
            v_maki.transform = CGAffineTransform(translationX: 0, y: 30)
            UIView.animate(
                withDuration: 0.5,
                delay: 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    v_maki.alpha = 1
                    v_maki.transform = .identity
                }
            )
        }
    }
}

// MARK: - 事件响应

extension Login_Maki {

    @objc private func onClose_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.dismiss_Maki()
    }

    @objc private func onToRegister_Maki() {
        Navigation_Maki.toRegister_Maki(style_maki: .push_maki)
    }

    @objc private func onLogin_Maki() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 按钮按压动画
        UIView.animate(withDuration: 0.1, animations: {
            self.loginBtn_Maki.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) { self.loginBtn_Maki.transform = .identity }
        })

        let username_maki = usernameTF_Maki.textValue_Maki.trimmingCharacters(in: .whitespaces)
        let password_maki = passwordTF_Maki.textValue_Maki.trimmingCharacters(in: .whitespaces)
        guard !username_maki.isEmpty, !password_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Please fill in all fields")
            return
        }
        UserViewModel_Maki.shared_Maki.loginById_Maki(userId_maki: 51588)
    }

    private func onAppleLogin_Maki() {
        let manager_maki = AppleLoginManager_Maki(viewController_Maki: self)
        appleManager_Maki = manager_maki
        manager_maki.startAppleLogin_Maki(
            success_Maki: { [weak self] _ in
                guard let self else { return }
                UserViewModel_Maki.shared_Maki.loginById_Maki(userId_maki: 999999)
            },
            failure_Maki: { msg_maki in
                Load_Maki.showWarning_Maki(message_Maki: msg_maki)
            }
        )
    }
}

// MARK: - LoginTextField_Maki（登录/注册公用输入框组件）

/// 登录/注册页通用输入框
/// 功能：带左侧彩色图标背景 + 圆角白色卡片 + 聚焦时橙色边框高亮
final class LoginTextField_Maki: UIView {

    // MARK: UI 子视图

    /// 图标背景圆角块
    private let iconBg_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.1)
        v_maki.layer.cornerRadius = 10
        return v_maki
    }()
    private let iconIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.tintColor   = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    private let tf_Maki: UITextField = {
        let tf_maki = UITextField()
        tf_maki.font                   = .systemFont(ofSize: 15)
        tf_maki.textColor              = UIColor(hexstring_Maki: "#1A0A00")
        tf_maki.autocorrectionType     = .no
        tf_maki.autocapitalizationType = .none
        return tf_maki
    }()

    var textValue_Maki: String { tf_Maki.text ?? "" }

    // MARK: 初始化

    init(placeholder: String, icon: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        iconIV_Maki.image = UIImage(systemName: icon)
        tf_Maki.placeholder = placeholder
        tf_Maki.isSecureTextEntry = isSecure
        tf_Maki.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(hexstring_Maki: "#C0A880")]
        )
        setupAppearance_Maki()
        setupLayout_Maki()
        tf_Maki.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupAppearance_Maki() {
        backgroundColor = UIColor(hexstring_Maki: "#FFF9F2")
        layer.cornerRadius = 14
        layer.borderWidth  = 1.5
        layer.borderColor  = UIColor(hexstring_Maki: "#F0D8BE").cgColor
        layer.shadowColor  = UIColor.black.withAlphaComponent(0.04).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
    }

    private func setupLayout_Maki() {
        addSubview(iconBg_Maki)
        iconBg_Maki.addSubview(iconIV_Maki)
        addSubview(tf_Maki)

        iconBg_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        iconIV_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        tf_Maki.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Maki.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-14)
            make.top.bottom.equalToSuperview()
        }
    }
}

extension LoginTextField_Maki: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.6).cgColor
            self.backgroundColor   = .white
            self.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.1).cgColor
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#F0D8BE").cgColor
            self.backgroundColor   = UIColor(hexstring_Maki: "#FFF9F2")
            self.layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        }
    }
}
