import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面视图控制器

/// 设置页面视图控制器
/// 功能：展示 Terms / Privacy 协议入口、登出、删除账号四个操作入口；底部应用版本信息
/// 设计：顶部渐变用户信息卡 + 卡片分组列表 + 彩色图标 + 危险操作红色标注
/// 逻辑：危险操作附有确认弹窗保护；协议由 ProtocolHelper 统一处理
class Setting_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary  = UIColor(hexstring_Maki: "#FF8C00")
        static let bg       = UIColor(hexstring_Maki: "#FFFBF4")
        static let card     = UIColor.white
        static let tp       = UIColor(hexstring_Maki: "#1A0A00")
        static let ts       = UIColor(hexstring_Maki: "#8B7355")
        static let danger   = UIColor(hexstring_Maki: "#E53E3E")
        static let divider  = UIColor(hexstring_Maki: "#F0EDE6")
    }

    // MARK: - UI 属性

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        setupNav_Maki()
        buildUI_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - 导航栏配置

    private func setupNav_Maki() {
        title = "Settings"
        let appearance_maki = UINavigationBarAppearance()
        appearance_maki.configureWithTransparentBackground()
        appearance_maki.titleTextAttributes = [
            .foregroundColor: K_Maki.tp,
            .font: UIFont(name: "Georgia-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance_maki
        navigationController?.navigationBar.scrollEdgeAppearance = appearance_maki
        navigationController?.navigationBar.tintColor = K_Maki.primary
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(onBack_Maki)
        )
    }
}

// MARK: - UI 构建

