import Foundation
import UIKit
import Combine

// MARK: - 帖子ViewModel

/// 帖子状态管理类
class TitleViewModel_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = TitleViewModel_lite()
    
    // MARK: - 响应式属性
    
    /// 帖子列表
    @Published var posts_lite: [TitleModel_lite] = []
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_lite() -> [TitleModel_lite] {
        return posts_lite
    }
    
    /// 初始化帖子列表
    func initPosts_lite() {
        posts_lite = LocalData_lite.shared_lite.titleList_lite
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_lite(user_lite: PrewUserModel_lite, type_lite: Int? = nil) -> [TitleModel_lite] {
        guard let userId_lite = user_lite.userId_lite else { return [] }
        
        var filteredPosts_lite = posts_lite.filter { post_lite in
            post_lite.titleUserId_lite == userId_lite
        }
        
        // 如果指定了类型，进一步筛选
        if type_lite != nil {
            filteredPosts_lite = filteredPosts_lite.filter { post_lite in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_lite
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_lite(post_lite: TitleModel_lite) -> Bool {
        return UserViewModel_lite.shared_lite.isLikedByCurrentUser_lite(post_lite: post_lite)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_lite(
        title_lite: String,
        content_lite: String,
        media_lite: String,
        type_lite: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let newPostId_lite = posts_lite.count + 20 + 1
        
        let newPost_lite = TitleModel_lite(
            titleId_lite: newPostId_lite,
            titleUserId_lite: currentUser_lite.userId_lite ?? 0,
            titleUserName_lite: currentUser_lite.userName_lite ?? "User",
            titleMeidas_lite: [media_lite],
            title_lite: title_lite,
            titleContent_lite: content_lite,
            reviews_lite: [],
            likes_lite: 0
        )
        
        posts_lite.append(newPost_lite)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_lite.shared_lite.addPostToCurrentUser_lite(post_lite: newPost_lite)
        
        Utils_lite.showSuccess_lite(
            message_lite: "Published successfully.",
            image_lite: UIImage(systemName: "checkmark.circle.fill")
        )
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_lite(post_lite: TitleModel_lite, isDelete_lite: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_lite.shared_lite.removePostFromCurrentUser_lite(post_lite: post_lite)
        
        // 从用户的喜欢列表中移除
        UserViewModel_lite.shared_lite.removeLikeFromCurrentUser_lite(post_lite: post_lite)
        
        // 从帖子列表中移除
        posts_lite.removeAll { $0.titleId_lite == post_lite.titleId_lite }
        
        let message_lite = isDelete_lite
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_lite.showSuccess_lite(
            message_lite: message_lite,
            image_lite: UIImage(systemName: "trash.fill"),
            delay_lite: 1.5
        )
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_lite(userId_lite: Int) {
        posts_lite.removeAll { post_lite in
            post_lite.titleUserId_lite == userId_lite
        }
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_lite(post_lite: TitleModel_lite, content_lite: String) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 获取当前用户信息
        let currentUser_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite()
        
        let newCommentId_lite = post_lite.reviews_lite.count + 1
        
        let newComment_lite = Comment_lite(
            commentId_lite: newCommentId_lite,
            commentUserId_lite: currentUser_lite.userId_lite ?? 0,
            commentUserName_lite: currentUser_lite.userName_lite ?? "User",
            commentContent_lite: content_lite
        )
        
        // 找到对应的帖子并添加评论
        if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
            posts_lite[index_lite].reviews_lite.append(newComment_lite)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        Utils_lite.showSuccess_lite(
            message_lite: "Comment posted",
            image_lite: UIImage(systemName: "bubble.left.fill")
        )
    }
    
    /// 删除评论
    func deleteComment_lite(
        post_lite: TitleModel_lite,
        comment_lite: Comment_lite,
        isDelete_lite: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
            posts_lite[index_lite].reviews_lite.removeAll { comment_lite in
                comment_lite.commentId_lite == comment_lite.commentId_lite
            }
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        let message_lite = isDelete_lite
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_lite.showSuccess_lite(
            message_lite: message_lite,
            delay_lite: 1.5
        )
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_lite(post_lite: TitleModel_lite) {
        // 检查是否登录
        if !UserViewModel_lite.shared_lite.isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_lite(post_lite: post_lite) {
            // 取消点赞
            UserViewModel_lite.shared_lite.removeLikeFromCurrentUser_lite(post_lite: post_lite)
            
            // 更新帖子的点赞数
            if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
                posts_lite[index_lite].likes_lite = max(0, posts_lite[index_lite].likes_lite - 1)
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        } else {
            // 点赞
            UserViewModel_lite.shared_lite.addLikeToCurrentUser_lite(post_lite: post_lite)
            
            // 更新帖子的点赞数
            if let index_lite = posts_lite.firstIndex(where: { $0.titleId_lite == post_lite.titleId_lite }) {
                posts_lite[index_lite].likes_lite += 1
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_lite() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_lite.shared_lite.toLogin_liteui()
        }
    }
}
