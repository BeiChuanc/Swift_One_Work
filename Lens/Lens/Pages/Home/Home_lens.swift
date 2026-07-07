import UIKit
import SnapKit

// MARK: - 首页（调制画盘工作室 · 圆弧拱形版）

/// Home_Lens
/// 功能：热门帖子推荐 + 三大功能入口 + 作品日历 + 周期汇总 + 弹幕交流池
/// 设计思路：横向热门帖 + 三列功能卡 + 数据看板 + 弹幕互动
class Home_Lens: UIViewController {

    // MARK: - UI

    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let scrollView_Lens: HomeScrollView_Lens = {
        let sv = HomeScrollView_Lens()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.keyboardDismissMode = .onDrag
        sv.alwaysBounceVertical = true 
        sv.delaysContentTouches = false
        return sv
    }()

    private let contentView_Lens = UIView()

    private let spectrumBarView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Lens Studio"
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let subtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Swipe the arc · Create · Test · Light"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        return l
    }()

    private let hotPostsView_Lens = HomeHotPostsView_Lens()
    private let featureHubView_Lens = HomeFeatureHubView_Lens()

    /// 日历区描述
    private let calendarDescLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Track your creative days and tap any date to revisit works."
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.38)
        l.numberOfLines = 0
        return l
    }()

    /// 统计区描述
    private let summaryDescLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "A quick snapshot of your studio activity this week."
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.38)
        l.numberOfLines = 0
        return l
    }()

    /// 弹幕池描述
    private let danmakuDescLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Share thoughts with the community in real-time."
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.38)
        l.numberOfLines = 0
        return l
    }()

    private let calendarCard_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        v.clipsToBounds = true
        return v
    }()

    /// 日历区渐变背景
    private let calendarGradient_Lens = CAGradientLayer()

    private let workCalendarView_Lens = WorkCalendarView_Lens()

    /// 日历卡片内边距（上下合计）
    private let calendarCardPadding_Lens: CGFloat = 20

    /// 统计区标题
    private let summaryHeader_Lens: UIView = {
        let v = UIView()
        return v
    }()

    private let summaryTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "WEEKLY STATS"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        return l
    }()

    private let summaryIconView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "chart.bar.fill"))
        v.tintColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.6)
        v.contentMode = .scaleAspectFit
        return v
    }()

    /// 装饰粒子容器
    private let decorParticlesView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 日历卡片高度约束（随展开/折叠变化）
    private var calendarHeightConstraint_Lens: Constraint?

    private let summaryStack_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 10
        return s
    }()

    private let danmakuCard_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        v.clipsToBounds = true
        return v
    }()

    /// 弹幕池渐变背景
    private let danmakuGradient_Lens = CAGradientLayer()

    private let danmakuPoolView_Lens = DanmakuPoolView_Lens()

    private let danmakuInput_Lens: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Say something..."
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Say something...",
            attributes: [.foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)]
        )
        tf.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    /// 顶部内容留白（跟随安全区）
    private var topContentInset_Lens: CGFloat = 0

    /// 弹幕池底部与自定义 Tab 顶部的目标间距
    private let tabBarClearance_Lens: CGFloat = 100

    /// 上次应用的底部 contentInset，避免重复赋值
    private var lastBottomInset_Lens: CGFloat = -1

    private let danmakuSendBtn_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Send", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        b.layer.cornerRadius = 20
        return b
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Lens()
        setupUI_Lens()
        setupFeatureHub_Lens()
        registerNotifications_Lens()
        danmakuPoolView_Lens.hostViewController_Lens = self
        danmakuPoolView_Lens.onActionCompleted_Lens = { [weak self] in
            self?.reloadAll_Lens()
        }
        reloadAll_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAll_Lens()
        danmakuPoolView_Lens.stopAnimation_Lens()
        danmakuPoolView_Lens.startAnimation_Lens()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        danmakuPoolView_Lens.stopAnimation_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGlowView_Lens.layer.sublayers?.forEach { layer_Lens in
            if layer_Lens.name == "bgGlowPurple_Lens" {
                layer_Lens.frame = CGRect(x: -80, y: -60, width: 340, height: 340)
            } else if layer_Lens.name == "bgGlowCyan_Lens" {
                layer_Lens.frame = CGRect(x: view.bounds.width - 180, y: 420, width: 260, height: 260)
            }
        }
        spectrumBarView_Lens.layer.sublayers?.forEach { $0.frame = spectrumBarView_Lens.bounds }
        calendarGradient_Lens.frame = calendarCard_Lens.bounds
        calendarGradient_Lens.cornerRadius = 18
        danmakuGradient_Lens.frame = danmakuCard_Lens.bounds
        updateSummaryGradients_Lens()

        let topInset_Lens = view.safeAreaInsets.top
        // Tab 悬浮高度 + 目标间距，滚到底时弹幕池底部距屏幕底 = overlay + clearance
        let bottomInset_Lens = TabBar_Lens.tabOverlayHeight_Lens + tabBarClearance_Lens

        if topContentInset_Lens != topInset_Lens {
            topContentInset_Lens = topInset_Lens
            spectrumBarView_Lens.snp.updateConstraints {
                $0.top.equalToSuperview().offset(topInset_Lens + 12)
            }
        }

        if lastBottomInset_Lens != bottomInset_Lens {
            lastBottomInset_Lens = bottomInset_Lens
            scrollView_Lens.contentInset.bottom = bottomInset_Lens
            scrollView_Lens.verticalScrollIndicatorInsets.bottom = bottomInset_Lens
        }

        // 轮播已替换为热门帖子 + 功能入口，无需补刷
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 搭建

    private func setupBackground_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        view.addSubview(backgroundGlowView_Lens)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.28).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.locations = [0, 1]
        purple_Lens.startPoint = CGPoint(x: 0.2, y: 0)
        purple_Lens.endPoint = CGPoint(x: 0.8, y: 0.6)
        purple_Lens.frame = CGRect(x: -80, y: -60, width: 340, height: 340)
        purple_Lens.name = "bgGlowPurple_Lens"

        let cyan_Lens = CAGradientLayer()
        cyan_Lens.type = .radial
        cyan_Lens.colors = [
            UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0).cgColor
        ]
        cyan_Lens.locations = [0, 1]
        cyan_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        cyan_Lens.endPoint = CGPoint(x: 1, y: 1)
        cyan_Lens.frame = CGRect(x: UIScreen.main.bounds.width - 180, y: 420, width: 260, height: 260)
        cyan_Lens.name = "bgGlowCyan_Lens"

        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)
        backgroundGlowView_Lens.layer.addSublayer(cyan_Lens)
    }

    /// 添加装饰粒子光点
    private func setupDecorParticles_Lens() {
        decorParticlesView_Lens.subviews.forEach { $0.removeFromSuperview() }
        let points_Lens: [(CGFloat, CGFloat, CGFloat, UIColor)] = [
            (28, 90, 4, UIColor(hexstring_Lens: "#FFD93D", alpha_Lens: 0.5)),
            (320, 160, 3, UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.45)),
            (18, 480, 3, UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.4)),
            (340, 620, 5, UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.35)),
            (300, 780, 3, UIColor(hexstring_Lens: "#6BCB77", alpha_Lens: 0.35))
        ]
        for point_Lens in points_Lens {
            let dot_Lens = UIView()
            dot_Lens.backgroundColor = point_Lens.3
            dot_Lens.layer.cornerRadius = point_Lens.2
            decorParticlesView_Lens.addSubview(dot_Lens)
            dot_Lens.snp.makeConstraints {
                $0.width.height.equalTo(point_Lens.2 * 2)
                $0.leading.equalToSuperview().offset(point_Lens.0)
                $0.top.equalToSuperview().offset(point_Lens.1)
            }
        }
    }

    private func setupUI_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)

        let barGrad_Lens = CAGradientLayer()
        barGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#FF6B6B").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#C77DFF").cgColor
        ]
        barGrad_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        barGrad_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        spectrumBarView_Lens.layer.addSublayer(barGrad_Lens)

        contentView_Lens.addSubview(decorParticlesView_Lens)
        contentView_Lens.addSubview(spectrumBarView_Lens)
        contentView_Lens.addSubview(titleLabel_Lens)
        contentView_Lens.addSubview(subtitleLabel_Lens)
        contentView_Lens.addSubview(hotPostsView_Lens)
        contentView_Lens.addSubview(featureHubView_Lens)
        contentView_Lens.addSubview(calendarDescLabel_Lens)
        contentView_Lens.addSubview(calendarCard_Lens)
        calendarCard_Lens.layer.insertSublayer(calendarGradient_Lens, at: 0) 
        applySectionGradient_Lens(
            layer_Lens: calendarGradient_Lens,
            hexes_Lens: ["#4D96FF", "#7B2FF7", "#12122A"],
            alphas_Lens: [0.38, 0.22, 0.95]
        )
        calendarCard_Lens.addSubview(workCalendarView_Lens)
        contentView_Lens.addSubview(summaryDescLabel_Lens)
        contentView_Lens.addSubview(summaryHeader_Lens)
        summaryHeader_Lens.addSubview(summaryIconView_Lens)
        summaryHeader_Lens.addSubview(summaryTitleLabel_Lens)
        contentView_Lens.addSubview(summaryStack_Lens)
        contentView_Lens.addSubview(danmakuDescLabel_Lens)
        contentView_Lens.addSubview(danmakuCard_Lens)
        danmakuCard_Lens.layer.insertSublayer(danmakuGradient_Lens, at: 0)
        applySectionGradient_Lens(
            layer_Lens: danmakuGradient_Lens,
            hexes_Lens: ["#FF6B6B", "#C77DFF", "#1A1035"],
            alphas_Lens: [0.32, 0.28, 0.92]
        )
        danmakuCard_Lens.addSubview(danmakuPoolView_Lens)
        danmakuCard_Lens.addSubview(danmakuInput_Lens)
        danmakuCard_Lens.addSubview(danmakuSendBtn_Lens)

        danmakuSendBtn_Lens.addTarget(self, action: #selector(sendDanmaku_Lens), for: .touchUpInside)
        scrollView_Lens.danmakuTouchExclusionView_Lens = danmakuPoolView_Lens

        scrollView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        decorParticlesView_Lens.snp.makeConstraints {
            $0.edges.equalTo(contentView_Lens)
        }
        // 使用 contentLayoutGuide / frameLayoutGuide 正确计算 contentSize
        contentView_Lens.snp.makeConstraints { make in
            make.top.equalTo(scrollView_Lens.contentLayoutGuide)
            make.leading.equalTo(scrollView_Lens.contentLayoutGuide)
            make.trailing.equalTo(scrollView_Lens.contentLayoutGuide)
            make.bottom.equalTo(scrollView_Lens.contentLayoutGuide)
            make.width.equalTo(scrollView_Lens.frameLayoutGuide)
        }
        spectrumBarView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(56)
            $0.width.equalTo(44)
            $0.height.equalTo(4)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(spectrumBarView_Lens.snp.bottom).offset(10)
        }
        hotPostsView_Lens.onPostSelected_Lens = { [weak self] post_Lens in
            Navigation_Lens.toTitleDetail_Lens(titleModel_lens: post_Lens)
        }

        subtitleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(6)
        }
        hotPostsView_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(subtitleLabel_Lens.snp.bottom).offset(16)
        }
        featureHubView_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(hotPostsView_Lens.snp.bottom).offset(18)
        }
        calendarDescLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(featureHubView_Lens.snp.bottom).offset(16)
        }
        calendarCard_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(calendarDescLabel_Lens.snp.bottom).offset(8)
            calendarHeightConstraint_Lens = $0.height.equalTo(
                WorkCalendarView_Lens.collapsedHeight_Lens + calendarCardPadding_Lens
            ).constraint
        }
        workCalendarView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }

        workCalendarView_Lens.onHeightChanged_Lens = { [weak self] height_Lens in
            guard let self_Lens = self else { return }
            self_Lens.calendarHeightConstraint_Lens?.update(
                offset: height_Lens + self_Lens.calendarCardPadding_Lens
            )
            UIView.animate(withDuration: 0.28) {
                self_Lens.view.layoutIfNeeded()
            }
        }
        workCalendarView_Lens.onDateSelected_Lens = { [weak self] dateKey_Lens in
            self?.handleCalendarDateSelected_Lens(dateKey_Lens: dateKey_Lens)
        }
        summaryDescLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(calendarCard_Lens.snp.bottom).offset(14)
        }
        summaryHeader_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(summaryDescLabel_Lens.snp.bottom).offset(8)
            $0.height.equalTo(18)
        }
        summaryIconView_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        summaryTitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(summaryIconView_Lens.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
        }
        summaryStack_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(summaryHeader_Lens.snp.bottom).offset(8)
            $0.height.equalTo(72)
        }
        danmakuDescLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(summaryStack_Lens.snp.bottom).offset(14)
        }
        danmakuCard_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(danmakuDescLabel_Lens.snp.bottom).offset(8)
            $0.bottom.equalToSuperview()
        }
        danmakuPoolView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        danmakuInput_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(danmakuPoolView_Lens.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(40)
            $0.trailing.equalTo(danmakuSendBtn_Lens.snp.leading).offset(-8)
        }
        danmakuSendBtn_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(danmakuInput_Lens)
            $0.width.equalTo(64)
            $0.height.equalTo(40)
        }
        setupDecorParticles_Lens()
        addCalendarCornerDecor_Lens()
    }

    /// 日历卡片底部装饰光点（避免顶部圆角区域露边）
    private func addCalendarCornerDecor_Lens() {
        let corners_Lens: [(Bool, UIColor)] = [
            (true, UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.5)),
            (false, UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.4))
        ]
        for (isTrailing_Lens, color_Lens) in corners_Lens {
            let dot_Lens = UIView()
            dot_Lens.backgroundColor = color_Lens
            dot_Lens.layer.cornerRadius = 3
            calendarCard_Lens.addSubview(dot_Lens)
            dot_Lens.snp.makeConstraints {
                $0.width.height.equalTo(6)
                if isTrailing_Lens {
                    $0.trailing.equalToSuperview().inset(10)
                } else {
                    $0.leading.equalToSuperview().inset(10)
                }
                $0.bottom.equalToSuperview().inset(8)
            }
        }
    }

    /// 配置三大功能区入口
    private func setupFeatureHub_Lens() {
        featureHubView_Lens.configure_Lens(items_Lens: [
            HomeFeatureItem_Lens(
                title_Lens: "Creation\nTimeline",
                subtitle_Lens: "Record every step",
                iconName_Lens: "timeline.selection",
                accentHex_Lens: "#00D4FF",
                gradientHexes_Lens: ["#00D4FF", "#00A3E0", "#005F8A", "#0A1628"],
                onTap_Lens: { [weak self] in self?.openPortfolio_Lens() }
            ),
            HomeFeatureItem_Lens(
                title_Lens: "Acrylic\nLayers",
                subtitle_Lens: "Test & save colors",
                iconName_Lens: "square.stack.3d.up.fill",
                accentHex_Lens: "#FF6B9D",
                gradientHexes_Lens: ["#FF6B9D", "#E040FB", "#9C27B0", "#1A0A24"],
                onTap_Lens: { [weak self] in self?.openAcrylicStudio_Lens() }
            ),
            HomeFeatureItem_Lens(
                title_Lens: "Light\nStudio",
                subtitle_Lens: "12 light modes",
                iconName_Lens: "light.max",
                accentHex_Lens: "#FFD93D",
                gradientHexes_Lens: ["#FFE566", "#FFB84D", "#8B6914", "#0D0D1A"],
                onTap_Lens: { [weak self] in self?.openLightStudio_Lens() }
            )
        ])
    }

    private func registerNotifications_Lens() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadAll_Lens),
            name: StudioViewModel_Lens.studioStateDidChangeNotification_Lens, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadAll_Lens),
            name: TitleViewModel_Lens.titleStateDidChangeNotification_Lens, object: nil
        )
    }

    @objc private func reloadAll_Lens() {
        workCalendarView_Lens.refresh_Lens(
            activeDays_Lens: StudioViewModel_Lens.shared_Lens.getRecentActiveDays_Lens()
        )
        rebuildSummary_Lens()
        reloadHotPosts_Lens()
        danmakuPoolView_Lens.reload_Lens(items_Lens: StudioViewModel_Lens.shared_Lens.getDanmakus_Lens())
    }

    /// 刷新热门帖子推荐
    private func reloadHotPosts_Lens() {
        let hotPosts_Lens = TitleViewModel_Lens.shared_Lens.getPosts_Lens()
            .sorted { $0.likes_Lens > $1.likes_Lens }
            .prefix(8)
        hotPostsView_Lens.reload_Lens(posts_Lens: Array(hotPosts_Lens))
    }

    /// 日历日期选中：查看当日 Creation Timeline
    private func handleCalendarDateSelected_Lens(dateKey_Lens: String) {
        let artworks_Lens = StudioViewModel_Lens.shared_Lens.getArtworksOnDay_Lens(dateKey_Lens: dateKey_Lens)
        if artworks_Lens.isEmpty {
            Load_Lens.showInfo_Lens(message_Lens: "No Creation Timeline on this day.")
            return
        }
        if artworks_Lens.count == 1, let artwork_Lens = artworks_Lens.first {
            Navigation_Lens.toArtworkProcess_Lens(artworkId_Lens: artwork_Lens.artworkId_Lens)
            return
        }
        Navigation_Lens.toArtworkPortfolio_Lens(filterDateKey_Lens: dateKey_Lens)
    }

    /// 重建周期汇总数据卡片
    private func rebuildSummary_Lens() {
        summaryStack_Lens.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let s_Lens = StudioViewModel_Lens.shared_Lens.getPeriodSummary_Lens()
        let items_Lens: [(String, String, String)] = [
            ("\(s_Lens.weekArtworks_Lens)", "Works", "#4D96FF"),
            ("\(s_Lens.weekEvents_Lens)", "Steps", "#C77DFF"),
            ("\(s_Lens.weekLayerTests_Lens)", "Color Tests", "#FFD93D"),
            ("\(s_Lens.weekLightSessions_Lens)", "Light", "#6BCB77")
        ]
        for item_Lens in items_Lens {
            summaryStack_Lens.addArrangedSubview(makeStatCard_Lens(value_Lens: item_Lens.0, label_Lens: item_Lens.1, hex_Lens: item_Lens.2))
        }
    }

    /// 为功能区卡片配置对角渐变
    private func applySectionGradient_Lens(layer_Lens: CAGradientLayer, hexes_Lens: [String], alphas_Lens: [CGFloat]) {
        layer_Lens.colors = zip(hexes_Lens, alphas_Lens).map {
            UIColor(hexstring_Lens: $0.0, alpha_Lens: $0.1).cgColor
        }
        layer_Lens.locations = [0, 0.5, 1]
        layer_Lens.startPoint = CGPoint(x: 0, y: 0)
        layer_Lens.endPoint = CGPoint(x: 1, y: 1)
    }

    /// 同步汇总卡片的渐变图层尺寸
    private func updateSummaryGradients_Lens() {
        summaryStack_Lens.arrangedSubviews.forEach { card_Lens in
            card_Lens.layer.sublayers?
                .filter { $0.name == "statGradient_Lens" }
                .forEach { $0.frame = card_Lens.bounds }
        }
    }

    private func makeStatCard_Lens(value_Lens: String, label_Lens: String, hex_Lens: String) -> UIView {
        let card_Lens = UIView()
        card_Lens.backgroundColor = .clear
        card_Lens.layer.cornerRadius = 14
        card_Lens.layer.borderWidth = 1
        card_Lens.layer.borderColor = UIColor(hexstring_Lens: hex_Lens, alpha_Lens: 0.2).cgColor
        card_Lens.clipsToBounds = true

        let grad_Lens = CAGradientLayer()
        grad_Lens.name = "statGradient_Lens"
        grad_Lens.colors = [
            UIColor(hexstring_Lens: hex_Lens, alpha_Lens: 0.35).cgColor,
            UIColor(hexstring_Lens: "#1C1C35", alpha_Lens: 0.9).cgColor,
            UIColor(hexstring_Lens: "#12122A", alpha_Lens: 0.95).cgColor
        ]
        grad_Lens.locations = [0, 0.55, 1]
        grad_Lens.startPoint = CGPoint(x: 0, y: 0)
        grad_Lens.endPoint = CGPoint(x: 1, y: 1)
        grad_Lens.cornerRadius = 14
        card_Lens.layer.insertSublayer(grad_Lens, at: 0)

        let valLbl_Lens = UILabel()
        valLbl_Lens.text = value_Lens
        valLbl_Lens.font = .systemFont(ofSize: 18, weight: .bold)
        valLbl_Lens.textColor = UIColor(hexstring_Lens: hex_Lens)
        valLbl_Lens.textAlignment = .center

        let sparkle_Lens = UIImageView(image: UIImage(systemName: "sparkle"))
        sparkle_Lens.tintColor = UIColor(hexstring_Lens: hex_Lens, alpha_Lens: 0.45)
        sparkle_Lens.contentMode = .scaleAspectFit

        let titleLbl_Lens = UILabel()
        titleLbl_Lens.text = label_Lens
        titleLbl_Lens.font = .systemFont(ofSize: 9, weight: .medium)
        titleLbl_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        titleLbl_Lens.textAlignment = .center
        titleLbl_Lens.numberOfLines = 2
        titleLbl_Lens.adjustsFontSizeToFitWidth = true
        titleLbl_Lens.minimumScaleFactor = 0.75
        titleLbl_Lens.lineBreakMode = .byWordWrapping

        card_Lens.addSubview(valLbl_Lens)
        card_Lens.addSubview(sparkle_Lens)
        card_Lens.addSubview(titleLbl_Lens)
        sparkle_Lens.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(10)
        }
        valLbl_Lens.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.equalToSuperview().offset(12) }
        titleLbl_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.top.equalTo(valLbl_Lens.snp.bottom).offset(4)
            $0.bottom.lessThanOrEqualToSuperview().inset(8)
        }
        return card_Lens
    }

    // MARK: - 动作

    @objc private func openPortfolio_Lens() {
        Navigation_Lens.toArtworkPortfolio_Lens()
    }

    @objc private func openAcrylicStudio_Lens() {
        Navigation_Lens.toAcrylicStudio_Lens()
    }

    @objc private func openLightStudio_Lens() {
        Navigation_Lens.toLightStudio_Lens()
    }

    @objc private func sendDanmaku_Lens() {
        guard let text_Lens = danmakuInput_Lens.text else { return }
        if StudioViewModel_Lens.shared_Lens.postDanmaku_Lens(content_Lens: text_Lens) {
            danmakuInput_Lens.text = nil
            danmakuInput_Lens.resignFirstResponder()
            Load_Lens.showSuccess_Lens(message_Lens: "Danmaku sent!")
        }
    }
}

