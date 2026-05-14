import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 核心作用：承载协议查看、登出和删除账号操作
/// 设计思路：顶部描述卡 + 分组列表（文档组 / 账号组），每行含图标、标题和箭头；
///          危险操作（登出、删除）使用暖橙和警示红差异化样式
class Setting_Epoch: UIViewController {

    // MARK: - 视图

    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    private let scrollView_Epoch: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Epoch = UIView()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
    }

    // MARK: - 界面搭建

    private func setupUI_Epoch() {
        title = "Settings"
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Epoch)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Epoch.textPrimary_Epoch

        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }

        setupHeaderCard_Epoch()
        setupDocumentSection_Epoch()
        setupAccountSection_Epoch()
    }

    /// 顶部描述卡片
    private func setupHeaderCard_Epoch() {
        let headerCard_epoch = SurfaceCardView_Epoch()
        headerCard_epoch.clipsToBounds = true

        // 装饰光斑
        let glowTop_epoch = UIView()
        glowTop_epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.18)
        glowTop_epoch.layer.cornerRadius = 56
        glowTop_epoch.isUserInteractionEnabled = false

        let glowBottom_epoch = UIView()
        glowBottom_epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.14)
        glowBottom_epoch.layer.cornerRadius = 48
        glowBottom_epoch.isUserInteractionEnabled = false

        // 图标背景
        let iconBg_epoch = UIView()
        iconBg_epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch.withAlphaComponent(0.14)
        iconBg_epoch.layer.cornerRadius = 22

        let iconView_epoch = UIImageView(image: UIImage(systemName: "gearshape.2.fill"))
        iconView_epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iconView_epoch.contentMode = .scaleAspectFit

        // 文字角标
        let badgeLabel_epoch = PaddingLabel_Epoch()
        badgeLabel_epoch.text = "SETTINGS"
        badgeLabel_epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        badgeLabel_epoch.textColor = ColorConfig_Epoch.textOnDark_Epoch
        badgeLabel_epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        badgeLabel_epoch.layer.cornerRadius = 12
        badgeLabel_epoch.clipsToBounds = true
        badgeLabel_epoch.horizontalInset_Epoch = 10
        badgeLabel_epoch.verticalInset_Epoch = 6

        let titleLabel_epoch = UILabel()
        titleLabel_epoch.text = "App preferences"
        titleLabel_epoch.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel_epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        titleLabel_epoch.numberOfLines = 0

        let subtitleLabel_epoch = UILabel()
        subtitleLabel_epoch.text = "Review your documents, manage your account or sign out from this device."
        subtitleLabel_epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel_epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        subtitleLabel_epoch.numberOfLines = 0

        let textStack_epoch = UIStackView(arrangedSubviews: [badgeLabel_epoch, titleLabel_epoch, subtitleLabel_epoch])
        textStack_epoch.axis = .vertical
        textStack_epoch.spacing = 8
        textStack_epoch.alignment = .leading

        contentView_Epoch.addSubview(headerCard_epoch)
        headerCard_epoch.addSubview(glowTop_epoch)
        headerCard_epoch.addSubview(glowBottom_epoch)
        headerCard_epoch.addSubview(iconBg_epoch)
        iconBg_epoch.addSubview(iconView_epoch)
        headerCard_epoch.addSubview(textStack_epoch)

        headerCard_epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.right.equalToSuperview().inset(20)
        }

        glowTop_epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-28)
            make.right.equalToSuperview().offset(28)
            make.width.height.equalTo(112)
        }

        glowBottom_epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(-28)
            make.width.height.equalTo(96)
        }

        iconBg_epoch.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.width.height.equalTo(44)
        }

        iconView_epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        textStack_epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(22)
            make.right.lessThanOrEqualTo(iconBg_epoch.snp.left).offset(-10)
            make.bottom.equalToSuperview().offset(-22)
        }
    }

    /// 文档分组（Terms、Privacy）
    private func setupDocumentSection_Epoch() {
        let sectionHeader_epoch = SettingSectionHeaderView_Epoch()
        sectionHeader_epoch.configure_Epoch(
            iconName_Epoch: "doc.text.fill",
            title_Epoch: "Documents"
        )
        contentView_Epoch.addSubview(sectionHeader_epoch)

        // 找到 headerCard 的底部（通过约束）
        sectionHeader_epoch.snp.makeConstraints { make in
            // 动态依附 headerCard 底部，使用 tag 方式找到它
            if let headerCard = contentView_Epoch.subviews.first(where: { $0 is SurfaceCardView_Epoch }) {
                make.top.equalTo(headerCard.snp.bottom).offset(28)
            } else {
                make.top.equalToSuperview().offset(160)
            }
            make.left.right.equalToSuperview().inset(20)
        }

        let docItems_epoch: [(String, String, Selector)] = [
            ("doc.plaintext", "Terms of Service", #selector(termsTapped_Epoch)),
            ("hand.raised.fill", "Privacy Policy", #selector(privacyTapped_Epoch))
        ]

        var prevAnchor = sectionHeader_epoch.snp.bottom

        docItems_epoch.forEach { icon_epoch, title_epoch, action_epoch in
            let row_epoch = SettingRowView_Epoch()
            row_epoch.configure_Epoch(
                iconName_Epoch: icon_epoch,
                title_Epoch: title_epoch,
                style_Epoch: .normal
            )
            contentView_Epoch.addSubview(row_epoch)
            let tapGesture_epoch = SettingRowTapGesture_Epoch(target: self, action: action_epoch)
            row_epoch.addGestureRecognizer(tapGesture_epoch)
            row_epoch.isUserInteractionEnabled = true
            row_epoch.snp.makeConstraints { make in
                make.top.equalTo(prevAnchor).offset(10)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(62)
            }
            prevAnchor = row_epoch.snp.bottom
        }

        // 记录文档区最后一行，用于账号区顶部约束
        if let lastRow_epoch = contentView_Epoch.subviews.last {
            let accountHeader_epoch = SettingSectionHeaderView_Epoch()
            accountHeader_epoch.configure_Epoch(
                iconName_Epoch: "person.crop.circle.fill",
                title_Epoch: "Account"
            )
            contentView_Epoch.addSubview(accountHeader_epoch)
            accountHeader_epoch.snp.makeConstraints { make in
                make.top.equalTo(lastRow_epoch.snp.bottom).offset(28)
                make.left.right.equalToSuperview().inset(20)
            }

            let accountItems_epoch: [(String, String, Selector, SettingRowStyle_Epoch)] = [
                ("rectangle.portrait.and.arrow.right", "Log out", #selector(logoutTapped_Epoch), .warning),
                ("trash.fill", "Delete account", #selector(deleteTapped_Epoch), .destructive)
            ]

            var prevAccAnchor = accountHeader_epoch.snp.bottom

            accountItems_epoch.forEach { icon_epoch, title_epoch, action_epoch, style_epoch in
                let row_epoch = SettingRowView_Epoch()
                row_epoch.configure_Epoch(
                    iconName_Epoch: icon_epoch,
                    title_Epoch: title_epoch,
                    style_Epoch: style_epoch
                )
                contentView_Epoch.addSubview(row_epoch)
                let tapGesture_epoch = SettingRowTapGesture_Epoch(target: self, action: action_epoch)
                row_epoch.addGestureRecognizer(tapGesture_epoch)
                row_epoch.isUserInteractionEnabled = true
                row_epoch.snp.makeConstraints { make in
                    make.top.equalTo(prevAccAnchor).offset(10)
                    make.left.right.equalToSuperview().inset(20)
                    make.height.equalTo(62)
                    if action_epoch == #selector(deleteTapped_Epoch) {
                        make.bottom.equalToSuperview().offset(-100)
                    }
                }
                prevAccAnchor = row_epoch.snp.bottom
            }
        }
    }

    /// 账号分组由 setupDocumentSection 内联完成，此方法保留为占位
    private func setupAccountSection_Epoch() {}

    // MARK: - 协议展示

    private func showProtocol_Epoch(type_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch) {
        let content_epoch: String
        switch type_Epoch {
        case .terms_Epoch:
            content_epoch = "terms.png"
        case .privacy_Epoch:
            content_epoch = "privacy.png"
        case .eula_Epoch:
            content_epoch = "This end user license explains access conditions and acceptable usage."
        case .custom_Epoch(let title_epoch):
            content_epoch = title_epoch
        }
        ProtocolHelper_Epoch.showProtocol_Epoch(type_Epoch: type_Epoch, content_Epoch: content_epoch, from: self)
    }

    // MARK: - @objc 动作

    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch()
    }

    @objc private func termsTapped_Epoch() {
        showProtocol_Epoch(type_Epoch: .terms_Epoch)
    }

    @objc private func privacyTapped_Epoch() {
        showProtocol_Epoch(type_Epoch: .privacy_Epoch)
    }

    @objc private func logoutTapped_Epoch() {
        UIAlertController.logout_Epoch {
            UserViewModel_Epoch.shared_Epoch.logout_Epoch(logoutType_epoch: .logout_epoch)
        }
    }

    @objc private func deleteTapped_Epoch() {
        UIAlertController.delete_Epoch {
            UserViewModel_Epoch.shared_Epoch.logout_Epoch(logoutType_epoch: .delete_epoch)
        }
    }
}

// MARK: - 行点击手势（携带 action 的 UITapGestureRecognizer 子类）

/// 携带自定义 action 的点击手势
/// 核心作用：让 SettingRowView 支持附加指定 Selector，不破坏 UIButton 内嵌逻辑
private final class SettingRowTapGesture_Epoch: UITapGestureRecognizer {}

// MARK: - 分组头部

/// 设置页分组头部
/// 核心作用：展示图标和分组名，区分文档区和账号区
/// 设计思路：图标背景圆块 + 粗标题，与其他页面风格统一
private final class SettingSectionHeaderView_Epoch: UIView {

    private let iconBgView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        v.layer.cornerRadius = 14
        return v
    }()

    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        return iv
    }()

    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconBgView_Epoch)
        iconBgView_Epoch.addSubview(iconImageView_Epoch)
        addSubview(titleLabel_Epoch)

        iconBgView_Epoch.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(13)
        }
        titleLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(iconBgView_Epoch.snp.right).offset(8)
            make.top.bottom.right.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置分组头部
    /// - Parameters:
    ///   - iconName_Epoch: 图标名称
    ///   - title_Epoch: 分组名称
    func configure_Epoch(iconName_Epoch: String, title_Epoch: String) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        titleLabel_Epoch.text = title_Epoch.uppercased()
    }
}

