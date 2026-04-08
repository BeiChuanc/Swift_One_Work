import Foundation
import UIKit

// MARK: - 梦境数据 ViewModel

/// 梦境数据管理 ViewModel
/// 核心功能：统一管理梦境册、梦境记录、梦物图腾和噩梦追踪，数据来源为当前登录用户的模型字段
/// 持久化策略：以 userId 为键将数据写入 UserDefaults，同时同步写回 UserViewModel 的用户模型
/// 关键方法：createBook / addRecord / addTotem / nightmareStats / reloadForCurrentUser
class DreamViewModel_Somnia: NSObject {

    // MARK: - 单例

    /// 全局单例
    static let shared_Somnia = DreamViewModel_Somnia()

    /// 数据变更通知名称，UI 层监听此通知刷新界面
    static let dreamStateDidChangeNotification_Somnia = Notification.Name("DreamStateDidChange_Somnia")

    // MARK: - 私有数据

    private var dreamBooks_Somnia: [DreamBookModel_Somnia] = []
    private var dreamRecords_Somnia: [DreamRecordModel_Somnia] = []
    private var dreamTotems_Somnia: [DreamTotemModel_Somnia] = []
    /// 全局每日打卡时间戳列表（每天最多记录一次）
    private var dailyCheckInDates_Somnia: [Double] = []

    // MARK: - 初始化

    private override init() {
        super.init()
        loadForCurrentUser_Somnia()
        // 监听用户登录/登出，自动切换当前用户的梦境数据
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserStateChanged_Somnia),
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 用户状态变更响应

    /// 用户登录/登出时重新加载对应用户的梦境数据
    @objc private func onUserStateChanged_Somnia() {
        loadForCurrentUser_Somnia()
        notifyChange_Somnia()
    }

    // MARK: - 数据加载（按用户隔离）

    /// 加载当前登录用户的梦境数据
    /// 优先从用户模型读取，若为空则尝试从 UserDefaults 按 userId 恢复
    func loadForCurrentUser_Somnia() {
        let user = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()

        // 优先使用用户模型中已有的数据（非空时直接用）
        if !user.userDreamBooks_Somnia.isEmpty || !user.userDreamRecords_Somnia.isEmpty {
            dreamBooks_Somnia        = user.userDreamBooks_Somnia
            dreamRecords_Somnia      = user.userDreamRecords_Somnia
            dreamTotems_Somnia       = user.userDreamTotems_Somnia
            dailyCheckInDates_Somnia = user.dailyCheckInDates_Somnia
            return
        }

        // 用户模型为空时，尝试从 UserDefaults（按 userId 键）恢复
        let uid = user.userId_Somnia ?? 0
        let booksKey    = "somnia_dream_books_uid\(uid)"
        let recordsKey  = "somnia_dream_records_uid\(uid)"
        let totemsKey   = "somnia_dream_totems_uid\(uid)"
        let checkInKey  = "somnia_daily_checkin_uid\(uid)"

        dreamBooks_Somnia = (try? JSONDecoder().decode(
            [DreamBookModel_Somnia].self,
            from: UserDefaults.standard.data(forKey: booksKey) ?? Data()
        )) ?? []

        dreamRecords_Somnia = (try? JSONDecoder().decode(
            [DreamRecordModel_Somnia].self,
            from: UserDefaults.standard.data(forKey: recordsKey) ?? Data()
        )) ?? []

        dreamTotems_Somnia = (try? JSONDecoder().decode(
            [DreamTotemModel_Somnia].self,
            from: UserDefaults.standard.data(forKey: totemsKey) ?? Data()
        )) ?? []

        dailyCheckInDates_Somnia = (try? JSONDecoder().decode(
            [Double].self,
            from: UserDefaults.standard.data(forKey: checkInKey) ?? Data()
        )) ?? []

        // 将恢复的数据同步写回用户模型
        syncBackToUserModel_Somnia()
    }

    // MARK: - 持久化

    /// 将当前数据持久化到 UserDefaults（按 userId 隔离）并同步写回用户模型
    private func saveCurrentUserData_Somnia() {
        let uid = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia().userId_Somnia ?? 0
        let booksKey   = "somnia_dream_books_uid\(uid)"
        let recordsKey = "somnia_dream_records_uid\(uid)"
        let totemsKey  = "somnia_dream_totems_uid\(uid)"
        let checkInKey = "somnia_daily_checkin_uid\(uid)"

        if let data = try? JSONEncoder().encode(dreamBooks_Somnia) {
            UserDefaults.standard.set(data, forKey: booksKey)
        }
        if let data = try? JSONEncoder().encode(dreamRecords_Somnia) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
        if let data = try? JSONEncoder().encode(dreamTotems_Somnia) {
            UserDefaults.standard.set(data, forKey: totemsKey)
        }
        if let data = try? JSONEncoder().encode(dailyCheckInDates_Somnia) {
            UserDefaults.standard.set(data, forKey: checkInKey)
        }

        syncBackToUserModel_Somnia()
    }

