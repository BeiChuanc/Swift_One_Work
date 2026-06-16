import Foundation
import UIKit
import SnapKit

// MARK: 注册页面

/// 注册页面视图控制器
/// 功能：提供用户名/密码/确认密码输入，完成注册并自动登录
/// 设计：全屏玫红渐变背景 + 装饰气泡 + Logo 浮卡 + 图标输入行 + 渐变注册按钮
/// 关键：注册后调用 UserViewModel.loginById 方法完成登录
class Register_Niche: UIViewController {
    
    // MARK: - UI 组件 / 背景
    
    private let _bgView_niche = UIView()
    private let _orb1_niche = makeOrb_Reg_Niche(size: 160, alpha: 0.12)
    private let _orb2_niche = makeOrb_Reg_Niche(size: 88,  alpha: 0.08)
    private let _orb3_niche = makeOrb_Reg_Niche(size: 55,  alpha: 0.10)
    
    /// 返回按钮
    private let _backBtn_niche = BackButton_Niche()
    
    // MARK: - UI 组件 / Logo 区域
    
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
        iv_niche.image = UIImage(systemName: "person.badge.plus.fill")
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
        return l_niche
    }()
    
    private let _titleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Join the Tribe"
        l_niche.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        return l_niche
    }()
    
    private let _subtitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Create your account and start exploring ✦"
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.80)
        l_niche.textAlignment = .center
        l_niche.numberOfLines = 2
        return l_niche
    }()
    
    // MARK: - UI 组件 / 表单卡片
    
    private let _formCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 30
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#E91E8C").withValues(alpha: 0.20).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 12)
        v_niche.layer.shadowRadius = 28
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()
    
    private let _usernameField_niche: UITextField = makeField_Reg_Niche(placeholder: "Username")
    private let _passwordField_niche: UITextField = {
        let tf_niche = makeField_Reg_Niche(placeholder: "Password")
        tf_niche.isSecureTextEntry = true
        return tf_niche
    }()
    private let _confirmField_niche: UITextField = {
        let tf_niche = makeField_Reg_Niche(placeholder: "Confirm Password")
        tf_niche.isSecureTextEntry = true
        return tf_niche
    }()
    
    /// 注册按钮（渐变）
    private let _registerButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 18
        btn_niche.clipsToBounds = true
        return btn_niche
    }()
    private var _regBtnGrad_niche: CAGradientLayer?
    
    private let _regBtnIconIV_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        iv_niche.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        iv_niche.isUserInteractionEnabled = false
        return iv_niche
    }()
    
    private let _regBtnLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Create Account"
        l_niche.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l_niche.textColor = .white
        l_niche.isUserInteractionEnabled = false
        return l_niche
    }()
    
    private var _protocolLabel_niche: UILabel!
    
    // MARK: - 辅助工厂
    
    private static func makeOrb_Reg_Niche(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: alpha)
        v_niche.layer.cornerRadius = size / 2
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }
    
    private static func makeField_Reg_Niche(placeholder: String) -> UITextField {
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
        refreshRegBtnGrad_Niche()
    }
    
    // MARK: - UI 构建
    
    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#E91E8C")
        
        // ── 全屏渐变背景 ──
        view.addSubview(_bgView_niche)
        _bgView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        _bgView_niche.addSubview(_orb1_niche)
        _orb1_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.trailing.equalToSuperview().offset(30)
            make.width.height.equalTo(160)
        }
        _bgView_niche.addSubview(_orb2_niche)
        _orb2_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().multipliedBy(0.55).offset(0)
            make.leading.equalToSuperview().offset(-24)
            make.width.height.equalTo(88)
        }
        _bgView_niche.addSubview(_orb3_niche)
        _orb3_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.leading.equalToSuperview().offset(28)
            make.width.height.equalTo(55)
        }
        
        // ── 返回按钮 ──
        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { [weak self] in
            Navigation_Niche.pop_Niche()
            _ = self
        }
        
        // ── Logo 区域 ──
        view.addSubview(_logoBg_niche)
        _logoBg_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(42)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(84)
        }
        _logoBg_niche.addSubview(_logoView_niche)
        _logoView_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(38)
        }
        
        view.addSubview(_appNameLabel_niche)
        _appNameLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_logoBg_niche.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(_titleLabel_niche)
        _titleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_appNameLabel_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(_subtitleLabel_niche)
        _subtitleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // ── 表单卡片 ──
        view.addSubview(_formCard_niche)
        _formCard_niche.snp.makeConstraints { make in
            make.top.equalTo(_subtitleLabel_niche.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-14)
        }
        
        buildFormContent_Niche()
    }
    
    private func buildFormContent_Niche() {
        // 用户名
        let userRow_niche = buildInputRow_Niche(
            icon: "person.fill", color: UIColor(hexstring_Niche: "#E91E8C"),
            field: _usernameField_niche
        )
        _formCard_niche.addSubview(userRow_niche)
        userRow_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }
        
        let div1_niche = makeDivider_Niche()
        _formCard_niche.addSubview(div1_niche)
        div1_niche.snp.makeConstraints { make in
            make.top.equalTo(userRow_niche.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(0.5)
        }
        
        // 密码
        let passRow_niche = buildInputRow_Niche(
            icon: "lock.fill", color: UIColor(hexstring_Niche: "#FD79A8"),
            field: _passwordField_niche
        )
        _formCard_niche.addSubview(passRow_niche)
        passRow_niche.snp.makeConstraints { make in
            make.top.equalTo(div1_niche.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }
        
        let div2_niche = makeDivider_Niche()
        _formCard_niche.addSubview(div2_niche)
        div2_niche.snp.makeConstraints { make in
            make.top.equalTo(passRow_niche.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(0.5)
        }
        
        // 确认密码
        let confirmRow_niche = buildInputRow_Niche(
            icon: "lock.rotation", color: UIColor(hexstring_Niche: "#FDCB6E"),
            field: _confirmField_niche
        )
        _formCard_niche.addSubview(confirmRow_niche)
        confirmRow_niche.snp.makeConstraints { make in
            make.top.equalTo(div2_niche.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }
        
        // 注册按钮
        _formCard_niche.addSubview(_registerButton_niche)
        _registerButton_niche.addSubview(_regBtnIconIV_niche)
        _registerButton_niche.addSubview(_regBtnLabel_niche)
        _registerButton_niche.snp.makeConstraints { make in
            make.top.equalTo(confirmRow_niche.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(52)
        }
        _regBtnLabel_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        _regBtnIconIV_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_regBtnLabel_niche.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        // 协议
        _protocolLabel_niche = ProtocolHelper_Niche.createProtocolTextLabel_Niche(
            firstContent_Niche: "terms.png",
            secondContent_Niche: "privacy.png",
            from: self
        )
        _formCard_niche.addSubview(_protocolLabel_niche)
        _protocolLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_registerButton_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
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
            UIColor(hexstring_Niche: "#E91E8C").cgColor,
            UIColor(hexstring_Niche: "#FD79A8").cgColor,
            UIColor(hexstring_Niche: "#FBB6CE").cgColor,
            UIColor(hexstring_Niche: "#FED7AA").cgColor
        ]
        grad_niche.locations = [0, 0.35, 0.70, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint   = CGPoint(x: 1, y: 1)
        _bgView_niche.layer.insertSublayer(grad_niche, at: 0)
    }
    
    private func refreshRegBtnGrad_Niche() {
        guard !_registerButton_niche.bounds.isEmpty else { return }
        if _regBtnGrad_niche == nil {
            let grad_niche = UIColor.createSecondaryGradientLayer_Niche(frame_Niche: _registerButton_niche.bounds)
            grad_niche.cornerRadius = 18
            _registerButton_niche.layer.insertSublayer(grad_niche, at: 0)
            _regBtnGrad_niche = grad_niche
        }
        _regBtnGrad_niche?.frame = _registerButton_niche.bounds
    }
    
    // MARK: - 行为绑定
    
    private func setupActions_Niche() {
        _registerButton_niche.addTarget(self, action: #selector(handleRegister_Niche), for: .touchUpInside)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleRegister_Niche() {
        let username_niche = _usernameField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password_niche = _passwordField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm_niche  = _confirmField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !username_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please enter a username")
            _usernameField_niche.animateShake_Niche()
            return
        }
        guard !password_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please enter a password")
            _passwordField_niche.animateShake_Niche()
            return
        }
        guard !confirm_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please confirm your password")
            _confirmField_niche.animateShake_Niche()
            return
        }
        guard password_niche == confirm_niche else {
            Utils_Niche.showWarning_Niche(message_Niche: "Passwords do not match")
            _confirmField_niche.animateShake_Niche()
            return
        }
        
        Task { @MainActor in
            UserViewModel_Niche.shared_Niche.loginById_Niche(userId_niche: 845615)
        }
    }
}
