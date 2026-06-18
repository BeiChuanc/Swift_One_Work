import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
@MainActor
class TitleViewModel_Sylva {
    
    /// 单例
    static let shared_Sylva = TitleViewModel_Sylva()
    
    // MARK: - 通知名称
    
    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Sylva = Notification.Name("TitleStateDidChange_Sylva")
    
    // MARK: - 私有属性
    
    /// 帖子列表
    private var posts_Sylva: [TitleModel_Sylva] = []
    
    private init() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取帖子列表
    func getPosts_Sylva() -> [TitleModel_Sylva] {
        return posts_Sylva
    }
    
    /// 初始化帖子列表
    func initPosts_Sylva() {
        posts_Sylva = LocalData_Sylva.shared_Sylva.titleList_Sylva
        notifyStateChange_Sylva()
    }
    
    /// 按关键词过滤帖子列表（多关键词逗号分隔，匹配标题或内容）
    /// - Parameter keyword_sylva: 搜索关键词字符串，多词用逗号分隔；空字符串返回全部
    /// - Returns: 匹配的帖子数组
    func getFilteredPosts_Sylva(keyword_sylva: String) -> [TitleModel_Sylva] {
        guard !keyword_sylva.isEmpty else { return posts_Sylva }
        let keywords_sylva = keyword_sylva.lowercased().components(separatedBy: ",")
        return posts_Sylva.filter { post_sylva in
            let combined_sylva = "\(post_sylva.title_Sylva) \(post_sylva.titleContent_Sylva)".lowercased()
            return keywords_sylva.contains { combined_sylva.contains($0.trimmingCharacters(in: .whitespaces)) }
        }
    }
    
    /// 获取指定用户的帖子列表（按类型筛选）
    func getUserPosts_Sylva(user_sylva: PrewUserModel_Sylva, type_sylva: Int? = nil) -> [TitleModel_Sylva] {
        guard let userId_sylva = user_sylva.userId_Sylva else { return [] }
        
        var filteredPosts_sylva = posts_Sylva.filter { post in
            post.titleUserId_Sylva == userId_sylva
        }
        
        // 如果指定了类型，进一步筛选
        if type_sylva != nil {
            filteredPosts_sylva = filteredPosts_sylva.filter { post in
                // 暂时返回所有该用户的帖子
                return true
            }
        }
        
        return filteredPosts_sylva
    }
    
    /// 判断是否喜欢指定帖子
    func isLikedPost_Sylva(post_sylva: TitleModel_Sylva) -> Bool {
        return UserViewModel_Sylva.shared_Sylva.isLikedByCurrentUser_Sylva(post_sylva: post_sylva)
    }
    
    // MARK: - 公共方法 - 发布帖子
    
