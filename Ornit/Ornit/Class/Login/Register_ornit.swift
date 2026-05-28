import UIKit
import SnapKit

// MARK: 注册页

/// 注册页
/// 功能：提供用户名、密码、确认密码三个输入框，验证非空及密码一致，完成注册
/// 设计：与登录页相同渐变背景 + 顶部品牌区（标题 + 鸟类图标）+ 白色浮起表单卡片
class Register_Ornit: UIViewController {

    // MARK: - UI 组件

    /// 全屏渐变背景图层
    private var backgroundGradient_Ornit: CAGradientLayer?

    /// 白色表单卡片（底部浮起，上圆角）
    private let formCard_Ornit = UIView()

    /// 用户名输入框
    private let usernameField_Ornit = UITextField()

    /// 密码输入框
    private let passwordField_Ornit = UITextField()

    /// 确认密码输入框
    private let confirmPasswordField_Ornit = UITextField()

    /// 注册按钮（渐变 + wrapper 阴影）
    private let registerButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.setTitle("Create Account", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_ornit.setTitleColor(.white, for: .normal)
        btn_ornit.layer.cornerRadius = 16
        btn_ornit.layer.masksToBounds = true
        return btn_ornit
    }()

    /// 注册按钮渐变图层
    private var registerGradient_Ornit: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Ornit()
        setupTopArea_Ornit()
        setupFormCard_Ornit()
        setupBackButton_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient_Ornit?.frame = view.bounds
        registerGradient_Ornit?.frame = registerButton_Ornit.bounds
    }

    // MARK: - UI 搭建

    /// 构建全屏三色渐变背景（与登录页保持一致）
    private func setupBackground_Ornit() {
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor,
            ColorConfig_Ornit.messageGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.locations = [0, 0.5, 1]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient_ornit, at: 0)
        backgroundGradient_Ornit = gradient_ornit
    }

    /// 构建顶部品牌 + 标题区（与登录页视觉风格一致）
    private func setupTopArea_Ornit() {
        // 装饰大圆
        let decoBig_ornit = UIView()
        decoBig_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.06)
        decoBig_ornit.layer.cornerRadius = 80
        view.addSubview(decoBig_ornit)
        decoBig_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(50)
            make_ornit.top.equalToSuperview().offset(-28)
            make_ornit.width.height.equalTo(160)
        }

        // 标题（顶部从 106 开始，避开返回按钮区域 56+40=96pt）
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = "Create Account"
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 30, weight: .black)
        titleLabel_ornit.textColor = .white
        view.addSubview(titleLabel_ornit)
        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.top.equalToSuperview().offset(106)
        }

        // 副标题
        let subtitleLabel_ornit = UILabel()
        subtitleLabel_ornit.text = "Join the birding community"
        subtitleLabel_ornit.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.78)
        view.addSubview(subtitleLabel_ornit)
        subtitleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(6)
        }

        // 装饰鸟图标（右侧，与标题垂直居中）
        let birdConfig_ornit = UIImage.SymbolConfiguration(pointSize: 38, weight: .thin)
        let birdIcon_ornit = UIImageView(
            image: UIImage(systemName: "bird.fill", withConfiguration: birdConfig_ornit)
        )
        birdIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.2)
        view.addSubview(birdIcon_ornit)
        birdIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.centerY.equalTo(titleLabel_ornit)
            make_ornit.width.height.equalTo(52)
        }
    }

    /// 构建左上角返回按钮
    private func setupBackButton_Ornit() {
        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in
            Navigation_Ornit.pop_Ornit(from: self)
        }
        view.addSubview(backView_ornit)
        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(40)
        }
    }

    /// 构建底部白色浮起表单卡片（三个输入框 + 注册按钮 + 协议）
    private func setupFormCard_Ornit() {
        formCard_Ornit.backgroundColor = .white
        formCard_Ornit.layer.cornerRadius = 32
        formCard_Ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        formCard_Ornit.layer.shadowColor = UIColor.black.cgColor
        formCard_Ornit.layer.shadowOpacity = 0.12
        formCard_Ornit.layer.shadowRadius = 24
        view.addSubview(formCard_Ornit)

        formCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.bottom.equalToSuperview()
            make_ornit.top.equalToSuperview().offset(230)
        }

        // 区段标题
        let formTitleLabel_ornit = UILabel()
        formTitleLabel_ornit.text = "Your Details"
        formTitleLabel_ornit.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        formTitleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        formCard_Ornit.addSubview(formTitleLabel_ornit)

        let formSubLabel_ornit = UILabel()
        formSubLabel_ornit.text = "Fill in the information below"
        formSubLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        formSubLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        formCard_Ornit.addSubview(formSubLabel_ornit)

        formTitleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(28)
            make_ornit.leading.equalToSuperview().offset(28)
        }
        formSubLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(formTitleLabel_ornit.snp.bottom).offset(4)
            make_ornit.leading.equalToSuperview().offset(28)
        }

        // 配置并添加三个输入框
        configureTextField_Ornit(usernameField_Ornit,
            placeholder_ornit: "Username", icon_ornit: "person.fill",
            secure_ornit: false, returnKey_ornit: .next)
        configureTextField_Ornit(passwordField_Ornit,
            placeholder_ornit: "Password", icon_ornit: "lock.fill",
            secure_ornit: true, returnKey_ornit: .next)
        configureTextField_Ornit(confirmPasswordField_Ornit,
            placeholder_ornit: "Confirm Password", icon_ornit: "lock.shield.fill",
            secure_ornit: true, returnKey_ornit: .done)

        let userCon_ornit = addInputField_Ornit(usernameField_Ornit,
            topAnchor_ornit: formSubLabel_ornit.snp.bottom, topOffset_ornit: 22)
        let passCon_ornit = addInputField_Ornit(passwordField_Ornit,
            topAnchor_ornit: userCon_ornit.snp.bottom, topOffset_ornit: 13)
        let confirmCon_ornit = addInputField_Ornit(confirmPasswordField_Ornit,
            topAnchor_ornit: passCon_ornit.snp.bottom, topOffset_ornit: 13)

        // 注册按钮 + wrapper 阴影
        let regWrapper_ornit = UIView()
        regWrapper_ornit.layer.cornerRadius = 16
        regWrapper_ornit.layer.shadowColor = ColorConfig_Ornit.meGradientEnd_Ornit.withValues(alpha: 0.45).cgColor
        regWrapper_ornit.layer.shadowOffset = CGSize(width: 0, height: 6)
        regWrapper_ornit.layer.shadowOpacity = 1
        regWrapper_ornit.layer.shadowRadius = 14
        formCard_Ornit.addSubview(regWrapper_ornit)
        regWrapper_ornit.addSubview(registerButton_Ornit)

        let regGrad_ornit = CAGradientLayer()
        regGrad_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        regGrad_ornit.startPoint = CGPoint(x: 0, y: 0.5)
        regGrad_ornit.endPoint = CGPoint(x: 1, y: 0.5)
        registerButton_Ornit.layer.insertSublayer(regGrad_ornit, at: 0)
        // 立即设置 frame，确保按钮初始即可见（高度固定 54pt，宽度用视图宽减去左右 padding 56pt）
        regGrad_ornit.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 56, height: 54)
        registerGradient_Ornit = regGrad_ornit

        regWrapper_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(confirmCon_ornit.snp.bottom).offset(28)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.height.equalTo(54)
        }
        registerButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        registerButton_Ornit.addTarget(self, action: #selector(registerTapped_Ornit), for: .touchUpInside)

        // 协议文本
        let protocolLabel_ornit = ProtocolHelper_Ornit.createProtocolTextLabel_Ornit(
            firstContent_Ornit: "terms",
            secondContent_Ornit: "privacy",
            config_Ornit: .light_Ornit(),
            from: self
        )
        formCard_Ornit.addSubview(protocolLabel_ornit)
        protocolLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(regWrapper_ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
        }

        usernameField_Ornit.delegate = self
        passwordField_Ornit.delegate = self
        confirmPasswordField_Ornit.delegate = self
    }

    /// 配置输入框样式
    private func configureTextField_Ornit(
        _ textField_ornit: UITextField,
        placeholder_ornit: String,
        icon_ornit: String,
        secure_ornit: Bool,
        returnKey_ornit: UIReturnKeyType
    ) {
        textField_ornit.placeholder = placeholder_ornit
        textField_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        textField_ornit.backgroundColor = .clear
        textField_ornit.isSecureTextEntry = secure_ornit
        textField_ornit.returnKeyType = returnKey_ornit
        textField_ornit.autocapitalizationType = .none
        textField_ornit.autocorrectionType = .no
    }

    /// 将输入框添加到带图标的圆角容器中，返回容器视图供链式约束
    @discardableResult
    private func addInputField_Ornit(
        _ textField_ornit: UITextField,
        topAnchor_ornit: ConstraintRelatableTarget,
        topOffset_ornit: CGFloat
    ) -> UIView {
        let container_ornit = UIView()
        container_ornit.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        container_ornit.layer.cornerRadius = 14
        container_ornit.layer.borderWidth = 1
        container_ornit.layer.borderColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.1).cgColor
        formCard_Ornit.addSubview(container_ornit)
        container_ornit.addSubview(textField_ornit)

        container_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(topAnchor_ornit).offset(topOffset_ornit)
            make_ornit.leading.equalToSuperview().offset(28)
            make_ornit.trailing.equalToSuperview().offset(-28)
            make_ornit.height.equalTo(54)
        }

        textField_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.centerY.equalToSuperview()
        }

        return container_ornit
    }

    // MARK: - 事件处理

    /// 注册按钮点击 — 校验输入后执行注册
    @objc private func registerTapped_Ornit() {
        let username_ornit = usernameField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password_ornit = passwordField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let confirm_ornit = confirmPasswordField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !username_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please enter a username")
            return
        }
        guard !password_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please enter a password")
            return
        }
        guard !confirm_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please confirm your password")
            return
        }
        guard password_ornit == confirm_ornit else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Passwords do not match")
            return
        }

        UIView.animate(withDuration: 0.1, animations: {
            self.registerButton_Ornit.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) { self.registerButton_Ornit.transform = .identity }
        }

        UserViewModel_Ornit.shared_Ornit.loginById_Ornit(userId_ornit: 845143)
    }
}

// MARK: - UITextFieldDelegate

extension Register_Ornit: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField_Ornit {
            passwordField_Ornit.becomeFirstResponder()
        } else if textField == passwordField_Ornit {
            confirmPasswordField_Ornit.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            registerTapped_Ornit()
        }
        return true
    }
}
