import Foundation
import UIKit
import SnapKit

// MARK: - 注册页
/// 核心作用：新用户注册入口
/// 设计思路：
///   - 沉浸式辅助色渐变 Hero 区（300pt，波浪底边 + 四层气泡 + New Member 徽章 + 双环 Logo）
///   - 表单浮卡（把手条 + 欢迎语 + 三输入框 + 密码强度条 + 密码不匹配提示 + 带箭头注册按钮 + 分割线 + 协议文案）
///   - 输入框聚焦：左侧彩色竖条 + 边框变辅助主色 + 图标加深 + 轻阴影
/// 关键逻辑：
///   - 三个输入框任一为空，或两次密码不一致时禁用注册按钮
///   - 密码不一致时 confirmField 边框变红并显示提示
///   - 密码强度随输入长度实时更新（弱/一般/强）
class Register_Nest: UIViewController {

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

    private let heroView_Nest = RegisterHeroView_Nest()

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

    /// 顶部把手指示条
    private let handleBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#CBD5E0")
        v_Nest.layer.cornerRadius = 2.5
        return v_Nest
    }()

    /// 表单区欢迎小标题
    private let formGreeting_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Let's create your account"
        lbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let userNameField_Nest = RegisterInputField_Nest(placeholder: "Username",         icon: "person.fill",      isSecure: false)
    private let passwordField_Nest  = RegisterInputField_Nest(placeholder: "Password",         icon: "lock.fill",        isSecure: true)
    private let confirmField_Nest   = RegisterInputField_Nest(placeholder: "Confirm Password", icon: "lock.shield.fill", isSecure: true)

    /// 密码强度指示组件（输入密码时出现）
    private let strengthView_Nest = RegisterPasswordStrengthView_Nest()

    /// 密码不一致提示标签
    private let pwdMismatchLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let attachment_Nest = NSTextAttachment()
        attachment_Nest.image = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: cfg_Nest)?
            .withTintColor(UIColor(hexstring_Nest: "#FC8181"), renderingMode: .alwaysOriginal)
        let attrStr_Nest = NSMutableAttributedString(attachment: attachment_Nest)
        attrStr_Nest.append(NSAttributedString(
            string: "  Passwords do not match",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor(hexstring_Nest: "#FC8181")
            ]
        ))
        lbl_Nest.attributedText = attrStr_Nest
        lbl_Nest.isHidden = true
        return lbl_Nest
    }()

    /// 注册按钮（辅助渐变 + 右侧箭头图标）
    private let registerBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setTitle("Create Account", for: .normal)
        btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Nest.setTitleColor(.white, for: .normal)
        btn_Nest.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .disabled)
        btn_Nest.setTitleColor(.white, for: .highlighted)
        btn_Nest.layer.cornerRadius = 27
        btn_Nest.layer.shadowColor   = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.45).cgColor
        btn_Nest.layer.shadowOffset  = CGSize(width: 0, height: 8)
        btn_Nest.layer.shadowRadius  = 18
        btn_Nest.layer.shadowOpacity = 0
        btn_Nest.isEnabled = false
        btn_Nest.alpha = 0.5
        return btn_Nest
    }()

    private var registerBtnGradient_Nest: CAGradientLayer?
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
        registerBtnGradient_Nest?.frame = registerBtn_Nest.bounds
        // 确保标题与箭头不被渐变层遮盖
        registerBtn_Nest.titleLabel.map { registerBtn_Nest.bringSubviewToFront($0) }
        registerBtn_Nest.imageView.map  { registerBtn_Nest.bringSubviewToFront($0) }
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
            make_Nest.height.equalTo(300)
        }
        heroView_Nest.onBack_Nest = { [weak self] in Navigation_Nest.pop_Nest(from: self) }
    }

    private func buildForm_Nest() {
        // 注册按钮渐变层
        let gl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        gl_Nest.cornerRadius = 27
        registerBtn_Nest.layer.insertSublayer(gl_Nest, at: 0)
        registerBtnGradient_Nest = gl_Nest

        // 按钮右侧箭头图标
        let arrowCfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        if let arrowImg_Nest = UIImage(systemName: "arrow.right", withConfiguration: arrowCfg_Nest)?
            .withTintColor(.white, renderingMode: .alwaysOriginal) {
            registerBtn_Nest.setImage(arrowImg_Nest, for: .normal)
            registerBtn_Nest.semanticContentAttribute = .forceRightToLeft
            registerBtn_Nest.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        registerBtn_Nest.addTarget(self, action: #selector(onRegisterTapped_Nest), for: .touchUpInside)

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
        formCard_Nest.addSubview(strengthView_Nest)
        formCard_Nest.addSubview(confirmField_Nest)
        formCard_Nest.addSubview(pwdMismatchLabel_Nest)
        formCard_Nest.addSubview(registerBtn_Nest)
        formCard_Nest.addSubview(divider_Nest)
        formCard_Nest.addSubview(protocol_Nest)
        contentView_Nest.addSubview(formCard_Nest)

        for tf_Nest in [userNameField_Nest, passwordField_Nest, confirmField_Nest] {
            tf_Nest.textField_Nest.addTarget(self, action: #selector(onTextChanged_Nest), for: .editingChanged)
            tf_Nest.textField_Nest.delegate = self
        }

        setupFormConstraints_Nest(divider: divider_Nest, protocol_Nest: protocol_Nest)
    }

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
        // 密码强度条紧跟密码框
        strengthView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(passwordField_Nest.snp.bottom).offset(10)
            make_Nest.leading.trailing.equalTo(userNameField_Nest)
        }
        confirmField_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(strengthView_Nest.snp.bottom).offset(12)
            make_Nest.leading.trailing.height.equalTo(userNameField_Nest)
        }
        pwdMismatchLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(confirmField_Nest.snp.bottom).offset(7)
            make_Nest.leading.equalTo(confirmField_Nest).offset(4)
        }
        registerBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(pwdMismatchLabel_Nest.snp.bottom).offset(20)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(54)
        }
        divider.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(registerBtn_Nest.snp.bottom).offset(26)
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

    // MARK: - 输入校验

    /// 检查全部输入有效性，并更新按钮状态、密码强度视图
    @objc private func onTextChanged_Nest() {
        let user_Nest    = userNameField_Nest.textField_Nest.text ?? ""
        let pwd_Nest     = passwordField_Nest.textField_Nest.text ?? ""
        let confirm_Nest = confirmField_Nest.textField_Nest.text ?? ""

        // 更新密码强度
        strengthView_Nest.update_Nest(password: pwd_Nest)

        let allFilled_Nest    = !user_Nest.isEmpty && !pwd_Nest.isEmpty && !confirm_Nest.isEmpty
        let showMismatch_Nest = !confirm_Nest.isEmpty && pwd_Nest != confirm_Nest
        let pwdMatch_Nest     = pwd_Nest == confirm_Nest || confirm_Nest.isEmpty

        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            self.pwdMismatchLabel_Nest.isHidden = !showMismatch_Nest
            self.confirmField_Nest.layer.borderColor = showMismatch_Nest
                ? UIColor(hexstring_Nest: "#FC8181").cgColor
                : ColorConfig_Nest.border_Nest.cgColor
        }

        let enabled_Nest = allFilled_Nest && pwdMatch_Nest
        registerBtn_Nest.isEnabled = enabled_Nest
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            self.registerBtn_Nest.alpha = enabled_Nest ? 1.0 : 0.5
            self.registerBtn_Nest.layer.shadowOpacity = enabled_Nest ? 1.0 : 0
        }
    }

    // MARK: - 事件处理

    @objc private func onRegisterTapped_Nest() {
        view.endEditing(true)
        registerBtn_Nest.animatePulse_Nest()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let userId_Nest = Int.random(in: 1...9)
        UserViewModel_Nest.shared_Nest.loginById_Nest(userId_nest: userId_Nest)
    }

    @objc private func dismissKeyboard_Nest() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate

