import Foundation
import UIKit
import SnapKit

// MARK: - 首页视图控制器
/// 核心作用：独居好物社区首页，展示三大板块
/// 设计思路：
///   - 沉浸式渐变顶部（紧贴屏幕顶部）
///   - 板块一：小众独居好物，一行两列翻转卡片（点击翻转查看详情）
///   - 板块二：用户打卡日常，竖向列表 + 空状态 + 模态发布弹窗（封面/描述/自定义 tag）
///   - 板块三：官方主题征集，任何人可见评论，举报只做提示不删除数据
class Home_Nest: UIViewController {

    // MARK: - 静态数据

    private let goodItems_Nest: [HomeGoodItem_Nest] = [
        HomeGoodItem_Nest(name: "Sleep Diffuser",    desc: "Lavender & cedarwood blend for deep sleep",   detailDesc: "Ultrasonic cold-mist diffuser, covers 30m² room, auto-off timer, 7-color LED. Perfect for winding down after solo work-from-home days.",    icon: "sparkles",            tag: "💤 Sleep",    tint: UIColor(hexstring_Nest: "#B794F6")),
        HomeGoodItem_Nest(name: "Mini Coffee Maker", desc: "One-cup espresso in under 90 seconds",        detailDesc: "Portable 0.3kg pod espresso. Heats water to 90°C in 25s. Works on USB-C power bank—so you can have café vibes in your tiny kitchen.",         icon: "cup.and.saucer.fill", tag: "☕ Morning",  tint: UIColor(hexstring_Nest: "#F6AD55")),
        HomeGoodItem_Nest(name: "Foldable Storage",  desc: "Compact bins that fit every corner",          detailDesc: "Japanese-style fabric box that collapses flat. Comes in 4 neutral tones. Holds up to 8kg. Solo-life game-changer for under-bed clutter.",    icon: "archivebox.fill",     tag: "📦 Organize", tint: UIColor(hexstring_Nest: "#68D391")),
        HomeGoodItem_Nest(name: "Desk Warm Lamp",    desc: "Warm 2700K light, perfect for night reading", detailDesc: "Touch-dimming desk lamp with 3 color modes. Memory function remembers your last brightness. Feels like golden-hour light, every night.",    icon: "lightbulb.fill",      tag: "🌙 Cozy",     tint: UIColor(hexstring_Nest: "#FBB6CE")),
        HomeGoodItem_Nest(name: "Tiny Succulent",    desc: "Zero-maintenance desk companion",             detailDesc: "Echeveria rosette in a hand-crafted cement pot. Thrives on neglect—water every 2 weeks. Adds life without the anxiety of plant parenthood.", icon: "leaf.fill",           tag: "🌿 Green",    tint: UIColor(hexstring_Nest: "#4FD1C5")),
        HomeGoodItem_Nest(name: "Sleep Headphones",  desc: "Ultra-thin side-sleeper friendly buds",       detailDesc: "6mm driver inside a soft cotton headband. 10hr battery. Built-in mic for night-time calls. Ideal companion for solo movie nights in bed.",   icon: "headphones",          tag: "🎵 Sound",    tint: UIColor(hexstring_Nest: "#90CDF4")),
    ]

    private let themes_Nest: [HomeTheme_Nest] = [
        HomeTheme_Nest(title: "First Solo Living Essential", subtitle: "What was the very first item that made your solo life feel like home?",   icon: "house.fill",          accentHex: "#B794F6"),
        HomeTheme_Nest(title: "Birthday Essentials for One", subtitle: "How do you celebrate your birthday beautifully when living alone?",      icon: "birthday.cake.fill",  accentHex: "#FBB6CE"),
        HomeTheme_Nest(title: "Late Night Comfort Items",    subtitle: "Share the items that keep you company during those quiet midnight hours.",icon: "moon.stars.fill",     accentHex: "#F6AD55"),
    ]

    // MARK: - 动态数据

    private var checkIns_Nest: [CheckInPost_Nest] = []

    // MARK: - UI

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.alwaysBounceVertical = true
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest    = UIView()
    private let headerView_Nest     = HomeHeaderView_Nest()

