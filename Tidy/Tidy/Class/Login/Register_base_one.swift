import Foundation
import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页面
/// 核心功能：用户名 + 密码 + 确认密码三步完成新账号注册，注册成功后自动登录
/// 设计思路：薰衣草紫→天空蓝对角渐变背景（区别于登录页绿色调），顶部返回按钮，
///           品牌区缩小展示，底部白色弹出卡片包含三个输入框与校验逻辑
/// 逻辑解耦：所有业务操作委托给 UserViewModel_Base_one，页面仅负责 UI 呈现与交互
class Register_Base_one: UIViewController {

    // MARK: - 私有属性

    /// 背景渐变层
    private var gradientLayer_Base_one: CAGradientLayer?

    /// 注册按钮渐变层
    private var regBtnGradLayer_Base_one: CAGradientLayer?

    // MARK: - 背景装饰元素

    /// 右上大装饰圆
    private let bgDecoCircleA_Base_one = Register_Base_one.makeDecoCircle_reg(size: 220, alpha: 0.14)
    /// 左中装饰圆
    private let bgDecoCircleB_Base_one = Register_Base_one.makeDecoCircle_reg(size: 150, alpha: 0.10)
    /// 右下小圆
    private let bgDecoCircleC_Base_one = Register_Base_one.makeDecoCircle_reg(size: 80, alpha: 0.12)
    /// 右侧装饰点
    private let bgDecoDot_Base_one     = Register_Base_one.makeDecoCircle_reg(size: 16, alpha: 0.24)
    /// 描边环装饰
    private let bgDecoRing_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 55
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 顶部返回按钮