extension Register_Nest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField_Nest.textField_Nest {
            passwordField_Nest.textField_Nest.becomeFirstResponder()
        } else if textField == passwordField_Nest.textField_Nest {
            confirmField_Nest.textField_Nest.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameField_Nest.textField_Nest      { userNameField_Nest.setFocused_Nest(true) }
        else if textField == passwordField_Nest.textField_Nest { passwordField_Nest.setFocused_Nest(true) }
        else if textField == confirmField_Nest.textField_Nest  { confirmField_Nest.setFocused_Nest(true) }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userNameField_Nest.textField_Nest      { userNameField_Nest.setFocused_Nest(false) }
        else if textField == passwordField_Nest.textField_Nest { passwordField_Nest.setFocused_Nest(false) }
        else if textField == confirmField_Nest.textField_Nest  { confirmField_Nest.setFocused_Nest(false) }
    }
}

// MARK: - RegisterHeroView_Nest
/// 注册页沉浸式 Hero 区
/// 核心作用：辅助色渐变底 + 四层气泡 + "New Member" 徽章 + 双环 Logo + 标题副标题 + 返回按钮
class RegisterHeroView_Nest: UIView {

    var onBack_Nest: (() -> Void)?

    private var gradientLayer_Nest: CAGradientLayer?

