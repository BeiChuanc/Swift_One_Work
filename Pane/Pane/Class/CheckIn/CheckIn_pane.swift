import UIKit
import SnapKit

// MARK: 打卡页面

// MARK: - 打卡日历单元格（私有，仅供 CheckIn_Pane 使用）

/// 打卡日历单元格
/// 核心作用：展示单天的打卡状态（已打卡 / 今天 / 未来 / 过去未打卡）
/// 设计理念：圆形主图标 + 日期数字 + 星期字母，三层信息呈现
private class CheckInDayCell_Pane: UICollectionViewCell {

    static let reuseId_Pane = "CheckInDayCell_Pane"

    // MARK: 打卡状态枚举
    enum DayState_Pane {
        case checked_pane        // 已打卡
        case today_pane          // 今天（未打卡）
        case todayChecked_pane   // 今天（已打卡）
        case past_pane           // 过去未打卡
        case future_pane         // 未来
    }

    // MARK: UI组件

    private let circleView_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private var circleGradient_Pane: CAGradientLayer?

    private let checkIconView_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let dateLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let weekdayLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .medium)
        l.textAlignment = .center
        return l
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        circleGradient_Pane?.frame = circleView_Pane.bounds
    }

    private func setupUI_Pane() {
        contentView.addSubview(circleView_Pane)
        circleView_Pane.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(48)
        }

        circleView_Pane.addSubview(checkIconView_Pane)
        checkIconView_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        circleView_Pane.addSubview(dateLabel_Pane)
        dateLabel_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        contentView.addSubview(weekdayLabel_Pane)
        weekdayLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(circleView_Pane.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    // MARK: 数据配置

    /// 配置单元格
    /// - Parameters:
    ///   - dateString_pane: 日期字符串（yyyy-MM-dd）
    ///   - weekday_pane:    星期缩写（Mon, Tue...）
    ///   - state_pane:      当天打卡状态
    func configure_Pane(dateString_pane: String, weekday_pane: String, state_pane: DayState_Pane) {
        // 日期数字
        let parts_pane = dateString_pane.split(separator: "-")
        dateLabel_Pane.text = parts_pane.count >= 3 ? String(parts_pane[2]).replacingOccurrences(of: "^0", with: "", options: .regularExpression) : "?"
        weekdayLabel_Pane.text = weekday_pane

        // 清除旧渐变
        circleGradient_Pane?.removeFromSuperlayer()
        circleGradient_Pane = nil

        switch state_pane {
        case .checked_pane, .todayChecked_pane:
            // 已打卡：主题渐变填充
            let gl = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: circleView_Pane.bounds)
            gl.cornerRadius = 24
            circleView_Pane.layer.insertSublayer(gl, at: 0)
            circleGradient_Pane = gl
            circleView_Pane.layer.borderWidth = 0
            circleView_Pane.backgroundColor   = .clear
            checkIconView_Pane.isHidden = false
            dateLabel_Pane.isHidden     = true
            dateLabel_Pane.textColor    = .white
            weekdayLabel_Pane.textColor = ColorConfig_Pane.textSecondary_Pane
            // 今天已打卡在圆圈图层加光晕
            if state_pane == .todayChecked_pane {
                circleView_Pane.layer.addGlowEffect_Pane(color_Pane: ColorConfig_Pane.primaryGradientStart_Pane)
            }

        case .today_pane:
            // 今天未打卡：带描边的空心圆 + 脉冲提示
            circleView_Pane.backgroundColor   = ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.1)
            circleView_Pane.layer.borderWidth = 2.5
            circleView_Pane.layer.borderColor = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
            checkIconView_Pane.isHidden = true
            dateLabel_Pane.isHidden     = false
            dateLabel_Pane.textColor    = ColorConfig_Pane.primaryGradientStart_Pane
            weekdayLabel_Pane.textColor = ColorConfig_Pane.primaryGradientStart_Pane

        case .past_pane:
            // 过去未打卡：浅灰
            circleView_Pane.backgroundColor   = UIColor(hexstring_Pane: "#EDF2F7")
            circleView_Pane.layer.borderWidth = 0
            checkIconView_Pane.isHidden = true
            dateLabel_Pane.isHidden     = false
            dateLabel_Pane.textColor    = ColorConfig_Pane.textPlaceholder_Pane
            weekdayLabel_Pane.textColor = ColorConfig_Pane.textPlaceholder_Pane

        case .future_pane:
            // 未来：虚线描边
            circleView_Pane.backgroundColor   = .clear
            circleView_Pane.layer.borderWidth = 1.5
            circleView_Pane.layer.borderColor = UIColor(hexstring_Pane: "#CBD5E0").cgColor
            checkIconView_Pane.isHidden = true
            dateLabel_Pane.isHidden     = false
            dateLabel_Pane.textColor    = UIColor(hexstring_Pane: "#CBD5E0")
            weekdayLabel_Pane.textColor = UIColor(hexstring_Pane: "#CBD5E0")
        }
    }
}

