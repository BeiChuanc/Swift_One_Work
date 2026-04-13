import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面

/// 设置页面
/// 核心功能：提供 Terms of Service、Privacy Policy 查阅入口，以及登出与删除账号操作
/// 设计思路：顶部渐变 Banner（展示用户头像 + 用户名）+ 卡片分区列表；
///           Legal 区展示协议链接，Account 区展示操作按钮，底部展示 App 版本号
/// 关键方法：
/// - setupBanner_Clara: 构建渐变 Banner，含装饰圆圈和用户信息
/// - showTerms_Clara / showPrivacy_Clara: 调用协议助手展示协议图片
/// - logoutTapped_Clara: 弹出确认后调用 UserViewModel 登出
/// - deleteAccountTapped_Clara: 弹出双重确认后调用 UserViewModel 删除账号
class Setting_Clara: UIViewController {

    // MARK: - UI 组件

    private let scrollView_Clara = UIScrollView()
    private let contentView_Clara = UIView()

    /// 顶部渐变 Banner
    private let bannerView_Clara = UIView()

    /// Banner 渐变图层
    private var bannerGl_Clara: CAGradientLayer?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 完全隐藏导航栏，使用页面内嵌的自定义返回按钮
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupScrollView_Clara()
        setupBanner_Clara()
        setupLegalSection_Clara()
        setupAccountSection_Clara()
        // 最后添加返回按钮，确保 z-order 在 ScrollView 之上
        setupNavigationBar_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gl = bannerGl_Clara {
            gl.frame = bannerView_Clara.bounds
        } else if bannerView_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: bannerView_Clara.bounds)
            bannerView_Clara.layer.insertSublayer(gl, at: 0)
            bannerGl_Clara = gl
        }
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - 自定义返回按钮

    /// 在 Banner 左上角嵌入自定义返回按钮，与渐变背景融合
    private func setupNavigationBar_Clara() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        btn.addTarget(self, action: #selector(backTapped_Clara), for: .touchUpInside)
    }

    // MARK: - UI 搭建

    private func setupScrollView_Clara() {
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(contentView_Clara)
        scrollView_Clara.showsVerticalScrollIndicator = false
        // 透明背景，使 view 层的多拼色渐变透出
        scrollView_Clara.backgroundColor = .clear
        contentView_Clara.backgroundColor = .clear
        // 贴满整个 view（含状态栏区域），让 Banner 延伸到屏幕顶部
        scrollView_Clara.contentInsetAdjustmentBehavior = .never
        scrollView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    /// 顶部渐变 Banner（纯装饰：标题 + 圆圈装饰，不含用户信息）
    private func setupBanner_Clara() {
        contentView_Clara.addSubview(bannerView_Clara)
        bannerView_Clara.layer.cornerRadius = 24
        bannerView_Clara.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bannerView_Clara.clipsToBounds = true
        bannerView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(110)
        }

        // 大装饰圆（右上）
        let bigCircle = UIView()
        bigCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        bigCircle.layer.cornerRadius = 55
        bannerView_Clara.addSubview(bigCircle)
        bigCircle.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.right.equalToSuperview().inset(-24)
            make.top.equalToSuperview().inset(-24)
        }

        // 小装饰圆（左下）
        let smallCircle = UIView()
        smallCircle.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        smallCircle.layer.cornerRadius = 32
        bannerView_Clara.addSubview(smallCircle)
        smallCircle.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.left.equalToSuperview().inset(-16)
            make.bottom.equalToSuperview().inset(-18)
        }

        // 页面标题（居中，左侧预留返回按钮空间）
        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        bannerView_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 齿轮图标装饰（右侧）
        let gearIcon = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        gearIcon.image = UIImage(systemName: "gearshape.fill", withConfiguration: cfg)
        gearIcon.tintColor = UIColor.white.withAlphaComponent(0.45)
        bannerView_Clara.addSubview(gearIcon)
        gearIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }

    /// 法律协议栏（Terms / Privacy）
    private func setupLegalSection_Clara() {
        let sectionLabel = makeSectionLabel_Clara(text: "Legal")
        contentView_Clara.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Clara.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
        }

        let card = makeCard_Clara()
        contentView_Clara.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        let termsRow = makeSettingRow_Clara(
            icon: "doc.text.fill",
            title: "Terms of Service",
            subtitle: "Read our usage agreement",
            color: ColorConfig_Clara.primaryGradientStart_Clara,
            showDivider: true
        )
        let privacyRow = makeSettingRow_Clara(
            icon: "lock.shield.fill",
            title: "Privacy Policy",
            subtitle: "How we protect your data",
            color: ColorConfig_Clara.primaryGradientEnd_Clara,
            showDivider: false
        )

        card.addSubview(termsRow)
        card.addSubview(privacyRow)
        termsRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        privacyRow.snp.makeConstraints { make in
            make.top.equalTo(termsRow.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(70)
        }

        let termsTap = UITapGestureRecognizer(target: self, action: #selector(showTerms_Clara))
        termsRow.addGestureRecognizer(termsTap)
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(showPrivacy_Clara))
        privacyRow.addGestureRecognizer(privacyTap)
    }

    /// 账号操作栏（登出 / 删除账号）
    private func setupAccountSection_Clara() {
        let sectionLabel = makeSectionLabel_Clara(text: "Account")
        contentView_Clara.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            // Legal section: 24 + 11 + 8 + 140 = 183; 再加上 24 间距
            make.top.equalTo(bannerView_Clara.snp.bottom).offset(207)
            make.left.equalToSuperview().offset(24)
        }

        let card = makeCard_Clara()
        contentView_Clara.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            // Account 卡片是 contentView 的最后元素，撑开底部空间
            make.bottom.equalToSuperview().inset(40)
        }

        let logoutRow = makeSettingRow_Clara(
            icon: "arrow.right.square.fill",
            title: "Sign Out",
            subtitle: "Log out of your account",
            color: UIColor.systemOrange,
            showDivider: true
        )
        let deleteRow = makeSettingRow_Clara(
            icon: "trash.fill",
            title: "Delete Account",
            subtitle: "Permanently remove your account",
            color: .systemRed,
            showDivider: false,
            textColor: .systemRed
        )

        card.addSubview(logoutRow)
        card.addSubview(deleteRow)
        logoutRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        deleteRow.snp.makeConstraints { make in
            make.top.equalTo(logoutRow.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(70)
        }

        let logoutTap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped_Clara))
        logoutRow.addGestureRecognizer(logoutTap)
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped_Clara))
        deleteRow.addGestureRecognizer(deleteTap)
    }


    // MARK: - 辅助构建

    /// 创建分区标题标签
    private func makeSectionLabel_Clara(text: String) -> UILabel {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        return l
    }

    /// 创建卡片容器
    private func makeCard_Clara() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 18
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        return v
    }

    /// 创建通用设置行（含图标、主标题、副标题、右箭头）
    /// - Parameters:
    ///   - icon: SF Symbol 图标名
    ///   - title: 行主标题
    ///   - subtitle: 行副标题描述
    ///   - color: 图标强调色
    ///   - showDivider: 是否显示底部分割线
    ///   - textColor: 主标题颜色（默认主文本色）
    /// - Returns: 配置好的行视图
    private func makeSettingRow_Clara(
        icon: String,
        title: String,
        subtitle: String,
        color: UIColor,
        showDivider: Bool,
        textColor: UIColor = ColorConfig_Clara.textPrimary_Clara
    ) -> UIView {
        let row = UIView()
        row.isUserInteractionEnabled = true

        // 图标背景色块
        let iconBg = UIView()
        iconBg.backgroundColor = color.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 12
        row.addSubview(iconBg)
        iconBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }

        let iconView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: cfg)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconBg.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        // 主标题
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = textColor
        row.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(12)
            make.top.equalToSuperview().offset(14)
        }

        // 副标题
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        row.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
        }

        // 右箭头
        let chevron = UIImageView()
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = ColorConfig_Clara.textPlaceholder_Clara
        chevron.contentMode = .scaleAspectFit
        row.addSubview(chevron)
        chevron.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }

        if showDivider {
            let divider = UIView()
            divider.backgroundColor = ColorConfig_Clara.divider_Clara
            row.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.left.equalTo(iconBg.snp.left)
                make.right.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
        return row
    }


    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    /// 展示服务条款
    @objc private func showTerms_Clara() {
        ProtocolHelper_Clara.showProtocol_Clara(
            type_Clara: .terms_Clara,
            content_Clara: "terms.png",
            from: self
        )
    }

    /// 展示隐私政策
    @objc private func showPrivacy_Clara() {
        ProtocolHelper_Clara.showProtocol_Clara(
            type_Clara: .privacy_Clara,
            content_Clara: "privacy.png",
            from: self
        )
    }

    /// 登出（弹出确认对话框）
    @objc private func logoutTapped_Clara() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Clara.shared_Clara.logout_Clara(logoutType_clara: .logout_clara)
            }
        })
        present(alert, animated: true)
    }

    /// 删除账号（双重确认对话框）
    @objc private func deleteAccountTapped_Clara() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This action is irreversible. Your account will be permanently deleted after 24 hours. Are you sure?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.confirmDeleteAccount_Clara()
        })
        present(alert, animated: true)
    }

    /// 最终确认删除账号
    private func confirmDeleteAccount_Clara() {
        let confirm = UIAlertController(
            title: "Final Confirmation",
            message: "I understand my account will be deleted.",
            preferredStyle: .alert
        )
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Confirm Delete", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Clara.shared_Clara.logout_Clara(logoutType_clara: .delete_clara)
            }
        })
        present(confirm, animated: true)
    }
}
