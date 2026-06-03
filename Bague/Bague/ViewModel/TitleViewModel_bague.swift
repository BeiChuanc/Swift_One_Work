import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Bague {
    
    /// 单例
    static let shared_Bague = TitleViewModel_Bague()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Bague = Notification.Name("TitleStateDidChange_Bague")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Bague: [TitleModel_Bague] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Bague() -> [TitleModel_Bague] {
        return posts_Bague
    }
    
    /// 初始化帖子列表
    func initPosts_Bague() {
        posts_Bague = LocalData_Bague.shared_Bague.titleList_Bague
        notifyStateChange_Bague()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Bague(user_bague: PrewUserModel_Bague, type_bague: Int? = nil) -> [TitleModel_Bague] {
        guard let userId_bague = user_bague.userId_Bague else { return [] }
        
        var filteredPosts_bague = posts_Bague.filter { post in
            post.titleUserId_Bague == userId_bague
        }
        
        // 如果指定了类型，进一步筛选
        if type_bague != nil {
            filteredPosts_bague = filteredPosts_bague.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_bague
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Bague(post_bague: TitleModel_Bague) -> Bool {
        return UserViewModel_Bague.shared_Bague.isLikedByCurrentUser_Bague(post_bague: post_bague)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Bague(
        title_bague: String,
        content_bague: String,
        media_bague: String,
        type_bague: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Bague.shared_Bague.isLoggedIn_Bague {
            showLoginPrompt_Bague()
            return
        }
        
        // 获取当前用户信息
        let currentUser_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        
        let newPostId_bague = posts_Bague.count + 20 + 1
        
        let newPost_bague = TitleModel_Bague(
            titleId_Bague: newPostId_bague,
            titleUserId_Bague: currentUser_bague.userId_Bague ?? 0,
            titleUserName_Bague: currentUser_bague.userName_Bague ?? "User",
            titleMeidas_Bague: [media_bague],
            title_Bague: title_bague,
            titleContent_Bague: content_bague,
            reviews_Bague: [],
            likes_Bague: 0
        )
        
        posts_Bague.append(newPost_bague)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Bague.shared_Bague.addPostToCurrentUser_Bague(post_bague: newPost_bague)
        
        Utils_Bague.showSuccess_Bague(
            message_Bague: "Published successfully.",
            image_Bague: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Bague()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Bague(post_bague: TitleModel_Bague, isDelete_bague: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Bague.shared_Bague.removePostFromCurrentUser_Bague(post_bague: post_bague)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Bague.shared_Bague.removeLikeFromCurrentUser_Bague(post_bague: post_bague)
        
        // 从帖子列表中移除
        posts_Bague.removeAll { $0.titleId_Bague == post_bague.titleId_Bague }
        
        let message_bague = isDelete_bague
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Bague.showSuccess_Bague(
            message_Bague: message_bague,
            image_Bague: UIImage(systemName: "trash.fill"),
            delay_Bague: 1.5
        )
        
        notifyStateChange_Bague()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Bague(userId_bague: Int) {
        posts_Bague.removeAll { post in
            post.titleUserId_Bague == userId_bague
        }
        notifyStateChange_Bague()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Bague(post_bague: TitleModel_Bague, content_bague: String) {
        // 检查是否登录
        if !UserViewModel_Bague.shared_Bague.isLoggedIn_Bague {
            showLoginPrompt_Bague()
            return
        }
        
        // 获取当前用户信息
        let currentUser_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        
        let newCommentId_bague = post_bague.reviews_Bague.count + 1
        
        let newComment_bague = Comment_Bague(
            commentId_Bague: newCommentId_bague,
            commentUserId_Bague: currentUser_bague.userId_Bague ?? 0,
            commentUserName_Bague: currentUser_bague.userName_Bague ?? "User",
            commentContent_Bague: content_bague
        )
        
        // 找到对应的帖子并添加评论
        if let index_bague = posts_Bague.firstIndex(where: { $0.titleId_Bague == post_bague.titleId_Bague }) {
            posts_Bague[index_bague].reviews_Bague.append(newComment_bague)
        }
        
        notifyStateChange_Bague()
    }
    
    /// 删除评论
    func deleteComment_Bague(
        post_bague: TitleModel_Bague,
        comment_bague: Comment_Bague,
        isDelete_bague: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_bague = posts_Bague.firstIndex(where: { $0.titleId_Bague == post_bague.titleId_Bague }) {
            posts_Bague[index_bague].reviews_Bague.removeAll { comment in
                comment.commentId_Bague == comment_bague.commentId_Bague
            }
        }
        
        let message_bague = isDelete_bague
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Bague.showSuccess_Bague(
            message_Bague: message_bague,
            delay_Bague: 1.5
        )
        
        notifyStateChange_Bague()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Bague(post_bague: TitleModel_Bague) {
        // 检查是否登录
        if !UserViewModel_Bague.shared_Bague.isLoggedIn_Bague {
            showLoginPrompt_Bague()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Bague(post_bague: post_bague) {
            // 取消点赞
            UserViewModel_Bague.shared_Bague.removeLikeFromCurrentUser_Bague(post_bague: post_bague)
            
            // 更新帖子的点赞数
            if let index_bague = posts_Bague.firstIndex(where: { $0.titleId_Bague == post_bague.titleId_Bague }) {
                posts_Bague[index_bague].likes_Bague = max(0, posts_Bague[index_bague].likes_Bague - 1)
            }
        } else {
            // 点赞
            UserViewModel_Bague.shared_Bague.addLikeToCurrentUser_Bague(post_bague: post_bague)
            
            // 更新帖子的点赞数
            if let index_bague = posts_Bague.firstIndex(where: { $0.titleId_Bague == post_bague.titleId_Bague }) {
                posts_Bague[index_bague].likes_Bague += 1
            }
        }
        
        notifyStateChange_Bague()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Bague() {
        NotificationCenter.default.post(
            name: TitleViewModel_Bague.titleStateDidChangeNotification_Bague,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Bague() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Bague.toLogin_Bague(style_bague: .present_bague)
        }
    }
}

