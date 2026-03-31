import Foundation
import UIKit
import SnapKit

// MARK: 注册页面

/// 注册页面
/// 功能：用户名 + 密码 + 确认密码注册；三个字段均非空且密码一致才允许提交
/// 设计：辅助渐变背景 + 多层装饰圆 + 浮动图标 + 外环品牌区 + 步骤标签 + 密码强度提示
class Register_Sprig: UIViewController {

    // MARK: - 属性

    /// 全屏渐变背景层
    private let bgGradientLayer_Sprig = CAGradientLayer()
    /// 注册按钮渐变层（viewDidLayoutSubviews 中更新 frame）
    private let registerGradientLayer_Sprig = CAGradientLayer()
    /// 品牌副标题（白卡 top 约束锚点）
    private let brandSubLabel_Sprig = UILabel()

    /// 用户名输入卡片（校验失败抖动）
    private let userNameCard_Sprig = UIView()
    /// 密码输入卡片（校验失败抖动）
    private let passwordCard_Sprig = UIView()
    /// 确认密码输入卡片（校验失败抖动）
    private let confirmPasswordCard_Sprig = UIView()

    /// 用户名输入框（读取校验值）
    private let userNameTextField_Sprig = UITextField()
    /// 密码输入框（读取校验值）
    private let passwordTextField_Sprig = UITextField()
    /// 确认密码输入框（读取校验值）
    private let confirmPasswordTextField_Sprig = UITextField()

    /// 注册按钮（渐变层更新 + 点击动画）
    private let registerButton_Sprig = UIButton(type: .system)

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
        registerGradientLayer_Sprig.frame = registerButton_Sprig.bounds
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

    /// 搭建全屏辅助渐变背景：4 层装饰圆 + 2 个浮动植物图标
    private func buildBackground_Sprig() {
        bgGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.secondaryGradientEnd_Sprig.cgColor
        ]
        bgGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        bgGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(bgGradientLayer_Sprig, at: 0)

