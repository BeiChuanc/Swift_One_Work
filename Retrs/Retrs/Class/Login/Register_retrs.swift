import Foundation
import UIKit
import SnapKit

// MARK: 注册页 - 重构版

/// 注册页控制器
/// 核心作用：用户名、密码、确认密码输入，注册并自动登录
/// 设计思路：与登录页统一渐变色系（薰衣草紫→天空蓝）+ 装饰气泡 + 表单卡片
class Register_Retrs: UIViewController {

    // MARK: - 属性

    private let userVM_Retrs = UserViewModel_Retrs.shared_Retrs

    /// 背景渐变
    private let bgGradLayer_Retrs = CAGradientLayer()

    /// 返回按钮
    private let backBtn_Retrs = UIButton(type: .system)

    /// 头部标题区
    private let headerWrap_Retrs   = UIView()
    private let headerIcon_Retrs   = UIImageView()
    private let headerTitle_Retrs  = UILabel()
    private let headerSub_Retrs    = UILabel()

    /// 表单卡片
    private let cardView_Retrs          = UIView()
    private let userField_Retrs         = UITextField()
    private let pwdField_Retrs          = UITextField()
    private let confirmPwdField_Retrs   = UITextField()
    private let registerBtn_Retrs       = UIButton(type: .system)
    private let registerGradLayer_Retrs = CAGradientLayer()
    private var protocolLabel_Retrs: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Retrs()
        setupBackButton_Retrs()
        setupHeader_Retrs()
        setupFormCard_Retrs()
        setupConstraints_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Retrs)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer_Retrs.frame       = view.bounds
        registerGradLayer_Retrs.frame = registerBtn_Retrs.bounds
    }

    // MARK: - 背景

    private func setupBackground_Retrs() {
        // 与登录页统一：薰衣草紫渐变（方向稍有差异增加变化感）
        bgGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#90CDF4").cgColor,
            UIColor(hexstring_Retrs: "#C3A6F8").cgColor
        ]
        bgGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        bgGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(bgGradLayer_Retrs, at: 0)

        // 装饰气泡（与登录页对称布局）
        addBgBubble_Retrs(alpha: 0.18, size: 220, top: -60, leading: -60)
        addBgBubble_Retrs(alpha: 0.12, size: 150, bottom: 140, trailing: -50)
        addBgBubble_Retrs(alpha: 0.09, size: 90,  top: 200, trailing: 20)
        addBgBubble_Retrs(alpha: 0.10, size: 70,  bottom: -20, leading: 50)
    }

    private func addBgBubble_Retrs(alpha: CGFloat, size: CGFloat,
                                    top: CGFloat? = nil, bottom: CGFloat? = nil,
                                    leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        let v_Retrs = UIView()
        v_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Retrs.layer.cornerRadius = size / 2
        view.addSubview(v_Retrs)
        v_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            if let t = top     { make.top.equalToSuperview().offset(t) }
            if let b = bottom  { make.bottom.equalToSuperview().offset(b) }
            if let l = leading { make.leading.equalToSuperview().offset(l) }
            if let r = trailing { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 返回按钮

    private func setupBackButton_Retrs() {
        backBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        backBtn_Retrs.layer.cornerRadius = 18
        backBtn_Retrs.layer.borderWidth  = 1
        backBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.4).cgColor
        backBtn_Retrs.setImage(
            UIImage(systemName: "arrow.left",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)),
            for: .normal
        )
        backBtn_Retrs.tintColor = .white
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        view.addSubview(backBtn_Retrs)
    }

    // MARK: - 头部标题区

    private func setupHeader_Retrs() {
        view.addSubview(headerWrap_Retrs)

        // 小相机图标
        headerIcon_Retrs.image = UIImage(
            systemName: "person.badge.plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        )
        headerIcon_Retrs.tintColor = UIColor.white.withAlphaComponent(0.9)
        headerIcon_Retrs.contentMode = .scaleAspectFit
        headerWrap_Retrs.addSubview(headerIcon_Retrs)

        headerTitle_Retrs.text = "Create Account"
        headerTitle_Retrs.font = UIFont.systemFont(ofSize: 32, weight: .black)
        headerTitle_Retrs.textColor = .white
        headerWrap_Retrs.addSubview(headerTitle_Retrs)

        headerSub_Retrs.text = "Join the CCD community today"
        headerSub_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        headerSub_Retrs.textColor = UIColor.white.withAlphaComponent(0.82)
        headerWrap_Retrs.addSubview(headerSub_Retrs)

        headerIcon_Retrs.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(36)
        }
        headerTitle_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerIcon_Retrs.snp.bottom).offset(8)
            make.leading.equalToSuperview()
        }
        headerSub_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerTitle_Retrs.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 表单卡片

    private func setupFormCard_Retrs() {
        cardView_Retrs.backgroundColor = .white
        cardView_Retrs.layer.cornerRadius = 28
        cardView_Retrs.clipsToBounds = false
        cardView_Retrs.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        cardView_Retrs.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView_Retrs.layer.shadowOpacity = 1
        cardView_Retrs.layer.shadowRadius  = 24
        view.addSubview(cardView_Retrs)

        // 卡片内小标题
        let formTitle_Retrs = UILabel()
        formTitle_Retrs.text = "Your Details"
        formTitle_Retrs.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        formTitle_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        cardView_Retrs.addSubview(formTitle_Retrs)
        formTitle_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(22)
        }

        // 渐变分隔线
        let line_Retrs = UIView()
        line_Retrs.backgroundColor = ColorConfig_Retrs.divider_Retrs
        cardView_Retrs.addSubview(line_Retrs)
        line_Retrs.snp.makeConstraints { make in
            make.top.equalTo(formTitle_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        // 三个输入框
        let purple_Retrs = ColorConfig_Retrs.primaryGradientStart_Retrs
        let blue_Retrs   = ColorConfig_Retrs.primaryGradientEnd_Retrs
        let green_Retrs  = UIColor(hexstring_Retrs: "#68D391")

        styleTextField_Retrs(userField_Retrs, placeholder_Retrs: "Choose a username",
                             icon_Retrs: "person.fill", accent_Retrs: purple_Retrs)
        styleTextField_Retrs(pwdField_Retrs, placeholder_Retrs: "Create a password",
                             icon_Retrs: "lock.fill", accent_Retrs: blue_Retrs)
        styleTextField_Retrs(confirmPwdField_Retrs, placeholder_Retrs: "Confirm your password",
                             icon_Retrs: "lock.shield.fill", accent_Retrs: green_Retrs)
        pwdField_Retrs.isSecureTextEntry        = true
        confirmPwdField_Retrs.isSecureTextEntry = true

        cardView_Retrs.addSubview(userField_Retrs)
        cardView_Retrs.addSubview(pwdField_Retrs)
        cardView_Retrs.addSubview(confirmPwdField_Retrs)

        userField_Retrs.snp.makeConstraints { make in
            make.top.equalTo(line_Retrs.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        pwdField_Retrs.snp.makeConstraints { make in
            make.top.equalTo(userField_Retrs.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        confirmPwdField_Retrs.snp.makeConstraints { make in
            make.top.equalTo(pwdField_Retrs.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        // 注册按钮（渐变胶囊，与登录页方向相反增加变化）
        registerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor
        ]
        registerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        registerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        registerGradLayer_Retrs.cornerRadius = 26
        registerBtn_Retrs.layer.insertSublayer(registerGradLayer_Retrs, at: 0)
        registerBtn_Retrs.layer.cornerRadius = 26
        registerBtn_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientEnd_Retrs
            .withAlphaComponent(0.4).cgColor
        registerBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        registerBtn_Retrs.layer.shadowOpacity = 1
        registerBtn_Retrs.layer.shadowRadius  = 12
        registerBtn_Retrs.setTitle("Create Account", for: .normal)
        registerBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        registerBtn_Retrs.setTitleColor(.white, for: .normal)
        registerBtn_Retrs.addTarget(self, action: #selector(registerTapped_Retrs), for: .touchUpInside)
        cardView_Retrs.addSubview(registerBtn_Retrs)
        registerBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(confirmPwdField_Retrs.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        // 协议文本
        let protLbl_Retrs = ProtocolHelper_Retrs.createProtocolTextLabel_Retrs(
            firstProtocol_Retrs: .terms_Retrs, firstContent_Retrs: "terms.png",
            secondProtocol_Retrs: .privacy_Retrs, secondContent_Retrs: "privacy.png",
            config_Retrs: .light_Retrs(), from: self
        )
        cardView_Retrs.addSubview(protLbl_Retrs)
        protocolLabel_Retrs = protLbl_Retrs
        protLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(registerBtn_Retrs.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    /// 统一输入框样式（浅紫背景 + 彩色图标）
    private func styleTextField_Retrs(_ field_Retrs: UITextField, placeholder_Retrs: String,
                                       icon_Retrs: String, accent_Retrs: UIColor) {
        field_Retrs.placeholder = placeholder_Retrs
        field_Retrs.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        field_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        field_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        field_Retrs.layer.cornerRadius = 16
        field_Retrs.autocorrectionType     = .no
        field_Retrs.autocapitalizationType = .none

        let pad_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 52))
        let iv_Retrs  = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
        )
        iv_Retrs.tintColor = accent_Retrs
        iv_Retrs.contentMode = .scaleAspectFit
        iv_Retrs.frame = CGRect(x: 14, y: 14, width: 18, height: 24)
        pad_Retrs.addSubview(iv_Retrs)
        field_Retrs.leftView = pad_Retrs
        field_Retrs.leftViewMode = .always
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        headerWrap_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 72)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        cardView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerWrap_Retrs.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
    }

    // MARK: - 事件

    @objc private func backTapped_Retrs()      { Navigation_Retrs.pop_Retrs() }
    @objc private func dismissKeyboard_Retrs() { view.endEditing(true) }

    @objc private func registerTapped_Retrs() {
        registerBtn_Retrs.animatePressDown_Retrs { [weak self] in self?.registerBtn_Retrs.animatePressUp_Retrs() }
        let username_Retrs    = userField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pwd_Retrs         = pwdField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let confirmPwd_Retrs  = confirmPwdField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !username_Retrs.isEmpty else {
            userField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please enter a username"); return
        }
        guard !pwd_Retrs.isEmpty else {
            pwdField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please enter a password"); return
        }
        guard pwd_Retrs == confirmPwd_Retrs else {
            confirmPwdField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Passwords do not match"); return
        }
        let newUserId_Retrs = abs(username_Retrs.hashValue % 1000 + 100)
        userVM_Retrs.loginById_Retrs(userId_retrs: newUserId_Retrs)
    }
}
