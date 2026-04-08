import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Somnia {
    
    /// 单例
    static let shared_Somnia = TitleViewModel_Somnia()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Somnia = Notification.Name("TitleStateDidChange_Somnia")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Somnia: [TitleModel_Somnia] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Somnia() -> [TitleModel_Somnia] {
        return posts_Somnia
    }
    
    /// 初始化帖子列表
    func initPosts_Somnia() {
        posts_Somnia = LocalData_Somnia.shared_Somnia.titleList_Somnia
        notifyStateChange_Somnia()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Somnia(user_somnia: PrewUserModel_Somnia, type_somnia: Int? = nil) -> [TitleModel_Somnia] {
        guard let userId_somnia = user_somnia.userId_Somnia else { return [] }
        
        var filteredPosts_somnia = posts_Somnia.filter { post in
            post.titleUserId_Somnia == userId_somnia
        }
        
        // 如果指定了类型，进一步筛选
        if type_somnia != nil {
            filteredPosts_somnia = filteredPosts_somnia.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_somnia
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Somnia(post_somnia: TitleModel_Somnia) -> Bool {
        return UserViewModel_Somnia.shared_Somnia.isLikedByCurrentUser_Somnia(post_somnia: post_somnia)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Somnia(
        title_somnia: String,
        content_somnia: String,
        media_somnia: String,
        type_somnia: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia {
            showLoginPrompt_Somnia()
            return
        }
        
        // 获取当前用户信息
        let currentUser_somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        
        let newPostId_somnia = posts_Somnia.count + 20 + 1
        
        let newPost_somnia = TitleModel_Somnia(
            titleId_Somnia: newPostId_somnia,
            titleUserId_Somnia: currentUser_somnia.userId_Somnia ?? 0,
            titleUserName_Somnia: currentUser_somnia.userName_Somnia ?? "User",
            titleMeidas_Somnia: [media_somnia],
            title_Somnia: title_somnia,
            titleContent_Somnia: content_somnia,
            reviews_Somnia: [],
            likes_Somnia: 0
        )
        
        posts_Somnia.append(newPost_somnia)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Somnia.shared_Somnia.addPostToCurrentUser_Somnia(post_somnia: newPost_somnia)
        
        Utils_Somnia.showSuccess_Somnia(
            message_Somnia: "Published successfully.",
            image_Somnia: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Somnia()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Somnia(post_somnia: TitleModel_Somnia, isDelete_somnia: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Somnia.shared_Somnia.removePostFromCurrentUser_Somnia(post_somnia: post_somnia)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Somnia.shared_Somnia.removeLikeFromCurrentUser_Somnia(post_somnia: post_somnia)
        
        // 从帖子列表中移除
        posts_Somnia.removeAll { $0.titleId_Somnia == post_somnia.titleId_Somnia }
        
        let message_somnia = isDelete_somnia
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Somnia.showSuccess_Somnia(
            message_Somnia: message_somnia,
            image_Somnia: UIImage(systemName: "trash.fill"),
            delay_Somnia: 1.5
        )
        
        notifyStateChange_Somnia()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Somnia(userId_somnia: Int) {
        posts_Somnia.removeAll { post in
            post.titleUserId_Somnia == userId_somnia
        }
        notifyStateChange_Somnia()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Somnia(post_somnia: TitleModel_Somnia, content_somnia: String) {
        // 检查是否登录
        if !UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia {
            showLoginPrompt_Somnia()
            return
        }
        
        // 获取当前用户信息
        let currentUser_somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        
        let newCommentId_somnia = post_somnia.reviews_Somnia.count + 1
        
        let newComment_somnia = Comment_Somnia(
            commentId_Somnia: newCommentId_somnia,
            commentUserId_Somnia: currentUser_somnia.userId_Somnia ?? 0,
            commentUserName_Somnia: currentUser_somnia.userName_Somnia ?? "User",
            commentContent_Somnia: content_somnia
        )
        
        // 找到对应的帖子并添加评论
        if let index_somnia = posts_Somnia.firstIndex(where: { $0.titleId_Somnia == post_somnia.titleId_Somnia }) {
            posts_Somnia[index_somnia].reviews_Somnia.append(newComment_somnia)
        }
        
        notifyStateChange_Somnia()
    }
    
    /// 删除评论
    func deleteComment_Somnia(
        post_somnia: TitleModel_Somnia,
        comment_somnia: Comment_Somnia,
        isDelete_somnia: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_somnia = posts_Somnia.firstIndex(where: { $0.titleId_Somnia == post_somnia.titleId_Somnia }) {
            posts_Somnia[index_somnia].reviews_Somnia.removeAll { comment in
                comment.commentId_Somnia == comment_somnia.commentId_Somnia
            }
        }
        
        let message_somnia = isDelete_somnia
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Somnia.showSuccess_Somnia(
            message_Somnia: message_somnia,
            delay_Somnia: 1.5
        )
        
        notifyStateChange_Somnia()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Somnia(post_somnia: TitleModel_Somnia) {
        // 检查是否登录
        if !UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia {
            showLoginPrompt_Somnia()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Somnia(post_somnia: post_somnia) {
            // 取消点赞
            UserViewModel_Somnia.shared_Somnia.removeLikeFromCurrentUser_Somnia(post_somnia: post_somnia)
            
            // 更新帖子的点赞数
            if let index_somnia = posts_Somnia.firstIndex(where: { $0.titleId_Somnia == post_somnia.titleId_Somnia }) {
                posts_Somnia[index_somnia].likes_Somnia = max(0, posts_Somnia[index_somnia].likes_Somnia - 1)
            }
        } else {
            // 点赞
            UserViewModel_Somnia.shared_Somnia.addLikeToCurrentUser_Somnia(post_somnia: post_somnia)
            
            // 更新帖子的点赞数
            if let index_somnia = posts_Somnia.firstIndex(where: { $0.titleId_Somnia == post_somnia.titleId_Somnia }) {
                posts_Somnia[index_somnia].likes_Somnia += 1
            }
        }
        
        notifyStateChange_Somnia()
    }
    
    // MARK: - 公共方法 - 搜索与过滤
    
    /// 分类标签枚举，用于发现页帖子过滤
    enum DiscoverCategory_Somnia: String, CaseIterable {
        case all_somnia = "All"
        case peaceful_somnia = "Peaceful"
        case magical_somnia = "Magical"
        case adventure_somnia = "Adventure"
        case friends_somnia = "Friends"
        case stars_somnia = "Stars"
        
        /// 对应的关键字匹配列表（匹配标题或内容）
        var keywords_Somnia: [String] {
            switch self {
            case .all_somnia:      return []
            case .peaceful_somnia: return ["peace", "quiet", "calm", "embers", "seep", "warmth", "silent"]
            case .magical_somnia:  return ["magic", "magical", "sparkl", "glow", "firelight", "treasure"]
            case .adventure_somnia:return ["adventure", "danc", "jump", "activ", "game", "sing"]
            case .friends_somnia:  return ["friend", "crew", "people", "family", "heart", "together", "company"]
            case .stars_somnia:    return ["star", "sky", "universe", "drift", "firefl"]
            }
        }
    }
    
    /// 搜索并过滤帖子
    /// - Parameters:
    ///   - keyword_somnia: 搜索关键字（匹配标题和内容），空字符串返回全量
    ///   - category_somnia: 分类标签，nil 或 .all_somnia 时不过滤分类
    /// - Returns: 过滤后的帖子列表
    func searchPosts_Somnia(
        keyword_somnia: String,
        category_somnia: DiscoverCategory_Somnia? = nil
    ) -> [TitleModel_Somnia] {
        var result_somnia = posts_Somnia
        
        // 按分类过滤
        if let cat_somnia = category_somnia, cat_somnia != .all_somnia {
            let keys_somnia = cat_somnia.keywords_Somnia
            result_somnia = result_somnia.filter { post_somnia in
                let combined_somnia = (post_somnia.title_Somnia + " " + post_somnia.titleContent_Somnia).lowercased()
                return keys_somnia.contains { combined_somnia.contains($0.lowercased()) }
            }
        }
        
        // 按关键字搜索
        let trimmed_somnia = keyword_somnia.trimmingCharacters(in: .whitespaces)
        if !trimmed_somnia.isEmpty {
            result_somnia = result_somnia.filter { post_somnia in
                post_somnia.title_Somnia.localizedCaseInsensitiveContains(trimmed_somnia)
                || post_somnia.titleContent_Somnia.localizedCaseInsensitiveContains(trimmed_somnia)
                || post_somnia.titleUserName_Somnia.localizedCaseInsensitiveContains(trimmed_somnia)
            }
        }
        
        return result_somnia
    }
    
    /// 获取热门帖子（按点赞数降序）
    /// - Parameter limit_somnia: 返回数量上限，0 表示全量
    /// - Returns: 排序后的帖子列表
    func getHotPosts_Somnia(limit_somnia: Int = 0) -> [TitleModel_Somnia] {
        let sorted_somnia = posts_Somnia.sorted { $0.likes_Somnia > $1.likes_Somnia }
        if limit_somnia > 0 {
            return Array(sorted_somnia.prefix(limit_somnia))
        }
        return sorted_somnia
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Somnia() {
        NotificationCenter.default.post(
            name: TitleViewModel_Somnia.titleStateDidChangeNotification_Somnia,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Somnia() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Somnia.toLogin_Somnia(style_somnia: .present_somnia)
        }
    }
}

