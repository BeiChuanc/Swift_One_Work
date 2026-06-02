import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Breeze {
    
    /// 单例
    static let shared_Breeze = TitleViewModel_Breeze()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Breeze = Notification.Name("TitleStateDidChange_Breeze")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Breeze: [TitleModel_Breeze] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取全量帖子列表
    func getPosts_Breeze() -> [TitleModel_Breeze] {
        return posts_Breeze
    }
    
    /// 按分类筛选帖子列表
    /// - Parameter category_breeze: 目标分类；传入 .all_breeze 时返回全量列表
    /// - Returns: 符合分类的帖子数组
    func getPostsByCategory_Breeze(category_breeze: PostCategory_Breeze) -> [TitleModel_Breeze] {
        guard category_breeze != .all_breeze else { return posts_Breeze }
        return posts_Breeze.filter { $0.titleCategory_Breeze == category_breeze }
    }
    
    /// 按关键词与分类双重筛选帖子列表
    /// - Parameters:
    ///   - keyword_breeze: 搜索关键词，同时匹配标题和内容（空串视为不过滤）
    ///   - category_breeze: 目标分类，.all_breeze 时不过滤分类
    /// - Returns: 同时满足分类和关键词条件的帖子数组
    func searchPosts_Breeze(keyword_breeze: String, category_breeze: PostCategory_Breeze) -> [TitleModel_Breeze] {
        // 先按分类筛选
        var result_breeze = category_breeze == .all_breeze
            ? posts_Breeze
            : posts_Breeze.filter { $0.titleCategory_Breeze == category_breeze }
        
        // 关键词为空时直接返回分类结果
        let trimmed_breeze = keyword_breeze.trimmingCharacters(in: .whitespaces)
        guard !trimmed_breeze.isEmpty else { return result_breeze }
        
        // 不区分大小写匹配标题或内容
        let lower_breeze = trimmed_breeze.lowercased()
        result_breeze = result_breeze.filter {
            $0.title_Breeze.lowercased().contains(lower_breeze) ||
            $0.titleContent_Breeze.lowercased().contains(lower_breeze)
        }
        return result_breeze
    }
    
    /// 初始化帖子列表
    func initPosts_Breeze() {
        posts_Breeze = LocalData_Breeze.shared_Breeze.titleList_Breeze
        notifyStateChange_Breeze()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Breeze(user_breeze: PrewUserModel_Breeze, type_breeze: Int? = nil) -> [TitleModel_Breeze] {
        guard let userId_breeze = user_breeze.userId_Breeze else { return [] }
        
        var filteredPosts_breeze = posts_Breeze.filter { post in
            post.titleUserId_Breeze == userId_breeze
        }
        
        // 如果指定了类型，进一步筛选
        if type_breeze != nil {
            filteredPosts_breeze = filteredPosts_breeze.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_breeze
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Breeze(post_breeze: TitleModel_Breeze) -> Bool {
        return UserViewModel_Breeze.shared_Breeze.isLikedByCurrentUser_Breeze(post_breeze: post_breeze)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    /// - Parameters:
    ///   - title_breeze: 帖子标题
    ///   - content_breeze: 帖子内容
    ///   - media_breeze: 媒体文件名
    ///   - category_breeze: 帖子分类（默认 .camping_breeze）
    func releasePost_Breeze(
        title_breeze: String,
        content_breeze: String,
        media_breeze: String,
        category_breeze: PostCategory_Breeze = .camping_breeze
    ) {
        // 检查是否登录
        if !UserViewModel_Breeze.shared_Breeze.isLoggedIn_Breeze {
            showLoginPrompt_Breeze()
            return
        }
        
        // 获取当前用户信息
        let currentUser_breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        
        let newPostId_breeze = posts_Breeze.count + 20 + 1
        
        let newPost_breeze = TitleModel_Breeze(
            titleId_Breeze: newPostId_breeze,
            titleUserId_Breeze: currentUser_breeze.userId_Breeze ?? 0,
            titleUserName_Breeze: currentUser_breeze.userName_Breeze ?? "User",
            titleMeidas_Breeze: [media_breeze],
            title_Breeze: title_breeze,
            titleContent_Breeze: content_breeze,
            reviews_Breeze: [],
            likes_Breeze: 0,
            titleCategory_Breeze: category_breeze
        )
        
        posts_Breeze.append(newPost_breeze)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Breeze.shared_Breeze.addPostToCurrentUser_Breeze(post_breeze: newPost_breeze)
        
        Utils_Breeze.showSuccess_Breeze(
            message_Breeze: "Published successfully.",
            image_Breeze: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Breeze()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Breeze(post_breeze: TitleModel_Breeze, isDelete_breeze: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Breeze.shared_Breeze.removePostFromCurrentUser_Breeze(post_breeze: post_breeze)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Breeze.shared_Breeze.removeLikeFromCurrentUser_Breeze(post_breeze: post_breeze)
        
        // 从帖子列表中移除
        posts_Breeze.removeAll { $0.titleId_Breeze == post_breeze.titleId_Breeze }
        
        let message_breeze = isDelete_breeze
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Breeze.showSuccess_Breeze(
            message_Breeze: message_breeze,
            image_Breeze: UIImage(systemName: "trash.fill"),
            delay_Breeze: 1.5
        )
        
        notifyStateChange_Breeze()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Breeze(userId_breeze: Int) {
        posts_Breeze.removeAll { post in
            post.titleUserId_Breeze == userId_breeze
        }
        notifyStateChange_Breeze()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Breeze(post_breeze: TitleModel_Breeze, content_breeze: String) {
        // 检查是否登录
        if !UserViewModel_Breeze.shared_Breeze.isLoggedIn_Breeze {
            showLoginPrompt_Breeze()
            return
        }
        
        // 获取当前用户信息
        let currentUser_breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        
        let newCommentId_breeze = post_breeze.reviews_Breeze.count + 1
        
        let newComment_breeze = Comment_Breeze(
            commentId_Breeze: newCommentId_breeze,
            commentUserId_Breeze: currentUser_breeze.userId_Breeze ?? 0,
            commentUserName_Breeze: currentUser_breeze.userName_Breeze ?? "User",
            commentContent_Breeze: content_breeze
        )
        
        // 找到对应的帖子并添加评论
        if let index_breeze = posts_Breeze.firstIndex(where: { $0.titleId_Breeze == post_breeze.titleId_Breeze }) {
            posts_Breeze[index_breeze].reviews_Breeze.append(newComment_breeze)
        }
        
        notifyStateChange_Breeze()
    }
    
    /// 删除评论
    func deleteComment_Breeze(
        post_breeze: TitleModel_Breeze,
        comment_breeze: Comment_Breeze,
        isDelete_breeze: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_breeze = posts_Breeze.firstIndex(where: { $0.titleId_Breeze == post_breeze.titleId_Breeze }) {
            posts_Breeze[index_breeze].reviews_Breeze.removeAll { comment in
                comment.commentId_Breeze == comment_breeze.commentId_Breeze
            }
        }
        
        let message_breeze = isDelete_breeze
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Breeze.showSuccess_Breeze(
            message_Breeze: message_breeze,
            delay_Breeze: 1.5
        )
        
        notifyStateChange_Breeze()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Breeze(post_breeze: TitleModel_Breeze) {
        // 检查是否登录
        if !UserViewModel_Breeze.shared_Breeze.isLoggedIn_Breeze {
            showLoginPrompt_Breeze()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Breeze(post_breeze: post_breeze) {
            // 取消点赞
            UserViewModel_Breeze.shared_Breeze.removeLikeFromCurrentUser_Breeze(post_breeze: post_breeze)
            
            // 更新帖子的点赞数
            if let index_breeze = posts_Breeze.firstIndex(where: { $0.titleId_Breeze == post_breeze.titleId_Breeze }) {
                posts_Breeze[index_breeze].likes_Breeze = max(0, posts_Breeze[index_breeze].likes_Breeze - 1)
            }
        } else {
            // 点赞
            UserViewModel_Breeze.shared_Breeze.addLikeToCurrentUser_Breeze(post_breeze: post_breeze)
            
            // 更新帖子的点赞数
            if let index_breeze = posts_Breeze.firstIndex(where: { $0.titleId_Breeze == post_breeze.titleId_Breeze }) {
                posts_Breeze[index_breeze].likes_Breeze += 1
            }
        }
        
        notifyStateChange_Breeze()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Breeze() {
        NotificationCenter.default.post(
            name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Breeze() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Breeze.toLogin_Breeze(style_breeze: .present_breeze)
        }
    }
}

