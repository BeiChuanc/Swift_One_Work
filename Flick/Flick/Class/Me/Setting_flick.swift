import UIKit
import SnapKit

// MARK: - 设置页面控制器

/// 设置页面控制器
/// 功能：服务条款/隐私政策查看入口、登出账号、删除账号操作
/// 设计：波浪渐变头部（返回按钮右侧显示副标题）+ 分组卡片行（带副标题）
class Setting_Flick: UIViewController {

    // MARK: - UI 组件

    private let scrollView_Flick: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        // 禁止 ScrollView 自动增加安全区 inset，确保渐变头部贴顶显示
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Flick = UIView()

    /// 顶部渐变头部（含波浪下边缘）
    private let headerView_Flick = UIView()
    private var headerGradient_Flick: CAGradientLayer?
    private var headerWaveMask_Flick: CAShapeLayer?

    /// 返回按钮
    private let backBtn_Flick: BackButton_Flick = BackButton_Flick()

    /// 页面标题
    private let titleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Settings"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    /// 副标题
    private let subtitleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Manage your account"
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withValues(alpha: 0.7)
        return lbl
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Flick?.frame = headerView_Flick.bounds
        applyHeaderWave_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applySignOutGradient_Flick()
    }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        view.addSubview(scrollView_Flick)
        scrollView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView_Flick.addSubview(contentView_Flick)
        contentView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        setupHeader_Flick()
        setupLegalSection_Flick()
        setupAccountSection_Flick()
    }

    // MARK: - 头部区域

    private func setupHeader_Flick() {
        contentView_Flick.addSubview(headerView_Flick)
        headerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(155)
        }

        let gradient = UIColor.createPrimaryGradientLayer_Flick(
            frame_Flick: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 155)
        )
        headerView_Flick.layer.insertSublayer(gradient, at: 0)
        headerGradient_Flick = gradient

        // 波浪遮罩（viewDidLayoutSubviews 中应用）
        let mask = CAShapeLayer()
        headerView_Flick.layer.mask = mask
        headerWaveMask_Flick = mask

        addHeaderDecor_Flick()

        // 返回按钮
        headerView_Flick.addSubview(backBtn_Flick)
        backBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(headerView_Flick.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        backBtn_Flick.onTapped_Flick = { [weak self] in Navigation_Flick.pop_Flick(from: self) }

        // 副标题：与返回按钮同行，显示在其右侧
        headerView_Flick.addSubview(subtitleLabel_Flick)
        subtitleLabel_Flick.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Flick.snp.right).offset(10)
            make.centerY.equalTo(backBtn_Flick)
        }

        // 大标题：紧跟返回按钮下方，减少中间空白
        headerView_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.top.equalTo(backBtn_Flick.snp.bottom).offset(8)
        }

        // 右侧大图标装饰
        let decorIcon = UILabel()
        decorIcon.text = "⚙️"
        decorIcon.font = .systemFont(ofSize: 52)
        decorIcon.alpha = 0.85
        headerView_Flick.addSubview(decorIcon)
        decorIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(28)
            make.centerY.equalTo(titleLabel_Flick)
        }
    }

    /// 波浪遮罩（向下弯曲）
    private func applyHeaderWave_Flick() {
        let b = headerView_Flick.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: b.width, y: 0))
        path.addLine(to: CGPoint(x: b.width, y: b.height - 24))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: b.height - 24),
            controlPoint: CGPoint(x: b.width / 2, y: b.height + 24)
        )
        path.close()
        headerWaveMask_Flick?.path = path.cgPath
    }

    private func addHeaderDecor_Flick() {
        let circles: [(CGFloat, CGFloat, CGFloat, Bool)] = [
            (120, -30, 0.08, true),
            (90, 20, 0.05, false)
        ]
        for (size, yOffset, alpha, isRight) in circles {
            let c = UIView()
            c.backgroundColor = UIColor.white.withValues(alpha: alpha)
            c.layer.cornerRadius = size / 2
            headerView_Flick.addSubview(c)
            c.snp.makeConstraints { make in
                make.width.height.equalTo(size)
                if isRight {
                    make.right.equalToSuperview().offset(40)
                    make.top.equalToSuperview().offset(yOffset)
                } else {
                    make.left.equalToSuperview().offset(130)
                    make.bottom.equalToSuperview().offset(yOffset)
                }
            }
        }
    }

    // MARK: - 法律协议区域

    private func setupLegalSection_Flick() {
        let sectionLabel = buildSectionLabel_Flick(text: "Legal", dotColor: UIColor(hexstring_Flick: "#B794F6"))
        contentView_Flick.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView_Flick.snp.bottom).offset(28)
            make.left.equalToSuperview().inset(20)
        }

        let card = buildCard_Flick()
        contentView_Flick.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }

        let termsRow = buildSettingRow_Flick(
            icon: "doc.text.fill",
            iconColor: UIColor(hexstring_Flick: "#B794F6"),
            title: "Terms of Service",
            subtitle: "Read our terms and conditions",
            showDivider: true
        )
        card.addSubview(termsRow)
        termsRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(68)
        }
        addTapAction_Flick(to: termsRow) { [weak self] in
            self?.openProtocol_Flick(type: .terms_Flick, imageName: "terms.png")
        }

        let privacyRow = buildSettingRow_Flick(
            icon: "lock.shield.fill",
            iconColor: UIColor(hexstring_Flick: "#90CDF4"),
            title: "Privacy Policy",
            subtitle: "How we protect your data",
            showDivider: false
        )
        card.addSubview(privacyRow)
        privacyRow.snp.makeConstraints { make in
            make.top.equalTo(termsRow.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(68)
            make.bottom.equalToSuperview()
        }
        addTapAction_Flick(to: privacyRow) { [weak self] in
            self?.openProtocol_Flick(type: .privacy_Flick, imageName: "privacy.png")
        }
    }

    // MARK: - 账号操作区域

    private func setupAccountSection_Flick() {
        guard let legalCard = contentView_Flick.subviews.last else { return }

        let sectionLabel = buildSectionLabel_Flick(text: "Account", dotColor: UIColor(hexstring_Flick: "#FC8181"))
        contentView_Flick.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            make.top.equalTo(legalCard.snp.bottom).offset(28)
            make.left.equalToSuperview().inset(20)
        }

        let signOutBtn = buildActionButton_Flick(title: "Sign Out", icon: "arrow.right.square.fill", style: .signOut_Flick)
        contentView_Flick.addSubview(signOutBtn)
        signOutBtn.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(58)
        }
        signOutBtn.addTarget(self, action: #selector(signOutTapped_Flick), for: .touchUpInside)

        let deleteBtn = buildActionButton_Flick(title: "Delete Account", icon: "trash.fill", style: .delete_Flick)
        contentView_Flick.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.top.equalTo(signOutBtn.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().inset(52)
        }
        deleteBtn.addTarget(self, action: #selector(deleteTapped_Flick), for: .touchUpInside)
    }

    // MARK: - UI 工厂方法

    /// 构建带色点的区块标题 Label
    private func buildSectionLabel_Flick(text: String, dotColor: UIColor) -> UIView {
        let container = UIView()

        let dot = UIView()
        dot.backgroundColor = dotColor
        dot.layer.cornerRadius = 4
        container.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        let lbl = UILabel()
        lbl.text = text.uppercased()
        lbl.font = .systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = ColorConfig_Flick.textSecondary_Flick
        lbl.letterSpacing_Flick(spacing: 1.2)
        container.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(dot.snp.right).offset(8)
            make.top.bottom.right.equalToSuperview()
        }

        return container
    }

    private func buildCard_Flick() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.cardBackground_Flick
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.05).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        return v
    }

    /// 构建设置行（图标 + 标题 + 副标题 + 箭头 + 可选分割线）
    private func buildSettingRow_Flick(
        icon: String,
        iconColor: UIColor,
        title: String,
        subtitle: String,
        showDivider: Bool
    ) -> UIView {
        let row = UIView()
        row.backgroundColor = .clear

        let iconBg = UIView()
        iconBg.backgroundColor = iconColor.withValues(alpha: 0.13)
        iconBg.layer.cornerRadius = 11
        row.addSubview(iconBg)
        iconBg.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        let iconView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: cfg)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconBg.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(19)
        }

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLbl.textColor = ColorConfig_Flick.textPrimary_Flick
        row.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(14)
            make.top.equalToSuperview().inset(14)
        }

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLbl.textColor = ColorConfig_Flick.textSecondary_Flick
        row.addSubview(subtitleLbl)
        subtitleLbl.snp.makeConstraints { make in
            make.left.equalTo(titleLbl)
            make.top.equalTo(titleLbl.snp.bottom).offset(3)
        }

        let arrowView = UIImageView()
        let arrowCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        arrowView.image = UIImage(systemName: "chevron.right", withConfiguration: arrowCfg)
        arrowView.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        arrowView.contentMode = .scaleAspectFit
        row.addSubview(arrowView)
        arrowView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        if showDivider {
            let div = UIView()
            div.backgroundColor = ColorConfig_Flick.divider_Flick
            row.addSubview(div)
            div.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(70)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }

        return row
    }

    private enum ActionBtnStyle_Flick { case signOut_Flick, delete_Flick }

    private func buildActionButton_Flick(title: String, icon: String, style: ActionBtnStyle_Flick) -> UIButton {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 16

        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: icon, withConfiguration: cfg), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)

        switch style {
        case .signOut_Flick:
            btn.tintColor = .white
            btn.setTitleColor(.white, for: .normal)
            btn.layer.shadowColor = UIColor(hexstring_Flick: "#FBB6CE").cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 5)
            btn.layer.shadowOpacity = 0.4
            btn.layer.shadowRadius = 10
        case .delete_Flick:
            btn.tintColor = UIColor(hexstring_Flick: "#FC8181")
            btn.setTitleColor(UIColor(hexstring_Flick: "#FC8181"), for: .normal)
            btn.backgroundColor = UIColor(hexstring_Flick: "#FC8181").withValues(alpha: 0.08)
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = UIColor(hexstring_Flick: "#FC8181").withValues(alpha: 0.35).cgColor
        }
        return btn
    }

    private func addTapAction_Flick(to view: UIView, action: @escaping () -> Void) {
        view.isUserInteractionEnabled = true
        let tap = SettingRowTapGesture_Flick(action: action)
        view.addGestureRecognizer(tap)
    }

    // MARK: - 渐变按钮 + 色条

    /// 为 Sign Out 按钮应用辅助渐变色
    private func applySignOutGradient_Flick() {
        let buttons = contentView_Flick.subviews.compactMap { $0 as? UIButton }
        guard let signOutBtn = buttons.first else { return }
        signOutBtn.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let grad = UIColor.createSecondaryGradientLayer_Flick(frame_Flick: signOutBtn.bounds)
        grad.cornerRadius = 16
        signOutBtn.layer.insertSublayer(grad, at: 0)
    }

    // MARK: - 事件处理

    @objc private func signOutTapped_Flick() {
        UIAlertController.logout_Flick {
            UserViewModel_Flick.shared_Flick.logout_Flick(logoutType_flick: .logout_flick)
        }
    }

    @objc private func deleteTapped_Flick() {
        UIAlertController.delete_Flick {
            UserViewModel_Flick.shared_Flick.logout_Flick(logoutType_flick: .delete_flick)
        }
    }

    private func openProtocol_Flick(type: ProtocolHelper_Flick.ProtocolType_Flick, imageName: String) {
        ProtocolHelper_Flick.showProtocol_Flick(type_Flick: type, content_Flick: imageName, from: self)
    }
}

// MARK: - UILabel 字间距扩展（本文件内部使用）

private extension UILabel {
    func letterSpacing_Flick(spacing: CGFloat) {
        guard let text = text else { return }
        let attrs: [NSAttributedString.Key: Any] = [
            .kern: spacing,
            .font: font as Any,
            .foregroundColor: textColor as Any
        ]
        attributedText = NSAttributedString(string: text, attributes: attrs)
    }
}

// MARK: - 设置行点击手势识别器

/// 设置行点击手势，携带回调 action 及按压动画
private class SettingRowTapGesture_Flick: UITapGestureRecognizer {

    private var action_Flick: (() -> Void)?

    init(action: @escaping () -> Void) {
        self.action_Flick = action
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Flick))
    }

    @objc private func handleTap_Flick() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let v = view {
            v.animatePressDown_Flick { [weak v] in v?.animatePressUp_Flick() }
        }
        action_Flick?()
    }
}