    /// 板块二：打卡列表 StackView（动态刷新）
    private let checkInStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .vertical
        sv_Nest.spacing = 14
        return sv_Nest
    }()

    private let checkInEmptyView_Nest = HomeCheckInEmptyView_Nest()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        setupScrollView_Nest()
        buildHeader_Nest()
        buildSections_Nest()
        reloadCheckIns_Nest()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadCheckIns_Nest),
            name: UserViewModel_Nest.userStateDidChangeNotification_Nest, object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadCheckIns_Nest()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // contentInsetAdjustmentBehavior = .never 禁用了系统自动适配
        // 在此手动补充 tab bar 高度作为底部 inset，确保内容可滚动到底部
        let tabBarH_Nest = tabBarController?.tabBar.frame.height ?? 0
        scrollView_Nest.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarH_Nest + 20, right: 0)
        scrollView_Nest.scrollIndicatorInsets = scrollView_Nest.contentInset
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 布局

    private func setupScrollView_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)
        scrollView_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }
    }

    private func buildHeader_Nest() {
        contentView_Nest.addSubview(headerView_Nest)
        headerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(130)
        }
    }

    private func buildSections_Nest() {
        let s1_Nest = buildGoodItemsSection_Nest()
        let s2_Nest = buildCheckInSection_Nest()
        let s3_Nest = buildThemeSection_Nest()

        contentView_Nest.addSubview(s1_Nest)
        contentView_Nest.addSubview(s2_Nest)
        contentView_Nest.addSubview(s3_Nest)

        s1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(headerView_Nest.snp.bottom).offset(20)
            make_Nest.leading.trailing.equalToSuperview()
        }
        s2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(s1_Nest.snp.bottom).offset(28)
            make_Nest.leading.trailing.equalToSuperview()
        }
        s3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(s2_Nest.snp.bottom).offset(28)
            make_Nest.leading.trailing.equalToSuperview()
            make_Nest.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 板块一：翻转卡片网格

    private func buildGoodItemsSection_Nest() -> UIView {
        let section_Nest = UIView()
        let header_Nest  = makeSectionHeader_Nest(
            title: "Solo Living Finds", subtitle: "Tap to flip & discover ✨",
            iconName: "sparkles.rectangle.stack.fill", tint: ColorConfig_Nest.primaryGradientStart_Nest
        )
        section_Nest.addSubview(header_Nest)
        header_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview()
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
        }

        let pairs_Nest = stride(from: 0, to: goodItems_Nest.count, by: 2).map {
            Array(goodItems_Nest[$0..<min($0 + 2, goodItems_Nest.count)])
        }
        var prevRow_Nest: UIView? = nil
        for (pIdx_Nest, pair_Nest) in pairs_Nest.enumerated() {
            let row_Nest = UIView()
            section_Nest.addSubview(row_Nest)
            row_Nest.snp.makeConstraints { make_Nest in
                make_Nest.top.equalTo(prevRow_Nest?.snp.bottom ?? header_Nest.snp.bottom).offset(12)
                make_Nest.leading.equalToSuperview().offset(14)
                make_Nest.trailing.equalToSuperview().offset(-14)
                make_Nest.height.equalTo(158)
                if pIdx_Nest == pairs_Nest.count - 1 { make_Nest.bottom.equalToSuperview() }
            }
            var prevCard_Nest: HomeFlipCard_Nest? = nil
            for (i_Nest, item_Nest) in pair_Nest.enumerated() {
                let card_Nest = HomeFlipCard_Nest(item: item_Nest)
                row_Nest.addSubview(card_Nest)
                card_Nest.snp.makeConstraints { make_Nest in
                    make_Nest.top.bottom.equalToSuperview()
                    if i_Nest == 0 {
                        make_Nest.leading.equalToSuperview()
                        make_Nest.width.equalToSuperview().multipliedBy(0.5).offset(-4)
                    } else {
                        make_Nest.leading.equalTo(prevCard_Nest!.snp.trailing).offset(8)
                        make_Nest.trailing.equalToSuperview()
                    }
                }
                prevCard_Nest = card_Nest
            }
            prevRow_Nest = row_Nest
        }
        return section_Nest
    }

    // MARK: - 板块二：打卡日常

    private func buildCheckInSection_Nest() -> UIView {
        let section_Nest = UIView()
        let header_Nest  = makeSectionHeader_Nest(
            title: "Daily Check-in", subtitle: "Share your solo living moments 📸",
            iconName: "camera.viewfinder", tint: ColorConfig_Nest.secondaryGradientStart_Nest
        )
        section_Nest.addSubview(header_Nest)
        header_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview()
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
        }

        // 发布按钮
        let postBtn_Nest = buildCheckInPostButton_Nest()
        section_Nest.addSubview(postBtn_Nest)
        postBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(header_Nest.snp.bottom).offset(12)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(48)
        }

        // 打卡竖向列表
        section_Nest.addSubview(checkInEmptyView_Nest)
        section_Nest.addSubview(checkInStack_Nest)
        checkInEmptyView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(postBtn_Nest.snp.bottom).offset(20)
            make_Nest.centerX.equalToSuperview()
            make_Nest.bottom.equalToSuperview().offset(-10)
        }
        checkInStack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(postBtn_Nest.snp.bottom).offset(14)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.bottom.equalToSuperview()
        }
        return section_Nest
    }

    private func buildCheckInPostButton_Nest() -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 24
        v_Nest.layer.borderWidth = 1.5
        v_Nest.layer.borderColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.3).cgColor

        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let icon_Nest = UIImageView(image: UIImage(systemName: "plus.circle.fill", withConfiguration: cfg_Nest))
        icon_Nest.tintColor = ColorConfig_Nest.secondaryGradientStart_Nest

        let lbl_Nest = UILabel()
        lbl_Nest.text = "Share your solo good find today..."
        lbl_Nest.font = UIFont.systemFont(ofSize: 14)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest

        v_Nest.addSubview(icon_Nest)
        v_Nest.addSubview(lbl_Nest)
        icon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(18)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(22)
        }
        lbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(icon_Nest.snp.trailing).offset(10)
            make_Nest.centerY.equalToSuperview()
        }
        v_Nest.isUserInteractionEnabled = true
        v_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPostCheckInTapped_Nest)))
        return v_Nest
    }

    /// 刷新打卡列表
    @objc private func reloadCheckIns_Nest() {
        checkIns_Nest = UserViewModel_Nest.shared_Nest.getCheckIns_Nest()
        checkInStack_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if checkIns_Nest.isEmpty {
            checkInEmptyView_Nest.isHidden = false
            checkInStack_Nest.isHidden = true
        } else {
            checkInEmptyView_Nest.isHidden = true
            checkInStack_Nest.isHidden = false
            for (i_Nest, ci_Nest) in checkIns_Nest.enumerated() {
                let card_Nest = HomeCheckInCard_Nest(checkIn: ci_Nest)
                checkInStack_Nest.addArrangedSubview(card_Nest)
                card_Nest.animateSlideInFromBottom_Nest(
                    offset_Nest: 20,
                    delay_Nest: TimeInterval(i_Nest) * 0.06
                )
            }
        }
    }

    // MARK: - 板块三：官方主题征集

    private func buildThemeSection_Nest() -> UIView {
        let section_Nest = UIView()
        let header_Nest  = makeSectionHeader_Nest(
            title: "Theme Collections", subtitle: "Official topics — tap to join the discussion 🏆",
            iconName: "flag.fill", tint: UIColor(hexstring_Nest: "#F6AD55")
        )
        section_Nest.addSubview(header_Nest)
        header_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview()
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
        }

        let allComments_Nest = LocalData_Nest.shared_Nest.titleList_Nest.flatMap { $0.reviews_Nest }
        var prevCard_Nest: UIView? = nil

        for (i_Nest, theme_Nest) in themes_Nest.enumerated() {
            // 每个主题取若干评论供详情页使用
            let startIdx_Nest = (i_Nest * 4) % max(allComments_Nest.count, 1)
            var themeComments_Nest: [Comment_Nest] = []
            for j_Nest in 0..<min(8, allComments_Nest.count) {
                themeComments_Nest.append(allComments_Nest[(startIdx_Nest + j_Nest) % allComments_Nest.count])
            }

            let card_Nest = makeThemeCard_Nest(theme: theme_Nest, comments: themeComments_Nest)
            section_Nest.addSubview(card_Nest)
            card_Nest.snp.makeConstraints { make_Nest in
                make_Nest.top.equalTo(prevCard_Nest?.snp.bottom ?? header_Nest.snp.bottom).offset(14)
                make_Nest.leading.equalToSuperview().offset(16)
                make_Nest.trailing.equalToSuperview().offset(-16)
                if i_Nest == themes_Nest.count - 1 { make_Nest.bottom.equalToSuperview() }
            }
            prevCard_Nest = card_Nest
        }
        return section_Nest
    }

    /// 主题卡片：只展示主题信息和参与入口，不展示评论列表
    private func makeThemeCard_Nest(theme: HomeTheme_Nest, comments: [Comment_Nest]) -> UIView {
        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        card_Nest.layer.cornerRadius = 20
        card_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        card_Nest.layer.shadowOffset  = CGSize(width: 0, height: 4)
        card_Nest.layer.shadowRadius  = 12
        card_Nest.layer.shadowOpacity = 1

        let accent_Nest = UIColor(hexstring_Nest: theme.accentHex_Nest)

        let iconBg_Nest = UIView()
        iconBg_Nest.backgroundColor = accent_Nest.withAlphaComponent(0.12)
        iconBg_Nest.layer.cornerRadius = 20
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let iconIV_Nest = UIImageView(image: UIImage(systemName: theme.icon_Nest, withConfiguration: cfg_Nest))
        iconIV_Nest.tintColor = accent_Nest
        iconIV_Nest.contentMode = .scaleAspectFit
        iconBg_Nest.addSubview(iconIV_Nest)

        let badge_Nest = UILabel()
        badge_Nest.text = "  🔥 HOT  "
        badge_Nest.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        badge_Nest.textColor = accent_Nest
        badge_Nest.backgroundColor = accent_Nest.withAlphaComponent(0.1)
        badge_Nest.layer.cornerRadius = 9
        badge_Nest.clipsToBounds = true

        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = theme.title_Nest
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        titleLbl_Nest.numberOfLines = 2

        let subLbl_Nest = UILabel()
        subLbl_Nest.text = theme.subtitle_Nest
        subLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        subLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        subLbl_Nest.numberOfLines = 2

        // 底部"参与讨论"行
        let joinRow_Nest = UIView()
        let joinLbl_Nest = UILabel()
        joinLbl_Nest.text = "View Discussion  \(comments.count) comments"
        joinLbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        joinLbl_Nest.textColor = accent_Nest
        let arrowIV_Nest = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowIV_Nest.tintColor = accent_Nest
        arrowIV_Nest.contentMode = .scaleAspectFit
        joinRow_Nest.addSubview(joinLbl_Nest)
        joinRow_Nest.addSubview(arrowIV_Nest)
        joinLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
        }
        arrowIV_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(joinLbl_Nest.snp.trailing).offset(4)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.equalTo(8)
            make_Nest.height.equalTo(14)
        }

        card_Nest.addSubview(iconBg_Nest)
        card_Nest.addSubview(badge_Nest)
        card_Nest.addSubview(titleLbl_Nest)
        card_Nest.addSubview(subLbl_Nest)
        card_Nest.addSubview(joinRow_Nest)

        iconBg_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(16)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.width.height.equalTo(44)
        }
        iconIV_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(22)
        }
        badge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconBg_Nest)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(20)
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconBg_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
        }
        subLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(4)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
        }
        joinRow_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(subLbl_Nest.snp.bottom).offset(14)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.bottom.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(20)
        }

        // 点击整个卡片进入详情
        card_Nest.isUserInteractionEnabled = true
        card_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onThemeCardTapped_Nest(_:))))
        card_Nest.accessibilityLabel = theme.title_Nest  // 用于识别点击哪张卡片

        // 存储主题数据（通过关联对象）
        objc_setAssociatedObject(card_Nest, &HomeThemeCardKey_Nest, theme, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(card_Nest, &HomeThemeCommentsKey_Nest, comments, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return card_Nest
    }

    @objc private func onThemeCardTapped_Nest(_ gesture: UITapGestureRecognizer) {
        guard let card_Nest = gesture.view,
              let theme_Nest = objc_getAssociatedObject(card_Nest, &HomeThemeCardKey_Nest) as? HomeTheme_Nest,
              let comments_Nest = objc_getAssociatedObject(card_Nest, &HomeThemeCommentsKey_Nest) as? [Comment_Nest]
        else { return }
        card_Nest.animatePressDown_Nest { card_Nest.animatePressUp_Nest() }
        let vc_Nest = HomeThemeDetailVC_Nest(theme: theme_Nest, comments: comments_Nest)
        navigationController?.pushViewController(vc_Nest, animated: true)
    }

    /// 评论行：头像 + 用户名 + 内容 + 举报（仅提示，不删数据）
    private func makeThemeCommentRow_Nest(comment: Comment_Nest, isLast: Bool) -> UIView {
        let row_Nest = UIView()
        let avatar_Nest = UserAvatarView_Nest()
        avatar_Nest.configure_Nest(userId_Nest: comment.commentUserId_Nest)

        let nameLbl_Nest = UILabel()
        nameLbl_Nest.text = comment.commentUserName_Nest
        nameLbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nameLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest

        let contentLbl_Nest = UILabel()
        contentLbl_Nest.text = comment.commentContent_Nest
        contentLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        contentLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        contentLbl_Nest.numberOfLines = 0

        // 举报按钮：只弹提示，不删评论数据
        let reportBtn_Nest = UIButton(type: .custom)
        let reportCfg_Nest = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        reportBtn_Nest.setImage(UIImage(systemName: "ellipsis.circle.fill", withConfiguration: reportCfg_Nest), for: .normal)
        reportBtn_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        reportBtn_Nest.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let alert_Nest = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert_Nest.addAction(UIAlertAction(title: "Report Comment", style: .destructive) { _ in
                Utils_Nest.showSuccess_Nest(message_Nest: "Comment reported. Thank you!")
            })
            alert_Nest.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert_Nest, animated: true)
        }, for: .touchUpInside)

        row_Nest.addSubview(avatar_Nest)
        row_Nest.addSubview(nameLbl_Nest)
        row_Nest.addSubview(contentLbl_Nest)
        row_Nest.addSubview(reportBtn_Nest)

        avatar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.top.equalToSuperview().offset(10)
            make_Nest.width.height.equalTo(30)
        }
        reportBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.top.equalToSuperview().offset(10)
            make_Nest.width.height.equalTo(26)
        }
        nameLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(avatar_Nest.snp.trailing).offset(10)
            make_Nest.top.equalTo(avatar_Nest).offset(1)
            make_Nest.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-6)
        }
        contentLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(nameLbl_Nest)
            make_Nest.top.equalTo(nameLbl_Nest.snp.bottom).offset(3)
            make_Nest.trailing.equalToSuperview().offset(-14)
            make_Nest.bottom.equalToSuperview().offset(isLast ? -10 : -8)
        }

        if !isLast {
            let div_Nest = UIView()
            div_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
            row_Nest.addSubview(div_Nest)
            div_Nest.snp.makeConstraints { make_Nest in
                make_Nest.leading.equalToSuperview().offset(58)
                make_Nest.trailing.equalToSuperview().offset(-16)
                make_Nest.bottom.equalToSuperview()
                make_Nest.height.equalTo(0.5)
            }
        }
        return row_Nest
    }

    // MARK: - 通用板块 Header

    private func makeSectionHeader_Nest(title: String, subtitle: String, iconName: String, tint: UIColor) -> UIView {
        let v_Nest = UIView()
        let iconBg_Nest = UIView()
        iconBg_Nest.backgroundColor = tint.withAlphaComponent(0.1)
        iconBg_Nest.layer.cornerRadius = 10

        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        let icon_Nest = UIImageView(image: UIImage(systemName: iconName, withConfiguration: cfg_Nest))
        icon_Nest.tintColor = tint
        icon_Nest.contentMode = .scaleAspectFit
        iconBg_Nest.addSubview(icon_Nest)

        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = title
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 17, weight: .black)
        titleLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest

        let subLbl_Nest = UILabel()
        subLbl_Nest.text = subtitle
        subLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        subLbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest

        v_Nest.addSubview(iconBg_Nest)
        v_Nest.addSubview(titleLbl_Nest)
        v_Nest.addSubview(subLbl_Nest)

        iconBg_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.top.equalToSuperview()
            make_Nest.width.height.equalTo(36)
        }
        icon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(18)
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(iconBg_Nest.snp.trailing).offset(10)
            make_Nest.centerY.equalTo(iconBg_Nest).offset(-6)
        }
        subLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLbl_Nest)
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(2)
            make_Nest.bottom.equalToSuperview()
        }
        return v_Nest
    }

    // MARK: - 事件

    @objc private func onPostCheckInTapped_Nest() {
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
            return
        }
        let vc_Nest = HomeCheckInPublishVC_Nest()
        vc_Nest.onPublished_Nest = { [weak self] in self?.reloadCheckIns_Nest() }
        let nav_Nest = UINavigationController(rootViewController: vc_Nest)
        nav_Nest.modalPresentationStyle = .pageSheet
        if let sheet_Nest = nav_Nest.sheetPresentationController {
            sheet_Nest.detents = [.large()]
            sheet_Nest.prefersGrabberVisible = true
        }
        present(nav_Nest, animated: true)
    }
}

