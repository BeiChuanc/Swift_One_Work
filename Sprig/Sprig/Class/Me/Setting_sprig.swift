import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面
/// 功能：提供服务条款/隐私政策查看、账号登出与账号删除操作入口
/// 设计：渐变头部（多圈装饰）+ 分区标题 + 卡片式功能列表 + 危险操作区
class Setting_Sprig: UIViewController {

    // MARK: - UI 组件 - 头部

    private let headerView_Sprig = UIView()
    private let gradientLayer_Sprig = CAGradientLayer()
    private let backButton_Sprig = UIButton(type: .system)
    private let headerTitleLabel_Sprig = UILabel()
    /// 头部装饰圆组
    private let decorCircle1_Sprig = UIView()
    private let decorCircle2_Sprig = UIView()
    private let decorCircle3_Sprig = UIView()

    // MARK: - UI 组件 - 内容

    private let scrollView_Sprig = UIScrollView()
    private let contentView_Sprig = UIView()

    /// Legal 分区标签
    private let legalSectionLabel_Sprig = UILabel()
    /// 条款 & 隐私卡片
    private let legalCard_Sprig = UIView()
    private let termsRowBtn_Sprig = UIButton(type: .system)
    private let privacyRowBtn_Sprig = UIButton(type: .system)
    private let rowDivider_Sprig = UIView()

    /// Account 分区标签
    private let accountSectionLabel_Sprig = UILabel()
    /// 登出按钮（渐变背景）
    private let logoutBtn_Sprig = UIButton(type: .system)
    /// 登出按钮渐变层
    private let logoutGradientLayer_Sprig = CAGradientLayer()