// MARK: - 打卡页面 ViewController

/// 打卡页面
/// 核心作用：展示用户的每日打卡记录（7/15天切换），支持今日打卡操作
/// 设计理念：温暖渐变顶部卡片展示连续天数 + 下方日历网格 + 底部打卡按钮
/// 关键方法：
///   refreshData_Pane()   - 刷新打卡数据并更新 UI
///   handleCheckIn_Pane() - 执行今日打卡
class CheckIn_Pane: UIViewController {

    // MARK: - 模式常量
    private let modeOptions_Pane: [Int] = [7, 15]
    private var currentMode_Pane: Int = 7

    // MARK: - 数据
    private var checkInRecords_Pane: [(date: String, checked: Bool, isToday: Bool)] = []
    private var streak_Pane: Int = 0
    private var checkedToday_Pane: Bool = false

    // MARK: - UI组件

    /// 滚动视图（整页可滚动）
    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentContainer_Pane = UIView()

    /// 顶部关闭按钮
    private let closeButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 顶部渐变背景卡片（展示连续天数）
    private let streakCard_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private var streakCardGradient_Pane: CAGradientLayer?

    /// 火焰图标（大）
    private let bigFlameIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
        iv.tintColor = UIColor(hexstring_Pane: "#FF8C42")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 连续天数大数字
    private let bigStreakNumber_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 56, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// "Days Streak" 副标题
    private let bigStreakTitle_Pane: UILabel = {
        let l = UILabel()
        l.text = "Days Streak"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        return l
    }()

