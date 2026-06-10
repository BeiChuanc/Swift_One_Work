import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页控制器
/// 核心作用：整合「打卡记录看板」「用户自定义体态计划」「话题互助社区」三大模块，作为 App 主入口。
/// 设计思路：顶部 Hero 区压缩排版；打卡区优先展示；计划区支持用户自行增删及计时锻炼；话题区改为横向两列网格。
/// 关键属性：scrollView_Posture 承载全页内容，三个子模块各有独立 section 卡片。
/// 关键方法：reloadAll_Posture() 统一刷新三个区块。
@MainActor
class Home_Posture: UIViewController {

    // MARK: - 容器组件

    private let scrollView_Posture = UIScrollView()
    private let contentView_Posture = UIView()
    private let contentStack_Posture = UIStackView()

    // MARK: - 打卡看板区块

    /// 连续天数数字标签
    private let streakNumberLabel_Posture = UILabel()

    /// 7天打卡圆点栈
    private let checkDotStack_Posture = UIStackView()

    /// 打卡按钮
    private let checkInButton_Posture = UIButton(type: .system)

    // MARK: - 用户计划区块

    /// 计划列表容器（动态增删）
    private let planListStack_Posture = UIStackView()

    // MARK: - 话题社区区块

    /// 话题网格容器（两列）
    private let topicsGridStack_Posture = UIStackView()

    // MARK: - 计划计时器

    /// 计时器状态枚举
    enum TimerState_Posture { case stopped_Posture, running_Posture, paused_Posture }

    /// 当前计时计划 ID
    private var timerPlanId_Posture: String?
    /// 本次会话已计时秒数
    private var timerSessionSeconds_Posture: Int = 0
    /// 计时器实例
    private var exerciseTimer_Posture: Timer?
    /// 当前计时状态
    private var timerState_Posture: TimerState_Posture = .stopped_Posture
    /// 计时显示标签（弱引用）
    private weak var timerDisplayLabel_Posture: UILabel?
    /// 环形进度视图（弱引用）
    private weak var timerRingView_Posture: TimerRingView_Posture?
    /// 本次用时标签（弱引用）
    private weak var timerSessionLabel_Posture: UILabel?
    /// 开始/暂停按钮（弱引用，状态切换）
    private weak var startPauseBtn_Posture: UIButton?
    /// 计时弹窗遮罩
    private weak var timerOverlay_Posture: UIView?
    /// 计时目标秒数
    private var timerTargetSeconds_Posture: Int = 0

    // MARK: - 添加计划弹窗

    private weak var addPlanOverlay_Posture: UIView?
    /// 添加计划时选中的封面图片路径
    private var pendingCoverPath_Posture: String?

    // MARK: - 计划日历弹窗

    private weak var calendarOverlay_Posture: UIView?
    /// 当前日历显示的月份基准日（每月1日）
    private var calendarDisplayDate_Posture: Date = Date()
    /// 日历网格容器（月份切换时替换内容）
    private weak var calendarGridContainer_Posture: UIView?
    /// 当前选中日期字符串（"yyyy-MM-dd"），用于日历下方计划列表刷新
    private var selectedCalendarDate_Posture: String?
    /// 日历弹窗内计划列表区域（弱引用，点击日期后更新内容）
    private weak var calendarPlanListContainer_Posture: UIView?

    // MARK: - Tips 弹窗

    private weak var tipsOverlay_Posture: UIView?

    // MARK: - 推荐详情弹窗

