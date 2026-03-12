import Foundation
import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页面
/// 核心作用：提供现代化、有创意的睡眠主题登录 UI
/// 设计思路：全屏深色渐变背景 + 星空浮动粒子 + 月亮装饰 + 毛玻璃输入卡片
/// 关键方法：
///   - setupUI_Doze: 搭建页面结构
///   - bindLogic_Doze: 绑定业务逻辑回调
///   - animateEntrance_Doze: 进场动画
class Login_Doze: UIViewController {

    // MARK: - 业务逻辑

    /// 登录逻辑控制器
    private var logic_Doze: LoginLogic_Doze!

    // MARK: - 背景层

    /// 深色渐变背景图层
    private let gradientLayer_Doze = CAGradientLayer()

    // MARK: - 装饰元素

    /// 月亮图标（主视觉装饰）
    private let moonImageView_Doze: UIImageView = {
        let iv_Doze = UIImageView()
        iv_Doze.image = UIImage(systemName: "moon.stars.fill")
        iv_Doze.tintColor = UIColor(white: 1.0, alpha: 0.90)
        iv_Doze.contentMode = .scaleAspectFit
        return iv_Doze
    }()

    /// App 标语
    private let taglineLabel_Doze: UILabel = {
        let lbl_Doze = UILabel()
        lbl_Doze.text = "Sweet Dreams Await"
        lbl_Doze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Doze.textColor = UIColor(white: 1.0, alpha: 0.60)
        lbl_Doze.textAlignment = .center
        return lbl_Doze
    }()

    /// App 名称标题
    private let titleLabel_Doze: UILabel = {
        let lbl_Doze = UILabel()
        lbl_Doze.text = "Doze"
        lbl_Doze.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        lbl_Doze.textColor = .white
        lbl_Doze.textAlignment = .center
        return lbl_Doze
    }()

    // MARK: - 星星粒子（纯装饰）

    /// 浮动星星容器
    private let starsContainer_Doze = UIView()

    // MARK: - 输入卡片（毛玻璃效果）

    /// 毛玻璃背景卡片
    private let cardView_Doze: UIVisualEffectView = {
        let blur_Doze = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let v_Doze = UIVisualEffectView(effect: blur_Doze)
        v_Doze.layer.cornerRadius = 28
        v_Doze.layer.masksToBounds = true
        return v_Doze
    }()

    // MARK: - 用户名输入框

    /// 用户名输入容器
    private let usernameContainer_Doze = InputFieldContainer_Doze(
        icon_Doze: "person.fill",
        placeholder_Doze: "Username"
    )

    // MARK: - 密码输入框

    /// 密码输入容器（安全输入）
    private let passwordContainer_Doze = InputFieldContainer_Doze(
        icon_Doze: "lock.fill",
        placeholder_Doze: "Password",
        isSecure_Doze: true
    )

    // MARK: - 登录按钮

    /// 主登录按钮
    private let loginButton_Doze: UIButton = {
        let btn_Doze = UIButton(type: .custom)
        btn_Doze.setTitle("Sign In", for: .normal)
        btn_Doze.setTitleColor(.white, for: .normal)
        btn_Doze.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Doze.layer.cornerRadius = 25
        btn_Doze.layer.masksToBounds = true
        return btn_Doze
    }()

    /// 登录按钮渐变图层
    private let loginGradient_Doze = CAGradientLayer()

    // MARK: - Apple 登录按钮

    /// Apple 登录按钮组件
    private lazy var appleButton_Doze: AppleLoginBt_Doze = {
        return AppleLoginBt_Doze { [weak self] in
            self?.logic_Doze.loginWithApple_Doze()
        }
    }()

    // MARK: - 注册引导

