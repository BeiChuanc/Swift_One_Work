import UIKit
import SnapKit

// MARK: - 打卡页面

/// 打卡页视图控制器
/// 核心作用：展示7天/15天打卡记录、连续打卡天数、今日打卡入口
/// 设计思路：日历条横向滑动 + 渐变打卡按钮 + 火焰连签天数卡片
class CheckIn_Trace: UIViewController {
    
    // MARK: - 私有属性
    
    /// 当前展示天数（7 或 15）
    private var displayDays_Trace: Int = 7 {
        didSet { refreshData_Trace() }
    }
    
    /// 打卡状态数组
    private var checkInStatus_Trace: [(date: Date, isCheckedIn: Bool)] = []
    
    // MARK: - UI 组件
    
    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsVerticalScrollIndicator = false
        sv_Trace.alwaysBounceVertical = true
        return sv_Trace
    }()
    
    private let contentView_Trace = UIView()
    
    /// 顶部渐变装饰背景
    private let headerBgView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.layer.cornerRadius = 28
        v_Trace.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v_Trace.layer.masksToBounds = true
        return v_Trace
    }()
    
    private let headerGradientLayer_Trace = CAGradientLayer()
    
    /// 连签火焰图标
    private let flameIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        iv_Trace.image = UIImage(systemName: "flame.fill", withConfiguration: config_Trace)
        iv_Trace.tintColor = .white
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    /// 连签天数标签
    private let streakNumberLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        lbl_Trace.textColor = .white
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()
    
    /// 连签副标题
    private let streakSubtitleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl_Trace.textColor = UIColor.white.withAlphaComponent(0.85)
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()
    
    /// 7天/15天切换容器
    private let toggleContainer_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Trace.layer.cornerRadius = 16
        v_Trace.layer.masksToBounds = true
        return v_Trace
    }()
    
    private let toggle7Btn_Trace: UIButton = makeToggleButton_Trace(title_trace: "7 Days")
    private let toggle15Btn_Trace: UIButton = makeToggleButton_Trace(title_trace: "15 Days")
    
    /// 日历条白卡
    private let calendarCard_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Trace.layer.shadowRadius = 12
        v_Trace.layer.shadowOpacity = 0.08
        return v_Trace
    }()
    
    /// 日历横向滚动
    private let calendarScrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsHorizontalScrollIndicator = false
        sv_Trace.clipsToBounds = false
        return sv_Trace
    }()
    
    private let calendarStackView_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .horizontal
        sv_Trace.spacing = 8
        sv_Trace.alignment = .center
        return sv_Trace
    }()
    
    /// 打卡操作卡片
    private let actionCard_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Trace.layer.shadowRadius = 12
        v_Trace.layer.shadowOpacity = 0.08
        return v_Trace
    }()
    
    /// 打卡按钮（未打卡时可见）
    private lazy var checkInButton_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.setTitle("Check In Today", for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn_Trace.setTitleColor(.white, for: .normal)
        btn_Trace.layer.cornerRadius = 24
        btn_Trace.layer.masksToBounds = true
        btn_Trace.addTarget(self, action: #selector(handleCheckInTap_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    private let checkInGradientLayer_Trace = CAGradientLayer()
    
    /// 已打卡状态视图
    private let checkedInView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.isHidden = true
        return v_Trace
    }()
    
    private let checkedInIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        iv_Trace.image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: config_Trace)
        iv_Trace.tintColor = UIColor(hexstring_Trace: "#48BB78")
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    private let checkedInLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Already checked in today ✓"
        lbl_Trace.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl_Trace.textColor = UIColor(hexstring_Trace: "#48BB78")
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation_Trace()
        setupUI_Trace()
        refreshData_Trace()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Trace.frame = headerBgView_Trace.bounds
        checkInGradientLayer_Trace.frame = checkInButton_Trace.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - 导航栏配置
    
    private func setupNavigation_Trace() {
        title = "Check-In"
        navigationController?.navigationBar.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackTap_Trace)
        )
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        
        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        setupHeaderSection_Trace()
        setupCalendarCard_Trace()
        setupActionCard_Trace()
        
        contentView_Trace.subviews.last?.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    /// 搭建顶部渐变区（连签展示）
    private func setupHeaderSection_Trace() {
        contentView_Trace.addSubview(headerBgView_Trace)
        headerGradientLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        headerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        headerBgView_Trace.layer.insertSublayer(headerGradientLayer_Trace, at: 0)
        
        headerBgView_Trace.addSubview(flameIcon_Trace)
        headerBgView_Trace.addSubview(streakNumberLabel_Trace)
        headerBgView_Trace.addSubview(streakSubtitleLabel_Trace)
        headerBgView_Trace.addSubview(toggleContainer_Trace)
        
        headerBgView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }
        
        flameIcon_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }
        streakNumberLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(flameIcon_Trace.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        streakSubtitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(streakNumberLabel_Trace.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        // 7天/15天切换
        toggleContainer_Trace.addSubview(toggle7Btn_Trace)
        toggleContainer_Trace.addSubview(toggle15Btn_Trace)
        
        toggleContainer_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        toggle7Btn_Trace.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(3)
            make.width.equalTo(90)
        }
        toggle15Btn_Trace.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(3)
            make.leading.equalTo(toggle7Btn_Trace.snp.trailing).offset(0)
            make.width.equalTo(90)
        }
        toggleContainer_Trace.snp.makeConstraints { make in
            make.width.equalTo(186)
        }
        
        toggle7Btn_Trace.addTarget(self, action: #selector(handleToggle7_Trace), for: .touchUpInside)
        toggle15Btn_Trace.addTarget(self, action: #selector(handleToggle15_Trace), for: .touchUpInside)
        updateToggleState_Trace()
    }
    
    /// 搭建日历条卡片
    private func setupCalendarCard_Trace() {
        contentView_Trace.addSubview(calendarCard_Trace)
        calendarCard_Trace.addSubview(calendarScrollView_Trace)
        calendarScrollView_Trace.addSubview(calendarStackView_Trace)
        
        calendarCard_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerBgView_Trace.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        calendarScrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            make.height.equalTo(80)
        }
        calendarStackView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    /// 搭建打卡操作卡片
    private func setupActionCard_Trace() {
        contentView_Trace.addSubview(actionCard_Trace)
        actionCard_Trace.addSubview(checkInButton_Trace)
        actionCard_Trace.addSubview(checkedInView_Trace)
        checkedInView_Trace.addSubview(checkedInIcon_Trace)
        checkedInView_Trace.addSubview(checkedInLabel_Trace)
        
        actionCard_Trace.snp.makeConstraints { make in
            make.top.equalTo(calendarCard_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        checkInButton_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        checkInGradientLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        checkInGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        checkInGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        checkInGradientLayer_Trace.cornerRadius = 24
        checkInButton_Trace.layer.insertSublayer(checkInGradientLayer_Trace, at: 0)
        
        checkedInView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        checkedInIcon_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(checkedInLabel_Trace.snp.leading).offset(-8)
        }
        checkedInLabel_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        checkedInIcon_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(checkedInLabel_Trace.snp.leading).offset(-8)
        }
    }
    
    // MARK: - 数据刷新
    
    private func refreshData_Trace() {
        checkInStatus_Trace = UserViewModel_Trace.shared_Trace.getCheckInStatus_Trace(days_trace: displayDays_Trace)
        
        let streak_Trace = UserViewModel_Trace.shared_Trace.getCheckInStreak_Trace()
        streakNumberLabel_Trace.text = "\(streak_Trace)"
        streakSubtitleLabel_Trace.text = streak_Trace == 1 ? "day streak 🔥" : "days streak 🔥"
        
        buildCalendarDays_Trace()
        updateActionCard_Trace()
    }
    
    /// 构建日历条
    private func buildCalendarDays_Trace() {
        calendarStackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let weekdayFmt_Trace = DateFormatter()
        weekdayFmt_Trace.dateFormat = "EEE"
        let dayFmt_Trace = DateFormatter()
        dayFmt_Trace.dateFormat = "d"
        
        let today_Trace = Calendar.current.startOfDay(for: Date())
        
        for item_Trace in checkInStatus_Trace {
            let isToday_Trace = Calendar.current.isDateInToday(item_Trace.date)
            let dayView_Trace = buildDayCell_Trace(
                weekday_trace: weekdayFmt_Trace.string(from: item_Trace.date),
                day_trace: dayFmt_Trace.string(from: item_Trace.date),
                isCheckedIn_trace: item_Trace.isCheckedIn,
                isToday_trace: isToday_Trace,
                isFuture_trace: item_Trace.date > today_Trace
            )
            calendarStackView_Trace.addArrangedSubview(dayView_Trace)
        }
        
        // 自动滚动到今天（最右侧）
        DispatchQueue.main.async {
            let maxOffset_Trace = max(0, self.calendarScrollView_Trace.contentSize.width - self.calendarScrollView_Trace.bounds.width)
            self.calendarScrollView_Trace.setContentOffset(CGPoint(x: maxOffset_Trace, y: 0), animated: false)
        }
    }
    
    /// 构建单个日历天格
    /// - Parameters:
    ///   - weekday_trace: 周几缩写
    ///   - day_trace: 日期数字
    ///   - isCheckedIn_trace: 是否已打卡
    ///   - isToday_trace: 是否今天
    ///   - isFuture_trace: 是否未来
    private func buildDayCell_Trace(weekday_trace: String, day_trace: String, isCheckedIn_trace: Bool, isToday_trace: Bool, isFuture_trace: Bool) -> UIView {
        let container_Trace = UIView()
        container_Trace.snp.makeConstraints { make in
            make.width.equalTo(52)
        }
        
        let weekdayLbl_Trace = UILabel()
        weekdayLbl_Trace.text = weekday_trace
        weekdayLbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        weekdayLbl_Trace.textAlignment = .center
        weekdayLbl_Trace.textColor = isFuture_trace
            ? ColorConfig_Trace.textPlaceholder_Trace
            : ColorConfig_Trace.textSecondary_Trace
        
        // 圆形日期指示器
        let circle_Trace = UIView()
        circle_Trace.layer.cornerRadius = 20
        
        if isToday_trace {
            // 今天：渐变边框
            let grad_Trace = CAGradientLayer()
            grad_Trace.colors = [
                ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
                ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
            ]
            grad_Trace.startPoint = CGPoint(x: 0, y: 0)
            grad_Trace.endPoint = CGPoint(x: 1, y: 1)
            grad_Trace.cornerRadius = 20
            circle_Trace.layer.insertSublayer(grad_Trace, at: 0)
            circle_Trace.backgroundColor = .white
            DispatchQueue.main.async {
                grad_Trace.frame = circle_Trace.bounds
                circle_Trace.layer.borderWidth = 2.5
                circle_Trace.layer.borderColor = ColorConfig_Trace.primaryGradientStart_Trace.cgColor
            }
        } else if isCheckedIn_trace {
            circle_Trace.backgroundColor = UIColor(hexstring_Trace: "#48BB78").withAlphaComponent(0.15)
        } else if isFuture_trace {
            circle_Trace.backgroundColor = UIColor.clear
            circle_Trace.layer.borderWidth = 1.5
            circle_Trace.layer.borderColor = ColorConfig_Trace.divider_Trace.cgColor
        } else {
            circle_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        }
        
        let dayLbl_Trace = UILabel()
        dayLbl_Trace.text = day_trace
        dayLbl_Trace.font = UIFont.systemFont(ofSize: isToday_trace ? 16 : 14, weight: isToday_trace ? .bold : .medium)
        dayLbl_Trace.textAlignment = .center
        dayLbl_Trace.textColor = isToday_trace
            ? ColorConfig_Trace.primaryGradientStart_Trace
            : (isFuture_trace ? ColorConfig_Trace.textPlaceholder_Trace : ColorConfig_Trace.textPrimary_Trace)
        
        // 打卡对勾
        let checkIcon_Trace = UIImageView()
        let checkConfig_Trace = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        checkIcon_Trace.image = UIImage(systemName: "checkmark", withConfiguration: checkConfig_Trace)
        checkIcon_Trace.tintColor = UIColor(hexstring_Trace: "#48BB78")
        checkIcon_Trace.isHidden = !isCheckedIn_trace || isToday_trace
        
        circle_Trace.addSubview(dayLbl_Trace)
        circle_Trace.addSubview(checkIcon_Trace)
        container_Trace.addSubview(weekdayLbl_Trace)
        container_Trace.addSubview(circle_Trace)
        
        weekdayLbl_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        circle_Trace.snp.makeConstraints { make in
            make.top.equalTo(weekdayLbl_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        dayLbl_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        checkIcon_Trace.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().offset(-2)
        }
        
        return container_Trace
    }
    
    /// 更新打卡操作卡片状态
    private func updateActionCard_Trace() {
        let isChecked_Trace = UserViewModel_Trace.shared_Trace.hasCheckedInToday_Trace()
        checkInButton_Trace.isHidden = isChecked_Trace
        checkedInView_Trace.isHidden = !isChecked_Trace
    }
    
    /// 更新切换按钮状态
    private func updateToggleState_Trace() {
        let is7Selected_Trace = (displayDays_Trace == 7)
        updateToggleButton_Trace(toggle7Btn_Trace, isSelected_trace: is7Selected_Trace)
        updateToggleButton_Trace(toggle15Btn_Trace, isSelected_trace: !is7Selected_Trace)
    }
    
    private func updateToggleButton_Trace(_ btn_trace: UIButton, isSelected_trace: Bool) {
        btn_trace.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        if isSelected_trace {
            let grad_Trace = CAGradientLayer()
            grad_Trace.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
            grad_Trace.cornerRadius = 13
            btn_trace.layer.insertSublayer(grad_Trace, at: 0)
            btn_trace.setTitleColor(ColorConfig_Trace.primaryGradientStart_Trace, for: .normal)
            DispatchQueue.main.async { grad_Trace.frame = btn_trace.bounds }
        } else {
            btn_trace.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        }
    }
    
    // MARK: - 辅助方法
    
    private static func makeToggleButton_Trace(title_trace: String) -> UIButton {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.setTitle(title_trace, for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn_Trace.layer.cornerRadius = 13
        btn_Trace.layer.masksToBounds = true
        return btn_Trace
    }
    
    // MARK: - 事件处理
    
    @objc private func handleBackTap_Trace() {
        Navigation_Trace.pop_Trace()
    }
    
    @objc private func handleCheckInTap_Trace() {
        checkInButton_Trace.animatePressDown_Trace {
            self.checkInButton_Trace.animatePressUp_Trace()
        }
        let generator_Trace = UIImpactFeedbackGenerator(style: .medium)
        generator_Trace.impactOccurred()
        
        UserViewModel_Trace.shared_Trace.checkIn_Trace()
        refreshData_Trace()
        
        // 打卡成功动画：图标放大淡出
        checkedInIcon_Trace.animatePulse_Trace()
    }
    
    @objc private func handleToggle7_Trace() {
        guard displayDays_Trace != 7 else { return }
        displayDays_Trace = 7
        updateToggleState_Trace()
        toggle7Btn_Trace.animatePressDown_Trace { self.toggle7Btn_Trace.animatePressUp_Trace() }
    }
    
    @objc private func handleToggle15_Trace() {
        guard displayDays_Trace != 15 else { return }
        displayDays_Trace = 15
        updateToggleState_Trace()
        toggle15Btn_Trace.animatePressDown_Trace { self.toggle15Btn_Trace.animatePressUp_Trace() }
    }
}
