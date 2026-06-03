import Foundation
import UIKit
import SnapKit

// MARK: 设置项枚举（文件级别供行视图复用）

/// 设置项类型枚举
enum SettingItem_Bague {
    case terms_bague
    case privacy_bague
    case logout_bague
    case deleteAccount_bague

    var title_Bague: String {
        switch self {
        case .terms_bague: return "Terms of Service"
        case .privacy_bague: return "Privacy Policy"
        case .logout_bague: return "Sign Out"
        case .deleteAccount_bague: return "Delete Account"
        }
    }

    var icon_Bague: String {
        switch self {
        case .terms_bague: return "doc.text.fill"
        case .privacy_bague: return "hand.raised.fill"
        case .logout_bague: return "rectangle.portrait.and.arrow.right"
        case .deleteAccount_bague: return "trash.fill"
        }
    }

    /// 图标调和色（各项使用不同颜色）
    var tintColor_Bague: UIColor {
        switch self {
        case .terms_bague: return UIColor(hexstring_Bague: "#5AADEC")
        case .privacy_bague: return UIColor(hexstring_Bague: "#9B72F5")
        case .logout_bague: return UIColor(hexstring_Bague: "#F5A623")
        case .deleteAccount_bague: return UIColor(hexstring_Bague: "#FF6B6B")
        }
    }

    var isDanger_Bague: Bool {
        return self == .logout_bague || self == .deleteAccount_bague
    }
}

// MARK: 设置页

/// 设置视图控制器
/// 功能：展示 Terms、Privacy、登出、删除账号四个功能入口
/// 设计：三色渐变头部、半透明胶囊返回按钮、调色盘图标行、分组卡片、蓝紫调阴影
class Setting_Bague: UIViewController {

    // MARK: - UI 组件（滚动容器）

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        // 禁止自动添加 safeArea 内边距，让头部渐变紧贴屏幕顶端
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Bague = UIView()

    // MARK: - 头部区域

    private let headerView_Bague = UIView()
    private var headerGradient_Bague: CAGradientLayer?