    /// 将当前梦境数据同步写回 UserViewModel 的用户模型
    private func syncBackToUserModel_Somnia() {
        UserViewModel_Somnia.shared_Somnia.updateDreamData_Somnia(
            books_somnia: dreamBooks_Somnia,
            records_somnia: dreamRecords_Somnia,
            totems_somnia: dreamTotems_Somnia,
            checkInDates_somnia: dailyCheckInDates_Somnia
        )
    }

    // MARK: - 梦境册管理

    /// 获取所有梦境册（按创建时间倒序）
    /// - Returns: 排序后的梦境册数组，未有数据则返回空数组
    func getAllBooks_Somnia() -> [DreamBookModel_Somnia] {
        return dreamBooks_Somnia.sorted { $0.createdAt_Somnia > $1.createdAt_Somnia }
    }

    /// 创建新梦境册
    /// - Parameters:
    ///   - title_somnia: 梦境册名称
    ///   - icon_somnia: 封面图标（SF Symbol 名）
    ///   - colorHex_somnia: 主题色十六进制字符串
    func createBook_Somnia(title_somnia: String, icon_somnia: String, colorHex_somnia: String) {
        let book = DreamBookModel_Somnia(
            bookId_Somnia: UUID().uuidString,
            bookTitle_Somnia: title_somnia,
            bookIcon_Somnia: icon_somnia,
            bookColorHex_Somnia: colorHex_somnia
        )
        dreamBooks_Somnia.insert(book, at: 0)
        saveCurrentUserData_Somnia()
        notifyChange_Somnia()
    }

    // MARK: - 梦境记录管理

    /// 获取最新梦境记录（按时间倒序）
    /// - Parameter limit_somnia: 最大返回条数，默认 10；无数据则返回空数组
    func getRecentRecords_Somnia(limit_somnia: Int = 10) -> [DreamRecordModel_Somnia] {
        return Array(
            dreamRecords_Somnia
                .sorted { $0.recordTimestamp_Somnia > $1.recordTimestamp_Somnia }
                .prefix(limit_somnia)
        )
    }

    /// 获取属于同一梦系列的所有记录（按时间升序）
    /// - Parameter seriesId_somnia: 系列ID
    func getSeriesRecords_Somnia(seriesId_somnia: String) -> [DreamRecordModel_Somnia] {
        return dreamRecords_Somnia
            .filter { $0.seriesId_Somnia == seriesId_somnia || $0.recordId_Somnia == seriesId_somnia }
            .sorted { $0.recordTimestamp_Somnia < $1.recordTimestamp_Somnia }
    }

    /// 添加新梦境记录
    /// 自动计算月亮相位注入梦痕时间戳，自动收集标签中的梦物，支持续梦串联梦系列
    /// - Parameters:
    ///   - bookId_somnia: 所属梦境册ID，若传入 ID 的册不存在则不更新计数
    ///   - content_somnia: 梦境内容文字
    ///   - sleepTime_somnia: 入睡时间字符串（如 "23:00"），创建后不可修改
    ///   - emotionKeyword_somnia: 情绪关键词，创建后不可修改
    ///   - isNightmare_somnia: 是否为噩梦
    ///   - isDontDream_somnia: 是否标记为「不想再梦」
    ///   - totemTags_somnia: 本梦出现的梦物名称列表
    ///   - parentRecordId_somnia: 续梦时传入源记录 ID，nil 表示独立新梦
    func addRecord_Somnia(
        bookId_somnia: String,
        content_somnia: String,
        sleepTime_somnia: String,
        emotionKeyword_somnia: String,
        isNightmare_somnia: Bool,
        isDontDream_somnia: Bool,
        totemTags_somnia: [String],
        parentRecordId_somnia: String? = nil
    ) {
        let moonPhase = calculateMoonPhase_Somnia(date_somnia: Date())

        // 续梦：沿用源梦的 seriesId，若源梦无系列则以其 recordId 作为新系列 ID
        var seriesId: String? = nil
        if let parentId = parentRecordId_somnia,
           let parent = dreamRecords_Somnia.first(where: { $0.recordId_Somnia == parentId }) {
            seriesId = parent.seriesId_Somnia ?? parentId
        }

        let record = DreamRecordModel_Somnia(
            recordId_Somnia: UUID().uuidString,
            bookId_Somnia: bookId_somnia,
            content_Somnia: content_somnia,
            sleepTime_Somnia: sleepTime_somnia,
            moonPhase_Somnia: moonPhase,
            emotionKeyword_Somnia: emotionKeyword_somnia,
            recordTimestamp_Somnia: Date().timeIntervalSince1970,
            seriesId_Somnia: seriesId,
            parentRecordId_Somnia: parentRecordId_somnia,
            isNightmare_Somnia: isNightmare_somnia,
            isDontDream_Somnia: isDontDream_somnia,
            totemTags_Somnia: totemTags_somnia
        )
        dreamRecords_Somnia.insert(record, at: 0)

        // 更新所属梦境册计数
        if let idx = dreamBooks_Somnia.firstIndex(where: { $0.bookId_Somnia == bookId_somnia }) {
            dreamBooks_Somnia[idx].dreamCount_Somnia += 1
        }

        // 自动收集标签中的梦物
        collectTotems_Somnia(fromTags_somnia: totemTags_somnia)

        // 记录梦境时自动完成今日全局打卡（无需用户手动触发）
        performDailyCheckIn_Somnia()

        saveCurrentUserData_Somnia()
        notifyChange_Somnia()
    }

