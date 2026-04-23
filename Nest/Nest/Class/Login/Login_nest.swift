import Foundation
import UIKit
import SnapKit

// MARK: - 登录页
/// 核心作用：用户登录入口，账号密码验证
/// 设计思路：
///   - 沉浸式主渐变 Hero 区（340pt，波浪底边 + 四层气泡 + 双环 Logo + 特性标签胶囊行）
///   - Hero 右上角描边胶囊关闭按钮
///   - 表单浮卡（顶部把手条 + 欢迎小标题 + 输入框组 + 注册引导 + 带箭头登录按钮 + 分割线 + 协议文案）
///   - 输入框聚焦：左侧彩色竖条出现 + 边框变主色 + 图标加深 + 底部轻阴影 + 密码字段可切换可见
/// 关键逻辑：
///   - 用户名 / 密码任一为空时禁用登录按钮
///   - 登录仅调用 UserViewModel_Nest.loginById_Nest
class Login_Nest: UIViewController {

    // MARK: - UI 组件

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.alwaysBounceVertical = false
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest = UIView()

    // MARK: Hero 区

    private let heroView_Nest = LoginHeroView_Nest()

    // MARK: 表单浮卡

    private let formCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 32
        v_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset  = CGSize(width: 0, height: -6)
        v_Nest.layer.shadowRadius  = 28
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    /// 顶部把手指示条（提示卡片可上拉）
    private let handleBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#CBD5E0")
        v_Nest.layer.cornerRadius = 2.5
        return v_Nest
    }()

    /// 卡片内欢迎小标题
    private let formGreeting_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Sign in to your account"
        lbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let userNameField_Nest = LoginInputField_Nest(placeholder: "Username", icon: "person.fill",  isSecure: false)
    private let passwordField_Nest  = LoginInputField_Nest(placeholder: "Password",  icon: "lock.fill",   isSecure: true)

    /// 去注册引导行
    private let registerGuide_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.isUserInteractionEnabled = true
        let full_Nest = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: ColorConfig_Nest.textSecondary_Nest
            ]
        )
        full_Nest.append(NSAttributedString(
            string: "Register",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: ColorConfig_Nest.primaryGradientStart_Nest
            ]
        ))
        lbl_Nest.attributedText = full_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    /// 登录按钮（主色渐变 + 右侧箭头图标）
    private let loginBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setTitle("Sign In", for: .normal)
        btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Nest.setTitleColor(.white, for: .normal)
        btn_Nest.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .disabled)
        btn_Nest.setTitleColor(.white, for: .highlighted)
        btn_Nest.layer.cornerRadius = 27
        btn_Nest.layer.shadowColor   = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.45).cgColor
        btn_Nest.layer.shadowOffset  = CGSize(width: 0, height: 8)
        btn_Nest.layer.shadowRadius  = 18
        btn_Nest.layer.shadowOpacity = 0
        btn_Nest.isEnabled = false
        btn_Nest.alpha = 0.5
        return btn_Nest
    }()

    private var loginBtnGradient_Nest: CAGradientLayer?
    private var protocolLabel_Nest: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        setupScrollView_Nest()
        buildHero_Nest()
        buildForm_Nest()
        bindKeyboard_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginBtnGradient_Nest?.frame = loginBtn_Nest.bounds
        // 确保标题与箭头图标不被渐变层遮盖
        loginBtn_Nest.titleLabel.map { loginBtn_Nest.bringSubviewToFront($0) }
        loginBtn_Nest.imageView.map  { loginBtn_Nest.bringSubviewToFront($0) }
    }

    // MARK: - 布局

    private func setupScrollView_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)
        scrollView_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }
    }

    private func buildHero_Nest() {
        contentView_Nest.addSubview(heroView_Nest)
        heroView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(340)
        }
        heroView_Nest.onClose_Nest = { [weak self] in
            Navigation_Nest.dismiss_Nest(from: self)
        }
    }

    private func buildForm_Nest() {
        // 登录按钮渐变层
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        gl_Nest.cornerRadius = 27
        loginBtn_Nest.layer.insertSublayer(gl_Nest, at: 0)
        loginBtnGradient_Nest = gl_Nest

        // 按钮右侧箭头图标
        let arrowCfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        if let arrowImg_Nest = UIImage(systemName: "arrow.right", withConfiguration: arrowCfg_Nest)?
            .withTintColor(.white, renderingMode: .alwaysOriginal) {
            loginBtn_Nest.setImage(arrowImg_Nest, for: .normal)
            loginBtn_Nest.semanticContentAttribute = .forceRightToLeft
            loginBtn_Nest.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        loginBtn_Nest.addTarget(self, action: #selector(onLoginTapped_Nest), for: .touchUpInside)

        // 协议标签
        let protocol_Nest = ProtocolHelper_Nest.createProtocolTextLabel_Nest(
            firstContent_Nest: "terms.png",
            secondContent_Nest: "privacy.png",
            from: self
        )
        protocolLabel_Nest = protocol_Nest

        // 分割线
        let divider_Nest = makeDivider_Nest()

        formCard_Nest.addSubview(handleBar_Nest)
        formCard_Nest.addSubview(formGreeting_Nest)
        formCard_Nest.addSubview(userNameField_Nest)
        formCard_Nest.addSubview(passwordField_Nest)
        formCard_Nest.addSubview(registerGuide_Nest)
        formCard_Nest.addSubview(loginBtn_Nest)
        formCard_Nest.addSubview(divider_Nest)
        formCard_Nest.addSubview(protocol_Nest)
        contentView_Nest.addSubview(formCard_Nest)

        registerGuide_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onRegisterTapped_Nest))
        )

        userNameField_Nest.textField_Nest.addTarget(self, action: #selector(onTextChanged_Nest), for: .editingChanged)
        passwordField_Nest.textField_Nest.addTarget(self, action: #selector(onTextChanged_Nest), for: .editingChanged)
        userNameField_Nest.textField_Nest.delegate = self
        passwordField_Nest.textField_Nest.delegate = self

        setupFormConstraints_Nest(divider: divider_Nest, protocol_Nest: protocol_Nest)
    }

    /// 创建协议上方细分割线
    private func makeDivider_Nest() -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.border_Nest.withAlphaComponent(0.7)
        return v_Nest
    }

    private func setupFormConstraints_Nest(divider: UIView, protocol_Nest: UILabel) {
        formCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(heroView_Nest.snp.bottom).offset(-28)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }
        handleBar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(12)
            make_Nest.centerX.equalToSuperview()
            make_Nest.width.equalTo(40)
            make_Nest.height.equalTo(5)
        }
        formGreeting_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(handleBar_Nest.snp.bottom).offset(18)
            make_Nest.centerX.equalToSuperview()
        }
        userNameField_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(formGreeting_Nest.snp.bottom).offset(20)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(56)
        }
        passwordField_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(userNameField_Nest.snp.bottom).offset(14)
            make_Nest.leading.trailing.height.equalTo(userNameField_Nest)
        }
        registerGuide_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(passwordField_Nest.snp.bottom).offset(16)
            make_Nest.centerX.equalToSuperview()
        }
        loginBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(registerGuide_Nest.snp.bottom).offset(22)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(54)
        }
        divider.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(loginBtn_Nest.snp.bottom).offset(26)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(1)
        }
        protocol_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(divider.snp.bottom).offset(18)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.bottom.equalToSuperview().offset(-32)
        }
    }

    private func bindKeyboard_Nest() {
        let tap_Nest = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Nest))
        tap_Nest.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Nest)
    }

    // MARK: - 事件

    @objc private func onLoginTapped_Nest() {
        view.endEditing(true)
        loginBtn_Nest.animatePulse_Nest()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let userId_Nest = Int.random(in: 1...9)
        UserViewModel_Nest.shared_Nest.loginById_Nest(userId_nest: userId_Nest)
    }

    @objc private func onRegisterTapped_Nest() {
        Navigation_Nest.toRegister_Nest(style_nest: .push_nest)
    }

    @objc private func onTextChanged_Nest() {
        let hasUser_Nest = !(userNameField_Nest.textField_Nest.text ?? "").isEmpty
        let hasPass_Nest = !(passwordField_Nest.textField_Nest.text ?? "").isEmpty
        let enabled_Nest = hasUser_Nest && hasPass_Nest
        loginBtn_Nest.isEnabled = enabled_Nest
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            self.loginBtn_Nest.alpha = enabled_Nest ? 1.0 : 0.5
            self.loginBtn_Nest.layer.shadowOpacity = enabled_Nest ? 1.0 : 0
        }
    }

    @objc private func dismissKeyboard_Nest() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate

