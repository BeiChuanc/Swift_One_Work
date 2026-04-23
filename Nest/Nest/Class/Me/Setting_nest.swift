import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面
/// 核心作用：提供用户协议、隐私政策、登出、删除账号四个核心操作入口
/// 设计思路：
///   - 沉浸式渐变 Header（紧贴屏幕顶部，波浪底边 + 装饰气泡）
///   - 分组卡片（Legal / Account），每组带渐变点标题
///   - 每行设置项：大图标徽章 + 主标题 + 副标题描述 + 右侧操作指示
///   - 危险操作行用警示色区分，底部展示应用版本信息
class Setting_Nest: UIViewController {

    // MARK: - UI 组件

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.alwaysBounceVertical = true
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest = UIView()
    private let headerView_Nest  = SettingHeaderView_Nest()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        setupScrollView_Nest()
        buildContent_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView_Nest.updateCurvedMask_Nest()
    }

    // MARK: - 布局

    private func setupScrollView_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)

        scrollView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }
    }

    // MARK: - 内容构建

    private func buildContent_Nest() {
        headerView_Nest.onBack_Nest = { [weak self] in Navigation_Nest.pop_Nest(from: self) }
        contentView_Nest.addSubview(headerView_Nest)
        headerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(130)
        }

        // Legal 分组
        let legalCard_Nest = buildGroupCard_Nest(
            sectionTitle: "Legal",
            rows: [
                SettingRowConfig_Nest(
                    icon: "doc.text.fill",
                    iconTint: ColorConfig_Nest.primaryGradientStart_Nest,
                    title: "Terms of Service",
                    subtitle: "Read our terms and conditions",
                    indicator: .arrow,
                    tag: 1
                ),
                SettingRowConfig_Nest(
                    icon: "lock.shield.fill",
                    iconTint: ColorConfig_Nest.primaryGradientEnd_Nest,
                    title: "Privacy Policy",
                    subtitle: "How we handle your data",
                    indicator: .arrow,
                    tag: 2
                )
            ]
        )

        // Account 分组
        let accountCard_Nest = buildGroupCard_Nest(
            sectionTitle: "Account",
            rows: [
                SettingRowConfig_Nest(
                    icon: "arrow.right.square.fill",
                    iconTint: UIColor(hexstring_Nest: "#F6AD55"),
                    title: "Sign Out",
                    subtitle: "You can sign in again at any time",
                    indicator: .none,
                    tag: 3
                ),
                SettingRowConfig_Nest(
                    icon: "trash.fill",
                    iconTint: UIColor(hexstring_Nest: "#FC8181"),
                    title: "Delete Account",
                    subtitle: "Permanently remove your account",
                    indicator: .warning,
                    tag: 4,
                    titleColor: UIColor(hexstring_Nest: "#FC8181")
                )
            ]
        )

        contentView_Nest.addSubview(legalCard_Nest)
        contentView_Nest.addSubview(accountCard_Nest)

        legalCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(headerView_Nest.snp.bottom).offset(24)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
        }
        accountCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(legalCard_Nest.snp.bottom).offset(20)
            make_Nest.leading.trailing.equalTo(legalCard_Nest)
            make_Nest.bottom.equalToSuperview().offset(-40)
        }
    }

    /// 构建分组卡片（含标题行 + 若干设置行）
    /// - Parameters:
    ///   - sectionTitle: 组标题文字
    ///   - rows: 行配置数组
    private func buildGroupCard_Nest(sectionTitle: String, rows: [SettingRowConfig_Nest]) -> UIView {
        let wrapper_Nest = UIView()

        // 组标题
        let sectionHeader_Nest = makeSectionHeader_Nest(title: sectionTitle)
        wrapper_Nest.addSubview(sectionHeader_Nest)
        sectionHeader_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(28)
        }

        // 卡片
        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        card_Nest.layer.cornerRadius = 20
        card_Nest.layer.shadowColor  = ColorConfig_Nest.shadowColor_Nest.cgColor
        card_Nest.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Nest.layer.shadowRadius = 14
        card_Nest.layer.shadowOpacity = 1
        wrapper_Nest.addSubview(card_Nest)
        card_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(sectionHeader_Nest.snp.bottom).offset(8)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }

        // 逐行构建
        var prevView_Nest: UIView? = nil
        for (i_Nest, config_Nest) in rows.enumerated() {
            let rowView_Nest = makeRowView_Nest(config: config_Nest)
            card_Nest.addSubview(rowView_Nest)
            rowView_Nest.snp.makeConstraints { make_Nest in
                make_Nest.leading.trailing.equalToSuperview()
                if let prev_Nest = prevView_Nest {
                    make_Nest.top.equalTo(prev_Nest.snp.bottom)
                } else {
                    make_Nest.top.equalToSuperview()
                }
                if i_Nest == rows.count - 1 {
                    make_Nest.bottom.equalToSuperview()
                }
            }

            // 分割线（非最后一行）
            if i_Nest < rows.count - 1 {
                let div_Nest = makeDivider_Nest()
                card_Nest.addSubview(div_Nest)
                div_Nest.snp.makeConstraints { make_Nest in
                    make_Nest.top.equalTo(rowView_Nest.snp.bottom)
                    make_Nest.leading.equalToSuperview().offset(72)
                    make_Nest.trailing.equalToSuperview().offset(-16)
                    make_Nest.height.equalTo(0.5)
                }
                prevView_Nest = div_Nest
            } else {
                prevView_Nest = rowView_Nest
            }
        }
        return wrapper_Nest
    }

    /// 构建单行设置视图
    private func makeRowView_Nest(config: SettingRowConfig_Nest) -> UIView {
        let row_Nest = UIView()
        row_Nest.backgroundColor = .clear
        row_Nest.tag = config.tag
        row_Nest.isUserInteractionEnabled = true
        row_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRowTapped_Nest(_:))))

        // 图标徽章
        let iconBadge_Nest = UIView()
        iconBadge_Nest.backgroundColor = config.iconTint.withAlphaComponent(0.12)
        iconBadge_Nest.layer.cornerRadius = 14
        let iconIV_Nest = UIImageView(image: UIImage(systemName: config.icon))
        iconIV_Nest.tintColor = config.iconTint
        iconIV_Nest.contentMode = .scaleAspectFit
        iconBadge_Nest.addSubview(iconIV_Nest)

        // 文字
        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = config.title
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLbl_Nest.textColor = config.titleColor

        let subtitleLbl_Nest = UILabel()
        subtitleLbl_Nest.text = config.subtitle
        subtitleLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        subtitleLbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest

        row_Nest.addSubview(iconBadge_Nest)
        row_Nest.addSubview(titleLbl_Nest)
        row_Nest.addSubview(subtitleLbl_Nest)

        iconBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(44)
        }
        iconIV_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(22)
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(14)
            make_Nest.leading.equalTo(iconBadge_Nest.snp.trailing).offset(14)
        }
        subtitleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(3)
            make_Nest.leading.equalTo(titleLbl_Nest)
            make_Nest.bottom.equalToSuperview().offset(-14)
        }

        // 右侧指示器
        switch config.indicator {
        case .arrow:
            let arrowIV_Nest = UIImageView(image: UIImage(systemName: "chevron.right"))
            arrowIV_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
            arrowIV_Nest.contentMode = .scaleAspectFit
            row_Nest.addSubview(arrowIV_Nest)
            arrowIV_Nest.snp.makeConstraints { make_Nest in
                make_Nest.trailing.equalToSuperview().offset(-16)
                make_Nest.centerY.equalToSuperview()
                make_Nest.width.equalTo(9)
                make_Nest.height.equalTo(15)
            }
        case .warning:
            let warnLbl_Nest = UILabel()
            warnLbl_Nest.text = "Danger"
            warnLbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            warnLbl_Nest.textColor = UIColor(hexstring_Nest: "#FC8181")
            warnLbl_Nest.backgroundColor = UIColor(hexstring_Nest: "#FC8181").withAlphaComponent(0.1)
            warnLbl_Nest.layer.cornerRadius = 9
            warnLbl_Nest.clipsToBounds = true
            warnLbl_Nest.textAlignment = .center
            row_Nest.addSubview(warnLbl_Nest)
            warnLbl_Nest.snp.makeConstraints { make_Nest in
                make_Nest.trailing.equalToSuperview().offset(-16)
                make_Nest.centerY.equalToSuperview()
                make_Nest.width.equalTo(56)
                make_Nest.height.equalTo(22)
            }
        case .none:
            break
        }

        return row_Nest
    }

    /// 创建组标题行（渐变圆点 + 标题文字）
    private func makeSectionHeader_Nest(title: String) -> UIView {
        let view_Nest = UIView()
        let dot_Nest  = SettingDotView_Nest()
        let lbl_Nest  = UILabel()
        lbl_Nest.text = title
        lbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest

        view_Nest.addSubview(dot_Nest)
        view_Nest.addSubview(lbl_Nest)

        dot_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(7)
        }
        lbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(dot_Nest.snp.trailing).offset(7)
            make_Nest.centerY.equalToSuperview()
        }
        return view_Nest
    }

    private func makeDivider_Nest() -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
        return v_Nest
    }

    // MARK: - 事件

    @objc private func onRowTapped_Nest(_ gesture: UITapGestureRecognizer) {
        guard let view_Nest = gesture.view else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        view_Nest.animatePressDown_Nest { view_Nest.animatePressUp_Nest() }

        switch view_Nest.tag {
        case 1:
            ProtocolHelper_Nest.showProtocol_Nest(type_Nest: .terms_Nest, content_Nest: "terms.png", from: self)
        case 2:
            ProtocolHelper_Nest.showProtocol_Nest(type_Nest: .privacy_Nest, content_Nest: "privacy.png", from: self)
        case 3:
            showLogoutConfirm_Nest()
        case 4:
            showDeleteConfirm_Nest()
        default:
            break
        }
    }

    private func showLogoutConfirm_Nest() {
        let alert_Nest = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert_Nest.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Nest.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            guard let self else { return }
            UserViewModel_Nest.shared_Nest.logout_Nest(logoutType_nest: .logout_nest)
        })
        present(alert_Nest, animated: true)
    }

    private func showDeleteConfirm_Nest() {
        let alert_Nest = UIAlertController(title: "Delete Account", message: "This action cannot be undone. Your account will be permanently deleted.", preferredStyle: .alert)
        alert_Nest.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Nest.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            UserViewModel_Nest.shared_Nest.logout_Nest(logoutType_nest: .delete_nest)
        })
        present(alert_Nest, animated: true)
    }
}

