import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Nest {
    
    /// 单例
    static let shared_Nest = TitleViewModel_Nest()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Nest = Notification.Name("TitleStateDidChange_Nest")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Nest: [TitleModel_Nest] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Nest() -> [TitleModel_Nest] {
        return posts_Nest
    }
    
    /// 初始化帖子列表
    func initPosts_Nest() {
        posts_Nest = LocalData_Nest.shared_Nest.titleList_Nest
        notifyStateChange_Nest()
    }
    
    /// 根据用户ID获取该用户的所有帖子列表
    /// - Parameter userId_nest: 用户ID
    /// - Returns: 该用户发布的帖子数组
    func getUserPostsById_Nest(userId_nest: Int) -> [TitleModel_Nest] {
        return posts_Nest.filter { $0.titleUserId_Nest == userId_nest }
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Nest(user_nest: PrewUserModel_Nest, type_nest: Int? = nil) -> [TitleModel_Nest] {
        guard let userId_nest = user_nest.userId_Nest else { return [] }
        
        var filteredPosts_nest = posts_Nest.filter { post in
            post.titleUserId_Nest == userId_nest
        }
        
        // 如果指定了类型，进一步筛选
        if type_nest != nil {
            filteredPosts_nest = filteredPosts_nest.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_nest
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Nest(post_nest: TitleModel_Nest) -> Bool {
        return UserViewModel_Nest.shared_Nest.isLikedByCurrentUser_Nest(post_nest: post_nest)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Nest(
        title_nest: String,
        content_nest: String,
        media_nest: String,
        type_nest: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Nest.shared_Nest.isLoggedIn_Nest {
            showLoginPrompt_Nest()
            return
        }
        
        // 获取当前用户信息
        let currentUser_nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        
        let newPostId_nest = posts_Nest.count + 20 + 1
        
        let newPost_nest = TitleModel_Nest(
            titleId_Nest: newPostId_nest,
            titleUserId_Nest: currentUser_nest.userId_Nest ?? 0,
            titleUserName_Nest: currentUser_nest.userName_Nest ?? "User",
            titleMeidas_Nest: [media_nest],
            title_Nest: title_nest,
            titleContent_Nest: content_nest,
            reviews_Nest: [],
            likes_Nest: 0
        )
        
        posts_Nest.append(newPost_nest)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Nest.shared_Nest.addPostToCurrentUser_Nest(post_nest: newPost_nest)
        
        Utils_Nest.showSuccess_Nest(
            message_Nest: "Published successfully.",
            image_Nest: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Nest()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Nest(post_nest: TitleModel_Nest, isDelete_nest: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Nest.shared_Nest.removePostFromCurrentUser_Nest(post_nest: post_nest)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Nest.shared_Nest.removeLikeFromCurrentUser_Nest(post_nest: post_nest)
        
        // 从帖子列表中移除
        posts_Nest.removeAll { $0.titleId_Nest == post_nest.titleId_Nest }
        
        let message_nest = isDelete_nest
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Nest.showSuccess_Nest(
            message_Nest: message_nest,
            image_Nest: UIImage(systemName: "trash.fill"),
            delay_Nest: 1.5
        )
        
        notifyStateChange_Nest()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Nest(userId_nest: Int) {
        posts_Nest.removeAll { post in
            post.titleUserId_Nest == userId_nest
        }
        notifyStateChange_Nest()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Nest(post_nest: TitleModel_Nest, content_nest: String) {
        // 检查是否登录
        if !UserViewModel_Nest.shared_Nest.isLoggedIn_Nest {
            showLoginPrompt_Nest()
            return
        }
        
        // 获取当前用户信息
        let currentUser_nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        
        let newCommentId_nest = post_nest.reviews_Nest.count + 1
        
        let newComment_nest = Comment_Nest(
            commentId_Nest: newCommentId_nest,
            commentUserId_Nest: currentUser_nest.userId_Nest ?? 0,
            commentUserName_Nest: currentUser_nest.userName_Nest ?? "User",
            commentContent_Nest: content_nest
        )
        
        // 找到对应的帖子并添加评论
        if let index_nest = posts_Nest.firstIndex(where: { $0.titleId_Nest == post_nest.titleId_Nest }) {
            posts_Nest[index_nest].reviews_Nest.append(newComment_nest)
        }
        
        notifyStateChange_Nest()
    }
    
    /// 删除评论
    func deleteComment_Nest(
        post_nest: TitleModel_Nest,
        comment_nest: Comment_Nest,
        isDelete_nest: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_nest = posts_Nest.firstIndex(where: { $0.titleId_Nest == post_nest.titleId_Nest }) {
            posts_Nest[index_nest].reviews_Nest.removeAll { comment in
                comment.commentId_Nest == comment_nest.commentId_Nest
            }
        }
        
        let message_nest = isDelete_nest
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Nest.showSuccess_Nest(
            message_Nest: message_nest,
            delay_Nest: 1.5
        )
        
        notifyStateChange_Nest()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Nest(post_nest: TitleModel_Nest) {
        // 检查是否登录
        if !UserViewModel_Nest.shared_Nest.isLoggedIn_Nest {
            showLoginPrompt_Nest()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Nest(post_nest: post_nest) {
            // 取消点赞
            UserViewModel_Nest.shared_Nest.removeLikeFromCurrentUser_Nest(post_nest: post_nest)
            
            // 更新帖子的点赞数
            if let index_nest = posts_Nest.firstIndex(where: { $0.titleId_Nest == post_nest.titleId_Nest }) {
                posts_Nest[index_nest].likes_Nest = max(0, posts_Nest[index_nest].likes_Nest - 1)
            }
        } else {
            // 点赞
            UserViewModel_Nest.shared_Nest.addLikeToCurrentUser_Nest(post_nest: post_nest)
            
            // 更新帖子的点赞数
            if let index_nest = posts_Nest.firstIndex(where: { $0.titleId_Nest == post_nest.titleId_Nest }) {
                posts_Nest[index_nest].likes_Nest += 1
            }
        }
        
        notifyStateChange_Nest()
    }
    
    // MARK: - 公共方法 - 首页筛选
    
    /// 获取精选帖子（按点赞数降序，取前5条），用于首页轮播 Banner
    /// 返回值：TitleModel_Nest 数组，最多5条
    func getFeaturedPosts_Nest() -> [TitleModel_Nest] {
        return posts_Nest.sorted { $0.likes_Nest > $1.likes_Nest }.prefix(5).map { $0 }
    }
    
    /// 获取经过分类过滤和关键词搜索后的帖子列表
    /// 参数：
    ///   - category_nest: 0=全部(All) 1=热门(Trending,按点赞降序) 2=最新(New,按ID降序) 3=流行(Popular,按评论数降序)
    ///   - keyword_nest: 搜索关键词，为空时不做文本过滤
    /// 返回值：过滤并排序后的 TitleModel_Nest 数组
    func getFilteredPosts_Nest(category_nest: Int, keyword_nest: String) -> [TitleModel_Nest] {
        // 关键词过滤
        var result_nest: [TitleModel_Nest]
        if keyword_nest.isEmpty {
            result_nest = posts_Nest
        } else {
            let lower_nest = keyword_nest.lowercased()
            result_nest = posts_Nest.filter {
                $0.title_Nest.lowercased().contains(lower_nest) ||
                $0.titleContent_Nest.lowercased().contains(lower_nest)
            }
        }
        
        // 分类排序
        switch category_nest {
        case 1:
            // Trending：按点赞数降序
            result_nest.sort { $0.likes_Nest > $1.likes_Nest }
        case 2:
            // New：按帖子 ID 降序（越大越新）
            result_nest.sort { $0.titleId_Nest > $1.titleId_Nest }
        case 3:
            // Popular：按评论数降序
            result_nest.sort { $0.reviews_Nest.count > $1.reviews_Nest.count }
        default:
            // All：保持原始顺序，不做额外排序
            break
        }
        
        return result_nest
    }
    
    /// 获取发现页使用的帖子列表
    /// 参数：
    ///   - keyword_nest: 搜索关键词，支持标题、正文与作者名模糊匹配
    /// 返回值：适合发现页展示的 TitleModel_Nest 数组
    func getDiscoverPosts_Nest(keyword_nest: String) -> [TitleModel_Nest] {
        let trimmedKeyword_nest = keyword_nest.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword_nest.isEmpty else {
            return posts_Nest
        }
        
        let lowerKeyword_nest = trimmedKeyword_nest.lowercased()
        return posts_Nest.filter { post_nest in
            let authorName_nest = post_nest.titleUserName_Nest.lowercased()
            return post_nest.title_Nest.lowercased().contains(lowerKeyword_nest) ||
                post_nest.titleContent_Nest.lowercased().contains(lowerKeyword_nest) ||
                authorName_nest.contains(lowerKeyword_nest)
        }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Nest() {
        NotificationCenter.default.post(
            name: TitleViewModel_Nest.titleStateDidChangeNotification_Nest,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Nest() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
        }
    }
}

