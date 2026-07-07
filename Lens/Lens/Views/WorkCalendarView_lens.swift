import UIKit
import SnapKit

// MARK: - 可展开作品日历

/// WorkCalendarView_Lens
/// 功能：首页作品日历，支持折叠近 7 天条与展开当月完整网格
/// 设计：固定行高网格，动态计算展开高度，避免末行被拉伸
class WorkCalendarView_Lens: UIView {

    /// 日期选中回调 yyyy-MM-dd
    var onDateSelected_Lens: ((String) -> Void)?

    /// 展开状态变化回调（内容区目标高度，不含卡片内边距）
    var onHeightChanged_Lens: ((CGFloat) -> Void)?

    private var activeDays_Lens = Set<String>()
    private var displayMonth_Lens = Date()
    private var selectedDateKey_Lens: String?
    private var isExpanded_Lens = false
    private var monthRowCount_Lens = 6

    private let headerContainer_Lens = UIView()

    private let monthNavRow_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.distribution = .equalCentering
        s.spacing = 12
        s.isHidden = true
        return s
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "WORK CALENDAR"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        return l
    }()

    private let monthLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.75)
        l.textAlignment = .center
        return l
    }()

    private let expandButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.down", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = UIColor(hexstring_Lens: "#4D96FF")
        b.backgroundColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.12)
        b.layer.cornerRadius = 14
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()

    private let prevMonthButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        return b
    }()

    private let nextMonthButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "chevron.right", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        return b
    }()

    private let weekStripStack_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 6
        return s
    }()

    private let weekdayHeaderStack_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 4
        s.isHidden = true
        return s
    }()

    private let monthGridStack_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 4
        s.distribution = .fill
        s.isHidden = true
        return s
    }()

    private var monthGridHeightConstraint_Lens: Constraint?

    private let dateFormatter_Lens: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// 折叠内容高度
    static let collapsedHeight_Lens: CGFloat = 84

    /// 网格单行高度
    private static let gridRowHeight_Lens: CGFloat = 34

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 初始化子视图与事件绑定
    private func setupUI_Lens() {
        addSubview(headerContainer_Lens)
        headerContainer_Lens.addSubview(titleLabel_Lens)
        headerContainer_Lens.addSubview(expandButton_Lens)
        addSubview(monthNavRow_Lens)
        addSubview(weekStripStack_Lens)
        addSubview(weekdayHeaderStack_Lens)
        addSubview(monthGridStack_Lens)

        monthNavRow_Lens.addArrangedSubview(prevMonthButton_Lens)
        monthNavRow_Lens.addArrangedSubview(monthLabel_Lens)
        monthNavRow_Lens.addArrangedSubview(nextMonthButton_Lens)

        expandButton_Lens.addTarget(self, action: #selector(toggleExpand_Lens), for: .touchUpInside)
        prevMonthButton_Lens.addTarget(self, action: #selector(prevMonthTapped_Lens), for: .touchUpInside)
        nextMonthButton_Lens.addTarget(self, action: #selector(nextMonthTapped_Lens), for: .touchUpInside)

        let weekdaySymbols_Lens = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for symbol_Lens in weekdaySymbols_Lens {
            weekdayHeaderStack_Lens.addArrangedSubview(makeWeekdayLabel_Lens(text_Lens: symbol_Lens))
        }

        headerContainer_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(expandButton_Lens.snp.leading).offset(-8)
        }
        expandButton_Lens.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        monthNavRow_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(headerContainer_Lens.snp.bottom).offset(8)
            $0.height.equalTo(28)
        }
        prevMonthButton_Lens.snp.makeConstraints { $0.width.height.equalTo(28) }
        nextMonthButton_Lens.snp.makeConstraints { $0.width.height.equalTo(28) }
        weekStripStack_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(headerContainer_Lens.snp.bottom).offset(8)
            $0.height.equalTo(44)
        }
        weekdayHeaderStack_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(monthNavRow_Lens.snp.bottom).offset(6)
            $0.height.equalTo(16)
        }
        monthGridStack_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(weekdayHeaderStack_Lens.snp.bottom).offset(6)
            monthGridHeightConstraint_Lens = $0.height.equalTo(0).constraint
        }

        selectedDateKey_Lens = dateFormatter_Lens.string(from: Date())
        refresh_Lens(activeDays_Lens: [])
    }

    /// 刷新日历数据并重建视图
    func refresh_Lens(activeDays_Lens: Set<String>) {
        self.activeDays_Lens = activeDays_Lens
        if isExpanded_Lens {
            rebuildMonthGrid_Lens()
        } else {
            rebuildWeekStrip_Lens()
        }
        updateMonthTitle_Lens()
        notifyHeight_Lens()
    }

    /// 根据行数计算展开高度
    static func expandedHeight_Lens(rowCount_Lens: Int) -> CGFloat {
        let gridH_Lens = CGFloat(rowCount_Lens) * gridRowHeight_Lens + CGFloat(max(rowCount_Lens - 1, 0)) * 4
        // header 28 + monthNav 8+28 + weekday 6+16 + grid top 6 + grid + bottom 4
        return 28 + 8 + 28 + 6 + 16 + 6 + gridH_Lens + 4
    }

    /// 切换展开/折叠
    @objc private func toggleExpand_Lens() {
        isExpanded_Lens.toggle()
        applyExpandState_Lens(animated_Lens: true)
    }

    /// 应用展开/折叠 UI 状态
    private func applyExpandState_Lens(animated_Lens: Bool) {
        weekStripStack_Lens.isHidden = isExpanded_Lens
        weekdayHeaderStack_Lens.isHidden = !isExpanded_Lens
        monthGridStack_Lens.isHidden = !isExpanded_Lens
        monthNavRow_Lens.isHidden = !isExpanded_Lens

        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let icon_Lens = isExpanded_Lens ? "chevron.up" : "chevron.down"
        expandButton_Lens.setImage(UIImage(systemName: icon_Lens, withConfiguration: cfg_Lens), for: .normal)

        if isExpanded_Lens {
            displayMonth_Lens = Date()
            rebuildMonthGrid_Lens()
            updateMonthTitle_Lens()
        } else {
            rebuildWeekStrip_Lens()
        }
        notifyHeight_Lens()

        if animated_Lens {
            UIView.animate(withDuration: 0.25) { self.superview?.layoutIfNeeded() }
        }
    }

    @objc private func prevMonthTapped_Lens() {
        guard let newMonth_Lens = Calendar.current.date(byAdding: .month, value: -1, to: displayMonth_Lens) else { return }
        displayMonth_Lens = newMonth_Lens
        rebuildMonthGrid_Lens()
        updateMonthTitle_Lens()
        notifyHeight_Lens()
    }

    @objc private func nextMonthTapped_Lens() {
        guard let newMonth_Lens = Calendar.current.date(byAdding: .month, value: 1, to: displayMonth_Lens) else { return }
        displayMonth_Lens = newMonth_Lens
        rebuildMonthGrid_Lens()
        updateMonthTitle_Lens()
        notifyHeight_Lens()
    }

    /// 重建近 7 天横条
    private func rebuildWeekStrip_Lens() {
        weekStripStack_Lens.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let dayFmt_Lens = DateFormatter()
        dayFmt_Lens.dateFormat = "EEE"

        for offset_Lens in (0..<7).reversed() {
            guard let date_Lens = Calendar.current.date(byAdding: .day, value: -offset_Lens, to: Date()) else { continue }
            let key_Lens = dateFormatter_Lens.string(from: date_Lens)
            weekStripStack_Lens.addArrangedSubview(
                makeDayCell_Lens(
                    dateKey_Lens: key_Lens,
                    dayText_Lens: dayFmt_Lens.string(from: date_Lens),
                    dayNum_Lens: Calendar.current.component(.day, from: date_Lens),
                    isActive_Lens: activeDays_Lens.contains(key_Lens),
                    isToday_Lens: offset_Lens == 0,
                    isSelected_Lens: key_Lens == selectedDateKey_Lens,
                    compact_Lens: true
                )
            )
        }
    }

    /// 重建当月网格（固定行高，不拉伸末行）
    private func rebuildMonthGrid_Lens() {
        monthGridStack_Lens.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let calendar_Lens = Calendar.current
        let year_Lens = calendar_Lens.component(.year, from: displayMonth_Lens)
        let month_Lens = calendar_Lens.component(.month, from: displayMonth_Lens)
        var components_Lens = DateComponents()
        components_Lens.year = year_Lens
        components_Lens.month = month_Lens
        components_Lens.day = 1
        guard let firstDay_Lens = calendar_Lens.date(from: components_Lens),
              let range_Lens = calendar_Lens.range(of: .day, in: .month, for: firstDay_Lens) else { return }

        let firstWeekday_Lens = calendar_Lens.component(.weekday, from: firstDay_Lens)
        let leadingBlanks_Lens = firstWeekday_Lens - 1
        var dayIndex_Lens = 1
        let totalCells_Lens = leadingBlanks_Lens + range_Lens.count
        let rowCount_Lens = Int(ceil(Double(totalCells_Lens) / 7.0))
        monthRowCount_Lens = rowCount_Lens

        for row_Lens in 0..<rowCount_Lens {
            let rowStack_Lens = UIStackView()
            rowStack_Lens.axis = .horizontal
            rowStack_Lens.distribution = .fillEqually
            rowStack_Lens.spacing = 4

            for col_Lens in 0..<7 {
                let cellIndex_Lens = row_Lens * 7 + col_Lens
                if cellIndex_Lens < leadingBlanks_Lens || dayIndex_Lens > range_Lens.count {
                    rowStack_Lens.addArrangedSubview(makeBlankCell_Lens())
                } else {
                    components_Lens.day = dayIndex_Lens
                    if let date_Lens = calendar_Lens.date(from: components_Lens) {
                        let key_Lens = dateFormatter_Lens.string(from: date_Lens)
                        rowStack_Lens.addArrangedSubview(
                            makeDayCell_Lens(
                                dateKey_Lens: key_Lens,
                                dayText_Lens: nil,
                                dayNum_Lens: dayIndex_Lens,
                                isActive_Lens: activeDays_Lens.contains(key_Lens),
                                isToday_Lens: calendar_Lens.isDateInToday(date_Lens),
                                isSelected_Lens: key_Lens == selectedDateKey_Lens,
                                compact_Lens: false
                            )
                        )
                    }
                    dayIndex_Lens += 1
                }
            }
            monthGridStack_Lens.addArrangedSubview(rowStack_Lens)
            rowStack_Lens.snp.makeConstraints { $0.height.equalTo(Self.gridRowHeight_Lens) }
        }

        let gridH_Lens = CGFloat(rowCount_Lens) * Self.gridRowHeight_Lens + CGFloat(max(rowCount_Lens - 1, 0)) * 4
        monthGridHeightConstraint_Lens?.update(offset: gridH_Lens)
    }

    /// 更新月份标题
    private func updateMonthTitle_Lens() {
        let fmt_Lens = DateFormatter()
        fmt_Lens.dateFormat = "MMMM yyyy"
        monthLabel_Lens.text = fmt_Lens.string(from: displayMonth_Lens)
    }

    /// 通知外部高度变化
    private func notifyHeight_Lens() {
        let height_Lens = isExpanded_Lens
            ? Self.expandedHeight_Lens(rowCount_Lens: monthRowCount_Lens)
            : Self.collapsedHeight_Lens
        onHeightChanged_Lens?(height_Lens)
    }

    /// 创建空白占位格
    private func makeBlankCell_Lens() -> UIView {
        let v_Lens = UIView()
        v_Lens.backgroundColor = .clear
        v_Lens.snp.makeConstraints { $0.height.equalTo(Self.gridRowHeight_Lens) }
        return v_Lens
    }

    /// 创建星期标题
    private func makeWeekdayLabel_Lens(text_Lens: String) -> UILabel {
        let l_Lens = UILabel()
        l_Lens.text = text_Lens
        l_Lens.font = .systemFont(ofSize: 9, weight: .semibold)
        l_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        l_Lens.textAlignment = .center
        return l_Lens
    }

    /// 创建可点击日期单元格
    private func makeDayCell_Lens(
        dateKey_Lens: String,
        dayText_Lens: String?,
        dayNum_Lens: Int,
        isActive_Lens: Bool,
        isToday_Lens: Bool,
        isSelected_Lens: Bool,
        compact_Lens: Bool
    ) -> UIView {
        let v_Lens = UIView()
        v_Lens.layer.cornerRadius = compact_Lens ? 10 : 8
        v_Lens.backgroundColor = isSelected_Lens
            ? UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.35)
            : (isToday_Lens
                ? UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.18)
                : UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.04))
        v_Lens.isUserInteractionEnabled = true

        if let dayText_Lens {
            let dayLbl_Lens = UILabel()
            dayLbl_Lens.text = dayText_Lens
            dayLbl_Lens.font = .systemFont(ofSize: 9, weight: .medium)
            dayLbl_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
            dayLbl_Lens.textAlignment = .center
            v_Lens.addSubview(dayLbl_Lens)
            dayLbl_Lens.snp.makeConstraints { $0.top.equalToSuperview().offset(3); $0.centerX.equalToSuperview() }
        }

        let numLbl_Lens = UILabel()
        numLbl_Lens.text = "\(dayNum_Lens)"
        numLbl_Lens.font = .systemFont(ofSize: compact_Lens ? 14 : 12, weight: .bold)
        numLbl_Lens.textColor = isSelected_Lens || isToday_Lens
            ? .white
            : UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.7)
        numLbl_Lens.textAlignment = .center
        v_Lens.addSubview(numLbl_Lens)
        numLbl_Lens.snp.makeConstraints {
            if compact_Lens {
                $0.center.equalToSuperview()
            } else {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-1)
            }
        }

        let dot_Lens = UIView()
        dot_Lens.layer.cornerRadius = 2.5
        dot_Lens.backgroundColor = isActive_Lens
            ? UIColor(hexstring_Lens: "#4D96FF")
            : .clear
        v_Lens.addSubview(dot_Lens)
        dot_Lens.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(compact_Lens ? 4 : 3)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(5)
        }

        if !compact_Lens {
            v_Lens.snp.makeConstraints { $0.height.equalTo(Self.gridRowHeight_Lens) }
        }

        let tap_Lens = DayCellTapGesture_Lens(dateKey_Lens: dateKey_Lens, target_Lens: self, action_Lens: #selector(dayCellTapped_Lens(_:)))
        v_Lens.addGestureRecognizer(tap_Lens)
        return v_Lens
    }

    /// 日期点击处理
    @objc private func dayCellTapped_Lens(_ gesture_Lens: DayCellTapGesture_Lens) {
        selectedDateKey_Lens = gesture_Lens.dateKey_Lens
        if isExpanded_Lens {
            rebuildMonthGrid_Lens()
        } else {
            rebuildWeekStrip_Lens()
        }
        onDateSelected_Lens?(gesture_Lens.dateKey_Lens)
    }
}

/// DayCellTapGesture_Lens：携带日期键的手势识别器
private class DayCellTapGesture_Lens: UITapGestureRecognizer {
    let dateKey_Lens: String

    init(dateKey_Lens: String, target_Lens: Any?, action_Lens: Selector?) {
        self.dateKey_Lens = dateKey_Lens
        super.init(target: target_Lens, action: action_Lens)
    }
}
