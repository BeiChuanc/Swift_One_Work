import Foundation
import UIKit

// MARK: 推荐ViewModel

/// 推荐状态管理类
/// 功能：管理推荐逻辑和时光轴数据
/// 职责：今日灵感推荐、时光轴归档、成长曲线计算
@MainActor
class RecommendViewModel_Glasspaint {
    
    /// 单例
    static let shared_Glasspaint = RecommendViewModel_Glasspaint()
    
    // MARK: - 通知名称
    
    /// 推荐状态更新通知
    static let recommendStateDidChangeNotification_Glasspaint = Notification.Name("RecommendStateDidChange_Glasspaint")
    
    private init() {}
    
    // MARK: - 今日灵感推荐
    
    /// 获取今日推荐作品
    /// 功能：基于用户水平和偏好风格进行智能推荐
    /// 算法：优先匹配风格 → 难度适配
    /// 返回值：2-3幅推荐作品
    func getTodayRecommendations_Glasspaint() -> [TitleModel_Glasspaint] {
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        let allPosts_glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.getPosts_Glasspaint()
        
        // 获取用户偏好
        let userLevel_glasspaint = currentUser_glasspaint.paintingLevel_Glasspaint
        let userPreferredStyles_glasspaint = currentUser_glasspaint.preferredStyles_Glasspaint
        
        // 如果用户没有偏好，返回通用推荐（热门作品）
        if userPreferredStyles_glasspaint.isEmpty {
            return getDefaultRecommendations_Glasspaint(from_glasspaint: allPosts_glasspaint)
        }
        
        // 筛选匹配用户偏好风格的作品
        var matchedPosts_glasspaint = allPosts_glasspaint.filter { post_glasspaint in
            userPreferredStyles_glasspaint.contains(post_glasspaint.paintingStyle_Glasspaint)
        }
        
        // 如果匹配作品少于3个，补充其他作品
        if matchedPosts_glasspaint.count < 3 {
            let remainingPosts_glasspaint = allPosts_glasspaint.filter { post_glasspaint in
                !matchedPosts_glasspaint.contains { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }
            }
            matchedPosts_glasspaint.append(contentsOf: remainingPosts_glasspaint)
        }
        
        // 筛选适合用户水平的作品
        var levelFilteredPosts_glasspaint = matchedPosts_glasspaint.filter { post_glasspaint in
            // 新手：只推荐新手和进阶
            // 进阶：推荐所有难度
            // 高级：推荐所有难度
            switch userLevel_glasspaint {
            case .beginner_glasspaint:
                return post_glasspaint.paintingLevel_Glasspaint == .beginner_glasspaint ||
                       post_glasspaint.paintingLevel_Glasspaint == .intermediate_glasspaint
            case .intermediate_glasspaint, .advanced_glasspaint:
                return true
            }
        }
        
        // 如果筛选后作品不足，使用所有匹配风格的作品
        if levelFilteredPosts_glasspaint.count < 3 {
            levelFilteredPosts_glasspaint = matchedPosts_glasspaint
        }
        
        // 按点赞数排序
        levelFilteredPosts_glasspaint.sort { post1_glasspaint, post2_glasspaint in
            post1_glasspaint.likes_Glasspaint > post2_glasspaint.likes_Glasspaint
        }
        
        // 使用日期种子进行随机，确保每日变化
        let todaySeed_glasspaint = getTodaySeed_Glasspaint()
        let shuffledPosts_glasspaint = shuffleWithSeed_Glasspaint(
            array_glasspaint: levelFilteredPosts_glasspaint,
            seed_glasspaint: todaySeed_glasspaint
        )
        
        // 返回前2-3个
        let count_glasspaint = min(3, shuffledPosts_glasspaint.count)
        return Array(shuffledPosts_glasspaint.prefix(count_glasspaint))
    }
    
    /// 获取默认推荐
    /// 功能：用户无偏好时的推荐策略
    /// 返回值：热门作品
    private func getDefaultRecommendations_Glasspaint(from_glasspaint posts_glasspaint: [TitleModel_Glasspaint]) -> [TitleModel_Glasspaint] {
        // 按点赞数排序
        let sortedPosts_glasspaint = posts_glasspaint.sorted { post1_glasspaint, post2_glasspaint in
            return post1_glasspaint.likes_Glasspaint > post2_glasspaint.likes_Glasspaint
        }
        
        let count_glasspaint = min(3, sortedPosts_glasspaint.count)
        return Array(sortedPosts_glasspaint.prefix(count_glasspaint))
    }
    
    // MARK: - 时光轴功能
    
