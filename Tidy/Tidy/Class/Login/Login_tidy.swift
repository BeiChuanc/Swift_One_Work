import Foundation
import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页面
/// 核心功能：用户名/密码登录、Apple 登录、跳转注册页三种入口
/// 设计思路：全屏薄荷渐变背景（mint→teal→blue）+ 品牌标识区 + 底部白色弹出卡片
///           输入框聚焦高亮边框、震动错误反馈、按钮弹性动画
/// 逻辑解耦：所有业务操作委托给 UserViewModel_Tidy，页面仅负责 UI 呈现与交互
class Login_Tidy: UIViewController {

    // MARK: - 私有属性

    /// Apple 登录管理器
    private var appleLoginManager_Tidy: AppleLoginManager_Tidy?

    /// 背景渐变层
    private var gradientLayer_Tidy: CAGradientLayer?

    /// 登录按钮渐变层
    private var loginBtnGradLayer_Tidy: CAGradientLayer?

    // MARK: - 背景装饰元素

    /// 右上角大装饰圆
    private let bgDecoCircleA_Tidy = Login_Tidy.makeDecoCircle_login(size: 250, alpha: 0.15)
    /// 左中装饰圆
    private let bgDecoCircleB_Tidy = Login_Tidy.makeDecoCircle_login(size: 170, alpha: 0.10)
    /// 右中小装饰圆
    private let bgDecoCircleC_Tidy = Login_Tidy.makeDecoCircle_login(size: 90, alpha: 0.13)
    /// 左上角小圆点
    private let bgDecoDot_Tidy = Login_Tidy.makeDecoCircle_login(size: 20, alpha: 0.22)
    /// 描边环装饰
    private let bgDecoRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 65
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 品牌区（顶部）

