import Foundation
import UIKit
import SnapKit

// MARK: 登录页面

/// 登录页面
/// 功能：用户名 + 密码登录，支持 Apple 登录及协议查看；输入框均非空才允许提交
/// 设计：全屏渐变背景 + 多层装饰圆 + 浮动图标 + 外环品牌区 + 白卡（字段标签 + 图标泡泡 + 左侧色条 + OR 胶囊分割线）
class Login_Sprig: UIViewController {

    // MARK: - 属性

    /// 全屏渐变背景层
    private let bgGradientLayer_Sprig = CAGradientLayer()
    /// 登录按钮渐变层（viewDidLayoutSubviews 中更新 frame）
    private let loginGradientLayer_Sprig = CAGradientLayer()
    /// 品牌副标题（白卡 top 约束锚点）
    private let brandSubLabel_Sprig = UILabel()

    /// 用户名输入卡片（校验失败抖动）
    private let userNameCard_Sprig = UIView()
    /// 密码输入卡片（校验失败抖动）
    private let passwordCard_Sprig = UIView()
    /// 用户名输入框（读取校验值）
    private let userNameTextField_Sprig = UITextField()
    /// 密码输入框（读取校验值）
    private let passwordTextField_Sprig = UITextField()
    /// 登录按钮（渐变层更新 + 点击动画）
    private let loginButton_Sprig = UIButton(type: .system)

    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Sprig()
        registerKeyboardObservers_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradientLayer_Sprig.frame = view.bounds
        loginGradientLayer_Sprig.frame = loginButton_Sprig.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        buildBackground_Sprig()
        buildBrandArea_Sprig()
        buildCard_Sprig()
        let tap_Sprig = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sprig))
        tap_Sprig.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Sprig)
    }

    /// 搭建全屏渐变背景：4 层装饰圆 + 2 个浮动植物图标
    private func buildBackground_Sprig() {
        bgGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        bgGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        bgGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(bgGradientLayer_Sprig, at: 0)

        // 右上角大实填圆
        let c1_Sprig = makeDecoCircle_Sprig(radius: 90, alpha: 0.10, outlined: false)
        view.addSubview(c1_Sprig)
        c1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(58)
            make.top.equalToSuperview().offset(-46)
            make.width.height.equalTo(180)
        }

        // 左中描边圆
        let c2_Sprig = makeDecoCircle_Sprig(radius: 50, alpha: 0.20, outlined: true)
        view.addSubview(c2_Sprig)
        c2_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-28)
            make.top.equalToSuperview().offset(142)
            make.width.height.equalTo(100)
        }

        // 左上小实填圆
        let c3_Sprig = makeDecoCircle_Sprig(radius: 27, alpha: 0.08, outlined: false)
        view.addSubview(c3_Sprig)
        c3_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(38)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.width.height.equalTo(54)
        }

        // 右侧中部大描边圆（新增层次）
        let c4_Sprig = makeDecoCircle_Sprig(radius: 65, alpha: 0.12, outlined: true)
        view.addSubview(c4_Sprig)
        c4_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(38)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(155)
            make.width.height.equalTo(130)
        }

        // 浮动叶片图标（右上）
        let leaf1_Sprig = makeFloatIcon_Sprig(symbolName: "leaf.fill", ptSize: 20, alpha: 0.24)
        view.addSubview(leaf1_Sprig)
        leaf1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-22)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.width.height.equalTo(26)
        }

        // 浮动花朵图标（左下角，品牌区附近）
        let flower1_Sprig = makeFloatIcon_Sprig(symbolName: "camera.macro", ptSize: 16, alpha: 0.18)
        view.addSubview(flower1_Sprig)
        flower1_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.width.height.equalTo(22)
        }
    }

    /// 搭建品牌区：关闭按钮 + 外环 + 玻璃图标框 + 闪光角标 + App 名称 + 副标题
    private func buildBrandArea_Sprig() {
        // 右上角关闭按钮（玻璃圆角背景）
        let closeBtn_Sprig = UIButton(type: .system)
        let closeCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        closeBtn_Sprig.setImage(UIImage(systemName: "xmark", withConfiguration: closeCfg_Sprig), for: .normal)
        closeBtn_Sprig.tintColor = .white
        closeBtn_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        closeBtn_Sprig.layer.cornerRadius = 18
        closeBtn_Sprig.layer.borderWidth = 1
        closeBtn_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.38).cgColor
        closeBtn_Sprig.addTarget(self, action: #selector(onCloseTapped_Sprig), for: .touchUpInside)
        view.addSubview(closeBtn_Sprig)
        closeBtn_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.height.equalTo(36)
        }

        // 外描边大环
        let outerRing_Sprig = UIView()
        outerRing_Sprig.backgroundColor = .clear
        outerRing_Sprig.layer.cornerRadius = 46
        outerRing_Sprig.layer.borderWidth = 1
        outerRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        view.addSubview(outerRing_Sprig)
        outerRing_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.height.equalTo(92)
        }

        // 内玻璃图标背景
        let iconBg_Sprig = UIView()
        iconBg_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.24)
        iconBg_Sprig.layer.cornerRadius = 28
        iconBg_Sprig.layer.borderWidth = 1.5
        iconBg_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.46).cgColor
        view.addSubview(iconBg_Sprig)
        iconBg_Sprig.snp.makeConstraints { make in
            make.center.equalTo(outerRing_Sprig)
            make.width.height.equalTo(72)
        }

        // 叶片图标
        let leafCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        let leafIcon_Sprig = UIImageView(
            image: UIImage(systemName: "leaf.fill", withConfiguration: leafCfg_Sprig)
        )
        leafIcon_Sprig.tintColor = .white
        leafIcon_Sprig.contentMode = .scaleAspectFit
        iconBg_Sprig.addSubview(leafIcon_Sprig)
        leafIcon_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }

        // 右上角闪光角标
        let sparkleCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let sparkle_Sprig = UIImageView(
            image: UIImage(systemName: "sparkles", withConfiguration: sparkleCfg_Sprig)
        )
        sparkle_Sprig.tintColor = UIColor.white.withAlphaComponent(0.72)
        view.addSubview(sparkle_Sprig)
        sparkle_Sprig.snp.makeConstraints { make in
            make.left.equalTo(outerRing_Sprig.snp.right).offset(2)
            make.top.equalTo(outerRing_Sprig).offset(-4)
            make.width.height.equalTo(18)
        }

        // App 名称（字间距加宽）
        let titleLabel_Sprig = UILabel()
        titleLabel_Sprig.attributedText = NSAttributedString(
            string: "Sprig",
            attributes: [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold),
                .foregroundColor: UIColor.white,
                .kern: 1.2
            ]
        )
        titleLabel_Sprig.textAlignment = .center
        view.addSubview(titleLabel_Sprig)
        titleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(outerRing_Sprig.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // 副标题（白卡 top 锚）
        brandSubLabel_Sprig.text = "Your floral community 🌿"
        brandSubLabel_Sprig.font = UIFont.systemFont(ofSize: 14)
        brandSubLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.78)
        brandSubLabel_Sprig.textAlignment = .center
        view.addSubview(brandSubLabel_Sprig)
        brandSubLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Sprig.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建底部白卡（渐变左侧标题条 + 字段标签 + 输入卡 + 按钮 + 苹果登录 + 协议）
    private func buildCard_Sprig() {
        let cardView_Sprig = UIView()
        cardView_Sprig.backgroundColor = .white
        cardView_Sprig.layer.cornerRadius = 32
        cardView_Sprig.layer.cornerCurve = .continuous
        cardView_Sprig.clipsToBounds = true
        view.addSubview(cardView_Sprig)
        cardView_Sprig.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(brandSubLabel_Sprig.snp.bottom).offset(26)
        }

        let scrollView_Sprig = UIScrollView()
        scrollView_Sprig.showsVerticalScrollIndicator = false
        scrollView_Sprig.alwaysBounceVertical = false
        cardView_Sprig.addSubview(scrollView_Sprig)
        scrollView_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let cv_Sprig = UIView()
        scrollView_Sprig.addSubview(cv_Sprig)
        cv_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 标题左侧渐变色条
        let titleBar_Sprig = UIView()
        titleBar_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        titleBar_Sprig.layer.cornerRadius = 2
        cv_Sprig.addSubview(titleBar_Sprig)
        titleBar_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(28)
            make.width.equalTo(4)
            make.height.equalTo(26)
        }

        // 欢迎标题
        let welcomeLabel_Sprig = UILabel()
        welcomeLabel_Sprig.text = "Welcome back 👋"
        welcomeLabel_Sprig.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        welcomeLabel_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        cv_Sprig.addSubview(welcomeLabel_Sprig)
        welcomeLabel_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(titleBar_Sprig)
            make.left.equalTo(titleBar_Sprig.snp.right).offset(10)
        }

        // "MEMBER" 身份胶囊
        let memberBadge_Sprig = UILabel()
        memberBadge_Sprig.attributedText = NSAttributedString(
            string: "MEMBER",
            attributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .bold),
                .foregroundColor: ColorConfig_Sprig.primaryGradientStart_Sprig,
                .kern: 0.8
            ]
        )
        memberBadge_Sprig.textAlignment = .center
        memberBadge_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.10)
        memberBadge_Sprig.layer.cornerRadius = 8
        memberBadge_Sprig.clipsToBounds = true
        cv_Sprig.addSubview(memberBadge_Sprig)
        memberBadge_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(welcomeLabel_Sprig)
            make.left.equalTo(welcomeLabel_Sprig.snp.right).offset(8)
            make.height.equalTo(18)
            make.width.equalTo(62)
        }

        let subLabel_Sprig = UILabel()
        subLabel_Sprig.text = "Sign in to continue your journey"
        subLabel_Sprig.font = UIFont.systemFont(ofSize: 13)
        subLabel_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        cv_Sprig.addSubview(subLabel_Sprig)
        subLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(titleBar_Sprig.snp.bottom).offset(6)
            make.left.equalTo(titleBar_Sprig.snp.right).offset(10)
        }

        // USERNAME 字段标签 + 输入卡
        let userLabel_Sprig = buildSectionLabel_Sprig(
            title_Sprig: "USERNAME",
            below_Sprig: subLabel_Sprig.snp.bottom,
            offset_Sprig: 18,
            parent_Sprig: cv_Sprig,
            accentColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig
        )
        buildFieldCard_Sprig(
            card_Sprig: userNameCard_Sprig,
            field_Sprig: userNameTextField_Sprig,
            iconName_Sprig: "person.fill",
            placeholder_Sprig: "Enter your username",
            belowItem_Sprig: userLabel_Sprig.snp.bottom,
            offset_Sprig: 6,
            parent_Sprig: cv_Sprig,
            isPassword_Sprig: false,
            accentColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig
        )

        // PASSWORD 字段标签 + 输入卡
        let passLabel_Sprig = buildSectionLabel_Sprig(
            title_Sprig: "PASSWORD",
            below_Sprig: userNameCard_Sprig.snp.bottom,
            offset_Sprig: 14,
            parent_Sprig: cv_Sprig,
            accentColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig
        )
        buildFieldCard_Sprig(
            card_Sprig: passwordCard_Sprig,
            field_Sprig: passwordTextField_Sprig,
            iconName_Sprig: "lock.fill",
            placeholder_Sprig: "Enter your password",
            belowItem_Sprig: passLabel_Sprig.snp.bottom,
            offset_Sprig: 6,
            parent_Sprig: cv_Sprig,
            isPassword_Sprig: true,
            accentColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig
        )

        // 渐变登录按钮（56pt 高）
        loginGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        loginGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        loginGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
        loginGradientLayer_Sprig.cornerRadius = 28
        loginButton_Sprig.layer.insertSublayer(loginGradientLayer_Sprig, at: 0)
        loginButton_Sprig.setTitle("Sign In", for: .normal)
        loginButton_Sprig.setTitleColor(.white, for: .normal)
        loginButton_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        loginButton_Sprig.layer.cornerRadius = 28
        loginButton_Sprig.clipsToBounds = false
        loginButton_Sprig.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.46).cgColor
        loginButton_Sprig.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginButton_Sprig.layer.shadowOpacity = 1
        loginButton_Sprig.layer.shadowRadius = 14
        loginButton_Sprig.addTarget(self, action: #selector(onLoginTapped_Sprig), for: .touchUpInside)
        cv_Sprig.addSubview(loginButton_Sprig)
        loginButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(passwordCard_Sprig.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        // 没有账号？去注册
        let noAccountLabel_Sprig = UILabel()
        let attrStr_Sprig = NSMutableAttributedString()
        attrStr_Sprig.append(NSAttributedString(string: "Don't have an account? ", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: ColorConfig_Sprig.textSecondary_Sprig
        ]))
        attrStr_Sprig.append(NSAttributedString(string: "Sign Up", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: ColorConfig_Sprig.primaryGradientStart_Sprig
        ]))
        noAccountLabel_Sprig.attributedText = attrStr_Sprig
        noAccountLabel_Sprig.textAlignment = .center
        noAccountLabel_Sprig.isUserInteractionEnabled = true
        noAccountLabel_Sprig.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onRegisterTapped_Sprig))
        )
        cv_Sprig.addSubview(noAccountLabel_Sprig)
        noAccountLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(loginButton_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        // 协议文本
        let protocolLabel_Sprig = ProtocolHelper_Sprig.createProtocolTextLabel_Sprig(
            firstContent_Sprig: "terms.png",
            secondContent_Sprig: "privacy.png",
            config_Sprig: .light_Sprig(),
            from: self
        )
        cv_Sprig.addSubview(protocolLabel_Sprig)
        protocolLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(noAccountLabel_Sprig.snp.bottom).offset(60)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-34)
        }
    }

    // MARK: - 辅助构建方法

    /// 搭建字段区段小标签（uppercase + 字间距）
    /// - Returns: 标签视图（用于后续约束锚点）
    @discardableResult
    private func buildSectionLabel_Sprig(
        title_Sprig: String,
        below_Sprig: ConstraintItem,
        offset_Sprig: CGFloat,
        parent_Sprig: UIView,
        accentColor_Sprig: UIColor
    ) -> UILabel {
        let label_Sprig = UILabel()
        label_Sprig.attributedText = NSAttributedString(
            string: title_Sprig,
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: accentColor_Sprig.withAlphaComponent(0.70),
                .kern: 1.2
            ]
        )
        parent_Sprig.addSubview(label_Sprig)
        label_Sprig.snp.makeConstraints { make in
            make.top.equalTo(below_Sprig).offset(offset_Sprig)
            make.left.equalToSuperview().offset(28)
        }
        return label_Sprig
    }

    /// 搭建输入框卡片（左侧色条 + 图标泡泡 + 密码眼睛按钮）
    /// - Parameters:
    ///   - card_Sprig: 外层卡片（用于抖动动画引用）
    ///   - field_Sprig: UITextField（用于读取值和焦点管理）
    ///   - iconName_Sprig: SF Symbol 名称
    ///   - placeholder_Sprig: 占位文字（英文）
    ///   - belowItem_Sprig: SnapKit 上方锚点
    ///   - offset_Sprig: 与上方的间距
    ///   - parent_Sprig: 父视图
    ///   - isPassword_Sprig: 是否为密码框
    ///   - accentColor_Sprig: 主题强调色（左侧色条、图标颜色）
    private func buildFieldCard_Sprig(
        card_Sprig: UIView,
        field_Sprig: UITextField,
        iconName_Sprig: String,
        placeholder_Sprig: String,
        belowItem_Sprig: ConstraintItem,
        offset_Sprig: CGFloat,
        parent_Sprig: UIView,
        isPassword_Sprig: Bool,
        accentColor_Sprig: UIColor
    ) {
        card_Sprig.backgroundColor = .white
        card_Sprig.layer.cornerRadius = 16
        card_Sprig.layer.borderWidth = 1.0
        card_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        card_Sprig.clipsToBounds = true
        parent_Sprig.addSubview(card_Sprig)
        card_Sprig.snp.makeConstraints { make in
            make.top.equalTo(belowItem_Sprig).offset(offset_Sprig)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        // 左侧渐变色条
        let accentStrip_Sprig = UIView()
        accentStrip_Sprig.backgroundColor = accentColor_Sprig.withAlphaComponent(0.60)
        card_Sprig.addSubview(accentStrip_Sprig)
        card_Sprig.sendSubviewToBack(accentStrip_Sprig)
        accentStrip_Sprig.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        // 图标圆形泡泡背景
        let iconBubble_Sprig = UIView()
        iconBubble_Sprig.backgroundColor = accentColor_Sprig.withAlphaComponent(0.10)
        iconBubble_Sprig.layer.cornerRadius = 17
        card_Sprig.addSubview(iconBubble_Sprig)
        iconBubble_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }

        let iconCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iconView_Sprig = UIImageView(
            image: UIImage(systemName: iconName_Sprig, withConfiguration: iconCfg_Sprig)
        )
        iconView_Sprig.tintColor = accentColor_Sprig
        iconView_Sprig.contentMode = .scaleAspectFit
        iconBubble_Sprig.addSubview(iconView_Sprig)
        iconView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(17)
        }

        // 输入框
        field_Sprig.placeholder = placeholder_Sprig
        field_Sprig.placeHolderTextColor_Sprig(ColorConfig_Sprig.textPlaceholder_Sprig)
        field_Sprig.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        field_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        field_Sprig.isSecureTextEntry = isPassword_Sprig
        field_Sprig.returnKeyType = isPassword_Sprig ? .done : .next
        field_Sprig.delegate = self
        field_Sprig.autocapitalizationType = .none
        field_Sprig.autocorrectionType = .no
        card_Sprig.addSubview(field_Sprig)

        if isPassword_Sprig {
            let eyeBtn_Sprig = UIButton(type: .system)
            let eyeCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            eyeBtn_Sprig.setImage(
                UIImage(systemName: "eye.slash.fill", withConfiguration: eyeCfg_Sprig), for: .normal
            )
            eyeBtn_Sprig.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
            eyeBtn_Sprig.addAction(UIAction { [weak field_Sprig, weak eyeBtn_Sprig] _ in
                guard let field_Sprig, let eyeBtn_Sprig else { return }
                field_Sprig.isSecureTextEntry.toggle()
                let name_Sprig = field_Sprig.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
                eyeBtn_Sprig.setImage(
                    UIImage(systemName: name_Sprig,
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)),
                    for: .normal
                )
            }, for: .touchUpInside)
            card_Sprig.addSubview(eyeBtn_Sprig)
            eyeBtn_Sprig.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-14)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(28)
            }
            field_Sprig.snp.makeConstraints { make in
                make.left.equalTo(iconBubble_Sprig.snp.right).offset(10)
                make.right.equalTo(eyeBtn_Sprig.snp.left).offset(-6)
                make.top.bottom.equalToSuperview()
            }
        } else {
            field_Sprig.snp.makeConstraints { make in
                make.left.equalTo(iconBubble_Sprig.snp.right).offset(10)
                make.right.equalToSuperview().offset(-14)
                make.top.bottom.equalToSuperview()
            }
        }
    }

    /// 创建装饰圆（实填或描边）
    /// - Parameters:
    ///   - radius: 圆角半径（= 直径 / 2）
    ///   - alpha: 透明度
    ///   - outlined: true 为描边圆，false 为实填圆
    private func makeDecoCircle_Sprig(radius: CGFloat, alpha: CGFloat, outlined: Bool) -> UIView {
        let circle_Sprig = UIView()
        circle_Sprig.layer.cornerRadius = radius
        if outlined {
            circle_Sprig.backgroundColor = .clear
            circle_Sprig.layer.borderWidth = 1.5
            circle_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(alpha).cgColor
        } else {
            circle_Sprig.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        }
        return circle_Sprig
    }

    /// 创建浮动图标（半透明 SF Symbol）
    /// - Parameters:
    ///   - symbolName: SF Symbol 名称
    ///   - ptSize: 字号大小
    ///   - alpha: 透明度
    private func makeFloatIcon_Sprig(symbolName: String, ptSize: CGFloat, alpha: CGFloat) -> UIImageView {
        let cfg_Sprig = UIImage.SymbolConfiguration(pointSize: ptSize, weight: .light)
        let icon_Sprig = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: cfg_Sprig))
        icon_Sprig.tintColor = UIColor.white.withAlphaComponent(alpha)
        icon_Sprig.contentMode = .scaleAspectFit
        return icon_Sprig
    }

    // MARK: - 键盘管理

    private func registerKeyboardObservers_Sprig() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardShow_Sprig(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardHide_Sprig(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func onKeyboardShow_Sprig(_ notification: Notification) {
        guard let frame_Sprig = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        UIView.animate(withDuration: 0.28) {
            self.view.frame.origin.y = -frame_Sprig.height * 0.25
        }
    }

    @objc private func onKeyboardHide_Sprig(_ notification: Notification) {
        UIView.animate(withDuration: 0.28) {
            self.view.frame.origin.y = 0
        }
    }

    @objc private func dismissKeyboard_Sprig() {
        view.endEditing(true)
    }

    // MARK: - 事件处理

    /// 点击关闭：dismiss 登录页，回到调用方
    @objc private func onCloseTapped_Sprig() {
        Navigation_Sprig.dismiss_Sprig()
    }

    @objc private func onRegisterTapped_Sprig() {
        Navigation_Sprig.toRegister_Sprig(style_sprig: .push_sprig)
    }

    /// 点击登录：校验用户名和密码均非空 → 匹配本地用户 → 调用 loginById_Sprig
    @objc private func onLoginTapped_Sprig() {
        view.endEditing(true)
        let username_Sprig = userNameTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password_Sprig = passwordTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !username_Sprig.isEmpty else {
            Utils_Sprig.showError_Sprig(message_Sprig: "Username cannot be empty")
            shakeField_Sprig(userNameCard_Sprig)
            return
        }
        guard !password_Sprig.isEmpty else {
            Utils_Sprig.showError_Sprig(message_Sprig: "Password cannot be empty")
            shakeField_Sprig(passwordCard_Sprig)
            return
        }

        loginButton_Sprig.animatePressDown_Sprig { [weak self] in
            self?.loginButton_Sprig.animatePressUp_Sprig()
        }

        // 本地演示：按用户名匹配 userId，未匹配时使用 1
        let matched_Sprig = LocalData_Sprig.shared_Sprig.userList_Sprig.first {
            $0.userName_Sprig?.lowercased() == username_Sprig.lowercased()
        }
        UserViewModel_Sprig.shared_Sprig.loginById_Sprig(userId_sprig: matched_Sprig?.userId_Sprig ?? 1)
    }

    /// 输入卡片校验失败抖动 + 边框短暂变红
    /// - Parameter targetView_Sprig: 目标卡片
    private func shakeField_Sprig(_ targetView_Sprig: UIView) {
        let anim_Sprig = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim_Sprig.timingFunction = CAMediaTimingFunction(name: .linear)
        anim_Sprig.duration = 0.4
        anim_Sprig.values = [-8, 8, -6, 6, -4, 4, 0]
        targetView_Sprig.layer.add(anim_Sprig, forKey: "shake_Sprig")
        targetView_Sprig.layer.borderColor = UIColor(hexstring_Sprig: "#FC8181").cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            targetView_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        }
    }
}

// MARK: - UITextFieldDelegate

extension Login_Sprig: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField_Sprig {
            passwordTextField_Sprig.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    /// 聚焦时输入卡片边框高亮为品牌色
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let activeColor_Sprig = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.55).cgColor
        if textField == userNameTextField_Sprig {
            userNameCard_Sprig.layer.borderColor = activeColor_Sprig
        } else if textField == passwordTextField_Sprig {
            passwordCard_Sprig.layer.borderColor = activeColor_Sprig
        }
    }

    /// 失焦时恢复默认边框色
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userNameTextField_Sprig {
            userNameCard_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        } else if textField == passwordTextField_Sprig {
            passwordCard_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        }
    }
}