    /// 删除账号按钮
    private let deleteAccountBtn_Sprig = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Sprig.frame = headerView_Sprig.bounds
        logoutGradientLayer_Sprig.frame = logoutBtn_Sprig.bounds
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        buildHeader_Sprig()
        buildScrollContent_Sprig()
    }

    /// 搭建渐变头部（含问候语与多圈装饰）
    private func buildHeader_Sprig() {
        gradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        headerView_Sprig.layer.insertSublayer(gradientLayer_Sprig, at: 0)
        headerView_Sprig.clipsToBounds = true
        view.addSubview(headerView_Sprig)
        headerView_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
        }

        // 装饰圆 1（右上角，大圈）
        decorCircle1_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        decorCircle1_Sprig.layer.cornerRadius = 70
        headerView_Sprig.addSubview(decorCircle1_Sprig)
        decorCircle1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(-24)
            make.width.height.equalTo(140)
        }

        // 装饰圆 2（左下，中圈）
        decorCircle2_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        decorCircle2_Sprig.layer.cornerRadius = 46
        headerView_Sprig.addSubview(decorCircle2_Sprig)
        decorCircle2_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(22)
            make.width.height.equalTo(92)
        }

        // 装饰圆 3（右中，小圈，描边款）
        decorCircle3_Sprig.backgroundColor = .clear
        decorCircle3_Sprig.layer.borderWidth = 2
        decorCircle3_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        decorCircle3_Sprig.layer.cornerRadius = 32
        headerView_Sprig.addSubview(decorCircle3_Sprig)
        decorCircle3_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(64)
        }

        // 返回按钮（毛玻璃圆形背景）
        let backBg_Sprig = UIView()
        backBg_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backBg_Sprig.layer.cornerRadius = 18
        headerView_Sprig.addSubview(backBg_Sprig)
        backBg_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.height.equalTo(36)
        }
        let backCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton_Sprig.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_Sprig), for: .normal)
        backButton_Sprig.tintColor = .white
        backButton_Sprig.addTarget(self, action: #selector(onBackTapped_Sprig), for: .touchUpInside)
        headerView_Sprig.addSubview(backButton_Sprig)
        backButton_Sprig.snp.makeConstraints { make in make.edges.equalTo(backBg_Sprig) }

        // 页面标题
        headerTitleLabel_Sprig.text = "Settings"
        headerTitleLabel_Sprig.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerTitleLabel_Sprig.textColor = .white
        headerView_Sprig.addSubview(headerTitleLabel_Sprig)
        headerTitleLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton_Sprig)
        }

    }

    /// 搭建滚动内容区
    private func buildScrollContent_Sprig() {
        scrollView_Sprig.showsVerticalScrollIndicator = false
        view.addSubview(scrollView_Sprig)
        scrollView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(headerView_Sprig.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        scrollView_Sprig.addSubview(contentView_Sprig)
        contentView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildLegalSection_Sprig()
        buildAccountSection_Sprig()

        // 底部占位
        let bottomSpacer_Sprig = UIView()
        contentView_Sprig.addSubview(bottomSpacer_Sprig)
        bottomSpacer_Sprig.snp.makeConstraints { make in
            make.top.equalTo(deleteAccountBtn_Sprig.snp.bottom).offset(50)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    /// 搭建 Legal 分区（分区标签 + 条款隐私卡片）
    private func buildLegalSection_Sprig() {
        // 分区标签
        buildSectionLabel_Sprig(
            label_Sprig: legalSectionLabel_Sprig,
            text_Sprig: "LEGAL",
            topAnchor_Sprig: contentView_Sprig.topAnchor,
            topOffset_Sprig: 24
        )

        // 卡片
        legalCard_Sprig.backgroundColor = ColorConfig_Sprig.cardBackground_Sprig
        legalCard_Sprig.layer.cornerRadius = 20
        applyShadow_Sprig(to: legalCard_Sprig)
        contentView_Sprig.addSubview(legalCard_Sprig)
        legalCard_Sprig.snp.makeConstraints { make in
            make.top.equalTo(legalSectionLabel_Sprig.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        buildRow_Sprig(
            button_Sprig: termsRowBtn_Sprig,
            icon_Sprig: "doc.text.fill",
            title_Sprig: "Terms of Service",
            subtitle_Sprig: "Read our usage rules",
            iconColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig,
            in_Sprig: legalCard_Sprig,
            topAnchor_Sprig: legalCard_Sprig.topAnchor,
            topOffset_Sprig: 0,
            action_Sprig: #selector(onTermsTapped_Sprig)
        )

        rowDivider_Sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig
        legalCard_Sprig.addSubview(rowDivider_Sprig)
        rowDivider_Sprig.snp.makeConstraints { make in
            make.top.equalTo(termsRowBtn_Sprig.snp.bottom)
            make.left.equalToSuperview().offset(68)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }

        buildRow_Sprig(
            button_Sprig: privacyRowBtn_Sprig,
            icon_Sprig: "lock.shield.fill",
            title_Sprig: "Privacy Policy",
            subtitle_Sprig: "How we protect your data",
            iconColor_Sprig: ColorConfig_Sprig.primaryGradientEnd_Sprig,
            in_Sprig: legalCard_Sprig,
            topAnchor_Sprig: rowDivider_Sprig.bottomAnchor,
            topOffset_Sprig: 0,
            action_Sprig: #selector(onPrivacyTapped_Sprig)
        )

        legalCard_Sprig.snp.makeConstraints { make in
            make.bottom.equalTo(privacyRowBtn_Sprig.snp.bottom)
        }
    }

    /// 搭建 Account 分区（登出 + 删除账号）
    private func buildAccountSection_Sprig() {
        buildSectionLabel_Sprig(
            label_Sprig: accountSectionLabel_Sprig,
            text_Sprig: "ACCOUNT",
            topAnchor_Sprig: legalCard_Sprig.bottomAnchor,
            topOffset_Sprig: 22
        )

        buildGradientLogoutButton_Sprig()
        buildDeleteAccountButton_Sprig()
    }

    /// 搭建渐变风格登出按钮
    private func buildGradientLogoutButton_Sprig() {
        // 渐变层（柔和色调）
        logoutGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.88).cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.withAlphaComponent(0.88).cgColor
        ]
        logoutGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        logoutGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
        logoutGradientLayer_Sprig.cornerRadius = 20
        logoutBtn_Sprig.layer.insertSublayer(logoutGradientLayer_Sprig, at: 0)
        logoutBtn_Sprig.layer.cornerRadius = 20
        logoutBtn_Sprig.clipsToBounds = true
        logoutBtn_Sprig.addTarget(self, action: #selector(onLogoutTapped_Sprig), for: .touchUpInside)
        contentView_Sprig.addSubview(logoutBtn_Sprig)
        logoutBtn_Sprig.snp.makeConstraints { make in
            make.top.equalTo(accountSectionLabel_Sprig.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(62)
        }

        // 左侧图标（白色）
        let iconView_Sprig = UIImageView()
        let iconCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconView_Sprig.image = UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: iconCfg_Sprig)
        iconView_Sprig.tintColor = .white
        iconView_Sprig.contentMode = .scaleAspectFit
        iconView_Sprig.isUserInteractionEnabled = false
        logoutBtn_Sprig.addSubview(iconView_Sprig)
        iconView_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        // 标题文字（白色）
        let titleLbl_Sprig = UILabel()
        titleLbl_Sprig.text = "Log Out"
        titleLbl_Sprig.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLbl_Sprig.textColor = .white
        titleLbl_Sprig.isUserInteractionEnabled = false
        logoutBtn_Sprig.addSubview(titleLbl_Sprig)
        titleLbl_Sprig.snp.makeConstraints { make in
            make.left.equalTo(iconView_Sprig.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }

        // 右侧再见标签（半透明白色）
        let tagLabel_Sprig = UILabel()
        tagLabel_Sprig.text = "See you soon 👋"
        tagLabel_Sprig.font = UIFont.systemFont(ofSize: 12)
        tagLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.72)
        tagLabel_Sprig.isUserInteractionEnabled = false
        logoutBtn_Sprig.addSubview(tagLabel_Sprig)
        tagLabel_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }
    }

    /// 搭建删除账号按钮（危险区域，红色调）
    private func buildDeleteAccountButton_Sprig() {
        deleteAccountBtn_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#FFF5F5")
        deleteAccountBtn_Sprig.layer.cornerRadius = 20
        deleteAccountBtn_Sprig.layer.borderWidth = 1
        deleteAccountBtn_Sprig.layer.borderColor = UIColor(hexstring_Sprig: "#FC8181").withAlphaComponent(0.35).cgColor
        deleteAccountBtn_Sprig.addTarget(self, action: #selector(onDeleteAccountTapped_Sprig), for: .touchUpInside)
        contentView_Sprig.addSubview(deleteAccountBtn_Sprig)
        deleteAccountBtn_Sprig.snp.makeConstraints { make in
            make.top.equalTo(logoutBtn_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(58)
        }

        // 红色图标背景圆
        let iconBg_Sprig = UIView()
        iconBg_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#FED7D7").withAlphaComponent(0.60)
        iconBg_Sprig.layer.cornerRadius = 16
        iconBg_Sprig.isUserInteractionEnabled = false
        deleteAccountBtn_Sprig.addSubview(iconBg_Sprig)
        iconBg_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        let deleteCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let deleteIconView_Sprig = UIImageView(image: UIImage(systemName: "trash.fill", withConfiguration: deleteCfg_Sprig))
        deleteIconView_Sprig.tintColor = UIColor(hexstring_Sprig: "#E53E3E")
        deleteIconView_Sprig.contentMode = .scaleAspectFit
        deleteIconView_Sprig.isUserInteractionEnabled = false
        iconBg_Sprig.addSubview(deleteIconView_Sprig)
        deleteIconView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        let deleteTitleLbl_Sprig = UILabel()
        deleteTitleLbl_Sprig.text = "Delete Account"
        deleteTitleLbl_Sprig.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        deleteTitleLbl_Sprig.textColor = UIColor(hexstring_Sprig: "#E53E3E")
        deleteTitleLbl_Sprig.isUserInteractionEnabled = false
        deleteAccountBtn_Sprig.addSubview(deleteTitleLbl_Sprig)
        deleteTitleLbl_Sprig.snp.makeConstraints { make in
            make.left.equalTo(iconBg_Sprig.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }

        // 危险标签（右侧小胶囊）
        let warnLabel_Sprig = UILabel()
        warnLabel_Sprig.text = "⚠ Permanent"
        warnLabel_Sprig.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        warnLabel_Sprig.textColor = UIColor(hexstring_Sprig: "#E53E3E")
        warnLabel_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#FED7D7").withAlphaComponent(0.55)
        warnLabel_Sprig.layer.cornerRadius = 8
        warnLabel_Sprig.clipsToBounds = true
        warnLabel_Sprig.textAlignment = .center
        warnLabel_Sprig.isUserInteractionEnabled = false
        deleteAccountBtn_Sprig.addSubview(warnLabel_Sprig)
        warnLabel_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.equalTo(86)
        }
    }

    // MARK: - 分区标签辅助方法

    /// 构建统一风格的分区标题标签（带左侧短竖条）
    /// - Parameters:
    ///   - label_Sprig: 目标标签
    ///   - text_Sprig: 分区名称（英文大写）
    ///   - topAnchor_Sprig: 顶部参考锚点
    ///   - topOffset_Sprig: 顶部偏移
    private func buildSectionLabel_Sprig(
        label_Sprig: UILabel,
        text_Sprig: String,
        topAnchor_Sprig: NSLayoutYAxisAnchor,
        topOffset_Sprig: CGFloat
    ) {
        label_Sprig.text = text_Sprig
        label_Sprig.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig

        // 左侧装饰竖条
        let accentBar_Sprig = UIView()
        accentBar_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        accentBar_Sprig.layer.cornerRadius = 1.5

        let container_Sprig = UIView()
        contentView_Sprig.addSubview(container_Sprig)
        container_Sprig.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container_Sprig.topAnchor.constraint(equalTo: topAnchor_Sprig, constant: topOffset_Sprig),
            container_Sprig.leftAnchor.constraint(equalTo: contentView_Sprig.leftAnchor, constant: 22),
            container_Sprig.heightAnchor.constraint(equalToConstant: 18)
        ])

        container_Sprig.addSubview(accentBar_Sprig)
        container_Sprig.addSubview(label_Sprig)
        accentBar_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(3)
            make.height.equalTo(12)
        }
        label_Sprig.snp.makeConstraints { make in
            make.left.equalTo(accentBar_Sprig.snp.right).offset(6)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 行构建辅助方法

    /// 构建带图标、双行标题（主标题 + 副标题）、右箭头的设置行
    private func buildRow_Sprig(
        button_Sprig: UIButton,
        icon_Sprig: String,
        title_Sprig: String,
        subtitle_Sprig: String,
        iconColor_Sprig: UIColor,
        in_Sprig superView_Sprig: UIView,
        topAnchor_Sprig: NSLayoutYAxisAnchor,
        topOffset_Sprig: CGFloat,
        action_Sprig: Selector
    ) {
        button_Sprig.backgroundColor = .clear
        button_Sprig.addTarget(self, action: action_Sprig, for: .touchUpInside)
        superView_Sprig.addSubview(button_Sprig)
        button_Sprig.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button_Sprig.topAnchor.constraint(equalTo: topAnchor_Sprig, constant: topOffset_Sprig),
            button_Sprig.leftAnchor.constraint(equalTo: superView_Sprig.leftAnchor),
            button_Sprig.rightAnchor.constraint(equalTo: superView_Sprig.rightAnchor),
            button_Sprig.heightAnchor.constraint(equalToConstant: 68)
        ])

        // 图标背景（渐变色调）
        let iconBg_Sprig = UIView()
        iconBg_Sprig.backgroundColor = iconColor_Sprig.withAlphaComponent(0.10)
        iconBg_Sprig.layer.cornerRadius = 12
        iconBg_Sprig.isUserInteractionEnabled = false
        button_Sprig.addSubview(iconBg_Sprig)
        iconBg_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        let iconCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iconImg_Sprig = UIImageView(image: UIImage(systemName: icon_Sprig, withConfiguration: iconCfg_Sprig))
        iconImg_Sprig.tintColor = iconColor_Sprig
        iconImg_Sprig.contentMode = .scaleAspectFit
        iconImg_Sprig.isUserInteractionEnabled = false
        iconBg_Sprig.addSubview(iconImg_Sprig)
        iconImg_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        // 主标题
        let rowTitleLbl_Sprig = UILabel()
        rowTitleLbl_Sprig.text = title_Sprig
        rowTitleLbl_Sprig.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        rowTitleLbl_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        rowTitleLbl_Sprig.isUserInteractionEnabled = false
        button_Sprig.addSubview(rowTitleLbl_Sprig)
        rowTitleLbl_Sprig.snp.makeConstraints { make in
            make.left.equalTo(iconBg_Sprig.snp.right).offset(12)
            make.top.equalToSuperview().offset(14)
        }

        // 副标题
        let rowSubLbl_Sprig = UILabel()
        rowSubLbl_Sprig.text = subtitle_Sprig
        rowSubLbl_Sprig.font = UIFont.systemFont(ofSize: 12)
        rowSubLbl_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        rowSubLbl_Sprig.isUserInteractionEnabled = false
        button_Sprig.addSubview(rowSubLbl_Sprig)
        rowSubLbl_Sprig.snp.makeConstraints { make in
            make.left.equalTo(rowTitleLbl_Sprig)
            make.top.equalTo(rowTitleLbl_Sprig.snp.bottom).offset(3)
        }

        // 右箭头
        let arrowCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let arrowView_Sprig = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: arrowCfg_Sprig))
        arrowView_Sprig.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        arrowView_Sprig.isUserInteractionEnabled = false
        button_Sprig.addSubview(arrowView_Sprig)
        arrowView_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }

        // 按下高亮效果
        button_Sprig.addAction(UIAction { [weak button_Sprig] _ in
            UIView.animate(withDuration: 0.1) {
                button_Sprig?.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
            } completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    button_Sprig?.backgroundColor = .clear
                }
            }
        }, for: .touchDown)
    }

    // MARK: - 私有工厂方法

    /// 为视图添加统一卡片阴影
    private func applyShadow_Sprig(to view_Sprig: UIView) {
        view_Sprig.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_Sprig.layer.shadowOpacity = 1
        view_Sprig.layer.shadowRadius = 8
    }

    // MARK: - 事件处理

    @objc private func onBackTapped_Sprig() {
        backButton_Sprig.animatePressDown_Sprig { self.backButton_Sprig.animatePressUp_Sprig() }
        Navigation_Sprig.pop_Sprig()
    }

    /// 点击 Terms of Service，通过 ProtocolHelper 展示对应图片
    @objc private func onTermsTapped_Sprig() {
        termsRowBtn_Sprig.animatePressDown_Sprig { self.termsRowBtn_Sprig.animatePressUp_Sprig() }
        ProtocolHelper_Sprig.showProtocol_Sprig(
            type_Sprig: .terms_Sprig,
            content_Sprig: "terms_sprig.png",
            from: self
        )
    }

    /// 点击 Privacy Policy，通过 ProtocolHelper 展示对应图片
    @objc private func onPrivacyTapped_Sprig() {
        privacyRowBtn_Sprig.animatePressDown_Sprig { self.privacyRowBtn_Sprig.animatePressUp_Sprig() }
        ProtocolHelper_Sprig.showProtocol_Sprig(
            type_Sprig: .privacy_Sprig,
            content_Sprig: "privacy_sprig.png",
            from: self
        )
    }

    /// 点击登出，弹出确认 Alert 后执行登出
    @objc private func onLogoutTapped_Sprig() {
        logoutBtn_Sprig.animatePressDown_Sprig { self.logoutBtn_Sprig.animatePressUp_Sprig() }
        UIAlertController.logout_Sprig {
            UserViewModel_Sprig.shared_Sprig.logout_Sprig(logoutType_sprig: .logout_sprig)
        }
    }

    /// 点击删除账号，弹出确认 Alert 后执行删除
    @objc private func onDeleteAccountTapped_Sprig() {
        deleteAccountBtn_Sprig.animatePressDown_Sprig { self.deleteAccountBtn_Sprig.animatePressUp_Sprig() }
        UIAlertController.delete_Sprig {
            UserViewModel_Sprig.shared_Sprig.logout_Sprig(logoutType_sprig: .delete_sprig)
        }
    }
}
