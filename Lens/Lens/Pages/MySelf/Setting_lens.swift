import UIKit
import SnapKit

// MARK: - 设置页面（重构版）

/// 设置页面视图控制器（重构版）
/// 核心作用：提供服务条款查看、账号登出和注销入口
/// 设计思路：
///   - 自定义顶部导航栏，不依赖外层被隐藏的系统导航栏
///   - 背景多层径向光晕渐变与全局视觉一致
///   - 分组标题带渐变竖条装饰（General / Account）
///   - 卡片背景 #1C1C35，行高 60pt，图标容器带彩色渐变背景
///   - 底部展示 App 版本信息
class Setting_Lens: UIViewController {

    // MARK: - 私有类型

    /// 设置项数据模型
    private struct SettingItem_lens {
        let title_lens: String
        let iconName_lens: String
        let iconColor_lens: UIColor
        let isDestructive_lens: Bool
        let action_lens: () -> Void
    }

    // MARK: - 属性

    private var settingGroups_lens: [[SettingItem_lens]] = []

    // MARK: - UI 组件：背景装饰

    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：自定义导航栏

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Settings"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：滚动内容

    private let scrollView_Lens = UIScrollView()
    private let contentView_Lens = UIView()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Lens()
        buildSettingItems_Lens()
        setupCustomNavigation_Lens()
        setupScrollContent_Lens()
        view.bringSubviewToFront(navBar_Lens)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset_Lens = view.safeAreaInsets.bottom + 16
        if scrollView_Lens.contentInset.bottom != bottomInset_Lens {
            scrollView_Lens.contentInset.bottom = bottomInset_Lens
        }
    }

    // MARK: - 初始化

    private func setupView_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(280)
        }
        setupBackgroundGlows_Lens()
    }

    /// 构建背景多层径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.25).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purple_Lens.frame = CGRect(x: -80, y: -60, width: 300, height: 300)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let sw_Lens = UIScreen.main.bounds.width
        blue_Lens.frame = CGRect(x: sw_Lens - 60, y: 40, width: 200, height: 200)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// 搭建自定义顶部导航栏（返回按钮 + 标题）
    private func setupCustomNavigation_Lens() {
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        backButton_Lens.addTarget(self, action: #selector(onBackTap_Lens), for: .touchUpInside)

        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }
    }

    private func buildSettingItems_Lens() {
        let legalGroup_lens: [SettingItem_lens] = [
            SettingItem_lens(title_lens: "Terms of Service", iconName_lens: "doc.text.fill",
                             iconColor_lens: UIColor(hexstring_Lens: "#4D96FF"), isDestructive_lens: false) {
                [weak self] in self?.showTerms_Lens()
            },
            SettingItem_lens(title_lens: "Privacy Policy", iconName_lens: "lock.shield.fill",
                             iconColor_lens: UIColor(hexstring_Lens: "#6BCB77"), isDestructive_lens: false) {
                [weak self] in self?.showPrivacy_Lens()
            }
        ]
        let accountGroup_lens: [SettingItem_lens] = [
            SettingItem_lens(title_lens: "Log Out", iconName_lens: "rectangle.portrait.and.arrow.right.fill",
                             iconColor_lens: UIColor(hexstring_Lens: "#FFB347"), isDestructive_lens: false) {
                [weak self] in self?.confirmLogout_Lens()
            },
            SettingItem_lens(title_lens: "Delete Account", iconName_lens: "trash.fill",
                             iconColor_lens: UIColor(hexstring_Lens: "#FF6B6B"), isDestructive_lens: true) {
                [weak self] in self?.confirmDeleteAccount_Lens()
            }
        ]
        settingGroups_lens = [legalGroup_lens, accountGroup_lens]
    }

    // MARK: - 布局搭建

    private func setupScrollContent_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)
        scrollView_Lens.showsVerticalScrollIndicator = false
        scrollView_Lens.contentInsetAdjustmentBehavior = .never
        scrollView_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 用内容顶部 UIView 作为布局锚点（替代已移除的用户卡片）
        let topAnchor_Lens = UIView()
        topAnchor_Lens.isHidden = true
        contentView_Lens.addSubview(topAnchor_Lens)
        topAnchor_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
        }

        var lastView_Lens: UIView = topAnchor_Lens

        let groupTitles_Lens = ["General", "Account"]
        for (groupIdx_lens, group_lens) in settingGroups_lens.enumerated() {
            // 分组标题
            let sectionHeader_Lens = buildSectionHeader_Lens(title_lens: groupTitles_Lens[groupIdx_lens])
            contentView_Lens.addSubview(sectionHeader_Lens)
            sectionHeader_Lens.snp.makeConstraints {
                $0.top.equalTo(lastView_Lens.snp.bottom).offset(20)
                $0.leading.equalToSuperview().offset(20)
            }
            lastView_Lens = sectionHeader_Lens

            // 卡片
            let groupCard_Lens = buildGroupCard_Lens(items_lens: group_lens)
            contentView_Lens.addSubview(groupCard_Lens)
            groupCard_Lens.snp.makeConstraints {
                $0.top.equalTo(lastView_Lens.snp.bottom).offset(8)
                $0.leading.trailing.equalToSuperview().inset(20)
            }
            lastView_Lens = groupCard_Lens
        }

        // 版本信息标签
        let versionLabel_Lens = UILabel()
        let version_Lens = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build_Lens = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel_Lens.text = "Lens v\(version_Lens) (\(build_Lens))"
        versionLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        versionLabel_Lens.font = .systemFont(ofSize: 12)
        versionLabel_Lens.textAlignment = .center
        contentView_Lens.addSubview(versionLabel_Lens)
        versionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(lastView_Lens.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
    }

    /// 构建顶部用户快照卡片（头像 + 昵称 + 已登录标识）
    /// - Returns: 用户快照卡片视图
    /// 构建分组标题视图（渐变竖条 + 文字）
    /// - Parameter title_lens: 分组标题文字
    /// - Returns: 分组标题视图
    private func buildSectionHeader_Lens(title_lens: String) -> UIView {
        let container_Lens = UIView()

        let accentBar_Lens = UIView()
        accentBar_Lens.layer.cornerRadius = 1.5
        let barGrad_Lens = CAGradientLayer()
        barGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor
        ]
        barGrad_Lens.startPoint = CGPoint(x: 0.5, y: 0)
        barGrad_Lens.endPoint = CGPoint(x: 0.5, y: 1)
        barGrad_Lens.cornerRadius = 1.5
        barGrad_Lens.frame = CGRect(x: 0, y: 0, width: 3, height: 14)
        accentBar_Lens.layer.addSublayer(barGrad_Lens)

        let titleLabel_Lens = UILabel()
        titleLabel_Lens.text = title_lens.uppercased()
        titleLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        titleLabel_Lens.font = .systemFont(ofSize: 11, weight: .semibold)

        container_Lens.addSubview(accentBar_Lens)
        container_Lens.addSubview(titleLabel_Lens)

        accentBar_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(accentBar_Lens.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.top.bottom.trailing.equalToSuperview()
        }

        return container_Lens
    }

    /// 构建单个分组卡片视图
    /// - Parameter items_lens: 当前分组的设置项列表
    /// - Returns: 构建完成的分组卡片视图
    private func buildGroupCard_Lens(items_lens: [SettingItem_lens]) -> UIView {
        let card_Lens = UIView()
        card_Lens.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        card_Lens.layer.cornerRadius = 18
        card_Lens.layer.borderWidth = 1
        card_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor

        var prevRow_Lens: UIView?
        for (idx_Lens, item_Lens) in items_lens.enumerated() {
            let row_Lens = buildRow_Lens(item_lens: item_Lens)
            card_Lens.addSubview(row_Lens)
            row_Lens.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                if let prev_Lens = prevRow_Lens {
                    $0.top.equalTo(prev_Lens.snp.bottom)
                } else {
                    $0.top.equalToSuperview()
                }
                if idx_Lens == items_lens.count - 1 {
                    $0.bottom.equalToSuperview()
                }
            }
            // 分隔线
            if idx_Lens < items_lens.count - 1 {
                let divider_Lens = UIView()
                divider_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
                card_Lens.addSubview(divider_Lens)
                divider_Lens.snp.makeConstraints {
                    $0.bottom.equalTo(row_Lens)
                    $0.leading.equalToSuperview().inset(64)
                    $0.trailing.equalToSuperview()
                    $0.height.equalTo(0.5)
                }
            }
            prevRow_Lens = row_Lens
        }
        return card_Lens
    }

    /// 构建单行设置项视图
    /// - Parameter item_lens: 设置项数据模型
    /// - Returns: 构建完成的行视图
    private func buildRow_Lens(item_lens: SettingItem_lens) -> UIView {
        let row_Lens = UIView()

        // 图标容器（渐变色背景）
        let iconBg_Lens = UIView()
        iconBg_Lens.backgroundColor = item_lens.iconColor_lens.withAlphaComponent(0.15)
        iconBg_Lens.layer.cornerRadius = 11
        iconBg_Lens.layer.borderWidth = 1
        iconBg_Lens.layer.borderColor = item_lens.iconColor_lens.withAlphaComponent(0.25).cgColor

        let iconView_Lens = UIImageView(image: UIImage(systemName: item_lens.iconName_lens))
        iconView_Lens.tintColor = item_lens.iconColor_lens
        iconView_Lens.contentMode = .scaleAspectFit
        iconBg_Lens.addSubview(iconView_Lens)
        iconView_Lens.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(20) }

        // 标题
        let titleLabel_Lens = UILabel()
        titleLabel_Lens.text = item_lens.title_lens
        titleLabel_Lens.textColor = item_lens.isDestructive_lens
            ? UIColor(hexstring_Lens: "#FF6B6B")
            : .white
        titleLabel_Lens.font = .systemFont(ofSize: 16, weight: item_lens.isDestructive_lens ? .semibold : .regular)

        // 箭头
        let arrowView_Lens = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowView_Lens.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        arrowView_Lens.contentMode = .scaleAspectFit

        row_Lens.addSubview(iconBg_Lens)
        row_Lens.addSubview(titleLabel_Lens)
        row_Lens.addSubview(arrowView_Lens)

        iconBg_Lens.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.width.height.equalTo(40)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconBg_Lens.snp.trailing).offset(14)
            $0.trailing.equalTo(arrowView_Lens.snp.leading).offset(-8)
        }
        arrowView_Lens.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(10)
            $0.height.equalTo(16)
        }
        row_Lens.snp.makeConstraints { $0.height.equalTo(60) }

        let tap_Lens = SettingRowTapGesture_lens(action_lens: item_lens.action_lens)
        row_Lens.isUserInteractionEnabled = true
        row_Lens.addGestureRecognizer(tap_Lens)

        let press_Lens = SettingRowPressGesture_lens(row_lens: row_Lens)
        row_Lens.addGestureRecognizer(press_Lens)

        return row_Lens
    }

    // MARK: - 业务逻辑

    private func showTerms_Lens() {
        ProtocolHelper_Lens.showProtocol_Lens(type_Lens: .terms_Lens, content_Lens: "txt", from: self)
    }

    private func showPrivacy_Lens() {
        ProtocolHelper_Lens.showProtocol_Lens(type_Lens: .privacy_Lens, content_Lens: "data", from: self)
    }

    private func confirmLogout_Lens() {
        UIAlertController.logout_Lens { [weak self] in
            guard let self else { return }
            UserViewModel_Lens.shared_Lens.logout_Lens(logoutType_lens: .logout_lens)
        }
    }

    private func confirmDeleteAccount_Lens() {
        UIAlertController.delete_Lens { [weak self] in
            guard let self else { return }
            UserViewModel_Lens.shared_Lens.logout_Lens(logoutType_lens: .delete_lens)
        }
    }

    @objc private func onBackTap_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }
}

// MARK: - 设置行点击手势

private class SettingRowTapGesture_lens: UITapGestureRecognizer {
    private let action_lens: () -> Void
    init(action_lens: @escaping () -> Void) {
        self.action_lens = action_lens
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_lens))
    }
    @objc private func handleTap_lens() { action_lens() }
}

// MARK: - 设置行按压反馈手势

private class SettingRowPressGesture_lens: UILongPressGestureRecognizer {
    private weak var row_lens: UIView?
    init(row_lens: UIView) {
        self.row_lens = row_lens
        super.init(target: nil, action: nil)
        minimumPressDuration = 0.05
        cancelsTouchesInView = false
        addTarget(self, action: #selector(handlePress_lens(_:)))
    }
    @objc private func handlePress_lens(_ g: UILongPressGestureRecognizer) {
        switch g.state {
        case .began:
            row_lens?.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.05)
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.row_lens?.backgroundColor = .clear
            }
        default: break
        }
    }
}
