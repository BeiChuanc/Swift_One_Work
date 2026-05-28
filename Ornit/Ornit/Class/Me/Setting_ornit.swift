import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 功能：展示当前用户信息摘要、Terms / Privacy / Log Out / Delete Account 四个设置项
/// 设计：深紫渐变 Header + 用户资料摘要卡 + 分组设置列表卡片
class Setting_Ornit: UIViewController {

    // MARK: - 设置项数据结构

    /// 设置项模型
    private struct SettingItem_Ornit {
        let icon_Ornit: String
        let title_Ornit: String
        let tintColor_Ornit: UIColor
        let isDestructive_Ornit: Bool
    }

    /// 法律条款分组
    private let legalItems_Ornit: [SettingItem_Ornit] = [
        SettingItem_Ornit(
            icon_Ornit: "doc.text.fill",
            title_Ornit: "Terms of Service",
            tintColor_Ornit: ColorConfig_Ornit.meAccent_Ornit,
            isDestructive_Ornit: false
        ),
        SettingItem_Ornit(
            icon_Ornit: "lock.shield.fill",
            title_Ornit: "Privacy Policy",
            tintColor_Ornit: ColorConfig_Ornit.meGradientEnd_Ornit,
            isDestructive_Ornit: false
        )
    ]

    /// 账号操作分组
    private let accountItems_Ornit: [SettingItem_Ornit] = [
        SettingItem_Ornit(
            icon_Ornit: "arrow.right.square.fill",
            title_Ornit: "Log Out",
            tintColor_Ornit: ColorConfig_Ornit.publishGradientEnd_Ornit,
            isDestructive_Ornit: false
        ),
        SettingItem_Ornit(
            icon_Ornit: "trash.fill",
            title_Ornit: "Delete Account",
            tintColor_Ornit: UIColor(hexstring_Ornit: "#EF4444"),
            isDestructive_Ornit: true
        )
    ]

    // MARK: - UI 组件

    /// 顶部渐变 Header 容器
    private let headerView_Ornit = UIView()

    /// Header 渐变图层
    private var headerGradient_Ornit: CAGradientLayer?