    // MARK: - 全局每日打卡管理

    /// 手动触发今日全局打卡（每天仅限一次）
    /// - Returns: true=本次打卡成功；false=今天已打过
    @discardableResult
    func checkInToday_Somnia() -> Bool {
        let result = performDailyCheckIn_Somnia()
        if result {
            saveCurrentUserData_Somnia()
            notifyChange_Somnia()
        }
        return result
    }

    /// 判断今天是否已全局打卡
    func isDailyCheckedInToday_Somnia() -> Bool {
        let today = startOfDay_Somnia(date_somnia: Date())
        return dailyCheckInDates_Somnia.contains {
            startOfDay_Somnia(timestamp_somnia: $0) == today
        }
    }

    /// 计算当前全局连续打卡天数（从今天往前倒推，遇断层停止）
    /// - Returns: 连续天数，至少为 0
    func getDailyCheckInStreak_Somnia() -> Int {
        guard !dailyCheckInDates_Somnia.isEmpty else { return 0 }
        let calendar = Calendar.current
        // 将所有打卡时间去重、取整为0点、倒序
        let days: [Date] = Array(
            Set(dailyCheckInDates_Somnia.map { startOfDay_Somnia(timestamp_somnia: $0) })
        ).sorted(by: >)

        var streak = 0
        var checkDate = startOfDay_Somnia(date_somnia: Date())
        for day in days {
            if day == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if day < checkDate {
                break
            }
        }
        return streak
    }

    /// 内部共享打卡逻辑，不触发通知，由调用方决定是否保存
    @discardableResult
    private func performDailyCheckIn_Somnia() -> Bool {
        let today = startOfDay_Somnia(date_somnia: Date())
        let alreadyChecked = dailyCheckInDates_Somnia.contains {
            startOfDay_Somnia(timestamp_somnia: $0) == today
        }
        guard !alreadyChecked else { return false }
        dailyCheckInDates_Somnia.append(Date().timeIntervalSince1970)
        return true
    }

    /// 辅助：将 Date 取整到当天0点（Calendar-aware）
    private func startOfDay_Somnia(date_somnia: Date) -> Date {
        Calendar.current.startOfDay(for: date_somnia)
    }

    /// 辅助：将时间戳转换后取整到当天0点
    private func startOfDay_Somnia(timestamp_somnia: Double) -> Date {
        startOfDay_Somnia(date_somnia: Date(timeIntervalSince1970: timestamp_somnia))
    }

    // MARK: - 月亮相位计算

    /// 根据指定日期计算月亮相位描述字符串（含 Emoji）
    /// - Parameter date_somnia: 目标日期
    /// - Returns: 带 Emoji 的月相字符串，如 "🌕 满月"
    func calculateMoonPhase_Somnia(date_somnia: Date) -> String {
        // 以 2000-01-06 18:14 UTC 为已知新月基准
        let knownNewMoon = Date(timeIntervalSince1970: 947182440)
        let lunarCycle: Double = 29.53058867
        let elapsed = date_somnia.timeIntervalSince(knownNewMoon) / 86400
        let phase = (elapsed.truncatingRemainder(dividingBy: lunarCycle) + lunarCycle)
            .truncatingRemainder(dividingBy: lunarCycle)

        switch phase {
        case 0..<1.85:   return "🌑 新月"
        case 1.85..<7.38:  return "🌒 峨眉月"
        case 7.38..<9.22:  return "🌓 上弦月"
        case 9.22..<14.77: return "🌔 盈凸月"
        case 14.77..<16.61: return "🌕 满月"
        case 16.61..<22.15: return "🌖 亏凸月"
        case 22.15..<24.00: return "🌗 下弦月"
        default:           return "🌘 残月"
        }
    }

