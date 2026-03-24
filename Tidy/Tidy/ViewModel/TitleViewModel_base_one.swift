import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
/// 功能：管理社区帖子的完整生命周期，包含发布、删除、点赞、评论、分类筛选与搜索
/// 设计思路：@MainActor 单例，通过 NotificationCenter 驱动 UI 响应式更新
@MainActor
class TitleViewModel_Base_one {
    
    /// 单例
    static let shared_Base_one = TitleViewModel_Base_one()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Base_one = Notification.Name("TitleStateDidChange_Base_one")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Base_one: [TitleModel_Base_one] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Base_one() -> [TitleModel_Base_one] {
        return posts_Base_one
    }
    
    /// 初始化帖子列表
    func initPosts_Base_one() {
        posts_Base_one = LocalData_Base_one.shared_Base_one.titleList_Base_one
        notifyStateChange_Base_one()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Base_one(user_base_one: PrewUserModel_Base_one, type_base_one: Int? = nil) -> [TitleModel_Base_one] {
        guard let userId_base_one = user_base_one.userId_Base_one else { return [] }
        
        var filteredPosts_base_one = posts_Base_one.filter { post in
            post.titleUserId_Base_one == userId_base_one
        }
        
        // 如果指定了类型，进一步筛选
        if type_base_one != nil {
            filteredPosts_base_one = filteredPosts_base_one.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_base_one
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Base_one(post_base_one: TitleModel_Base_one) -> Bool {
        return UserViewModel_Base_one.shared_Base_one.isLikedByCurrentUser_Base_one(post_base_one: post_base_one)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    /// - Parameters:
    ///   - title_base_one: 帖子标题
    ///   - content_base_one: 帖子内容
    ///   - media_base_one: 媒体文件路径
    ///   - category_base_one: 帖子所属家居分类ID（对应 HomeCategory_Base_one.id_Base_one，默认 "all"）
    func releasePost_Base_one(
        title_base_one: String,
        content_base_one: String,
        media_base_one: String,
        category_base_one: String = "all"
    ) {
        // 检查是否登录
        if !UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 获取当前用户信息
        let currentUser_base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        
        let newPostId_base_one = posts_Base_one.count + 20 + 1
        
        let newPost_base_one = TitleModel_Base_one(
            titleId_Base_one: newPostId_base_one,
            titleUserId_Base_one: currentUser_base_one.userId_Base_one ?? 0,
            titleUserName_Base_one: currentUser_base_one.userName_Base_one ?? "User",
            titleMeidas_Base_one: [media_base_one],
            title_Base_one: title_base_one,
            titleContent_Base_one: content_base_one,
            reviews_Base_one: [],
            likes_Base_one: 0,
            titleCategory_Base_one: category_base_one
        )
        
        posts_Base_one.append(newPost_base_one)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Base_one.shared_Base_one.addPostToCurrentUser_Base_one(post_base_one: newPost_base_one)
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: "Published successfully.",
            image_Base_one: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Base_one(post_base_one: TitleModel_Base_one, isDelete_base_one: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Base_one.shared_Base_one.removePostFromCurrentUser_Base_one(post_base_one: post_base_one)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Base_one.shared_Base_one.removeLikeFromCurrentUser_Base_one(post_base_one: post_base_one)
        
        // 从帖子列表中移除
        posts_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }
        
        let message_base_one = isDelete_base_one
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: message_base_one,
            image_Base_one: UIImage(systemName: "trash.fill"),
            delay_Base_one: 1.5
        )
        
        notifyStateChange_Base_one()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Base_one(userId_base_one: Int) {
        posts_Base_one.removeAll { post in
            post.titleUserId_Base_one == userId_base_one
        }
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Base_one(post_base_one: TitleModel_Base_one, content_base_one: String) {
        // 检查是否登录
        if !UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 获取当前用户信息
        let currentUser_base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        
        let newCommentId_base_one = post_base_one.reviews_Base_one.count + 1
        
        let newComment_base_one = Comment_Base_one(
            commentId_Base_one: newCommentId_base_one,
            commentUserId_Base_one: currentUser_base_one.userId_Base_one ?? 0,
            commentUserName_Base_one: currentUser_base_one.userName_Base_one ?? "User",
            commentContent_Base_one: content_base_one
        )
        
        // 找到对应的帖子并添加评论
        if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
            posts_Base_one[index_base_one].reviews_Base_one.append(newComment_base_one)
        }
        
        notifyStateChange_Base_one()
    }
    
    /// 删除评论
    func deleteComment_Base_one(
        post_base_one: TitleModel_Base_one,
        comment_base_one: Comment_Base_one,
        isDelete_base_one: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
            posts_Base_one[index_base_one].reviews_Base_one.removeAll { comment in
                comment.commentId_Base_one == comment_base_one.commentId_Base_one
            }
        }
        
        let message_base_one = isDelete_base_one
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: message_base_one,
            delay_Base_one: 1.5
        )
        
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Base_one(post_base_one: TitleModel_Base_one) {
        // 检查是否登录
        if !UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Base_one(post_base_one: post_base_one) {
            // 取消点赞
            UserViewModel_Base_one.shared_Base_one.removeLikeFromCurrentUser_Base_one(post_base_one: post_base_one)
            
            // 更新帖子的点赞数
            if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
                posts_Base_one[index_base_one].likes_Base_one = max(0, posts_Base_one[index_base_one].likes_Base_one - 1)
            }
        } else {
            // 点赞
            UserViewModel_Base_one.shared_Base_one.addLikeToCurrentUser_Base_one(post_base_one: post_base_one)
            
            // 更新帖子的点赞数
            if let index_base_one = posts_Base_one.firstIndex(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
                posts_Base_one[index_base_one].likes_Base_one += 1
            }
        }
        
        notifyStateChange_Base_one()
    }
    
    // MARK: - 公共方法 - 分类与搜索
    
    /// 获取所有家居分类列表（含"全部"选项）
    /// 返回值：HomeCategory_Base_one 数组
    func getCategories_Base_one() -> [HomeCategory_Base_one] {
        return [
            HomeCategory_Base_one(id_Base_one: "all",         name_Base_one: "All",         iconName_Base_one: "square.grid.2x2.fill",  colorHex_Base_one: "#4ECDC4"),
            HomeCategory_Base_one(id_Base_one: "living_room", name_Base_one: "Living Room", iconName_Base_one: "sofa.fill",             colorHex_Base_one: "#4ECDC4"),
            HomeCategory_Base_one(id_Base_one: "bedroom",     name_Base_one: "Bedroom",     iconName_Base_one: "bed.double.fill",       colorHex_Base_one: "#9F7AEA"),
            HomeCategory_Base_one(id_Base_one: "kitchen",     name_Base_one: "Kitchen",     iconName_Base_one: "fork.knife",            colorHex_Base_one: "#F6AD55"),
            HomeCategory_Base_one(id_Base_one: "bathroom",    name_Base_one: "Bathroom",    iconName_Base_one: "shower.fill",           colorHex_Base_one: "#63B3ED"),
            HomeCategory_Base_one(id_Base_one: "study",       name_Base_one: "Study",       iconName_Base_one: "books.vertical.fill",   colorHex_Base_one: "#68D391"),
            HomeCategory_Base_one(id_Base_one: "storage",     name_Base_one: "Storage",     iconName_Base_one: "archivebox.fill",       colorHex_Base_one: "#FC8181"),
            HomeCategory_Base_one(id_Base_one: "garden",      name_Base_one: "Garden",      iconName_Base_one: "leaf.fill",             colorHex_Base_one: "#48BB78"),
        ]
    }
    
    /// 按分类筛选帖子
    /// 参数：
    /// - category_base_one: 分类ID，传入 "all" 返回全部
    /// 返回值：筛选后的帖子数组
    func getPostsByCategory_Base_one(category_base_one: String) -> [TitleModel_Base_one] {
        guard category_base_one != "all" else { return posts_Base_one }
        return posts_Base_one.filter { $0.titleCategory_Base_one == category_base_one }
    }
    
    /// 关键词搜索帖子（标题 + 内容 + 作者名模糊匹配，不区分大小写）
    /// 参数：
    /// - keyword_base_one: 搜索关键词，为空时返回全部
    /// 返回值：匹配的帖子数组
    func searchPosts_Base_one(keyword_base_one: String) -> [TitleModel_Base_one] {
        let trimmed_base_one = keyword_base_one.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_base_one.isEmpty else { return posts_Base_one }
        let lower_base_one = trimmed_base_one.lowercased()
        return posts_Base_one.filter {
            $0.title_Base_one.lowercased().contains(lower_base_one)
            || $0.titleContent_Base_one.lowercased().contains(lower_base_one)
            || $0.titleUserName_Base_one.lowercased().contains(lower_base_one)
        }
    }
    
    /// 关键词 + 分类叠加过滤
    /// 参数：
    /// - keyword_base_one: 搜索关键词（空则忽略）
    /// - category_base_one: 分类ID（"all" 则忽略）
    /// 返回值：同时满足两个条件的帖子数组
    func filterPosts_Base_one(keyword_base_one: String, category_base_one: String) -> [TitleModel_Base_one] {
        var result_base_one = posts_Base_one
        
        // 按分类筛选
        if category_base_one != "all" {
            result_base_one = result_base_one.filter { $0.titleCategory_Base_one == category_base_one }
        }
        
        // 按关键词筛选
        let trimmed_base_one = keyword_base_one.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed_base_one.isEmpty {
            let lower_base_one = trimmed_base_one.lowercased()
            result_base_one = result_base_one.filter {
                $0.title_Base_one.lowercased().contains(lower_base_one)
                || $0.titleContent_Base_one.lowercased().contains(lower_base_one)
                || $0.titleUserName_Base_one.lowercased().contains(lower_base_one)
            }
        }
        
        return result_base_one
    }
    
    /// 获取精选帖子（点赞数最高的前 N 条，用于 Banner 展示）
    /// 参数：
    /// - count_base_one: 取前 N 条，默认 5
    /// 返回值：精选帖子数组
    func getFeaturedPosts_Base_one(count_base_one: Int = 5) -> [TitleModel_Base_one] {
        return Array(posts_Base_one.sorted { $0.likes_Base_one > $1.likes_Base_one }.prefix(count_base_one))
    }
    
    /// 获取首页统计信息（总帖子数、分类数、最高点赞数）
    /// 返回值：(帖子总数, 分类数, 最高点赞)
    func getHomeStats_Base_one() -> (Int, Int, Int) {
        let totalPosts_base_one = posts_Base_one.count
        let uniqueCategories_base_one = Set(posts_Base_one.map { $0.titleCategory_Base_one }).count
        let topLikes_base_one = posts_Base_one.map { $0.likes_Base_one }.max() ?? 0
        return (totalPosts_base_one, uniqueCategories_base_one, topLikes_base_one)
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Base_one() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
        }
    }
}