    /// 页面主标题
    private let titleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Settings"
        label_ornit.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label_ornit.textColor = .white
        return label_ornit
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        setupHeaderView_Ornit()
        setupSettingsCards_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
    }

    // MARK: - UI 搭建

    /// 构建顶部渐变 Header（深紫渐变 + 返回按钮 + 标题 + 齿轮装饰）
    private func setupHeaderView_Ornit() {
        view.addSubview(headerView_Ornit)

        // 深紫 → 鲜亮紫渐变
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit

        headerView_Ornit.layer.cornerRadius = 24
        headerView_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Ornit.clipsToBounds = true

        // 装饰圆
        let deco_ornit = UIView()
        deco_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        deco_ornit.layer.cornerRadius = 64
        headerView_Ornit.addSubview(deco_ornit)

        // 返回按钮
        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in
            Navigation_Ornit.pop_Ornit(from: self)
        }
        headerView_Ornit.addSubview(backView_ornit)
        headerView_Ornit.addSubview(titleLabel_Ornit)

        // 装饰齿轮图标
        let gearConfig_ornit = UIImage.SymbolConfiguration(pointSize: 34, weight: .thin)
        let gearIcon_ornit = UIImageView(
            image: UIImage(systemName: "gearshape.2.fill", withConfiguration: gearConfig_ornit)
        )
        gearIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.16)
        headerView_Ornit.addSubview(gearIcon_ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(120)
        }

        deco_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(40)
            make_ornit.top.equalToSuperview().offset(-24)
            make_ornit.width.height.equalTo(128)
        }

        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(38)
        }

        titleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(backView_ornit.snp.trailing).offset(12)
            make_ornit.centerY.equalTo(backView_ornit)
        }

        gearIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.centerY.equalTo(backView_ornit)
            make_ornit.width.height.equalTo(42)
        }
    }

    /// 构建分组设置列表（法律条款组 → 账号操作组，动态锚点链接）
    private func setupSettingsCards_Ornit() {
        // 法律条款分组紧跟 Header
        let legalBottom_ornit = buildSettingsGroup_Ornit(
            title_Ornit: "Legal",
            items_Ornit: legalItems_Ornit,
            topAnchor_Ornit: headerView_Ornit.snp.bottom,
            topOffset_Ornit: 20,
            startIndex_Ornit: 0
        )

        // 账号操作分组锚定在法律分组卡片底部
        buildSettingsGroup_Ornit(
            title_Ornit: "Account",
            items_Ornit: accountItems_Ornit,
            topAnchor_Ornit: legalBottom_ornit,
            topOffset_Ornit: 16,
            startIndex_Ornit: 2
        )
    }

    /// 构建单个分组设置卡片，返回列表卡片底部锚点供下一分组引用
    /// - Parameters:
    ///   - title_Ornit: 分组标题文字
    ///   - items_Ornit: 该分组的设置项数组
    ///   - topAnchor_Ornit: 顶部参考锚点（可以是 Header 底部或上一分组卡片底部）
    ///   - topOffset_Ornit: 距参考锚点的偏移量
    ///   - startIndex_Ornit: 该分组第一项在全局 items 中的起始 tag 编号
    /// - Returns: 当前分组列表卡片的底部约束锚点
    @discardableResult
    private func buildSettingsGroup_Ornit(
        title_Ornit: String,
        items_Ornit: [SettingItem_Ornit],
        topAnchor_Ornit: ConstraintItem,
        topOffset_Ornit: CGFloat,
        startIndex_Ornit: Int
    ) -> ConstraintItem {
        // 分组标题
        let groupLabel_ornit = UILabel()
        groupLabel_ornit.text = title_Ornit.uppercased()
        groupLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        groupLabel_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        groupLabel_ornit.letterSpacing_Ornit(spacing_Ornit: 1.2)
        view.addSubview(groupLabel_ornit)

        let listCard_ornit = UIView()
        listCard_ornit.backgroundColor = .white
        listCard_ornit.layer.cornerRadius = 18
        listCard_ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.08).cgColor
        listCard_ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        listCard_ornit.layer.shadowOpacity = 1
        listCard_ornit.layer.shadowRadius = 10
        view.addSubview(listCard_ornit)

        groupLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(topAnchor_Ornit).offset(topOffset_Ornit)
            make_ornit.leading.equalToSuperview().offset(28)
        }

        listCard_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(groupLabel_ornit.snp.bottom).offset(8)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
        }

        var previousAnchor_ornit: ConstraintItem = listCard_ornit.snp.top

        for (i_ornit, item_ornit) in items_Ornit.enumerated() {
            let row_ornit = createSettingRow_Ornit(
                item_ornit: item_ornit,
                globalIndex_Ornit: startIndex_Ornit + i_ornit
            )
            listCard_ornit.addSubview(row_ornit)

            row_ornit.snp.makeConstraints { make_ornit in
                make_ornit.top.equalTo(previousAnchor_ornit).offset(i_ornit == 0 ? 6 : 0)
                make_ornit.leading.trailing.equalToSuperview()
                make_ornit.height.equalTo(62)
            }

            if i_ornit < items_Ornit.count - 1 {
                let divider_ornit = UIView()
                divider_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
                listCard_ornit.addSubview(divider_ornit)
                divider_ornit.snp.makeConstraints { make_ornit in
                    make_ornit.top.equalTo(row_ornit.snp.bottom)
                    make_ornit.leading.equalToSuperview().offset(62)
                    make_ornit.trailing.equalToSuperview().offset(-16)
                    make_ornit.height.equalTo(0.5)
                }
                previousAnchor_ornit = divider_ornit.snp.bottom
            } else {
                row_ornit.snp.makeConstraints { make_ornit in
                    make_ornit.bottom.equalToSuperview().offset(-6)
                }
            }
        }

        return listCard_ornit.snp.bottom
    }

    /// 创建单行设置项（图标圆形背景 + 标题 + 箭头）
    /// - Parameters:
    ///   - item_ornit: 设置项数据
    ///   - globalIndex_Ornit: 全局索引（用于 tag 标记点击处理）
    /// - Returns: 完整的设置行 UIView
    private func createSettingRow_Ornit(item_ornit: SettingItem_Ornit, globalIndex_Ornit: Int) -> UIView {
        let row_ornit = UIView()
        row_ornit.isUserInteractionEnabled = true
        row_ornit.tag = globalIndex_Ornit

        // 图标圆形背景
        let iconBg_ornit = UIView()
        iconBg_ornit.backgroundColor = item_ornit.tintColor_Ornit.withValues(alpha: 0.1)
        iconBg_ornit.layer.cornerRadius = 13
        row_ornit.addSubview(iconBg_ornit)

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: item_ornit.icon_Ornit, withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = item_ornit.tintColor_Ornit
        iconView_ornit.contentMode = .scaleAspectFit
        iconBg_ornit.addSubview(iconView_ornit)

        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = item_ornit.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 15, weight: item_ornit.isDestructive_Ornit ? .semibold : .medium)
        titleLabel_ornit.textColor = item_ornit.isDestructive_Ornit
            ? UIColor(hexstring_Ornit: "#EF4444")
            : ColorConfig_Ornit.textPrimary_Ornit
        row_ornit.addSubview(titleLabel_ornit)

        let arrowConfig_ornit = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let arrowView_ornit = UIImageView(
            image: UIImage(systemName: "chevron.right", withConfiguration: arrowConfig_ornit)
        )
        arrowView_ornit.tintColor = ColorConfig_Ornit.textPlaceholder_Ornit
        row_ornit.addSubview(arrowView_ornit)

        iconBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(42)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.height.equalTo(18)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(14)
            make_ornit.centerY.equalToSuperview()
        }

        arrowView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.equalTo(8)
            make_ornit.height.equalTo(13)
        }

        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(settingRowTapped_Ornit(_:)))
        row_ornit.addGestureRecognizer(tap_ornit)

        return row_ornit
    }

    // MARK: - 事件处理

    /// 设置行点击，执行对应操作
    @objc private func settingRowTapped_Ornit(_ gesture: UITapGestureRecognizer) {
        guard let view_ornit = gesture.view else { return }

        UIView.animate(withDuration: 0.1, animations: {
            view_ornit.alpha = 0.55
        }) { _ in
            UIView.animate(withDuration: 0.12) { view_ornit.alpha = 1 }
        }

        switch view_ornit.tag {
        case 0:
            ProtocolHelper_Ornit.showProtocol_Ornit(type_Ornit: .terms_Ornit, content_Ornit: "terms", from: self)
        case 1:
            ProtocolHelper_Ornit.showProtocol_Ornit(type_Ornit: .privacy_Ornit, content_Ornit: "privacy", from: self)
        case 2:
            showLogoutConfirm_Ornit()
        case 3:
            showDeleteAccountConfirm_Ornit()
        default:
            break
        }
    }

    /// 展示退出登录确认弹窗
    private func showLogoutConfirm_Ornit() {
        let alert_ornit = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_ornit.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            UserViewModel_Ornit.shared_Ornit.logout_Ornit(logoutType_ornit: .logout_ornit)
        })
        alert_ornit.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_ornit, animated: true)
    }

    /// 展示删除账号确认弹窗
    private func showDeleteAccountConfirm_Ornit() {
        let alert_ornit = UIAlertController(
            title: "Delete Account",
            message: "Your account will be permanently deleted after 24 hours. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert_ornit.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            UserViewModel_Ornit.shared_Ornit.logout_Ornit(logoutType_ornit: .delete_ornit)
        })
        alert_ornit.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_ornit, animated: true)
    }
}

// MARK: - UILabel 字间距扩展

private extension UILabel {
    /// 设置字间距
    /// - Parameter spacing_Ornit: 字间距值
    func letterSpacing_Ornit(spacing_Ornit: CGFloat) {
        guard let text_ornit = text else { return }
        let attrStr_ornit = NSMutableAttributedString(string: text_ornit)
        attrStr_ornit.addAttribute(
            .kern,
            value: spacing_Ornit,
            range: NSRange(location: 0, length: attrStr_ornit.length)
        )
        attributedText = attrStr_ornit
    }
}
