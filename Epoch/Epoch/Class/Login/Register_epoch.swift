import Foundation
import UIKit
import SnapKit

// MARK: 注册页

/// 注册页
/// 核心作用：创建本地账号并在成功后直接完成登录
/// 设计思路：与登录页保持「渐变顶部 + 底部浮板」风格一致，
///          浮板锚定 Hero 区下方，内部用 UIScrollView 确保触摸正确传递
class Register_Epoch: UIViewController {

    // MARK: - 背景渐变

    private let bgGradient_Epoch = CAGradientLayer()

    // MARK: - 装饰球（关闭交互）

    private let orbTopRight_Epoch = UIView()
    private let orbMidLeft_Epoch  = UIView()

    // MARK: - 返回按钮

    private let backBtn_Epoch = UIButton(type: .system)

    // MARK: - 品牌 Hero

    private let heroIconWrap_Epoch  = UIView()
    private let heroIconView_Epoch  = UIImageView()
    private let heroNameLabel_Epoch = UILabel()
    private let heroTagLabel_Epoch  = UILabel()

    // MARK: - 底部浮板

    private let sheetView_Epoch    = UIView()
    private let sheetScroll_Epoch  = UIScrollView()
    private let sheetContent_Epoch = UIView()

    // MARK: - 表单元素

    private let sheetHandle_Epoch   = UIView()
    private let sheetTitle_Epoch    = UILabel()
    private let sheetSubtitle_Epoch = UILabel()

    private let userNameField_Epoch = Register_Epoch.makeField_Epoch(
        placeholder_Epoch: "Username", icon_Epoch: "person.fill"
    )
    private let passwordField_Epoch = Register_Epoch.makeField_Epoch(
        placeholder_Epoch: "Password", icon_Epoch: "lock.fill"
    )
    private let confirmField_Epoch = Register_Epoch.makeField_Epoch(
        placeholder_Epoch: "Confirm password", icon_Epoch: "checkmark.shield.fill"
    )