extension Login_Nest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField_Nest.textField_Nest {
            passwordField_Nest.textField_Nest.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameField_Nest.textField_Nest      { userNameField_Nest.setFocused_Nest(true) }
        else if textField == passwordField_Nest.textField_Nest { passwordField_Nest.setFocused_Nest(true) }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userNameField_Nest.textField_Nest      { userNameField_Nest.setFocused_Nest(false) }
        else if textField == passwordField_Nest.textField_Nest { passwordField_Nest.setFocused_Nest(false) }
    }
}

// MARK: - LoginHeroView_Nest
/// 登录 Hero 区
/// 核心作用：沉浸式品牌展示，营造独居生活社区氛围感
/// 布局：主色渐变底 → 四层装饰气泡 → 双环 Logo 徽章 → 大标题 → 副标题 → 特性标签胶囊行
class LoginHeroView_Nest: UIView {

    var onClose_Nest: (() -> Void)?

    private var gradientLayer_Nest: CAGradientLayer?

    // 四层装饰气泡（大→小，透明度渐增，打造空间纵深感）
    private let bubble1_Nest = LoginHeroView_Nest.makeBubble_Nest(size: 180, alpha: 0.06)
    private let bubble2_Nest = LoginHeroView_Nest.makeBubble_Nest(size: 110, alpha: 0.08)
    private let bubble3_Nest = LoginHeroView_Nest.makeBubble_Nest(size: 60,  alpha: 0.11)
    private let bubble4_Nest = LoginHeroView_Nest.makeBubble_Nest(size: 34,  alpha: 0.14)

