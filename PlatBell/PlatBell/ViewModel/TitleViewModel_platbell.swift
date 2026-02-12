import Foundation
import UIKit
import Combine

// MARK: - 帖子ViewModel

/// 帖子状态管理类
class TitleViewModel_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = TitleViewModel_platbell()
    
    // MARK: - 响应式属性
    
    /// 帖子列表
    @Published var posts_platbell: [TitleModel_platbell] = []
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_platbell() -> [TitleModel_platbell] {
        return posts_platbell
    }
    
    /// 初始化帖子列表
    func initPosts_platbell() {
        posts_platbell = LocalData_platbell.shared_platbell.titleList_platbell
    }
    
    /// 获取时间线帖子（按时间倒序，模拟时间排序）
    /// - Returns: 按时间倒序的帖子列表
    func getTimelinePosts_platbell() -> [TitleModel_platbell] {
        // 由于没有时间字段，我们按照帖子ID倒序排列（假设ID越大越新）
        return posts_platbell.sorted { $0.titleId_platbell > $1.titleId_platbell }
    }
    
    /// 获取热门帖子（按点赞数排序）
    /// - Parameter limit_platbell: 限制数量，默认10
    /// - Returns: 按点赞数排序的帖子列表
    func getHotPosts_platbell(limit_platbell: Int = 10) -> [TitleModel_platbell] {
        return posts_platbell.sorted { $0.likes_platbell > $1.likes_platbell }
            .prefix(limit_platbell)
            .map { $0 }
    }
    
    /// 获取话题帖子（类型为1的帖子）
    /// - Returns: 话题帖子列表
    func getTopicPosts_platbell() -> [TitleModel_platbell] {
        return posts_platbell.filter { $0.type_platbell == 1 }
    }
    
    /// 获取普通帖子（类型为0的帖子）
    /// - Returns: 普通帖子列表
    func getNormalPosts_platbell() -> [TitleModel_platbell] {
        return posts_platbell.filter { $0.type_platbell == 0 }
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_platbell(user_platbell: PrewUserModel_platbell, type_platbell: Int? = nil) -> [TitleModel_platbell] {
        guard let userId_platbell = user_platbell.userId_platbell else { return [] }
        
        var filteredPosts_platbell = posts_platbell.filter { post_platbell in
            post_platbell.titleUserId_platbell == userId_platbell
        }
        
        // 如果指定了类型，进一步筛选
        if type_platbell != nil {
            filteredPosts_platbell = filteredPosts_platbell.filter { post_platbell in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_platbell
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_platbell(post_platbell: TitleModel_platbell) -> Bool {
        return UserViewModel_platbell.shared_platbell.isLikedByCurrentUser_platbell(post_platbell: post_platbell)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_platbell(
        title_platbell: String,
        content_platbell: String,
        media_platbell: String,
        type_platbell: Int = 0,
        tags_platbell: [String] = []
    ) {
        // 检查是否登录
        if !UserViewModel_platbell.shared_platbell.isLoggedIn_platbell {
            showLoginPrompt_platbell()
            return
        }
        
        // 获取当前用户信息
        let currentUser_platbell = UserViewModel_platbell.shared_platbell.getCurrentUser_platbell()
        
        let newPostId_platbell = posts_platbell.count + 20 + 1
        
        let newPost_platbell = TitleModel_platbell(
            titleId_platbell: newPostId_platbell,
            titleUserId_platbell: currentUser_platbell.userId_platbell ?? 0,
            titleUserName_platbell: currentUser_platbell.userName_platbell ?? "User",
            titleMeidas_platbell: [media_platbell],
            title_platbell: title_platbell,
            titleContent_platbell: content_platbell,
            reviews_platbell: [],
            likes_platbell: 0,
            type_platbell: type_platbell,
            tags_platbell: tags_platbell
        )
        
        posts_platbell.append(newPost_platbell)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_platbell.shared_platbell.addPostToCurrentUser_platbell(post_platbell: newPost_platbell)
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Published successfully.",
            image_platbell: UIImage(systemName: "checkmark.circle.fill")
        )
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_platbell(post_platbell: TitleModel_platbell, isDelete_platbell: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_platbell.shared_platbell.removePostFromCurrentUser_platbell(post_platbell: post_platbell)
        
        // 从用户的喜欢列表中移除
        UserViewModel_platbell.shared_platbell.removeLikeFromCurrentUser_platbell(post_platbell: post_platbell)
        
        // 从帖子列表中移除
        posts_platbell.removeAll { $0.titleId_platbell == post_platbell.titleId_platbell }
        
        let message_platbell = isDelete_platbell
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: message_platbell,
            image_platbell: UIImage(systemName: "trash.fill"),
            delay_platbell: 1.5
        )
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_platbell(userId_platbell: Int) {
        posts_platbell.removeAll { post_platbell in
            post_platbell.titleUserId_platbell == userId_platbell
        }
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 添加评论（快捷方法）
    /// - Parameters:
    ///   - post_platbell: 帖子对象
    ///   - comment_platbell: 评论对象
    func addComment_platbell(post_platbell: TitleModel_platbell, comment_platbell: Comment_platbell) {
        // 找到对应的帖子并添加评论
        if let index_platbell = posts_platbell.firstIndex(where: { $0.titleId_platbell == post_platbell.titleId_platbell }) {
            posts_platbell[index_platbell].reviews_platbell.append(comment_platbell)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
    }
    
    /// 发布评论
    func releaseComment_platbell(post_platbell: TitleModel_platbell, content_platbell: String) {
        // 检查是否登录
        if !UserViewModel_platbell.shared_platbell.isLoggedIn_platbell {
            showLoginPrompt_platbell()
            return
        }
        
        // 获取当前用户信息
        let currentUser_platbell = UserViewModel_platbell.shared_platbell.getCurrentUser_platbell()
        
        let newCommentId_platbell = post_platbell.reviews_platbell.count + 1
        
        let newComment_platbell = Comment_platbell(
            commentId_platbell: newCommentId_platbell,
            commentUserId_platbell: currentUser_platbell.userId_platbell ?? 0,
            commentUserName_platbell: currentUser_platbell.userName_platbell ?? "User",
            commentContent_platbell: content_platbell
        )
        
        // 找到对应的帖子并添加评论
        if let index_platbell = posts_platbell.firstIndex(where: { $0.titleId_platbell == post_platbell.titleId_platbell }) {
            posts_platbell[index_platbell].reviews_platbell.append(newComment_platbell)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Comment posted",
            image_platbell: UIImage(systemName: "bubble.left.fill")
        )
    }
    
    /// 删除评论
    func deleteComment_platbell(
        post_platbell: TitleModel_platbell,
        comment_platbell: Comment_platbell,
        isDelete_platbell: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_platbell = posts_platbell.firstIndex(where: { $0.titleId_platbell == post_platbell.titleId_platbell }) {
            posts_platbell[index_platbell].reviews_platbell.removeAll { $0.commentId_platbell == comment_platbell.commentId_platbell }
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
        
        let message_platbell = isDelete_platbell
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: message_platbell,
            delay_platbell: 1.5
        )
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_platbell(post_platbell: TitleModel_platbell) {
        // 检查是否登录
        if !UserViewModel_platbell.shared_platbell.isLoggedIn_platbell {
            showLoginPrompt_platbell()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_platbell(post_platbell: post_platbell) {
            // 取消点赞
            UserViewModel_platbell.shared_platbell.removeLikeFromCurrentUser_platbell(post_platbell: post_platbell)
            
            // 更新帖子的点赞数
            if let index_platbell = posts_platbell.firstIndex(where: { $0.titleId_platbell == post_platbell.titleId_platbell }) {
                posts_platbell[index_platbell].likes_platbell = max(0, posts_platbell[index_platbell].likes_platbell - 1)
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        } else {
            // 点赞
            UserViewModel_platbell.shared_platbell.addLikeToCurrentUser_platbell(post_platbell: post_platbell)
            
            // 更新帖子的点赞数
            if let index_platbell = posts_platbell.firstIndex(where: { $0.titleId_platbell == post_platbell.titleId_platbell }) {
                posts_platbell[index_platbell].likes_platbell += 1
                // 手动触发更新，因为修改了嵌套属性
                objectWillChange.send()
            }
        }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_platbell() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_platbell.shared_platbell.toLogin_platbellui()
        }
    }
}