// MARK: - 首页 ScrollView（pan 手势 delegate 必须为 scrollView 自身）

/// HomeScrollView_Lens
/// 功能：首页纵向滚动容器，触摸弹幕操作按钮时不触发滚动
class HomeScrollView_Lens: UIScrollView, UIGestureRecognizerDelegate {

    /// 弹幕池视图：其内 UIButton 触摸不交给 pan 手势
    weak var danmakuTouchExclusionView_Lens: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        panGestureRecognizer.delegate = self
        panGestureRecognizer.cancelsTouchesInView = false
    }

    required init?(coder: NSCoder) { fatalError() }

    /// ScrollView 不取消弹幕池内 UIControl 的 touch 序列
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if let pool_Lens = danmakuTouchExclusionView_Lens,
           view.isDescendant(of: pool_Lens),
           view is UIControl {
            return false
        }
        return super.touchesShouldCancel(in: view)
    }

    /// 触摸落在弹幕池操作控件上时，不触发 ScrollView 拖动
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let pool_Lens = danmakuTouchExclusionView_Lens else { return true }
        var view_Lens: UIView? = touch.view
        while let current_Lens = view_Lens {
            if current_Lens is UIControl, current_Lens.isDescendant(of: pool_Lens) {
                return false
            }
            view_Lens = current_Lens.superview
        }
        return true
    }
}