    private weak var detailOverlay_Posture: UIView?

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
        exerciseTimer_Posture?.invalidate()
    }

    // MARK: - UI 搭建

    /// 搭建首页整体布局（ScrollView + Section 堆叠）
    /// 顺序：Hero → 打卡 → 自定义计划 → 话题社区
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        scrollView_Posture.showsVerticalScrollIndicator = false
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
            // 顶部间距 12：safeArea 已由 contentInsetAdjustmentBehavior 自动处理
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-100)
        }

        contentStack_Posture.addArrangedSubview(buildHomeHeroSection_Posture())
        contentStack_Posture.addArrangedSubview(buildCheckInSection_Posture())
        contentStack_Posture.addArrangedSubview(buildPlanSection_Posture())
        contentStack_Posture.addArrangedSubview(buildTopicsSection_Posture())
        contentStack_Posture.addArrangedSubview(buildTipsSection_Posture())       // 每日 Tips
    }

    // MARK: - Section 0：首页 Hero 区（压缩排版）

    /// 构建首页顶部 Hero 卡（紧凑布局，压缩高度）
    private func buildHomeHeroSection_Posture() -> UIView {
        let cardWidth_Posture = UIScreen.main.bounds.width - 36
        let card_Posture = UIView()
        card_Posture.layer.cornerRadius = 24
        card_Posture.clipsToBounds = true
        card_Posture.backgroundColor = ColorConfig_Posture.accentIndigo_Posture

        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            ColorConfig_Posture.accentIndigo_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor
        ]
        grad_Posture.locations = [0, 0.55, 1.0]
        grad_Posture.startPoint = CGPoint(x: 0.1, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 0.9, y: 1)
        grad_Posture.frame = CGRect(x: 0, y: 0, width: cardWidth_Posture, height: 130)
        card_Posture.layer.insertSublayer(grad_Posture, at: 0)

        // 右上角装饰图标
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconBg_Posture.layer.cornerRadius = 20
        let iconIV_Posture = UIImageView(image: UIImage(systemName: "figure.walk.motion"))
        iconIV_Posture.tintColor = .white
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
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
        greetLabel_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        greetLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)

        // 主标题（压缩字号）
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Stand Tall Today"
        titleLabel_Posture.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel_Posture.textColor = .white

        // 副标题（单行）
        let descLabel_Posture = UILabel()
        descLabel_Posture.text = "Build better posture with small, consistent habits."
        descLabel_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        descLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.72)
        descLabel_Posture.numberOfLines = 1

        // 打卡状态徽章
        let checkedIn_Posture = UserViewModel_Posture.shared_Posture.hasCheckedInToday_Posture()
        let badge_Posture = UIView()
        badge_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        badge_Posture.layer.cornerRadius = 12
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
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        badgeText_Posture.snp.makeConstraints { make in
            make.leading.equalTo(badgeIcon_Posture.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(greetLabel_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(descLabel_Posture)
        card_Posture.addSubview(badge_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }
        greetLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(iconBg_Posture.snp.leading).offset(-8)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(greetLabel_Posture.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(iconBg_Posture.snp.leading).offset(-8)
        }
        descLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        badge_Posture.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Posture.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(14)
            make.height.equalTo(24)
        }

        return card_Posture
    }

    // MARK: - Section 1：打卡记录看板（移至第一位，需登录）

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

    /// 构建打卡卡片（紧凑横向布局：连火焰+天数 | 7日圆点，底部一行打卡按钮）
    private func buildCheckInCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 20
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 10
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        // 顶部横向行：左侧 streak，右侧 7 日圆点
        let topRow_Posture = UIView()
        topRow_Posture.backgroundColor = ColorConfig_Posture.accentMintLight_Posture
        topRow_Posture.layer.cornerRadius = 14

        // 左侧：🔥 + 数字 + "days"
        let fireIcon_Posture = UIImageView(image: UIImage(systemName: "flame.fill"))
        fireIcon_Posture.tintColor = ColorConfig_Posture.accentAmber_Posture
        fireIcon_Posture.contentMode = .scaleAspectFit

        streakNumberLabel_Posture.font = .systemFont(ofSize: 28, weight: .heavy)
        streakNumberLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let dayLabel_Posture = UILabel()
        dayLabel_Posture.text = "days"
        dayLabel_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        dayLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 右侧：7 日圆点（较小）
        checkDotStack_Posture.axis = .horizontal
        checkDotStack_Posture.spacing = 5
        checkDotStack_Posture.distribution = .fillEqually

        topRow_Posture.addSubview(fireIcon_Posture)
        topRow_Posture.addSubview(streakNumberLabel_Posture)
        topRow_Posture.addSubview(dayLabel_Posture)
        topRow_Posture.addSubview(checkDotStack_Posture)

        fireIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        streakNumberLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(fireIcon_Posture.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        dayLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(streakNumberLabel_Posture.snp.trailing).offset(4)
            make.bottom.equalTo(streakNumberLabel_Posture)
        }
        // 分割线
        let divider_Posture = UIView()
        divider_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.25)
        topRow_Posture.addSubview(divider_Posture)
        divider_Posture.snp.makeConstraints { make in
            make.leading.equalTo(dayLabel_Posture.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(26)
        }
        checkDotStack_Posture.snp.makeConstraints { make in
            make.leading.equalTo(divider_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(38)
        }

        // 打卡按钮
        checkInButton_Posture.setTitle("Check In Today", for: .normal)
        checkInButton_Posture.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        checkInButton_Posture.setTitleColor(.white, for: .normal)
        checkInButton_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture
        checkInButton_Posture.layer.cornerRadius = 18
        checkInButton_Posture.layer.shadowColor = ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.4).cgColor
        checkInButton_Posture.layer.shadowOpacity = 1
        checkInButton_Posture.layer.shadowRadius = 8
        checkInButton_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)
        checkInButton_Posture.addAction(UIAction { [weak self] _ in
            self?.handleCheckIn_Posture()
        }, for: .touchUpInside)

        card_Posture.addSubview(topRow_Posture)
        card_Posture.addSubview(checkInButton_Posture)

        topRow_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(58)
        }
        checkInButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(topRow_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(12)
        }

        return card_Posture
    }

    /// 打卡按钮点击：校验登录，未登录跳转，已登录执行打卡
    private func handleCheckIn_Posture() {
        guard UserViewModel_Posture.shared_Posture.isLoggedIn_Posture else {
            Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
            return
        }
        UserViewModel_Posture.shared_Posture.checkIn_Posture()
    }

    /// 刷新打卡区块数据（连续天数 + 7日圆点 + 按钮状态）
    private func reloadCheckInSection_Posture() {
        let streak_posture = UserViewModel_Posture.shared_Posture.getCheckInStreak_Posture()
        streakNumberLabel_Posture.text = "\(streak_posture)"

        checkDotStack_Posture.arrangedSubviews.forEach {
            checkDotStack_Posture.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let calendar_posture = Calendar.current
        let boolArray_posture = UserViewModel_Posture.shared_Posture.getRecentCheckInBoolArray_Posture(days_posture: 7)
        let dayLetters_posture = ["M", "T", "W", "T", "F", "S", "S"]
        let weekday_posture = calendar_posture.component(.weekday, from: Date())
        let startOffset_posture = (weekday_posture - 2 + 7) % 7

        for i_posture in 0..<7 {
            let dayLetterIdx_posture = (startOffset_posture + i_posture) % 7
            let dot_posture = makeDayDot_Posture(
                dayLetter_posture: dayLetters_posture[dayLetterIdx_posture],
                checked_posture: boolArray_posture[i_posture],
                isToday_posture: i_posture == 6
            )
            checkDotStack_Posture.addArrangedSubview(dot_posture)
        }

        let checkedToday_posture = UserViewModel_Posture.shared_Posture.hasCheckedInToday_Posture()
        checkInButton_Posture.setTitle(checkedToday_posture ? "Checked In ✓" : "Check In Today", for: .normal)
        checkInButton_Posture.backgroundColor = checkedToday_posture
            ? ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.5)
            : ColorConfig_Posture.accentMint_Posture
        checkInButton_Posture.isEnabled = !checkedToday_posture
    }

    /// 创建单个日期圆点视图（紧凑版，圆点 26pt，字母 9pt）
    private func makeDayDot_Posture(dayLetter_posture: String, checked_posture: Bool, isToday_posture: Bool) -> UIView {
        let container_Posture = UIView()
        let circle_Posture = UIView()
        circle_Posture.layer.cornerRadius = 13
        if checked_posture {
            circle_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture
        } else if isToday_posture {
            circle_Posture.backgroundColor = ColorConfig_Posture.accentMintLight_Posture
            circle_Posture.layer.borderWidth = 1.5
            circle_Posture.layer.borderColor = ColorConfig_Posture.accentMint_Posture.cgColor
        } else {
            circle_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }

        let checkmark_Posture = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark_Posture.tintColor = .white
        checkmark_Posture.contentMode = .scaleAspectFit
        checkmark_Posture.isHidden = !checked_posture
        circle_Posture.addSubview(checkmark_Posture)
        checkmark_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(10)
        }

        let dayLabel_Posture = UILabel()
        dayLabel_Posture.text = dayLetter_posture
        dayLabel_Posture.font = .systemFont(ofSize: 9, weight: .semibold)
        dayLabel_Posture.textColor = isToday_posture
            ? ColorConfig_Posture.accentMint_Posture
            : ColorConfig_Posture.textPlaceholder_Posture
        dayLabel_Posture.textAlignment = .center

        container_Posture.addSubview(circle_Posture)
        container_Posture.addSubview(dayLabel_Posture)

        circle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(26)
        }
        dayLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(circle_Posture.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return container_Posture
    }

    // MARK: - Section 2：用户自定义体态计划

    /// 构建每日体态计划区块（用户自定义）
    private func buildPlanSection_Posture() -> UIView {
        let section_Posture = UIView()

        // 标题行（右侧有 + 添加按钮）
        let titleRow_Posture = UIView()

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Daily Posture Plan"
        titleLabel_Posture.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "Your personal workout plans"
        subtitleLabel_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 日历按钮（查看当月计划分布）
        let calBtn_Posture = UIButton(type: .system)
        calBtn_Posture.setImage(UIImage(systemName: "calendar"), for: .normal)
        calBtn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        calBtn_Posture.addAction(UIAction { [weak self] _ in
            self?.showPlanCalendar_Posture()
        }, for: .touchUpInside)

        // 添加按钮（校验登录）
        let addBtn_Posture = UIButton(type: .system)
        addBtn_Posture.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addBtn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        addBtn_Posture.addAction(UIAction { [weak self] _ in
            guard UserViewModel_Posture.shared_Posture.isLoggedIn_Posture else {
                Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
                return
            }
            self?.showAddPlanSheet_Posture()
        }, for: .touchUpInside)

        titleRow_Posture.addSubview(titleLabel_Posture)
        titleRow_Posture.addSubview(subtitleLabel_Posture)
        titleRow_Posture.addSubview(calBtn_Posture)
        titleRow_Posture.addSubview(addBtn_Posture)

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(calBtn_Posture.snp.leading).offset(-8)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(3)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        calBtn_Posture.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(addBtn_Posture.snp.leading).offset(-6)
            make.width.height.equalTo(28)
        }
        addBtn_Posture.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(30)
        }

        // 计划列表
        planListStack_Posture.axis = .vertical
        planListStack_Posture.spacing = 12

        section_Posture.addSubview(titleRow_Posture)
        section_Posture.addSubview(planListStack_Posture)

        titleRow_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        planListStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleRow_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return section_Posture
    }

    /// 刷新用户自定义计划列表
    private func reloadPlanSection_Posture() {
        planListStack_Posture.arrangedSubviews.forEach {
            planListStack_Posture.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let plans_Posture = UserViewModel_Posture.shared_Posture.getUserPlans_Posture()

        if plans_Posture.isEmpty {
            let emptyView_Posture = buildPlanEmptyState_Posture()
            planListStack_Posture.addArrangedSubview(emptyView_Posture)
            return
        }

        for (idx_Posture, plan_Posture) in plans_Posture.enumerated() {
            let card_Posture = makePlanCard_Posture(plan: plan_Posture, index: idx_Posture)
            planListStack_Posture.addArrangedSubview(card_Posture)
            card_Posture.animateSlideInFromBottom_Posture(delay_Posture: Double(idx_Posture) * 0.05)
        }
    }

    /// 构建计划空状态视图
    private func buildPlanEmptyState_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.primaryLight_Posture
        card_Posture.layer.cornerRadius = 20

        let icon_Posture = UIImageView(image: UIImage(systemName: "plus.rectangle.on.rectangle"))
        icon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        icon_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = "Tap + to add your first posture plan and start timing your workouts."
        label_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        label_Posture.numberOfLines = 3

        card_Posture.addSubview(icon_Posture)
        card_Posture.addSubview(label_Posture)

        icon_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(18)
            make.width.height.equalTo(26)
        }
        label_Posture.snp.makeConstraints { make in
            make.top.equalTo(icon_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }

        return card_Posture
    }

    /// 构建单个用户计划卡片（含进度条、删除、计时入口）
    /// - Parameters:
    ///   - plan: 计划数据
    ///   - index: 索引，用于调色
    /// - Returns: UIView
    private func makePlanCard_Posture(plan: UserPlan_Posture, index: Int) -> UIView {
        let palette_Posture = ColorConfig_Posture.cardAccentPalette_Posture[index % ColorConfig_Posture.cardAccentPalette_Posture.count]
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 20
        card_Posture.layer.shadowColor = palette_Posture.shadow.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 12
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 5)

        // 左侧彩色竖条
        let accentBar_Posture = UIView()
        accentBar_Posture.backgroundColor = palette_Posture.main
        accentBar_Posture.layer.cornerRadius = 2

        // 图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = palette_Posture.light
        iconBg_Posture.layer.cornerRadius = 16

        let iconIV_Posture = UIImageView(image: UIImage(systemName: plan.isCompleted_Posture ? "checkmark.circle.fill" : "figure.walk"))
        iconIV_Posture.tintColor = palette_Posture.main
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = plan.title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 进度文字
        let progressText_Posture = UILabel()
        progressText_Posture.text = "\(plan.completedMinutes_Posture) / \(plan.targetMinutes_Posture) min"
        progressText_Posture.font = .systemFont(ofSize: 12, weight: .regular)
        progressText_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 进度条
        let progressView_Posture = UIProgressView(progressViewStyle: .default)
        progressView_Posture.trackTintColor = palette_Posture.light
        progressView_Posture.progressTintColor = palette_Posture.main
        progressView_Posture.layer.cornerRadius = 3
        progressView_Posture.clipsToBounds = true
        progressView_Posture.progress = Float(plan.progressRatio_Posture)

        // 删除按钮
        let deleteBtn_Posture = UIButton(type: .system)
        deleteBtn_Posture.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteBtn_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        deleteBtn_Posture.addAction(UIAction { [weak self] _ in
            self?.confirmDeletePlan_Posture(planId: plan.planId_Posture, title: plan.title_Posture)
        }, for: .touchUpInside)

        card_Posture.addSubview(accentBar_Posture)
        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(progressText_Posture)
        card_Posture.addSubview(progressView_Posture)
        card_Posture.addSubview(deleteBtn_Posture)

        accentBar_Posture.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(4)
        }
        iconBg_Posture.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Posture.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        deleteBtn_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(10)
            make.trailing.equalTo(deleteBtn_Posture.snp.leading).offset(-8)
        }
        progressText_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel_Posture)
            make.trailing.equalTo(deleteBtn_Posture.snp.leading).offset(-8)
        }
        progressView_Posture.snp.makeConstraints { make in
            make.top.equalTo(progressText_Posture.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel_Posture)
            make.trailing.equalTo(deleteBtn_Posture.snp.leading).offset(-8)
            make.height.equalTo(6)
            make.bottom.equalToSuperview().inset(14)
        }

        // 整体点击 → 进入计时页面
        let tapBtn_Posture = UIButton(type: .custom)
        tapBtn_Posture.backgroundColor = .clear
        tapBtn_Posture.addAction(UIAction { [weak self, weak card_Posture] _ in
            card_Posture?.animatePressDown_Posture { card_Posture?.animatePressUp_Posture() }
            self?.showPlanTimer_Posture(plan: plan)
        }, for: .touchUpInside)
        card_Posture.addSubview(tapBtn_Posture)
        tapBtn_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        // 确保删除按钮在点击层之上
        card_Posture.bringSubviewToFront(deleteBtn_Posture)

        return card_Posture
    }

    /// 确认删除计划（弹窗）
    private func confirmDeletePlan_Posture(planId: String, title: String) {
        let alert_Posture = UIAlertController(
            title: "Delete Plan",
            message: "Are you sure you want to delete \"\(title)\"? This will also remove all recorded progress.",
            preferredStyle: .alert
        )
        alert_Posture.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Posture.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            UserViewModel_Posture.shared_Posture.deletePlan_Posture(planId_posture: planId)
            self?.reloadPlanSection_Posture()
        })
        present(alert_Posture, animated: true)
    }

    // MARK: - 添加计划弹窗

    /// 展示「添加计划」底部弹窗
    private func showAddPlanSheet_Posture() {
        guard addPlanOverlay_Posture == nil, let window_Posture = view.window else { return }

        let overlay_Posture = UIView()
        overlay_Posture.backgroundColor = .clear
        overlay_Posture.frame = window_Posture.bounds
        overlay_Posture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window_Posture.addSubview(overlay_Posture)
        addPlanOverlay_Posture = overlay_Posture

        let sheet_Posture = buildAddPlanSheet_Posture()
        sheet_Posture.layer.cornerRadius = 28
        sheet_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_Posture.addSubview(sheet_Posture)
        sheet_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        sheet_Posture.transform = CGAffineTransform(translationX: 0, y: window_Posture.bounds.height)

        overlay_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAddPlanSheet_Posture)))

        UIView.animate(
            withDuration: AnimationConfig_Posture.durationSpring_Posture,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Posture.springDampingNormal_Posture,
            initialSpringVelocity: AnimationConfig_Posture.springVelocity_Posture,
            options: [.curveEaseOut]
        ) {
            overlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            sheet_Posture.transform = .identity
        }
    }

    /// 收起「添加计划」弹窗
    @objc private func dismissAddPlanSheet_Posture() {
        guard let overlay_Posture = addPlanOverlay_Posture else { return }
        UIView.animate(withDuration: AnimationConfig_Posture.durationNormal_Posture, animations: {
            overlay_Posture.alpha = 0
            overlay_Posture.subviews.first?.transform = CGAffineTransform(translationX: 0, y: overlay_Posture.bounds.height)
        }, completion: { _ in overlay_Posture.removeFromSuperview() })
    }

    /// 构建添加计划弹窗内容（名称 + 内容 + 封面 + 时间 + 时长）
    private func buildAddPlanSheet_Posture() -> UIView {
        let sheet_Posture = UIView()
        sheet_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        // 把手
        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 2.5

        // 标题
        let sheetTitle_Posture = UILabel()
        sheetTitle_Posture.text = "Add New Plan"
        sheetTitle_Posture.font = .systemFont(ofSize: 20, weight: .heavy)
        sheetTitle_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 封面选择区
        let coverContainer_Posture = UIView()
        coverContainer_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        coverContainer_Posture.layer.cornerRadius = 16
        coverContainer_Posture.layer.borderWidth = 1.5
        coverContainer_Posture.layer.borderColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.25).cgColor

        let coverImageView_Posture = UIImageView()
        coverImageView_Posture.contentMode = .scaleAspectFill
        coverImageView_Posture.clipsToBounds = true
        coverImageView_Posture.layer.cornerRadius = 14
        coverImageView_Posture.backgroundColor = .clear
        coverImageView_Posture.tag = 9100

        let coverPlaceholderIcon_Posture = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        coverPlaceholderIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.55)
        coverPlaceholderIcon_Posture.contentMode = .scaleAspectFit
        coverPlaceholderIcon_Posture.tag = 9101

        let coverHint_Posture = UILabel()
        coverHint_Posture.text = "Add Cover Photo"
        coverHint_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        coverHint_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        coverHint_Posture.textAlignment = .center
        coverHint_Posture.tag = 9102

        coverContainer_Posture.addSubview(coverImageView_Posture)
        coverContainer_Posture.addSubview(coverPlaceholderIcon_Posture)
        coverContainer_Posture.addSubview(coverHint_Posture)
        coverImageView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        coverPlaceholderIcon_Posture.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        coverHint_Posture.snp.makeConstraints { make in
            make.top.equalTo(coverPlaceholderIcon_Posture.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        // 点击选封面
        coverContainer_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPlanCover_Posture)))
        coverContainer_Posture.isUserInteractionEnabled = true

        // 计划名称
        let nameField_Posture = UITextField()
        nameField_Posture.placeholder = "Plan name, e.g. Morning Stretch"
        nameField_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        nameField_Posture.borderStyle = .none
        nameField_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        nameField_Posture.layer.cornerRadius = 14
        nameField_Posture.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        nameField_Posture.leftViewMode = .always
        nameField_Posture.returnKeyType = .next

        // 计划内容
        let contentView_Posture = UITextView()
        contentView_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        contentView_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        contentView_Posture.layer.cornerRadius = 14
        contentView_Posture.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        contentView_Posture.tag = 9103

        // content placeholder（模拟）
        let contentPlaceholder_Posture = UILabel()
        contentPlaceholder_Posture.text = "Describe the exercises, steps or goals…"
        contentPlaceholder_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        contentPlaceholder_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        contentPlaceholder_Posture.tag = 9104
        contentView_Posture.addSubview(contentPlaceholder_Posture)
        contentPlaceholder_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().inset(10)
        }
        // 隐藏 placeholder 时机
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: contentView_Posture, queue: .main) { _ in
            contentPlaceholder_Posture.isHidden = !contentView_Posture.text.isEmpty
        }

        // 计划时间选择
        let timePicker_Posture = UIDatePicker()
        timePicker_Posture.datePickerMode = .time
        timePicker_Posture.preferredDatePickerStyle = .compact
        timePicker_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        // 默认 08:00
        var comps_Posture = Calendar.current.dateComponents([.hour, .minute], from: Date())
        comps_Posture.hour = 8; comps_Posture.minute = 0
        if let d = Calendar.current.date(from: comps_Posture) { timePicker_Posture.date = d }
        timePicker_Posture.tag = 9105

        let timeRow_Posture = UIView()
        timeRow_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        timeRow_Posture.layer.cornerRadius = 14

        let timeIcon_Posture = UIImageView(image: UIImage(systemName: "clock.fill"))
        timeIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        timeIcon_Posture.contentMode = .scaleAspectFit

        let timeTitle_Posture = UILabel()
        timeTitle_Posture.text = "Scheduled Time"
        timeTitle_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        timeTitle_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        timeRow_Posture.addSubview(timeIcon_Posture)
        timeRow_Posture.addSubview(timeTitle_Posture)
        timeRow_Posture.addSubview(timePicker_Posture)
        timeIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        timeTitle_Posture.snp.makeConstraints { make in
            make.leading.equalTo(timeIcon_Posture.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        timePicker_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        // 时长行
        var selectedMinutes_Posture = 20
        let minutesLabel_Posture = UILabel()
        minutesLabel_Posture.text = "\(selectedMinutes_Posture) min"
        minutesLabel_Posture.font = .systemFont(ofSize: 18, weight: .heavy)
        minutesLabel_Posture.textColor = ColorConfig_Posture.primaryGradientStart_Posture
        minutesLabel_Posture.textAlignment = .center

        let minusBtn_Posture = UIButton(type: .system)
        minusBtn_Posture.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        minusBtn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        let plusBtn_Posture = UIButton(type: .system)
        plusBtn_Posture.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusBtn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        minusBtn_Posture.addAction(UIAction { [weak minutesLabel_Posture] _ in
            if selectedMinutes_Posture > 5 { selectedMinutes_Posture -= 5; minutesLabel_Posture?.text = "\(selectedMinutes_Posture) min" }
        }, for: .touchUpInside)
        plusBtn_Posture.addAction(UIAction { [weak minutesLabel_Posture] _ in
            if selectedMinutes_Posture < 120 { selectedMinutes_Posture += 5; minutesLabel_Posture?.text = "\(selectedMinutes_Posture) min" }
        }, for: .touchUpInside)
        minusBtn_Posture.snp.makeConstraints { make in make.width.height.equalTo(36) }
        plusBtn_Posture.snp.makeConstraints { make in make.width.height.equalTo(36) }

        let durationRow_Posture = UIView()
        durationRow_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        durationRow_Posture.layer.cornerRadius = 14

        let durationIcon_Posture = UIImageView(image: UIImage(systemName: "timer"))
        durationIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        durationIcon_Posture.contentMode = .scaleAspectFit
        let durationTitle_Posture = UILabel()
        durationTitle_Posture.text = "Target Duration"
        durationTitle_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        durationTitle_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let durationControls_Posture = UIStackView(arrangedSubviews: [minusBtn_Posture, minutesLabel_Posture, plusBtn_Posture])
        durationControls_Posture.axis = .horizontal
        durationControls_Posture.spacing = 10
        durationControls_Posture.alignment = .center

        durationRow_Posture.addSubview(durationIcon_Posture)
        durationRow_Posture.addSubview(durationTitle_Posture)
        durationRow_Posture.addSubview(durationControls_Posture)
        durationIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        durationTitle_Posture.snp.makeConstraints { make in
            make.leading.equalTo(durationIcon_Posture.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        durationControls_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }

        // 确认按钮
        let confirmBtn_Posture = UIButton(type: .system)
        confirmBtn_Posture.setTitle("Add Plan", for: .normal)
        confirmBtn_Posture.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        confirmBtn_Posture.setTitleColor(.white, for: .normal)
        confirmBtn_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        confirmBtn_Posture.layer.cornerRadius = 22
        confirmBtn_Posture.addAction(UIAction { [weak self, weak nameField_Posture, weak contentView_Posture, weak timePicker_Posture] _ in
            let name_Posture = (nameField_Posture?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name_Posture.isEmpty else {
                nameField_Posture?.layer.borderColor = UIColor.systemRed.cgColor
                nameField_Posture?.layer.borderWidth = 1.5
                return
            }
            let content_Posture = (contentView_Posture?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            // 时间字符串
            let fmt_Posture = DateFormatter()
            fmt_Posture.dateFormat = "HH:mm"
            let timeStr_Posture = timePicker_Posture.map { fmt_Posture.string(from: $0.date) }

            UserViewModel_Posture.shared_Posture.addPlan_Posture(
                title_posture: name_Posture,
                content_posture: content_Posture,
                coverImagePath_posture: self?.pendingCoverPath_Posture,
                scheduledTime_posture: timeStr_Posture,
                targetMinutes_posture: selectedMinutes_Posture
            )
            self?.pendingCoverPath_Posture = nil
            self?.dismissAddPlanSheet_Posture()
            self?.reloadPlanSection_Posture()
        }, for: .touchUpInside)

        // 布局
        [handle_Posture, sheetTitle_Posture, coverContainer_Posture,
         nameField_Posture, contentView_Posture, timeRow_Posture,
         durationRow_Posture, confirmBtn_Posture].forEach { sheet_Posture.addSubview($0) }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40); make.height.equalTo(5)
        }
        sheetTitle_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(22)
        }
        // 封面（右对齐，小尺寸）
        coverContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(sheetTitle_Posture.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(22)
            make.width.equalTo(90)
            make.height.equalTo(68)
        }
        nameField_Posture.snp.makeConstraints { make in
            make.top.equalTo(sheetTitle_Posture.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalTo(coverContainer_Posture.snp.leading).offset(-12)
            make.height.equalTo(46)
        }
        contentView_Posture.snp.makeConstraints { make in
            make.top.equalTo(coverContainer_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(80)
        }
        timeRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentView_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(50)
        }
        durationRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(timeRow_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(50)
        }
        confirmBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(durationRow_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(52)
            make.bottom.equalTo(sheet_Posture.safeAreaLayoutGuide.snp.bottom).inset(20)
        }

        return sheet_Posture
    }

    /// 选取计划封面图片（从相册）
    @objc private func pickPlanCover_Posture() {
        var config = UIImagePickerController.SourceType.photoLibrary
        _ = config
        let picker_Posture = UIImagePickerController()
        picker_Posture.sourceType = .photoLibrary
        picker_Posture.allowsEditing = true
        picker_Posture.delegate = self
        present(picker_Posture, animated: true)
    }

    // MARK: - 计划计时弹窗

    /// 展示计划计时页（全屏计时锻炼）
    /// - Parameter plan: 要计时的计划
    private func showPlanTimer_Posture(plan: UserPlan_Posture) {
        guard timerOverlay_Posture == nil, let window_Posture = view.window else { return }

        timerPlanId_Posture = plan.planId_Posture
        timerSessionSeconds_Posture = 0
        timerState_Posture = .stopped_Posture
        timerTargetSeconds_Posture = plan.targetMinutes_Posture * 60

        let overlay_Posture = UIView()
        overlay_Posture.backgroundColor = .clear
        overlay_Posture.frame = window_Posture.bounds
        overlay_Posture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window_Posture.addSubview(overlay_Posture)
        timerOverlay_Posture = overlay_Posture

        let sheet_Posture = buildTimerSheet_Posture(plan: plan)
        sheet_Posture.layer.cornerRadius = 30
        sheet_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_Posture.addSubview(sheet_Posture)
        sheet_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        sheet_Posture.transform = CGAffineTransform(translationX: 0, y: window_Posture.bounds.height)

        UIView.animate(
            withDuration: AnimationConfig_Posture.durationSpring_Posture,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Posture.springDampingNormal_Posture,
            initialSpringVelocity: AnimationConfig_Posture.springVelocity_Posture,
            options: [.curveEaseOut]
        ) {
            overlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            sheet_Posture.transform = .identity
        }
        // 计时器不自动开始，由用户点击「Start」按钮触发
    }

    /// 构建计时弹窗（全新设计：封面 Hero + 环形进度计时 + 数据卡 + 三按钮）
    private func buildTimerSheet_Posture(plan: UserPlan_Posture) -> UIView {
        let sheet_Posture = UIView()
        sheet_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        // ── 把手 ──
        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 2.5

        // ── Hero 封面区（全宽，含渐变遮罩展示标题+内容）──
        let heroCard_Posture = buildTimerHeroCard_Posture(plan: plan)

        // ── 数据卡（目标 / 已完成 / 本次用时 三格）──
        let statsCard_Posture = UIView()
        statsCard_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        statsCard_Posture.layer.cornerRadius = 20
        statsCard_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        statsCard_Posture.layer.shadowOpacity = 1
        statsCard_Posture.layer.shadowRadius = 10
        statsCard_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        let goalChip_Posture   = makeTimerStatChip_Posture(icon: "target",        title: "Goal",     value: "\(plan.targetMinutes_Posture) min", color: ColorConfig_Posture.primaryGradientStart_Posture)
        let doneChip_Posture   = makeTimerStatChip_Posture(icon: "checkmark.seal", title: "Done",     value: "\(plan.completedMinutes_Posture) min", color: ColorConfig_Posture.accentMint_Posture)

        let sessionLabel_Posture = UILabel()
        sessionLabel_Posture.text = "Session: 0 sec"
        sessionLabel_Posture.font = .systemFont(ofSize: 13, weight: .semibold)
        sessionLabel_Posture.textColor = ColorConfig_Posture.accentAmber_Posture
        sessionLabel_Posture.textAlignment = .center
        timerSessionLabel_Posture = sessionLabel_Posture

        let statsRow_Posture = UIStackView(arrangedSubviews: [goalChip_Posture, doneChip_Posture, sessionLabel_Posture])
        statsRow_Posture.axis = .horizontal
        statsRow_Posture.distribution = .fillEqually
        statsRow_Posture.spacing = 0

        // 竖分割线
        let div1_Posture = makeVerticalDivider_Posture()
        let div2_Posture = makeVerticalDivider_Posture()
        statsCard_Posture.addSubview(statsRow_Posture)
        statsCard_Posture.addSubview(div1_Posture)
        statsCard_Posture.addSubview(div2_Posture)
        statsRow_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        div1_Posture.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(2.0/3.0)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(32)
        }
        div2_Posture.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(4.0/3.0)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(32)
        }

        // ── 环形进度 + 大字计时 ──
        let ringContainer_Posture = UIView()

        let ringView_Posture = TimerRingView_Posture()
        ringView_Posture.setProgress(Float(plan.progressRatio_Posture), animated: false)
        timerRingView_Posture = ringView_Posture

        let timerLabel_Posture = UILabel()
        timerLabel_Posture.text = "00:00"
        timerLabel_Posture.font = .monospacedDigitSystemFont(ofSize: 48, weight: .heavy)
        timerLabel_Posture.textColor = ColorConfig_Posture.primaryGradientStart_Posture
        timerLabel_Posture.textAlignment = .center
        timerDisplayLabel_Posture = timerLabel_Posture

        let stateHint_Posture = UILabel()
        stateHint_Posture.text = "Tap Start to begin"
        stateHint_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        stateHint_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        stateHint_Posture.textAlignment = .center
        stateHint_Posture.tag = 6001

        ringContainer_Posture.addSubview(ringView_Posture)
        ringContainer_Posture.addSubview(timerLabel_Posture)
        ringContainer_Posture.addSubview(stateHint_Posture)

        ringView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(180)
            make.top.bottom.equalToSuperview().inset(8)
        }
        timerLabel_Posture.snp.makeConstraints { make in
            make.center.equalTo(ringView_Posture).offset(-10)
        }
        stateHint_Posture.snp.makeConstraints { make in
            make.top.equalTo(timerLabel_Posture.snp.bottom).offset(4)
            make.centerX.equalTo(ringView_Posture)
        }

        // ── 按钮区 ──
        let startPause_Posture = UIButton(type: .system)
        startPause_Posture.setTitle("  Start", for: .normal)
        startPause_Posture.setImage(UIImage(systemName: "play.fill"), for: .normal)
        startPause_Posture.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        startPause_Posture.setTitleColor(.white, for: .normal)
        startPause_Posture.tintColor = .white
        startPause_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        startPause_Posture.layer.cornerRadius = 26
        startPause_Posture.layer.shadowColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.4).cgColor
        startPause_Posture.layer.shadowOpacity = 1
        startPause_Posture.layer.shadowRadius = 12
        startPause_Posture.layer.shadowOffset = CGSize(width: 0, height: 5)
        startPause_Posture.addAction(UIAction { [weak self] _ in self?.toggleStartPause_Posture() }, for: .touchUpInside)
        startPauseBtn_Posture = startPause_Posture

        let endSave_Posture = UIButton(type: .system)
        endSave_Posture.setTitle("  End & Save", for: .normal)
        endSave_Posture.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        endSave_Posture.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        endSave_Posture.setTitleColor(ColorConfig_Posture.primaryGradientStart_Posture, for: .normal)
        endSave_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        endSave_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.1)
        endSave_Posture.layer.cornerRadius = 22
        endSave_Posture.addAction(UIAction { [weak self] _ in self?.saveAndCloseTimer_Posture() }, for: .touchUpInside)

        let discardBtn_Posture = UIButton(type: .system)
        discardBtn_Posture.setTitle("Discard Session", for: .normal)
        discardBtn_Posture.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        discardBtn_Posture.setTitleColor(ColorConfig_Posture.textPlaceholder_Posture, for: .normal)
        discardBtn_Posture.addAction(UIAction { [weak self] _ in self?.discardAndCloseTimer_Posture() }, for: .touchUpInside)

        // 布局
        [handle_Posture, heroCard_Posture, statsCard_Posture, ringContainer_Posture,
         startPause_Posture, endSave_Posture, discardBtn_Posture].forEach { sheet_Posture.addSubview($0) }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40); make.height.equalTo(5)
        }
        heroCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(110)
        }
        statsCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(heroCard_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(60)
        }
        ringContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Posture.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        startPause_Posture.snp.makeConstraints { make in
            make.top.equalTo(ringContainer_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(54)
        }
        endSave_Posture.snp.makeConstraints { make in
            make.top.equalTo(startPause_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(46)
        }
        discardBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(endSave_Posture.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(sheet_Posture.safeAreaLayoutGuide.snp.bottom).inset(14)
        }

        return sheet_Posture
    }

    /// 构建计时弹窗 Hero 区（封面或渐变卡片）
    private func buildTimerHeroCard_Posture(plan: UserPlan_Posture) -> UIView {
        let card_Posture = UIView()
        card_Posture.layer.cornerRadius = 20
        card_Posture.clipsToBounds = true

        // 背景：使用 MediaDisplayView_Posture 加载封面（支持 Documents / Bundle / 本地路径多回退）
        let mediaView_Posture = MediaDisplayView_Posture()
        mediaView_Posture.layer.cornerRadius = 0
        mediaView_Posture.clipsToBounds = true

        if let path_Posture = plan.coverImagePath_Posture, !path_Posture.isEmpty {
            // 有封面路径时加载图片（MediaDisplayView 内部多路径回退）
            mediaView_Posture.configure_Posture(mediaPath_Posture: path_Posture, isVideo_Posture: false)
        } else {
            // 无封面：渐变背景占位
            let grad_Posture = CAGradientLayer()
            grad_Posture.colors = [
                ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
                ColorConfig_Posture.accentIndigo_Posture.cgColor
            ]
            grad_Posture.startPoint = CGPoint(x: 0, y: 0)
            grad_Posture.endPoint   = CGPoint(x: 1, y: 1)
            DispatchQueue.main.async { grad_Posture.frame = card_Posture.bounds }
            card_Posture.layer.insertSublayer(grad_Posture, at: 0)
        }
        card_Posture.addSubview(mediaView_Posture)
        mediaView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 底部渐变遮罩
        let gradient_Posture = CAGradientLayer()
        gradient_Posture.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.68).cgColor]
        gradient_Posture.startPoint = CGPoint(x: 0, y: 0)
        gradient_Posture.endPoint   = CGPoint(x: 0, y: 1)
        DispatchQueue.main.async { gradient_Posture.frame = card_Posture.bounds }
        let gradView_Posture = UIView()
        gradView_Posture.isUserInteractionEnabled = false
        card_Posture.addSubview(gradView_Posture)
        gradView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        DispatchQueue.main.async { gradView_Posture.layer.insertSublayer(gradient_Posture, at: 0) }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = plan.title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 18, weight: .heavy)
        titleLabel_Posture.textColor = .white
        titleLabel_Posture.numberOfLines = 1

        // 内容
        let contentLabel_Posture = UILabel()
        contentLabel_Posture.text = plan.content_Posture.isEmpty ? "Tap Start to begin your session." : plan.content_Posture
        contentLabel_Posture.font = .systemFont(ofSize: 12, weight: .regular)
        contentLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.82)
        contentLabel_Posture.numberOfLines = 2

        // 计划时间徽章（如有）
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(contentLabel_Posture)

        if let timeStr_Posture = plan.scheduledTime_Posture, !timeStr_Posture.isEmpty {
            let timeBadge_Posture = UIView()
            timeBadge_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
            timeBadge_Posture.layer.cornerRadius = 10
            let clockIV_Posture = UIImageView(image: UIImage(systemName: "clock.fill"))
            clockIV_Posture.tintColor = .white
            clockIV_Posture.contentMode = .scaleAspectFit
            let timeLabel_Posture = UILabel()
            timeLabel_Posture.text = timeStr_Posture
            timeLabel_Posture.font = .systemFont(ofSize: 11, weight: .bold)
            timeLabel_Posture.textColor = .white
            timeBadge_Posture.addSubview(clockIV_Posture)
            timeBadge_Posture.addSubview(timeLabel_Posture)
            clockIV_Posture.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(8)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(12)
            }
            timeLabel_Posture.snp.makeConstraints { make in
                make.leading.equalTo(clockIV_Posture.snp.trailing).offset(4)
                make.trailing.equalToSuperview().inset(8)
                make.centerY.equalToSuperview()
            }
            card_Posture.addSubview(timeBadge_Posture)
            timeBadge_Posture.snp.makeConstraints { make in
                make.top.trailing.equalToSuperview().inset(12)
                make.height.equalTo(22)
            }
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalTo(contentLabel_Posture.snp.top).offset(-3)
        }
        contentLabel_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(12)
        }

        return card_Posture
    }

    /// 创建计时数据小格（图标 + 标题 + 数值）
    private func makeTimerStatChip_Posture(icon: String, title: String, value: String, color: UIColor) -> UIView {
        let container_Posture = UIView()
        let iconIV_Posture = UIImageView(image: UIImage(systemName: icon))
        iconIV_Posture.tintColor = color
        iconIV_Posture.contentMode = .scaleAspectFit

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title
        titleLabel_Posture.font = .systemFont(ofSize: 10, weight: .semibold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        titleLabel_Posture.textAlignment = .center

        let valueLabel_Posture = UILabel()
        valueLabel_Posture.text = value
        valueLabel_Posture.font = .systemFont(ofSize: 15, weight: .heavy)
        valueLabel_Posture.textColor = color
        valueLabel_Posture.textAlignment = .center

        container_Posture.addSubview(iconIV_Posture)
        container_Posture.addSubview(titleLabel_Posture)
        container_Posture.addSubview(valueLabel_Posture)

        iconIV_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(14)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconIV_Posture.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
        }
        valueLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(6)
        }
        return container_Posture
    }

    /// 创建竖向分割线
    private func makeVerticalDivider_Posture() -> UIView {
        let v_Posture = UIView()
        v_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        return v_Posture
    }

    /// 开始/暂停 切换（点击同一按钮，并更新状态提示文字）
    private func toggleStartPause_Posture() {
        // 查找状态提示 label（tag 6001）
        let stateHint_Posture = timerOverlay_Posture?.subviews.first?.viewWithTag(6001) as? UILabel

        switch timerState_Posture {
        case .stopped_Posture, .paused_Posture:
            timerState_Posture = .running_Posture
            startExerciseTimer_Posture()
            startPauseBtn_Posture?.setTitle("  Pause", for: .normal)
            startPauseBtn_Posture?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startPauseBtn_Posture?.backgroundColor = ColorConfig_Posture.accentAmber_Posture
            stateHint_Posture?.text = "Running…"
            stateHint_Posture?.textColor = ColorConfig_Posture.accentAmber_Posture
        case .running_Posture:
            timerState_Posture = .paused_Posture
            exerciseTimer_Posture?.invalidate()
            exerciseTimer_Posture = nil
            startPauseBtn_Posture?.setTitle("  Resume", for: .normal)
            startPauseBtn_Posture?.setImage(UIImage(systemName: "play.fill"), for: .normal)
            startPauseBtn_Posture?.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
            stateHint_Posture?.text = "Paused"
            stateHint_Posture?.textColor = ColorConfig_Posture.textPlaceholder_Posture
        }
    }

    /// 启动内部计时器（每秒回调）
    private func startExerciseTimer_Posture() {
        exerciseTimer_Posture?.invalidate()
        exerciseTimer_Posture = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self_Posture = self else { return }
            self_Posture.timerSessionSeconds_Posture += 1
            self_Posture.updateTimerDisplay_Posture()
        }
    }

    /// 更新计时显示、环形进度和本次用时标签
    private func updateTimerDisplay_Posture() {
        let s_Posture = timerSessionSeconds_Posture
        timerDisplayLabel_Posture?.text = String(format: "%02d:%02d", s_Posture / 60, s_Posture % 60)

        // 更新环形进度（叠加历史完成量）
        if timerTargetSeconds_Posture > 0 {
            let historySec_Posture = UserViewModel_Posture.shared_Posture
                .getUserPlans_Posture()
                .first(where: { $0.planId_Posture == timerPlanId_Posture })?
                .completedSeconds_Posture ?? 0
            let total_Posture = historySec_Posture + s_Posture
            let ratio_Posture = Float(min(1.0, Double(total_Posture) / Double(timerTargetSeconds_Posture)))
            timerRingView_Posture?.setProgress(ratio_Posture, animated: true)
        }

        // 本次用时
        if s_Posture < 60 {
            timerSessionLabel_Posture?.text = "Session: \(s_Posture) sec"
        } else {
            timerSessionLabel_Posture?.text = "Session: \(s_Posture / 60)m \(s_Posture % 60)s"
        }
    }

    /// 结束并保存本次会话进度
    private func saveAndCloseTimer_Posture() {
        exerciseTimer_Posture?.invalidate()
        exerciseTimer_Posture = nil
        timerState_Posture = .stopped_Posture

        if let planId_Posture = timerPlanId_Posture, timerSessionSeconds_Posture > 0 {
            UserViewModel_Posture.shared_Posture.updatePlanProgress_Posture(
                planId_posture: planId_Posture,
                addSeconds_posture: timerSessionSeconds_Posture
            )
        }
        closeTimerOverlay_Posture { [weak self] in
            self?.reloadPlanSection_Posture()
        }
    }

    /// 放弃本次会话，不记录进度
    private func discardAndCloseTimer_Posture() {
        exerciseTimer_Posture?.invalidate()
        exerciseTimer_Posture = nil
        timerState_Posture = .stopped_Posture
        closeTimerOverlay_Posture()
    }

    /// 关闭计时弹窗动画
    private func closeTimerOverlay_Posture(completion: (() -> Void)? = nil) {
        guard let overlay_Posture = timerOverlay_Posture else { return }
        UIView.animate(withDuration: AnimationConfig_Posture.durationNormal_Posture, animations: {
            overlay_Posture.alpha = 0
            overlay_Posture.subviews.first?.transform = CGAffineTransform(translationX: 0, y: overlay_Posture.bounds.height)
        }, completion: { _ in
            overlay_Posture.removeFromSuperview()
            completion?()
        })
    }

    // MARK: - Section 3：话题社区（横向两列网格）

    /// 构建话题互助社区区块
    private func buildTopicsSection_Posture() -> UIView {
        let section_Posture = UIView()
        let header_Posture = makeSectionHeader_Posture(
            title_posture: "Topic Community",
            subtitle_posture: "Tap a topic to join the conversation"
        )

        topicsGridStack_Posture.axis = .vertical
        topicsGridStack_Posture.spacing = 12

        section_Posture.addSubview(header_Posture)
        section_Posture.addSubview(topicsGridStack_Posture)

        header_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        topicsGridStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(header_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return section_Posture
    }

    /// 刷新话题列表（重新生成两列网格）
    private func reloadTopicsSection_Posture() {
        topicsGridStack_Posture.arrangedSubviews.forEach {
            topicsGridStack_Posture.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let topics_Posture = TitleViewModel_Posture.shared_Posture.getTopics_Posture()
        guard !topics_Posture.isEmpty else { return }

        // 每两个话题排一行
        var rowIndex_Posture = 0
        while rowIndex_Posture < topics_Posture.count {
            let rowStack_Posture = UIStackView()
            rowStack_Posture.axis = .horizontal
            rowStack_Posture.spacing = 12
            rowStack_Posture.distribution = .fillEqually

            let first_Posture = topics_Posture[rowIndex_Posture]
            rowStack_Posture.addArrangedSubview(makeTopicChip_Posture(topic: first_Posture, index: rowIndex_Posture))

            if rowIndex_Posture + 1 < topics_Posture.count {
                let second_Posture = topics_Posture[rowIndex_Posture + 1]
                rowStack_Posture.addArrangedSubview(makeTopicChip_Posture(topic: second_Posture, index: rowIndex_Posture + 1))
            } else {
                // 奇数话题：末行加一个透明占位保持均分
                let spacer_Posture = UIView()
                spacer_Posture.isUserInteractionEnabled = false
                rowStack_Posture.addArrangedSubview(spacer_Posture)
            }

            topicsGridStack_Posture.addArrangedSubview(rowStack_Posture)
            rowIndex_Posture += 2
        }
    }

    /// 构建单个话题横向圆角矩形卡片（紧凑版）
    /// - Parameters:
    ///   - topic: 话题模型
    ///   - index: 调色盘索引
    /// - Returns: UIView
    private func makeTopicChip_Posture(topic: Topic_Posture, index: Int) -> UIView {
        let colors_Posture = ColorConfig_Posture.chipColors_Posture(at: index)
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 20
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 8
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        // 图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = colors_Posture.bg
        iconBg_Posture.layer.cornerRadius = 16

        let iconIV_Posture = UIImageView(image: UIImage(systemName: topic.topicIcon_Posture))
        iconIV_Posture.tintColor = colors_Posture.tint
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = topic.topicTitle_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 1

        // 成员数
        let memberLabel_Posture = UILabel()
        memberLabel_Posture.text = "\(formatCount_Posture(topic.memberCount_Posture)) members"
        memberLabel_Posture.font = .systemFont(ofSize: 11, weight: .regular)
        memberLabel_Posture.textColor = colors_Posture.tint

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(memberLabel_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        memberLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel_Posture)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(12)
        }

        // 点击跳转话题详情
        card_Posture.tag = topic.topicId_Posture
        card_Posture.isUserInteractionEnabled = true
        let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(handleTopicTap_Posture(_:)))
        card_Posture.addGestureRecognizer(tap_Posture)

        return card_Posture
    }

    // MARK: - 统一刷新

    /// 刷新所有区块数据
    private func reloadAll_Posture() {
        reloadCheckInSection_Posture()
        reloadPlanSection_Posture()
        reloadTopicsSection_Posture()
    }

    // MARK: - 通知监听

    /// 注册所有相关通知
    private func observeNotifications_Posture() {
        let center_Posture = NotificationCenter.default
        center_Posture.addObserver(self, selector: #selector(handleUserStateChange_Posture),
                                   name: UserViewModel_Posture.userStateDidChangeNotification_Posture, object: nil)
        center_Posture.addObserver(self, selector: #selector(handlePlanProfileChange_Posture),
                                   name: UserViewModel_Posture.planProfileDidChangeNotification_Posture, object: nil)
        center_Posture.addObserver(self, selector: #selector(handleTopicStateChange_Posture),
                                   name: TitleViewModel_Posture.topicStateDidChangeNotification_Posture, object: nil)
        center_Posture.addObserver(self, selector: #selector(handleUserPlansChange_Posture),
                                   name: UserViewModel_Posture.userPlansDidChangeNotification_Posture, object: nil)
    }

    @objc private func handleUserStateChange_Posture()  { reloadCheckInSection_Posture() }
    @objc private func handlePlanProfileChange_Posture() { reloadPlanSection_Posture() }
    @objc private func handleTopicStateChange_Posture()  { reloadTopicsSection_Posture() }
    @objc private func handleUserPlansChange_Posture()   { reloadPlanSection_Posture() }

    // MARK: - 事件处理

    /// 话题卡片点击跳转详情
    @objc private func handleTopicTap_Posture(_ gesture_Posture: UITapGestureRecognizer) {
        guard let topicId_Posture = gesture_Posture.view?.tag,
              let topic_Posture = TitleViewModel_Posture.shared_Posture.getTopics_Posture()
                  .first(where: { $0.topicId_Posture == topicId_Posture }) else { return }
        gesture_Posture.view?.animatePressDown_Posture { [weak gesture_Posture] in
            gesture_Posture?.view?.animatePressUp_Posture()
        }
        Navigation_Posture.toTopicDetail_Posture(topic_posture: topic_Posture)
    }

    // MARK: - 通用工具

    /// 构建通用区块标题视图
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
    private func formatCount_Posture(_ count_posture: Int) -> String {
        return count_posture >= 1000
            ? String(format: "%.1fk", Double(count_posture) / 1000)
            : "\(count_posture)"
    }
}

