import Foundation
import UIKit
import SnapKit

// MARK: - 注册页

/// 注册页面
/// 核心作用：用户名/密码/确认密码注册、协议展示，成功后由 ViewModel 内部调用 loginById_Flick 自动登录
/// 设计思路：与登录页同系渐变与卡片风格，英文 UI 文案
class Register_Flick: UIViewController {

    // MARK: - 私有属性

    private let gradientLayer_Flick = CAGradientLayer()

    private let termsBody_Flick = "Flick Terms of Service (demo). By using the app you agree to these terms."
    private let privacyBody_Flick = "Flick Privacy Policy (demo). We respect your data and use it only to improve the experience."

    // MARK: - UI

    private let scrollView_Flick: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = false
        v.keyboardDismissMode = .onDrag
        v.delaysContentTouches = false
        v.canCancelContentTouches = false
        return v
    }()

    private let contentView_Flick = UIView()

    private let backBtn_Flick: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left.circle.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = UIColor.white.withValues(alpha: 0.92)
        return b
    }()

    private let titleLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Create account"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let subtitleLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Join Flick and start sharing your glow."
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = UIColor.white.withValues(alpha: 0.85)
        l.numberOfLines = 0
        return l
    }()

    private let cardView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.96)
        v.layer.cornerRadius = 28
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withValues(alpha: 0.35).cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 20
        return v
    }()

    private lazy var userNameCredential_Flick = Register_Flick.makeCredentialRow_Flick(
        placeholder_flick: "Username", secure_flick: false, symbol_flick: "person.fill"
    )
    private lazy var passwordCredential_Flick = Register_Flick.makeCredentialRow_Flick(
        placeholder_flick: "Password", secure_flick: true, symbol_flick: "lock.fill"
    )
    private lazy var confirmCredential_Flick = Register_Flick.makeCredentialRow_Flick(
        placeholder_flick: "Confirm password", secure_flick: true, symbol_flick: "checkmark.shield.fill"
    )

    private var userNameField_Flick: UITextField { userNameCredential_Flick.field_flick }
    private var passwordField_Flick: UITextField { passwordCredential_Flick.field_flick }
    private var confirmField_Flick: UITextField { confirmCredential_Flick.field_flick }

    /// 卡片角标（与登录页风格统一）
    private let cardBadge_Flick: UILabel = {
        let l = UILabel()
        l.text = "NEW HERE"
        l.font = .systemFont(ofSize: 10, weight: .heavy)
        l.textColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.85)
        l.layer.cornerRadius = 8
        l.layer.masksToBounds = true
        l.layer.borderWidth = 1
        l.layer.borderColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.35).cgColor
        l.textAlignment = .center
        return l
    }()

    private let registerBtn_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Create account", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        return b
    }()

    private var registerBtnGradient_Flick: CAGradientLayer?

    private lazy var protocolLabel_Flick: UILabel = {
        var cfg = ProtocolHelper_Flick.ProtocolTextConfig_Flick.light_Flick()
        cfg.linkColor_Flick = ColorConfig_Flick.primaryGradientStart_Flick
        cfg.textColor_Flick = ColorConfig_Flick.textSecondary_Flick
        return ProtocolHelper_Flick.createProtocolTextLabel_Flick(
            firstContent_Flick: termsBody_Flick,
            secondContent_Flick: privacyBody_Flick,
            config_Flick: cfg,
            from: self
        )
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupBackground_Flick()
        setupDecorativeLayer_Flick()
        setupLayout_Flick()
        setupRegisterButtonGradient_Flick()
        backBtn_Flick.addTarget(self, action: #selector(backTapped_Flick), for: .touchUpInside)
        registerBtn_Flick.addTarget(self, action: #selector(registerTapped_Flick), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Flick.frame = view.bounds
        if let g = registerBtnGradient_Flick {
            g.frame = registerBtn_Flick.bounds
            g.cornerRadius = 16
        }
    }

    // MARK: - 工厂

    /// 构建圆角容器内的「图标 + UITextField」行（不使用 leftView）
    private static func makeCredentialRow_Flick(
        placeholder_flick: String,
        secure_flick: Bool,
        symbol_flick: String
    ) -> (container_flick: UIView, field_flick: UITextField) {
        let container_flick = UIView()
        container_flick.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        container_flick.layer.cornerRadius = 14
        container_flick.layer.borderWidth = 1
        container_flick.layer.borderColor = ColorConfig_Flick.divider_Flick.cgColor
        container_flick.clipsToBounds = true

        let row_flick = UIStackView()
        row_flick.axis = .horizontal
        row_flick.alignment = .center
        row_flick.spacing = 10
        row_flick.isLayoutMarginsRelativeArrangement = true
        row_flick.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        let icon_flick = UIImageView()
        let symCfg_flick = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        icon_flick.image = UIImage(systemName: symbol_flick, withConfiguration: symCfg_flick)
        icon_flick.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        icon_flick.contentMode = .scaleAspectFit
        icon_flick.setContentHuggingPriority(.required, for: .horizontal)
        icon_flick.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }

        let tf_flick = UITextField()
        tf_flick.font = .systemFont(ofSize: 16, weight: .regular)
        tf_flick.textColor = ColorConfig_Flick.textPrimary_Flick
        tf_flick.backgroundColor = .clear
        tf_flick.isSecureTextEntry = secure_flick
        tf_flick.autocapitalizationType = .none
        tf_flick.autocorrectionType = .no
        tf_flick.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf_flick.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tf_flick.attributedPlaceholder = NSAttributedString(
            string: placeholder_flick,
            attributes: [
                .foregroundColor: ColorConfig_Flick.textPlaceholder_Flick,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )

        row_flick.addArrangedSubview(icon_flick)
        row_flick.addArrangedSubview(tf_flick)
        container_flick.addSubview(row_flick)
        row_flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(52)
        }
        return (container_flick, tf_flick)
    }

    private func setupBackground_Flick() {
        view.layer.insertSublayer(gradientLayer_Flick, at: 0)
        gradientLayer_Flick.colors = [
            UIColor(hexstring_Flick: "#4C1D95").cgColor,
            UIColor(hexstring_Flick: "#6D28D9").cgColor,
            UIColor(hexstring_Flick: "#3B82F6").cgColor
        ]
        gradientLayer_Flick.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Flick.endPoint = CGPoint(x: 1, y: 1)
    }

    /// 背景漂浮装饰与底部文案（置于 scroll 之下，避免遮挡表单）
    private func setupDecorativeLayer_Flick() {
        for (i, emoji) in ["✦", "·", "✧", "◇"].enumerated() {
            let dot = UILabel()
            dot.text = emoji
            dot.font = .systemFont(ofSize: CGFloat([20, 12, 16, 14][i]))
            dot.textColor = UIColor.white.withValues(alpha: CGFloat([0.22, 0.32, 0.18, 0.16][i]))
            view.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(CGFloat(-22 - i * 88))
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(CGFloat(96 + i * 44))
            }
        }
        let footer_flick = UILabel()
        footer_flick.text = "✨ Your story starts here"
        footer_flick.font = .italicSystemFont(ofSize: 13)
        footer_flick.textColor = UIColor.white.withValues(alpha: 0.42)
        footer_flick.textAlignment = .center
        view.addSubview(footer_flick)
        footer_flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }

    private func setupLayout_Flick() {
        view.addSubview(scrollView_Flick)
        scrollView_Flick.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        view.addSubview(backBtn_Flick)
        backBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(44)
        }

        scrollView_Flick.addSubview(contentView_Flick)
        contentView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(scrollView_Flick.snp.width)
        }

        contentView_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.left.equalToSuperview().offset(28)
        }

        contentView_Flick.addSubview(subtitleLabel_Flick)
        subtitleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Flick.snp.bottom).offset(8)
            make.left.equalTo(titleLabel_Flick)
            make.right.lessThanOrEqualToSuperview().inset(28)
        }

        contentView_Flick.addSubview(cardView_Flick)
        cardView_Flick.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Flick.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }

        cardView_Flick.addSubview(cardBadge_Flick)
        cardBadge_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(88)
        }

        let stack = UIStackView(arrangedSubviews: [
            userNameCredential_Flick.container_flick,
            passwordCredential_Flick.container_flick,
            confirmCredential_Flick.container_flick,
            registerBtn_Flick
        ])
        stack.axis = .vertical
        stack.spacing = 14

        cardView_Flick.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(52)
            make.left.right.equalToSuperview().inset(22)
        }

        registerBtn_Flick.snp.makeConstraints { make in
            make.height.equalTo(54)
        }

        cardView_Flick.addSubview(protocolLabel_Flick)
        protocolLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(30)
        }

        contentView_Flick.snp.makeConstraints { make in
            make.bottom.equalTo(cardView_Flick.snp.bottom).offset(36)
        }

        // 装饰在底层；表单可交互；返回键最顶层
        view.bringSubviewToFront(scrollView_Flick)
        view.bringSubviewToFront(backBtn_Flick)
    }

    private func setupRegisterButtonGradient_Flick() {
        let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: registerBtn_Flick.bounds)
        g.cornerRadius = 16
        registerBtn_Flick.layer.insertSublayer(g, at: 0)
        registerBtnGradient_Flick = g
    }

    // MARK: - 事件

    @objc private func backTapped_Flick() {
        Navigation_Flick.pop_Flick(animated: true, from: self)
    }

    /// 校验非空与两次密码一致后注册；成功则由 ViewModel 调用 loginById_Flick
    @objc private func registerTapped_Flick() {
        view.endEditing(true)
        let name_flick = userNameField_Flick.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pwd_flick = passwordField_Flick.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm_flick = confirmField_Flick.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name_flick.isEmpty || pwd_flick.isEmpty || confirm_flick.isEmpty {
            Utils_Flick.showWarning_Flick(message_Flick: "Please fill in all fields.")
            return
        }
        if pwd_flick != confirm_flick {
            Utils_Flick.showWarning_Flick(message_Flick: "Passwords do not match.")
            return
        }
        UserViewModel_Flick.shared_Flick.loginById_Flick(userId_flick: 845417)
    }
}
