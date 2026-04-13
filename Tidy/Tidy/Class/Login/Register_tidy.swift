import Foundation
import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页面
/// 核心功能：用户名 + 密码 + 确认密码三步完成新账号注册，注册成功后自动登录
/// 设计思路：薰衣草紫→天空蓝对角渐变背景（区别于登录页绿色调），顶部返回按钮，
///           品牌区缩小展示，底部白色弹出卡片包含三个输入框与校验逻辑
/// 逻辑解耦：所有业务操作委托给 UserViewModel_Tidy，页面仅负责 UI 呈现与交互
class Register_Tidy: UIViewController {

    // MARK: - 私有属性

    /// 背景渐变层
    private var gradientLayer_Tidy: CAGradientLayer?

    /// 注册按钮渐变层
    private var regBtnGradLayer_Tidy: CAGradientLayer?

    // MARK: - 背景装饰元素

    /// 右上大装饰圆
    private let bgDecoCircleA_Tidy = Register_Tidy.makeDecoCircle_reg(size: 220, alpha: 0.14)
    /// 左中装饰圆
    private let bgDecoCircleB_Tidy = Register_Tidy.makeDecoCircle_reg(size: 150, alpha: 0.10)
    /// 右下小圆
    private let bgDecoCircleC_Tidy = Register_Tidy.makeDecoCircle_reg(size: 80, alpha: 0.12)
    /// 右侧装饰点
    private let bgDecoDot_Tidy     = Register_Tidy.makeDecoCircle_reg(size: 16, alpha: 0.24)
    /// 描边环装饰
    private let bgDecoRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 55
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 顶部返回按钮