    /// 发布帖子
    func releasePost_Sylva(
        title_sylva: String,
        content_sylva: String,
        media_sylva: String,
        type_sylva: Int = 0
    ) {
        // 检查是否登录
        if !UserViewModel_Sylva.shared_Sylva.isLoggedIn_Sylva {
            showLoginPrompt_Sylva()
            return
        }
        
        // 获取当前用户信息
        let currentUser_sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        
        let newPostId_sylva = posts_Sylva.count + 20 + 1
        
        let newPost_sylva = TitleModel_Sylva(
            titleId_Sylva: newPostId_sylva,
            titleUserId_Sylva: currentUser_sylva.userId_Sylva ?? 0,
            titleUserName_Sylva: currentUser_sylva.userName_Sylva ?? "User",
            titleMeidas_Sylva: [media_sylva],
            title_Sylva: title_sylva,
            titleContent_Sylva: content_sylva,
            reviews_Sylva: [],
            likes_Sylva: 0
        )
        
        posts_Sylva.append(newPost_sylva)

        // 将帖子添加到用户的帖子列表
        UserViewModel_Sylva.shared_Sylva.addPostToCurrentUser_Sylva(post_sylva: newPost_sylva)
        // 任务进度：发布帖子
        UserViewModel_Sylva.shared_Sylva.progressTask_Sylva(type_sylva: .publishPost_Sylva)

        Utils_Sylva.showSuccess_Sylva(
            message_Sylva: "Published successfully.",
            image_Sylva: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Sylva()
    }
    
    // MARK: - 公共方法 - 删除帖子
    
    /// 删除帖子
    func deletePost_Sylva(post_sylva: TitleModel_Sylva, isDelete_sylva: Bool = false) {
        // 从用户的帖子列表中移除
        UserViewModel_Sylva.shared_Sylva.removePostFromCurrentUser_Sylva(post_sylva: post_sylva)
        
        // 从用户的喜欢列表中移除
        UserViewModel_Sylva.shared_Sylva.removeLikeFromCurrentUser_Sylva(post_sylva: post_sylva)
        
        // 从帖子列表中移除
        posts_Sylva.removeAll { $0.titleId_Sylva == post_sylva.titleId_Sylva }
        
        let message_sylva = isDelete_sylva
            ? "Deleted successfully."
            : "This post will no longer appear."
        
        Utils_Sylva.showSuccess_Sylva(
            message_Sylva: message_sylva,
            image_Sylva: UIImage(systemName: "trash.fill"),
            delay_Sylva: 1.5
        )
        
        notifyStateChange_Sylva()
    }
    
    /// 删除指定用户的所有帖子
    func deleteUserPosts_Sylva(userId_sylva: Int) {
        posts_Sylva.removeAll { post in
            post.titleUserId_Sylva == userId_sylva
        }
        notifyStateChange_Sylva()
    }
    
    // MARK: - 公共方法 - 评论管理
    
    /// 发布评论
    func releaseComment_Sylva(post_sylva: TitleModel_Sylva, content_sylva: String) {
        // 检查是否登录
        if !UserViewModel_Sylva.shared_Sylva.isLoggedIn_Sylva {
            showLoginPrompt_Sylva()
            return
        }
        
        // 获取当前用户信息
        let currentUser_sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        
        let newCommentId_sylva = post_sylva.reviews_Sylva.count + 1
        
        let newComment_sylva = Comment_Sylva(
            commentId_Sylva: newCommentId_sylva,
            commentUserId_Sylva: currentUser_sylva.userId_Sylva ?? 0,
            commentUserName_Sylva: currentUser_sylva.userName_Sylva ?? "User",
            commentContent_Sylva: content_sylva
        )
        
        // 找到对应的帖子并添加评论
        if let index_sylva = posts_Sylva.firstIndex(where: { $0.titleId_Sylva == post_sylva.titleId_Sylva }) {
            posts_Sylva[index_sylva].reviews_Sylva.append(newComment_sylva)
        }
        // 任务进度：评论帖子
        UserViewModel_Sylva.shared_Sylva.progressTask_Sylva(type_sylva: .commentPost_Sylva)

        notifyStateChange_Sylva()
    }

    /// 删除评论
    func deleteComment_Sylva(
        post_sylva: TitleModel_Sylva,
        comment_sylva: Comment_Sylva,
        isDelete_sylva: Bool = false
    ) {
        // 找到对应的帖子并删除评论
        if let index_sylva = posts_Sylva.firstIndex(where: { $0.titleId_Sylva == post_sylva.titleId_Sylva }) {
            posts_Sylva[index_sylva].reviews_Sylva.removeAll { comment in
                comment.commentId_Sylva == comment_sylva.commentId_Sylva
            }
        }
        
        let message_sylva = isDelete_sylva
            ? "Deleted successfully."
            : "This comment will no longer appear."
        
        Utils_Sylva.showSuccess_Sylva(
            message_Sylva: message_sylva,
            delay_Sylva: 1.5
        )
        
        notifyStateChange_Sylva()
    }
    
    // MARK: - 公共方法 - 点赞管理
    
    /// 点赞/取消点赞帖子
    func likePost_Sylva(post_sylva: TitleModel_Sylva) {
        // 检查是否登录
        if !UserViewModel_Sylva.shared_Sylva.isLoggedIn_Sylva {
            showLoginPrompt_Sylva()
            return
        }
        
        // 判断是否已点赞
        if isLikedPost_Sylva(post_sylva: post_sylva) {
            // 取消点赞
            UserViewModel_Sylva.shared_Sylva.removeLikeFromCurrentUser_Sylva(post_sylva: post_sylva)
            
            // 更新帖子的点赞数
            if let index_sylva = posts_Sylva.firstIndex(where: { $0.titleId_Sylva == post_sylva.titleId_Sylva }) {
                posts_Sylva[index_sylva].likes_Sylva = max(0, posts_Sylva[index_sylva].likes_Sylva - 1)
            }
        } else {
            // 点赞
            UserViewModel_Sylva.shared_Sylva.addLikeToCurrentUser_Sylva(post_sylva: post_sylva)

            // 更新帖子的点赞数
            if let index_sylva = posts_Sylva.firstIndex(where: { $0.titleId_Sylva == post_sylva.titleId_Sylva }) {
                posts_Sylva[index_sylva].likes_Sylva += 1
            }
            // 任务进度：点赞帖子
            UserViewModel_Sylva.shared_Sylva.progressTask_Sylva(type_sylva: .likePost_Sylva)
        }

        notifyStateChange_Sylva()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Sylva() {
        NotificationCenter.default.post(
            name: TitleViewModel_Sylva.titleStateDidChangeNotification_Sylva,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Sylva() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Sylva.toLogin_Sylva(style_sylva: .present_sylva)
        }
    }
}

