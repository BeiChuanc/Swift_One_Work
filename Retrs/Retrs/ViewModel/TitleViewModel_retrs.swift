import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Retrs {
    
    /// 单例
    static let shared_Retrs = TitleViewModel_Retrs()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Retrs = Notification.Name("TitleStateDidChange_Retrs")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Retrs: [TitleModel_Retrs] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Retrs() -> [TitleModel_Retrs] {
        return posts_Retrs
    }
    
    /// 初始化帖子列表
    func initPosts_Retrs() {
        posts_Retrs = LocalData_Retrs.shared_Retrs.titleList_Retrs
        notifyStateChange_Retrs()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Retrs(user_retrs: PrewUserModel_Retrs, type_retrs: Int? = nil) -> [TitleModel_Retrs] {
        guard let userId_retrs = user_retrs.userId_Retrs else { return [] }
        
        var filteredPosts_retrs = posts_Retrs.filter { post in
            post.titleUserId_Retrs == userId_retrs
        }
        
        // 如果指定了类型，进一步筛选
        if type_retrs != nil {
            filteredPosts_retrs = filteredPosts_retrs.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_retrs
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Retrs(post_retrs: TitleModel_Retrs) -> Bool {
        return UserViewModel_Retrs.shared_Retrs.isLikedByCurrentUser_Retrs(post_retrs: post_retrs)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Retrs(
        title_retrs: String,
        content_retrs: String,
        media_retrs: String,
        type_retrs: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Retrs.shared_Retrs.isLoggedIn_Retrs {
            showLoginPrompt_Retrs()
            return
        }
        
        // 获取当前用户信息
        let currentUser_retrs = UserViewModel_Retrs.shared_Retrs.getCurrentUser_Retrs()
        
        let newPostId_retrs = posts_Retrs.count + 20 + 1
        
        let newPost_retrs = TitleModel_Retrs(
            titleId_Retrs: newPostId_retrs,
            titleUserId_Retrs: currentUser_retrs.userId_Retrs ?? 0,
            titleUserName_Retrs: currentUser_retrs.userName_Retrs ?? "User",
            titleMeidas_Retrs: [media_retrs],
            title_Retrs: title_retrs,
            titleContent_Retrs: content_retrs,
            reviews_Retrs: [],
            likes_Retrs: 0
        )
        
        posts_Retrs.append(newPost_retrs)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Retrs.shared_Retrs.addPostToCurrentUser_Retrs(post_retrs: newPost_retrs)
        
        Utils_Retrs.showSuccess_Retrs(
            message_Retrs: "Published successfully.",
            image_Retrs: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Retrs()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Retrs(post_retrs: TitleModel_Retrs, isDelete_retrs: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Retrs.shared_Retrs.removePostFromCurrentUser_Retrs(post_retrs: post_retrs)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Retrs.shared_Retrs.removeLikeFromCurrentUser_Retrs(post_retrs: post_retrs)
        
        // 从帖子列表中移除
        posts_Retrs.removeAll { $0.titleId_Retrs == post_retrs.titleId_Retrs }
        
        let message_retrs = isDelete_retrs
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Retrs.showSuccess_Retrs(
            message_Retrs: message_retrs,
            image_Retrs: UIImage(systemName: "trash.fill"),
            delay_Retrs: 1.5
        )
        
        notifyStateChange_Retrs()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Retrs(userId_retrs: Int) {
        posts_Retrs.removeAll { post in
            post.titleUserId_Retrs == userId_retrs
        }
        notifyStateChange_Retrs()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Retrs(post_retrs: TitleModel_Retrs, content_retrs: String) {
        // 检查是否登录
        if !UserViewModel_Retrs.shared_Retrs.isLoggedIn_Retrs {
            showLoginPrompt_Retrs()
            return
        }
        
        // 获取当前用户信息
        let currentUser_retrs = UserViewModel_Retrs.shared_Retrs.getCurrentUser_Retrs()
        
        let newCommentId_retrs = post_retrs.reviews_Retrs.count + 1
        
        let newComment_retrs = Comment_Retrs(
            commentId_Retrs: newCommentId_retrs,
            commentUserId_Retrs: currentUser_retrs.userId_Retrs ?? 0,
            commentUserName_Retrs: currentUser_retrs.userName_Retrs ?? "User",
            commentContent_Retrs: content_retrs
        )
        
        // 找到对应的帖子并添加评论
        if let index_retrs = posts_Retrs.firstIndex(where: { $0.titleId_Retrs == post_retrs.titleId_Retrs }) {
            posts_Retrs[index_retrs].reviews_Retrs.append(newComment_retrs)
        }
        
        notifyStateChange_Retrs()
    }
    
    /// 删除评论
    func deleteComment_Retrs(
        post_retrs: TitleModel_Retrs,
        comment_retrs: Comment_Retrs,
        isDelete_retrs: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_retrs = posts_Retrs.firstIndex(where: { $0.titleId_Retrs == post_retrs.titleId_Retrs }) {
            posts_Retrs[index_retrs].reviews_Retrs.removeAll { comment in
                comment.commentId_Retrs == comment_retrs.commentId_Retrs
            }
        }
        
        let message_retrs = isDelete_retrs
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Retrs.showSuccess_Retrs(
            message_Retrs: message_retrs,
            delay_Retrs: 1.5
        )
        
        notifyStateChange_Retrs()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Retrs(post_retrs: TitleModel_Retrs) {
        // 检查是否登录
        if !UserViewModel_Retrs.shared_Retrs.isLoggedIn_Retrs {
            showLoginPrompt_Retrs()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Retrs(post_retrs: post_retrs) {
            // 取消点赞
            UserViewModel_Retrs.shared_Retrs.removeLikeFromCurrentUser_Retrs(post_retrs: post_retrs)
            
            // 更新帖子的点赞数
            if let index_retrs = posts_Retrs.firstIndex(where: { $0.titleId_Retrs == post_retrs.titleId_Retrs }) {
                posts_Retrs[index_retrs].likes_Retrs = max(0, posts_Retrs[index_retrs].likes_Retrs - 1)
            }
        } else {
            // 点赞
            UserViewModel_Retrs.shared_Retrs.addLikeToCurrentUser_Retrs(post_retrs: post_retrs)
            
            // 更新帖子的点赞数
            if let index_retrs = posts_Retrs.firstIndex(where: { $0.titleId_Retrs == post_retrs.titleId_Retrs }) {
                posts_Retrs[index_retrs].likes_Retrs += 1
            }
        }
        
        notifyStateChange_Retrs()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Retrs() {
        NotificationCenter.default.post(
            name: TitleViewModel_Retrs.titleStateDidChangeNotification_Retrs,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Retrs() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs)
        }
    }
}