// MARK: - HomeHeaderView_Nest
/// 首页沉浸式渐变顶栏：主色渐变 + 波浪底边 + 装饰气泡 + App 标题
class HomeHeaderView_Nest: UIView {

    private var gradientLayer_Nest: CAGradientLayer?
    private let bubble1_Nest = HomeHeaderView_Nest.makeBubble_Nest(size: 120, alpha: 0.08)
    private let bubble2_Nest = HomeHeaderView_Nest.makeBubble_Nest(size: 65,  alpha: 0.10)

    private let titleLbl_Nest: UILabel = {
        let l_Nest = UILabel()
        l_Nest.text = "Nest"
        l_Nest.font = UIFont.systemFont(ofSize: 28, weight: .black)
        l_Nest.textColor = .white
        return l_Nest
    }()

    private let sloganLbl_Nest: UILabel = {
        let l_Nest = UILabel()
        l_Nest.text = "Discover solo living goods ✨"
        l_Nest.font = UIFont.systemFont(ofSize: 13)
        l_Nest.textColor = UIColor.white.withAlphaComponent(0.8)
        return l_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(titleLbl_Nest)
        addSubview(sloganLbl_Nest)
        bubble1_Nest.snp.makeConstraints { m in m.top.equalToSuperview().offset(-20); m.trailing.equalToSuperview().offset(20); m.width.height.equalTo(120) }
        bubble2_Nest.snp.makeConstraints { m in m.bottom.equalToSuperview().offset(15); m.trailing.equalToSuperview().offset(-80); m.width.height.equalTo(65) }
        titleLbl_Nest.snp.makeConstraints  { m in m.leading.equalToSuperview().offset(20); m.top.equalToSuperview().offset(58) }
        sloganLbl_Nest.snp.makeConstraints { m in m.leading.equalTo(titleLbl_Nest); m.top.equalTo(titleLbl_Nest.snp.bottom).offset(3) }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 在尺寸确定后刷新渐变与波浪遮罩，避免只依赖父控制器时序导致首帧未绘制
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout_Nest()
    }

    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView(); v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2; return v_Nest
    }

    /// 功能：同步渐变尺寸与圆底波浪形遮罩
    /// 注意：作 layer.mask 的 CAShapeLayer 必须设置与头图一致的 frame，否则在 frame 为 .zero 时整块内容会被错误遮罩，只露出父级浅底，白字会「看不见」
    func updateLayout_Nest() {
        let b_Nest = bounds
        guard b_Nest.width > 0, b_Nest.height > 0 else { return }
        gradientLayer_Nest?.frame = b_Nest
        let p_Nest = UIBezierPath()
        p_Nest.move(to: .zero)
        p_Nest.addLine(to: CGPoint(x: b_Nest.width, y: 0))
        p_Nest.addLine(to: CGPoint(x: b_Nest.width, y: b_Nest.height - 10))
        p_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: b_Nest.height - 10),
            controlPoint: CGPoint(x: b_Nest.width / 2, y: b_Nest.height + 16)
        )
        p_Nest.close()
        let m_Nest = CAShapeLayer()
        m_Nest.frame = b_Nest
        m_Nest.path = p_Nest.cgPath
        m_Nest.fillColor = UIColor.white.cgColor
        layer.mask = m_Nest
    }
}

