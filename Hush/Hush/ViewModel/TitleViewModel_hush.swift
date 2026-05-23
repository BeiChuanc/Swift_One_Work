import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Hush {
    
    /// 单例
    static let shared_Hush = TitleViewModel_Hush()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Hush = Notification.Name("TitleStateDidChange_Hush")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Hush: [TitleModel_Hush] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Hush() -> [TitleModel_Hush] {
        return posts_Hush
    }
    
    /// 初始化帖子列表
    func initPosts_Hush() {
        posts_Hush = LocalData_Hush.shared_Hush.titleList_Hush
        notifyStateChange_Hush()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Hush(user_hush: PrewUserModel_Hush, type_hush: Int? = nil) -> [TitleModel_Hush] {
        guard let userId_hush = user_hush.userId_Hush else { return [] }
        
        var filteredPosts_hush = posts_Hush.filter { post in
            post.titleUserId_Hush == userId_hush
        }
        
        // 如果指定了类型，进一步筛选
        if type_hush != nil {
            filteredPosts_hush = filteredPosts_hush.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_hush
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Hush(post_hush: TitleModel_Hush) -> Bool {
        return UserViewModel_Hush.shared_Hush.isLikedByCurrentUser_Hush(post_hush: post_hush)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Hush(
        title_hush: String,
        content_hush: String,
        media_hush: String,
        type_hush: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            showLoginPrompt_Hush()
            return
        }
        
        // 获取当前用户信息
        let currentUser_hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
        
        let newPostId_hush = posts_Hush.count + 20 + 1
        
        let newPost_hush = TitleModel_Hush(
            titleId_Hush: newPostId_hush,
            titleUserId_Hush: currentUser_hush.userId_Hush ?? 0,
            titleUserName_Hush: currentUser_hush.userName_Hush ?? "User",
            titleMeidas_Hush: [media_hush],
            title_Hush: title_hush,
            titleContent_Hush: content_hush,
            reviews_Hush: [],
            likes_Hush: 0
        )
        
        posts_Hush.append(newPost_hush)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Hush.shared_Hush.addPostToCurrentUser_Hush(post_hush: newPost_hush)
        
        Utils_Hush.showSuccess_Hush(
            message_Hush: "Published successfully.",
            image_Hush: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Hush()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Hush(post_hush: TitleModel_Hush, isDelete_hush: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Hush.shared_Hush.removePostFromCurrentUser_Hush(post_hush: post_hush)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Hush.shared_Hush.removeLikeFromCurrentUser_Hush(post_hush: post_hush)
        
        // 从帖子列表中移除
        posts_Hush.removeAll { $0.titleId_Hush == post_hush.titleId_Hush }
        
        let message_hush = isDelete_hush
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Hush.showSuccess_Hush(
            message_Hush: message_hush,
            image_Hush: UIImage(systemName: "trash.fill"),
            delay_Hush: 1.5
        )
        
        notifyStateChange_Hush()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Hush(userId_hush: Int) {
        posts_Hush.removeAll { post in
            post.titleUserId_Hush == userId_hush
        }
        notifyStateChange_Hush()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Hush(post_hush: TitleModel_Hush, content_hush: String) {
        // 检查是否登录
        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            showLoginPrompt_Hush()
            return
        }
        
        // 获取当前用户信息
        let currentUser_hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
        
        let newCommentId_hush = post_hush.reviews_Hush.count + 1
        
        let newComment_hush = Comment_Hush(
            commentId_Hush: newCommentId_hush,
            commentUserId_Hush: currentUser_hush.userId_Hush ?? 0,
            commentUserName_Hush: currentUser_hush.userName_Hush ?? "User",
            commentContent_Hush: content_hush
        )
        
        // 找到对应的帖子并添加评论
        if let index_hush = posts_Hush.firstIndex(where: { $0.titleId_Hush == post_hush.titleId_Hush }) {
            posts_Hush[index_hush].reviews_Hush.append(newComment_hush)
        }
        
        notifyStateChange_Hush()
    }
    
    /// 删除评论
    func deleteComment_Hush(
        post_hush: TitleModel_Hush,
        comment_hush: Comment_Hush,
        isDelete_hush: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_hush = posts_Hush.firstIndex(where: { $0.titleId_Hush == post_hush.titleId_Hush }) {
            posts_Hush[index_hush].reviews_Hush.removeAll { comment in
                comment.commentId_Hush == comment_hush.commentId_Hush
            }
        }
        
        let message_hush = isDelete_hush
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Hush.showSuccess_Hush(
            message_Hush: message_hush,
            delay_Hush: 1.5
        )
        
        notifyStateChange_Hush()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Hush(post_hush: TitleModel_Hush) {
        // 检查是否登录
        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            showLoginPrompt_Hush()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Hush(post_hush: post_hush) {
            // 取消点赞
            UserViewModel_Hush.shared_Hush.removeLikeFromCurrentUser_Hush(post_hush: post_hush)
            
            // 更新帖子的点赞数
            if let index_hush = posts_Hush.firstIndex(where: { $0.titleId_Hush == post_hush.titleId_Hush }) {
                posts_Hush[index_hush].likes_Hush = max(0, posts_Hush[index_hush].likes_Hush - 1)
            }
        } else {
            // 点赞
            UserViewModel_Hush.shared_Hush.addLikeToCurrentUser_Hush(post_hush: post_hush)
            
            // 更新帖子的点赞数
            if let index_hush = posts_Hush.firstIndex(where: { $0.titleId_Hush == post_hush.titleId_Hush }) {
                posts_Hush[index_hush].likes_Hush += 1
            }
        }
        
        notifyStateChange_Hush()
    }
    
    // MARK: - 季节挑战评论管理
    
    /// 季节挑战评论状态变化通知名
    static let challengeCommentDidChangeNotification_Hush = Notification.Name("ChallengeCommentDidChange_Hush")
    
    /// 获取指定季节挑战的评论列表
    /// - Parameter challengeId_hush: 挑战 ID
    /// - Returns: 评论数组
    func getChallengeComments_Hush(challengeId_hush: Int) -> [Comment_Hush] {
        return LocalData_Hush.shared_Hush.findChallenge_Hush(challengeId_hush: challengeId_hush)?.comments_Hush ?? []
    }
    
    /// 发布季节挑战评论
    /// - Parameters:
    ///   - challengeId_hush: 挑战 ID
    ///   - content_hush: 评论内容
    /// - Returns: 是否发布成功
    @discardableResult
    func releaseChallengeComment_Hush(challengeId_hush: Int, content_hush: String) -> Bool {
        guard !content_hush.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            showLoginPrompt_Hush()
            return false
        }
        
        guard let challenge_hush = LocalData_Hush.shared_Hush.findChallenge_Hush(challengeId_hush: challengeId_hush) else { return false }
        
        let currentUser_hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
        let newId_hush = (challenge_hush.comments_Hush.map { $0.commentId_Hush }.max() ?? 0) + 1
        
        let comment_hush = Comment_Hush(
            commentId_Hush: newId_hush,
            commentUserId_Hush: currentUser_hush.userId_Hush ?? 0,
            commentUserName_Hush: currentUser_hush.userName_Hush ?? "User",
            commentContent_Hush: content_hush
        )
        challenge_hush.comments_Hush.append(comment_hush)
        
        NotificationCenter.default.post(
            name: TitleViewModel_Hush.challengeCommentDidChangeNotification_Hush,
            object: nil,
            userInfo: ["challengeId": challengeId_hush]
        )
        return true
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Hush() {
        NotificationCenter.default.post(
            name: TitleViewModel_Hush.titleStateDidChangeNotification_Hush,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Hush() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Hush.toLogin_Hush(style_hush: .present_hush)
        }
    }
}

