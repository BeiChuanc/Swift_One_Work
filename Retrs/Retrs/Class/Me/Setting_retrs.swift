import Foundation
import UIKit
import SnapKit

// MARK: 设置页面 - 重构版

/// 设置页控制器
/// 核心作用：Terms、Privacy 协议入口，Sign Out、Delete Account 账号操作
/// 设计思路：渐变头部 + 分组卡片列表（Legal / Account），彩色图标容器区分功能语义
class Setting_Retrs: UIViewController {

    // MARK: - 属性

    private let userVM_Retrs = UserViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 渐变头部
    private let headerView_Retrs       = UIView()
    private let headerGradLayer_Retrs  = CAGradientLayer()
    private let backBtn_Retrs          = UIButton(type: .system)
    private let titleLabel_Retrs       = UILabel()
    private let headerSubLabel_Retrs   = UILabel()

    /// 设置分组数据：(sectionTitle, [(itemTitle, sfSymbol, iconBgColor, isDestructive)])
    private let sections_Retrs: [(String, [(String, String, String, Bool)])] = [
        ("Legal & Privacy", [
            ("Terms of Service",  "doc.text.fill",      "#B794F6", false),
            ("Privacy Policy",    "hand.raised.fill",   "#90CDF4", false)
        ]),
        ("Account", [
            ("Sign Out",          "rectangle.portrait.and.arrow.right.fill", "#FBB6CE", true),
            ("Delete Account",    "trash.fill",         "#FC8181", true)
        ])
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        buildSections_Retrs()
        setupConstraints_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
    }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.backgroundColor = .clear
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
        contentView_Retrs.backgroundColor = .clear
    }

    // MARK: - 渐变头部

    private func setupHeaderView_Retrs() {
        headerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 28
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡
        addBubble_Retrs(alpha: 0.12, size: 130, top: -30, trailing: 20)
        addBubble_Retrs(alpha: 0.07, size: 70,  bottom: 10, leading: -18)

        // 返回按钮（白色半透明圆形）
        backBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_Retrs.layer.cornerRadius = 18
        backBtn_Retrs.layer.borderWidth  = 1
        backBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        let cfg_Retrs = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        backBtn_Retrs.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg_Retrs), for: .normal)
        backBtn_Retrs.tintColor = .white
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(backBtn_Retrs)

        // 标题
        titleLabel_Retrs.text = "Settings"
        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 28, weight: .black)
        titleLabel_Retrs.textColor = .white
        headerView_Retrs.addSubview(titleLabel_Retrs)

        // 副标题
        headerSubLabel_Retrs.text = "Manage your account & preferences"
        headerSubLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        headerSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.75)
        headerView_Retrs.addSubview(headerSubLabel_Retrs)

        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        titleLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.centerX.equalToSuperview()
        }
        headerSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func addBubble_Retrs(alpha: CGFloat, size: CGFloat,
                                  top: CGFloat? = nil, bottom: CGFloat? = nil,
                                  leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        let v_Retrs = UIView()
        v_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Retrs.layer.cornerRadius = size / 2
        headerView_Retrs.addSubview(v_Retrs)
        v_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            if let t = top     { make.top.equalToSuperview().offset(t) }
            if let b = bottom  { make.bottom.equalToSuperview().offset(b) }
            if let l = leading { make.leading.equalToSuperview().offset(l) }
            if let r = trailing { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 分组卡片

    /// 动态构建所有分组卡片（添加到 contentView）
    private func buildSections_Retrs() {
        var prevAnchor: ConstraintItem? = nil
        let isFirst_Retrs = { (idx: Int) -> Bool in idx == 0 }

        for (secIdx_Retrs, section_Retrs) in sections_Retrs.enumerated() {
            // 分组标题
            let secLabel_Retrs = makeGroupLabel_Retrs(title_Retrs: section_Retrs.0)
            contentView_Retrs.addSubview(secLabel_Retrs)
            secLabel_Retrs.snp.makeConstraints { make in
                if let prev_Retrs = prevAnchor {
                    make.top.equalTo(prev_Retrs).offset(isFirst_Retrs(secIdx_Retrs) ? 0 : 22)
                } else {
                    make.top.equalToSuperview()
                }
                make.leading.equalToSuperview().offset(24)
            }

            // 卡片容器
            let card_Retrs = makeGroupCard_Retrs()
            contentView_Retrs.addSubview(card_Retrs)
            card_Retrs.snp.makeConstraints { make in
                make.top.equalTo(secLabel_Retrs.snp.bottom).offset(10)
                make.leading.equalToSuperview().offset(18)
                make.trailing.equalToSuperview().offset(-18)
            }

            // 卡片内行
            var lastRowAnchor: ConstraintItem? = nil
            for (rowIdx_Retrs, item_Retrs) in section_Retrs.1.enumerated() {
                let row_Retrs = makeSettingRow_Retrs(
                    title_Retrs: item_Retrs.0,
                    icon_Retrs:  item_Retrs.1,
                    iconBg_Retrs: item_Retrs.2,
                    isDestructive_Retrs: item_Retrs.3,
                    sectionIdx_Retrs: secIdx_Retrs,
                    rowIdx_Retrs: rowIdx_Retrs
                )
                card_Retrs.addSubview(row_Retrs)
                row_Retrs.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(62)
                    if let prev_Retrs = lastRowAnchor {
                        make.top.equalTo(prev_Retrs)
                    } else {
                        make.top.equalToSuperview()
                    }
                    if rowIdx_Retrs == section_Retrs.1.count - 1 {
                        make.bottom.equalToSuperview()
                    }
                }

                // 分隔线（非最后一行）
                if rowIdx_Retrs < section_Retrs.1.count - 1 {
                    let div_Retrs = UIView()
                    div_Retrs.backgroundColor = ColorConfig_Retrs.divider_Retrs
                    card_Retrs.addSubview(div_Retrs)
                    div_Retrs.snp.makeConstraints { make in
                        make.top.equalTo(row_Retrs.snp.bottom)
                        make.leading.equalToSuperview().offset(56)
                        make.trailing.equalToSuperview().offset(-16)
                        make.height.equalTo(0.5)
                    }
                    lastRowAnchor = div_Retrs.snp.bottom
                } else {
                    lastRowAnchor = row_Retrs.snp.bottom
                }
            }
            prevAnchor = card_Retrs.snp.bottom
        }

        // contentView 底部约束
        if let last_Retrs = prevAnchor {
            let dummy_Retrs = UIView()
            contentView_Retrs.addSubview(dummy_Retrs)
            dummy_Retrs.snp.makeConstraints { make in
                make.top.equalTo(last_Retrs).offset(32)
                make.height.equalTo(1)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }

    /// 创建分组标题 Label
    private func makeGroupLabel_Retrs(title_Retrs: String) -> UILabel {
        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs.uppercased()
        lbl_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.7)
        lbl_Retrs.letterSpacing_Retrs(1.2)
        return lbl_Retrs
    }

    /// 创建卡片容器（白色圆角阴影）
    private func makeGroupCard_Retrs() -> UIView {
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 18
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_Retrs.layer.shadowOpacity = 1
        card_Retrs.layer.shadowRadius  = 14
        return card_Retrs
    }

    /// 创建单个设置行
    private func makeSettingRow_Retrs(title_Retrs: String, icon_Retrs: String,
                                       iconBg_Retrs: String, isDestructive_Retrs: Bool,
                                       sectionIdx_Retrs: Int, rowIdx_Retrs: Int) -> UIView {
        let row_Retrs = UIView()
        row_Retrs.backgroundColor = .clear

        // 图标圆角背景
        let iconContainer_Retrs = UIView()
        iconContainer_Retrs.backgroundColor = UIColor(hexstring_Retrs: iconBg_Retrs).withAlphaComponent(0.18)
        iconContainer_Retrs.layer.cornerRadius = 11
        row_Retrs.addSubview(iconContainer_Retrs)
        iconContainer_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        let iconIV_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        )
        iconIV_Retrs.tintColor = UIColor(hexstring_Retrs: iconBg_Retrs)
        iconIV_Retrs.contentMode = .scaleAspectFit
        iconContainer_Retrs.addSubview(iconIV_Retrs)
        iconIV_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 行标题
        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl_Retrs.textColor = isDestructive_Retrs
            ? UIColor(hexstring_Retrs: "#FC8181")
            : ColorConfig_Retrs.textPrimary_Retrs
        row_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer_Retrs.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }

        // 右侧箭头
        let arrow_Retrs = UIImageView(
            image: UIImage(systemName: "chevron.right",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        )
        arrow_Retrs.tintColor = ColorConfig_Retrs.textPlaceholder_Retrs
        arrow_Retrs.contentMode = .scaleAspectFit
        row_Retrs.addSubview(arrow_Retrs)
        arrow_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }

        // 点击手势
        let tap_Retrs = SettingRowTapGesture_Retrs(
            sectionIdx_Retrs: sectionIdx_Retrs,
            rowIdx_Retrs: rowIdx_Retrs
        ) { [weak self] sec, row in
            self?.handleTap_Retrs(section: sec, row: row)
        }
        row_Retrs.addGestureRecognizer(tap_Retrs)
        row_Retrs.isUserInteractionEnabled = true

        return row_Retrs
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        scrollView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        // 第一个分组 secLabel 需要相对 header 定位
        // (已在 buildSections_Retrs 中处理，此处补充 header → first section 偏移)
        if let firstChild_Retrs = contentView_Retrs.subviews.first(where: { $0 !== headerView_Retrs && $0 is UILabel }) {
            firstChild_Retrs.snp.remakeConstraints { make in
                make.top.equalTo(headerView_Retrs.snp.bottom).offset(24)
                make.leading.equalToSuperview().offset(24)
            }
        }
    }

    // MARK: - 事件

    @objc private func backTapped_Retrs() {
        Navigation_Retrs.pop_Retrs()
    }

    /// 处理行点击
    private func handleTap_Retrs(section: Int, row: Int) {
        switch (section, row) {
        case (0, 0):
            ProtocolHelper_Retrs.showProtocol_Retrs(type_Retrs: .terms_Retrs, content_Retrs: "terms.png", from: self)
        case (0, 1):
            ProtocolHelper_Retrs.showProtocol_Retrs(type_Retrs: .privacy_Retrs, content_Retrs: "privacy.png", from: self)
        case (1, 0):
            UIAlertController.logout_Retrs { [weak self] in
                self?.userVM_Retrs.logout_Retrs(logoutType_retrs: .logout_retrs)
            }
        case (1, 1):
            UIAlertController.delete_Retrs { [weak self] in
                self?.userVM_Retrs.logout_Retrs(logoutType_retrs: .delete_retrs)
            }
        default:
            break
        }
    }
}

