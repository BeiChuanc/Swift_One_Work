import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
/// 功能：管理帖子、评论和点赞的增删改查
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class TitleViewModel_Lens {

    /// 单例
    static let shared_Lens = TitleViewModel_Lens()

    // MARK: - 通知名称

    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Lens = Notification.Name("TitleStateDidChange_Lens")

    // MARK: - 私有属性

    /// 帖子列表
    private var posts_Lens: [TitleModel_Lens] = []

    private init() {}

    // MARK: - 公共方法 - 获取数据

    /// 获取帖子列表
    func getPosts_Lens() -> [TitleModel_Lens] { posts_Lens }

    /// 初始化帖子列表
    func initPosts_Lens() {
        posts_Lens = LocalData_Lens.shared_Lens.titleList_Lens
        notifyStateChange_Lens()
    }

    /// 获取指定用户的帖子列表
    /// 参数：
    /// - user_lens: 目标用户模型
    /// - type_lens: 帖子类型过滤（保留参数，预留后续扩展）
    /// 返回值：该用户的帖子数组，用户ID缺失时返回空数组
    func getUserPosts_Lens(user_lens: PrewUserModel_Lens, type_lens: Int? = nil) -> [TitleModel_Lens] {
        guard let userId_lens = user_lens.userId_Lens else { return [] }
        return posts_Lens.filter { $0.titleUserId_Lens == userId_lens }
    }

    /// 判断当前用户是否已点赞指定帖子
    func isLikedPost_Lens(post_lens: TitleModel_Lens) -> Bool {
        UserViewModel_Lens.shared_Lens.isLikedByCurrentUser_Lens(post_lens: post_lens)
    }

    // MARK: - 公共方法 - 发布帖子

    /// 发布帖子
    /// 功能：创建新帖子并追加到列表，同步更新当前用户的帖子记录
    /// 参数：
    /// - title_lens: 帖子标题
    /// - content_lens: 帖子正文
    /// - media_lens: 媒体资源路径
    /// - type_lens: 帖子类型，默认 0
    func releasePost_Lens(title_lens: String, content_lens: String, media_lens: String, type_lens: Int = 0) {
        guard UserViewModel_Lens.shared_Lens.isLoggedIn_Lens else {
            showLoginPrompt_Lens()
            return
        }

        let currentUser_lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        let newPost_lens = TitleModel_Lens(
            titleId_Lens: posts_Lens.count + 21,
            titleUserId_Lens: currentUser_lens.userId_Lens ?? 0,
            titleUserName_Lens: currentUser_lens.userName_Lens ?? "User",
            titleMeidas_Lens: [media_lens],
            title_Lens: title_lens,
            titleContent_Lens: content_lens,
            reviews_Lens: [],
            likes_Lens: 0
        )

        posts_Lens.append(newPost_lens)
        UserViewModel_Lens.shared_Lens.addPostToCurrentUser_Lens(post_lens: newPost_lens)
        Load_Lens.showSuccess_Lens(
            message_Lens: "Published successfully.",
            image_Lens: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Lens()
    }

    // MARK: - 公共方法 - 删除帖子

    /// 删除/屏蔽帖子
    /// 功能：从帖子列表及用户记录中移除帖子
    /// 参数：
    /// - post_lens: 目标帖子
    /// - isDelete_lens: true 表示主动删除，false 表示屏蔽（提示语不同）
    func deletePost_Lens(post_lens: TitleModel_Lens, isDelete_lens: Bool = false) {
        let userVM_lens = UserViewModel_Lens.shared_Lens
        userVM_lens.removePostFromCurrentUser_Lens(post_lens: post_lens)
        userVM_lens.removeLikeFromCurrentUser_Lens(post_lens: post_lens)
        posts_Lens.removeAll { $0.titleId_Lens == post_lens.titleId_Lens }

        Load_Lens.showSuccess_Lens(
            message_Lens: isDelete_lens ? "Deleted successfully." : "This post will no longer appear.",
            image_Lens: UIImage(systemName: "trash.fill"),
            delay_Lens: 1.5
        )
        notifyStateChange_Lens()
    }

    /// 删除指定用户的所有帖子
    func deleteUserPosts_Lens(userId_lens: Int) {
        posts_Lens.removeAll { $0.titleUserId_Lens == userId_lens }
        notifyStateChange_Lens()
    }

    // MARK: - 公共方法 - 评论管理

    /// 发布评论
    /// 功能：向指定帖子追加新评论
    /// 参数：
    /// - post_lens: 目标帖子
    /// - content_lens: 评论内容
    func releaseComment_Lens(post_lens: TitleModel_Lens, content_lens: String) {
        guard UserViewModel_Lens.shared_Lens.isLoggedIn_Lens else {
            showLoginPrompt_Lens()
            return
        }

        let currentUser_lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        let newComment_lens = Comment_Lens(
            commentId_Lens: post_lens.reviews_Lens.count + 1,
            commentUserId_Lens: currentUser_lens.userId_Lens ?? 0,
            commentUserName_Lens: currentUser_lens.userName_Lens ?? "User",
            commentContent_Lens: content_lens
        )

        if let index_lens = postIndex_Lens(for: post_lens) {
            posts_Lens[index_lens].reviews_Lens.append(newComment_lens)
        }
        notifyStateChange_Lens()
    }

    /// 删除/屏蔽评论
    /// 参数：
    /// - post_lens: 目标帖子
    /// - comment_lens: 要删除的评论
    /// - isDelete_lens: true 表示主动删除，false 表示屏蔽
    func deleteComment_Lens(post_lens: TitleModel_Lens, comment_lens: Comment_Lens, isDelete_lens: Bool = false) {
        if let index_lens = postIndex_Lens(for: post_lens) {
            posts_Lens[index_lens].reviews_Lens.removeAll {
                $0.commentId_Lens == comment_lens.commentId_Lens
            }
        }

        Load_Lens.showSuccess_Lens(
            message_Lens: isDelete_lens ? "Deleted successfully." : "This comment will no longer appear.",
            delay_Lens: 1.5
        )
        notifyStateChange_Lens()
    }

    // MARK: - 公共方法 - 点赞管理

    /// 点赞 / 取消点赞
    /// 功能：切换当前用户对指定帖子的点赞状态，同步更新点赞计数
    /// 参数：
    /// - post_lens: 目标帖子
    func likePost_Lens(post_lens: TitleModel_Lens) {
        guard UserViewModel_Lens.shared_Lens.isLoggedIn_Lens else {
            showLoginPrompt_Lens()
            return
        }

        let userVM_lens = UserViewModel_Lens.shared_Lens
        guard let index_lens = postIndex_Lens(for: post_lens) else {
            notifyStateChange_Lens()
            return
        }

        if isLikedPost_Lens(post_lens: post_lens) {
            userVM_lens.removeLikeFromCurrentUser_Lens(post_lens: post_lens)
            posts_Lens[index_lens].likes_Lens = max(0, posts_Lens[index_lens].likes_Lens - 1)
        } else {
            userVM_lens.addLikeToCurrentUser_Lens(post_lens: post_lens)
            posts_Lens[index_lens].likes_Lens += 1
        }
        notifyStateChange_Lens()
    }

    // MARK: - 私有方法

    /// 查找帖子在列表中的下标
    /// 参数：
    /// - post_lens: 目标帖子
    /// 返回值：下标索引，未找到时返回 nil
    private func postIndex_Lens(for post_lens: TitleModel_Lens) -> Int? {
        posts_Lens.firstIndex { $0.titleId_Lens == post_lens.titleId_Lens }
    }

    /// 发送状态更新通知
    private func notifyStateChange_Lens() {
        NotificationCenter.default.post(
            name: TitleViewModel_Lens.titleStateDidChangeNotification_Lens,
            object: nil
        )
    }

    /// 显示登录引导（延迟 0.5 秒后跳转登录页）
    private func showLoginPrompt_Lens() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Lens.toLogin_Lens(style_lens: .present_lens)
        }
    }
}
