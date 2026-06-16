import Foundation
import UIKit
import SnapKit

// MARK: 登录页 - 重构版

/// 登录页控制器
/// 核心作用：提供用户名/密码登录、Apple登录、协议展示及跳转注册
/// 设计思路：全幅薰衣草渐变背景 + 装饰气泡 + 磨砂玻璃 Logo 区 + 白色圆角表单卡
class Login_Retrs: UIViewController {

    // MARK: - 属性

    private let userVM_Retrs = UserViewModel_Retrs.shared_Retrs

    /// 背景渐变层
    private let bgGradLayer_Retrs = CAGradientLayer()

    /// 关闭按钮
    private let closeBtn_Retrs = UIButton(type: .system)

    /// Logo 区域（磨砂玻璃卡）
    private let logoCard_Retrs     = UIView()
    private let logoIcon_Retrs     = UIImageView()
    private let logoLabel_Retrs    = UILabel()
    private let logoSubLabel_Retrs = UILabel()

    /// 表单卡片
    private let cardView_Retrs    = UIView()
    private let cardTitle_Retrs   = UILabel()
    private let cardSub_Retrs     = UILabel()
    private let userField_Retrs   = UITextField()
    private let pwdField_Retrs    = UITextField()
    private let loginBtn_Retrs    = UIButton(type: .system)
    private let loginGradLayer_Retrs = CAGradientLayer()
    private var appleLoginBt_Retrs: AppleLoginBt_Retrs?
    private var appleLoginManager_Retrs: AppleLoginManager_Retrs?
    private let toRegisterBtn_Retrs = UIButton(type: .system)
    private var protocolLabel_Retrs: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Retrs()
        setupCloseButton_Retrs()
        setupLogoArea_Retrs()
        setupFormCard_Retrs()
        setupConstraints_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Retrs)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer_Retrs.frame    = view.bounds
        loginGradLayer_Retrs.frame = loginBtn_Retrs.bounds
    }

    // MARK: - 背景

    /// 全幅渐变背景 + 装饰气泡
    private func setupBackground_Retrs() {
        bgGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#C3A6F8").cgColor,
            UIColor(hexstring_Retrs: "#7EC8E3").cgColor
        ]
        bgGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        bgGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(bgGradLayer_Retrs, at: 0)

        // 装饰气泡
        addBgBubble_Retrs(alpha: 0.18, size: 240, top: -80, trailing: -80)
        addBgBubble_Retrs(alpha: 0.12, size: 160, bottom: 120, leading: -60)
        addBgBubble_Retrs(alpha: 0.09, size: 100, bottom: -30, trailing: 40)
        addBgBubble_Retrs(alpha: 0.10, size: 80,  top: 160, leading: 20)
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

    // MARK: - 关闭按钮

    private func setupCloseButton_Retrs() {
        closeBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        closeBtn_Retrs.layer.cornerRadius = 18
        closeBtn_Retrs.layer.borderWidth  = 1
        closeBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.4).cgColor
        closeBtn_Retrs.setImage(
            UIImage(systemName: "xmark",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)),
            for: .normal
        )
        closeBtn_Retrs.tintColor = .white
        closeBtn_Retrs.addTarget(self, action: #selector(closeTapped_Retrs), for: .touchUpInside)
        view.addSubview(closeBtn_Retrs)
    }

    // MARK: - Logo 区域

    /// 磨砂玻璃感 Logo 卡（相机图标 + 品牌名 + 副标题）
    private func setupLogoArea_Retrs() {
        // 磨砂白色背景
        logoCard_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        logoCard_Retrs.layer.cornerRadius = 28
        logoCard_Retrs.layer.borderWidth  = 1
        logoCard_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.4).cgColor
        view.addSubview(logoCard_Retrs)

        // 相机图标
        logoIcon_Retrs.image = UIImage(systemName: "camera.vintage",
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .light))
        logoIcon_Retrs.tintColor = .white
        logoIcon_Retrs.contentMode = .scaleAspectFit
        logoCard_Retrs.addSubview(logoIcon_Retrs)

        // 品牌名
        logoLabel_Retrs.text = "Retrs"
        logoLabel_Retrs.font = UIFont(name: "Georgia-BoldItalic", size: 38)
            ?? UIFont.systemFont(ofSize: 38, weight: .black)
        logoLabel_Retrs.textColor = .white
        logoCard_Retrs.addSubview(logoLabel_Retrs)

        // 副标题
        logoSubLabel_Retrs.text = "Capture Retro Moments"
        logoSubLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        logoSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.82)
        logoCard_Retrs.addSubview(logoSubLabel_Retrs)

        logoIcon_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        logoLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(logoIcon_Retrs.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        logoSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(logoLabel_Retrs.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
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

        // 卡片内标题
        cardTitle_Retrs.text = "Welcome Back"
        cardTitle_Retrs.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        cardTitle_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        cardView_Retrs.addSubview(cardTitle_Retrs)

        cardSub_Retrs.text = "Sign in to continue your CCD journey"
        cardSub_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        cardSub_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        cardView_Retrs.addSubview(cardSub_Retrs)

        // 输入框
        styleTextField_Retrs(userField_Retrs, placeholder_Retrs: "Username", icon_Retrs: "person.fill",
                             accent_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
        styleTextField_Retrs(pwdField_Retrs, placeholder_Retrs: "Password", icon_Retrs: "lock.fill",
                             accent_Retrs: ColorConfig_Retrs.primaryGradientEnd_Retrs)
        pwdField_Retrs.isSecureTextEntry = true
        cardView_Retrs.addSubview(userField_Retrs)
        cardView_Retrs.addSubview(pwdField_Retrs)

        // 登录按钮（渐变胶囊）
        loginGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        loginGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        loginGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        loginGradLayer_Retrs.cornerRadius = 26
        loginBtn_Retrs.layer.insertSublayer(loginGradLayer_Retrs, at: 0)
        loginBtn_Retrs.layer.cornerRadius = 26
        loginBtn_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.4).cgColor
        loginBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginBtn_Retrs.layer.shadowOpacity = 1
        loginBtn_Retrs.layer.shadowRadius  = 12
        loginBtn_Retrs.setTitle("Sign In", for: .normal)
        loginBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        loginBtn_Retrs.setTitleColor(.white, for: .normal)
        loginBtn_Retrs.addTarget(self, action: #selector(loginTapped_Retrs), for: .touchUpInside)
        cardView_Retrs.addSubview(loginBtn_Retrs)

        // 分隔线（OR）
        let orRow_Retrs = buildOrDivider_Retrs()
        cardView_Retrs.addSubview(orRow_Retrs)
        orRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(loginBtn_Retrs.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }

        // Apple 登录
        appleLoginManager_Retrs = AppleLoginManager_Retrs(viewController_Retrs: self)
        let btn_Retrs = AppleLoginBt_Retrs { [weak self] in
            guard let self else { return }
            self.appleLoginManager_Retrs?.startAppleLogin_Retrs(
                success_Retrs: { [weak self] account_Retrs in
                    guard let self else { return }
                    let uid_Retrs = abs(account_Retrs.hashValue % 1000 + 200)
                    self.userVM_Retrs.loginById_Retrs(userId_retrs: uid_Retrs)
                },
                failure_Retrs: { msg_Retrs in Utils_Retrs.showWarning_Retrs(message_Retrs: msg_Retrs) }
            )
        }
        appleLoginBt_Retrs = btn_Retrs
        cardView_Retrs.addSubview(btn_Retrs)
        btn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(orRow_Retrs.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        // 去注册链接
        let attr_Retrs = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: ColorConfig_Retrs.textSecondary_Retrs
        ])
        attr_Retrs.append(NSAttributedString(string: "Sign Up →", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: ColorConfig_Retrs.primaryGradientStart_Retrs
        ]))
        toRegisterBtn_Retrs.setAttributedTitle(attr_Retrs, for: .normal)
        toRegisterBtn_Retrs.addTarget(self, action: #selector(toRegisterTapped_Retrs), for: .touchUpInside)
        cardView_Retrs.addSubview(toRegisterBtn_Retrs)
        toRegisterBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(btn_Retrs.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
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
            make.top.equalTo(toRegisterBtn_Retrs.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    /// 构建 "— OR —" 分隔行
    private func buildOrDivider_Retrs() -> UIView {
        let row_Retrs = UIView()
        let l_Retrs = UIView(); l_Retrs.backgroundColor = ColorConfig_Retrs.divider_Retrs
        let r_Retrs = UIView(); r_Retrs.backgroundColor = ColorConfig_Retrs.divider_Retrs
        let lbl_Retrs = UILabel()
        lbl_Retrs.text = "OR"
        lbl_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        row_Retrs.addSubview(l_Retrs); row_Retrs.addSubview(lbl_Retrs); row_Retrs.addSubview(r_Retrs)
        lbl_Retrs.snp.makeConstraints { make in make.center.equalToSuperview() }
        l_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(lbl_Retrs.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        r_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(lbl_Retrs.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        return row_Retrs
    }

    /// 统一输入框样式（浅紫背景 + 彩色图标 + 圆角）
    private func styleTextField_Retrs(_ field_Retrs: UITextField, placeholder_Retrs: String,
                                       icon_Retrs: String, accent_Retrs: UIColor) {
        field_Retrs.placeholder = placeholder_Retrs
        field_Retrs.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        field_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        field_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        field_Retrs.layer.cornerRadius = 16
        field_Retrs.autocorrectionType  = .no
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

        closeBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        logoCard_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 60)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        cardView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(logoCard_Retrs.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        cardTitle_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(22)
        }
        cardSub_Retrs.snp.makeConstraints { make in
            make.top.equalTo(cardTitle_Retrs.snp.bottom).offset(4)
            make.leading.equalTo(cardTitle_Retrs)
        }
        userField_Retrs.snp.makeConstraints { make in
            make.top.equalTo(cardSub_Retrs.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        pwdField_Retrs.snp.makeConstraints { make in
            make.top.equalTo(userField_Retrs.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        loginBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(pwdField_Retrs.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
    }

    // MARK: - 事件

    @objc private func closeTapped_Retrs()    { Navigation_Retrs.dismiss_Retrs() }
    @objc private func dismissKeyboard_Retrs() { view.endEditing(true) }
    @objc private func toRegisterTapped_Retrs() { Navigation_Retrs.toRegister_Retrs(style_retrs: .push_retrs) }

    @objc private func loginTapped_Retrs() {
        loginBtn_Retrs.animatePressDown_Retrs { [weak self] in self?.loginBtn_Retrs.animatePressUp_Retrs() }
        let username_Retrs = userField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_Retrs = pwdField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !username_Retrs.isEmpty else {
            userField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please enter your username"); return
        }
        guard !password_Retrs.isEmpty else {
            pwdField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please enter your password"); return
        }
        let users_Retrs = LocalData_Retrs.shared_Retrs.userList_Retrs
        let matched_Retrs = users_Retrs.first { $0.userName_Retrs?.lowercased() == username_Retrs.lowercased() }
        let uid_Retrs = matched_Retrs?.userId_Retrs ?? abs(username_Retrs.hashValue % 100 + 1)
        userVM_Retrs.loginById_Retrs(userId_retrs: uid_Retrs)
    }
}
