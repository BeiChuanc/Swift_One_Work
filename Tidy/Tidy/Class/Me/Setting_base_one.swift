import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面

/// 设置页面
/// 功能：提供服务条款、隐私政策查看，以及登出和删除账号操作
/// 设计：隐藏系统导航栏，使用自定义返回按钮；标题区锚定至 safeAreaLayoutGuide
///       避免与返回按钮重叠；卡片分区布局，危险区域用暖红色高亮
class Setting_Base_one: UIViewController {

    // MARK: - 布局常量

    private enum LayoutConst_Base_one {
        static let cardCornerRadius: CGFloat = 20
        static let rowHeight: CGFloat = 62
        static let horizontalPadding: CGFloat = 20
        static let cardShadowRadius: CGFloat = 12
        static let headerHeight: CGFloat = 220
    }

    // MARK: - 头部渐变区

    private let headerView_Base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradientLayer_Base_one = CAGradientLayer()

    /// 装饰圆 1（右上角）
    private let decorCircle1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 70
        return v
    }()

    /// 装饰圆 2（左下角）
    private let decorCircle2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 装饰圆 3（右下角，小）
    private let decorCircle3_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 28
        return v
    }()

    /// 自定义返回按钮（替代系统导航栏按钮，避免与标题文字重叠）
    private let backButton_Base_one = BackButton_Base_one()

    /// 页面标题（锚定至 safeAreaLayoutGuide，确保在导航栏下方显示）
    private let titleLabel_Base_one: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()

    /// 副标题
    private let subtitleLabel_Base_one: UILabel = {
        let label = UILabel()
        label.text = "Manage your account"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        return label
    }()

    // MARK: - 滚动容器

    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - 法律信息区

    private let legalSectionLabel_Base_one = Setting_Base_one.makeSectionLabel_Base_one(text: "Legal")
    private let legalCardView_Base_one = Setting_Base_one.makeCardView_Base_one()

    private let termsButton_Base_one = Setting_Base_one.makeRowButton_Base_one(
        icon: "doc.text.fill",
        title: "Terms of Service",
        subtitle: "Read our terms and conditions",
        iconBgColor: UIColor(hexstring_Base_one: "#B794F6")
    )

    private let legalDivider_Base_one = Setting_Base_one.makeDivider_Base_one()

    private let privacyButton_Base_one = Setting_Base_one.makeRowButton_Base_one(
        icon: "lock.shield.fill",
        title: "Privacy Policy",
        subtitle: "How we handle your data",
        iconBgColor: UIColor(hexstring_Base_one: "#90CDF4")
    )

    // MARK: - 账号操作区

    private let accountSectionLabel_Base_one = Setting_Base_one.makeSectionLabel_Base_one(text: "Account")
    private let accountCardView_Base_one = Setting_Base_one.makeCardView_Base_one()

    private let logoutButton_Base_one = Setting_Base_one.makeRowButton_Base_one(
        icon: "arrow.right.square.fill",
        title: "Log Out",
        subtitle: "Sign out of your account",
        iconBgColor: UIColor(hexstring_Base_one: "#F6AD55"),
        titleColor: ColorConfig_Base_one.textPrimary_Base_one
    )

    private let accountDivider_Base_one = Setting_Base_one.makeDivider_Base_one()

    private let deleteAccountButton_Base_one = Setting_Base_one.makeRowButton_Base_one(
        icon: "trash.fill",
        title: "Delete Account",
        subtitle: "Permanently remove your account",
        iconBgColor: UIColor(hexstring_Base_one: "#FC8181"),
        titleColor: UIColor(hexstring_Base_one: "#E53E3E")
    )

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        bindActions_Base_one()
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
        headerGradientLayer_Base_one.frame = headerView_Base_one.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        setupHeaderView_Base_one()
        setupScrollContent_Base_one()
        animateEntrance_Base_one()
    }

    // MARK: 头部

    private func setupHeaderView_Base_one() {
        // 渐变层
        headerGradientLayer_Base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        headerGradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        headerView_Base_one.layer.insertSublayer(headerGradientLayer_Base_one, at: 0)

        view.addSubview(headerView_Base_one)
        headerView_Base_one.addSubview(decorCircle1_Base_one)
        headerView_Base_one.addSubview(decorCircle2_Base_one)
        headerView_Base_one.addSubview(decorCircle3_Base_one)
        headerView_Base_one.addSubview(backButton_Base_one)
        headerView_Base_one.addSubview(titleLabel_Base_one)
        headerView_Base_one.addSubview(subtitleLabel_Base_one)

        headerView_Base_one.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(LayoutConst_Base_one.headerHeight)
        }

        // 装饰圆位置
        decorCircle1_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(20)
        }
        decorCircle2_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.bottom.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(-25)
        }
        decorCircle3_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(-40)
        }

        // 返回按钮 — 锚定至 safeAreaLayoutGuide 顶部，避免与状态栏重叠
        backButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        // 标题 — 锚定至 safeAreaLayoutGuide，确保在导航栏下方显示（修复与返回按钮重叠问题）
        titleLabel_Base_one.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
        }
        subtitleLabel_Base_one.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Base_one)
            make.top.equalTo(titleLabel_Base_one.snp.bottom).offset(6)
        }
    }

    // MARK: 滚动内容

    private func setupScrollContent_Base_one() {
        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentView_Base_one)

        scrollView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(headerView_Base_one.snp.bottom).offset(-24)
            make.left.right.bottom.equalToSuperview()
        }
        contentView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }

        // 法律信息区
        contentView_Base_one.addSubview(legalSectionLabel_Base_one)
        contentView_Base_one.addSubview(legalCardView_Base_one)
        legalCardView_Base_one.addSubview(termsButton_Base_one)
        legalCardView_Base_one.addSubview(legalDivider_Base_one)
        legalCardView_Base_one.addSubview(privacyButton_Base_one)

        // 账号操作区
        contentView_Base_one.addSubview(accountSectionLabel_Base_one)
        contentView_Base_one.addSubview(accountCardView_Base_one)
        accountCardView_Base_one.addSubview(logoutButton_Base_one)
        accountCardView_Base_one.addSubview(accountDivider_Base_one)
        accountCardView_Base_one.addSubview(deleteAccountButton_Base_one)

        layoutScrollContent_Base_one()
    }

    /// 布局滚动内容约束
    private func layoutScrollContent_Base_one() {
        let pad = LayoutConst_Base_one.horizontalPadding

        // 法律信息 — 直接从滚动区顶部开始
        legalSectionLabel_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(pad + 4)
        }
        legalCardView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(legalSectionLabel_Base_one.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
        }
        termsButton_Base_one.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(LayoutConst_Base_one.rowHeight)
        }
        legalDivider_Base_one.snp.makeConstraints { make in
            make.top.equalTo(termsButton_Base_one.snp.bottom)
            make.left.equalToSuperview().offset(66)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        privacyButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(legalDivider_Base_one.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(LayoutConst_Base_one.rowHeight)
        }

        // 账号操作
        accountSectionLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(legalCardView_Base_one.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(pad + 4)
        }
        accountCardView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(accountSectionLabel_Base_one.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.bottom.equalToSuperview().offset(-40)
        }
        logoutButton_Base_one.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(LayoutConst_Base_one.rowHeight)
        }
        accountDivider_Base_one.snp.makeConstraints { make in
            make.top.equalTo(logoutButton_Base_one.snp.bottom)
            make.left.equalToSuperview().offset(66)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        deleteAccountButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(accountDivider_Base_one.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(LayoutConst_Base_one.rowHeight)
        }
    }

    // MARK: - 入场动画

    private func animateEntrance_Base_one() {
        let elements: [(UIView, Double)] = [
            (legalCardView_Base_one, 0.05),
            (accountCardView_Base_one, 0.14)
        ]
        elements.forEach { view_Base_one, delay_Base_one in
            view_Base_one.alpha = 0
            view_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 28, delay_Base_one: delay_Base_one)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Base_one() {
        backButton_Base_one.onTapped_Base_one = { [weak self] in
            Navigation_Base_one.pop_Base_one()
        }

        termsButton_Base_one.addTarget(self, action: #selector(termsTapped_Base_one), for: .touchUpInside)
        privacyButton_Base_one.addTarget(self, action: #selector(privacyTapped_Base_one), for: .touchUpInside)
        logoutButton_Base_one.addTarget(self, action: #selector(logoutTapped_Base_one), for: .touchUpInside)
        deleteAccountButton_Base_one.addTarget(self, action: #selector(deleteAccountTapped_Base_one), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func termsTapped_Base_one() {
        termsButton_Base_one.animatePressDown_Base_one { self.termsButton_Base_one.animatePressUp_Base_one() }
        ProtocolHelper_Base_one.showProtocol_Base_one(
            type_Base_one: .terms_Base_one,
            content_Base_one: "terms.png",
            from: self
        )
    }

    @objc private func privacyTapped_Base_one() {
        privacyButton_Base_one.animatePressDown_Base_one { self.privacyButton_Base_one.animatePressUp_Base_one() }
        ProtocolHelper_Base_one.showProtocol_Base_one(
            type_Base_one: .privacy_Base_one,
            content_Base_one: "privacy.png",
            from: self
        )
    }

    @objc private func logoutTapped_Base_one() {
        logoutButton_Base_one.animatePressDown_Base_one { self.logoutButton_Base_one.animatePressUp_Base_one() }
        showLogoutConfirm_Base_one()
    }

    @objc private func deleteAccountTapped_Base_one() {
        deleteAccountButton_Base_one.animatePressDown_Base_one { self.deleteAccountButton_Base_one.animatePressUp_Base_one() }
        showDeleteConfirm_Base_one()
    }

    // MARK: - 弹窗确认

    private func showLogoutConfirm_Base_one() {
        let alert_Base_one = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_Base_one.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Base_one.shared_Base_one.logout_Base_one(logoutType_base_one: .logout_base_one)
            }
        })
        alert_Base_one.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Base_one, animated: true)
    }

    private func showDeleteConfirm_Base_one() {
        let alert_Base_one = UIAlertController(
            title: "Delete Account",
            message: "This action is irreversible. Your account will be permanently deleted after 24 hours.",
            preferredStyle: .alert
        )
        alert_Base_one.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Base_one.shared_Base_one.logout_Base_one(logoutType_base_one: .delete_base_one)
            }
        })
        alert_Base_one.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Base_one, animated: true)
    }

    // MARK: - 工厂方法

    private static func makeSectionLabel_Base_one(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = ColorConfig_Base_one.textSecondary_Base_one
        // 设置字母间距
        let attributed = NSMutableAttributedString(string: text.uppercased())
        attributed.addAttribute(.kern, value: CGFloat(1.4), range: NSRange(location: 0, length: text.count))
        label.attributedText = attributed
        return label
    }

    private static func makeCardView_Base_one() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.cardBackground_Base_one
        v.layer.cornerRadius = LayoutConst_Base_one.cardCornerRadius
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.07
        v.layer.shadowRadius = LayoutConst_Base_one.cardShadowRadius
        return v
    }

    /// 创建设置行按钮（带副标题描述文字）
    /// - Parameters:
    ///   - icon: SF Symbol 名称
    ///   - title: 主标题
    ///   - subtitle: 副标题描述（可选）
    ///   - iconBgColor: 图标背景色
    ///   - titleColor: 标题颜色
    private static func makeRowButton_Base_one(
        icon: String,
        title: String,
        subtitle: String = "",
        iconBgColor: UIColor,
        titleColor: UIColor = ColorConfig_Base_one.textPrimary_Base_one
    ) -> UIButton {
        let button_Base_one = UIButton(type: .system)
        button_Base_one.backgroundColor = .clear

        // 图标容器（方形圆角）
        let iconContainer_Base_one = UIView()
        iconContainer_Base_one.backgroundColor = iconBgColor
        iconContainer_Base_one.layer.cornerRadius = 12
        iconContainer_Base_one.isUserInteractionEnabled = false

        let iconImageView_Base_one = UIImageView()
        iconImageView_Base_one.image = UIImage(systemName: icon)
        iconImageView_Base_one.tintColor = .white
        iconImageView_Base_one.contentMode = .scaleAspectFit
        iconImageView_Base_one.isUserInteractionEnabled = false

        // 主标题
        let titleLabel_Base_one = UILabel()
        titleLabel_Base_one.text = title
        titleLabel_Base_one.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel_Base_one.textColor = titleColor
        titleLabel_Base_one.isUserInteractionEnabled = false

        // 副标题
        let subtitleLabel_Base_one = UILabel()
        subtitleLabel_Base_one.text = subtitle
        subtitleLabel_Base_one.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel_Base_one.textColor = ColorConfig_Base_one.textSecondary_Base_one
        subtitleLabel_Base_one.isUserInteractionEnabled = false

        // 右侧箭头
        let chevron_Base_one = UIImageView()
        chevron_Base_one.image = UIImage(systemName: "chevron.right")
        chevron_Base_one.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        chevron_Base_one.contentMode = .scaleAspectFit
        chevron_Base_one.isUserInteractionEnabled = false

        button_Base_one.addSubview(iconContainer_Base_one)
        iconContainer_Base_one.addSubview(iconImageView_Base_one)
        button_Base_one.addSubview(titleLabel_Base_one)
        button_Base_one.addSubview(subtitleLabel_Base_one)
        button_Base_one.addSubview(chevron_Base_one)

        iconContainer_Base_one.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(38)
        }
        iconImageView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.left.equalTo(iconContainer_Base_one.snp.right).offset(14)
            make.bottom.equalTo(iconContainer_Base_one.snp.centerY).offset(-1)
        }
        subtitleLabel_Base_one.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Base_one)
            make.top.equalTo(iconContainer_Base_one.snp.centerY).offset(3)
        }
        chevron_Base_one.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(9)
            make.height.equalTo(15)
        }

        return button_Base_one
    }

    private static func makeDivider_Base_one() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }
}