    /// 返回按钮（半透明胶囊）
    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    private let headerTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 30, weight: .black)
        label.textColor = .white
        return label
    }()

    private let headerSubtitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Manage your account & preferences"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        return label
    }()

    /// 头部装饰：半透明大圆
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰：设置齿轮图标
    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "gearshape.2.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.16)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部装饰：小星形
    private let headerDecorStar_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.13)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 内容区域（法律 & 账号分组）

    private let legalSectionRow_Bague = makeSettingSectionRow_Bague(
        icon: "doc.text.fill",
        title: "Legal",
        tint: UIColor(hexstring_Bague: "#5AADEC")
    )
    private let legalCard_Bague: UIView = makeSettingCard_Bague()

    private let accountSectionRow_Bague = makeSettingSectionRow_Bague(
        icon: "person.crop.circle.fill",
        title: "Account",
        tint: UIColor(hexstring_Bague: "#F5A623")
    )
    private let accountCard_Bague: UIView = makeSettingCard_Bague()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient_Bague()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        scrollView_Bague.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView_Bague.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)
        contentView_Bague.addSubview(headerView_Bague)

        // 头部
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        headerView_Bague.addSubview(headerDecorStar_Bague)
        headerView_Bague.addSubview(backBtn_Bague)
        headerView_Bague.addSubview(headerTitleLabel_Bague)
        headerView_Bague.addSubview(headerSubtitleLabel_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        // 法律条款组
        contentView_Bague.addSubview(legalSectionRow_Bague)
        contentView_Bague.addSubview(legalCard_Bague)
        let termsRow_Bague = SettingRowView_Bague(item_bague: .terms_bague, showDivider_bague: true)
        let privacyRow_Bague = SettingRowView_Bague(item_bague: .privacy_bague, showDivider_bague: false)
        legalCard_Bague.addSubview(termsRow_Bague)
        legalCard_Bague.addSubview(privacyRow_Bague)
        termsRow_Bague.onTap_Bague = { [weak self] in self?.handleTap_Bague(.terms_bague) }
        privacyRow_Bague.onTap_Bague = { [weak self] in self?.handleTap_Bague(.privacy_bague) }
        termsRow_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        privacyRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(termsRow_Bague.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(66)
        }

        // 账号操作组
        contentView_Bague.addSubview(accountSectionRow_Bague)
        contentView_Bague.addSubview(accountCard_Bague)
        let logoutRow_Bague = SettingRowView_Bague(item_bague: .logout_bague, showDivider_bague: true)
        let deleteRow_Bague = SettingRowView_Bague(item_bague: .deleteAccount_bague, showDivider_bague: false)
        accountCard_Bague.addSubview(logoutRow_Bague)
        accountCard_Bague.addSubview(deleteRow_Bague)
        logoutRow_Bague.onTap_Bague = { [weak self] in self?.handleTap_Bague(.logout_bague) }
        deleteRow_Bague.onTap_Bague = { [weak self] in self?.handleTap_Bague(.deleteAccount_bague) }
        logoutRow_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        deleteRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(logoutRow_Bague.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(66)
        }
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-15)
            make.width.height.equalTo(100)
        }
        // 装饰图标使用相对 headerView 的固定偏移，避免与 safeArea 参照产生空白
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(54)
            make.width.height.equalTo(72)
        }
        headerDecorStar_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-102)
            make.top.equalToSuperview().offset(62)
            make.width.height.equalTo(20)
        }
        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        // 标题紧跟返回按钮，消除红框空白区域
        headerTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
        }
        headerSubtitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Bague.snp.bottom).offset(5)
            make.leading.equalTo(headerTitleLabel_Bague)
        }
        legalSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerView_Bague.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        legalCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(legalSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        accountSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(legalCard_Bague.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        accountCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(accountSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    // MARK: - 渐变

    private func updateGradient_Bague() {
        headerGradient_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = headerView_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        grad_bague.locations = [0.0, 0.55, 1.0]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 28
        grad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(grad_bague, at: 0)
        headerGradient_Bague = grad_bague
    }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }

    private func handleTap_Bague(_ item_bague: SettingItem_Bague) {
        switch item_bague {
        case .terms_bague:
            ProtocolHelper_Bague.showProtocol_Bague(type_Bague: .terms_Bague, content_Bague: "terms.png", from: self)
        case .privacy_bague:
            ProtocolHelper_Bague.showProtocol_Bague(type_Bague: .privacy_Bague, content_Bague: "privacy.png", from: self)
        case .logout_bague:
            UIAlertController.logout_Bague {
                Task { @MainActor in
                    UserViewModel_Bague.shared_Bague.logout_Bague(logoutType_bague: .logout_bague)
                }
            }
        case .deleteAccount_bague:
            UIAlertController.delete_Bague {
                Task { @MainActor in
                    UserViewModel_Bague.shared_Bague.logout_Bague(logoutType_bague: .delete_bague)
                }
            }
        }
    }
}

// MARK: - 设置行视图

/// 单个设置条目行视图
/// 功能：展示图标、标题、箭头，支持点击动画和回调
/// 设计：各条目使用调色盘独立颜色区分，危险操作保持红/橙色
class SettingRowView_Bague: UIView {

    var onTap_Bague: (() -> Void)?

    private let iconBg_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        return v
    }()

    private let iconView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let arrowView_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Bague.textPlaceholder_Bague
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let dividerLine_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        return v
    }()

    init(item_bague: SettingItem_Bague, showDivider_bague: Bool) {
        super.init(frame: .zero)
        setupUI_Bague(item_bague: item_bague, showDivider_bague: showDivider_bague)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague(item_bague: SettingItem_Bague, showDivider_bague: Bool) {
        backgroundColor = .clear

        let tint_bague = item_bague.tintColor_Bague
        iconBg_Bague.backgroundColor = tint_bague.withAlphaComponent(0.12)
        iconView_Bague.tintColor = tint_bague
        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iconView_Bague.image = UIImage(systemName: item_bague.icon_Bague, withConfiguration: cfg_bague)
        titleLabel_Bague.text = item_bague.title_Bague
        titleLabel_Bague.textColor = item_bague.isDanger_Bague ? tint_bague : ColorConfig_Bague.textPrimary_Bague

        addSubview(iconBg_Bague)
        iconBg_Bague.addSubview(iconView_Bague)
        addSubview(titleLabel_Bague)
        addSubview(arrowView_Bague)

        iconBg_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        iconView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        titleLabel_Bague.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Bague.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
        }
        arrowView_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        if showDivider_bague {
            addSubview(dividerLine_Bague)
            dividerLine_Bague.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(74)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }

        let tap_bague = UITapGestureRecognizer(target: self, action: #selector(handleTap_Bague))
        addGestureRecognizer(tap_bague)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap_Bague() {
        animatePressDown_Bague {
            self.animatePressUp_Bague {
                self.onTap_Bague?()
            }
        }
    }
}

// MARK: - 辅助工厂方法

/// 创建带彩色图标的分组标题行视图
private func makeSettingSectionRow_Bague(icon: String, title: String, tint: UIColor) -> UIView {
    let container_bague = UIView()
    let iconView_bague = UIImageView()
    let cfg_bague = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
    iconView_bague.image = UIImage(systemName: icon, withConfiguration: cfg_bague)
    iconView_bague.tintColor = tint
    iconView_bague.contentMode = .scaleAspectFit
    let label_bague = UILabel()
    label_bague.text = title.uppercased()
    label_bague.font = UIFont.systemFont(ofSize: 11, weight: .bold)
    label_bague.textColor = tint
    container_bague.addSubview(iconView_bague)
    container_bague.addSubview(label_bague)
    iconView_bague.snp.makeConstraints { make in
        make.leading.centerY.equalToSuperview()
        make.width.height.equalTo(14)
    }
    label_bague.snp.makeConstraints { make in
        make.leading.equalTo(iconView_bague.snp.trailing).offset(6)
        make.centerY.top.bottom.trailing.equalToSuperview()
    }
    return container_bague
}

/// 创建设置分组卡片
private func makeSettingCard_Bague() -> UIView {
    let v = UIView()
    v.backgroundColor = .white
    v.layer.cornerRadius = 20
    v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
    v.layer.shadowOffset = CGSize(width: 0, height: 3)
    v.layer.shadowOpacity = 0.1
    v.layer.shadowRadius = 10
    return v
}

// MARK: - UILabel 字间距扩展

extension UILabel {
    /// 设置字间距
    func letterSpacing_Bague(spacing: CGFloat) {
        guard let text_bague = text else { return }
        let attrs_bague: [NSAttributedString.Key: Any] = [
            .kern: spacing,
            .font: font as Any,
            .foregroundColor: textColor as Any
        ]
        attributedText = NSAttributedString(string: text_bague, attributes: attrs_bague)
    }
}
