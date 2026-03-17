import UIKit
import SnapKit

// MARK: - 月度可视化日历单元格（暖色重设计版）

/// 首页月度可视化日历单元格
/// 核心作用：以暖色热力图展示当月每日打卡情况；顶部徽章显示连续打卡天数；点击任意日期触发弹窗回调
/// 设计思路：温暖琥珀→珊瑚渐变头部 + 暖奶白卡片 + 橙系热力格 + 今日金边高亮 + 装饰圆点散布
/// 关键属性：
///   - onMonthChange_Pane: 月份切换回调，携带 (year, month)
///   - onDayTapped_Pane:   日期点击回调，携带 day (1-31)
///   - configure_Pane:     用年份、月份、打卡数字典、连续天数刷新日历
class HomeCalendarCell_Pane: UICollectionViewCell {

    // MARK: - 常量

    static let reuseId_Pane = "HomeCalendarCell_Pane"

    /// 星期标题（日 ~ 六）
    private let weekdayTitles_Pane = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    /// 头部渐变起始色 - 暖琥珀金
    private let headerColorStart_Pane = UIColor(hexstring_Pane: "#F7A24B")

    /// 头部渐变结束色 - 暖珊瑚红
    private let headerColorEnd_Pane   = UIColor(hexstring_Pane: "#E05A4E")

    // MARK: - UI 组件 — 外层卡片

