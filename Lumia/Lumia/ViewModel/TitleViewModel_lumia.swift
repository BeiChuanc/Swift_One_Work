import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Lumia {
    
    /// 单例
    static let shared_Lumia = TitleViewModel_Lumia()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Lumia = Notification.Name("TitleStateDidChange_Lumia")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Lumia: [TitleModel_Lumia] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Lumia() -> [TitleModel_Lumia] {
        return posts_Lumia
    }
    
    /// 初始化帖子列表
    func initPosts_Lumia() {
        posts_Lumia = LocalData_Lumia.shared_Lumia.titleList_Lumia
        notifyStateChange_Lumia()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Lumia(user_lumia: PrewUserModel_Lumia, type_lumia: Int? = nil) -> [TitleModel_Lumia] {
        guard let userId_lumia = user_lumia.userId_Lumia else { return [] }
        
        var filteredPosts_lumia = posts_Lumia.filter { post in
            post.titleUserId_Lumia == userId_lumia
        }
        
        // 如果指定了类型，进一步筛选
        if type_lumia != nil {
            filteredPosts_lumia = filteredPosts_lumia.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_lumia
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Lumia(post_lumia: TitleModel_Lumia) -> Bool {
        return UserViewModel_Lumia.shared_Lumia.isLikedByCurrentUser_Lumia(post_lumia: post_lumia)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Lumia(
        title_lumia: String,
        content_lumia: String,
        media_lumia: String,
        type_lumia: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia {
            showLoginPrompt_Lumia()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        
        let newPostId_lumia = currentUser_lumia.userId_Lumia ?? 0 + 1
        
        let newPost_lumia = TitleModel_Lumia(
            titleId_Lumia: newPostId_lumia,
            titleUserId_Lumia: currentUser_lumia.userId_Lumia ?? 0,
            titleUserName_Lumia: currentUser_lumia.userName_Lumia ?? "User",
            titleMeidas_Lumia: [media_lumia],
            title_Lumia: title_lumia,
            titleContent_Lumia: content_lumia,
            reviews_Lumia: [],
            likes_Lumia: 0
        )
        
        posts_Lumia.append(newPost_lumia)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Lumia.shared_Lumia.addPostToCurrentUser_Lumia(post_lumia: newPost_lumia)
        
        Utils_Lumia.showSuccess_Lumia(
            message_Lumia: "Published successfully.",
            image_Lumia: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Lumia()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Lumia(post_lumia: TitleModel_Lumia, isDelete_lumia: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Lumia.shared_Lumia.removePostFromCurrentUser_Lumia(post_lumia: post_lumia)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Lumia.shared_Lumia.removeLikeFromCurrentUser_Lumia(post_lumia: post_lumia)
        
        // 从帖子列表中移除
        posts_Lumia.removeAll { $0.titleId_Lumia == post_lumia.titleId_Lumia }
        
        let message_lumia = isDelete_lumia
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Lumia.showSuccess_Lumia(
            message_Lumia: message_lumia,
            image_Lumia: UIImage(systemName: "trash.fill"),
            delay_Lumia: 1.5
        )
        
        notifyStateChange_Lumia()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Lumia(userId_lumia: Int) {
        posts_Lumia.removeAll { post in
            post.titleUserId_Lumia == userId_lumia
        }
        notifyStateChange_Lumia()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Lumia(post_lumia: TitleModel_Lumia, content_lumia: String) {
        // 检查是否登录
        if !UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia {
            showLoginPrompt_Lumia()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        
        let newCommentId_lumia = post_lumia.reviews_Lumia.count + 1
        
        let newComment_lumia = Comment_Lumia(
            commentId_Lumia: newCommentId_lumia,
            commentUserId_Lumia: currentUser_lumia.userId_Lumia ?? 0,
            commentUserName_Lumia: currentUser_lumia.userName_Lumia ?? "User",
            commentContent_Lumia: content_lumia
        )
        
        // 找到对应的帖子并添加评论
        if let index_lumia = posts_Lumia.firstIndex(where: { $0.titleId_Lumia == post_lumia.titleId_Lumia }) {
            posts_Lumia[index_lumia].reviews_Lumia.append(newComment_lumia)
        }
        
        notifyStateChange_Lumia()
    }
    
    /// 删除评论
    func deleteComment_Lumia(
        post_lumia: TitleModel_Lumia,
        comment_lumia: Comment_Lumia,
        isDelete_lumia: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_lumia = posts_Lumia.firstIndex(where: { $0.titleId_Lumia == post_lumia.titleId_Lumia }) {
            posts_Lumia[index_lumia].reviews_Lumia.removeAll { comment in
                comment.commentId_Lumia == comment_lumia.commentId_Lumia
            }
        }
        
        let message_lumia = isDelete_lumia
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Lumia.showSuccess_Lumia(
            message_Lumia: message_lumia,
            delay_Lumia: 1.5
        )
        
        notifyStateChange_Lumia()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Lumia(post_lumia: TitleModel_Lumia) {
        // 检查是否登录
        if !UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia {
            showLoginPrompt_Lumia()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Lumia(post_lumia: post_lumia) {
            // 取消点赞
            UserViewModel_Lumia.shared_Lumia.removeLikeFromCurrentUser_Lumia(post_lumia: post_lumia)
            
            // 更新帖子的点赞数
            if let index_lumia = posts_Lumia.firstIndex(where: { $0.titleId_Lumia == post_lumia.titleId_Lumia }) {
                posts_Lumia[index_lumia].likes_Lumia = max(0, posts_Lumia[index_lumia].likes_Lumia - 1)
            }
        } else {
            // 点赞
            UserViewModel_Lumia.shared_Lumia.addLikeToCurrentUser_Lumia(post_lumia: post_lumia)
            
            // 更新帖子的点赞数
            if let index_lumia = posts_Lumia.firstIndex(where: { $0.titleId_Lumia == post_lumia.titleId_Lumia }) {
                posts_Lumia[index_lumia].likes_Lumia += 1
            }
        }
        
        notifyStateChange_Lumia()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Lumia() {
        NotificationCenter.default.post(
            name: TitleViewModel_Lumia.titleStateDidChangeNotification_Lumia,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Lumia() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia)
        }
    }
}