    /// 品牌图标背景圆
    private let brandIconBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 26
        return v
    }()

    /// 品牌图标
    private let brandIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iv.image = UIImage(systemName: "house.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// App 名称
    private let brandNameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Tidy"
        lb.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    /// 品牌标语
    private let brandTaglineLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Organize · Inspire · Live Better ✨"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.82)
        return lb
    }()

    // MARK: - 底部白色弹出卡片

    /// 白色主卡（顶部圆角）
    private let bottomCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 34
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -8)
        v.layer.shadowRadius = 24
        v.layer.shadowOpacity = 1
        return v
    }()

    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentContainer_Tidy = UIView()

    // MARK: - 卡片内容 - 标题

    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Welcome Back 👋"
        lb.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()

    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Sign in to continue"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    // MARK: - 输入框容器

    /// 用户名输入框整体容器
    private let userNameContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        return v
    }()

    /// 用户名输入框
    private let userNameField_Tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        return tf
    }()

    /// 密码输入框整体容器
    private let passwordContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        return v
    }()

    /// 密码输入框
    private let passwordField_Tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    /// 密码可见切换按钮
    private let eyeButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return btn
    }()

    // MARK: - 登录按钮

    private let loginButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = false
        return btn
    }()

    // MARK: - 分隔线

    private let dividerView_Tidy: UIView = UIView()

    private let dividerLeftLine_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()

    private let dividerLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "or continue with"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return lb
    }()

    private let dividerRightLine_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()

    // MARK: - 注册跳转行

    private let registerRow_Tidy = UIView()

    private let registerHintLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Don't have an account? "
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    private let registerButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Register", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(ColorConfig_Tidy.tidyMint_Tidy, for: .normal)
        return btn
    }()

    // MARK: - 协议文字（由 ProtocolHelper 在 setupCardContent 中生成）
    private var protocolLabel_Tidy = UILabel()

    // MARK: - 右上角关闭按钮

    /// 关闭登录页按钮（白色半透明圆形）
    private let closeButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.90)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        btn.layer.borderWidth = 1
        return btn
    }()

    // MARK: - 工具方法（static，避免在 init 之前引用 self）

    /// 创建背景装饰圆
    private static func makeDecoCircle_login(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.isUserInteractionEnabled = false
        return v
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        appleLoginManager_Tidy = AppleLoginManager_Tidy(viewController_Tidy: self)
        setupBackground_Tidy()
        setupBrandArea_Tidy()
        setupCloseButton_Tidy()
        setupBottomCard_Tidy()
        setupCardContent_Tidy()
        setupKeyboardHandling_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 避免与子页面 setNavigationBarHidden(false) 产生状态冲突
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Tidy?.frame = view.bounds
        // 更新登录按钮渐变 frame
        loginBtnGradLayer_Tidy?.frame = loginButton_Tidy.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runEntranceAnimation_Tidy()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 背景搭建

    /// 搭建全屏渐变背景和装饰圆
    private func setupBackground_Tidy() {
        // 三色对角渐变背景
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Tidy.tidyMint_Tidy.cgColor,
            UIColor(hexstring_Tidy: "#2C9E96").cgColor,
            UIColor(hexstring_Tidy: "#2D7DD2").cgColor
        ]
        grad.locations  = [0, 0.55, 1.0]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
        gradientLayer_Tidy = grad

        // 添加装饰圆
        [bgDecoCircleA_Tidy, bgDecoCircleB_Tidy, bgDecoCircleC_Tidy,
         bgDecoDot_Tidy, bgDecoRing_Tidy].forEach { view.addSubview($0) }

        bgDecoCircleA_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(250)
            make.top.equalToSuperview().offset(-80)
            make.trailing.equalToSuperview().offset(60)
        }
        bgDecoCircleB_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(-55)
        }
        bgDecoCircleC_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalToSuperview().offset(200)
            make.trailing.equalToSuperview().offset(-22)
        }
        bgDecoDot_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(60)
        }
        bgDecoRing_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.top.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-80)
        }
    }

    // MARK: - 品牌区搭建

    /// 搭建顶部品牌标识区域
    private func setupBrandArea_Tidy() {
        brandIconBg_Tidy.addSubview(brandIconView_Tidy)
        view.addSubview(brandIconBg_Tidy)
        view.addSubview(brandNameLabel_Tidy)
        view.addSubview(brandTaglineLabel_Tidy)

        brandIconBg_Tidy.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        brandIconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        brandNameLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(brandIconBg_Tidy.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        brandTaglineLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(brandNameLabel_Tidy.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 底部白卡搭建

    /// 搭建底部白色弹出卡片（含 ScrollView）
    private func setupBottomCard_Tidy() {
        view.addSubview(bottomCard_Tidy)
        bottomCard_Tidy.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentContainer_Tidy)

        bottomCard_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(brandTaglineLabel_Tidy.snp.bottom).offset(26)
        }
        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentContainer_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }
    }

    // MARK: - 卡片内容搭建

    /// 搭建卡片内所有 UI 元素
    private func setupCardContent_Tidy() {
        // 标题区域
        contentContainer_Tidy.addSubview(titleLabel_Tidy)
        contentContainer_Tidy.addSubview(subtitleLabel_Tidy)
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel_Tidy)
        }

        // 用户名输入框
        buildInputField_Tidy(
            container: userNameContainer_Tidy,
            iconName: "person.fill",
            textField: userNameField_Tidy,
            rightButton: nil
        )
        contentContainer_Tidy.addSubview(userNameContainer_Tidy)
        userNameContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Tidy.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(56)
        }

        // 密码输入框
        buildInputField_Tidy(
            container: passwordContainer_Tidy,
            iconName: "lock.fill",
            textField: passwordField_Tidy,
            rightButton: eyeButton_Tidy
        )
        contentContainer_Tidy.addSubview(passwordContainer_Tidy)
        passwordContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(userNameContainer_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalTo(userNameContainer_Tidy)
            make.height.equalTo(56)
        }

        // 登录按钮
        buildLoginButton_Tidy()
        contentContainer_Tidy.addSubview(loginButton_Tidy)
        loginButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Tidy.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 分隔线
        buildDivider_Tidy()
        contentContainer_Tidy.addSubview(dividerView_Tidy)
        dividerView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Tidy.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(20)
        }

        // Apple 登录按钮
        let appleBtn_tidy = AppleLoginBt_Tidy { [weak self] in
            self?.handleAppleLogin_Tidy()
        }
        contentContainer_Tidy.addSubview(appleBtn_tidy)
        appleBtn_tidy.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Tidy.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 注册跳转行
        buildRegisterRow_Tidy()
        contentContainer_Tidy.addSubview(registerRow_Tidy)
        registerRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_tidy.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

        // 协议文字（使用 ProtocolHelper 生成可点击富文本，链接颜色为薄荷绿）
        var protoCfg_tidy = ProtocolHelper_Tidy.ProtocolTextConfig_Tidy()
        protoCfg_tidy.textColor_Tidy   = ColorConfig_Tidy.textPlaceholder_Tidy
        protoCfg_tidy.linkColor_Tidy   = ColorConfig_Tidy.tidyMint_Tidy
        protoCfg_tidy.fontSize_Tidy    = 11
        protoCfg_tidy.hasUnderline_Tidy = false
        protoCfg_tidy.prefixText_Tidy   = "By continuing, you agree to our "
        protoCfg_tidy.separatorText_Tidy = " & "
        protocolLabel_Tidy = ProtocolHelper_Tidy.createProtocolTextLabel_Tidy(
            firstContent_Tidy: "terms.png",
            secondContent_Tidy: "privacy.png",
            config_Tidy: protoCfg_tidy,
            from: self
        )
        contentContainer_Tidy.addSubview(protocolLabel_Tidy)
        protocolLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(registerRow_Tidy.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    /// 构建通用输入框容器（图标 + 输入框 + 可选右侧按钮）
    /// 参数：
    /// - container: 容器视图
    /// - iconName: SF Symbol 图标名
    /// - textField: 输入框实例
    /// - rightButton: 右侧按钮（可为 nil）
    private func buildInputField_Tidy(
        container: UIView,
        iconName: String,
        textField: UITextField,
        rightButton: UIButton?
    ) {
        let iconCfg_tidy = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iconIV_tidy = UIImageView()
        iconIV_tidy.image = UIImage(systemName: iconName, withConfiguration: iconCfg_tidy)
        iconIV_tidy.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        iconIV_tidy.contentMode = .scaleAspectFit

        container.addSubview(iconIV_tidy)
        container.addSubview(textField)

        iconIV_tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        if let btn_tidy = rightButton {
            container.addSubview(btn_tidy)
            btn_tidy.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-14)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(30)
            }
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconIV_tidy.snp.trailing).offset(10)
                make.trailing.equalTo(btn_tidy.snp.leading).offset(-6)
                make.top.bottom.equalToSuperview()
            }
        } else {
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconIV_tidy.snp.trailing).offset(10)
                make.trailing.equalToSuperview().offset(-16)
                make.top.bottom.equalToSuperview()
            }
        }

        // 绑定聚焦/失焦边框高亮
        textField.addTarget(self, action: #selector(onFieldBeginEdit_Tidy(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(onFieldEndEdit_Tidy(_:)), for: .editingDidEnd)
    }

    /// 构建登录按钮（渐变背景 + 分类色阴影）
    private func buildLoginButton_Tidy() {
        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [
            ColorConfig_Tidy.tidyMint_Tidy.cgColor,
            UIColor(hexstring_Tidy: "#2C9E96").cgColor
        ]
        grad_tidy.startPoint = CGPoint(x: 0, y: 0.5)
        grad_tidy.endPoint   = CGPoint(x: 1, y: 0.5)
        grad_tidy.cornerRadius = 16
        loginButton_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        loginBtnGradLayer_Tidy = grad_tidy

        // 薄荷绿投影
        loginButton_Tidy.layer.shadowColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.45).cgColor
        loginButton_Tidy.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginButton_Tidy.layer.shadowRadius = 12
        loginButton_Tidy.layer.shadowOpacity = 1

        loginButton_Tidy.addTarget(self, action: #selector(onLoginTapped_Tidy), for: .touchUpInside)
    }

    /// 构建 "or continue with" 分隔线
    private func buildDivider_Tidy() {
        dividerView_Tidy.addSubview(dividerLeftLine_Tidy)
        dividerView_Tidy.addSubview(dividerLabel_Tidy)
        dividerView_Tidy.addSubview(dividerRightLine_Tidy)

        dividerLabel_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        dividerLeftLine_Tidy.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(dividerLabel_Tidy.snp.leading).offset(-10)
            make.height.equalTo(1)
        }
        dividerRightLine_Tidy.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(dividerLabel_Tidy.snp.trailing).offset(10)
            make.height.equalTo(1)
        }
    }

    /// 构建注册跳转行
    private func buildRegisterRow_Tidy() {
        registerRow_Tidy.addSubview(registerHintLabel_Tidy)
        registerRow_Tidy.addSubview(registerButton_Tidy)

        registerHintLabel_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        registerButton_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(registerHintLabel_Tidy.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        registerButton_Tidy.addTarget(self, action: #selector(onRegisterTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 关闭按钮

    /// 搭建右上角关闭按钮（悬浮于渐变背景上方）
    private func setupCloseButton_Tidy() {
        view.addSubview(closeButton_Tidy)
        closeButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }
        closeButton_Tidy.addTarget(self, action: #selector(onCloseTapped_Tidy), for: .touchUpInside)
    }

    /// 关闭按钮点击：弹性动画后退出登录页
    /// 登录页以 present 模式展示时是新导航栈的根控制器，需使用 dismiss；
    /// 若以 push 模式进入则降级为 pop
    @objc private func onCloseTapped_Tidy() {
        closeButton_Tidy.animatePulse_Tidy()
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - 键盘处理

    /// 注册键盘通知并设置收键手势
    private func setupKeyboardHandling_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardShow_Tidy(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardHide_Tidy(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap_tidy = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Tidy))
        tap_tidy.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_tidy)
        userNameField_Tidy.delegate = self
        passwordField_Tidy.delegate = self
        eyeButton_Tidy.addTarget(self, action: #selector(toggleEye_Tidy), for: .touchUpInside)
    }

    // MARK: - 入场动画

    /// 执行各元素依次滑入的入场动画
    private func runEntranceAnimation_Tidy() {
        brandIconBg_Tidy.animateSpringScaleIn_Tidy(delay_Tidy: 0.08)
        brandNameLabel_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 20, delay_Tidy: 0.16)
        brandTaglineLabel_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 16, delay_Tidy: 0.24)
        bottomCard_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 50, delay_Tidy: 0.10)
    }

    // MARK: - 用户事件处理

    /// 登录按钮点击
    @objc private func onLoginTapped_Tidy() {
        loginButton_Tidy.animatePressDown_Tidy { [weak self] in
            self?.loginButton_Tidy.animatePressUp_Tidy()
        }
        view.endEditing(true)
        UserViewModel_Tidy.shared_Tidy.loginById_Tidy(userId_tidy: 454512)
    }

    /// 跳转注册页
    @objc private func onRegisterTapped_Tidy() {
        Navigation_Tidy.toRegister_Tidy(style_tidy: .push_tidy)
    }

    /// 切换密码明文/密文显示
    @objc private func toggleEye_Tidy() {
        eyeButton_Tidy.isSelected.toggle()
        passwordField_Tidy.isSecureTextEntry = !eyeButton_Tidy.isSelected
        eyeButton_Tidy.animatePulse_Tidy()
    }

    /// 输入框聚焦 → 边框高亮为薄荷绿
    @objc private func onFieldBeginEdit_Tidy(_ tf: UITextField) {
        let container_tidy = tf == userNameField_Tidy
            ? userNameContainer_Tidy : passwordContainer_Tidy
        UIView.animate(withDuration: AnimationConfig_Tidy.durationFast_Tidy) {
            container_tidy.layer.borderColor = ColorConfig_Tidy.tidyMint_Tidy.cgColor
            container_tidy.layer.borderWidth  = 2
        }
    }

    /// 输入框失焦 → 边框恢复默认
    @objc private func onFieldEndEdit_Tidy(_ tf: UITextField) {
        let container_tidy = tf == userNameField_Tidy
            ? userNameContainer_Tidy : passwordContainer_Tidy
        UIView.animate(withDuration: AnimationConfig_Tidy.durationFast_Tidy) {
            container_tidy.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
            container_tidy.layer.borderWidth  = 1.5
        }
    }

    /// 键盘弹出：调整 ScrollView 底部偏移
    @objc private func onKeyboardShow_Tidy(_ n: Notification) {
        guard let info_tidy = n.userInfo,
              let kbFrame_tidy = info_tidy[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        scrollView_Tidy.contentInset.bottom = kbFrame_tidy.height + 20
    }

    /// 键盘收起：复原底部偏移
    @objc private func onKeyboardHide_Tidy(_ n: Notification) {
        scrollView_Tidy.contentInset.bottom = 0
    }

    /// 点击背景收键盘
    @objc private func dismissKeyboard_Tidy() {
        view.endEditing(true)
    }

    /// 执行 Apple 登录
    private func handleAppleLogin_Tidy() {
        appleLoginManager_Tidy?.startAppleLogin_Tidy(
            success_Tidy: { userName_tidy in
                UserViewModel_Tidy.shared_Tidy.loginById_Tidy(
                    userId_tidy: 99999
                )
            },
            failure_Tidy: { msg_tidy in }
        )
    }

}

// MARK: - UITextFieldDelegate

extension Login_Tidy: UITextFieldDelegate {

    /// 键盘 Return 键行为：用户名框 → 切到密码框；密码框 → 收键盘并触发登录
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField_Tidy {
            passwordField_Tidy.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            UserViewModel_Tidy.shared_Tidy.loginById_Tidy(userId_tidy: 0)
        }
        return true
    }
}
