/// CheckinHistory_base_one.swift
///
/// 打卡历史详情页
/// 功能：展示全量打卡记录，顶部渐变 Banner 展示连续打卡信息，
///       三张统计迷你卡，下方按月分组日历网格（包含打卡进度条）。
/// 设计：渐变 Banner + 浮层统计卡 + 白色月历卡片 + 渐变打卡圆点。
/// 架构：UIScrollView 嵌套：顶部统计区（纯 UIView）+ UICollectionView（月历）。

import UIKit
import SnapKit

// MARK: - 数据模型

/// 单个月份打卡数据
private struct MonthCheckinData_Base_one {
    let yearMonth_base_one: String       // "yyyy-MM"
    let daysInMonth_base_one: Int        // 该月总天数
    let checkedSet_base_one: Set<String> // 已打卡日集合（无前导零）
    let firstWeekday_base_one: Int       // ISO：1=周一，7=周日
}

// MARK: - Section Header（月份标题 + 进度条 + 周标签行）

/// Section 补充视图：月份名 + 打卡进度条 + 周标签行
private class CheckinMonthHeaderView_Base_one: UICollectionReusableView {

    // MARK: 月份标题行
    private let monthLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = UIColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1)
        return lb
    }()
    private let rateBadge_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.layer.cornerRadius = 9
        lb.clipsToBounds = true
        return lb
    }()

    // MARK: 进度条
    private let progressBg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Base_one: "#E8F8F7")
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()
    private let progressFill_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()
    private var progressGrad_Base_one: CAGradientLayer?
    private var progressWidthConstraint_Base_one: Constraint?

    // MARK: 周标签行
    private let weekStack_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        ["M","T","W","T","F","S","S"].forEach { d in
            let lb = UILabel()
            lb.text = d
            lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            lb.textColor = UIColor(hexstring_Base_one: "#A0AEC0")
            lb.textAlignment = .center
            sv.addArrangedSubview(lb)
        }
        return sv
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(monthLabel_Base_one)
        addSubview(rateBadge_Base_one)
        addSubview(progressBg_Base_one)
        progressBg_Base_one.addSubview(progressFill_Base_one)
        addSubview(weekStack_Base_one)

        // 进度填充渐变
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Base_one.tidyMint_Base_one.cgColor,
                       UIColor(hexstring_Base_one: "#2D7DD2").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 3
        progressFill_Base_one.layer.insertSublayer(grad, at: 0)
        progressGrad_Base_one = grad

        monthLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(14)
        }
        rateBadge_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalTo(monthLabel_Base_one)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(42)
        }
        progressBg_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.top.equalTo(monthLabel_Base_one.snp.bottom).offset(8)
            make.height.equalTo(5)
        }
        progressFill_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            progressWidthConstraint_Base_one = make.width.equalTo(0).constraint
        }
        weekStack_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(progressBg_Base_one.snp.bottom).offset(10)
            make.height.equalTo(24)
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressGrad_Base_one?.frame = progressFill_Base_one.bounds
    }

    /// 渲染月份 Header
    /// - Parameters:
    ///   - yearMonth_base_one: "yyyy-MM"
    ///   - checkedCount_base_one: 已打卡天数
    ///   - totalDays_base_one: 该月总天数
    func configure_Base_one(yearMonth_base_one: String,
                             checkedCount_base_one: Int,
                             totalDays_base_one: Int) {
        let parts = yearMonth_base_one.components(separatedBy: "-")
        guard parts.count == 2, let month = Int(parts[1]) else {
            monthLabel_Base_one.text = yearMonth_base_one; return
        }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        monthLabel_Base_one.text = "\(fmt.monthSymbols[month - 1]) \(parts[0])"

        // 打卡率徽章
        let rate = totalDays_base_one > 0
            ? Int(round(Double(checkedCount_base_one) / Double(totalDays_base_one) * 100))
            : 0
        rateBadge_Base_one.text = "  \(rate)%  "
        // 根据打卡率变换徽章颜色
        let badgeColor: UIColor
        switch rate {
        case 80...: badgeColor = ColorConfig_Base_one.tidyMint_Base_one
        case 50..<80: badgeColor = ColorConfig_Base_one.tidyGold_Base_one
        default:     badgeColor = UIColor(hexstring_Base_one: "#FC8181")
        }
        rateBadge_Base_one.backgroundColor = badgeColor

        // 进度条宽度（layoutIfNeeded 后生效）
        let ratio = totalDays_base_one > 0
            ? CGFloat(checkedCount_base_one) / CGFloat(totalDays_base_one)
            : 0
        // 用 DispatchQueue 等 frame 确定后更新
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let maxW = self.progressBg_Base_one.bounds.width
            self.progressWidthConstraint_Base_one?.update(offset: maxW * ratio)
        }
    }
}

