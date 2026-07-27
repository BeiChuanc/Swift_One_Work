import Foundation
import UIKit

// MARK: 每日任务 ViewModel

/// 每日任务状态管理类
/// 核心作用：追踪"浏览帖子/点赞帖子/发布帖子/打卡/查看用户资料"五类每日任务的完成进度，
///           按日期自动重置，任务进度变化时广播通知供首页任务区块刷新
/// 设计思路：
///   打卡任务直接读取 UserViewModel_Tidy 的打卡状态，不单独计数，避免与打卡逻辑重复维护；
///   其余四类任务通过 UserDefaults 按"日期 + 类型"持久化计数，跨天自动清零；
///   每类任务达到 targetCount_Tidy 后不再继续累加，避免重复弹出完成提示。
/// 关键属性/方法：
///   - taskProgressDidChangeNotification_Tidy：任务进度变更通知
///   - recordEvent_Tidy：记录一次任务事件（浏览/点赞/发布/查看资料触发时调用）
///   - getAllTasks_Tidy / getCompletedSummary_Tidy：首页任务区块渲染所需的数据
@MainActor
class TaskViewModel_Tidy {

    /// 单例
    static let shared_Tidy = TaskViewModel_Tidy()

    /// 任务进度变更通知
    static let taskProgressDidChangeNotification_Tidy = Notification.Name("TaskProgressDidChange_Tidy")

    /// UserDefaults 任务计数存储 Key
    private let kTaskCounts_Tidy = "Tidy_DailyTaskCounts_v1"
    /// UserDefaults 任务计数所属日期存储 Key
    private let kTaskDate_Tidy = "Tidy_DailyTaskDate_v1"

    private init() {}

    // MARK: - 日期与存储

    /// 获取今天的日期字符串（格式：yyyy-MM-dd）
    private func todayString_Tidy() -> String {
        let formatter_tidy = DateFormatter()
        formatter_tidy.dateFormat = "yyyy-MM-dd"
        return formatter_tidy.string(from: Date())
    }

    /// 若与上次记录不是同一天，则清空所有任务计数（打卡数据由 UserViewModel 单独持久化，不受影响）
    private func resetIfNewDay_Tidy() {
        let today_tidy = todayString_Tidy()
        guard UserDefaults.standard.string(forKey: kTaskDate_Tidy) != today_tidy else { return }
        UserDefaults.standard.removeObject(forKey: kTaskCounts_Tidy)
        UserDefaults.standard.set(today_tidy, forKey: kTaskDate_Tidy)
    }

    /// 读取今日任务计数字典
    private func getCounts_Tidy() -> [String: Int] {
        resetIfNewDay_Tidy()
        return UserDefaults.standard.dictionary(forKey: kTaskCounts_Tidy) as? [String: Int] ?? [:]
    }

    /// 写入今日任务计数字典
    private func setCounts_Tidy(_ counts_tidy: [String: Int]) {
        UserDefaults.standard.set(counts_tidy, forKey: kTaskCounts_Tidy)
    }

    // MARK: - 进度查询

    /// 获取指定任务今日已完成次数
    /// 参数：
    /// - type_tidy: 任务类型
    /// 返回值：已完成次数（不超过目标次数）
    func getProgress_Tidy(type_tidy: DailyTaskType_Tidy) -> Int {
        if type_tidy == .checkin_tidy {
            return UserViewModel_Tidy.shared_Tidy.hasCheckedInToday_Tidy() ? 1 : 0
        }
        let counts_tidy = getCounts_Tidy()
        return min(counts_tidy[type_tidy.rawValue] ?? 0, type_tidy.targetCount_Tidy)
    }

    /// 判断指定任务今日是否已达标完成
    /// 参数：
    /// - type_tidy: 任务类型
    func isCompleted_Tidy(type_tidy: DailyTaskType_Tidy) -> Bool {
        getProgress_Tidy(type_tidy: type_tidy) >= type_tidy.targetCount_Tidy
    }

    /// 获取全部任务的展示列表（供首页任务区块渲染，按枚举声明顺序：打卡→浏览→点赞→查看资料→发布）
    func getAllTasks_Tidy() -> [DailyTaskItem_Tidy] {
        DailyTaskType_Tidy.allCases.map {
            DailyTaskItem_Tidy(type_Tidy: $0, progress_Tidy: getProgress_Tidy(type_tidy: $0))
        }
    }

    /// 获取今日已完成任务数 / 任务总数（供首页展示整体完成度）
    func getCompletedSummary_Tidy() -> (completed_Tidy: Int, total_Tidy: Int) {
        let all_tidy = DailyTaskType_Tidy.allCases
        let completed_tidy = all_tidy.filter { isCompleted_Tidy(type_tidy: $0) }.count
        return (completed_tidy, all_tidy.count)
    }

    // MARK: - 事件记录

    /// 记录一次任务事件，自动截断到目标次数；首次达标时弹出完成提示并广播进度变更通知
    /// 参数：
    /// - type_tidy: 任务类型（打卡任务由 UserViewModel 单独维护打卡状态，调用本方法会被忽略）
    func recordEvent_Tidy(type_tidy: DailyTaskType_Tidy) {
        guard type_tidy != .checkin_tidy else { return }

        var counts_tidy = getCounts_Tidy()
        let current_tidy = counts_tidy[type_tidy.rawValue] ?? 0
        // 已达标则不再继续累加，避免超额计数与重复的完成提示
        guard current_tidy < type_tidy.targetCount_Tidy else { return }

        let newValue_tidy = current_tidy + 1
        counts_tidy[type_tidy.rawValue] = newValue_tidy
        setCounts_Tidy(counts_tidy)

        if newValue_tidy >= type_tidy.targetCount_Tidy {
            Utils_Tidy.showSuccess_Tidy(message_Tidy: "\(type_tidy.title_Tidy) completed! 🎉")
        }
        notifyChange_Tidy()
    }

    /// 广播任务进度变更通知
    func notifyChange_Tidy() {
        NotificationCenter.default.post(
            name: TaskViewModel_Tidy.taskProgressDidChangeNotification_Tidy, object: nil
        )
    }
}
