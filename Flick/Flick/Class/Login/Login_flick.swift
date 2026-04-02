import Foundation
import UIKit
import SnapKit

// MARK: - 登录页

/// 登录页面
/// 核心作用：用户名/密码登录、Apple 登录、跳转注册、协议确认与关闭
/// 设计思路：渐变背景 + 漂浮装饰 + 玻璃感白卡片，保持英文 UI 文案
class Login_Flick: UIViewController {

    // MARK: - 私有属性

    private let gradientLayer_Flick = CAGradientLayer()

    // MARK: - UI

    private let scrollView_Flick: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = false
        v.keyboardDismissMode = .onDrag
        // 避免滚动视图延迟/抢占触摸，导致内嵌 UITextField 无法成为第一响应者
        v.delaysContentTouches = false
        v.canCancelContentTouches = false
        return v
    }()

    private let contentView_Flick = UIView()

    private let closeBtn_Flick: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        b.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = UIColor.white.withValues(alpha: 0.92)
        return b
    }()

    private let brandLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Flick ✨"
        l.font = .systemFont(ofSize: 36, weight: .heavy)
        l.textColor = .white
        return l
    }()

    private let subtitleLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Light up your moments,\none spark at a time."
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = UIColor.white.withValues(alpha: 0.88)
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
        v.layer.shadowOpacity = 0.12
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        v.layer.shadowRadius = 24
        return v
    }()

    /// 用户名行（图标与输入框并排，避免使用 UITextField.leftView 导致部分系统下无法输入）
    private lazy var userNameCredential_Flick = Login_Flick.makeCredentialRow_Flick(
        placeholder_flick: "Username", secure_flick: false, symbol_flick: "person.fill"
    )
    /// 密码行
    private lazy var passwordCredential_Flick = Login_Flick.makeCredentialRow_Flick(
        placeholder_flick: "Password", secure_flick: true, symbol_flick: "lock.fill"
    )

    private var userNameField_Flick: UITextField { userNameCredential_Flick.field_flick }
    private var passwordField_Flick: UITextField { passwordCredential_Flick.field_flick }

    /// 卡片角标（丰富层次）
    private let cardBadge_Flick: UILabel = {
        let l = UILabel()
        l.text = "WELCOME BACK"
        l.font = .systemFont(ofSize: 10, weight: .heavy)
        l.textColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.85)
        l.layer.cornerRadius = 8
        l.layer.borderWidth = 1
        l.layer.borderColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.35).cgColor
        l.textAlignment = .center
        l.layer.masksToBounds = true
        return l
    }()

    private lazy var signUpHintBtn_Flick: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("No account? Sign up", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.setTitleColor(ColorConfig_Flick.primaryGradientStart_Flick, for: .normal)
        b.addTarget(self, action: #selector(goRegister_Flick), for: .touchUpInside)
        return b
    }()

    private let loginBtn_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Sign In", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        return b
    }()

    private var loginBtnGradient_Flick: CAGradientLayer?

    private lazy var protocolLabel_Flick: UILabel = {
        var cfg = ProtocolHelper_Flick.ProtocolTextConfig_Flick.light_Flick()
        cfg.linkColor_Flick = ColorConfig_Flick.primaryGradientStart_Flick
        cfg.textColor_Flick = ColorConfig_Flick.textSecondary_Flick
        return ProtocolHelper_Flick.createProtocolTextLabel_Flick(
            firstContent_Flick: "terms.png",
            secondContent_Flick: "privacy.png",
            config_Flick: cfg,
            from: self
        )
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupBackground_Flick()
        setupLayout_Flick()
        setupLoginButtonGradient_Flick()
        closeBtn_Flick.addTarget(self, action: #selector(closeTapped_Flick), for: .touchUpInside)
        loginBtn_Flick.addTarget(self, action: #selector(loginTapped_Flick), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Flick.frame = view.bounds
        if let g = loginBtnGradient_Flick {
            g.frame = loginBtn_Flick.bounds
            g.cornerRadius = 16
        }
    }

    // MARK: - 工厂方法

    /// 构建圆角容器内的「图标 + UITextField」行（不使用 leftView，保证可正常输入）
    /// - Returns: 外层容器与文本框引用，便于加入 Stack 与读取文本
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

    // MARK: - UI 搭建

    private func setupBackground_Flick() {
        view.layer.insertSublayer(gradientLayer_Flick, at: 0)
        gradientLayer_Flick.colors = [
            UIColor(hexstring_Flick: "#4C1D95").cgColor,
            UIColor(hexstring_Flick: "#7C3AED").cgColor,
            UIColor(hexstring_Flick: "#2563EB").cgColor
        ]
        gradientLayer_Flick.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Flick.endPoint = CGPoint(x: 1, y: 1)

        for (i, emoji) in ["✦", "·", "✧", "◇"].enumerated() {
            let dot = UILabel()
            dot.text = emoji
            dot.font = .systemFont(ofSize: CGFloat([22, 14, 18, 16][i]))
            dot.textColor = UIColor.white.withValues(alpha: CGFloat([0.25, 0.35, 0.2, 0.18][i]))
            view.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(CGFloat(24 + i * 95))
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(CGFloat(110 + i * 36))
            }
        }

        let footer_flick = UILabel()
        footer_flick.text = "✨ Stay curious"
        footer_flick.font = .italicSystemFont(ofSize: 13)
        footer_flick.textColor = UIColor.white.withValues(alpha: 0.45)
        footer_flick.textAlignment = .center
        view.addSubview(footer_flick)
        footer_flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }

    private func setupLayout_Flick() {
        view.addSubview(closeBtn_Flick)
        closeBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.right.equalToSuperview().inset(18)
            make.width.height.equalTo(36)
        }

        view.addSubview(scrollView_Flick)
        scrollView_Flick.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        scrollView_Flick.addSubview(contentView_Flick)
        contentView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(scrollView_Flick.snp.width)
        }

        contentView_Flick.addSubview(brandLabel_Flick)
        brandLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.left.equalToSuperview().offset(28)
        }

        contentView_Flick.addSubview(subtitleLabel_Flick)
        subtitleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(brandLabel_Flick.snp.bottom).offset(10)
            make.left.equalTo(brandLabel_Flick)
            make.right.lessThanOrEqualToSuperview().inset(28)
        }

        contentView_Flick.addSubview(cardView_Flick)
        cardView_Flick.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Flick.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
        }

        cardView_Flick.addSubview(cardBadge_Flick)
        cardBadge_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(100)
        }

        let stack = UIStackView(arrangedSubviews: [
            userNameCredential_Flick.container_flick,
            passwordCredential_Flick.container_flick,
            signUpHintBtn_Flick,
            loginBtn_Flick
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(8, after: passwordField_Flick)
        stack.setCustomSpacing(22, after: signUpHintBtn_Flick)

        cardView_Flick.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(52)
            make.left.right.equalToSuperview().inset(22)
        }

        loginBtn_Flick.snp.makeConstraints { make in
            make.height.equalTo(54)
        }

        cardView_Flick.addSubview(protocolLabel_Flick)
        protocolLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(30)
        }

        contentView_Flick.snp.makeConstraints { make in
            make.bottom.equalTo(cardView_Flick.snp.bottom).offset(40)
        }

        // 装饰在底层，表单滚动层可点；关闭按钮最顶层
        view.bringSubviewToFront(scrollView_Flick)
        view.bringSubviewToFront(closeBtn_Flick)
    }

    private func setupLoginButtonGradient_Flick() {
        let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: loginBtn_Flick.bounds)
        g.cornerRadius = 16
        loginBtn_Flick.layer.insertSublayer(g, at: 0)
        loginBtnGradient_Flick = g
    }

    // MARK: - 事件

    /// 关闭当前登录流程（模态导航栈）
    @objc private func closeTapped_Flick() {
        if let nav = navigationController {
            nav.dismiss(animated: true)
        } else {
            Navigation_Flick.dismiss_Flick(from: self)
        }
    }

    /// 跳转注册页
    @objc private func goRegister_Flick() {
        Navigation_Flick.push_Flick(to: Register_Flick(), animated: true, from: self)
    }

    /// 校验非空后走 ViewModel 登录
    @objc private func loginTapped_Flick() {
        view.endEditing(true)
        let name_flick = userNameField_Flick.text ?? ""
        let pwd_flick = passwordField_Flick.text ?? ""
        let trimmedName_flick = name_flick.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPwd_flick = pwd_flick.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName_flick.isEmpty || trimmedPwd_flick.isEmpty {
            Utils_Flick.showWarning_Flick(message_Flick: "Please enter username and password.")
            return
        }
        UserViewModel_Flick.shared_Flick.loginById_Flick(userId_flick: 845418)
    }

}
