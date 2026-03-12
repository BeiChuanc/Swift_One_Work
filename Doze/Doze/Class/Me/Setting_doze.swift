import Foundation
import UIKit
import SnapKit

// MARK: 设置

/// 设置页面
/// 设计风格：浅色清新主题 + 分组卡片列表 + 渐变退出 / 删除按钮
/// 功能：Terms、Privacy 展示协议；退出登录；删除账号（二次确认）
class Setting_Doze: UIViewController {

    // MARK: - 顶部 NavBar

    private let navBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        return v
    }()

    private let backButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Doze.textPrimary_Doze
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        btn.layer.cornerRadius = 18
        return btn
    }()

    private let navTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Settings"
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    // MARK: - 滚动容器

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Doze = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        setupNavBar_Doze()
        setupContent_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - NavBar 搭建

    private func setupNavBar_Doze() {
        view.addSubview(navBar_Doze)
        navBar_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        navBar_Doze.addSubview(backButton_Doze)
        backButton_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        backButton_Doze.addTarget(self, action: #selector(handleBack_Doze), for: .touchUpInside)

        navBar_Doze.addSubview(navTitleLabel_Doze)
        navTitleLabel_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - 内容搭建

    private func setupContent_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }

        scrollView_Doze.addSubview(contentView_Doze)
        contentView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 顶部装饰横幅
        let heroBanner = buildHeroBanner_Doze()
        contentView_Doze.addSubview(heroBanner)
        heroBanner.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(20)
        }

        // 协议分组卡片（行视图必须加入内层 card，保证白色背景正确包裹）
        let (legalWrapper, legalCard) = buildSectionCard_Doze(title: "Legal & Privacy", icon: "doc.text.fill")
        contentView_Doze.addSubview(legalWrapper)
        legalWrapper.snp.makeConstraints { make in
            make.top.equalTo(heroBanner.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        let termsRow = buildRowButton_Doze(
            icon: "checkmark.seal.fill",
            iconColor: ColorConfig_Doze.primaryGradientStart_Doze,
            title: "Terms of Service",
            showArrow: true,
            destructive: false,
            action: #selector(handleTerms_Doze)
        )
        let privacyRow = buildRowButton_Doze(
            icon: "lock.shield.fill",
            iconColor: UIColor(hexstring_Doze: "#9F7AEA"),
            title: "Privacy Policy",
            showArrow: true,
            destructive: false,
            action: #selector(handlePrivacy_Doze)
        )

        // 行添加进内层白色 card，确保背景完整包裹
        legalCard.addSubview(termsRow)
        legalCard.addSubview(privacyRow)

        let sepLegal = buildSep_Doze()
        legalCard.addSubview(sepLegal)

        termsRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        sepLegal.snp.makeConstraints { make in
            make.top.equalTo(termsRow.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }
        privacyRow.snp.makeConstraints { make in
            make.top.equalTo(sepLegal.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }

        // 账号操作卡片
        let (accountWrapper, accountCard) = buildSectionCard_Doze(title: "Account", icon: "person.fill")
        contentView_Doze.addSubview(accountWrapper)
        accountWrapper.snp.makeConstraints { make in
            make.top.equalTo(legalWrapper.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        let logoutRow = buildRowButton_Doze(
            icon: "arrow.right.square.fill",
            iconColor: UIColor(hexstring_Doze: "#ED8936"),
            title: "Log Out",
            showArrow: false,
            destructive: false,
            action: #selector(handleLogout_Doze)
        )
        let deleteRow = buildRowButton_Doze(
            icon: "trash.fill",
            iconColor: UIColor(hexstring_Doze: "#FC8181"),
            title: "Delete Account",
            showArrow: false,
            destructive: true,
            action: #selector(handleDelete_Doze)
        )

        accountCard.addSubview(logoutRow)
        accountCard.addSubview(deleteRow)

        let sepAccount = buildSep_Doze()
        accountCard.addSubview(sepAccount)

        logoutRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        sepAccount.snp.makeConstraints { make in
            make.top.equalTo(logoutRow.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }
        deleteRow.snp.makeConstraints { make in
            make.top.equalTo(sepAccount.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }

        // 底部留白
        let spacer = UIView()
        contentView_Doze.addSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.top.equalTo(accountWrapper.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 顶部装饰横幅

    private func buildHeroBanner_Doze() -> UIView {
        let banner = UIView()
        banner.layer.cornerRadius = 20
        banner.clipsToBounds = true

        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#4A1D96").cgColor,
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.locations = [0, 0.5, 1]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        banner.layer.addSublayer(gl)

        // 装饰圆
        let deco = UIView()
        deco.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        deco.layer.cornerRadius = 44
        banner.addSubview(deco)
        deco.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(88)
        }

        let gearIv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        gearIv.image = UIImage(systemName: "gearshape.2.fill", withConfiguration: cfg)
        gearIv.tintColor = UIColor.white.withAlphaComponent(0.35)
        banner.addSubview(gearIv)
        gearIv.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }

        let titleLbl = UILabel()
        titleLbl.text = "Settings"
        titleLbl.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        titleLbl.textColor = .white
        banner.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
        }

        let subLbl = UILabel()
        subLbl.text = "Manage your preferences"
        subLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subLbl.textColor = UIColor.white.withAlphaComponent(0.75)
        banner.addSubview(subLbl)
        subLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(titleLbl.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-20)
        }

        DispatchQueue.main.async { gl.frame = banner.bounds }
        return banner
    }

    /// 构建分组卡片（返回 (外层 wrapper, 内层白色 card)，行内容必须加进内层 card）
    private func buildSectionCard_Doze(title: String, icon: String) -> (UIView, UIView) {
        let wrapper = UIView()

        // 区组标题行
        let headerRow = UIView()
        wrapper.addSubview(headerRow)
        headerRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(28)
        }

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iconIv = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconCfg))
        iconIv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        headerRow.addSubview(iconIv)
        iconIv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let headerLbl = UILabel()
        headerLbl.text = title
        headerLbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        headerLbl.textColor = ColorConfig_Doze.textSecondary_Doze
        headerRow.addSubview(headerLbl)
        headerLbl.snp.makeConstraints { make in
            make.left.equalTo(iconIv.snp.right).offset(6)
            make.centerY.equalToSuperview()
        }

        // 白色卡片容器（行内容由调用方加入，内层 card 高度由其子视图撑起）
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 1
        wrapper.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalTo(headerRow.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }

        return (wrapper, card)
    }

    /// 构建列表行按钮
    /// - Note: 使用覆盖整行的透明 UIButton 替代 Tap + LongPress 手势组合，
    ///         避免 minimumPressDuration=0 的 LongPress 在 touchesBegan 立刻进入 .began
    ///         导致 TapGestureRecognizer 强制 fail 而无法响应点击的问题
    private func buildRowButton_Doze(
        icon: String,
        iconColor: UIColor,
        title: String,
        showArrow: Bool,
        destructive: Bool,
        action: Selector
    ) -> UIView {
        let row = UIView()
        row.isUserInteractionEnabled = true
        row.layer.cornerRadius = 0

        // 图标背景
        let iconBg = UIView()
        iconBg.backgroundColor = iconColor.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 10
        iconBg.isUserInteractionEnabled = false
        row.addSubview(iconBg)
        iconBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iconIv = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconCfg))
        iconIv.tintColor = iconColor
        iconIv.isUserInteractionEnabled = false
        iconBg.addSubview(iconIv)
        iconIv.snp.makeConstraints { make in make.center.equalToSuperview() }

        // 标题
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLbl.textColor = destructive
            ? UIColor(hexstring_Doze: "#E53E3E")
            : ColorConfig_Doze.textPrimary_Doze
        titleLbl.isUserInteractionEnabled = false
        row.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }

        // 箭头（仅协议行展示）
        if showArrow {
            let arrowCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            let arrowIv = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: arrowCfg))
            arrowIv.tintColor = ColorConfig_Doze.textPlaceholder_Doze
            arrowIv.isUserInteractionEnabled = false
            row.addSubview(arrowIv)
            arrowIv.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-18)
                make.centerY.equalToSuperview()
            }
        }

        // 覆盖整行的透明按钮：touchUpInside 触发业务 action，touchDown / cancel 处理高亮
        let hitBtn = UIButton(type: .custom)
        hitBtn.backgroundColor = .clear
        hitBtn.addTarget(self, action: action, for: .touchUpInside)
        hitBtn.addTarget(self, action: #selector(handleRowTouchDown_Doze(_:)), for: .touchDown)
        hitBtn.addTarget(self, action: #selector(handleRowTouchUp_Doze(_:)),
                         for: [.touchUpInside, .touchUpOutside, .touchCancel])
        row.addSubview(hitBtn)
        hitBtn.snp.makeConstraints { make in make.edges.equalToSuperview() }

        return row
    }

    /// 构建分隔线
    private func buildSep_Doze() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Doze.divider_Doze
        return v
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        guard let sv = scrollView_Doze.subviews.first else { return }
        sv.subviews.forEach { v in
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: 18)
        }
        for (i, v) in sv.subviews.enumerated() {
            UIView.animate(withDuration: 0.42, delay: Double(i) * 0.06,
                           usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3,
                           options: .curveEaseOut) {
                v.alpha = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - 事件处理

    @objc private func handleBack_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.pop_Doze()
    }

    /// 展示服务条款（Assets 中的 terms 图片）
    @objc private func handleTerms_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Doze.showProtocol_Doze(
            type_Doze: .terms_Doze,
            content_Doze: "terms.png",
            from: self
        )
    }

    /// 展示隐私政策（Assets 中的 privacy 图片）
    @objc private func handlePrivacy_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Doze.showProtocol_Doze(
            type_Doze: .privacy_Doze,
            content_Doze: "privacy.png",
            from: self
        )
    }

    /// 退出登录（带二次确认）
    @objc private func handleLogout_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            UserViewModel_Doze.shared_Doze.logout_Doze(logoutType_doze: .logout_doze)
        })
        present(alert, animated: true)
    }

    /// 删除账号（带二次确认）
    @objc private func handleDelete_Doze() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Your account will be permanently deleted after 24 hours. If you log in within 24 hours, the deletion will be cancelled.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            UserViewModel_Doze.shared_Doze.logout_Doze(logoutType_doze: .delete_doze)
        })
        present(alert, animated: true)
    }

    /// 列表行按下高亮
    @objc private func handleRowTouchDown_Doze(_ sender: UIButton) {
        UIView.animate(withDuration: 0.10) {
            sender.superview?.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        }
    }

    /// 列表行抬起 / 取消恢复背景
    @objc private func handleRowTouchUp_Doze(_ sender: UIButton) {
        UIView.animate(withDuration: 0.14) {
            sender.superview?.backgroundColor = .clear
        }
    }
}
