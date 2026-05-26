import Foundation
import UIKit
import SnapKit

// MARK: 设置页面

/// 设置操作数据结构体
struct NicheSettingItem_Niche {
    let iconName_niche: String
    let title_niche: String
    let iconColor_niche: UIColor
    let isDangerous_niche: Bool
}

/// 设置页面视图控制器
/// 功能：展示 Terms、Privacy、登出、删除账号四个操作入口
/// 设计：渐变头部 + 用户身份卡 + 分区标题 + 圆形渐变图标行 + 危险区深色卡片
class Setting_Niche: UIViewController {

    // MARK: - 数据

    private let _legalItems_niche: [NicheSettingItem_Niche] = [
        NicheSettingItem_Niche(
            iconName_niche: "doc.text.fill",
            title_niche: "Terms of Service",
            iconColor_niche: ColorConfig_Niche.primaryGradientStart_Niche,
            isDangerous_niche: false
        ),
        NicheSettingItem_Niche(
            iconName_niche: "lock.shield.fill",
            title_niche: "Privacy Policy",
            iconColor_niche: ColorConfig_Niche.primaryGradientEnd_Niche,
            isDangerous_niche: false
        )
    ]

    private let _accountItems_niche: [NicheSettingItem_Niche] = [
        NicheSettingItem_Niche(
            iconName_niche: "arrow.left.circle.fill",
            title_niche: "Log Out",
            iconColor_niche: UIColor(hexstring_Niche: "#FC8181"),
            isDangerous_niche: false
        ),
        NicheSettingItem_Niche(
            iconName_niche: "trash.circle.fill",
            title_niche: "Delete Account",
            iconColor_niche: UIColor(hexstring_Niche: "#FC5252"),
            isDangerous_niche: true
        )
    ]

    // MARK: - UI 组件

    private let _headerView_niche = UIView()