// MARK: - 带索引的点击手势（内部辅助）

/// 携带 section/row 索引的点击手势
private class SettingRowTapGesture_Retrs: UITapGestureRecognizer {
    private let sectionIdx_Retrs: Int
    private let rowIdx_Retrs: Int
    private let action_Retrs: (Int, Int) -> Void

    init(sectionIdx_Retrs: Int, rowIdx_Retrs: Int, action_Retrs: @escaping (Int, Int) -> Void) {
        self.sectionIdx_Retrs = sectionIdx_Retrs
        self.rowIdx_Retrs     = rowIdx_Retrs
        self.action_Retrs     = action_Retrs
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Retrs))
    }

    @objc private func handleTap_Retrs() {
        action_Retrs(sectionIdx_Retrs, rowIdx_Retrs)
    }
}

// MARK: - UILabel 字间距扩展（模块内使用）

private extension UILabel {
    /// 设置字间距
    func letterSpacing_Retrs(_ spacing_Retrs: CGFloat) {
        guard let text_Retrs = text else { return }
        let attr_Retrs = NSMutableAttributedString(string: text_Retrs)
        attr_Retrs.addAttribute(.kern, value: spacing_Retrs,
                                range: NSRange(location: 0, length: attr_Retrs.length - 1))
        attributedText = attr_Retrs
    }
}
