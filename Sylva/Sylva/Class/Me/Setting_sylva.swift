import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面（Premium 重构版）

/// 设置视图控制器
/// 核心作用：提供协议查看、登出、删除账号操作入口
/// 设计思路：渐变紧凑头部 + 卡片式分组 + 危险区特殊样式 + 版本信息尾部
class Setting_Sylva: UIViewController {

    // MARK: - 私有属性

    private let scrollView_Sylva   = UIScrollView()
    private let contentView_Sylva  = UIView()
    private let headerGradient_Sylva = CAGradientLayer()
    private let headerGradMask_Sylva = CAShapeLayer()
    private let headerView_Sylva   = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupHeader_Sylva()
        setupScrollContent_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds_sylva = headerView_Sylva.bounds
        headerGradient_Sylva.frame = bounds_sylva
        let path_sylva = UIBezierPath(
            roundedRect: bounds_sylva,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 24, height: 24)
        )
        headerGradMask_Sylva.path = path_sylva.cgPath
    }

    // MARK: - UI 搭建

    /// 搭建渐变头部（含返回键 + 标题 + 装饰）
    private func setupHeader_Sylva() {
        headerGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#2D6A4F").cgColor
        ]
        headerGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Sylva.endPoint   = CGPoint(x: 1, y: 1)
        headerGradient_Sylva.mask       = headerGradMask_Sylva
        headerView_Sylva.layer.insertSublayer(headerGradient_Sylva, at: 0)
        // headerView 仅作渐变背景，高度固定覆盖所有机型安全区
        view.addSubview(headerView_Sylva)
        headerView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }

        // 装饰圆（视觉装饰，不可交互）
        let deco_sylva = UIView()
        deco_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        deco_sylva.layer.cornerRadius = 50
        headerView_Sylva.addSubview(deco_sylva)
        deco_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(-10)
            make.width.height.equalTo(100)
        }

        // 返回按钮、标题、齿轮图标全部直接加到 view，用 safeAreaLayoutGuide 定位
        // 确保始终在安全区内可点击，不受 headerView 层级影响
        let backBtn_sylva = UIButton(type: .system)
        let backCfg_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn_sylva.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_sylva), for: .normal)
        backBtn_sylva.tintColor = .white
        backBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backBtn_sylva.layer.cornerRadius = 18
        backBtn_sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        view.addSubview(backBtn_sylva)
        backBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Settings"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel_sylva.textColor = .white
        view.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_sylva)
            make.centerX.equalToSuperview()
        }

        let gearIcon_sylva = UIImageView(image: UIImage(systemName: "gearshape.2.fill"))
        gearIcon_sylva.tintColor = UIColor.white.withAlphaComponent(0.35)
        gearIcon_sylva.contentMode = .scaleAspectFit
        view.addSubview(gearIcon_sylva)
        gearIcon_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(backBtn_sylva)
            make.width.height.equalTo(22)
        }
    }

    /// 搭建滚动内容区
    private func setupScrollContent_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)
        scrollView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(headerView_Sylva.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        // Legal 分组
        let legalCard_sylva = buildGroupCard_Sylva(
            sectionIcon: "shield.lefthalf.filled",
            sectionTitle: "Legal",
            items: [
                ("doc.text.fill",    "Terms of Service", UIColor(hexstring_Sylva: "#40916C"), false),
                ("hand.raised.fill", "Privacy Policy",   UIColor(hexstring_Sylva: "#40916C"), false),
            ]
        )
        contentView_Sylva.addSubview(legalCard_sylva)
        legalCard_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // Account 分组
        let accountCard_sylva = buildGroupCard_Sylva(
            sectionIcon: "person.crop.circle",
            sectionTitle: "Account",
            items: [
                ("arrow.right.circle.fill", "Sign Out",       UIColor(hexstring_Sylva: "#F59E0B"), false),
            ]
        )
        contentView_Sylva.addSubview(accountCard_sylva)
        accountCard_sylva.snp.makeConstraints { make in
            make.top.equalTo(legalCard_sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // Danger Zone 分组（特殊红色样式）
        let dangerCard_sylva = buildDangerCard_Sylva()
        contentView_Sylva.addSubview(dangerCard_sylva)
        dangerCard_sylva.snp.makeConstraints { make in
            make.top.equalTo(accountCard_sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 版本信息尾部
        let versionLabel_sylva = UILabel()
        versionLabel_sylva.text = "Sylva · Version 1.0.0"
        versionLabel_sylva.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        versionLabel_sylva.textAlignment = .center
        contentView_Sylva.addSubview(versionLabel_sylva)
        versionLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(dangerCard_sylva.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 卡片构建

    /// 构建标准分组卡片
    private func buildGroupCard_Sylva(
        sectionIcon: String,
        sectionTitle: String,
        items: [(String, String, UIColor, Bool)]
    ) -> UIView {
        let card_sylva = UIView()
        card_sylva.backgroundColor = .white
        card_sylva.layer.cornerRadius = 18
        card_sylva.layer.shadowColor  = UIColor.black.cgColor
        card_sylva.layer.shadowOpacity = 0.05
        card_sylva.layer.shadowRadius  = 10
        card_sylva.layer.shadowOffset  = CGSize(width: 0, height: 3)

        // 分组标题行
        let headerRow_sylva = buildSectionHeader_Sylva(icon: sectionIcon, title: sectionTitle)
        card_sylva.addSubview(headerRow_sylva)
        headerRow_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(22)
        }

        var prevView: UIView = headerRow_sylva
        for (idx_sylva, item_sylva) in items.enumerated() {
            let row_sylva = buildSettingRow_Sylva(
                icon: item_sylva.0, text: item_sylva.1,
                color: item_sylva.2, isDanger: item_sylva.3,
                tag: tagForText_Sylva(item_sylva.1)
            )
            card_sylva.addSubview(row_sylva)
            row_sylva.snp.makeConstraints { make in
                make.top.equalTo(prevView.snp.bottom).offset(4)
                make.leading.equalToSuperview().offset(8)
                make.trailing.equalToSuperview().offset(-8)
                make.height.equalTo(54)
                if idx_sylva == items.count - 1 {
                    make.bottom.equalToSuperview().offset(-8)
                }
            }
            if idx_sylva < items.count - 1 {
                let div_sylva = UIView()
                div_sylva.backgroundColor = ColorConfig_Sylva.divider_Sylva
                card_sylva.addSubview(div_sylva)
                div_sylva.snp.makeConstraints { make in
                    make.bottom.equalTo(row_sylva)
                    make.leading.equalToSuperview().offset(54)
                    make.trailing.equalToSuperview().offset(-16)
                    make.height.equalTo(0.5)
                }
            }
            prevView = row_sylva
        }
        return card_sylva
    }

    /// 构建危险区卡片（红色渐变背景提示）
    private func buildDangerCard_Sylva() -> UIView {
        let card_sylva = UIView()
        card_sylva.backgroundColor = UIColor(hexstring_Sylva: "#FFF5F5")
        card_sylva.layer.cornerRadius = 18
        card_sylva.layer.borderWidth  = 1
        card_sylva.layer.borderColor  = UIColor.systemRed.withAlphaComponent(0.15).cgColor
        card_sylva.layer.shadowColor  = UIColor.systemRed.cgColor
        card_sylva.layer.shadowOpacity = 0.04
        card_sylva.layer.shadowRadius  = 8

        // 标题行
        let headerRow_sylva = buildSectionHeader_Sylva(icon: "exclamationmark.triangle.fill", title: "Danger Zone", tint: UIColor.systemRed)
        card_sylva.addSubview(headerRow_sylva)
        headerRow_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(22)
        }

        let row_sylva = buildSettingRow_Sylva(
            icon: "trash.fill", text: "Delete Account",
            color: UIColor.systemRed, isDanger: true,
            tag: tagForText_Sylva("Delete Account")
        )
        card_sylva.addSubview(row_sylva)
        row_sylva.snp.makeConstraints { make in
            make.top.equalTo(headerRow_sylva.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-8)
        }
        return card_sylva
    }

    /// 构建分组标题行
    private func buildSectionHeader_Sylva(icon: String, title: String, tint: UIColor = UIColor(hexstring_Sylva: "#40916C")) -> UIView {
        let container_sylva = UIView()
        let cfg_sylva = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let iconView_sylva = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg_sylva))
        iconView_sylva.tintColor = tint
        iconView_sylva.contentMode = .scaleAspectFit
        let label_sylva = UILabel()
        label_sylva.text = title
        label_sylva.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label_sylva.textColor = tint

        container_sylva.addSubview(iconView_sylva)
        container_sylva.addSubview(label_sylva)
        iconView_sylva.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        label_sylva.snp.makeConstraints { make in
            make.leading.equalTo(iconView_sylva.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        return container_sylva
    }

    /// 构建单行设置项
    private func buildSettingRow_Sylva(icon: String, text: String, color: UIColor, isDanger: Bool, tag: Int) -> UIView {
        let row_sylva = UIView()
        row_sylva.layer.cornerRadius = 12
        row_sylva.isUserInteractionEnabled = true
        row_sylva.tag = tag

        let iconBg_sylva = UIView()
        iconBg_sylva.backgroundColor = color.withAlphaComponent(0.12)
        iconBg_sylva.layer.cornerRadius = 11
        row_sylva.addSubview(iconBg_sylva)

        let iconView_sylva = UIImageView(image: UIImage(systemName: icon))
        iconView_sylva.tintColor = color
        iconView_sylva.contentMode = .scaleAspectFit
        iconBg_sylva.addSubview(iconView_sylva)

        let textLabel_sylva = UILabel()
        textLabel_sylva.text = text
        textLabel_sylva.font = UIFont.systemFont(ofSize: 15, weight: isDanger ? .semibold : .regular)
        textLabel_sylva.textColor = isDanger ? UIColor.systemRed : ColorConfig_Sylva.textPrimary_Sylva
        row_sylva.addSubview(textLabel_sylva)

        let arrowView_sylva = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowView_sylva.tintColor = ColorConfig_Sylva.textPlaceholder_Sylva
        arrowView_sylva.contentMode = .scaleAspectFit
        row_sylva.addSubview(arrowView_sylva)

        // 统一约束
        iconBg_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
        iconView_sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        textLabel_sylva.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_sylva.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        arrowView_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(rowTapped_Sylva(_:)))
        row_sylva.addGestureRecognizer(tap_sylva)
        return row_sylva
    }

    // MARK: - 辅助

    private func tagForText_Sylva(_ text: String) -> Int {
        switch text {
        case "Terms of Service": return 1
        case "Privacy Policy":   return 2
        case "Sign Out":         return 3
        case "Delete Account":   return 4
        default:                 return 0
        }
    }

    // MARK: - 事件

    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func rowTapped_Sylva(_ gesture: UITapGestureRecognizer) {
        guard let row_sylva = gesture.view else { return }
        row_sylva.animatePressDown_Sylva { row_sylva.animatePressUp_Sylva() }
        switch row_sylva.tag {
        case 1:
            ProtocolHelper_Sylva.showProtocol_Sylva(type_Sylva: .terms_Sylva,   content_Sylva: "tt",   from: self)
        case 2:
            ProtocolHelper_Sylva.showProtocol_Sylva(type_Sylva: .privacy_Sylva, content_Sylva: "data", from: self)
        case 3:
            UIAlertController.logout_Sylva { UserViewModel_Sylva.shared_Sylva.logout_Sylva(logoutType_sylva: .logout_sylva) }
        case 4:
            UIAlertController.delete_Sylva { UserViewModel_Sylva.shared_Sylva.logout_Sylva(logoutType_sylva: .delete_sylva) }
        default: break
        }
    }
}
