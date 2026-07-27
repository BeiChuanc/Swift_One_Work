import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
/// 功能：管理帖子、评论和点赞的增删改查
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class TitleViewModel_Maki {

    /// 单例
    static let shared_Maki = TitleViewModel_Maki()

    // MARK: - 通知名称

    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Maki = Notification.Name("TitleStateDidChange_Maki")

    // MARK: - 私有属性

    /// 帖子列表
    private var posts_Maki: [TitleModel_Maki] = []

    private init() {}

    // MARK: - 公共方法 - 获取数据

    /// 获取帖子列表
    func getPosts_Maki() -> [TitleModel_Maki] { posts_Maki }

    /// 初始化帖子列表
    func initPosts_Maki() {
        posts_Maki = LocalData_Maki.shared_Maki.titleList_Maki
        notifyStateChange_Maki()
    }

    /// 获取指定用户的帖子列表
    /// 参数：
    /// - user_maki: 目标用户模型
    /// - type_maki: 帖子类型过滤（保留参数，预留后续扩展）
    /// 返回值：该用户的帖子数组，用户ID缺失时返回空数组
    func getUserPosts_Maki(user_maki: PrewUserModel_Maki, type_maki: Int? = nil) -> [TitleModel_Maki] {
        guard let userId_maki = user_maki.userId_Maki else { return [] }
        return posts_Maki.filter { $0.titleUserId_Maki == userId_maki }
    }

    /// 判断当前用户是否已点赞指定帖子
    func isLikedPost_Maki(post_maki: TitleModel_Maki) -> Bool {
        UserViewModel_Maki.shared_Maki.isLikedByCurrentUser_Maki(post_maki: post_maki)
    }

    // MARK: - 公共方法 - 发布帖子

    /// 发布帖子
    /// 功能：创建新帖子并追加到列表，同步更新当前用户的帖子记录
    /// 参数：
    /// - title_maki: 帖子标题
    /// - content_maki: 帖子正文
    /// - media_maki: 媒体资源路径
    /// - type_maki: 帖子类型，默认 0
    func releasePost_Maki(title_maki: String, content_maki: String, media_maki: String, type_maki: Int = 0) {
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            showLoginPrompt_Maki()
            return
        }

        let currentUser_maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
        let newPost_maki = TitleModel_Maki(
            titleId_Maki: posts_Maki.count + 21,
            titleUserId_Maki: currentUser_maki.userId_Maki ?? 0,
            titleUserName_Maki: currentUser_maki.userName_Maki ?? "User",
            titleMeidas_Maki: [media_maki],
            title_Maki: title_maki,
            titleContent_Maki: content_maki,
            reviews_Maki: [],
            likes_Maki: 0
        )

        posts_Maki.append(newPost_maki)
        UserViewModel_Maki.shared_Maki.addPostToCurrentUser_Maki(post_maki: newPost_maki)
        Load_Maki.showSuccess_Maki(
            message_Maki: "Published successfully.",
            image_Maki: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Maki()
    }

    // MARK: - 公共方法 - 删除帖子

    /// 删除/屏蔽帖子
    /// 功能：从帖子列表及用户记录中移除帖子
    /// 参数：
    /// - post_maki: 目标帖子
    /// - isDelete_maki: true 表示主动删除，false 表示屏蔽（提示语不同）
    func deletePost_Maki(post_maki: TitleModel_Maki, isDelete_maki: Bool = false) {
        let userVM_maki = UserViewModel_Maki.shared_Maki
        userVM_maki.removePostFromCurrentUser_Maki(post_maki: post_maki)
        userVM_maki.removeLikeFromCurrentUser_Maki(post_maki: post_maki)
        posts_Maki.removeAll { $0.titleId_Maki == post_maki.titleId_Maki }

        Load_Maki.showSuccess_Maki(
            message_Maki: isDelete_maki ? "Deleted successfully." : "This post will no longer appear.",
            image_Maki: UIImage(systemName: "trash.fill"),
            delay_Maki: 1.5
        )
        notifyStateChange_Maki()
    }

    /// 删除指定用户的所有帖子
    func deleteUserPosts_Maki(userId_maki: Int) {
        posts_Maki.removeAll { $0.titleUserId_Maki == userId_maki }
        notifyStateChange_Maki()
    }

    // MARK: - 公共方法 - 评论管理

    /// 发布评论
    /// 功能：向指定帖子追加新评论
    /// 参数：
    /// - post_maki: 目标帖子
    /// - content_maki: 评论内容
    func releaseComment_Maki(post_maki: TitleModel_Maki, content_maki: String) {
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            showLoginPrompt_Maki()
            return
        }

        let currentUser_maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
        let newComment_maki = Comment_Maki(
            commentId_Maki: post_maki.reviews_Maki.count + 1,
            commentUserId_Maki: currentUser_maki.userId_Maki ?? 0,
            commentUserName_Maki: currentUser_maki.userName_Maki ?? "User",
            commentContent_Maki: content_maki
        )

        if let index_maki = postIndex_Maki(for: post_maki) {
            posts_Maki[index_maki].reviews_Maki.append(newComment_maki)
        }
        notifyStateChange_Maki()
    }

    /// 删除/屏蔽评论
    /// 参数：
    /// - post_maki: 目标帖子
    /// - comment_maki: 要删除的评论
    /// - isDelete_maki: true 表示主动删除，false 表示屏蔽
    func deleteComment_Maki(post_maki: TitleModel_Maki, comment_maki: Comment_Maki, isDelete_maki: Bool = false) {
        if let index_maki = postIndex_Maki(for: post_maki) {
            posts_Maki[index_maki].reviews_Maki.removeAll {
                $0.commentId_Maki == comment_maki.commentId_Maki
            }
        }

        Load_Maki.showSuccess_Maki(
            message_Maki: isDelete_maki ? "Deleted successfully." : "This comment will no longer appear.",
            delay_Maki: 1.5
        )
        notifyStateChange_Maki()
    }

    // MARK: - 公共方法 - 点赞管理

    /// 点赞 / 取消点赞
    /// 功能：切换当前用户对指定帖子的点赞状态，同步更新点赞计数
    /// 参数：
    /// - post_maki: 目标帖子
    func likePost_Maki(post_maki: TitleModel_Maki) {
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            showLoginPrompt_Maki()
            return
        }

        let userVM_maki = UserViewModel_Maki.shared_Maki
        guard let index_maki = postIndex_Maki(for: post_maki) else {
            notifyStateChange_Maki()
            return
        }

        if isLikedPost_Maki(post_maki: post_maki) {
            userVM_maki.removeLikeFromCurrentUser_Maki(post_maki: post_maki)
            posts_Maki[index_maki].likes_Maki = max(0, posts_Maki[index_maki].likes_Maki - 1)
        } else {
            userVM_maki.addLikeToCurrentUser_Maki(post_maki: post_maki)
            posts_Maki[index_maki].likes_Maki += 1
        }
        notifyStateChange_Maki()
    }

    // MARK: - 私有方法

    /// 查找帖子在列表中的下标
    /// 参数：
    /// - post_maki: 目标帖子
    /// 返回值：下标索引，未找到时返回 nil
    private func postIndex_Maki(for post_maki: TitleModel_Maki) -> Int? {
        posts_Maki.firstIndex { $0.titleId_Maki == post_maki.titleId_Maki }
    }

    /// 发送状态更新通知
    private func notifyStateChange_Maki() {
        NotificationCenter.default.post(
            name: TitleViewModel_Maki.titleStateDidChangeNotification_Maki,
            object: nil
        )
    }

    /// 显示登录引导（延迟 0.5 秒后跳转登录页）
    private func showLoginPrompt_Maki() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki)
        }
    }
}
