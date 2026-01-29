import Foundation
import UIKit
import FSCalendar
import SnapKit

// MARK: 情绪日历视图

/// 情绪日历视图
/// 功能：展示每日情绪记录，支持月份切换和日期选择
/// 设计：集成FSCalendar，自定义样式，情绪颜色标记
class EmotionCalendar_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// FSCalendar实例
    private let calendar_Wanderbell: FSCalendar = {
        let calendar_wanderbell = FSCalendar()
        calendar_wanderbell.scope = .month
        calendar_wanderbell.scrollDirection = .horizontal
        calendar_wanderbell.appearance.headerMinimumDissolvedAlpha = 0
        calendar_wanderbell.appearance.headerTitleColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        calendar_wanderbell.appearance.headerTitleFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        calendar_wanderbell.appearance.weekdayTextColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        calendar_wanderbell.appearance.weekdayFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        calendar_wanderbell.appearance.titleDefaultColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        calendar_wanderbell.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        calendar_wanderbell.appearance.selectionColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        calendar_wanderbell.appearance.todayColor = ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell
        calendar_wanderbell.appearance.borderRadius = 0.5
        return calendar_wanderbell
    }()
    
    // MARK: - 属性
    
    /// 当月情绪数据（日期 -> 情绪类型）
    private var monthlyEmotions_Wanderbell: [Date: EmotionType_Wanderbell] = [:]
    
    /// 日期选择回调
    var onDateSelected_Wanderbell: ((Date) -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        loadCurrentMonthData_Wanderbell()
        observeEmotionState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        addSubview(calendar_Wanderbell)
        
        calendar_Wanderbell.delegate = self
        calendar_Wanderbell.dataSource = self
    }
    
    private func setupConstraints_Wanderbell() {
        calendar_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    /// 监听情绪状态变化
    private func observeEmotionState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEmotionStateChange_Wanderbell),
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 数据加载
    
    /// 加载当前月份数据
    private func loadCurrentMonthData_Wanderbell() {
        let calendar_wanderbell = Calendar.current
        let components_wanderbell = calendar_wanderbell.dateComponents([.year, .month], from: Date())
        
        guard let year_wanderbell = components_wanderbell.year,
              let month_wanderbell = components_wanderbell.month else { return }
        
        loadMonthData_Wanderbell(year_wanderbell: year_wanderbell, month_wanderbell: month_wanderbell)
    }
    
    /// 加载指定月份数据
    private func loadMonthData_Wanderbell(year_wanderbell: Int, month_wanderbell: Int) {
        // 获取当前登录用户的日历数据
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let userId_wanderbell = currentUser_wanderbell.userId_Wanderbell
        
        monthlyEmotions_Wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getEmotionCalendarData_Wanderbell(
            year_wanderbell: year_wanderbell,
            month_wanderbell: month_wanderbell,
            userId_wanderbell: userId_wanderbell
        )
        calendar_Wanderbell.reloadData()
    }
    
    // MARK: - 事件处理
    
    @objc private func handleEmotionStateChange_Wanderbell() {
        loadCurrentMonthData_Wanderbell()
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - FSCalendarDelegate

extension EmotionCalendar_Wanderbell: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        onDateSelected_Wanderbell?(date)
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let components_wanderbell = Calendar.current.dateComponents([.year, .month], from: calendar.currentPage)
        if let year_wanderbell = components_wanderbell.year,
           let month_wanderbell = components_wanderbell.month {
            loadMonthData_Wanderbell(year_wanderbell: year_wanderbell, month_wanderbell: month_wanderbell)
        }
    }
}

// MARK: - FSCalendarDataSource

extension EmotionCalendar_Wanderbell: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let calendar_wanderbell = Calendar.current
        let dateKey_wanderbell = calendar_wanderbell.startOfDay(for: date)
        return monthlyEmotions_Wanderbell[dateKey_wanderbell] != nil ? 1 : 0
    }
}

// MARK: - FSCalendarDelegateAppearance

extension EmotionCalendar_Wanderbell: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let calendar_wanderbell = Calendar.current
        let dateKey_wanderbell = calendar_wanderbell.startOfDay(for: date)
        
        if let emotionType_wanderbell = monthlyEmotions_Wanderbell[dateKey_wanderbell] {
            return [emotionType_wanderbell.getColor_Wanderbell()]
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let calendar_wanderbell = Calendar.current
        let dateKey_wanderbell = calendar_wanderbell.startOfDay(for: date)
        
        if let emotionType_wanderbell = monthlyEmotions_Wanderbell[dateKey_wanderbell] {
            return emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.2)
        }
        
        return nil
    }
}