    // 四层装饰气泡
    private let bubble1_Nest = RegisterHeroView_Nest.makeBubble_Nest(size: 160, alpha: 0.07)
    private let bubble2_Nest = RegisterHeroView_Nest.makeBubble_Nest(size: 95,  alpha: 0.09)
    private let bubble3_Nest = RegisterHeroView_Nest.makeBubble_Nest(size: 52,  alpha: 0.12)
    private let bubble4_Nest = RegisterHeroView_Nest.makeBubble_Nest(size: 30,  alpha: 0.15)

    /// 返回按钮（半透明描边胶囊，左上角）
    private let backBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        v_Nest.layer.borderWidth = 1
        v_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v_Nest
    }()

    private let backIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    /// "New Member" 身份徽章胶囊（Logo 上方）
    private let memberBadge_Nest: UIView = {
        let wrapper_Nest = UIView()
        wrapper_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        wrapper_Nest.layer.cornerRadius = 12
        wrapper_Nest.layer.borderWidth = 1
        wrapper_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        let lbl_Nest = UILabel()
        lbl_Nest.text = "✦ New Member"
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Nest.textColor = .white
        wrapper_Nest.addSubview(lbl_Nest)
        lbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.bottom.equalToSuperview().inset(5)
            make_Nest.leading.trailing.equalToSuperview().inset(12)
        }
        return wrapper_Nest
    }()

    // 双环 Logo
    private let outerRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_Nest.layer.cornerRadius = 40
        v_Nest.layer.borderWidth = 1.5
        v_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v_Nest
    }()

    private let innerRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.24)
        v_Nest.layer.cornerRadius = 28
        return v_Nest
    }()

    private let logoIcon_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Create Account"
        lbl_Nest.font = UIFont.systemFont(ofSize: 28, weight: .black)
        lbl_Nest.textColor = .white
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Join the community today"
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)
        addSubview(bubble4_Nest)

        outerRing_Nest.addSubview(innerRing_Nest)
        innerRing_Nest.addSubview(logoIcon_Nest)
        backBtn_Nest.addSubview(backIcon_Nest)
        addSubview(backBtn_Nest)
        addSubview(memberBadge_Nest)
        addSubview(outerRing_Nest)
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)

        // 气泡布局（错落四角）
        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-30)
            make_Nest.trailing.equalToSuperview().offset(30)
            make_Nest.width.height.equalTo(160)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(20)
            make_Nest.leading.equalToSuperview().offset(-25)
            make_Nest.width.height.equalTo(95)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(60)
            make_Nest.leading.equalToSuperview().offset(40)
            make_Nest.width.height.equalTo(52)
        }
        bubble4_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(-20)
            make_Nest.trailing.equalToSuperview().offset(-40)
            make_Nest.width.height.equalTo(30)
        }

        // 返回按钮（左上角）
        backBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.width.height.equalTo(36)
        }
        backIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(14)
        }

        // New Member 徽章（居中，Logo 上方）
        memberBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerX.equalToSuperview()
            make_Nest.top.equalToSuperview().offset(62)
        }

        // 双环 Logo
        outerRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerX.equalToSuperview()
            make_Nest.top.equalTo(memberBadge_Nest.snp.bottom).offset(12)
            make_Nest.width.height.equalTo(80)
        }
        innerRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(56)
        }
        logoIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(26)
        }

        // 标题 & 副标题
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(outerRing_Nest.snp.bottom).offset(16)
            make_Nest.centerX.equalToSuperview()
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(7)
            make_Nest.centerX.equalToSuperview()
        }

        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(backTapped_Nest))
        )
    }

    /// 功能：同步渐变与波浪形 layer.mask，在 layoutSubviews 中自动触发
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

    @objc private func backTapped_Nest() {
        backBtn_Nest.animatePressDown_Nest { self.backBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onBack_Nest?()
    }
}

// MARK: - RegisterInputField_Nest
/// 注册输入框组件
/// 核心作用：与 LoginInputField 结构一致，颜色使用辅助渐变（玫瑰粉系）
/// 聚焦时：左侧彩色竖条 + 辅助渐变色边框 + 图标徽章加深 + 轻阴影
class RegisterInputField_Nest: UIView {

    let textField_Nest: UITextField