// MARK: - 计划日历弹窗

extension Home_Posture {

    /// 展示当月计划日历弹窗
    private func showPlanCalendar_Posture() {
        guard calendarOverlay_Posture == nil, let window_Posture = view.window else { return }
        calendarDisplayDate_Posture = Date()

        let overlay_Posture = UIView()
        overlay_Posture.backgroundColor = .clear
        overlay_Posture.frame = window_Posture.bounds
        overlay_Posture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window_Posture.addSubview(overlay_Posture)
        calendarOverlay_Posture = overlay_Posture

        let sheet_Posture = buildPlanCalendarSheet_Posture()
        sheet_Posture.layer.cornerRadius = 30
        sheet_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_Posture.addSubview(sheet_Posture)
        sheet_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        sheet_Posture.transform = CGAffineTransform(translationX: 0, y: window_Posture.bounds.height)
        overlay_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPlanCalendar_Posture)))

        UIView.animate(
            withDuration: AnimationConfig_Posture.durationSpring_Posture,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Posture.springDampingNormal_Posture,
            initialSpringVelocity: AnimationConfig_Posture.springVelocity_Posture,
            options: [.curveEaseOut]
        ) {
            overlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            sheet_Posture.transform = .identity
        }
    }

    /// 关闭日历弹窗
    @objc private func dismissPlanCalendar_Posture() {
        guard let overlay_Posture = calendarOverlay_Posture else { return }
        UIView.animate(withDuration: AnimationConfig_Posture.durationNormal_Posture, animations: {
            overlay_Posture.alpha = 0
            overlay_Posture.subviews.first?.transform = CGAffineTransform(translationX: 0, y: overlay_Posture.bounds.height)
        }, completion: { _ in overlay_Posture.removeFromSuperview() })
    }

    /// 构建日历弹窗主体
    private func buildPlanCalendarSheet_Posture() -> UIView {
        let sheet_Posture = UIView()
        sheet_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 2.5

        // 月份标题行（← 月份 →）
        let prevBtn_Posture = UIButton(type: .system)
        prevBtn_Posture.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevBtn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        prevBtn_Posture.tag = -1
        prevBtn_Posture.addTarget(self, action: #selector(handleCalendarMonthChange_Posture(_:)), for: .touchUpInside)

        let nextBtn_Posture = UIButton(type: .system)
        nextBtn_Posture.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextBtn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        nextBtn_Posture.tag = 1
        nextBtn_Posture.addTarget(self, action: #selector(handleCalendarMonthChange_Posture(_:)), for: .touchUpInside)

        let monthLabel_Posture = UILabel()
        let fmt_Posture = DateFormatter()
        fmt_Posture.dateFormat = "MMMM yyyy"
        monthLabel_Posture.text = fmt_Posture.string(from: calendarDisplayDate_Posture)
        monthLabel_Posture.font = .systemFont(ofSize: 17, weight: .bold)
        monthLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        monthLabel_Posture.textAlignment = .center
        monthLabel_Posture.tag = 5001  // 用于月份切换时刷新

        // 图例说明行
        let legendRow_Posture = buildCalendarLegend_Posture()

        // 星期表头
        let weekHeader_Posture = buildCalendarWeekHeader_Posture()

        // 日历网格容器（月份切换时替换内容）
        let gridContainer_Posture = UIView()
        calendarGridContainer_Posture = gridContainer_Posture

        let planDates_Posture = Set(UserViewModel_Posture.shared_Posture.getUserPlans_Posture().map { $0.createdDate_Posture })
        let grid_Posture = buildCalendarGrid_Posture(displayDate: calendarDisplayDate_Posture, planDates: planDates_Posture)
        gridContainer_Posture.addSubview(grid_Posture)
        grid_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 分割线
        let divider_Posture = UIView()
        divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture

        // 选中日期计划列表区（初始提示文字）
        let planListOuter_Posture = UIView()
        calendarPlanListContainer_Posture = planListOuter_Posture
        buildCalendarPlanListContent_Posture(in: planListOuter_Posture, dateStr: nil)

        // 关闭按钮
        let closeBtn_Posture = UIButton(type: .system)
        closeBtn_Posture.setTitle("Close", for: .normal)
        closeBtn_Posture.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        closeBtn_Posture.setTitleColor(ColorConfig_Posture.primaryGradientStart_Posture, for: .normal)
        closeBtn_Posture.addTarget(self, action: #selector(dismissPlanCalendar_Posture), for: .touchUpInside)

        [handle_Posture, prevBtn_Posture, monthLabel_Posture, nextBtn_Posture,
         legendRow_Posture, weekHeader_Posture, gridContainer_Posture,
         divider_Posture, planListOuter_Posture, closeBtn_Posture].forEach {
            sheet_Posture.addSubview($0)
        }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40); make.height.equalTo(5)
        }
        prevBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(22)
            make.width.height.equalTo(32)
        }
        monthLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(prevBtn_Posture)
            make.leading.equalTo(prevBtn_Posture.snp.trailing).offset(8)
            make.trailing.equalTo(nextBtn_Posture.snp.leading).offset(-8)
        }
        nextBtn_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(prevBtn_Posture)
            make.trailing.equalToSuperview().inset(22)
            make.width.height.equalTo(32)
        }
        legendRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(prevBtn_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        weekHeader_Posture.snp.makeConstraints { make in
            make.top.equalTo(legendRow_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(24)
        }
        gridContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(weekHeader_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        divider_Posture.snp.makeConstraints { make in
            make.top.equalTo(gridContainer_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(1)
        }
        planListOuter_Posture.snp.makeConstraints { make in
            make.top.equalTo(divider_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        closeBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(planListOuter_Posture.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(sheet_Posture.safeAreaLayoutGuide.snp.bottom).inset(14)
        }

        return sheet_Posture
    }

    /// 月份切换：tag=-1 上月，tag=1 下月
    @objc private func handleCalendarMonthChange_Posture(_ sender: UIButton) {
        guard let container_Posture = calendarGridContainer_Posture else { return }
        var comps_Posture = DateComponents()
        comps_Posture.month = sender.tag
        calendarDisplayDate_Posture = Calendar.current.date(byAdding: comps_Posture, to: calendarDisplayDate_Posture) ?? calendarDisplayDate_Posture

        // 刷新月份标签
        if let overlay_Posture = calendarOverlay_Posture,
           let sheet_Posture = overlay_Posture.subviews.first,
           let monthLabel_Posture = sheet_Posture.viewWithTag(5001) as? UILabel {
            let fmt_Posture = DateFormatter()
            fmt_Posture.dateFormat = "MMMM yyyy"
            monthLabel_Posture.text = fmt_Posture.string(from: calendarDisplayDate_Posture)
        }

        // 替换日历网格
        container_Posture.subviews.forEach { $0.removeFromSuperview() }
        let planDates_Posture = Set(UserViewModel_Posture.shared_Posture.getUserPlans_Posture().map { $0.createdDate_Posture })
        let newGrid_Posture = buildCalendarGrid_Posture(displayDate: calendarDisplayDate_Posture, planDates: planDates_Posture)
        container_Posture.addSubview(newGrid_Posture)
        newGrid_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        UIView.transition(with: container_Posture, duration: 0.25, options: .transitionCrossDissolve) {
            container_Posture.layoutIfNeeded()
        }
        // 月份切换后清空选中日期和计划列表
        selectedCalendarDate_Posture = nil
        if let listContainer_Posture = calendarPlanListContainer_Posture {
            buildCalendarPlanListContent_Posture(in: listContainer_Posture, dateStr: nil)
        }
    }

    /// 处理日历日期格子点击：更新选中状态和下方计划列表
    @objc private func handleCalendarDayTap_Posture(_ gesture_Posture: UITapGestureRecognizer) {
        guard let dateStr_Posture = gesture_Posture.view?.accessibilityIdentifier else { return }
        selectedCalendarDate_Posture = dateStr_Posture

        // 动画反馈
        gesture_Posture.view?.animatePressDown_Posture { [weak gesture_Posture] in
            gesture_Posture?.view?.animatePressUp_Posture()
        }

        // 更新计划列表区域
        if let listContainer_Posture = calendarPlanListContainer_Posture {
            UIView.transition(with: listContainer_Posture, duration: 0.2, options: .transitionCrossDissolve) {
                self.buildCalendarPlanListContent_Posture(in: listContainer_Posture, dateStr: dateStr_Posture)
                listContainer_Posture.superview?.layoutIfNeeded()
            }
        }
    }

    /// 在指定容器中填充选中日期的计划列表
    /// - Parameters:
    ///   - container_posture: 承载计划列表的 UIView
    ///   - dateStr_posture: "yyyy-MM-dd" 日期字符串，nil 时显示提示文字
    private func buildCalendarPlanListContent_Posture(in container_posture: UIView, dateStr: String?) {
        // 清空旧内容
        container_posture.subviews.forEach { $0.removeFromSuperview() }

        guard let date_Posture = dateStr else {
            // 未选中日期：提示
            let hint_Posture = UILabel()
            hint_Posture.text = "Tap a date to see plans"
            hint_Posture.font = .systemFont(ofSize: 13, weight: .regular)
            hint_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
            hint_Posture.textAlignment = .center
            container_posture.addSubview(hint_Posture)
            hint_Posture.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.leading.trailing.equalToSuperview()
            }
            return
        }

        // 找到该日期的计划
        let matched_Posture = UserViewModel_Posture.shared_Posture.getUserPlans_Posture()
            .filter { $0.createdDate_Posture == date_Posture }

        // 日期标题行
        let fmt_Posture = DateFormatter()
        fmt_Posture.dateFormat = "yyyy-MM-dd"
        let displayFmt_Posture = DateFormatter()
        displayFmt_Posture.dateFormat = "MMM d, yyyy"
        let displayDate_Posture: String
        if let d_Posture = fmt_Posture.date(from: date_Posture) {
            displayDate_Posture = displayFmt_Posture.string(from: d_Posture)
        } else {
            displayDate_Posture = date_Posture
        }

        let dateTitle_Posture = UILabel()
        dateTitle_Posture.text = "Plans on \(displayDate_Posture)"
        dateTitle_Posture.font = .systemFont(ofSize: 14, weight: .bold)
        dateTitle_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        container_posture.addSubview(dateTitle_Posture)
        dateTitle_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        if matched_Posture.isEmpty {
            // 当天无计划
            let empty_Posture = UILabel()
            empty_Posture.text = "No plans on this day"
            empty_Posture.font = .systemFont(ofSize: 13, weight: .regular)
            empty_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
            container_posture.addSubview(empty_Posture)
            empty_Posture.snp.makeConstraints { make in
                make.top.equalTo(dateTitle_Posture.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(8)
            }
        } else {
            // 计划列表
            let stack_Posture = UIStackView()
            stack_Posture.axis = .vertical
            stack_Posture.spacing = 10
            container_posture.addSubview(stack_Posture)
            stack_Posture.snp.makeConstraints { make in
                make.top.equalTo(dateTitle_Posture.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(4)
            }

            for (idx_Posture, plan_Posture) in matched_Posture.enumerated() {
                let row_Posture = makePlanSummaryRow_Posture(plan: plan_Posture, index: idx_Posture)
                stack_Posture.addArrangedSubview(row_Posture)
            }
        }
    }

    /// 日历弹窗内的计划摘要行（彩色点 + 标题 + 进度）
    private func makePlanSummaryRow_Posture(plan: UserPlan_Posture, index: Int) -> UIView {
        let palette_Posture = ColorConfig_Posture.cardAccentPalette_Posture[index % ColorConfig_Posture.cardAccentPalette_Posture.count]
        let row_Posture = UIView()
        row_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        row_Posture.layer.cornerRadius = 14

        // 彩色左侧竖条
        let bar_Posture = UIView()
        bar_Posture.backgroundColor = palette_Posture.main
        bar_Posture.layer.cornerRadius = 2

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = plan.title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 进度文字
        let progressText_Posture = UILabel()
        progressText_Posture.text = "\(plan.completedMinutes_Posture)/\(plan.targetMinutes_Posture) min"
        progressText_Posture.font = .systemFont(ofSize: 11, weight: .regular)
        progressText_Posture.textColor = palette_Posture.main

        // 进度条
        let progressBar_Posture = UIProgressView(progressViewStyle: .default)
        progressBar_Posture.trackTintColor = palette_Posture.light
        progressBar_Posture.progressTintColor = palette_Posture.main
        progressBar_Posture.layer.cornerRadius = 2
        progressBar_Posture.clipsToBounds = true
        progressBar_Posture.progress = Float(plan.progressRatio_Posture)

        // 时间徽章（如有）
        row_Posture.addSubview(bar_Posture)
        row_Posture.addSubview(titleLabel_Posture)
        row_Posture.addSubview(progressText_Posture)
        row_Posture.addSubview(progressBar_Posture)

        if let time_Posture = plan.scheduledTime_Posture, !time_Posture.isEmpty {
            let timeLabel_Posture = UILabel()
            timeLabel_Posture.text = "⏰ \(time_Posture)"
            timeLabel_Posture.font = .systemFont(ofSize: 10, weight: .semibold)
            timeLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
            row_Posture.addSubview(timeLabel_Posture)
            timeLabel_Posture.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(12)
                make.centerY.equalTo(titleLabel_Posture)
            }
        }

        bar_Posture.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(3)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.leading.equalTo(bar_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
        }
        progressText_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel_Posture)
        }
        progressBar_Posture.snp.makeConstraints { make in
            make.top.equalTo(progressText_Posture.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel_Posture)
            make.trailing.equalToSuperview().inset(12)
            make.height.equalTo(4)
            make.bottom.equalToSuperview().inset(9)
        }

        return row_Posture
    }

    /// 构建日历图例行（有计划 / 今天 / 普通）
    private func buildCalendarLegend_Posture() -> UIView {
        let stack_Posture = UIStackView()
        stack_Posture.axis = .horizontal
        stack_Posture.spacing = 18
        stack_Posture.alignment = .center

        func legendItem_Posture(_ color: UIColor, _ text: String) -> UIView {
            let row_Posture = UIView()
            let dot_Posture = UIView()
            dot_Posture.backgroundColor = color
            dot_Posture.layer.cornerRadius = 6
            let label_Posture = UILabel()
            label_Posture.text = text
            label_Posture.font = .systemFont(ofSize: 11, weight: .regular)
            label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
            row_Posture.addSubview(dot_Posture)
            row_Posture.addSubview(label_Posture)
            dot_Posture.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.width.height.equalTo(12)
            }
            label_Posture.snp.makeConstraints { make in
                make.leading.equalTo(dot_Posture.snp.trailing).offset(5)
                make.centerY.trailing.equalToSuperview()
            }
            return row_Posture
        }

        stack_Posture.addArrangedSubview(legendItem_Posture(ColorConfig_Posture.primaryGradientStart_Posture, "Has plan"))
        stack_Posture.addArrangedSubview(legendItem_Posture(ColorConfig_Posture.accentMint_Posture, "Today"))
        stack_Posture.addArrangedSubview(legendItem_Posture(ColorConfig_Posture.border_Posture, "No plan"))
        return stack_Posture
    }

    /// 构建星期表头（Sun Mon … Sat）
    private func buildCalendarWeekHeader_Posture() -> UIView {
        let stack_Posture = UIStackView()
        stack_Posture.axis = .horizontal
        stack_Posture.distribution = .fillEqually
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].forEach { day_Posture in
            let label_Posture = UILabel()
            label_Posture.text = day_Posture
            label_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
            label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
            label_Posture.textAlignment = .center
            stack_Posture.addArrangedSubview(label_Posture)
        }
        return stack_Posture
    }

    /// 构建月份日历网格（有计划日期高亮）
    /// - Parameters:
    ///   - displayDate: 当月任意日期
    ///   - planDates: "yyyy-MM-dd" 有计划的日期集合
    /// - Returns: UIView - 周行网格
    private func buildCalendarGrid_Posture(displayDate: Date, planDates: Set<String>) -> UIView {
        let container_Posture = UIView()
        let cal_Posture = Calendar.current

        // 本月第一天
        var comps_Posture = cal_Posture.dateComponents([.year, .month], from: displayDate)
        comps_Posture.day = 1
        guard let firstDay_Posture = cal_Posture.date(from: comps_Posture) else { return container_Posture }

        let weekday_Posture = cal_Posture.component(.weekday, from: firstDay_Posture) - 1  // 0=Sunday
        let daysCount_Posture = cal_Posture.range(of: .day, in: .month, for: firstDay_Posture)?.count ?? 30

        let dateFmt_Posture = DateFormatter()
        dateFmt_Posture.dateFormat = "yyyy-MM-dd"

        let rowsStack_Posture = UIStackView()
        rowsStack_Posture.axis = .vertical
        rowsStack_Posture.spacing = 8

        var dayNumber_Posture = 1
        var offsetLeft_Posture = weekday_Posture

        while dayNumber_Posture <= daysCount_Posture {
            let rowStack_Posture = UIStackView()
            rowStack_Posture.axis = .horizontal
            rowStack_Posture.distribution = .fillEqually
            rowStack_Posture.spacing = 4

            for _ in 0..<7 {
                if offsetLeft_Posture > 0 {
                    rowStack_Posture.addArrangedSubview(UIView())
                    offsetLeft_Posture -= 1
                } else if dayNumber_Posture <= daysCount_Posture {
                    var dayComps_Posture = comps_Posture
                    dayComps_Posture.day = dayNumber_Posture
                    let dayDate_Posture = cal_Posture.date(from: dayComps_Posture) ?? firstDay_Posture
                    let dateStr_Posture = dateFmt_Posture.string(from: dayDate_Posture)
                    let hasPlan_Posture = planDates.contains(dateStr_Posture)
                    let isToday_Posture = cal_Posture.isDateInToday(dayDate_Posture)
                    let cell_Posture = makeCalendarDayCell_Posture(day: dayNumber_Posture, hasPlan: hasPlan_Posture, isToday: isToday_Posture)
                    // 存储日期字符串，用于点击时识别
                    cell_Posture.accessibilityIdentifier = dateStr_Posture
                    cell_Posture.isUserInteractionEnabled = true
                    cell_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCalendarDayTap_Posture(_:))))
                    rowStack_Posture.addArrangedSubview(cell_Posture)
                    dayNumber_Posture += 1
                } else {
                    rowStack_Posture.addArrangedSubview(UIView())
                }
            }
            rowsStack_Posture.addArrangedSubview(rowStack_Posture)
            rowStack_Posture.snp.makeConstraints { make in make.height.equalTo(38) }
        }

        container_Posture.addSubview(rowsStack_Posture)
        rowsStack_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        return container_Posture
    }

    /// 构建单个日期格子（圆圈样式）
    private func makeCalendarDayCell_Posture(day: Int, hasPlan: Bool, isToday: Bool) -> UIView {
        let cell_Posture = UIView()
        let circle_Posture = UIView()
        circle_Posture.layer.cornerRadius = 16

        if hasPlan {
            circle_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        } else if isToday {
            circle_Posture.backgroundColor = ColorConfig_Posture.accentMint_Posture
        } else {
            circle_Posture.backgroundColor = .clear
        }

        let label_Posture = UILabel()
        label_Posture.text = "\(day)"
        label_Posture.font = .systemFont(ofSize: 14, weight: hasPlan || isToday ? .bold : .regular)
        label_Posture.textColor = hasPlan || isToday ? .white : ColorConfig_Posture.textPrimary_Posture
        label_Posture.textAlignment = .center

        // 有计划时在圆点下方加小点
        if hasPlan {
            let dot_Posture = UIView()
            dot_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            dot_Posture.layer.cornerRadius = 2
            circle_Posture.addSubview(dot_Posture)
            dot_Posture.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(3)
                make.width.equalTo(4); make.height.equalTo(4)
            }
        }

        cell_Posture.addSubview(circle_Posture)
        circle_Posture.addSubview(label_Posture)

        circle_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        label_Posture.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(hasPlan ? -2 : 0)
        }
        return cell_Posture
    }
}

