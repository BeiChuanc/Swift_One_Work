import Foundation
import UIKit
import SnapKit

// MARK: 登录页

/// 登录页
/// 核心作用：用户名密码登录、Apple 登录、协议展示
/// 设计思路：全屏渐变背景 + 顶部品牌 Hero 区 + 底部白色浮板表单
///          浮板锚定在 Hero 区下方并延伸到屏幕底部，内部用 UIScrollView 保证触摸正确传递
class Login_Epoch: UIViewController {

    // MARK: - 背景渐变

    private let bgGradient_Epoch = CAGradientLayer()

    // MARK: - 装饰球（仅视觉，isUserInteractionEnabled = false）

    private let orbTopLeft_Epoch     = UIView()
    private let orbCenterRight_Epoch = UIView()

    // MARK: - 顶部关闭按钮

    private let closeBtn_Epoch = UIButton(type: .system)

    // MARK: - 品牌 Hero

    private let heroIconWrap_Epoch  = UIView()
    private let heroIconView_Epoch  = UIImageView()
    private let heroNameLabel_Epoch = UILabel()
    private let heroTagLabel_Epoch  = UILabel()

    // MARK: - 底部浮板

    private let sheetView_Epoch   = UIView()
    private let sheetScroll_Epoch = UIScrollView()
    private let sheetContent_Epoch = UIView()

    // MARK: - 表单元素

    private let sheetHandle_Epoch   = UIView()
    private let sheetTitle_Epoch    = UILabel()
    private let sheetSubtitle_Epoch = UILabel()

    private let userNameField_Epoch = Login_Epoch.makeField_Epoch(
        placeholder_Epoch: "Username", icon_Epoch: "person.fill"
    )
    private let passwordField_Epoch = Login_Epoch.makeField_Epoch(
        placeholder_Epoch: "Password", icon_Epoch: "lock.fill"
    )

    private let loginBtn_Epoch     = PrimaryActionButton_Epoch(title_Epoch: "Log in")
    private let dividerView_Epoch  = LoginDividerView_Epoch()
    private lazy var appleBtn_Epoch = AppleLoginBt_Epoch { [weak self] in
        self?.startAppleLogin_Epoch()
    }

