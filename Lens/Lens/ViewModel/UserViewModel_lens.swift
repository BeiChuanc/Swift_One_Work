import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Lens {
    /// 删除账号
    case delete_lens
    /// 普通登出
    case logout_lens
}

/// 用户状态管理类
/// 功能：管理登录用户的状态、信息更新、关注、点赞和帖子操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class UserViewModel_Lens {

    /// 单例
    static let shared_Lens = UserViewModel_Lens()

    // MARK: - 通知名称

    /// 用户状态更新通知
    static let userStateDidChangeNotification_Lens = Notification.Name("UserStateDidChange_Lens")

    // MARK: - 私有属性

    /// 当前登录用户
    private var loggedUser_Lens: LoginUserModel_Lens?

    /// 默认用户（游客）
    private let defaultUser_Lens = LoginUserModel_Lens(
        userId_Lens: 0,
        userPwd_Lens: nil,
        userName_Lens: "Guest",
        userIntroduce_Lens: "Nothing yet.",
        userHead_Lens: "default_avatar",
        userPosts_Lens: [],
        userLike_Lens: [],
        userFollow_Lens: []
    )

    private init() {}

    // MARK: - 公共属性

    /// 是否已登录
    var isLoggedIn_Lens: Bool {
        loggedUser_Lens?.userId_Lens != 0
    }

    /// 获取当前用户（未登录时返回游客）
    func getCurrentUser_Lens() -> LoginUserModel_Lens {
        loggedUser_Lens ?? defaultUser_Lens
    }

    // MARK: - 初始化

    /// 初始化用户状态（重置为游客）
    func initUser_Lens() {
        loggedUser_Lens = defaultUser_Lens
        notifyStateChange_Lens()
    }

    // MARK: - 登录 / 登出

    /// 通过用户ID登录
    /// 参数：
    /// - userId_lens: 目标用户ID
    func loginById_Lens(userId_lens: Int) {
        Load_Lens.showLoading_Lens(message_Lens: "Logging in...")

        let localUser_lens = LocalData_Lens.shared_Lens.userList_Lens.first {
            $0.userId_Lens == userId_lens
        }

        loggedUser_Lens = LoginUserModel_Lens(
            userId_Lens: userId_lens,
            userPwd_Lens: nil,
            userName_Lens: "Wanderer",
            userIntroduce_Lens: localUser_lens?.userIntroduce_Lens ?? "Nothing yet.",
            userHead_Lens: "user_avatar",
            userPosts_Lens: [],
            userLike_Lens: [],
            userFollow_Lens: []
        )

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Load_Lens.dismissLoading_Lens()
            Load_Lens.showSuccess_Lens(message_Lens: "Login successful!")
            Navigation_Lens.switchToTabbar_Lens(animated: true)
            notifyStateChange_Lens()
        }
    }

    /// 用户登出
    /// 参数：
    /// - logoutType_lens: 登出类型（普通登出 / 删除账号）
    func logout_Lens(logoutType_lens: LogOutType_Lens) {
        guard isLoggedIn_Lens else {
            showLoginPrompt_Lens()
            return
        }

        loggedUser_Lens = defaultUser_Lens
        MessageViewModel_Lens.shared_Lens.clearAiChat_Lens()
        LocalData_Lens.shared_Lens.initData_Lens()
        notifyStateChange_Lens()
        Navigation_Lens.switchToTabbar_Lens()

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_lens == .delete_lens {
                Load_Lens.showInfo_Lens(
                    message_Lens: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Lens: 3.0
                )
            } else {
                Load_Lens.showSuccess_Lens(message_Lens: "Logout successful")
            }
        }
    }

    /// 同步工作室统计到登录用户模型
    func syncStudioStats_Lens(
        artworkCount_Lens: Int,
        lastActiveDate_Lens: String?,
        coverMedia_Lens: String?
    ) {
        guard loggedUser_Lens != nil, isLoggedIn_Lens else { return }
        loggedUser_Lens?.studioArtworkCount_Lens = artworkCount_Lens
        loggedUser_Lens?.studioLastActiveDate_Lens = lastActiveDate_Lens
        if let cover_Lens = coverMedia_Lens, !cover_Lens.isEmpty {
            loggedUser_Lens?.studioDefaultCover_Lens = cover_Lens
        }
        notifyStateChange_Lens()
    }

    // MARK: - 用户信息更新

    /// 更新用户头像
    /// 参数：
    /// - headUrl_lens: 新头像路径
    func updateHead_Lens(headUrl_lens: String) {
        guard loggedUser_Lens != nil else { return }
        loggedUser_Lens?.userHead_Lens = headUrl_lens
        Load_Lens.showSuccess_Lens(message_Lens: "Avatar updated successfully")
        notifyStateChange_Lens()
    }

    /// 更新用户昵称
    /// 参数：
    /// - userName_lens: 新昵称
    func updateName_Lens(userName_lens: String) {
        guard loggedUser_Lens != nil else { return }
        loggedUser_Lens?.userName_Lens = userName_lens
        Load_Lens.showSuccess_Lens(message_Lens: "Name updated successfully")
        notifyStateChange_Lens()
    }

    /// 更新用户自我介绍
    /// 参数：
    /// - userIntroduce_lens: 新自我介绍内容
    func updateIntroduce_Lens(userIntroduce_lens: String) {
        guard loggedUser_Lens != nil else { return }
        loggedUser_Lens?.userIntroduce_Lens = userIntroduce_lens
        Load_Lens.showSuccess_Lens(message_Lens: "Bio updated successfully")
        notifyStateChange_Lens()
    }

    /// 上传用户封面
    /// 参数：
    /// - coverUrl_lens: 封面图片路径
    func uploadCover_Lens(coverUrl_lens: String) {
        Load_Lens.showSuccess_Lens(message_Lens: "Cover updated successfully")
        notifyStateChange_Lens()
    }

    // MARK: - 打卡功能

    /// 检查今天是否已打卡
    /// 返回值：已打卡返回 true，否则 false
    func hasCheckedInToday_Lens() -> Bool { false }

    /// 执行打卡
    /// 功能：已打卡时提示，未打卡时记录并提示成功
    func checkIn_Lens() {
        guard !hasCheckedInToday_Lens() else {
            Load_Lens.showWarning_Lens(message_Lens: "You have already checked in today.")
            return
        }
        Load_Lens.showSuccess_Lens(
            message_Lens: "Check-in successful!",
            image_Lens: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Lens()
    }

    // MARK: - 关注功能

    /// 判断当前用户是否关注了指定用户
    /// 参数：
    /// - user_lens: 目标用户
    /// 返回值：已关注返回 true，未登录或未关注返回 false
    func isFollowing_Lens(user_lens: PrewUserModel_Lens) -> Bool {
        guard let logged_lens = loggedUser_Lens,
              let targetId_Lens = user_lens.userId_Lens else { return false }
        return logged_lens.userFollow_Lens.contains { $0.userId_Lens == targetId_Lens }
    }

    /// 关注 / 取消关注用户
    /// 参数：
    /// - user_lens: 目标用户
    func followUser_Lens(user_lens: PrewUserModel_Lens) {
        guard isLoggedIn_Lens else {
            showLoginPrompt_Lens()
            return
        }

        guard let targetId_Lens = user_lens.userId_Lens else { return }

        if isFollowing_Lens(user_lens: user_lens) {
            loggedUser_Lens?.userFollow_Lens.removeAll { $0.userId_Lens == targetId_Lens }
            updateUserFansCount_Lens(userId_lens: targetId_Lens, delta_Lens: -1)
        } else {
            if loggedUser_Lens?.userFollow_Lens.contains(where: { $0.userId_Lens == targetId_Lens }) != true {
                loggedUser_Lens?.userFollow_Lens.append(user_lens)
            }
            updateUserFansCount_Lens(userId_lens: targetId_Lens, delta_Lens: 1)
        }
        notifyStateChange_Lens()
    }

    /// 更新预制用户粉丝数（关注 / 取关时同步）
    /// 参数：
    /// - userId_lens: 目标用户 ID
    /// - delta_Lens: 变化量（关注 +1，取关 -1）
    private func updateUserFansCount_Lens(userId_lens: Int, delta_Lens: Int) {
        guard let user_Lens = LocalData_Lens.shared_Lens.userList_Lens.first(where: { $0.userId_Lens == userId_lens }) else { return }
        let current_Lens = user_Lens.userFans_Lens ?? 0
        user_Lens.userFans_Lens = max(0, current_Lens + delta_Lens)
    }

    // MARK: - 举报功能

    /// 举报并屏蔽用户
    /// 功能：删除该用户的聊天记录、帖子，并从本地用户列表移除
    /// 参数：
    /// - user_lens: 被举报的用户
    func reportUser_Lens(user_lens: PrewUserModel_Lens) {
        guard let userId_lens = user_lens.userId_Lens else { return }

        MessageViewModel_Lens.shared_Lens.deleteUserMessages_Lens(userId_lens: userId_lens)
        TitleViewModel_Lens.shared_Lens.deleteUserPosts_Lens(userId_lens: userId_lens)
        LocalData_Lens.shared_Lens.userList_Lens.removeAll { $0.userId_Lens == userId_lens }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Load_Lens.showSuccess_Lens(message_Lens: "This user will no longer appear.", delay_Lens: 2.0)
        }
        notifyStateChange_Lens()
    }

    // MARK: - 用户查询

    /// 判断是否是当前登录用户
    /// 参数：
    /// - userId_lens: 待判断的用户ID
    func isCurrentUser_Lens(userId_lens: Int) -> Bool {
        loggedUser_Lens?.userId_Lens == userId_lens
    }

    /// 根据用户ID获取用户信息
    /// 参数：
    /// - userId_lens: 目标用户ID
    /// 返回值：找到时返回对应用户，未找到时返回以该ID构建的默认游客模型
    func getUserById_Lens(userId_lens: Int) -> PrewUserModel_Lens {
        if let found_lens = LocalData_Lens.shared_Lens.userList_Lens.first(where: { $0.userId_Lens == userId_lens }) {
            return found_lens
        }
        let guest_lens = PrewUserModel_Lens()
        guest_lens.userId_Lens = userId_lens
        guest_lens.userName_Lens = "Guest"
        guest_lens.userHead_Lens = "default_avatar"
        return guest_lens
    }

    /// 获取用户关注排行榜
    /// 返回值：用户列表（当前按原始顺序返回）
    func getUserFollowRanking_Lens() -> [PrewUserModel_Lens] {
        LocalData_Lens.shared_Lens.userList_Lens
    }

    // MARK: - 帖子和点赞管理

    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Lens(post_lens: TitleModel_Lens) {
        guard loggedUser_Lens != nil else { return }
        loggedUser_Lens?.userPosts_Lens.append(post_lens)
        notifyStateChange_Lens()
    }

    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Lens(post_lens: TitleModel_Lens) {
        guard loggedUser_Lens != nil else { return }
        loggedUser_Lens?.userPosts_Lens.removeAll { $0.titleId_Lens == post_lens.titleId_Lens }
        notifyStateChange_Lens()
    }

    /// 将帖子添加到当前用户的喜欢列表（已存在时跳过）
    func addLikeToCurrentUser_Lens(post_lens: TitleModel_Lens) {
        guard let user_lens = loggedUser_Lens,
              !user_lens.userLike_Lens.contains(where: { $0.titleId_Lens == post_lens.titleId_Lens }) else { return }
        user_lens.userLike_Lens.append(post_lens)
        notifyStateChange_Lens()
    }

    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Lens(post_lens: TitleModel_Lens) {
        guard loggedUser_Lens != nil else { return }
        loggedUser_Lens?.userLike_Lens.removeAll { $0.titleId_Lens == post_lens.titleId_Lens }
        notifyStateChange_Lens()
    }

    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Lens(post_lens: TitleModel_Lens) -> Bool {
        loggedUser_Lens?.userLike_Lens.contains { $0.titleId_Lens == post_lens.titleId_Lens } ?? false
    }

    // MARK: - 私有方法

    /// 发送状态更新通知
    private func notifyStateChange_Lens() {
        NotificationCenter.default.post(
            name: UserViewModel_Lens.userStateDidChangeNotification_Lens,
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