// MARK: - 弹幕池视图

/// DanmakuBubbleView_Lens
/// 功能：单条飞行弹幕气泡，由 CADisplayLink 统一驱动位移
class DanmakuBubbleView_Lens: UIView {

    var item_Lens: DanmakuModel_Lens?
    var laneIndex_Lens: Int = 0
    var actionButton_Lens: UIButton?

    /// 仅操作按钮响应触摸，文字区域不拦截 ScrollView
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        if let btn_Lens = actionButton_Lens {
            let local_Lens = convert(point, to: btn_Lens)
            if btn_Lens.point(inside: local_Lens, with: event) {
                return btn_Lens.hitTest(local_Lens, with: event)
            }
        }
        return nil
    }
}

/// DanmakuPoolView_Lens
/// 功能：展示从右向左飞过的滚动弹幕；同一条数据不会同时重复出现，确认举报/删除后移除
class DanmakuPoolView_Lens: UIView {

    private var items_Lens: [DanmakuModel_Lens] = []
    private var animating_Lens = false
    private var scheduleWorkItem_Lens: DispatchWorkItem?
    private var displayLink_Lens: CADisplayLink?
    private var lastTickTime_Lens: CFTimeInterval = 0
    private var nextSpawnIndex_Lens = 0
    private var activeDanmakuIds_Lens = Set<Int>()
    private var flyingBubbles_Lens: [DanmakuBubbleView_Lens] = []

