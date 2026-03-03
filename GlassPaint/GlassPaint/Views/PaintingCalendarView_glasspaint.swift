import Foundation
import UIKit
import SnapKit

// MARK: - 彩绘日历视图

/// 彩绘日历视图
/// 功能：展示当月日历，标记有彩绘记录的日期，支持日期选择与添加记录
/// 特性：月份切换、日期选择、添加按钮、点标记、渐变背景、选中高亮、今日标识
/// 关键属性：currentDisplayDate_Glasspaint（当前显示月份）、selectedDate_Glasspaint（选中日期）、datesWithEntries_Glasspaint（有记录的日期集合）
/// 关键方法：configure_Glasspaint（配置日历数据）、onDateSelected_Glasspaint（日期选择回调）、onAddTapped_Glasspaint（添加按钮回调）
class PaintingCalendarView_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 顶部容器
    private let headerContainer_Glasspaint = UIView()
    
    /// 月份标签
    private let monthLabel_Glasspaint = UILabel()
    
    /// 上一月按钮
    private let previousButton_Glasspaint = UIButton(type: .system)
    
    /// 下一月按钮
    private let nextButton_Glasspaint = UIButton(type: .system)
    
    /// 添加按钮
    private let addButton_Glasspaint = UIButton(type: .system)
    
    /// 星期标签容器
    private let weekdayContainer_Glasspaint = UIView()
    
    /// 日历集合视图布局
    private let calendarLayout_Glasspaint: UICollectionViewFlowLayout = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.minimumLineSpacing = 8
        layout_glasspaint.minimumInteritemSpacing = 8
        return layout_glasspaint
    }()
    
    /// 日历集合视图
    private lazy var calendarCollectionView_Glasspaint: UICollectionView = {
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: calendarLayout_Glasspaint)
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.isScrollEnabled = false
        collectionView_glasspaint.clipsToBounds = false
        return collectionView_glasspaint
    }()
    
    // MARK: - 数据属性
    
    /// 当前显示的日期（用于定位月份）
    private var currentDisplayDate_Glasspaint: Date = Date()
    
    /// 选中的日期
    private var selectedDate_Glasspaint: Date?
    
    /// 有记录的日期集合（用于标记）
    private var datesWithEntries_Glasspaint: Set<String> = []
    
    /// 日历数据（当月所有日期）
    private var calendarDates_Glasspaint: [Date?] = []
    
    /// 日期格式化器（yyyy-MM-dd）
    private let dateFormatter_Glasspaint: DateFormatter = {
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateFormat = "yyyy-MM-dd"
        return formatter_glasspaint
    }()
    
    /// 月份格式化器
    private let monthFormatter_Glasspaint: DateFormatter = {
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateFormat = "MMMM yyyy"
        return formatter_glasspaint
    }()
    
    // MARK: - 回调
    
    /// 日期选择回调
    var onDateSelected_Glasspaint: ((Date) -> Void)?
    
    /// 添加按钮回调
    var onAddTapped_Glasspaint: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        layer.cornerRadius = 20
        layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.8
        
        // 添加渐变背景
        let gradientLayer_glasspaint = CAGradientLayer()
        gradientLayer_glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.03).cgColor,
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.03).cgColor
        ]
        gradientLayer_glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_glasspaint.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer_glasspaint, at: 0)
        
        // 顶部容器
        addSubview(headerContainer_Glasspaint)
        
        // 月份标签
        headerContainer_Glasspaint.addSubview(monthLabel_Glasspaint)
        monthLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        monthLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        monthLabel_Glasspaint.textAlignment = .left
        
        // 上一月按钮
        headerContainer_Glasspaint.addSubview(previousButton_Glasspaint)
        previousButton_Glasspaint.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        previousButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        previousButton_Glasspaint.addTarget(self, action: #selector(handlePreviousMonth_Glasspaint), for: .touchUpInside)
        
        // 下一月按钮
        headerContainer_Glasspaint.addSubview(nextButton_Glasspaint)
        nextButton_Glasspaint.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
        nextButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        nextButton_Glasspaint.addTarget(self, action: #selector(handleNextMonth_Glasspaint), for: .touchUpInside)
        
        // 添加按钮
        headerContainer_Glasspaint.addSubview(addButton_Glasspaint)
        addButton_Glasspaint.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton_Glasspaint.tintColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        addButton_Glasspaint.addTarget(self, action: #selector(handleAddTap_Glasspaint), for: .touchUpInside)
        
        // 星期标签
        addSubview(weekdayContainer_Glasspaint)
        setupWeekdayLabels_Glasspaint()
        
        // 日历集合视图
        addSubview(calendarCollectionView_Glasspaint)
        calendarCollectionView_Glasspaint.delegate = self
        calendarCollectionView_Glasspaint.dataSource = self
        calendarCollectionView_Glasspaint.register(CalendarDayCell_Glasspaint.self, forCellWithReuseIdentifier: "CalendarDayCell")
        
        setupConstraints_Glasspaint()
        
        // 初始化日历数据
        generateCalendarDates_Glasspaint()
        
        // 更新月份标签
        updateMonthLabel_Glasspaint()
        
        // 异步更新渐变层
        DispatchQueue.main.async {
            gradientLayer_glasspaint.frame = self.bounds
        }
    }
    
    /// 设置星期标签
    private func setupWeekdayLabels_Glasspaint() {
        let weekdays_glasspaint = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let stackView_glasspaint = UIStackView()
        weekdayContainer_Glasspaint.addSubview(stackView_glasspaint)
        stackView_glasspaint.axis = .horizontal
        stackView_glasspaint.distribution = .fillEqually
        stackView_glasspaint.alignment = .center
        
        for weekday_glasspaint in weekdays_glasspaint {
            let label_glasspaint = UILabel()
            label_glasspaint.text = weekday_glasspaint
            label_glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label_glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
            label_glasspaint.textAlignment = .center
            stackView_glasspaint.addArrangedSubview(label_glasspaint)
        }
        
        stackView_glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        headerContainer_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        monthLabel_Glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        previousButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(monthLabel_Glasspaint.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        nextButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(previousButton_Glasspaint.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        addButton_Glasspaint.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        weekdayContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        calendarCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(weekdayContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(240)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置日历数据
    /// 参数：
    /// - diaryEntries_glasspaint: 彩绘日记列表
    func configure_Glasspaint(with_glasspaint diaryEntries_glasspaint: [PaintingDiaryEntry_Glasspaint]) {
        // 更新有记录的日期集合
        datesWithEntries_Glasspaint.removeAll()
        for entry_glasspaint in diaryEntries_glasspaint {
            let dateString_glasspaint = dateFormatter_Glasspaint.string(from: entry_glasspaint.date_Glasspaint)
            datesWithEntries_Glasspaint.insert(dateString_glasspaint)
        }
        
        // 刷新视图
        calendarCollectionView_Glasspaint.reloadData()
    }
    
    // MARK: - 私有方法
    
    /// 生成日历日期数据
    private func generateCalendarDates_Glasspaint() {
        calendarDates_Glasspaint.removeAll()
        
        let calendar_glasspaint = Calendar.current
        
        // 获取当月第一天
        let components_glasspaint = calendar_glasspaint.dateComponents([.year, .month], from: currentDisplayDate_Glasspaint)
        guard let firstDayOfMonth_glasspaint = calendar_glasspaint.date(from: components_glasspaint) else { return }
        
        // 获取当月天数
        guard let range_glasspaint = calendar_glasspaint.range(of: .day, in: .month, for: firstDayOfMonth_glasspaint) else { return }
        let numberOfDays_glasspaint = range_glasspaint.count
        
        // 获取第一天是星期几（0=Sunday）
        let firstWeekday_glasspaint = calendar_glasspaint.component(.weekday, from: firstDayOfMonth_glasspaint) - 1
        
        // 添加前置空白
        for _ in 0..<firstWeekday_glasspaint {
            calendarDates_Glasspaint.append(nil)
        }
        
        // 添加当月日期
        for day_glasspaint in 1...numberOfDays_glasspaint {
            var dateComponents_glasspaint = components_glasspaint
            dateComponents_glasspaint.day = day_glasspaint
            if let date_glasspaint = calendar_glasspaint.date(from: dateComponents_glasspaint) {
                calendarDates_Glasspaint.append(date_glasspaint)
            }
        }
        
        calendarCollectionView_Glasspaint.reloadData()
        
        // 触发布局更新以重新计算高度
        setNeedsLayout()
    }
    
    /// 更新日历高度
    private func updateCalendarHeight_Glasspaint() {
        // 计算需要的行数
        let totalCells_glasspaint = calendarDates_Glasspaint.count
        let rows_glasspaint = Int(ceil(Double(totalCells_glasspaint) / 7.0))
        
        // 计算单元格大小（基于实际的 collectionView 宽度）
        let collectionViewWidth_glasspaint = calendarCollectionView_Glasspaint.bounds.width
        guard collectionViewWidth_glasspaint > 0 else { return }
        
        let spacing_glasspaint: CGFloat = 8
        let totalSpacing_glasspaint = spacing_glasspaint * 6
        let itemWidth_glasspaint = (collectionViewWidth_glasspaint - totalSpacing_glasspaint) / 7
        
        // 计算总高度：行数 * 单元格高度 + (行数-1) * 行间距
        let totalHeight_glasspaint = CGFloat(rows_glasspaint) * itemWidth_glasspaint + CGFloat(rows_glasspaint - 1) * spacing_glasspaint
        
        // 更新约束（只在高度变化时更新）
        calendarCollectionView_Glasspaint.snp.updateConstraints { make in
            make.height.equalTo(totalHeight_glasspaint)
        }
    }
    
    /// 更新月份标签
    private func updateMonthLabel_Glasspaint() {
        monthLabel_Glasspaint.text = monthFormatter_Glasspaint.string(from: currentDisplayDate_Glasspaint)
    }
    
    // MARK: - 事件处理
    
    /// 处理上一月按钮
    @objc private func handlePreviousMonth_Glasspaint() {
        previousButton_Glasspaint.animatePressDown_Glasspaint {
            self.previousButton_Glasspaint.animatePressUp_Glasspaint()
        }
        
        let calendar_glasspaint = Calendar.current
        if let newDate_glasspaint = calendar_glasspaint.date(byAdding: .month, value: -1, to: currentDisplayDate_Glasspaint) {
            currentDisplayDate_Glasspaint = newDate_glasspaint
            updateMonthLabel_Glasspaint()
            generateCalendarDates_Glasspaint()
        }
    }
    
    /// 处理下一月按钮
    @objc private func handleNextMonth_Glasspaint() {
        nextButton_Glasspaint.animatePressDown_Glasspaint {
            self.nextButton_Glasspaint.animatePressUp_Glasspaint()
        }
        
        let calendar_glasspaint = Calendar.current
        if let newDate_glasspaint = calendar_glasspaint.date(byAdding: .month, value: 1, to: currentDisplayDate_Glasspaint) {
            currentDisplayDate_Glasspaint = newDate_glasspaint
            updateMonthLabel_Glasspaint()
            generateCalendarDates_Glasspaint()
        }
    }
    
    /// 处理添加按钮
    @objc private func handleAddTap_Glasspaint() {
        // 检查登录状态
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
            }
            return
        }
        
        addButton_Glasspaint.animatePulse_Glasspaint()
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        onAddTapped_Glasspaint?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变层
        if let gradientLayer_glasspaint = layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer_glasspaint.frame = bounds
        }
        
        // 在布局时重新计算日历高度
        if calendarCollectionView_Glasspaint.bounds.width > 0 && !calendarDates_Glasspaint.isEmpty {
            updateCalendarHeight_Glasspaint()
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension PaintingCalendarView_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarDates_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell_Glasspaint
        
        let dateOption_glasspaint = calendarDates_Glasspaint[indexPath.item]
        
        if let date_glasspaint = dateOption_glasspaint {
            let day_glasspaint = Calendar.current.component(.day, from: date_glasspaint)
            let dateString_glasspaint = dateFormatter_Glasspaint.string(from: date_glasspaint)
            let hasEntry_glasspaint = datesWithEntries_Glasspaint.contains(dateString_glasspaint)
            let isSelected_glasspaint = selectedDate_Glasspaint != nil && Calendar.current.isDate(date_glasspaint, inSameDayAs: selectedDate_Glasspaint!)
            let isToday_glasspaint = Calendar.current.isDateInToday(date_glasspaint)
            
            cell_glasspaint.configure_Glasspaint(
                day_glasspaint: day_glasspaint,
                hasEntry_glasspaint: hasEntry_glasspaint,
                isSelected_glasspaint: isSelected_glasspaint,
                isToday_glasspaint: isToday_glasspaint
            )
        } else {
            cell_glasspaint.configureEmpty_Glasspaint()
        }
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date_glasspaint = calendarDates_Glasspaint[indexPath.item] else { return }
        
        // 如果点击的是已选中的日期，则取消选择
        if let currentSelected_glasspaint = selectedDate_Glasspaint,
           Calendar.current.isDate(date_glasspaint, inSameDayAs: currentSelected_glasspaint) {
            selectedDate_Glasspaint = nil
        } else {
            selectedDate_Glasspaint = date_glasspaint
        }
        
        collectionView.reloadData()
        
        // 通知选择变化（nil表示取消选择）
        if let selected_glasspaint = selectedDate_Glasspaint {
            onDateSelected_Glasspaint?(selected_glasspaint)
        } else {
            // 取消选择，传递当前显示日期作为参考
            onDateSelected_Glasspaint?(currentDisplayDate_Glasspaint)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 动态计算单元格大小
        let collectionViewWidth_glasspaint = collectionView.bounds.width
        let spacing_glasspaint: CGFloat = 8
        let totalSpacing_glasspaint = spacing_glasspaint * 6 // 7列之间有6个间距
        let itemWidth_glasspaint = (collectionViewWidth_glasspaint - totalSpacing_glasspaint) / 7
        return CGSize(width: itemWidth_glasspaint, height: itemWidth_glasspaint)
    }
    
    /// 获取选中的日期
    func getSelectedDate_Glasspaint() -> Date? {
        return selectedDate_Glasspaint
    }
    
    /// 清除选中状态
    func clearSelection_Glasspaint() {
        selectedDate_Glasspaint = nil
        calendarCollectionView_Glasspaint.reloadData()
    }
}

// MARK: - 日历日期单元格

/// 日历日期单元格
class CalendarDayCell_Glasspaint: UICollectionViewCell {
    
    /// 日期标签
    private let dayLabel_Glasspaint = UILabel()
    
    /// 点标记（有记录时显示）
    private let dotIndicator_Glasspaint = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置所有状态
        contentView.transform = .identity
        contentView.layer.sublayers?.forEach { layer_glasspaint in
            if layer_glasspaint is CAGradientLayer {
                layer_glasspaint.removeFromSuperlayer()
            }
        }
        contentView.layer.borderWidth = 0
        contentView.layer.shadowOpacity = 0
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 日期标签
        contentView.addSubview(dayLabel_Glasspaint)
        dayLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        dayLabel_Glasspaint.textAlignment = .center
        
        // 点标记
        contentView.addSubview(dotIndicator_Glasspaint)
        dotIndicator_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        dotIndicator_Glasspaint.layer.cornerRadius = 3
        dotIndicator_Glasspaint.isHidden = true
        
        // 布局
        dayLabel_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        dotIndicator_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
            make.width.height.equalTo(6)
        }
    }
    
    /// 配置单元格
    /// 参数：
    /// - day_glasspaint: 日期数字
    /// - hasEntry_glasspaint: 是否有记录
    /// - isSelected_glasspaint: 是否选中
    /// - isToday_glasspaint: 是否今天
    func configure_Glasspaint(
        day_glasspaint: Int,
        hasEntry_glasspaint: Bool,
        isSelected_glasspaint: Bool,
        isToday_glasspaint: Bool
    ) {
        dayLabel_Glasspaint.text = "\(day_glasspaint)"
        
        // 移除所有旧的渐变层
        contentView.layer.sublayers?.forEach { layer_glasspaint in
            if layer_glasspaint is CAGradientLayer {
                layer_glasspaint.removeFromSuperlayer()
            }
        }
        
        if isSelected_glasspaint {
            // 选中状态 - 双层渐变设计
            // 外层渐变（光晕效果）
            let outerGradient_glasspaint = CAGradientLayer()
            outerGradient_glasspaint.colors = [
                ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor,
                ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor
            ]
            outerGradient_glasspaint.startPoint = CGPoint(x: 0, y: 0)
            outerGradient_glasspaint.endPoint = CGPoint(x: 1, y: 1)
            outerGradient_glasspaint.frame = contentView.bounds
            outerGradient_glasspaint.cornerRadius = contentView.bounds.width / 2
            contentView.layer.insertSublayer(outerGradient_glasspaint, at: 0)
            
            // 内层渐变（主体）
            let innerGradient_glasspaint = CAGradientLayer()
            innerGradient_glasspaint.colors = [
                ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
                ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor,
                ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor
            ]
            innerGradient_glasspaint.locations = [0.0, 0.5, 1.0]
            innerGradient_glasspaint.startPoint = CGPoint(x: 0, y: 0)
            innerGradient_glasspaint.endPoint = CGPoint(x: 1, y: 1)
            let inset: CGFloat = 3
            innerGradient_glasspaint.frame = contentView.bounds.insetBy(dx: inset, dy: inset)
            innerGradient_glasspaint.cornerRadius = (contentView.bounds.width - inset * 2) / 2
            contentView.layer.insertSublayer(innerGradient_glasspaint, at: 1)
            
            contentView.backgroundColor = .clear
            dayLabel_Glasspaint.textColor = .white
            dayLabel_Glasspaint.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            
            // 外边框 - 白色光晕
            contentView.layer.borderWidth = 2.5
            contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            contentView.layer.cornerRadius = contentView.bounds.width / 2
            
            // 多层阴影效果
            contentView.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
            contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            contentView.layer.shadowRadius = 12
            contentView.layer.shadowOpacity = 0.8
            contentView.layer.masksToBounds = false
            
            // 缩放动画（仅当尚未缩放时）
            if contentView.transform == .identity {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                    self.contentView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                }
            } else {
                contentView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
            
            // 点标记变为白色且更大
            dotIndicator_Glasspaint.isHidden = !hasEntry_glasspaint
            dotIndicator_Glasspaint.backgroundColor = .white
            dotIndicator_Glasspaint.layer.cornerRadius = 3.5
            dotIndicator_Glasspaint.snp.updateConstraints { make in
                make.width.height.equalTo(7)
            }
            
        } else if isToday_glasspaint {
            // 今天 - 特殊边框样式
            let todayGradient_glasspaint = CAGradientLayer()
            todayGradient_glasspaint.colors = [
                ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.2).cgColor,
                ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint.withAlphaComponent(0.2).cgColor
            ]
            todayGradient_glasspaint.startPoint = CGPoint(x: 0, y: 0)
            todayGradient_glasspaint.endPoint = CGPoint(x: 1, y: 1)
            todayGradient_glasspaint.frame = contentView.bounds
            todayGradient_glasspaint.cornerRadius = contentView.bounds.width / 2
            contentView.layer.insertSublayer(todayGradient_glasspaint, at: 0)
            
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.cgColor
            contentView.layer.cornerRadius = contentView.bounds.width / 2
            contentView.layer.shadowOpacity = 0
            
            // 重置缩放（带动画）
            if contentView.transform != .identity {
                UIView.animate(withDuration: 0.2) {
                    self.contentView.transform = .identity
                }
            }
            
            dayLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
            dayLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            
            dotIndicator_Glasspaint.isHidden = !hasEntry_glasspaint
            dotIndicator_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
            dotIndicator_Glasspaint.layer.cornerRadius = 3
            dotIndicator_Glasspaint.snp.updateConstraints { make in
                make.width.height.equalTo(6)
            }
            
        } else {
            // 普通状态
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 0
            contentView.layer.shadowOpacity = 0
            
            // 重置缩放（带动画）
            if contentView.transform != .identity {
                UIView.animate(withDuration: 0.2) {
                    self.contentView.transform = .identity
                }
            }
            
            dayLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
            dayLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            
            dotIndicator_Glasspaint.isHidden = !hasEntry_glasspaint
            dotIndicator_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
            dotIndicator_Glasspaint.layer.cornerRadius = 3
            dotIndicator_Glasspaint.snp.updateConstraints { make in
                make.width.height.equalTo(6)
            }
        }
    }
    
    /// 配置空单元格
    func configureEmpty_Glasspaint() {
        dayLabel_Glasspaint.text = ""
        dotIndicator_Glasspaint.isHidden = true
        contentView.backgroundColor = .clear
        contentView.layer.shadowOpacity = 0
    }
}
