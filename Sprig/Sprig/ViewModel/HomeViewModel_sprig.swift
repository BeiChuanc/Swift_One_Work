import Foundation
import UIKit

// MARK: 首页 ViewModel

/// 首页状态管理类
/// 功能：负责首页数据供给，包括今日花期轮播、每日养护贴士、养花轨迹、时光胶囊
/// 设计：@MainActor 单例，内部管理养花记录与胶囊状态变化通知
@MainActor
class HomeViewModel_Sprig {

    /// 单例
    static let shared_Sprig = HomeViewModel_Sprig()

    /// 首页状态变化通知名
    static let homeStateDidChangeNotification_Sprig = Notification.Name("HomeStateDidChange_Sprig")

    // MARK: - 养花轨迹

    /// 养花轨迹记录列表（按创建时间倒序，最新在前）
    private(set) var flowerJourney_Sprig: [FlowerStatusRecord_Sprig] = []

    /// 轨迹记录自增ID
    private var nextRecordId_Sprig = 1

    // MARK: - 时光胶囊

    /// 时光胶囊列表
    private(set) var capsules_Sprig: [FlowerCapsule_Sprig] = []

    /// 胶囊自增ID
    private var nextCapsuleId_Sprig = 1

    // MARK: - 私有属性

    /// 每日养护贴士列表（图标, 标题, 内容）
    private let dailyTips_Sprig: [(icon: String, title: String, text: String)] = [
        ("drop.fill",        "Watering Wisdom",     "Water plants in the morning so leaves dry before nightfall, reducing fungal risk."),
        ("sun.max.fill",     "Light Balance",        "Rotate your pots 90° weekly so all sides receive even light for uniform growth."),
        ("leaf.fill",        "Leaf Care",            "Wipe dusty leaves with a damp cloth monthly — clean leaves photosynthesize better."),
        ("thermometer",      "Temperature Tips",     "Most flowering plants prefer 15–22 °C. Keep them away from heating vents and drafts."),
        ("scissors",         "Pruning Power",        "Deadhead spent blooms immediately to redirect energy into new flowers."),
        ("cylinder.split.1x2.fill", "Soil Health",  "Top-dress pots with fresh compost each spring to replenish nutrients naturally."),
        ("humidity.fill",    "Humidity Hack",        "Cluster plants together — they naturally raise humidity through transpiration."),
        ("ant.fill",         "Pest Watch",           "Check the undersides of leaves weekly. Early detection makes pest control much easier."),
    ]
    
    private init() {}
    
    // MARK: - 公共方法
    
    /// 获取当月花期花卉列表
    /// 功能：根据当前月份筛选正在盛开的花卉，最多返回6个
    /// 返回值：[FlowerModel_Sprig] 按 careLevel 升序排列
    func getTodayBloomFlowers_Sprig() -> [FlowerModel_Sprig] {
        let currentMonth_sprig = Calendar.current.component(.month, from: Date())
        let blooming_sprig = LocalData_Sprig.shared_Sprig.flowerList_Sprig.filter {
            $0.bloomMonths_Sprig.contains(currentMonth_sprig)
        }
        // 若当月无花，返回全年花卉中的前6个
        let source_sprig = blooming_sprig.isEmpty
            ? Array(LocalData_Sprig.shared_Sprig.flowerList_Sprig.prefix(6))
            : blooming_sprig
        return Array(source_sprig.prefix(6))
    }
    
    /// 获取今日养护贴士
    /// 功能：根据当天日期索引返回贴士，每日固定但轮换
    /// 返回值：(icon: String, title: String, text: String) 元组
    func getDailyTip_Sprig() -> (icon: String, title: String, text: String) {
        let dayOfYear_sprig = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index_sprig = (dayOfYear_sprig - 1) % dailyTips_Sprig.count
        let tip_sprig = dailyTips_Sprig[index_sprig]
        return (icon: tip_sprig.icon, title: tip_sprig.title, text: tip_sprig.text)
    }
    
    /// 获取首页社区帖子列表
    /// 功能：返回随机打乱的全部帖子，确保每次进入首页内容有新鲜感
    /// 返回值：[TitleModel_Sprig]
    func getHomeFeedPosts_Sprig() -> [TitleModel_Sprig] {
        return TitleViewModel_Sprig.shared_Sprig.getPosts_Sprig().shuffled()
    }
    
