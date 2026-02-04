import Foundation
import UIKit
import Combine

// MARK: - 帖子ViewModel

/// 帖子状态管理类
class TitleViewModel_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = TitleViewModel_blisslink()
    
    // MARK: - 响应式属性
    
    /// 帖子列表
    @Published var posts_blisslink: [TitleModel_blisslink] = []
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_blisslink() -> [TitleModel_blisslink] {
        return posts_blisslink
    }
    
    /// 初始化帖子列表
    func initPosts_blisslink() {
        posts_blisslink = LocalData_blisslink.shared_blisslink.titleList_blisslink
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_blisslink(user_blisslink: PrewUserModel_blisslink, type_blisslink: Int? = nil) -> [TitleModel_blisslink] {
        guard let userId_blisslink = user_blisslink.userId_blisslink else { return [] }
        
        var filteredPosts_blisslink = posts_blisslink.filter { post_blisslink in
            post_blisslink.titleUserId_blisslink == userId_blisslink
        }
        
        // 如果指定了类型，进一步筛选
        if type_blisslink != nil {
            filteredPosts_blisslink = filteredPosts_blisslink.filter { post_blisslink in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_blisslink
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_blisslink(post_blisslink: TitleModel_blisslink) -> Bool {
        return UserViewModel_blisslink.shared_blisslink.isLikedByCurrentUser_blisslink(post_blisslink: post_blisslink)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_blisslink(
        title_blisslink: String,
        content_blisslink: String,
        media_blisslink: String,
        type_blisslink: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_blisslink.shared_blisslink.isLoggedIn_blisslink {
            showLoginPrompt_blisslink()
            return
        }
        
        // 获取当前用户信息
        let currentUser_blisslink = UserViewModel_blisslink.shared_blisslink.getCurrentUser_blisslink()
        
        let newPostId_blisslink = posts_blisslink.count + 20 + 1
        
        let newPost_blisslink = TitleModel_blisslink(
            titleId_blisslink: newPostId_blisslink,
            titleUserId_blisslink: currentUser_blisslink.userId_blisslink ?? 0,
            titleUserName_blisslink: currentUser_blisslink.userName_blisslink ?? "User",
            titleMeidas_blisslink: [media_blisslink],
            title_blisslink: title_blisslink,
            titleContent_blisslink: content_blisslink,
            reviews_blisslink: [],
            likes_blisslink: 0
        )
        
        posts_blisslink.append(newPost_blisslink)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_blisslink.shared_blisslink.addPostToCurrentUser_blisslink(post_blisslink: newPost_blisslink)
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: "Published successfully.",
            image_blisslink: UIImage(systemName: "checkmark.circle.fill")
        )
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_blisslink(post_blisslink: TitleModel_blisslink, isDelete_blisslink: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_blisslink.shared_blisslink.removePostFromCurrentUser_blisslink(post_blisslink: post_blisslink)
        
        // 从用户的喜欢列表中移除
        UserViewModel_blisslink.shared_blisslink.removeLikeFromCurrentUser_blisslink(post_blisslink: post_blisslink)
        
        // 从帖子列表中移除
        posts_blisslink.removeAll { $0.titleId_blisslink == post_blisslink.titleId_blisslink }
        
        let message_blisslink = isDelete_blisslink
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: message_blisslink,
            image_blisslink: UIImage(systemName: "trash.fill"),
            delay_blisslink: 1.5
        )
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_blisslink(userId_blisslink: Int) {
        posts_blisslink.removeAll { post_blisslink in
            post_blisslink.titleUserId_blisslink == userId_blisslink
        }
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_blisslink(post_blisslink: TitleModel_blisslink, content_blisslink: String) {
        // 检查是否登录
        if !UserViewModel_blisslink.shared_blisslink.isLoggedIn_blisslink {
            showLoginPrompt_blisslink()
            return
        }
        
        // 获取当前用户信息
        let currentUser_blisslink = UserViewModel_blisslink.shared_blisslink.getCurrentUser_blisslink()
        
        let newCommentId_blisslink = post_blisslink.reviews_blisslink.count + 1
        
        let newComment_blisslink = Comment_blisslink(
            commentId_blisslink: newCommentId_blisslink,
            commentUserId_blisslink: currentUser_blisslink.userId_blisslink ?? 0,
            commentUserName_blisslink: currentUser_blisslink.userName_blisslink ?? "User",
            commentContent_blisslink: content_blisslink
        )
        
        // 找到对应的帖子并添加评论
        if let index_blisslink = posts_blisslink.firstIndex(where: { $0.titleId_blisslink == post_blisslink.titleId_blisslink }) {
            posts_blisslink[index_blisslink].reviews_blisslink.append(newComment_blisslink)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: "Comment posted",
            image_blisslink: UIImage(systemName: "bubble.left.fill")
        )
    }
    
    /// 删除评论
    func deleteComment_blisslink(
        post_blisslink: TitleModel_blisslink,
        comment_blisslink: Comment_blisslink,
        isDelete_blisslink: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_blisslink = posts_blisslink.firstIndex(where: { $0.titleId_blisslink == post_blisslink.titleId_blisslink }) {
            // 修复：使用不同的参数名避免变量遮蔽
            posts_blisslink[index_blisslink].reviews_blisslink.removeAll { iteratingComment_blisslink in
                iteratingComment_blisslink.commentId_blisslink == comment_blisslink.commentId_blisslink
            }
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        let message_blisslink = isDelete_blisslink
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: message_blisslink,
            delay_blisslink: 1.5
        )
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_blisslink(post_blisslink: TitleModel_blisslink) {
        // 检查是否登录
        if !UserViewModel_blisslink.shared_blisslink.isLoggedIn_blisslink {
            showLoginPrompt_blisslink()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_blisslink(post_blisslink: post_blisslink) {
            // 取消点赞
            UserViewModel_blisslink.shared_blisslink.removeLikeFromCurrentUser_blisslink(post_blisslink: post_blisslink)
            
            // 更新帖子的点赞数
            if let index_blisslink = posts_blisslink.firstIndex(where: { $0.titleId_blisslink == post_blisslink.titleId_blisslink }) {
                posts_blisslink[index_blisslink].likes_blisslink = max(0, posts_blisslink[index_blisslink].likes_blisslink - 1)
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        } else {
            // 点赞
            UserViewModel_blisslink.shared_blisslink.addLikeToCurrentUser_blisslink(post_blisslink: post_blisslink)
            
            // 更新帖子的点赞数
            if let index_blisslink = posts_blisslink.firstIndex(where: { $0.titleId_blisslink == post_blisslink.titleId_blisslink }) {
                posts_blisslink[index_blisslink].likes_blisslink += 1
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_blisslink() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Router_blisslink.shared_blisslink.toLogin_blisslink()
        }
    }
}
