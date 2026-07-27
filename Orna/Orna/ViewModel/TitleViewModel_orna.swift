import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
/// 功能：管理帖子、评论和点赞的增删改查
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class TitleViewModel_Orna {

    /// 单例
    static let shared_Orna = TitleViewModel_Orna()

    // MARK: - 通知名称

    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Orna = Notification.Name("TitleStateDidChange_Orna")

    // MARK: - 私有属性

    /// 帖子列表
    private var posts_Orna: [TitleModel_Orna] = []

    private init() {}

    // MARK: - 公共方法 - 获取数据

    /// 获取帖子列表
    func getPosts_Orna() -> [TitleModel_Orna] { posts_Orna }

    /// 初始化帖子列表
    func initPosts_Orna() {
        posts_Orna = LocalData_Orna.shared_Orna.titleList_Orna
        notifyStateChange_Orna()
    }

    /// 获取指定用户的帖子列表
    /// 参数：
    /// - user_orna: 目标用户模型
    /// - type_orna: 帖子类型过滤（保留参数，预留后续扩展）
    /// 返回值：该用户的帖子数组，用户ID缺失时返回空数组
    func getUserPosts_Orna(user_orna: PrewUserModel_Orna, type_orna: Int? = nil) -> [TitleModel_Orna] {
        guard let userId_orna = user_orna.userId_Orna else { return [] }
        return posts_Orna.filter { $0.titleUserId_Orna == userId_orna }
    }

    /// 判断当前用户是否已点赞指定帖子
    func isLikedPost_Orna(post_orna: TitleModel_Orna) -> Bool {
        UserViewModel_Orna.shared_Orna.isLikedByCurrentUser_Orna(post_orna: post_orna)
    }

    /// 获取帖子的可见评论列表（自动过滤已被举报/拉黑用户发布的评论）
    /// 参数：
    /// - post_orna: 目标帖子
    /// 返回值：过滤后的评论数组
    func getVisibleComments_Orna(post_orna: TitleModel_Orna) -> [Comment_Orna] {
        post_orna.reviews_Orna.filter { !UserViewModel_Orna.shared_Orna.isBlocked_Orna(userId_orna: $0.commentUserId_Orna) }
    }

    // MARK: - 公共方法 - 发布帖子

    /// 发布帖子
    /// 功能：创建新帖子并追加到列表，同步更新当前用户的帖子记录
    /// 参数：
    /// - title_orna: 帖子标题
    /// - content_orna: 帖子正文
    /// - media_orna: 媒体资源路径
    /// - isVideo_orna: 媒体是否为视频，默认 false（图片）
    /// - type_orna: 帖子类型，默认 0
    func releasePost_Orna(title_orna: String, content_orna: String, media_orna: String, isVideo_orna: Bool = false, type_orna: Int = 0) {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return
        }

        let currentUser_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        let newPost_orna = TitleModel_Orna(
            titleId_Orna: posts_Orna.count + 21,
            titleUserId_Orna: currentUser_orna.userId_Orna ?? 0,
            titleUserName_Orna: currentUser_orna.userName_Orna ?? "User",
            titleMeidas_Orna: [media_orna],
            title_Orna: title_orna,
            titleContent_Orna: content_orna,
            reviews_Orna: [],
            likes_Orna: 0,
            isVideoMedia_Orna: isVideo_orna
        )

        posts_Orna.append(newPost_orna)
        UserViewModel_Orna.shared_Orna.addPostToCurrentUser_Orna(post_orna: newPost_orna)
        Load_Orna.showSuccess_Orna(
            message_Orna: "Published successfully.",
            image_Orna: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Orna()
    }

    // MARK: - 公共方法 - 删除帖子

    /// 删除/屏蔽帖子
    /// 功能：从帖子列表及用户记录中移除帖子
    /// 参数：
    /// - post_orna: 目标帖子
    /// - isDelete_orna: true 表示主动删除，false 表示屏蔽（提示语不同）
    func deletePost_Orna(post_orna: TitleModel_Orna, isDelete_orna: Bool = false) {
        let userVM_orna = UserViewModel_Orna.shared_Orna
        userVM_orna.removePostFromCurrentUser_Orna(post_orna: post_orna)
        userVM_orna.removeLikeFromCurrentUser_Orna(post_orna: post_orna)
        posts_Orna.removeAll { $0.titleId_Orna == post_orna.titleId_Orna }

        Load_Orna.showSuccess_Orna(
            message_Orna: isDelete_orna ? "Deleted successfully." : "This post will no longer appear.",
            image_Orna: UIImage(systemName: "trash.fill"),
            delay_Orna: 1.5
        )
        notifyStateChange_Orna()
    }

    /// 删除指定用户的所有帖子
    func deleteUserPosts_Orna(userId_orna: Int) {
        posts_Orna.removeAll { $0.titleUserId_Orna == userId_orna }
        notifyStateChange_Orna()
    }

    // MARK: - 公共方法 - 评论管理

    /// 发布评论
    /// 功能：向指定帖子追加新评论
    /// 参数：
    /// - post_orna: 目标帖子
    /// - content_orna: 评论内容
    func releaseComment_Orna(post_orna: TitleModel_Orna, content_orna: String) {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return
        }

        let currentUser_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        let newComment_orna = Comment_Orna(
            commentId_Orna: post_orna.reviews_Orna.count + 1,
            commentUserId_Orna: currentUser_orna.userId_Orna ?? 0,
            commentUserName_Orna: currentUser_orna.userName_Orna ?? "User",
            commentContent_Orna: content_orna
        )

        if let index_orna = postIndex_Orna(for: post_orna) {
            posts_Orna[index_orna].reviews_Orna.append(newComment_orna)
        }
        notifyStateChange_Orna()
    }

    /// 删除/屏蔽评论
    /// 参数：
    /// - post_orna: 目标帖子
    /// - comment_orna: 要删除的评论
    /// - isDelete_orna: true 表示主动删除，false 表示屏蔽
    func deleteComment_Orna(post_orna: TitleModel_Orna, comment_orna: Comment_Orna, isDelete_orna: Bool = false) {
        if let index_orna = postIndex_Orna(for: post_orna) {
            posts_Orna[index_orna].reviews_Orna.removeAll {
                $0.commentId_Orna == comment_orna.commentId_Orna
            }
        }

        Load_Orna.showSuccess_Orna(
            message_Orna: isDelete_orna ? "Deleted successfully." : "This comment will no longer appear.",
            delay_Orna: 1.5
        )
        notifyStateChange_Orna()
    }

    // MARK: - 公共方法 - 点赞管理

    /// 点赞 / 取消点赞
    /// 功能：切换当前用户对指定帖子的点赞状态，同步更新点赞计数
    /// 参数：
    /// - post_orna: 目标帖子
    func likePost_Orna(post_orna: TitleModel_Orna) {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return
        }

        let userVM_orna = UserViewModel_Orna.shared_Orna
        guard let index_orna = postIndex_Orna(for: post_orna) else {
            notifyStateChange_Orna()
            return
        }

        if isLikedPost_Orna(post_orna: post_orna) {
            userVM_orna.removeLikeFromCurrentUser_Orna(post_orna: post_orna)
            posts_Orna[index_orna].likes_Orna = max(0, posts_Orna[index_orna].likes_Orna - 1)
        } else {
            userVM_orna.addLikeToCurrentUser_Orna(post_orna: post_orna)
            posts_Orna[index_orna].likes_Orna += 1
        }
        notifyStateChange_Orna()
    }

    // MARK: - 私有方法

    /// 查找帖子在列表中的下标
    /// 参数：
    /// - post_orna: 目标帖子
    /// 返回值：下标索引，未找到时返回 nil
    private func postIndex_Orna(for post_orna: TitleModel_Orna) -> Int? {
        posts_Orna.firstIndex { $0.titleId_Orna == post_orna.titleId_Orna }
    }

    /// 发送状态更新通知
    private func notifyStateChange_Orna() {
        NotificationCenter.default.post(
            name: TitleViewModel_Orna.titleStateDidChangeNotification_Orna,
            object: nil
        )
    }

    /// 显示登录引导（延迟 0.5 秒后跳转登录页）
    private func showLoginPrompt_Orna() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Orna.toLogin_Orna(style_orna: .present_orna)
        }
    }
}