    /// 获取按月归档的时光轴
    /// 功能：将用户发布和收藏的作品按月份归档
    /// 返回值：字典（月份 -> 作品列表）
    func getTimelineByMonth_Glasspaint() -> [String: [TitleModel_Glasspaint]] {
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        // 合并发布和收藏的作品
        var allUserPosts_glasspaint = currentUser_glasspaint.userPosts_Glasspaint
        allUserPosts_glasspaint.append(contentsOf: currentUser_glasspaint.userLike_Glasspaint)
        
        // 去重
        let uniquePosts_glasspaint = Array(Set(allUserPosts_glasspaint.map { $0.titleId_Glasspaint }))
            .compactMap { id_glasspaint in
                allUserPosts_glasspaint.first { $0.titleId_Glasspaint == id_glasspaint }
            }
        
        // 按月份分组
        var monthlyPosts_glasspaint: [String: [TitleModel_Glasspaint]] = [:]
        let dateFormatter_glasspaint = DateFormatter()
        dateFormatter_glasspaint.dateFormat = "MMM yyyy"
        
        for post_glasspaint in uniquePosts_glasspaint {
            let monthKey_glasspaint = dateFormatter_glasspaint.string(from: post_glasspaint.createdDate_Glasspaint)
            if monthlyPosts_glasspaint[monthKey_glasspaint] == nil {
                monthlyPosts_glasspaint[monthKey_glasspaint] = []
            }
            monthlyPosts_glasspaint[monthKey_glasspaint]?.append(post_glasspaint)
        }
        
        return monthlyPosts_glasspaint
    }
    
    /// 获取按季度归档的时光轴
    /// 功能：将用户发布和收藏的作品按季度归档
    /// 返回值：字典（季度 -> 作品列表）
    func getTimelineByQuarter_Glasspaint() -> [String: [TitleModel_Glasspaint]] {
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        // 合并发布和收藏的作品
        var allUserPosts_glasspaint = currentUser_glasspaint.userPosts_Glasspaint
        allUserPosts_glasspaint.append(contentsOf: currentUser_glasspaint.userLike_Glasspaint)
        
        // 去重
        let uniquePosts_glasspaint = Array(Set(allUserPosts_glasspaint.map { $0.titleId_Glasspaint }))
            .compactMap { id_glasspaint in
                allUserPosts_glasspaint.first { $0.titleId_Glasspaint == id_glasspaint }
            }
        
        // 按季度分组
        var quarterlyPosts_glasspaint: [String: [TitleModel_Glasspaint]] = [:]
        let calendar_glasspaint = Calendar.current
        
        for post_glasspaint in uniquePosts_glasspaint {
            let year_glasspaint = calendar_glasspaint.component(.year, from: post_glasspaint.createdDate_Glasspaint)
            let month_glasspaint = calendar_glasspaint.component(.month, from: post_glasspaint.createdDate_Glasspaint)
            let quarter_glasspaint = (month_glasspaint - 1) / 3 + 1
            let quarterKey_glasspaint = "Q\(quarter_glasspaint) \(year_glasspaint)"
            
            if quarterlyPosts_glasspaint[quarterKey_glasspaint] == nil {
                quarterlyPosts_glasspaint[quarterKey_glasspaint] = []
            }
            quarterlyPosts_glasspaint[quarterKey_glasspaint]?.append(post_glasspaint)
        }
        
        return quarterlyPosts_glasspaint
    }
    
    // MARK: - 成长曲线
    
    /// 获取用户成长曲线数据
    /// 功能：计算用户的彩绘技能成长指标
    /// 返回值：成长数据模型
    func getGrowthCurve_Glasspaint() -> GrowthData_Glasspaint {
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        let userPosts_glasspaint = currentUser_glasspaint.userPosts_Glasspaint
        
        // 如果用户没有作品，返回默认数据
        if userPosts_glasspaint.isEmpty {
            return GrowthData_Glasspaint()
        }
        
        // 计算线条流畅度（基于点赞率）
        let totalLikes_glasspaint = userPosts_glasspaint.reduce(0) { $0 + $1.likes_Glasspaint }
        let avgLikes_glasspaint = Double(totalLikes_glasspaint) / Double(userPosts_glasspaint.count)
        let lineSmoothnessScore_glasspaint = min(100, avgLikes_glasspaint * 10)
        
        // 计算色彩搭配（基于风格多样性）
        let uniqueStyles_glasspaint = Set(userPosts_glasspaint.map { $0.paintingStyle_Glasspaint })
        let colorMatchingScore_glasspaint = min(100, Double(uniqueStyles_glasspaint.count) * 20)
        
        // 计算技法提升（基于难度等级分布）
        let beginnerCount_glasspaint = userPosts_glasspaint.filter { $0.paintingLevel_Glasspaint == .beginner_glasspaint }.count
        let intermediateCount_glasspaint = userPosts_glasspaint.filter { $0.paintingLevel_Glasspaint == .intermediate_glasspaint }.count
        let advancedCount_glasspaint = userPosts_glasspaint.filter { $0.paintingLevel_Glasspaint == .advanced_glasspaint }.count
        
        let totalCount_glasspaint = Double(userPosts_glasspaint.count)
        let techniqueScore_glasspaint = (Double(intermediateCount_glasspaint) * 50 + Double(advancedCount_glasspaint) * 100) / totalCount_glasspaint
        
        // 计算月度进步曲线
        var monthlyProgress_glasspaint: [String: Double] = [:]
        let dateFormatter_glasspaint = DateFormatter()
        dateFormatter_glasspaint.dateFormat = "MMM yyyy"
        
        // 按月份分组作品
        var monthlyPosts_glasspaint: [String: [TitleModel_Glasspaint]] = [:]
        for post_glasspaint in userPosts_glasspaint {
            let monthKey_glasspaint = dateFormatter_glasspaint.string(from: post_glasspaint.createdDate_Glasspaint)
            if monthlyPosts_glasspaint[monthKey_glasspaint] == nil {
                monthlyPosts_glasspaint[monthKey_glasspaint] = []
            }
            monthlyPosts_glasspaint[monthKey_glasspaint]?.append(post_glasspaint)
        }
        
        // 计算每月综合评分
        for (month_glasspaint, posts_glasspaint) in monthlyPosts_glasspaint {
            let monthScore_glasspaint = calculateMonthScore_Glasspaint(posts_glasspaint: posts_glasspaint)
            monthlyProgress_glasspaint[month_glasspaint] = monthScore_glasspaint
        }
        
        return GrowthData_Glasspaint(
            lineSmoothnessScore_glasspaint: lineSmoothnessScore_glasspaint,
            colorMatchingScore_glasspaint: colorMatchingScore_glasspaint,
            techniqueScore_glasspaint: techniqueScore_glasspaint,
            monthlyProgress_glasspaint: monthlyProgress_glasspaint
        )
    }
    
