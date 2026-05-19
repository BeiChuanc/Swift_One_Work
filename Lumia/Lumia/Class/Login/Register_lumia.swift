import Foundation
import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页视图控制器
/// 核心作用：提供用户名、密码、确认密码的注册表单，注册成功后完成登录
/// 设计思路：与登录页同款大结构，使用主渐变色系（薰衣草紫→天空蓝），区分品牌感
class Register_Lumia: UIViewController {

    // MARK: - UI组件

    private var bgGradient_Lumia: CAGradientLayer?
    private let bgView_Lumia = UIView()
    private let backButton_Lumia = BackButton_Lumia()

    private let cameraIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.aperture")
        iv_Lumia.tintColor = .white
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let brandTitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        let attrs_Lumia: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "AvenirNext-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.white,
            .kern: 4.0
        ]
        lbl_Lumia.attributedText = NSAttributedString(string: "JOIN LUMIA", attributes: attrs_Lumia)
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let brandSubtitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Start your film diary journey"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let registerCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 32
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Lumia.layer.shadowColor = UIColor.black.cgColor
        v_Lumia.layer.shadowOpacity = 0.10
        v_Lumia.layer.shadowRadius = 20
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: -6)
        return v_Lumia
    }()

    private let cardAccentBar_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 2
        return v_Lumia
    }()

    private let cardTitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Create Account"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A1040")
        return lbl_Lumia
    }()

    private let cardSubtitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Fill in your details to get started"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8070B0")
        return lbl_Lumia
    }()

    private let nameField_Lumia = LoginInputField_Lumia(
        placeholder: "Username", icon: "person.fill", isSecure: false
    )
    private let passwordField_Lumia = LoginInputField_Lumia(
        placeholder: "Password", icon: "lock.fill", isSecure: true
    )
    private let confirmPasswordField_Lumia = LoginInputField_Lumia(
        placeholder: "Confirm Password", icon: "lock.fill", isSecure: true
    )

    private let registerButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        btn_Lumia.setTitle("Create Account", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.layer.cornerRadius = 26
        btn_Lumia.clipsToBounds = true
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Lumia?.frame = bgView_Lumia.bounds
        cardAccentBar_Lumia.layer.sublayers?.compactMap { $0 as? CAGradientLayer }.forEach {
            $0.frame = cardAccentBar_Lumia.bounds
        }
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#B794F6")

        view.addSubview(bgView_Lumia)
        bgView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#8A5CC8").cgColor,
            UIColor(hexstring_Lumia: "#4A86D4").cgColor,
            UIColor(hexstring_Lumia: "#2AA8E8").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        bgView_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        bgGradient_Lumia = gradient_Lumia

        // 装饰气泡
        [makeDecoBubble_Lumia(size: 110, alpha: 0.09),
         makeDecoBubble_Lumia(size: 60, alpha: 0.12),
         makeDecoBubble_Lumia(size: 36, alpha: 0.08)].enumerated().forEach { idx_Lumia, bubble_Lumia in
            view.addSubview(bubble_Lumia)
            let offsets: [(CGFloat, CGFloat)] = [(-30, -30),
                                                  (UIScreen.main.bounds.width - 70, 20),
                                                  (UIScreen.main.bounds.width - 40, 80)]
            bubble_Lumia.frame = CGRect(x: offsets[idx_Lumia].0, y: offsets[idx_Lumia].1,
                                        width: [110, 60, 36][idx_Lumia], height: [110, 60, 36][idx_Lumia])
        }

        // 返回按钮
        view.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        // 品牌区
        view.addSubview(cameraIcon_Lumia)
        cameraIcon_Lumia.snp.makeConstraints { make in
            make.top.equalTo(backButton_Lumia.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }

        view.addSubview(brandTitle_Lumia)
        brandTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cameraIcon_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        view.addSubview(brandSubtitle_Lumia)
        brandSubtitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(brandTitle_Lumia.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 注册卡片
        view.addSubview(registerCard_Lumia)
        registerCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(brandSubtitle_Lumia.snp.bottom).offset(26)
            make.leading.trailing.bottom.equalToSuperview()
        }

        setupRegisterCard_Lumia()
    }

    private func makeDecoBubble_Lumia(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Lumia.layer.cornerRadius = size / 2
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }

    private func setupRegisterCard_Lumia() {
        // 顶部主渐变色条
        registerCard_Lumia.addSubview(cardAccentBar_Lumia)
        cardAccentBar_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(48)
            make.height.equalTo(4)
        }
        let accentGrad_Lumia = CAGradientLayer()
        accentGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#8A5CC8").cgColor,
            UIColor(hexstring_Lumia: "#4A86D4").cgColor
        ]
        accentGrad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        accentGrad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        accentGrad_Lumia.cornerRadius = 2
        cardAccentBar_Lumia.layer.insertSublayer(accentGrad_Lumia, at: 0)

        registerCard_Lumia.addSubview(cardTitle_Lumia)
        cardTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cardAccentBar_Lumia.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(28)
        }

        registerCard_Lumia.addSubview(cardSubtitle_Lumia)
        cardSubtitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cardTitle_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(cardTitle_Lumia)
        }

        nameField_Lumia.textField_Lumia.returnKeyType = .next
        nameField_Lumia.textField_Lumia.delegate = self
        registerCard_Lumia.addSubview(nameField_Lumia)
        nameField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(cardSubtitle_Lumia.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        passwordField_Lumia.textField_Lumia.returnKeyType = .next
        passwordField_Lumia.textField_Lumia.delegate = self
        registerCard_Lumia.addSubview(passwordField_Lumia)
        passwordField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameField_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        confirmPasswordField_Lumia.textField_Lumia.returnKeyType = .done
        confirmPasswordField_Lumia.textField_Lumia.delegate = self
        registerCard_Lumia.addSubview(confirmPasswordField_Lumia)
        confirmPasswordField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }

        registerCard_Lumia.addSubview(registerButton_Lumia)
        registerButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField_Lumia.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        let gradientBtn_Lumia = UIColor.createPrimaryGradientLayer_Lumia(
            frame_Lumia: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 52)
        )
        gradientBtn_Lumia.cornerRadius = 26
        registerButton_Lumia.layer.insertSublayer(gradientBtn_Lumia, at: 0)
        registerButton_Lumia.addTarget(self, action: #selector(handleRegister_Lumia), for: .touchUpInside)

        let protocol_Lumia = ProtocolHelper_Lumia.createProtocolTextLabel_Lumia(
            firstContent_Lumia: "terms_image",
            secondContent_Lumia: "privacy_image",
            config_Lumia: .light_Lumia(),
            from: self
        )
        registerCard_Lumia.addSubview(protocol_Lumia)
        protocol_Lumia.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-40)
        }
    }

    // MARK: - 事件处理

    @objc private func handleRegister_Lumia() {
        let name_Lumia = nameField_Lumia.textField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pwd_Lumia = passwordField_Lumia.textField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let confirmPwd_Lumia = confirmPasswordField_Lumia.textField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !name_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please enter a username.")
            nameField_Lumia.shake_Lumia()
            return
        }
        guard !pwd_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please enter a password.")
            passwordField_Lumia.shake_Lumia()
            return
        }
        guard pwd_Lumia == confirmPwd_Lumia else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Passwords do not match.")
            confirmPasswordField_Lumia.shake_Lumia()
            return
        }

        view.endEditing(true)
        registerButton_Lumia.animatePressDown_Lumia { self.registerButton_Lumia.animatePressUp_Lumia() }
        Task { @MainActor in
            UserViewModel_Lumia.shared_Lumia.loginById_Lumia(userId_lumia: 56165)
        }
    }
}

// MARK: - UITextFieldDelegate

extension Register_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField_Lumia.textField_Lumia {
            passwordField_Lumia.textField_Lumia.becomeFirstResponder()
        } else if textField == passwordField_Lumia.textField_Lumia {
            confirmPasswordField_Lumia.textField_Lumia.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleRegister_Lumia()
        }
        return true
    }
}
