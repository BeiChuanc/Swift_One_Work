import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 功能：展示 Terms、Privacy、登出、删除账号
/// 设计亮点：
///   • 青绿→靛蓝渐变头部（区别于我的页面玫瑰色与其他页面紫色）
///   • 头部副标题 + 右侧渐变装饰符
///   • 顶部用户身份识别卡（显示当前用户名 + 头像 + 跳转编辑）
///   • 设置分组卡片：左侧彩色图标背景 + 右侧状态徽章（箭头/危险标识）
class Setting_Vestir: UIViewController {

    // MARK: - 设置项配置

    private struct SettingItem_Vestir {
        let icon_Vestir: String
        let title_Vestir: String
        let subtitle_Vestir: String
        let tintColor_Vestir: UIColor
        let showArrow_Vestir: Bool
    }

    private let settingItems_Vestir: [[SettingItem_Vestir]] = [
        [
            SettingItem_Vestir(
                icon_Vestir: "doc.text.fill",
                title_Vestir: "Terms of Service",
                subtitle_Vestir: "Usage rules & policies",
                tintColor_Vestir: UIColor(hexstring_Vestir: "#0D9488"),
                showArrow_Vestir: true
            ),
            SettingItem_Vestir(
                icon_Vestir: "hand.raised.fill",
                title_Vestir: "Privacy Policy",
                subtitle_Vestir: "Data collection & protection",
                tintColor_Vestir: UIColor(hexstring_Vestir: "#1D4ED8"),
                showArrow_Vestir: true
            )
        ],
        [
            SettingItem_Vestir(
                icon_Vestir: "rectangle.portrait.and.arrow.right.fill",
                title_Vestir: "Log Out",
                subtitle_Vestir: "You can log back in anytime",
                tintColor_Vestir: UIColor(hexstring_Vestir: "#D97706"),
                showArrow_Vestir: false
            ),
            SettingItem_Vestir(
                icon_Vestir: "trash.fill",
                title_Vestir: "Delete Account",
                subtitle_Vestir: "This action cannot be undone",
                tintColor_Vestir: UIColor(hexstring_Vestir: "#DC2626"),
                showArrow_Vestir: false
            )
        ]
    ]

    // MARK: - 渐变头部（青绿→靛蓝）

