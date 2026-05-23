import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面 ViewController
/// 功能：展示 Terms、Privacy、Logout、Delete Account 四项功能入口
/// 设计：现代卡片风格，渐变顶部装饰，分区卡片布局，带图标的操作行
/// 注意：登出/注销相关确认对话框和 VM 调用均在 VC 中完成（无独立 ViewModel）
class Setting_Hush: UIViewController {
    
    // MARK: - UI 组件
    
    /// 返回按钮
    private let backButton_Hush = BackButton_Hush()
    
    /// 顶部渐变装饰视图
    private let headerGradientView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.clipsToBounds = true
        return view_Hush
    }()
    
    /// 顶部渐变图层
    private var headerGradientLayer_Hush: CAGradientLayer?
    
    /// 页面标题标签
    private let titleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Settings"
        label_Hush.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_Hush.textColor = .white
        return label_Hush
    }()
    
    /// 副标题标签
    private let subtitleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Manage your account preferences"
        label_Hush.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_Hush.textColor = UIColor.white.withAlphaComponent(0.8)
        return label_Hush
    }()
    
    /// 主滚动容器
    private let scrollView_Hush: UIScrollView = {
        let sv_Hush = UIScrollView()
        sv_Hush.showsVerticalScrollIndicator = false
        sv_Hush.alwaysBounceVertical = true
        return sv_Hush
    }()
    
    /// 内容容器
    private let contentView_Hush: UIView = {
        let view_Hush = UIView()
        return view_Hush
    }()
    
    /// "关于" 分区卡片（Terms & Privacy）
    private let aboutCardView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        view_Hush.layer.cornerRadius = 16
        view_Hush.layer.shadowColor = ColorConfig_Hush.shadowColor_Hush.cgColor
        view_Hush.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Hush.layer.shadowRadius = 12
        view_Hush.layer.shadowOpacity = 1.0
        return view_Hush
    }()
    
    /// "账户" 分区卡片（Logout & Delete Account）
    private let accountCardView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        view_Hush.layer.cornerRadius = 16
        view_Hush.layer.shadowColor = ColorConfig_Hush.shadowColor_Hush.cgColor
        view_Hush.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Hush.layer.shadowRadius = 12
        view_Hush.layer.shadowOpacity = 1.0
        return view_Hush
    }()
    
    /// Terms of Service 行
    private lazy var termsRow_Hush: SettingRowView_Hush = {
        let row_Hush = SettingRowView_Hush(
            icon_Hush: "doc.text.fill",
            title_Hush: "Terms of Service",
            iconColor_Hush: ColorConfig_Hush.primaryGradientStart_Hush,
            showArrow_Hush: true
        )
        return row_Hush
    }()
    
    /// Privacy Policy 行
    private lazy var privacyRow_Hush: SettingRowView_Hush = {
        let row_Hush = SettingRowView_Hush(
            icon_Hush: "lock.shield.fill",
            title_Hush: "Privacy Policy",
            iconColor_Hush: ColorConfig_Hush.primaryGradientEnd_Hush,
            showArrow_Hush: true
        )
        return row_Hush
    }()
    
    /// 分割线（About 卡片内）
    private let aboutDivider_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.divider_Hush
        return view_Hush
    }()
    
    /// Logout 行
    private lazy var logoutRow_Hush: SettingRowView_Hush = {
        let row_Hush = SettingRowView_Hush(
            icon_Hush: "arrow.right.square.fill",
            title_Hush: "Sign Out",
            iconColor_Hush: UIColor(hexstring_Hush: "#F6AD55"),
            showArrow_Hush: false,
            titleColor_Hush: UIColor(hexstring_Hush: "#F6AD55")
        )
        return row_Hush
    }()
    
    /// 分割线（Account 卡片内）
    private let accountDivider_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.divider_Hush
        return view_Hush
    }()
    
    /// Delete Account 行
    private lazy var deleteRow_Hush: SettingRowView_Hush = {
        let row_Hush = SettingRowView_Hush(
            icon_Hush: "trash.fill",
            title_Hush: "Delete Account",
            iconColor_Hush: UIColor(hexstring_Hush: "#FC8181"),
            showArrow_Hush: false,
            titleColor_Hush: UIColor(hexstring_Hush: "#FC8181")
        )
        return row_Hush
    }()
    
    /// "About" 分区标题
    private let aboutSectionLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "ABOUT"
        label_Hush.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        label_Hush.letterSpacing_Hush(1.5)
        return label_Hush
    }()
    
    /// "Account" 分区标题
    private let accountSectionLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "ACCOUNT"
        label_Hush.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        label_Hush.letterSpacing_Hush(1.5)
        return label_Hush
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        setupActions_Hush()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变图层跟随布局更新
        headerGradientLayer_Hush?.frame = headerGradientView_Hush.bounds
    }
    
    // MARK: - UI 搭建
    
    /// 构建页面 UI
    private func setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        
        setupHeaderView_Hush()
        setupScrollContent_Hush()
        setupAnimations_Hush()
    }
    
    /// 搭建顶部渐变头部
    private func setupHeaderView_Hush() {
        view.addSubview(headerGradientView_Hush)
        headerGradientView_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        // 渐变图层
        let gradient_Hush = UIColor.createPrimaryGradientLayer_Hush(frame_Hush: .zero)
        gradient_Hush.cornerRadius = 0
        headerGradientLayer_Hush = gradient_Hush
        headerGradientView_Hush.layer.insertSublayer(gradient_Hush, at: 0)
        
        // 底部圆弧装饰
        headerGradientView_Hush.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerGradientView_Hush.layer.cornerRadius = 32
        
        // 返回按钮
        view.addSubview(backButton_Hush)
        backButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }
        
        // 页面标题
        headerGradientView_Hush.addSubview(titleLabel_Hush)
        titleLabel_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-36)
        }
        
        // 副标题
        headerGradientView_Hush.addSubview(subtitleLabel_Hush)
        subtitleLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Hush)
            make.top.equalTo(titleLabel_Hush.snp.bottom).offset(4)
        }
    }
    
    /// 搭建滚动内容区
    private func setupScrollContent_Hush() {
        view.addSubview(scrollView_Hush)
        scrollView_Hush.addSubview(contentView_Hush)
        
        scrollView_Hush.snp.makeConstraints { make in
            make.top.equalTo(headerGradientView_Hush.snp.bottom).offset(-16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // About 分区标题
        contentView_Hush.addSubview(aboutSectionLabel_Hush)
        aboutSectionLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalToSuperview().offset(24)
        }
        
        // About 卡片
        contentView_Hush.addSubview(aboutCardView_Hush)
        aboutCardView_Hush.snp.makeConstraints { make in
            make.top.equalTo(aboutSectionLabel_Hush.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        aboutCardView_Hush.addSubview(termsRow_Hush)
        aboutCardView_Hush.addSubview(aboutDivider_Hush)
        aboutCardView_Hush.addSubview(privacyRow_Hush)
        
        termsRow_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        aboutDivider_Hush.snp.makeConstraints { make in
            make.top.equalTo(termsRow_Hush.snp.bottom)
            make.leading.equalToSuperview().offset(56)
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        privacyRow_Hush.snp.makeConstraints { make in
            make.top.equalTo(aboutDivider_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        
        // Account 分区标题
        contentView_Hush.addSubview(accountSectionLabel_Hush)
        accountSectionLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(aboutCardView_Hush.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(24)
        }
        
        // Account 卡片
        contentView_Hush.addSubview(accountCardView_Hush)
        accountCardView_Hush.snp.makeConstraints { make in
            make.top.equalTo(accountSectionLabel_Hush.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        accountCardView_Hush.addSubview(logoutRow_Hush)
        accountCardView_Hush.addSubview(accountDivider_Hush)
        accountCardView_Hush.addSubview(deleteRow_Hush)
        
        logoutRow_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        accountDivider_Hush.snp.makeConstraints { make in
            make.top.equalTo(logoutRow_Hush.snp.bottom)
            make.leading.equalToSuperview().offset(56)
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        deleteRow_Hush.snp.makeConstraints { make in
            make.top.equalTo(accountDivider_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
    }
    
    /// 设置入场动画
    private func setupAnimations_Hush() {
        let cards_Hush = [aboutCardView_Hush, accountCardView_Hush]
        for (index_Hush, card_Hush) in cards_Hush.enumerated() {
            card_Hush.alpha = 0
            card_Hush.transform = CGAffineTransform(translationX: 0, y: 30)
            UIView.animate(
                withDuration: AnimationConfig_Hush.durationSpring_Hush,
                delay: Double(index_Hush) * 0.12,
                usingSpringWithDamping: AnimationConfig_Hush.springDampingNormal_Hush,
                initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
                options: [.curveEaseOut],
                animations: {
                    card_Hush.alpha = 1
                    card_Hush.transform = .identity
                }
            )
        }
    }
    
    // MARK: - 事件绑定
    
    /// 绑定各行点击事件
    private func setupActions_Hush() {
        termsRow_Hush.onTapped_Hush = { [weak self] in
            guard let self_Hush = self else { return }
            ProtocolHelper_Hush.showProtocol_Hush(
                type_Hush: .terms_Hush,
                content_Hush: "terms.png",
                from: self_Hush
            )
        }
        
        privacyRow_Hush.onTapped_Hush = { [weak self] in
            guard let self_Hush = self else { return }
            ProtocolHelper_Hush.showProtocol_Hush(
                type_Hush: .privacy_Hush,
                content_Hush: "privacy.png",
                from: self_Hush
            )
        }
        
        logoutRow_Hush.onTapped_Hush = { [weak self] in
            self?.showLogoutConfirm_Hush()
        }
        
        deleteRow_Hush.onTapped_Hush = { [weak self] in
            self?.showDeleteAccountConfirm_Hush()
        }
    }
    
    // MARK: - 确认对话框
    
    /// 展示普通退出确认 Alert
    private func showLogoutConfirm_Hush() {
        let alert_Hush = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        alert_Hush.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Hush.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            guard let self_Hush = self else { return }
            // 确认后执行退出登录
            Task { @MainActor in
                UserViewModel_Hush.shared_Hush.logout_Hush(logoutType_hush: .logout_hush)
            }
        })
        present(alert_Hush, animated: true)
    }
    
    /// 展示删除账号二次确认 Alert（高危操作）
    private func showDeleteAccountConfirm_Hush() {
        let alert_Hush = UIAlertController(
            title: "Delete Account",
            message: "This action is irreversible. Your account will be permanently deleted after 24 hours. Are you sure you want to continue?",
            preferredStyle: .alert
        )
        alert_Hush.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Hush.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self_Hush = self else { return }
            // 确认后执行账号注销
            Task { @MainActor in
                UserViewModel_Hush.shared_Hush.logout_Hush(logoutType_hush: .delete_hush)
            }
        })
        present(alert_Hush, animated: true)
    }
}

// MARK: - 设置行视图

/// 设置列表行组件
/// 功能：展示图标、标题和可选箭头，支持点击回调
private class SettingRowView_Hush: UIView {
    
    // MARK: - 回调
    
    var onTapped_Hush: (() -> Void)?
    
    // MARK: - UI 组件
    
    /// 图标背景视图（圆形彩色）
    private let iconBg_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.layer.cornerRadius = 10
        return view_Hush
    }()
    
    /// 图标
    private let iconView_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.contentMode = .scaleAspectFit
        iv_Hush.tintColor = .white
        return iv_Hush
    }()
    
    /// 标题标签
    private let titleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label_Hush
    }()
    
    /// 右侧箭头
    private let arrowView_Hush: UIImageView = {
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "chevron.right")
        iv_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        iv_Hush.contentMode = .scaleAspectFit
        return iv_Hush
    }()
    
    // MARK: - 初始化
    
    /// 初始化设置行
    /// - Parameters:
    ///   - icon_Hush: SF Symbol 图标名
    ///   - title_Hush: 行标题文本（英文）
    ///   - iconColor_Hush: 图标背景颜色
    ///   - showArrow_Hush: 是否显示右侧箭头
    ///   - titleColor_Hush: 标题文字颜色（默认主文本色）
    init(
        icon_Hush: String,
        title_Hush: String,
        iconColor_Hush: UIColor,
        showArrow_Hush: Bool,
        titleColor_Hush: UIColor = ColorConfig_Hush.textPrimary_Hush
    ) {
        super.init(frame: .zero)
        
        iconBg_Hush.backgroundColor = iconColor_Hush
        iconView_Hush.image = UIImage(systemName: icon_Hush)
        titleLabel_Hush.text = title_Hush
        titleLabel_Hush.textColor = titleColor_Hush
        arrowView_Hush.isHidden = !showArrow_Hush
        
        setupUI_Hush()
        setupGesture_Hush()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Hush() {
        addSubview(iconBg_Hush)
        iconBg_Hush.addSubview(iconView_Hush)
        addSubview(titleLabel_Hush)
        addSubview(arrowView_Hush)
        
        iconBg_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }
        iconView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        titleLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Hush.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
        }
        arrowView_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }
    }
    
    // MARK: - 手势
    
    private func setupGesture_Hush() {
        let tap_Hush = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        addGestureRecognizer(tap_Hush)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap_Hush() {
        // 点击反馈动画
        UIView.animate(withDuration: 0.08, animations: {
            self.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.08) {
                self.alpha = 1.0
            }
        }
        let generator_Hush = UIImpactFeedbackGenerator(style: .light)
        generator_Hush.impactOccurred()
        onTapped_Hush?()
    }
}

// MARK: - UILabel 字符间距扩展

private extension UILabel {
    
    /// 设置字符间距
    /// - Parameter spacing_Hush: 间距值（以点为单位）
    func letterSpacing_Hush(_ spacing_Hush: CGFloat) {
        if let currentText_Hush = text {
            let attrString_Hush = NSMutableAttributedString(string: currentText_Hush)
            attrString_Hush.addAttribute(
                .kern,
                value: spacing_Hush,
                range: NSRange(location: 0, length: currentText_Hush.count)
            )
            attributedText = attrString_Hush
        }
    }
}
