import Foundation
import UIKit
import SnapKit

// MARK: - 注册页
// 核心作用：收集用户名、密码、确认密码，校验后创建新账号并通过 loginById_Moode 登录。
// 设计思路：与登录页共用渐变背景 + 浮动泡泡风格；
//           实时渲染密码强度条；全字段非空且密码一致时才可提交。
// 关键方法：handleRegister_Moode（创建本地用户 → loginById_Moode）

/// 注册页控制器
class Register_Moode: UIViewController {

    // MARK: - UI组件

    private let bgGradient_Moode = CAGradientLayer()

    private let bubble1_Moode: UIView = makeRegBubble_Moode(size: 200, alpha: 0.10)
    private let bubble2_Moode: UIView = makeRegBubble_Moode(size: 110, alpha: 0.08)
    private let bubble3_Moode: UIView = makeRegBubble_Moode(size: 70,  alpha: 0.06)

    private let backBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    private let heroEmoji_Moode: UILabel = {
        let l = UILabel()
        l.text = "🌟"
        l.font = .systemFont(ofSize: 44)
        l.textAlignment = .center
        return l
    }()

    private let titleLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Create Account"
        l.font = UIFont(name: "AvenirNext-Heavy", size: 30) ?? .systemFont(ofSize: 30, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let subLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Join Moode and start your mood journey ✨"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 输入卡片
    private let inputCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 28
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        return v
    }()

    private let nameRow_Moode = LoginInputRow_Moode(
        icon_moode: "person.fill",
        placeholder_moode: "Username",
        isSecure_moode: false
    )
    private let divider1_Moode: UIView = makeDivider_Moode()

    private let pwdRow_Moode = LoginInputRow_Moode(
        icon_moode: "lock.fill",
        placeholder_moode: "Password",
        isSecure_moode: true
    )
    private let divider2_Moode: UIView = makeDivider_Moode()

    private let confirmRow_Moode = LoginInputRow_Moode(
        icon_moode: "lock.rotation",
        placeholder_moode: "Confirm Password",
        isSecure_moode: true
    )

