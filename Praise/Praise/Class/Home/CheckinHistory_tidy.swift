/// CheckinHistory_tidy.swift
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
private struct MonthCheckinData_Tidy {
    let yearMonth_tidy: String       // "yyyy-MM"
    let daysInMonth_tidy: Int        // 该月总天数
    let checkedSet_tidy: Set<String> // 已打卡日集合（无前导零）
    let firstWeekday_tidy: Int       // ISO：1=周一，7=周日
}

// MARK: - Section Header（月份标题 + 进度条 + 周标签行）

/// Section 补充视图：月份名 + 打卡进度条 + 周标签行
private class CheckinMonthHeaderView_Tidy: UICollectionReusableView {

    // MARK: 月份标题行
    private let monthLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = UIColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1)
        return lb
    }()
    private let rateBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.layer.cornerRadius = 9
        lb.clipsToBounds = true
        return lb
    }()

    // MARK: 进度条
    private let progressBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#E8F8F7")
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()
    private let progressFill_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()
    private var progressGrad_Tidy: CAGradientLayer?
    private var progressWidthConstraint_Tidy: Constraint?

    // MARK: 周标签行
    private let weekStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        ["M","T","W","T","F","S","S"].forEach { d in
            let lb = UILabel()
            lb.text = d
            lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            lb.textColor = UIColor(hexstring_Tidy: "#A0AEC0")
            lb.textAlignment = .center
            sv.addArrangedSubview(lb)
        }
        return sv
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(monthLabel_Tidy)
        addSubview(rateBadge_Tidy)
        addSubview(progressBg_Tidy)
        progressBg_Tidy.addSubview(progressFill_Tidy)
        addSubview(weekStack_Tidy)

        // 进度填充渐变
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                       ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 3
        progressFill_Tidy.layer.insertSublayer(grad, at: 0)
        progressGrad_Tidy = grad

        monthLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(14)
        }
        rateBadge_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalTo(monthLabel_Tidy)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(42)
        }
        progressBg_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.top.equalTo(monthLabel_Tidy.snp.bottom).offset(8)
            make.height.equalTo(5)
        }
        progressFill_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            progressWidthConstraint_Tidy = make.width.equalTo(0).constraint
        }
        weekStack_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(progressBg_Tidy.snp.bottom).offset(10)
            make.height.equalTo(24)
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressGrad_Tidy?.frame = progressFill_Tidy.bounds
    }

    /// 渲染月份 Header
    /// - Parameters:
    ///   - yearMonth_tidy: "yyyy-MM"
    ///   - checkedCount_tidy: 已打卡天数
    ///   - totalDays_tidy: 该月总天数
    func configure_Tidy(yearMonth_tidy: String,
                             checkedCount_tidy: Int,
                             totalDays_tidy: Int) {
        let parts = yearMonth_tidy.components(separatedBy: "-")
        guard parts.count == 2, let month = Int(parts[1]) else {
            monthLabel_Tidy.text = yearMonth_tidy; return
        }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        monthLabel_Tidy.text = "\(fmt.monthSymbols[month - 1]) \(parts[0])"

        // 打卡率徽章
        let rate = totalDays_tidy > 0
            ? Int(round(Double(checkedCount_tidy) / Double(totalDays_tidy) * 100))
            : 0
        rateBadge_Tidy.text = "  \(rate)%  "
        // 根据打卡率变换徽章颜色
        let badgeColor: UIColor
        switch rate {
        case 80...: badgeColor = ColorConfig_Tidy.tidyMint_Tidy
        case 50..<80: badgeColor = ColorConfig_Tidy.tidyGold_Tidy
        default:     badgeColor = ColorConfig_Tidy.tidyWarm_Tidy
        }
        rateBadge_Tidy.backgroundColor = badgeColor

        // 进度条宽度（layoutIfNeeded 后生效）
        let ratio = totalDays_tidy > 0
            ? CGFloat(checkedCount_tidy) / CGFloat(totalDays_tidy)
            : 0
        // 用 DispatchQueue 等 frame 确定后更新
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let maxW = self.progressBg_Tidy.bounds.width
            self.progressWidthConstraint_Tidy?.update(offset: maxW * ratio)
        }
    }
}