    weak var hostViewController_Lens: UIViewController?
    var onActionCompleted_Lens: (() -> Void)?

    private let laneCount_Lens = 4
    private let laneBaseY_Lens: CGFloat = 40
    private let laneSpacing_Lens: CGFloat = 30
    private let flySpeed_Lens: CGFloat = 60
    private let bubbleHeight_Lens: CGFloat = 28
    private var laneBusy_Lens = [Bool](repeating: false, count: 4)

    private let titleIconView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        v.tintColor = UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.55)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "DANMAKU POOL"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        l.isUserInteractionEnabled = false
        return l
    }()

    private let titleDivider_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08)
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isUserInteractionEnabled = true
        addSubview(titleIconView_Lens)
        addSubview(titleLabel_Lens)
        addSubview(titleDivider_Lens)
        titleIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.width.height.equalTo(14)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(titleIconView_Lens.snp.trailing).offset(6)
            $0.centerY.equalTo(titleIconView_Lens)
        }
        titleDivider_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(titleIconView_Lens.snp.bottom).offset(8)
            $0.height.equalTo(1)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit {
        stopDisplayLink_Lens()
    }

    /// 优先命中飞行弹幕及其操作按钮
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        for bubble_Lens in flyingBubbles_Lens.reversed() {
            let local_Lens = convert(point, to: bubble_Lens)
            if let hit_Lens = bubble_Lens.hitTest(local_Lens, with: event) {
                return hit_Lens
            }
        }
        return nil
    }

    func reload_Lens(items_Lens: [DanmakuModel_Lens]) {
        var seenIds_Lens = Set<Int>()
        self.items_Lens = items_Lens.filter { seenIds_Lens.insert($0.danmakuId_Lens).inserted }
    }

    func startAnimation_Lens() {
        guard !animating_Lens else { return }
        animating_Lens = true
        lastTickTime_Lens = 0
        clearFlyingDanmaku_Lens()
        startDisplayLink_Lens()
        scheduleNext_Lens()
    }

    func stopAnimation_Lens() {
        animating_Lens = false
        scheduleWorkItem_Lens?.cancel()
        scheduleWorkItem_Lens = nil
        stopDisplayLink_Lens()
        clearFlyingDanmaku_Lens()
    }

    /// 启动统一帧驱动，避免多条 UIViewPropertyAnimator 造成卡顿
    private func startDisplayLink_Lens() {
        guard displayLink_Lens == nil else { return }
        let link_Lens = CADisplayLink(target: self, selector: #selector(handleDisplayTick_Lens(_:)))
        link_Lens.add(to: .main, forMode: .common)
        displayLink_Lens = link_Lens
    }

    /// 停止帧驱动
    private func stopDisplayLink_Lens() {
        displayLink_Lens?.invalidate()
        displayLink_Lens = nil
        lastTickTime_Lens = 0
    }

    /// 每帧更新飞行弹幕位置
    @objc private func handleDisplayTick_Lens(_ link_Lens: CADisplayLink) {
        guard animating_Lens else { return }
        if lastTickTime_Lens == 0 {
            lastTickTime_Lens = link_Lens.timestamp
            return
        }
        let delta_Lens = CGFloat(link_Lens.timestamp - lastTickTime_Lens)
        lastTickTime_Lens = link_Lens.timestamp
        updateFlyingBubbles_Lens(deltaTime_Lens: delta_Lens)
    }

    /// 按速度位移并回收飞出屏幕的气泡
    private func updateFlyingBubbles_Lens(deltaTime_Lens: CGFloat) {
        let offset_Lens = flySpeed_Lens * deltaTime_Lens
        var finished_Lens: [DanmakuBubbleView_Lens] = []
        for bubble_Lens in flyingBubbles_Lens {
            var frame_Lens = bubble_Lens.frame
            frame_Lens.origin.x -= offset_Lens
            bubble_Lens.frame = frame_Lens
            if frame_Lens.maxX < -8 {
                finished_Lens.append(bubble_Lens)
            }
        }
        finished_Lens.forEach { finishBubble_Lens($0) }
    }

    private func clearFlyingDanmaku_Lens() {
        flyingBubbles_Lens.forEach { $0.removeFromSuperview() }
        flyingBubbles_Lens.removeAll()
        activeDanmakuIds_Lens.removeAll()
        laneBusy_Lens = [Bool](repeating: false, count: laneCount_Lens)
    }

    private func scheduleNext_Lens() {
        scheduleWorkItem_Lens?.cancel()
        guard animating_Lens, !items_Lens.isEmpty else { return }
        guard bounds.width > 10 else {
            let retry_Lens = DispatchWorkItem { [weak self] in self?.scheduleNext_Lens() }
            scheduleWorkItem_Lens = retry_Lens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: retry_Lens)
            return
        }

        let interval_Lens = max(1.2, min(2.4, Double(items_Lens.count) * 0.35))
        let work_Lens = DispatchWorkItem { [weak self] in
            guard let self_Lens = self, self_Lens.animating_Lens else { return }
            if self_Lens.spawnFlyingDanmaku_Lens() {
                self_Lens.scheduleNext_Lens()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self_Lens.scheduleNext_Lens()
                }
            }
        }
        scheduleWorkItem_Lens = work_Lens
        DispatchQueue.main.asyncAfter(deadline: .now() + interval_Lens, execute: work_Lens)
    }

    /// 选取下一条未在屏幕上的弹幕（轮播，避免同条重复飞行）
    private func pickNextItem_Lens() -> DanmakuModel_Lens? {
        guard !items_Lens.isEmpty else { return nil }
        let total_Lens = items_Lens.count
        for offset_Lens in 0..<total_Lens {
            let index_Lens = (nextSpawnIndex_Lens + offset_Lens) % total_Lens
            let item_Lens = items_Lens[index_Lens]
            if !activeDanmakuIds_Lens.contains(item_Lens.danmakuId_Lens) {
                nextSpawnIndex_Lens = (index_Lens + 1) % total_Lens
                return item_Lens
            }
        }
        return nil
    }

    /// 生成一条飞行弹幕，成功返回 true
    @discardableResult
    private func spawnFlyingDanmaku_Lens() -> Bool {
        guard bounds.width > 10,
              let item_Lens = pickNextItem_Lens(),
              let lane_Lens = laneBusy_Lens.firstIndex(where: { !$0 }) else { return false }

        let bubble_Lens = buildDanmakuBubble_Lens(item_Lens: item_Lens)
        bubble_Lens.laneIndex_Lens = lane_Lens
        laneBusy_Lens[lane_Lens] = true
        activeDanmakuIds_Lens.insert(item_Lens.danmakuId_Lens)

        let y_Lens = laneBaseY_Lens + CGFloat(lane_Lens) * laneSpacing_Lens
        bubble_Lens.frame = CGRect(
            x: bounds.width + 6,
            y: y_Lens,
            width: bubble_Lens.bounds.width,
            height: bubble_Lens.bounds.height
        )
        addSubview(bubble_Lens)
        flyingBubbles_Lens.append(bubble_Lens)
        return true
    }

    /// 弹幕飞出屏幕或确认删除后回收
    private func finishBubble_Lens(_ bubble_Lens: DanmakuBubbleView_Lens) {
        if let id_Lens = bubble_Lens.item_Lens?.danmakuId_Lens {
            activeDanmakuIds_Lens.remove(id_Lens)
        }
        laneBusy_Lens[bubble_Lens.laneIndex_Lens] = false
        flyingBubbles_Lens.removeAll { $0 === bubble_Lens }
        bubble_Lens.removeFromSuperview()
    }

    /// 移除指定弹幕（含仍在飞行的气泡）并同步本地数据源
    private func removeDanmakuById_Lens(danmakuId_Lens: Int) {
        items_Lens.removeAll { $0.danmakuId_Lens == danmakuId_Lens }
        flyingBubbles_Lens
            .filter { $0.item_Lens?.danmakuId_Lens == danmakuId_Lens }
            .forEach { finishBubble_Lens($0) }
    }

    /// 构建单条弹幕气泡（手动布局，避免 AutoLayout 动画卡顿）
    private func buildDanmakuBubble_Lens(item_Lens: DanmakuModel_Lens) -> DanmakuBubbleView_Lens {
        let bubble_Lens = DanmakuBubbleView_Lens()
        bubble_Lens.item_Lens = item_Lens
        bubble_Lens.isUserInteractionEnabled = true
        bubble_Lens.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.38)
        bubble_Lens.clipsToBounds = true

        let bubbleH_Lens = bubbleHeight_Lens
        let hasAction_Lens = hostViewController_Lens != nil
        let btnSize_Lens = bubbleH_Lens - 4
        let horizontalPad_Lens: CGFloat = 10
        let trailingPad_Lens: CGFloat = hasAction_Lens ? (btnSize_Lens + 10) : horizontalPad_Lens

        let textLabel_Lens = UILabel()
        textLabel_Lens.isUserInteractionEnabled = false
        textLabel_Lens.text = "\(item_Lens.userName_Lens): \(item_Lens.content_Lens)"
        textLabel_Lens.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel_Lens.textColor = UIColor(hexstring_Lens: item_Lens.colorHex_Lens)
        textLabel_Lens.lineBreakMode = .byTruncatingTail

        let maxTextW_Lens = max(bounds.width * 0.55, 120)
        let textSize_Lens = textLabel_Lens.sizeThatFits(CGSize(width: maxTextW_Lens, height: bubbleH_Lens))
        let textW_Lens = min(textSize_Lens.width, maxTextW_Lens)
        let bubbleW_Lens = horizontalPad_Lens + textW_Lens + trailingPad_Lens

        textLabel_Lens.frame = CGRect(
            x: horizontalPad_Lens,
            y: (bubbleH_Lens - 16) / 2,
            width: textW_Lens,
            height: 16
        )
        bubble_Lens.addSubview(textLabel_Lens)

        if let host_Lens = hostViewController_Lens {
            let actionBtn_Lens = ReportDeleteHelper_Lens.createDanmakuActionButton_Lens(
                danmaku_Lens: item_Lens,
                buttonSize_Lens: btnSize_Lens,
                from: host_Lens,
                completion_Lens: { [weak self] in
                    guard let self_Lens = self else { return }
                    self_Lens.removeDanmakuById_Lens(danmakuId_Lens: item_Lens.danmakuId_Lens)
                    self_Lens.onActionCompleted_Lens?()
                }
            )
            actionBtn_Lens.frame = CGRect(
                x: bubbleW_Lens - btnSize_Lens - 6,
                y: (bubbleH_Lens - btnSize_Lens) / 2,
                width: btnSize_Lens,
                height: btnSize_Lens
            )
            bubble_Lens.addSubview(actionBtn_Lens)
            bubble_Lens.actionButton_Lens = actionBtn_Lens
        }

        bubble_Lens.bounds = CGRect(x: 0, y: 0, width: bubbleW_Lens, height: bubbleH_Lens)
        bubble_Lens.layer.cornerRadius = bubbleH_Lens / 2
        return bubble_Lens
    }
}
