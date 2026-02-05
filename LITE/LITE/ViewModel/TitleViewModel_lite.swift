import Foundation
import UIKit
import Combine

// MARK: - 帖子ViewModel

/// 帖子状态管理类
class TitleViewModel_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = TitleViewModel_lite()
    
    // MARK: - 响应式属性
    
    /// 帖子列表
    @Published var posts_lite: [TitleModel_lite] = []
    
    /// 用户参与的挑战ID集合（用于追踪参与状态）
    @Published var participatedChallenges_lite: Set<Int> = []
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_lite() -> [TitleModel_lite] {
        return posts_lite
    }
    
    /// 初始化帖子列表
    func initPosts_lite() {
        posts_lite = LocalData_lite.shared_lite.titleList_lite
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_lite(user_lite: PrewUserModel_lite, type_lite: Int? = nil) -> [TitleModel_lite] {
        guard let userId_lite = user_lite.userId_lite else { return [] }
        
        var filteredPosts_lite = posts_lite.filter { post_lite in
            post_lite.titleUserId_lite == userId_lite
        }
        
        // 如果指定了类型，进一步筛选
        if type_lite != nil {
            filteredPosts_lite = filteredPosts_lite.filter { post_lite in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_lite
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_lite(post_lite: TitleModel_lite) -> Bool {
        return UserViewModel_lite.shared_lite.isLikedByCurrentUser_lite(post_lite: post_lite)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_lite(
        title_lite: String,
        content_lite: String,
        media_lite: String,
        type_lite: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let newPostId_lite = posts_lite.count + 20 + 1
        
        let newPost_lite = TitleModel_lite(
            titleId_lite: newPostId_lite,
            titleUserId_lite: currentUser_lite.userId_lite ?? 0,
            titleUserName_lite: currentUser_lite.userName_lite ?? "User",
            titleMeidas_lite: [media_lite],
            title_lite: title_lite,
            titleContent_lite: content_lite,
            reviews_lite: [],
            likes_lite: 0
        )
        
        posts_lite.append(newPost_lite)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_lite.shared_lite.addPostToCurrentUser_lite(post_lite: newPost_lite)
        
        Utils_lite.showSuccess_lite(
            message_lite: "Published successfully.",
            image_lite: UIImage(systemName: "checkmark.circle.fill")
        )
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_lite(post_lite: TitleModel_lite, isDelete_lite: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_lite.shared_lite.removePostFromCurrentUser_lite(post_lite: post_lite)
        
        // 从用户的喜欢列表中移除
        UserViewModel_lite.shared_lite.removeLikeFromCurrentUser_lite(post_lite: post_lite)
        
        // 从帖子列表中移除
        posts_lite.removeAll { $0.titleId_lite == post_lite.titleId_lite }
        
        let message_lite = isDelete_lite
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_lite.showSuccess_lite(
            message_lite: message_lite,
            image_lite: UIImage(systemName: "trash.fill"),
            delay_lite: 1.5
        )
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_lite(userId_lite: Int) {
        posts_lite.removeAll { post_lite in
            post_lite.titleUserId_lite == userId_lite
        }
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_lite(post_lite: TitleModel_lite, content_lite: String) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let newCommentId_lite = post_lite.reviews_lite.count + 1
        
        let newComment_lite = Comment_lite(
            commentId_lite: newCommentId_lite,
            commentUserId_lite: currentUser_lite.userId_lite ?? 0,
            commentUserName_lite: currentUser_lite.userName_lite ?? "User",
            commentContent_lite: content_lite
        )
        
        // 找到对应的帖子并添加评论
        if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
            posts_lite[index_lite].reviews_lite.append(newComment_lite)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        Utils_lite.showSuccess_lite(
            message_lite: "Comment posted",
            image_lite: UIImage(systemName: "bubble.left.fill")
        )
    }
    
    /// 删除评论
    func deleteComment_lite(
        post_lite: TitleModel_lite,
        comment_lite: Comment_lite,
        isDelete_lite: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
            posts_lite[index_lite].reviews_lite.removeAll { comment_lite in
                comment_lite.commentId_lite == comment_lite.commentId_lite
            }
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        let message_lite = isDelete_lite
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_lite.showSuccess_lite(
            message_lite: message_lite,
            delay_lite: 1.5
        )
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_lite(post_lite: TitleModel_lite) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_lite(post_lite: post_lite) {
            // 取消点赞
            UserViewModel_lite.shared_lite.removeLikeFromCurrentUser_lite(post_lite: post_lite)
            
            // 更新帖子的点赞数
            if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
                posts_lite[index_lite].likes_lite = max(0, posts_lite[index_lite].likes_lite - 1)
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        } else {
            // 点赞
            UserViewModel_lite.shared_lite.addLikeToCurrentUser_lite(post_lite: post_lite)
            
            // 更新帖子的点赞数
            if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
                posts_lite[index_lite].likes_lite += 1
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        }
    }
    
    // MARK: - 公共方法 - 穿搭组合管理
    
    /// 获取今日推荐的穿搭组合
    func getTodayRecommendations_lite(scene_lite: OutfitScene_lite? = nil) -> [OutfitCombo_lite] {
        var combos_lite = LocalData_lite.shared_lite.outfitComboList_lite
        
        // 如果指定了场景，按场景筛选
        if let scene_lite = scene_lite {
            combos_lite = combos_lite.filter { $0.scene_lite == scene_lite }
        }
        
        // 随机返回2-3套
        let count_lite = min(Int.random(in: 2...3), combos_lite.count)
        return Array(combos_lite.shuffled().prefix(count_lite))
    }
    
    /// 收藏穿搭组合
    func favoriteOutfit_lite(outfit_lite: OutfitCombo_lite) {
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        if let index_lite = LocalData_lite.shared_lite.outfitComboList_lite.firstIndex(where: { $0.comboId_lite == outfit_lite.comboId_lite }) {
            LocalData_lite.shared_lite.outfitComboList_lite[index_lite].isFavorited_lite.toggle()
            
            let message_lite = LocalData_lite.shared_lite.outfitComboList_lite[index_lite].isFavorited_lite
                ? "Added to favorites"
                : "Removed from favorites"
            
            Utils_lite.showSuccess_lite(
                message_lite: message_lite,
                image_lite: UIImage(systemName: "heart.fill")
            )
        }
    }
    
    /// 标记为当日穿搭
    func markAsDailyOutfit_lite(outfit_lite: OutfitCombo_lite) {
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        if let index_lite = LocalData_lite.shared_lite.outfitComboList_lite.firstIndex(where: { $0.comboId_lite == outfit_lite.comboId_lite }) {
            LocalData_lite.shared_lite.outfitComboList_lite[index_lite].isDailyOutfit_lite = true
            
            // 自动添加到时光轴
            addToTimeline_lite(outfit_lite: outfit_lite)
            
            Utils_lite.showSuccess_lite(
                message_lite: "Marked as today's outfit",
                image_lite: UIImage(systemName: "calendar.badge.checkmark")
            )
        }
    }
    
    /// 添加到穿搭时光轴
    func addToTimeline_lite(outfit_lite: OutfitCombo_lite, note_lite: String? = nil, memoryTag_lite: String? = nil) {
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        _ = OutfitTimeline_lite(
            timelineId_lite: Int.random(in: 1000...9999),
            userId_lite: currentUser_lite.userId_lite ?? 0,
            outfit_lite: outfit_lite,
            recordDate_lite: Date(),
            note_lite: note_lite,
            memoryTag_lite: memoryTag_lite
        )
        
        // 这里应该保存到用户的时光轴列表中
        Utils_lite.showSuccess_lite(
            message_lite: "Added to timeline",
            image_lite: UIImage(systemName: "clock.arrow.circlepath")
        )
    }
    
    /// 点赞穿搭组合
    func likeOutfit_lite(outfit_lite: OutfitCombo_lite) {
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        if let index_lite = LocalData_lite.shared_lite.outfitComboList_lite.firstIndex(where: { $0.comboId_lite == outfit_lite.comboId_lite }) {
            LocalData_lite.shared_lite.outfitComboList_lite[index_lite].likes_lite += 1
        }
    }
    
    // MARK: - 公共方法 - 挑战管理
    
    /// 获取活跃的挑战列表
    func getActiveChallenges_lite() -> [OutfitChallenge_lite] {
        return LocalData_lite.shared_lite.challengeList_lite.filter { $0.isActive_lite }
    }
    
    /// 参与挑战
    func joinChallenge_lite(challenge_lite: OutfitChallenge_lite, outfit_lite: OutfitCombo_lite) {
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 验证穿搭是否包含基础单品
        let hasBaseItem_lite = outfit_lite.items_lite.contains { item_lite in
            item_lite.itemId_lite == challenge_lite.baseItem_lite.itemId_lite
        }
        
        guard hasBaseItem_lite else {
            Utils_lite.showWarning_lite(
                message_lite: "Your outfit must include the challenge base item"
            )
            return
        }
        
        // 添加到挑战提交列表
        if let index_lite = LocalData_lite.shared_lite.challengeList_lite.firstIndex(where: { $0.challengeId_lite == challenge_lite.challengeId_lite }) {
            LocalData_lite.shared_lite.challengeList_lite[index_lite].submissions_lite.append(outfit_lite)
            
            Utils_lite.showSuccess_lite(
                message_lite: "Successfully joined the challenge!",
                image_lite: UIImage(systemName: "trophy.fill")
            )
        }
    }
    
    /// 创建新挑战
    func createChallenge_lite(
        title_lite: String,
        description_lite: String,
        baseItem_lite: OutfitItem_lite,
        endDate_lite: Date
    ) {
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let newChallenge_lite = OutfitChallenge_lite(
            challengeId_lite: LocalData_lite.shared_lite.challengeList_lite.count + 1,
            challengeTitle_lite: title_lite,
            challengeDescription_lite: description_lite,
            baseItem_lite: baseItem_lite,
            creatorUserId_lite: currentUser_lite.userId_lite ?? 0,
            creatorUserName_lite: currentUser_lite.userName_lite ?? "User",
            submissions_lite: [],
            createDate_lite: Date(),
            endDate_lite: endDate_lite,
            isOfficial_lite: false,
            isActive_lite: true
        )
        
        LocalData_lite.shared_lite.challengeList_lite.append(newChallenge_lite)
        
        Utils_lite.showSuccess_lite(
            message_lite: "Challenge created successfully!",
            image_lite: UIImage(systemName: "flag.checkered")
        )
    }
    
    // MARK: - 公共方法 - 时光胶囊管理
    
    /// 创建时光胶囊
    func createCapsule_lite(
        outfit_lite: OutfitCombo_lite,
        thoughtNote_lite: String,
        unlockDate_lite: Date
    ) {
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let capsule_lite = OutfitCapsule_lite(
            capsuleId_lite: LocalData_lite.shared_lite.capsuleList_lite.count + 1,
            userId_lite: currentUser_lite.userId_lite ?? 0,
            outfit_lite: outfit_lite,
            thoughtNote_lite: thoughtNote_lite,
            sealDate_lite: Date(),
            unlockDate_lite: unlockDate_lite,
            isUnlocked_lite: false
        )
        
        LocalData_lite.shared_lite.capsuleList_lite.append(capsule_lite)
        
        Utils_lite.showSuccess_lite(
            message_lite: "Time capsule sealed successfully!",
            image_lite: UIImage(systemName: "lock.fill")
        )
    }
    
    /// 解锁时光胶囊
    func unlockCapsule_lite(capsule_lite: OutfitCapsule_lite, unlockNote_lite: String? = nil) {
        // 检查是否到达解锁时间
        guard Date() >= capsule_lite.unlockDate_lite else {
            Utils_lite.showWarning_lite(
                message_lite: "This capsule is not ready to unlock yet"
            )
            return
        }
        
        if let index_lite = LocalData_lite.shared_lite.capsuleList_lite.firstIndex(where: { $0.capsuleId_lite == capsule_lite.capsuleId_lite }) {
            LocalData_lite.shared_lite.capsuleList_lite[index_lite].isUnlocked_lite = true
            LocalData_lite.shared_lite.capsuleList_lite[index_lite].unlockNote_lite = unlockNote_lite
            
            Utils_lite.showSuccess_lite(
                message_lite: "Time capsule unlocked!",
                image_lite: UIImage(systemName: "lock.open.fill"),
                delay_lite: 2.0
            )
        }
    }
    
    /// 获取用户的时光胶囊列表
    func getUserCapsules_lite(userId_lite: Int) -> [OutfitCapsule_lite] {
        return LocalData_lite.shared_lite.capsuleList_lite.filter { $0.userId_lite == userId_lite }
    }
    
    // MARK: - 公共方法 - 灵感评论管理
    
    /// 检查用户是否已参与挑战
    func hasParticipatedInChallenge_lite(challengeId_lite: Int) -> Bool {
        return participatedChallenges_lite.contains(challengeId_lite)
    }
    
    /// 标记用户已参与挑战
    func markChallengeAsParticipated_lite(challengeId_lite: Int) {
        participatedChallenges_lite.insert(challengeId_lite)
    }
    
    /// 发布灵感评论
    func releaseInspirationComment_lite(challenge_lite: OutfitChallenge_lite, content_lite: String) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let newCommentId_lite = Int.random(in: 10000...99999)
        
        let newComment_lite = Comment_lite(
            commentId_lite: newCommentId_lite,
            commentUserId_lite: currentUser_lite.userId_lite ?? 0,
            commentUserName_lite: currentUser_lite.userName_lite ?? "User",
            commentContent_lite: content_lite
        )
        
        // 找到对应的挑战并添加评论到submissions的第一个（作为评论区）
        if let index_lite = LocalData_lite.shared_lite.challengeList_lite.firstIndex(where: { $0.challengeId_lite == challenge_lite.challengeId_lite }) {
            // 将评论添加到挑战的评论列表（这里我们需要扩展模型）
            // 暂时通过创建一个虚拟的帖子来存储评论
            let inspirationPost_lite = TitleModel_lite(
                titleId_lite: newCommentId_lite,
                titleUserId_lite: currentUser_lite.userId_lite ?? 0,
                titleUserName_lite: currentUser_lite.userName_lite ?? "User",
                titleMeidas_lite: [],
                title_lite: "Inspiration Share",
                titleContent_lite: content_lite,
                reviews_lite: [],
                likes_lite: 0
            )
            
            // 创建一个虚拟的穿搭组合来承载评论
            let inspirationCombo_lite = OutfitCombo_lite(
                comboId_lite: newCommentId_lite,
                comboTitle_lite: content_lite,
                comboDescription_lite: "User inspiration",
                items_lite: [challenge_lite.baseItem_lite],
                style_lite: .casual_lite,
                scene_lite: .daily_lite,
                createDate_lite: Date(),
                userId_lite: currentUser_lite.userId_lite
            )
            
            LocalData_lite.shared_lite.challengeList_lite[index_lite].submissions_lite.append(inspirationCombo_lite)
            
            // 标记用户已参与
            markChallengeAsParticipated_lite(challengeId_lite: challenge_lite.challengeId_lite)
            
            // 手动触发更新 - 通知 LocalData_lite 和 TitleViewModel_lite
            LocalData_lite.shared_lite.objectWillChange.send()
            objectWillChange.send()
        }
        
        Utils_lite.showSuccess_lite(
            message_lite: "Inspiration posted!",
            image_lite: UIImage(systemName: "lightbulb.fill")
        )
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_lite() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_lite.shared_lite.toLogin_liteui()
        }
    }
}