    /// 是否有账号提示按钮
    private let registerPromptButton_Doze: UIButton = {
        let btn_Doze = UIButton(type: .custom)
        let attr_Doze = NSMutableAttributedString(
            string: "New here? ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor(white: 1.0, alpha: 0.55)
            ]
        )
        attr_Doze.append(NSAttributedString(
            string: "Create account",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor(white: 1.0, alpha: 0.95),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        btn_Doze.setAttributedTitle(attr_Doze, for: .normal)
        return btn_Doze
    }()

    // MARK: - 协议文本

    /// 协议 Label（懒加载，需要持有 VC 引用）
    private lazy var protocolLabel_Doze: UILabel = {
        ProtocolHelper_Doze.createProtocolTextLabel_Doze(
            firstContent_Doze: "terms.png",
            secondContent_Doze: "privacy.png",
            config_Doze: .dark_Doze(),
            from: self
        )
    }()

    // MARK: - 分隔线

    /// "or" 分隔线
    private let dividerView_Doze = OrDivider_Doze()

    // MARK: - 关闭按钮

    /// 右上角关闭按钮
    private let closeButton_Doze: UIButton = {
        let btn_Doze = UIButton(type: .custom)
        let cfg_Doze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Doze.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Doze), for: .normal)
        btn_Doze.tintColor = UIColor(white: 1.0, alpha: 0.75)
        btn_Doze.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        btn_Doze.layer.cornerRadius = 18
        return btn_Doze
    }()

    // MARK: - 动画标志

    /// 是否已执行过进场动画（避免重复触发）
    private var hasAnimatedEntrance_Doze = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        logic_Doze = LoginLogic_Doze(viewController_Doze: self)
        setupBackground_Doze()
        setupUI_Doze()
        bindLogic_Doze()
        setupKeyboardDismiss_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 仅首次出现时执行进场动画，避免返回时重复触发
        guard !hasAnimatedEntrance_Doze else { return }
        hasAnimatedEntrance_Doze = true
        animateEntrance_Doze()
        animateStars_Doze()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 背景渐变跟随视图大小更新
        gradientLayer_Doze.frame = view.bounds
        // 登录按钮渐变
        loginGradient_Doze.frame = loginButton_Doze.bounds
    }

    // MARK: - 背景搭建

    /// 设置深色渐变背景
    private func setupBackground_Doze() {
        gradientLayer_Doze.colors = [
            UIColor(hexstring_Doze: "#0D0221").cgColor,
            UIColor(hexstring_Doze: "#1A0A3B").cgColor,
            UIColor(hexstring_Doze: "#2D1558").cgColor
        ]
        gradientLayer_Doze.locations = [0, 0.5, 1]
        gradientLayer_Doze.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Doze.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer_Doze, at: 0)
    }

    // MARK: - UI 搭建

    /// 搭建完整 UI 层次
    private func setupUI_Doze() {
        // 星星容器（最底层装饰）
        view.addSubview(starsContainer_Doze)
        starsContainer_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupStars_Doze()

        // 右上角关闭按钮
        view.addSubview(closeButton_Doze)
        closeButton_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.width.height.equalTo(36)
        }
        closeButton_Doze.addTarget(self, action: #selector(closeTapped_Doze), for: .touchUpInside)

        // 月亮图标
        view.addSubview(moonImageView_Doze)
        moonImageView_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.height.equalTo(72)
        }

        // App 名称
        view.addSubview(titleLabel_Doze)
        titleLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(moonImageView_Doze.snp.bottom).offset(12)
        }

        // 标语
        view.addSubview(taglineLabel_Doze)
        taglineLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel_Doze.snp.bottom).offset(6)
        }

        // 卡片
        view.addSubview(cardView_Doze)
        cardView_Doze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(taglineLabel_Doze.snp.bottom).offset(40)
        }
        setupCard_Doze()

        // 协议
        view.addSubview(protocolLabel_Doze)
        protocolLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        // 注册引导
        view.addSubview(registerPromptButton_Doze)
        registerPromptButton_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(protocolLabel_Doze.snp.top).offset(-12)
        }
    }

    /// 搭建输入卡片内部布局
    private func setupCard_Doze() {
        let content_Doze = cardView_Doze.contentView

        content_Doze.addSubview(usernameContainer_Doze)
        usernameContainer_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        content_Doze.addSubview(passwordContainer_Doze)
        passwordContainer_Doze.snp.makeConstraints { make in
            make.top.equalTo(usernameContainer_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        // 登录按钮
        setupLoginButton_Doze()
        content_Doze.addSubview(loginButton_Doze)
        loginButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Doze.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        // 分隔线
        content_Doze.addSubview(dividerView_Doze)
        dividerView_Doze.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Doze.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }

        // Apple 登录
        content_Doze.addSubview(appleButton_Doze)
        appleButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    /// 配置登录按钮渐变
    private func setupLoginButton_Doze() {
        loginGradient_Doze.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        loginGradient_Doze.startPoint = CGPoint(x: 0, y: 0)
        loginGradient_Doze.endPoint = CGPoint(x: 1, y: 0)
        loginButton_Doze.layer.insertSublayer(loginGradient_Doze, at: 0)

        loginButton_Doze.addTarget(self, action: #selector(loginTapped_Doze), for: .touchUpInside)
        registerPromptButton_Doze.addTarget(self, action: #selector(registerTapped_Doze), for: .touchUpInside)
    }

    // MARK: - 星星粒子

    /// 在容器中随机生成静态星星
    private func setupStars_Doze() {
        let screenW_Doze = UIScreen.main.bounds.width
        let screenH_Doze = UIScreen.main.bounds.height

        for _ in 0..<80 {
            let star_Doze = UIView()
            let size_Doze = CGFloat.random(in: 1.5...3.5)
            star_Doze.frame = CGRect(
                x: CGFloat.random(in: 0...screenW_Doze),
                y: CGFloat.random(in: 0...screenH_Doze),
                width: size_Doze,
                height: size_Doze
            )
            star_Doze.layer.cornerRadius = size_Doze / 2
            star_Doze.backgroundColor = UIColor(
                white: 1.0,
                alpha: CGFloat.random(in: 0.2...0.8)
            )
            starsContainer_Doze.addSubview(star_Doze)
        }
    }

    /// 星星闪烁动画
    private func animateStars_Doze() {
        for (index_Doze, star_Doze) in starsContainer_Doze.subviews.enumerated() {
            let delay_Doze = Double(index_Doze) * 0.05
            UIView.animate(
                withDuration: Double.random(in: 1.5...3.0),
                delay: delay_Doze,
                options: [.autoreverse, .repeat, .allowUserInteraction],
                animations: {
                    star_Doze.alpha = CGFloat.random(in: 0.1...0.5)
                }
            )
        }
    }

    // MARK: - 进场动画

    /// 卡片与文字的进场动画（仅首次触发）
    private func animateEntrance_Doze() {
        let elements_Doze: [UIView] = [closeButton_Doze, moonImageView_Doze, titleLabel_Doze, taglineLabel_Doze, cardView_Doze, registerPromptButton_Doze, protocolLabel_Doze]
        elements_Doze.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 30)
        }

        for (i_Doze, element_Doze) in elements_Doze.enumerated() {
            UIView.animate(
                withDuration: 0.6,
                delay: Double(i_Doze) * 0.08,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    element_Doze.alpha = 1
                    element_Doze.transform = .identity
                }
            )
        }
    }

    // MARK: - 绑定逻辑

    /// 绑定业务逻辑回调
    private func bindLogic_Doze() {
        logic_Doze.onLoginSuccess_Doze = { [weak self] in
            // 登录成功后 UserViewModel 内部已处理跳转，此处可扩展额外 UI 反馈
            print("✅ 登录成功回调触发")
            self?.animateButtonSuccess_Doze()
        }
        logic_Doze.onLoginFailed_Doze = { [weak self] msg_Doze in
            print("❌ 登录失败：\(msg_Doze)")
            self?.shakeCard_Doze()
            Utils_Doze.showError_Doze(message_Doze: msg_Doze)
        }
    }

    // MARK: - 事件处理

    /// 登录按钮点击
    @objc private func loginTapped_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        view.endEditing(true)

        let username_Doze = usernameContainer_Doze.text_Doze
        let password_Doze = passwordContainer_Doze.text_Doze
        logic_Doze.login_Doze(username_Doze: username_Doze, password_Doze: password_Doze)
    }

    /// 关闭按钮点击（关闭登录页）
    @objc private func closeTapped_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.dismiss_Doze()
    }

    /// 注册引导点击
    @objc private func registerTapped_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        logic_Doze.goToRegister_Doze()
    }

    // MARK: - 动画效果

    /// 登录成功脉冲动画
    private func animateButtonSuccess_Doze() {
        UIView.animate(withDuration: 0.15, animations: {
            self.loginButton_Doze.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.loginButton_Doze.transform = .identity
            }
        }
    }

    /// 输入错误时卡片抖动
    private func shakeCard_Doze() {
        let animation_Doze = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_Doze.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_Doze.duration = 0.5
        animation_Doze.values = [-10, 10, -8, 8, -5, 5, 0]
        cardView_Doze.layer.add(animation_Doze, forKey: "shake")
    }

    // MARK: - 键盘处理

    /// 点击背景收起键盘
    private func setupKeyboardDismiss_Doze() {
        let tap_Doze = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Doze))
        tap_Doze.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Doze)
    }

    @objc private func dismissKeyboard_Doze() {
        view.endEditing(true)
    }
}

