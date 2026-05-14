import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Echd {
    
    /// 单例
    static let shared_Echd = TitleViewModel_Echd()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Echd = Notification.Name("TitleStateDidChange_Echd")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Echd: [TitleModel_Echd] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Echd() -> [TitleModel_Echd] {
        return posts_Echd
    }
    
    /// 初始化帖子列表
    func initPosts_Echd() {
        posts_Echd = LocalData_Echd.shared_Echd.titleList_Echd
        notifyStateChange_Echd()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Echd(user_echd: PrewUserModel_Echd, type_echd: Int? = nil) -> [TitleModel_Echd] {
        guard let userId_echd = user_echd.userId_Echd else { return [] }
        
        var filteredPosts_echd = posts_Echd.filter { post in
            post.titleUserId_Echd == userId_echd
        }
        
        // 如果指定了类型，进一步筛选
        if type_echd != nil {
            filteredPosts_echd = filteredPosts_echd.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_echd
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Echd(post_echd: TitleModel_Echd) -> Bool {
        return UserViewModel_Echd.shared_Echd.isLikedByCurrentUser_Echd(post_echd: post_echd)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Echd(
        title_echd: String,
        content_echd: String,
        media_echd: String,
        type_echd: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Echd.shared_Echd.isLoggedIn_Echd {
            showLoginPrompt_Echd()
            return
        }
        
        // 获取当前用户信息
        let currentUser_echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        
        let newPostId_echd = posts_Echd.count + 20 + 1
        
        let newPost_echd = TitleModel_Echd(
            titleId_Echd: newPostId_echd,
            titleUserId_Echd: currentUser_echd.userId_Echd ?? 0,
            titleUserName_Echd: currentUser_echd.userName_Echd ?? "User",
            titleMeidas_Echd: [media_echd],
            title_Echd: title_echd,
            titleContent_Echd: content_echd,
            reviews_Echd: [],
            likes_Echd: 0
        )
        
        posts_Echd.append(newPost_echd)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Echd.shared_Echd.addPostToCurrentUser_Echd(post_echd: newPost_echd)
        
        Utils_Echd.showSuccess_Echd(
            message_Echd: "Published successfully.",
            image_Echd: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Echd()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Echd(post_echd: TitleModel_Echd, isDelete_echd: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Echd.shared_Echd.removePostFromCurrentUser_Echd(post_echd: post_echd)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Echd.shared_Echd.removeLikeFromCurrentUser_Echd(post_echd: post_echd)
        
        // 从帖子列表中移除
        posts_Echd.removeAll { $0.titleId_Echd == post_echd.titleId_Echd }
        
        let message_echd = isDelete_echd
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Echd.showSuccess_Echd(
            message_Echd: message_echd,
            image_Echd: UIImage(systemName: "trash.fill"),
            delay_Echd: 1.5
        )
        
        notifyStateChange_Echd()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Echd(userId_echd: Int) {
        posts_Echd.removeAll { post in
            post.titleUserId_Echd == userId_echd
        }
        notifyStateChange_Echd()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Echd(post_echd: TitleModel_Echd, content_echd: String) {
        // 检查是否登录
        if !UserViewModel_Echd.shared_Echd.isLoggedIn_Echd {
            showLoginPrompt_Echd()
            return
        }
        
        // 获取当前用户信息
        let currentUser_echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        
        let newCommentId_echd = post_echd.reviews_Echd.count + 1
        
        let newComment_echd = Comment_Echd(
            commentId_Echd: newCommentId_echd,
            commentUserId_Echd: currentUser_echd.userId_Echd ?? 0,
            commentUserName_Echd: currentUser_echd.userName_Echd ?? "User",
            commentContent_Echd: content_echd
        )
        
        // 找到对应的帖子并添加评论
        if let index_echd = posts_Echd.firstIndex(where: { $0.titleId_Echd == post_echd.titleId_Echd }) {
            posts_Echd[index_echd].reviews_Echd.append(newComment_echd)
        }
        
        notifyStateChange_Echd()
    }
    
    /// 删除评论
    func deleteComment_Echd(
        post_echd: TitleModel_Echd,
        comment_echd: Comment_Echd,
        isDelete_echd: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_echd = posts_Echd.firstIndex(where: { $0.titleId_Echd == post_echd.titleId_Echd }) {
            posts_Echd[index_echd].reviews_Echd.removeAll { comment in
                comment.commentId_Echd == comment_echd.commentId_Echd
            }
        }
        
        let message_echd = isDelete_echd
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Echd.showSuccess_Echd(
            message_Echd: message_echd,
            delay_Echd: 1.5
        )
        
        notifyStateChange_Echd()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Echd(post_echd: TitleModel_Echd) {
        // 检查是否登录
        if !UserViewModel_Echd.shared_Echd.isLoggedIn_Echd {
            showLoginPrompt_Echd()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Echd(post_echd: post_echd) {
            // 取消点赞
            UserViewModel_Echd.shared_Echd.removeLikeFromCurrentUser_Echd(post_echd: post_echd)
            
            // 更新帖子的点赞数
            if let index_echd = posts_Echd.firstIndex(where: { $0.titleId_Echd == post_echd.titleId_Echd }) {
                posts_Echd[index_echd].likes_Echd = max(0, posts_Echd[index_echd].likes_Echd - 1)
            }
        } else {
            // 点赞
            UserViewModel_Echd.shared_Echd.addLikeToCurrentUser_Echd(post_echd: post_echd)
            
            // 更新帖子的点赞数
            if let index_echd = posts_Echd.firstIndex(where: { $0.titleId_Echd == post_echd.titleId_Echd }) {
                posts_Echd[index_echd].likes_Echd += 1
            }
        }
        
        notifyStateChange_Echd()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Echd() {
        NotificationCenter.default.post(
            name: TitleViewModel_Echd.titleStateDidChangeNotification_Echd,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Echd() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Echd.toLogin_Echd(style_echd: .present_echd)
        }
    }
}