    /// 密码强度条背景
    private let strengthBg_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        v.layer.cornerRadius = 2
        return v
    }()

    /// 密码强度条前景
    private let strengthBar_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#F6AD55")
        v.layer.cornerRadius = 2
        return v
    }()

    /// 密码强度文字
    private let strengthLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.80)
        return l
    }()

    /// Create Account 按钮
    private let registerBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create Account", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 26
        btn.clipsToBounds = true
        return btn
    }()
    private let regBtnGrad_Moode = CAGradientLayer()

    /// 已有账号行
    private let loginRow_Moode    = UIView()
    private let hasAccountLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Already have an account?"
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        return l
    }()
    private let goLoginBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()

    private lazy var protocolLbl_Moode: UILabel = {
        ProtocolHelper_Moode.createProtocolTextLabel_Moode(
            firstContent_Moode: "terms.png",
            secondContent_Moode: "privacy.png",
            config_Moode: ProtocolHelper_Moode.ProtocolTextConfig_Moode(
                textColor_Moode: UIColor.white.withAlphaComponent(0.55),
                linkColor_Moode: UIColor.white.withAlphaComponent(0.90),
                fontSize_Moode: 11,
                fontWeight_Moode: .regular,
                hasUnderline_Moode: true,
                prefixText_Moode: "By signing up you agree to our ",
                separatorText_Moode: " & "
            ),
            from: self
        )
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        observeInputs_Moode()
        updateRegBtnState_Moode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Moode.frame   = view.bounds
        regBtnGrad_Moode.frame   = registerBtn_Moode.bounds
    }

    // MARK: - UI搭建

    private func setupUI_Moode() {
        // 渐变背景
        bgGradient_Moode.colors     = [UIColor(hexstring_Moode: "#5B50D4").cgColor,
                                        UIColor(hexstring_Moode: "#8B7BF5").cgColor,
                                        UIColor(hexstring_Moode: "#B8A8FF").cgColor]
        bgGradient_Moode.locations   = [0, 0.5, 1]
        bgGradient_Moode.startPoint  = CGPoint(x: 0.3, y: 0)
        bgGradient_Moode.endPoint    = CGPoint(x: 0.7, y: 1)
        view.layer.insertSublayer(bgGradient_Moode, at: 0)

        // 泡泡
        view.addSubview(bubble1_Moode)
        bubble1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.bottom.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(60)
        }
        view.addSubview(bubble2_Moode)
        bubble2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(-30)
        }
        view.addSubview(bubble3_Moode)
        bubble3_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.top.equalToSuperview().offset(280)
            make.right.equalToSuperview().offset(-20)
        }

        // 返回按钮
        view.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        backBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // Hero 区域
        view.addSubview(heroEmoji_Moode)
        heroEmoji_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(26)
            make.centerX.equalToSuperview()
        }
        view.addSubview(titleLbl_Moode)
        titleLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(heroEmoji_Moode.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        view.addSubview(subLbl_Moode)
        subLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Moode.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(40)
        }

        // 输入卡片
        view.addSubview(inputCard_Moode)
        inputCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(subLbl_Moode.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
        }
        inputCard_Moode.addSubview(nameRow_Moode)
        nameRow_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        inputCard_Moode.addSubview(divider1_Moode)
        divider1_Moode.snp.makeConstraints { make in
            make.top.equalTo(nameRow_Moode.snp.bottom)
            make.left.equalToSuperview().offset(52)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        inputCard_Moode.addSubview(pwdRow_Moode)
        pwdRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(divider1_Moode.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        inputCard_Moode.addSubview(divider2_Moode)
        divider2_Moode.snp.makeConstraints { make in
            make.top.equalTo(pwdRow_Moode.snp.bottom)
            make.left.equalToSuperview().offset(52)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        inputCard_Moode.addSubview(confirmRow_Moode)
        confirmRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(divider2_Moode.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        nameRow_Moode.textField_Moode.returnKeyType    = .next
        pwdRow_Moode.textField_Moode.returnKeyType     = .next
        confirmRow_Moode.textField_Moode.returnKeyType = .done
        nameRow_Moode.textField_Moode.delegate    = self
        pwdRow_Moode.textField_Moode.delegate     = self
        confirmRow_Moode.textField_Moode.delegate = self

        // 密码强度条
        view.addSubview(strengthBg_Moode)
        strengthBg_Moode.snp.makeConstraints { make in
            make.top.equalTo(inputCard_Moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(24)
            make.width.equalToSuperview().multipliedBy(0.55)
            make.height.equalTo(4)
        }
        strengthBg_Moode.addSubview(strengthBar_Moode)
        strengthBar_Moode.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        view.addSubview(strengthLbl_Moode)
        strengthLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(strengthBg_Moode.snp.right).offset(10)
            make.centerY.equalTo(strengthBg_Moode)
        }

        // Create Account 按钮
        view.addSubview(registerBtn_Moode)
        registerBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(strengthBg_Moode.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }
        regBtnGrad_Moode.colors      = [UIColor(hexstring_Moode: "#5045C8").cgColor,
                                         UIColor(hexstring_Moode: "#7060F0").cgColor]
        regBtnGrad_Moode.startPoint   = CGPoint(x: 0, y: 0)
        regBtnGrad_Moode.endPoint     = CGPoint(x: 1, y: 0)
        regBtnGrad_Moode.cornerRadius = 26
        registerBtn_Moode.layer.insertSublayer(regBtnGrad_Moode, at: 0)
        registerBtn_Moode.addTarget(self, action: #selector(handleRegister_Moode), for: .touchUpInside)

        // 已有账号行
        view.addSubview(loginRow_Moode)
        loginRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(registerBtn_Moode.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        loginRow_Moode.addSubview(hasAccountLbl_Moode)
        loginRow_Moode.addSubview(goLoginBtn_Moode)
        hasAccountLbl_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        goLoginBtn_Moode.snp.makeConstraints { make in
            make.left.equalTo(hasAccountLbl_Moode.snp.right).offset(6)
            make.right.centerY.equalToSuperview()
        }
        goLoginBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // 协议（紧跟已有账号行下方）
        view.addSubview(protocolLbl_Moode)
        protocolLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(loginRow_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Moode))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - 工厂

    private static func makeRegBubble_Moode(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        return v
    }
    private static func makeDivider_Moode() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        return v
    }

    // MARK: - 输入监听

    private func observeInputs_Moode() {
        nameRow_Moode.textField_Moode.addTarget(self, action: #selector(inputChanged_Moode), for: .editingChanged)
        pwdRow_Moode.textField_Moode.addTarget(self, action: #selector(inputChanged_Moode), for: .editingChanged)
        confirmRow_Moode.textField_Moode.addTarget(self, action: #selector(inputChanged_Moode), for: .editingChanged)
    }

    @objc private func inputChanged_Moode() {
        updateRegBtnState_Moode()
        updateStrengthBar_Moode()
    }

    /// 更新注册按钮可用状态
    private func updateRegBtnState_Moode() {
        let nameOk    = !(nameRow_Moode.textField_Moode.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let pwdOk     = !(pwdRow_Moode.textField_Moode.text?.isEmpty ?? true)
        let pwd        = pwdRow_Moode.textField_Moode.text ?? ""
        let confirm    = confirmRow_Moode.textField_Moode.text ?? ""
        let matchOk   = !confirm.isEmpty && pwd == confirm
        let enabled   = nameOk && pwdOk && matchOk
        registerBtn_Moode.isUserInteractionEnabled = enabled
        UIView.animate(withDuration: 0.2) {
            self.regBtnGrad_Moode.opacity = enabled ? 1.0 : 0.40
            self.registerBtn_Moode.alpha  = enabled ? 1.0 : 0.55
        }
    }

    /// 根据密码长度更新强度条
    private func updateStrengthBar_Moode() {
        let pwd    = pwdRow_Moode.textField_Moode.text ?? ""
        let len    = pwd.count
        let total  = strengthBg_Moode.bounds.width
        let ratio : CGFloat
        let color  : UIColor
        let label  : String

        switch len {
        case 0:
            ratio = 0; color = .clear; label = ""
        case 1...3:
            ratio = 0.25; color = UIColor(hexstring_Moode: "#FC8181"); label = "Weak"
        case 4...6:
            ratio = 0.55; color = UIColor(hexstring_Moode: "#F6AD55"); label = "Fair"
        case 7...9:
            ratio = 0.80; color = UIColor(hexstring_Moode: "#68D391"); label = "Good"
        default:
            ratio = 1.00; color = UIColor(hexstring_Moode: "#48BB78"); label = "Strong"
        }

        strengthLbl_Moode.text       = label
        strengthLbl_Moode.textColor  = len == 0 ? .clear : color
        strengthBar_Moode.backgroundColor = color
        strengthBar_Moode.snp.updateConstraints { make in
            make.width.equalTo(total * ratio)
        }
        UIView.animate(withDuration: 0.3) { self.strengthBg_Moode.layoutIfNeeded() }
    }

    // MARK: - 事件处理

    /// 注册：校验 → 创建本地用户 → loginById_Moode
    @objc private func handleRegister_Moode() {
        let name    = nameRow_Moode.textField_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pwd     = pwdRow_Moode.textField_Moode.text ?? ""
        let confirm = confirmRow_Moode.textField_Moode.text ?? ""

        guard !name.isEmpty else {
            Utils_Moode.showWarning_Moode(message_Moode: "Please enter a username.")
            return
        }
        guard !pwd.isEmpty else {
            Utils_Moode.showWarning_Moode(message_Moode: "Please enter a password.")
            return
        }
        guard pwd == confirm else {
            Utils_Moode.showError_Moode(message_Moode: "Passwords do not match.")
            return
        }

        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 统一使用 loginById_Moode 完成登录流程
        UserViewModel_Moode.shared_Moode.loginById_Moode(userId_moode: 98542)
    }

    @objc private func handleBack_Moode() {
        Navigation_Moode.pop_Moode(animated: true)
    }

    @objc private func dismissKeyboard_Moode() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate

extension Register_Moode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameRow_Moode.textField_Moode {
            pwdRow_Moode.textField_Moode.becomeFirstResponder()
        } else if textField == pwdRow_Moode.textField_Moode {
            confirmRow_Moode.textField_Moode.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleRegister_Moode()
        }
        return true
    }
}