// MARK: - SettingRowConfig_Nest
/// 设置行数据模型，解耦视图创建与数据
private struct SettingRowConfig_Nest {
    enum Indicator_Nest { case arrow, warning, none }
    let icon:       String
    let iconTint:   UIColor
    let title:      String
    let subtitle:   String
    let indicator:  Indicator_Nest
    let tag:        Int
    var titleColor: UIColor = ColorConfig_Nest.textPrimary_Nest
}

// MARK: - SettingHeaderView_Nest
/// 设置页顶部沉浸式渐变 Header
/// 紧贴屏幕顶部（无 safeArea 间隙），波浪底边 + 装饰气泡 + 返回按钮 + 标题
private class SettingHeaderView_Nest: UIView {

    var onBack_Nest: (() -> Void)?

    private var gradientLayer_Nest: CAGradientLayer?

    private let bubble1_Nest = SettingHeaderView_Nest.makeBubble_Nest(size: 120, alpha: 0.08)
    private let bubble2_Nest = SettingHeaderView_Nest.makeBubble_Nest(size: 70,  alpha: 0.10)
    private let bubble3_Nest = SettingHeaderView_Nest.makeBubble_Nest(size: 40,  alpha: 0.13)

    private let backBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()

    private let backIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Settings"
        lbl_Nest.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Manage your account & preferences"
        lbl_Nest.font = UIFont.systemFont(ofSize: 12)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.7)
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)

        backBtn_Nest.addSubview(backIcon_Nest)
        addSubview(backBtn_Nest)
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)

        // 气泡
        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-20)
            make_Nest.trailing.equalToSuperview().offset(20)
            make_Nest.width.height.equalTo(120)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(10)
            make_Nest.trailing.equalToSuperview().offset(-50)
            make_Nest.width.height.equalTo(70)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(30)
            make_Nest.trailing.equalToSuperview().offset(-100)
            make_Nest.width.height.equalTo(40)
        }

        // 返回按钮
        backBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.bottom.equalToSuperview().offset(-18)
            make_Nest.width.height.equalTo(36)
        }
        backIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(16)
        }

        // 标题（返回按钮右侧）
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(backBtn_Nest.snp.trailing).offset(12)
            make_Nest.centerY.equalTo(backBtn_Nest)
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLabel_Nest)
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(2)
        }

        // 返回按钮手势
        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped_Nest)))
    }

    /// 刷新渐变 frame 与波浪底边蒙版，在 viewDidLayoutSubviews 后调用
    func updateCurvedMask_Nest() {
        gradientLayer_Nest?.frame = bounds
        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 14))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - 14),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + 18)
        )
        path_Nest.close()
        let mask_Nest = CAShapeLayer()
        mask_Nest.path = path_Nest.cgPath
        layer.mask = mask_Nest
    }

    @objc private func backTapped_Nest() {
        backBtn_Nest.animatePressDown_Nest { self.backBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onBack_Nest?()
    }
}

// MARK: - SettingDotView_Nest
/// 分组标题左侧渐变小圆点
private class SettingDotView_Nest: UIView {
    private var gradientLayer_Nest: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 3.5
        clipsToBounds = true
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Nest?.frame = bounds
    }
}
