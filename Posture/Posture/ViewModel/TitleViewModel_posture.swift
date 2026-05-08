import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Posture {
    
    /// 单例
    static let shared_Posture = TitleViewModel_Posture()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Posture = Notification.Name("TitleStateDidChange_Posture")

    /// 话题状态更新通知
    static let topicStateDidChangeNotification_Posture = Notification.Name("TopicStateDidChange_Posture")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Posture: [TitleModel_Posture] = []

    /// 话题列表
    private var topics_Posture: [Topic_Posture] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Posture() -> [TitleModel_Posture] {
        return posts_Posture
    }
    
    /// 初始化帖子列表
    func initPosts_Posture() {
        posts_Posture = LocalData_Posture.shared_Posture.titleList_Posture
        notifyStateChange_Posture()
    }

    /// 初始化话题列表
    func initTopics_Posture() {
        topics_Posture = LocalData_Posture.shared_Posture.topicList_Posture
        notifyTopicStateChange_Posture()
    }

    /// 获取话题列表
    /// - Returns: [Topic_Posture] 当前话题数组
    func getTopics_Posture() -> [Topic_Posture] {
        return topics_Posture
    }

    /// 向指定话题添加评论
    /// - Parameters:
    ///   - topicId_posture: 目标话题 ID
    ///   - content_posture: 评论内容
    func addTopicComment_Posture(topicId_posture: Int, content_posture: String) {
        if !UserViewModel_Posture.shared_Posture.isLoggedIn_Posture {
            showLoginPrompt_Posture()
            return
        }
        let currentUser_posture = UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        guard let idx_posture = topics_Posture.firstIndex(where: { $0.topicId_Posture == topicId_posture }) else { return }
        let newId_posture = topics_Posture[idx_posture].comments_Posture.count + 1
        let comment_posture = Comment_Posture(
            commentId_Posture: newId_posture,
            commentUserId_Posture: currentUser_posture.userId_Posture ?? 0,
            commentUserName_Posture: currentUser_posture.userName_Posture ?? "User",
            commentContent_Posture: content_posture
        )
        topics_Posture[idx_posture].comments_Posture.append(comment_posture)
        notifyTopicStateChange_Posture()
    }

    /// 删除或举报话题中的评论
    /// - Parameters:
    ///   - topicId_posture: 目标话题 ID
    ///   - comment_posture: 待删除/举报的评论
    ///   - isDelete_posture: true 为删除（自己的），false 为举报（他人的）
    func deleteTopicComment_Posture(topicId_posture: Int, comment_posture: Comment_Posture, isDelete_posture: Bool = false) {
        guard let idx_posture = topics_Posture.firstIndex(where: { $0.topicId_Posture == topicId_posture }) else { return }
        topics_Posture[idx_posture].comments_Posture.removeAll { $0.commentId_Posture == comment_posture.commentId_Posture }
        let msg_posture = isDelete_posture ? "Deleted successfully." : "This comment will no longer appear."
        Utils_Posture.showSuccess_Posture(message_Posture: msg_posture, delay_Posture: 1.5)
        notifyTopicStateChange_Posture()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Posture(user_posture: PrewUserModel_Posture, type_posture: Int? = nil) -> [TitleModel_Posture] {
        guard let userId_posture = user_posture.userId_Posture else { return [] }
        
        var filteredPosts_posture = posts_Posture.filter { post in
            post.titleUserId_Posture == userId_posture
        }
        
        // 如果指定了类型，进一步筛选
        if type_posture != nil {
            filteredPosts_posture = filteredPosts_posture.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_posture
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Posture(post_posture: TitleModel_Posture) -> Bool {
        return UserViewModel_Posture.shared_Posture.isLikedByCurrentUser_Posture(post_posture: post_posture)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Posture(
        title_posture: String,
        content_posture: String,
        media_posture: String,
        type_posture: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Posture.shared_Posture.isLoggedIn_Posture {
            showLoginPrompt_Posture()
            return
        }
        
        // 获取当前用户信息
        let currentUser_posture = UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        
        let newPostId_posture = posts_Posture.count + 20 + 1
        
        let newPost_posture = TitleModel_Posture(
            titleId_Posture: newPostId_posture,
            titleUserId_Posture: currentUser_posture.userId_Posture ?? 0,
            titleUserName_Posture: currentUser_posture.userName_Posture ?? "User",
            titleMeidas_Posture: [media_posture],
            title_Posture: title_posture,
            titleContent_Posture: content_posture,
            reviews_Posture: [],
            likes_Posture: 0
        )
        
        posts_Posture.append(newPost_posture)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Posture.shared_Posture.addPostToCurrentUser_Posture(post_posture: newPost_posture)
        
        Utils_Posture.showSuccess_Posture(
            message_Posture: "Published successfully.",
            image_Posture: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Posture()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Posture(post_posture: TitleModel_Posture, isDelete_posture: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Posture.shared_Posture.removePostFromCurrentUser_Posture(post_posture: post_posture)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Posture.shared_Posture.removeLikeFromCurrentUser_Posture(post_posture: post_posture)
        
        // 从帖子列表中移除
        posts_Posture.removeAll { $0.titleId_Posture == post_posture.titleId_Posture }
        
        let message_posture = isDelete_posture
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Posture.showSuccess_Posture(
            message_Posture: message_posture,
            image_Posture: UIImage(systemName: "trash.fill"),
            delay_Posture: 1.5
        )
        
        notifyStateChange_Posture()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Posture(userId_posture: Int) {
        posts_Posture.removeAll { post in
            post.titleUserId_Posture == userId_posture
        }
        notifyStateChange_Posture()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Posture(post_posture: TitleModel_Posture, content_posture: String) {
        // 检查是否登录
        if !UserViewModel_Posture.shared_Posture.isLoggedIn_Posture {
            showLoginPrompt_Posture()
            return
        }
        
        // 获取当前用户信息
        let currentUser_posture = UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        
        let newCommentId_posture = post_posture.reviews_Posture.count + 1
        
        let newComment_posture = Comment_Posture(
            commentId_Posture: newCommentId_posture,
            commentUserId_Posture: currentUser_posture.userId_Posture ?? 0,
            commentUserName_Posture: currentUser_posture.userName_Posture ?? "User",
            commentContent_Posture: content_posture
        )
        
        // 找到对应的帖子并添加评论
        if let index_posture = posts_Posture.firstIndex(where: { $0.titleId_Posture == post_posture.titleId_Posture }) {
            posts_Posture[index_posture].reviews_Posture.append(newComment_posture)
        }
        
        notifyStateChange_Posture()
    }
    
    /// 删除评论
    func deleteComment_Posture(
        post_posture: TitleModel_Posture,
        comment_posture: Comment_Posture,
        isDelete_posture: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_posture = posts_Posture.firstIndex(where: { $0.titleId_Posture == post_posture.titleId_Posture }) {
            posts_Posture[index_posture].reviews_Posture.removeAll { comment in
                comment.commentId_Posture == comment_posture.commentId_Posture
            }
        }
        
        let message_posture = isDelete_posture
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Posture.showSuccess_Posture(
            message_Posture: message_posture,
            delay_Posture: 1.5
        )
        
        notifyStateChange_Posture()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Posture(post_posture: TitleModel_Posture) {
        // 检查是否登录
        if !UserViewModel_Posture.shared_Posture.isLoggedIn_Posture {
            showLoginPrompt_Posture()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Posture(post_posture: post_posture) {
            // 取消点赞
            UserViewModel_Posture.shared_Posture.removeLikeFromCurrentUser_Posture(post_posture: post_posture)
            
            // 更新帖子的点赞数
            if let index_posture = posts_Posture.firstIndex(where: { $0.titleId_Posture == post_posture.titleId_Posture }) {
                posts_Posture[index_posture].likes_Posture = max(0, posts_Posture[index_posture].likes_Posture - 1)
            }
        } else {
            // 点赞
            UserViewModel_Posture.shared_Posture.addLikeToCurrentUser_Posture(post_posture: post_posture)
            
            // 更新帖子的点赞数
            if let index_posture = posts_Posture.firstIndex(where: { $0.titleId_Posture == post_posture.titleId_Posture }) {
                posts_Posture[index_posture].likes_Posture += 1
            }
        }
        
        notifyStateChange_Posture()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送帖子状态更新通知
    private func notifyStateChange_Posture() {
        NotificationCenter.default.post(
            name: TitleViewModel_Posture.titleStateDidChangeNotification_Posture,
            object: nil
        )
    }

    /// 发送话题状态更新通知
    private func notifyTopicStateChange_Posture() {
        NotificationCenter.default.post(name: TitleViewModel_Posture.topicStateDidChangeNotification_Posture, object: nil)
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Posture() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
        }
    }
}

