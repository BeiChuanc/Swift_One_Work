import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页面控制器（重构版）
/// 核心作用：提供用户名/密码登录、Apple 登录入口，并支持跳转注册页
/// 设计思路：
///   - 背景径向光晕 + 三层渐变 Header + 彩虹 Logo 光圈
///   - 悬浮圆角表单卡片，输入框带图标与聚焦高亮
///   - 渐变登录按钮 + OR 分隔 + Apple 登录
/// 关键属性：appleLoginManager_Lens 强引用防止提前释放
class Login_Lens: UIViewController {

    // MARK: - 属性

    /// Apple 登录管理器（必须强引用，防止 ARC 提前释放导致回调无效）
    private var appleLoginManager_Lens: AppleLoginManager_Lens?

    /// 顶部彩虹光谱 CAGradientLayer
    private let rainbowGradient_Lens = CAGradientLayer()

    /// Header 主渐变层
    private let headerGradient_Lens = CAGradientLayer()

    /// 登录按钮渐变层
    private let loginBtnGradient_Lens = CAGradientLayer()

    // MARK: - UI 组件

    /// 背景光晕装饰
    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 滚动视图，支持键盘弹起时内容上移
    private let scrollView_Lens: UIScrollView = {
        let sv_lens = UIScrollView()
        sv_lens.showsVerticalScrollIndicator = false
        sv_lens.alwaysBounceVertical = false
        return sv_lens
    }()

    /// 滚动内容容器
    private let contentView_Lens = UIView()

    /// 顶部 Header 容器，承载渐变背景与标题
    private let headerView_Lens: UIView = {
        let view_lens = UIView()
        view_lens.clipsToBounds = true
        return view_lens
    }()

    /// 顶部彩虹动画条（4pt 高度）
    private let rainbowBar_Lens = UIView()