// MARK: - 每日 Tips 推荐

extension Home_Posture {

    /// Tips 数据（图标 / 短标题 / 完整内容）
    private static let tipsData_Posture: [(icon: String, title: String, content: String)] = [
        ("figure.cooldown",
         "Chin Tuck",
         "Sit or stand tall with shoulders relaxed.\nGently pull your chin straight back — not down.\nHold for 5 seconds, then release.\nRepeat 10 times. This realigns the cervical spine and reduces forward-head posture."),
        ("lungs",
         "Box Breathing",
         "Inhale slowly through your nose for 4 counts.\nHold your breath for 4 counts.\nExhale fully through your mouth for 4 counts.\nHold empty for 4 counts.\nRepeat 4–6 cycles. Activates the parasympathetic nervous system and improves posture awareness."),
        ("figure.strengthtraining.traditional",
         "Shoulder Rolls",
         "Sit or stand tall.\nRoll both shoulders backward in large circles — 10 reps.\nThen roll forward — 10 reps.\nFinish with a shoulder squeeze: pull blades together and hold 5 sec.\nReleases tension caused by prolonged desk work."),
        ("figure.flexibility",
         "Cat-Cow Stretch",
         "Start on hands and knees with a neutral spine.\nInhale: drop your belly, lift your head and tailbone (cow pose).\nExhale: round your spine upward, tuck chin and tailbone (cat pose).\nFlow through 10 slow cycles. Mobilises the spine and reduces back stiffness."),
        ("chair",
         "Desk Break Rule",
         "Set a recurring timer every 45 minutes.\nWhen it rings: stand up, walk for 2 minutes.\nDo a quick shoulder roll and one deep breath.\nReset your sitting posture before returning.\nConsistent micro-breaks prevent chronic tension buildup."),
        ("figure.walk",
         "Hip Flexor Stretch",
         "Stand tall and step one foot forward into a lunge.\nLower your back knee gently toward the floor.\nFeel the stretch in the front of the back hip.\nHold 30 seconds, then switch sides.\nTight hip flexors from sitting tilt the pelvis and cause lower-back pain."),
    ]

