import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Niche {
    
    /// 单例
    static let shared_Niche = TitleViewModel_Niche()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Niche = Notification.Name("TitleStateDidChange_Niche")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Niche: [TitleModel_Niche] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Niche() -> [TitleModel_Niche] {
        return posts_Niche
    }
    
    /// 初始化帖子列表
    func initPosts_Niche() {
        posts_Niche = LocalData_Niche.shared_Niche.titleList_Niche
        notifyStateChange_Niche()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Niche(user_niche: PrewUserModel_Niche, type_niche: Int? = nil) -> [TitleModel_Niche] {
        guard let userId_niche = user_niche.userId_Niche else { return [] }
        
        var filteredPosts_niche = posts_Niche.filter { post in
            post.titleUserId_Niche == userId_niche
        }
        
        // 如果指定了类型，进一步筛选
        if type_niche != nil {
            filteredPosts_niche = filteredPosts_niche.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_niche
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Niche(post_niche: TitleModel_Niche) -> Bool {
        return UserViewModel_Niche.shared_Niche.isLikedByCurrentUser_Niche(post_niche: post_niche)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Niche(
        title_niche: String,
        content_niche: String,
        media_niche: String,
        type_niche: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Niche.shared_Niche.isLoggedIn_Niche {
            showLoginPrompt_Niche()
            return
        }
        
        // 获取当前用户信息
        let currentUser_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        
        let newPostId_niche = posts_Niche.count + 20 + 1
        
        let newPost_niche = TitleModel_Niche(
            titleId_Niche: newPostId_niche,
            titleUserId_Niche: currentUser_niche.userId_Niche ?? 0,
            titleUserName_Niche: currentUser_niche.userName_Niche ?? "User",
            titleMeidas_Niche: [media_niche],
            title_Niche: title_niche,
            titleContent_Niche: content_niche,
            reviews_Niche: [],
            likes_Niche: 0
        )
        
        posts_Niche.append(newPost_niche)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Niche.shared_Niche.addPostToCurrentUser_Niche(post_niche: newPost_niche)
        
        Utils_Niche.showSuccess_Niche(
            message_Niche: "Published successfully.",
            image_Niche: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Niche()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Niche(post_niche: TitleModel_Niche, isDelete_niche: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Niche.shared_Niche.removePostFromCurrentUser_Niche(post_niche: post_niche)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Niche.shared_Niche.removeLikeFromCurrentUser_Niche(post_niche: post_niche)
        
        // 从帖子列表中移除
        posts_Niche.removeAll { $0.titleId_Niche == post_niche.titleId_Niche }
        
        let message_niche = isDelete_niche
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Niche.showSuccess_Niche(
            message_Niche: message_niche,
            image_Niche: UIImage(systemName: "trash.fill"),
            delay_Niche: 1.5
        )
        
        notifyStateChange_Niche()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Niche(userId_niche: Int) {
        posts_Niche.removeAll { post in
            post.titleUserId_Niche == userId_niche
        }
        notifyStateChange_Niche()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Niche(post_niche: TitleModel_Niche, content_niche: String) {
        // 检查是否登录
        if !UserViewModel_Niche.shared_Niche.isLoggedIn_Niche {
            showLoginPrompt_Niche()
            return
        }
        
        // 获取当前用户信息
        let currentUser_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        
        let newCommentId_niche = post_niche.reviews_Niche.count + 1
        
        let newComment_niche = Comment_Niche(
            commentId_Niche: newCommentId_niche,
            commentUserId_Niche: currentUser_niche.userId_Niche ?? 0,
            commentUserName_Niche: currentUser_niche.userName_Niche ?? "User",
            commentContent_Niche: content_niche
        )
        
        // 找到对应的帖子并添加评论
        if let index_niche = posts_Niche.firstIndex(where: { $0.titleId_Niche == post_niche.titleId_Niche }) {
            posts_Niche[index_niche].reviews_Niche.append(newComment_niche)
        }
        
        notifyStateChange_Niche()
    }
    
    /// 删除评论
    func deleteComment_Niche(
        post_niche: TitleModel_Niche,
        comment_niche: Comment_Niche,
        isDelete_niche: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_niche = posts_Niche.firstIndex(where: { $0.titleId_Niche == post_niche.titleId_Niche }) {
            posts_Niche[index_niche].reviews_Niche.removeAll { comment in
                comment.commentId_Niche == comment_niche.commentId_Niche
            }
        }
        
        let message_niche = isDelete_niche
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Niche.showSuccess_Niche(
            message_Niche: message_niche,
            delay_Niche: 1.5
        )
        
        notifyStateChange_Niche()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Niche(post_niche: TitleModel_Niche) {
        // 检查是否登录
        if !UserViewModel_Niche.shared_Niche.isLoggedIn_Niche {
            showLoginPrompt_Niche()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Niche(post_niche: post_niche) {
            // 取消点赞
            UserViewModel_Niche.shared_Niche.removeLikeFromCurrentUser_Niche(post_niche: post_niche)
            
            // 更新帖子的点赞数
            if let index_niche = posts_Niche.firstIndex(where: { $0.titleId_Niche == post_niche.titleId_Niche }) {
                posts_Niche[index_niche].likes_Niche = max(0, posts_Niche[index_niche].likes_Niche - 1)
            }
        } else {
            // 点赞
            UserViewModel_Niche.shared_Niche.addLikeToCurrentUser_Niche(post_niche: post_niche)
            
            // 更新帖子的点赞数
            if let index_niche = posts_Niche.firstIndex(where: { $0.titleId_Niche == post_niche.titleId_Niche }) {
                posts_Niche[index_niche].likes_Niche += 1
            }
        }
        
        notifyStateChange_Niche()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Niche() {
        NotificationCenter.default.post(
            name: TitleViewModel_Niche.titleStateDidChangeNotification_Niche,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Niche() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Niche.toLogin_Niche(style_niche: .present_niche)
        }
    }
}

