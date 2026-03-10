import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Moode {
    
    /// 单例
    static let shared_Moode = TitleViewModel_Moode()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Moode = Notification.Name("TitleStateDidChange_Moode")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Moode: [TitleModel_Moode] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Moode() -> [TitleModel_Moode] {
        return posts_Moode
    }
    
    /// 初始化帖子列表（全量：普通帖子 + 情绪帖子）
    func initPosts_Moode() {
        posts_Moode = LocalData_Moode.shared_Moode.titleList_Moode
        notifyStateChange_Moode()
    }

    /// 获取情绪帖子列表（postType == .mood_moode，供首页情绪流使用）
    /// 返回值：仅包含情绪类型帖子的数组
    func getMoodPosts_Moode() -> [TitleModel_Moode] {
        return posts_Moode.filter { $0.postType_Moode == .mood_moode }
    }

    /// 获取普通帖子列表（postType == .normal_moode，供发现页瀑布流使用）
    /// 返回值：仅包含普通帖子的数组
    func getNormalPosts_Moode() -> [TitleModel_Moode] {
        return posts_Moode.filter { $0.postType_Moode == .normal_moode }
    }

    /// 在普通帖子中搜索（标题 / 正文 / 作者名，忽略大小写）
    /// - Parameter keyword_moode: 搜索关键词，为空时返回全部普通帖子
    /// 返回值：匹配关键词的普通帖子数组
    func searchNormalPosts_Moode(keyword_moode: String) -> [TitleModel_Moode] {
        let trimmed_moode = keyword_moode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_moode.isEmpty else { return getNormalPosts_Moode() }
        let lower_moode = trimmed_moode.lowercased()
        return getNormalPosts_Moode().filter {
            $0.title_Moode.lowercased().contains(lower_moode) ||
            $0.titleContent_Moode.lowercased().contains(lower_moode) ||
            $0.titleUserName_Moode.lowercased().contains(lower_moode)
        }
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Moode(user_moode: PrewUserModel_Moode, type_moode: Int? = nil) -> [TitleModel_Moode] {
        guard let userId_moode = user_moode.userId_Moode else { return [] }
        
        var filteredPosts_moode = posts_Moode.filter { post in
            post.titleUserId_Moode == userId_moode
        }
        
        // 如果指定了类型，进一步筛选
        if type_moode != nil {
            filteredPosts_moode = filteredPosts_moode.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_moode
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Moode(post_moode: TitleModel_Moode) -> Bool {
        return UserViewModel_Moode.shared_Moode.isLikedByCurrentUser_Moode(post_moode: post_moode)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Moode(
        title_moode: String,
        content_moode: String,
        media_moode: String,
        type_moode: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Moode.shared_Moode.isLoggedIn_Moode {
            showLoginPrompt_Moode()
            return
        }
        
        // 获取当前用户信息
        let currentUser_moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        
        let newPostId_moode = posts_Moode.count + 20 + 1
        
        let newPost_moode = TitleModel_Moode(
            titleId_Moode: newPostId_moode,
            titleUserId_Moode: currentUser_moode.userId_Moode ?? 0,
            titleUserName_Moode: currentUser_moode.userName_Moode ?? "User",
            titleMeidas_Moode: [media_moode],
            title_Moode: title_moode,
            titleContent_Moode: content_moode,
            reviews_Moode: [],
            likes_Moode: 0
        )
        
        posts_Moode.append(newPost_moode)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Moode.shared_Moode.addPostToCurrentUser_Moode(post_moode: newPost_moode)
        
        Utils_Moode.showSuccess_Moode(
            message_Moode: "Published successfully.",
            image_Moode: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Moode()
    }
    
    /// 发布帖子（带情绪类型，供发布页调用）
    /// - Parameter title_moode: 帖子标题
    /// - Parameter content_moode: 帖子内容
    /// - Parameter moodType_moode: 情绪类型，默认平静
    /// 发布帖子（带情绪类型和媒体路径，供发布页调用）
    /// 参数：
    /// - title_moode: 帖子标题
    /// - content_moode: 帖子内容
    /// - moodType_moode: 情绪类型，默认平静
    /// - mediaPaths_moode: 媒体文件路径数组（本地路径或资源名）
    func addPost_Moode(
        title_moode: String,
        content_moode: String,
        postType_moode: PostType_Moode = .normal_moode,
        moodType_moode: MoodType_Moode = .calm_moode,
        mediaPaths_moode: [String] = []
    ) {
        if !UserViewModel_Moode.shared_Moode.isLoggedIn_Moode {
            showLoginPrompt_Moode()
            return
        }

        let currentUser_moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        let newPostId_moode = posts_Moode.count + 20 + 1

        let newPost_moode = TitleModel_Moode(
            titleId_Moode: newPostId_moode,
            titleUserId_Moode: currentUser_moode.userId_Moode ?? 0,
            titleUserName_Moode: currentUser_moode.userName_Moode ?? "User",
            titleMeidas_Moode: mediaPaths_moode,
            title_Moode: title_moode,
            titleContent_Moode: content_moode,
            reviews_Moode: [],
            likes_Moode: 0,
            postType_Moode: postType_moode,
            moodType_Moode: moodType_moode
        )

        // 插入到列表最前端，新内容优先展示
        posts_Moode.insert(newPost_moode, at: 0)

        UserViewModel_Moode.shared_Moode.addPostToCurrentUser_Moode(post_moode: newPost_moode)

        Utils_Moode.showSuccess_Moode(
            message_Moode: "Mood note published!",
            image_Moode: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Moode()
    }

    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Moode(post_moode: TitleModel_Moode, isDelete_moode: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Moode.shared_Moode.removePostFromCurrentUser_Moode(post_moode: post_moode)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Moode.shared_Moode.removeLikeFromCurrentUser_Moode(post_moode: post_moode)
        
        // 从帖子列表中移除
        posts_Moode.removeAll { $0.titleId_Moode == post_moode.titleId_Moode }
        
        let message_moode = isDelete_moode
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Moode.showSuccess_Moode(
            message_Moode: message_moode,
            image_Moode: UIImage(systemName: "trash.fill"),
            delay_Moode: 1.5
        )
        
        notifyStateChange_Moode()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Moode(userId_moode: Int) {
        posts_Moode.removeAll { post in
            post.titleUserId_Moode == userId_moode
        }
        notifyStateChange_Moode()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Moode(post_moode: TitleModel_Moode, content_moode: String) {
        // 检查是否登录
        if !UserViewModel_Moode.shared_Moode.isLoggedIn_Moode {
            showLoginPrompt_Moode()
            return
        }
        
        // 获取当前用户信息
        let currentUser_moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        
        let newCommentId_moode = post_moode.reviews_Moode.count + 1
        
        let newComment_moode = Comment_Moode(
            commentId_Moode: newCommentId_moode,
            commentUserId_Moode: currentUser_moode.userId_Moode ?? 0,
            commentUserName_Moode: currentUser_moode.userName_Moode ?? "User",
            commentContent_Moode: content_moode
        )
        
        // 找到对应的帖子并添加评论
        if let index_moode = posts_Moode.firstIndex(where: { $0.titleId_Moode == post_moode.titleId_Moode }) {
            posts_Moode[index_moode].reviews_Moode.append(newComment_moode)
        }
        
        Utils_Moode.showSuccess_Moode(
            message_Moode: "Comment posted",
            image_Moode: UIImage(systemName: "bubble.left.fill")
        )
        
        notifyStateChange_Moode()
    }
    
    /// 删除评论
    func deleteComment_Moode(
        post_moode: TitleModel_Moode,
        comment_moode: Comment_Moode,
        isDelete_moode: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_moode = posts_Moode.firstIndex(where: { $0.titleId_Moode == post_moode.titleId_Moode }) {
            posts_Moode[index_moode].reviews_Moode.removeAll { comment in
                comment.commentId_Moode == comment_moode.commentId_Moode
            }
        }
        
        let message_moode = isDelete_moode
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Moode.showSuccess_Moode(
            message_Moode: message_moode,
            delay_Moode: 1.5
        )
        
        notifyStateChange_Moode()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Moode(post_moode: TitleModel_Moode) {
        // 检查是否登录
        if !UserViewModel_Moode.shared_Moode.isLoggedIn_Moode {
            showLoginPrompt_Moode()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Moode(post_moode: post_moode) {
            // 取消点赞
            UserViewModel_Moode.shared_Moode.removeLikeFromCurrentUser_Moode(post_moode: post_moode)
            
            // 更新帖子的点赞数
            if let index_moode = posts_Moode.firstIndex(where: { $0.titleId_Moode == post_moode.titleId_Moode }) {
                posts_Moode[index_moode].likes_Moode = max(0, posts_Moode[index_moode].likes_Moode - 1)
            }
        } else {
            // 点赞
            UserViewModel_Moode.shared_Moode.addLikeToCurrentUser_Moode(post_moode: post_moode)
            
            // 更新帖子的点赞数
            if let index_moode = posts_Moode.firstIndex(where: { $0.titleId_Moode == post_moode.titleId_Moode }) {
                posts_Moode[index_moode].likes_Moode += 1
            }
        }
        
        notifyStateChange_Moode()
    }
    
    // MARK: - 公共方法 - 筛选与搜索
    
    /// 按情绪类型筛选帖子列表
    /// 功能：从全量帖子中过滤出指定情绪类型的帖子，nil 则返回全部
    /// 参数：
    /// - moodType_moode: 情绪类型枚举，nil 时返回全部帖子
    /// 返回值：符合条件的帖子数组
    /// 在情绪帖子中按情绪类型筛选（nil 返回全部情绪帖子）
    /// 参数：
    /// - moodType_moode: 情绪类型枚举，nil 时返回全部情绪帖子
    /// 返回值：符合情绪类型的情绪帖子数组
    func getFilteredPosts_Moode(moodType_moode: MoodType_Moode?) -> [TitleModel_Moode] {
        let moodPosts_moode = getMoodPosts_Moode()
        guard let mood_moode = moodType_moode else {
            return moodPosts_moode
        }
        return moodPosts_moode.filter { $0.moodType_Moode == mood_moode }
    }
    
    /// 关键词搜索帖子
    /// 功能：在帖子标题、内容和作者名中搜索包含关键词的帖子，忽略大小写
    /// 参数：
    /// - keyword_moode: 搜索关键词，空字符串时返回全部帖子
    /// 返回值：匹配关键词的帖子数组
    func searchPosts_Moode(keyword_moode: String) -> [TitleModel_Moode] {
        let trimmed_moode = keyword_moode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_moode.isEmpty else { return posts_Moode }
        let lowercased_moode = trimmed_moode.lowercased()
        return posts_Moode.filter {
            $0.title_Moode.lowercased().contains(lowercased_moode) ||
            $0.titleContent_Moode.lowercased().contains(lowercased_moode) ||
            $0.titleUserName_Moode.lowercased().contains(lowercased_moode)
        }
    }
    
    /// 获取按点赞数降序排列的热门帖子
    /// 功能：返回全部帖子按 likes 倒序排列的副本，用于发现页 Trending/Popular 模块
    /// 返回值：按点赞数降序的帖子数组
    func getPopularPosts_Moode() -> [TitleModel_Moode] {
        return posts_Moode.sorted { $0.likes_Moode > $1.likes_Moode }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Moode() {
        NotificationCenter.default.post(
            name: TitleViewModel_Moode.titleStateDidChangeNotification_Moode,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Moode() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Navigation_Moode.toLogin_Moode(style_moode: .present_moode)
        }
    }
}