    /// 构建每日 Tips 推荐区块（标题 + 横向卡片滚动）
    private func buildTipsSection_Posture() -> UIView {
        let section_Posture = UIView()

        let header_Posture = makeSectionHeader_Posture(
            title_posture: "Daily Tips",
            subtitle_posture: "Quick posture habits — tap to learn more"
        )

        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsHorizontalScrollIndicator = false
        scrollView_Posture.alwaysBounceHorizontal = true
        scrollView_Posture.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)

        let cardStack_Posture = UIStackView()
        cardStack_Posture.axis = .horizontal
        cardStack_Posture.spacing = 12

        for (idx_Posture, tip_Posture) in Self.tipsData_Posture.enumerated() {
            let card_Posture = makeTipCard_Posture(index: idx_Posture, title: tip_Posture.title, icon: tip_Posture.icon)
            cardStack_Posture.addArrangedSubview(card_Posture)
            card_Posture.snp.makeConstraints { make in
                make.width.equalTo(110)
            }
        }

        scrollView_Posture.addSubview(cardStack_Posture)
        cardStack_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.height.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        section_Posture.addSubview(header_Posture)
        section_Posture.addSubview(scrollView_Posture)

        header_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        scrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(header_Posture.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(130)
        }

        return section_Posture
    }

    /// 构建单个 Tip 卡片
    private func makeTipCard_Posture(index: Int, title: String, icon: String) -> UIView {
        let colors_Posture = ColorConfig_Posture.chipColors_Posture(at: index)
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 20
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 8
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        // 图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = colors_Posture.bg
        iconBg_Posture.layer.cornerRadius = 16

        let iconIV_Posture = UIImageView(image: UIImage(systemName: icon))
        iconIV_Posture.tintColor = colors_Posture.tint
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title
        titleLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.textAlignment = .center
        titleLabel_Posture.numberOfLines = 2

        let arrowLabel_Posture = UILabel()
        arrowLabel_Posture.text = "Tap to read ›"
        arrowLabel_Posture.font = .systemFont(ofSize: 10, weight: .regular)
        arrowLabel_Posture.textColor = colors_Posture.tint
        arrowLabel_Posture.textAlignment = .center

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(arrowLabel_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(38)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        arrowLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }

        // 点击展示 Tips 详情
        let tap_Posture = UITapGestureRecognizer()
        tap_Posture.addTarget(self, action: #selector(handleTipTap_Posture(_:)))
        card_Posture.addGestureRecognizer(tap_Posture)
        card_Posture.isUserInteractionEnabled = true
        card_Posture.tag = 4000 + index

        return card_Posture
    }

    /// 处理 Tip 卡片点击
    @objc private func handleTipTap_Posture(_ gesture_Posture: UIGestureRecognizer) {
        guard let idx_Posture = gesture_Posture.view.map({ $0.tag - 4000 }),
              idx_Posture >= 0, idx_Posture < Self.tipsData_Posture.count else { return }
        gesture_Posture.view?.animatePressDown_Posture { [weak gesture_Posture] in
            gesture_Posture?.view?.animatePressUp_Posture()
        }
        showTipDetail_Posture(index: idx_Posture)
    }

    /// 展示 Tip 详情弹窗
    private func showTipDetail_Posture(index: Int) {
        guard tipsOverlay_Posture == nil, let window_Posture = view.window else { return }
        let tip_Posture = Self.tipsData_Posture[index]

        let overlay_Posture = UIView()
        overlay_Posture.backgroundColor = .clear
        overlay_Posture.frame = window_Posture.bounds
        overlay_Posture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window_Posture.addSubview(overlay_Posture)
        tipsOverlay_Posture = overlay_Posture

        let sheet_Posture = buildTipDetailSheet_Posture(index: index, icon: tip_Posture.icon, title: tip_Posture.title, content: tip_Posture.content)
        sheet_Posture.layer.cornerRadius = 28
        sheet_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlay_Posture.addSubview(sheet_Posture)
        sheet_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        sheet_Posture.transform = CGAffineTransform(translationX: 0, y: window_Posture.bounds.height)
        overlay_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTipDetail_Posture)))

        UIView.animate(
            withDuration: AnimationConfig_Posture.durationSpring_Posture,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Posture.springDampingNormal_Posture,
            initialSpringVelocity: AnimationConfig_Posture.springVelocity_Posture,
            options: [.curveEaseOut]
        ) {
            overlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            sheet_Posture.transform = .identity
        }
    }

    @objc private func dismissTipDetail_Posture() {
        guard let overlay_Posture = tipsOverlay_Posture else { return }
        UIView.animate(withDuration: AnimationConfig_Posture.durationNormal_Posture, animations: {
            overlay_Posture.alpha = 0
            overlay_Posture.subviews.first?.transform = CGAffineTransform(translationX: 0, y: overlay_Posture.bounds.height)
        }, completion: { _ in overlay_Posture.removeFromSuperview() })
    }

    /// 构建 Tip 详情弹窗内容
    private func buildTipDetailSheet_Posture(index: Int, icon: String, title: String, content: String) -> UIView {
        let colors_Posture = ColorConfig_Posture.chipColors_Posture(at: index)
        let sheet_Posture = UIView()
        sheet_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        let handle_Posture = UIView()
        handle_Posture.backgroundColor = ColorConfig_Posture.border_Posture
        handle_Posture.layer.cornerRadius = 2.5

        // 图标区
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = colors_Posture.bg
        iconBg_Posture.layer.cornerRadius = 28
        let iconIV_Posture = UIImageView(image: UIImage(systemName: icon))
        iconIV_Posture.tintColor = colors_Posture.tint
        iconIV_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconIV_Posture)
        iconIV_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title
        titleLabel_Posture.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 标签
        let tagView_Posture = UIView()
        tagView_Posture.backgroundColor = colors_Posture.bg
        tagView_Posture.layer.cornerRadius = 10
        let tagLabel_Posture = UILabel()
        tagLabel_Posture.text = "Daily Tip"
        tagLabel_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        tagLabel_Posture.textColor = colors_Posture.tint
        tagView_Posture.addSubview(tagLabel_Posture)
        tagLabel_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(4)
        }

        // 分割线
        let divider_Posture = UIView()
        divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture

        // 内容
        let contentLabel_Posture = UILabel()
        contentLabel_Posture.text = content
        contentLabel_Posture.font = .systemFont(ofSize: 15, weight: .regular)
        contentLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        contentLabel_Posture.numberOfLines = 0
        contentLabel_Posture.lineBreakMode = .byWordWrapping

        // 关闭
        let closeBtn_Posture = UIButton(type: .system)
        closeBtn_Posture.setTitle("Got it!", for: .normal)
        closeBtn_Posture.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        closeBtn_Posture.setTitleColor(.white, for: .normal)
        closeBtn_Posture.backgroundColor = colors_Posture.tint
        closeBtn_Posture.layer.cornerRadius = 22
        closeBtn_Posture.addTarget(self, action: #selector(dismissTipDetail_Posture), for: .touchUpInside)

        [handle_Posture, iconBg_Posture, titleLabel_Posture, tagView_Posture,
         divider_Posture, contentLabel_Posture, closeBtn_Posture].forEach { sheet_Posture.addSubview($0) }

        handle_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40); make.height.equalTo(5)
        }
        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalTo(handle_Posture.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(22)
            make.width.height.equalTo(56)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(14)
            make.top.equalTo(iconBg_Posture).offset(2)
            make.trailing.equalToSuperview().inset(22)
        }
        tagView_Posture.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Posture)
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(6)
        }
        divider_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(1)
        }
        contentLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(divider_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
        }
        closeBtn_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(50)
            make.bottom.equalTo(sheet_Posture.safeAreaLayoutGuide.snp.bottom).inset(20)
        }

        return sheet_Posture
    }
}

