import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面控制器
/// 核心作用：展示协议、登出和删除账号入口。
/// 设计思路：分为 Legal 分组、Account 分组两大区块，
///          协议展示复用 `ProtocolHelper_Posture`，账号操作统一交给 `UserViewModel_Posture`。
/// 关键属性：页面由各分组卡片组成，无额外业务状态。
/// 关键方法：`handleLogout_Posture(type_Posture:)` 统一处理登出与删除账号确认。
@MainActor
class Setting_Posture: UIViewController {

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
    }

    // MARK: - UI 搭建

    /// 搭建设置页完整 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        setupBackgroundGlows_Posture()

        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = false
        view.addSubview(scrollView_Posture)
        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        scrollView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        let navBar_Posture = buildNavBar_Posture()
        let legalGroup_Posture = buildSettingGroup_Posture(
            header: "Legal",
            headerIcon: "checkmark.seal.fill",
            headerColor: ColorConfig_Posture.accentTeal_Posture,
            items: [
                makeSettingRow_Posture(
                    icon: "doc.text.fill", iconBg: ColorConfig_Posture.accentIndigoLight_Posture,
                    iconColor: ColorConfig_Posture.accentIndigo_Posture,
                    title: "Terms of Service", subtitle: "Read our terms and conditions", chevron: true
                ) { [weak self] in
                    guard let self_Posture = self else { return }
                    ProtocolHelper_Posture.showProtocol_Posture(type_Posture: .terms_Posture, content_Posture: "terms.png", from: self_Posture)
                },
                makeSettingRow_Posture(
                    icon: "lock.shield.fill", iconBg: ColorConfig_Posture.accentTealLight_Posture,
                    iconColor: ColorConfig_Posture.accentTeal_Posture,
                    title: "Privacy Policy", subtitle: "How we protect your data", chevron: true
                ) { [weak self] in
                    guard let self_Posture = self else { return }
                    ProtocolHelper_Posture.showProtocol_Posture(type_Posture: .privacy_Posture, content_Posture: "privacy.png", from: self_Posture)
                },
            ]
        )
        let accountGroup_Posture = buildSettingGroup_Posture(
            header: "Account",
            headerIcon: "person.crop.circle.badge.fill",
            headerColor: ColorConfig_Posture.accentAmber_Posture,
            items: [
                makeSettingRow_Posture(
                    icon: "rectangle.portrait.and.arrow.right.fill", iconBg: ColorConfig_Posture.accentAmberLight_Posture,
                    iconColor: ColorConfig_Posture.accentAmber_Posture,
                    title: "Logout", subtitle: "Sign out of your account", chevron: false
                ) { [weak self] in
                    self?.handleLogout_Posture(type_Posture: .logout_posture)
                },
                makeSettingRow_Posture(
                    icon: "trash.fill", iconBg: ColorConfig_Posture.accentCoralLight_Posture,
                    iconColor: ColorConfig_Posture.accentCoral_Posture,
                    title: "Delete Account", subtitle: "Permanently remove your account", chevron: false, isDanger: true
                ) { [weak self] in
                    self?.handleLogout_Posture(type_Posture: .delete_posture)
                },
            ]
        )

        contentView_Posture.addSubview(navBar_Posture)
        contentView_Posture.addSubview(legalGroup_Posture)
        contentView_Posture.addSubview(accountGroup_Posture)

        navBar_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        legalGroup_Posture.snp.makeConstraints { make in
            make.top.equalTo(navBar_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        accountGroup_Posture.snp.makeConstraints { make in
            make.top.equalTo(legalGroup_Posture.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    // MARK: - 区块构建

    /// 搭建背景光晕
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupBackgroundGlows_Posture() {
        [
            (ColorConfig_Posture.accentAmber_Posture.withAlphaComponent(0.13),  CGFloat(160), true,   30.0, 30.0),
            (ColorConfig_Posture.accentTeal_Posture.withAlphaComponent(0.12),   CGFloat(140), false, -44.0, 300.0),
            (ColorConfig_Posture.accentCoral_Posture.withAlphaComponent(0.10),  CGFloat(120), true,   50.0, 550.0),
        ].forEach { cfg_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = cfg_Posture.0
            blob_Posture.layer.cornerRadius = cfg_Posture.1 / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 0)
            blob_Posture.snp.makeConstraints { make in
                if cfg_Posture.2 { make.trailing.equalToSuperview().offset(cfg_Posture.3)
                } else { make.leading.equalToSuperview().offset(cfg_Posture.3) }
                make.top.equalToSuperview().offset(cfg_Posture.4)
                make.width.height.equalTo(cfg_Posture.1)
            }
        }
    }

    /// 构建顶部导航栏
    /// - Parameters: 无
    /// - Returns: UIView - 导航栏
    /// - Throws: 无
    private func buildNavBar_Posture() -> UIView {
        let container_Posture = UIView()
        let backButton_Posture = UIButton(type: .system)
        backButton_Posture.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton_Posture.tintColor = ColorConfig_Posture.textPrimary_Posture
        backButton_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        backButton_Posture.layer.cornerRadius = 22
        backButton_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        backButton_Posture.layer.shadowOpacity = 1
        backButton_Posture.layer.shadowRadius  = 8
        backButton_Posture.layer.shadowOffset  = CGSize(width: 0, height: 4)
        backButton_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Settings"
        titleLabel_Posture.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let gearIcon_Posture = UIImageView(image: UIImage(systemName: "gearshape.2.fill"))
        gearIcon_Posture.tintColor = ColorConfig_Posture.accentAmber_Posture
        gearIcon_Posture.contentMode = .scaleAspectFit

        container_Posture.addSubview(backButton_Posture)
        container_Posture.addSubview(titleLabel_Posture)
        container_Posture.addSubview(gearIcon_Posture)

        backButton_Posture.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Posture)
            make.leading.equalTo(backButton_Posture.snp.trailing).offset(14)
        }
        gearIcon_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Posture)
            make.trailing.equalToSuperview().inset(22)
            make.width.height.equalTo(28)
        }
        return container_Posture
    }

    /// 构建设置分组卡片
    /// - Parameters:
    ///   - header: 分组标题
    ///   - headerIcon: 分组图标
    ///   - headerColor: 分组颜色
    ///   - items: 行视图数组
    /// - Returns: UIView - 分组卡片
    /// - Throws: 无
    private func buildSettingGroup_Posture(header: String, headerIcon: String, headerColor: UIColor, items: [UIView]) -> UIView {
        let container_Posture = UIView()

        // 标题行
        let headerStack_Posture = UIStackView()
        headerStack_Posture.axis = .horizontal
        headerStack_Posture.spacing = 8
        headerStack_Posture.alignment = .center

        let hIconView_Posture = UIImageView(image: UIImage(systemName: headerIcon))
        hIconView_Posture.tintColor = headerColor
        hIconView_Posture.contentMode = .scaleAspectFit
        hIconView_Posture.snp.makeConstraints { make in make.width.height.equalTo(18) }

        let hLabel_Posture = UILabel()
        hLabel_Posture.text = header.uppercased()
        hLabel_Posture.font = .systemFont(ofSize: 12, weight: .heavy)
        hLabel_Posture.textColor = headerColor

        headerStack_Posture.addArrangedSubview(hIconView_Posture)
        headerStack_Posture.addArrangedSubview(hLabel_Posture)

        // 内容卡片
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 26
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 14
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 8)

        let itemStack_Posture = UIStackView()
        itemStack_Posture.axis = .vertical
        itemStack_Posture.spacing = 0
        items.enumerated().forEach { idx_Posture, item_Posture in
            itemStack_Posture.addArrangedSubview(item_Posture)
            if idx_Posture < items.count - 1 {
                let divider_Posture = UIView()
                divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture
                itemStack_Posture.addArrangedSubview(divider_Posture)
                divider_Posture.snp.makeConstraints { make in
                    make.height.equalTo(1)
                    make.leading.equalToSuperview().offset(68)
                    make.trailing.equalToSuperview()
                }
            }
        }

        card_Posture.addSubview(itemStack_Posture)
        itemStack_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        container_Posture.addSubview(headerStack_Posture)
        container_Posture.addSubview(card_Posture)

        headerStack_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        card_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerStack_Posture.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return container_Posture
    }

    /// 创建设置行视图
    /// - Parameters:
    ///   - icon: 图标名
    ///   - iconBg: 图标背景色
    ///   - iconColor: 图标颜色
    ///   - title: 主标题
    ///   - subtitle: 副标题
    ///   - chevron: 是否显示右箭头
    ///   - isDanger: 是否为危险操作（红色高亮）
    ///   - onTap_Posture: 点击回调，在创建时直接绑定，避免事后注入时视图未布局导致的手势失效
    /// - Returns: UIView - 设置行视图（带点击高亮与回调）
    /// - Throws: 无
    private func makeSettingRow_Posture(icon: String, iconBg: UIColor, iconColor: UIColor, title: String, subtitle: String, chevron: Bool, isDanger: Bool = false, onTap_Posture: @escaping () -> Void) -> UIView {
        let row_Posture = UIControl()
        row_Posture.addAction(UIAction { _ in onTap_Posture() }, for: .touchUpInside)
        row_Posture.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.1) { row_Posture.alpha = 0.55 }
        }, for: .touchDown)
        row_Posture.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.15) { row_Posture.alpha = 1.0 }
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel])

        let iconBgView_Posture = UIView()
        iconBgView_Posture.backgroundColor = iconBg
        iconBgView_Posture.layer.cornerRadius = 20

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = isDanger ? UIColor.systemRed : iconColor
        iconView_Posture.contentMode = .scaleAspectFit
        iconBgView_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title
        titleLabel_Posture.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel_Posture.textColor = isDanger ? UIColor.systemRed : ColorConfig_Posture.textPrimary_Posture

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = subtitle
        subtitleLabel_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        row_Posture.addSubview(iconBgView_Posture)
        row_Posture.addSubview(titleLabel_Posture)
        row_Posture.addSubview(subtitleLabel_Posture)

        iconBgView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(iconBgView_Posture.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(chevron ? 40 : 18)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel_Posture)
            make.bottom.equalToSuperview().offset(-18)
        }

        if chevron {
            let chevronView_Posture = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevronView_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
            chevronView_Posture.contentMode = .scaleAspectFit
            row_Posture.addSubview(chevronView_Posture)
            chevronView_Posture.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(18)
                make.centerY.equalToSuperview()
                make.width.equalTo(8)
                make.height.equalTo(14)
            }
        }

        row_Posture.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(76)
        }

        return row_Posture
    }

    // MARK: - 事件处理

    /// 处理账号登出或删除确认弹窗
    /// - Parameter type_Posture: 操作类型
    /// - Returns: Void
    /// - Throws: 无
    private func handleLogout_Posture(type_Posture: LogOutType_Posture) {
        let title_Posture   = type_Posture == .delete_posture ? "Delete Account" : "Logout"
        let message_Posture = type_Posture == .delete_posture ? "Are you sure you want to delete this account?" : "Are you sure you want to logout?"
        let alert_Posture   = UIAlertController(title: title_Posture, message: message_Posture, preferredStyle: .alert)
        alert_Posture.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Posture.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
            UserViewModel_Posture.shared_Posture.logout_Posture(logoutType_posture: type_Posture)
        })
        present(alert_Posture, animated: true)
    }
}
