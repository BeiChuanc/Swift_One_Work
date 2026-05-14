import Foundation
import UIKit
import SnapKit

// MARK: 设置页
// 设计思路：
//   顶部采用与全局统一的深紫-靛蓝渐变 Header（圆弧底部）；
//   内容区采用分组卡片布局：Legal 组（Terms / Privacy）、
//   Account 组（Edit Profile / Log Out / Delete Account）；
//   每行图标背景色与主题协调，底部展示 App 版本信息。
//   整体色调与 Discover / Release / Messages 一致（深紫-靛蓝）。

/// 设置页视图控制器
class Setting_Echd: UIViewController {

    // MARK: - UI组件 / Header

    /// 顶部渐变 Header 容器
    private let headerView_Echd = UIView()

    /// Header 渐变图层
    private var headerGradient_Echd: CAGradientLayer?

    /// 返回按钮
    private let backButton_Echd = BackButton_Echd()

    /// 页面标题
    private let pageTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Settings"
        label_Echd.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    /// Header 副标题
    private let pageSubLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Manage your account ✦"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.75)
        return label_Echd
    }()

    /// Header 右侧装饰图标
    private let headerDecoIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        iv_Echd.image = UIImage(systemName: "gearshape.2", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - UI组件 / 滚动区

    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        return sv_Echd
    }()

    private let contentView_Echd = UIView()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerView_Echd.bounds
        applyHeaderArc_Echd()
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // Header
        headerView_Echd.clipsToBounds = true
        view.addSubview(headerView_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        headerGradient_Echd = grad_Echd

        headerView_Echd.addSubview(pageTitleLabel_Echd)
        headerView_Echd.addSubview(pageSubLabel_Echd)
        headerView_Echd.addSubview(headerDecoIcon_Echd)

        view.addSubview(backButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }

        // 滚动区
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        buildSettingsContent_Echd()
    }

    /// Header 底部圆弧遮罩
    private func applyHeaderArc_Echd() {
        let w_Echd = headerView_Echd.bounds.width
        let h_Echd = headerView_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 20))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 20),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 20)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer()
        mask_Echd.path = path_Echd.cgPath
        headerView_Echd.layer.mask = mask_Echd
    }

    /// 构建设置内容（分组卡片）
    private func buildSettingsContent_Echd() {
        var lastAnchor_Echd = contentView_Echd.snp.top

        // MARK: Legal 分组
        let (legalGroup_Echd, legalAnchor_Echd) = buildSectionGroup_Echd(
            title: "LEGAL",
            topAnchor: lastAnchor_Echd,
            topOffset: 16,
            rows: [
                SettingRowConfig_Echd(
                    icon: "doc.text.fill",
                    iconGradient: (UIColor(hexstring_Echd: "#7C3AED"), UIColor(hexstring_Echd: "#6366F1")),
                    title: "Terms of Service",
                    showArrow: true,
                    action: #selector(termsTapped_Echd)
                ),
                SettingRowConfig_Echd(
                    icon: "hand.raised.fill",
                    iconGradient: (UIColor(hexstring_Echd: "#10B981"), UIColor(hexstring_Echd: "#059669")),
                    title: "Privacy Policy",
                    showArrow: true,
                    action: #selector(privacyTapped_Echd)
                )
            ]
        )
        _ = legalGroup_Echd
        lastAnchor_Echd = legalAnchor_Echd

        // MARK: Account 分组（已移除 Edit Profile）
        let (accountGroup_Echd, accountAnchor_Echd) = buildSectionGroup_Echd(
            title: "ACCOUNT",
            topAnchor: lastAnchor_Echd,
            topOffset: 24,
            rows: [
                SettingRowConfig_Echd(
                    icon: "arrow.right.square.fill",
                    iconGradient: (UIColor(hexstring_Echd: "#F59E0B"), UIColor(hexstring_Echd: "#EF4444")),
                    title: "Log Out",
                    showArrow: false,
                    titleColor: UIColor(hexstring_Echd: "#1F2937"),
                    action: #selector(logoutTapped_Echd)
                ),
                SettingRowConfig_Echd(
                    icon: "trash.fill",
                    iconGradient: (UIColor(hexstring_Echd: "#EF4444"), UIColor(hexstring_Echd: "#DC2626")),
                    title: "Delete Account",
                    showArrow: false,
                    titleColor: UIColor(hexstring_Echd: "#EF4444"),
                    action: #selector(deleteAccountTapped_Echd)
                )
            ]
        )
        _ = accountGroup_Echd
        lastAnchor_Echd = accountAnchor_Echd

        // 底部收尾约束（已移除版本信息）
        let spacer_Echd = UIView()
        contentView_Echd.addSubview(spacer_Echd)
        spacer_Echd.snp.makeConstraints { make in
            make.top.equalTo(lastAnchor_Echd).offset(30)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }
    }

    /// 构建一个分组卡片（含 section 标签 + 内部行）
    /// - Returns: (groupWrapper视图, 尾部约束锚点)
    private func buildSectionGroup_Echd(
        title: String,
        topAnchor: ConstraintRelatableTarget,
        topOffset: CGFloat,
        rows: [SettingRowConfig_Echd]
    ) -> (UIView, ConstraintItem) {
        let wrapper_Echd = UIView()
        contentView_Echd.addSubview(wrapper_Echd)

        // Section 标题
        let sectionLabel_Echd = UILabel()
        sectionLabel_Echd.text = title
        sectionLabel_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        sectionLabel_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        wrapper_Echd.addSubview(sectionLabel_Echd)
        sectionLabel_Echd.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        // 卡片
        let card_Echd = UIView()
        card_Echd.backgroundColor = .white
        card_Echd.layer.cornerRadius = 18
        card_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.08).cgColor
        card_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Echd.layer.shadowRadius = 12
        card_Echd.layer.shadowOpacity = 1
        wrapper_Echd.addSubview(card_Echd)
        card_Echd.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_Echd.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }

        var prevRowBottomAnchor: ConstraintItem = card_Echd.snp.top
        for (idx_Echd, config_Echd) in rows.enumerated() {
            let row_Echd = buildRow_Echd(config: config_Echd)
            card_Echd.addSubview(row_Echd)
            row_Echd.snp.makeConstraints { make in
                make.top.equalTo(prevRowBottomAnchor)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(62)
                if idx_Echd == rows.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }
            prevRowBottomAnchor = row_Echd.snp.bottom

            // 非最后一行加分隔线
            if idx_Echd < rows.count - 1 {
                let div_Echd = UIView()
                div_Echd.backgroundColor = UIColor(hexstring_Echd: "#F3F4F6")
                card_Echd.addSubview(div_Echd)
                div_Echd.snp.makeConstraints { make in
                    make.top.equalTo(row_Echd.snp.bottom)
                    make.leading.equalToSuperview().offset(62)
                    make.trailing.equalToSuperview().offset(-16)
                    make.height.equalTo(0.5)
                }
                prevRowBottomAnchor = div_Echd.snp.bottom
            }
        }

        wrapper_Echd.snp.makeConstraints { make in
            make.top.equalTo(topAnchor).offset(topOffset)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        return (wrapper_Echd, wrapper_Echd.snp.bottom)
    }

    /// 构建单个设置行
    /// - Parameter config: 行配置
    private func buildRow_Echd(config: SettingRowConfig_Echd) -> UIView {
        let row_Echd = UIView()
        row_Echd.isUserInteractionEnabled = true

        // 图标渐变背景
        let iconBg_Echd = UIView()
        iconBg_Echd.layer.cornerRadius = 12
        iconBg_Echd.clipsToBounds = true
        row_Echd.addSubview(iconBg_Echd)

        let iconGrad_Echd = CAGradientLayer()
        iconGrad_Echd.colors = [config.iconGradient.0.cgColor, config.iconGradient.1.cgColor]
        iconGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        iconGrad_Echd.endPoint = CGPoint(x: 1, y: 1)
        iconBg_Echd.layer.insertSublayer(iconGrad_Echd, at: 0)

        // 在 layoutSubviews 后再设置 frame（在 row 的 layoutSubviews 中无法直接调用，用 UIView 子类更稳妥；这里用 DispatchQueue 补丁）
        DispatchQueue.main.async {
            iconGrad_Echd.frame = iconBg_Echd.bounds
        }

        let iconIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconIV_Echd.image = UIImage(systemName: config.icon, withConfiguration: cfg_Echd)
        iconIV_Echd.tintColor = .white
        iconIV_Echd.contentMode = .scaleAspectFit
        iconBg_Echd.addSubview(iconIV_Echd)

        // 标题
        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = config.title
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLbl_Echd.textColor = config.titleColor
        row_Echd.addSubview(titleLbl_Echd)

        // 副标题（可选）
        if let sub_Echd = config.subtitle {
            let subLbl_Echd = UILabel()
            subLbl_Echd.text = sub_Echd
            subLbl_Echd.font = UIFont.systemFont(ofSize: 12)
            subLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
            row_Echd.addSubview(subLbl_Echd)
            subLbl_Echd.snp.makeConstraints { make in
                make.leading.equalTo(titleLbl_Echd)
                make.top.equalTo(titleLbl_Echd.snp.bottom).offset(2)
            }
        }

        // 右侧箭头
        if config.showArrow {
            let arrowIV_Echd = UIImageView()
            let arrCfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            arrowIV_Echd.image = UIImage(systemName: "chevron.right", withConfiguration: arrCfg_Echd)
            arrowIV_Echd.tintColor = UIColor(hexstring_Echd: "#D1D5DB")
            arrowIV_Echd.contentMode = .scaleAspectFit
            row_Echd.addSubview(arrowIV_Echd)
            arrowIV_Echd.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.equalTo(8)
                make.height.equalTo(14)
            }
        }

        // 约束
        iconBg_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
        iconIV_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Echd.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
        }

        // 透明 UIButton 覆盖整行，原生处理点击响应和按压高亮
        // 替代之前的 UITapGestureRecognizer + UILongPressGestureRecognizer 组合，
        // 避免 LongPress(minimumPressDuration:0) 抢先识别导致 Tap 失效的问题。
        let actionBtn_Echd = UIButton(type: .custom)
        actionBtn_Echd.backgroundColor = .clear
        actionBtn_Echd.addTarget(self, action: config.action, for: .touchUpInside)
        // 按下时微微变灰，抬手恢复
        actionBtn_Echd.addAction(UIAction { [weak row_Echd] _ in
            UIView.animate(withDuration: 0.1) { row_Echd?.alpha = 0.6 }
        }, for: .touchDown)
        actionBtn_Echd.addAction(UIAction { [weak row_Echd] _ in
            UIView.animate(withDuration: 0.15) { row_Echd?.alpha = 1.0 }
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel])
        row_Echd.addSubview(actionBtn_Echd)
        actionBtn_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }

        return row_Echd
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        pageTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(headerDecoIcon_Echd.snp.leading).offset(-10)
        }
        pageSubLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }
        headerDecoIcon_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(8)
            make.width.height.equalTo(110)
        }
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }
    }

    // MARK: - 事件处理

    @objc private func termsTapped_Echd() {
        ProtocolHelper_Echd.showProtocol_Echd(type_Echd: .terms_Echd, content_Echd: "terms", from: self)
    }

    @objc private func privacyTapped_Echd() {
        ProtocolHelper_Echd.showProtocol_Echd(type_Echd: .privacy_Echd, content_Echd: "privacy", from: self)
    }

    @objc private func editProfileTapped_Echd() {
        Navigation_Echd.toEditInfo_Echd(style_echd: .push_echd)
    }

    @objc private func logoutTapped_Echd() {
        UIAlertController.logout_Echd {
            Task { @MainActor in
                UserViewModel_Echd.shared_Echd.logout_Echd(logoutType_echd: .logout_echd)
            }
        }
    }

    @objc private func deleteAccountTapped_Echd() {
        UIAlertController.delete_Echd {
            Task { @MainActor in
                UserViewModel_Echd.shared_Echd.logout_Echd(logoutType_echd: .delete_echd)
            }
        }
    }
}

// MARK: - 设置行配置模型

/// 设置行配置
/// 功能：封装单行设置项所需的所有视觉与交互参数
private struct SettingRowConfig_Echd {
    /// SF Symbol 图标名
    let icon: String
    /// 图标背景渐变色（起始色, 结束色）
    let iconGradient: (UIColor, UIColor)
    /// 行标题
    let title: String
    /// 是否显示右侧箭头
    let showArrow: Bool
    /// 标题颜色（默认深灰）
    var titleColor: UIColor = UIColor(hexstring_Echd: "#1F2937")
    /// 可选副标题
    var subtitle: String? = nil
    /// 点击 action（目标为 Setting_Echd 实例）
    let action: Selector
}
