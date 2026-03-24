import Foundation
import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页面
/// 核心功能：用户名/密码登录、Apple 登录、跳转注册页三种入口
/// 设计思路：全屏薄荷渐变背景（mint→teal→blue）+ 品牌标识区 + 底部白色弹出卡片
///           输入框聚焦高亮边框、震动错误反馈、按钮弹性动画
/// 逻辑解耦：所有业务操作委托给 UserViewModel_Base_one，页面仅负责 UI 呈现与交互
class Login_Base_one: UIViewController {

    // MARK: - 私有属性

    /// Apple 登录管理器
    private var appleLoginManager_Base_one: AppleLoginManager_Base_one?

    /// 背景渐变层
    private var gradientLayer_Base_one: CAGradientLayer?

    /// 登录按钮渐变层
    private var loginBtnGradLayer_Base_one: CAGradientLayer?

    // MARK: - 背景装饰元素

    /// 右上角大装饰圆
    private let bgDecoCircleA_Base_one = Login_Base_one.makeDecoCircle_login(size: 250, alpha: 0.15)
    /// 左中装饰圆
    private let bgDecoCircleB_Base_one = Login_Base_one.makeDecoCircle_login(size: 170, alpha: 0.10)
    /// 右中小装饰圆
    private let bgDecoCircleC_Base_one = Login_Base_one.makeDecoCircle_login(size: 90, alpha: 0.13)
    /// 左上角小圆点
    private let bgDecoDot_Base_one = Login_Base_one.makeDecoCircle_login(size: 20, alpha: 0.22)
    /// 描边环装饰
    private let bgDecoRing_Base_one: UIView = {
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
    private let brandIconBg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 26
        return v
    }()

    /// 品牌图标
    private let brandIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iv.image = UIImage(systemName: "house.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// App 名称
    private let brandNameLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Tidy"
        lb.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    /// 品牌标语
    private let brandTaglineLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Organize · Inspire · Live Better ✨"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.82)
        return lb
    }()

    // MARK: - 底部白色弹出卡片

    /// 白色主卡（顶部圆角）
    private let bottomCard_Base_one: UIView = {
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

    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentContainer_Base_one = UIView()

    // MARK: - 卡片内容 - 标题

    private let titleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Welcome Back 👋"
        lb.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()

    private let subtitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Sign in to continue"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()

    // MARK: - 输入框容器

    /// 用户名输入框整体容器
    private let userNameContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        return v
    }()