// MARK: - 环形进度视图

/// 环形计时进度视图
/// 核心作用：用两个 CAShapeLayer（轨道层 + 进度层）绘制圆弧，直观展示计划完成比例。
/// 设计思路：进度颜色使用主色调渐变；轨道使用淡色；圆心为透明以便叠加计时文字。
/// 关键方法：setProgress(_:animated:) 更新 strokeEnd 驱动动画。
@MainActor
private class TimerRingView_Posture: UIView {

    private let trackLayer_Posture  = CAShapeLayer()
    private let progressLayer_Posture = CAShapeLayer()

    private var currentProgress_Posture: Float = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayers_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 设置两个圆弧图层
    private func setupLayers_Posture() {
        let lineWidth_Posture: CGFloat = 12

        // 轨道层
        trackLayer_Posture.fillColor   = UIColor.clear.cgColor
        trackLayer_Posture.strokeColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.12).cgColor
        trackLayer_Posture.lineWidth   = lineWidth_Posture
        trackLayer_Posture.lineCap     = .round
        layer.addSublayer(trackLayer_Posture)

        // 进度层
        progressLayer_Posture.fillColor   = UIColor.clear.cgColor
        progressLayer_Posture.strokeColor = ColorConfig_Posture.primaryGradientStart_Posture.cgColor
        progressLayer_Posture.lineWidth   = lineWidth_Posture
        progressLayer_Posture.lineCap     = .round
        progressLayer_Posture.strokeEnd   = 0
        layer.addSublayer(progressLayer_Posture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 圆弧路径：从 -90°（12点方向）顺时针一圈
        let center_Posture = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius_Posture = (min(bounds.width, bounds.height) - 12) / 2
        let path_Posture = UIBezierPath(
            arcCenter: center_Posture,
            radius: radius_Posture,
            startAngle: -(.pi / 2),
            endAngle: .pi * 1.5,
            clockwise: true
        )
        trackLayer_Posture.path  = path_Posture.cgPath
        progressLayer_Posture.path = path_Posture.cgPath
    }

