import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页控制器
/// 核心作用：整合「每日体态计划」「打卡记录看板」「话题互助社区」三大模块，作为 App 主入口。
/// 设计思路：页面只负责 UI 布局与事件转发；计划数据从 UserViewModel_Posture 获取，话题数据来自 TitleViewModel_Posture。
/// 关键属性：scrollView_Posture 承载全页内容，三个子模块各有独立 section 卡片。
/// 关键方法：reloadAll_Posture() 统一刷新三个区块。
@MainActor
class Home_Posture: UIViewController {

    // MARK: - 容器组件

    private let scrollView_Posture = UIScrollView()
    private let contentView_Posture = UIView()
    private let contentStack_Posture = UIStackView()

    // MARK: - 每日计划区块

    /// 计划区容器（动态内容替换）
    private let planBodyContainer_Posture = UIView()

    // MARK: - 打卡看板区块

    /// 连续天数数字标签
    private let streakNumberLabel_Posture = UILabel()

    /// 7天打卡圆点栈
    private let checkDotStack_Posture = UIStackView()

    /// 打卡按钮
    private let checkInButton_Posture = UIButton(type: .system)

    // MARK: - 话题社区区块

    /// 话题卡片列表容器
    private let topicsStack_Posture = UIStackView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observeNotifications_Posture()
        reloadAll_Posture()
        contentStack_Posture.animateFadeIn_Posture(duration_Posture: AnimationConfig_Posture.durationSlow_Posture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAll_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建首页整体布局（ScrollView + 三大 Section）
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        scrollView_Posture.showsVerticalScrollIndicator = false
        // 使用 .automatic 让 UIKit 自动为 TabBar 高度补偿底部 contentInset
        scrollView_Posture.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView_Posture)
        scrollView_Posture.addSubview(contentView_Posture)
        contentView_Posture.addSubview(contentStack_Posture)

        contentStack_Posture.axis = .vertical
        contentStack_Posture.spacing = 22
        contentStack_Posture.alignment = .fill