// MARK: - Cell：单日格子

/// 单日打卡格子 Cell
/// 设计：已打卡（渐变圆 + 外发光）、今日未打卡（描边圆）、普通（纯文字）
/// 关键：configure 只缓存状态并调用 setNeedsLayout，视觉样式在 layoutSubviews 中应用，
///       此时 bounds 已确定，避免 CAGradientLayer frame 为零导致渐变不显示
class CheckinDayCell_Tidy: UICollectionViewCell {

    private let glowView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = false
        return v
    }()
    private let circleView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()
    private let dayLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb.textAlignment = .center
        return lb
    }()
    /// 渐变层（layoutSubviews 时创建，frame 基于真实 bounds）
    private var gradLayer_Tidy: CAGradientLayer?

    /// 状态缓存（configure 时存储，layoutSubviews 时读取渲染）
    private var _day_tidy: String = ""
    private var _isChecked_tidy = false
    private var _isToday_tidy   = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(glowView_Tidy)
        contentView.addSubview(circleView_Tidy)
        circleView_Tidy.addSubview(dayLabel_Tidy)
        glowView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        circleView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        dayLabel_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    /// 缓存状态并触发 layout，实际渲染在 layoutSubviews 中执行（bounds 已确定）
    /// - Parameters:
    ///   - day_tidy: 日字符串；空字符串表示占位格
    ///   - isChecked_tidy: 是否已打卡
    ///   - isToday_tidy: 是否为今日
    func configure_Tidy(day_tidy: String,
                             isChecked_tidy: Bool,
                             isToday_tidy: Bool) {
        _day_tidy       = day_tidy
        _isChecked_tidy = isChecked_tidy
        _isToday_tidy   = isToday_tidy
        dayLabel_Tidy.text = day_tidy
        applyVisualState_Tidy()
        /// 延迟一个 RunLoop 再次应用，保证渐变图层在 bounds 确定后正确渲染
        DispatchQueue.main.async { [weak self] in
            self?.applyVisualState_Tidy()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _day_tidy       = ""
        _isChecked_tidy = false
        _isToday_tidy   = false
        dayLabel_Tidy.text = ""
        gradLayer_Tidy?.removeFromSuperlayer()
        gradLayer_Tidy = nil
        circleView_Tidy.backgroundColor = .clear
        circleView_Tidy.layer.borderWidth = 0
        dayLabel_Tidy.textColor = UIColor(hexstring_Tidy: "#718096")
        glowView_Tidy.layer.shadowOpacity = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 尺寸变化时同步渐变图层帧
        if let grad = gradLayer_Tidy {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            grad.frame = circleView_Tidy.bounds
            CATransaction.commit()
        }
    }

    /// 根据缓存状态刷新圆圈样式
    private func applyVisualState_Tidy() {
        // 清除旧渐变图层
        gradLayer_Tidy?.removeFromSuperlayer()
        gradLayer_Tidy = nil
        circleView_Tidy.backgroundColor = .clear
        circleView_Tidy.layer.borderWidth = 0
        circleView_Tidy.layer.borderColor = nil
        glowView_Tidy.layer.shadowOpacity = 0

        guard !_day_tidy.isEmpty else {
            dayLabel_Tidy.textColor = .clear
            return
        }

        if _isChecked_tidy {
            /// 已打卡：薄荷实色圆 + 外发光
            /// 使用 backgroundColor 代替渐变图层，避免 CAGradientLayer frame 时序问题
            circleView_Tidy.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
            dayLabel_Tidy.textColor = .white
            glowView_Tidy.layer.shadowColor   = ColorConfig_Tidy.tidyMint_Tidy.cgColor
            glowView_Tidy.layer.shadowOffset  = .zero
            glowView_Tidy.layer.shadowRadius  = 8
            glowView_Tidy.layer.shadowOpacity = 0.45

            /// 叠加渐变光泽：仅在 bounds 确定后（宽度 > 0）创建，避免零尺寸图层
            if circleView_Tidy.bounds.width > 0 {
                let grad = CAGradientLayer()
                grad.colors     = [UIColor.white.withValues(alpha: 0.35).cgColor,
                                   UIColor.clear.cgColor]
                grad.startPoint = CGPoint(x: 0, y: 0)
                grad.endPoint   = CGPoint(x: 1, y: 1)
                grad.cornerRadius = 15
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                grad.frame = circleView_Tidy.bounds
                circleView_Tidy.layer.insertSublayer(grad, at: 0)
                CATransaction.commit()
                gradLayer_Tidy = grad
            }
        } else if _isToday_tidy {
            /// 今日未打卡：薄荷淡底色 + 描边
            circleView_Tidy.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy.withValues(alpha: 0.12)
            circleView_Tidy.layer.borderWidth = 1.5
            circleView_Tidy.layer.borderColor = ColorConfig_Tidy.tidyMint_Tidy.cgColor
            dayLabel_Tidy.textColor = ColorConfig_Tidy.tidyMint_Tidy
        } else {
            /// 普通未打卡
            dayLabel_Tidy.textColor = UIColor(hexstring_Tidy: "#718096")
        }
    }
}

