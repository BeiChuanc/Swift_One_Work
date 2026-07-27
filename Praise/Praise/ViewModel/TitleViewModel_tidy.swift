import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
/// 功能：管理社区帖子的完整生命周期，包含发布、删除、点赞、评论、分类筛选与搜索
/// 设计思路：@MainActor 单例，通过 NotificationCenter 驱动 UI 响应式更新
@MainActor
class TitleViewModel_Tidy {
    
    /// 单例
    static let shared_Tidy = TitleViewModel_Tidy()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Tidy = Notification.Name("TitleStateDidChange_Tidy")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Tidy: [TitleModel_Tidy] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Tidy() -> [TitleModel_Tidy] {
        return posts_Tidy
    }
    
    /// 初始化帖子列表
    func initPosts_Tidy() {
        posts_Tidy = LocalData_Tidy.shared_Tidy.titleList_Tidy
        notifyStateChange_Tidy()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Tidy(user_tidy: PrewUserModel_Tidy, type_tidy: Int? = nil) -> [TitleModel_Tidy] {
        guard let userId_tidy = user_tidy.userId_Tidy else { return [] }
        
        var filteredPosts_tidy = posts_Tidy.filter { post in
            post.titleUserId_Tidy == userId_tidy
        }
        
        // 如果指定了类型，进一步筛选
        if type_tidy != nil {
            filteredPosts_tidy = filteredPosts_tidy.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_tidy
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Tidy(post_tidy: TitleModel_Tidy) -> Bool {
        return UserViewModel_Tidy.shared_Tidy.isLikedByCurrentUser_Tidy(post_tidy: post_tidy)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    /// - Parameters:
    ///   - title_tidy: 帖子标题
    ///   - content_tidy: 帖子内容
    ///   - media_tidy: 媒体文件路径
    ///   - category_tidy: 帖子所属家居分类ID（对应 HomeCategory_Tidy.id_Tidy，默认 "all"）
    func releasePost_Tidy(
        title_tidy: String,
        content_tidy: String,
        media_tidy: String,
        category_tidy: String = "all"
    ) {
        // 检查是否登录
        if !UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy {
            showLoginPrompt_Tidy()
            return
        }
        
        // 获取当前用户信息
        let currentUser_tidy = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
        
        let newPostId_tidy = posts_Tidy.count + 20 + 1
        
        let newPost_tidy = TitleModel_Tidy(
            titleId_Tidy: newPostId_tidy,
            titleUserId_Tidy: currentUser_tidy.userId_Tidy ?? 0,
            titleUserName_Tidy: currentUser_tidy.userName_Tidy ?? "User",
            titleMeidas_Tidy: [media_tidy],
            title_Tidy: title_tidy,
            titleContent_Tidy: content_tidy,
            reviews_Tidy: [],
            likes_Tidy: 0,
            titleCategory_Tidy: category_tidy
        )
        
        posts_Tidy.append(newPost_tidy)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Tidy.shared_Tidy.addPostToCurrentUser_Tidy(post_tidy: newPost_tidy)

        // 记录"发布帖子"每日任务进度
        TaskViewModel_Tidy.shared_Tidy.recordEvent_Tidy(type_tidy: .publishPost_tidy)
        
        Utils_Tidy.showSuccess_Tidy(
            message_Tidy: "Published successfully.",
            image_Tidy: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Tidy()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Tidy(post_tidy: TitleModel_Tidy, isDelete_tidy: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Tidy.shared_Tidy.removePostFromCurrentUser_Tidy(post_tidy: post_tidy)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Tidy.shared_Tidy.removeLikeFromCurrentUser_Tidy(post_tidy: post_tidy)
        
        // 从帖子列表中移除
        posts_Tidy.removeAll { $0.titleId_Tidy == post_tidy.titleId_Tidy }
        
        let message_tidy = isDelete_tidy
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Tidy.showSuccess_Tidy(
            message_Tidy: message_tidy,
            image_Tidy: UIImage(systemName: "trash.fill"),
            delay_Tidy: 1.5
        )
        
        notifyStateChange_Tidy()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Tidy(userId_tidy: Int) {
        posts_Tidy.removeAll { post in
            post.titleUserId_Tidy == userId_tidy
        }
        notifyStateChange_Tidy()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Tidy(post_tidy: TitleModel_Tidy, content_tidy: String) {
        // 检查是否登录
        if !UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy {
            showLoginPrompt_Tidy()
            return
        }
        
        // 获取当前用户信息
        let currentUser_tidy = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
        
        let newCommentId_tidy = post_tidy.reviews_Tidy.count + 1
        
        let newComment_tidy = Comment_Tidy(
            commentId_Tidy: newCommentId_tidy,
            commentUserId_Tidy: currentUser_tidy.userId_Tidy ?? 0,
            commentUserName_Tidy: currentUser_tidy.userName_Tidy ?? "User",
            commentContent_Tidy: content_tidy
        )
        
        // 找到对应的帖子并添加评论
        if let index_tidy = posts_Tidy.firstIndex(where: { $0.titleId_Tidy == post_tidy.titleId_Tidy }) {
            posts_Tidy[index_tidy].reviews_Tidy.append(newComment_tidy)
        }
        
        notifyStateChange_Tidy()
    }
    
    /// 删除评论
    func deleteComment_Tidy(
        post_tidy: TitleModel_Tidy,
        comment_tidy: Comment_Tidy,
        isDelete_tidy: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_tidy = posts_Tidy.firstIndex(where: { $0.titleId_Tidy == post_tidy.titleId_Tidy }) {
            posts_Tidy[index_tidy].reviews_Tidy.removeAll { comment in
                comment.commentId_Tidy == comment_tidy.commentId_Tidy
            }
        }
        
        let message_tidy = isDelete_tidy
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Tidy.showSuccess_Tidy(
            message_Tidy: message_tidy,
            delay_Tidy: 1.5
        )
        
        notifyStateChange_Tidy()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Tidy(post_tidy: TitleModel_Tidy) {
        // 检查是否登录
        if !UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy {
            showLoginPrompt_Tidy()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Tidy(post_tidy: post_tidy) {
            // 取消点赞
            UserViewModel_Tidy.shared_Tidy.removeLikeFromCurrentUser_Tidy(post_tidy: post_tidy)
            
            // 更新帖子的点赞数
            if let index_tidy = posts_Tidy.firstIndex(where: { $0.titleId_Tidy == post_tidy.titleId_Tidy }) {
                posts_Tidy[index_tidy].likes_Tidy = max(0, posts_Tidy[index_tidy].likes_Tidy - 1)
            }
        } else {
            // 点赞
            UserViewModel_Tidy.shared_Tidy.addLikeToCurrentUser_Tidy(post_tidy: post_tidy)
            
            // 更新帖子的点赞数
            if let index_tidy = posts_Tidy.firstIndex(where: { $0.titleId_Tidy == post_tidy.titleId_Tidy }) {
                posts_Tidy[index_tidy].likes_Tidy += 1
            }

            // 记录"点赞帖子"每日任务进度（仅点赞时记录，取消点赞不计入）
            TaskViewModel_Tidy.shared_Tidy.recordEvent_Tidy(type_tidy: .likePosts_tidy)
        }
        
        notifyStateChange_Tidy()
    }
    
    // MARK: - 公共方法 - 分类与搜索
    
    /// 获取所有拍照技巧分类列表（含"全部"选项）
    /// 返回值：HomeCategory_Tidy 数组
    func getCategories_Tidy() -> [HomeCategory_Tidy] {
        return [
            HomeCategory_Tidy(id_Tidy: "all",         name_Tidy: "All",         iconName_Tidy: "square.grid.2x2.fill",  colorHex_Tidy: "#5B8CFF"),
            HomeCategory_Tidy(id_Tidy: "living_room", name_Tidy: "Lighting",    iconName_Tidy: "sun.max.fill",          colorHex_Tidy: "#FFB547"),
            HomeCategory_Tidy(id_Tidy: "bedroom",     name_Tidy: "Pose",        iconName_Tidy: "figure.stand",          colorHex_Tidy: "#8B7CFF"),
            HomeCategory_Tidy(id_Tidy: "kitchen",     name_Tidy: "Composition", iconName_Tidy: "square.on.circle",      colorHex_Tidy: "#45C8FF"),
            HomeCategory_Tidy(id_Tidy: "bathroom",    name_Tidy: "Outfit",      iconName_Tidy: "tshirt.fill",           colorHex_Tidy: "#FF7A8A"),
            HomeCategory_Tidy(id_Tidy: "study",       name_Tidy: "Location",    iconName_Tidy: "map.fill",              colorHex_Tidy: "#35C58B"),
            HomeCategory_Tidy(id_Tidy: "storage",     name_Tidy: "Editing",     iconName_Tidy: "slider.horizontal.3",   colorHex_Tidy: "#FF5CA8"),
            HomeCategory_Tidy(id_Tidy: "garden",      name_Tidy: "Gear",        iconName_Tidy: "camera.fill",           colorHex_Tidy: "#4F6DFF"),
        ]
    }
    
    /// 按分类筛选帖子
    /// 参数：
    /// - category_tidy: 分类ID，传入 "all" 返回全部
    /// 返回值：筛选后的帖子数组
    func getPostsByCategory_Tidy(category_tidy: String) -> [TitleModel_Tidy] {
        guard category_tidy != "all" else { return posts_Tidy }
        return posts_Tidy.filter { $0.titleCategory_Tidy == category_tidy }
    }
    
    /// 关键词搜索帖子（标题 + 内容 + 作者名模糊匹配，不区分大小写）
    /// 参数：
    /// - keyword_tidy: 搜索关键词，为空时返回全部
    /// 返回值：匹配的帖子数组
    func searchPosts_Tidy(keyword_tidy: String) -> [TitleModel_Tidy] {
        let trimmed_tidy = keyword_tidy.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_tidy.isEmpty else { return posts_Tidy }
        let lower_tidy = trimmed_tidy.lowercased()
        return posts_Tidy.filter {
            $0.title_Tidy.lowercased().contains(lower_tidy)
            || $0.titleContent_Tidy.lowercased().contains(lower_tidy)
            || $0.titleUserName_Tidy.lowercased().contains(lower_tidy)
        }
    }
    
    /// 关键词 + 分类叠加过滤
    /// 参数：
    /// - keyword_tidy: 搜索关键词（空则忽略）
    /// - category_tidy: 分类ID（"all" 则忽略）
    /// 返回值：同时满足两个条件的帖子数组
    func filterPosts_Tidy(keyword_tidy: String, category_tidy: String) -> [TitleModel_Tidy] {
        var result_tidy = posts_Tidy
        
        // 按分类筛选
        if category_tidy != "all" {
            result_tidy = result_tidy.filter { $0.titleCategory_Tidy == category_tidy }
        }
        
        // 按关键词筛选
        let trimmed_tidy = keyword_tidy.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed_tidy.isEmpty {
            let lower_tidy = trimmed_tidy.lowercased()
            result_tidy = result_tidy.filter {
                $0.title_Tidy.lowercased().contains(lower_tidy)
                || $0.titleContent_Tidy.lowercased().contains(lower_tidy)
                || $0.titleUserName_Tidy.lowercased().contains(lower_tidy)
            }
        }
        
        return result_tidy
    }
    
    /// 获取精选帖子（点赞数最高的前 N 条，用于 Banner 展示）
    /// 参数：
    /// - count_tidy: 取前 N 条，默认 5
    /// 返回值：精选帖子数组
    func getFeaturedPosts_Tidy(count_tidy: Int = 5) -> [TitleModel_Tidy] {
        return Array(posts_Tidy.sorted { $0.likes_Tidy > $1.likes_Tidy }.prefix(count_tidy))
    }
    
    /// 获取首页统计信息（总帖子数、分类数、最高点赞数）
    /// 返回值：(帖子总数, 分类数, 最高点赞)
    func getHomeStats_Tidy() -> (Int, Int, Int) {
        let totalPosts_tidy = posts_Tidy.count
        let uniqueCategories_tidy = Set(posts_Tidy.map { $0.titleCategory_Tidy }).count
        let topLikes_tidy = posts_Tidy.map { $0.likes_Tidy }.max() ?? 0
        return (totalPosts_tidy, uniqueCategories_tidy, topLikes_tidy)
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Tidy() {
        NotificationCenter.default.post(
            name: TitleViewModel_Tidy.titleStateDidChangeNotification_Tidy,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Tidy() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Tidy.toLogin_Tidy(style_tidy: .present_tidy)
        }
    }
}