extension Setting_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }

        // 协议组
        let termsRow_maki   = makeRow_Maki(
            title: "Terms of Service", icon: "doc.text.fill",
            iconColor: K_Maki.primary, showChevron: true
        ) { [weak self] in
            guard let self else { return }
            ProtocolHelper_Maki.showProtocol_Maki(type_Maki: .terms_Maki, content_Maki: "terms", from: self)
        }
        let privacyRow_maki = makeRow_Maki(
            title: "Privacy Policy", icon: "lock.shield.fill",
            iconColor: UIColor(hexstring_Maki: "#2980B9"), showChevron: true
        ) { [weak self] in
            guard let self else { return }
            ProtocolHelper_Maki.showProtocol_Maki(type_Maki: .privacy_Maki, content_Maki: "privacy", from: self)
        }

        // 账号组
        let logoutRow_maki = makeRow_Maki(
            title: "Log Out", icon: "arrow.right.square.fill",
            iconColor: UIColor(hexstring_Maki: "#E8650A"), showChevron: false
        ) { [weak self] in self?.confirmLogout_Maki() }
        let deleteRow_maki = makeRow_Maki(
            title: "Delete Account", icon: "trash.fill",
            iconColor: K_Maki.danger, showChevron: false, titleColor: K_Maki.danger
        ) { [weak self] in self?.confirmDelete_Maki() }

        let legalGroup_maki   = makeGroup_Maki(label: "LEGAL",   rows: [termsRow_maki, privacyRow_maki])
        let accountGroup_maki = makeGroup_Maki(label: "ACCOUNT", rows: [logoutRow_maki, deleteRow_maki])

        contentView_Maki.addSubview(legalGroup_maki)
        contentView_Maki.addSubview(accountGroup_maki)
        legalGroup_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        accountGroup_maki.snp.makeConstraints { make in
            make.top.equalTo(legalGroup_maki.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    /// 构建带标题的卡片分组容器
    private func makeGroup_Maki(label: String, rows: [UIView]) -> UIView {
        let v_maki = UIView()

        // 区块标题（字间距加大）
        let titleLb_maki = UILabel()
        titleLb_maki.attributedText = NSAttributedString(string: label, attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: K_Maki.ts,
            .kern: CGFloat(1.5)
        ])
        v_maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        // 白色圆角卡片
        let card_maki = UIView()
        card_maki.backgroundColor = K_Maki.card
        card_maki.layer.cornerRadius = 18
        card_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        card_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_maki.layer.shadowRadius = 10
        card_maki.layer.shadowOpacity = 1
        v_maki.addSubview(card_maki)
        card_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        var prev_maki: UIView?
        for (i_maki, row_maki) in rows.enumerated() {
            card_maki.addSubview(row_maki)
            row_maki.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(60)
                if let p = prev_maki { make.top.equalTo(p.snp.bottom) }
                else { make.top.equalToSuperview() }
                if i_maki == rows.count - 1 { make.bottom.equalToSuperview() }
            }
            if i_maki < rows.count - 1 {
                let div_maki = UIView()
                div_maki.backgroundColor = K_Maki.divider
                card_maki.addSubview(div_maki)
                div_maki.snp.makeConstraints { make in
                    make.bottom.equalTo(row_maki)
                    make.leading.equalToSuperview().offset(62)
                    make.trailing.equalToSuperview()
                    make.height.equalTo(0.5)
                }
            }
            prev_maki = row_maki
        }
        return v_maki
    }

    /// 构建单行设置项（彩色图标背景 + 标题 + 可选箭头）
    /// - Parameters:
    ///   - title: 显示标题
    ///   - icon: SF Symbol 图标名
    ///   - iconColor: 图标主题色
    ///   - showChevron: 是否显示右侧箭头
    ///   - titleColor: 标题文字颜色（默认深色）
    ///   - action: 点击回调
    private func makeRow_Maki(
        title: String, icon: String, iconColor: UIColor,
        showChevron: Bool, titleColor: UIColor? = nil,
        action: @escaping () -> Void
    ) -> UIView {
        let v_maki = UIView()
        v_maki.backgroundColor = .clear

        // 图标背景（渐变圆角块）
        let iconBg_maki = UIView()
        iconBg_maki.backgroundColor = iconColor.withAlphaComponent(0.14)
        iconBg_maki.layer.cornerRadius = 10

        let iconIV_maki = UIImageView(image: UIImage(systemName: icon))
        iconIV_maki.tintColor    = iconColor
        iconIV_maki.contentMode  = .scaleAspectFit

        let titleLb_maki = UILabel()
        titleLb_maki.text      = title
        titleLb_maki.font      = .systemFont(ofSize: 15, weight: .medium)
        titleLb_maki.textColor = titleColor ?? K_Maki.tp

        v_maki.addSubview(iconBg_maki)
        iconBg_maki.addSubview(iconIV_maki)
        v_maki.addSubview(titleLb_maki)

        iconBg_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        iconIV_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_maki.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
        }

        if showChevron {
            let chevron_maki = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron_maki.tintColor   = UIColor(hexstring_Maki: "#C0B4A0")
            chevron_maki.contentMode = .scaleAspectFit
            v_maki.addSubview(chevron_maki)
            chevron_maki.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(13)
            }
        }

        // 透明按钮覆盖整行：点击 + 按压反馈
        let btn_maki = UIButton(type: .system)
        btn_maki.backgroundColor = .clear
        v_maki.addSubview(btn_maki)
        btn_maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        btn_maki.addAction(UIAction { _ in action() }, for: .touchUpInside)
        btn_maki.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.1) {
                v_maki.backgroundColor = UIColor.black.withAlphaComponent(0.04)
            }
        }, for: .touchDown)
        btn_maki.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.15) { v_maki.backgroundColor = .clear }
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return v_maki
    }

}

// MARK: - 事件响应

extension Setting_Maki {

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }

    /// 确认登出弹窗
    private func confirmLogout_Maki() {
        let alert_maki = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_maki.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_maki.addAction(UIAlertAction(title: "Log Out", style: .default) { _ in
            UserViewModel_Maki.shared_Maki.logout_Maki(logoutType_maki: .logout_maki)
        })
        present(alert_maki, animated: true)
    }

    /// 确认删除账号弹窗
    private func confirmDelete_Maki() {
        let alert_maki = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert_maki.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_maki.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            UserViewModel_Maki.shared_Maki.logout_Maki(logoutType_maki: .delete_maki)
        })
        present(alert_maki, animated: true)
    }
}
