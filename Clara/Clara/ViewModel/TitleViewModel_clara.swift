import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Clara {
    
    /// 单例
    static let shared_Clara = TitleViewModel_Clara()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Clara = Notification.Name("TitleStateDidChange_Clara")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Clara: [TitleModel_Clara] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Clara() -> [TitleModel_Clara] {
        return posts_Clara
    }
    
    /// 初始化帖子列表
    func initPosts_Clara() {
        posts_Clara = LocalData_Clara.shared_Clara.titleList_Clara
        notifyStateChange_Clara()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Clara(user_clara: PrewUserModel_Clara, type_clara: Int? = nil) -> [TitleModel_Clara] {
        guard let userId_clara = user_clara.userId_Clara else { return [] }
        
        var filteredPosts_clara = posts_Clara.filter { post in
            post.titleUserId_Clara == userId_clara
        }
        
        // 如果指定了类型，进一步筛选
        if type_clara != nil {
            filteredPosts_clara = filteredPosts_clara.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_clara
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Clara(post_clara: TitleModel_Clara) -> Bool {
        return UserViewModel_Clara.shared_Clara.isLikedByCurrentUser_Clara(post_clara: post_clara)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Clara(
        title_clara: String,
        content_clara: String,
        media_clara: String,
        type_clara: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Clara.shared_Clara.isLoggedIn_Clara {
            showLoginPrompt_Clara()
            return
        }
        
        // 获取当前用户信息
        let currentUser_clara = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara()
        
        let newPostId_clara = posts_Clara.count + 20 + 1
        
        let newPost_clara = TitleModel_Clara(
            titleId_Clara: newPostId_clara,
            titleUserId_Clara: currentUser_clara.userId_Clara ?? 0,
            titleUserName_Clara: currentUser_clara.userName_Clara ?? "User",
            titleMeidas_Clara: [media_clara],
            title_Clara: title_clara,
            titleContent_Clara: content_clara,
            reviews_Clara: [],
            likes_Clara: 0
        )
        
        posts_Clara.append(newPost_clara)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Clara.shared_Clara.addPostToCurrentUser_Clara(post_clara: newPost_clara)
        
        Utils_Clara.showSuccess_Clara(
            message_Clara: "Published successfully.",
            image_Clara: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Clara()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Clara(post_clara: TitleModel_Clara, isDelete_clara: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Clara.shared_Clara.removePostFromCurrentUser_Clara(post_clara: post_clara)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Clara.shared_Clara.removeLikeFromCurrentUser_Clara(post_clara: post_clara)
        
        // 从帖子列表中移除
        posts_Clara.removeAll { $0.titleId_Clara == post_clara.titleId_Clara }
        
        let message_clara = isDelete_clara
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Clara.showSuccess_Clara(
            message_Clara: message_clara,
            image_Clara: UIImage(systemName: "trash.fill"),
            delay_Clara: 1.5
        )
        
        notifyStateChange_Clara()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Clara(userId_clara: Int) {
        posts_Clara.removeAll { post in
            post.titleUserId_Clara == userId_clara
        }
        notifyStateChange_Clara()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Clara(post_clara: TitleModel_Clara, content_clara: String) {
        // 检查是否登录
        if !UserViewModel_Clara.shared_Clara.isLoggedIn_Clara {
            showLoginPrompt_Clara()
            return
        }
        
        // 获取当前用户信息
        let currentUser_clara = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara()
        
        let newCommentId_clara = post_clara.reviews_Clara.count + 1
        
        let newComment_clara = Comment_Clara(
            commentId_Clara: newCommentId_clara,
            commentUserId_Clara: currentUser_clara.userId_Clara ?? 0,
            commentUserName_Clara: currentUser_clara.userName_Clara ?? "User",
            commentContent_Clara: content_clara
        )
        
        // 找到对应的帖子并添加评论
        if let index_clara = posts_Clara.firstIndex(where: { $0.titleId_Clara == post_clara.titleId_Clara }) {
            posts_Clara[index_clara].reviews_Clara.append(newComment_clara)
        }
        
        notifyStateChange_Clara()
    }
    
    /// 删除评论
    func deleteComment_Clara(
        post_clara: TitleModel_Clara,
        comment_clara: Comment_Clara,
        isDelete_clara: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_clara = posts_Clara.firstIndex(where: { $0.titleId_Clara == post_clara.titleId_Clara }) {
            posts_Clara[index_clara].reviews_Clara.removeAll { comment in
                comment.commentId_Clara == comment_clara.commentId_Clara
            }
        }
        
        let message_clara = isDelete_clara
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Clara.showSuccess_Clara(
            message_Clara: message_clara,
            delay_Clara: 1.5
        )
        
        notifyStateChange_Clara()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Clara(post_clara: TitleModel_Clara) {
        // 检查是否登录
        if !UserViewModel_Clara.shared_Clara.isLoggedIn_Clara {
            showLoginPrompt_Clara()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Clara(post_clara: post_clara) {
            // 取消点赞
            UserViewModel_Clara.shared_Clara.removeLikeFromCurrentUser_Clara(post_clara: post_clara)
            
            // 更新帖子的点赞数
            if let index_clara = posts_Clara.firstIndex(where: { $0.titleId_Clara == post_clara.titleId_Clara }) {
                posts_Clara[index_clara].likes_Clara = max(0, posts_Clara[index_clara].likes_Clara - 1)
            }
        } else {
            // 点赞
            UserViewModel_Clara.shared_Clara.addLikeToCurrentUser_Clara(post_clara: post_clara)
            
            // 更新帖子的点赞数
            if let index_clara = posts_Clara.firstIndex(where: { $0.titleId_Clara == post_clara.titleId_Clara }) {
                posts_Clara[index_clara].likes_Clara += 1
            }
        }
        
        notifyStateChange_Clara()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Clara() {
        NotificationCenter.default.post(
            name: TitleViewModel_Clara.titleStateDidChangeNotification_Clara,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Clara() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Clara.toLogin_Clara(style_clara: .present_clara)
        }
    }
}

