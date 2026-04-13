import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面

/// 设置页面
/// 功能：提供服务条款、隐私政策查看，以及登出和删除账号操作
/// 设计：隐藏系统导航栏，使用自定义返回按钮；标题区锚定至 safeAreaLayoutGuide
///       避免与返回按钮重叠；卡片分区布局，危险区域用暖红色高亮
class Setting_Tidy: UIViewController {

    // MARK: - 布局常量

    private enum LayoutConst_Tidy {
        static let cardCornerRadius: CGFloat = 20
        static let rowHeight: CGFloat = 62
        static let horizontalPadding: CGFloat = 20
        static let cardShadowRadius: CGFloat = 12
        static let headerHeight: CGFloat = 220
    }

    // MARK: - 头部渐变区

    private let headerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradientLayer_Tidy = CAGradientLayer()

    /// 装饰圆 1（右上角）
    private let decorCircle1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 70
        return v
    }()

    /// 装饰圆 2（左下角）
    private let decorCircle2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 装饰圆 3（右下角，小）
    private let decorCircle3_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 28
        return v
    }()

    /// 自定义返回按钮（替代系统导航栏按钮，避免与标题文字重叠）
    private let backButton_Tidy = BackButton_Tidy()

    /// 页面标题（锚定至 safeAreaLayoutGuide，确保在导航栏下方显示）
    private let titleLabel_Tidy: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()

    /// 副标题
    private let subtitleLabel_Tidy: UILabel = {
        let label = UILabel()
        label.text = "Manage your account"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        return label
    }()

    // MARK: - 滚动容器

    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - 法律信息区

    private let legalSectionLabel_Tidy = Setting_Tidy.makeSectionLabel_Tidy(text: "Legal")
    private let legalCardView_Tidy = Setting_Tidy.makeCardView_Tidy()

    private let termsButton_Tidy = Setting_Tidy.makeRowButton_Tidy(
        icon: "doc.text.fill",
        title: "Terms of Service",
        subtitle: "Read our terms and conditions",
        iconBgColor: ColorConfig_Tidy.primaryGradientStart_Tidy
    )

    private let legalDivider_Tidy = Setting_Tidy.makeDivider_Tidy()

    private let privacyButton_Tidy = Setting_Tidy.makeRowButton_Tidy(
        icon: "lock.shield.fill",
        title: "Privacy Policy",
        subtitle: "How we handle your data",
        iconBgColor: ColorConfig_Tidy.primaryGradientEnd_Tidy
    )

    // MARK: - 账号操作区

    private let accountSectionLabel_Tidy = Setting_Tidy.makeSectionLabel_Tidy(text: "Account")
    private let accountCardView_Tidy = Setting_Tidy.makeCardView_Tidy()

    private let logoutButton_Tidy = Setting_Tidy.makeRowButton_Tidy(
        icon: "arrow.right.square.fill",
        title: "Log Out",
        subtitle: "Sign out of your account",
        iconBgColor: ColorConfig_Tidy.tidyGold_Tidy,
        titleColor: ColorConfig_Tidy.textPrimary_Tidy
    )

    private let accountDivider_Tidy = Setting_Tidy.makeDivider_Tidy()

    private let deleteAccountButton_Tidy = Setting_Tidy.makeRowButton_Tidy(
        icon: "trash.fill",
        title: "Delete Account",
        subtitle: "Permanently remove your account",
        iconBgColor: ColorConfig_Tidy.tidyWarm_Tidy,
        titleColor: UIColor(hexstring_Tidy: "#E53E3E")
    )

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        bindActions_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏系统导航栏，使用自定义返回按钮完全掌控头部样式
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 允许右滑返回手势
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 恢复导航栏（其他页面可能需要）
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Tidy.frame = headerView_Tidy.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupHeaderView_Tidy()
        setupScrollContent_Tidy()
        animateEntrance_Tidy()
    }

    // MARK: 头部

    private func setupHeaderView_Tidy() {
        // 渐变层
        headerGradientLayer_Tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        headerGradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        headerView_Tidy.layer.insertSublayer(headerGradientLayer_Tidy, at: 0)

        view.addSubview(headerView_Tidy)
        headerView_Tidy.addSubview(decorCircle1_Tidy)
        headerView_Tidy.addSubview(decorCircle2_Tidy)
        headerView_Tidy.addSubview(decorCircle3_Tidy)
        headerView_Tidy.addSubview(backButton_Tidy)
        headerView_Tidy.addSubview(titleLabel_Tidy)
        headerView_Tidy.addSubview(subtitleLabel_Tidy)

        headerView_Tidy.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(LayoutConst_Tidy.headerHeight)
        }

        // 装饰圆位置
        decorCircle1_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(20)
        }
        decorCircle2_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.bottom.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(-25)
        }
        decorCircle3_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(-40)
        }

        // 返回按钮 — 锚定至 safeAreaLayoutGuide 顶部，避免与状态栏重叠
        backButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        // 标题 — 锚定至 safeAreaLayoutGuide，确保在导航栏下方显示（修复与返回按钮重叠问题）
        titleLabel_Tidy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Tidy)
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(6)
        }
    }

    // MARK: 滚动内容

    private func setupScrollContent_Tidy() {
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentView_Tidy)

        scrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerView_Tidy.snp.bottom).offset(-24)
            make.left.right.bottom.equalToSuperview()
        }
        contentView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }

        // 法律信息区
        contentView_Tidy.addSubview(legalSectionLabel_Tidy)
        contentView_Tidy.addSubview(legalCardView_Tidy)
        legalCardView_Tidy.addSubview(termsButton_Tidy)
        legalCardView_Tidy.addSubview(legalDivider_Tidy)
        legalCardView_Tidy.addSubview(privacyButton_Tidy)

        // 账号操作区
        contentView_Tidy.addSubview(accountSectionLabel_Tidy)
        contentView_Tidy.addSubview(accountCardView_Tidy)
        accountCardView_Tidy.addSubview(logoutButton_Tidy)
        accountCardView_Tidy.addSubview(accountDivider_Tidy)
        accountCardView_Tidy.addSubview(deleteAccountButton_Tidy)

        layoutScrollContent_Tidy()
    }

    /// 布局滚动内容约束
    private func layoutScrollContent_Tidy() {
        let pad = LayoutConst_Tidy.horizontalPadding

        // 法律信息 — 直接从滚动区顶部开始
        legalSectionLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(pad + 4)
        }
        legalCardView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(legalSectionLabel_Tidy.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
        }
        termsButton_Tidy.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(LayoutConst_Tidy.rowHeight)
        }
        legalDivider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(termsButton_Tidy.snp.bottom)
            make.left.equalToSuperview().offset(66)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        privacyButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(legalDivider_Tidy.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(LayoutConst_Tidy.rowHeight)
        }

        // 账号操作
        accountSectionLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(legalCardView_Tidy.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(pad + 4)
        }
        accountCardView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(accountSectionLabel_Tidy.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.bottom.equalToSuperview().offset(-40)
        }
        logoutButton_Tidy.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(LayoutConst_Tidy.rowHeight)
        }
        accountDivider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(logoutButton_Tidy.snp.bottom)
            make.left.equalToSuperview().offset(66)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        deleteAccountButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(accountDivider_Tidy.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(LayoutConst_Tidy.rowHeight)
        }
    }

    // MARK: - 入场动画

    private func animateEntrance_Tidy() {
        let elements: [(UIView, Double)] = [
            (legalCardView_Tidy, 0.05),
            (accountCardView_Tidy, 0.14)
        ]
        elements.forEach { view_Tidy, delay_Tidy in
            view_Tidy.alpha = 0
            view_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 28, delay_Tidy: delay_Tidy)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Tidy() {
        backButton_Tidy.onTapped_Tidy = { [weak self] in
            Navigation_Tidy.pop_Tidy()
        }

        termsButton_Tidy.addTarget(self, action: #selector(termsTapped_Tidy), for: .touchUpInside)
        privacyButton_Tidy.addTarget(self, action: #selector(privacyTapped_Tidy), for: .touchUpInside)
        logoutButton_Tidy.addTarget(self, action: #selector(logoutTapped_Tidy), for: .touchUpInside)
        deleteAccountButton_Tidy.addTarget(self, action: #selector(deleteAccountTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func termsTapped_Tidy() {
        termsButton_Tidy.animatePressDown_Tidy { self.termsButton_Tidy.animatePressUp_Tidy() }
        ProtocolHelper_Tidy.showProtocol_Tidy(
            type_Tidy: .terms_Tidy,
            content_Tidy: "terms.png",
            from: self
        )
    }

    @objc private func privacyTapped_Tidy() {
        privacyButton_Tidy.animatePressDown_Tidy { self.privacyButton_Tidy.animatePressUp_Tidy() }
        ProtocolHelper_Tidy.showProtocol_Tidy(
            type_Tidy: .privacy_Tidy,
            content_Tidy: "privacy.png",
            from: self
        )
    }

    @objc private func logoutTapped_Tidy() {
        logoutButton_Tidy.animatePressDown_Tidy { self.logoutButton_Tidy.animatePressUp_Tidy() }
        showLogoutConfirm_Tidy()
    }

    @objc private func deleteAccountTapped_Tidy() {
        deleteAccountButton_Tidy.animatePressDown_Tidy { self.deleteAccountButton_Tidy.animatePressUp_Tidy() }
        showDeleteConfirm_Tidy()
    }

    // MARK: - 弹窗确认

    private func showLogoutConfirm_Tidy() {
        let alert_Tidy = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_Tidy.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Tidy.shared_Tidy.logout_Tidy(logoutType_tidy: .logout_tidy)
            }
        })
        alert_Tidy.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Tidy, animated: true)
    }

    private func showDeleteConfirm_Tidy() {
        let alert_Tidy = UIAlertController(
            title: "Delete Account",
            message: "This action is irreversible. Your account will be permanently deleted after 24 hours.",
            preferredStyle: .alert
        )
        alert_Tidy.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Tidy.shared_Tidy.logout_Tidy(logoutType_tidy: .delete_tidy)
            }
        })
        alert_Tidy.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Tidy, animated: true)
    }

    // MARK: - 工厂方法

    private static func makeSectionLabel_Tidy(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = ColorConfig_Tidy.textSecondary_Tidy
        // 设置字母间距
        let attributed = NSMutableAttributedString(string: text.uppercased())
        attributed.addAttribute(.kern, value: CGFloat(1.4), range: NSRange(location: 0, length: text.count))
        label.attributedText = attributed
        return label
    }

    private static func makeCardView_Tidy() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.cardBackground_Tidy
        v.layer.cornerRadius = LayoutConst_Tidy.cardCornerRadius
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.07
        v.layer.shadowRadius = LayoutConst_Tidy.cardShadowRadius
        return v
    }

    /// 创建设置行按钮（带副标题描述文字）
    /// - Parameters:
    ///   - icon: SF Symbol 名称
    ///   - title: 主标题
    ///   - subtitle: 副标题描述（可选）
    ///   - iconBgColor: 图标背景色
    ///   - titleColor: 标题颜色
    private static func makeRowButton_Tidy(
        icon: String,
        title: String,
        subtitle: String = "",
        iconBgColor: UIColor,
        titleColor: UIColor = ColorConfig_Tidy.textPrimary_Tidy
    ) -> UIButton {
        let button_Tidy = UIButton(type: .system)
        button_Tidy.backgroundColor = .clear

        // 图标容器（方形圆角）
        let iconContainer_Tidy = UIView()
        iconContainer_Tidy.backgroundColor = iconBgColor
        iconContainer_Tidy.layer.cornerRadius = 12
        iconContainer_Tidy.isUserInteractionEnabled = false

        let iconImageView_Tidy = UIImageView()
        iconImageView_Tidy.image = UIImage(systemName: icon)
        iconImageView_Tidy.tintColor = .white
        iconImageView_Tidy.contentMode = .scaleAspectFit
        iconImageView_Tidy.isUserInteractionEnabled = false

        // 主标题
        let titleLabel_Tidy = UILabel()
        titleLabel_Tidy.text = title
        titleLabel_Tidy.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel_Tidy.textColor = titleColor
        titleLabel_Tidy.isUserInteractionEnabled = false

        // 副标题
        let subtitleLabel_Tidy = UILabel()
        subtitleLabel_Tidy.text = subtitle
        subtitleLabel_Tidy.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel_Tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        subtitleLabel_Tidy.isUserInteractionEnabled = false

        // 右侧箭头
        let chevron_Tidy = UIImageView()
        chevron_Tidy.image = UIImage(systemName: "chevron.right")
        chevron_Tidy.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        chevron_Tidy.contentMode = .scaleAspectFit
        chevron_Tidy.isUserInteractionEnabled = false

        button_Tidy.addSubview(iconContainer_Tidy)
        iconContainer_Tidy.addSubview(iconImageView_Tidy)
        button_Tidy.addSubview(titleLabel_Tidy)
        button_Tidy.addSubview(subtitleLabel_Tidy)
        button_Tidy.addSubview(chevron_Tidy)

        iconContainer_Tidy.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(38)
        }
        iconImageView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.left.equalTo(iconContainer_Tidy.snp.right).offset(14)
            make.bottom.equalTo(iconContainer_Tidy.snp.centerY).offset(-1)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Tidy)
            make.top.equalTo(iconContainer_Tidy.snp.centerY).offset(3)
        }
        chevron_Tidy.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(9)
            make.height.equalTo(15)
        }

        return button_Tidy
    }

    private static func makeDivider_Tidy() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }
}