// MARK: - 统计迷你卡

/// 单个统计数据迷你卡（图标 + 数字 + 说明文字）
private class StatMiniCard_Tidy: UIView {

    private let iconLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22)
        lb.textAlignment = .center
        return lb
    }()
    private let valueLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb.textAlignment = .center
        lb.textColor = UIColor.white.withAlphaComponent(0.80)
        return lb
    }()
    private var bgGrad_Tidy: CAGradientLayer?

    /// 初始化迷你卡
    /// - Parameters:
    ///   - icon_tidy: emoji 图标字符串
    ///   - gradColors_tidy: 渐变颜色数组（2 个 UIColor）
    init(icon_tidy: String, gradColors_tidy: [UIColor]) {
        super.init(frame: .zero)
        layer.cornerRadius = 16
        clipsToBounds = true

        let grad = CAGradientLayer()
        grad.colors     = gradColors_tidy.map { $0.cgColor }
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = 16
        layer.insertSublayer(grad, at: 0)
        bgGrad_Tidy = grad

        iconLabel_Tidy.text = icon_tidy
        addSubview(iconLabel_Tidy)
        addSubview(valueLabel_Tidy)
        addSubview(titleLabel_Tidy)

        iconLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        valueLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(iconLabel_Tidy.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Tidy.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgGrad_Tidy?.frame = bounds
    }

    /// 更新数字与标题
    /// - Parameters:
    ///   - value_tidy: 数字字符串
    ///   - title_tidy: 说明文字
    ///   - valueColor_tidy: 数字颜色
    func update_Tidy(value_tidy: String, title_tidy: String, valueColor_tidy: UIColor = .white) {
        valueLabel_Tidy.text  = value_tidy
        valueLabel_Tidy.textColor = valueColor_tidy
        titleLabel_Tidy.text  = title_tidy
    }
}

// MARK: - 打卡历史 ViewController

/// 打卡历史详情页
/// 布局：顶部渐变 Banner（含连续天数）→ 三张统计迷你卡 → 月历列表（带进度条）
class CheckinHistory_Tidy: UIViewController {

    // MARK: 复用 ID
    private let kDayCell_Tidy     = "CheckinDayCell_Tidy"
    private let kMonthHeader_Tidy = "CheckinMonthHeader_Tidy"
    private let kSectionBg_Tidy   = "CheckinSectionBg_Tidy"

    // MARK: 数据
    private var monthList_Tidy: [MonthCheckinData_Tidy] = []
    private var totalDays_Tidy     = 0
    private var currentStreak_Tidy = 0
    private var longestStreak_Tidy = 0
    private var thisMonthDays_Tidy = 0

    // MARK: UI 主容器
    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    private let contentView_Tidy = UIView()

    // MARK: 顶部 Banner
    private let bannerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    private var bannerGrad_Tidy: CAGradientLayer?
    /// Banner 左侧装饰圆
    private let decorCircle1_Tidy = UIView()
    private let decorCircle2_Tidy = UIView()

