import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Maki {
    /// 删除账号
    case delete_maki
    /// 普通登出
    case logout_maki
}

/// 用户状态管理类
/// 功能：管理登录用户的状态、信息更新、关注、点赞和帖子操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class UserViewModel_Maki {

    /// 单例
    static let shared_Maki = UserViewModel_Maki()

    // MARK: - 通知名称

    /// 用户状态更新通知
    static let userStateDidChangeNotification_Maki = Notification.Name("UserStateDidChange_Maki")

    // MARK: - 私有属性

    /// 当前登录用户
    private var loggedUser_Maki: LoginUserModel_Maki?

    /// 默认用户（游客）
    private let defaultUser_Maki = LoginUserModel_Maki(
        userId_Maki: 0,
        userPwd_Maki: nil,
        userName_Maki: "Guest",
        userIntroduce_Maki: "Nothing yet.",
        userHead_Maki: "default_avatar",
        userPosts_Maki: [],
        userLike_Maki: [],
        userFollow_Maki: []
    )

    private init() {}

    // MARK: - 公共属性

    /// 是否已登录
    var isLoggedIn_Maki: Bool {
        loggedUser_Maki?.userId_Maki != 0
    }

    /// 获取当前用户（未登录时返回游客）
    func getCurrentUser_Maki() -> LoginUserModel_Maki {
        loggedUser_Maki ?? defaultUser_Maki
    }

    // MARK: - 初始化

    /// 初始化用户状态（重置为游客）
    func initUser_Maki() {
        loggedUser_Maki = defaultUser_Maki
        notifyStateChange_Maki()
    }

    // MARK: - 登录 / 登出

    /// 通过用户ID登录
    /// 参数：
    /// - userId_maki: 目标用户ID
    func loginById_Maki(userId_maki: Int) {
        Load_Maki.showLoading_Maki(message_Maki: "Logging in...")

        let localUser_maki = LocalData_Maki.shared_Maki.userList_Maki.first {
            $0.userId_Maki == userId_maki
        }

        loggedUser_Maki = LoginUserModel_Maki(
            userId_Maki: userId_maki,
            userPwd_Maki: nil,
            userName_Maki: "Makier",
            userIntroduce_Maki: localUser_maki?.userIntroduce_Maki ?? "Nothing yet.",
            userHead_Maki: "user_avatar",
            userPosts_Maki: [],
            userLike_Maki: [],
            userFollow_Maki: []
        )

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Load_Maki.dismissLoading_Maki()
            Load_Maki.showSuccess_Maki(message_Maki: "Login successful!")
            Navigation_Maki.switchToTabbar_Maki(animated: true)
            notifyStateChange_Maki()
        }
    }

    /// 用户登出
    /// 参数：
    /// - logoutType_maki: 登出类型（普通登出 / 删除账号）
    func logout_Maki(logoutType_maki: LogOutType_Maki) {
        guard isLoggedIn_Maki else {
            showLoginPrompt_Maki()
            return
        }

        loggedUser_Maki = defaultUser_Maki
        MessageViewModel_Maki.shared_Maki.clearAiChat_Maki()
        LocalData_Maki.shared_Maki.initData_Maki()
        notifyStateChange_Maki()
        Navigation_Maki.switchToTabbar_Maki()

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_maki == .delete_maki {
                Load_Maki.showInfo_Maki(
                    message_Maki: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Maki: 3.0
                )
            } else {
                Load_Maki.showSuccess_Maki(message_Maki: "Logout successful")
            }
        }
    }

    // MARK: - 用户信息更新

    /// 更新用户头像
    /// 参数：
    /// - headUrl_maki: 新头像路径
    func updateHead_Maki(headUrl_maki: String) {
        guard loggedUser_Maki != nil else { return }
        loggedUser_Maki?.userHead_Maki = headUrl_maki
        Load_Maki.showSuccess_Maki(message_Maki: "Avatar updated successfully")
        notifyStateChange_Maki()
    }

    /// 更新用户昵称
    /// 参数：
    /// - userName_maki: 新昵称
    func updateName_Maki(userName_maki: String) {
        guard loggedUser_Maki != nil else { return }
        loggedUser_Maki?.userName_Maki = userName_maki
        Load_Maki.showSuccess_Maki(message_Maki: "Name updated successfully")
        notifyStateChange_Maki()
    }

    /// 更新用户自我介绍
    /// 参数：
    /// - userIntroduce_maki: 新自我介绍内容
    func updateIntroduce_Maki(userIntroduce_maki: String) {
        guard loggedUser_Maki != nil else { return }
        loggedUser_Maki?.userIntroduce_Maki = userIntroduce_maki
        Load_Maki.showSuccess_Maki(message_Maki: "Bio updated successfully")
        notifyStateChange_Maki()
    }

    /// 上传用户封面
    /// 参数：
    /// - coverUrl_maki: 封面图片路径
    func uploadCover_Maki(coverUrl_maki: String) {
        Load_Maki.showSuccess_Maki(message_Maki: "Cover updated successfully")
        notifyStateChange_Maki()
    }

    // MARK: - 打卡功能

    /// 检查今天是否已打卡
    /// 返回值：已打卡返回 true，否则 false
    func hasCheckedInToday_Maki() -> Bool { false }

    /// 执行打卡
    /// 功能：已打卡时提示，未打卡时记录并提示成功
    func checkIn_Maki() {
        guard !hasCheckedInToday_Maki() else {
            Load_Maki.showWarning_Maki(message_Maki: "You have already checked in today.")
            return
        }
        Load_Maki.showSuccess_Maki(
            message_Maki: "Check-in successful!",
            image_Maki: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Maki()
    }

    // MARK: - 关注功能

    /// 判断当前用户是否关注了指定用户
    /// 参数：
    /// - user_maki: 目标用户
    /// 返回值：已关注返回 true，未登录或未关注返回 false
    func isFollowing_Maki(user_maki: PrewUserModel_Maki) -> Bool {
        guard let logged_maki = loggedUser_Maki else { return false }
        return logged_maki.userFollow_Maki.contains { $0.userId_Maki == user_maki.userId_Maki }
    }

    /// 关注 / 取消关注用户
    /// 功能：切换当前用户对目标用户的关注状态，同步增减目标用户的粉丝数（userFans_Maki）
    /// 参数：
    /// - user_maki: 目标用户
    func followUser_Maki(user_maki: PrewUserModel_Maki) {
        guard isLoggedIn_Maki else {
            showLoginPrompt_Maki()
            return
        }

        if isFollowing_Maki(user_maki: user_maki) {
            loggedUser_Maki?.userFollow_Maki.removeAll { $0.userId_Maki == user_maki.userId_Maki }
            user_maki.userFans_Maki = max(0, (user_maki.userFans_Maki ?? 0) - 1)
        } else {
            loggedUser_Maki?.userFollow_Maki.append(user_maki)
            user_maki.userFans_Maki = (user_maki.userFans_Maki ?? 0) + 1
        }
        notifyStateChange_Maki()
    }

    // MARK: - 举报功能

    /// 举报并屏蔽用户
    /// 功能：删除该用户的聊天记录、帖子，并从本地用户列表移除
    /// 参数：
    /// - user_maki: 被举报的用户
    func reportUser_Maki(user_maki: PrewUserModel_Maki) {
        guard let userId_maki = user_maki.userId_Maki else { return }

        MessageViewModel_Maki.shared_Maki.deleteUserMessages_Maki(userId_maki: userId_maki)
        TitleViewModel_Maki.shared_Maki.deleteUserPosts_Maki(userId_maki: userId_maki)
        LocalData_Maki.shared_Maki.userList_Maki.removeAll { $0.userId_Maki == userId_maki }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Load_Maki.showSuccess_Maki(message_Maki: "This user will no longer appear.", delay_Maki: 2.0)
        }
        notifyStateChange_Maki()
    }

    // MARK: - 用户查询

    /// 判断是否是当前登录用户
    /// 参数：
    /// - userId_maki: 待判断的用户ID
    func isCurrentUser_Maki(userId_maki: Int) -> Bool {
        loggedUser_Maki?.userId_Maki == userId_maki
    }

    /// 根据用户ID获取用户信息
    /// 参数：
    /// - userId_maki: 目标用户ID
    /// 返回值：找到时返回对应用户，未找到时返回以该ID构建的默认游客模型
    func getUserById_Maki(userId_maki: Int) -> PrewUserModel_Maki {
        if let found_maki = LocalData_Maki.shared_Maki.userList_Maki.first(where: { $0.userId_Maki == userId_maki }) {
            return found_maki
        }
        let guest_maki = PrewUserModel_Maki()
        guest_maki.userId_Maki = userId_maki
        guest_maki.userName_Maki = "Guest"
        guest_maki.userHead_Maki = "default_avatar"
        return guest_maki
    }

    /// 获取用户关注排行榜
    /// 返回值：用户列表（当前按原始顺序返回）
    func getUserFollowRanking_Maki() -> [PrewUserModel_Maki] {
        LocalData_Maki.shared_Maki.userList_Maki
    }

    // MARK: - 帖子和点赞管理

    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Maki(post_maki: TitleModel_Maki) {
        guard loggedUser_Maki != nil else { return }
        loggedUser_Maki?.userPosts_Maki.append(post_maki)
        notifyStateChange_Maki()
    }

    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Maki(post_maki: TitleModel_Maki) {
        guard loggedUser_Maki != nil else { return }
        loggedUser_Maki?.userPosts_Maki.removeAll { $0.titleId_Maki == post_maki.titleId_Maki }
        notifyStateChange_Maki()
    }

    /// 将帖子添加到当前用户的喜欢列表（已存在时跳过）
    func addLikeToCurrentUser_Maki(post_maki: TitleModel_Maki) {
        guard let user_maki = loggedUser_Maki,
              !user_maki.userLike_Maki.contains(where: { $0.titleId_Maki == post_maki.titleId_Maki }) else { return }
        user_maki.userLike_Maki.append(post_maki)
        notifyStateChange_Maki()
    }

    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Maki(post_maki: TitleModel_Maki) {
        guard loggedUser_Maki != nil else { return }
        loggedUser_Maki?.userLike_Maki.removeAll { $0.titleId_Maki == post_maki.titleId_Maki }
        notifyStateChange_Maki()
    }

    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Maki(post_maki: TitleModel_Maki) -> Bool {
        loggedUser_Maki?.userLike_Maki.contains { $0.titleId_Maki == post_maki.titleId_Maki } ?? false
    }

    // MARK: - 私有方法

    /// 发送状态更新通知
    private func notifyStateChange_Maki() {
        NotificationCenter.default.post(
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki,
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