    // MARK: - 梦物管理

    /// 获取所有梦物（按出现次数倒序）；无数据返回空数组
    func getAllTotems_Somnia() -> [DreamTotemModel_Somnia] {
        return dreamTotems_Somnia.sorted { $0.appearCount_Somnia > $1.appearCount_Somnia }
    }

    /// 手动添加梦物；若同名已存在则累加出现次数
    /// - Parameters:
    ///   - name_somnia: 梦物名称
    ///   - type_somnia: 梦物类型
    ///   - icon_somnia: 展示图标（Emoji）
    func addTotem_Somnia(name_somnia: String, type_somnia: DreamTotemType_Somnia, icon_somnia: String) {
        let now = Date().timeIntervalSince1970
        if let idx = dreamTotems_Somnia.firstIndex(where: { $0.name_Somnia == name_somnia }) {
            dreamTotems_Somnia[idx].appearCount_Somnia += 1
            dreamTotems_Somnia[idx].lastSeenTimestamp_Somnia = now
        } else {
            let totem = DreamTotemModel_Somnia(
                totemId_Somnia: UUID().uuidString,
                name_Somnia: name_somnia,
                type_Somnia: type_somnia,
                appearCount_Somnia: 1,
                firstSeenTimestamp_Somnia: now,
                lastSeenTimestamp_Somnia: now,
                icon_Somnia: icon_somnia
            )
            dreamTotems_Somnia.append(totem)
        }
        saveCurrentUserData_Somnia()
        notifyChange_Somnia()
    }

    /// 从梦境记录的标签列表自动收集梦物（内部调用，不触发额外通知）
    private func collectTotems_Somnia(fromTags_somnia: [String]) {
        let now = Date().timeIntervalSince1970
        for tag in fromTags_somnia {
            if let idx = dreamTotems_Somnia.firstIndex(where: { $0.name_Somnia == tag }) {
                dreamTotems_Somnia[idx].appearCount_Somnia += 1
                dreamTotems_Somnia[idx].lastSeenTimestamp_Somnia = now
            } else {
                let totem = DreamTotemModel_Somnia(
                    totemId_Somnia: UUID().uuidString,
                    name_Somnia: tag,
                    type_Somnia: .object_Somnia,
                    appearCount_Somnia: 1,
                    firstSeenTimestamp_Somnia: now,
                    lastSeenTimestamp_Somnia: now,
                    icon_Somnia: "✨"
                )
                dreamTotems_Somnia.append(totem)
            }
        }
    }

    // MARK: - 噩梦统计

    /// 获取最近 N 天内的噩梦数量
    /// - Parameter days_somnia: 统计天数，默认 7 天；无数据则返回 0
    func getRecentNightmareCount_Somnia(days_somnia: Int = 7) -> Int {
        let cutoff = Date().timeIntervalSince1970 - Double(days_somnia) * 86400
        return dreamRecords_Somnia.filter {
            $0.isNightmare_Somnia && $0.recordTimestamp_Somnia >= cutoff
        }.count
    }

    /// 根据近期噩梦频率生成放松建议文案
    /// - Returns: 建议字符串；近 7 天无噩梦返回 nil
    func getNightmareSuggestion_Somnia() -> String? {
        let count = getRecentNightmareCount_Somnia(days_somnia: 7)
        guard count > 0 else { return nil }

        let suggestions = [
            "Try 4-7-8 breathing (inhale 4s, hold 7s, exhale 8s) before sleep.",
            "Write down your worries in a journal before bed to quiet the mind.",
            "Avoid screens 30 minutes before sleep — try soft music instead.",
            "A warm bath or shower can lower stress hormones before bedtime.",
            "Try 5 minutes of body-scan meditation to fully relax before sleep."
        ]
        let index = min(count - 1, suggestions.count - 1)
        return suggestions[index]
    }

    // MARK: - 通知

    /// 发送数据变更通知，触发 UI 刷新
    private func notifyChange_Somnia() {
        NotificationCenter.default.post(
            name: DreamViewModel_Somnia.dreamStateDidChangeNotification_Somnia,
            object: nil
        )
    }
}
