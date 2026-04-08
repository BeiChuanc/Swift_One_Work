import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 核心作用：提供 Terms、Privacy、登出及删除账号入口
/// 设计思路：三色渐变全屏背景 + 浮动装饰球 + 分组卡片（General / Account）
///          SettingRow 采用渐变图标背景，各组有独立标题，底部展示版本号
class Setting_Somnia: UIViewController {

    // MARK: - UI组件 — 背景

    private var _gradientLayer_Somnia: CAGradientLayer?

    // MARK: - UI组件 — 头部

    /// 返回按钮
    private let backButton_Somnia = BackButton_Somnia()

    /// 主标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Settings"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .white
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOpacity = 0.14
        lbl.layer.shadowRadius = 6
        return lbl
    }()

    /// 副标题
    private let subtitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Manage your account & preferences"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.72)
        return lbl
    }()

    // MARK: - UI组件 — General 分组

    /// General 分组标题
    private let generalHeaderLabel_Somnia = Setting_Somnia.makeSectionLabel_Somnia("General")

    /// General 卡片容器
    private let generalCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 18
        v.layer.shadowOpacity = 0.14
        return v
    }()

    /// Terms of Service 行
    private let termsRow_Somnia = SettingRow_Somnia(
        icon_Somnia: "doc.text.fill",
        title_Somnia: "Terms of Service",
        iconColors_Somnia: [UIColor(hexstring_Somnia: "#C4B5FD"), UIColor(hexstring_Somnia: "#B794F6")],
        showDivider_Somnia: true
    )

    /// Privacy Policy 行
    private let privacyRow_Somnia = SettingRow_Somnia(
        icon_Somnia: "hand.raised.fill",
        title_Somnia: "Privacy Policy",
        iconColors_Somnia: [UIColor(hexstring_Somnia: "#B794F6"), UIColor(hexstring_Somnia: "#90CDF4")],
        showDivider_Somnia: false
    )

    // MARK: - UI组件 — Account 分组

    /// Account 分组标题
    private let accountHeaderLabel_Somnia = Setting_Somnia.makeSectionLabel_Somnia("Account")

    /// Account 卡片容器
    private let accountCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 0.07
        return v
    }()

    /// Sign Out 行
    private let logoutRow_Somnia = SettingRow_Somnia(
        icon_Somnia: "rectangle.portrait.and.arrow.right",
        title_Somnia: "Sign Out",
        iconColors_Somnia: [UIColor(hexstring_Somnia: "#FCD34D"), UIColor(hexstring_Somnia: "#F59E0B")],
        showDivider_Somnia: true
    )

    /// Delete Account 行
    private let deleteRow_Somnia = SettingRow_Somnia(
        icon_Somnia: "trash.fill",
        title_Somnia: "Delete Account",
        iconColors_Somnia: [UIColor(hexstring_Somnia: "#FC8181"), UIColor(hexstring_Somnia: "#E53E3E")],
        showDivider_Somnia: false,
        isDestructive_Somnia: true
    )

    // MARK: - UI组件 — 底部版本信息

    private let versionLabel_Somnia: UILabel = {
        let lbl = UILabel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        lbl.text = "Version \(version)"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.42)
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 工厂方法

    /// 创建分组标题标签（全大写 + 字间距）
    private static func makeSectionLabel_Somnia(_ text: String) -> UILabel {
        let lbl = UILabel()
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.65),
            .kern: 1.4
        ]
        lbl.attributedText = NSAttributedString(string: text.uppercased(), attributes: attrs)
        return lbl
    }

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _gradientLayer_Somnia?.frame = view.bounds
    }

    // MARK: - 私有方法 — UI设置

    private func setupUI_Somnia() {
        // 三色渐变背景
        let gradient_Somnia = CAGradientLayer()
        gradient_Somnia.colors = [
            UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        gradient_Somnia.locations = [0.0, 0.45, 1.0]
        gradient_Somnia.startPoint = CGPoint(x: 0.1, y: 0)
        gradient_Somnia.endPoint   = CGPoint(x: 0.9, y: 1)
        gradient_Somnia.frame = view.bounds
        view.layer.insertSublayer(gradient_Somnia, at: 0)
        _gradientLayer_Somnia = gradient_Somnia

        addDecorOrbs_Somnia()

        view.addSubview(backButton_Somnia)
        view.addSubview(titleLabel_Somnia)
        view.addSubview(subtitleLabel_Somnia)

        view.addSubview(generalHeaderLabel_Somnia)
        view.addSubview(generalCard_Somnia)
        generalCard_Somnia.addSubview(termsRow_Somnia)
        generalCard_Somnia.addSubview(privacyRow_Somnia)

        view.addSubview(accountHeaderLabel_Somnia)
        view.addSubview(accountCard_Somnia)
        accountCard_Somnia.addSubview(logoutRow_Somnia)
        accountCard_Somnia.addSubview(deleteRow_Somnia)

        view.addSubview(versionLabel_Somnia)

        setupConstraints_Somnia()
    }

    /// 布局所有约束
    private func setupConstraints_Somnia() {
        backButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }

        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(backButton_Somnia.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(24)
        }

        subtitleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(24)
        }

        // General 分组
        generalHeaderLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Somnia.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(26)
        }

        generalCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(generalHeaderLabel_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        termsRow_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(68)
        }

        privacyRow_Somnia.snp.makeConstraints { make in
            make.top.equalTo(termsRow_Somnia.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(68)
            make.bottom.equalToSuperview()
        }

        // Account 分组
        accountHeaderLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(generalCard_Somnia.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(26)
        }

        accountCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(accountHeaderLabel_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        logoutRow_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(68)
        }

        deleteRow_Somnia.snp.makeConstraints { make in
            make.top.equalTo(logoutRow_Somnia.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(68)
            make.bottom.equalToSuperview()
        }

        // 版本号
        versionLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(accountCard_Somnia.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
    }

    /// 添加浮动装饰半透明球
    private func addDecorOrbs_Somnia() {
        let w = view.bounds.width
        let configs: [(x: CGFloat, y: CGFloat, r: CGFloat, a: CGFloat)] = [
            (w - 28, 80,  60, 0.10),
            (18,     220, 48, 0.08),
            (w * 0.6, 20, 32, 0.12)
        ]
        for c in configs {
            let orb = UIView(frame: CGRect(x: c.x - c.r, y: c.y - c.r,
                                          width: c.r * 2, height: c.r * 2))
            orb.backgroundColor = UIColor.white.withAlphaComponent(c.a)
            orb.layer.cornerRadius = c.r
            view.insertSubview(orb, at: 1)
        }
    }

    // MARK: - 私有方法 — 事件绑定

    private func setupActions_Somnia() {
        backButton_Somnia.onTapped_Somnia = { [weak self] in
            Navigation_Somnia.pop_Somnia()
        }

        termsRow_Somnia.onTapped_Somnia = { [weak self] in
            guard let self = self else { return }
            ProtocolHelper_Somnia.showProtocol_Somnia(
                type_Somnia: .terms_Somnia,
                content_Somnia: "terms.png",
                from: self
            )
        }

        privacyRow_Somnia.onTapped_Somnia = { [weak self] in
            guard let self = self else { return }
            ProtocolHelper_Somnia.showProtocol_Somnia(
                type_Somnia: .privacy_Somnia,
                content_Somnia: "privacy.png",
                from: self
            )
        }

        logoutRow_Somnia.onTapped_Somnia = { [weak self] in
            self?.showLogoutAlert_Somnia(isDelete_Somnia: false)
        }

        deleteRow_Somnia.onTapped_Somnia = { [weak self] in
            self?.showLogoutAlert_Somnia(isDelete_Somnia: true)
        }
    }

    /// 显示登出/删除账号确认弹框
    /// - Parameter isDelete_Somnia: true 表示删除账号，false 表示普通登出
    private func showLogoutAlert_Somnia(isDelete_Somnia: Bool) {
        let title_Somnia   = isDelete_Somnia ? "Delete Account" : "Sign Out"
        let msg_Somnia     = isDelete_Somnia
            ? "Your account will be scheduled for deletion. This action takes 24 hours to complete."
            : "Are you sure you want to sign out?"
        let confirmTitle_Somnia = isDelete_Somnia ? "Delete" : "Sign Out"

        let alert_Somnia = UIAlertController(title: title_Somnia,
                                             message: msg_Somnia,
                                             preferredStyle: .alert)
        let confirmAction_Somnia = UIAlertAction(title: confirmTitle_Somnia,
                                                 style: .destructive) { [weak self] _ in
            let type_Somnia: LogOutType_Somnia = isDelete_Somnia ? .delete_somnia : .logout_somnia
            Task { @MainActor in
                UserViewModel_Somnia.shared_Somnia.logout_Somnia(logoutType_somnia: type_Somnia)
            }
        }
        let cancelAction_Somnia = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Somnia.addAction(confirmAction_Somnia)
        alert_Somnia.addAction(cancelAction_Somnia)
        present(alert_Somnia, animated: true)
    }
}

// MARK: - 设置行可复用组件

/// 单行设置项视图
/// 功能：展示渐变图标背景、标题及右箭头，支持点击弹簧动画回调
/// 设计：图标 44pt 渐变圆角背景，标题 16pt semibold，右侧细箭头
private class SettingRow_Somnia: UIView {

    // MARK: - UI组件

    /// 图标容器（渐变背景）
    private let iconContainer_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 13
        v.clipsToBounds = true
        return v
    }()

    private var iconGradient_Somnia: CAGradientLayer?

    /// 图标
    private let iconView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    /// 标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return lbl
    }()

    /// 右侧箭头
    private let arrowView_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(hexstring_Somnia: "#CBD5E0")
        return iv
    }()

    /// 分割线
    private let divider_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.06)
        return v
    }()

    // MARK: - 属性

    var onTapped_Somnia: (() -> Void)?

    // MARK: - 初始化

    /// 初始化设置行
    /// - Parameters:
    ///   - icon_Somnia: SF Symbols 图标名
    ///   - title_Somnia: 行标题
    ///   - iconColors_Somnia: 图标背景渐变颜色数组（从左上到右下）
    ///   - showDivider_Somnia: 是否显示底部分割线
    ///   - isDestructive_Somnia: 是否为危险操作（红色文字）
    init(icon_Somnia: String,
         title_Somnia: String,
         iconColors_Somnia: [UIColor],
         showDivider_Somnia: Bool,
         isDestructive_Somnia: Bool = false) {
        super.init(frame: .zero)

        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView_Somnia.image = UIImage(systemName: icon_Somnia, withConfiguration: cfg)
        titleLabel_Somnia.text = title_Somnia
        titleLabel_Somnia.textColor = isDestructive_Somnia
            ? UIColor(hexstring_Somnia: "#E53E3E")
            : ColorConfig_Somnia.textPrimary_Somnia
        divider_Somnia.isHidden = !showDivider_Somnia

        setupLayout_Somnia()

        // 图标渐变在布局后异步设置
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let grad = CAGradientLayer()
            grad.colors = iconColors_Somnia.map { $0.cgColor }
            grad.startPoint = CGPoint(x: 0, y: 0)
            grad.endPoint   = CGPoint(x: 1, y: 1)
            grad.frame = self.iconContainer_Somnia.bounds
            self.iconContainer_Somnia.layer.insertSublayer(grad, at: 0)
            self.iconGradient_Somnia = grad
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconGradient_Somnia?.frame = iconContainer_Somnia.bounds
    }

    // MARK: - 私有方法

    private func setupLayout_Somnia() {
        addSubview(iconContainer_Somnia)
        iconContainer_Somnia.addSubview(iconView_Somnia)
        addSubview(titleLabel_Somnia)
        addSubview(arrowView_Somnia)
        addSubview(divider_Somnia)

        iconContainer_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        iconView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(iconContainer_Somnia.snp.right).offset(14)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(arrowView_Somnia.snp.left).offset(-8)
        }

        arrowView_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(16)
        }

        divider_Somnia.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Somnia)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    /// 点击时弹簧缩放 + 高亮反馈
    @objc private func handleTap_Somnia() {
        UIView.animate(withDuration: 0.08) {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        } completion: { _ in
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.65,
                           initialSpringVelocity: 0.5) {
                self.transform = .identity
                self.backgroundColor = .clear
            }
            self.onTapped_Somnia?()
        }
    }
}
