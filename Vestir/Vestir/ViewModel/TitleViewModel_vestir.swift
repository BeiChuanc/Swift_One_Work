import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Vestir {
    
    /// 单例
    static let shared_Vestir = TitleViewModel_Vestir()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Vestir = Notification.Name("TitleStateDidChange_Vestir")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Vestir: [TitleModel_Vestir] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Vestir() -> [TitleModel_Vestir] {
        return posts_Vestir
    }
    
    /// 初始化帖子列表
    func initPosts_Vestir() {
        posts_Vestir = LocalData_Vestir.shared_Vestir.titleList_Vestir
        notifyStateChange_Vestir()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Vestir(user_vestir: PrewUserModel_Vestir, type_vestir: Int? = nil) -> [TitleModel_Vestir] {
        guard let userId_vestir = user_vestir.userId_Vestir else { return [] }
        
        var filteredPosts_vestir = posts_Vestir.filter { post in
            post.titleUserId_Vestir == userId_vestir
        }
        
        // 如果指定了类型，进一步筛选
        if type_vestir != nil {
            filteredPosts_vestir = filteredPosts_vestir.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_vestir
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Vestir(post_vestir: TitleModel_Vestir) -> Bool {
        return UserViewModel_Vestir.shared_Vestir.isLikedByCurrentUser_Vestir(post_vestir: post_vestir)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Vestir(
        title_vestir: String,
        content_vestir: String,
        media_vestir: String,
        type_vestir: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir {
            showLoginPrompt_Vestir()
            return
        }
        
        // 获取当前用户信息
        let currentUser_vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        
        let newPostId_vestir = posts_Vestir.count + 20 + 1
        
        let newPost_vestir = TitleModel_Vestir(
            titleId_Vestir: newPostId_vestir,
            titleUserId_Vestir: currentUser_vestir.userId_Vestir ?? 0,
            titleUserName_Vestir: currentUser_vestir.userName_Vestir ?? "User",
            titleMeidas_Vestir: [media_vestir],
            title_Vestir: title_vestir,
            titleContent_Vestir: content_vestir,
            reviews_Vestir: [],
            likes_Vestir: 0
        )
        
        posts_Vestir.append(newPost_vestir)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Vestir.shared_Vestir.addPostToCurrentUser_Vestir(post_vestir: newPost_vestir)
        
        Utils_Vestir.showSuccess_Vestir(
            message_Vestir: "Published successfully.",
            image_Vestir: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Vestir()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Vestir(post_vestir: TitleModel_Vestir, isDelete_vestir: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Vestir.shared_Vestir.removePostFromCurrentUser_Vestir(post_vestir: post_vestir)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Vestir.shared_Vestir.removeLikeFromCurrentUser_Vestir(post_vestir: post_vestir)
        
        // 从帖子列表中移除
        posts_Vestir.removeAll { $0.titleId_Vestir == post_vestir.titleId_Vestir }
        
        let message_vestir = isDelete_vestir
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Vestir.showSuccess_Vestir(
            message_Vestir: message_vestir,
            image_Vestir: UIImage(systemName: "trash.fill"),
            delay_Vestir: 1.5
        )
        
        notifyStateChange_Vestir()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Vestir(userId_vestir: Int) {
        posts_Vestir.removeAll { post in
            post.titleUserId_Vestir == userId_vestir
        }
        notifyStateChange_Vestir()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Vestir(post_vestir: TitleModel_Vestir, content_vestir: String) {
        // 检查是否登录
        if !UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir {
            showLoginPrompt_Vestir()
            return
        }
        
        // 获取当前用户信息
        let currentUser_vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        
        let newCommentId_vestir = post_vestir.reviews_Vestir.count + 1
        
        let newComment_vestir = Comment_Vestir(
            commentId_Vestir: newCommentId_vestir,
            commentUserId_Vestir: currentUser_vestir.userId_Vestir ?? 0,
            commentUserName_Vestir: currentUser_vestir.userName_Vestir ?? "User",
            commentContent_Vestir: content_vestir
        )
        
        // 找到对应的帖子并添加评论
        if let index_vestir = posts_Vestir.firstIndex(where: { $0.titleId_Vestir == post_vestir.titleId_Vestir }) {
            posts_Vestir[index_vestir].reviews_Vestir.append(newComment_vestir)
        }
        
        notifyStateChange_Vestir()
    }
    
    /// 删除评论
    func deleteComment_Vestir(
        post_vestir: TitleModel_Vestir,
        comment_vestir: Comment_Vestir,
        isDelete_vestir: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_vestir = posts_Vestir.firstIndex(where: { $0.titleId_Vestir == post_vestir.titleId_Vestir }) {
            posts_Vestir[index_vestir].reviews_Vestir.removeAll { comment in
                comment.commentId_Vestir == comment_vestir.commentId_Vestir
            }
        }
        
        let message_vestir = isDelete_vestir
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Vestir.showSuccess_Vestir(
            message_Vestir: message_vestir,
            delay_Vestir: 1.5
        )
        
        notifyStateChange_Vestir()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Vestir(post_vestir: TitleModel_Vestir) {
        // 检查是否登录
        if !UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir {
            showLoginPrompt_Vestir()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Vestir(post_vestir: post_vestir) {
            // 取消点赞
            UserViewModel_Vestir.shared_Vestir.removeLikeFromCurrentUser_Vestir(post_vestir: post_vestir)
            
            // 更新帖子的点赞数
            if let index_vestir = posts_Vestir.firstIndex(where: { $0.titleId_Vestir == post_vestir.titleId_Vestir }) {
                posts_Vestir[index_vestir].likes_Vestir = max(0, posts_Vestir[index_vestir].likes_Vestir - 1)
            }
        } else {
            // 点赞
            UserViewModel_Vestir.shared_Vestir.addLikeToCurrentUser_Vestir(post_vestir: post_vestir)
            
            // 更新帖子的点赞数
            if let index_vestir = posts_Vestir.firstIndex(where: { $0.titleId_Vestir == post_vestir.titleId_Vestir }) {
                posts_Vestir[index_vestir].likes_Vestir += 1
            }
        }
        
        notifyStateChange_Vestir()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Vestir() {
        NotificationCenter.default.post(
            name: TitleViewModel_Vestir.titleStateDidChangeNotification_Vestir,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Vestir() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Vestir.toLogin_Vestir(style_vestir: .present_vestir)
        }
    }
}