// MARK: - HomeFlipCard_Nest
/// 可翻转的独居好物卡片
/// 点击后以 3D 翻转动画切换正面（图标/名称/描述）和背面（详细说明/小贴士）
class HomeFlipCard_Nest: UIView {

    private let item_Nest: HomeGoodItem_Nest
    private var isFlipped_Nest = false

    // 正面
    private let frontView_Nest = UIView()
    // 背面
    private let backView_Nest  = UIView()

    /// - Parameter item: 好物数据
    init(item: HomeGoodItem_Nest) {
        self.item_Nest = item
        super.init(frame: .zero)
        layer.cornerRadius = 18
        clipsToBounds = false
        buildFront_Nest()
        buildBack_Nest()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped_Nest)))
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildFront_Nest() {
        frontView_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        frontView_Nest.layer.cornerRadius = 18
        frontView_Nest.layer.shadowColor   = item_Nest.tint_Nest.withAlphaComponent(0.2).cgColor
        frontView_Nest.layer.shadowOffset  = CGSize(width: 0, height: 4)
        frontView_Nest.layer.shadowRadius  = 10
        frontView_Nest.layer.shadowOpacity = 1

        let iconBg_Nest = UIView()
        iconBg_Nest.backgroundColor = item_Nest.tint_Nest.withAlphaComponent(0.12)
        iconBg_Nest.layer.cornerRadius = 16

        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let iconIV_Nest = UIImageView(image: UIImage(systemName: item_Nest.icon_Nest, withConfiguration: cfg_Nest))
        iconIV_Nest.tintColor = item_Nest.tint_Nest
        iconIV_Nest.contentMode = .scaleAspectFit
        iconBg_Nest.addSubview(iconIV_Nest)

        let tagLbl_Nest = UILabel()
        tagLbl_Nest.text = item_Nest.tag_Nest
        tagLbl_Nest.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        tagLbl_Nest.textColor = item_Nest.tint_Nest
        tagLbl_Nest.backgroundColor = item_Nest.tint_Nest.withAlphaComponent(0.1)
        tagLbl_Nest.layer.cornerRadius = 8
        tagLbl_Nest.clipsToBounds = true
        tagLbl_Nest.textAlignment = .center

        let nameLbl_Nest = UILabel()
        nameLbl_Nest.text = item_Nest.name_Nest
        nameLbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        nameLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest

        let descLbl_Nest = UILabel()
        descLbl_Nest.text = item_Nest.desc_Nest
        descLbl_Nest.font = UIFont.systemFont(ofSize: 11)
        descLbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        descLbl_Nest.numberOfLines = 2

        let hintLbl_Nest = UILabel()
        hintLbl_Nest.text = "Tap to flip ↺"
        hintLbl_Nest.font = UIFont.systemFont(ofSize: 10)
        hintLbl_Nest.textColor = item_Nest.tint_Nest.withAlphaComponent(0.6)
        hintLbl_Nest.textAlignment = .right

        frontView_Nest.addSubview(iconBg_Nest)
        frontView_Nest.addSubview(tagLbl_Nest)
        frontView_Nest.addSubview(nameLbl_Nest)
        frontView_Nest.addSubview(descLbl_Nest)
        frontView_Nest.addSubview(hintLbl_Nest)

        addSubview(frontView_Nest)
        frontView_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        iconBg_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(14)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.width.height.equalTo(44)
        }
        iconIV_Nest.snp.makeConstraints { make_Nest in make_Nest.center.equalToSuperview(); make_Nest.width.height.equalTo(24) }
        tagLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerY.equalTo(iconBg_Nest)
            make_Nest.trailing.equalToSuperview().offset(-12)
            make_Nest.height.equalTo(20)
        }
        nameLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconBg_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.trailing.equalToSuperview().offset(-10)
        }
        descLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLbl_Nest.snp.bottom).offset(5)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.trailing.equalToSuperview().offset(-10)
        }
        hintLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-12)
            make_Nest.bottom.equalToSuperview().offset(-12)
        }
    }

    private func buildBack_Nest() {
        backView_Nest.backgroundColor = item_Nest.tint_Nest
        backView_Nest.layer.cornerRadius = 18
        backView_Nest.layer.shadowColor   = item_Nest.tint_Nest.withAlphaComponent(0.4).cgColor
        backView_Nest.layer.shadowOffset  = CGSize(width: 0, height: 6)
        backView_Nest.layer.shadowRadius  = 12
        backView_Nest.layer.shadowOpacity = 1
        backView_Nest.isHidden = true

        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = item_Nest.name_Nest
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .black)
        titleLbl_Nest.textColor = .white
        titleLbl_Nest.numberOfLines = 1

        let detailLbl_Nest = UILabel()
        detailLbl_Nest.text = item_Nest.detailDesc_Nest
        detailLbl_Nest.font = UIFont.systemFont(ofSize: 11)
        detailLbl_Nest.textColor = UIColor.white.withAlphaComponent(0.9)
        detailLbl_Nest.numberOfLines = 0

        let backHint_Nest = UILabel()
        backHint_Nest.text = "Tap to flip back ↺"
        backHint_Nest.font = UIFont.systemFont(ofSize: 10)
        backHint_Nest.textColor = UIColor.white.withAlphaComponent(0.7)
        backHint_Nest.textAlignment = .right

        backView_Nest.addSubview(titleLbl_Nest)
        backView_Nest.addSubview(detailLbl_Nest)
        backView_Nest.addSubview(backHint_Nest)

        addSubview(backView_Nest)
        backView_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(16)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.trailing.equalToSuperview().offset(-14)
        }
        detailLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(8)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.trailing.equalToSuperview().offset(-14)
        }
        backHint_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-12)
            make_Nest.bottom.equalToSuperview().offset(-12)
        }
    }

    @objc private func onTapped_Nest() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let fromView_Nest = isFlipped_Nest ? backView_Nest  : frontView_Nest
        let toView_Nest   = isFlipped_Nest ? frontView_Nest : backView_Nest
        let dir_Nest: UIView.AnimationOptions = isFlipped_Nest ? .transitionFlipFromLeft : .transitionFlipFromRight

        UIView.transition(with: self, duration: 0.55, options: [dir_Nest, .curveEaseInOut]) {
            fromView_Nest.isHidden = true
            toView_Nest.isHidden   = false
        }
        isFlipped_Nest.toggle()
    }
}