    /// 获取首页问候语
    /// 功能：根据当前时段返回不同的问候文字
    /// 返回值：String - 问候语
    func getGreeting_Sprig() -> String {
        let hour_sprig = Calendar.current.component(.hour, from: Date())
        switch hour_sprig {
        case 5..<12:  return "Good morning, Bloom Explorer!"
        case 12..<17: return "Good afternoon, Plant Lover!"
        case 17..<21: return "Good evening, Garden Keeper!"
        default:      return "Good night, Flower Dreamer!"
        }
    }
    
    /// 获取当前月份的花期描述
    /// 功能：返回当前月份适合欣赏的花卉数量描述
    /// 返回值：String - 花期描述
    func getMonthBloomSummary_Sprig() -> String {
        let count_sprig = getTodayBloomFlowers_Sprig().count
        let monthName_sprig = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
        return "\(count_sprig) blooms in \(monthName_sprig)"
    }
    
    /// 刷新首页数据
    /// 功能：重新初始化帖子，模拟刷新动作
    /// 参数：completion_sprig - 刷新完成回调
    func refresh_Sprig(completion_sprig: @escaping () -> Void) {
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            TitleViewModel_Sprig.shared_Sprig.initPosts_Sprig()
            completion_sprig()
        }
    }

    // MARK: - 养花轨迹方法

    /// 新增一条养花状态记录
    /// 参数：milestone_sprig - 花期节点；notes_sprig - 养护心得
    func addJourneyRecord_Sprig(milestone_sprig: FlowerMilestone_Sprig, notes_sprig: String) {
        let record_sprig = FlowerStatusRecord_Sprig(
            recordId_Sprig: nextRecordId_Sprig,
            milestone_Sprig: milestone_sprig,
            notes_Sprig: notes_sprig
        )
        nextRecordId_Sprig += 1
        // 按时间倒序插入到头部
        flowerJourney_Sprig.insert(record_sprig, at: 0)
        notifyHomeStateChange_Sprig()
    }

    /// 获取养花轨迹列表（最新在前）
    /// 返回值：[FlowerStatusRecord_Sprig]
    func getJourneyRecords_Sprig() -> [FlowerStatusRecord_Sprig] {
        return flowerJourney_Sprig
    }

    /// 删除指定养花轨迹记录
    /// - Parameter recordId_sprig: 要删除的记录 ID
    func deleteJourneyRecord_Sprig(recordId_sprig: Int) {
        flowerJourney_Sprig.removeAll { $0.recordId_Sprig == recordId_sprig }
        notifyHomeStateChange_Sprig()
    }

    // MARK: - 时光胶囊方法

    /// 新增一个时光胶囊
    /// 参数：notes_sprig - 养护心得；unlockYears_sprig - 解锁年数（1 或 3）
    func addCapsule_Sprig(notes_sprig: String, unlockYears_sprig: Int) {
        let capsule_sprig = FlowerCapsule_Sprig(
            capsuleId_Sprig: nextCapsuleId_Sprig,
            notes_Sprig: notes_sprig,
            unlockYears_Sprig: unlockYears_sprig
        )
        nextCapsuleId_Sprig += 1
        capsules_Sprig.append(capsule_sprig)
        notifyHomeStateChange_Sprig()
    }

    /// 获取所有时光胶囊
    /// 返回值：[FlowerCapsule_Sprig]
    func getCapsules_Sprig() -> [FlowerCapsule_Sprig] {
        return capsules_Sprig
    }

    /// 删除指定时光胶囊
    /// - Parameter capsuleId_sprig: 要删除的胶囊 ID
    func deleteCapsule_Sprig(capsuleId_sprig: Int) {
        capsules_Sprig.removeAll { $0.capsuleId_Sprig == capsuleId_sprig }
        notifyHomeStateChange_Sprig()
    }

    // MARK: - 私有通知

    /// 发送首页状态变化通知
    private func notifyHomeStateChange_Sprig() {
        NotificationCenter.default.post(
            name: HomeViewModel_Sprig.homeStateDidChangeNotification_Sprig,
            object: nil
        )
    }
}
