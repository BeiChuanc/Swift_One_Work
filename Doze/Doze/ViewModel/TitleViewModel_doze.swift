import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Doze {
    
    /// 单例
    static let shared_Doze = TitleViewModel_Doze()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Doze = Notification.Name("TitleStateDidChange_Doze")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Doze: [TitleModel_Doze] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Doze() -> [TitleModel_Doze] {
        return posts_Doze
    }
    
    /// 初始化帖子列表
    func initPosts_Doze() {
        posts_Doze = LocalData_Doze.shared_Doze.titleList_Doze
        notifyStateChange_Doze()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Doze(user_doze: PrewUserModel_Doze, type_doze: Int? = nil) -> [TitleModel_Doze] {
        guard let userId_doze = user_doze.userId_Doze else { return [] }
        
        var filteredPosts_doze = posts_Doze.filter { post in
            post.titleUserId_Doze == userId_doze
        }
        
        // 如果指定了类型，进一步筛选
        if type_doze != nil {
            filteredPosts_doze = filteredPosts_doze.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_doze
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Doze(post_doze: TitleModel_Doze) -> Bool {
        return UserViewModel_Doze.shared_Doze.isLikedByCurrentUser_Doze(post_doze: post_doze)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Doze(
        title_doze: String,
        content_doze: String,
        media_doze: String,
        type_doze: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Doze.shared_Doze.isLoggedIn_Doze {
            showLoginPrompt_Doze()
            return
        }
        
        // 获取当前用户信息
        let currentUser_doze = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        
        let newPostId_doze = posts_Doze.count + 20 + 1
        
        let newPost_doze = TitleModel_Doze(
            titleId_Doze: newPostId_doze,
            titleUserId_Doze: currentUser_doze.userId_Doze ?? 0,
            titleUserName_Doze: currentUser_doze.userName_Doze ?? "User",
            titleMeidas_Doze: [media_doze],
            title_Doze: title_doze,
            titleContent_Doze: content_doze,
            reviews_Doze: [],
            likes_Doze: 0
        )
        
        posts_Doze.append(newPost_doze)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Doze.shared_Doze.addPostToCurrentUser_Doze(post_doze: newPost_doze)
        
        Utils_Doze.showSuccess_Doze(
            message_Doze: "Published successfully.",
            image_Doze: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Doze()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Doze(post_doze: TitleModel_Doze, isDelete_doze: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Doze.shared_Doze.removePostFromCurrentUser_Doze(post_doze: post_doze)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Doze.shared_Doze.removeLikeFromCurrentUser_Doze(post_doze: post_doze)
        
        // 从帖子列表中移除
        posts_Doze.removeAll { $0.titleId_Doze == post_doze.titleId_Doze }
        
        let message_doze = isDelete_doze
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Doze.showSuccess_Doze(
            message_Doze: message_doze,
            image_Doze: UIImage(systemName: "trash.fill"),
            delay_Doze: 1.5
        )
        
        notifyStateChange_Doze()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Doze(userId_doze: Int) {
        posts_Doze.removeAll { post in
            post.titleUserId_Doze == userId_doze
        }
        notifyStateChange_Doze()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Doze(post_doze: TitleModel_Doze, content_doze: String) {
        // 检查是否登录
        if !UserViewModel_Doze.shared_Doze.isLoggedIn_Doze {
            showLoginPrompt_Doze()
            return
        }
        
        // 获取当前用户信息
        let currentUser_doze = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        
        let newCommentId_doze = post_doze.reviews_Doze.count + 1
        
        let newComment_doze = Comment_Doze(
            commentId_Doze: newCommentId_doze,
            commentUserId_Doze: currentUser_doze.userId_Doze ?? 0,
            commentUserName_Doze: currentUser_doze.userName_Doze ?? "User",
            commentContent_Doze: content_doze
        )
        
        // 找到对应的帖子并添加评论
        if let index_doze = posts_Doze.firstIndex(where: { $0.titleId_Doze == post_doze.titleId_Doze }) {
            posts_Doze[index_doze].reviews_Doze.append(newComment_doze)
        }
        
        notifyStateChange_Doze()
    }
    
    /// 删除评论
    func deleteComment_Doze(
        post_doze: TitleModel_Doze,
        comment_doze: Comment_Doze,
        isDelete_doze: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_doze = posts_Doze.firstIndex(where: { $0.titleId_Doze == post_doze.titleId_Doze }) {
            posts_Doze[index_doze].reviews_Doze.removeAll { comment in
                comment.commentId_Doze == comment_doze.commentId_Doze
            }
        }
        
        let message_doze = isDelete_doze
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Doze.showSuccess_Doze(
            message_Doze: message_doze,
            delay_Doze: 1.5
        )
        
        notifyStateChange_Doze()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Doze(post_doze: TitleModel_Doze) {
        // 检查是否登录
        if !UserViewModel_Doze.shared_Doze.isLoggedIn_Doze {
            showLoginPrompt_Doze()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Doze(post_doze: post_doze) {
            // 取消点赞
            UserViewModel_Doze.shared_Doze.removeLikeFromCurrentUser_Doze(post_doze: post_doze)
            
            // 更新帖子的点赞数
            if let index_doze = posts_Doze.firstIndex(where: { $0.titleId_Doze == post_doze.titleId_Doze }) {
                posts_Doze[index_doze].likes_Doze = max(0, posts_Doze[index_doze].likes_Doze - 1)
            }
        } else {
            // 点赞
            UserViewModel_Doze.shared_Doze.addLikeToCurrentUser_Doze(post_doze: post_doze)
            
            // 更新帖子的点赞数
            if let index_doze = posts_Doze.firstIndex(where: { $0.titleId_Doze == post_doze.titleId_Doze }) {
                posts_Doze[index_doze].likes_Doze += 1
            }
        }
        
        notifyStateChange_Doze()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Doze() {
        NotificationCenter.default.post(
            name: TitleViewModel_Doze.titleStateDidChangeNotification_Doze,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Doze() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Navigation_Doze.toLogin_Doze(style_doze: .present_doze)
        }
    }
}