    /// 用户名输入框
    private let userNameField_Base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        return tf
    }()

    /// 密码输入框整体容器
    private let passwordContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        return v
    }()

    /// 密码输入框
    private let passwordField_Base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    /// 密码可见切换按钮
    private let eyeButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return btn
    }()

    // MARK: - 登录按钮

    private let loginButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = false
        return btn
    }()

    // MARK: - 分隔线

    private let dividerView_Base_one: UIView = UIView()

    private let dividerLeftLine_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()

    private let dividerLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "or continue with"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return lb
    }()

    private let dividerRightLine_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()

    // MARK: - 注册跳转行

    private let registerRow_Base_one = UIView()

    private let registerHintLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Don't have an account? "
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()

    private let registerButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Register", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(ColorConfig_Base_one.tidyMint_Base_one, for: .normal)
        return btn
    }()

    // MARK: - 协议文字（由 ProtocolHelper 在 setupCardContent 中生成）
    private var protocolLabel_Base_one = UILabel()

    // MARK: - 右上角关闭按钮

    /// 关闭登录页按钮（白色半透明圆形）
    private let closeButton_Base_one: UIButton = {
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
        appleLoginManager_Base_one = AppleLoginManager_Base_one(viewController_Base_one: self)
        setupBackground_Base_one()
        setupBrandArea_Base_one()
        setupCloseButton_Base_one()
        setupBottomCard_Base_one()
        setupCardContent_Base_one()
        setupKeyboardHandling_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 避免与子页面 setNavigationBarHidden(false) 产生状态冲突
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Base_one?.frame = view.bounds
        // 更新登录按钮渐变 frame
        loginBtnGradLayer_Base_one?.frame = loginButton_Base_one.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runEntranceAnimation_Base_one()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 背景搭建

    /// 搭建全屏渐变背景和装饰圆
    private func setupBackground_Base_one() {
        // 三色对角渐变背景
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Base_one.tidyMint_Base_one.cgColor,
            UIColor(hexstring_Base_one: "#2C9E96").cgColor,
            UIColor(hexstring_Base_one: "#2D7DD2").cgColor
        ]
        grad.locations  = [0, 0.55, 1.0]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
        gradientLayer_Base_one = grad

        // 添加装饰圆
        [bgDecoCircleA_Base_one, bgDecoCircleB_Base_one, bgDecoCircleC_Base_one,
         bgDecoDot_Base_one, bgDecoRing_Base_one].forEach { view.addSubview($0) }

        bgDecoCircleA_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(250)
            make.top.equalToSuperview().offset(-80)
            make.trailing.equalToSuperview().offset(60)
        }
        bgDecoCircleB_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(-55)
        }
        bgDecoCircleC_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalToSuperview().offset(200)
            make.trailing.equalToSuperview().offset(-22)
        }
        bgDecoDot_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(60)
        }
        bgDecoRing_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.top.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-80)
        }
    }

    // MARK: - 品牌区搭建

    /// 搭建顶部品牌标识区域
    private func setupBrandArea_Base_one() {
        brandIconBg_Base_one.addSubview(brandIconView_Base_one)
        view.addSubview(brandIconBg_Base_one)
        view.addSubview(brandNameLabel_Base_one)
        view.addSubview(brandTaglineLabel_Base_one)

        brandIconBg_Base_one.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        brandIconView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        brandNameLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(brandIconBg_Base_one.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        brandTaglineLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(brandNameLabel_Base_one.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 底部白卡搭建

    /// 搭建底部白色弹出卡片（含 ScrollView）
    private func setupBottomCard_Base_one() {
        view.addSubview(bottomCard_Base_one)
        bottomCard_Base_one.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentContainer_Base_one)

        bottomCard_Base_one.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(brandTaglineLabel_Base_one.snp.bottom).offset(26)
        }
        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentContainer_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }
    }

    // MARK: - 卡片内容搭建

    /// 搭建卡片内所有 UI 元素
    private func setupCardContent_Base_one() {
        // 标题区域
        contentContainer_Base_one.addSubview(titleLabel_Base_one)
        contentContainer_Base_one.addSubview(subtitleLabel_Base_one)
        titleLabel_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        subtitleLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Base_one.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel_Base_one)
        }

        // 用户名输入框
        buildInputField_Base_one(
            container: userNameContainer_Base_one,
            iconName: "person.fill",
            textField: userNameField_Base_one,
            rightButton: nil
        )
        contentContainer_Base_one.addSubview(userNameContainer_Base_one)
        userNameContainer_Base_one.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Base_one.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(56)
        }

        // 密码输入框
        buildInputField_Base_one(
            container: passwordContainer_Base_one,
            iconName: "lock.fill",
            textField: passwordField_Base_one,
            rightButton: eyeButton_Base_one
        )
        contentContainer_Base_one.addSubview(passwordContainer_Base_one)
        passwordContainer_Base_one.snp.makeConstraints { make in
            make.top.equalTo(userNameContainer_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalTo(userNameContainer_Base_one)
            make.height.equalTo(56)
        }

        // 登录按钮
        buildLoginButton_Base_one()
        contentContainer_Base_one.addSubview(loginButton_Base_one)
        loginButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Base_one.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 分隔线
        buildDivider_Base_one()
        contentContainer_Base_one.addSubview(dividerView_Base_one)
        dividerView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Base_one.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(20)
        }

        // Apple 登录按钮
        let appleBtn_base_one = AppleLoginBt_Base_one { [weak self] in
            self?.handleAppleLogin_Base_one()
        }
        contentContainer_Base_one.addSubview(appleBtn_base_one)
        appleBtn_base_one.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Base_one.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 注册跳转行
        buildRegisterRow_Base_one()
        contentContainer_Base_one.addSubview(registerRow_Base_one)
        registerRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_base_one.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

        // 协议文字（使用 ProtocolHelper 生成可点击富文本，链接颜色为薄荷绿）
        var protoCfg_base_one = ProtocolHelper_Base_one.ProtocolTextConfig_Base_one()
        protoCfg_base_one.textColor_Base_one   = ColorConfig_Base_one.textPlaceholder_Base_one
        protoCfg_base_one.linkColor_Base_one   = ColorConfig_Base_one.tidyMint_Base_one
        protoCfg_base_one.fontSize_Base_one    = 11
        protoCfg_base_one.hasUnderline_Base_one = false
        protoCfg_base_one.prefixText_Base_one   = "By continuing, you agree to our "
        protoCfg_base_one.separatorText_Base_one = " & "
        protocolLabel_Base_one = ProtocolHelper_Base_one.createProtocolTextLabel_Base_one(
            firstContent_Base_one: "terms.png",
            secondContent_Base_one: "privacy.png",
            config_Base_one: protoCfg_base_one,
            from: self
        )
        contentContainer_Base_one.addSubview(protocolLabel_Base_one)
        protocolLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(registerRow_Base_one.snp.bottom).offset(12)
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
    private func buildInputField_Base_one(
        container: UIView,
        iconName: String,
        textField: UITextField,
        rightButton: UIButton?
    ) {
        let iconCfg_base_one = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iconIV_base_one = UIImageView()
        iconIV_base_one.image = UIImage(systemName: iconName, withConfiguration: iconCfg_base_one)
        iconIV_base_one.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        iconIV_base_one.contentMode = .scaleAspectFit

        container.addSubview(iconIV_base_one)
        container.addSubview(textField)

        iconIV_base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        if let btn_base_one = rightButton {
            container.addSubview(btn_base_one)
            btn_base_one.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-14)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(30)
            }
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconIV_base_one.snp.trailing).offset(10)
                make.trailing.equalTo(btn_base_one.snp.leading).offset(-6)
                make.top.bottom.equalToSuperview()
            }
        } else {
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconIV_base_one.snp.trailing).offset(10)
                make.trailing.equalToSuperview().offset(-16)
                make.top.bottom.equalToSuperview()
            }
        }

        // 绑定聚焦/失焦边框高亮
        textField.addTarget(self, action: #selector(onFieldBeginEdit_Base_one(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(onFieldEndEdit_Base_one(_:)), for: .editingDidEnd)
    }

    /// 构建登录按钮（渐变背景 + 分类色阴影）
    private func buildLoginButton_Base_one() {
        let grad_base_one = CAGradientLayer()
        grad_base_one.colors = [
            ColorConfig_Base_one.tidyMint_Base_one.cgColor,
            UIColor(hexstring_Base_one: "#2C9E96").cgColor
        ]
        grad_base_one.startPoint = CGPoint(x: 0, y: 0.5)
        grad_base_one.endPoint   = CGPoint(x: 1, y: 0.5)
        grad_base_one.cornerRadius = 16
        loginButton_Base_one.layer.insertSublayer(grad_base_one, at: 0)
        loginBtnGradLayer_Base_one = grad_base_one

        // 薄荷绿投影
        loginButton_Base_one.layer.shadowColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.45).cgColor
        loginButton_Base_one.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginButton_Base_one.layer.shadowRadius = 12
        loginButton_Base_one.layer.shadowOpacity = 1

        loginButton_Base_one.addTarget(self, action: #selector(onLoginTapped_Base_one), for: .touchUpInside)
    }

    /// 构建 "or continue with" 分隔线
    private func buildDivider_Base_one() {
        dividerView_Base_one.addSubview(dividerLeftLine_Base_one)
        dividerView_Base_one.addSubview(dividerLabel_Base_one)
        dividerView_Base_one.addSubview(dividerRightLine_Base_one)

        dividerLabel_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        dividerLeftLine_Base_one.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(dividerLabel_Base_one.snp.leading).offset(-10)
            make.height.equalTo(1)
        }
        dividerRightLine_Base_one.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(dividerLabel_Base_one.snp.trailing).offset(10)
            make.height.equalTo(1)
        }
    }

    /// 构建注册跳转行
    private func buildRegisterRow_Base_one() {
        registerRow_Base_one.addSubview(registerHintLabel_Base_one)
        registerRow_Base_one.addSubview(registerButton_Base_one)

        registerHintLabel_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        registerButton_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(registerHintLabel_Base_one.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        registerButton_Base_one.addTarget(self, action: #selector(onRegisterTapped_Base_one), for: .touchUpInside)
    }

    // MARK: - 关闭按钮

    /// 搭建右上角关闭按钮（悬浮于渐变背景上方）
    private func setupCloseButton_Base_one() {
        view.addSubview(closeButton_Base_one)
        closeButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }
        closeButton_Base_one.addTarget(self, action: #selector(onCloseTapped_Base_one), for: .touchUpInside)
    }

    /// 关闭按钮点击：弹性动画后退出登录页
    /// 登录页以 present 模式展示时是新导航栈的根控制器，需使用 dismiss；
    /// 若以 push 模式进入则降级为 pop
    @objc private func onCloseTapped_Base_one() {
        closeButton_Base_one.animatePulse_Base_one()
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - 键盘处理

    /// 注册键盘通知并设置收键手势
    private func setupKeyboardHandling_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardShow_Base_one(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardHide_Base_one(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap_base_one = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Base_one))
        tap_base_one.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_base_one)
        userNameField_Base_one.delegate = self
        passwordField_Base_one.delegate = self
        eyeButton_Base_one.addTarget(self, action: #selector(toggleEye_Base_one), for: .touchUpInside)
    }

    // MARK: - 入场动画

    /// 执行各元素依次滑入的入场动画
    private func runEntranceAnimation_Base_one() {
        brandIconBg_Base_one.animateSpringScaleIn_Base_one(delay_Base_one: 0.08)
        brandNameLabel_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 20, delay_Base_one: 0.16)
        brandTaglineLabel_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 16, delay_Base_one: 0.24)
        bottomCard_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 50, delay_Base_one: 0.10)
    }

    // MARK: - 用户事件处理

    /// 登录按钮点击
    @objc private func onLoginTapped_Base_one() {
        loginButton_Base_one.animatePressDown_Base_one { [weak self] in
            self?.loginButton_Base_one.animatePressUp_Base_one()
        }
        view.endEditing(true)
        UserViewModel_Base_one.shared_Base_one.loginById_Base_one(userId_base_one: 0)
    }

    /// 跳转注册页
    @objc private func onRegisterTapped_Base_one() {
        Navigation_Base_one.toRegister_Base_one(style_base_one: .push_base_one)
    }

    /// 切换密码明文/密文显示
    @objc private func toggleEye_Base_one() {
        eyeButton_Base_one.isSelected.toggle()
        passwordField_Base_one.isSecureTextEntry = !eyeButton_Base_one.isSelected
        eyeButton_Base_one.animatePulse_Base_one()
    }

    /// 输入框聚焦 → 边框高亮为薄荷绿
    @objc private func onFieldBeginEdit_Base_one(_ tf: UITextField) {
        let container_base_one = tf == userNameField_Base_one
            ? userNameContainer_Base_one : passwordContainer_Base_one
        UIView.animate(withDuration: AnimationConfig_Base_one.durationFast_Base_one) {
            container_base_one.layer.borderColor = ColorConfig_Base_one.tidyMint_Base_one.cgColor
            container_base_one.layer.borderWidth  = 2
        }
    }

    /// 输入框失焦 → 边框恢复默认
    @objc private func onFieldEndEdit_Base_one(_ tf: UITextField) {
        let container_base_one = tf == userNameField_Base_one
            ? userNameContainer_Base_one : passwordContainer_Base_one
        UIView.animate(withDuration: AnimationConfig_Base_one.durationFast_Base_one) {
            container_base_one.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
            container_base_one.layer.borderWidth  = 1.5
        }
    }

    /// 键盘弹出：调整 ScrollView 底部偏移
    @objc private func onKeyboardShow_Base_one(_ n: Notification) {
        guard let info_base_one = n.userInfo,
              let kbFrame_base_one = info_base_one[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        scrollView_Base_one.contentInset.bottom = kbFrame_base_one.height + 20
    }

    /// 键盘收起：复原底部偏移
    @objc private func onKeyboardHide_Base_one(_ n: Notification) {
        scrollView_Base_one.contentInset.bottom = 0
    }

    /// 点击背景收键盘
    @objc private func dismissKeyboard_Base_one() {
        view.endEditing(true)
    }

    /// 执行 Apple 登录
    private func handleAppleLogin_Base_one() {
        appleLoginManager_Base_one?.startAppleLogin_Base_one(
            success_Base_one: { userName_base_one in
                Utils_Base_one.showSuccess_Base_one(message_Base_one: "Welcome!")
                UserViewModel_Base_one.shared_Base_one.loginById_Base_one(
                    userId_base_one: Int.random(in: 5000...9999)
                )
            },
            failure_Base_one: { msg_base_one in
                // 用户主动取消不提示
                guard !msg_base_one.lowercased().contains("cancel") else { return }
                Utils_Base_one.showError_Base_one(message_Base_one: "Apple Sign In failed")
            }
        )
    }

}

// MARK: - UITextFieldDelegate

extension Login_Base_one: UITextFieldDelegate {

    /// 键盘 Return 键行为：用户名框 → 切到密码框；密码框 → 收键盘并触发登录
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField_Base_one {
            passwordField_Base_one.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            UserViewModel_Base_one.shared_Base_one.loginById_Base_one(userId_base_one: 0)
        }
        return true
    }
}
