import Foundation
import UIKit
import Combine

// MARK: - 帖子ViewModel

/// 帖子状态管理类
class TitleViewModel_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = TitleViewModel_baseswiftui()
    
    // MARK: - 响应式属性
    
    /// 帖子列表
    @Published var posts_baseswiftui: [TitleModel_baseswiftui] = []
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_baseswiftui() -> [TitleModel_baseswiftui] {
        return posts_baseswiftui
    }
    
    /// 初始化帖子列表
    func initPosts_baseswiftui() {
        posts_baseswiftui = LocalData_baseswiftui.shared_baseswiftui.titleList_baseswiftui
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui, type_baseswiftui: Int? = nil) -> [TitleModel_baseswiftui] {
        guard let userId_baseswiftui = user_baseswiftui.userId_baseswiftui else { return [] }
        
        var filteredPosts_baseswiftui = posts_baseswiftui.filter { post_baseswiftui in
            post_baseswiftui.titleUserId_baseswiftui == userId_baseswiftui
        }
        
        // 如果指定了类型，进一步筛选
        if type_baseswiftui != nil {
            filteredPosts_baseswiftui = filteredPosts_baseswiftui.filter { post_baseswiftui in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_baseswiftui
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) -> Bool {
        return UserViewModel_baseswiftui.shared_baseswiftui.isLikedByCurrentUser_baseswiftui(post_baseswiftui: post_baseswiftui)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_baseswiftui(
        title_baseswiftui: String,
        content_baseswiftui: String,
        media_baseswiftui: String,
        type_baseswiftui: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_baseswiftui.shared_baseswiftui.isLoggedIn_baseswiftui {
            showLoginPrompt_baseswiftui()
            return
        }
        
        // 获取当前用户信息
        let currentUser_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui.getCurrentUser_baseswiftui()
        
        let newPostId_baseswiftui = posts_baseswiftui.count + 20 + 1
        
        let newPost_baseswiftui = TitleModel_baseswiftui(
            titleId_baseswiftui: newPostId_baseswiftui,
            titleUserId_baseswiftui: currentUser_baseswiftui.userId_baseswiftui ?? 0,
            titleUserName_baseswiftui: currentUser_baseswiftui.userName_baseswiftui ?? "User",
            titleMeidas_baseswiftui: [media_baseswiftui],
            title_baseswiftui: title_baseswiftui,
            titleContent_baseswiftui: content_baseswiftui,
            reviews_baseswiftui: [],
            likes_baseswiftui: 0
        )
        
        posts_baseswiftui.append(newPost_baseswiftui)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_baseswiftui.shared_baseswiftui.addPostToCurrentUser_baseswiftui(post_baseswiftui: newPost_baseswiftui)
        
        Utils_baseswiftui.showSuccess_baseswiftui(
            message_baseswiftui: "Published successfully.",
            image_baseswiftui: UIImage(systemName: "checkmark.circle.fill")
        )
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_baseswiftui(post_baseswiftui: TitleModel_baseswiftui, isDelete_baseswiftui: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_baseswiftui.shared_baseswiftui.removePostFromCurrentUser_baseswiftui(post_baseswiftui: post_baseswiftui)
        
        // 从用户的喜欢列表中移除
        UserViewModel_baseswiftui.shared_baseswiftui.removeLikeFromCurrentUser_baseswiftui(post_baseswiftui: post_baseswiftui)
        
        // 从帖子列表中移除
        posts_baseswiftui.removeAll { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }
        
        let message_baseswiftui = isDelete_baseswiftui
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_baseswiftui.showSuccess_baseswiftui(
            message_baseswiftui: message_baseswiftui,
            image_baseswiftui: UIImage(systemName: "trash.fill"),
            delay_baseswiftui: 1.5
        )
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_baseswiftui(userId_baseswiftui: Int) {
        posts_baseswiftui.removeAll { post_baseswiftui in
            post_baseswiftui.titleUserId_baseswiftui == userId_baseswiftui
        }
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_baseswiftui(post_baseswiftui: TitleModel_baseswiftui, content_baseswiftui: String) {
        // 检查是否登录
        if !UserViewModel_baseswiftui.shared_baseswiftui.isLoggedIn_baseswiftui {
            showLoginPrompt_baseswiftui()
            return
        }
        
        // 获取当前用户信息
        let currentUser_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui.getCurrentUser_baseswiftui()
        
        let newCommentId_baseswiftui = post_baseswiftui.reviews_baseswiftui.count + 1
        
        let newComment_baseswiftui = Comment_baseswiftui(
            commentId_baseswiftui: newCommentId_baseswiftui,
            commentUserId_baseswiftui: currentUser_baseswiftui.userId_baseswiftui ?? 0,
            commentUserName_baseswiftui: currentUser_baseswiftui.userName_baseswiftui ?? "User",
            commentContent_baseswiftui: content_baseswiftui
        )
        
        // 找到对应的帖子并添加评论
        if let index_baseswiftui = posts_baseswiftui.firstIndex(where: { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }) {
            posts_baseswiftui[index_baseswiftui].reviews_baseswiftui.append(newComment_baseswiftui)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        Utils_baseswiftui.showSuccess_baseswiftui(
            message_baseswiftui: "Comment posted",
            image_baseswiftui: UIImage(systemName: "bubble.left.fill")
        )
    }
    
    /// 删除评论
    func deleteComment_baseswiftui(
        post_baseswiftui: TitleModel_baseswiftui,
        comment_baseswiftui: Comment_baseswiftui,
        isDelete_baseswiftui: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_baseswiftui = posts_baseswiftui.firstIndex(where: { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }) {
            posts_baseswiftui[index_baseswiftui].reviews_baseswiftui.removeAll { comment_baseswiftui in
                comment_baseswiftui.commentId_baseswiftui == comment_baseswiftui.commentId_baseswiftui
            }
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        let message_baseswiftui = isDelete_baseswiftui
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_baseswiftui.showSuccess_baseswiftui(
            message_baseswiftui: message_baseswiftui,
            delay_baseswiftui: 1.5
        )
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) {
        // 检查是否登录
        if !UserViewModel_baseswiftui.shared_baseswiftui.isLoggedIn_baseswiftui {
            showLoginPrompt_baseswiftui()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_baseswiftui(post_baseswiftui: post_baseswiftui) {
            // 取消点赞
            UserViewModel_baseswiftui.shared_baseswiftui.removeLikeFromCurrentUser_baseswiftui(post_baseswiftui: post_baseswiftui)
            
            // 更新帖子的点赞数
            if let index_baseswiftui = posts_baseswiftui.firstIndex(where: { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }) {
                posts_baseswiftui[index_baseswiftui].likes_baseswiftui = max(0, posts_baseswiftui[index_baseswiftui].likes_baseswiftui - 1)
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        } else {
            // 点赞
            UserViewModel_baseswiftui.shared_baseswiftui.addLikeToCurrentUser_baseswiftui(post_baseswiftui: post_baseswiftui)
            
            // 更新帖子的点赞数
            if let index_baseswiftui = posts_baseswiftui.firstIndex(where: { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }) {
                posts_baseswiftui[index_baseswiftui].likes_baseswiftui += 1
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_baseswiftui() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_baseswiftui.shared_baseswiftui.toLogin_baseswiftuiui()
        }
    }
}
