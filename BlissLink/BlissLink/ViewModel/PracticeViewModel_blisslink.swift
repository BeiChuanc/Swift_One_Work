import Foundation
import Combine
import UIKit

// MARK: - 练习状态管理
// 核心作用：管理瑜伽冥想练习的所有业务逻辑
// 设计思路：统一管理课程、练习记录、统计数据、挑战计划
// 关键方法：课程筛选、开始/结束练习、统计计算、挑战管理

/// 练习状态管理类
class PracticeViewModel_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = PracticeViewModel_blisslink()
    
    // MARK: - 响应式属性
    
    /// 练习记录列表
    @Published var practiceSessions_blisslink: [PracticeSessionModel_blisslink] = []
    
    /// 当前用户的练习统计
    @Published var practiceStats_blisslink: PracticeStatsModel_blisslink?
    
    /// 当前正在进行的练习
    @Published var currentSession_blisslink: PracticeSessionModel_blisslink?
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 初始化方法
    
    /// 初始化练习数据
    func initPracticeData_blisslink() {
        // 初始化当前用户的统计数据
        let currentUserId_blisslink = UserViewModel_baseswiftui.shared_baseswiftui.getCurrentUser_baseswiftui().userId_baseswiftui ?? 0
        
        // 模拟一些练习统计数据
        practiceStats_blisslink = PracticeStatsModel_blisslink(
            userId_blisslink: currentUserId_blisslink,
            totalDuration_blisslink: 420, // 7小时
            streakDays_blisslink: 5,
            weeklySessionCount_blisslink: 8,
            monthlySessionCount_blisslink: 24,
            weeklyDuration_blisslink: 180, // 3小时
            favoriteCourseType_blisslink: nil,
            totalCompletedCourses_blisslink: 15,
            lastPracticeDate_blisslink: Date()
        )
        
        print("✅ 练习数据初始化完成")
    }
    
    // MARK: - 练习记录管理
    
    /// 开始练习
    /// - Parameter duration_blisslink: 练习时长（分钟）
    func startPractice_blisslink(duration_blisslink: Int) {
        // 检查是否已登录
        guard UserViewModel_baseswiftui.shared_baseswiftui.isLoggedIn_baseswiftui else {
            Utils_baseswiftui.showWarning_baseswiftui(message_baseswiftui: "Please login first")
            return
        }
        
        let currentUserId_blisslink = UserViewModel_baseswiftui.shared_baseswiftui.getCurrentUser_baseswiftui().userId_baseswiftui ?? 0
        let sessionId_blisslink = practiceSessions_blisslink.count + 1
        
        let session_blisslink = PracticeSessionModel_blisslink(
            sessionId_blisslink: sessionId_blisslink,
            userId_blisslink: currentUserId_blisslink,
            courseId_blisslink: 0,
            startTime_blisslink: Date(),
            endTime_blisslink: Date(),
            duration_blisslink: duration_blisslink,
            isCompleted_blisslink: false
        )
        
        currentSession_blisslink = session_blisslink
        
        print("▶️ 开始练习：\(duration_blisslink) 分钟")
    }
    
    /// 结束练习
    /// - Parameters:
    ///   - isCompleted_blisslink: 是否完成
    ///   - moodRating_blisslink: 心情评分（可选）
    func endPractice_blisslink(isCompleted_blisslink: Bool, moodRating_blisslink: Int? = nil) {
        guard var session_blisslink = currentSession_blisslink else { return }
        
        // 更新练习记录
        session_blisslink.endTime_blisslink = Date()
        session_blisslink.duration_blisslink = Int(session_blisslink.endTime_blisslink.timeIntervalSince(session_blisslink.startTime_blisslink) / 60)
        session_blisslink.isCompleted_blisslink = isCompleted_blisslink
        session_blisslink.moodRating_blisslink = moodRating_blisslink
        
        // 保存练习记录
        practiceSessions_blisslink.append(session_blisslink)
        
        // 更新统计数据
        updatePracticeStats_blisslink(session_blisslink: session_blisslink)
        
        // 清空当前练习
        currentSession_blisslink = nil
        
        // 显示完成提示
        if isCompleted_blisslink {
            Utils_baseswiftui.showSuccess_baseswiftui(
                message_baseswiftui: "Practice completed! Great job!",
                image_baseswiftui: UIImage(systemName: "checkmark.seal.fill"),
                delay_baseswiftui: 2.0
            )
        }
        
        print("⏹ 结束练习：时长 \(session_blisslink.duration_blisslink) 分钟")
    }
    
    /// 获取练习历史
    /// - Parameter userId_blisslink: 用户ID（可选，默认当前用户）
    /// - Returns: 练习记录列表
    func getPracticeHistory_blisslink(userId_blisslink: Int? = nil) -> [PracticeSessionModel_blisslink] {
        let targetUserId_blisslink = userId_blisslink ?? (UserViewModel_baseswiftui.shared_baseswiftui.getCurrentUser_baseswiftui().userId_baseswiftui ?? 0)
        return practiceSessions_blisslink.filter { $0.userId_blisslink == targetUserId_blisslink }
            .sorted { $0.startTime_blisslink > $1.startTime_blisslink }
    }
    
    // MARK: - 统计数据计算
    
    /// 更新练习统计数据
    /// - Parameter session_blisslink: 新的练习记录
    private func updatePracticeStats_blisslink(session_blisslink: PracticeSessionModel_blisslink) {
        guard var stats_blisslink = practiceStats_blisslink else { return }
        
        // 更新总时长
        if session_blisslink.isCompleted_blisslink {
            stats_blisslink.totalDuration_blisslink += session_blisslink.duration_blisslink
            stats_blisslink.totalCompletedCourses_blisslink += 1
        }
        
        // 更新最后练习日期
        stats_blisslink.lastPracticeDate_blisslink = session_blisslink.endTime_blisslink
        
        // 计算连续打卡天数
        stats_blisslink.streakDays_blisslink = calculateStreakDays_blisslink()
        
        // 计算本周统计
        let weekStats_blisslink = calculateWeeklyStats_blisslink()
        stats_blisslink.weeklySessionCount_blisslink = weekStats_blisslink.count
        stats_blisslink.weeklyDuration_blisslink = weekStats_blisslink.duration
        
        // 计算本月统计
        stats_blisslink.monthlySessionCount_blisslink = calculateMonthlySessionCount_blisslink()
        
        // 更新最喜欢的课程类型
        stats_blisslink.favoriteCourseType_blisslink = calculateFavoriteCourseType_blisslink()
        
        practiceStats_blisslink = stats_blisslink
        
        // 手动触发更新
        objectWillChange.send()
    }
    
    /// 计算连续打卡天数
    /// - Returns: 连续天数
    private func calculateStreakDays_blisslink() -> Int {
        let completedSessions_blisslink = practiceSessions_blisslink.filter { $0.isCompleted_blisslink }
            .sorted { $0.startTime_blisslink > $1.startTime_blisslink }
        
        guard !completedSessions_blisslink.isEmpty else { return 0 }
        
        let calendar_blisslink = Calendar.current
        var streakDays_blisslink = 1
        var currentDate_blisslink = calendar_blisslink.startOfDay(for: completedSessions_blisslink[0].startTime_blisslink)
        
        for i_blisslink in 1..<completedSessions_blisslink.count {
            let sessionDate_blisslink = calendar_blisslink.startOfDay(for: completedSessions_blisslink[i_blisslink].startTime_blisslink)
            
            if let daysDifference_blisslink = calendar_blisslink.dateComponents([.day], from: sessionDate_blisslink, to: currentDate_blisslink).day {
                if daysDifference_blisslink == 1 {
                    streakDays_blisslink += 1
                    currentDate_blisslink = sessionDate_blisslink
                } else if daysDifference_blisslink > 1 {
                    break
                }
            }
        }
        
        return streakDays_blisslink
    }
    
    /// 计算本周统计
    /// - Returns: (练习次数, 总时长)
    private func calculateWeeklyStats_blisslink() -> (count: Int, duration: Int) {
        let calendar_blisslink = Calendar.current
        let now_blisslink = Date()
        let weekAgo_blisslink = calendar_blisslink.date(byAdding: .day, value: -7, to: now_blisslink) ?? now_blisslink
        
        let weeklySessions_blisslink = practiceSessions_blisslink.filter { 
            $0.isCompleted_blisslink && $0.startTime_blisslink >= weekAgo_blisslink
        }
        
        let totalDuration_blisslink = weeklySessions_blisslink.reduce(0) { $0 + $1.duration_blisslink }
        
        return (weeklySessions_blisslink.count, totalDuration_blisslink)
    }
    
    /// 计算本月练习次数
    /// - Returns: 本月练习次数
    private func calculateMonthlySessionCount_blisslink() -> Int {
        let calendar_blisslink = Calendar.current
        let now_blisslink = Date()
        let monthAgo_blisslink = calendar_blisslink.date(byAdding: .month, value: -1, to: now_blisslink) ?? now_blisslink
        
        return practiceSessions_blisslink.filter { 
            $0.isCompleted_blisslink && $0.startTime_blisslink >= monthAgo_blisslink
        }.count
    }
    
    /// 计算最喜欢的课程类型
    /// - Returns: 最喜欢的课程类型
    private func calculateFavoriteCourseType_blisslink() -> CourseType_blisslink? {
        // 简化实现，返回nil
        return nil
    }
    
    /// 获取练习统计数据
    /// - Returns: 统计数据模型
    func getPracticeStats_blisslink() -> PracticeStatsModel_blisslink? {
        return practiceStats_blisslink
    }
}