// MARK: - HomeCheckInCard_Nest
/// 打卡记录卡片（竖向列表项）
/// 展示封面图（或占位）、描述内容、自定义 tag 标签行、发布日期
class HomeCheckInCard_Nest: UIView {

    private let checkIn_Nest: CheckInPost_Nest

    init(checkIn: CheckInPost_Nest) {
        self.checkIn_Nest = checkIn
        super.init(frame: .zero)
        backgroundColor = ColorConfig_Nest.cardBackground_Nest
        layer.cornerRadius = 18
        layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 3)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 1
        buildUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Nest() {
        // 封面图
        let coverView_Nest = UIView()
        coverView_Nest.layer.cornerRadius = 14
        coverView_Nest.clipsToBounds = true
        coverView_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)

        let coverIV_Nest = UIImageView()
        coverIV_Nest.contentMode = .scaleAspectFill
        coverIV_Nest.clipsToBounds = true
        if let path_Nest = checkIn_Nest.coverImagePath_Nest {
            if let img_Nest = UIImage(contentsOfFile: path_Nest) ?? UIImage(named: path_Nest) {
                coverIV_Nest.image = img_Nest
                coverView_Nest.backgroundColor = .clear
            }
        }
        if coverIV_Nest.image == nil {
            let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 26, weight: .light)
            let placeholder_Nest = UIImageView(image: UIImage(systemName: "photo.fill", withConfiguration: cfg_Nest))
            placeholder_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.4)
            placeholder_Nest.contentMode = .scaleAspectFit
            coverView_Nest.addSubview(placeholder_Nest)
            placeholder_Nest.snp.makeConstraints { make_Nest in make_Nest.center.equalToSuperview(); make_Nest.width.height.equalTo(32) }
        }
        coverView_Nest.addSubview(coverIV_Nest)
        coverIV_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }

        // 描述
        let descLbl_Nest = UILabel()
        descLbl_Nest.text = checkIn_Nest.descContent_Nest
        descLbl_Nest.font = UIFont.systemFont(ofSize: 14)
        descLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        descLbl_Nest.numberOfLines = 3

        // Tag 标签行
        let tagRow_Nest = buildTagRow_Nest(tags: checkIn_Nest.tags_Nest)

        // 日期
        let dateLbl_Nest = UILabel()
        dateLbl_Nest.text = checkIn_Nest.dateString_Nest
        dateLbl_Nest.font = UIFont.systemFont(ofSize: 11)
        dateLbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest

        addSubview(coverView_Nest)
        addSubview(descLbl_Nest)
        addSubview(tagRow_Nest)
        addSubview(dateLbl_Nest)

        coverView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview().inset(12)
            make_Nest.height.equalTo(140)
        }
        descLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(coverView_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.trailing.equalToSuperview().offset(-14)
        }
        tagRow_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(descLbl_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.trailing.equalToSuperview().offset(-14)
        }
        dateLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(tagRow_Nest.snp.bottom).offset(8)
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.bottom.equalToSuperview().offset(-12)
        }
    }

    /// 生成 tag 标签横排
    private func buildTagRow_Nest(tags: [String]) -> UIView {
        let wrapper_Nest = UIView()
        var prevTag_Nest: UIView? = nil
        for tag_Nest in tags {
            let lbl_Nest = UILabel()
            lbl_Nest.text = " \(tag_Nest) "
            lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            lbl_Nest.textColor = ColorConfig_Nest.primaryGradientStart_Nest
            lbl_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
            lbl_Nest.layer.cornerRadius = 9
            lbl_Nest.clipsToBounds = true
            wrapper_Nest.addSubview(lbl_Nest)
            lbl_Nest.snp.makeConstraints { make_Nest in
                make_Nest.top.bottom.equalToSuperview()
                make_Nest.height.equalTo(22)
                if let prev_Nest = prevTag_Nest {
                    make_Nest.leading.equalTo(prev_Nest.snp.trailing).offset(8)
                } else {
                    make_Nest.leading.equalToSuperview()
                }
            }
            prevTag_Nest = lbl_Nest
        }
        if prevTag_Nest == nil {
            wrapper_Nest.snp.makeConstraints { make_Nest in make_Nest.height.equalTo(0) }
        }
        return wrapper_Nest
    }
}

// MARK: - HomeCheckInEmptyView_Nest
/// 打卡列表空状态视图
private class HomeCheckInEmptyView_Nest: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        let icon_Nest = UIImageView(image: UIImage(systemName: "camera.on.rectangle", withConfiguration: cfg_Nest))
        icon_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        icon_Nest.contentMode = .scaleAspectFit

        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = "No Check-ins Yet"
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        titleLbl_Nest.textAlignment = .center

        let subLbl_Nest = UILabel()
        subLbl_Nest.text = "Be the first to share your solo living moment!"
        subLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        subLbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        subLbl_Nest.textAlignment = .center
        subLbl_Nest.numberOfLines = 2

        addSubview(icon_Nest)
        addSubview(titleLbl_Nest)
        addSubview(subLbl_Nest)

        icon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(50)
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(icon_Nest.snp.bottom).offset(12)
            make_Nest.centerX.equalToSuperview()
        }
        subLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(6)
            make_Nest.centerX.equalToSuperview()
            make_Nest.width.lessThanOrEqualTo(260)
            make_Nest.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - HomeCheckInPublishVC_Nest
/// 打卡发布模态页面
/// 功能：上传封面图、填写描述、选择/添加自定义 tag 标签，提交发布到当前用户 CheckIn 列表
class HomeCheckInPublishVC_Nest: UIViewController {

    var onPublished_Nest: (() -> Void)?

    // MARK: - 私有状态
    private var selectedImage_Nest: UIImage?
    private var selectedTags_Nest:  Set<String> = []

    // MARK: - 预设 Tag
    private let presetTags_Nest = ["☕ Morning","💤 Sleep","🌿 Green","📦 Organize","🌙 Cozy","🎵 Sound","🏠 Living","✨ Finds"]

