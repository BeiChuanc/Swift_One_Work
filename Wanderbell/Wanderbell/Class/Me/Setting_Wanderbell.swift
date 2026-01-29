import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 功能：服务条款、隐私政策、登出、删除账号
/// 设计：现代化卡片、清晰分组、警告样式
class Setting_Wanderbell: UIViewController {
    
    // MARK: - UI组件
    
    /// 页面标题
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Settings",
            subtitle_wanderbell: "Manage your account preferences",
            iconName_wanderbell: "gearshape.2.fill",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#9F7AEA")
        )
    }()
    
    /// 返回按钮
    private let backButton_Wanderbell = BackButton_Wanderbell()
    
    /// 内容容器
    private let contentView_Wanderbell = UIView()
    
    /// 法律信息组
    private let legalSection_Wanderbell = SettingSectionView_Wanderbell(title_wanderbell: "Legal")
    
    /// 账户操作组
    private let accountSection_Wanderbell = SettingSectionView_Wanderbell(title_wanderbell: "Account")
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupContent_Wanderbell()
        
        // 启动动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        // 设置渐变背景
        view.addProfileBackgroundGradient_Wanderbell()
        
        view.addSubview(backButton_Wanderbell)
        view.addSubview(pageTitleView_Wanderbell)
        view.addSubview(contentView_Wanderbell)
        
        contentView_Wanderbell.addSubview(legalSection_Wanderbell)
        contentView_Wanderbell.addSubview(accountSection_Wanderbell)
        
        // 设置返回按钮回调
        backButton_Wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.backTapped_Wanderbell()
        }
    }
    
    private func setupConstraints_Wanderbell() {
        backButton_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(44)
        }
        
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(backButton_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(90)
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        legalSection_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        accountSection_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(legalSection_Wanderbell.snp.bottom).offset(24)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupContent_Wanderbell() {
        // 法律信息组
        let termsItem_wanderbell = SettingItem_Wanderbell(
            icon_wanderbell: "doc.text",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#63B3ED"),
            title_wanderbell: "Terms of Service",
            subtitle_wanderbell: "Read our terms and conditions"
        )
        termsItem_wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.openTerms_Wanderbell()
        }
        
        let privacyItem_wanderbell = SettingItem_Wanderbell(
            icon_wanderbell: "lock.shield",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#48BB78"),
            title_wanderbell: "Privacy Policy",
            subtitle_wanderbell: "How we protect your data"
        )
        privacyItem_wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.openPrivacy_Wanderbell()
        }
        
        legalSection_Wanderbell.addItems_Wanderbell(items_wanderbell: [termsItem_wanderbell, privacyItem_wanderbell])
        
        // 账户操作组
        let logoutItem_wanderbell = SettingItem_Wanderbell(
            icon_wanderbell: "rectangle.portrait.and.arrow.right",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#F6AD55"),
            title_wanderbell: "Logout",
            subtitle_wanderbell: "Sign out from your account"
        )
        logoutItem_wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.showLogoutConfirmation_Wanderbell()
        }
        
        let deleteItem_wanderbell = SettingItem_Wanderbell(
            icon_wanderbell: "trash",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#FC8181"),
            title_wanderbell: "Delete Account",
            subtitle_wanderbell: "Permanently delete your account"
        )
        deleteItem_wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.showDeleteConfirmation_Wanderbell()
        }
        
        accountSection_Wanderbell.addItems_Wanderbell(items_wanderbell: [logoutItem_wanderbell, deleteItem_wanderbell])
    }
    
    // MARK: - 事件处理
    
    private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
    
    private func openTerms_Wanderbell() {
        ProtocolHelper_Wanderbell.showProtocol_Wanderbell(type_wanderbell: .terms_Wanderbell, content_wanderbell: "terms.png", from: self)
    }
    
    private func openPrivacy_Wanderbell() {
        ProtocolHelper_Wanderbell.showProtocol_Wanderbell(type_wanderbell: .terms_Wanderbell, content_wanderbell: "privacy.png", from: self)
    }
    
    private func showLogoutConfirmation_Wanderbell() {
        let alert_wanderbell = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert_wanderbell.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert_wanderbell.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout_Wanderbell()
        })
        
        present(alert_wanderbell, animated: true)
    }
    
    private func showDeleteConfirmation_Wanderbell() {
        let alert_wanderbell = UIAlertController(
            title: "Delete Account",
            message: "This action cannot be undone. Your account will be permanently deleted after 24 hours. Are you sure?",
            preferredStyle: .alert
        )
        
        alert_wanderbell.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert_wanderbell.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete_Wanderbell()
        })
        
        present(alert_wanderbell, animated: true)
    }
    
    private func performLogout_Wanderbell() {
        UserViewModel_Wanderbell.shared_Wanderbell.logout_Wanderbell(logoutType_wanderbell: .logout_wanderbell)
    }
    
    private func performDelete_Wanderbell() {
        UserViewModel_Wanderbell.shared_Wanderbell.logout_Wanderbell(logoutType_wanderbell: .delete_wanderbell)
    }
}

// MARK: - 设置分组视图

/// 设置分组视图
/// 功能：展示一组设置项
class SettingSectionView_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    private let stackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    init(title_wanderbell: String) {
        super.init(frame: .zero)
        titleLabel_Wanderbell.text = title_wanderbell.uppercased()
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(titleLabel_Wanderbell)
        addSubview(stackView_Wanderbell)
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        stackView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func addItems_Wanderbell(items_wanderbell: [SettingItem_Wanderbell]) {
        for item_wanderbell in items_wanderbell {
            stackView_Wanderbell.addArrangedSubview(item_wanderbell)
        }
    }
}

// MARK: - 设置项视图

/// 设置项视图
/// 功能：单个设置选项卡片
/// 设计：图标、标题、副标题、箭头、点击效果
class SettingItem_Wanderbell: UIView {
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.1
        return view_wanderbell
    }()
    
    private let iconContainer_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 12
        return view_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let subtitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 2
        return label_wanderbell
    }()
    
    private let arrowIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "chevron.right")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    var onTapped_Wanderbell: (() -> Void)?
    
    init(icon_wanderbell: String, iconColor_wanderbell: UIColor, title_wanderbell: String, subtitle_wanderbell: String) {
        super.init(frame: .zero)
        
        iconView_Wanderbell.image = UIImage(systemName: icon_wanderbell)
        iconView_Wanderbell.tintColor = iconColor_wanderbell
        iconContainer_Wanderbell.backgroundColor = iconColor_wanderbell.withAlphaComponent(0.15)
        titleLabel_Wanderbell.text = title_wanderbell
        subtitleLabel_Wanderbell.text = subtitle_wanderbell
        
        setupUI_Wanderbell()
        setupActions_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(iconContainer_Wanderbell)
        iconContainer_Wanderbell.addSubview(iconView_Wanderbell)
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(subtitleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(arrowIcon_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(80)
        }
        
        iconContainer_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconContainer_Wanderbell.snp.right).offset(16)
            make.top.equalToSuperview().offset(16)
            make.right.equalTo(arrowIcon_Wanderbell.snp.left).offset(-16)
        }
        
        subtitleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(4)
            make.right.equalTo(titleLabel_Wanderbell)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        arrowIcon_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    private func setupActions_Wanderbell() {
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(itemTapped_Wanderbell))
        containerView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    @objc private func itemTapped_Wanderbell() {
        // 按压动画
        containerView_Wanderbell.animatePressDown_Wanderbell {
            self.containerView_Wanderbell.animatePressUp_Wanderbell {
                self.onTapped_Wanderbell?()
            }
        }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
}
