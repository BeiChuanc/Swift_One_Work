import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Sprig {
    
    /// 单例
    static let shared_Sprig = TitleViewModel_Sprig()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Sprig = Notification.Name("TitleStateDidChange_Sprig")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Sprig: [TitleModel_Sprig] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Sprig() -> [TitleModel_Sprig] {
        return posts_Sprig
    }
    
    /// 初始化帖子列表
    func initPosts_Sprig() {
        posts_Sprig = LocalData_Sprig.shared_Sprig.titleList_Sprig
        notifyStateChange_Sprig()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Sprig(user_sprig: PrewUserModel_Sprig, type_sprig: Int? = nil) -> [TitleModel_Sprig] {
        guard let userId_sprig = user_sprig.userId_Sprig else { return [] }
        
        var filteredPosts_sprig = posts_Sprig.filter { post in
            post.titleUserId_Sprig == userId_sprig
        }
        
        // 如果指定了类型，进一步筛选
        if type_sprig != nil {
            filteredPosts_sprig = filteredPosts_sprig.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_sprig
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Sprig(post_sprig: TitleModel_Sprig) -> Bool {
        return UserViewModel_Sprig.shared_Sprig.isLikedByCurrentUser_Sprig(post_sprig: post_sprig)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    /// - Parameters:
    ///   - title_sprig: 帖子标题
    ///   - content_sprig: 帖子内容
    ///   - media_sprig: 媒体路径
    ///   - type_sprig: 帖子类型（默认 0）
    ///   - tags_sprig: 帖子标签列表（可选，默认为空）
    func releasePost_Sprig(
        title_sprig: String,
        content_sprig: String,
        media_sprig: String,
        type_sprig: Int = 0,
        tags_sprig: [String] = []
    ) {
        // 检查是否登录
        if !UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig {
            showLoginPrompt_Sprig()
            return
        }
        
        // 获取当前用户信息
        let currentUser_sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()
        
        let newPostId_sprig = posts_Sprig.count + 20 + 1
        
        let newPost_sprig = TitleModel_Sprig(
            titleId_Sprig: newPostId_sprig,
            titleUserId_Sprig: currentUser_sprig.userId_Sprig ?? 0,
            titleUserName_Sprig: currentUser_sprig.userName_Sprig ?? "User",
            titleMeidas_Sprig: [media_sprig],
            title_Sprig: title_sprig,
            titleContent_Sprig: content_sprig,
            reviews_Sprig: [],
            likes_Sprig: 0,
            titleTags_Sprig: tags_sprig
        )
        
        posts_Sprig.append(newPost_sprig)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Sprig.shared_Sprig.addPostToCurrentUser_Sprig(post_sprig: newPost_sprig)
        
        Utils_Sprig.showSuccess_Sprig(
            message_Sprig: "Published successfully.",
            image_Sprig: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Sprig()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Sprig(post_sprig: TitleModel_Sprig, isDelete_sprig: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Sprig.shared_Sprig.removePostFromCurrentUser_Sprig(post_sprig: post_sprig)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Sprig.shared_Sprig.removeLikeFromCurrentUser_Sprig(post_sprig: post_sprig)
        
        // 从帖子列表中移除
        posts_Sprig.removeAll { $0.titleId_Sprig == post_sprig.titleId_Sprig }
        
        let message_sprig = isDelete_sprig
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Sprig.showSuccess_Sprig(
            message_Sprig: message_sprig,
            image_Sprig: UIImage(systemName: "trash.fill"),
            delay_Sprig: 1.5
        )
        
        notifyStateChange_Sprig()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Sprig(userId_sprig: Int) {
        posts_Sprig.removeAll { post in
            post.titleUserId_Sprig == userId_sprig
        }
        notifyStateChange_Sprig()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Sprig(post_sprig: TitleModel_Sprig, content_sprig: String) {
        // 检查是否登录
        if !UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig {
            showLoginPrompt_Sprig()
            return
        }
        
        // 获取当前用户信息
        let currentUser_sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()
        
        let newCommentId_sprig = post_sprig.reviews_Sprig.count + 1
        
        let newComment_sprig = Comment_Sprig(
            commentId_Sprig: newCommentId_sprig,
            commentUserId_Sprig: currentUser_sprig.userId_Sprig ?? 0,
            commentUserName_Sprig: currentUser_sprig.userName_Sprig ?? "User",
            commentContent_Sprig: content_sprig
        )
        
        // 找到对应的帖子并添加评论
        if let index_sprig = posts_Sprig.firstIndex(where: { $0.titleId_Sprig == post_sprig.titleId_Sprig }) {
            posts_Sprig[index_sprig].reviews_Sprig.append(newComment_sprig)
        }
        
        notifyStateChange_Sprig()
    }
    
    /// 删除评论
    func deleteComment_Sprig(
        post_sprig: TitleModel_Sprig,
        comment_sprig: Comment_Sprig,
        isDelete_sprig: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_sprig = posts_Sprig.firstIndex(where: { $0.titleId_Sprig == post_sprig.titleId_Sprig }) {
            posts_Sprig[index_sprig].reviews_Sprig.removeAll { comment in
                comment.commentId_Sprig == comment_sprig.commentId_Sprig
            }
        }
        
        let message_sprig = isDelete_sprig
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Sprig.showSuccess_Sprig(
            message_Sprig: message_sprig,
            delay_Sprig: 1.5
        )
        
        notifyStateChange_Sprig()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Sprig(post_sprig: TitleModel_Sprig) {
        // 检查是否登录
        if !UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig {
            showLoginPrompt_Sprig()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Sprig(post_sprig: post_sprig) {
            // 取消点赞
            UserViewModel_Sprig.shared_Sprig.removeLikeFromCurrentUser_Sprig(post_sprig: post_sprig)
            
            // 更新帖子的点赞数
            if let index_sprig = posts_Sprig.firstIndex(where: { $0.titleId_Sprig == post_sprig.titleId_Sprig }) {
                posts_Sprig[index_sprig].likes_Sprig = max(0, posts_Sprig[index_sprig].likes_Sprig - 1)
            }
        } else {
            // 点赞
            UserViewModel_Sprig.shared_Sprig.addLikeToCurrentUser_Sprig(post_sprig: post_sprig)
            
            // 更新帖子的点赞数
            if let index_sprig = posts_Sprig.firstIndex(where: { $0.titleId_Sprig == post_sprig.titleId_Sprig }) {
                posts_Sprig[index_sprig].likes_Sprig += 1
            }
        }
        
        notifyStateChange_Sprig()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Sprig() {
        NotificationCenter.default.post(
            name: TitleViewModel_Sprig.titleStateDidChangeNotification_Sprig,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Sprig() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Sprig.toLogin_Sprig(style_sprig: .present_sprig)
        }
    }
}

