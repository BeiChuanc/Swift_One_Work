import Foundation
import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页面
/// 核心作用：提供现代化、简洁的睡眠主题注册 UI
/// 设计思路：沿用登录页深色渐变星空风格，毛玻璃卡片 + 三栏输入框 + 主渐变注册按钮
/// 关键方法：
///   - setupBackground_Doze: 搭建渐变背景
///   - setupUI_Doze: 搭建页面结构
///   - bindLogic_Doze: 绑定业务逻辑回调
class Register_Doze: UIViewController {

    // MARK: - 业务逻辑

    /// 注册逻辑控制器
    private let logic_Doze = RegisterLogic_Doze()

    // MARK: - 背景层

    /// 深色渐变背景图层
    private let gradientLayer_Doze = CAGradientLayer()

    // MARK: - 装饰元素

    /// 顶部装饰图标（睡眠主题）
    private let decorIcon_Doze: UIImageView = {
        let iv_Doze = UIImageView()
        iv_Doze.image = UIImage(systemName: "sparkles")
        iv_Doze.tintColor = UIColor(white: 1.0, alpha: 0.85)
        iv_Doze.contentMode = .scaleAspectFit
        return iv_Doze
    }()

    /// 页面主标题
    private let titleLabel_Doze: UILabel = {
        let lbl_Doze = UILabel()
        lbl_Doze.text = "Create Account"
        lbl_Doze.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        lbl_Doze.textColor = .white
        lbl_Doze.textAlignment = .center
        return lbl_Doze
    }()

    /// 副标题
    private let subtitleLabel_Doze: UILabel = {
        let lbl_Doze = UILabel()
        lbl_Doze.text = "Join the dream community"
        lbl_Doze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Doze.textColor = UIColor(white: 1.0, alpha: 0.55)
        lbl_Doze.textAlignment = .center
        return lbl_Doze
    }()

    // MARK: - 星星粒子容器

    /// 浮动星星容器
    private let starsContainer_Doze = UIView()

    // MARK: - 输入卡片（毛玻璃）

    /// 毛玻璃背景卡片
    private let cardView_Doze: UIVisualEffectView = {
        let blur_Doze = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let v_Doze = UIVisualEffectView(effect: blur_Doze)
        v_Doze.layer.cornerRadius = 28
        v_Doze.layer.masksToBounds = true
        return v_Doze
    }()

    // MARK: - 输入框

    /// 用户名输入框
    private let usernameContainer_Doze = InputFieldContainer_Doze(
        icon_Doze: "person.fill",
        placeholder_Doze: "Username"
    )

    /// 密码输入框
    private let passwordContainer_Doze = InputFieldContainer_Doze(
        icon_Doze: "lock.fill",
        placeholder_Doze: "Password",
        isSecure_Doze: true
    )

    /// 确认密码输入框
    private let confirmPasswordContainer_Doze = InputFieldContainer_Doze(
        icon_Doze: "lock.rotation",
        placeholder_Doze: "Confirm Password",
        isSecure_Doze: true
    )

    // MARK: - 注册按钮

    /// 主注册按钮
    private let registerButton_Doze: UIButton = {
        let btn_Doze = UIButton(type: .custom)
        btn_Doze.setTitle("Create Account", for: .normal)
        btn_Doze.setTitleColor(.white, for: .normal)
        btn_Doze.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Doze.layer.cornerRadius = 25
        btn_Doze.layer.masksToBounds = true
        return btn_Doze
    }()

    /// 注册按钮渐变图层
    private let registerGradient_Doze = CAGradientLayer()

    // MARK: - 返回按钮

