import Foundation
import UIKit

// MARK: 首页内容分类枚举

/// 首页内容分类过滤枚举
/// 功能：控制首页帖子列表的筛选方式
enum HomeFilter_Pane {
    /// 全部帖子
    case all_pane
    /// 仅显示关注用户的帖子（需登录）
    case following_pane
    /// 按点赞数降序排列的热门帖子
    case hot_pane
    /// 最新发布的帖子（倒序）
    case new_pane
}

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Pane {
    
    /// 单例
    static let shared_Pane = TitleViewModel_Pane()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Pane = Notification.Name("TitleStateDidChange_Pane")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Pane: [TitleModel_Pane] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Pane() -> [TitleModel_Pane] {
        return posts_Pane
    }
    
    /// 初始化帖子列表
    func initPosts_Pane() {
        posts_Pane = LocalData_Pane.shared_Pane.titleList_Pane
        notifyStateChange_Pane()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Pane(user_pane: PrewUserModel_Pane, type_pane: Int? = nil) -> [TitleModel_Pane] {
        guard let userId_pane = user_pane.userId_Pane else { return [] }
        
        var filteredPosts_pane = posts_Pane.filter { post in
            post.titleUserId_Pane == userId_pane
        }
        
        // 如果指定了类型，进一步筛选
        if type_pane != nil {
            filteredPosts_pane = filteredPosts_pane.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_pane
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Pane(post_pane: TitleModel_Pane) -> Bool {
        return UserViewModel_Pane.shared_Pane.isLikedByCurrentUser_Pane(post_pane: post_pane)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子（支持主题类型标签）
    /// - Parameters:
    ///   - title_pane: 标题
    ///   - content_pane: 内容描述
    ///   - media_pane: 媒体资源名
    ///   - theme_pane: 窗景主题标签（可选）
    ///   - type_pane: 帖子类型（保留参数）
    func releasePost_Pane(
        title_pane: String,
        content_pane: String,
        media_pane: String,
        theme_pane: String = "",
        type_pane: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Pane.shared_Pane.isLoggedIn_Pane {
            showLoginPrompt_Pane()
            return
        }
        
        // 获取当前用户信息
        let currentUser_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
        
        let newPostId_pane = posts_Pane.count + 20 + 1
        
        let newPost_pane = TitleModel_Pane(
            titleId_Pane: newPostId_pane,
            titleUserId_Pane: currentUser_pane.userId_Pane ?? 0,
            titleUserName_Pane: currentUser_pane.userName_Pane ?? "User",
            titleMeidas_Pane: [media_pane],
            title_Pane: title_pane,
            titleContent_Pane: content_pane,
            reviews_Pane: [],
            likes_Pane: 0,
            titleTheme_Pane: theme_pane
        )
        
        posts_Pane.append(newPost_pane)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Pane.shared_Pane.addPostToCurrentUser_Pane(post_pane: newPost_pane)
        
        Utils_Pane.showSuccess_Pane(
            message_Pane: "Published successfully.",
            image_Pane: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Pane()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Pane(post_pane: TitleModel_Pane, isDelete_pane: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Pane.shared_Pane.removePostFromCurrentUser_Pane(post_pane: post_pane)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Pane.shared_Pane.removeLikeFromCurrentUser_Pane(post_pane: post_pane)
        
        // 从帖子列表中移除
        posts_Pane.removeAll { $0.titleId_Pane == post_pane.titleId_Pane }
        
        let message_pane = isDelete_pane
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Pane.showSuccess_Pane(
            message_Pane: message_pane,
            image_Pane: UIImage(systemName: "trash.fill"),
            delay_Pane: 1.5
        )
        
        notifyStateChange_Pane()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Pane(userId_pane: Int) {
        posts_Pane.removeAll { post in
            post.titleUserId_Pane == userId_pane
        }
        notifyStateChange_Pane()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Pane(post_pane: TitleModel_Pane, content_pane: String) {
        // 检查是否登录
        if !UserViewModel_Pane.shared_Pane.isLoggedIn_Pane {
            showLoginPrompt_Pane()
            return
        }
        
        // 获取当前用户信息
        let currentUser_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
        
        let newCommentId_pane = post_pane.reviews_Pane.count + 1
        
        let newComment_pane = Comment_Pane(
            commentId_Pane: newCommentId_pane,
            commentUserId_Pane: currentUser_pane.userId_Pane ?? 0,
            commentUserName_Pane: currentUser_pane.userName_Pane ?? "User",
            commentContent_Pane: content_pane
        )
        
        // 找到对应的帖子并添加评论
        if let index_pane = posts_Pane.firstIndex(where: { $0.titleId_Pane == post_pane.titleId_Pane }) {
            posts_Pane[index_pane].reviews_Pane.append(newComment_pane)
        }
        
        Utils_Pane.showSuccess_Pane(
            message_Pane: "Comment posted",
            image_Pane: UIImage(systemName: "bubble.left.fill")
        )
        
        notifyStateChange_Pane()
    }
    
    /// 删除评论
    func deleteComment_Pane(
        post_pane: TitleModel_Pane,
        comment_pane: Comment_Pane,
        isDelete_pane: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_pane = posts_Pane.firstIndex(where: { $0.titleId_Pane == post_pane.titleId_Pane }) {
            posts_Pane[index_pane].reviews_Pane.removeAll { comment in
                comment.commentId_Pane == comment_pane.commentId_Pane
            }
        }
        
        let message_pane = isDelete_pane
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Pane.showSuccess_Pane(
            message_Pane: message_pane,
            delay_Pane: 1.5
        )
        
        notifyStateChange_Pane()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Pane(post_pane: TitleModel_Pane) {
        // 检查是否登录
        if !UserViewModel_Pane.shared_Pane.isLoggedIn_Pane {
            showLoginPrompt_Pane()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Pane(post_pane: post_pane) {
            // 取消点赞
            UserViewModel_Pane.shared_Pane.removeLikeFromCurrentUser_Pane(post_pane: post_pane)
            
            // 更新帖子的点赞数
            if let index_pane = posts_Pane.firstIndex(where: { $0.titleId_Pane == post_pane.titleId_Pane }) {
                posts_Pane[index_pane].likes_Pane = max(0, posts_Pane[index_pane].likes_Pane - 1)
            }
        } else {
            // 点赞
            UserViewModel_Pane.shared_Pane.addLikeToCurrentUser_Pane(post_pane: post_pane)
            
            // 更新帖子的点赞数
            if let index_pane = posts_Pane.firstIndex(where: { $0.titleId_Pane == post_pane.titleId_Pane }) {
                posts_Pane[index_pane].likes_Pane += 1
            }
        }
        
        notifyStateChange_Pane()
    }
    
    // MARK: - 公共方法 - 筛选与搜索
    
    /// 按分类获取首页帖子列表
    /// - Parameter filter_pane: 分类过滤枚举（all/following/hot/new）
    /// - Returns: 过滤后的帖子数组；following 分类在未登录时降级为 all
    func getFilteredPosts_Pane(filter_pane: HomeFilter_Pane) -> [TitleModel_Pane] {
        switch filter_pane {
        case .all_pane:
            return posts_Pane

        case .following_pane:
            // 未登录时返回全部
            guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
                return posts_Pane
            }
            let followedUsers_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane().userFollow_Pane
            let followedIds_pane = Set(followedUsers_pane.compactMap { $0.userId_Pane })
            let result_pane = posts_Pane.filter { followedIds_pane.contains($0.titleUserId_Pane) }
            // 若关注列表为空则返回全部
            return result_pane.isEmpty ? posts_Pane : result_pane

        case .hot_pane:
            return posts_Pane.sorted { $0.likes_Pane > $1.likes_Pane }

        case .new_pane:
            return posts_Pane.reversed()
        }
    }

    /// 获取热门帖子（发现页使用，按点赞数降序取前 N 条）
    /// - Parameter limit_pane: 返回条数上限，默认 10
    /// - Returns: 按点赞数降序排列的帖子数组
    func getTrendingPosts_Pane(limit_pane: Int = 10) -> [TitleModel_Pane] {
        return Array(posts_Pane.sorted { $0.likes_Pane > $1.likes_Pane }.prefix(limit_pane))
    }

    /// 按关键词搜索帖子（标题或内容模糊匹配）
    /// - Parameter keyword_pane: 搜索关键词，为空时返回全部
    /// - Returns: 匹配的帖子数组
    func searchPosts_Pane(keyword_pane: String) -> [TitleModel_Pane] {
        let kw_pane = keyword_pane.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !kw_pane.isEmpty else { return posts_Pane }
        let lower_pane = kw_pane.lowercased()
        return posts_Pane.filter {
            $0.title_Pane.lowercased().contains(lower_pane) ||
            $0.titleContent_Pane.lowercased().contains(lower_pane) ||
            $0.titleUserName_Pane.lowercased().contains(lower_pane)
        }
    }

    // MARK: - 公共方法 - 月度日历数据
    
    /// 获取指定年月内当前用户（或全部帖子）按天的发帖数量
    /// - Parameters:
    ///   - year_pane: 年份（如 2026）
    ///   - month_pane: 月份（1～12）
    /// - Returns: 字典，键为日（1～31），值为当天帖子数量
    func getCalendarData_Pane(year_pane: Int, month_pane: Int) -> [Int: Int] {
        let f_pane = DateFormatter()
        f_pane.dateFormat = "yyyy-MM-dd"
        
        // 已登录则只统计当前用户的帖子
        let targetPosts_pane: [TitleModel_Pane]
        if UserViewModel_Pane.shared_Pane.isLoggedIn_Pane {
            let uid_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane().userId_Pane ?? -1
            targetPosts_pane = posts_Pane.filter { $0.titleUserId_Pane == uid_pane }
        } else {
            targetPosts_pane = posts_Pane
        }
        
        var result_pane: [Int: Int] = [:]
        for post_pane in targetPosts_pane {
            guard let date_pane = f_pane.date(from: post_pane.titleDate_Pane) else { continue }
            let comps_pane = Calendar.current.dateComponents([.year, .month, .day], from: date_pane)
            guard comps_pane.year == year_pane,
                  comps_pane.month == month_pane,
                  let day_pane = comps_pane.day else { continue }
            result_pane[day_pane, default: 0] += 1
        }
        return result_pane
    }
    
    // MARK: - 公共方法 - 窗景册管理
    
    /// 获取当前用户窗景册在 UserDefaults 中的存储 Key
    private func albumStorageKey_Pane() -> String {
        let uid_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane().userId_Pane ?? 0
        return "pane_albums_\(uid_pane)"
    }
    
    /// 读取当前用户的窗景册列表
    /// 优先从登录用户模型字段读取，模型为空时回退到 UserDefaults 备份
    /// - Returns: 窗景册数组；未登录时返回空
    func getUserAlbums_Pane() -> [WindowAlbum_Pane] {
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else { return [] }
        let modelAlbums_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane().userWindowAlbums_Pane
        if !modelAlbums_pane.isEmpty { return modelAlbums_pane }
        // 回退到 UserDefaults 备份
        guard let data_pane = UserDefaults.standard.data(forKey: albumStorageKey_Pane()),
              let albums_pane = try? JSONDecoder().decode([WindowAlbum_Pane].self, from: data_pane)
        else { return [] }
        return albums_pane
    }

    /// 将窗景册列表同步到用户模型字段和 UserDefaults 备份
    /// - Parameter albums_pane: 待保存的窗景册数组
    private func saveAlbums_Pane(albums_pane: [WindowAlbum_Pane]) {
        // 同步写入用户模型
        UserViewModel_Pane.shared_Pane.updateAlbumsInModel_Pane(albums_pane: albums_pane)
        // UserDefaults 备份
        if let data_pane = try? JSONEncoder().encode(albums_pane) {
            UserDefaults.standard.set(data_pane, forKey: albumStorageKey_Pane())
        }
    }
    
    /// 创建新窗景册
    /// - Parameters:
    ///   - name_pane: 相册名称
    ///   - emoji_pane: 封面 Emoji
    ///   - desc_pane: 相册描述
    /// - Returns: 创建成功的窗景册对象；未登录时返回 nil
    @discardableResult
    func createAlbum_Pane(name_pane: String,
                          emoji_pane: String = "🪟",
                          desc_pane: String = "") -> WindowAlbum_Pane? {
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
            showLoginPrompt_Pane()
            return nil
        }
        let album_pane = WindowAlbum_Pane(
            albumName_pane: name_pane,
            albumEmoji_pane: emoji_pane,
            albumDesc_pane: desc_pane
        )
        var albums_pane = getUserAlbums_Pane()
        albums_pane.append(album_pane)
        saveAlbums_Pane(albums_pane: albums_pane)
        notifyStateChange_Pane()
        return album_pane
    }
    
    /// 删除指定窗景册
    /// - Parameter albumId_pane: 目标相册 ID
    func deleteAlbum_Pane(albumId_pane: String) {
        var albums_pane = getUserAlbums_Pane()
        albums_pane.removeAll { $0.albumId_Pane == albumId_pane }
        saveAlbums_Pane(albums_pane: albums_pane)
        notifyStateChange_Pane()
    }
    
    /// 向窗景册添加帖子
    /// - Parameters:
    ///   - postId_pane: 帖子 ID
    ///   - albumId_pane: 目标相册 ID
    func addPostToAlbum_Pane(postId_pane: Int, albumId_pane: String) {
        var albums_pane = getUserAlbums_Pane()
        guard let idx_pane = albums_pane.firstIndex(where: { $0.albumId_Pane == albumId_pane })
        else { return }
        if !albums_pane[idx_pane].postIds_Pane.contains(postId_pane) {
            albums_pane[idx_pane].postIds_Pane.append(postId_pane)
            saveAlbums_Pane(albums_pane: albums_pane)
            notifyStateChange_Pane()
        }
    }
    
    /// 向窗景册添加本地图片路径（图片文件名，保存在 Documents 目录）
    /// - Parameters:
    ///   - imagePath_pane: 图片文件名（Documents 目录相对路径）
    ///   - albumId_pane: 目标相册 ID
    func addImageToAlbum_Pane(imagePath_pane: String, albumId_pane: String) {
        var albums_pane = getUserAlbums_Pane()
        guard let idx_pane = albums_pane.firstIndex(where: { $0.albumId_Pane == albumId_pane })
        else { return }
        var paths_pane = albums_pane[idx_pane].imagePaths_Pane ?? []
        guard !paths_pane.contains(imagePath_pane) else { return }
        paths_pane.append(imagePath_pane)
        albums_pane[idx_pane].imagePaths_Pane = paths_pane
        saveAlbums_Pane(albums_pane: albums_pane)
        notifyStateChange_Pane()
    }

    /// 从窗景册移除本地图片路径
    /// - Parameters:
    ///   - imagePath_pane: 图片文件名
    ///   - albumId_pane: 目标相册 ID
    func removeImageFromAlbum_Pane(imagePath_pane: String, albumId_pane: String) {
        var albums_pane = getUserAlbums_Pane()
        guard let idx_pane = albums_pane.firstIndex(where: { $0.albumId_Pane == albumId_pane })
        else { return }
        var paths_pane = albums_pane[idx_pane].imagePaths_Pane ?? []
        paths_pane.removeAll { $0 == imagePath_pane }
        albums_pane[idx_pane].imagePaths_Pane = paths_pane
        saveAlbums_Pane(albums_pane: albums_pane)
        notifyStateChange_Pane()
    }

    /// 从窗景册移除帖子
    /// - Parameters:
    ///   - postId_pane: 帖子 ID
    ///   - albumId_pane: 目标相册 ID
    func removePostFromAlbum_Pane(postId_pane: Int, albumId_pane: String) {
        var albums_pane = getUserAlbums_Pane()
        guard let idx_pane = albums_pane.firstIndex(where: { $0.albumId_Pane == albumId_pane })
        else { return }
        albums_pane[idx_pane].postIds_Pane.removeAll { $0 == postId_pane }
        saveAlbums_Pane(albums_pane: albums_pane)
        notifyStateChange_Pane()
    }
    
    /// 获取指定窗景册内的帖子列表
    /// - Parameter albumId_pane: 相册 ID
    /// - Returns: 属于该相册的帖子数组
    func getAlbumPosts_Pane(albumId_pane: String) -> [TitleModel_Pane] {
        guard let album_pane = getUserAlbums_Pane()
            .first(where: { $0.albumId_Pane == albumId_pane })
        else { return [] }
        return posts_Pane.filter { album_pane.postIds_Pane.contains($0.titleId_Pane) }
    }
    
    /// 根据 ID 列表批量获取帖子
    /// - Parameter ids_pane: 帖子 ID 数组
    /// - Returns: 对应帖子数组
    func getPostsByIds_Pane(ids_pane: [Int]) -> [TitleModel_Pane] {
        let idSet_pane = Set(ids_pane)
        return posts_Pane.filter { idSet_pane.contains($0.titleId_Pane) }
    }
    
    // MARK: - 公共方法 - 按日期查询

    /// 获取指定年月日当天的帖子列表（仅当前用户，用于日历弹窗）
    /// - Parameters:
    ///   - year_pane: 年份
    ///   - month_pane: 月份（1-12）
    ///   - day_pane: 日（1-31）
    /// - Returns: 该日发布的帖子数组
    func getPostsByDay_Pane(year_pane: Int, month_pane: Int, day_pane: Int) -> [TitleModel_Pane] {
        let f_pane = DateFormatter()
        f_pane.dateFormat = "yyyy-MM-dd"
        var comps_pane = DateComponents()
        comps_pane.year  = year_pane
        comps_pane.month = month_pane
        comps_pane.day   = day_pane
        guard let targetDate_pane = Calendar.current.date(from: comps_pane) else { return [] }
        let targetStr_pane = f_pane.string(from: targetDate_pane)
        // 已登录则只返回当前用户帖子，否则返回全量
        let source_pane: [TitleModel_Pane]
        if UserViewModel_Pane.shared_Pane.isLoggedIn_Pane {
            let uid_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane().userId_Pane ?? -1
            source_pane  = posts_Pane.filter { $0.titleUserId_Pane == uid_pane }
        } else {
            source_pane = posts_Pane
        }
        return source_pane.filter { $0.titleDate_Pane == targetStr_pane }
    }

    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Pane() {
        NotificationCenter.default.post(
            name: TitleViewModel_Pane.titleStateDidChangeNotification_Pane,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Pane() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Pane.toLogin_Pane(style_pane: .present_pane)
        }
    }
}