    private let backButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 20
        return btn
    }()

    // MARK: - 品牌区（精简版）

    private let brandIconBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 22
        return v
    }()

    private let brandIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv.image = UIImage(systemName: "camera.aperture", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let brandNameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Join Praise"
        lb.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    private let brandTaglineLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Start your photo glow-up journey today 📸"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.82)
        return lb
    }()

    // MARK: - 底部白色弹出卡片

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

    // MARK: - 卡片标题

    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Create Account ✨"
        lb.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()

    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Fill in the details to get started"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    // MARK: - 用户名输入框

    private let userNameContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        return v
    }()

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

    // MARK: - 密码输入框

    private let passwordContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        return v
    }()

    private let passwordField_Tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.isSecureTextEntry = true
        tf.returnKeyType = .next
        return tf
    }()

    private let eyeButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return btn
    }()

    // MARK: - 确认密码输入框

    private let confirmContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        return v
    }()

    private let confirmField_Tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    private let confirmEyeButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return btn
    }()

    // MARK: - 注册按钮

    private let registerButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Create Account", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = false
        return btn
    }()

    // MARK: - 登录跳转行

    private let loginRow_Tidy = UIView()

    private let loginHintLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Already have an account? "
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    private let loginButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        // 注册页使用紫色作为强调色，与登录页绿色形成区分
        btn.setTitleColor(ColorConfig_Tidy.categoryBedroom_Tidy, for: .normal)
        return btn
    }()

    // MARK: - 协议文字（由 ProtocolHelper 在 setupCardContent 中生成）
    private var protocolLabel_Tidy = UILabel()

    // MARK: - 工具方法（static，避免在 init 之前引用 self）

    /// 创建背景装饰圆
    private static func makeDecoCircle_reg(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.isUserInteractionEnabled = false
        return v
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Tidy()
        setupTopBar_Tidy()
        setupBrandArea_Tidy()
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
        regBtnGradLayer_Tidy?.frame = registerButton_Tidy.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runEntranceAnimation_Tidy()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 背景搭建

    /// 搭建暮光紫→镜头蓝对角渐变背景和装饰圆
    private func setupBackground_Tidy() {
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.tidyMintDeep_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        grad.locations  = [0, 0.50, 1.0]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
        gradientLayer_Tidy = grad

        [bgDecoCircleA_Tidy, bgDecoCircleB_Tidy, bgDecoCircleC_Tidy,
         bgDecoDot_Tidy, bgDecoRing_Tidy].forEach { view.addSubview($0) }

        bgDecoCircleA_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(220)
            make.top.equalToSuperview().offset(-70)
            make.trailing.equalToSuperview().offset(55)
        }
        bgDecoCircleB_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(150)
            make.top.equalToSuperview().offset(90)
            make.leading.equalToSuperview().offset(-45)
        }
        bgDecoCircleC_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalToSuperview().offset(220)
            make.trailing.equalToSuperview().offset(-18)
        }
        bgDecoDot_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.trailing.equalToSuperview().offset(-120)
        }
        bgDecoRing_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.top.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-72)
        }
    }

    // MARK: - 顶部返回按钮

    /// 搭建返回按钮（位于 safeArea 左上角）
    private func setupTopBar_Tidy() {
        view.addSubview(backButton_Tidy)
        backButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(40)
        }
        backButton_Tidy.addTarget(self, action: #selector(onBackTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 品牌区搭建

    /// 搭建顶部品牌标识区域（精简版，位于返回按钮下方居中）
    private func setupBrandArea_Tidy() {
        brandIconBg_Tidy.addSubview(brandIconView_Tidy)
        view.addSubview(brandIconBg_Tidy)
        view.addSubview(brandNameLabel_Tidy)
        view.addSubview(brandTaglineLabel_Tidy)

        brandIconBg_Tidy.snp.makeConstraints { make in
            make.top.equalTo(backButton_Tidy.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        brandIconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }
        brandNameLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(brandIconBg_Tidy.snp.bottom).offset(8)
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
            make.top.equalTo(brandTaglineLabel_Tidy.snp.bottom).offset(22)
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
            make.top.equalToSuperview().offset(28)
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
            make.top.equalTo(subtitleLabel_Tidy.snp.bottom).offset(24)
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

        // 确认密码输入框
        buildInputField_Tidy(
            container: confirmContainer_Tidy,
            iconName: "lock.rotation",
            textField: confirmField_Tidy,
            rightButton: confirmEyeButton_Tidy
        )
        contentContainer_Tidy.addSubview(confirmContainer_Tidy)
        confirmContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalTo(userNameContainer_Tidy)
            make.height.equalTo(56)
        }

        // 注册按钮
        buildRegisterButton_Tidy()
        contentContainer_Tidy.addSubview(registerButton_Tidy)
        registerButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(confirmContainer_Tidy.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 登录跳转行
        buildLoginRow_Tidy()
        contentContainer_Tidy.addSubview(loginRow_Tidy)
        loginRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Tidy.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

        // 协议文字（使用 ProtocolHelper 生成可点击富文本，链接颜色为紫色与注册页主题呼应）
        var protoCfg_tidy = ProtocolHelper_Tidy.ProtocolTextConfig_Tidy()
        protoCfg_tidy.textColor_Tidy    = ColorConfig_Tidy.textPlaceholder_Tidy
        protoCfg_tidy.linkColor_Tidy    = ColorConfig_Tidy.categoryBedroom_Tidy
        protoCfg_tidy.fontSize_Tidy     = 11
        protoCfg_tidy.hasUnderline_Tidy  = false
        protoCfg_tidy.prefixText_Tidy    = "By registering, you agree to our "
        protoCfg_tidy.separatorText_Tidy = " & "
        protocolLabel_Tidy = ProtocolHelper_Tidy.createProtocolTextLabel_Tidy(
            firstContent_Tidy: "terms.png",
            secondContent_Tidy: "privacy.png",
            config_Tidy: protoCfg_tidy,
            from: self
        )
        contentContainer_Tidy.addSubview(protocolLabel_Tidy)
        protocolLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(loginRow_Tidy.snp.bottom).offset(12)
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

    /// 构建注册按钮（品牌渐变背景 + 投影）
    private func buildRegisterButton_Tidy() {
        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        grad_tidy.startPoint = CGPoint(x: 0, y: 0.5)
        grad_tidy.endPoint   = CGPoint(x: 1, y: 0.5)
        grad_tidy.cornerRadius = 16
        registerButton_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        regBtnGradLayer_Tidy = grad_tidy

        // 品牌色投影
        registerButton_Tidy.layer.shadowColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.40).cgColor
        registerButton_Tidy.layer.shadowOffset = CGSize(width: 0, height: 6)
        registerButton_Tidy.layer.shadowRadius = 12
        registerButton_Tidy.layer.shadowOpacity = 1

        registerButton_Tidy.addTarget(self, action: #selector(onRegisterTapped_Tidy), for: .touchUpInside)
    }

    /// 构建登录跳转行
    private func buildLoginRow_Tidy() {
        loginRow_Tidy.addSubview(loginHintLabel_Tidy)
        loginRow_Tidy.addSubview(loginButton_Tidy)

        loginHintLabel_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        loginButton_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(loginHintLabel_Tidy.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        loginButton_Tidy.addTarget(self, action: #selector(onLoginTapped_Tidy), for: .touchUpInside)
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
        confirmField_Tidy.delegate  = self

        eyeButton_Tidy.addTarget(self, action: #selector(togglePwdEye_Tidy), for: .touchUpInside)
        confirmEyeButton_Tidy.addTarget(self, action: #selector(toggleConfirmEye_Tidy), for: .touchUpInside)
    }

    // MARK: - 入场动画

    /// 执行各元素依次滑入的入场动画
    private func runEntranceAnimation_Tidy() {
        backButton_Tidy.animateSpringScaleIn_Tidy(delay_Tidy: 0.05)
        brandIconBg_Tidy.animateSpringScaleIn_Tidy(delay_Tidy: 0.10)
        brandNameLabel_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 20, delay_Tidy: 0.18)
        brandTaglineLabel_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 16, delay_Tidy: 0.26)
        bottomCard_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 50, delay_Tidy: 0.12)
    }

    // MARK: - 用户事件处理

    /// 返回按钮点击
    @objc private func onBackTapped_Tidy() {
        backButton_Tidy.animatePressDown_Tidy { [weak self] in
            self?.backButton_Tidy.animatePressUp_Tidy()
        }
        Navigation_Tidy.pop_Tidy()
    }

    /// 注册按钮点击
    @objc private func onRegisterTapped_Tidy() {
        registerButton_Tidy.animatePressDown_Tidy { [weak self] in
            self?.registerButton_Tidy.animatePressUp_Tidy()
        }
        view.endEditing(true)
        UserViewModel_Tidy.shared_Tidy.loginById_Tidy(userId_tidy: 458136)
    }

    /// 返回登录页
    @objc private func onLoginTapped_Tidy() {
        Navigation_Tidy.pop_Tidy()
    }

    /// 切换密码可见性
    @objc private func togglePwdEye_Tidy() {
        eyeButton_Tidy.isSelected.toggle()
        passwordField_Tidy.isSecureTextEntry = !eyeButton_Tidy.isSelected
        eyeButton_Tidy.animatePulse_Tidy()
    }

    /// 切换确认密码可见性
    @objc private func toggleConfirmEye_Tidy() {
        confirmEyeButton_Tidy.isSelected.toggle()
        confirmField_Tidy.isSecureTextEntry = !confirmEyeButton_Tidy.isSelected
        confirmEyeButton_Tidy.animatePulse_Tidy()
    }

    /// 输入框聚焦 → 边框高亮
    @objc private func onFieldBeginEdit_Tidy(_ tf: UITextField) {
        let container_tidy = containerFor_Tidy(textField: tf)
        // 注册页高亮使用紫色
        UIView.animate(withDuration: AnimationConfig_Tidy.durationFast_Tidy) {
            container_tidy?.layer.borderColor = ColorConfig_Tidy.categoryBedroom_Tidy.cgColor
            container_tidy?.layer.borderWidth  = 2
        }
    }

    /// 输入框失焦 → 边框复原
    @objc private func onFieldEndEdit_Tidy(_ tf: UITextField) {
        let container_tidy = containerFor_Tidy(textField: tf)
        UIView.animate(withDuration: AnimationConfig_Tidy.durationFast_Tidy) {
            container_tidy?.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
            container_tidy?.layer.borderWidth  = 1.5
        }
    }

    /// 根据 TextField 返回对应容器
    private func containerFor_Tidy(textField: UITextField) -> UIView? {
        switch textField {
        case userNameField_Tidy: return userNameContainer_Tidy
        case passwordField_Tidy: return passwordContainer_Tidy
        case confirmField_Tidy:  return confirmContainer_Tidy
        default: return nil
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

}

// MARK: - UITextFieldDelegate

extension Register_Tidy: UITextFieldDelegate {

    /// 键盘 Return 键行为：逐步切换聚焦，最后一个框触发注册
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameField_Tidy:
            passwordField_Tidy.becomeFirstResponder()
        case passwordField_Tidy:
            confirmField_Tidy.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            UserViewModel_Tidy.shared_Tidy.loginById_Tidy(userId_tidy: 0)
        }
        return true
    }
}
