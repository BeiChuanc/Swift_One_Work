import Foundation
import UIKit

// MARK: 情绪ViewModel

/// 情绪状态管理类
/// 功能：管理用户的情绪记录，提供添加、删除、查询、统计等功能
/// 核心职责：情绪记录CRUD、数据统计、日历数据、搜索筛选
@MainActor
class EmotionViewModel_Wanderbell {
    
    /// 单例
    static let shared_Wanderbell = EmotionViewModel_Wanderbell()
    
    // MARK: - 通知名称
    
    /// 情绪状态更新通知
    static let emotionStateDidChangeNotification_Wanderbell = Notification.Name("EmotionStateDidChange_Wanderbell")
    
    // MARK: - 私有属性
    
    /// 情绪记录列表（所有用户的记录）
    private var emotionRecords_Wanderbell: [EmotionRecord_Wanderbell] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化情绪记录列表
    /// 功能：从LocalData获取预制的情绪记录数据
    func initEmotionRecords_Wanderbell() {
        emotionRecords_Wanderbell = LocalData_Wanderbell.shared_Wanderbell.emotionRecordList_Wanderbell
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取所有情绪记录
    /// 返回值：[EmotionRecord_Wanderbell] - 所有情绪记录数组
    func getAllRecords_Wanderbell() -> [EmotionRecord_Wanderbell] {
        return emotionRecords_Wanderbell.sorted { $0.timestamp_Wanderbell > $1.timestamp_Wanderbell }
    }
    
    /// 获取当前用户的情绪记录
    /// 返回值：[EmotionRecord_Wanderbell] - 当前用户的情绪记录数组（按时间倒序）
    func getCurrentUserRecords_Wanderbell() -> [EmotionRecord_Wanderbell] {
        let currentUserId_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell().userId_Wanderbell ?? 0
        return emotionRecords_Wanderbell
            .filter { $0.userId_Wanderbell == currentUserId_wanderbell }
            .sorted { $0.timestamp_Wanderbell > $1.timestamp_Wanderbell }
    }
    
    /// 获取指定用户的情绪记录
    /// 参数：
    /// - userId_wanderbell: 用户ID
    /// 返回值：[EmotionRecord_Wanderbell] - 指定用户的情绪记录数组
    func getUserRecords_Wanderbell(userId_wanderbell: Int) -> [EmotionRecord_Wanderbell] {
        return emotionRecords_Wanderbell
            .filter { $0.userId_Wanderbell == userId_wanderbell }
            .sorted { $0.timestamp_Wanderbell > $1.timestamp_Wanderbell }
    }
    
    /// 获取最近N条记录
    /// 参数：
    /// - count_wanderbell: 记录数量
    /// - userId_wanderbell: 用户ID（可选，不传则获取当前用户）
    /// 返回值：[EmotionRecord_Wanderbell] - 最近的情绪记录数组
    func getRecentRecords_Wanderbell(count_wanderbell: Int, userId_wanderbell: Int? = nil) -> [EmotionRecord_Wanderbell] {
        let targetUserId_wanderbell = userId_wanderbell ?? (UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell().userId_Wanderbell ?? 0)
        return getUserRecords_Wanderbell(userId_wanderbell: targetUserId_wanderbell)
            .prefix(count_wanderbell)
            .map { $0 }
    }
    
    // MARK: - 公共方法 - 筛选和搜索
    
    /// 按情绪类型筛选记录
    /// 参数：
    /// - emotionTypes_wanderbell: 情绪类型数组
    /// - userId_wanderbell: 用户ID（可选）
    /// 返回值：[EmotionRecord_Wanderbell] - 筛选后的情绪记录数组
    func getRecordsByEmotionTypes_Wanderbell(emotionTypes_wanderbell: [EmotionType_Wanderbell], userId_wanderbell: Int? = nil) -> [EmotionRecord_Wanderbell] {
        let records_wanderbell = userId_wanderbell != nil 
            ? getUserRecords_Wanderbell(userId_wanderbell: userId_wanderbell!) 
            : getAllRecords_Wanderbell()
        
        return records_wanderbell.filter { emotionTypes_wanderbell.contains($0.emotionType_Wanderbell) }
    }
    
    /// 按日期范围筛选记录
    /// 参数：
    /// - startDate_wanderbell: 开始日期
    /// - endDate_wanderbell: 结束日期
    /// - userId_wanderbell: 用户ID（可选）
    /// 返回值：[EmotionRecord_Wanderbell] - 筛选后的情绪记录数组
    func getRecordsByDateRange_Wanderbell(startDate_wanderbell: Date, endDate_wanderbell: Date, userId_wanderbell: Int? = nil) -> [EmotionRecord_Wanderbell] {
        let records_wanderbell = userId_wanderbell != nil 
            ? getUserRecords_Wanderbell(userId_wanderbell: userId_wanderbell!) 
            : getAllRecords_Wanderbell()
        
        return records_wanderbell.filter { 
            $0.timestamp_Wanderbell >= startDate_wanderbell && $0.timestamp_Wanderbell <= endDate_wanderbell 
        }
    }
    
    /// 搜索情绪记录
    /// 参数：
    /// - keyword_wanderbell: 搜索关键词
    /// - userId_wanderbell: 用户ID（可选）
    /// 返回值：[EmotionRecord_Wanderbell] - 搜索结果数组
    func searchRecords_Wanderbell(keyword_wanderbell: String, userId_wanderbell: Int? = nil) -> [EmotionRecord_Wanderbell] {
        guard !keyword_wanderbell.isEmpty else {
            return userId_wanderbell != nil 
                ? getUserRecords_Wanderbell(userId_wanderbell: userId_wanderbell!) 
                : getAllRecords_Wanderbell()
        }
        
        let records_wanderbell = userId_wanderbell != nil 
            ? getUserRecords_Wanderbell(userId_wanderbell: userId_wanderbell!) 
            : getAllRecords_Wanderbell()
        
        return records_wanderbell.filter { record_wanderbell in
            // 搜索笔记内容
            let noteMatch_wanderbell = record_wanderbell.note_Wanderbell.lowercased().contains(keyword_wanderbell.lowercased())
            
            // 搜索情绪名称
            let emotionMatch_wanderbell = record_wanderbell.getEmotionDisplayName_Wanderbell().lowercased().contains(keyword_wanderbell.lowercased())
            
            // 搜索标签
            let tagMatch_wanderbell = record_wanderbell.tags_Wanderbell.contains { $0.lowercased().contains(keyword_wanderbell.lowercased()) }
            
            return noteMatch_wanderbell || emotionMatch_wanderbell || tagMatch_wanderbell
        }
    }
    
    // MARK: - 公共方法 - 统计数据
    
    /// 获取情绪统计数据（按类型）
    /// 功能：计算指定时间范围内各种情绪的数量和占比
    /// 参数：
    /// - days_wanderbell: 统计天数（7=本周，30=本月）
    /// - userId_wanderbell: 用户ID（可选）
    /// 返回值：[EmotionType_Wanderbell: Int] - 情绪类型和对应的记录数量
    func getEmotionStatistics_Wanderbell(days_wanderbell: Int, userId_wanderbell: Int? = nil) -> [EmotionType_Wanderbell: Int] {
        let startDate_wanderbell = Calendar.current.date(byAdding: .day, value: -days_wanderbell, to: Date()) ?? Date()
        let endDate_wanderbell = Date()
        
        let records_wanderbell = getRecordsByDateRange_Wanderbell(
            startDate_wanderbell: startDate_wanderbell, 
            endDate_wanderbell: endDate_wanderbell, 
            userId_wanderbell: userId_wanderbell
        )
        
        var statistics_wanderbell: [EmotionType_Wanderbell: Int] = [:]
        
        for record_wanderbell in records_wanderbell {
            let count_wanderbell = statistics_wanderbell[record_wanderbell.emotionType_Wanderbell] ?? 0
            statistics_wanderbell[record_wanderbell.emotionType_Wanderbell] = count_wanderbell + 1
        }
        
        return statistics_wanderbell
    }
    
    /// 获取情绪趋势数据
    /// 功能：计算指定天数内每天的平均情绪强度
    /// 参数：
    /// - days_wanderbell: 统计天数
    /// - userId_wanderbell: 用户ID（可选）
    /// 返回值：[(Date, Double)] - 日期和对应的平均强度数组
    func getEmotionTrend_Wanderbell(days_wanderbell: Int, userId_wanderbell: Int? = nil) -> [(Date, Double)] {
        let startDate_wanderbell = Calendar.current.date(byAdding: .day, value: -days_wanderbell, to: Date()) ?? Date()
        let endDate_wanderbell = Date()
        
        let records_wanderbell = getRecordsByDateRange_Wanderbell(
            startDate_wanderbell: startDate_wanderbell, 
            endDate_wanderbell: endDate_wanderbell, 
            userId_wanderbell: userId_wanderbell
        )
        
        // 按日期分组
        var dailyRecords_wanderbell: [Date: [EmotionRecord_Wanderbell]] = [:]
        let calendar_wanderbell = Calendar.current
        
        for record_wanderbell in records_wanderbell {
            let date_wanderbell = calendar_wanderbell.startOfDay(for: record_wanderbell.timestamp_Wanderbell)
            if dailyRecords_wanderbell[date_wanderbell] == nil {
                dailyRecords_wanderbell[date_wanderbell] = []
            }
            dailyRecords_wanderbell[date_wanderbell]?.append(record_wanderbell)
        }
        
        // 计算每天的平均强度
        var trendData_wanderbell: [(Date, Double)] = []
        for day_wanderbell in 0..<days_wanderbell {
            let date_wanderbell = calendar_wanderbell.date(byAdding: .day, value: -day_wanderbell, to: endDate_wanderbell) ?? Date()
            let dayStart_wanderbell = calendar_wanderbell.startOfDay(for: date_wanderbell)
            
            if let records_wanderbell = dailyRecords_wanderbell[dayStart_wanderbell], !records_wanderbell.isEmpty {
                let totalIntensity_wanderbell = records_wanderbell.reduce(0) { $0 + $1.intensity_Wanderbell }
                let averageIntensity_wanderbell = Double(totalIntensity_wanderbell) / Double(records_wanderbell.count)
                trendData_wanderbell.append((dayStart_wanderbell, averageIntensity_wanderbell))
            } else {
                trendData_wanderbell.append((dayStart_wanderbell, 0.0))
            }
        }
        
        return trendData_wanderbell.sorted { $0.0 < $1.0 }
    }
    
    /// 获取情绪日历数据（某月的每日情绪）
    /// 功能：获取指定月份每天的主要情绪类型
    /// 参数：
    /// - year_wanderbell: 年份
    /// - month_wanderbell: 月份
    /// - userId_wanderbell: 用户ID（可选）
    /// 返回值：[Date: EmotionType_Wanderbell] - 日期和对应的主要情绪类型
    func getEmotionCalendarData_Wanderbell(year_wanderbell: Int, month_wanderbell: Int, userId_wanderbell: Int? = nil) -> [Date: EmotionType_Wanderbell] {
        var components_wanderbell = DateComponents()
        components_wanderbell.year = year_wanderbell
        components_wanderbell.month = month_wanderbell
        components_wanderbell.day = 1
        
        let calendar_wanderbell = Calendar.current
        guard let startDate_wanderbell = calendar_wanderbell.date(from: components_wanderbell),
              let endDate_wanderbell = calendar_wanderbell.date(byAdding: DateComponents(month: 1, day: -1), to: startDate_wanderbell) else {
            return [:]
        }
        
        let records_wanderbell = getRecordsByDateRange_Wanderbell(
            startDate_wanderbell: startDate_wanderbell, 
            endDate_wanderbell: endDate_wanderbell, 
            userId_wanderbell: userId_wanderbell
        )
        
        // 按日期分组并找出每天最频繁的情绪
        var dailyEmotions_wanderbell: [Date: EmotionType_Wanderbell] = [:]
        var dailyRecords_wanderbell: [Date: [EmotionRecord_Wanderbell]] = [:]
        
        for record_wanderbell in records_wanderbell {
            let date_wanderbell = calendar_wanderbell.startOfDay(for: record_wanderbell.timestamp_Wanderbell)
            if dailyRecords_wanderbell[date_wanderbell] == nil {
                dailyRecords_wanderbell[date_wanderbell] = []
            }
            dailyRecords_wanderbell[date_wanderbell]?.append(record_wanderbell)
        }
        
        // 找出每天最频繁的情绪类型
        for (date_wanderbell, records_wanderbell) in dailyRecords_wanderbell {
            var emotionCounts_wanderbell: [EmotionType_Wanderbell: Int] = [:]
            for record_wanderbell in records_wanderbell {
                let count_wanderbell = emotionCounts_wanderbell[record_wanderbell.emotionType_Wanderbell] ?? 0
                emotionCounts_wanderbell[record_wanderbell.emotionType_Wanderbell] = count_wanderbell + 1
            }
            
            if let mostFrequent_wanderbell = emotionCounts_wanderbell.max(by: { $0.value < $1.value }) {
                dailyEmotions_wanderbell[date_wanderbell] = mostFrequent_wanderbell.key
            }
        }
        
        return dailyEmotions_wanderbell
    }
    
    // MARK: - 公共方法 - 添加记录
    
    /// 添加情绪记录
    /// 功能：为当前用户添加新的情绪记录
    /// 参数：
    /// - emotionType_wanderbell: 情绪类型
    /// - customEmotion_wanderbell: 自定义情绪名称（可选）
    /// - intensity_wanderbell: 强度（1-5）
    /// - note_wanderbell: 笔记内容
    /// - media_wanderbell: 媒体文件数组
    /// - tags_wanderbell: 标签数组
    func addEmotionRecord_Wanderbell(
        emotionType_wanderbell: EmotionType_Wanderbell,
        customEmotion_wanderbell: String? = nil,
        intensity_wanderbell: Int,
        note_wanderbell: String,
        media_wanderbell: [String],
        tags_wanderbell: [String]
    ) {
        // 检查是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            showLoginPrompt_Wanderbell()
            return
        }
        
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let newRecordId_wanderbell = (emotionRecords_Wanderbell.map { $0.recordId_Wanderbell }.max() ?? 0) + 1
        
        let newRecord_wanderbell = EmotionRecord_Wanderbell(
            recordId_Wanderbell: newRecordId_wanderbell,
            userId_Wanderbell: currentUser_wanderbell.userId_Wanderbell ?? 0,
            emotionType_Wanderbell: emotionType_wanderbell,
            customEmotion_Wanderbell: customEmotion_wanderbell,
            intensity_Wanderbell: intensity_wanderbell,
            note_Wanderbell: note_wanderbell,
            media_Wanderbell: media_wanderbell,
            timestamp_Wanderbell: Date(),
            tags_Wanderbell: tags_wanderbell
        )
        
        emotionRecords_Wanderbell.append(newRecord_wanderbell)
        
        // 同步到用户模型
        syncRecordToUser_Wanderbell(record_wanderbell: newRecord_wanderbell)
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Emotion recorded successfully!",
            image_wanderbell: UIImage(systemName: "checkmark.circle.fill")
        )
        