    /// 激励文字
    private let motivationLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 7天 / 15天 切换控件
    private let modeSegment_Pane: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["7 Days", "15 Days"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = ColorConfig_Pane.primaryGradientStart_Pane
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: ColorConfig_Pane.textSecondary_Pane], for: .normal)
        return sc
    }()

    /// 日历网格 CollectionView
    private lazy var daysCollectionView_Pane: UICollectionView = {
        let layout_pane = buildDaysLayout_Pane()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout_pane)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.register(CheckInDayCell_Pane.self, forCellWithReuseIdentifier: CheckInDayCell_Pane.reuseId_Pane)
        return cv
    }()

    /// 打卡按钮（底部固定）
    private let checkInButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Check In Today", for: .normal)
        btn.setTitle("✓ Already Checked In", for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
        btn.layer.cornerRadius = 26
        btn.clipsToBounds = true
        return btn
    }()

    private var buttonGradientLayer_Pane: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Pane()
        setupScrollView_Pane()
        setupStreakCard_Pane()
        setupControls_Pane()
        setupDaysCollection_Pane()
        setupCheckInButton_Pane()
        registerNotifications_Pane()
        refreshData_Pane()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        streakCardGradient_Pane?.frame = streakCard_Pane.bounds
        buttonGradientLayer_Pane?.frame = checkInButton_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI初始化

    private func setupView_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
    }

    private func setupScrollView_Pane() {
        view.addSubview(scrollView_Pane)
        scrollView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView_Pane.addSubview(contentContainer_Pane)
        contentContainer_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }
    }

    /// 构建顶部连续天数卡片
    private func setupStreakCard_Pane() {
        contentContainer_Pane.addSubview(streakCard_Pane)
        streakCard_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(220)
        }

        // 背景渐变（暖橙 → 玫瑰）
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Pane: "#FF7043").cgColor,
            UIColor(hexstring_Pane: "#E91E8C").cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint   = CGPoint(x: 1, y: 1)
        streakCard_Pane.layer.addSublayer(gl)
        streakCardGradient_Pane = gl

        // 装饰圆
        let decorA_pane = UIView()
        decorA_pane.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        decorA_pane.layer.cornerRadius = 70
        streakCard_Pane.addSubview(decorA_pane)
        decorA_pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(30)
            $0.top.equalToSuperview().offset(-30)
            $0.width.height.equalTo(140)
        }

        let decorB_pane = UIView()
        decorB_pane.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        decorB_pane.layer.cornerRadius = 50
        streakCard_Pane.addSubview(decorB_pane)
        decorB_pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview().offset(20)
            $0.width.height.equalTo(100)
        }

        // 关闭按钮
        streakCard_Pane.addSubview(closeButton_Pane)
        closeButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(36)
        }
        closeButton_Pane.addTarget(self, action: #selector(handleClose_Pane), for: .touchUpInside)

        // 火焰图标
        streakCard_Pane.addSubview(bigFlameIcon_Pane)
        bigFlameIcon_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(36)
        }

        // 大数字
        streakCard_Pane.addSubview(bigStreakNumber_Pane)
        bigStreakNumber_Pane.snp.makeConstraints {
            $0.top.equalTo(bigFlameIcon_Pane.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }

        streakCard_Pane.addSubview(bigStreakTitle_Pane)
        bigStreakTitle_Pane.snp.makeConstraints {
            $0.top.equalTo(bigStreakNumber_Pane.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }

        streakCard_Pane.addSubview(motivationLabel_Pane)
        motivationLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(bigStreakTitle_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    private func setupControls_Pane() {
        contentContainer_Pane.addSubview(modeSegment_Pane)
        modeSegment_Pane.snp.makeConstraints {
            $0.top.equalTo(streakCard_Pane.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        modeSegment_Pane.addTarget(self, action: #selector(handleModeChange_Pane(_:)), for: .valueChanged)
    }

    private func setupDaysCollection_Pane() {
        contentContainer_Pane.addSubview(daysCollectionView_Pane)
        daysCollectionView_Pane.snp.makeConstraints {
            $0.top.equalTo(modeSegment_Pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(daysCollectionHeight_Pane())
        }
    }

    private func setupCheckInButton_Pane() {
        contentContainer_Pane.addSubview(checkInButton_Pane)
        checkInButton_Pane.snp.makeConstraints {
            $0.top.equalTo(daysCollectionView_Pane.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().offset(-40)
        }
        checkInButton_Pane.addTarget(self, action: #selector(handleCheckInTap_Pane), for: .touchUpInside)

        // 渐变背景
        let gl = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: .zero)
        gl.cornerRadius = 26
        checkInButton_Pane.layer.insertSublayer(gl, at: 0)
        buttonGradientLayer_Pane = gl

        // 阴影
        checkInButton_Pane.layer.shadowColor   = ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.5).cgColor
        checkInButton_Pane.layer.shadowOpacity = 1.0
        checkInButton_Pane.layer.shadowOffset  = CGSize(width: 0, height: 6)
        checkInButton_Pane.layer.shadowRadius  = 14
        checkInButton_Pane.layer.masksToBounds = false
    }

    // MARK: - 日历网格布局

    /// 根据当前模式计算日历 CollectionView 高度
    private func daysCollectionHeight_Pane() -> CGFloat {
        // 7天模式：单行（每格约 74pt）；15天模式：3行
        let rows_pane = currentMode_Pane == 7 ? 1 : 3
        return CGFloat(rows_pane) * 74 + CGFloat(rows_pane - 1) * 12
    }

    private func buildDaysLayout_Pane() -> UICollectionViewFlowLayout {
        let layout_pane = UICollectionViewFlowLayout()
        layout_pane.minimumInteritemSpacing = 8
        layout_pane.minimumLineSpacing = 12
        let columns_pane: CGFloat = currentMode_Pane == 7 ? 7 : 5
        let totalWidth_pane = UIScreen.main.bounds.width - 32 - 8 * (columns_pane - 1)
        let itemWidth_pane = totalWidth_pane / columns_pane
        layout_pane.itemSize = CGSize(width: itemWidth_pane, height: 70)
        return layout_pane
    }

    // MARK: - 数据刷新

    /// 刷新打卡数据并更新所有 UI 组件
    private func refreshData_Pane() {
        let vm_pane = UserViewModel_Pane.shared_Pane
        streak_Pane      = vm_pane.getCheckInStreak_Pane()
        checkedToday_Pane = vm_pane.hasCheckedInToday_Pane()
        checkInRecords_Pane = vm_pane.getCheckInRecord_Pane(days_pane: currentMode_Pane)

        // 更新大数字
        bigStreakNumber_Pane.text = "\(streak_Pane)"
        motivationLabel_Pane.text = motivationText_Pane(streak_pane: streak_Pane)

        // 更新打卡按钮
        let isEnabled_pane = !checkedToday_Pane
        checkInButton_Pane.isEnabled = isEnabled_pane
        buttonGradientLayer_Pane?.opacity = isEnabled_pane ? 1.0 : 0.45

        // 刷新日历网格
        daysCollectionView_Pane.reloadData()
    }

    /// 根据连续天数返回激励文字
    private func motivationText_Pane(streak_pane: Int) -> String {
        switch streak_pane {
        case 0:         return "Every window holds a beautiful moment. Start today!"
        case 1...3:     return "Great start! Keep your window open every day."
        case 4...7:     return "Building momentum! Your view is getting better. 🌟"
        case 8...14:    return "On fire! Every day is a new window to the world. 🔥"
        default:        return "Unstoppable! You're a true window explorer! 💫"
        }
    }

    // MARK: - 通知

    private func registerNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Pane),
            name: UserViewModel_Pane.userStateDidChangeNotification_Pane,
            object: nil
        )
    }

    // MARK: - 事件处理

    @objc private func handleClose_Pane() {
        closeButton_Pane.animatePulse_Pane()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            Navigation_Pane.dismiss_Pane()
        }
    }

    @objc private func handleModeChange_Pane(_ sender: UISegmentedControl) {
        currentMode_Pane = modeOptions_Pane[sender.selectedSegmentIndex]

        // 更新日历高度约束
        daysCollectionView_Pane.snp.updateConstraints {
            $0.height.equalTo(daysCollectionHeight_Pane())
        }

        // 更新布局
        if let layout_pane = daysCollectionView_Pane.collectionViewLayout as? UICollectionViewFlowLayout {
            let columns_pane: CGFloat = currentMode_Pane == 7 ? 7 : 5
            let totalWidth_pane = UIScreen.main.bounds.width - 32 - 8 * (columns_pane - 1)
            layout_pane.itemSize = CGSize(width: totalWidth_pane / columns_pane, height: 70)
            layout_pane.invalidateLayout()
        }

        UIView.animate(withDuration: AnimationConfig_Pane.durationNormal_Pane) {
            self.view.layoutIfNeeded()
        }
        refreshData_Pane()
    }

    @objc private func handleCheckInTap_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .medium)
        gen_pane.impactOccurred()
        checkInButton_Pane.animatePressDown_Pane {
            self.checkInButton_Pane.animatePressUp_Pane {
                UserViewModel_Pane.shared_Pane.checkIn_Pane()
            }
        }
    }

    @objc private func handleUserStateChange_Pane() {
        refreshData_Pane()
    }
}