// MARK: - 输入框容器组件

/// 带图标的输入框容器
/// 功能：封装圆角毛玻璃背景 + 左侧图标 + UITextField
/// 参数：
///   - icon_Doze: SF Symbol 图标名
///   - placeholder_Doze: 占位符文本
///   - isSecure_Doze: 是否为密码输入
class InputFieldContainer_Doze: UIView {

    // MARK: - 属性

    /// 图标视图
    private let iconView_Doze: UIImageView = {
        let iv_Doze = UIImageView()
        iv_Doze.tintColor = UIColor(white: 1.0, alpha: 0.6)
        iv_Doze.contentMode = .scaleAspectFit
        return iv_Doze
    }()

    /// 文本输入框
    private let textField_Doze: UITextField = {
        let tf_Doze = UITextField()
        tf_Doze.textColor = .white
        tf_Doze.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf_Doze.autocorrectionType = .no
        tf_Doze.autocapitalizationType = .none
        tf_Doze.returnKeyType = .done
        return tf_Doze
    }()

    /// 密码显示切换按钮
    private lazy var eyeButton_Doze: UIButton = {
        let btn_Doze = UIButton(type: .custom)
        btn_Doze.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn_Doze.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        btn_Doze.tintColor = UIColor(white: 1.0, alpha: 0.5)
        btn_Doze.addTarget(self, action: #selector(toggleEye_Doze), for: .touchUpInside)
        return btn_Doze
    }()

    /// 当前输入的文本
    var text_Doze: String { textField_Doze.text ?? "" }

    // MARK: - 初始化

    /// 初始化输入框容器
    /// - Parameters:
    ///   - icon_Doze: 左侧 SF Symbol 图标名
    ///   - placeholder_Doze: 占位文本
    ///   - isSecure_Doze: 是否为安全输入（密码），默认 false
    init(icon_Doze: String, placeholder_Doze: String, isSecure_Doze: Bool = false) {
        super.init(frame: .zero)

        // 容器样式
        backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1.0, alpha: 0.18).cgColor

        // 图标
        iconView_Doze.image = UIImage(systemName: icon_Doze)

        // 占位符
        let attr_Doze = NSAttributedString(
            string: placeholder_Doze,
            attributes: [.foregroundColor: UIColor(white: 1.0, alpha: 0.35)]
        )
        textField_Doze.attributedPlaceholder = attr_Doze

        // 密码模式
        if isSecure_Doze {
            textField_Doze.isSecureTextEntry = true
        }

        addSubview(iconView_Doze)
        iconView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        addSubview(textField_Doze)

        if isSecure_Doze {
            addSubview(eyeButton_Doze)
            eyeButton_Doze.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-14)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(28)
            }
            textField_Doze.snp.makeConstraints { make in
                make.left.equalTo(iconView_Doze.snp.right).offset(12)
                make.right.equalTo(eyeButton_Doze.snp.left).offset(-8)
                make.top.bottom.equalToSuperview()
            }
        } else {
            textField_Doze.snp.makeConstraints { make in
                make.left.equalTo(iconView_Doze.snp.right).offset(12)
                make.right.equalToSuperview().offset(-16)
                make.top.bottom.equalToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 事件

    /// 切换密码显示/隐藏
    @objc private func toggleEye_Doze() {
        eyeButton_Doze.isSelected.toggle()
        textField_Doze.isSecureTextEntry = !eyeButton_Doze.isSelected
    }
}

// MARK: - "Or" 分隔线组件

/// 左右带横线的 "or" 分隔器
class OrDivider_Doze: UIView {

    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Doze()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 搭建分隔线 UI
    private func setupUI_Doze() {
        let leftLine_Doze = UIView()
        leftLine_Doze.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        addSubview(leftLine_Doze)

        let orLabel_Doze = UILabel()
        orLabel_Doze.text = "or"
        orLabel_Doze.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        orLabel_Doze.textColor = UIColor(white: 1.0, alpha: 0.4)
        orLabel_Doze.textAlignment = .center
        addSubview(orLabel_Doze)

        let rightLine_Doze = UIView()
        rightLine_Doze.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        addSubview(rightLine_Doze)

        orLabel_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(30)
        }
        leftLine_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(orLabel_Doze.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
        rightLine_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(orLabel_Doze.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
