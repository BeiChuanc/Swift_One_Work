import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Base_one {
    
    /// 单例
    static let shared_Base_one = TitleViewModel_Base_one()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Base_one = Notification.Name("TitleStateDidChange_Base_one")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Base_one: [TitleModel_Base_one] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Base_one() -> [TitleModel_Base_one] {
        return posts_Base_one
    }
    
    /// 初始化帖子列表
    func initPosts_Base_one() {
        posts_Base_one = LocalData_Base_one.shared_Base_one.titleList_Base_one
        notifyStateChange_Base_one()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Base_one(user_base_one: PrewUserModel_Base_one, type_base_one: Int? = nil) -> [TitleModel_Base_one] {
        guard let userId_base_one = user_base_one.userId_Base_one else { return [] }
        
        var filteredPosts_base_one = posts_Base_one.filter { post in
            post.titleUserId_Base_one == userId_base_one
        }
        
        // 如果指定了类型，进一步筛选
        if type_base_one != nil {
            filteredPosts_base_one = filteredPosts_base_one.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_base_one
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Base_one(post_base_one: TitleModel_Base_one) -> Bool {
        return UserViewModel_Base_one.shared_Base_one.isLikedByCurrentUser_Base_one(post_base_one: post_base_one)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Base_one(
        title_base_one: String,
        content_base_one: String,
        media_base_one: String,
        type_base_one: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 获取当前用户信息
        let currentUser_base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        
        let newPostId_base_one = posts_Base_one.count + 20 + 1
        
        let newPost_base_one = TitleModel_Base_one(
            titleId_Base_one: newPostId_base_one,
            titleUserId_Base_one: currentUser_base_one.userId_Base_one ?? 0,
            titleUserName_Base_one: currentUser_base_one.userName_Base_one ?? "User",
            titleMeidas_Base_one: [media_base_one],
            title_Base_one: title_base_one,
            titleContent_Base_one: content_base_one,
            reviews_Base_one: [],
            likes_Base_one: 0
        )
        
        posts_Base_one.append(newPost_base_one)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Base_one.shared_Base_one.addPostToCurrentUser_Base_one(post_base_one: newPost_base_one)
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: "Published successfully.",
            image_Base_one: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Base_one(post_base_one: TitleModel_Base_one, isDelete_base_one: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Base_one.shared_Base_one.removePostFromCurrentUser_Base_one(post_base_one: post_base_one)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Base_one.shared_Base_one.removeLikeFromCurrentUser_Base_one(post_base_one: post_base_one)
        
        // 从帖子列表中移除
        posts_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }
        
        let message_base_one = isDelete_base_one
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: message_base_one,
            image_Base_one: UIImage(systemName: "trash.fill"),
            delay_Base_one: 1.5
        )
        
        notifyStateChange_Base_one()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Base_one(userId_base_one: Int) {
        posts_Base_one.removeAll { post in
            post.titleUserId_Base_one == userId_base_one
        }
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Base_one(post_base_one: TitleModel_Base_one, content_base_one: String) {
        // 检查是否登录
        if !UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 获取当前用户信息
        let currentUser_base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        
        let newCommentId_base_one = post_base_one.reviews_Base_one.count + 1
        
        let newComment_base_one = Comment_Base_one(
            commentId_Base_one: newCommentId_base_one,
            commentUserId_Base_one: currentUser_base_one.userId_Base_one ?? 0,
            commentUserName_Base_one: currentUser_base_one.userName_Base_one ?? "User",
            commentContent_Base_one: content_base_one
        )
        
        // 找到对应的帖子并添加评论
        if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
            posts_Base_one[index_base_one].reviews_Base_one.append(newComment_base_one)
        }
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: "Comment posted",
            image_Base_one: UIImage(systemName: "bubble.left.fill")
        )
        
        notifyStateChange_Base_one()
    }
    
    /// 删除评论
    func deleteComment_Base_one(
        post_base_one: TitleModel_Base_one,
        comment_base_one: Comment_Base_one,
        isDelete_base_one: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
            posts_Base_one[index_base_one].reviews_Base_one.removeAll { comment in
                comment.commentId_Base_one == comment_base_one.commentId_Base_one
            }
        }
        
        let message_base_one = isDelete_base_one
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: message_base_one,
            delay_Base_one: 1.5
        )
        
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Base_one(post_base_one: TitleModel_Base_one) {
        // 检查是否登录
        if !UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Base_one(post_base_one: post_base_one) {
            // 取消点赞
            UserViewModel_Base_one.shared_Base_one.removeLikeFromCurrentUser_Base_one(post_base_one: post_base_one)
            
            // 更新帖子的点赞数
            if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
                posts_Base_one[index_base_one].likes_Base_one = max(0, posts_Base_one[index_base_one].likes_Base_one - 1)
            }
        } else {
            // 点赞
            UserViewModel_Base_one.shared_Base_one.addLikeToCurrentUser_Base_one(post_base_one: post_base_one)
            
            // 更新帖子的点赞数
            if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
                posts_Base_one[index_base_one].likes_Base_one += 1
            }
        }
        
        notifyStateChange_Base_one()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Base_one() {
        Utils_Base_one.showWarning_Base_one(
            message_Base_one: "Please login first.",
            delay_Base_one: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
        }
    }
}