        // 通知用户状态也更新（因为用户记录改变了）
        NotificationCenter.default.post(
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
            object: nil
        )
        
        notifyStateChange_Wanderbell()
    }
    
    /// 同步情绪记录到用户模型
    /// 功能：将新增的情绪记录添加到当前登录用户的记录列表中
    /// 参数：
    /// - record_wanderbell: 情绪记录
    private func syncRecordToUser_Wanderbell(record_wanderbell: EmotionRecord_Wanderbell) {
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        if currentUser_wanderbell.userId_Wanderbell == record_wanderbell.userId_Wanderbell {
            if !currentUser_wanderbell.userEmotionRecords_Wanderbell.contains(where: { $0.recordId_Wanderbell == record_wanderbell.recordId_Wanderbell }) {
                currentUser_wanderbell.userEmotionRecords_Wanderbell.append(record_wanderbell)
            }
        }
    }
    
    // MARK: - 公共方法 - 删除记录
    
    /// 删除情绪记录
    /// 功能：删除指定的情绪记录
    /// 参数：
    /// - record_wanderbell: 要删除的记录
    func deleteEmotionRecord_Wanderbell(record_wanderbell: EmotionRecord_Wanderbell) {
        emotionRecords_Wanderbell.removeAll { $0.recordId_Wanderbell == record_wanderbell.recordId_Wanderbell }
        
        // 从用户模型中同步删除
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        currentUser_wanderbell.userEmotionRecords_Wanderbell.removeAll { $0.recordId_Wanderbell == record_wanderbell.recordId_Wanderbell }
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Record deleted",
            image_wanderbell: UIImage(systemName: "trash.fill"),
            delay_wanderbell: 1.0
        )
        
        notifyStateChange_Wanderbell()
    }
    
    /// 删除指定用户的所有情绪记录
    /// 功能：删除某个用户的所有情绪记录（用于用户注销或举报）
    /// 参数：
    /// - userId_wanderbell: 用户ID
    func deleteUserEmotionRecords_Wanderbell(userId_wanderbell: Int) {
        emotionRecords_Wanderbell.removeAll { $0.userId_Wanderbell == userId_wanderbell }
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Wanderbell() {
        NotificationCenter.default.post(
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Wanderbell() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
        }
    }
}