// MARK: - Cell：单日格子

/// 单日打卡格子 Cell
/// 设计：已打卡（渐变圆 + 外发光）、今日未打卡（描边圆）、普通（纯文字）
/// 关键：configure 只缓存状态并调用 setNeedsLayout，视觉样式在 layoutSubviews 中应用，
///       此时 bounds 已确定，避免 CAGradientLayer frame 为零导致渐变不显示
class CheckinDayCell_Base_one: UICollectionViewCell {

    private let glowView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = false
        return v
    }()
    private let circleView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()
    private let dayLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb.textAlignment = .center
        return lb
    }()
    /// 渐变层（layoutSubviews 时创建，frame 基于真实 bounds）
    private var gradLayer_Base_one: CAGradientLayer?

    /// 状态缓存（configure 时存储，layoutSubviews 时读取渲染）
    private var _day_base_one: String = ""
    private var _isChecked_base_one = false
    private var _isToday_base_one   = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(glowView_Base_one)
        contentView.addSubview(circleView_Base_one)
        circleView_Base_one.addSubview(dayLabel_Base_one)
        glowView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        circleView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        dayLabel_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    /// 缓存状态并触发 layout，实际渲染在 layoutSubviews 中执行（bounds 已确定）
    /// - Parameters:
    ///   - day_base_one: 日字符串；空字符串表示占位格
    ///   - isChecked_base_one: 是否已打卡
    ///   - isToday_base_one: 是否为今日
    func configure_Base_one(day_base_one: String,
                             isChecked_base_one: Bool,
                             isToday_base_one: Bool) {
        _day_base_one       = day_base_one
        _isChecked_base_one = isChecked_base_one
        _isToday_base_one   = isToday_base_one
        dayLabel_Base_one.text = day_base_one
        setNeedsLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _day_base_one       = ""
        _isChecked_base_one = false
        _isToday_base_one   = false
        dayLabel_Base_one.text = ""
    }

    /// bounds 已确定，在此应用渐变 / 描边 / 普通三种视觉状态
    override func layoutSubviews() {
        super.layoutSubviews()
        applyVisualState_Base_one()
    }

    /// 根据缓存状态刷新圆圈样式
    private func applyVisualState_Base_one() {
        // 清除旧状态
        gradLayer_Base_one?.removeFromSuperlayer()
        gradLayer_Base_one = nil
        circleView_Base_one.backgroundColor = .clear
        circleView_Base_one.layer.borderWidth = 0
        circleView_Base_one.layer.borderColor = nil
        glowView_Base_one.layer.shadowOpacity = 0

        guard !_day_base_one.isEmpty else {
            dayLabel_Base_one.textColor = .clear
            return
        }

        if _isChecked_base_one {
            // 已打卡：薄荷 → 深蓝渐变圆 + 外发光
            let grad = CAGradientLayer()
            grad.colors     = [ColorConfig_Base_one.tidyMint_Base_one.cgColor,
                               UIColor(hexstring_Base_one: "#2D7DD2").cgColor]
            grad.startPoint = CGPoint(x: 0, y: 0)
            grad.endPoint   = CGPoint(x: 1, y: 1)
            grad.cornerRadius = 15
            grad.frame = circleView_Base_one.bounds  // bounds 已确定，frame 正确
            circleView_Base_one.layer.insertSublayer(grad, at: 0)
            gradLayer_Base_one = grad
            dayLabel_Base_one.textColor = .white
            glowView_Base_one.layer.shadowColor   = ColorConfig_Base_one.tidyMint_Base_one.cgColor
            glowView_Base_one.layer.shadowOffset  = .zero
            glowView_Base_one.layer.shadowRadius  = 8
            glowView_Base_one.layer.shadowOpacity = 0.45
        } else if _isToday_base_one {
            // 今日未打卡：薄荷底色 + 描边
            circleView_Base_one.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.12)
            circleView_Base_one.layer.borderWidth = 1.5
            circleView_Base_one.layer.borderColor = ColorConfig_Base_one.tidyMint_Base_one.cgColor
            dayLabel_Base_one.textColor = ColorConfig_Base_one.tidyMint_Base_one
        } else {
            // 普通未打卡
            dayLabel_Base_one.textColor = UIColor(hexstring_Base_one: "#718096")
        }
    }
}