    private let bannerEmojiLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "🔥"
        lb.font = UIFont.systemFont(ofSize: 40)
        return lb
    }()
    private let bannerStreakValue_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 52, weight: .heavy)
        lb.textColor = .white
        return lb
    }()
    private let bannerStreakUnit_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Day Streak"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb
    }()
    private let bannerTagline_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.75)
        lb.numberOfLines = 1
        return lb
    }()

    // MARK: 三张统计卡
    private let statsRow_Tidy = UIView()
    private lazy var cardTotal_Tidy = StatMiniCard_Tidy(
        icon_tidy: "📅",
        gradColors_tidy: [ColorConfig_Tidy.tidyMint_Tidy,
                               ColorConfig_Tidy.primaryGradientStart_Tidy]
    )
    private lazy var cardStreak_Tidy = StatMiniCard_Tidy(
        icon_tidy: "🔥",
        gradColors_tidy: [ColorConfig_Tidy.tidyWarm_Tidy,
                               ColorConfig_Tidy.secondaryGradientEnd_Tidy]
    )
    private lazy var cardMonth_Tidy = StatMiniCard_Tidy(
        icon_tidy: "🌿",
        gradColors_tidy: [ColorConfig_Tidy.primaryGradientStart_Tidy,
                               ColorConfig_Tidy.primaryGradientEnd_Tidy]
    )

    // MARK: 月历 CollectionView
    private var collectionView_Tidy: UICollectionView!
    /// CollectionView 高度约束（动态更新）
    private var cvHeight_Tidy: Constraint?

    // MARK: 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Tidy: "#F5F7FA")
        setupNavBar_Tidy()
        setupScrollView_Tidy()
        setupBanner_Tidy()
        setupStatsRow_Tidy()
        prepareData_Tidy()
        setupCollectionView_Tidy()
        fillData_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        applyNavAppearance_Tidy()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerGrad_Tidy?.frame = bannerView_Tidy.bounds
    }

    // MARK: 导航栏

    private func applyNavAppearance_Tidy() {
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
        navigationController?.navigationBar.tintColor = ColorConfig_Tidy.tidyMint_Tidy
    }

    private func setupNavBar_Tidy() {
        title = "Check-In History"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
            style: .plain, target: self, action: #selector(onBack_Tidy)
        )
    }

    @objc private func onBack_Tidy() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: 滚动容器

    private func setupScrollView_Tidy() {
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentView_Tidy)
        // 从 view.top（0）开始，Banner 延伸至导航栏后方，消除顶部空白间距
        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: Banner 顶部

    /// 构建渐变 Banner（连续打卡展示区）
    /// Banner 从 view.top（0）延伸，覆盖导航栏/状态栏后方；内容区通过 safeAreaLayoutGuide 避开遮挡
    private func setupBanner_Tidy() {
        contentView_Tidy.addSubview(bannerView_Tidy)
        // Banner 高度 = 导航栏+状态栏区域 + 内容区域（safeArea 内容高约 130）
        bannerView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }

        // 渐变背景（镜头蓝 → 暮光紫）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                       ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        bannerView_Tidy.layer.insertSublayer(grad, at: 0)
        bannerGrad_Tidy = grad

        // 装饰圆 A（右下角大圆）
        decorCircle1_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        decorCircle1_Tidy.layer.cornerRadius = 80
        bannerView_Tidy.addSubview(decorCircle1_Tidy)
        decorCircle1_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(40)
            make.width.height.equalTo(160)
        }

        // 装饰圆 B（左上角小圆）
        decorCircle2_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        decorCircle2_Tidy.layer.cornerRadius = 50
        bannerView_Tidy.addSubview(decorCircle2_Tidy)
        decorCircle2_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(100)
        }

        bannerView_Tidy.addSubview(bannerEmojiLabel_Tidy)
        bannerView_Tidy.addSubview(bannerStreakValue_Tidy)
        bannerView_Tidy.addSubview(bannerStreakUnit_Tidy)
        bannerView_Tidy.addSubview(bannerTagline_Tidy)

        // 内容区紧贴 safeAreaLayoutGuide.top，自动适配导航栏 + 状态栏高度
        bannerEmojiLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        bannerStreakValue_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(bannerEmojiLabel_Tidy.snp.trailing).offset(10)
            make.centerY.equalTo(bannerEmojiLabel_Tidy)
        }
        bannerStreakUnit_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(bannerEmojiLabel_Tidy)
            make.top.equalTo(bannerEmojiLabel_Tidy.snp.bottom).offset(8)
        }
        bannerTagline_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(bannerEmojiLabel_Tidy)
            make.top.equalTo(bannerStreakUnit_Tidy.snp.bottom).offset(6)
        }

        // Banner 底部白色圆角过渡
        let roundMask_Tidy = UIView()
        roundMask_Tidy.backgroundColor = UIColor(hexstring_Tidy: "#F5F7FA")
        roundMask_Tidy.layer.cornerRadius = 24
        roundMask_Tidy.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView_Tidy.addSubview(roundMask_Tidy)
        roundMask_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bannerView_Tidy)
            make.height.equalTo(30)
        }
    }

    // MARK: 统计卡行

    /// 构建三张统计迷你卡（悬浮在 Banner 底部）
    private func setupStatsRow_Tidy() {
        contentView_Tidy.addSubview(statsRow_Tidy)
        statsRow_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(bannerView_Tidy.snp.bottom).offset(-44)
        }

        [cardTotal_Tidy, cardStreak_Tidy, cardMonth_Tidy].forEach {
            statsRow_Tidy.addSubview($0)
            // 添加轻微阴影
            $0.layer.shadowColor  = UIColor.black.withAlphaComponent(0.12).cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowRadius = 10
            $0.layer.shadowOpacity = 1
            $0.clipsToBounds = false
        }
        statsRow_Tidy.snp.makeConstraints { make in
            make.height.equalTo(cardTotal_Tidy)
        }
        cardTotal_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        cardStreak_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(cardTotal_Tidy.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cardTotal_Tidy)
        }
        cardMonth_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(cardStreak_Tidy.snp.trailing).offset(10)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(cardStreak_Tidy)
        }
    }

    // MARK: 数据填充

    /// 将统计数据渲染到 Banner 和统计卡
    private func fillData_Tidy() {
        bannerStreakValue_Tidy.text = "\(currentStreak_Tidy)"
        bannerTagline_Tidy.text = motivationalText_Tidy(streak_tidy: currentStreak_Tidy)

        cardTotal_Tidy.update_Tidy(value_tidy: "\(totalDays_Tidy)",
                                            title_tidy: "Total Days")
        cardStreak_Tidy.update_Tidy(value_tidy: "\(longestStreak_Tidy)",
                                             title_tidy: "Best Streak")
        cardMonth_Tidy.update_Tidy(value_tidy: "\(thisMonthDays_Tidy)",
                                            title_tidy: "This Month")
    }

    /// 根据连续天数返回激励语
    /// - Parameter streak_tidy: 当前连续天数
    /// - Returns: 激励文字
    private func motivationalText_Tidy(streak_tidy: Int) -> String {
        switch streak_tidy {
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
    private func prepareData_Tidy() {
        let allDates = UserViewModel_Tidy.shared_Tidy.getAllCheckinDates_Tidy()
        totalDays_Tidy     = allDates.count
        currentStreak_Tidy = UserViewModel_Tidy.shared_Tidy.getCheckinStreak_Tidy()
        longestStreak_Tidy = calcLongestStreak_Tidy(dates_tidy: allDates)

        // 计算本月打卡数
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM"
        let curYM = fmt.string(from: Date())
        thisMonthDays_Tidy = allDates.filter { $0.hasPrefix(curYM) }.count

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
        monthList_Tidy = grouped.keys.sorted(by: >).compactMap { ym in
            let parts = ym.components(separatedBy: "-")
            guard parts.count == 2,
                  let firstDay = df.date(from: "\(ym)-01") else { return nil }
            let daysInMonth  = cal.range(of: .day, in: .month, for: firstDay)!.count
            let rawWeekday   = cal.component(.weekday, from: firstDay)
            let isoWeekday   = (rawWeekday == 1) ? 7 : (rawWeekday - 1)
            return MonthCheckinData_Tidy(
                yearMonth_tidy:   ym,
                daysInMonth_tidy: daysInMonth,
                checkedSet_tidy:  grouped[ym] ?? [],
                firstWeekday_tidy: isoWeekday
            )
        }
    }

    /// 计算历史最长连续打卡天数
    private func calcLongestStreak_Tidy(dates_tidy: [String]) -> Int {
        guard !dates_tidy.isEmpty else { return 0 }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let sorted = dates_tidy.sorted()
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

    private func setupCollectionView_Tidy() {
        collectionView_Tidy = UICollectionView(frame: .zero,
                                                    collectionViewLayout: makeLayout_Tidy())
        collectionView_Tidy.backgroundColor = .clear
        collectionView_Tidy.isScrollEnabled = false  // 由外层 scrollView 滚动
        collectionView_Tidy.dataSource = self

        collectionView_Tidy.register(CheckinDayCell_Tidy.self,
                                          forCellWithReuseIdentifier: kDayCell_Tidy)
        collectionView_Tidy.register(CheckinMonthHeaderView_Tidy.self,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: kMonthHeader_Tidy)
        // decoration view 由 layout 注册，不在此处注册 Cell

        contentView_Tidy.addSubview(collectionView_Tidy)
        collectionView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            cvHeight_Tidy = make.height.equalTo(100).constraint
        }

        // 布局后动态更新 CollectionView 高度
        collectionView_Tidy.layoutIfNeeded()
        updateCVHeight_Tidy()
    }

    /// 强制 CollectionView 高度与内容一致（因 isScrollEnabled=false）
    private func updateCVHeight_Tidy() {
        collectionView_Tidy.layoutIfNeeded()
        cvHeight_Tidy?.update(offset: collectionView_Tidy.contentSize.height)
    }

    private func makeLayout_Tidy() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16

        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] _, _ in
            self?.makeCalendarSection_Tidy()
        }, configuration: config)

        // 注册 Section 背景 decoration view
        layout.register(CheckinSectionBgView_Tidy.self,
                        forDecorationViewOfKind: kSectionBg_Tidy)
        return layout
    }

    private func makeCalendarSection_Tidy() -> NSCollectionLayoutSection {
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
        let bgDecor = NSCollectionLayoutDecorationItem.background(elementKind: kSectionBg_Tidy)
        bgDecor.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        section.decorationItems = [bgDecor]

        return section
    }
}

