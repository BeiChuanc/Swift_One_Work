import Foundation
import UIKit
import SnapKit

// MARK: 设置

/// 设置页面
/// 功能：展示服务条款、隐私政策、登出和删除账号选项
/// 设计：现代化设置界面，简洁清晰的操作项
class Setting_Glasspaint: UIViewController {
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle_Glasspaint = UIView()
    
    // 协议区域
    private let protocolContainer_Glasspaint = UIView()
    private let termsButton_Glasspaint = UIButton(type: .system)
    private let privacyButton_Glasspaint = UIButton(type: .system)
    
    // 账号操作区域
    private let accountContainer_Glasspaint = UIView()
    private let logoutButton_Glasspaint = UIButton(type: .system)
    private let deleteAccountButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        title = "Settings"
        
        // 设置返回按钮
        setupNavigationBar_Glasspaint()
        
        // 背景渐变
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 协议区域
        contentView_Glasspaint.addSubview(protocolContainer_Glasspaint)
        setupProtocolSection_Glasspaint()
        
        // 账号操作区域
        contentView_Glasspaint.addSubview(accountContainer_Glasspaint)
        setupAccountSection_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        let backButton_glasspaint = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackTap_Glasspaint)
        )
        backButton_glasspaint.tintColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        navigationItem.leftBarButtonItem = backButton_glasspaint
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#F0F4F8").cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        view.addSubview(decorCircle_Glasspaint)
        decorCircle_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle_Glasspaint.layer.cornerRadius = 120
        
        decorCircle_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.right.equalToSuperview().offset(60)
            make.width.height.equalTo(240)
        }
        
        // 旋转动画
        let rotation_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation_glasspaint.fromValue = 0
        rotation_glasspaint.toValue = Double.pi * 2
        rotation_glasspaint.duration = 60
        rotation_glasspaint.repeatCount = .infinity
        decorCircle_Glasspaint.layer.add(rotation_glasspaint, forKey: "rotation")
    }
    
    /// 设置协议区域
    private func setupProtocolSection_Glasspaint() {
        protocolContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        protocolContainer_Glasspaint.layer.cornerRadius = 20
        protocolContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        protocolContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        protocolContainer_Glasspaint.layer.shadowRadius = 12
        protocolContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // Terms按钮
        protocolContainer_Glasspaint.addSubview(termsButton_Glasspaint)
        setupSettingButton_Glasspaint(
            button: termsButton_Glasspaint,
            icon: "doc.text.fill",
            title: "Terms of Service",
            subtitle: "Read our terms and conditions",
            action: #selector(handleTermsTap_Glasspaint)
        )
        
        // 分隔线
        let divider_glasspaint = UIView()
        protocolContainer_Glasspaint.addSubview(divider_glasspaint)
        divider_glasspaint.backgroundColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.1)
        
        // Privacy按钮
        protocolContainer_Glasspaint.addSubview(privacyButton_Glasspaint)
        setupSettingButton_Glasspaint(
            button: privacyButton_Glasspaint,
            icon: "lock.shield.fill",
            title: "Privacy Policy",
            subtitle: "Learn how we protect your data",
            action: #selector(handlePrivacyTap_Glasspaint)
        )
        
        // 布局
        termsButton_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        divider_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(termsButton_Glasspaint.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        privacyButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(divider_glasspaint.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置账号操作区域
    private func setupAccountSection_Glasspaint() {
        accountContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        accountContainer_Glasspaint.layer.cornerRadius = 20
        accountContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        accountContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        accountContainer_Glasspaint.layer.shadowRadius = 12
        accountContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 登出按钮
        accountContainer_Glasspaint.addSubview(logoutButton_Glasspaint)
        logoutButton_Glasspaint.setTitle("Log Out", for: .normal)
        logoutButton_Glasspaint.setTitleColor(.white, for: .normal)
        logoutButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        logoutButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        logoutButton_Glasspaint.layer.cornerRadius = 16
        logoutButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        logoutButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        logoutButton_Glasspaint.layer.shadowRadius = 10
        logoutButton_Glasspaint.layer.shadowOpacity = 0.3
        logoutButton_Glasspaint.addTarget(self, action: #selector(handleLogoutTap_Glasspaint), for: .touchUpInside)
        
        // 删除账号按钮
        accountContainer_Glasspaint.addSubview(deleteAccountButton_Glasspaint)
        deleteAccountButton_Glasspaint.setTitle("Delete Account", for: .normal)
        deleteAccountButton_Glasspaint.setTitleColor(.white, for: .normal)
        deleteAccountButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        deleteAccountButton_Glasspaint.backgroundColor = UIColor.systemRed
        deleteAccountButton_Glasspaint.layer.cornerRadius = 16
        deleteAccountButton_Glasspaint.layer.shadowColor = UIColor.systemRed.cgColor
        deleteAccountButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        deleteAccountButton_Glasspaint.layer.shadowRadius = 10
        deleteAccountButton_Glasspaint.layer.shadowOpacity = 0.3
        deleteAccountButton_Glasspaint.addTarget(self, action: #selector(handleDeleteAccountTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        logoutButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        deleteAccountButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(logoutButton_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    /// 设置通用按钮样式
    /// 参数：
    /// - button: 按钮
    /// - icon: 图标名称
    /// - title: 标题
    /// - subtitle: 副标题
    /// - action: 点击事件
    private func setupSettingButton_Glasspaint(
        button: UIButton,
        icon: String,
        title: String,
        subtitle: String,
        action: Selector
    ) {
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // 图标
        let iconView_glasspaint = UIImageView()
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        iconView_glasspaint.image = UIImage(systemName: icon, withConfiguration: iconConfig_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        button.addSubview(iconView_glasspaint)
        
        // 标题
        let titleLabel_glasspaint = UILabel()
        titleLabel_glasspaint.text = title
        titleLabel_glasspaint.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        button.addSubview(titleLabel_glasspaint)
        
        // 副标题
        let subtitleLabel_glasspaint = UILabel()
        subtitleLabel_glasspaint.text = subtitle
        subtitleLabel_glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel_glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        button.addSubview(subtitleLabel_glasspaint)
        
        // 箭头
        let arrowView_glasspaint = UIImageView()
        let arrowConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        arrowView_glasspaint.image = UIImage(systemName: "chevron.right", withConfiguration: arrowConfig_glasspaint)
        arrowView_glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.5)
        arrowView_glasspaint.contentMode = .scaleAspectFit
        button.addSubview(arrowView_glasspaint)
        
        // 布局
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        titleLabel_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(16)
            make.top.equalToSuperview().offset(20)
            make.right.equalTo(arrowView_glasspaint.snp.left).offset(-12)
        }
        
        subtitleLabel_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_glasspaint)
            make.top.equalTo(titleLabel_glasspaint.snp.bottom).offset(4)
            make.right.equalTo(titleLabel_glasspaint)
        }
        
        arrowView_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 协议区域
        protocolContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 账号操作区域
        accountContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(protocolContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    /// 返回
    @objc private func handleBackTap_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 查看服务条款
    @objc private func handleTermsTap_Glasspaint() {
        ProtocolHelper_Glasspaint.showProtocol_Glasspaint(
            type_Glasspaint: .terms_Glasspaint,
            content_Glasspaint: "terms.png",
            from: self
        )
    }
    
    /// 查看隐私政策
    @objc private func handlePrivacyTap_Glasspaint() {
        ProtocolHelper_Glasspaint.showProtocol_Glasspaint(
            type_Glasspaint: .privacy_Glasspaint,
            content_Glasspaint: "privacy.png",
            from: self
        )
    }
    
    /// 登出
    @objc private func handleLogoutTap_Glasspaint() {
        let alert_glasspaint = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert_glasspaint.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_glasspaint.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout_Glasspaint()
        })
        
        present(alert_glasspaint, animated: true)
    }
    
    /// 执行登出
    private func performLogout_Glasspaint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UserViewModel_Glasspaint.shared_Glasspaint.logout_Glasspaint(logoutType_glasspaint: .logout_glasspaint)
        }
    }
    
    /// 删除账号
    @objc private func handleDeleteAccountTap_Glasspaint() {
        let alert_glasspaint = UIAlertController(
            title: "Delete Account",
            message: "This action cannot be undone. Your account will be permanently deleted after 24 hours. Are you sure?",
            preferredStyle: .alert
        )
        
        alert_glasspaint.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_glasspaint.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDeleteAccount_Glasspaint()
        })
        
        present(alert_glasspaint, animated: true)
    }
    
    /// 执行删除账号
    private func performDeleteAccount_Glasspaint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UserViewModel_Glasspaint.shared_Glasspaint.logout_Glasspaint(logoutType_glasspaint: .delete_glasspaint)
        }
    }
}
