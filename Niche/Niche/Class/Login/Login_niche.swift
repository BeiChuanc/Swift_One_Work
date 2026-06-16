import Foundation
import UIKit
import SnapKit

// MARK: 登录页面

/// 登录页面视图控制器
/// 功能：提供用户名/密码登录、Apple登录入口、协议展示
/// 设计：全屏沉浸式渐变背景 + 装饰气泡 + Logo 圆形浮卡 + 图标输入行 + 玻璃卡片
/// 关键：登录方法只调用 UserViewModel 的 loginById 方法
class Login_Niche: UIViewController {

    // MARK: - UI 组件 / 背景层

    /// 全屏渐变背景
    private let _bgView_niche = UIView()

    /// 装饰气泡
    private let _orb1_niche = makeOrb_Niche(size: 180, alpha: 0.12)
    private let _orb2_niche = makeOrb_Niche(size: 100, alpha: 0.08)
    private let _orb3_niche = makeOrb_Niche(size: 60,  alpha: 0.10)

    /// 关闭按钮
    private let _closeButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn_niche.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = UIColor.white.withValues(alpha: 0.80)
        return btn_niche
    }()

    // MARK: - UI 组件 / Logo 区域

    /// Logo 圆形背景（在背景上漂浮）
    private let _logoBg_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.22)
        v_niche.layer.cornerRadius = 42
        v_niche.layer.borderWidth = 1.5
        v_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.35).cgColor
        return v_niche
    }()

    private let _logoView_niche: UIImageView = {
        let iv_niche = UIImageView()
        iv_niche.image = UIImage(systemName: "flame.fill")
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    private let _appNameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "NICHE"
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.9)
        l_niche.textAlignment = .center
        l_niche.letterSpacing_Login_Niche(3)
        return l_niche
    }()

    private let _titleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Welcome Back"
        l_niche.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        return l_niche
    }()

    private let _subtitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Your tribe is waiting for you ✦"
        l_niche.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.80)
        l_niche.textAlignment = .center
        return l_niche
    }()

    // MARK: - UI 组件 / 表单卡片

    private let _formCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 30
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#6B21A8").withValues(alpha: 0.20).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 12)
        v_niche.layer.shadowRadius = 28
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    /// 用户名输入行
    private let _usernameField_niche: UITextField = makeField_Niche(placeholder: "Username")
    /// 密码输入行
    private let _passwordField_niche: UITextField = {
        let tf_niche = makeField_Niche(placeholder: "Password")
        tf_niche.isSecureTextEntry = true
        return tf_niche
    }()

    /// 登录按钮（渐变）
    private let _loginButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 18
        btn_niche.clipsToBounds = true
        return btn_niche
    }()
    private var _loginBtnGrad_niche: CAGradientLayer?

    private let _loginBtnIconIV_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        iv_niche.image = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        iv_niche.isUserInteractionEnabled = false
        return iv_niche
    }()

    private let _loginBtnLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Sign In"
        l_niche.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l_niche.textColor = .white
        l_niche.isUserInteractionEnabled = false
        return l_niche
    }()

    /// 分隔线区域
    private let _orDivider_niche = UIView()

    /// Apple 登录按钮
    private var _appleLoginView_niche: AppleLoginBt_Niche!

    /// 注册入口
    private let _registerButton_niche: UIButton = {
        let btn_niche = UIButton(type: .system)
        btn_niche.setTitle("New here? Join the tribe →", for: .normal)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn_niche.setTitleColor(ColorConfig_Niche.primaryGradientStart_Niche, for: .normal)
        return btn_niche
    }()

    /// 协议
    private var _protocolLabel_niche: UILabel!

    // MARK: - Apple 登录管理器

    private var _appleManager_niche: AppleLoginManager_Niche!

    // MARK: - 辅助工厂

    private static func makeOrb_Niche(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: alpha)
        v_niche.layer.cornerRadius = size / 2
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }

    private static func makeField_Niche(placeholder: String) -> UITextField {
        let tf_niche = UITextField()
        tf_niche.placeholder = placeholder
        tf_niche.font = UIFont.systemFont(ofSize: 15)
        tf_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tf_niche.backgroundColor = .clear
        tf_niche.autocapitalizationType = .none
        tf_niche.autocorrectionType = .no
        return tf_niche
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        _appleManager_niche = AppleLoginManager_Niche(viewController_Niche: self)
        setupUI_Niche()
        setupActions_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshBgGradient_Niche()
        refreshLoginBtnGrad_Niche()
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#6B21A8")

        // ── 全屏渐变背景 ──
        view.addSubview(_bgView_niche)
        _bgView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 装饰气泡
        _bgView_niche.addSubview(_orb1_niche)
        _orb1_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(40)
            make.width.height.equalTo(180)
        }
        _bgView_niche.addSubview(_orb2_niche)
        _orb2_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().multipliedBy(0.55).offset(0)
            make.leading.equalToSuperview().offset(-30)
            make.width.height.equalTo(100)
        }
        _bgView_niche.addSubview(_orb3_niche)
        _orb3_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.leading.equalToSuperview().offset(30)
            make.width.height.equalTo(60)
        }

        // ── 关闭按钮 ──
        view.addSubview(_closeButton_niche)
        _closeButton_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }

        // ── Logo 圆形卡 ──
        view.addSubview(_logoBg_niche)
        _logoBg_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(84)
        }
        _logoBg_niche.addSubview(_logoView_niche)
        _logoView_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }

        // NICHE 字样
        view.addSubview(_appNameLabel_niche)
        _appNameLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_logoBg_niche.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // 标题
        view.addSubview(_titleLabel_niche)
        _titleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_appNameLabel_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 副标题
        view.addSubview(_subtitleLabel_niche)
        _subtitleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // ── 表单卡片 ──
        view.addSubview(_formCard_niche)
        _formCard_niche.snp.makeConstraints { make in
            make.top.equalTo(_subtitleLabel_niche.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-14)
        }

        buildFormContent_Niche()
    }

    private func buildFormContent_Niche() {
        // 用户名输入行
        let userRow_niche = buildInputRow_Niche(
            icon: "person.fill", color: ColorConfig_Niche.primaryGradientStart_Niche,
            field: _usernameField_niche
        )
        _formCard_niche.addSubview(userRow_niche)
        userRow_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        // 分割线
        let div1_niche = makeDivider_Niche()
        _formCard_niche.addSubview(div1_niche)
        div1_niche.snp.makeConstraints { make in
            make.top.equalTo(userRow_niche.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(0.5)
        }

        // 密码输入行
        let passRow_niche = buildInputRow_Niche(
            icon: "lock.fill", color: ColorConfig_Niche.primaryGradientEnd_Niche,
            field: _passwordField_niche
        )
        _formCard_niche.addSubview(passRow_niche)
        passRow_niche.snp.makeConstraints { make in
            make.top.equalTo(div1_niche.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }

        // 登录按钮
        _formCard_niche.addSubview(_loginButton_niche)
        _loginButton_niche.addSubview(_loginBtnIconIV_niche)
        _loginButton_niche.addSubview(_loginBtnLabel_niche)
        _loginButton_niche.snp.makeConstraints { make in
            make.top.equalTo(passRow_niche.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }
        _loginBtnLabel_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        _loginBtnIconIV_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_loginBtnLabel_niche.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // Or 分隔
        buildOrDivider_Niche()

        // Apple 登录
        _appleLoginView_niche = AppleLoginBt_Niche { [weak self] in
            self?.handleAppleLogin_Niche()
        }
        _formCard_niche.addSubview(_appleLoginView_niche)
        _appleLoginView_niche.snp.makeConstraints { make in
            make.top.equalTo(_orDivider_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(48)
        }

        // 注册入口
        _formCard_niche.addSubview(_registerButton_niche)
        _registerButton_niche.snp.makeConstraints { make in
            make.top.equalTo(_appleLoginView_niche.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 协议
        _protocolLabel_niche = ProtocolHelper_Niche.createProtocolTextLabel_Niche(
            firstContent_Niche: "terms.png",
            secondContent_Niche: "privacy.png",
            from: self
        )
        _formCard_niche.addSubview(_protocolLabel_niche)
        _protocolLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_registerButton_niche.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 构建图标输入行
    private func buildInputRow_Niche(icon: String, color: UIColor, field: UITextField) -> UIView {
        let row_niche = UIView()

        let iconBg_niche = UIView()
        iconBg_niche.backgroundColor = color.withValues(alpha: 0.10)
        iconBg_niche.layer.cornerRadius = 10
        row_niche.addSubview(iconBg_niche)
        iconBg_niche.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }

        let iconIV_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconIV_niche.image = UIImage(systemName: icon, withConfiguration: cfg_niche)
        iconIV_niche.tintColor = color
        iconIV_niche.contentMode = .scaleAspectFit
        iconBg_niche.addSubview(iconIV_niche)
        iconIV_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        field.placeHolderTextColor_Niche(ColorConfig_Niche.textPlaceholder_Niche)
        row_niche.addSubview(field)
        field.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_niche.snp.trailing).offset(12)
            make.trailing.centerY.equalToSuperview()
        }

        return row_niche
    }

    private func buildOrDivider_Niche() {
        _formCard_niche.addSubview(_orDivider_niche)
        _orDivider_niche.snp.makeConstraints { make in
            make.top.equalTo(_loginButton_niche.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(16)
        }

        let leftLine_niche = makeDivider_Niche()
        let rightLine_niche = makeDivider_Niche()
        let orLabel_niche = UILabel()
        orLabel_niche.text = "or"
        orLabel_niche.font = UIFont.systemFont(ofSize: 12)
        orLabel_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche

        _orDivider_niche.addSubview(orLabel_niche)
        _orDivider_niche.addSubview(leftLine_niche)
        _orDivider_niche.addSubview(rightLine_niche)

        orLabel_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        leftLine_niche.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(orLabel_niche.snp.leading).offset(-10)
            make.height.equalTo(0.5)
        }
        rightLine_niche.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(orLabel_niche.snp.trailing).offset(10)
            make.height.equalTo(0.5)
        }
    }

    private func makeDivider_Niche() -> UIView {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.divider_Niche
        return v_niche
    }

    // MARK: - 渐变刷新

    private func refreshBgGradient_Niche() {
        _bgView_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_bgView_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _bgView_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#6B21A8").cgColor,
            UIColor(hexstring_Niche: "#9333EA").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#93C5FD").cgColor
        ]
        grad_niche.locations = [0, 0.35, 0.70, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint   = CGPoint(x: 1, y: 1)
        _bgView_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshLoginBtnGrad_Niche() {
        guard !_loginButton_niche.bounds.isEmpty else { return }
        if _loginBtnGrad_niche == nil {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _loginButton_niche.bounds)
            grad_niche.cornerRadius = 18
            _loginButton_niche.layer.insertSublayer(grad_niche, at: 0)
            _loginBtnGrad_niche = grad_niche
        }
        _loginBtnGrad_niche?.frame = _loginButton_niche.bounds
    }

    // MARK: - 行为绑定

    private func setupActions_Niche() {
        _loginButton_niche.addTarget(self, action: #selector(handleLogin_Niche), for: .touchUpInside)
        _registerButton_niche.addTarget(self, action: #selector(handleRegister_Niche), for: .touchUpInside)
        _closeButton_niche.addTarget(self, action: #selector(handleClose_Niche), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func handleLogin_Niche() {
        let username_niche = _usernameField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password_niche = _passwordField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !username_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please enter your username")
            _usernameField_niche.animateShake_Niche()
            return
        }
        guard !password_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please enter your password")
            _passwordField_niche.animateShake_Niche()
            return
        }

        _loginButton_niche.animatePressDown_Niche()

        Task { @MainActor in
            UserViewModel_Niche.shared_Niche.loginById_Niche(userId_niche: 845614)
        }
    }

    @objc private func handleRegister_Niche() {
        Navigation_Niche.toRegister_Niche(style_niche: .push_niche)
    }

    @objc private func handleAppleLogin_Niche() {
        _appleManager_niche.startAppleLogin_Niche { [weak self] _ in
            let userId_niche = LocalData_Niche.shared_Niche.userList_Niche.first?.userId_Niche ?? 10
            Task { @MainActor in
                UserViewModel_Niche.shared_Niche.loginById_Niche(userId_niche: userId_niche)
                Navigation_Niche.dismiss_Niche()
            }
            _ = self
        } failure_Niche: { _ in }
    }

    @objc private func handleClose_Niche() {
        Navigation_Niche.dismiss_Niche()
    }
}

// MARK: - UILabel 字间距辅助扩展（仅本文件作用域）

private extension UILabel {
    func letterSpacing_Login_Niche(_ spacing: CGFloat) {
        guard let text_niche = text else { return }
        attributedText = NSAttributedString(string: text_niche, attributes: [
            .kern: spacing,
            .font: font as Any,
            .foregroundColor: textColor as Any
        ])
    }
}
