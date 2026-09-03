import Foundation
import UIKit
import SnapKit

// MARK: - 注册页视图控制器

/// 注册页视图控制器
/// 功能：用户名 + 密码 + 确认密码注册，协议展示；字段验证完整
/// 设计：顶部渐变装饰区（品牌 + 装饰泡泡）+ 精美表单卡片 + 渐变注册按钮 + 进场动画
/// 逻辑：注册仅调用 UserViewModel 的 loginById_Maki 方法
class Register_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
    }

    // MARK: - UI 属性

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.keyboardDismissMode = .onDrag
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    /// 返回按钮
    private let backBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        btn_maki.tintColor = UIColor(hexstring_Maki: "#8B7355")
        btn_maki.backgroundColor = UIColor(hexstring_Maki: "#8B7355").withAlphaComponent(0.1)
        btn_maki.layer.cornerRadius = 16
        return btn_maki
    }()

    private let usernameTF_Maki = LoginTextField_Maki(placeholder: "Username",         icon: "person.fill")
    private let passwordTF_Maki = LoginTextField_Maki(placeholder: "Password",         icon: "lock.fill",        isSecure: true)
    private let confirmTF_Maki  = LoginTextField_Maki(placeholder: "Confirm Password", icon: "lock.shield.fill", isSecure: true)

    private let formCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 24
        v_maki.layer.shadowColor   = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        v_maki.layer.shadowOffset  = CGSize(width: 0, height: 8)
        v_maki.layer.shadowRadius  = 20
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    private let registerBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("  Create Account", for: .normal)
        btn_maki.setImage(UIImage(systemName: "sparkles"), for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.tintColor = .white
        btn_maki.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn_maki.layer.cornerRadius = 16
        btn_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.4).cgColor
        btn_maki.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_maki.layer.shadowRadius = 14
        btn_maki.layer.shadowOpacity = 1
        return btn_maki
    }()
    private let registerGrad_Maki = CAGradientLayer()

    private var protocolLabel_Maki: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildDecorBackground_Maki()
        buildUI_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40 - 32, height: 54)
    }
}

// MARK: - 背景装饰

extension Register_Maki {

    /// 构建全屏浅渐变 + 装饰气泡
    private func buildDecorBackground_Maki() {
        let bgGrad_maki = CAGradientLayer()
        bgGrad_maki.colors = [
            UIColor(hexstring_Maki: "#FFD700").withAlphaComponent(0.06).cgColor,
            UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.04).cgColor,
            UIColor(hexstring_Maki: "#FFFBF4").cgColor
        ]
        bgGrad_maki.startPoint = CGPoint(x: 0, y: 0)
        bgGrad_maki.endPoint   = CGPoint(x: 1, y: 0.7)
        bgGrad_maki.frame      = view.bounds
        view.layer.insertSublayer(bgGrad_maki, at: 0)

        // 左上角大气泡
        let bubble1_maki = UIView()
        bubble1_maki.backgroundColor = UIColor(hexstring_Maki: "#FFD700").withAlphaComponent(0.1)
        bubble1_maki.layer.cornerRadius = 90
        view.addSubview(bubble1_maki)
        bubble1_maki.snp.makeConstraints { make in
            make.width.height.equalTo(180)
            make.leading.equalToSuperview().offset(-60)
            make.top.equalToSuperview().offset(-40)
        }

        // 右下角小气泡
        let bubble2_maki = UIView()
        bubble2_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.06)
        bubble2_maki.layer.cornerRadius = 50
        view.addSubview(bubble2_maki)
        bubble2_maki.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(30)
        }

        // 右上角中气泡
        let bubble3_maki = UIView()
        bubble3_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.05)
        bubble3_maki.layer.cornerRadius = 40
        view.addSubview(bubble3_maki)
        bubble3_maki.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(60)
        }
    }
}

// MARK: - UI 构建

extension Register_Maki {

    private func buildUI_Maki() {
        // ScrollView
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }

        // 返回按钮（在 scrollView 之后添加，确保位于最上层不被遮挡）
        backBtn_Maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)
        view.addSubview(backBtn_Maki)
        backBtn_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.width.height.equalTo(32)
        }

        buildLogoArea_Maki()
        buildFormCard_Maki()
        buildProtocolArea_Maki()
    }

    /// 构建品牌 Logo 区域（带光晕圆圈、标题、副标题）
    private func buildLogoArea_Maki() {
        // 外层光晕
        let outerGlow_maki = UIView()
        outerGlow_maki.backgroundColor = UIColor(hexstring_Maki: "#FFD700").withAlphaComponent(0.12)
        outerGlow_maki.layer.cornerRadius = 44
        contentView_Maki.addSubview(outerGlow_maki)
        outerGlow_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
            make.width.height.equalTo(88)
        }

        // 内圈
        let innerCircle_maki = UIView()
        innerCircle_maki.backgroundColor = UIColor(hexstring_Maki: "#FFD700").withAlphaComponent(0.25)
        innerCircle_maki.layer.cornerRadius = 32
        contentView_Maki.addSubview(innerCircle_maki)
        innerCircle_maki.snp.makeConstraints { make in
            make.center.equalTo(outerGlow_maki)
            make.width.height.equalTo(64)
        }

        // 火花图标
        let sparkLb_maki = UILabel()
        sparkLb_maki.text = "✨"
        sparkLb_maki.font = .systemFont(ofSize: 26)
        sparkLb_maki.textAlignment = .center
        contentView_Maki.addSubview(sparkLb_maki)
        sparkLb_maki.snp.makeConstraints { make in
            make.center.equalTo(outerGlow_maki)
        }

        // 主标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Join Maki"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 30)
            ?? .systemFont(ofSize: 30, weight: .bold)
        titleLb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        titleLb_maki.textAlignment = .center
        contentView_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.top.equalTo(outerGlow_maki.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // 副标题
        let subLb_maki = UILabel()
        subLb_maki.text = "Start sharing your creations"
        subLb_maki.font = .systemFont(ofSize: 14, weight: .light)
        subLb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        subLb_maki.textAlignment = .center
        contentView_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }

    /// 构建表单卡片（三个输入框 + 注册按钮）
    private func buildFormCard_Maki() {
        contentView_Maki.addSubview(formCard_Maki)
        formCard_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(266)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 卡片内区块标题
        let formTitle_maki = UILabel()
        formTitle_maki.text = "Create your account"
        formTitle_maki.font = .systemFont(ofSize: 13, weight: .semibold)
        formTitle_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        formCard_Maki.addSubview(formTitle_maki)
        formTitle_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        // 输入字段
        formCard_Maki.addSubview(usernameTF_Maki)
        formCard_Maki.addSubview(passwordTF_Maki)
        formCard_Maki.addSubview(confirmTF_Maki)
        usernameTF_Maki.snp.makeConstraints { make in
            make.top.equalTo(formTitle_maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        passwordTF_Maki.snp.makeConstraints { make in
            make.top.equalTo(usernameTF_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        confirmTF_Maki.snp.makeConstraints { make in
            make.top.equalTo(passwordTF_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        // 注册按钮（渐变）
        registerGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#FF8C00").cgColor,
            UIColor(hexstring_Maki: "#E8650A").cgColor
        ]
        registerGrad_Maki.startPoint   = CGPoint(x: 0, y: 0.5)
        registerGrad_Maki.endPoint     = CGPoint(x: 1, y: 0.5)
        registerGrad_Maki.cornerRadius = 16
        registerBtn_Maki.layer.insertSublayer(registerGrad_Maki, at: 0)

        formCard_Maki.addSubview(registerBtn_Maki)
        registerBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(confirmTF_Maki.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-20)
        }
        registerBtn_Maki.addTarget(self, action: #selector(onRegister_Maki), for: .touchUpInside)
    }

    /// 构建底部协议文字
    private func buildProtocolArea_Maki() {
        let pLabel_maki = ProtocolHelper_Maki.createProtocolTextLabel_Maki(
            firstContent_Maki: "terms.png",
            secondContent_Maki: "privacy.png",
            config_Maki: .light_Maki(),
            from: self
        )
        protocolLabel_Maki = pLabel_maki
        contentView_Maki.addSubview(pLabel_maki)
        pLabel_maki.snp.makeConstraints { make in
            make.top.equalTo(formCard_Maki.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
}

// MARK: - 进场动画

extension Register_Maki {

    private func playEntranceAnimation_Maki() {
        formCard_Maki.alpha = 0
        formCard_Maki.transform = CGAffineTransform(translationX: 0, y: 30)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: [],
            animations: {
                self.formCard_Maki.alpha = 1
                self.formCard_Maki.transform = .identity
            }
        )
    }
}

// MARK: - 事件响应

extension Register_Maki {

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }

    /// 注册操作：验证字段 → 调用 loginById_Maki
    @objc private func onRegister_Maki() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 按压动画
        UIView.animate(withDuration: 0.1, animations: {
            self.registerBtn_Maki.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) { self.registerBtn_Maki.transform = .identity }
        })

        let username_maki = usernameTF_Maki.textValue_Maki.trimmingCharacters(in: .whitespaces)
        let password_maki = passwordTF_Maki.textValue_Maki.trimmingCharacters(in: .whitespaces)
        let confirm_maki  = confirmTF_Maki.textValue_Maki.trimmingCharacters(in: .whitespaces)

        guard !username_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Username cannot be empty"); return
        }
        guard !password_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Password cannot be empty"); return
        }
        guard password_maki == confirm_maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Passwords do not match"); return
        }
        UserViewModel_Maki.shared_Maki.loginById_Maki(userId_maki: 51589)
    }
}