        scrollView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }
        contentStack_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.trailing.equalToSuperview().inset(18)
            // 底部留出足够空间，避免最后一个卡片被截断
            make.bottom.equalToSuperview().offset(-100)
        }

        contentStack_Posture.addArrangedSubview(buildHomeHeroSection_Posture())
        contentStack_Posture.addArrangedSubview(buildPlanSection_Posture())
        contentStack_Posture.addArrangedSubview(buildCheckInSection_Posture())
        contentStack_Posture.addArrangedSubview(buildTopicsSection_Posture())
    }

    // MARK: - Section 0：首页 Hero 区

    /// 构建首页顶部 Hero 卡（时段问候 + 品牌宣言 + 装饰图标 + 今日打卡状态）
    private func buildHomeHeroSection_Posture() -> UIView {
        let cardWidth_Posture = UIScreen.main.bounds.width - 36
        let card_Posture = UIView()
        card_Posture.layer.cornerRadius = 28
        card_Posture.clipsToBounds = true
        card_Posture.backgroundColor = ColorConfig_Posture.accentIndigo_Posture

        // 渐变背景层
        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            ColorConfig_Posture.accentIndigo_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor
        ]
        grad_Posture.locations = [0, 0.55, 1.0]
        grad_Posture.startPoint = CGPoint(x: 0.1, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 0.9, y: 1)
        grad_Posture.frame = CGRect(x: 0, y: 0, width: cardWidth_Posture, height: 168)
        card_Posture.layer.insertSublayer(grad_Posture, at: 0)

        // 装饰光晕圆（右下角）
        let glowCircle_Posture = UIView()
        glowCircle_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        glowCircle_Posture.layer.cornerRadius = 80
        glowCircle_Posture.isUserInteractionEnabled = false

        // 右上角图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconBg_Posture.layer.cornerRadius = 26
        let iconIV_Posture = UIImageView(image: UIImage(systemName: "figure.walk.motion"))
        iconIV_Posture.tintColor = .white
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        // 时段问候
        let hour_Posture = Calendar.current.component(.hour, from: Date())
        let greetText_Posture: String
        switch hour_Posture {
        case 0..<12: greetText_Posture = "Good morning"
        case 12..<17: greetText_Posture = "Good afternoon"
        default:     greetText_Posture = "Good evening"
        }
        let greetLabel_Posture = UILabel()
        greetLabel_Posture.text = greetText_Posture
        greetLabel_Posture.font = .systemFont(ofSize: 13, weight: .semibold)
        greetLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)

        // 主标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Stand Tall Today"
        titleLabel_Posture.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel_Posture.textColor = .white
        titleLabel_Posture.numberOfLines = 1

        // 副标题
        let descLabel_Posture = UILabel()
        descLabel_Posture.text = "Build better posture with small,\nconsistent habits every day."
        descLabel_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        descLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.72)
        descLabel_Posture.numberOfLines = 2

        // 今日打卡状态徽章
        let checkedIn_Posture = UserViewModel_Posture.shared_Posture.hasCheckedInToday_Posture()
        let badge_Posture = UIView()
        badge_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        badge_Posture.layer.cornerRadius = 14
        badge_Posture.layer.borderWidth = 1
        badge_Posture.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        let badgeIcon_Posture = UIImageView(image: UIImage(systemName: checkedIn_Posture ? "checkmark.seal.fill" : "seal"))
        badgeIcon_Posture.tintColor = checkedIn_Posture ? ColorConfig_Posture.accentMint_Posture : UIColor.white.withAlphaComponent(0.7)
        badgeIcon_Posture.contentMode = .scaleAspectFit

        let badgeText_Posture = UILabel()
        badgeText_Posture.text = checkedIn_Posture ? "Checked in today" : "Not checked in yet"
        badgeText_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        badgeText_Posture.textColor = checkedIn_Posture ? ColorConfig_Posture.accentMint_Posture : UIColor.white.withAlphaComponent(0.7)

        badge_Posture.addSubview(badgeIcon_Posture)
        badge_Posture.addSubview(badgeText_Posture)
        badgeIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        badgeText_Posture.snp.makeConstraints { make in
            make.leading.equalTo(badgeIcon_Posture.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }

        card_Posture.addSubview(glowCircle_Posture)
        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(greetLabel_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(descLabel_Posture)
        card_Posture.addSubview(badge_Posture)

        glowCircle_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(40)
            make.width.height.equalTo(160)
        }

        iconBg_Posture.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(18)
            make.width.height.equalTo(52)
        }

        greetLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(iconBg_Posture.snp.leading).offset(-8)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(greetLabel_Posture.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(iconBg_Posture.snp.leading).offset(-8)
        }

        descLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        badge_Posture.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Posture.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(18)
            make.height.equalTo(28)
        }

        return card_Posture
    }

    // MARK: - Section 1：每日体态计划

    /// 构建每日体态计划区块
    /// - Returns: UIView
    private func buildPlanSection_Posture() -> UIView {
        let section_Posture = UIView()
        let header_Posture = makeSectionHeader_Posture(
            title_posture: "Daily Posture Plan",
            subtitle_posture: "Personalized stretches & corrections"
        )

        planBodyContainer_Posture.backgroundColor = .clear

        section_Posture.addSubview(header_Posture)
        section_Posture.addSubview(planBodyContainer_Posture)

        header_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        planBodyContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(header_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return section_Posture
    }

    /// 根据是否存在档案，动态渲染计划区内容
    private func reloadPlanSection_Posture() {
        planBodyContainer_Posture.subviews.forEach { $0.removeFromSuperview() }

        if let recommendations_posture = buildRecommendationsView_Posture() {
            planBodyContainer_Posture.addSubview(recommendations_posture)
            recommendations_posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else {
            let setupCard_Posture = buildPlanSetupPrompt_Posture()
            planBodyContainer_Posture.addSubview(setupCard_Posture)
            setupCard_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        }
    }

    /// 如果用户已有档案则构建推荐列表，否则返回 nil
    private func buildRecommendationsView_Posture() -> UIView? {
        let items_posture = UserViewModel_Posture.shared_Posture.getDailyRecommendations_Posture()
        guard !items_posture.isEmpty else { return nil }

        let stack_Posture = UIStackView()
        stack_Posture.axis = .vertical
        stack_Posture.spacing = 12

        for (idx_posture, item_posture) in items_posture.enumerated() {
            let card_Posture = makeRecommendCard_Posture(item_posture: item_posture, index_posture: idx_posture)
            stack_Posture.addArrangedSubview(card_Posture)
            card_Posture.animateSlideInFromBottom_Posture(delay_Posture: Double(idx_posture) * 0.06)
        }

        // 编辑档案按钮
        let editBtn_Posture = UIButton(type: .system)
        editBtn_Posture.setTitle("Edit Profile", for: .normal)
        editBtn_Posture.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        editBtn_Posture.setTitleColor(ColorConfig_Posture.primaryGradientStart_Posture, for: .normal)
        editBtn_Posture.addAction(UIAction { _ in
            Navigation_Posture.toPlanSetup_Posture()
        }, for: .touchUpInside)
        stack_Posture.addArrangedSubview(editBtn_Posture)

        return stack_Posture
    }

    /// 构建推荐条目卡片
    /// - Parameters:
    ///   - item_posture: 每日推荐条目
    ///   - index_posture: 排序索引，用于取色
    /// - Returns: UIView
    private func makeRecommendCard_Posture(item_posture: DailyRecommendation_Posture, index_posture: Int) -> UIView {
        let palette_posture = ColorConfig_Posture.cardAccentPalette_Posture[index_posture % ColorConfig_Posture.cardAccentPalette_Posture.count]
        let card_Posture = UIView()
        card_Posture.backgroundColor = palette_posture.light
        card_Posture.layer.cornerRadius = 20
        card_Posture.layer.shadowColor = palette_posture.shadow.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 12
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 5)

        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = palette_posture.main.withAlphaComponent(0.18)
        iconBg_Posture.layer.cornerRadius = 18

        let iconIV_Posture = UIImageView(image: UIImage(systemName: item_posture.icon_Posture))
        iconIV_Posture.tintColor = palette_posture.main
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = item_posture.title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let detailLabel_Posture = UILabel()
        detailLabel_Posture.text = item_posture.detail_Posture
        detailLabel_Posture.font = .systemFont(ofSize: 12, weight: .regular)
        detailLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        detailLabel_Posture.numberOfLines = 2

        let durationBadge_Posture = makeTagBadge_Posture(text_posture: item_posture.duration_Posture, color_posture: palette_posture.main)

        // 提示可点击的箭头图标
        let arrowIV_Posture = UIImageView(image: UIImage(systemName: "chevron.right.circle.fill"))
        arrowIV_Posture.tintColor = palette_posture.main.withAlphaComponent(0.5)
        arrowIV_Posture.contentMode = .scaleAspectFit
        arrowIV_Posture.isUserInteractionEnabled = false

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(detailLabel_Posture)
        card_Posture.addSubview(durationBadge_Posture)
        card_Posture.addSubview(arrowIV_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(14)
            make.width.height.equalTo(36)
        }

        arrowIV_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(12)
            make.trailing.equalTo(arrowIV_Posture.snp.leading).offset(-8)
        }

        detailLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(4)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(12)
            make.trailing.equalTo(arrowIV_Posture.snp.leading).offset(-8)
        }

        durationBadge_Posture.snp.makeConstraints { make in
            make.top.equalTo(detailLabel_Posture.snp.bottom).offset(8)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(12)
            make.bottom.equalToSuperview().inset(14)
            make.height.equalTo(22)
        }

        // 透明点击层，不影响子视图显示，捕获整块卡片的点击
        let tapBtn_Posture = UIButton(type: .custom)
        tapBtn_Posture.backgroundColor = .clear
        tapBtn_Posture.addAction(UIAction { [weak self, weak card_Posture] _ in
            card_Posture?.animatePressDown_Posture { card_Posture?.animatePressUp_Posture() }
            self?.showRecommendDetail_Posture(item_posture: item_posture, index_posture: index_posture)
        }, for: .touchUpInside)
        card_Posture.addSubview(tapBtn_Posture)
        tapBtn_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        return card_Posture
    }

    // MARK: - 推荐详情底部弹窗

    /// 当前弹窗遮罩（用于判断是否已有弹窗显示）
    private weak var detailOverlay_Posture: UIView?

    /// 展示推荐条目详情底部弹窗
    /// - Parameters:
    ///   - item_posture: 推荐条目
    ///   - index_posture: 色彩索引
    private func showRecommendDetail_Posture(item_posture: DailyRecommendation_Posture, index_posture: Int) {
        guard detailOverlay_Posture == nil,
              let window_posture = view.window else { return }
        let palette_posture = ColorConfig_Posture.cardAccentPalette_Posture[index_posture % ColorConfig_Posture.cardAccentPalette_Posture.count]

        // 遮罩层添加到 window，确保覆盖 TabBar
        let overlay_Posture = UIView()
        overlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0)
        overlay_Posture.frame = window_posture.bounds
        overlay_Posture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window_posture.addSubview(overlay_Posture)
        detailOverlay_Posture = overlay_Posture

        // 底部卡片
        let sheet_Posture = buildDetailSheet_Posture(item_posture: item_posture, palette_posture: palette_posture) {
            [weak self] in self?.dismissRecommendDetail_Posture()
        }
        sheet_Posture.layer.cornerRadius = 30
        sheet_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_Posture.addSubview(sheet_Posture)
        sheet_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 初始位置在屏幕底部外
        sheet_Posture.transform = CGAffineTransform(translationX: 0, y: window_posture.bounds.height)

        // 点击遮罩关闭
        overlay_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissRecommendDetail_Posture)))

        UIView.animate(
            withDuration: AnimationConfig_Posture.durationSpring_Posture,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Posture.springDampingNormal_Posture,
            initialSpringVelocity: AnimationConfig_Posture.springVelocity_Posture,
            options: [.curveEaseOut]
        ) {
            overlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.38)
            sheet_Posture.transform = .identity
        }
    }

    /// 收起推荐详情弹窗
    @objc private func dismissRecommendDetail_Posture() {
        guard let overlay_Posture = detailOverlay_Posture else { return }
        let sheetHeight_posture = overlay_Posture.bounds.height
        UIView.animate(
            withDuration: AnimationConfig_Posture.durationNormal_Posture,
            animations: {
                overlay_Posture.alpha = 0
                overlay_Posture.subviews.first?.transform = CGAffineTransform(translationX: 0, y: sheetHeight_posture)
            },
            completion: { _ in overlay_Posture.removeFromSuperview() }
        )
    }

    /// 构建详情弹窗内容视图
    /// - Parameters:
    ///   - item_posture: 推荐条目
    ///   - palette_posture: 色彩主题
    ///   - onClose_posture: 关闭回调
    /// - Returns: UIView
    private func buildDetailSheet_Posture(
        item_posture: DailyRecommendation_Posture,
        palette_posture: (main: UIColor, light: UIColor, shadow: UIColor),
        onClose_posture: @escaping () -> Void
    ) -> UIView {
        let sheet_Posture = UIView()
        sheet_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        // 拖动把手
        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 2.5

        // 大图标区域
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = palette_posture.light
        iconBg_Posture.layer.cornerRadius = 36
        let iconIV_Posture = UIImageView(image: UIImage(systemName: item_posture.icon_Posture))
        iconIV_Posture.tintColor = palette_posture.main
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }

        // 时长徽章
        let durationBadge_Posture = makeTagBadge_Posture(text_posture: "⏱ \(item_posture.duration_Posture)", color_posture: palette_posture.main)

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = item_posture.title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 24, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 2

        // 分割线
        let divider_Posture = UIView()
        divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture

        // 说明标题
        let howLabel_Posture = UILabel()
        howLabel_Posture.text = "How to do it"
        howLabel_Posture.font = .systemFont(ofSize: 14, weight: .bold)
        howLabel_Posture.textColor = palette_posture.main

        // 完整说明（不限行数）
        let detailLabel_Posture = UILabel()
        detailLabel_Posture.text = item_posture.detail_Posture
        detailLabel_Posture.font = .systemFont(ofSize: 15, weight: .regular)
        detailLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        detailLabel_Posture.numberOfLines = 0
        detailLabel_Posture.lineBreakMode = .byWordWrapping

        // 分步骤列表
        let stepsStack_Posture = buildDetailSteps_Posture(item_posture: item_posture, accentColor_posture: palette_posture.main)

        // 关闭按钮
        let closeBtn_Posture = UIButton(type: .system)
        closeBtn_Posture.setTitle("Got it!", for: .normal)
        closeBtn_Posture.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        closeBtn_Posture.setTitleColor(.white, for: .normal)
        closeBtn_Posture.backgroundColor = palette_posture.main
        closeBtn_Posture.layer.cornerRadius = 24
        closeBtn_Posture.layer.shadowColor = palette_posture.shadow.cgColor
        closeBtn_Posture.layer.shadowOpacity = 1
        closeBtn_Posture.layer.shadowRadius = 10
        closeBtn_Posture.layer.shadowOffset = CGSize(width: 0, height: 5)
        closeBtn_Posture.addAction(UIAction { _ in onClose_posture() }, for: .touchUpInside)

        [handle_Posture, iconBg_Posture, durationBadge_Posture, titleLabel_Posture,
         divider_Posture, howLabel_Posture, detailLabel_Posture,
         stepsStack_Posture, closeBtn_Posture].forEach { sheet_Posture.addSubview($0) }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(22)
            make.width.height.equalTo(72)
        }

        durationBadge_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(16)
            make.centerY.equalTo(iconBg_Posture).offset(-10)
            make.height.equalTo(24)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(16)
            make.top.equalTo(durationBadge_Posture.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(22)
        }

        divider_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(1)
        }

        howLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(divider_Posture.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(22)
        }

        detailLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(howLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        stepsStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(detailLabel_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        closeBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepsStack_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(52)
            make.bottom.equalTo(sheet_Posture.safeAreaLayoutGuide.snp.bottom).inset(20)
        }

        return sheet_Posture
    }

    /// 根据推荐条目生成分步骤视图（图标 + 文字列表）
    /// - Parameters:
    ///   - item_posture: 推荐条目
    ///   - accentColor_posture: 强调色
    /// - Returns: UIStackView
    private func buildDetailSteps_Posture(item_posture: DailyRecommendation_Posture, accentColor_posture: UIColor) -> UIStackView {
        let steps_posture = generateSteps_Posture(for: item_posture)
        let stack_Posture = UIStackView()
        stack_Posture.axis = .vertical
        stack_Posture.spacing = 10

        for (idx_posture, step_posture) in steps_posture.enumerated() {
            let row_Posture = UIView()

            let numLabel_Posture = UILabel()
            numLabel_Posture.text = "\(idx_posture + 1)"
            numLabel_Posture.font = .systemFont(ofSize: 13, weight: .heavy)
            numLabel_Posture.textColor = accentColor_posture
            numLabel_Posture.textAlignment = .center
            numLabel_Posture.backgroundColor = accentColor_posture.withAlphaComponent(0.12)
            numLabel_Posture.layer.cornerRadius = 12
            numLabel_Posture.clipsToBounds = true

            let stepLabel_Posture = UILabel()
            stepLabel_Posture.text = step_posture
            stepLabel_Posture.font = .systemFont(ofSize: 14, weight: .regular)
            stepLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
            stepLabel_Posture.numberOfLines = 0

            row_Posture.addSubview(numLabel_Posture)
            row_Posture.addSubview(stepLabel_Posture)

            numLabel_Posture.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalToSuperview()
                make.width.height.equalTo(24)
            }

            stepLabel_Posture.snp.makeConstraints { make in
                make.leading.equalTo(numLabel_Posture.snp.trailing).offset(10)
                make.trailing.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }

            stack_Posture.addArrangedSubview(row_Posture)
        }

        return stack_Posture
    }

    /// 根据推荐条目类型生成分步骤文字
    /// - Parameter item_posture: 推荐条目
    /// - Returns: [String] 步骤数组
    private func generateSteps_Posture(for item_posture: DailyRecommendation_Posture) -> [String] {
        switch item_posture.icon_Posture {
        case "figure.cooldown":
            return [
                "Sit or stand tall with shoulders relaxed.",
                "Gently pull your chin straight back (not down).",
                "Hold the position for 5 seconds, then release.",
                "Repeat 10 times, taking slow breaths throughout."
            ]
        case "figure.strengthtraining.traditional":
            return [
                "Sit upright at the edge of your chair.",
                "Draw your shoulder blades toward each other.",
                "Hold the squeeze for 5 seconds, then relax.",
                "Repeat 15 times, keeping your neck long."
            ]
        case "figure.flexibility":
            return [
                "Start on hands and knees (or seated in chair).",
                "Inhale and arch your back gently (cow pose).",
                "Exhale and round your spine upward (cat pose).",
                "Flow through 10 slow cycles, 4 seconds each."
            ]
        case "figure.walk":
            return [
                "Stand with one foot forward in a lunge position.",
                "Lower your back knee toward the floor.",
                "Feel the stretch in the front of the back hip.",
                "Hold 30 seconds, then switch sides."
            ]
        case "chair":
            return [
                "Set a recurring timer for 30 or 45 minutes.",
                "When it rings, stand up and walk for 2 minutes.",
                "Do a quick shoulder roll and deep breath.",
                "Return to your seat and reset your posture."
            ]
        case "lungs":
            return [
                "Sit comfortably and close your eyes.",
                "Inhale slowly through your nose for 4 counts.",
                "Hold the breath gently for 4 counts.",
                "Exhale fully through your mouth for 4 counts.",
                "Repeat 4–6 cycles to reset your nervous system."
            ]
        default:
            return [
                "Find a comfortable, stable position.",
                "Move slowly and with control throughout.",
                "Breathe steadily — never hold your breath.",
                "Stop if you feel any sharp discomfort."
            ]
        }
    }

    /// 构建「尚未设置档案」引导卡片
    private func buildPlanSetupPrompt_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.primaryLight_Posture
        card_Posture.layer.cornerRadius = 22
        card_Posture.layer.shadowColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.2).cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 14
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 6)

        let iconIV_Posture = UIImageView(image: UIImage(systemName: "doc.badge.plus"))
        iconIV_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        iconIV_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = "Set up your posture profile to receive a personalized daily plan."
        label_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        label_Posture.numberOfLines = 3

        let setupBtn_Posture = UIButton(type: .system)
        setupBtn_Posture.setTitle("Set Up Now", for: .normal)
        setupBtn_Posture.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        setupBtn_Posture.setTitleColor(.white, for: .normal)
        setupBtn_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        setupBtn_Posture.layer.cornerRadius = 18
        setupBtn_Posture.addAction(UIAction { _ in Navigation_Posture.toPlanSetup_Posture() }, for: .touchUpInside)

        card_Posture.addSubview(iconIV_Posture)
        card_Posture.addSubview(label_Posture)
        card_Posture.addSubview(setupBtn_Posture)

        iconIV_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(28)
        }

        label_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconIV_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        setupBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(label_Posture.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(20)
            make.width.equalTo(130)
            make.height.equalTo(38)
        }

        return card_Posture
    }

    // MARK: - Section 2：打卡记录看板

    /// 构建打卡记录看板区块
    private func buildCheckInSection_Posture() -> UIView {
        let section_Posture = UIView()
        let header_Posture = makeSectionHeader_Posture(
            title_posture: "Check-in Board",
            subtitle_posture: "Track your consistency streak"
        )

        let card_Posture = buildCheckInCard_Posture()
        section_Posture.addSubview(header_Posture)
        section_Posture.addSubview(card_Posture)

        header_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        card_Posture.snp.makeConstraints { make in
            make.top.equalTo(header_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return section_Posture
    }

    /// 构建打卡卡片（连续天数 + 7日可视化 + 打卡按钮）
    private func buildCheckInCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 24
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 14
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 6)

        // 渐变横幅
        let bannerView_Posture = UIView()
        bannerView_Posture.backgroundColor = ColorConfig_Posture.accentMintLight_Posture
        bannerView_Posture.layer.cornerRadius = 16

        let fireIcon_Posture = UIImageView(image: UIImage(systemName: "flame.fill"))
        fireIcon_Posture.tintColor = ColorConfig_Posture.accentAmber_Posture
        fireIcon_Posture.contentMode = .scaleAspectFit

        let streakTitle_Posture = UILabel()
        streakTitle_Posture.text = "Streak"
        streakTitle_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        streakTitle_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        streakNumberLabel_Posture.font = .systemFont(ofSize: 40, weight: .heavy)
        streakNumberLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let dayLabel_Posture = UILabel()
        dayLabel_Posture.text = "days"
        dayLabel_Posture.font = .systemFont(ofSize: 13, weight: .semibold)
        dayLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        bannerView_Posture.addSubview(fireIcon_Posture)
        bannerView_Posture.addSubview(streakTitle_Posture)
        bannerView_Posture.addSubview(streakNumberLabel_Posture)
        bannerView_Posture.addSubview(dayLabel_Posture)

        fireIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        streakNumberLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(fireIcon_Posture.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        dayLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(streakNumberLabel_Posture.snp.trailing).offset(6)
            make.bottom.equalTo(streakNumberLabel_Posture).inset(8)
        }

        streakTitle_Posture.snp.makeConstraints { make in
            make.leading.equalTo(streakNumberLabel_Posture)
            make.bottom.equalTo(streakNumberLabel_Posture.snp.top).offset(-2)
        }

        // 7日圆点
        checkDotStack_Posture.axis = .horizontal
        checkDotStack_Posture.spacing = 8
        checkDotStack_Posture.distribution = .fillEqually

        // 打卡按钮
        checkInButton_Posture.setTitle("Check In Today", for: .normal)
        checkInButton_Posture.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        checkInButton_Posture.setTitleColor(.white, for: .normal)
        checkInButton_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture
        checkInButton_Posture.layer.cornerRadius = 20
        checkInButton_Posture.layer.shadowColor = ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.4).cgColor
        checkInButton_Posture.layer.shadowOpacity = 1
        checkInButton_Posture.layer.shadowRadius = 10
        checkInButton_Posture.layer.shadowOffset = CGSize(width: 0, height: 5)
        checkInButton_Posture.addAction(UIAction { _ in
            UserViewModel_Posture.shared_Posture.checkIn_Posture()
        }, for: .touchUpInside)

        card_Posture.addSubview(bannerView_Posture)
        card_Posture.addSubview(checkDotStack_Posture)
        card_Posture.addSubview(checkInButton_Posture)

        bannerView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }

        checkDotStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }

        checkInButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(checkDotStack_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(18)
        }

        return card_Posture
    }

    /// 刷新打卡区块数据（连续天数 + 7日圆点 + 按钮状态）
    private func reloadCheckInSection_Posture() {
        let streak_posture = UserViewModel_Posture.shared_Posture.getCheckInStreak_Posture()
        streakNumberLabel_Posture.text = "\(streak_posture)"

        // 刷新7日圆点
        checkDotStack_Posture.arrangedSubviews.forEach {
            checkDotStack_Posture.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let calendar_posture = Calendar.current
        let boolArray_posture = UserViewModel_Posture.shared_Posture.getRecentCheckInBoolArray_Posture(days_posture: 7)
        let dayLetters_posture = ["M", "T", "W", "T", "F", "S", "S"]

        // 计算今天是周几（0=周日, 1=周一...）
        let weekday_posture = calendar_posture.component(.weekday, from: Date())
        // 将7个圆点的起始星期对齐
        let startOffset_posture = (weekday_posture - 2 + 7) % 7 // 周一对应0

        for i_posture in 0..<7 {
            let dayLetterIdx_posture = (startOffset_posture + i_posture) % 7
            let dot_posture = makeDayDot_Posture(
                dayLetter_posture: dayLetters_posture[dayLetterIdx_posture],
                checked_posture: boolArray_posture[i_posture],
                isToday_posture: i_posture == 6
            )
            checkDotStack_Posture.addArrangedSubview(dot_posture)
        }

        // 今日已打卡则修改按钮样式
        let checkedToday_posture = UserViewModel_Posture.shared_Posture.hasCheckedInToday_Posture()
        checkInButton_Posture.setTitle(checkedToday_posture ? "Checked In ✓" : "Check In Today", for: .normal)
        checkInButton_Posture.backgroundColor = checkedToday_posture
            ? ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.5)
            : ColorConfig_Posture.accentMint_Posture
        checkInButton_Posture.isEnabled = !checkedToday_posture
    }

    /// 创建单个日期圆点视图
    /// - Parameters:
    ///   - dayLetter_posture: 星期字母
    ///   - checked_posture: 是否已打卡
    ///   - isToday_posture: 是否是今天
    /// - Returns: UIView
    private func makeDayDot_Posture(dayLetter_posture: String, checked_posture: Bool, isToday_posture: Bool) -> UIView {
        let container_Posture = UIView()

        let circle_Posture = UIView()
        circle_Posture.layer.cornerRadius = 18
        if checked_posture {
            circle_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture
        } else if isToday_posture {
            circle_Posture.backgroundColor = ColorConfig_Posture.accentMintLight_Posture
            circle_Posture.layer.borderWidth = 2
            circle_Posture.layer.borderColor = ColorConfig_Posture.accentMint_Posture.cgColor
        } else {
            circle_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        }

        let checkmark_Posture = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark_Posture.tintColor = .white
        checkmark_Posture.contentMode = .scaleAspectFit
        checkmark_Posture.isHidden = !checked_posture
        circle_Posture.addSubview(checkmark_Posture)
        checkmark_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let dayLabel_Posture = UILabel()
        dayLabel_Posture.text = dayLetter_posture
        dayLabel_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        dayLabel_Posture.textColor = isToday_posture
            ? ColorConfig_Posture.accentMint_Posture
            : ColorConfig_Posture.textPlaceholder_Posture
        dayLabel_Posture.textAlignment = .center

        container_Posture.addSubview(circle_Posture)
        container_Posture.addSubview(dayLabel_Posture)

        circle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        dayLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(circle_Posture.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        return container_Posture
    }

    // MARK: - Section 3：话题互助社区

    /// 构建话题互助社区区块
    private func buildTopicsSection_Posture() -> UIView {
        let section_Posture = UIView()
        let header_Posture = makeSectionHeader_Posture(
            title_posture: "Topic Community",
            subtitle_posture: "Tap a topic to join the conversation"
        )

        topicsStack_Posture.axis = .vertical
        topicsStack_Posture.spacing = 14

        section_Posture.addSubview(header_Posture)
        section_Posture.addSubview(topicsStack_Posture)

        header_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        topicsStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(header_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return section_Posture
    }

    /// 刷新话题列表
    private func reloadTopicsSection_Posture() {
        topicsStack_Posture.arrangedSubviews.forEach {
            topicsStack_Posture.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let topics_posture = TitleViewModel_Posture.shared_Posture.getTopics_Posture()
        guard !topics_posture.isEmpty else { return }

        for (idx_posture, topic_posture) in topics_posture.enumerated() {
            let card_Posture = makeTopicCard_Posture(topic_posture: topic_posture, index_posture: idx_posture)
            topicsStack_Posture.addArrangedSubview(card_Posture)
            card_Posture.animateSlideInFromBottom_Posture(delay_Posture: Double(idx_posture) * 0.05)
        }
    }

    /// 构建单个话题卡片
    /// - Parameters:
    ///   - topic_posture: 话题模型
    ///   - index_posture: 排序索引，用于取色
    /// - Returns: UIView
    private func makeTopicCard_Posture(topic_posture: Topic_Posture, index_posture: Int) -> UIView {
        let colors_posture = ColorConfig_Posture.chipColors_Posture(at: index_posture)
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 22
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 12
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 5)

        // 左侧图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = colors_posture.bg
        iconBg_Posture.layer.cornerRadius = 22

        let iconIV_Posture = UIImageView(image: UIImage(systemName: topic_posture.topicIcon_Posture))
        iconIV_Posture.tintColor = colors_posture.tint
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = topic_posture.topicTitle_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 1

        // 描述
        let descLabel_Posture = UILabel()
        descLabel_Posture.text = topic_posture.topicDesc_Posture
        descLabel_Posture.font = .systemFont(ofSize: 12, weight: .regular)
        descLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        descLabel_Posture.numberOfLines = 2

        // 成员徽章
        let memberBadge_Posture = makeTagBadge_Posture(
            text_posture: "\(formatCount_Posture(topic_posture.memberCount_Posture)) members",
            color_posture: colors_posture.tint
        )
        memberBadge_Posture.backgroundColor = colors_posture.bg

        // 箭头
        let arrowIV_Posture = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowIV_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        arrowIV_Posture.contentMode = .scaleAspectFit

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(descLabel_Posture)
        card_Posture.addSubview(memberBadge_Posture)
        card_Posture.addSubview(arrowIV_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        arrowIV_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(14)
            make.trailing.equalTo(arrowIV_Posture.snp.leading).offset(-8)
        }

        descLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(4)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(14)
            make.trailing.equalTo(arrowIV_Posture.snp.leading).offset(-8)
        }

        memberBadge_Posture.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Posture.snp.bottom).offset(8)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(14)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(22)
        }

        // 点击手势跳转话题详情
        let tap_Posture = UITapGestureRecognizer()
        tap_Posture.addTarget(self, action: #selector(handleTopicTap_Posture(_:)))
        card_Posture.addGestureRecognizer(tap_Posture)
        card_Posture.isUserInteractionEnabled = true
        card_Posture.tag = topic_posture.topicId_Posture

        return card_Posture
    }

    // MARK: - 统一刷新

    /// 刷新所有区块数据
    private func reloadAll_Posture() {
        reloadPlanSection_Posture()
        reloadCheckInSection_Posture()
        reloadTopicsSection_Posture()
    }

    // MARK: - 通知监听

    /// 注册所有相关通知
    private func observeNotifications_Posture() {
        let center_Posture = NotificationCenter.default
        center_Posture.addObserver(self, selector: #selector(handleUserStateChange_Posture), name: UserViewModel_Posture.userStateDidChangeNotification_Posture, object: nil)
        center_Posture.addObserver(self, selector: #selector(handlePlanProfileChange_Posture), name: UserViewModel_Posture.planProfileDidChangeNotification_Posture, object: nil)
        center_Posture.addObserver(self, selector: #selector(handleTopicStateChange_Posture), name: TitleViewModel_Posture.topicStateDidChangeNotification_Posture, object: nil)
    }

    /// 用户状态变化 → 刷新打卡区块
    @objc private func handleUserStateChange_Posture() {
        reloadCheckInSection_Posture()
    }

    /// 档案更新 → 刷新计划区块
    @objc private func handlePlanProfileChange_Posture() {
        reloadPlanSection_Posture()
    }

    /// 话题状态变化 → 刷新话题区块
    @objc private func handleTopicStateChange_Posture() {
        reloadTopicsSection_Posture()
    }

    // MARK: - 事件处理

    /// 话题卡片点击跳转详情
    @objc private func handleTopicTap_Posture(_ gesture_posture: UITapGestureRecognizer) {
        guard let topicId_posture = gesture_posture.view?.tag,
              let topic_posture = TitleViewModel_Posture.shared_Posture.getTopics_Posture().first(where: { $0.topicId_Posture == topicId_posture }) else { return }
        gesture_posture.view?.animatePressDown_Posture { [weak gesture_posture] in
            gesture_posture?.view?.animatePressUp_Posture()
        }
        Navigation_Posture.toTopicDetail_Posture(topic_posture: topic_posture)
    }

    // MARK: - 通用工具

    /// 构建通用区块标题视图
    /// - Parameters:
    ///   - title_posture: 主标题
    ///   - subtitle_posture: 副标题
    /// - Returns: UIView
    private func makeSectionHeader_Posture(title_posture: String, subtitle_posture: String) -> UIView {
        let container_Posture = UIView()
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title_posture
        titleLabel_Posture.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = subtitle_posture
        subtitleLabel_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        container_Posture.addSubview(titleLabel_Posture)
        container_Posture.addSubview(subtitleLabel_Posture)

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return container_Posture
    }

    /// 创建小型标签徽章
    /// - Parameters:
    ///   - text_posture: 显示文字
    ///   - color_posture: 文字/图标颜色
    /// - Returns: UIView
    private func makeTagBadge_Posture(text_posture: String, color_posture: UIColor) -> UIView {
        let badge_Posture = UIView()
        badge_Posture.backgroundColor = color_posture.withAlphaComponent(0.12)
        badge_Posture.layer.cornerRadius = 11

        let label_Posture = UILabel()
        label_Posture.text = text_posture
        label_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        label_Posture.textColor = color_posture
        badge_Posture.addSubview(label_Posture)

        label_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        return badge_Posture
    }

    /// 将整数格式化为 "1.2k" 样式
    /// - Parameter count_posture: 原始整数
    /// - Returns: 格式化字符串
    private func formatCount_Posture(_ count_posture: Int) -> String {
        return count_posture >= 1000
            ? String(format: "%.1fk", Double(count_posture) / 1000)
            : "\(count_posture)"
    }
}