    private let iconBadge_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.1)
        v_Nest.layer.cornerRadius = 14
        return v_Nest
    }()

    private let iconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.tintColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.8)
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    /// 聚焦时左侧彩色竖条（辅助色）
    private let focusBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.secondaryGradientStart_Nest
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
    ///   - placeholder: 占位文字
    ///   - icon: SF Symbol 图标名
    ///   - isSecure: 是否密码模式
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

    /// 切换密码明文 / 密文
    @objc private func toggleVisibility_Nest() {
        toggleBtn_Nest.isSelected.toggle()
        textField_Nest.isSecureTextEntry = !toggleBtn_Nest.isSelected
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// 更新聚焦视觉状态（辅助渐变色系）
    /// - Parameter focused: 是否正在编辑
    func setFocused_Nest(_ focused: Bool) {
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut) {
            self.layer.borderColor = focused
                ? ColorConfig_Nest.secondaryGradientStart_Nest.cgColor
                : ColorConfig_Nest.border_Nest.cgColor
            self.layer.shadowColor   = focused
                ? ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.12).cgColor
                : UIColor.clear.cgColor
            self.layer.shadowRadius  = focused ? 8 : 0
            self.layer.shadowOpacity = focused ? 1 : 0
            self.layer.shadowOffset  = CGSize(width: 0, height: 3)
            self.iconBadge_Nest.backgroundColor = focused
                ? ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.18)
                : ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.1)
            self.iconView_Nest.tintColor = focused
                ? ColorConfig_Nest.secondaryGradientStart_Nest
                : ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.7)
            self.focusBar_Nest.alpha = focused ? 1 : 0
            self.backgroundColor = focused
                ? ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.02)
                : ColorConfig_Nest.backgroundPrimary_Nest
        }
    }
}

// MARK: - RegisterPasswordStrengthView_Nest
/// 密码强度指示组件
/// 核心作用：三段进度条（弱/一般/强）+ 强度文字，随密码输入实时变化
/// 设计：三段等宽横条，颜色由红→橙→绿渐变；文字标签显示当前强度等级
private class RegisterPasswordStrengthView_Nest: UIView {

    private let seg1_Nest = UIView()
    private let seg2_Nest = UIView()
    private let seg3_Nest = UIView()

    private let strengthLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.text = "Password strength"
        lbl_Nest.textAlignment = .right
        return lbl_Nest
    }()

    // 空状态灰色
    private let emptyColor_Nest  = UIColor(hexstring_Nest: "#E2E8F0")
    // 弱：红
    private let weakColor_Nest   = UIColor(hexstring_Nest: "#FC8181")
    // 一般：橙
    private let fairColor_Nest   = UIColor(hexstring_Nest: "#F6AD55")
    // 强：绿
    private let strongColor_Nest = UIColor(hexstring_Nest: "#68D391")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Nest() {
        let segs_Nest = [seg1_Nest, seg2_Nest, seg3_Nest]
        let segStack_Nest = UIStackView(arrangedSubviews: segs_Nest)
        segStack_Nest.axis = .horizontal
        segStack_Nest.spacing = 5
        segStack_Nest.distribution = .fillEqually

        segs_Nest.forEach { seg_Nest in
            seg_Nest.backgroundColor = emptyColor_Nest
            seg_Nest.layer.cornerRadius = 2
        }

        addSubview(segStack_Nest)
        addSubview(strengthLabel_Nest)

        segStack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(4)
        }
        strengthLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(segStack_Nest.snp.bottom).offset(5)
            make_Nest.trailing.equalToSuperview()
            make_Nest.bottom.equalToSuperview()
        }
    }

    /// 根据密码内容更新强度颜色与文字
    /// - Parameter password: 当前密码明文（不对内容做校验，仅按长度判断强弱）
    func update_Nest(password: String) {
        let len_Nest = password.count
        let (color_Nest, level_Nest, text_Nest): (UIColor, Int, String)
        switch len_Nest {
        case 0:         (color_Nest, level_Nest, text_Nest) = (emptyColor_Nest,  0, "Password strength")
        case 1...3:     (color_Nest, level_Nest, text_Nest) = (weakColor_Nest,   1, "Weak")
        case 4...7:     (color_Nest, level_Nest, text_Nest) = (fairColor_Nest,   2, "Fair")
        default:        (color_Nest, level_Nest, text_Nest) = (strongColor_Nest, 3, "Strong")
        }
        UIView.animate(withDuration: 0.25) {
            self.seg1_Nest.backgroundColor = level_Nest >= 1 ? color_Nest : self.emptyColor_Nest
            self.seg2_Nest.backgroundColor = level_Nest >= 2 ? color_Nest : self.emptyColor_Nest
            self.seg3_Nest.backgroundColor = level_Nest >= 3 ? color_Nest : self.emptyColor_Nest
            self.strengthLabel_Nest.textColor = level_Nest == 0
                ? ColorConfig_Nest.textPlaceholder_Nest
                : color_Nest
        }
        strengthLabel_Nest.text = text_Nest
    }
}