    /// 关闭按钮（半透明描边胶囊，右上角）
    private let closeBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        v_Nest.layer.borderWidth = 1
        v_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v_Nest
    }()

    private let closeIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "xmark"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    // 双环 Logo：外环（淡描边圆）→ 内环（实底圆）→ 图标
    private let outerRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_Nest.layer.cornerRadius = 44
        v_Nest.layer.borderWidth = 1.5
        v_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v_Nest
    }()

    private let innerRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.24)
        v_Nest.layer.cornerRadius = 30
        return v_Nest
    }()

    private let logoIcon_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "house.fill", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Welcome Back"
        lbl_Nest.font = UIFont.systemFont(ofSize: 32, weight: .black)
        lbl_Nest.textColor = .white
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Sign in to continue exploring"
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    /// 特性标签胶囊行（三个小标签）
    private let featureStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .horizontal
        sv_Nest.spacing = 8
        sv_Nest.alignment = .center
        return sv_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
        buildFeatureChips_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 制造装饰气泡（白色半透明圆形）
    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    /// 制造单个特性标签胶囊
    /// - Parameter text_Nest: 展示文字（含 emoji）
    private static func makeChip_Nest(text_Nest: String) -> UIView {
        let wrapper_Nest = UIView()
        wrapper_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        wrapper_Nest.layer.cornerRadius = 12
        wrapper_Nest.layer.borderWidth = 1
        wrapper_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        let lbl_Nest = UILabel()
        lbl_Nest.text = text_Nest
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = .white
        wrapper_Nest.addSubview(lbl_Nest)
        lbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.bottom.equalToSuperview().inset(5)
            make_Nest.leading.trailing.equalToSuperview().inset(10)
        }
        return wrapper_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    /// 构建三个特性标签并填入横排堆叠视图
    private func buildFeatureChips_Nest() {
        for text_Nest in ["🌿 Solo", "✨ Discover", "💬 Connect"] {
            featureStack_Nest.addArrangedSubview(Self.makeChip_Nest(text_Nest: text_Nest))
        }
    }

    private func setupSubviews_Nest() {
        // 气泡层（最底层装饰）
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)
        addSubview(bubble4_Nest)

        // Logo 双环
        outerRing_Nest.addSubview(innerRing_Nest)
        innerRing_Nest.addSubview(logoIcon_Nest)
        addSubview(outerRing_Nest)

        // 关闭按钮
        closeBtn_Nest.addSubview(closeIcon_Nest)
        addSubview(closeBtn_Nest)

        // 文字与标签
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)
        addSubview(featureStack_Nest)

        // 气泡布局（错落分布，营造纵深感）
        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-45)
            make_Nest.leading.equalToSuperview().offset(-55)
            make_Nest.width.height.equalTo(180)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(50)
            make_Nest.trailing.equalToSuperview().offset(32)
            make_Nest.width.height.equalTo(110)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(18)
            make_Nest.trailing.equalToSuperview().offset(-75)
            make_Nest.width.height.equalTo(60)
        }
        bubble4_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(140)
            make_Nest.leading.equalToSuperview().offset(28)
            make_Nest.width.height.equalTo(34)
        }

        // 关闭按钮（右上角，适配刘海）
        closeBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.width.height.equalTo(36)
        }
        closeIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(14)
        }

        // 双环 Logo（居中，距顶 80）
        outerRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerX.equalToSuperview()
            make_Nest.top.equalToSuperview().offset(80)
            make_Nest.width.height.equalTo(88)
        }
        innerRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(60)
        }
        logoIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(28)
        }

        // 标题 & 副标题
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(outerRing_Nest.snp.bottom).offset(18)
            make_Nest.centerX.equalToSuperview()
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(7)
            make_Nest.centerX.equalToSuperview()
        }

        // 特性标签胶囊行
        featureStack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(subtitleLabel_Nest.snp.bottom).offset(16)
            make_Nest.centerX.equalToSuperview()
        }

        closeBtn_Nest.isUserInteractionEnabled = true
        closeBtn_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(closeTapped_Nest))
        )
    }

    /// 功能：同步渐变与波浪形 layer.mask，在 layoutSubviews 中自动触发
    /// 注意：CAShapeLayer 作 mask 必须设 frame + fillColor，否则整段 Hero 被裁切为空白
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout_Nest()
    }

    func updateLayout_Nest() {
        let b_Nest = bounds
        guard b_Nest.width > 0, b_Nest.height > 0 else { return }
        gradientLayer_Nest?.frame = b_Nest
        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: b_Nest.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: b_Nest.width, y: b_Nest.height - 16))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: b_Nest.height - 16),
            controlPoint: CGPoint(x: b_Nest.width / 2, y: b_Nest.height + 22)
        )
        path_Nest.close()
        let mask_Nest = CAShapeLayer()
        mask_Nest.frame = b_Nest
        mask_Nest.path = path_Nest.cgPath
        mask_Nest.fillColor = UIColor.white.cgColor
        layer.mask = mask_Nest
    }

    @objc private func closeTapped_Nest() {
        closeBtn_Nest.animatePressDown_Nest { self.closeBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onClose_Nest?()
    }
}