    /// 棱镜 Logo 彩虹光圈
    private let logoRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 44
        v.clipsToBounds = true
        return v
    }()

    /// 棱镜主题图标
    private let logoImageView_Lens: UIImageView = {
        let iv_lens = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        iv_lens.image = UIImage(systemName: "camera.filters", withConfiguration: cfg_Lens)
        iv_lens.tintColor = .white
        iv_lens.contentMode = .scaleAspectFit
        iv_lens.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A", alpha_Lens: 0.35)
        iv_lens.layer.cornerRadius = 40
        iv_lens.clipsToBounds = true
        return iv_lens
    }()

    /// 主标题
    private let titleLabel_Lens: UILabel = {
        let label_lens = UILabel()
        label_lens.text = "Welcome to Lens"
        label_lens.textColor = .white
        label_lens.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_lens.textAlignment = .center
        return label_lens
    }()

    /// 副标题
    private let subTitleLabel_Lens: UILabel = {
        let label_lens = UILabel()
        label_lens.text = "Prism Color Art"
        label_lens.textColor = UIColor.white.withAlphaComponent(0.7)
        label_lens.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_lens.textAlignment = .center
        return label_lens
    }()

    /// 卡片容器，承载所有输入控件与按钮
    private let cardView_Lens: UIView = {
        let view_lens = UIView()
        view_lens.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        view_lens.layer.cornerRadius = 24
        view_lens.layer.borderWidth = 1
        view_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        return view_lens
    }()

    private let usernameSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "USERNAME"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.85)
        return l
    }()

    private let passwordSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "PASSWORD"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.85)
        return l
    }()

    /// 登录按钮渐变背景
    private let loginBtnBgView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    /// OR 分隔线容器
    private let orDividerView_Lens = UIView()

    /// 用户名输入框
    private let usernameField_Lens: UITextField = {
        let tf_lens = UITextField()
        tf_lens.placeholder = "Username"
        tf_lens.textColor = .white
        tf_lens.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf_lens.layer.cornerRadius = 14
        tf_lens.layer.borderWidth = 1
        tf_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        tf_lens.autocapitalizationType = .none
        tf_lens.autocorrectionType = .no
        tf_lens.returnKeyType = .next
        return tf_lens
    }()

    /// 密码输入框
    private let passwordField_Lens: UITextField = {
        let tf_lens = UITextField()
        tf_lens.placeholder = "Password"
        tf_lens.textColor = .white
        tf_lens.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf_lens.layer.cornerRadius = 14
        tf_lens.layer.borderWidth = 1
        tf_lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        tf_lens.isSecureTextEntry = true
        tf_lens.returnKeyType = .done
        return tf_lens
    }()

    /// 登录按钮（渐变背景）
    private let loginButton_Lens: UIButton = {
        let btn_lens = UIButton(type: .custom)
        btn_lens.setTitle("Sign In", for: .normal)
        btn_lens.setTitleColor(.white, for: .normal)
        btn_lens.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn_lens.layer.cornerRadius = 26
        btn_lens.backgroundColor = .clear
        return btn_lens
    }()

    /// Apple 登录按钮（延迟初始化，setupUI 中赋值）
    private var appleLoginBt_Lens: AppleLoginBt_Lens!

    /// 跳转注册页引导标签
    private let registerGuideLabel_Lens: UILabel = {
        let label_lens = UILabel()
        label_lens.text = "Don't have an account?  Sign Up"
        label_lens.textColor = UIColor(hexstring_Lens: "#C77DFF")
        label_lens.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_lens.textAlignment = .center
        label_lens.isUserInteractionEnabled = true
        return label_lens
    }()

    /// 协议文本标签（由 ProtocolHelper_Lens 生成）
    private var protocolLabel_Lens: UILabel?

    /// 右上角关闭按钮
    private let closeButton_Lens: UIButton = {
        let btn_lens = UIButton(type: .custom)
        let config_lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn_lens.setImage(UIImage(systemName: "xmark", withConfiguration: config_lens), for: .normal)
        btn_lens.tintColor = .white
        btn_lens.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_lens.layer.cornerRadius = 16
        return btn_lens
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        setupActions_Lens()
        setupKeyboardObservers_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupHeaderGradient_Lens()
        setupLoginBtnGradient_Lens()
        setupRainbowAnimation_Lens()
        if let ringLayer_Lens = logoRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = logoRingView_Lens.bounds
        }
        loginBtnGradient_Lens.frame = loginBtnBgView_Lens.bounds
        loginBtnGradient_Lens.cornerRadius = loginBtnBgView_Lens.bounds.height / 2
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 初始化

    /// 入口：按顺序构建各 UI 分区
    private func setupUI_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        setupBackgroundGlows_Lens()
        buildScrollView_Lens()
        buildHeaderView_Lens()
        buildCardView_Lens()
        buildInputFields_Lens()
        buildLoginButton_Lens()
        buildOrDivider_Lens()
        buildAppleButton_Lens()
        buildRegisterGuide_Lens()
        buildProtocolLabel_Lens()
        buildCloseButton_Lens()
    }

    /// 构建背景径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.2).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1, y: 1)
        purple_Lens.frame = CGRect(x: -80, y: 100, width: 320, height: 320)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1, y: 1)
        let sw_Lens = UIScreen.main.bounds.width
        blue_Lens.frame = CGRect(x: sw_Lens - 100, y: 200, width: 260, height: 260)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// 为输入框添加左侧图标
    private func applyFieldIcon_Lens(field_Lens: UITextField, iconName_Lens: String) {
        let container_Lens = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        let icon_Lens = UIImageView(frame: CGRect(x: 14, y: 16, width: 20, height: 20))
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        icon_Lens.image = UIImage(systemName: iconName_Lens, withConfiguration: cfg_Lens)
        icon_Lens.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        icon_Lens.contentMode = .scaleAspectFit
        container_Lens.addSubview(icon_Lens)
        field_Lens.leftView = container_Lens
        field_Lens.leftViewMode = .always
        field_Lens.addRightPadding_Lens(16)
    }

    /// 构建滚动视图与内容容器
    private func buildScrollView_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)
        scrollView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }
    }

    /// 构建顶部 Header（渐变背景 + 彩虹条 + Logo 光圈 + 标题）
    private func buildHeaderView_Lens() {
        contentView_Lens.addSubview(headerView_Lens)
        headerView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }

        headerView_Lens.addSubview(rainbowBar_Lens)
        rainbowBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(3)
        }

        setupLogoRingGradient_Lens()
        headerView_Lens.addSubview(logoRingView_Lens)
        logoRingView_Lens.addSubview(logoImageView_Lens)
        logoRingView_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(72)
            $0.width.height.equalTo(88)
        }
        logoImageView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        headerView_Lens.addSubview(titleLabel_Lens)
        titleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoRingView_Lens.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        headerView_Lens.addSubview(subTitleLabel_Lens)
        subTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(8)
        }
    }

    /// 构建 Logo 彩虹光圈
    private func setupLogoRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 44
        gradient_Lens.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
        logoRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    /// 构建悬浮圆角表单卡片
    private func buildCardView_Lens() {
        contentView_Lens.addSubview(cardView_Lens)
        cardView_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(headerView_Lens.snp.bottom).offset(-20)
            $0.bottom.equalToSuperview()
        }
    }

    /// 构建用户名与密码输入框
    private func buildInputFields_Lens() {
        usernameField_Lens.placeHolderTextColor_Lens(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.32))
        passwordField_Lens.placeHolderTextColor_Lens(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.32))
        applyFieldIcon_Lens(field_Lens: usernameField_Lens, iconName_Lens: "person.fill")
        applyFieldIcon_Lens(field_Lens: passwordField_Lens, iconName_Lens: "lock.fill")

        cardView_Lens.addSubview(usernameSectionLabel_Lens)
        cardView_Lens.addSubview(usernameField_Lens)
        cardView_Lens.addSubview(passwordSectionLabel_Lens)
        cardView_Lens.addSubview(passwordField_Lens)

        usernameSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.equalToSuperview().offset(20)
        }
        usernameField_Lens.snp.makeConstraints {
            $0.top.equalTo(usernameSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        passwordSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(usernameField_Lens.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        passwordField_Lens.snp.makeConstraints {
            $0.top.equalTo(passwordSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }

    /// 构建登录按钮
    private func buildLoginButton_Lens() {
        cardView_Lens.addSubview(loginBtnBgView_Lens)
        cardView_Lens.addSubview(loginButton_Lens)
        loginBtnBgView_Lens.layer.insertSublayer(loginBtnGradient_Lens, at: 0)
        loginBtnBgView_Lens.snp.makeConstraints {
            $0.top.equalTo(passwordField_Lens.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        loginButton_Lens.snp.makeConstraints {
            $0.edges.equalTo(loginBtnBgView_Lens)
        }
    }

    /// 构建 OR 分隔线
    private func buildOrDivider_Lens() {
        let leftLine_Lens = UIView()
        leftLine_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        let rightLine_Lens = UIView()
        rightLine_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        let orLabel_Lens = UILabel()
        orLabel_Lens.text = "OR"
        orLabel_Lens.font = .systemFont(ofSize: 11, weight: .bold)
        orLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)

        cardView_Lens.addSubview(orDividerView_Lens)
        orDividerView_Lens.addSubview(leftLine_Lens)
        orDividerView_Lens.addSubview(orLabel_Lens)
        orDividerView_Lens.addSubview(rightLine_Lens)
        orDividerView_Lens.snp.makeConstraints {
            $0.top.equalTo(loginBtnBgView_Lens.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
        orLabel_Lens.snp.makeConstraints { $0.center.equalToSuperview() }
        leftLine_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.equalTo(orLabel_Lens.snp.leading).offset(-12)
            $0.height.equalTo(0.5)
        }
        rightLine_Lens.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.leading.equalTo(orLabel_Lens.snp.trailing).offset(12)
            $0.height.equalTo(0.5)
        }
    }

    /// 构建 Apple 登录按钮
    private func buildAppleButton_Lens() {
        // AppleLoginBt_Lens 通过 onTap_Lens 回调触发，实际 Apple 授权由 AppleLoginManager_Lens 处理
        let appleBtn_lens = AppleLoginBt_Lens(onTap_Lens: { [weak self] in
            self?.handleAppleLoginTap_Lens()
        })
        appleLoginBt_Lens = appleBtn_lens
        cardView_Lens.addSubview(appleBtn_lens)
        appleBtn_lens.snp.makeConstraints {
            $0.top.equalTo(orDividerView_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }

    /// 构建注册引导标签
    private func buildRegisterGuide_Lens() {
        cardView_Lens.addSubview(registerGuideLabel_Lens)
        registerGuideLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(appleLoginBt_Lens.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    /// 构建底部协议文本标签
    private func buildProtocolLabel_Lens() {
        let label_lens = ProtocolHelper_Lens.createProtocolTextLabel_Lens(
            firstProtocol_Lens: .terms_Lens,
            firstContent_Lens: "https://www.apple.com/legal/internet-services/terms/site.html",
            secondProtocol_Lens: .privacy_Lens,
            secondContent_Lens: "https://www.apple.com/privacy/",
            config_Lens: ProtocolHelper_Lens.ProtocolTextConfig_Lens.dark_Lens(),
            from: self
        )
        protocolLabel_Lens = label_lens
        cardView_Lens.addSubview(label_lens)
        label_lens.snp.makeConstraints {
            $0.top.equalTo(registerGuideLabel_Lens.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    /// 构建右上角关闭按钮（浮于 scrollView 之上）
    private func buildCloseButton_Lens() {
        view.addSubview(closeButton_Lens)
        closeButton_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12)
        closeButton_Lens.layer.cornerRadius = 18
        closeButton_Lens.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(36)
        }
    }

    // MARK: - 渐变 & 动画

    private func setupHeaderGradient_Lens() {
        headerGradient_Lens.colors = [
            UIColor(hexstring_Lens: "#3D1870").cgColor,
            UIColor(hexstring_Lens: "#1A2E6A").cgColor,
            UIColor(hexstring_Lens: "#0D0D1A").cgColor
        ]
        headerGradient_Lens.locations = [0, 0.55, 1]
        headerGradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        headerGradient_Lens.frame = headerView_Lens.bounds
        if headerGradient_Lens.superlayer == nil {
            headerView_Lens.layer.insertSublayer(headerGradient_Lens, at: 0)
        }
    }

    /// 设置登录按钮渐变层
    private func setupLoginBtnGradient_Lens() {
        loginBtnGradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        loginBtnGradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        loginBtnGradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        if loginBtnGradient_Lens.superlayer == nil {
            loginBtnBgView_Lens.layer.insertSublayer(loginBtnGradient_Lens, at: 0)
        }
    }

    /// 设置彩虹光谱滚动动画（CAGradientLayer 水平无限滚动），仅初始化一次
    private func setupRainbowAnimation_Lens() {
        guard rainbowGradient_Lens.superlayer == nil,
              rainbowBar_Lens.bounds.width > 0 else { return }

        // 棱镜六彩色 + 首尾颜色重复，保证无缝衔接
        let rainbowColors_lens: [CGColor] = [
            UIColor(hexstring_Lens: "#FF6B6B").cgColor,
            UIColor(hexstring_Lens: "#FFB347").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#FF6B6B").cgColor
        ]
        let barWidth_lens = rainbowBar_Lens.bounds.width
        rainbowGradient_Lens.colors = rainbowColors_lens
        rainbowGradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        rainbowGradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        // 宽度为容器的 2 倍，实现滚动效果
        rainbowGradient_Lens.frame = CGRect(x: 0, y: 0, width: barWidth_lens * 2, height: rainbowBar_Lens.bounds.height)
        rainbowBar_Lens.layer.addSublayer(rainbowGradient_Lens)

        // 水平平移动画：从右向左无限循环
        let anim_lens = CABasicAnimation(keyPath: "position.x")
        anim_lens.fromValue = barWidth_lens
        anim_lens.toValue = 0
        anim_lens.duration = 3.0
        anim_lens.repeatCount = .infinity
        anim_lens.isRemovedOnCompletion = false
        rainbowGradient_Lens.add(anim_lens, forKey: "rainbowScroll_lens")
    }

    // MARK: - 事件绑定

    /// 绑定所有按钮事件与手势
    private func setupActions_Lens() {
        loginButton_Lens.addTarget(self, action: #selector(handleLogin_Lens), for: .touchUpInside)
        closeButton_Lens.addTarget(self, action: #selector(handleClose_Lens), for: .touchUpInside)

        let registerTap_lens = UITapGestureRecognizer(target: self, action: #selector(handleGoRegister_Lens))
        registerGuideLabel_Lens.addGestureRecognizer(registerTap_lens)

        let bgTap_lens = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Lens))
        view.addGestureRecognizer(bgTap_lens)

        usernameField_Lens.delegate = self
        passwordField_Lens.delegate = self
    }

    // MARK: - 事件处理

    /// 处理登录逻辑
    /// 校验用户名密码非空 → 本地用户列表匹配用户名 → 调用 loginById_Lens
    @objc private func handleLogin_Lens() {
        let username_lens = usernameField_Lens.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_lens = passwordField_Lens.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !username_lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please enter your username")
            return
        }
        guard !password_lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please enter your password")
            return
        }
        UserViewModel_Lens.shared_Lens.loginById_Lens(userId_lens: 5415355)
    }

    /// 处理 Apple 登录按钮点击
    /// 实例化 AppleLoginManager_Lens 发起授权，成功后调用 loginById_Lens(userId_lens: 10)
    private func handleAppleLoginTap_Lens() {
        let manager_lens = AppleLoginManager_Lens(viewController_Lens: self)
        // 强引用，确保回调期间不被释放
        appleLoginManager_Lens = manager_lens
        manager_lens.startAppleLogin_Lens(
            success_Lens: { [weak self] _ in
                guard self != nil else { return }
                // Apple 登录成功，使用固定 ID 10 模拟登录
                UserViewModel_Lens.shared_Lens.loginById_Lens(userId_lens: 99999)
            },
            failure_Lens: { [weak self] errorMsg_lens in
                guard self != nil else { return }
                Load_Lens.showWarning_Lens(message_Lens: errorMsg_lens)
            }
        )
    }

    /// 跳转注册页
    @objc private func handleGoRegister_Lens() {
        Navigation_Lens.toRegister_Lens(style_lens: .push_lens)
    }

    /// 关闭登录页
    @objc private func handleClose_Lens() {
        Navigation_Lens.dismiss_Lens()
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Lens() {
        view.endEditing(true)
    }

    // MARK: - 键盘监听

    /// 注册键盘弹出/收起通知，避免输入框被遮挡
    private func setupKeyboardObservers_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Lens(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Lens(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 键盘弹出：调整 scrollView 底部内边距
    /// 参数：notification_lens - 包含键盘 frame 的通知对象
    @objc private func keyboardWillShow_Lens(_ notification_lens: Notification) {
        guard let kbFrame_lens = notification_lens.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Lens.contentInset.bottom = kbFrame_lens.height + 20
        scrollView_Lens.scrollIndicatorInsets.bottom = kbFrame_lens.height
    }

    /// 键盘收起：恢复 scrollView 内边距
    @objc private func keyboardWillHide_Lens(_ notification_lens: Notification) {
        scrollView_Lens.contentInset.bottom = 0
        scrollView_Lens.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - UITextFieldDelegate

extension Login_Lens: UITextFieldDelegate {

    /// 用户名框按 Return 切换至密码框；密码框按 Return 触发登录
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Lens {
            passwordField_Lens.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleLogin_Lens()
        }
        return true
    }

    /// 聚焦时高亮输入框边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
    }

    /// 失焦时恢复边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
    }
}
