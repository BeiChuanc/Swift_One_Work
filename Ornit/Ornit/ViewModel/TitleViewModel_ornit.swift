import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Ornit {
    
    /// 单例
    static let shared_Ornit = TitleViewModel_Ornit()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Ornit = Notification.Name("TitleStateDidChange_Ornit")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Ornit: [TitleModel_Ornit] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Ornit() -> [TitleModel_Ornit] {
        return posts_Ornit
    }
    
    /// 初始化帖子列表
    func initPosts_Ornit() {
        posts_Ornit = LocalData_Ornit.shared_Ornit.titleList_Ornit
        notifyStateChange_Ornit()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Ornit(user_ornit: PrewUserModel_Ornit, type_ornit: Int? = nil) -> [TitleModel_Ornit] {
        guard let userId_ornit = user_ornit.userId_Ornit else { return [] }
        
        var filteredPosts_ornit = posts_Ornit.filter { post in
            post.titleUserId_Ornit == userId_ornit
        }
        
        // 如果指定了类型，进一步筛选
        if type_ornit != nil {
            filteredPosts_ornit = filteredPosts_ornit.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_ornit
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Ornit(post_ornit: TitleModel_Ornit) -> Bool {
        return UserViewModel_Ornit.shared_Ornit.isLikedByCurrentUser_Ornit(post_ornit: post_ornit)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Ornit(
        title_ornit: String,
        content_ornit: String,
        media_ornit: String,
        type_ornit: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit {
            showLoginPrompt_Ornit()
            return
        }
        
        // 获取当前用户信息
        let currentUser_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()
        
        let newPostId_ornit = posts_Ornit.count + 20 + 1
        
        let newPost_ornit = TitleModel_Ornit(
            titleId_Ornit: newPostId_ornit,
            titleUserId_Ornit: currentUser_ornit.userId_Ornit ?? 0,
            titleUserName_Ornit: currentUser_ornit.userName_Ornit ?? "User",
            titleMeidas_Ornit: [media_ornit],
            title_Ornit: title_ornit,
            titleContent_Ornit: content_ornit,
            reviews_Ornit: [],
            likes_Ornit: 0
        )
        
        posts_Ornit.append(newPost_ornit)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Ornit.shared_Ornit.addPostToCurrentUser_Ornit(post_ornit: newPost_ornit)
        
        Utils_Ornit.showSuccess_Ornit(
            message_Ornit: "Published successfully.",
            image_Ornit: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Ornit()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Ornit(post_ornit: TitleModel_Ornit, isDelete_ornit: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Ornit.shared_Ornit.removePostFromCurrentUser_Ornit(post_ornit: post_ornit)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Ornit.shared_Ornit.removeLikeFromCurrentUser_Ornit(post_ornit: post_ornit)
        
        // 从帖子列表中移除
        posts_Ornit.removeAll { $0.titleId_Ornit == post_ornit.titleId_Ornit }
        
        let message_ornit = isDelete_ornit
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Ornit.showSuccess_Ornit(
            message_Ornit: message_ornit,
            image_Ornit: UIImage(systemName: "trash.fill"),
            delay_Ornit: 1.5
        )
        
        notifyStateChange_Ornit()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Ornit(userId_ornit: Int) {
        posts_Ornit.removeAll { post in
            post.titleUserId_Ornit == userId_ornit
        }
        notifyStateChange_Ornit()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Ornit(post_ornit: TitleModel_Ornit, content_ornit: String) {
        // 检查是否登录
        if !UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit {
            showLoginPrompt_Ornit()
            return
        }
        
        // 获取当前用户信息
        let currentUser_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()
        
        let newCommentId_ornit = post_ornit.reviews_Ornit.count + 1
        
        let newComment_ornit = Comment_Ornit(
            commentId_Ornit: newCommentId_ornit,
            commentUserId_Ornit: currentUser_ornit.userId_Ornit ?? 0,
            commentUserName_Ornit: currentUser_ornit.userName_Ornit ?? "User",
            commentContent_Ornit: content_ornit
        )
        
        // 找到对应的帖子并添加评论
        if let index_ornit = posts_Ornit.firstIndex(where: { $0.titleId_Ornit == post_ornit.titleId_Ornit }) {
            posts_Ornit[index_ornit].reviews_Ornit.append(newComment_ornit)
        }
        
        notifyStateChange_Ornit()
    }
    
    /// 删除评论
    func deleteComment_Ornit(
        post_ornit: TitleModel_Ornit,
        comment_ornit: Comment_Ornit,
        isDelete_ornit: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_ornit = posts_Ornit.firstIndex(where: { $0.titleId_Ornit == post_ornit.titleId_Ornit }) {
            posts_Ornit[index_ornit].reviews_Ornit.removeAll { comment in
                comment.commentId_Ornit == comment_ornit.commentId_Ornit
            }
        }
        
        let message_ornit = isDelete_ornit
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Ornit.showSuccess_Ornit(
            message_Ornit: message_ornit,
            delay_Ornit: 1.5
        )
        
        notifyStateChange_Ornit()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Ornit(post_ornit: TitleModel_Ornit) {
        // 检查是否登录
        if !UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit {
            showLoginPrompt_Ornit()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Ornit(post_ornit: post_ornit) {
            // 取消点赞
            UserViewModel_Ornit.shared_Ornit.removeLikeFromCurrentUser_Ornit(post_ornit: post_ornit)
            
            // 更新帖子的点赞数
            if let index_ornit = posts_Ornit.firstIndex(where: { $0.titleId_Ornit == post_ornit.titleId_Ornit }) {
                posts_Ornit[index_ornit].likes_Ornit = max(0, posts_Ornit[index_ornit].likes_Ornit - 1)
            }
        } else {
            // 点赞
            UserViewModel_Ornit.shared_Ornit.addLikeToCurrentUser_Ornit(post_ornit: post_ornit)
            
            // 更新帖子的点赞数
            if let index_ornit = posts_Ornit.firstIndex(where: { $0.titleId_Ornit == post_ornit.titleId_Ornit }) {
                posts_Ornit[index_ornit].likes_Ornit += 1
            }
        }
        
        notifyStateChange_Ornit()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Ornit() {
        NotificationCenter.default.post(
            name: TitleViewModel_Ornit.titleStateDidChangeNotification_Ornit,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Ornit() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Ornit.toLogin_Ornit(style_ornit: .present_ornit)
        }
    }
}