// MARK: - LoginInputField_Nest
/// 登录输入框组件
/// 核心作用：统一圆角输入框，含图标徽章 + 左侧聚焦指示条 + 密码眼睛切换按钮
/// 聚焦时：左侧彩色竖条渐显 + 边框变主色 + 图标徽章加深 + 底部轻阴影
class LoginInputField_Nest: UIView {

    let textField_Nest: UITextField

    /// 图标徽章背景（圆角方块）
    private let iconBadge_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
        v_Nest.layer.cornerRadius = 14
        return v_Nest
    }()

    private let iconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.8)
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    /// 聚焦时左侧彩色竖条（alpha 动画渐显）
    private let focusBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest
        v_Nest.layer.cornerRadius = 1.5
        v_Nest.alpha = 0
        return v_Nest
    }()

    /// 密码可见切换按钮（仅 isSecure 时显示）
    private let toggleBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn_Nest.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg_Nest), for: .normal)
        btn_Nest.setImage(UIImage(systemName: "eye",       withConfiguration: cfg_Nest), for: .selected)
        btn_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        btn_Nest.isHidden = true
        return btn_Nest
    }()

    /// - Parameters:
    ///   - placeholder: 占位提示文字
    ///   - icon: SF Symbol 图标名
    ///   - isSecure: 是否密码模式（true 时右侧显示眼睛切换）
    init(placeholder: String, icon: String, isSecure: Bool) {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = placeholder
        tf_Nest.font = UIFont.systemFont(ofSize: 15)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.isSecureTextEntry = isSecure
        tf_Nest.backgroundColor = .clear
        tf_Nest.returnKeyType = isSecure ? .done : .next
        tf_Nest.autocapitalizationType = .none
        tf_Nest.autocorrectionType = .no
        textField_Nest = tf_Nest
        super.init(frame: .zero)

        backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        layer.cornerRadius = 18
        layer.borderWidth = 1.5
        layer.borderColor = ColorConfig_Nest.border_Nest.cgColor

        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconView_Nest.image = UIImage(systemName: icon, withConfiguration: cfg_Nest)

        if isSecure {
            toggleBtn_Nest.isHidden = false
            toggleBtn_Nest.addTarget(self, action: #selector(toggleVisibility_Nest), for: .touchUpInside)
        }

        iconBadge_Nest.addSubview(iconView_Nest)
        addSubview(focusBar_Nest)
        addSubview(iconBadge_Nest)
        addSubview(textField_Nest)
        addSubview(toggleBtn_Nest)

        focusBar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview()
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.equalTo(3)
            make_Nest.height.equalTo(26)
        }
        iconBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(40)
        }
        iconView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(18)
        }
        toggleBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(32)
        }
        // 密码模式下 trailing 止于眼睛按钮；普通模式直接到边
        if isSecure {
            textField_Nest.snp.makeConstraints { make_Nest in
                make_Nest.leading.equalTo(iconBadge_Nest.snp.trailing).offset(10)
                make_Nest.trailing.equalTo(toggleBtn_Nest.snp.leading).offset(-4)
                make_Nest.centerY.equalToSuperview()
            }
        } else {
            textField_Nest.snp.makeConstraints { make_Nest in
                make_Nest.leading.equalTo(iconBadge_Nest.snp.trailing).offset(10)
                make_Nest.trailing.equalToSuperview().offset(-16)
                make_Nest.centerY.equalToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 切换密码明文 / 密文显示
    @objc private func toggleVisibility_Nest() {
        toggleBtn_Nest.isSelected.toggle()
        textField_Nest.isSecureTextEntry = !toggleBtn_Nest.isSelected
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// 更新聚焦视觉状态（边框、指示条、徽章、阴影）
    /// - Parameter focused: 是否正在编辑中
    func setFocused_Nest(_ focused: Bool) {
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut) {
            self.layer.borderColor = focused
                ? ColorConfig_Nest.primaryGradientStart_Nest.cgColor
                : ColorConfig_Nest.border_Nest.cgColor
            self.layer.shadowColor   = focused
                ? ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.12).cgColor
                : UIColor.clear.cgColor
            self.layer.shadowRadius  = focused ? 8 : 0
            self.layer.shadowOpacity = focused ? 1 : 0
            self.layer.shadowOffset  = CGSize(width: 0, height: 3)
            self.iconBadge_Nest.backgroundColor = focused
                ? ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.18)
                : ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
            self.iconView_Nest.tintColor = focused
                ? ColorConfig_Nest.primaryGradientStart_Nest
                : ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.7)
            self.focusBar_Nest.alpha = focused ? 1 : 0
            self.backgroundColor = focused
                ? ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.02)
                : ColorConfig_Nest.backgroundPrimary_Nest
        }
    }
}