    private let backButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 20
        return btn
    }()

    // MARK: - 品牌区（精简版）

    private let brandIconBg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 22
        return v
    }()

    private let brandIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv.image = UIImage(systemName: "house.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let brandNameLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Join Tidy"
        lb.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    private let brandTaglineLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Start your tidy home journey today 🏡"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.82)
        return lb
    }()

    // MARK: - 底部白色弹出卡片

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

    // MARK: - 卡片标题

    private let titleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Create Account ✨"
        lb.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()

    private let subtitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Fill in the details to get started"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()

    // MARK: - 用户名输入框

    private let userNameContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        return v
    }()

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

    // MARK: - 密码输入框

    private let passwordContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        return v
    }()

    private let passwordField_Base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.isSecureTextEntry = true
        tf.returnKeyType = .next
        return tf
    }()

    private let eyeButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return btn
    }()

    // MARK: - 确认密码输入框

    private let confirmContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
        return v
    }()

    private let confirmField_Base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    private let confirmEyeButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return btn
    }()

    // MARK: - 注册按钮

    private let registerButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Create Account", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = false
        return btn
    }()

    // MARK: - 登录跳转行

    private let loginRow_Base_one = UIView()

    private let loginHintLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Already have an account? "
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()

    private let loginButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        // 注册页使用紫色作为强调色，与登录页绿色形成区分
        btn.setTitleColor(ColorConfig_Base_one.categoryBedroom_Base_one, for: .normal)
        return btn
    }()

    // MARK: - 协议文字（由 ProtocolHelper 在 setupCardContent 中生成）
    private var protocolLabel_Base_one = UILabel()

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
        setupBackground_Base_one()
        setupTopBar_Base_one()
        setupBrandArea_Base_one()
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
        regBtnGradLayer_Base_one?.frame = registerButton_Base_one.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runEntranceAnimation_Base_one()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 背景搭建

    /// 搭建薰衣草紫→天空蓝对角渐变背景（与登录页绿色调形成区分）和装饰圆
    private func setupBackground_Base_one() {
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            UIColor(hexstring_Base_one: "#A78BFA").cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        grad.locations  = [0, 0.50, 1.0]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
        gradientLayer_Base_one = grad

        [bgDecoCircleA_Base_one, bgDecoCircleB_Base_one, bgDecoCircleC_Base_one,
         bgDecoDot_Base_one, bgDecoRing_Base_one].forEach { view.addSubview($0) }

        bgDecoCircleA_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(220)
            make.top.equalToSuperview().offset(-70)
            make.trailing.equalToSuperview().offset(55)
        }
        bgDecoCircleB_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(150)
            make.top.equalToSuperview().offset(90)
            make.leading.equalToSuperview().offset(-45)
        }
        bgDecoCircleC_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalToSuperview().offset(220)
            make.trailing.equalToSuperview().offset(-18)
        }
        bgDecoDot_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.trailing.equalToSuperview().offset(-120)
        }
        bgDecoRing_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.top.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-72)
        }
    }

    // MARK: - 顶部返回按钮

    /// 搭建返回按钮（位于 safeArea 左上角）
    private func setupTopBar_Base_one() {
        view.addSubview(backButton_Base_one)
        backButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(40)
        }
        backButton_Base_one.addTarget(self, action: #selector(onBackTapped_Base_one), for: .touchUpInside)
    }

    // MARK: - 品牌区搭建

    /// 搭建顶部品牌标识区域（精简版，位于返回按钮下方居中）
    private func setupBrandArea_Base_one() {
        brandIconBg_Base_one.addSubview(brandIconView_Base_one)
        view.addSubview(brandIconBg_Base_one)
        view.addSubview(brandNameLabel_Base_one)
        view.addSubview(brandTaglineLabel_Base_one)

        brandIconBg_Base_one.snp.makeConstraints { make in
            make.top.equalTo(backButton_Base_one.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        brandIconView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }
        brandNameLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(brandIconBg_Base_one.snp.bottom).offset(8)
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
            make.top.equalTo(brandTaglineLabel_Base_one.snp.bottom).offset(22)
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
            make.top.equalToSuperview().offset(28)
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
            make.top.equalTo(subtitleLabel_Base_one.snp.bottom).offset(24)
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

        // 确认密码输入框
        buildInputField_Base_one(
            container: confirmContainer_Base_one,
            iconName: "lock.rotation",
            textField: confirmField_Base_one,
            rightButton: confirmEyeButton_Base_one
        )
        contentContainer_Base_one.addSubview(confirmContainer_Base_one)
        confirmContainer_Base_one.snp.makeConstraints { make in
            make.top.equalTo(passwordContainer_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalTo(userNameContainer_Base_one)
            make.height.equalTo(56)
        }

        // 注册按钮
        buildRegisterButton_Base_one()
        contentContainer_Base_one.addSubview(registerButton_Base_one)
        registerButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(confirmContainer_Base_one.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 登录跳转行
        buildLoginRow_Base_one()
        contentContainer_Base_one.addSubview(loginRow_Base_one)
        loginRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Base_one.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

        // 协议文字（使用 ProtocolHelper 生成可点击富文本，链接颜色为紫色与注册页主题呼应）
        var protoCfg_base_one = ProtocolHelper_Base_one.ProtocolTextConfig_Base_one()
        protoCfg_base_one.textColor_Base_one    = ColorConfig_Base_one.textPlaceholder_Base_one
        protoCfg_base_one.linkColor_Base_one    = ColorConfig_Base_one.categoryBedroom_Base_one
        protoCfg_base_one.fontSize_Base_one     = 11
        protoCfg_base_one.hasUnderline_Base_one  = false
        protoCfg_base_one.prefixText_Base_one    = "By registering, you agree to our "
        protoCfg_base_one.separatorText_Base_one = " & "
        protocolLabel_Base_one = ProtocolHelper_Base_one.createProtocolTextLabel_Base_one(
            firstContent_Base_one: "terms.png",
            secondContent_Base_one: "privacy.png",
            config_Base_one: protoCfg_base_one,
            from: self
        )
        contentContainer_Base_one.addSubview(protocolLabel_Base_one)
        protocolLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(loginRow_Base_one.snp.bottom).offset(12)
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

    /// 构建注册按钮（紫色渐变背景 + 投影）
    private func buildRegisterButton_Base_one() {
        let grad_base_one = CAGradientLayer()
        grad_base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            UIColor(hexstring_Base_one: "#A78BFA").cgColor
        ]
        grad_base_one.startPoint = CGPoint(x: 0, y: 0.5)
        grad_base_one.endPoint   = CGPoint(x: 1, y: 0.5)
        grad_base_one.cornerRadius = 16
        registerButton_Base_one.layer.insertSublayer(grad_base_one, at: 0)
        regBtnGradLayer_Base_one = grad_base_one

        // 紫色投影
        registerButton_Base_one.layer.shadowColor = ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.40).cgColor
        registerButton_Base_one.layer.shadowOffset = CGSize(width: 0, height: 6)
        registerButton_Base_one.layer.shadowRadius = 12
        registerButton_Base_one.layer.shadowOpacity = 1

        registerButton_Base_one.addTarget(self, action: #selector(onRegisterTapped_Base_one), for: .touchUpInside)
    }

    /// 构建登录跳转行
    private func buildLoginRow_Base_one() {
        loginRow_Base_one.addSubview(loginHintLabel_Base_one)
        loginRow_Base_one.addSubview(loginButton_Base_one)

        loginHintLabel_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        loginButton_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(loginHintLabel_Base_one.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        loginButton_Base_one.addTarget(self, action: #selector(onLoginTapped_Base_one), for: .touchUpInside)
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
        confirmField_Base_one.delegate  = self

        eyeButton_Base_one.addTarget(self, action: #selector(togglePwdEye_Base_one), for: .touchUpInside)
        confirmEyeButton_Base_one.addTarget(self, action: #selector(toggleConfirmEye_Base_one), for: .touchUpInside)
    }

    // MARK: - 入场动画

    /// 执行各元素依次滑入的入场动画
    private func runEntranceAnimation_Base_one() {
        backButton_Base_one.animateSpringScaleIn_Base_one(delay_Base_one: 0.05)
        brandIconBg_Base_one.animateSpringScaleIn_Base_one(delay_Base_one: 0.10)
        brandNameLabel_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 20, delay_Base_one: 0.18)
        brandTaglineLabel_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 16, delay_Base_one: 0.26)
        bottomCard_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 50, delay_Base_one: 0.12)
    }

    // MARK: - 用户事件处理

    /// 返回按钮点击
    @objc private func onBackTapped_Base_one() {
        backButton_Base_one.animatePressDown_Base_one { [weak self] in
            self?.backButton_Base_one.animatePressUp_Base_one()
        }
        Navigation_Base_one.pop_Base_one()
    }

    /// 注册按钮点击
    @objc private func onRegisterTapped_Base_one() {
        registerButton_Base_one.animatePressDown_Base_one { [weak self] in
            self?.registerButton_Base_one.animatePressUp_Base_one()
        }
        view.endEditing(true)
        UserViewModel_Base_one.shared_Base_one.loginById_Base_one(userId_base_one: 458136)
    }

    /// 返回登录页
    @objc private func onLoginTapped_Base_one() {
        Navigation_Base_one.pop_Base_one()
    }

    /// 切换密码可见性
    @objc private func togglePwdEye_Base_one() {
        eyeButton_Base_one.isSelected.toggle()
        passwordField_Base_one.isSecureTextEntry = !eyeButton_Base_one.isSelected
        eyeButton_Base_one.animatePulse_Base_one()
    }

    /// 切换确认密码可见性
    @objc private func toggleConfirmEye_Base_one() {
        confirmEyeButton_Base_one.isSelected.toggle()
        confirmField_Base_one.isSecureTextEntry = !confirmEyeButton_Base_one.isSelected
        confirmEyeButton_Base_one.animatePulse_Base_one()
    }

    /// 输入框聚焦 → 边框高亮
    @objc private func onFieldBeginEdit_Base_one(_ tf: UITextField) {
        let container_base_one = containerFor_Base_one(textField: tf)
        // 注册页高亮使用紫色
        UIView.animate(withDuration: AnimationConfig_Base_one.durationFast_Base_one) {
            container_base_one?.layer.borderColor = ColorConfig_Base_one.categoryBedroom_Base_one.cgColor
            container_base_one?.layer.borderWidth  = 2
        }
    }

    /// 输入框失焦 → 边框复原
    @objc private func onFieldEndEdit_Base_one(_ tf: UITextField) {
        let container_base_one = containerFor_Base_one(textField: tf)
        UIView.animate(withDuration: AnimationConfig_Base_one.durationFast_Base_one) {
            container_base_one?.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
            container_base_one?.layer.borderWidth  = 1.5
        }
    }

    /// 根据 TextField 返回对应容器
    private func containerFor_Base_one(textField: UITextField) -> UIView? {
        switch textField {
        case userNameField_Base_one: return userNameContainer_Base_one
        case passwordField_Base_one: return passwordContainer_Base_one
        case confirmField_Base_one:  return confirmContainer_Base_one
        default: return nil
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

}

// MARK: - UITextFieldDelegate

extension Register_Base_one: UITextFieldDelegate {

    /// 键盘 Return 键行为：逐步切换聚焦，最后一个框触发注册
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameField_Base_one:
            passwordField_Base_one.becomeFirstResponder()
        case passwordField_Base_one:
            confirmField_Base_one.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            UserViewModel_Base_one.shared_Base_one.loginById_Base_one(userId_base_one: 0)
        }
        return true
    }
}
