import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Flick {
    
    /// 单例
    static let shared_Flick = TitleViewModel_Flick()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Flick = Notification.Name("TitleStateDidChange_Flick")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Flick: [TitleModel_Flick] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Flick() -> [TitleModel_Flick] {
        return posts_Flick
    }
    
    /// 初始化帖子列表
    func initPosts_Flick() {
        posts_Flick = LocalData_Flick.shared_Flick.titleList_Flick
        notifyStateChange_Flick()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Flick(user_flick: PrewUserModel_Flick, type_flick: Int? = nil) -> [TitleModel_Flick] {
        guard let userId_flick = user_flick.userId_Flick else { return [] }
        
        var filteredPosts_flick = posts_Flick.filter { post in
            post.titleUserId_Flick == userId_flick
        }
        
        // 如果指定了类型，进一步筛选
        if type_flick != nil {
            filteredPosts_flick = filteredPosts_flick.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_flick
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Flick(post_flick: TitleModel_Flick) -> Bool {
        return UserViewModel_Flick.shared_Flick.isLikedByCurrentUser_Flick(post_flick: post_flick)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Flick(
        title_flick: String,
        content_flick: String,
        media_flick: String,
        type_flick: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Flick.shared_Flick.isLoggedIn_Flick {
            showLoginPrompt_Flick()
            return
        }
        
        // 获取当前用户信息
        let currentUser_flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
        
        let newPostId_flick = posts_Flick.count + 20 + 1
        
        let newPost_flick = TitleModel_Flick(
            titleId_Flick: newPostId_flick,
            titleUserId_Flick: currentUser_flick.userId_Flick ?? 0,
            titleUserName_Flick: currentUser_flick.userName_Flick ?? "User",
            titleMeidas_Flick: [media_flick],
            title_Flick: title_flick,
            titleContent_Flick: content_flick,
            reviews_Flick: [],
            likes_Flick: 0
        )
        
        posts_Flick.append(newPost_flick)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Flick.shared_Flick.addPostToCurrentUser_Flick(post_flick: newPost_flick)
        
        Utils_Flick.showSuccess_Flick(
            message_Flick: "Published successfully.",
            image_Flick: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Flick()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Flick(post_flick: TitleModel_Flick, isDelete_flick: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Flick.shared_Flick.removePostFromCurrentUser_Flick(post_flick: post_flick)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Flick.shared_Flick.removeLikeFromCurrentUser_Flick(post_flick: post_flick)
        
        // 从帖子列表中移除
        posts_Flick.removeAll { $0.titleId_Flick == post_flick.titleId_Flick }
        
        let message_flick = isDelete_flick
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Flick.showSuccess_Flick(
            message_Flick: message_flick,
            image_Flick: UIImage(systemName: "trash.fill"),
            delay_Flick: 1.5
        )
        
        notifyStateChange_Flick()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Flick(userId_flick: Int) {
        posts_Flick.removeAll { post in
            post.titleUserId_Flick == userId_flick
        }
        notifyStateChange_Flick()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Flick(post_flick: TitleModel_Flick, content_flick: String) {
        // 检查是否登录
        if !UserViewModel_Flick.shared_Flick.isLoggedIn_Flick {
            showLoginPrompt_Flick()
            return
        }
        
        // 获取当前用户信息
        let currentUser_flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
        
        let newCommentId_flick = post_flick.reviews_Flick.count + 1
        
        let newComment_flick = Comment_Flick(
            commentId_Flick: newCommentId_flick,
            commentUserId_Flick: currentUser_flick.userId_Flick ?? 0,
            commentUserName_Flick: currentUser_flick.userName_Flick ?? "User",
            commentContent_Flick: content_flick
        )
        
        // 找到对应的帖子并添加评论
        if let index_flick = posts_Flick.firstIndex(where: { $0.titleId_Flick == post_flick.titleId_Flick }) {
            posts_Flick[index_flick].reviews_Flick.append(newComment_flick)
        }
        
        notifyStateChange_Flick()
    }
    
    /// 删除评论
    func deleteComment_Flick(
        post_flick: TitleModel_Flick,
        comment_flick: Comment_Flick,
        isDelete_flick: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_flick = posts_Flick.firstIndex(where: { $0.titleId_Flick == post_flick.titleId_Flick }) {
            posts_Flick[index_flick].reviews_Flick.removeAll { comment in
                comment.commentId_Flick == comment_flick.commentId_Flick
            }
        }
        
        let message_flick = isDelete_flick
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Flick.showSuccess_Flick(
            message_Flick: message_flick,
            delay_Flick: 1.5
        )
        
        notifyStateChange_Flick()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Flick(post_flick: TitleModel_Flick) {
        // 检查是否登录
        if !UserViewModel_Flick.shared_Flick.isLoggedIn_Flick {
            showLoginPrompt_Flick()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Flick(post_flick: post_flick) {
            // 取消点赞
            UserViewModel_Flick.shared_Flick.removeLikeFromCurrentUser_Flick(post_flick: post_flick)
            
            // 更新帖子的点赞数
            if let index_flick = posts_Flick.firstIndex(where: { $0.titleId_Flick == post_flick.titleId_Flick }) {
                posts_Flick[index_flick].likes_Flick = max(0, posts_Flick[index_flick].likes_Flick - 1)
            }
        } else {
            // 点赞
            UserViewModel_Flick.shared_Flick.addLikeToCurrentUser_Flick(post_flick: post_flick)
            
            // 更新帖子的点赞数
            if let index_flick = posts_Flick.firstIndex(where: { $0.titleId_Flick == post_flick.titleId_Flick }) {
                posts_Flick[index_flick].likes_Flick += 1
            }
        }
        
        notifyStateChange_Flick()
    }
    
    // MARK: - 公共方法 - 筛选与搜索
    
    /// 帖子分类枚举
    enum PostCategory_Flick {
        /// 全部帖子
        case all_flick
        /// 热门（按点赞数降序）
        case hot_flick
        /// 最新（倒序）
        case newest_flick
        /// 关注用户的帖子
        case following_flick
    }
    
    /// 按分类获取帖子列表
    /// - Parameter category_flick: 分类类型
    /// - Returns: 筛选后的帖子数组
    func getFilteredPosts_Flick(category_flick: PostCategory_Flick) -> [TitleModel_Flick] {
        switch category_flick {
        case .all_flick:
            return posts_Flick
        case .hot_flick:
            return posts_Flick.sorted { $0.likes_Flick > $1.likes_Flick }
        case .newest_flick:
            return posts_Flick.reversed()
        case .following_flick:
            let followedIds_flick = UserViewModel_Flick.shared_Flick.getFollowingUserIds_Flick()
            if followedIds_flick.isEmpty { return [] }
            return posts_Flick.filter { followedIds_flick.contains($0.titleUserId_Flick) }
        }
    }
    
    /// 按关键词搜索帖子（匹配标题或内容）
    /// - Parameter keyword_flick: 搜索关键词
    /// - Returns: 命中的帖子数组
    func searchPosts_Flick(keyword_flick: String) -> [TitleModel_Flick] {
        let trimmed_flick = keyword_flick.trimmingCharacters(in: .whitespaces)
        guard !trimmed_flick.isEmpty else { return [] }
        let lower_flick = trimmed_flick.lowercased()
        return posts_Flick.filter {
            $0.title_Flick.lowercased().contains(lower_flick)
            || $0.titleContent_Flick.lowercased().contains(lower_flick)
            || $0.titleUserName_Flick.lowercased().contains(lower_flick)
        }
    }
    
    /// 获取热门帖子（按点赞数降序，取前N条）
    /// - Parameter count_flick: 取出条数，默认5
    /// - Returns: 热门帖子数组
    func getHotPosts_Flick(count_flick: Int = 5) -> [TitleModel_Flick] {
        return Array(posts_Flick.sorted { $0.likes_Flick > $1.likes_Flick }.prefix(count_flick))
    }
    
    // MARK: - 官方半截碎念挑战操作

    /// 通知名称（挑战补全状态变更）
    static let challengeStateDidChangeNotification_Flick = Notification.Name("ChallengeStateDidChange_Flick")

    /// 获取所有官方挑战列表
    func getChallenges_Flick() -> [HalfChallenge_Flick] {
        return LocalData_Flick.shared_Flick.halfChallenges_Flick
    }

    /// 为指定挑战添加补全内容
    /// - Parameters:
    ///   - challenge_flick: 目标挑战
    ///   - content_flick: 用户补全的后半段内容
    func addChallengeCompletion_Flick(challenge_flick: HalfChallenge_Flick, content_flick: String) {
        guard UserViewModel_Flick.shared_Flick.isLoggedIn_Flick else {
            Task { try? await Task.sleep(nanoseconds: 500_000_000)
                Navigation_Flick.toLogin_Flick(style_flick: .present_flick) }
            return
        }
        let trimmed_flick = content_flick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_flick.isEmpty else { return }
        let currentUser_flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
        let maxId_flick = (challenge_flick.completions_Flick.map { $0.commentId_Flick }.max() ?? 0) + 1
        let completion_flick = Comment_Flick(
            commentId_Flick: maxId_flick,
            commentUserId_Flick: currentUser_flick.userId_Flick ?? 0,
            commentUserName_Flick: currentUser_flick.userName_Flick ?? "Anonymous",
            commentContent_Flick: trimmed_flick
        )
        challenge_flick.completions_Flick.append(completion_flick)
        notifyChallengeChange_Flick()
    }

    /// 删除指定挑战中的某条补全
    /// - Parameters:
    ///   - challenge_flick: 目标挑战
    ///   - commentId_flick: 要删除的补全 ID
    func deleteChallengeCompletion_Flick(challenge_flick: HalfChallenge_Flick, commentId_flick: Int) {
        challenge_flick.completions_Flick.removeAll { $0.commentId_Flick == commentId_flick }
        notifyChallengeChange_Flick()
    }

    /// 发送挑战状态更新通知
    private func notifyChallengeChange_Flick() {
        NotificationCenter.default.post(
            name: TitleViewModel_Flick.challengeStateDidChangeNotification_Flick,
            object: nil
        )
    }

    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Flick() {
        NotificationCenter.default.post(
            name: TitleViewModel_Flick.titleStateDidChangeNotification_Flick,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Flick() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Flick.toLogin_Flick(style_flick: .present_flick)
        }
    }
}

