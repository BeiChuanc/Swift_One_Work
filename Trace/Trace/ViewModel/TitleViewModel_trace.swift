import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Trace {
    
    /// 单例
    static let shared_Trace = TitleViewModel_Trace()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Trace = Notification.Name("TitleStateDidChange_Trace")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Trace: [TitleModel_Trace] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Trace() -> [TitleModel_Trace] {
        return posts_Trace
    }
    
    /// 初始化帖子列表
    func initPosts_Trace() {
        posts_Trace = LocalData_Trace.shared_Trace.titleList_Trace
        notifyStateChange_Trace()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Trace(user_trace: PrewUserModel_Trace, type_trace: Int? = nil) -> [TitleModel_Trace] {
        guard let userId_trace = user_trace.userId_Trace else { return [] }
        
        var filteredPosts_trace = posts_Trace.filter { post in
            post.titleUserId_Trace == userId_trace
        }
        
        // 如果指定了类型，进一步筛选
        if type_trace != nil {
            filteredPosts_trace = filteredPosts_trace.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_trace
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Trace(post_trace: TitleModel_Trace) -> Bool {
        return UserViewModel_Trace.shared_Trace.isLikedByCurrentUser_Trace(post_trace: post_trace)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Trace(
        title_trace: String,
        content_trace: String,
        media_trace: String,
        type_trace: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Trace.shared_Trace.isLoggedIn_Trace {
            showLoginPrompt_Trace()
            return
        }
        
        // 获取当前用户信息
        let currentUser_trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        
        let newPostId_trace = posts_Trace.count + 20 + 1
        
        let newPost_trace = TitleModel_Trace(
            titleId_Trace: newPostId_trace,
            titleUserId_Trace: currentUser_trace.userId_Trace ?? 0,
            titleUserName_Trace: currentUser_trace.userName_Trace ?? "User",
            titleMeidas_Trace: [media_trace],
            title_Trace: title_trace,
            titleContent_Trace: content_trace,
            reviews_Trace: [],
            likes_Trace: 0
        )
        
        posts_Trace.append(newPost_trace)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Trace.shared_Trace.addPostToCurrentUser_Trace(post_trace: newPost_trace)
        
        Utils_Trace.showSuccess_Trace(
            message_Trace: "Published successfully.",
            image_Trace: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Trace()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Trace(post_trace: TitleModel_Trace, isDelete_trace: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Trace.shared_Trace.removePostFromCurrentUser_Trace(post_trace: post_trace)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Trace.shared_Trace.removeLikeFromCurrentUser_Trace(post_trace: post_trace)
        
        // 从帖子列表中移除
        posts_Trace.removeAll { $0.titleId_Trace == post_trace.titleId_Trace }
        
        let message_trace = isDelete_trace
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Trace.showSuccess_Trace(
            message_Trace: message_trace,
            image_Trace: UIImage(systemName: "trash.fill"),
            delay_Trace: 1.5
        )
        
        notifyStateChange_Trace()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Trace(userId_trace: Int) {
        posts_Trace.removeAll { post in
            post.titleUserId_Trace == userId_trace
        }
        notifyStateChange_Trace()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Trace(post_trace: TitleModel_Trace, content_trace: String) {
        // 检查是否登录
        if !UserViewModel_Trace.shared_Trace.isLoggedIn_Trace {
            showLoginPrompt_Trace()
            return
        }
        
        // 获取当前用户信息
        let currentUser_trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        
        let newCommentId_trace = post_trace.reviews_Trace.count + 1
        
        let newComment_trace = Comment_Trace(
            commentId_Trace: newCommentId_trace,
            commentUserId_Trace: currentUser_trace.userId_Trace ?? 0,
            commentUserName_Trace: currentUser_trace.userName_Trace ?? "User",
            commentContent_Trace: content_trace
        )
        
        // 找到对应的帖子并添加评论
        if let index_trace = posts_Trace.firstIndex(where: { $0.titleId_Trace == post_trace.titleId_Trace }) {
            posts_Trace[index_trace].reviews_Trace.append(newComment_trace)
        }
        
        Utils_Trace.showSuccess_Trace(
            message_Trace: "Comment posted",
            image_Trace: UIImage(systemName: "bubble.left.fill")
        )
        
        notifyStateChange_Trace()
    }
    
    /// 删除评论
    func deleteComment_Trace(
        post_trace: TitleModel_Trace,
        comment_trace: Comment_Trace,
        isDelete_trace: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_trace = posts_Trace.firstIndex(where: { $0.titleId_Trace == post_trace.titleId_Trace }) {
            posts_Trace[index_trace].reviews_Trace.removeAll { comment in
                comment.commentId_Trace == comment_trace.commentId_Trace
            }
        }
        
        let message_trace = isDelete_trace
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Trace.showSuccess_Trace(
            message_Trace: message_trace,
            delay_Trace: 1.5
        )
        
        notifyStateChange_Trace()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Trace(post_trace: TitleModel_Trace) {
        // 检查是否登录
        if !UserViewModel_Trace.shared_Trace.isLoggedIn_Trace {
            showLoginPrompt_Trace()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Trace(post_trace: post_trace) {
            // 取消点赞
            UserViewModel_Trace.shared_Trace.removeLikeFromCurrentUser_Trace(post_trace: post_trace)
            
            // 更新帖子的点赞数
            if let index_trace = posts_Trace.firstIndex(where: { $0.titleId_Trace == post_trace.titleId_Trace }) {
                posts_Trace[index_trace].likes_Trace = max(0, posts_Trace[index_trace].likes_Trace - 1)
            }
        } else {
            // 点赞
            UserViewModel_Trace.shared_Trace.addLikeToCurrentUser_Trace(post_trace: post_trace)
            
            // 更新帖子的点赞数
            if let index_trace = posts_Trace.firstIndex(where: { $0.titleId_Trace == post_trace.titleId_Trace }) {
                posts_Trace[index_trace].likes_Trace += 1
            }
        }
        
        notifyStateChange_Trace()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Trace() {
        NotificationCenter.default.post(
            name: TitleViewModel_Trace.titleStateDidChangeNotification_Trace,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Trace() {
        Utils_Trace.showWarning_Trace(
            message_Trace: "Please login first.",
            delay_Trace: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Trace.toLogin_Trace(style_trace: .present_trace)
        }
    }
}