    // MARK: - UI

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        return sv_Nest
    }()
    private let contentView_Nest = UIView()

    private let coverImageView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        iv_Nest.contentMode = .scaleAspectFill
        iv_Nest.clipsToBounds = true
        iv_Nest.layer.cornerRadius = 16
        iv_Nest.layer.borderWidth  = 1.5
        iv_Nest.layer.borderColor  = ColorConfig_Nest.border_Nest.cgColor
        return iv_Nest
    }()

    private let coverHintLbl_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "+ Add Cover Photo"
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let descTextView_Nest: UITextView = {
        let tv_Nest = UITextView()
        tv_Nest.font = UIFont.systemFont(ofSize: 15)
        tv_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tv_Nest.layer.cornerRadius = 14
        tv_Nest.layer.borderWidth  = 1.5
        tv_Nest.layer.borderColor  = ColorConfig_Nest.border_Nest.cgColor
        tv_Nest.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return tv_Nest
    }()

    private let descPlaceholder_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Describe your solo living moment..."
        lbl_Nest.font = UIFont.systemFont(ofSize: 15)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.isUserInteractionEnabled = false
        return lbl_Nest
    }()

    private let tagWrap_Nest = UIView()
    private var tagButtons_Nest: [UIButton] = []

    private let publishBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest
        v_Nest.layer.cornerRadius = 26
        v_Nest.layer.shadowColor   = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.4).cgColor
        v_Nest.layer.shadowOffset  = CGSize(width: 0, height: 6)
        v_Nest.layer.shadowRadius  = 14
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        navigationItem.title = "New Check-in"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain, target: self, action: #selector(onCancelTapped_Nest)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Nest.textPrimary_Nest
        buildUI_Nest()
    }

    // MARK: - UI 构建

    private func buildUI_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)
        scrollView_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }

        // 封面
        coverImageView_Nest.addSubview(coverHintLbl_Nest)
        coverHintLbl_Nest.snp.makeConstraints { make_Nest in make_Nest.center.equalToSuperview() }
        coverImageView_Nest.isUserInteractionEnabled = true
        coverImageView_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCoverTapped_Nest)))

        // 描述
        descTextView_Nest.delegate = self
        descTextView_Nest.addSubview(descPlaceholder_Nest)
        descPlaceholder_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(13)
            make_Nest.leading.equalToSuperview().offset(14)
        }

        // Tag 区域
        buildTagButtons_Nest()

        // 发布按钮
        let publishLbl_Nest = UILabel()
        publishLbl_Nest.text = "Publish Check-in"
        publishLbl_Nest.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        publishLbl_Nest.textColor = .white
        publishBtn_Nest.addSubview(publishLbl_Nest)
        publishLbl_Nest.snp.makeConstraints { make_Nest in make_Nest.center.equalToSuperview() }
        publishBtn_Nest.isUserInteractionEnabled = true
        publishBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPublishTapped_Nest)))

        // 标签
        let coverLabel_Nest = makeFormLabel_Nest("Cover Photo")
        let descLabel_Nest  = makeFormLabel_Nest("Description")
        let tagLabel_Nest   = makeFormLabel_Nest("Tags  (tap to select)")

        contentView_Nest.addSubview(coverLabel_Nest)
        contentView_Nest.addSubview(coverImageView_Nest)
        contentView_Nest.addSubview(descLabel_Nest)
        contentView_Nest.addSubview(descTextView_Nest)
        contentView_Nest.addSubview(tagLabel_Nest)
        contentView_Nest.addSubview(tagWrap_Nest)
        contentView_Nest.addSubview(publishBtn_Nest)

        coverLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(20)
            make_Nest.leading.equalToSuperview().offset(20)
        }
        coverImageView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(coverLabel_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(180)
        }
        descLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(coverImageView_Nest.snp.bottom).offset(20)
            make_Nest.leading.equalToSuperview().offset(20)
        }
        descTextView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(descLabel_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(110)
        }
        tagLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(descTextView_Nest.snp.bottom).offset(20)
            make_Nest.leading.equalToSuperview().offset(20)
        }
        tagWrap_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(tagLabel_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
        }
        publishBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(tagWrap_Nest.snp.bottom).offset(28)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(52)
            make_Nest.bottom.equalToSuperview().offset(-40)
        }
    }

    /// 生成标签选择按钮网格
    /// 生成标签选择按钮：每行 4 个，使用 UIStackView 确保对齐不遮挡
    private func buildTagButtons_Nest() {
        let outerStack_Nest = UIStackView()
        outerStack_Nest.axis = .vertical
        outerStack_Nest.spacing = 10
        outerStack_Nest.distribution = .fillEqually

        let rowSize_Nest = 4
        let rows_Nest = stride(from: 0, to: presetTags_Nest.count, by: rowSize_Nest).map {
            Array(presetTags_Nest[$0..<min($0 + rowSize_Nest, presetTags_Nest.count)])
        }

        for row_Nest in rows_Nest {
            let rowStack_Nest = UIStackView()
            rowStack_Nest.axis = .horizontal
            rowStack_Nest.spacing = 8
            rowStack_Nest.distribution = .fillEqually

            for tag_Nest in row_Nest {
                let btn_Nest = UIButton(type: .custom)
                btn_Nest.setTitle(tag_Nest, for: .normal)
                btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                btn_Nest.titleLabel?.adjustsFontSizeToFitWidth = true
                btn_Nest.titleLabel?.minimumScaleFactor = 0.8
                btn_Nest.setTitleColor(ColorConfig_Nest.textSecondary_Nest, for: .normal)
                btn_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
                btn_Nest.layer.cornerRadius = 15
                btn_Nest.layer.borderWidth  = 1.5
                btn_Nest.layer.borderColor  = ColorConfig_Nest.border_Nest.cgColor
                btn_Nest.snp.makeConstraints { make_Nest in make_Nest.height.equalTo(34) }
                btn_Nest.addTarget(self, action: #selector(onTagTapped_Nest(_:)), for: .touchUpInside)
                rowStack_Nest.addArrangedSubview(btn_Nest)
                tagButtons_Nest.append(btn_Nest)
            }
            // 补齐最后一行（不足 4 个时填充空白占位）
            while rowStack_Nest.arrangedSubviews.count < rowSize_Nest {
                let spacer_Nest = UIView()
                rowStack_Nest.addArrangedSubview(spacer_Nest)
            }
            outerStack_Nest.addArrangedSubview(rowStack_Nest)
        }

        tagWrap_Nest.addSubview(outerStack_Nest)
        outerStack_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
    }

    private func makeFormLabel_Nest(_ text: String) -> UILabel {
        let lbl_Nest = UILabel()
        lbl_Nest.text = text
        lbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        return lbl_Nest
    }

    // MARK: - 事件

    @objc private func onCancelTapped_Nest() { dismiss(animated: true) }

    @objc private func onCoverTapped_Nest() {
        MediaPickerHelper_Nest.pickImage_Nest(from: self) { [weak self] image_Nest in
            guard let self, let image_Nest else { return }
            self.selectedImage_Nest = image_Nest
            self.coverImageView_Nest.image = image_Nest
            self.coverHintLbl_Nest.isHidden = true
        }
    }

    @objc private func onTagTapped_Nest(_ btn_Nest: UIButton) {
        guard let tag_Nest = btn_Nest.titleLabel?.text?.trimmingCharacters(in: .whitespaces) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if selectedTags_Nest.contains(tag_Nest) {
            selectedTags_Nest.remove(tag_Nest)
            btn_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
            btn_Nest.setTitleColor(ColorConfig_Nest.textSecondary_Nest, for: .normal)
            btn_Nest.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        } else {
            selectedTags_Nest.insert(tag_Nest)
            btn_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
            btn_Nest.setTitleColor(ColorConfig_Nest.primaryGradientStart_Nest, for: .normal)
            btn_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.cgColor
        }
    }

    @objc private func onPublishTapped_Nest() {
        let desc_Nest = descTextView_Nest.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !desc_Nest.isEmpty else {
            Utils_Nest.showError_Nest(message_Nest: "Please write something about your find.")
            return
        }

        var coverPath_Nest: String? = nil
        if let img_Nest = selectedImage_Nest,
           let data_Nest = img_Nest.jpegData(compressionQuality: 0.8) {
            let path_Nest = FileManager.default.temporaryDirectory
                .appendingPathComponent("checkin_cover_\(Int(Date().timeIntervalSince1970)).jpg").path
            try? data_Nest.write(to: URL(fileURLWithPath: path_Nest))
            coverPath_Nest = path_Nest
        }

        let formatter_Nest = DateFormatter()
        formatter_Nest.dateStyle = .medium
        let dateStr_Nest = formatter_Nest.string(from: Date())

        let checkIn_Nest = CheckInPost_Nest(
            checkInId_Nest: Int(Date().timeIntervalSince1970),
            coverImagePath_Nest: coverPath_Nest,
            descContent_Nest: desc_Nest,
            tags_Nest: Array(selectedTags_Nest),
            dateString_Nest: dateStr_Nest
        )
        UserViewModel_Nest.shared_Nest.addCheckIn_Nest(checkIn_nest: checkIn_Nest)
        publishBtn_Nest.animatePulse_Nest()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        dismiss(animated: true) { [weak self] in
            self?.onPublished_Nest?()
        }
    }
}