        // 右上角大实填圆
        let c1_Sprig = makeDecoCircle_Sprig(radius: 75, alpha: 0.12, outlined: false)
        view.addSubview(c1_Sprig)
        c1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(46)
            make.top.equalToSuperview().offset(-38)
            make.width.height.equalTo(150)
        }

        // 左中描边圆
        let c2_Sprig = makeDecoCircle_Sprig(radius: 44, alpha: 0.22, outlined: true)
        view.addSubview(c2_Sprig)
        c2_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(120)
            make.width.height.equalTo(88)
        }

        // 左上小实填圆
        let c3_Sprig = makeDecoCircle_Sprig(radius: 24, alpha: 0.08, outlined: false)
        view.addSubview(c3_Sprig)
        c3_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(42)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(48)
            make.width.height.equalTo(48)
        }

        // 右侧中部大描边圆（层次感）
        let c4_Sprig = makeDecoCircle_Sprig(radius: 60, alpha: 0.10, outlined: true)
        view.addSubview(c4_Sprig)
        c4_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(32)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(145)
            make.width.height.equalTo(120)
        }

        // 浮动花朵图标（右上）
        let flower1_Sprig = makeFloatIcon_Sprig(symbolName: "flower.fill", ptSize: 18, alpha: 0.22)
        view.addSubview(flower1_Sprig)
        flower1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.width.height.equalTo(24)
        }

        // 浮动叶片图标（左下）
        let leaf1_Sprig = makeFloatIcon_Sprig(symbolName: "leaf", ptSize: 15, alpha: 0.16)
        view.addSubview(leaf1_Sprig)
        leaf1_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(88)
            make.width.height.equalTo(20)
        }
    }

    /// 搭建品牌区：返回按钮 + 外环 + 花朵图标 + 闪光角标 + 标题 + 副标题
    private func buildBrandArea_Sprig() {
        // 返回按钮（玻璃圆角背景）
        let backBtn_Sprig = UIButton(type: .system)
        let backCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn_Sprig.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_Sprig), for: .normal)
        backBtn_Sprig.tintColor = .white
        backBtn_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_Sprig.layer.cornerRadius = 18
        backBtn_Sprig.layer.borderWidth = 1
        backBtn_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.38).cgColor
        backBtn_Sprig.addTarget(self, action: #selector(onBackTapped_Sprig), for: .touchUpInside)
        view.addSubview(backBtn_Sprig)
        backBtn_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.height.equalTo(36)
        }

        // 外描边大环
        let outerRing_Sprig = UIView()
        outerRing_Sprig.backgroundColor = .clear
        outerRing_Sprig.layer.cornerRadius = 40
        outerRing_Sprig.layer.borderWidth = 1
        outerRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        view.addSubview(outerRing_Sprig)
        outerRing_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(22)
            make.width.height.equalTo(80)
        }

        // 内玻璃图标背景
        let iconBg_Sprig = UIView()
        iconBg_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.24)
        iconBg_Sprig.layer.cornerRadius = 24
        iconBg_Sprig.layer.borderWidth = 1.5
        iconBg_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.46).cgColor
        view.addSubview(iconBg_Sprig)
        iconBg_Sprig.snp.makeConstraints { make in
            make.center.equalTo(outerRing_Sprig)
            make.width.height.equalTo(62)
        }

        // 花朵图标
        let flowerCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        let flowerIcon_Sprig = UIImageView(
            image: UIImage(systemName: "flower.fill", withConfiguration: flowerCfg_Sprig)
        )
        flowerIcon_Sprig.tintColor = .white
        flowerIcon_Sprig.contentMode = .scaleAspectFit
        iconBg_Sprig.addSubview(flowerIcon_Sprig)
        flowerIcon_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }

        // 右上角 "new" 角标胶囊
        let newBadge_Sprig = UILabel()
        newBadge_Sprig.attributedText = NSAttributedString(
            string: "NEW",
            attributes: [
                .font: UIFont.systemFont(ofSize: 8, weight: .bold),
                .foregroundColor: UIColor.white,
                .kern: 0.6
            ]
        )
        newBadge_Sprig.textAlignment = .center
        newBadge_Sprig.backgroundColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.85)
        newBadge_Sprig.layer.cornerRadius = 7
        newBadge_Sprig.clipsToBounds = true
        view.addSubview(newBadge_Sprig)
        newBadge_Sprig.snp.makeConstraints { make in
            make.top.equalTo(outerRing_Sprig).offset(-4)
            make.left.equalTo(outerRing_Sprig.snp.right).offset(2)
            make.height.equalTo(16)
            make.width.equalTo(28)
        }

        // App 名称
        let titleLabel_Sprig = UILabel()
        titleLabel_Sprig.attributedText = NSAttributedString(
            string: "Join Sprig",
            attributes: [
                .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                .foregroundColor: UIColor.white,
                .kern: 0.8
            ]
        )
        titleLabel_Sprig.textAlignment = .center
        view.addSubview(titleLabel_Sprig)
        titleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(outerRing_Sprig.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // 副标题（白卡 top 锚）
        brandSubLabel_Sprig.text = "Grow with our community 🌸"
        brandSubLabel_Sprig.font = UIFont.systemFont(ofSize: 14)
        brandSubLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.78)
        brandSubLabel_Sprig.textAlignment = .center
        view.addSubview(brandSubLabel_Sprig)
        brandSubLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Sprig.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建底部白卡（步骤标签 + 三个字段 + 密码提示 + 注册按钮 + 协议）
    private func buildCard_Sprig() {
        let cardView_Sprig = UIView()
        cardView_Sprig.backgroundColor = .white
        cardView_Sprig.layer.cornerRadius = 32
        cardView_Sprig.layer.cornerCurve = .continuous
        cardView_Sprig.clipsToBounds = true
        view.addSubview(cardView_Sprig)
        cardView_Sprig.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(brandSubLabel_Sprig.snp.bottom).offset(24)
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
        titleBar_Sprig.backgroundColor = ColorConfig_Sprig.secondaryGradientStart_Sprig
        titleBar_Sprig.layer.cornerRadius = 2
        cv_Sprig.addSubview(titleBar_Sprig)
        titleBar_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(26)
            make.width.equalTo(4)
            make.height.equalTo(26)
        }

        // 卡片主标题
        let cardTitle_Sprig = UILabel()
        cardTitle_Sprig.text = "Create Account"
        cardTitle_Sprig.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        cardTitle_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        cv_Sprig.addSubview(cardTitle_Sprig)
        cardTitle_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(titleBar_Sprig)
            make.left.equalTo(titleBar_Sprig.snp.right).offset(10)
        }

        // "FREE" 账户胶囊
        let freeBadge_Sprig = UILabel()
        freeBadge_Sprig.attributedText = NSAttributedString(
            string: "FREE",
            attributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .bold),
                .foregroundColor: ColorConfig_Sprig.secondaryGradientStart_Sprig,
                .kern: 0.8
            ]
        )
        freeBadge_Sprig.textAlignment = .center
        freeBadge_Sprig.backgroundColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.10)
        freeBadge_Sprig.layer.cornerRadius = 8
        freeBadge_Sprig.clipsToBounds = true
        cv_Sprig.addSubview(freeBadge_Sprig)
        freeBadge_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(cardTitle_Sprig)
            make.left.equalTo(cardTitle_Sprig.snp.right).offset(8)
            make.height.equalTo(18)
            make.width.equalTo(40)
        }

        let cardSub_Sprig = UILabel()
        cardSub_Sprig.text = "Fill in your details to get started"
        cardSub_Sprig.font = UIFont.systemFont(ofSize: 13)
        cardSub_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        cv_Sprig.addSubview(cardSub_Sprig)
        cardSub_Sprig.snp.makeConstraints { make in
            make.top.equalTo(titleBar_Sprig.snp.bottom).offset(6)
            make.left.equalTo(titleBar_Sprig.snp.right).offset(10)
        }

        // 步骤进度条（3 个小点）
        let stepRow_Sprig = buildStepDots_Sprig(parent_Sprig: cv_Sprig, below_Sprig: cardSub_Sprig.snp.bottom)

        // USERNAME 字段标签 + 输入卡
        let userLabel_Sprig = buildSectionLabel_Sprig(
            title_Sprig: "USERNAME",
            below_Sprig: stepRow_Sprig.snp.bottom,
            offset_Sprig: 14,
            parent_Sprig: cv_Sprig,
            accentColor_Sprig: ColorConfig_Sprig.secondaryGradientStart_Sprig
        )
        buildFieldCard_Sprig(
            card_Sprig: userNameCard_Sprig,
            field_Sprig: userNameTextField_Sprig,
            iconName_Sprig: "person.fill",
            placeholder_Sprig: "Choose a username",
            belowItem_Sprig: userLabel_Sprig.snp.bottom,
            offset_Sprig: 6,
            parent_Sprig: cv_Sprig,
            isPassword_Sprig: false,
            accentColor_Sprig: ColorConfig_Sprig.secondaryGradientStart_Sprig
        )

        // PASSWORD 字段标签 + 输入卡
        let passLabel_Sprig = buildSectionLabel_Sprig(
            title_Sprig: "PASSWORD",
            below_Sprig: userNameCard_Sprig.snp.bottom,
            offset_Sprig: 14,
            parent_Sprig: cv_Sprig,
            accentColor_Sprig: ColorConfig_Sprig.secondaryGradientStart_Sprig
        )
        buildFieldCard_Sprig(
            card_Sprig: passwordCard_Sprig,
            field_Sprig: passwordTextField_Sprig,
            iconName_Sprig: "lock.fill",
            placeholder_Sprig: "Create a strong password",
            belowItem_Sprig: passLabel_Sprig.snp.bottom,
            offset_Sprig: 6,
            parent_Sprig: cv_Sprig,
            isPassword_Sprig: true,
            accentColor_Sprig: ColorConfig_Sprig.secondaryGradientStart_Sprig
        )

        // CONFIRM PASSWORD 字段标签 + 输入卡
        let confirmLabel_Sprig = buildSectionLabel_Sprig(
            title_Sprig: "CONFIRM PASSWORD",
            below_Sprig: passwordCard_Sprig.snp.bottom,
            offset_Sprig: 14,
            parent_Sprig: cv_Sprig,
            accentColor_Sprig: ColorConfig_Sprig.secondaryGradientStart_Sprig
        )
        buildFieldCard_Sprig(
            card_Sprig: confirmPasswordCard_Sprig,
            field_Sprig: confirmPasswordTextField_Sprig,
            iconName_Sprig: "lock.rotation",
            placeholder_Sprig: "Repeat your password",
            belowItem_Sprig: confirmLabel_Sprig.snp.bottom,
            offset_Sprig: 6,
            parent_Sprig: cv_Sprig,
            isPassword_Sprig: true,
            accentColor_Sprig: ColorConfig_Sprig.secondaryGradientStart_Sprig
        )

        // 密码规则提示（胶囊样式）
        let hintContainer_Sprig = UIView()
        hintContainer_Sprig.backgroundColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.07)
        hintContainer_Sprig.layer.cornerRadius = 10
        cv_Sprig.addSubview(hintContainer_Sprig)
        hintContainer_Sprig.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordCard_Sprig.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(32)
        }

        let hintIcon_Sprig = UIImageView(
            image: UIImage(systemName: "info.circle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        )
        hintIcon_Sprig.tintColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.70)
        hintContainer_Sprig.addSubview(hintIcon_Sprig)
        hintIcon_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }

        let hintLabel_Sprig = UILabel()
        hintLabel_Sprig.text = "Make sure both passwords match exactly"
        hintLabel_Sprig.font = UIFont.systemFont(ofSize: 11)
        hintLabel_Sprig.textColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.80)
        hintContainer_Sprig.addSubview(hintLabel_Sprig)
        hintLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(hintIcon_Sprig.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }

        // 渐变注册按钮（56pt）
        registerGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.secondaryGradientEnd_Sprig.cgColor
        ]
        registerGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        registerGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
        registerGradientLayer_Sprig.cornerRadius = 28
        registerButton_Sprig.layer.insertSublayer(registerGradientLayer_Sprig, at: 0)
        registerButton_Sprig.setTitle("Sign Up", for: .normal)
        registerButton_Sprig.setTitleColor(.white, for: .normal)
        registerButton_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        registerButton_Sprig.layer.cornerRadius = 28
        registerButton_Sprig.clipsToBounds = false
        registerButton_Sprig.layer.shadowColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.46).cgColor
        registerButton_Sprig.layer.shadowOffset = CGSize(width: 0, height: 6)
        registerButton_Sprig.layer.shadowOpacity = 1
        registerButton_Sprig.layer.shadowRadius = 14
        registerButton_Sprig.addTarget(self, action: #selector(onRegisterTapped_Sprig), for: .touchUpInside)
        cv_Sprig.addSubview(registerButton_Sprig)
        registerButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(hintContainer_Sprig.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        // 已有账号？去登录
        let hasAccountLabel_Sprig = UILabel()
        let attrStr_Sprig = NSMutableAttributedString()
        attrStr_Sprig.append(NSAttributedString(string: "Already have an account? ", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: ColorConfig_Sprig.textSecondary_Sprig
        ]))
        attrStr_Sprig.append(NSAttributedString(string: "Sign In", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: ColorConfig_Sprig.secondaryGradientStart_Sprig
        ]))
        hasAccountLabel_Sprig.attributedText = attrStr_Sprig
        hasAccountLabel_Sprig.textAlignment = .center
        hasAccountLabel_Sprig.isUserInteractionEnabled = true
        hasAccountLabel_Sprig.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onBackTapped_Sprig))
        )
        cv_Sprig.addSubview(hasAccountLabel_Sprig)
        hasAccountLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(registerButton_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        // 协议文本
        let protocolLabel_Sprig = ProtocolHelper_Sprig.createProtocolTextLabel_Sprig(
            firstContent_Sprig: "terms_sprig.png",
            secondContent_Sprig: "privacy_sprig.png",
            config_Sprig: .light_Sprig(),
            from: self
        )
        cv_Sprig.addSubview(protocolLabel_Sprig)
        protocolLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(hasAccountLabel_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-34)
        }
    }

    // MARK: - 辅助构建方法

    /// 搭建 3 步骤进度点（注册流程可视化）
    /// - Returns: 容器视图（用于后续约束锚点）
    @discardableResult
    private func buildStepDots_Sprig(parent_Sprig: UIView, below_Sprig: ConstraintItem) -> UIView {
        let container_Sprig = UIView()
        parent_Sprig.addSubview(container_Sprig)
        container_Sprig.snp.makeConstraints { make in
            make.top.equalTo(below_Sprig).offset(12)
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(8)
        }

        // 3 个步骤点：当前高亮，后续灰色
        let dotColors_Sprig: [UIColor] = [
            ColorConfig_Sprig.secondaryGradientStart_Sprig,
            ColorConfig_Sprig.divider_Sprig,
            ColorConfig_Sprig.divider_Sprig
        ]
        let dotWidths_Sprig: [CGFloat] = [22, 8, 8]
        var prevDot_Sprig: UIView?

        for (idx_Sprig, color_Sprig) in dotColors_Sprig.enumerated() {
            let dot_Sprig = UIView()
            dot_Sprig.backgroundColor = color_Sprig
            dot_Sprig.layer.cornerRadius = 4
            container_Sprig.addSubview(dot_Sprig)
            dot_Sprig.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.height.equalTo(8)
                make.width.equalTo(dotWidths_Sprig[idx_Sprig])
                if let prev = prevDot_Sprig {
                    make.left.equalTo(prev.snp.right).offset(4)
                } else {
                    make.left.equalToSuperview()
                }
                if idx_Sprig == dotColors_Sprig.count - 1 {
                    make.right.equalToSuperview()
                }
            }
            prevDot_Sprig = dot_Sprig
        }
        return container_Sprig
    }

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
    ///   - accentColor_Sprig: 主题强调色
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

        // 左侧色条
        let accentStrip_Sprig = UIView()
        accentStrip_Sprig.backgroundColor = accentColor_Sprig.withAlphaComponent(0.60)
        card_Sprig.addSubview(accentStrip_Sprig)
        card_Sprig.sendSubviewToBack(accentStrip_Sprig)
        accentStrip_Sprig.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        // 图标圆形泡泡
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
            self.view.frame.origin.y = -frame_Sprig.height * 0.30
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

    @objc private func onBackTapped_Sprig() {
        Navigation_Sprig.pop_Sprig()
    }

    /// 点击注册：三字段非空 + 密码一致校验 → 调用 loginById_Sprig 完成注册登录
    @objc private func onRegisterTapped_Sprig() {
        view.endEditing(true)

        let username_Sprig = userNameTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password_Sprig = passwordTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm_Sprig = confirmPasswordTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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
        guard !confirm_Sprig.isEmpty else {
            Utils_Sprig.showError_Sprig(message_Sprig: "Please confirm your password")
            shakeField_Sprig(confirmPasswordCard_Sprig)
            return
        }
        guard password_Sprig == confirm_Sprig else {
            Utils_Sprig.showError_Sprig(message_Sprig: "Passwords do not match")
            shakeField_Sprig(passwordCard_Sprig)
            shakeField_Sprig(confirmPasswordCard_Sprig)
            return
        }

        registerButton_Sprig.animatePressDown_Sprig { [weak self] in
            self?.registerButton_Sprig.animatePressUp_Sprig()
        }

        // 注册成功，通过 loginById_Sprig 完成登录
        UserViewModel_Sprig.shared_Sprig.loginById_Sprig(userId_sprig: 1)
    }

    /// 输入卡片校验失败抖动 + 边框短暂变红
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

extension Register_Sprig: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField_Sprig {
            passwordTextField_Sprig.becomeFirstResponder()
        } else if textField == passwordTextField_Sprig {
            confirmPasswordTextField_Sprig.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    /// 聚焦时输入卡片边框高亮为辅助品牌色
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let activeColor_Sprig = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.55).cgColor
        if textField == userNameTextField_Sprig {
            userNameCard_Sprig.layer.borderColor = activeColor_Sprig
        } else if textField == passwordTextField_Sprig {
            passwordCard_Sprig.layer.borderColor = activeColor_Sprig
        } else if textField == confirmPasswordTextField_Sprig {
            confirmPasswordCard_Sprig.layer.borderColor = activeColor_Sprig
        }
    }

    /// 失焦时恢复默认边框色
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userNameTextField_Sprig {
            userNameCard_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        } else if textField == passwordTextField_Sprig {
            passwordCard_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        } else if textField == confirmPasswordTextField_Sprig {
            confirmPasswordCard_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        }
    }
}
