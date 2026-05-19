import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面

/// 设置页面视图控制器
/// 核心作用：提供服务条款、隐私政策查看，以及登出、删除账号操作
/// 设计思路：卡片式设置列表，危险操作（登出/删除）独立卡片并以红色警示
class Setting_Lumia: UIViewController {

    // MARK: - 私有属性

    /// 设置项数据源（分区）
    private let sections_Lumia: [(title: String, items: [(icon: String, title: String, color: UIColor, tag: Int)])] = [
        (
            title: "Legal",
            items: [
                ("doc.text", "Terms of Service", ColorConfig_Lumia.textPrimary_Lumia, 0),
                ("hand.raised", "Privacy Policy", ColorConfig_Lumia.textPrimary_Lumia, 1)
            ]
        ),
        (
            title: "Account",
            items: [
                ("rectangle.portrait.and.arrow.right", "Log Out", UIColor(hexstring_Lumia: "#E53E3E"), 2),
                ("trash.fill", "Delete Account", UIColor(hexstring_Lumia: "#E53E3E"), 3)
            ]
        )
    ]

    // MARK: - UI组件

    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .insetGrouped)
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")
        tv_Lumia.separatorColor = ColorConfig_Lumia.divider_Lumia
        tv_Lumia.showsVerticalScrollIndicator = false
        return tv_Lumia
    }()

    private let topBar_Lumia = UIView()
    private let backButton_Lumia = BackButton_Lumia()

    private let pageTitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Settings"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        return lbl_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")

        view.addSubview(topBar_Lumia)
        topBar_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }

        topBar_Lumia.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        topBar_Lumia.addSubview(pageTitleLabel_Lumia)
        pageTitleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Lumia)
            make.centerX.equalToSuperview()
        }

        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(SettingCell_Lumia.self, forCellReuseIdentifier: SettingCell_Lumia.reuseId_Lumia)
    }

    // MARK: - 操作处理

    /// 处理各设置项点击
    private func handleSettingTap_Lumia(tag: Int) {
        switch tag {
        case 0:
            // Terms of Service
            ProtocolHelper_Lumia.showProtocol_Lumia(
                type_Lumia: .terms_Lumia,
                content_Lumia: "terms_image",
                from: self
            )
        case 1:
            // Privacy Policy
            ProtocolHelper_Lumia.showProtocol_Lumia(
                type_Lumia: .privacy_Lumia,
                content_Lumia: "privacy_image",
                from: self
            )
        case 2:
            // 登出
            showLogoutConfirm_Lumia()
        case 3:
            // 删除账号
            showDeleteAccountConfirm_Lumia()
        default:
            break
        }
    }

    /// 显示登出确认弹窗
    private func showLogoutConfirm_Lumia() {
        let alert_Lumia = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert_Lumia.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.logout_Lumia(logoutType_lumia: .logout_lumia)
            }
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }

    /// 显示删除账号确认弹窗
    private func showDeleteAccountConfirm_Lumia() {
        let alert_Lumia = UIAlertController(
            title: "Delete Account",
            message: "This action will permanently delete your account after 24 hours. You can cancel by logging in within 24 hours.",
            preferredStyle: .alert
        )
        alert_Lumia.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.logout_Lumia(logoutType_lumia: .delete_lumia)
            }
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension Setting_Lumia: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections_Lumia.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections_Lumia[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections_Lumia[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: SettingCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! SettingCell_Lumia
        let item_Lumia = sections_Lumia[indexPath.section].items[indexPath.row]
        cell_Lumia.configure_Lumia(icon: item_Lumia.icon, title: item_Lumia.title, color: item_Lumia.color)
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag_Lumia = sections_Lumia[indexPath.section].items[indexPath.row].tag
        handleSettingTap_Lumia(tag: tag_Lumia)
    }
}

// MARK: - 设置 Cell

/// 设置页面 Cell（图标 + 标题 + 箭头）
private class SettingCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "SettingCell_Lumia"

    private let iconContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 10
        return v_Lumia
    }()

    private let iconView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return lbl_Lumia
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        accessoryType = .disclosureIndicator

        contentView.addSubview(iconContainer_Lumia)
        iconContainer_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        iconContainer_Lumia.addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        contentView.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer_Lumia.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure_Lumia(icon: String, title: String, color: UIColor) {
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView_Lumia.image = UIImage(systemName: icon, withConfiguration: cfg_Lumia)
        iconView_Lumia.tintColor = color
        iconContainer_Lumia.backgroundColor = color.withAlphaComponent(0.12)
        titleLabel_Lumia.text = title
        titleLabel_Lumia.textColor = color
    }
}