// MARK: - UITextViewDelegate

extension HomeCheckInPublishVC_Nest: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder_Nest.isHidden = !textView.text.isEmpty
    }
}

// MARK: - 关联对象 Key（主题卡片存储数据用）
private var HomeThemeCardKey_Nest     = "HomeThemeCard"
private var HomeThemeCommentsKey_Nest = "HomeThemeComments"

// MARK: - HomeThemeDetailVC_Nest
/// 主题征集详情页
/// 设计思路：渐变顶栏（返回 + 主题标题）+ 评论列表 + 底部输入栏
/// 任何人可查看评论，登录用户可发送评论（举报只做提示不删数据）
class HomeThemeDetailVC_Nest: UIViewController {

    // MARK: - 数据
    private let theme_Nest:    HomeTheme_Nest
    private var comments_Nest: [Comment_Nest]

    init(theme: HomeTheme_Nest, comments: [Comment_Nest]) {
        self.theme_Nest    = theme
        self.comments_Nest = comments
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let headerView_Nest = UIView()
    private var headerGl_Nest: CAGradientLayer?

    private let tableView_Nest: UITableView = {
        let tv_Nest = UITableView(frame: .zero, style: .plain)
        tv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tv_Nest.separatorStyle  = .none
        tv_Nest.showsVerticalScrollIndicator = false
        tv_Nest.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv_Nest
    }()

    private let inputBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 20
        v_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset  = CGSize(width: 0, height: -3)
        v_Nest.layer.shadowRadius  = 10
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    private let inputField_Nest: UITextField = {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = "Share your story..."
        tf_Nest.font = UIFont.systemFont(ofSize: 14)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tf_Nest.layer.cornerRadius = 18
        tf_Nest.layer.borderWidth  = 1.2
        tf_Nest.layer.borderColor  = ColorConfig_Nest.border_Nest.cgColor
        let pad_Nest = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf_Nest.leftView = pad_Nest
        tf_Nest.leftViewMode = .always
        tf_Nest.returnKeyType = .send
        return tf_Nest
    }()

    private let sendContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()

    private let sendBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        btn_Nest.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Nest), for: .normal)
        btn_Nest.tintColor = .white
        btn_Nest.backgroundColor = .clear
        return btn_Nest
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildHeader_Nest()
        buildTableAndInput_Nest()
        bindKeyboard_Nest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGl_Nest?.frame = headerView_Nest.bounds
        updateHeaderMask_Nest()
    }

    // MARK: - 构建

    private func buildHeader_Nest() {
        headerView_Nest.clipsToBounds = true
        let accent_Nest = UIColor(hexstring_Nest: theme_Nest.accentHex_Nest)
        let gl_Nest = CAGradientLayer()
        gl_Nest.colors = [accent_Nest.cgColor, accent_Nest.withAlphaComponent(0.6).cgColor]
        gl_Nest.startPoint = CGPoint(x: 0, y: 0)
        gl_Nest.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Nest.layer.insertSublayer(gl_Nest, at: 0)
        headerGl_Nest = gl_Nest

        // 装饰气泡
        let bubble_Nest = UIView()
        bubble_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bubble_Nest.layer.cornerRadius = 55
        headerView_Nest.addSubview(bubble_Nest)
        bubble_Nest.snp.makeConstraints { m in m.top.equalToSuperview().offset(-20); m.trailing.equalToSuperview().offset(20); m.width.height.equalTo(110) }

        // 返回按钮
        let backBtn_Nest = UIView()
        backBtn_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        backBtn_Nest.layer.cornerRadius = 18
        let backIV_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        backIV_Nest.tintColor = .white
        backIV_Nest.contentMode = .scaleAspectFit
        backBtn_Nest.addSubview(backIV_Nest)
        backIV_Nest.snp.makeConstraints { m in m.center.equalToSuperview(); m.width.height.equalTo(15) }
        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBack_Nest)))
        headerView_Nest.addSubview(backBtn_Nest)
        backBtn_Nest.snp.makeConstraints { m in
            m.top.equalToSuperview().offset(54)
            m.leading.equalToSuperview().offset(16)
            m.width.height.equalTo(36)
        }

        // 标题
        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = theme_Nest.title_Nest
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLbl_Nest.textColor = .white
        titleLbl_Nest.numberOfLines = 2

        let subLbl_Nest = UILabel()
        subLbl_Nest.text = theme_Nest.subtitle_Nest
        subLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        subLbl_Nest.textColor = UIColor.white.withAlphaComponent(0.8)
        subLbl_Nest.numberOfLines = 2

        headerView_Nest.addSubview(titleLbl_Nest)
        headerView_Nest.addSubview(subLbl_Nest)
        titleLbl_Nest.snp.makeConstraints { m in
            m.top.equalTo(backBtn_Nest.snp.bottom).offset(10)
            m.leading.equalToSuperview().offset(16)
            m.trailing.equalToSuperview().offset(-16)
        }
        subLbl_Nest.snp.makeConstraints { m in
            m.top.equalTo(titleLbl_Nest.snp.bottom).offset(4)
            m.leading.equalToSuperview().offset(16)
            m.trailing.equalToSuperview().offset(-16)
        }

        view.addSubview(headerView_Nest)
        headerView_Nest.snp.makeConstraints { m in
            m.top.leading.trailing.equalToSuperview()
            m.height.equalTo(170)
        }
    }

    private func buildTableAndInput_Nest() {
        sendContainer_Nest.addSubview(sendBtn_Nest)
        sendBtn_Nest.snp.makeConstraints { m in m.edges.equalToSuperview() }
        sendBtn_Nest.addTarget(self, action: #selector(onSendTapped_Nest), for: .touchUpInside)

        inputBar_Nest.addSubview(inputField_Nest)
        inputBar_Nest.addSubview(sendContainer_Nest)
        view.addSubview(inputBar_Nest)

        inputBar_Nest.snp.makeConstraints { m in
            m.leading.trailing.bottom.equalToSuperview()
            m.height.equalTo(66)
        }
        sendContainer_Nest.snp.makeConstraints { m in
            m.trailing.equalToSuperview().offset(-14)
            m.centerY.equalToSuperview().offset(-2)
            m.width.height.equalTo(36)
        }
        inputField_Nest.snp.makeConstraints { m in
            m.leading.equalToSuperview().offset(16)
            m.trailing.equalTo(sendContainer_Nest.snp.leading).offset(-10)
            m.centerY.equalTo(sendContainer_Nest)
            m.height.equalTo(38)
        }

        tableView_Nest.dataSource = self
        tableView_Nest.delegate   = self
        view.addSubview(tableView_Nest)
        tableView_Nest.snp.makeConstraints { m in
            m.top.equalTo(headerView_Nest.snp.bottom)
            m.leading.trailing.equalToSuperview()
            m.bottom.equalTo(inputBar_Nest.snp.top)
        }
        inputField_Nest.delegate = self

        let tap_Nest = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Nest))
        tap_Nest.cancelsTouchesInView = false
        tableView_Nest.addGestureRecognizer(tap_Nest)
    }

    private func updateHeaderMask_Nest() {
        let p_Nest = UIBezierPath()
        p_Nest.move(to: .zero)
        p_Nest.addLine(to: CGPoint(x: headerView_Nest.bounds.width, y: 0))
        p_Nest.addLine(to: CGPoint(x: headerView_Nest.bounds.width, y: headerView_Nest.bounds.height - 10))
        p_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: headerView_Nest.bounds.height - 10),
            controlPoint: CGPoint(x: headerView_Nest.bounds.width / 2, y: headerView_Nest.bounds.height + 16)
        )
        p_Nest.close()
        let m_Nest = CAShapeLayer(); m_Nest.path = p_Nest.cgPath
        headerView_Nest.layer.mask = m_Nest
    }

    private func bindKeyboard_Nest() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow_Nest(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide_Nest(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 事件

    @objc private func onBack_Nest() { navigationController?.popViewController(animated: true) }

    @objc private func dismissKeyboard_Nest() { view.endEditing(true) }

    @objc private func onSendTapped_Nest() {
        let text_Nest = (inputField_Nest.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_Nest.isEmpty else { return }
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
            return
        }
        // 构造新评论并插入列表顶部（本地 mock）
        let user_Nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        let newComment_Nest = Comment_Nest(
            commentId_Nest: Int(Date().timeIntervalSince1970),
            commentUserId_Nest: user_Nest.userId_Nest ?? 0,
            commentUserName_Nest: user_Nest.userName_Nest ?? "Me",
            commentContent_Nest: text_Nest
        )
        comments_Nest.insert(newComment_Nest, at: 0)
        tableView_Nest.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        inputField_Nest.text = nil
        view.endEditing(true)
        sendContainer_Nest.animatePulse_Nest()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc private func onKeyboardShow_Nest(_ n: Notification) {
        guard let kbH_Nest = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height,
              let dur_Nest = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: dur_Nest) {
            self.inputBar_Nest.snp.updateConstraints { m in m.bottom.equalToSuperview().offset(-kbH_Nest) }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func onKeyboardHide_Nest(_ n: Notification) {
        guard let dur_Nest = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: dur_Nest) {
            self.inputBar_Nest.snp.updateConstraints { m in m.bottom.equalToSuperview() }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - HomeThemeDetailVC_Nest: UITableViewDataSource/Delegate

extension HomeThemeDetailVC_Nest: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { comments_Nest.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment_Nest = comments_Nest[indexPath.row]
        let cell_Nest = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell_Nest.selectionStyle = .none
        cell_Nest.backgroundColor = .clear

        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        card_Nest.layer.cornerRadius = 14
        card_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        card_Nest.layer.shadowOffset  = CGSize(width: 0, height: 2)
        card_Nest.layer.shadowRadius  = 6
        card_Nest.layer.shadowOpacity = 1

        let avatar_Nest = UserAvatarView_Nest()
        avatar_Nest.configure_Nest(userId_Nest: comment_Nest.commentUserId_Nest)

        let nameLbl_Nest = UILabel()
        nameLbl_Nest.text = comment_Nest.commentUserName_Nest
        nameLbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        nameLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest

        let contentLbl_Nest = UILabel()
        contentLbl_Nest.text = comment_Nest.commentContent_Nest
        contentLbl_Nest.font = UIFont.systemFont(ofSize: 13)
        contentLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        contentLbl_Nest.numberOfLines = 0

        // 举报/删除按钮：使用 ReportDeleteHelper，操作完成后移除该评论行
        // 找到该评论所属的帖子（供 Helper 使用）
        let parentPost_Nest = LocalData_Nest.shared_Nest.titleList_Nest
            .first { $0.reviews_Nest.contains { $0.commentId_Nest == comment_Nest.commentId_Nest } }
            ?? LocalData_Nest.shared_Nest.titleList_Nest.first
        let reportBtn_Nest: UIButton
        if let post_Nest = parentPost_Nest {
            reportBtn_Nest = ReportDeleteHelper_Nest.createCommentReportButton_Nest(
                comment_Nest: comment_Nest,
                post_Nest: post_Nest,
                size_Nest: 13,
                color_Nest: ColorConfig_Nest.textPlaceholder_Nest,
                from: self
            ) { [weak self] in
                guard let self else { return }
                // 操作完成后从本地列表移除该评论并刷新对应行
                if let idx_Nest = self.comments_Nest.firstIndex(where: { $0.commentId_Nest == comment_Nest.commentId_Nest }) {
                    self.comments_Nest.remove(at: idx_Nest)
                    self.tableView_Nest.deleteRows(at: [IndexPath(row: idx_Nest, section: 0)], with: .fade)
                }
            }
        } else {
            reportBtn_Nest = UIButton(type: .custom)
        }

        card_Nest.addSubview(avatar_Nest)
        card_Nest.addSubview(nameLbl_Nest)
        card_Nest.addSubview(contentLbl_Nest)
        card_Nest.addSubview(reportBtn_Nest)
        cell_Nest.contentView.addSubview(card_Nest)

        card_Nest.snp.makeConstraints { m in
            m.top.equalToSuperview().offset(6)
            m.leading.equalToSuperview().offset(16)
            m.trailing.equalToSuperview().offset(-16)
            m.bottom.equalToSuperview().offset(-6)
        }
        avatar_Nest.snp.makeConstraints { m in
            m.leading.equalToSuperview().offset(12)
            m.top.equalToSuperview().offset(12)
            m.width.height.equalTo(32)
        }
        reportBtn_Nest.snp.makeConstraints { m in
            m.trailing.equalToSuperview().offset(-10)
            m.top.equalToSuperview().offset(10)
            m.width.height.equalTo(26)
        }
        nameLbl_Nest.snp.makeConstraints { m in
            m.leading.equalTo(avatar_Nest.snp.trailing).offset(10)
            m.top.equalTo(avatar_Nest)
            m.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-6)
        }
        contentLbl_Nest.snp.makeConstraints { m in
            m.leading.equalTo(nameLbl_Nest)
            m.top.equalTo(nameLbl_Nest.snp.bottom).offset(4)
            m.trailing.equalToSuperview().offset(-12)
            m.bottom.equalToSuperview().offset(-12)
        }
        return cell_Nest
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
}

// MARK: - HomeThemeDetailVC_Nest: UITextFieldDelegate

extension HomeThemeDetailVC_Nest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { onSendTapped_Nest(); return true }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) { textField.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.cgColor }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) { textField.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor }
    }
}

// MARK: - HomeGoodItem_Nest

struct HomeGoodItem_Nest {
    let name_Nest:       String
    let desc_Nest:       String
    let detailDesc_Nest: String
    let icon_Nest:       String
    let tag_Nest:        String
    let tint_Nest:       UIColor

    init(name: String, desc: String, detailDesc: String, icon: String, tag: String, tint: UIColor) {
        self.name_Nest       = name
        self.desc_Nest       = desc
        self.detailDesc_Nest = detailDesc
        self.icon_Nest       = icon
        self.tag_Nest        = tag
        self.tint_Nest       = tint
    }
}

// MARK: - HomeTheme_Nest

struct HomeTheme_Nest {
    let title_Nest:     String
    let subtitle_Nest:  String
    let icon_Nest:      String
    let accentHex_Nest: String

    init(title: String, subtitle: String, icon: String, accentHex: String) {
        self.title_Nest     = title
        self.subtitle_Nest  = subtitle
        self.icon_Nest      = icon
        self.accentHex_Nest = accentHex
    }
}
