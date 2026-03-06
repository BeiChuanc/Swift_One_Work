import Foundation
import UIKit
import SnapKit

// MARK: - 设置行视图

/// 设置项行视图
/// 核心作用：展示单个设置项，含渐变图标区、主标题、副描述和右侧 chevron
/// 关键属性：onTapped_Trace（点击回调）
private class SettingRowView_Trace: UIView {

    // MARK: - UI 组件

    /// 图标渐变背景（圆角方形）
    private let iconContainer_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()

    private let iconGradientLayer_Trace = CAGradientLayer()

    private let iconView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    /// 文字区（标题 + 副标题）
    private let textStackView_Trace: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 3
        sv.alignment = .leading
        return sv
    }()

    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl
    }()

    private let subtitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        return lbl
    }()

    /// 右侧 chevron
    private let chevronView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    var onTapped_Trace: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconGradientLayer_Trace.frame = iconContainer_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        backgroundColor = .clear

        textStackView_Trace.addArrangedSubview(titleLabel_Trace)
        textStackView_Trace.addArrangedSubview(subtitleLabel_Trace)

        addSubview(iconContainer_Trace)
        iconContainer_Trace.layer.addSublayer(iconGradientLayer_Trace)
        iconContainer_Trace.addSubview(iconView_Trace)
        addSubview(textStackView_Trace)
        addSubview(chevronView_Trace)

        iconContainer_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }

        iconView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        chevronView_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.equalTo(9)
            make.height.equalTo(15)
        }

        textStackView_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer_Trace.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(chevronView_Trace.snp.leading).offset(-10)
        }

        let tap_trace = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        addGestureRecognizer(tap_trace)
        isUserInteractionEnabled = true
    }

    // MARK: - 公共方法

    /// 配置行内容
    /// - Parameters:
    ///   - title_trace: 主标题
    ///   - subtitle_trace: 副标题描述
    ///   - iconName_trace: SF Symbol 名称
    ///   - gradientStart_trace: 渐变起始色十六进制
    ///   - gradientEnd_trace: 渐变结束色十六进制
    func configure_Trace(
        title_trace: String,
        subtitle_trace: String = "",
        iconName_trace: String,
        gradientStart_trace: String,
        gradientEnd_trace: String
    ) {
        titleLabel_Trace.text = title_trace
        subtitleLabel_Trace.text = subtitle_trace
        subtitleLabel_Trace.isHidden = subtitle_trace.isEmpty

        let cfg_trace = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView_Trace.image = UIImage(systemName: iconName_trace, withConfiguration: cfg_trace)

        iconGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: gradientStart_trace).cgColor,
            UIColor(hexstring_Trace: gradientEnd_trace).cgColor
        ]
        iconGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        iconGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        iconGradientLayer_Trace.cornerRadius = 12
    }

    @objc private func handleTap_Trace() {
        animatePressDown_Trace {
            self.animatePressUp_Trace {
                self.onTapped_Trace?()
            }
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - 设置页面

/// 设置页面
/// 核心作用：提供使用条款/隐私查看、账户登出、账户注销入口
/// 设计思路：渐变头部（含副标题装饰）+ 分区卡片 + "Danger Zone" 警示区 + 底部版本信息
/// 关键方法：handleSignOut_Trace（登出确认），handleDeleteAccount_Trace（注销确认）
class Setting_Trace: UIViewController {

    // MARK: - UI 组件

    private let scrollView_Trace: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        return v
    }()

    // MARK: 头部

    private let headerView_Trace: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private let headerGradientLayer_Trace = CAGradientLayer()

    /// 装饰圆
    private let headerDecorCircle_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 80
        return v
    }()

    private let headerDecorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 55
        return v
    }()

    private let backButton_Trace = BackButton_Trace()

    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Settings"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    private let subtitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Manage your account & preferences"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.75)
        return lbl
    }()

    /// 头部大装饰图标（右侧淡显）
    private let headerIconView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 70, weight: .thin)
        iv.image = UIImage(systemName: "gearshape.2", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: 浮岛内容区

    private let contentIslandView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -4)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.05
        v.layer.masksToBounds = false
        return v
    }()

    // MARK: Legal 卡片

    private let legalSectionLabel_Trace: UILabel = buildSectionHeader_Trace(
        text: "  Legal",
        iconName: "shield.checkered",
        color: "#B794F6"
    )

    private let legalCardView_Trace: UIView = buildCard_Trace()

    private let termsRow_Trace = SettingRowView_Trace()
    private let privacyRow_Trace = SettingRowView_Trace()

    private let rowDivider_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    // MARK: Danger Zone 卡片

    private let dangerSectionView_Trace: UIView = {
        let v = UIView()
        return v
    }()

    private let dangerIconView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        iv.image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Trace: "#E53E3E")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let dangerTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Danger Zone"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = UIColor(hexstring_Trace: "#E53E3E")
        return lbl
    }()

    private let dangerCardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.borderColor = UIColor(hexstring_Trace: "#FC8181").withAlphaComponent(0.25).cgColor
        v.layer.borderWidth = 1
        v.layer.shadowColor = UIColor(hexstring_Trace: "#FC8181").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.08
        v.layer.masksToBounds = false
        return v
    }()

    /// Log Out 按钮（渐变填充，内容通过子视图居中，避免 imageEdgeInsets 偏移问题）
    private let signOutButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        return btn
    }()

    private let signOutGradientLayer_Trace = CAGradientLayer()

    /// Delete Account 按钮（红色）
    private let deleteAccountButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(hexstring_Trace: "#FFF5F5")
        btn.layer.cornerRadius = 16
        btn.layer.borderColor = UIColor(hexstring_Trace: "#FC8181").withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 1.5
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "person.crop.circle.badge.minus", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(hexstring_Trace: "#E53E3E")
        btn.setTitle("  Delete Account", for: .normal)
        btn.setTitleColor(UIColor(hexstring_Trace: "#E53E3E"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return btn
    }()

    // MARK: 底部版本信息

    private let footerView_Trace: UIView = UIView()

    private let footerIconView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
        iv.image = UIImage(systemName: "sparkles", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let footerNoteLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Account deletion takes effect after 24 hours."
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    private let versionLabel_Trace: UILabel = {
        let lbl = UILabel()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        lbl.text = "Trace v\(appVersion)"
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace.withAlphaComponent(0.7)
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: 辅助：静态工厂

    /// 构建分区标题视图（带图标）
    private static func buildSectionHeader_Trace(text: String, iconName: String, color: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = UIColor(hexstring_Trace: color)
        return lbl
    }

    /// 构建卡片容器
    private static func buildCard_Trace() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.06
        v.layer.masksToBounds = false
        return v
    }

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        configureRows_Trace()
        bindActions_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Trace.frame = headerView_Trace.bounds
        signOutGradientLayer_Trace.frame = signOutButton_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace

        // 头部渐变（紫 → 玫瑰粉）
        headerGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#F6A0C0").cgColor
        ]
        headerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        headerView_Trace.layer.insertSublayer(headerGradientLayer_Trace, at: 0)

        // Sign Out 渐变层
        signOutGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#90CDF4").cgColor
        ]
        signOutGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0.5)
        signOutGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 0.5)
        signOutGradientLayer_Trace.cornerRadius = 16
        signOutButton_Trace.layer.insertSublayer(signOutGradientLayer_Trace, at: 0)

        // 通过 UIStackView 子视图实现图标+文本严格居中（规避 imageEdgeInsets 在 iOS15+ 的偏移问题）
        let signOutIconCfg_Trace = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let signOutIconIV_Trace = UIImageView(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right",
                           withConfiguration: signOutIconCfg_Trace)
        )
        signOutIconIV_Trace.tintColor = .white
        signOutIconIV_Trace.contentMode = .scaleAspectFit
        signOutIconIV_Trace.isUserInteractionEnabled = false

        let signOutTitleLbl_Trace = UILabel()
        signOutTitleLbl_Trace.text = "Log Out"
        signOutTitleLbl_Trace.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        signOutTitleLbl_Trace.textColor = .white
        signOutTitleLbl_Trace.isUserInteractionEnabled = false

        let signOutStack_Trace = UIStackView(arrangedSubviews: [signOutIconIV_Trace, signOutTitleLbl_Trace])
        signOutStack_Trace.axis = .horizontal
        signOutStack_Trace.spacing = 8
        signOutStack_Trace.alignment = .center
        signOutStack_Trace.isUserInteractionEnabled = false
        signOutButton_Trace.addSubview(signOutStack_Trace)
        signOutStack_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 层级组装
        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)

        contentView_Trace.addSubview(headerView_Trace)
        headerView_Trace.addSubview(headerDecorCircle_Trace)
        headerView_Trace.addSubview(headerDecorCircle2_Trace)
        headerView_Trace.addSubview(headerIconView_Trace)
        headerView_Trace.addSubview(backButton_Trace)
        headerView_Trace.addSubview(titleLabel_Trace)
        headerView_Trace.addSubview(subtitleLabel_Trace)

        // 浮岛内容区
        contentView_Trace.addSubview(contentIslandView_Trace)

        contentIslandView_Trace.addSubview(legalSectionLabel_Trace)
        contentIslandView_Trace.addSubview(legalCardView_Trace)
        legalCardView_Trace.addSubview(termsRow_Trace)
        legalCardView_Trace.addSubview(rowDivider_Trace)
        legalCardView_Trace.addSubview(privacyRow_Trace)

        contentIslandView_Trace.addSubview(dangerSectionView_Trace)
        dangerSectionView_Trace.addSubview(dangerIconView_Trace)
        dangerSectionView_Trace.addSubview(dangerTitleLabel_Trace)

        contentIslandView_Trace.addSubview(dangerCardView_Trace)
        dangerCardView_Trace.addSubview(signOutButton_Trace)
        dangerCardView_Trace.addSubview(deleteAccountButton_Trace)

        contentIslandView_Trace.addSubview(footerView_Trace)
        footerView_Trace.addSubview(footerIconView_Trace)
        footerView_Trace.addSubview(footerNoteLabel_Trace)
        footerView_Trace.addSubview(versionLabel_Trace)

        buildConstraints_Trace()
    }

    private func buildConstraints_Trace() {
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 头部底边 = 安全区顶部 + 110pt，覆盖安全区高度差异，确保副标题不被浮岛遮盖
        headerView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(110)
        }

        headerDecorCircle_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(50)
            make.width.height.equalTo(160)
        }

        headerDecorCircle2_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(-30)
            make.width.height.equalTo(110)
        }

        headerIconView_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(100)
        }

        backButton_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.width.height.equalTo(44)
        }

        titleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(backButton_Trace.snp.trailing).offset(10)
            make.centerY.equalTo(backButton_Trace)
        }

        subtitleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Trace)
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(3)
        }

        // 浮岛
        contentIslandView_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerView_Trace.snp.bottom).offset(-24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // Legal 分区
        legalSectionLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(22)
        }

        legalCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(legalSectionLabel_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        termsRow_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
        }

        rowDivider_Trace.snp.makeConstraints { make in
            make.top.equalTo(termsRow_Trace.snp.bottom)
            make.leading.equalToSuperview().offset(74)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }

        privacyRow_Trace.snp.makeConstraints { make in
            make.top.equalTo(rowDivider_Trace.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
            make.bottom.equalToSuperview()
        }

        // Danger Zone 分区
        dangerSectionView_Trace.snp.makeConstraints { make in
            make.top.equalTo(legalCardView_Trace.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(22)
            make.height.equalTo(18)
        }

        dangerIconView_Trace.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        dangerTitleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(dangerIconView_Trace.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        dangerCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(dangerSectionView_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        signOutButton_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }

        deleteAccountButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(signOutButton_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 底部信息
        footerView_Trace.snp.makeConstraints { make in
            make.top.equalTo(dangerCardView_Trace.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-40)
        }

        footerIconView_Trace.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(22)
        }

        footerNoteLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(footerIconView_Trace.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        versionLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(footerNoteLabel_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 行配置

    private func configureRows_Trace() {
        termsRow_Trace.configure_Trace(
            title_trace: "Terms of Service",
            subtitle_trace: "View our usage guidelines",
            iconName_trace: "doc.text.fill",
            gradientStart_trace: "#B794F6",
            gradientEnd_trace: "#90CDF4"
        )
        termsRow_Trace.onTapped_Trace = { [weak self] in
            self?.showTerms_Trace()
        }

        privacyRow_Trace.configure_Trace(
            title_trace: "Privacy Policy",
            subtitle_trace: "Learn how we handle your data",
            iconName_trace: "lock.shield.fill",
            gradientStart_trace: "#FBB6CE",
            gradientEnd_trace: "#FED7AA"
        )
        privacyRow_Trace.onTapped_Trace = { [weak self] in
            self?.showPrivacy_Trace()
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        backButton_Trace.onTapped_Trace = {
            Navigation_Trace.pop_Trace()
        }
        signOutButton_Trace.addTarget(self, action: #selector(handleSignOut_Trace), for: .touchUpInside)
        deleteAccountButton_Trace.addTarget(self, action: #selector(handleDeleteAccount_Trace), for: .touchUpInside)
    }

    // MARK: - 协议展示

    private func showTerms_Trace() {
        ProtocolHelper_Trace.showProtocol_Trace(
            type_Trace: .terms_Trace,
            content_Trace: "terms.png",
            from: self
        )
    }

    private func showPrivacy_Trace() {
        ProtocolHelper_Trace.showProtocol_Trace(
            type_Trace: .privacy_Trace,
            content_Trace: "privacy.png",
            from: self
        )
    }

    // MARK: - 账户操作

    @objc private func handleSignOut_Trace() {
        signOutButton_Trace.animatePressDown_Trace {
            self.signOutButton_Trace.animatePressUp_Trace()
        }
        let alert_trace = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_trace.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_trace.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            UserViewModel_Trace.shared_Trace.logout_Trace(logoutType_trace: .logout_trace)
        })
        present(alert_trace, animated: true)
    }

    @objc private func handleDeleteAccount_Trace() {
        deleteAccountButton_Trace.animatePressDown_Trace {
            self.deleteAccountButton_Trace.animatePressUp_Trace()
        }
        let alert_trace = UIAlertController(
            title: "Delete Account",
            message: "Your account will be permanently deleted after 24 hours. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert_trace.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_trace.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            UserViewModel_Trace.shared_Trace.logout_Trace(logoutType_trace: .delete_trace)
        })
        present(alert_trace, animated: true)
    }
}
