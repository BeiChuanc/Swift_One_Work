import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 核心作用：提供协议查看（条款/隐私）与账号操作（登出/删除）入口
/// 设计思路：渐变头部（与 Discover 同款） + 分组卡片式设置行（图标圆 + 标题 + 描述 + 箭头）
class Setting_Breeze: UIViewController {
    
    // MARK: - 设置行类型
    
    /// 设置项类型
    private enum SettingRow_Breeze {
        case terms_breeze
        case privacy_breeze
        case logout_breeze
        case delete_breeze
    }
    
    // MARK: - UI：渐变头部
    
    private let headerView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var headerGradient_Breeze: CAGradientLayer?
    
    private let decorLarge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_breeze.layer.cornerRadius = 65
        return v_breeze
    }()
    
    private let decorSmall_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_breeze.layer.cornerRadius = 35
        return v_breeze
    }()
    
    /// 返回按钮（白色圆形）
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 主标题
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Settings"
        label_breeze.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    /// 副标题
    private let subtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Manage your account & preferences"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        return label_breeze
    }()
    
    // MARK: - UI：滚动内容区
    
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsVerticalScrollIndicator = false
        sv_breeze.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        return sv_breeze
    }()
    
    private let contentStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .vertical
        stack_breeze.spacing = 12
        return stack_breeze
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeaderView_Breeze()
        setupScrollContent_Breeze()
    }
    
    /// 搭建渐变头部
    private func setupHeaderView_Breeze() {
        view.addSubview(headerView_Breeze)
        headerView_Breeze.addSubview(decorLarge_Breeze)
        headerView_Breeze.addSubview(decorSmall_Breeze)
        headerView_Breeze.addSubview(backButton_Breeze)
        headerView_Breeze.addSubview(titleLabel_Breeze)
        headerView_Breeze.addSubview(subtitleLabel_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        decorLarge_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.right.equalToSuperview().offset(34)
            make.top.equalToSuperview().offset(-24)
        }
        
        decorSmall_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.left.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(12)
        }
        
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(backButton_Breeze.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(22)
        }
        
        subtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(22)
            make.right.equalTo(decorLarge_Breeze.snp.left).offset(-8)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
    }
    
    private func refreshHeaderGradient_Breeze() {
        headerGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: headerView_Breeze.bounds)
        headerView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradient_Breeze = gradient_breeze
    }
    
    /// 搭建设置内容区（分组）
    private func setupScrollContent_Breeze() {
        view.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(contentStack_Breeze)
        
        scrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentStack_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        // Legal 组标题
        contentStack_Breeze.addArrangedSubview(makeSectionHeader_Breeze(text_breeze: "Legal"))
        
        // 协议行
        contentStack_Breeze.addArrangedSubview(buildSettingRow_Breeze(
            iconName_breeze: "doc.text.fill",
            iconBgColor_breeze: ColorConfig_Breeze.accentTeal_Breeze,
            title_breeze: "Terms of Service",
            description_breeze: "Read our terms and conditions",
            row_breeze: .terms_breeze,
            isDestructive_breeze: false
        ))
        contentStack_Breeze.addArrangedSubview(buildSettingRow_Breeze(
            iconName_breeze: "lock.shield.fill",
            iconBgColor_breeze: ColorConfig_Breeze.primaryGradientEnd_Breeze,
            title_breeze: "Privacy Policy",
            description_breeze: "Learn how we protect your data",
            row_breeze: .privacy_breeze,
            isDestructive_breeze: false
        ))
        
        // Account 组标题
        contentStack_Breeze.addArrangedSubview(makeSectionHeader_Breeze(text_breeze: "Account"))
        
        // 账号操作行
        contentStack_Breeze.addArrangedSubview(buildSettingRow_Breeze(
            iconName_breeze: "rectangle.portrait.and.arrow.right",
            iconBgColor_breeze: ColorConfig_Breeze.accentAmber_Breeze,
            title_breeze: "Log Out",
            description_breeze: "Sign out of your account",
            row_breeze: .logout_breeze,
            isDestructive_breeze: false
        ))
        contentStack_Breeze.addArrangedSubview(buildSettingRow_Breeze(
            iconName_breeze: "trash.fill",
            iconBgColor_breeze: ColorConfig_Breeze.accentCoral_Breeze,
            title_breeze: "Delete Account",
            description_breeze: "Permanently remove your account",
            row_breeze: .delete_breeze,
            isDestructive_breeze: true
        ))
    }
    
    // MARK: - 工厂方法
    
    /// 创建分组小标题
    private func makeSectionHeader_Breeze(text_breeze: String) -> UIView {
        let container_breeze = UIView()
        let label_breeze = UILabel()
        label_breeze.text = text_breeze.uppercased()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.letterSpacing_Breeze(spacing_breeze: 1.2)
        
        container_breeze.addSubview(label_breeze)
        label_breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-2)
        }
        return container_breeze
    }
    
    /// 构建单个设置行卡片
    /// - Parameters:
    ///   - iconName_breeze: SF Symbol 名称
    ///   - iconBgColor_breeze: 图标圆形背景色
    ///   - title_breeze: 设置项标题（英文）
    ///   - description_breeze: 副描述文字（英文）
    ///   - row_breeze: 对应设置行类型
    ///   - isDestructive_breeze: 是否为破坏性操作（红色标题）
    /// - Returns: 配置完整的 UIControl
    private func buildSettingRow_Breeze(
        iconName_breeze: String,
        iconBgColor_breeze: UIColor,
        title_breeze: String,
        description_breeze: String,
        row_breeze: SettingRow_Breeze,
        isDestructive_breeze: Bool
    ) -> UIView {
        let card_breeze = UIControl()
        card_breeze.backgroundColor = .white
        card_breeze.layer.cornerRadius = 18
        card_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        card_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_breeze.layer.shadowRadius = 10
        card_breeze.layer.shadowOpacity = 0.09
        card_breeze.snp.makeConstraints { make in make.height.equalTo(70) }
        
        // 图标圆形容器
        let iconCircle_breeze = UIView()
        iconCircle_breeze.backgroundColor = iconBgColor_breeze.withAlphaComponent(0.15)
        iconCircle_breeze.layer.cornerRadius = 22
        
        let iconView_breeze = UIImageView()
        let iconConfig_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView_breeze.image = UIImage(systemName: iconName_breeze, withConfiguration: iconConfig_breeze)
        iconView_breeze.tintColor = iconBgColor_breeze
        iconView_breeze.contentMode = .scaleAspectFit
        
        // 标题
        let titleLbl_breeze = UILabel()
        titleLbl_breeze.text = title_breeze
        titleLbl_breeze.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLbl_breeze.textColor = isDestructive_breeze
            ? ColorConfig_Breeze.accentCoral_Breeze
            : ColorConfig_Breeze.textPrimary_Breeze
        
        // 副描述
        let descLbl_breeze = UILabel()
        descLbl_breeze.text = description_breeze
        descLbl_breeze.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLbl_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        
        // 右侧箭头
        let chevron_breeze = UIImageView()
        let chevronConfig_breeze = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        chevron_breeze.image = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig_breeze)
        chevron_breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        chevron_breeze.contentMode = .scaleAspectFit
        
        card_breeze.addSubview(iconCircle_breeze)
        iconCircle_breeze.addSubview(iconView_breeze)
        card_breeze.addSubview(titleLbl_breeze)
        card_breeze.addSubview(descLbl_breeze)
        card_breeze.addSubview(chevron_breeze)
        
        iconCircle_breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        iconView_breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        chevron_breeze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        titleLbl_breeze.snp.makeConstraints { make in
            make.left.equalTo(iconCircle_breeze.snp.right).offset(14)
            make.top.equalToSuperview().offset(18)
            make.right.lessThanOrEqualTo(chevron_breeze.snp.left).offset(-8)
        }
        
        descLbl_breeze.snp.makeConstraints { make in
            make.left.equalTo(iconCircle_breeze.snp.right).offset(14)
            make.top.equalTo(titleLbl_breeze.snp.bottom).offset(3)
            make.right.lessThanOrEqualTo(chevron_breeze.snp.left).offset(-8)
        }
        
        card_breeze.addAction(UIAction { [weak self] _ in
            self?.handleRow_Breeze(row_breeze: row_breeze)
        }, for: .touchUpInside)
        
        return card_breeze
    }
    
    // MARK: - 事件
    
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 处理设置行点击
    private func handleRow_Breeze(row_breeze: SettingRow_Breeze) {
        switch row_breeze {
        case .terms_breeze:
            ProtocolHelper_Breeze.showProtocol_Breeze(
                type_Breeze: .terms_Breeze,
                content_Breeze: ProtocolConfig_Breeze.termsContent_Breeze,
                from: self
            )
        case .privacy_breeze:
            ProtocolHelper_Breeze.showProtocol_Breeze(
                type_Breeze: .privacy_Breeze,
                content_Breeze: ProtocolConfig_Breeze.privacyContent_Breeze,
                from: self
            )
        case .logout_breeze:
            UIAlertController.logout_Breeze {
                UserViewModel_Breeze.shared_Breeze.logout_Breeze(logoutType_breeze: .logout_breeze)
            }
        case .delete_breeze:
            UIAlertController.delete_Breeze {
                UserViewModel_Breeze.shared_Breeze.logout_Breeze(logoutType_breeze: .delete_breeze)
            }
        }
    }
}

// MARK: - UILabel 字距扩展（Setting 内部使用）

private extension UILabel {
    /// 设置字符间距
    func letterSpacing_Breeze(spacing_breeze: CGFloat) {
        guard let text_breeze = text else { return }
        let attrStr_breeze = NSMutableAttributedString(string: text_breeze)
        attrStr_breeze.addAttribute(
            .kern,
            value: spacing_breeze,
            range: NSRange(location: 0, length: attrStr_breeze.length - 1)
        )
        attributedText = attrStr_breeze
    }
}