    /// 更新进度（0.0 ~ 1.0）
    /// - Parameters:
    ///   - progress: 新进度值
    ///   - animated: 是否带动画
    func setProgress(_ progress_posture: Float, animated animated_posture: Bool) {
        let clamped_Posture = max(0, min(1, progress_posture))
        currentProgress_Posture = clamped_Posture
        if animated_posture {
            let anim_Posture = CABasicAnimation(keyPath: "strokeEnd")
            anim_Posture.fromValue = progressLayer_Posture.presentation()?.strokeEnd ?? progressLayer_Posture.strokeEnd
            anim_Posture.toValue   = clamped_Posture
            anim_Posture.duration  = 0.4
            anim_Posture.timingFunction = CAMediaTimingFunction(name: .easeOut)
            progressLayer_Posture.add(anim_Posture, forKey: "progressAnim")
        }
        progressLayer_Posture.strokeEnd = CGFloat(clamped_Posture)
    }
}

// MARK: - UIImagePickerControllerDelegate（计划封面选取）

extension Home_Posture: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// 用户选取图片后保存到临时目录，并更新封面预览
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        let image_Posture = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        guard let img_Posture = image_Posture,
              let data_Posture = img_Posture.jpegData(compressionQuality: 0.85) else { return }

        // 保存到 Documents 目录（永久存储，不会被 OS 清理）
        let docs_Posture = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url_Posture = docs_Posture.appendingPathComponent("plan_cover_\(Date().timeIntervalSince1970).jpg")
        try? data_Posture.write(to: url_Posture)
        pendingCoverPath_Posture = url_Posture.path

        // 更新弹窗内封面预览（tag 9100 = coverImageView, 9101 = placeholder icon, 9102 = hint label）
        if let overlay_Posture = addPlanOverlay_Posture,
           let sheet_Posture = overlay_Posture.subviews.first {
            (sheet_Posture.viewWithTag(9100) as? UIImageView)?.image = img_Posture
            sheet_Posture.viewWithTag(9101)?.isHidden = true
            sheet_Posture.viewWithTag(9102)?.isHidden = true
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
