import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Glasspaint {
    
    /// 单例
    static let shared_Glasspaint = TitleViewModel_Glasspaint()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Glasspaint = Notification.Name("TitleStateDidChange_Glasspaint")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Glasspaint: [TitleModel_Glasspaint] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Glasspaint() -> [TitleModel_Glasspaint] {
        return posts_Glasspaint
    }
    
    /// 初始化帖子列表
    func initPosts_Glasspaint() {
        posts_Glasspaint = LocalData_Glasspaint.shared_Glasspaint.titleList_Glasspaint
        notifyStateChange_Glasspaint()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Glasspaint(user_glasspaint: PrewUserModel_Glasspaint, type_glasspaint: Int? = nil) -> [TitleModel_Glasspaint] {
        guard let userId_glasspaint = user_glasspaint.userId_Glasspaint else { return [] }
        
        var filteredPosts_glasspaint = posts_Glasspaint.filter { post in
            post.titleUserId_Glasspaint == userId_glasspaint
        }
        
        // 如果指定了类型，进一步筛选
        if type_glasspaint != nil {
            filteredPosts_glasspaint = filteredPosts_glasspaint.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_glasspaint
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Glasspaint(post_glasspaint: TitleModel_Glasspaint) -> Bool {
        return UserViewModel_Glasspaint.shared_Glasspaint.isLikedByCurrentUser_Glasspaint(post_glasspaint: post_glasspaint)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Glasspaint(
        title_glasspaint: String,
        content_glasspaint: String,
        media_glasspaint: String,
        type_glasspaint: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            showLoginPrompt_Glasspaint()
            return
        }
        
        // 获取当前用户信息
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        let newPostId_glasspaint = posts_Glasspaint.count + 20 + 1
        
        let newPost_glasspaint = TitleModel_Glasspaint(
            titleId_Glasspaint: newPostId_glasspaint,
            titleUserId_Glasspaint: currentUser_glasspaint.userId_Glasspaint ?? 0,
            titleUserName_Glasspaint: currentUser_glasspaint.userName_Glasspaint ?? "User",
            titleMeidas_Glasspaint: [media_glasspaint],
            title_Glasspaint: title_glasspaint,
            titleContent_Glasspaint: content_glasspaint,
            reviews_Glasspaint: [],
            likes_Glasspaint: 0
        )
        
        posts_Glasspaint.append(newPost_glasspaint)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Glasspaint.shared_Glasspaint.addPostToCurrentUser_Glasspaint(post_glasspaint: newPost_glasspaint)
        
        Utils_Glasspaint.showSuccess_Glasspaint(
            message_Glasspaint: "Published successfully.",
            image_Glasspaint: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Glasspaint(post_glasspaint: TitleModel_Glasspaint, isDelete_glasspaint: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Glasspaint.shared_Glasspaint.removePostFromCurrentUser_Glasspaint(post_glasspaint: post_glasspaint)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Glasspaint.shared_Glasspaint.removeLikeFromCurrentUser_Glasspaint(post_glasspaint: post_glasspaint)
        
        // 从帖子列表中移除
        posts_Glasspaint.removeAll { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }
        
        let message_glasspaint = isDelete_glasspaint
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Glasspaint.showSuccess_Glasspaint(
            message_Glasspaint: message_glasspaint,
            image_Glasspaint: UIImage(systemName: "trash.fill"),
            delay_Glasspaint: 1.5
        )
        
        notifyStateChange_Glasspaint()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Glasspaint(userId_glasspaint: Int) {
        posts_Glasspaint.removeAll { post in
            post.titleUserId_Glasspaint == userId_glasspaint
        }
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Glasspaint(post_glasspaint: TitleModel_Glasspaint, content_glasspaint: String) {
        // 检查是否登录
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            showLoginPrompt_Glasspaint()
            return
        }
        
        // 获取当前用户信息
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        let newCommentId_glasspaint = post_glasspaint.reviews_Glasspaint.count + 1
        
        let newComment_glasspaint = Comment_Glasspaint(
            commentId_Glasspaint: newCommentId_glasspaint,
            commentUserId_Glasspaint: currentUser_glasspaint.userId_Glasspaint ?? 0,
            commentUserName_Glasspaint: currentUser_glasspaint.userName_Glasspaint ?? "User",
            commentContent_Glasspaint: content_glasspaint
        )
        
        // 找到对应的帖子并添加评论
        if let index_glasspaint = posts_Glasspaint.firstIndex(where: { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }) {
            posts_Glasspaint[index_glasspaint].reviews_Glasspaint.append(newComment_glasspaint)
        }
        
        Utils_Glasspaint.showSuccess_Glasspaint(
            message_Glasspaint: "Comment posted",
            image_Glasspaint: UIImage(systemName: "bubble.left.fill")
        )
        
        notifyStateChange_Glasspaint()
    }
    
    /// 删除评论
    func deleteComment_Glasspaint(
        post_glasspaint: TitleModel_Glasspaint,
        comment_glasspaint: Comment_Glasspaint,
        isDelete_glasspaint: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_glasspaint = posts_Glasspaint.firstIndex(where: { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }) {
            posts_Glasspaint[index_glasspaint].reviews_Glasspaint.removeAll { comment in
                comment.commentId_Glasspaint == comment_glasspaint.commentId_Glasspaint
            }
        }
        
        let message_glasspaint = isDelete_glasspaint
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Glasspaint.showSuccess_Glasspaint(
            message_Glasspaint: message_glasspaint,
            delay_Glasspaint: 1.5
        )
        
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Glasspaint(post_glasspaint: TitleModel_Glasspaint) {
        // 检查是否登录
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            showLoginPrompt_Glasspaint()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Glasspaint(post_glasspaint: post_glasspaint) {
            // 取消点赞
            UserViewModel_Glasspaint.shared_Glasspaint.removeLikeFromCurrentUser_Glasspaint(post_glasspaint: post_glasspaint)
            
            // 更新帖子的点赞数
            if let index_glasspaint = posts_Glasspaint.firstIndex(where: { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }) {
                posts_Glasspaint[index_glasspaint].likes_Glasspaint = max(0, posts_Glasspaint[index_glasspaint].likes_Glasspaint - 1)
            }
        } else {
            // 点赞
            UserViewModel_Glasspaint.shared_Glasspaint.addLikeToCurrentUser_Glasspaint(post_glasspaint: post_glasspaint)
            
            // 更新帖子的点赞数
            if let index_glasspaint = posts_Glasspaint.firstIndex(where: { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }) {
                posts_Glasspaint[index_glasspaint].likes_Glasspaint += 1
            }
        }
        
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Glasspaint() {
        NotificationCenter.default.post(
            name: TitleViewModel_Glasspaint.titleStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Glasspaint() {
        Utils_Glasspaint.showWarning_Glasspaint(
            message_Glasspaint: "Please login first.",
            delay_Glasspaint: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
        }
    }
}

