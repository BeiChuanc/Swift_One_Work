import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面

/// 设置页面
/// 核心作用：展示应用级操作入口，包含协议查看（Terms / Privacy）及账号管理（登出 / 删除账号）
/// 设计思路：暖色渐变小头部 + 两组功能卡片（协议组 / 危险操作组）；
///          协议类跳转使用 ProtocolHelper_Pane，账号操作前弹出二次确认
/// 关键方法：
/// - showTerms_Pane / showPrivacy_Pane: 打开对应协议页
/// - logoutConfirm_Pane / deleteAccountConfirm_Pane: 带确认弹窗的账号操作
class Setting_Pane: UIViewController {

    // MARK: - UI · 顶部渐变头

    private let headerView_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var headerGradient_Pane: CAGradientLayer?

    /// 装饰圆
    private let decorCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 40
        v.isUserInteractionEnabled = false
        return v
    }()

    private let headerTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Settings"
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let headerSubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Manage your account & preferences"
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        return l
    }()

    // MARK: - UI · 自定义返回按钮

    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor       = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    // MARK: - UI · 协议卡片

    private let protocolCard_Pane: UIView = buildCard_Pane()

    private let termsRow_Pane = SettingRow_Pane(
        icon: "doc.text.fill",
        title: "Terms of Service",
        iconBgColor: UIColor(hexstring_Pane: "#667EEA")
    )

    private let divider1_Pane: UIView = buildDivider_Pane()

    private let privacyRow_Pane = SettingRow_Pane(
        icon: "lock.shield.fill",
        title: "Privacy Policy",
        iconBgColor: UIColor(hexstring_Pane: "#48BB78")
    )

    // MARK: - UI · 账号操作卡片

    private let accountCard_Pane: UIView = buildCard_Pane()

    private let logoutButton_Pane: UIButton = buildActionButton_Pane(
        title: "Log Out",
        color: UIColor(hexstring_Pane: "#F6AD55")
    )

    private let deleteButton_Pane: UIButton = buildActionButton_Pane(
        title: "Delete Account",
        color: UIColor(hexstring_Pane: "#FC8181")
    )

    // MARK: - 辅助工厂方法（static，避免存储属性初始化时引用未完成的 self）

    private static func buildCard_Pane() -> UIView {
        let v = UIView()
        v.backgroundColor  = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 20
        v.layer.shadowColor   = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.layer.shadowRadius  = 10
        return v
    }

    private static func buildDivider_Pane() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }

    private static func buildActionButton_Pane(title: String, color: UIColor) -> UIButton {
        let b = UIButton(type: .custom)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font  = .systemFont(ofSize: 15, weight: .semibold)
        b.setTitleColor(color, for: .normal)
        b.backgroundColor   = color.withAlphaComponent(0.08)
        b.layer.cornerRadius = 14
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return b
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Pane?.frame = headerView_Pane.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        // 头部
        view.addSubview(headerView_Pane)
        headerView_Pane.addSubview(decorCircle_Pane)
        headerView_Pane.addSubview(backButton_Pane)
        headerView_Pane.addSubview(headerTitleLabel_Pane)
        headerView_Pane.addSubview(headerSubLabel_Pane)

        // 协议卡片
        view.addSubview(protocolCard_Pane)
        protocolCard_Pane.addSubview(termsRow_Pane)
        protocolCard_Pane.addSubview(divider1_Pane)
        protocolCard_Pane.addSubview(privacyRow_Pane)

        // 账号操作卡片
        view.addSubview(accountCard_Pane)
        accountCard_Pane.addSubview(logoutButton_Pane)
        accountCard_Pane.addSubview(deleteButton_Pane)

        setupHeaderGradient_Pane()
        setupConstraints_Pane()
    }

    private func setupHeaderGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane
    }

    private func setupConstraints_Pane() {
        // 头部高度 = 安全区顶部 + 70pt（足够放返回按钮 + 两行文字）
        headerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
        }
        decorCircle_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(20)
            $0.width.height.equalTo(80)
        }
        // 返回按钮与标题共享同一行，垂直居中对齐
        backButton_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }
        // 标题与返回按钮垂直中心对齐，紧跟在按钮右侧
        headerTitleLabel_Pane.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Pane)
            $0.leading.equalTo(backButton_Pane.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        // 副标题在标题正下方
        headerSubLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(headerTitleLabel_Pane)
            $0.top.equalTo(headerTitleLabel_Pane.snp.bottom).offset(3)
        }

        // 协议卡片
        protocolCard_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        termsRow_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        divider1_Pane.snp.makeConstraints {
            $0.top.equalTo(termsRow_Pane.snp.bottom)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(0.5)
        }
        privacyRow_Pane.snp.makeConstraints {
            $0.top.equalTo(divider1_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(60)
        }

        // 账号操作卡片
        accountCard_Pane.snp.makeConstraints {
            $0.top.equalTo(protocolCard_Pane.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        logoutButton_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        deleteButton_Pane.snp.makeConstraints {
            $0.top.equalTo(logoutButton_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)

        let termsTap_pane   = UITapGestureRecognizer(target: self, action: #selector(showTerms_Pane))
        let privacyTap_pane = UITapGestureRecognizer(target: self, action: #selector(showPrivacy_Pane))
        termsRow_Pane.addGestureRecognizer(termsTap_pane)
        privacyRow_Pane.addGestureRecognizer(privacyTap_pane)

        logoutButton_Pane.addTarget(self, action: #selector(logoutConfirm_Pane), for: .touchUpInside)
        deleteButton_Pane.addTarget(self, action: #selector(deleteAccountConfirm_Pane), for: .touchUpInside)
    }

    @objc private func backTapped_Pane() {
        if let nav_pane = navigationController, nav_pane.viewControllers.count > 1 {
            nav_pane.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 展示服务条款（传入 Assets 中 terms 图片名称）
    @objc private func showTerms_Pane() {
        ProtocolHelper_Pane.showProtocol_Pane(
            type_Pane: .terms_Pane,
            content_Pane: "terms.png",
            from: self
        )
    }

    /// 展示隐私政策（传入 Assets 中 privacy 图片名称）
    @objc private func showPrivacy_Pane() {
        ProtocolHelper_Pane.showProtocol_Pane(
            type_Pane: .privacy_Pane,
            content_Pane: "privacy.png",
            from: self
        )
    }

    /// 登出确认弹窗
    @objc private func logoutConfirm_Pane() {
        let alert_pane = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_pane.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_pane.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Pane.shared_Pane.logout_Pane(logoutType_pane: .logout_pane)
            }
        })
        present(alert_pane, animated: true)
    }

    /// 删除账号确认弹窗（需二次输入确认）
    @objc private func deleteAccountConfirm_Pane() {
        let alert_pane = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account after 24 hours. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert_pane.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_pane.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Pane.shared_Pane.logout_Pane(logoutType_pane: .delete_pane)
            }
        })
        present(alert_pane, animated: true)
    }
}

// MARK: - SettingRow_Pane

/// 设置列表行组件
/// 核心作用：展示图标 + 标题 + 右箭头的行，支持自定义图标背景色
private class SettingRow_Pane: UIView {

    init(icon: String, title: String, iconBgColor: UIColor) {
        super.init(frame: .zero)
        isUserInteractionEnabled = true

        // 图标容器
        let iconContainer_pane = UIView()
        iconContainer_pane.backgroundColor  = iconBgColor
        iconContainer_pane.layer.cornerRadius = 10
        addSubview(iconContainer_pane)

        let iconImage_pane = UIImageView()
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconImage_pane.image       = UIImage(systemName: icon, withConfiguration: cfg_pane)?
            .withRenderingMode(.alwaysTemplate)
        iconImage_pane.tintColor   = .white
        iconImage_pane.contentMode = .scaleAspectFit
        iconContainer_pane.addSubview(iconImage_pane)

        // 标题
        let titleLabel_pane = UILabel()
        titleLabel_pane.text      = title
        titleLabel_pane.font      = .systemFont(ofSize: 15, weight: .medium)
        titleLabel_pane.textColor = ColorConfig_Pane.textPrimary_Pane
        addSubview(titleLabel_pane)

        // 右箭头
        let arrow_pane = UIImageView()
        let arrowCfg_pane = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        arrow_pane.image       = UIImage(systemName: "chevron.right", withConfiguration: arrowCfg_pane)?
            .withRenderingMode(.alwaysTemplate)
        arrow_pane.tintColor   = ColorConfig_Pane.textPlaceholder_Pane
        arrow_pane.contentMode = .scaleAspectFit
        addSubview(arrow_pane)

        // 约束
        iconContainer_pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(38)
        }
        iconImage_pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        titleLabel_pane.snp.makeConstraints {
            $0.leading.equalTo(iconContainer_pane.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
        }
        arrow_pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