// MARK: - UICollectionViewDataSource

extension CheckIn_Pane: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checkInRecords_Pane.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_pane = collectionView.dequeueReusableCell(
            withReuseIdentifier: CheckInDayCell_Pane.reuseId_Pane,
            for: indexPath
        ) as! CheckInDayCell_Pane

        let record_pane = checkInRecords_Pane[indexPath.item]

        // 解析日期并获取星期缩写
        let dateF_pane = DateFormatter()
        dateF_pane.dateFormat = "yyyy-MM-dd"
        let weekF_pane = DateFormatter()
        weekF_pane.dateFormat = "EEE"
        let weekday_pane: String
        if let date_pane = dateF_pane.date(from: record_pane.date) {
            weekday_pane = weekF_pane.string(from: date_pane)
        } else {
            weekday_pane = ""
        }

        // 判断单元格状态（getCheckInRecord_Pane 只返回过去 N 天，不含未来日期）
        let state_pane: CheckInDayCell_Pane.DayState_Pane
        if record_pane.isToday {
            state_pane = record_pane.checked ? .todayChecked_pane : .today_pane
        } else if record_pane.checked {
            state_pane = .checked_pane
        } else {
            state_pane = .past_pane
        }

        cell_pane.configure_Pane(dateString_pane: record_pane.date, weekday_pane: weekday_pane, state_pane: state_pane)
        return cell_pane
    }
}
