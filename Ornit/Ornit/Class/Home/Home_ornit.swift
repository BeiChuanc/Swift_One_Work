import UIKit
import SnapKit

// MARK: 首页

/// 观鸟爱好者首页
/// 功能：每日打卡 / 观鸟数据看板 / 四季专题 / 技巧 Tips 卡片
/// 设计：深紫渐变 Header + ScrollView 纵向内容区
class Home_Ornit: UIViewController {
    
    // MARK: - 私有属性
    
    /// 主滚动视图
    private let scrollView_Ornit = UIScrollView()
    private let contentView_Ornit = UIView()
    
    /// Header 渐变图层
    private var headerGradient_Ornit: CAGradientLayer?
    private let headerView_Ornit = UIView()

    /// 打卡按钮（Header 右侧）
    private let checkInButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn_ornit.setTitleColor(.white, for: .normal)
        btn_ornit.layer.cornerRadius = 16
        btn_ornit.layer.borderWidth = 1.5
        btn_ornit.layer.borderColor = UIColor.white.withValues(alpha: 0.5).cgColor
        btn_ornit.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        return btn_ornit
    }()
    
    /// 观鸟看板卡片（仅登录用户显示）
    private let dashboardCard_Ornit = UIView()

    /// 观鸟记录列表容器（同时持有空状态标签，统一控制卡片高度）
    private let observationsStack_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .vertical
        sv_ornit.spacing = 8
        return sv_ornit
    }()
    
    /// 观鸟看板空状态标签（作为 observationsStack 的 arrangedSubview 管理）
    private let dashboardEmptyLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "No observations yet. Tap + to add your first sighting!"
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .center
        label_ornit.numberOfLines = 2
        return label_ornit
    }()
    
    /// Tips 详情遮罩层引用（用于正确释放，防止遮罩卡住页面）
    private weak var tipDetailOverlay_Ornit: UIView?

    // MARK: - 静态数据

    /// 12 条技巧卡片
    private let tipCards_Ornit: [TipCard_Ornit] = [
        TipCard_Ornit(tipId_Ornit: 1, category_Ornit: "Photography",
            title_Ornit: "Golden Hour Magic",
            content_Ornit: "Shoot in the first and last hour of sunlight. The warm, angled light dramatically enhances feather colors and creates a natural bokeh effect when shooting wide open.\n\nSet your alarm 30 minutes before sunrise and find your position before the birds are active. The rewards are worth every early morning.",
            iconName_Ornit: "sun.horizon.fill", accentColor_Ornit: "#F59E0B"),
        TipCard_Ornit(tipId_Ornit: 2, category_Ornit: "Photography",
            title_Ornit: "Burst Mode Mastery",
            content_Ornit: "Enable continuous burst mode when birds take flight or display behavior. Modern cameras capture 10-20 frames per second—you only need one perfect shot from dozens.\n\nPre-focus on the perch where a bird is sitting, then hold burst as it takes off. Review sequences to find the peak action moment.",
            iconName_Ornit: "camera.fill", accentColor_Ornit: "#8B5CF6"),
        TipCard_Ornit(tipId_Ornit: 3, category_Ornit: "Photography",
            title_Ornit: "Clean Backgrounds",
            content_Ornit: "A cluttered background destroys an otherwise great bird photo. Get low, move laterally, and find an angle where the background is sky, water, or a uniform color.\n\nThe distance between subject and background matters more than the aperture. Even f/8 can blur a background that is 20 meters behind your subject.",
            iconName_Ornit: "photo.artframe", accentColor_Ornit: "#059669"),
        TipCard_Ornit(tipId_Ornit: 4, category_Ornit: "Observation",
            title_Ornit: "The Silent Approach",
            content_Ornit: "Move slowly and deliberately, stopping for 30 seconds every few steps. Birds detect movement through peripheral vision—stillness is your greatest ally in the field.\n\nWear muted earth tones and avoid synthetic fabrics that rustle loudly. Your shadow can alert birds before you even see them; keep it behind you when possible.",
            iconName_Ornit: "figure.walk", accentColor_Ornit: "#34D399"),
        TipCard_Ornit(tipId_Ornit: 5, category_Ornit: "Observation",
            title_Ornit: "Binocular Technique",
            content_Ornit: "Keep your eyes locked on the bird before raising your binoculars—never look down at the optics first. Practice the motion until it becomes automatic muscle memory.\n\nSet the diopter adjustment for your weaker eye once and leave it. In cold weather, keep optics inside your jacket to prevent fogging.",
            iconName_Ornit: "binoculars.fill", accentColor_Ornit: "#2563EB"),
        TipCard_Ornit(tipId_Ornit: 6, category_Ornit: "Observation",
            title_Ornit: "Learn Bird Songs",
            content_Ornit: "60% of birdwatching success comes from your ears. Learning 20 common calls in your local area dramatically increases detection rates before you ever raise binoculars.\n\nUse apps like Merlin to practice identification by ear. Focus on distinctive songs rather than call notes—songs are more consistent and easier to learn.",
            iconName_Ornit: "waveform", accentColor_Ornit: "#EC4899"),
        TipCard_Ornit(tipId_Ornit: 7, category_Ornit: "Observation",
            title_Ornit: "Feeding Behavior Patterns",
            content_Ornit: "Understanding how a species feeds reveals where to find it. Ground feeders prefer open grass; bark gleaners work tree trunks; aerial insectivores follow insect hatches.\n\nObserve a bird's foraging behavior for 60 seconds before moving on. This patience often reveals more individuals and occasionally rare species.",
            iconName_Ornit: "bird.fill", accentColor_Ornit: "#F97316"),
        TipCard_Ornit(tipId_Ornit: 8, category_Ornit: "Route",
            title_Ornit: "Edge Habitat Strategy",
            content_Ornit: "The boundary between two habitat types—woodland edge, marsh edge, forest/grassland transition—consistently hosts the highest species diversity.\n\nPlan routes that maximize time along these transitional zones rather than deep within a single habitat type. A single morning along a woodland edge typically outperforms a full day in uniform forest.",
            iconName_Ornit: "map.fill", accentColor_Ornit: "#10B981"),
        TipCard_Ornit(tipId_Ornit: 9, category_Ornit: "Route",
            title_Ornit: "Water Sources First",
            content_Ornit: "In any habitat, locate water sources as your first destination. Birds visit predictably at dawn and dusk, and even small puddles become reliable observation points during dry periods.\n\nPonds with emergent vegetation are especially productive—they attract both waterbirds and songbirds coming to bathe and drink.",
            iconName_Ornit: "drop.fill", accentColor_Ornit: "#0EA5E9"),
        TipCard_Ornit(tipId_Ornit: 10, category_Ornit: "Route",
            title_Ornit: "Dawn Patrol Timing",
            content_Ornit: "Bird activity peaks in the two hours after sunrise. Activity drops significantly by 10 AM in summer as birds seek shade and reduce exposure to predators.\n\nArrive at your site 15 minutes before sunrise to hear the full dawn chorus. The first light reveals silhouettes that help identify species before color becomes visible.",
            iconName_Ornit: "sunrise.fill", accentColor_Ornit: "#FBB60A"),
        TipCard_Ornit(tipId_Ornit: 11, category_Ornit: "Route",
            title_Ornit: "Seasonal Migration Paths",
            content_Ornit: "Research established flyways and stopover sites in your region. Migratory birds follow the same routes annually, making timing and location predictable with experience.\n\nCoastal ridgelines concentrate raptors; river valleys funnel passerine migrants; headlands trap exhausted birds after long water crossings.",
            iconName_Ornit: "arrow.up.right.circle.fill", accentColor_Ornit: "#7C3AED"),
        TipCard_Ornit(tipId_Ornit: 12, category_Ornit: "Route",
            title_Ornit: "Habitat Diversity",
            content_Ornit: "A route covering three or more distinct habitat types in a single outing will always outperform one confined to a single habitat, regardless of habitat quality.\n\nDesign your birding route as a loop that moves through woodland, open ground, and water. Even a half-kilometer loop with habitat variety can produce 30+ species in peak seasons.",
            iconName_Ornit: "globe.americas.fill", accentColor_Ornit: "#BE185D")
    ]
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        setupScrollView_Ornit()
        setupHeaderView_Ornit()
        setupCheckInSection_Ornit()
        setupBirdDashboard_Ornit()
        setupSeasonalTopics_Ornit()
        setupTipsSection_Ornit()
        setupNotifications_Ornit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAllSections_Ornit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知监听
    
    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Ornit),
            name: UserViewModel_Ornit.userStateDidChangeNotification_Ornit,
            object: nil
        )
    }
    
    @objc private func handleStateChange_Ornit() {
        refreshAllSections_Ornit()
    }

    // MARK: - 数据刷新

    /// 刷新所有可变 UI 区域
    private func refreshAllSections_Ornit() {
        refreshCheckInButton_Ornit()
        refreshDashboard_Ornit()
    }

    /// 刷新打卡按钮状态
    private func refreshCheckInButton_Ornit() {
        let checkedIn_ornit = UserViewModel_Ornit.shared_Ornit.hasCheckedInToday_Ornit()
        let isLoggedIn_ornit = UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit

        if !isLoggedIn_ornit {
            checkInButton_Ornit.setTitle("Login to Check In", for: .normal)
            checkInButton_Ornit.backgroundColor = UIColor.white.withValues(alpha: 0.15)
        } else if checkedIn_ornit {
            checkInButton_Ornit.setTitle("✓ Checked In", for: .normal)
            checkInButton_Ornit.backgroundColor = UIColor.white.withValues(alpha: 0.25)
        } else {
            checkInButton_Ornit.setTitle("Check In Today", for: .normal)
            checkInButton_Ornit.backgroundColor = UIColor.white.withValues(alpha: 0.15)
        }
    }

    /// 刷新观鸟看板（打卡统计 + 记录列表）
    private func refreshDashboard_Ornit() {
        // 更新打卡统计区
        refreshCheckInStats_Ornit()
        // 更新观鸟记录列表
        refreshObservationsList_Ornit()
        // 登录状态控制看板显示
        dashboardCard_Ornit.isHidden = false
    }
    
    // MARK: - UI 搭建
    
    private func setupScrollView_Ornit() {
        scrollView_Ornit.showsVerticalScrollIndicator = false
        scrollView_Ornit.contentInsetAdjustmentBehavior = .never
        scrollView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)
        
        scrollView_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }
        contentView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.width.equalToSuperview()
        }
    }

    /// 构建顶部渐变 Header（App 名 + 问候 + 日期 + 打卡按钮）
    private func setupHeaderView_Ornit() {
        contentView_Ornit.addSubview(headerView_Ornit)
        
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor,
            ColorConfig_Ornit.messageGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.locations = [0, 0.6, 1]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit
        headerView_Ornit.layer.cornerRadius = 28
        headerView_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Ornit.clipsToBounds = true

        // 装饰圆
        let deco1_ornit = UIView()
        deco1_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        deco1_ornit.layer.cornerRadius = 70
        headerView_Ornit.addSubview(deco1_ornit)

        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco2_ornit.layer.cornerRadius = 48
        headerView_Ornit.addSubview(deco2_ornit)

        // App 名
        let appNameLabel_ornit = UILabel()
        appNameLabel_ornit.text = "Ornit"
        appNameLabel_ornit.font = UIFont.systemFont(ofSize: 28, weight: .black)
        appNameLabel_ornit.textColor = .white
        headerView_Ornit.addSubview(appNameLabel_ornit)

        // 问候语（根据时段变化）
        let greetingLabel_ornit = UILabel()
        greetingLabel_ornit.text = timeGreeting_Ornit()
        greetingLabel_ornit.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        greetingLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.78)
        headerView_Ornit.addSubview(greetingLabel_ornit)

        // 日期标签
        let dateLabel_ornit = UILabel()
        dateLabel_ornit.text = formattedDate_Ornit()
        dateLabel_ornit.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.6)
        headerView_Ornit.addSubview(dateLabel_ornit)

        // 打卡按钮
        headerView_Ornit.addSubview(checkInButton_Ornit)
        
        // 装饰鸟图标
        let birdConfig_ornit = UIImage.SymbolConfiguration(pointSize: 36, weight: .thin)
        let birdIcon_ornit = UIImageView(
            image: UIImage(systemName: "bird.fill", withConfiguration: birdConfig_ornit)
        )
        birdIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.15)
        headerView_Ornit.addSubview(birdIcon_ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(158)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(48)
            make_ornit.top.equalToSuperview().offset(-28)
            make_ornit.width.height.equalTo(140)
        }
        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-20)
            make_ornit.bottom.equalToSuperview().offset(24)
            make_ornit.width.height.equalTo(96)
        }

        appNameLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalToSuperview().offset(58)
        }

        greetingLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(appNameLabel_ornit.snp.bottom).offset(4)
        }

        dateLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(greetingLabel_ornit.snp.bottom).offset(3)
        }

        checkInButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.centerY.equalTo(appNameLabel_ornit).offset(4)
            make_ornit.height.equalTo(34)
        }

        birdIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-18)
            make_ornit.bottom.equalToSuperview().offset(-10)
            make_ornit.width.height.equalTo(50)
        }
        
        checkInButton_Ornit.addTarget(self, action: #selector(checkInTapped_Ornit), for: .touchUpInside)
        refreshCheckInButton_Ornit()
    }

    // MARK: - 每日打卡区

    /// 构建每日打卡展示区（7 日历条 + 连续打卡天数）
    private func setupCheckInSection_Ornit() {
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 20
        card_ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.1).cgColor
        card_ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_ornit.layer.shadowOpacity = 1
        card_ornit.layer.shadowRadius = 10
        card_ornit.tag = 10001
        contentView_Ornit.addSubview(card_ornit)

        // 区段标题行
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = "Daily Check-in"
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        card_ornit.addSubview(titleLabel_ornit)

        // 连续打卡数（标签 + 数字）
        let streakContainer_ornit = UIView()
        streakContainer_ornit.backgroundColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.1)
        streakContainer_ornit.layer.cornerRadius = 12
        streakContainer_ornit.tag = 10002
        card_ornit.addSubview(streakContainer_ornit)

        let streakLabel_ornit = UILabel()
        streakLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        streakLabel_ornit.textColor = ColorConfig_Ornit.meAccent_Ornit
        streakLabel_ornit.tag = 10003
        streakContainer_ornit.addSubview(streakLabel_ornit)

        // 7 日历条容器
        let calendarRow_ornit = UIStackView()
        calendarRow_ornit.axis = .horizontal
        calendarRow_ornit.distribution = .fillEqually
        calendarRow_ornit.spacing = 6
        calendarRow_ornit.tag = 10004
        card_ornit.addSubview(calendarRow_ornit)

        card_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(18)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(16)
            make_ornit.leading.equalToSuperview().offset(16)
        }

        streakContainer_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.centerY.equalTo(titleLabel_ornit)
            make_ornit.height.equalTo(26)
        }

        streakLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerY.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview().inset(10)
        }

        calendarRow_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-16)
            make_ornit.height.equalTo(52)
        }

        buildCalendarDots_Ornit(stack_ornit: calendarRow_ornit)
        refreshCheckInStats_Ornit()
    }

    /// 构建 7 天日历圆点列
    private func buildCalendarDots_Ornit(stack_ornit: UIStackView) {
        stack_ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let dates_ornit = Set(UserViewModel_Ornit.shared_Ornit.getCheckInDates_Ornit())
        let fmt_ornit = DateFormatter()
        fmt_ornit.dateFormat = "yyyy-MM-dd"
        let dayFmt_ornit = DateFormatter()
        dayFmt_ornit.dateFormat = "E"

        for i_ornit in (0..<7).reversed() {
            let date_ornit = Calendar.current.date(byAdding: .day, value: -i_ornit, to: Date()) ?? Date()
            let dateStr_ornit = fmt_ornit.string(from: date_ornit)
            let isToday_ornit = i_ornit == 0
            let checkedIn_ornit = dates_ornit.contains(dateStr_ornit)

            let cell_ornit = UIView()
            stack_ornit.addArrangedSubview(cell_ornit)

            // 圆点
            let dot_ornit = UIView()
            dot_ornit.layer.cornerRadius = 14
            if checkedIn_ornit {
                dot_ornit.backgroundColor = ColorConfig_Ornit.meAccent_Ornit
            } else if isToday_ornit {
                dot_ornit.backgroundColor = .clear
                dot_ornit.layer.borderWidth = 2
                dot_ornit.layer.borderColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.5).cgColor
            } else {
                dot_ornit.backgroundColor = ColorConfig_Ornit.backgroundPrimary_Ornit
            }
            cell_ornit.addSubview(dot_ornit)

            // 日期缩写
            let dayLabel_ornit = UILabel()
            dayLabel_ornit.text = dayFmt_ornit.string(from: date_ornit)
            dayLabel_ornit.font = UIFont.systemFont(ofSize: 10, weight: isToday_ornit ? .bold : .regular)
            dayLabel_ornit.textColor = isToday_ornit ? ColorConfig_Ornit.meAccent_Ornit : ColorConfig_Ornit.textPlaceholder_Ornit
            dayLabel_ornit.textAlignment = .center
            cell_ornit.addSubview(dayLabel_ornit)

            // 打卡图标（已打卡时显示）
            if checkedIn_ornit {
                let checkIcon_ornit = UIImageView(
                    image: UIImage(systemName: "checkmark", withConfiguration:
                        UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
                )
                checkIcon_ornit.tintColor = .white
                checkIcon_ornit.contentMode = .scaleAspectFit
                dot_ornit.addSubview(checkIcon_ornit)
                checkIcon_ornit.snp.makeConstraints { make_ornit in make_ornit.center.equalToSuperview(); make_ornit.width.height.equalTo(12) }
            }

            dot_ornit.snp.makeConstraints { make_ornit in
                make_ornit.top.equalToSuperview()
                make_ornit.centerX.equalToSuperview()
                make_ornit.width.height.equalTo(28)
            }
            dayLabel_ornit.snp.makeConstraints { make_ornit in
                make_ornit.bottom.equalToSuperview()
                make_ornit.centerX.equalToSuperview()
            }
        }
    }

    /// 刷新打卡统计标签和日历圆点
    private func refreshCheckInStats_Ornit() {
        guard let card_ornit = contentView_Ornit.viewWithTag(10001) else { return }

        let streak_ornit = UserViewModel_Ornit.shared_Ornit.getCheckInStreak_Ornit()
        if let streakLabel_ornit = card_ornit.viewWithTag(10003) as? UILabel {
            streakLabel_ornit.text = "🔥 \(streak_ornit) day streak"
        }

        if let calRow_ornit = card_ornit.viewWithTag(10004) as? UIStackView {
            buildCalendarDots_Ornit(stack_ornit: calRow_ornit)
        }
    }

    // MARK: - 观鸟数据看板

    /// 构建观鸟数据看板（统计行 + 观测记录列表）
    private func setupBirdDashboard_Ornit() {
        dashboardCard_Ornit.backgroundColor = .white
        dashboardCard_Ornit.layer.cornerRadius = 20
        dashboardCard_Ornit.layer.shadowColor = ColorConfig_Ornit.discoverGradientStart_Ornit.withValues(alpha: 0.1).cgColor
        dashboardCard_Ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        dashboardCard_Ornit.layer.shadowOpacity = 1
        dashboardCard_Ornit.layer.shadowRadius = 10
        contentView_Ornit.addSubview(dashboardCard_Ornit)

        // 标题行
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = "My Birdwatching Dashboard"
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        dashboardCard_Ornit.addSubview(titleLabel_ornit)

        // 添加记录按钮
        let addBtn_ornit = UIButton(type: .system)
        let addConfig_ornit = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        addBtn_ornit.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: addConfig_ornit), for: .normal)
        addBtn_ornit.tintColor = ColorConfig_Ornit.naturePrimary_Ornit
        addBtn_ornit.addTarget(self, action: #selector(addObservationTapped_Ornit), for: .touchUpInside)
        dashboardCard_Ornit.addSubview(addBtn_ornit)

        // 统计数据行（equalSpacing 确保分隔线不被拉伸为等宽灰色方块）
        let statsRow_ornit = UIStackView()
        statsRow_ornit.axis = .horizontal
        statsRow_ornit.alignment = .center
        statsRow_ornit.spacing = 0
        statsRow_ornit.distribution = .equalSpacing
        statsRow_ornit.tag = 20001
        dashboardCard_Ornit.addSubview(statsRow_ornit)

        // 分割线
        let divider_ornit = UIView()
        divider_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        dashboardCard_Ornit.addSubview(divider_ornit)

        // 观测记录区段标题
        let recLabel_ornit = UILabel()
        recLabel_ornit.text = "Recent Observations"
        recLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        recLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        dashboardCard_Ornit.addSubview(recLabel_ornit)

        // 观测记录列表（含空状态标签，底部约束决定卡片高度）
        dashboardCard_Ornit.addSubview(observationsStack_Ornit)

        // 约束
        let checkInCard_ornit = contentView_Ornit.viewWithTag(10001)!
        dashboardCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(checkInCard_ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(16)
            make_ornit.leading.equalToSuperview().offset(16)
        }

        addBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.centerY.equalTo(titleLabel_ornit)
            make_ornit.width.height.equalTo(28)
        }

        statsRow_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.height.equalTo(56)
        }

        divider_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(statsRow_ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.height.equalTo(0.5)
        }

        recLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(divider_ornit.snp.bottom).offset(12)
            make_ornit.leading.equalToSuperview().offset(16)
        }

        // observationsStack 的 bottom 决定 dashboardCard 的高度
        observationsStack_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(recLabel_ornit.snp.bottom).offset(10)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-16)
        }

        refreshDashboard_Ornit()
    }

    /// 刷新统计数据行和观测列表
    private func refreshObservationsList_Ornit() {
        let obs_ornit = UserViewModel_Ornit.shared_Ornit.getBirdObservations_Ornit()
        let isLoggedIn_ornit = UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit

        // 更新统计行
        if let statsRow_ornit = dashboardCard_Ornit.viewWithTag(20001) as? UIStackView {
            statsRow_ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }
            let speciesCount_ornit = Set(obs_ornit.map { $0.birdName_Ornit }).count
            let dayCount_ornit = Set(obs_ornit.map { $0.observeDate_Ornit }).count
            let postCount_ornit = TitleViewModel_Ornit.shared_Ornit.getPosts_Ornit().filter {
                $0.titleUserId_Ornit == (UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit().userId_Ornit ?? -1)
            }.count

            let statItems_ornit: [(String, String, UIColor)] = [
                ("\(isLoggedIn_ornit ? speciesCount_ornit : 0)", "Species", ColorConfig_Ornit.naturePrimary_Ornit),
                ("\(isLoggedIn_ornit ? dayCount_ornit : 0)", "Obs Days", ColorConfig_Ornit.discoverGradientEnd_Ornit),
                ("\(isLoggedIn_ornit ? postCount_ornit : 0)", "Posts", ColorConfig_Ornit.meAccent_Ornit)
            ]

            for (i_ornit, (value_ornit, label_ornit, color_ornit)) in statItems_ornit.enumerated() {
                let item_ornit = makeDashStatItem_Ornit(value_ornit: value_ornit, label_ornit: label_ornit, color_ornit: color_ornit)
                statsRow_ornit.addArrangedSubview(item_ornit)
                if i_ornit < 2 {
                    let sep_ornit = UIView()
                    sep_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
                    sep_ornit.snp.makeConstraints { make_ornit in make_ornit.width.equalTo(0.5) }
                    statsRow_ornit.addArrangedSubview(sep_ornit)
                }
            }
        }

        // 更新观测列表（清空所有 arrangedSubview，包括空状态标签）
        observationsStack_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let isEmpty_ornit = obs_ornit.isEmpty || !isLoggedIn_ornit

        if isEmpty_ornit {
            // 无数据时将空状态标签加入 stack，由 stack.bottom 决定卡片高度
            dashboardEmptyLabel_Ornit.text = isLoggedIn_ornit
                ? "No observations yet. Tap + to add your first sighting!"
                : "Login to start tracking your bird sightings!"
            observationsStack_Ornit.addArrangedSubview(dashboardEmptyLabel_Ornit)
            return
        }

        // 展示最近 5 条记录
        for obs_item_ornit in obs_ornit.suffix(5).reversed() {
            observationsStack_Ornit.addArrangedSubview(makeObsRow_Ornit(obs_ornit: obs_item_ornit))
        }
    }

    /// 创建统计数据单项
    private func makeDashStatItem_Ornit(value_ornit: String, label_ornit: String, color_ornit: UIColor) -> UIView {
        let container_ornit = UIView()
        let valLabel_ornit = UILabel()
        valLabel_ornit.text = value_ornit
        valLabel_ornit.font = UIFont.systemFont(ofSize: 22, weight: .black)
        valLabel_ornit.textColor = color_ornit
        valLabel_ornit.textAlignment = .center
        container_ornit.addSubview(valLabel_ornit)

        let lbl_ornit = UILabel()
        lbl_ornit.text = label_ornit
        lbl_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        lbl_ornit.textAlignment = .center
        container_ornit.addSubview(lbl_ornit)

        // 显式约束宽度，防止 equalSpacing 分布时容器宽度为 0 导致内容渲染在卡片外
        valLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview()
        }
        lbl_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(valLabel_ornit.snp.bottom).offset(3)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
        return container_ornit
    }

    /// 创建单条观测记录行
    private func makeObsRow_Ornit(obs_ornit: BirdObservation_Ornit) -> UIView {
        let row_ornit = UIView()
        row_ornit.backgroundColor = ColorConfig_Ornit.backgroundNature_Ornit
        row_ornit.layer.cornerRadius = 10

        let birdLabel_ornit = UILabel()
        birdLabel_ornit.text = obs_ornit.birdName_Ornit
        birdLabel_ornit.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        birdLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        row_ornit.addSubview(birdLabel_ornit)

        let countLabel_ornit = UILabel()
        countLabel_ornit.text = "×\(obs_ornit.count_Ornit)"
        countLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        countLabel_ornit.textColor = ColorConfig_Ornit.naturePrimary_Ornit
        row_ornit.addSubview(countLabel_ornit)

        let dateLabel_ornit = UILabel()
        dateLabel_ornit.text = obs_ornit.observeDate_Ornit
        dateLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        row_ornit.addSubview(dateLabel_ornit)

        // 删除按钮
        let delBtn_ornit = UIButton(type: .system)
        let delConfig_ornit = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        delBtn_ornit.setImage(UIImage(systemName: "trash", withConfiguration: delConfig_ornit), for: .normal)
        delBtn_ornit.tintColor = ColorConfig_Ornit.textPlaceholder_Ornit
        let oid_ornit = obs_ornit.observationId_Ornit
        delBtn_ornit.addAction(UIAction { [weak self] _ in
            UserViewModel_Ornit.shared_Ornit.deleteBirdObservation_Ornit(observationId_ornit: oid_ornit)
            self?.refreshObservationsList_Ornit()
        }, for: .touchUpInside)
        row_ornit.addSubview(delBtn_ornit)

        birdLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.top.equalToSuperview().offset(10)
        }
        dateLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.top.equalTo(birdLabel_ornit.snp.bottom).offset(2)
            make_ornit.bottom.equalToSuperview().offset(-10)
        }
        countLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalTo(delBtn_ornit.snp.leading).offset(-10)
            make_ornit.centerY.equalToSuperview()
        }
        delBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(28)
        }

        return row_ornit
    }

    // MARK: - 四季专题区

    /// 构建四季专题横向滚动区
    private func setupSeasonalTopics_Ornit() {
        let sectionTitle_ornit = UILabel()
        sectionTitle_ornit.text = "Seasonal Topics"
        sectionTitle_ornit.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        sectionTitle_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        contentView_Ornit.addSubview(sectionTitle_ornit)

        let scroll_ornit = UIScrollView()
        scroll_ornit.showsHorizontalScrollIndicator = false
        scroll_ornit.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        contentView_Ornit.addSubview(scroll_ornit)

        let stack_ornit = UIStackView()
        stack_ornit.axis = .horizontal
        stack_ornit.spacing = 14
        stack_ornit.alignment = .fill
        scroll_ornit.addSubview(stack_ornit)

        sectionTitle_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(dashboardCard_Ornit.snp.bottom).offset(24)
            make_ornit.leading.equalToSuperview().offset(20)
        }

        scroll_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(sectionTitle_ornit.snp.bottom).offset(14)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(190)
        }

        stack_ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.height.equalToSuperview()
        }

        let topics_ornit = LocalData_Ornit.shared_Ornit.seasonalTopics_Ornit
        for topic_ornit in topics_ornit {
            let card_ornit = makeTopicCard_Ornit(topic_ornit: topic_ornit)
            stack_ornit.addArrangedSubview(card_ornit)
            card_ornit.snp.makeConstraints { make_ornit in
                make_ornit.width.equalTo(200)
            }
        }
    }

    /// 创建单个专题卡片
    private func makeTopicCard_Ornit(topic_ornit: SeasonalTopic_Ornit) -> UIView {
        let card_ornit = UIView()
        card_ornit.layer.cornerRadius = 18
        card_ornit.clipsToBounds = true
        card_ornit.isUserInteractionEnabled = true
        
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            UIColor(hexstring_Ornit: topic_ornit.gradientStart_Ornit).cgColor,
            UIColor(hexstring_Ornit: topic_ornit.gradientEnd_Ornit).cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        card_ornit.layer.insertSublayer(gradient_ornit, at: 0)
        
        DispatchQueue.main.async { gradient_ornit.frame = card_ornit.bounds }

        // 装饰圆
        let deco_ornit = UIView()
        deco_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.1)
        deco_ornit.layer.cornerRadius = 36
        card_ornit.addSubview(deco_ornit)

        // 图标
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 26, weight: .light)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: topic_ornit.iconName_Ornit, withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = UIColor.white.withValues(alpha: 0.9)
        iconView_ornit.contentMode = .scaleAspectFit
        card_ornit.addSubview(iconView_ornit)

        // 季节标签
        let seasonLabel_ornit = UILabel()
        seasonLabel_ornit.text = topic_ornit.season_Ornit.uppercased()
        seasonLabel_ornit.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        seasonLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.7)
        card_ornit.addSubview(seasonLabel_ornit)
        
        // 标题
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = topic_ornit.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel_ornit.textColor = .white
        titleLabel_ornit.numberOfLines = 2
        card_ornit.addSubview(titleLabel_ornit)
        
        // 评论数
        let countLabel_ornit = UILabel()
        countLabel_ornit.text = "\(topic_ornit.comments_Ornit.count) comments"
        countLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        countLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.75)
        card_ornit.addSubview(countLabel_ornit)

        deco_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(20)
            make_ornit.top.equalToSuperview().offset(-10)
            make_ornit.width.height.equalTo(72)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.top.equalToSuperview().offset(18)
            make_ornit.width.height.equalTo(32)
        }

        seasonLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.top.equalTo(iconView_ornit.snp.bottom).offset(12)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.top.equalTo(seasonLabel_ornit.snp.bottom).offset(4)
        }

        countLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.bottom.equalToSuperview().offset(-16)
        }

        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(topicCardTapped_Ornit(_:)))
        card_ornit.addGestureRecognizer(tap_ornit)
        card_ornit.tag = topic_ornit.topicId_Ornit
        
        return card_ornit
    }
    
    // MARK: - Tips 卡片区

    /// 构建技巧卡片横向滚动区
    private func setupTipsSection_Ornit() {
        let sectionRow_ornit = UIView()
        contentView_Ornit.addSubview(sectionRow_ornit)

        let sectionTitle_ornit = UILabel()
        sectionTitle_ornit.text = "Birding Tips"
        sectionTitle_ornit.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        sectionTitle_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        sectionRow_ornit.addSubview(sectionTitle_ornit)

        // ✅ 必须在 addSubview(scroll_ornit) 之前查找，否则 scroll_ornit 也会出现在子视图中
        // 导致 .last 返回的是 scroll_ornit 自身，产生循环约束，整页布局崩溃
        let topicsScroll_ornit = contentView_Ornit.subviews.compactMap { $0 as? UIScrollView }.last

        let scroll_ornit = UIScrollView()
        scroll_ornit.showsHorizontalScrollIndicator = false
        scroll_ornit.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        contentView_Ornit.addSubview(scroll_ornit)

        let stack_ornit = UIStackView()
        stack_ornit.axis = .horizontal
        stack_ornit.spacing = 14
        stack_ornit.alignment = .fill
        scroll_ornit.addSubview(stack_ornit)

        sectionRow_ornit.snp.makeConstraints { make_ornit in
            if let ts_ornit = topicsScroll_ornit {
                make_ornit.top.equalTo(ts_ornit.snp.bottom).offset(24)
            } else {
                make_ornit.top.equalTo(dashboardCard_Ornit.snp.bottom).offset(160)
            }
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(24)
        }

        sectionTitle_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.centerY.equalToSuperview()
        }

        scroll_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(sectionRow_ornit.snp.bottom).offset(14)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(200)
            make_ornit.bottom.equalToSuperview().offset(-20)
        }

        stack_ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.height.equalToSuperview()
        }

        for tip_ornit in tipCards_Ornit {
            let card_ornit = makeTipCard_Ornit(tip_ornit: tip_ornit)
            stack_ornit.addArrangedSubview(card_ornit)
            card_ornit.snp.makeConstraints { make_ornit in make_ornit.width.equalTo(220) }
        }
    }

    /// 创建单个技巧卡片
    private func makeTipCard_Ornit(tip_ornit: TipCard_Ornit) -> UIView {
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 18
        card_ornit.layer.shadowColor = UIColor(hexstring_Ornit: tip_ornit.accentColor_Ornit).withValues(alpha: 0.15).cgColor
        card_ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_ornit.layer.shadowOpacity = 1
        card_ornit.layer.shadowRadius = 8
        card_ornit.isUserInteractionEnabled = true

        let accentColor_ornit = UIColor(hexstring_Ornit: tip_ornit.accentColor_Ornit)

        // 分类标签
        let catChip_ornit = UIView()
        catChip_ornit.backgroundColor = accentColor_ornit.withValues(alpha: 0.1)
        catChip_ornit.layer.cornerRadius = 10
        card_ornit.addSubview(catChip_ornit)

        let catLabel_ornit = UILabel()
        catLabel_ornit.text = tip_ornit.category_Ornit
        catLabel_ornit.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        catLabel_ornit.textColor = accentColor_ornit
        catChip_ornit.addSubview(catLabel_ornit)

        // 图标
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: tip_ornit.iconName_Ornit, withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = accentColor_ornit
        iconView_ornit.contentMode = .scaleAspectFit
        card_ornit.addSubview(iconView_ornit)

        // 标题
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = tip_ornit.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        titleLabel_ornit.numberOfLines = 2
        card_ornit.addSubview(titleLabel_ornit)
        
        // 内容预览（2行截断）
        let previewLabel_ornit = UILabel()
        previewLabel_ornit.text = tip_ornit.content_Ornit
        previewLabel_ornit.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        previewLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        previewLabel_ornit.numberOfLines = 3
        card_ornit.addSubview(previewLabel_ornit)

        // "Read more" 提示
        let readLabel_ornit = UILabel()
        readLabel_ornit.text = "Tap to read more →"
        readLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        readLabel_ornit.textColor = accentColor_ornit
        card_ornit.addSubview(readLabel_ornit)

        catChip_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(14)
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.height.equalTo(22)
        }
        catLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerY.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview().inset(8)
        }
        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.top.equalToSuperview().offset(14)
            make_ornit.width.height.equalTo(26)
        }
        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(catChip_ornit.snp.bottom).offset(8)
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalToSuperview().offset(-14)
        }
        previewLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(6)
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalToSuperview().offset(-14)
        }
        readLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.bottom.equalToSuperview().offset(-14)
            make_ornit.trailing.equalToSuperview().offset(-14)
        }

        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(tipCardTapped_Ornit(_:)))
        card_ornit.addGestureRecognizer(tap_ornit)
        card_ornit.tag = tip_ornit.tipId_Ornit

        return card_ornit
    }

    // MARK: - 辅助方法

    /// 根据时段返回问候语
    private func timeGreeting_Ornit() -> String {
        let hour_ornit = Calendar.current.component(.hour, from: Date())
        switch hour_ornit {
        case 5..<12: return "Good Morning, Birder 🌅"
        case 12..<17: return "Good Afternoon, Birder ☀️"
        case 17..<21: return "Good Evening, Birder 🌆"
        default:      return "Good Night, Birder 🌙"
        }
    }

    /// 返回格式化日期字符串
    private func formattedDate_Ornit() -> String {
        let fmt_ornit = DateFormatter()
        fmt_ornit.dateFormat = "EEEE, MMM d"
        return fmt_ornit.string(from: Date())
    }
    
    // MARK: - 事件处理
    
    /// 打卡按钮点击
    @objc private func checkInTapped_Ornit() {
        guard UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit else {
            Navigation_Ornit.toLogin_Ornit()
            return
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.checkInButton_Ornit.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.12) { self.checkInButton_Ornit.transform = .identity }
        }
        UserViewModel_Ornit.shared_Ornit.checkIn_Ornit()
        refreshCheckInStats_Ornit()
        refreshCheckInButton_Ornit()
    }

    /// 添加观鸟记录按钮点击
    @objc private func addObservationTapped_Ornit() {
        guard UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit else {
            Navigation_Ornit.toLogin_Ornit()
            return
        }
        showAddObservationAlert_Ornit()
    }

    /// 专题卡片点击 → 跳转专题详情
    @objc private func topicCardTapped_Ornit(_ gesture: UITapGestureRecognizer) {
        guard let card_ornit = gesture.view,
              let topic_ornit = LocalData_Ornit.shared_Ornit.seasonalTopics_Ornit.first(
                where: { $0.topicId_Ornit == card_ornit.tag }
              ) else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            card_ornit.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) { card_ornit.transform = .identity }
            Navigation_Ornit.toTopicDetail_Ornit(topic_ornit: topic_ornit)
        }
    }

    /// 技巧卡片点击 → 弹出详情覆盖层
    @objc private func tipCardTapped_Ornit(_ gesture: UITapGestureRecognizer) {
        guard let card_ornit = gesture.view,
              let tip_ornit = tipCards_Ornit.first(where: { $0.tipId_Ornit == card_ornit.tag }) else { return }

        UIView.animate(withDuration: 0.1, animations: {
            card_ornit.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) { card_ornit.transform = .identity }
            self.showTipDetail_Ornit(tip_ornit: tip_ornit)
        }
    }

    // MARK: - 弹窗

    /// 弹出添加观鸟记录表单
    private func showAddObservationAlert_Ornit() {
        let alert_ornit = UIAlertController(
            title: "Add Bird Sighting",
            message: "Record the birds you observed today",
            preferredStyle: .alert
        )

        alert_ornit.addTextField { tf_ornit in
            tf_ornit.placeholder = "Bird species name (e.g. Robin)"
            tf_ornit.autocapitalizationType = .words
        }

        alert_ornit.addTextField { tf_ornit in
            tf_ornit.placeholder = "Count (e.g. 3)"
            tf_ornit.keyboardType = .numberPad
        }

        alert_ornit.addTextField { tf_ornit in
            tf_ornit.placeholder = "Location (optional)"
        }

        alert_ornit.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let birdName_ornit = alert_ornit.textFields?[0].text?.trimmingCharacters(in: .whitespaces),
                  !birdName_ornit.isEmpty else { return }

            let countText_ornit = alert_ornit.textFields?[1].text ?? "1"
            let count_ornit = Int(countText_ornit) ?? 1
            let location_ornit = alert_ornit.textFields?[2].text?.trimmingCharacters(in: .whitespaces)

            let fmt_ornit = DateFormatter()
            fmt_ornit.dateFormat = "yyyy-MM-dd"

            let obs_ornit = BirdObservation_Ornit(
                observationId_Ornit: UserViewModel_Ornit.shared_Ornit.nextObservationId_Ornit(),
                birdName_Ornit: birdName_ornit,
                count_Ornit: count_ornit,
                observeDate_Ornit: fmt_ornit.string(from: Date()),
                location_Ornit: location_ornit?.isEmpty == false ? location_ornit : nil
            )

            UserViewModel_Ornit.shared_Ornit.addBirdObservation_Ornit(observation_ornit: obs_ornit)
            self.refreshObservationsList_Ornit()
        })

        alert_ornit.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_ornit, animated: true)
    }

    /// 弹出 Tips 详情覆盖层
    private func showTipDetail_Ornit(tip_ornit: TipCard_Ornit) {
        // 先移除已存在的遮罩，防止重复叠加导致页面被永久覆盖
        tipDetailOverlay_Ornit?.removeFromSuperview()

        let accentColor_ornit = UIColor(hexstring_Ornit: tip_ornit.accentColor_Ornit)

        let overlay_ornit = UIView()
        overlay_ornit.backgroundColor = UIColor.black.withValues(alpha: 0.45)
        overlay_ornit.alpha = 0
        // 添加到 tabBarController.view，使遮罩覆盖 Tab Bar（Tab Bar 属于 tabBarController.view，z 轴高于 self.view）
        let overlayParent_ornit: UIView = tabBarController?.view ?? view
        overlayParent_ornit.addSubview(overlay_ornit)
        // 存储弱引用，供 dismissTipDetail_Ornit 使用
        tipDetailOverlay_Ornit = overlay_ornit
        overlay_ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }

        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 28
        card_ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_ornit.addSubview(card_ornit)

        // 拖动把手
        let handle_ornit = UIView()
        handle_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        handle_ornit.layer.cornerRadius = 2.5
        card_ornit.addSubview(handle_ornit)

        // 图标
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        let iconBg_ornit = UIView()
        iconBg_ornit.backgroundColor = accentColor_ornit.withValues(alpha: 0.1)
        iconBg_ornit.layer.cornerRadius = 22
        card_ornit.addSubview(iconBg_ornit)

        let iconView_ornit = UIImageView(
            image: UIImage(systemName: tip_ornit.iconName_Ornit, withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = accentColor_ornit
        iconView_ornit.contentMode = .scaleAspectFit
        iconBg_ornit.addSubview(iconView_ornit)

        // 标题
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = tip_ornit.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 20, weight: .black)
        titleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        titleLabel_ornit.numberOfLines = 2
        card_ornit.addSubview(titleLabel_ornit)

        // 分类标签
        let catChip_ornit = UIView()
        catChip_ornit.backgroundColor = accentColor_ornit.withValues(alpha: 0.1)
        catChip_ornit.layer.cornerRadius = 11
        card_ornit.addSubview(catChip_ornit)

        let catLabel_ornit = UILabel()
        catLabel_ornit.text = tip_ornit.category_Ornit
        catLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        catLabel_ornit.textColor = accentColor_ornit
        catChip_ornit.addSubview(catLabel_ornit)

        // 内容（可滚动）
        let contentScroll_ornit = UIScrollView()
        contentScroll_ornit.showsVerticalScrollIndicator = false
        card_ornit.addSubview(contentScroll_ornit)

        let contentLabel_ornit = UILabel()
        contentLabel_ornit.text = tip_ornit.content_Ornit
        contentLabel_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        contentLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        contentLabel_ornit.numberOfLines = 0
        contentScroll_ornit.addSubview(contentLabel_ornit)

        // 关闭按钮
        let closeBtn_ornit = UIButton(type: .system)
        closeBtn_ornit.setTitle("Got it!", for: .normal)
        closeBtn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        closeBtn_ornit.tintColor = .white
        closeBtn_ornit.backgroundColor = accentColor_ornit
        closeBtn_ornit.layer.cornerRadius = 16
        card_ornit.addSubview(closeBtn_ornit)

        // 约束
        card_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.bottom.equalToSuperview()
        }
        handle_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(12)
            make_ornit.centerX.equalToSuperview()
            make_ornit.width.equalTo(40); make_ornit.height.equalTo(5)
        }
        iconBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(28)
            make_ornit.leading.equalToSuperview().offset(22)
            make_ornit.width.height.equalTo(52)
        }
        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview(); make_ornit.width.height.equalTo(30)
        }
        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(32)
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(14)
            make_ornit.trailing.equalToSuperview().offset(-22)
        }
        catChip_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(6)
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(14)
            make_ornit.height.equalTo(24)
        }
        catLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerY.equalToSuperview(); make_ornit.leading.trailing.equalToSuperview().inset(10)
        }
        contentScroll_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(iconBg_ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(22)
            make_ornit.trailing.equalToSuperview().offset(-22)
            make_ornit.height.equalTo(160)
        }
        contentLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview(); make_ornit.width.equalToSuperview()
        }
        closeBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(contentScroll_ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(22)
            make_ornit.trailing.equalToSuperview().offset(-22)
            make_ornit.height.equalTo(50)
            // tabBarController.view 的 safeArea 不含 Tab Bar，需手动加上 Tab Bar 高度
            let tabH_ornit: CGFloat = self.tabBarController?.tabBar.frame.height ?? 83
            make_ornit.bottom.equalTo(overlay_ornit.safeAreaLayoutGuide.snp.bottom).offset(-(tabH_ornit + 14))
        }

        // 入场动画
        card_ornit.transform = CGAffineTransform(translationX: 0, y: 320)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            overlay_ornit.alpha = 1
            card_ornit.transform = .identity
        }

        // 关闭按钮：使用标准 target-action（无内存管理问题）
        closeBtn_ornit.addTarget(self, action: #selector(dismissTipDetail_Ornit), for: .touchUpInside)

        // 遮罩背景点击关闭：cancelsTouchesInView = false 确保卡片内按钮仍可响应
        let bgTap_ornit = UITapGestureRecognizer(target: self, action: #selector(dismissTipDetail_Ornit))
        bgTap_ornit.cancelsTouchesInView = false
        overlay_ornit.addGestureRecognizer(bgTap_ornit)
    }

    /// 收起 Tips 详情遮罩层
    @objc private func dismissTipDetail_Ornit() {
        guard let overlay_ornit = tipDetailOverlay_Ornit else { return }
        UIView.animate(withDuration: 0.22, animations: {
            overlay_ornit.alpha = 0
            overlay_ornit.subviews.first?.transform = CGAffineTransform(translationX: 0, y: 280)
        }) { _ in
            overlay_ornit.removeFromSuperview()
        }
    }
}