    private let registerBtn_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Create account")

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBg_Epoch()
        setupOrbs_Epoch()
        setupBackBtn_Epoch()
        setupHero_Epoch()
        setupSheet_Epoch()
        updateRegisterState_Epoch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Epoch.frame = view.bounds
        orbTopRight_Epoch.layer.cornerRadius = orbTopRight_Epoch.bounds.width / 2
        orbMidLeft_Epoch.layer.cornerRadius  = orbMidLeft_Epoch.bounds.width / 2
        heroIconWrap_Epoch.layer.cornerRadius = heroIconWrap_Epoch.bounds.width / 2
    }

    // MARK: - 背景

    private func setupBg_Epoch() {
        bgGradient_Epoch.colors = [
            UIColor(hexstring_Epoch: "#4C1D95").cgColor,
            UIColor(hexstring_Epoch: "#7C3AED").cgColor,
            UIColor(hexstring_Epoch: "#B794F6").cgColor,
            UIColor(hexstring_Epoch: "#90CDF4").cgColor
        ]
        bgGradient_Epoch.locations = [0.0, 0.3, 0.65, 1.0]
        bgGradient_Epoch.startPoint = CGPoint(x: 0.2, y: 0)
        bgGradient_Epoch.endPoint   = CGPoint(x: 0.8, y: 1)
        view.layer.insertSublayer(bgGradient_Epoch, at: 0)
    }

    /// 装饰球（关闭交互防止拦截触摸事件）
    private func setupOrbs_Epoch() {
        orbTopRight_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        orbTopRight_Epoch.isUserInteractionEnabled = false
        view.addSubview(orbTopRight_Epoch)
        orbTopRight_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.right.equalToSuperview().offset(40)
            make.width.height.equalTo(200)
        }

        orbMidLeft_Epoch.backgroundColor = UIColor(hexstring_Epoch: "#63B3ED").withAlphaComponent(0.14)
        orbMidLeft_Epoch.isUserInteractionEnabled = false
        view.addSubview(orbMidLeft_Epoch)
        orbMidLeft_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(-40)
            make.width.height.equalTo(140)
        }
    }

    // MARK: - 返回按钮

    private func setupBackBtn_Epoch() {
        backBtn_Epoch.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backBtn_Epoch.tintColor = UIColor.white.withAlphaComponent(0.85)
        backBtn_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        backBtn_Epoch.layer.cornerRadius = 16
        backBtn_Epoch.addTarget(self, action: #selector(backTapped_Epoch), for: .touchUpInside)
        view.addSubview(backBtn_Epoch)
        backBtn_Epoch.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(32)
        }
    }

    // MARK: - 品牌 Hero

    private func setupHero_Epoch() {
        heroIconWrap_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        heroIconWrap_Epoch.clipsToBounds = true
        heroIconWrap_Epoch.isUserInteractionEnabled = false
        view.addSubview(heroIconWrap_Epoch)

        heroIconView_Epoch.image = UIImage(systemName: "person.badge.plus")
        heroIconView_Epoch.tintColor = .white
        heroIconView_Epoch.contentMode = .scaleAspectFit
        heroIconView_Epoch.isUserInteractionEnabled = false
        heroIconWrap_Epoch.addSubview(heroIconView_Epoch)

        let baseDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let serifDesc_epoch = (baseDesc_epoch.withDesign(.serif) ?? baseDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? baseDesc_epoch
        heroNameLabel_Epoch.font = UIFont(descriptor: serifDesc_epoch, size: 46)
        heroNameLabel_Epoch.text = "Epoch"
        heroNameLabel_Epoch.textColor = .white
        heroNameLabel_Epoch.textAlignment = .center
        heroNameLabel_Epoch.isUserInteractionEnabled = false
        view.addSubview(heroNameLabel_Epoch)

        heroTagLabel_Epoch.text = "Create your ritual identity"
        heroTagLabel_Epoch.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        heroTagLabel_Epoch.textColor = UIColor.white.withAlphaComponent(0.75)
        heroTagLabel_Epoch.textAlignment = .center
        heroTagLabel_Epoch.isUserInteractionEnabled = false
        view.addSubview(heroTagLabel_Epoch)

        heroIconWrap_Epoch.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }
        heroIconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        heroNameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroIconWrap_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }
        heroTagLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroNameLabel_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(40)
        }
    }

    // MARK: - 底部浮板

    private func setupSheet_Epoch() {
        sheetView_Epoch.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        sheetView_Epoch.layer.cornerRadius = 32
        sheetView_Epoch.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sheetView_Epoch)
        sheetView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroTagLabel_Epoch.snp.bottom).offset(28)
            make.left.right.bottom.equalToSuperview()
        }

        // 把手
        sheetHandle_Epoch.backgroundColor = ColorConfig_Epoch.divider_Epoch
        sheetHandle_Epoch.layer.cornerRadius = 2
        sheetView_Epoch.addSubview(sheetHandle_Epoch)
        sheetHandle_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(4)
        }

        // 内部 ScrollView
        sheetScroll_Epoch.showsVerticalScrollIndicator = false
        sheetScroll_Epoch.alwaysBounceVertical = false
        sheetView_Epoch.addSubview(sheetScroll_Epoch)
        sheetScroll_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sheetHandle_Epoch.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }

        sheetScroll_Epoch.addSubview(sheetContent_Epoch)
        sheetContent_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sheetScroll_Epoch)
        }

        buildFormContent_Epoch()
    }

    /// 在 sheetContent_Epoch 内构建三输入框注册表单
    private func buildFormContent_Epoch() {
        // 标题行 + 角标
        sheetTitle_Epoch.text = "Create account"
        let rDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldR_epoch = (rDesc_epoch.withDesign(.rounded) ?? rDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? rDesc_epoch
        sheetTitle_Epoch.font = UIFont(descriptor: boldR_epoch, size: 24)
        sheetTitle_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        sheetContent_Epoch.addSubview(sheetTitle_Epoch)

        let stepBadge_epoch = PaddingLabel_Epoch()
        stepBadge_epoch.text = "NEW"
        stepBadge_epoch.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        stepBadge_epoch.textColor = .white
        stepBadge_epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        stepBadge_epoch.layer.cornerRadius = 9
        stepBadge_epoch.clipsToBounds = true
        stepBadge_epoch.horizontalInset_Epoch = 7
        stepBadge_epoch.verticalInset_Epoch = 3
        sheetContent_Epoch.addSubview(stepBadge_epoch)

        // 副标题
        sheetSubtitle_Epoch.text = "Fill in your details and start your journey."
        sheetSubtitle_Epoch.font = UIFont.systemFont(ofSize: 14)
        sheetSubtitle_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        sheetContent_Epoch.addSubview(sheetSubtitle_Epoch)

        // 输入框
        passwordField_Epoch.isSecureTextEntry = true
        confirmField_Epoch.isSecureTextEntry  = true
        [userNameField_Epoch, passwordField_Epoch, confirmField_Epoch].forEach {
            $0.addTarget(self, action: #selector(fieldChanged_Epoch), for: .editingChanged)
            sheetContent_Epoch.addSubview($0)
        }

        // 已有账号跳转
        let loginHint_epoch = UIButton(type: .system)
        loginHint_epoch.setAttributedTitle(NSAttributedString(
            string: "Already have an account? Log in →",
            attributes: [
                .foregroundColor: ColorConfig_Epoch.accentPurple_Epoch,
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]
        ), for: .normal)
        loginHint_epoch.addTarget(self, action: #selector(backTapped_Epoch), for: .touchUpInside)
        sheetContent_Epoch.addSubview(loginHint_epoch)

        // 注册按钮
        registerBtn_Epoch.addTarget(self, action: #selector(registerTapped_Epoch), for: .touchUpInside)
        sheetContent_Epoch.addSubview(registerBtn_Epoch)

        // 协议
        let protocolLabel_epoch = ProtocolHelper_Epoch.createProtocolTextLabel_Epoch(
            firstProtocol_Epoch: .terms_Epoch,
            firstContent_Epoch: "These terms explain acceptable publishing behavior and account responsibility inside Epoch.",
            secondProtocol_Epoch: .privacy_Epoch,
            secondContent_Epoch: "This policy explains how local profile, selected media and basic activity are stored for your app experience.",
            from: self
        )
        sheetContent_Epoch.addSubview(protocolLabel_epoch)

        // MARK: 约束
        sheetTitle_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(24)
        }
        stepBadge_epoch.snp.makeConstraints { make in
            make.centerY.equalTo(sheetTitle_Epoch)
            make.left.equalTo(sheetTitle_Epoch.snp.right).offset(8)
        }
        sheetSubtitle_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sheetTitle_Epoch.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(24)
        }
        userNameField_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sheetSubtitle_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        passwordField_Epoch.snp.makeConstraints { make in
            make.top.equalTo(userNameField_Epoch.snp.bottom).offset(12)
            make.left.right.height.equalTo(userNameField_Epoch)
        }
        confirmField_Epoch.snp.makeConstraints { make in
            make.top.equalTo(passwordField_Epoch.snp.bottom).offset(12)
            make.left.right.height.equalTo(userNameField_Epoch)
        }
        loginHint_epoch.snp.makeConstraints { make in
            make.top.equalTo(confirmField_Epoch.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-20)
        }
        registerBtn_Epoch.snp.makeConstraints { make in
            make.top.equalTo(loginHint_epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        protocolLabel_epoch.snp.makeConstraints { make in
            make.top.equalTo(registerBtn_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    // MARK: - 输入框工厂

    /// 创建输入框（浅蓝底 + 圆角 + 紫色图标，frame 布局避免触摸问题）
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

        let iconBox_epoch = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 56))
        iconBox_epoch.isUserInteractionEnabled = false
        let iconImg_epoch = UIImageView(frame: CGRect(x: 14, y: 18, width: 20, height: 20))
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

    private func updateRegisterState_Epoch() {
        let u = !(userNameField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let p = !(passwordField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let c = !(confirmField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        registerBtn_Epoch.isEnabled = u && p && c && (passwordField_Epoch.text == confirmField_Epoch.text)
    }

    // MARK: - @objc

    @objc private func fieldChanged_Epoch() {
        updateRegisterState_Epoch()
    }

    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch()
    }

    @objc private func registerTapped_Epoch() {
        let u = userNameField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let p = passwordField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let c = confirmField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !u.isEmpty, !p.isEmpty, !c.isEmpty else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Please complete all fields.")
            return
        }
        guard p == c else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Passwords do not match.")
            return
        }
        UserViewModel_Epoch.shared_Epoch.loginById_Epoch(userId_epoch: 542257)
    }
}
