import Foundation

// MARK: 打卡 ViewModel

/// 打卡状态管理类
/// 功能：管理用户每日 OOTD 打卡记录，计算连续签到天数，提供本周日历数据
/// 持久化：使用 UserDefaults 保存打卡记录，App 重启后保留
@MainActor
class CheckInViewModel_Vestir {

    // MARK: - 单例与通知

    static let shared_Vestir = CheckInViewModel_Vestir()
    static let checkInStateDidChangeNotification_Vestir =
        Notification.Name("CheckInStateDidChange_Vestir")

    // MARK: - 私有存储

    private var checkIns_Vestir: [DailyCheckIn_Vestir] = []
    private static let storageKey_Vestir = "vestir_checkIns_v1"

    private init() {
        loadFromStorage_Vestir()
    }

    // MARK: - 日期工具

    /// 今日日期字符串（yyyy-MM-dd）
    var todayString_Vestir: String {
        dateString_Vestir(from: Date())
    }

    /// 将 Date 转为 yyyy-MM-dd 字符串
    func dateString_Vestir(from date_vestir: Date) -> String {
        let f_Vestir = DateFormatter()
        f_Vestir.dateFormat = "yyyy-MM-dd"
        return f_Vestir.string(from: date_vestir)
    }

    // MARK: - 打卡状态

    /// 今日打卡记录（nil 表示尚未打卡）
    var todayCheckIn_Vestir: DailyCheckIn_Vestir? {
        checkIns_Vestir.first { $0.date_Vestir == todayString_Vestir }
    }

    /// 今日是否已打卡
    var isCheckedInToday_Vestir: Bool { todayCheckIn_Vestir != nil }

    /// 当前连续签到天数
    var streakCount_Vestir: Int {
        let calendar_Vestir = Calendar.current
        var streak_Vestir = isCheckedInToday_Vestir ? 1 : 0
        var checkDate_Vestir = calendar_Vestir.date(
            byAdding: .day, value: -1, to: Date()
        ) ?? Date()

        for _ in 0..<90 {
            let dateStr_Vestir = dateString_Vestir(from: checkDate_Vestir)
            if checkIns_Vestir.contains(where: { $0.date_Vestir == dateStr_Vestir }) {
                streak_Vestir += 1
                checkDate_Vestir = calendar_Vestir.date(
                    byAdding: .day, value: -1, to: checkDate_Vestir
                ) ?? checkDate_Vestir
            } else {
                break
            }
        }
        return streak_Vestir
    }

    /// 获取指定日期的打卡记录
    func getCheckIn_Vestir(for dateString_vestir: String) -> DailyCheckIn_Vestir? {
        checkIns_Vestir.first { $0.date_Vestir == dateString_vestir }
    }

    /// 获取所有打卡记录（按日期降序）
    func getAllCheckIns_Vestir() -> [DailyCheckIn_Vestir] {
        checkIns_Vestir.sorted { $0.date_Vestir > $1.date_Vestir }
    }

    /// 删除指定日期的打卡记录
    /// 参数：
    /// - dateString_vestir: 要删除的打卡日期（"yyyy-MM-dd"）
    func deleteCheckIn_Vestir(dateString_vestir: String) {
        checkIns_Vestir.removeAll { $0.date_Vestir == dateString_vestir }
        saveToStorage_Vestir()
        notifyStateChange_Vestir()
    }

    // MARK: - 打卡操作

    /// 执行今日打卡
    /// 参数：媒体路径、品牌、色系、版型、场景、气温
    func performCheckIn_Vestir(
        mediaPath_vestir: String,
        brand_vestir: String?,
        colorTheme_vestir: String?,
        outfitStyle_vestir: String?,
        occasion_vestir: String?,
        temperature_vestir: String?
    ) {
        let checkIn_Vestir = DailyCheckIn_Vestir(
            date_Vestir: todayString_Vestir,
            mediaPath_Vestir: mediaPath_vestir,
            brand_Vestir: brand_vestir,
            colorTheme_Vestir: colorTheme_vestir,
            outfitStyle_Vestir: outfitStyle_vestir,
            occasion_Vestir: occasion_vestir,
            temperature_Vestir: temperature_vestir
        )
        // 覆盖当天已有记录
        checkIns_Vestir.removeAll { $0.date_Vestir == todayString_Vestir }
        checkIns_Vestir.append(checkIn_Vestir)
        saveToStorage_Vestir()
        notifyStateChange_Vestir()
    }

    // MARK: - 周日历数据

    /// 返回当前周的 7 个日期字符串（周一 → 周日）
    func currentWeekDates_Vestir() -> [String] {
        let calendar_Vestir = Calendar.current
        let today_Vestir = Date()
        // weekday: 1=Sun, 2=Mon … 7=Sat → daysFromMonday
        let weekday_Vestir = calendar_Vestir.component(.weekday, from: today_Vestir)
        let daysFromMonday_Vestir = (weekday_Vestir - 2 + 7) % 7

        return (0..<7).compactMap { i_Vestir in
            calendar_Vestir.date(
                byAdding: .day,
                value: i_Vestir - daysFromMonday_Vestir,
                to: today_Vestir
            ).map { dateString_Vestir(from: $0) }
        }
    }

    /// 从日期字符串提取英文缩写（Mon / Tue …）
    func dayAbbr_Vestir(from dateString_vestir: String) -> String {
        let f1_Vestir = DateFormatter()
        f1_Vestir.dateFormat = "yyyy-MM-dd"
        guard let date_Vestir = f1_Vestir.date(from: dateString_vestir) else { return "" }
        let f2_Vestir = DateFormatter()
        f2_Vestir.dateFormat = "EEE"
        return f2_Vestir.string(from: date_Vestir)
    }

    /// 从日期字符串提取日期数字（1～31）
    func dayNumber_Vestir(from dateString_vestir: String) -> String {
        let f1_Vestir = DateFormatter()
        f1_Vestir.dateFormat = "yyyy-MM-dd"
        guard let date_Vestir = f1_Vestir.date(from: dateString_vestir) else { return "" }
        let f2_Vestir = DateFormatter()
        f2_Vestir.dateFormat = "d"
        return f2_Vestir.string(from: date_Vestir)
    }

    // MARK: - 持久化

    private func notifyStateChange_Vestir() {
        NotificationCenter.default.post(
            name: CheckInViewModel_Vestir.checkInStateDidChangeNotification_Vestir,
            object: nil
        )
    }

    private func loadFromStorage_Vestir() {
        guard
            let data_Vestir = UserDefaults.standard.data(
                forKey: CheckInViewModel_Vestir.storageKey_Vestir
            ),
            let decoded_Vestir = try? JSONDecoder().decode(
                [DailyCheckIn_Vestir].self, from: data_Vestir
            )
        else { return }
        checkIns_Vestir = decoded_Vestir
    }

    private func saveToStorage_Vestir() {
        guard let data_Vestir = try? JSONEncoder().encode(checkIns_Vestir) else { return }
        UserDefaults.standard.set(data_Vestir, forKey: CheckInViewModel_Vestir.storageKey_Vestir)
    }
}
