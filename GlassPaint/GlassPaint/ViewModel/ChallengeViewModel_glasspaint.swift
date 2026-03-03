import Foundation
import UIKit

// MARK: 挑战ViewModel

/// 挑战状态管理类
/// 功能：管理官方挑战和榜单数据
/// 职责：挑战列表、参与挑战、排行榜
@MainActor
class ChallengeViewModel_Glasspaint {
    
    /// 单例
    static let shared_Glasspaint = ChallengeViewModel_Glasspaint()
    
    // MARK: - 通知名称
    
    /// 挑战状态更新通知
    static let challengeStateDidChangeNotification_Glasspaint = Notification.Name("ChallengeStateDidChange_Glasspaint")
    
    // MARK: - 私有属性
    
    /// 挑战列表
    private var challenges_Glasspaint: [ChallengeModel_Glasspaint] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 挑战管理
    
    /// 初始化挑战列表
    /// 功能：从本地数据加载挑战
    func initChallenges_Glasspaint() {
        challenges_Glasspaint = LocalData_Glasspaint.shared_Glasspaint.challengeList_Glasspaint
        notifyStateChange_Glasspaint()
    }
    
    /// 获取当前进行中的挑战列表
    /// 功能：筛选未结束的挑战
    /// 返回值：进行中的挑战数组
    func getActiveChallenges_Glasspaint() -> [ChallengeModel_Glasspaint] {
        let now_glasspaint = Date()
        return challenges_Glasspaint.filter { challenge_glasspaint in
            challenge_glasspaint.endDate_Glasspaint > now_glasspaint
        }
    }
    
    /// 获取所有挑战列表
    /// 功能：获取全部挑战（包括已结束）
    /// 返回值：所有挑战数组
    func getAllChallenges_Glasspaint() -> [ChallengeModel_Glasspaint] {
        return challenges_Glasspaint
    }
    
    /// 根据ID获取挑战详情
    /// 功能：查找指定ID的挑战
    /// 参数：
    /// - challengeId_glasspaint: 挑战ID
    /// 返回值：挑战模型，未找到时返回nil
    func getChallengeById_Glasspaint(challengeId_glasspaint: Int) -> ChallengeModel_Glasspaint? {
        return challenges_Glasspaint.first { $0.challengeId_Glasspaint == challengeId_glasspaint }
    }
    
    /// 参与挑战
    /// 功能：用户参与指定挑战，更新参与人数，跳转到发布页
    /// 参数：
    /// - challenge_glasspaint: 挑战模型
    func joinChallenge_Glasspaint(challenge_glasspaint: ChallengeModel_Glasspaint) {
        // 检查是否登录
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            showLoginPrompt_Glasspaint()
            return
        }
        
        // 更新参与人数
        if let index_glasspaint = challenges_Glasspaint.firstIndex(where: { $0.challengeId_Glasspaint == challenge_glasspaint.challengeId_Glasspaint }) {
            challenges_Glasspaint[index_glasspaint].participantCount_Glasspaint += 1
        }
        
        // 显示成功提示
        Utils_Glasspaint.showSuccess_Glasspaint(
            message_Glasspaint: "Joined challenge successfully!",
            image_Glasspaint: UIImage(systemName: "star.fill")
        )
        
        notifyStateChange_Glasspaint()
        
        // 延迟跳转到发布页
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            
            // 跳转到发布页，可以在发布页预填载体类型
            Navigation_Glasspaint.toRelease_Glasspaint()
        }
    }
    
    // MARK: - 公共方法 - 排行榜
    
    /// 根据分类获取排行榜
    /// 功能：按场景/载体/风格对作品进行分类排序
    /// 参数：
    /// - category_glasspaint: 排行榜分类
    /// 返回值：排序后的作品列表
    func getRankingByCategory_Glasspaint(category_glasspaint: RankingCategory_Glasspaint) -> [TitleModel_Glasspaint] {
        let allPosts_glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.getPosts_Glasspaint()
        
        // 根据分类进行排序
        switch category_glasspaint {
        case .scene_glasspaint:
            // 按场景分组，取每个场景的热门作品
            return sortBySceneRanking_Glasspaint(posts_glasspaint: allPosts_glasspaint)
            
        case .carrier_glasspaint:
            // 按载体分组，取每个载体的热门作品
            return sortByCarrierRanking_Glasspaint(posts_glasspaint: allPosts_glasspaint)
            
        case .style_glasspaint:
            // 按风格分组，取每个风格的热门作品
            return sortByStyleRanking_Glasspaint(posts_glasspaint: allPosts_glasspaint)
        }
    }
    
    // MARK: - 私有方法 - 排序逻辑
    
    /// 按场景排序
    /// 功能：计算每个作品的综合评分并排序
    /// 排序规则：点赞数 → 评论数
    /// 参数：
    /// - posts_glasspaint: 作品列表
    /// 返回值：排序后的作品列表
    private func sortBySceneRanking_Glasspaint(posts_glasspaint: [TitleModel_Glasspaint]) -> [TitleModel_Glasspaint] {
        return posts_glasspaint.sorted { post1_glasspaint, post2_glasspaint in
            calculateRankingScore_Glasspaint(post_glasspaint: post1_glasspaint) >
            calculateRankingScore_Glasspaint(post_glasspaint: post2_glasspaint)
        }
    }
    
    /// 按载体排序
    /// 功能：计算每个作品的综合评分并排序
    /// 参数：
    /// - posts_glasspaint: 作品列表
    /// 返回值：排序后的作品列表
    private func sortByCarrierRanking_Glasspaint(posts_glasspaint: [TitleModel_Glasspaint]) -> [TitleModel_Glasspaint] {
        return posts_glasspaint.sorted { post1_glasspaint, post2_glasspaint in
            calculateRankingScore_Glasspaint(post_glasspaint: post1_glasspaint) >
            calculateRankingScore_Glasspaint(post_glasspaint: post2_glasspaint)
        }
    }
    
    /// 按风格排序
    /// 功能：计算每个作品的综合评分并排序
    /// 参数：
    /// - posts_glasspaint: 作品列表
    /// 返回值：排序后的作品列表
    private func sortByStyleRanking_Glasspaint(posts_glasspaint: [TitleModel_Glasspaint]) -> [TitleModel_Glasspaint] {
        return posts_glasspaint.sorted { post1_glasspaint, post2_glasspaint in
            calculateRankingScore_Glasspaint(post_glasspaint: post1_glasspaint) >
            calculateRankingScore_Glasspaint(post_glasspaint: post2_glasspaint)
        }
    }
    
    /// 计算排行榜评分
    /// 功能：综合点赞数、评论数计算作品评分
    /// 公式：点赞数 * 7 + 评论数 * 3
    /// 参数：
    /// - post_glasspaint: 作品模型
    /// 返回值：综合评分
    private func calculateRankingScore_Glasspaint(post_glasspaint: TitleModel_Glasspaint) -> Int {
        let likesScore_glasspaint = post_glasspaint.likes_Glasspaint * 7
        let commentsScore_glasspaint = post_glasspaint.reviews_Glasspaint.count * 3
        
        return likesScore_glasspaint + commentsScore_glasspaint
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Glasspaint() {
        NotificationCenter.default.post(
            name: ChallengeViewModel_Glasspaint.challengeStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Glasspaint() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
        }
    }
}