// MARK: - 统计迷你卡

/// 单个统计数据迷你卡（图标 + 数字 + 说明文字）
private class StatMiniCard_Base_one: UIView {

    private let iconLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22)
        lb.textAlignment = .center
        return lb
    }()
    private let valueLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    private let titleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb.textAlignment = .center
        lb.textColor = UIColor.white.withAlphaComponent(0.80)
        return lb
    }()
    private var bgGrad_Base_one: CAGradientLayer?

    /// 初始化迷你卡
    /// - Parameters:
    ///   - icon_base_one: emoji 图标字符串
    ///   - gradColors_base_one: 渐变颜色数组（2 个 UIColor）
    init(icon_base_one: String, gradColors_base_one: [UIColor]) {
        super.init(frame: .zero)
        layer.cornerRadius = 16
        clipsToBounds = true

        let grad = CAGradientLayer()
        grad.colors     = gradColors_base_one.map { $0.cgColor }
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = 16
        layer.insertSublayer(grad, at: 0)
        bgGrad_Base_one = grad

        iconLabel_Base_one.text = icon_base_one
        addSubview(iconLabel_Base_one)
        addSubview(valueLabel_Base_one)
        addSubview(titleLabel_Base_one)

        iconLabel_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        valueLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(iconLabel_Base_one.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Base_one.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgGrad_Base_one?.frame = bounds
    }

    /// 更新数字与标题
    /// - Parameters:
    ///   - value_base_one: 数字字符串
    ///   - title_base_one: 说明文字
    ///   - valueColor_base_one: 数字颜色
    func update_Base_one(value_base_one: String, title_base_one: String, valueColor_base_one: UIColor = .white) {
        valueLabel_Base_one.text  = value_base_one
        valueLabel_Base_one.textColor = valueColor_base_one
        titleLabel_Base_one.text  = title_base_one
    }
}

// MARK: - 打卡历史 ViewController

/// 打卡历史详情页
/// 布局：顶部渐变 Banner（含连续天数）→ 三张统计迷你卡 → 月历列表（带进度条）
class CheckinHistory_Base_one: UIViewController {

    // MARK: 复用 ID
    private let kDayCell_Base_one     = "CheckinDayCell_Base_one"
    private let kMonthHeader_Base_one = "CheckinMonthHeader_Base_one"
    private let kSectionBg_Base_one   = "CheckinSectionBg_Base_one"

    // MARK: 数据
    private var monthList_Base_one: [MonthCheckinData_Base_one] = []
    private var totalDays_Base_one     = 0
    private var currentStreak_Base_one = 0
    private var longestStreak_Base_one = 0
    private var thisMonthDays_Base_one = 0

    // MARK: UI 主容器
    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    private let contentView_Base_one = UIView()

    // MARK: 顶部 Banner
    private let bannerView_Base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    private var bannerGrad_Base_one: CAGradientLayer?
    /// Banner 左侧装饰圆
    private let decorCircle1_Base_one = UIView()
    private let decorCircle2_Base_one = UIView()