// MARK: - 行样式枚举

/// 设置行的视觉样式
enum SettingRowStyle_Epoch {
    /// 普通样式
    case normal
    /// 警告样式（登出，橙色）
    case warning
    /// 危险样式（删除，红色）
    case destructive
}

// MARK: - 设置行视图

/// 设置列表单行视图
/// 核心作用：展示图标、标题和右侧箭头，支持三种样式：普通 / 警告 / 危险
/// 设计思路：左侧图标背景 + 标题 + 右侧 chevron，卡片式浮层增强层次感
private final class SettingRowView_Epoch: UIView {

    private let cardView_Epoch = SurfaceCardView_Epoch()

    private let iconBgView_Epoch: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        return v
    }()

    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return l
    }()

    private let arrowView_Epoch: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Epoch.textPlaceholder_Epoch
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置行内容和样式
    /// - Parameters:
    ///   - iconName_Epoch: 图标名称
    ///   - title_Epoch: 标题
    ///   - style_Epoch: 行样式
    func configure_Epoch(iconName_Epoch: String, title_Epoch: String, style_Epoch: SettingRowStyle_Epoch) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)

        switch style_Epoch {
        case .normal:
            iconBgView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
            iconImageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
            titleLabel_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        case .warning:
            iconBgView_Epoch.backgroundColor = ColorConfig_Epoch.accentGold_Epoch.withAlphaComponent(0.14)
            iconImageView_Epoch.tintColor = ColorConfig_Epoch.accentGold_Epoch
            titleLabel_Epoch.textColor = ColorConfig_Epoch.accentGold_Epoch
        case .destructive:
            iconBgView_Epoch.backgroundColor = ColorConfig_Epoch.accentPink_Epoch.withAlphaComponent(0.12)
            iconImageView_Epoch.tintColor = ColorConfig_Epoch.accentPink_Epoch
            titleLabel_Epoch.textColor = ColorConfig_Epoch.accentPink_Epoch
        }

        titleLabel_Epoch.text = title_Epoch
    }

    private func setupUI_Epoch() {
        addSubview(cardView_Epoch)
        cardView_Epoch.addSubview(iconBgView_Epoch)
        iconBgView_Epoch.addSubview(iconImageView_Epoch)
        cardView_Epoch.addSubview(titleLabel_Epoch)
        cardView_Epoch.addSubview(arrowView_Epoch)

        cardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconBgView_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(iconBgView_Epoch.snp.right).offset(14)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(arrowView_Epoch.snp.left).offset(-8)
        }

        arrowView_Epoch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(14)
        }
    }
}
