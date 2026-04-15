import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Epoch {
    
    /// 单例
    static let shared_Epoch = TitleViewModel_Epoch()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Epoch = Notification.Name("TitleStateDidChange_Epoch")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Epoch: [TitleModel_Epoch] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Epoch() -> [TitleModel_Epoch] {
        return posts_Epoch
    }

    /// 获取首页贴纸墙帖子
    /// - Parameter limit_epoch: 返回数量上限
    /// - Returns: 适合首页贴纸墙展示的帖子列表
    func getHomeMomentPosts_Epoch(limit_epoch: Int) -> [TitleModel_Epoch] {
        guard limit_epoch > 0 else { return [] }
        let sortedPosts_epoch = posts_Epoch.sorted { left_epoch, right_epoch in
            if left_epoch.titleId_Epoch != right_epoch.titleId_Epoch {
                return left_epoch.titleId_Epoch > right_epoch.titleId_Epoch
            }
            return popularityScore_Epoch(post_epoch: left_epoch) > popularityScore_Epoch(post_epoch: right_epoch)
        }
        return Array(sortedPosts_epoch.prefix(limit_epoch))
    }

    /// 获取点赞最高的帖子
    /// - Parameter excludingTitleId_epoch: 需要排除的帖子ID
    /// - Returns: 点赞最高的帖子模型
    func getMostLikedPost_Epoch(excludingTitleId_epoch: Int? = nil) -> TitleModel_Epoch? {
        return posts_Epoch
            .filter { post_epoch in
                post_epoch.titleId_Epoch != excludingTitleId_epoch
            }
            .sorted { left_epoch, right_epoch in
                if left_epoch.likes_Epoch != right_epoch.likes_Epoch {
                    return left_epoch.likes_Epoch > right_epoch.likes_Epoch
                }
                return popularityScore_Epoch(post_epoch: left_epoch) > popularityScore_Epoch(post_epoch: right_epoch)
            }
            .first
    }

    /// 获取最受欢迎的帖子
    /// - Parameter excludingTitleId_epoch: 需要排除的帖子ID
    /// - Returns: 热度最高的帖子模型
    func getMostPopularPost_Epoch(excludingTitleId_epoch: Int? = nil) -> TitleModel_Epoch? {
        return posts_Epoch
            .filter { post_epoch in
                post_epoch.titleId_Epoch != excludingTitleId_epoch
            }
            .sorted { left_epoch, right_epoch in
                let leftScore_epoch = popularityScore_Epoch(post_epoch: left_epoch)
                let rightScore_epoch = popularityScore_Epoch(post_epoch: right_epoch)
                if leftScore_epoch != rightScore_epoch {
                    return leftScore_epoch > rightScore_epoch
                }
                return left_epoch.likes_Epoch > right_epoch.likes_Epoch
            }
            .first
    }

    /// 根据帖子ID获取帖子
    /// - Parameter titleId_epoch: 帖子ID
    /// - Returns: 帖子模型
    func getPost_Epoch(titleId_epoch: Int) -> TitleModel_Epoch? {
        return posts_Epoch.first { $0.titleId_Epoch == titleId_epoch }
    }
    
    /// 初始化帖子列表
    func initPosts_Epoch() {
        posts_Epoch = LocalData_Epoch.shared_Epoch.titleList_Epoch
        notifyStateChange_Epoch()
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Epoch(user_epoch: PrewUserModel_Epoch, type_epoch: Int? = nil) -> [TitleModel_Epoch] {
        guard let userId_epoch = user_epoch.userId_Epoch else { return [] }
        
        var filteredPosts_epoch = posts_Epoch.filter { post in
            post.titleUserId_Epoch == userId_epoch
        }
        
        // 如果指定了类型，进一步筛选
        if type_epoch != nil {
            filteredPosts_epoch = filteredPosts_epoch.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_epoch
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Epoch(post_epoch: TitleModel_Epoch) -> Bool {
        return UserViewModel_Epoch.shared_Epoch.isLikedByCurrentUser_Epoch(post_epoch: post_epoch)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Epoch(
        title_epoch: String,
        content_epoch: String,
        media_epoch: String,
        type_epoch: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Epoch.shared_Epoch.isLoggedIn_Epoch {
            showLoginPrompt_Epoch()
            return
        }
        
        // 获取当前用户信息
        let currentUser_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        
        let newPostId_epoch = posts_Epoch.count + 20 + 1
        
        let newPost_epoch = TitleModel_Epoch(
            titleId_Epoch: newPostId_epoch,
            titleUserId_Epoch: currentUser_epoch.userId_Epoch ?? 0,
            titleUserName_Epoch: currentUser_epoch.userName_Epoch ?? "User",
            titleMeidas_Epoch: [media_epoch],
            title_Epoch: title_epoch,
            titleContent_Epoch: content_epoch,
            reviews_Epoch: [],
            likes_Epoch: 0
        )
        
        posts_Epoch.insert(newPost_epoch, at: 0)
        LocalData_Epoch.shared_Epoch.titleList_Epoch.insert(newPost_epoch, at: 0)
        
        // 将帖子添加到用户的帖子列表
        UserViewModel_Epoch.shared_Epoch.addPostToCurrentUser_Epoch(post_epoch: newPost_epoch)
        
        Utils_Epoch.showSuccess_Epoch(
            message_Epoch: "Published successfully.",
            image_Epoch: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Epoch()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Epoch(post_epoch: TitleModel_Epoch, isDelete_epoch: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Epoch.shared_Epoch.removePostFromCurrentUser_Epoch(post_epoch: post_epoch)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Epoch.shared_Epoch.removeLikeFromCurrentUser_Epoch(post_epoch: post_epoch)
        
        // 从帖子列表中移除
        posts_Epoch.removeAll { $0.titleId_Epoch == post_epoch.titleId_Epoch }
        LocalData_Epoch.shared_Epoch.titleList_Epoch.removeAll { $0.titleId_Epoch == post_epoch.titleId_Epoch }
        
        let message_epoch = isDelete_epoch
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Epoch.showSuccess_Epoch(
            message_Epoch: message_epoch,
            image_Epoch: UIImage(systemName: "trash.fill"),
            delay_Epoch: 1.5
        )
        
        notifyStateChange_Epoch()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Epoch(userId_epoch: Int) {
        posts_Epoch.removeAll { post in
            post.titleUserId_Epoch == userId_epoch
        }
        LocalData_Epoch.shared_Epoch.titleList_Epoch.removeAll { $0.titleUserId_Epoch == userId_epoch }
        notifyStateChange_Epoch()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Epoch(post_epoch: TitleModel_Epoch, content_epoch: String) {
        // 检查是否登录
        if !UserViewModel_Epoch.shared_Epoch.isLoggedIn_Epoch {
            showLoginPrompt_Epoch()
            return
        }
        
        // 获取当前用户信息
        let currentUser_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        
        let newCommentId_epoch = post_epoch.reviews_Epoch.count + 1
        
        let newComment_epoch = Comment_Epoch(
            commentId_Epoch: newCommentId_epoch,
            commentUserId_Epoch: currentUser_epoch.userId_Epoch ?? 0,
            commentUserName_Epoch: currentUser_epoch.userName_Epoch ?? "User",
            commentContent_Epoch: content_epoch
        )
        
        // 找到对应的帖子并添加评论
        if let index_epoch = posts_Epoch.firstIndex(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
            posts_Epoch[index_epoch].reviews_Epoch.append(newComment_epoch)
        }
        
        notifyStateChange_Epoch()
    }
    
    /// 删除评论
    func deleteComment_Epoch(
        post_epoch: TitleModel_Epoch,
        comment_epoch: Comment_Epoch,
        isDelete_epoch: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_epoch = posts_Epoch.firstIndex(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
            posts_Epoch[index_epoch].reviews_Epoch.removeAll { comment in
                comment.commentId_Epoch == comment_epoch.commentId_Epoch
            }
        }
        
        let message_epoch = isDelete_epoch
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Epoch.showSuccess_Epoch(
            message_Epoch: message_epoch,
            delay_Epoch: 1.5
        )
        
        notifyStateChange_Epoch()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Epoch(post_epoch: TitleModel_Epoch) {
        // 检查是否登录
        if !UserViewModel_Epoch.shared_Epoch.isLoggedIn_Epoch {
            showLoginPrompt_Epoch()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Epoch(post_epoch: post_epoch) {
            // 取消点赞
            UserViewModel_Epoch.shared_Epoch.removeLikeFromCurrentUser_Epoch(post_epoch: post_epoch)
            
            // 更新帖子的点赞数
            if let index_epoch = posts_Epoch.firstIndex(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
                posts_Epoch[index_epoch].likes_Epoch = max(0, posts_Epoch[index_epoch].likes_Epoch - 1)
            }
        } else {
            // 点赞
            UserViewModel_Epoch.shared_Epoch.addLikeToCurrentUser_Epoch(post_epoch: post_epoch)
            
            // 更新帖子的点赞数
            if let index_epoch = posts_Epoch.firstIndex(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
                posts_Epoch[index_epoch].likes_Epoch += 1
            }
        }
        
        notifyStateChange_Epoch()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Epoch() {
        NotificationCenter.default.post(
            name: TitleViewModel_Epoch.titleStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    /// 计算帖子热度分数
    /// - Parameter post_epoch: 帖子模型
    /// - Returns: 综合点赞和评论后的热度值
    private func popularityScore_Epoch(post_epoch: TitleModel_Epoch) -> Int {
        return post_epoch.likes_Epoch * 3 + post_epoch.reviews_Epoch.count * 2
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Epoch() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Epoch.toLogin_Epoch(style_epoch: .present_epoch)
        }
    }
}