    private let bannerEmojiLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "🔥"
        lb.font = UIFont.systemFont(ofSize: 40)
        return lb
    }()
    private let bannerStreakValue_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 52, weight: .heavy)
        lb.textColor = .white
        return lb
    }()
    private let bannerStreakUnit_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Day Streak"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb
    }()
    private let bannerTagline_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.75)
        lb.numberOfLines = 1
        return lb
    }()

    // MARK: 三张统计卡
    private let statsRow_Base_one = UIView()
    private lazy var cardTotal_Base_one = StatMiniCard_Base_one(
        icon_base_one: "📅",
        gradColors_base_one: [ColorConfig_Base_one.tidyMint_Base_one,
                               UIColor(hexstring_Base_one: "#2D7DD2")]
    )
    private lazy var cardStreak_Base_one = StatMiniCard_Base_one(
        icon_base_one: "🔥",
        gradColors_base_one: [UIColor(hexstring_Base_one: "#FF6B6B"),
                               UIColor(hexstring_Base_one: "#FF8E53")]
    )
    private lazy var cardMonth_Base_one = StatMiniCard_Base_one(
        icon_base_one: "🌿",
        gradColors_base_one: [UIColor(hexstring_Base_one: "#9F7AEA"),
                               UIColor(hexstring_Base_one: "#B794F6")]
    )

    // MARK: 月历 CollectionView
    private var collectionView_Base_one: UICollectionView!
    /// CollectionView 高度约束（动态更新）
    private var cvHeight_Base_one: Constraint?

    // MARK: 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Base_one: "#F5F7FA")
        setupNavBar_Base_one()
        setupScrollView_Base_one()
        setupBanner_Base_one()
        setupStatsRow_Base_one()
        prepareData_Base_one()
        setupCollectionView_Base_one()
        fillData_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        applyNavAppearance_Base_one()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerGrad_Base_one?.frame = bannerView_Base_one.bounds
    }

    // MARK: 导航栏

    private func applyNavAppearance_Base_one() {
        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .white
        ap.shadowColor = .clear
        ap.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance   = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.tintColor = ColorConfig_Base_one.tidyMint_Base_one
    }

    private func setupNavBar_Base_one() {
        title = "Check-In History"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
            style: .plain, target: self, action: #selector(onBack_Base_one)
        )
    }

    @objc private func onBack_Base_one() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: 滚动容器

    private func setupScrollView_Base_one() {
        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentView_Base_one)
        // 从 view.top（0）开始，Banner 延伸至导航栏后方，消除顶部空白间距
        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: Banner 顶部

    /// 构建渐变 Banner（连续打卡展示区）
    /// Banner 从 view.top（0）延伸，覆盖导航栏/状态栏后方；内容区通过 safeAreaLayoutGuide 避开遮挡
    private func setupBanner_Base_one() {
        contentView_Base_one.addSubview(bannerView_Base_one)
        // Banner 高度 = 导航栏+状态栏区域 + 内容区域（safeArea 内容高约 130）
        bannerView_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }

        // 渐变背景（薄荷 → 深蓝）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Base_one.tidyMint_Base_one.cgColor,
                       UIColor(hexstring_Base_one: "#1A5276").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        bannerView_Base_one.layer.insertSublayer(grad, at: 0)
        bannerGrad_Base_one = grad

        // 装饰圆 A（右下角大圆）
        decorCircle1_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        decorCircle1_Base_one.layer.cornerRadius = 80
        bannerView_Base_one.addSubview(decorCircle1_Base_one)
        decorCircle1_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(40)
            make.width.height.equalTo(160)
        }

        // 装饰圆 B（左上角小圆）
        decorCircle2_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        decorCircle2_Base_one.layer.cornerRadius = 50
        bannerView_Base_one.addSubview(decorCircle2_Base_one)
        decorCircle2_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(100)
        }

        bannerView_Base_one.addSubview(bannerEmojiLabel_Base_one)
        bannerView_Base_one.addSubview(bannerStreakValue_Base_one)
        bannerView_Base_one.addSubview(bannerStreakUnit_Base_one)
        bannerView_Base_one.addSubview(bannerTagline_Base_one)

        // 内容区紧贴 safeAreaLayoutGuide.top，自动适配导航栏 + 状态栏高度
        bannerEmojiLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        bannerStreakValue_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(bannerEmojiLabel_Base_one.snp.trailing).offset(10)
            make.centerY.equalTo(bannerEmojiLabel_Base_one)
        }
        bannerStreakUnit_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(bannerEmojiLabel_Base_one)
            make.top.equalTo(bannerEmojiLabel_Base_one.snp.bottom).offset(8)
        }
        bannerTagline_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(bannerEmojiLabel_Base_one)
            make.top.equalTo(bannerStreakUnit_Base_one.snp.bottom).offset(6)
        }

        // Banner 底部白色圆角过渡
        let roundMask_Base_one = UIView()
        roundMask_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#F5F7FA")
        roundMask_Base_one.layer.cornerRadius = 24
        roundMask_Base_one.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView_Base_one.addSubview(roundMask_Base_one)
        roundMask_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bannerView_Base_one)
            make.height.equalTo(30)
        }
    }

    // MARK: 统计卡行

    /// 构建三张统计迷你卡（悬浮在 Banner 底部）
    private func setupStatsRow_Base_one() {
        contentView_Base_one.addSubview(statsRow_Base_one)
        statsRow_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(bannerView_Base_one.snp.bottom).offset(-44)
        }

        [cardTotal_Base_one, cardStreak_Base_one, cardMonth_Base_one].forEach {
            statsRow_Base_one.addSubview($0)
            // 添加轻微阴影
            $0.layer.shadowColor  = UIColor.black.withAlphaComponent(0.12).cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowRadius = 10
            $0.layer.shadowOpacity = 1
            $0.clipsToBounds = false
        }
        statsRow_Base_one.snp.makeConstraints { make in
            make.height.equalTo(cardTotal_Base_one)
        }
        cardTotal_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        cardStreak_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(cardTotal_Base_one.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cardTotal_Base_one)
        }
        cardMonth_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(cardStreak_Base_one.snp.trailing).offset(10)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(cardStreak_Base_one)
        }
    }

    // MARK: 数据填充

    /// 将统计数据渲染到 Banner 和统计卡
    private func fillData_Base_one() {
        bannerStreakValue_Base_one.text = "\(currentStreak_Base_one)"
        bannerTagline_Base_one.text = motivationalText_Base_one(streak_base_one: currentStreak_Base_one)

        cardTotal_Base_one.update_Base_one(value_base_one: "\(totalDays_Base_one)",
                                            title_base_one: "Total Days")
        cardStreak_Base_one.update_Base_one(value_base_one: "\(longestStreak_Base_one)",
                                             title_base_one: "Best Streak")
        cardMonth_Base_one.update_Base_one(value_base_one: "\(thisMonthDays_Base_one)",
                                            title_base_one: "This Month")
    }

    /// 根据连续天数返回激励语
    /// - Parameter streak_base_one: 当前连续天数
    /// - Returns: 激励文字
    private func motivationalText_Base_one(streak_base_one: Int) -> String {
        switch streak_base_one {
        case 0:         return "Start your streak today!"
        case 1...3:     return "Great start! Keep it up 🌱"
        case 4...7:     return "One week? You're on fire! 🔥"
        case 8...14:    return "Two weeks strong! Amazing 💪"
        case 15...30:   return "A month of dedication! 🏆"
        default:        return "Unstoppable! Legend level 🌟"
        }
    }

    // MARK: 数据准备

    /// 从 ViewModel 读取所有打卡记录，按月分组并计算统计值
    private func prepareData_Base_one() {
        let allDates = UserViewModel_Base_one.shared_Base_one.getAllCheckinDates_Base_one()
        totalDays_Base_one     = allDates.count
        currentStreak_Base_one = UserViewModel_Base_one.shared_Base_one.getCheckinStreak_Base_one()
        longestStreak_Base_one = calcLongestStreak_Base_one(dates_base_one: allDates)

        // 计算本月打卡数
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM"
        let curYM = fmt.string(from: Date())
        thisMonthDays_Base_one = allDates.filter { $0.hasPrefix(curYM) }.count

        // 按 "yyyy-MM" 分组
        var grouped: [String: Set<String>] = [:]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for dateStr in allDates {
            let parts = dateStr.components(separatedBy: "-")
            guard parts.count == 3, let dayInt = Int(parts[2]) else { continue }
            let ym = "\(parts[0])-\(parts[1])"
            grouped[ym, default: []].insert("\(dayInt)")
        }

        let cal = Calendar.current
        monthList_Base_one = grouped.keys.sorted(by: >).compactMap { ym in
            let parts = ym.components(separatedBy: "-")
            guard parts.count == 2,
                  let firstDay = df.date(from: "\(ym)-01") else { return nil }
            let daysInMonth  = cal.range(of: .day, in: .month, for: firstDay)!.count
            let rawWeekday   = cal.component(.weekday, from: firstDay)
            let isoWeekday   = (rawWeekday == 1) ? 7 : (rawWeekday - 1)
            return MonthCheckinData_Base_one(
                yearMonth_base_one:   ym,
                daysInMonth_base_one: daysInMonth,
                checkedSet_base_one:  grouped[ym] ?? [],
                firstWeekday_base_one: isoWeekday
            )
        }
    }

    /// 计算历史最长连续打卡天数
    private func calcLongestStreak_Base_one(dates_base_one: [String]) -> Int {
        guard !dates_base_one.isEmpty else { return 0 }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let sorted = dates_base_one.sorted()
        guard let first = fmt.date(from: sorted[0]) else { return 0 }
        var maxS = 1, cur = 1, prev = first
        for i in 1..<sorted.count {
            guard let d = fmt.date(from: sorted[i]) else { continue }
            let diff = Calendar.current.dateComponents([.day], from: prev, to: d).day ?? 0
            if diff == 1      { cur += 1; maxS = max(maxS, cur) }
            else if diff > 1  { cur = 1 }
            prev = d
        }
        return maxS
    }

    // MARK: CollectionView

    private func setupCollectionView_Base_one() {
        collectionView_Base_one = UICollectionView(frame: .zero,
                                                    collectionViewLayout: makeLayout_Base_one())
        collectionView_Base_one.backgroundColor = .clear
        collectionView_Base_one.isScrollEnabled = false  // 由外层 scrollView 滚动
        collectionView_Base_one.dataSource = self

        collectionView_Base_one.register(CheckinDayCell_Base_one.self,
                                          forCellWithReuseIdentifier: kDayCell_Base_one)
        collectionView_Base_one.register(CheckinMonthHeaderView_Base_one.self,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: kMonthHeader_Base_one)
        // decoration view 由 layout 注册，不在此处注册 Cell

        contentView_Base_one.addSubview(collectionView_Base_one)
        collectionView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            cvHeight_Base_one = make.height.equalTo(100).constraint
        }

        // 布局后动态更新 CollectionView 高度
        collectionView_Base_one.layoutIfNeeded()
        updateCVHeight_Base_one()
    }

    /// 强制 CollectionView 高度与内容一致（因 isScrollEnabled=false）
    private func updateCVHeight_Base_one() {
        collectionView_Base_one.layoutIfNeeded()
        cvHeight_Base_one?.update(offset: collectionView_Base_one.contentSize.height)
    }

    private func makeLayout_Base_one() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16

        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] _, _ in
            self?.makeCalendarSection_Base_one()
        }, configuration: config)

        // 注册 Section 背景 decoration view
        layout.register(CheckinSectionBgView_Base_one.self,
                        forDecorationViewOfKind: kSectionBg_Base_one)
        return layout
    }

    private func makeCalendarSection_Base_one() -> NSCollectionLayoutSection {
        let cellW = (UIScreen.main.bounds.width - 32 - 6 * 4) / 7
        let item  = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .absolute(cellW), heightDimension: .absolute(cellW))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(cellW)),
            subitems: Array(repeating: item, count: 7)
        )
        group.interItemSpacing = .fixed(4)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 20, bottom: 16, trailing: 20)
        section.interGroupSpacing = 4

        // Section Header（月份名 + 进度条 + 周标签）高度 76
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .absolute(76))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        // 白色圆角卡片背景
        let bgDecor = NSCollectionLayoutDecorationItem.background(elementKind: kSectionBg_Base_one)
        bgDecor.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        section.decorationItems = [bgDecor]

        return section
    }
}