    /// 计算月度综合评分
    /// 功能：根据该月作品的综合表现计算评分
    /// 参数：
    /// - posts_glasspaint: 该月的作品列表
    /// 返回值：综合评分（0-100）
    private func calculateMonthScore_Glasspaint(posts_glasspaint: [TitleModel_Glasspaint]) -> Double {
        if posts_glasspaint.isEmpty { return 0 }
        
        let avgLikes_glasspaint = Double(posts_glasspaint.reduce(0) { $0 + $1.likes_Glasspaint }) / Double(posts_glasspaint.count)
        let avgComments_glasspaint = Double(posts_glasspaint.reduce(0) { $0 + $1.reviews_Glasspaint.count }) / Double(posts_glasspaint.count)
        
        // 综合评分：点赞数 * 0.7 + 评论数 * 0.3
        return min(100, avgLikes_glasspaint * 7 + avgComments_glasspaint * 3)
    }
    
    // MARK: - 工具方法
    
    /// 获取今日种子
    /// 功能：基于日期生成随机种子，确保同一天推荐相同
    /// 返回值：今日种子值
    private func getTodaySeed_Glasspaint() -> Int {
        let calendar_glasspaint = Calendar.current
        let today_glasspaint = Date()
        let dayOfYear_glasspaint = calendar_glasspaint.ordinality(of: .day, in: .year, for: today_glasspaint) ?? 1
        let year_glasspaint = calendar_glasspaint.component(.year, from: today_glasspaint)
        return year_glasspaint * 1000 + dayOfYear_glasspaint
    }
    
    /// 基于种子的伪随机打乱
    /// 功能：使用指定种子打乱数组，确保可重现
    /// 参数：
    /// - array_glasspaint: 待打乱的数组
    /// - seed_glasspaint: 随机种子
    /// 返回值：打乱后的数组
    private func shuffleWithSeed_Glasspaint<T>(array_glasspaint: [T], seed_glasspaint: Int) -> [T] {
        var shuffled_glasspaint = array_glasspaint
        var generator_glasspaint = SeededRandomGenerator_Glasspaint(seed: seed_glasspaint)
        
        for i_glasspaint in 0..<shuffled_glasspaint.count {
            let j_glasspaint = Int(generator_glasspaint.next() * Double(shuffled_glasspaint.count - i_glasspaint)) + i_glasspaint
            if j_glasspaint < shuffled_glasspaint.count {
                shuffled_glasspaint.swapAt(i_glasspaint, j_glasspaint)
            }
        }
        
        return shuffled_glasspaint
    }
    
    // MARK: - 通知
    
    /// 发送状态更新通知
    private func notifyStateChange_Glasspaint() {
        NotificationCenter.default.post(
            name: RecommendViewModel_Glasspaint.recommendStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
}

// MARK: - 种子随机数生成器

/// 种子随机数生成器
/// 功能：基于种子生成可重现的随机序列
private struct SeededRandomGenerator_Glasspaint {
    private var state_glasspaint: UInt64
    
    init(seed: Int) {
        state_glasspaint = UInt64(seed)
    }
    
    mutating func next() -> Double {
        // 线性同余生成器
        state_glasspaint = (state_glasspaint &* 1103515245 &+ 12345) & 0x7FFFFFFF
        return Double(state_glasspaint) / Double(0x7FFFFFFF)
    }
}