    private var appleManager_Epoch: AppleLoginManager_Epoch?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBg_Epoch()
        setupOrbs_Epoch()
        setupCloseBtn_Epoch()
        setupHero_Epoch()
        setupSheet_Epoch()
        updateLoginState_Epoch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Epoch.frame = view.bounds
        orbTopLeft_Epoch.layer.cornerRadius   = orbTopLeft_Epoch.bounds.width / 2
        orbCenterRight_Epoch.layer.cornerRadius = orbCenterRight_Epoch.bounds.width / 2
        heroIconWrap_Epoch.layer.cornerRadius = heroIconWrap_Epoch.bounds.width / 2
    }

    // MARK: - 背景

    private func setupBg_Epoch() {
        bgGradient_Epoch.colors = [
            UIColor(hexstring_Epoch: "#7C3AED").cgColor,
            UIColor(hexstring_Epoch: "#B794F6").cgColor,
            UIColor(hexstring_Epoch: "#FBB6CE").cgColor,
            UIColor(hexstring_Epoch: "#FED7AA").cgColor
        ]
        bgGradient_Epoch.locations = [0.0, 0.35, 0.70, 1.0]
        bgGradient_Epoch.startPoint = CGPoint(x: 0.1, y: 0)
        bgGradient_Epoch.endPoint   = CGPoint(x: 0.9, y: 1)
        view.layer.insertSublayer(bgGradient_Epoch, at: 0)
    }

    /// 装饰球（关闭交互防止拦截触摸）
    private func setupOrbs_Epoch() {
        orbTopLeft_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        orbTopLeft_Epoch.isUserInteractionEnabled = false
        view.addSubview(orbTopLeft_Epoch)
        orbTopLeft_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.left.equalToSuperview().offset(-60)
            make.width.height.equalTo(240)
        }

        orbCenterRight_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        orbCenterRight_Epoch.isUserInteractionEnabled = false
        view.addSubview(orbCenterRight_Epoch)
        orbCenterRight_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.right.equalToSuperview().offset(60)
            make.width.height.equalTo(160)
        }
    }

    // MARK: - 关闭按钮

    private func setupCloseBtn_Epoch() {
        closeBtn_Epoch.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn_Epoch.tintColor = UIColor.white.withAlphaComponent(0.85)
        closeBtn_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        closeBtn_Epoch.layer.cornerRadius = 16
        closeBtn_Epoch.addTarget(self, action: #selector(closeTapped_Epoch), for: .touchUpInside)
        view.addSubview(closeBtn_Epoch)
        closeBtn_Epoch.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(32)
        }
    }

    // MARK: - 品牌 Hero 区

    private func setupHero_Epoch() {
        // 图标圆背景
        heroIconWrap_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        heroIconWrap_Epoch.clipsToBounds = true
        heroIconWrap_Epoch.isUserInteractionEnabled = false
        view.addSubview(heroIconWrap_Epoch)

        heroIconView_Epoch.image = UIImage(systemName: "sparkles")
        heroIconView_Epoch.tintColor = .white
        heroIconView_Epoch.contentMode = .scaleAspectFit
        heroIconView_Epoch.isUserInteractionEnabled = false
        heroIconWrap_Epoch.addSubview(heroIconView_Epoch)

        // App 名称（衬线）
        let baseDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let serifDesc_epoch = (baseDesc_epoch.withDesign(.serif) ?? baseDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? baseDesc_epoch
        heroNameLabel_Epoch.font = UIFont(descriptor: serifDesc_epoch, size: 46)
        heroNameLabel_Epoch.text = "Epoch"
        heroNameLabel_Epoch.textColor = .white
        heroNameLabel_Epoch.textAlignment = .center
        heroNameLabel_Epoch.isUserInteractionEnabled = false
        view.addSubview(heroNameLabel_Epoch)

        heroTagLabel_Epoch.text = "Share your ritual moments"
        heroTagLabel_Epoch.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        heroTagLabel_Epoch.textColor = UIColor.white.withAlphaComponent(0.75)
        heroTagLabel_Epoch.textAlignment = .center
        heroTagLabel_Epoch.isUserInteractionEnabled = false
        view.addSubview(heroTagLabel_Epoch)

        heroIconWrap_Epoch.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(52)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }
        heroIconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        heroNameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroIconWrap_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        heroTagLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroNameLabel_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(40)
        }
    }

    // MARK: - 底部浮板

    private func setupSheet_Epoch() {
        // 浮板：锚定在 Hero 标语下方并延伸到屏幕底部
        sheetView_Epoch.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        sheetView_Epoch.layer.cornerRadius = 32
        sheetView_Epoch.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sheetView_Epoch)
        sheetView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroTagLabel_Epoch.snp.bottom).offset(28)
            make.left.right.bottom.equalToSuperview()
        }

        // 拖拽把手
        sheetHandle_Epoch.backgroundColor = ColorConfig_Epoch.divider_Epoch
        sheetHandle_Epoch.layer.cornerRadius = 2
        sheetView_Epoch.addSubview(sheetHandle_Epoch)
        sheetHandle_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(4)
        }

        // 内部 ScrollView（确保触摸事件正确传递，并支持键盘抬起）
        sheetScroll_Epoch.showsVerticalScrollIndicator = false
        sheetScroll_Epoch.alwaysBounceVertical = false
        sheetView_Epoch.addSubview(sheetScroll_Epoch)
        sheetScroll_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sheetHandle_Epoch.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }

        // 内容容器
        sheetScroll_Epoch.addSubview(sheetContent_Epoch)
        sheetContent_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sheetScroll_Epoch)
        }

        buildFormContent_Epoch()
    }

    /// 在 sheetContent_Epoch 内构建表单元素
    private func buildFormContent_Epoch() {
        // 标题
        sheetTitle_Epoch.text = "Welcome back"
        let rDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldR_epoch = (rDesc_epoch.withDesign(.rounded) ?? rDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? rDesc_epoch
        sheetTitle_Epoch.font = UIFont(descriptor: boldR_epoch, size: 24)
        sheetTitle_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        sheetContent_Epoch.addSubview(sheetTitle_Epoch)

        // 副标题
        sheetSubtitle_Epoch.text = "Log in and continue your journey."
        sheetSubtitle_Epoch.font = UIFont.systemFont(ofSize: 14)
        sheetSubtitle_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        sheetContent_Epoch.addSubview(sheetSubtitle_Epoch)

        // 输入框
        passwordField_Epoch.isSecureTextEntry = true
        userNameField_Epoch.addTarget(self, action: #selector(fieldChanged_Epoch), for: .editingChanged)
        passwordField_Epoch.addTarget(self, action: #selector(fieldChanged_Epoch), for: .editingChanged)
        sheetContent_Epoch.addSubview(userNameField_Epoch)
        sheetContent_Epoch.addSubview(passwordField_Epoch)

        // 注册跳转
        let regBtn_epoch = UIButton(type: .system)
        regBtn_epoch.setAttributedTitle(NSAttributedString(
            string: "No account? Register →",
            attributes: [
                .foregroundColor: ColorConfig_Epoch.accentPurple_Epoch,
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]
        ), for: .normal)
        regBtn_epoch.addTarget(self, action: #selector(registerTapped_Epoch), for: .touchUpInside)
        sheetContent_Epoch.addSubview(regBtn_epoch)

        // 登录按钮
        loginBtn_Epoch.addTarget(self, action: #selector(loginTapped_Epoch), for: .touchUpInside)
        sheetContent_Epoch.addSubview(loginBtn_Epoch)

        // OR 分割线
        sheetContent_Epoch.addSubview(dividerView_Epoch)

        // Apple 登录
        sheetContent_Epoch.addSubview(appleBtn_Epoch)

        // 协议
        let protocolLabel_epoch = ProtocolHelper_Epoch.createProtocolTextLabel_Epoch(
            firstProtocol_Epoch: .terms_Epoch,
            firstContent_Epoch: "These terms describe acceptable sharing behavior, creator responsibility and safe publishing rules inside Epoch.",
            secondProtocol_Epoch: .privacy_Epoch,
            secondContent_Epoch: "This policy explains how local profile data, selected media and chat previews are used only for your in-app experience.",
            from: self
        )
        sheetContent_Epoch.addSubview(protocolLabel_epoch)

        // MARK: 约束
        sheetTitle_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(24)
        }
        sheetSubtitle_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sheetTitle_Epoch.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(24)
        }
        userNameField_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sheetSubtitle_Epoch.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        passwordField_Epoch.snp.makeConstraints { make in
            make.top.equalTo(userNameField_Epoch.snp.bottom).offset(12)
            make.left.right.height.equalTo(userNameField_Epoch)
        }
        regBtn_epoch.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Epoch.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-20)
        }
        loginBtn_Epoch.snp.makeConstraints { make in
            make.top.equalTo(regBtn_epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        dividerView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(loginBtn_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        appleBtn_Epoch.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        protocolLabel_epoch.snp.makeConstraints { make in
            make.top.equalTo(appleBtn_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    // MARK: - 输入框工厂

    /// 创建输入框（浅蓝底 + 圆角 + 紫色图标，使用 frame 布局避免触摸拦截）
    /// - Parameters:
    ///   - placeholder_Epoch: 占位文案
    ///   - icon_Epoch: 系统图标名称
    /// - Returns: UITextField
    private static func makeField_Epoch(placeholder_Epoch: String, icon_Epoch: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder_Epoch
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf.textColor = ColorConfig_Epoch.textPrimary_Epoch
        tf.backgroundColor = UIColor(hexstring_Epoch: "#EEF2FF")
        tf.layer.cornerRadius = 16
        tf.clipsToBounds = true
        tf.isUserInteractionEnabled = true

        // 左侧图标用 frame 布局，避免 SnapKit 在非层级视图中产生触摸问题
        let iconBox_epoch = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 56))
        iconBox_epoch.isUserInteractionEnabled = false
        let iconImg_epoch = UIImageView(
            frame: CGRect(x: 14, y: 18, width: 20, height: 20)
        )
        iconImg_epoch.image = UIImage(systemName: icon_Epoch)
        iconImg_epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iconImg_epoch.contentMode = .scaleAspectFit
        iconImg_epoch.isUserInteractionEnabled = false
        iconBox_epoch.addSubview(iconImg_epoch)
        tf.leftView = iconBox_epoch
        tf.leftViewMode = .always
        return tf
    }

    // MARK: - 业务逻辑

    private func updateLoginState_Epoch() {
        let u = !(userNameField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let p = !(passwordField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        loginBtn_Epoch.isEnabled = u && p
    }

    private func startAppleLogin_Epoch() {
        appleManager_Epoch = AppleLoginManager_Epoch(viewController_Epoch: self)
        appleManager_Epoch?.startAppleLogin_Epoch(success_Epoch: { [weak self] account_epoch in
            UserViewModel_Epoch.shared_Epoch.loginById_Epoch(userId_epoch: 99999)
        }, failure_Epoch: { msg in
            Utils_Epoch.showWarning_Epoch(message_Epoch: msg)
        })
    }

    // MARK: - @objc

    @objc private func closeTapped_Epoch() {
        Navigation_Epoch.dismiss_Epoch()
    }

    @objc private func fieldChanged_Epoch() {
        updateLoginState_Epoch()
    }

    @objc private func registerTapped_Epoch() {
        Navigation_Epoch.toRegister_Epoch(style_epoch: .push_epoch)
    }

    @objc private func loginTapped_Epoch() {
        let u = userNameField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let p = passwordField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !u.isEmpty, !p.isEmpty else { updateLoginState_Epoch(); return }
        UserViewModel_Epoch.shared_Epoch.loginById_Epoch(userId_epoch: 542256)
    }
}

// MARK: - OR 分割线

/// 登录页 OR 分割线（左右横线 + 中间文字）
final class LoginDividerView_Epoch: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let leftLine = UIView()
        leftLine.backgroundColor = ColorConfig_Epoch.divider_Epoch
        let rightLine = UIView()
        rightLine.backgroundColor = ColorConfig_Epoch.divider_Epoch
        let label = UILabel()
        label.text = "or continue with"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        addSubview(leftLine); addSubview(label); addSubview(rightLine)
        label.snp.makeConstraints { make in make.center.equalToSuperview() }
        leftLine.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.right.equalTo(label.snp.left).offset(-10)
            make.height.equalTo(1)
        }
        rightLine.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.left.equalTo(label.snp.right).offset(10)
            make.height.equalTo(1)
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