    /// 外层卡片容器（暖色阴影）
    private let cardView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor     = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius  = 22
        v.layer.shadowColor   = UIColor(hexstring_Pane: "#D08040").cgColor
        v.layer.shadowOpacity = 0.16
        v.layer.shadowOffset  = CGSize(width: 0, height: 6)
        v.layer.shadowRadius  = 20
        v.layer.masksToBounds = false
        return v
    }()

    // MARK: - 渐变头部

    /// 渐变头部容器（圆角上半部分）
    private let headerView_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds       = true
        v.layer.cornerRadius  = 22
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private var headerGradient_Pane: CAGradientLayer?

    /// 窗景图标 Emoji
    private let headerIconLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "🪟"
        l.font = .systemFont(ofSize: 20)
        return l
    }()

    /// 月份标题（斜体衬线字体增加质感）
    private let monthLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = UIFont(name: "Georgia-BoldItalic", size: 19) ?? .systemFont(ofSize: 19, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 年份胶囊标签
    private let yearChip_Pane: UILabel = {
        let l = UILabel()
        l.font               = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor          = UIColor.white.alpha_Pane(0.9)
        l.backgroundColor    = UIColor.white.alpha_Pane(0.22)
        l.layer.cornerRadius = 9
        l.clipsToBounds      = true
        l.textAlignment      = .center
        return l
    }()

    /// 连续打卡天数徽章（🔥 Nd）
    private let streakBadge_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.alpha_Pane(0.22)
        v.layer.cornerRadius = 12
        v.clipsToBounds      = true
        return v
    }()

    /// 徽章文字标签
    private let streakLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 11, weight: .bold)
        l.textColor     = .white
        l.textAlignment = .center
        return l
    }()

    /// 上一月按钮（半透明圆形）
    private let prevButton_Pane: UIButton = {
        let b   = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.alpha_Pane(0.22)
        b.layer.cornerRadius = 15
        return b
    }()

    /// 下一月按钮（半透明圆形）
    private let nextButton_Pane: UIButton = {
        let b   = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "chevron.right", withConfiguration: cfg), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.alpha_Pane(0.22)
        b.layer.cornerRadius = 15
        return b
    }()

    // MARK: - 星期行 & 日格网格

    /// 星期名称行
    private let weekdayRow_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .horizontal
        sv.distribution = .fillEqually
        sv.spacing      = 3
        return sv
    }()

    /// 星期行下方细分割线
    private let weekdayDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.divider_Pane
        v.layer.cornerRadius = 0.25
        return v
    }()

    /// 日格网格容器（6行×7列）
    private let gridContainer_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .vertical
        sv.spacing      = 3
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: - 底部统计区

    private let statsRow_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .horizontal
        sv.spacing   = 8
        sv.alignment = .center
        return sv
    }()

    private let statsLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 11, weight: .medium)
        l.textColor     = ColorConfig_Pane.textSecondary_Pane
        l.numberOfLines = 1
        return l
    }()

    private let legendStack_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .horizontal
        sv.spacing   = 4
        sv.alignment = .center
        return sv
    }()

    // MARK: - 状态属性

    private var displayYear_Pane:  Int = Calendar.current.component(.year,  from: Date())
    private var displayMonth_Pane: Int = Calendar.current.component(.month, from: Date())

    /// 各日打卡次数字典（键为日 1-31，值为打卡次数）
    private var checkInByDay_Pane: [Int: Int] = [:]

    private var dayViews_Pane:      [HomeDayView_Pane] = []
    private var firstWeekday_Pane:  Int = 0
    private var daysInMonth_Pane:   Int = 30

    // MARK: - 回调

    /// 月份切换回调 (year, month)
    var onMonthChange_Pane: ((Int, Int) -> Void)?

    /// 日期点击回调 (day: 1-31)
    var onDayTapped_Pane: ((Int) -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        headerGradient_Pane?.frame = headerView_Pane.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        backgroundColor = .clear
        contentView.addSubview(cardView_Pane)
        cardView_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16))
        }
        buildHeader_Pane()
        buildWeekdayRow_Pane()
        buildGrid_Pane()
        buildFooter_Pane()

        prevButton_Pane.addTarget(self, action: #selector(prevMonthTapped_Pane), for: .touchUpInside)
        nextButton_Pane.addTarget(self, action: #selector(nextMonthTapped_Pane), for: .touchUpInside)
    }

    // MARK: 头部

    private func buildHeader_Pane() {
        cardView_Pane.addSubview(headerView_Pane)
        headerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(68)
        }

        // 暖琥珀 → 珊瑚渐变层
        let gl_pane         = CAGradientLayer()
        gl_pane.colors      = [headerColorStart_Pane.cgColor, headerColorEnd_Pane.cgColor]
        gl_pane.startPoint  = CGPoint(x: 0, y: 0)
        gl_pane.endPoint    = CGPoint(x: 1, y: 1)
        headerView_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane

        // 装饰圆点（散布于头部营造景深感）
        addHeaderDecorations_Pane()

        // 左/右翻页按钮约束
        prevButton_Pane.snp.makeConstraints { $0.width.height.equalTo(30) }
        nextButton_Pane.snp.makeConstraints { $0.width.height.equalTo(30) }

        // 年份胶囊约束
        yearChip_Pane.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.width.greaterThanOrEqualTo(44)
        }

        // 连续打卡徽章（Streak Badge）
        streakBadge_Pane.addSubview(streakLabel_Pane)
        streakLabel_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        // 中部信息堆叠：图标 + 月份 + 年份胶囊
        let centerStack_pane = UIStackView(arrangedSubviews: [
            headerIconLabel_Pane, monthLabel_Pane, yearChip_Pane
        ])
        centerStack_pane.axis      = .horizontal
        centerStack_pane.spacing   = 6
        centerStack_pane.alignment = .center

        // 头部行：左箭头 | 中部信息 | Streak 徽章 | 右箭头
        let headerRow_pane = UIStackView(arrangedSubviews: [
            prevButton_Pane, centerStack_pane, UIView(), streakBadge_Pane, nextButton_Pane
        ])
        headerRow_pane.axis         = .horizontal
        headerRow_pane.alignment    = .center
        headerRow_pane.spacing      = 8
        // 弹性空白使中部居中、徽章靠右
        headerRow_pane.arrangedSubviews[2].setContentHuggingPriority(.defaultLow, for: .horizontal)

        headerView_Pane.addSubview(headerRow_pane)
        headerRow_pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }

    /// 添加头部装饰圆点（营造层次感和温暖视觉）
    private func addHeaderDecorations_Pane() {
        // 左上大圆（主装饰）
        let bigCircle_pane = makeHeaderDot_Pane(alpha: 0.12, size: 72)
        headerView_Pane.insertSubview(bigCircle_pane, at: 1)
        bigCircle_pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-22)
            $0.leading.equalToSuperview().offset(-18)
            $0.width.height.equalTo(72)
        }

        // 右上中圆
        let midCircle_pane = makeHeaderDot_Pane(alpha: 0.09, size: 50)
        headerView_Pane.insertSubview(midCircle_pane, at: 1)
        midCircle_pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-16)
            $0.trailing.equalToSuperview().offset(12)
            $0.width.height.equalTo(50)
        }

        // 左下小圆
        let smallCircleL_pane = makeHeaderDot_Pane(alpha: 0.07, size: 34)
        headerView_Pane.insertSubview(smallCircleL_pane, at: 1)
        smallCircleL_pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(44)
            $0.width.height.equalTo(34)
        }

        // 右下小圆
        let smallCircleR_pane = makeHeaderDot_Pane(alpha: 0.10, size: 28)
        headerView_Pane.insertSubview(smallCircleR_pane, at: 1)
        smallCircleR_pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-50)
            $0.width.height.equalTo(28)
        }

        // 顶部细长装饰横条
        let stripe_pane = UIView()
        stripe_pane.backgroundColor    = UIColor.white.alpha_Pane(0.06)
        stripe_pane.layer.cornerRadius = 1.5
        headerView_Pane.insertSubview(stripe_pane, at: 1)
        stripe_pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(100)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(3)
        }
    }

    /// 创建半透明白色装饰圆点
    /// - Parameters:
    ///   - alpha: 透明度（0-1）
    ///   - size:  圆点直径
    private func makeHeaderDot_Pane(alpha: CGFloat, size: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor    = UIColor.white.alpha_Pane(alpha)
        v.layer.cornerRadius = size / 2
        return v
    }

    // MARK: 星期行

    private func buildWeekdayRow_Pane() {
        for (idx_pane, title_pane) in weekdayTitles_Pane.enumerated() {
            let l           = UILabel()
            l.text          = title_pane
            l.textAlignment = .center
            l.font          = .systemFont(ofSize: 9, weight: .bold)
            // 周末用暖橙色，工作日用次级文本色
            l.textColor = (idx_pane == 0 || idx_pane == 6)
                ? UIColor(hexstring_Pane: "#E07030")
                : ColorConfig_Pane.textSecondary_Pane
            weekdayRow_Pane.addArrangedSubview(l)
        }

        cardView_Pane.addSubview(weekdayRow_Pane)
        weekdayRow_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(14)
        }

        // 星期行下方细分割线（暖米色）
        cardView_Pane.addSubview(weekdayDivider_Pane)
        weekdayDivider_Pane.snp.makeConstraints {
            $0.top.equalTo(weekdayRow_Pane.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(0.5)
        }
    }

    // MARK: 日格网格

    private func buildGrid_Pane() {
        for rowIdx_pane in 0..<6 {
            let rowStack_pane          = UIStackView()
            rowStack_pane.axis         = .horizontal
            rowStack_pane.distribution = .fillEqually
            rowStack_pane.spacing      = 3

            for colIdx_pane in 0..<7 {
                let dayView_pane = HomeDayView_Pane()
                let idx_pane     = rowIdx_pane * 7 + colIdx_pane
                dayView_pane.onTap_Pane = { [weak self] in
                    self?.handleDayTap_Pane(at: idx_pane)
                }
                rowStack_pane.addArrangedSubview(dayView_pane)
                dayViews_Pane.append(dayView_pane)
            }
            gridContainer_Pane.addArrangedSubview(rowStack_pane)
        }

        cardView_Pane.addSubview(gridContainer_Pane)
        gridContainer_Pane.snp.makeConstraints {
            $0.top.equalTo(weekdayDivider_Pane.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(6 * 30 + 5 * 3)
        }
    }

    // MARK: 底部统计

    private func buildFooter_Pane() {
        setupLegend_Pane()

        let spacer_pane = UIView()
        spacer_pane.setContentHuggingPriority(.defaultLow, for: .horizontal)

        statsRow_Pane.addArrangedSubview(statsLabel_Pane)
        statsRow_Pane.addArrangedSubview(spacer_pane)
        statsRow_Pane.addArrangedSubview(legendStack_Pane)

        cardView_Pane.addSubview(statsRow_Pane)
        statsRow_Pane.snp.makeConstraints {
            $0.top.equalTo(gridContainer_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(12)
        }
    }

    /// 搭建颜色图例（暖橙色阶 Less → More）
    private func setupLegend_Pane() {
        legendStack_Pane.addArrangedSubview(makeLegendText_Pane("Less"))

        let levels_pane: [UIColor] = [
            ColorConfig_Pane.divider_Pane,
            UIColor(hexstring_Pane: "#FDECC8"),
            UIColor(hexstring_Pane: "#F5A623").alpha_Pane(0.75),
            UIColor(hexstring_Pane: "#E07030")
        ]
        for color_pane in levels_pane {
            let dot_pane              = UIView()
            dot_pane.backgroundColor  = color_pane
            dot_pane.layer.cornerRadius = 3
            dot_pane.snp.makeConstraints { $0.width.height.equalTo(10) }
            legendStack_Pane.addArrangedSubview(dot_pane)
        }
        legendStack_Pane.addArrangedSubview(makeLegendText_Pane("More"))
    }

    /// 创建图例文字标签
    private func makeLegendText_Pane(_ text_pane: String) -> UILabel {
        let l       = UILabel()
        l.text      = text_pane
        l.font      = .systemFont(ofSize: 9, weight: .regular)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }

    // MARK: - 数据配置

    /// 配置日历数据并刷新所有日格
    /// - Parameters:
    ///   - year_pane:         展示年份
    ///   - month_pane:        展示月份（1-12）
    ///   - checkInByDay_pane: 各日打卡次数字典（键为日，值为次数；来自用户模型 userCheckInDates_Pane）
    ///   - streak_pane:       当前连续打卡天数（0 时隐藏徽章）
    func configure_Pane(year_pane: Int,
                        month_pane: Int,
                        checkInByDay_pane: [Int: Int],
                        streak_pane: Int = 0) {
        displayYear_Pane  = year_pane
        displayMonth_Pane = month_pane
        checkInByDay_Pane = checkInByDay_pane

        // 月份名称
        let monthNames_pane = ["January","February","March","April","May","June",
                               "July","August","September","October","November","December"]
        monthLabel_Pane.text = monthNames_pane[max(0, min(11, month_pane - 1))]
        yearChip_Pane.text   = " \(year_pane) "

        // 连续打卡徽章（streak > 0 才显示）
        if streak_pane > 0 {
            streakBadge_Pane.isHidden = false
            streakLabel_Pane.text     = "🔥 \(streak_pane)d"
        } else {
            streakBadge_Pane.isHidden = true
        }

        // 禁止翻到未来月份
        let today_pane     = Date()
        let nowYear_pane   = Calendar.current.component(.year,  from: today_pane)
        let nowMonth_pane  = Calendar.current.component(.month, from: today_pane)
        let isCurrent_pane = (year_pane == nowYear_pane && month_pane == nowMonth_pane)
        nextButton_Pane.isEnabled = !isCurrent_pane
        nextButton_Pane.alpha     = isCurrent_pane ? 0.4 : 1.0

        // 计算月份起始星期和总天数
        let cal_pane   = Calendar.current
        var comps_pane = DateComponents()
        comps_pane.year  = year_pane
        comps_pane.month = month_pane
        comps_pane.day   = 1
        guard let firstDate_pane = cal_pane.date(from: comps_pane) else { return }

        firstWeekday_Pane = cal_pane.component(.weekday, from: firstDate_pane) - 1
        daysInMonth_Pane  = cal_pane.range(of: .day, in: .month, for: firstDate_pane)?.count ?? 30
        let nowDay_pane   = isCurrent_pane ? cal_pane.component(.day, from: today_pane) : -1

        // 刷新 42 个日格（6行 × 7列）
        for i_pane in 0..<42 {
            let dayNum_pane = i_pane - firstWeekday_Pane + 1
            let dv_pane     = dayViews_Pane[i_pane]
            if dayNum_pane >= 1 && dayNum_pane <= daysInMonth_Pane {
                let cnt_pane     = checkInByDay_pane[dayNum_pane] ?? 0
                let isToday_pane = (dayNum_pane == nowDay_pane)
                dv_pane.configure_Pane(day_pane: dayNum_pane, count_pane: cnt_pane, isToday_pane: isToday_pane)
            } else {
                dv_pane.configure_Pane(day_pane: 0, count_pane: 0, isToday_pane: false)
            }
        }

        // 底部统计文字
        let total_pane  = checkInByDay_pane.values.reduce(0, +)
        let active_pane = checkInByDay_pane.keys.count
        if total_pane > 0 {
            statsLabel_Pane.text = "✦ \(active_pane) days · \(total_pane) check-ins"
        } else {
            statsLabel_Pane.text = "No check-ins this month"
        }
    }

    // MARK: - 日格点击

    /// 根据 grid index 计算日期并触发回调
    private func handleDayTap_Pane(at index_pane: Int) {
        let dayNum_pane = index_pane - firstWeekday_Pane + 1
        guard dayNum_pane >= 1, dayNum_pane <= daysInMonth_Pane else { return }
        let gen_pane = UIImpactFeedbackGenerator(style: .light)
        gen_pane.impactOccurred()
        dayViews_Pane[index_pane].animateTap_Pane()
        onDayTapped_Pane?(dayNum_pane)
    }

    // MARK: - 月份翻页

    @objc private func prevMonthTapped_Pane() {
        var y_pane = displayYear_Pane, m_pane = displayMonth_Pane - 1
        if m_pane < 1 { m_pane = 12; y_pane -= 1 }
        onMonthChange_Pane?(y_pane, m_pane)
    }

    @objc private func nextMonthTapped_Pane() {
        var y_pane = displayYear_Pane, m_pane = displayMonth_Pane + 1
        if m_pane > 12 { m_pane = 1; y_pane += 1 }
        onMonthChange_Pane?(y_pane, m_pane)
    }
}

// MARK: - 日历日格视图

/// 单个日格视图：暖色热力色块 + 今日金边高亮 + 点击回调
/// 核心作用：根据打卡次数渲染不同深度的暖橙色阶；今日使用金色边框 + 暖底色强调显示
private class HomeDayView_Pane: UIView {

    // MARK: 点击回调

    var onTap_Pane: (() -> Void)?

    // MARK: UI

    /// 日期数字标签
    private let dayLabel_Pane: UILabel = {
        let l           = UILabel()
        l.textAlignment = .center
        l.font          = .systemFont(ofSize: 10, weight: .semibold)
        return l
    }()

    /// 今日指示底部小点
    private let todayDot_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor(hexstring_Pane: "#F5A623")
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 7
        clipsToBounds      = true
        addSubview(dayLabel_Pane)
        addSubview(todayDot_Pane)

        dayLabel_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        todayDot_Pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(3)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(4)
        }

        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(tapped_Pane))
        addGestureRecognizer(tap_pane)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置日格显示状态
    /// - Parameters:
    ///   - day_pane:     日期数字（0 表示空格占位）
    ///   - count_pane:   该日打卡次数（0、1、2、3+）
    ///   - isToday_pane: 是否是今日
    func configure_Pane(day_pane: Int, count_pane: Int, isToday_pane: Bool) {
        layer.borderWidth = 0
        todayDot_Pane.isHidden = true

        // 空格占位（月首/月尾的填充格）
        guard day_pane > 0 else {
            backgroundColor           = .clear
            dayLabel_Pane.text        = ""
            isUserInteractionEnabled  = false
            return
        }

        isUserInteractionEnabled = true
        dayLabel_Pane.text       = "\(day_pane)"

        // 暖橙色阶热力着色
        switch count_pane {
        case 0:
            // 未打卡：极浅暖底色 + 浅边框
            backgroundColor         = ColorConfig_Pane.backgroundPrimary_Pane
            dayLabel_Pane.textColor = ColorConfig_Pane.textPlaceholder_Pane
            layer.borderWidth       = 0.5
            layer.borderColor       = ColorConfig_Pane.divider_Pane.cgColor
        case 1:
            // 已打卡：浅杏黄填充
            backgroundColor         = UIColor(hexstring_Pane: "#FDECC8")
            dayLabel_Pane.textColor = UIColor(hexstring_Pane: "#C06010")
            layer.borderWidth       = 0
        case 2:
            // 打卡2次：中度琥珀橙
            backgroundColor         = UIColor(hexstring_Pane: "#F5A623").alpha_Pane(0.75)
            dayLabel_Pane.textColor = .white
            layer.borderWidth       = 0
        default:
            // 打卡3次以上：深砖橙
            backgroundColor         = UIColor(hexstring_Pane: "#E07030")
            dayLabel_Pane.textColor = .white
            layer.borderWidth       = 0
        }

        // 今日特殊样式：金色边框 + 底部指示点
        if isToday_pane {
            layer.borderWidth = 2.0
            layer.borderColor = UIColor(hexstring_Pane: "#F5A623").cgColor
            todayDot_Pane.isHidden = false
            // 今日未打卡时给予特别暖色底
            if count_pane == 0 {
                backgroundColor         = UIColor(hexstring_Pane: "#FFF3E0")
                dayLabel_Pane.textColor = UIColor(hexstring_Pane: "#E07020")
                layer.borderColor       = UIColor(hexstring_Pane: "#F5A623").cgColor
            }
        }
    }

    /// 点击弹跳动画
    func animateTap_Pane() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        }) { _ in
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 6,
                animations: { self.transform = .identity }
            )
        }
    }

    @objc private func tapped_Pane() {
        onTap_Pane?()
    }
}