// MARK: - Section 背景 Decoration View

/// 月份 Section 白色圆角卡片背景
private class CheckinSectionBgView_Tidy: UICollectionReusableView {
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

extension CheckinHistory_Tidy: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        monthList_Tidy.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let data   = monthList_Tidy[section]
        let offset = data.firstWeekday_tidy - 1
        return offset + data.daysInMonth_tidy
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: kDayCell_Tidy, for: indexPath
        ) as! CheckinDayCell_Tidy

        let data   = monthList_Tidy[indexPath.section]
        let offset = data.firstWeekday_tidy - 1

        guard indexPath.item >= offset else {
            cell.configure_Tidy(day_tidy: "", isChecked_tidy: false, isToday_tidy: false)
            return cell
        }

        let dayNum   = indexPath.item - offset + 1
        let dayStr   = "\(dayNum)"
        let isChecked = data.checkedSet_tidy.contains(dayStr)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let todayStr    = df.string(from: Date())
        let cellDateStr = "\(data.yearMonth_tidy)-\(String(format: "%02d", dayNum))"
        let isToday     = (cellDateStr == todayStr)

        cell.configure_Tidy(day_tidy: dayStr,
                                 isChecked_tidy: isChecked,
                                 isToday_tidy: isToday)
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
            withReuseIdentifier: kMonthHeader_Tidy,
            for: indexPath
        ) as! CheckinMonthHeaderView_Tidy
        let data = monthList_Tidy[indexPath.section]
        header.configure_Tidy(yearMonth_tidy: data.yearMonth_tidy,
                                   checkedCount_tidy: data.checkedSet_tidy.count,
                                   totalDays_tidy: data.daysInMonth_tidy)
        return header
    }
}