// MARK: - Section 背景 Decoration View

/// 月份 Section 白色圆角卡片背景
private class CheckinSectionBgView_Base_one: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        clipsToBounds = false
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

// MARK: - UICollectionViewDataSource

extension CheckinHistory_Base_one: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        monthList_Base_one.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let data   = monthList_Base_one[section]
        let offset = data.firstWeekday_base_one - 1
        return offset + data.daysInMonth_base_one
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: kDayCell_Base_one, for: indexPath
        ) as! CheckinDayCell_Base_one

        let data   = monthList_Base_one[indexPath.section]
        let offset = data.firstWeekday_base_one - 1

        guard indexPath.item >= offset else {
            cell.configure_Base_one(day_base_one: "", isChecked_base_one: false, isToday_base_one: false)
            return cell
        }

        let dayNum   = indexPath.item - offset + 1
        let dayStr   = "\(dayNum)"
        let isChecked = data.checkedSet_base_one.contains(dayStr)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let todayStr    = df.string(from: Date())
        let cellDateStr = "\(data.yearMonth_base_one)-\(String(format: "%02d", dayNum))"
        let isToday     = (cellDateStr == todayStr)

        cell.configure_Base_one(day_base_one: dayStr,
                                 isChecked_base_one: isChecked,
                                 isToday_base_one: isToday)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: kMonthHeader_Base_one,
            for: indexPath
        ) as! CheckinMonthHeaderView_Base_one
        let data = monthList_Base_one[indexPath.section]
        header.configure_Base_one(yearMonth_base_one: data.yearMonth_base_one,
                                   checkedCount_base_one: data.checkedSet_base_one.count,
                                   totalDays_base_one: data.daysInMonth_base_one)
        return header
    }
}