    private let headerShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#0D9488").cgColor
        v_Vestir.layer.shadowOpacity = 0.30
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 18
        return v_Vestir
    }()

    private let headerCard_Vestir = SettingTealBlueCard_Vestir()

    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        v_Vestir.layer.cornerRadius = 44
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private lazy var backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    private let navTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Settings"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    /// 头部第一行说明（Account & Privacy）
    private let navSubtitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Account & Privacy"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.75)
        return lbl_Vestir
    }()

    /// 头部第二行描述（补充说明）
    private let navDescLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Manage your account & legal documents"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.52)
        return lbl_Vestir
    }()

    /// 头部右侧装饰符
    private let navDecoLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .light)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.45)
        return lbl_Vestir
    }()

    // MARK: - 分区标题

    private func makeSectionTitle_Vestir(_ text: String, color: UIColor) -> UILabel {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = text
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Vestir.textColor = color
        return lbl_Vestir
    }

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        buildContent_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if headerShadow_Vestir.bounds.width > 0 {
            headerShadow_Vestir.layer.shadowPath = UIBezierPath(
                roundedRect: headerShadow_Vestir.bounds, cornerRadius: 0
            ).cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 90)
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        view.addSubview(headerShadow_Vestir)
        headerShadow_Vestir.addSubview(headerCard_Vestir)
        headerCard_Vestir.addSubview(decoCircle1_Vestir)
        headerCard_Vestir.addSubview(backBtn_Vestir)
        headerCard_Vestir.addSubview(navTitleLabel_Vestir)
        headerCard_Vestir.addSubview(navSubtitleLabel_Vestir)
        headerCard_Vestir.addSubview(navDescLabel_Vestir)
        headerCard_Vestir.addSubview(navDecoLabel_Vestir)

        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)
    }

    private func setupConstraints_Vestir() {
        headerShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 90)
        }
        headerCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.equalToSuperview().offset(26)
            make.top.equalToSuperview().offset(-26)
        }
        backBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(32)
        }
        // 标题左对齐（与返回按钮左边距对齐，更有层次感）
        navTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(backBtn_Vestir.snp.trailing).offset(12)
            make.bottom.equalToSuperview().offset(-18)
        }
        navSubtitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navTitleLabel_Vestir)
            make.bottom.equalTo(navTitleLabel_Vestir.snp.top).offset(-3)
        }
        navDescLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navTitleLabel_Vestir)
            make.top.equalTo(navTitleLabel_Vestir.snp.bottom).offset(3)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        navDecoLabel_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(navTitleLabel_Vestir)
        }

        scrollView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerShadow_Vestir.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
    }

    // MARK: - 构建内容

    private func buildContent_Vestir() {
        // 设置分组（从 contentView 顶部直接开始，无用户身份卡）
        let sectionTitles_Vestir = ["General", "Danger Zone"]
        let sectionColors_Vestir: [UIColor] = [
            UIColor(hexstring_Vestir: "#0D9488"),
            UIColor(hexstring_Vestir: "#DC2626")
        ]

        var lastBottom: ConstraintItem = contentView_Vestir.snp.top

        for (groupIdx_Vestir, group_Vestir) in settingItems_Vestir.enumerated() {
            // 分区标题
            let sectionTitle_Vestir = makeSectionTitle_Vestir(
                sectionTitles_Vestir[groupIdx_Vestir].uppercased(),
                color: sectionColors_Vestir[groupIdx_Vestir]
            )
            contentView_Vestir.addSubview(sectionTitle_Vestir)
            sectionTitle_Vestir.snp.makeConstraints { make in
                make.top.equalTo(lastBottom).offset(24)
                make.leading.equalToSuperview().offset(28)
            }

            let groupCard_Vestir = buildGroupCard_Vestir(
                items_vestir: group_Vestir,
                groupIdx_vestir: groupIdx_Vestir,
                accentColor_vestir: sectionColors_Vestir[groupIdx_Vestir]
            )
            groupCard_Vestir.alpha = 0
            contentView_Vestir.addSubview(groupCard_Vestir)
            groupCard_Vestir.snp.makeConstraints { make in
                make.top.equalTo(sectionTitle_Vestir.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(16)
            }
            groupCard_Vestir.animateSlideInFromBottom_Vestir(
                offset_Vestir: 30,
                delay_Vestir: Double(groupIdx_Vestir) * 0.10
            )

            lastBottom = groupCard_Vestir.snp.bottom
        }

        contentView_Vestir.snp.makeConstraints { make in
            make.bottom.equalTo(lastBottom).offset(40)
        }
    }

    private func buildGroupCard_Vestir(
        items_vestir: [SettingItem_Vestir],
        groupIdx_vestir: Int,
        accentColor_vestir: UIColor
    ) -> UIView {
        let card_Vestir = UIView()
        card_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        card_Vestir.layer.cornerRadius = 20
        card_Vestir.layer.shadowColor = accentColor_vestir.cgColor
        card_Vestir.layer.shadowOpacity = 0.11
        card_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Vestir.layer.shadowRadius = 12

        var lastRowBottom: ConstraintItem = card_Vestir.snp.top

        for (itemIdx_Vestir, item_Vestir) in items_vestir.enumerated() {
            let rowView_Vestir = buildRow_Vestir(
                item_vestir: item_Vestir,
                groupIdx_vestir: groupIdx_vestir,
                itemIdx_vestir: itemIdx_Vestir
            )
            card_Vestir.addSubview(rowView_Vestir)
            rowView_Vestir.snp.makeConstraints { make in
                make.top.equalTo(lastRowBottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(68)
            }

            if itemIdx_Vestir < items_vestir.count - 1 {
                let divider_Vestir = UIView()
                divider_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
                card_Vestir.addSubview(divider_Vestir)
                divider_Vestir.snp.makeConstraints { make in
                    make.top.equalTo(rowView_Vestir.snp.bottom)
                    make.leading.equalToSuperview().offset(66)
                    make.trailing.equalToSuperview().offset(-16)
                    make.height.equalTo(0.5)
                }
                lastRowBottom = divider_Vestir.snp.bottom
            } else {
                lastRowBottom = rowView_Vestir.snp.bottom
            }
        }

        card_Vestir.snp.makeConstraints { make in make.bottom.equalTo(lastRowBottom) }
        return card_Vestir
    }

    private func buildRow_Vestir(
        item_vestir: SettingItem_Vestir,
        groupIdx_vestir: Int,
        itemIdx_vestir: Int
    ) -> UIView {
        let row_Vestir = UIView()
        row_Vestir.isUserInteractionEnabled = true

        let iconBg_Vestir = UIView()
        iconBg_Vestir.backgroundColor = item_vestir.tintColor_Vestir.withAlphaComponent(0.14)
        iconBg_Vestir.layer.cornerRadius = 12

        let iconView_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iconView_Vestir.image = UIImage(systemName: item_vestir.icon_Vestir, withConfiguration: cfg_Vestir)
        iconView_Vestir.tintColor = item_vestir.tintColor_Vestir
        iconView_Vestir.contentMode = .scaleAspectFit

        let titleLabel_Vestir = UILabel()
        titleLabel_Vestir.text = item_vestir.title_Vestir
        titleLabel_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel_Vestir.textColor = groupIdx_vestir == 1
            ? item_vestir.tintColor_Vestir
            : ColorConfig_Vestir.textPrimary_Vestir

        let subtitleLabel_Vestir = UILabel()
        subtitleLabel_Vestir.text = item_vestir.subtitle_Vestir
        subtitleLabel_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir

        row_Vestir.addSubview(iconBg_Vestir)
        iconBg_Vestir.addSubview(iconView_Vestir)
        row_Vestir.addSubview(titleLabel_Vestir)
        row_Vestir.addSubview(subtitleLabel_Vestir)

        iconBg_Vestir.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(42)
        }
        iconView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        titleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalTo(iconBg_Vestir.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-44)
        }
        subtitleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Vestir.snp.bottom).offset(3)
            make.leading.trailing.equalTo(titleLabel_Vestir)
        }

        if item_vestir.showArrow_Vestir {
            let arrow_Vestir = UIImageView()
            arrow_Vestir.image = UIImage(systemName: "chevron.right")
            arrow_Vestir.tintColor = item_vestir.tintColor_Vestir.withAlphaComponent(0.60)
            arrow_Vestir.contentMode = .scaleAspectFit
            row_Vestir.addSubview(arrow_Vestir)
            arrow_Vestir.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-16)
                make.width.height.equalTo(14)
            }
        } else {
            // 危险操作右侧警告圆点
            let dangerDot_Vestir = UIView()
            dangerDot_Vestir.backgroundColor = item_vestir.tintColor_Vestir.withAlphaComponent(0.85)
            dangerDot_Vestir.layer.cornerRadius = 4
            row_Vestir.addSubview(dangerDot_Vestir)
            dangerDot_Vestir.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-20)
                make.width.height.equalTo(8)
            }
        }

        let tag_Vestir = groupIdx_vestir * 10 + itemIdx_vestir
        let tap_Vestir = UITapGestureRecognizer(target: self, action: #selector(settingRowTapped_Vestir(_:)))
        row_Vestir.tag = tag_Vestir
        row_Vestir.addGestureRecognizer(tap_Vestir)
        return row_Vestir
    }

    // MARK: - 数据

    // MARK: - 事件

    @objc private func backTapped_Vestir() { Navigation_Vestir.pop_Vestir() }

    @objc private func settingRowTapped_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let view_Vestir = gesture.view else { return }
        view_Vestir.animatePressDown_Vestir { view_Vestir.animatePressUp_Vestir() }

        switch (view_Vestir.tag / 10, view_Vestir.tag % 10) {
        case (0, 0):
            ProtocolHelper_Vestir.showProtocol_Vestir(
                type_Vestir: .terms_Vestir, content_Vestir: "terms", from: self
            )
        case (0, 1):
            ProtocolHelper_Vestir.showProtocol_Vestir(
                type_Vestir: .privacy_Vestir, content_Vestir: "privacy", from: self
            )
        case (1, 0):
            UIAlertController.logout_Vestir {
                Task { @MainActor in
                    UserViewModel_Vestir.shared_Vestir.logout_Vestir(logoutType_vestir: .logout_vestir)
                }
            }
        case (1, 1):
            UIAlertController.delete_Vestir {
                Task { @MainActor in
                    UserViewModel_Vestir.shared_Vestir.logout_Vestir(logoutType_vestir: .delete_vestir)
                }
            }
        default: break
        }
    }
}

// MARK: - 设置页渐变背景（青绿→靛蓝）

fileprivate final class SettingTealBlueCard_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#0F766E").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor,
            UIColor(hexstring_Vestir: "#1D4ED8").cgColor
        ]
        g.locations = [0, 0.50, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 24
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}