    /// 左上角返回按钮
    private let backButton_Doze: UIButton = {
        let btn_Doze = UIButton(type: .custom)
        let cfg_Doze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_Doze.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Doze), for: .normal)
        btn_Doze.tintColor = UIColor(white: 1.0, alpha: 0.8)
        btn_Doze.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        btn_Doze.layer.cornerRadius = 18
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

    // MARK: - 动画标志

    /// 是否已执行过进场动画（避免重复触发）
    private var hasAnimatedEntrance_Doze = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
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
        gradientLayer_Doze.frame = view.bounds
        registerGradient_Doze.frame = registerButton_Doze.bounds
    }

    // MARK: - 背景搭建

    /// 设置深色渐变背景（与登录页保持风格统一）
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
        // 星星容器
        view.addSubview(starsContainer_Doze)
        starsContainer_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupStars_Doze()

        // 返回按钮
        view.addSubview(backButton_Doze)
        backButton_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.width.height.equalTo(36)
        }
        backButton_Doze.addTarget(self, action: #selector(backTapped_Doze), for: .touchUpInside)

        // 装饰图标
        view.addSubview(decorIcon_Doze)
        decorIcon_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            make.width.height.equalTo(56)
        }

        // 主标题
        view.addSubview(titleLabel_Doze)
        titleLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(decorIcon_Doze.snp.bottom).offset(12)
        }

        // 副标题
        view.addSubview(subtitleLabel_Doze)
        subtitleLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel_Doze.snp.bottom).offset(6)
        }

        // 卡片
        view.addSubview(cardView_Doze)
        cardView_Doze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(subtitleLabel_Doze.snp.bottom).offset(36)
        }
        setupCard_Doze()

        // 协议
        view.addSubview(protocolLabel_Doze)
        protocolLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
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

        content_Doze.addSubview(confirmPasswordContainer_Doze)
        confirmPasswordContainer_Doze.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        // 注册按钮
        setupRegisterButton_Doze()
        content_Doze.addSubview(registerButton_Doze)
        registerButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordContainer_Doze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    /// 配置注册按钮渐变
    private func setupRegisterButton_Doze() {
        registerGradient_Doze.colors = [
            ColorConfig_Doze.secondaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor
        ]
        registerGradient_Doze.startPoint = CGPoint(x: 0, y: 0)
        registerGradient_Doze.endPoint = CGPoint(x: 1, y: 0)
        registerButton_Doze.layer.insertSublayer(registerGradient_Doze, at: 0)
        registerButton_Doze.addTarget(self, action: #selector(registerTapped_Doze), for: .touchUpInside)
    }

    // MARK: - 星星粒子

    /// 在容器中随机生成静态星星
    private func setupStars_Doze() {
        let screenW_Doze = UIScreen.main.bounds.width
        let screenH_Doze = UIScreen.main.bounds.height

        for _ in 0..<70 {
            let star_Doze = UIView()
            let size_Doze = CGFloat.random(in: 1.5...3.0)
            star_Doze.frame = CGRect(
                x: CGFloat.random(in: 0...screenW_Doze),
                y: CGFloat.random(in: 0...screenH_Doze),
                width: size_Doze,
                height: size_Doze
            )
            star_Doze.layer.cornerRadius = size_Doze / 2
            star_Doze.backgroundColor = UIColor(
                white: 1.0,
                alpha: CGFloat.random(in: 0.15...0.7)
            )
            starsContainer_Doze.addSubview(star_Doze)
        }
    }

    /// 星星闪烁动画
    private func animateStars_Doze() {
        for (index_Doze, star_Doze) in starsContainer_Doze.subviews.enumerated() {
            let delay_Doze = Double(index_Doze) * 0.06
            UIView.animate(
                withDuration: Double.random(in: 1.5...3.0),
                delay: delay_Doze,
                options: [.autoreverse, .repeat, .allowUserInteraction],
                animations: {
                    star_Doze.alpha = CGFloat.random(in: 0.08...0.45)
                }
            )
        }
    }

    // MARK: - 进场动画

    /// 页面元素进场动画
    private func animateEntrance_Doze() {
        let elements_Doze: [UIView] = [
            backButton_Doze, decorIcon_Doze, titleLabel_Doze,
            subtitleLabel_Doze, cardView_Doze, protocolLabel_Doze
        ]
        elements_Doze.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 25)
        }
        for (i_Doze, element_Doze) in elements_Doze.enumerated() {
            UIView.animate(
                withDuration: 0.55,
                delay: Double(i_Doze) * 0.07,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.4,
                options: [],
                animations: {
                    element_Doze.alpha = 1
                    element_Doze.transform = .identity
                }
            )
        }
    }

    // MARK: - 绑定逻辑

    /// 绑定注册逻辑回调
    private func bindLogic_Doze() {
        logic_Doze.onRegisterSuccess_Doze = { [weak self] in
            print("✅ 注册成功回调触发")
            self?.animateButtonSuccess_Doze()
        }
        logic_Doze.onRegisterFailed_Doze = { [weak self] msg_Doze in
            print("❌ 注册失败：\(msg_Doze)")
            self?.shakeCard_Doze()
            Utils_Doze.showError_Doze(message_Doze: msg_Doze)
        }
    }

    // MARK: - 事件处理

    /// 注册按钮点击
    @objc private func registerTapped_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        view.endEditing(true)

        let username_Doze        = usernameContainer_Doze.text_Doze
        let password_Doze        = passwordContainer_Doze.text_Doze
        let confirmPassword_Doze = confirmPasswordContainer_Doze.text_Doze

        logic_Doze.register_Doze(
            username_Doze: username_Doze,
            password_Doze: password_Doze,
            confirmPassword_Doze: confirmPassword_Doze
        )
    }

    /// 返回按钮点击
    @objc private func backTapped_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        logic_Doze.goBack_Doze()
    }

    // MARK: - 动画效果

    /// 注册成功脉冲动画
    private func animateButtonSuccess_Doze() {
        UIView.animate(withDuration: 0.15, animations: {
            self.registerButton_Doze.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.registerButton_Doze.transform = .identity
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