    private let _headerOrb_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.10)
        v_niche.layer.cornerRadius = 50
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    private let _backBtn_niche = BackButton_Niche()

    private let _pageTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Settings"
        l_niche.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        l_niche.textColor = .white
        return l_niche
    }()

    private let _pageSubtitle_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Manage your profile & account"
        l_niche.font = UIFont.systemFont(ofSize: 12)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.7)
        return l_niche
    }()

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        return sv_niche
    }()

    private let _contentView_niche = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Niche()
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        // 渐变头部
        view.addSubview(_headerView_niche)
        _headerView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }

        _headerView_niche.addSubview(_headerOrb_niche)
        _headerOrb_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-16)
            make.trailing.equalToSuperview().offset(12)
            make.width.height.equalTo(100)
        }

        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { Navigation_Niche.pop_Niche() }

        _headerView_niche.addSubview(_pageTitleLabel_niche)
        _pageTitleLabel_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-26)
            make.centerX.equalToSuperview()
        }

        _headerView_niche.addSubview(_pageSubtitle_niche)
        _pageSubtitle_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.centerX.equalToSuperview()
        }

        // 滚动区
        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in
            make.top.equalTo(_headerView_niche.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildContent_Niche()
    }

    private func buildContent_Niche() {
        // Legal 分区标题
        let legalTitle_niche = buildSectionTitle_Niche(text: "Legal", color: ColorConfig_Niche.primaryGradientStart_Niche)
        _contentView_niche.addSubview(legalTitle_niche)
        legalTitle_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(22)
        }

        let legalCard_niche = buildItemCard_Niche(items: _legalItems_niche, isDangerZone: false)
        _contentView_niche.addSubview(legalCard_niche)
        legalCard_niche.snp.makeConstraints { make in
            make.top.equalTo(legalTitle_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // Account 分区标题
        let accountTitle_niche = buildSectionTitle_Niche(text: "Account", color: UIColor(hexstring_Niche: "#FC8181"))
        _contentView_niche.addSubview(accountTitle_niche)
        accountTitle_niche.snp.makeConstraints { make in
            make.top.equalTo(legalCard_niche.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(22)
        }

        let accountCard_niche = buildItemCard_Niche(items: _accountItems_niche, isDangerZone: true)
        _contentView_niche.addSubview(accountCard_niche)
        accountCard_niche.snp.makeConstraints { make in
            make.top.equalTo(accountTitle_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    private func buildSectionTitle_Niche(text: String, color: UIColor) -> UIView {
        let container_niche = UIView()
        let dot_niche = UIView()
        dot_niche.backgroundColor = color
        dot_niche.layer.cornerRadius = 4
        container_niche.addSubview(dot_niche)
        dot_niche.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        let lbl_niche = UILabel()
        lbl_niche.text = text.uppercased()
        lbl_niche.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        lbl_niche.textColor = color
        container_niche.addSubview(lbl_niche)
        lbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(dot_niche.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        return container_niche
    }

    /// 构建设置卡片（支持危险区样式）
    private func buildItemCard_Niche(items: [NicheSettingItem_Niche], isDangerZone: Bool) -> UIView {
        let card_niche = UIView()
        card_niche.backgroundColor = isDangerZone ? UIColor(hexstring_Niche: "#FFF5F5") : .white
        card_niche.layer.cornerRadius = 18
        card_niche.layer.shadowColor = (isDangerZone
            ? UIColor(hexstring_Niche: "#FC5252")
            : UIColor(hexstring_Niche: "#B794F6")
        ).withValues(alpha: 0.10).cgColor
        card_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_niche.layer.shadowRadius = 12
        card_niche.layer.shadowOpacity = 1

        if isDangerZone {
            let borderLayer_niche = CAShapeLayer()
            borderLayer_niche.strokeColor = UIColor(hexstring_Niche: "#FC5252").withValues(alpha: 0.15).cgColor
            borderLayer_niche.fillColor = UIColor.clear.cgColor
            borderLayer_niche.lineWidth = 1
            DispatchQueue.main.async {
                borderLayer_niche.path = UIBezierPath(roundedRect: card_niche.bounds, cornerRadius: 18).cgPath
            }
            card_niche.layer.addSublayer(borderLayer_niche)
        }

        var prevRow_niche: UIView? = nil
        for (idx_niche, item_niche) in items.enumerated() {
            let row_niche = buildRow_Niche(item: item_niche)
            card_niche.addSubview(row_niche)
            row_niche.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(68)
                if let prev_niche = prevRow_niche {
                    make.top.equalTo(prev_niche.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                if idx_niche == items.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }
            if idx_niche < items.count - 1 {
                let div_niche = UIView()
                div_niche.backgroundColor = ColorConfig_Niche.divider_Niche
                card_niche.addSubview(div_niche)
                div_niche.snp.makeConstraints { make in
                    make.leading.equalToSuperview().offset(68)
                    make.trailing.equalToSuperview().offset(-16)
                    make.bottom.equalTo(row_niche.snp.bottom)
                    make.height.equalTo(0.5)
                }
            }
            prevRow_niche = row_niche
        }
        return card_niche
    }

    private func buildRow_Niche(item: NicheSettingItem_Niche) -> UIView {
        let row_niche = UIView()
        row_niche.isUserInteractionEnabled = true

        // 圆形渐变图标背景
        let iconCircle_niche = UIView()
        iconCircle_niche.layer.cornerRadius = 20
        iconCircle_niche.backgroundColor = item.iconColor_niche.withValues(alpha: 0.15)
        row_niche.addSubview(iconCircle_niche)
        iconCircle_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        let iconIV_niche = UIImageView()
        let symCfg_niche = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconIV_niche.image = UIImage(systemName: item.iconName_niche, withConfiguration: symCfg_niche)
        iconIV_niche.tintColor = item.iconColor_niche
        iconIV_niche.contentMode = .scaleAspectFit
        iconCircle_niche.addSubview(iconIV_niche)
        iconIV_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        let titleLbl_niche = UILabel()
        titleLbl_niche.text = item.title_niche
        titleLbl_niche.font = UIFont.systemFont(ofSize: 15, weight: item.isDangerous_niche ? .bold : .semibold)
        titleLbl_niche.textColor = item.isDangerous_niche
            ? UIColor(hexstring_Niche: "#FC5252")
            : ColorConfig_Niche.textPrimary_Niche
        row_niche.addSubview(titleLbl_niche)
        titleLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(iconCircle_niche.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-42)
        }

        let arrowIV_niche = UIImageView()
        let arrowCfg_niche = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        arrowIV_niche.image = UIImage(
            systemName: item.isDangerous_niche ? "chevron.right" : "chevron.right",
            withConfiguration: arrowCfg_niche
        )
        arrowIV_niche.tintColor = item.isDangerous_niche
            ? UIColor(hexstring_Niche: "#FC5252").withValues(alpha: 0.5)
            : ColorConfig_Niche.textPlaceholder_Niche
        arrowIV_niche.contentMode = .scaleAspectFit
        row_niche.addSubview(arrowIV_niche)
        arrowIV_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(16)
        }

        let tap_niche = UITapGestureRecognizer(target: self, action: #selector(handleRowTap_Niche(_:)))
        tap_niche.name = item.title_niche
        row_niche.addGestureRecognizer(tap_niche)
        return row_niche
    }

    // MARK: - 渐变

    private func refreshHeaderGradient_Niche() {
        _headerView_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_headerView_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _headerView_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#9B59B6").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#90CDF4").cgColor
        ]
        grad_niche.locations = [0, 0.5, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint   = CGPoint(x: 1, y: 1)
        _headerView_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    // MARK: - 事件

    @objc private func handleRowTap_Niche(_ gesture: UITapGestureRecognizer) {
        guard let name_niche = gesture.name else { return }
        gesture.view?.animatePressDown_Niche { gesture.view?.animatePressUp_Niche() }
        switch name_niche {
        case "Terms of Service":
            ProtocolHelper_Niche.showProtocol_Niche(type_Niche: .terms_Niche, content_Niche: "terms", from: self)
        case "Privacy Policy":
            ProtocolHelper_Niche.showProtocol_Niche(type_Niche: .privacy_Niche, content_Niche: "privacy", from: self)
        case "Log Out":
            UIAlertController.logout_Niche {
                Task { @MainActor in UserViewModel_Niche.shared_Niche.logout_Niche(logoutType_niche: .logout_niche) }
            }
        case "Delete Account":
            UIAlertController.delete_Niche {
                Task { @MainActor in UserViewModel_Niche.shared_Niche.logout_Niche(logoutType_niche: .delete_niche) }
            }
        default: break
        }
    }
}
