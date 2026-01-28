import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Wanderbell {
    
    /// 单例
    static let shared_Wanderbell = TitleViewModel_Wanderbell()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Wanderbell = Notification.Name("TitleStateDidChange_Wanderbell")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Wanderbell: [TitleModel_Wanderbell] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Wanderbell() -> [TitleModel_Wanderbell] {
        return posts_Wanderbell
    }
    
    /// 初始化帖子列表
    func initPosts_Wanderbell() {
        posts_Wanderbell = LocalData_Wanderbell.shared_Wanderbell.titleList_Wanderbell
        notifyStateChange_Wanderbell()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Wanderbell(user_wanderbell: PrewUserModel_Wanderbell, type_wanderbell: Int? = nil) -> [TitleModel_Wanderbell] {
        guard let userId_wanderbell = user_wanderbell.userId_Wanderbell else { return [] }
        
        var filteredPosts_wanderbell = posts_Wanderbell.filter { post in
            post.titleUserId_Wanderbell == userId_wanderbell
        }
        
        // 如果指定了类型，进一步筛选
        if type_wanderbell != nil {
            filteredPosts_wanderbell = filteredPosts_wanderbell.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_wanderbell
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Wanderbell(post_wanderbell: TitleModel_Wanderbell) -> Bool {
        return UserViewModel_Wanderbell.shared_Wanderbell.isLikedByCurrentUser_Wanderbell(post_wanderbell: post_wanderbell)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Wanderbell(
        title_wanderbell: String,
        content_wanderbell: String,
        media_wanderbell: String,
        type_wanderbell: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            showLoginPrompt_Wanderbell()
            return
        }
        
        // 获取当前用户信息
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        
        let newPostId_wanderbell = posts_Wanderbell.count + 20 + 1
        
        let newPost_wanderbell = TitleModel_Wanderbell(
            titleId_Wanderbell: newPostId_wanderbell,
            titleUserId_Wanderbell: currentUser_wanderbell.userId_Wanderbell ?? 0,
            titleUserName_Wanderbell: currentUser_wanderbell.userName_Wanderbell ?? "User",
            titleMeidas_Wanderbell: [media_wanderbell],
            title_Wanderbell: title_wanderbell,
            titleContent_Wanderbell: content_wanderbell,
            reviews_Wanderbell: [],
            likes_Wanderbell: 0
        )
        
        posts_Wanderbell.append(newPost_wanderbell)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Wanderbell.shared_Wanderbell.addPostToCurrentUser_Wanderbell(post_wanderbell: newPost_wanderbell)
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Published successfully.",
            image_wanderbell: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Wanderbell(post_wanderbell: TitleModel_Wanderbell, isDelete_wanderbell: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Wanderbell.shared_Wanderbell.removePostFromCurrentUser_Wanderbell(post_wanderbell: post_wanderbell)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Wanderbell.shared_Wanderbell.removeLikeFromCurrentUser_Wanderbell(post_wanderbell: post_wanderbell)
        
        // 从帖子列表中移除
        posts_Wanderbell.removeAll { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }
        
        let message_wanderbell = isDelete_wanderbell
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: message_wanderbell,
            image_wanderbell: UIImage(systemName: "trash.fill"),
            delay_wanderbell: 1.5
        )
        
        notifyStateChange_Wanderbell()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Wanderbell(userId_wanderbell: Int) {
        posts_Wanderbell.removeAll { post in
            post.titleUserId_Wanderbell == userId_wanderbell
        }
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Wanderbell(post_wanderbell: TitleModel_Wanderbell, content_wanderbell: String) {
        // 检查是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            showLoginPrompt_Wanderbell()
            return
        }
        
        // 获取当前用户信息
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        
        let newCommentId_wanderbell = post_wanderbell.reviews_Wanderbell.count + 1
        
        let newComment_wanderbell = Comment_Wanderbell(
            commentId_Wanderbell: newCommentId_wanderbell,
            commentUserId_Wanderbell: currentUser_wanderbell.userId_Wanderbell ?? 0,
            commentUserName_Wanderbell: currentUser_wanderbell.userName_Wanderbell ?? "User",
            commentContent_Wanderbell: content_wanderbell
        )
        
        // 找到对应的帖子并添加评论
        if let index_wanderbell = posts_Wanderbell.firstIndex(where: { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }) {
            posts_Wanderbell[index_wanderbell].reviews_Wanderbell.append(newComment_wanderbell)
        }
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Comment posted",
            image_wanderbell: UIImage(systemName: "bubble.left.fill")
        )
        
        notifyStateChange_Wanderbell()
    }
    
    /// 删除评论
    func deleteComment_Wanderbell(
        post_wanderbell: TitleModel_Wanderbell,
        comment_wanderbell: Comment_Wanderbell,
        isDelete_wanderbell: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_wanderbell = posts_Wanderbell.firstIndex(where: { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }) {
            posts_Wanderbell[index_wanderbell].reviews_Wanderbell.removeAll { comment in
                comment.commentId_Wanderbell == comment_wanderbell.commentId_Wanderbell
            }
        }
        
        let message_wanderbell = isDelete_wanderbell
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: message_wanderbell,
            delay_wanderbell: 1.5
        )
        
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Wanderbell(post_wanderbell: TitleModel_Wanderbell) {
        // 检查是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            showLoginPrompt_Wanderbell()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Wanderbell(post_wanderbell: post_wanderbell) {
            // 取消点赞
            UserViewModel_Wanderbell.shared_Wanderbell.removeLikeFromCurrentUser_Wanderbell(post_wanderbell: post_wanderbell)
            
            // 更新帖子的点赞数
            if let index_wanderbell = posts_Wanderbell.firstIndex(where: { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }) {
                posts_Wanderbell[index_wanderbell].likes_Wanderbell = max(0, posts_Wanderbell[index_wanderbell].likes_Wanderbell - 1)
            }
        } else {
            // 点赞
            UserViewModel_Wanderbell.shared_Wanderbell.addLikeToCurrentUser_Wanderbell(post_wanderbell: post_wanderbell)
            
            // 更新帖子的点赞数
            if let index_wanderbell = posts_Wanderbell.firstIndex(where: { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }) {
                posts_Wanderbell[index_wanderbell].likes_Wanderbell += 1
            }
        }
        
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Wanderbell() {
        NotificationCenter.default.post(
            name: TitleViewModel_Wanderbell.titleStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Wanderbell() {
        Utils_Wanderbell.showWarning_Wanderbell(
            message_wanderbell: "Please login first.",
            delay_wanderbell: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .present_wanderbell)
        }
    }
}

