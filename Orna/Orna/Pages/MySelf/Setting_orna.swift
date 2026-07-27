import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置页面视图控制器
/// 核心作用：展示服务条款、隐私政策入口，以及登出与注销账号操作
/// 设计思路：
///   - 页面背景改为与首页/发现页/我的页一致的浅紫底色，条款卡片改为白色圆角卡片承载，
///     与发布页三个输入卡片保持统一的视觉语言（白色卡片浮于浅紫背景之上）
///   - 顶部返回按钮 + 标题，条款区新增分区小标题呼应其他页面的分区图标语言
///   - 条款卡片区：服务条款 / 隐私政策，点击通过 ProtocolHelper_Orna 展示 Assets 中的配图
///   - 账户操作区：登出改为白色卡片按钮（次要样式），注销账号改为浅红底胶囊（危险样式），均需二次确认
class Setting_Orna: UIViewController {

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Settings"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    // MARK: - UI · 条款卡片

    /// "Legal" 分区小标题，呼应发布页/消息页的图标徽标 + 文案分区语言
    private lazy var legalSectionHeader_Orna = Setting_Orna.makeSectionHeader_Orna(
        icon_orna: "scroll.fill", text_orna: "Legal", accentColorHex_orna: "#7B61FF"
    )

    private let legalCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    private lazy var termsRow_Orna = Setting_Orna.makeRow_Orna(icon_orna: "doc.text.fill", title_orna: "Terms of Service", tint_orna: UIColor(hexstring_Orna: "#7B61FF"))
    private lazy var privacyRow_Orna = Setting_Orna.makeRow_Orna(icon_orna: "shield.lefthalf.filled", title_orna: "Privacy Policy", tint_orna: UIColor(hexstring_Orna: "#63B3ED"))
    private let dividerView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        return v
    }()

    // MARK: - UI · 账户操作

    /// "Account" 分区小标题
    private lazy var accountSectionHeader_Orna = Setting_Orna.makeSectionHeader_Orna(
        icon_orna: "person.crop.circle.fill", text_orna: "Account", accentColorHex_orna: "#FF9A6C"
    )

    private let logoutButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Log Out", for: .normal)
        b.setTitleColor(UIColor(hexstring_Orna: "#7B61FF"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        b.backgroundColor = .white
        b.layer.cornerRadius = 22
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.06
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 10
        return b
    }()

    private let deleteAccountButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        var config_orna = UIButton.Configuration.plain()
        config_orna.attributedTitle = AttributedString(
            "Delete Account", attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
        )
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: "#FF6B6B")
        config_orna.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        b.configuration = config_orna
        b.backgroundColor = UIColor(hexstring_Orna: "#FF6B6B").withAlphaComponent(0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(backButton_Orna)
        view.addSubview(titleLabel_Orna)

        view.addSubview(legalSectionHeader_Orna)
        view.addSubview(legalCardView_Orna)
        legalCardView_Orna.addSubview(termsRow_Orna)
        legalCardView_Orna.addSubview(dividerView_Orna)
        legalCardView_Orna.addSubview(privacyRow_Orna)

        view.addSubview(accountSectionHeader_Orna)
        view.addSubview(logoutButton_Orna)
        view.addSubview(deleteAccountButton_Orna)
    }

    /// 搭建分区图标徽标 + 标题，用于区分条款区与账户操作区并丰富色彩层次，
    /// 呼应发布页/消息页的分区头部视觉语言
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - text_orna: 分区标题文本
    /// - accentColorHex_orna: 该分区的强调色（十六进制）
    private static func makeSectionHeader_Orna(icon_orna: String, text_orna: String, accentColorHex_orna: String) -> UIView {
        let container_orna = UIView()
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)

        let badge_orna = UIView()
        badge_orna.backgroundColor = accentColor_orna.withAlphaComponent(0.15)
        badge_orna.layer.cornerRadius = 12

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = accentColor_orna
        iconView_orna.contentMode = .scaleAspectFit

        let label_orna = UILabel()
        label_orna.text = text_orna
        label_orna.font = .systemFont(ofSize: 13, weight: .bold)
        label_orna.textColor = UIColor(hexstring_Orna: "#8B87A0")

        container_orna.addSubview(badge_orna)
        badge_orna.addSubview(iconView_orna)
        container_orna.addSubview(label_orna)

        badge_orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        label_orna.snp.makeConstraints {
            $0.leading.equalTo(badge_orna.snp.trailing).offset(8)
            $0.centerY.equalTo(badge_orna)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        return container_orna
    }

    private func setupConstraints_Orna() {
        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.centerX.equalToSuperview()
        }

        legalSectionHeader_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(24)
        }
        legalCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(legalSectionHeader_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        termsRow_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(58)
        }
        dividerView_Orna.snp.makeConstraints {
            $0.top.equalTo(termsRow_Orna.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        privacyRow_Orna.snp.makeConstraints {
            $0.top.equalTo(dividerView_Orna.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(58)
        }

        accountSectionHeader_Orna.snp.makeConstraints {
            $0.top.equalTo(legalCardView_Orna.snp.bottom).offset(36)
            $0.leading.equalToSuperview().offset(24)
        }
        logoutButton_Orna.snp.makeConstraints {
            $0.top.equalTo(accountSectionHeader_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        deleteAccountButton_Orna.snp.makeConstraints {
            $0.top.equalTo(logoutButton_Orna.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        logoutButton_Orna.addTarget(self, action: #selector(handleLogoutTapped_Orna), for: .touchUpInside)
        deleteAccountButton_Orna.addTarget(self, action: #selector(handleDeleteAccountTapped_Orna), for: .touchUpInside)

        termsRow_Orna.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTermsTapped_Orna)))
        privacyRow_Orna.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePrivacyTapped_Orna)))
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 展示服务条款（Assets: terms.png）
    @objc private func handleTermsTapped_Orna() {
        ProtocolHelper_Orna.showProtocol_Orna(type_Orna: .terms_Orna, content_Orna: "terms.png", from: self)
    }

    /// 展示隐私政策（Assets: privacy.png）
    @objc private func handlePrivacyTapped_Orna() {
        ProtocolHelper_Orna.showProtocol_Orna(type_Orna: .privacy_Orna, content_Orna: "privacy.png", from: self)
    }

    /// 登出账户（二次确认后清空状态并返回主 Tabbar）
    @objc private func handleLogoutTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        UIAlertController.logout_Orna {
            UserViewModel_Orna.shared_Orna.logout_Orna(logoutType_orna: .logout_orna)
        }
    }

    /// 注销账号（二次确认后进入延迟删除流程）
    @objc private func handleDeleteAccountTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        UIAlertController.delete_Orna {
            UserViewModel_Orna.shared_Orna.logout_Orna(logoutType_orna: .delete_orna)
        }
    }

    // MARK: - 工具方法

    /// 创建统一样式的设置行（图标 + 标题 + 箭头）
    private static func makeRow_Orna(icon_orna: String, title_orna: String, tint_orna: UIColor) -> UIView {
        let container_orna = UIView()
        container_orna.isUserInteractionEnabled = true

        let iconBg_orna = UIView()
        iconBg_orna.backgroundColor = tint_orna.withAlphaComponent(0.15)
        iconBg_orna.layer.cornerRadius = 16
        container_orna.addSubview(iconBg_orna)

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = tint_orna
        iconView_orna.contentMode = .scaleAspectFit
        iconBg_orna.addSubview(iconView_orna)

        let titleLabel_orna = UILabel()
        titleLabel_orna.text = title_orna
        titleLabel_orna.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel_orna.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        container_orna.addSubview(titleLabel_orna)

        let chevron_orna = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron_orna.tintColor = UIColor(hexstring_Orna: "#B5AFCB")
        chevron_orna.contentMode = .scaleAspectFit
        container_orna.addSubview(chevron_orna)

        iconBg_orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        titleLabel_orna.snp.makeConstraints {
            $0.leading.equalTo(iconBg_orna.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        chevron_orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        return container_orna
    }
}
