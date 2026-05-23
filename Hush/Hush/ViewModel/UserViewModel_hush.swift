import Foundation
import UIKit

// MARK: 用户状态管理 ViewModel

/// 登出类型枚举
/// - delete_hush: 注销账号（24小时后删除）
/// - logout_hush: 普通退出登录
enum LogOutType_Hush {
    case delete_hush
    case logout_hush
}

/// 用户状态管理 ViewModel
/// 功能：管理登录用户的全局状态，包括登录、注册、关注、点赞等操作
/// 设计：单例模式，通过 NotificationCenter 广播状态变化，UI 层监听通知刷新
/// 关键属性：loggedUser_Hush（当前登录用户）、isLoggedIn_Hush（登录状态）
@MainActor
class UserViewModel_Hush {
    
    // MARK: - 单例与通知名
    
    /// 单例实例
    static let shared_Hush = UserViewModel_Hush()
    
    /// 用户状态变化通知名
    static let userStateDidChangeNotification_Hush = Notification.Name("UserStateDidChange_Hush")
    
    // MARK: - 私有属性
    
    /// 当前登录用户（nil 或 userId==0 表示未登录）
    private var loggedUser_Hush: LoginUserModel_Hush?
    
    /// 默认游客用户（未登录时使用）
    private let defaultUser_Hush = LoginUserModel_Hush(
        userId_Hush: 0,
        userPwd_Hush: nil,
        userName_Hush: "Guest",
        userHead_Hush: "default_avatar",
        userPosts_Hush: [],
        userLike_Hush: [],
        userFollow_Hush: []
    )
    
    private init() {}
    
    // MARK: - 公开属性
    
    /// 是否已登录（userId 不为 0 且不为 nil 视为已登录）
    var isLoggedIn_Hush: Bool {
        guard let userId_hush = loggedUser_Hush?.userId_Hush else { return false }
        return userId_hush != 0
    }
    
    // MARK: - 获取当前用户
    
    /// 获取当前登录用户
    /// - Returns: 当前 LoginUserModel_Hush，未登录时返回默认游客对象
    func getCurrentUser_Hush() -> LoginUserModel_Hush {
        return loggedUser_Hush ?? defaultUser_Hush
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态（应用启动时调用）
    /// 功能：将用户状态重置为游客
    func initUser_Hush() {
        loggedUser_Hush = defaultUser_Hush
        notifyStateChange_Hush()
    }
    
    // MARK: - 登录
    
    /// 通过用户ID登录（已有账号时使用）
    /// 功能：从 LocalData 中查找对应用户信息并设置登录状态，模拟网络延迟后跳转首页
    /// - Parameter userId_hush: 目标用户 ID
    func loginById_Hush(userId_hush: Int) {
        // 从 LocalData 查找对应用户信息
        let users_hush = LocalData_Hush.shared_Hush.userList_Hush
        let userInfo_hush = users_hush.first(where: { $0.userId_Hush == userId_hush })
        
        Utils_Hush.showLoading_Hush(message_Hush: "Logging in...")
        loggedUser_Hush = LoginUserModel_Hush(
            userId_Hush: userId_hush,
            userPwd_Hush: nil,
            userName_Hush: userInfo_hush?.userName_Hush ?? "Wanderer",
            userHead_Hush: userInfo_hush?.userHead_Hush ?? "user_avatar",
            userPosts_Hush: [],
            userLike_Hush: [],
            userFollow_Hush: []
        )
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Utils_Hush.dismissLoading_Hush()
            Utils_Hush.showSuccess_Hush(message_Hush: "Login successful!")
            Navigation_Hush.switchToTabbar_Hush(animated: true)
            notifyStateChange_Hush()
        }
    }
    
    // MARK: - 登出
    
    /// 登出或注销账号
    /// - Parameter logoutType_hush: 登出类型（.logout_hush 普通退出，.delete_hush 注销）
    func logout_Hush(logoutType_hush: LogOutType_Hush) {
        if !isLoggedIn_Hush { showLoginPrompt_Hush(); return }
        loggedUser_Hush = defaultUser_Hush
        MessageViewModel_Hush.shared_Hush.clearAiChat_Hush()
        LocalData_Hush.shared_Hush.initData_Hush()
        notifyStateChange_Hush()
        Navigation_Hush.switchToTabbar_Hush()
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_hush == .delete_hush {
                Utils_Hush.showInfo_Hush(message_Hush: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.", delay_Hush: 3.0)
            } else {
                Utils_Hush.showSuccess_Hush(message_Hush: "Logout successful")
            }
        }
    }
    
    // MARK: - 更新用户信息
    
    /// 更新用户头像
    /// - Parameter headUrl_hush: 头像路径（本地路径或网络 URL）
    func updateHead_Hush(headUrl_hush: String) {
        guard let user_hush = loggedUser_Hush else { return }
        user_hush.userHead_Hush = headUrl_hush
        loggedUser_Hush = user_hush
        Utils_Hush.showSuccess_Hush(message_Hush: "Avatar updated successfully")
        notifyStateChange_Hush()
    }
    
    /// 更新用户名
    /// - Parameter userName_hush: 新用户名
    func updateName_Hush(userName_hush: String) {
        guard let user_hush = loggedUser_Hush else { return }
        user_hush.userName_Hush = userName_hush
        loggedUser_Hush = user_hush
        Utils_Hush.showSuccess_Hush(message_Hush: "Name updated successfully")
        notifyStateChange_Hush()
    }
    
    /// 更新用户简介
    /// 功能：将简介同步更新到 LocalData 的 PrewUserModel 中，以便在用户信息页展示
    /// - Parameter introduce_hush: 新的用户简介文本
    func updateIntroduce_Hush(introduce_hush: String) {
        guard let userId_hush = loggedUser_Hush?.userId_Hush else { return }
        // 同步更新 LocalData 中对应 PrewUserModel 的简介
        if let index_hush = LocalData_Hush.shared_Hush.userList_Hush.firstIndex(where: { $0.userId_Hush == userId_hush }) {
            LocalData_Hush.shared_Hush.userList_Hush[index_hush].userIntroduce_Hush = introduce_hush
        }
        Utils_Hush.showSuccess_Hush(message_Hush: "Introduction updated successfully")
        notifyStateChange_Hush()
    }
    
    /// 更新封面图片（预留方法，暂时只展示成功提示）
    /// - Parameter coverUrl_hush: 封面图片路径
    func uploadCover_Hush(coverUrl_hush: String) {
        Utils_Hush.showSuccess_Hush(message_Hush: "Cover updated successfully")
        notifyStateChange_Hush()
    }
    
    // MARK: - 签到
    
    /// 判断今天是否已签到（预留方法）
    func hasCheckedInToday_Hush() -> Bool { return false }
    
    /// 执行签到
    func checkIn_Hush() {
        if hasCheckedInToday_Hush() {
            Utils_Hush.showWarning_Hush(message_Hush: "You have already checked in today.")
            return
        }
        Utils_Hush.showSuccess_Hush(message_Hush: "Check-in successful!", image_Hush: UIImage(systemName: "checkmark.seal.fill"))
        notifyStateChange_Hush()
    }
    
    // MARK: - 关注功能（Bug修复版）
    
    /// 判断当前登录用户是否已关注目标用户
    /// 修复：原代码中 `guard let user_hush = loggedUser_Hush` 会遮蔽参数 user_hush，
    /// 导致最终比较的是 loggedUser 自身的 userId，而非参数中的目标用户 ID
    /// - Parameter user_hush: 目标用户
    /// - Returns: 是否已关注
    func isFollowing_Hush(user_hush: PrewUserModel_Hush) -> Bool {
        guard let loggedUser_hush = loggedUser_Hush else { return false }
        return loggedUser_hush.userFollow_Hush.contains(where: { $0.userId_Hush == user_hush.userId_Hush })
    }
    
    /// 关注或取消关注指定用户
    /// 同步更新目标用户在 LocalData 中的 userFans_Hush 计数，确保用户中心显示实时数据
    /// - Parameter user_hush: 目标用户
    func followUser_Hush(user_hush: PrewUserModel_Hush) {
        if !isLoggedIn_Hush { showLoginPrompt_Hush(); return }
        let alreadyFollowing = isFollowing_Hush(user_hush: user_hush)
        if alreadyFollowing {
            // 取消关注：移除当前用户关注列表中的目标用户
            loggedUser_Hush?.userFollow_Hush.removeAll { $0.userId_Hush == user_hush.userId_Hush }
            // 同步减少目标用户粉丝数
            if let idx = LocalData_Hush.shared_Hush.userList_Hush.firstIndex(where: { $0.userId_Hush == user_hush.userId_Hush }) {
                let current = LocalData_Hush.shared_Hush.userList_Hush[idx].userFans_Hush ?? 0
                LocalData_Hush.shared_Hush.userList_Hush[idx].userFans_Hush = max(0, current - 1)
            }
        } else {
            // 添加关注：加入当前用户关注列表
            loggedUser_Hush?.userFollow_Hush.append(user_hush)
            // 同步增加目标用户粉丝数
            if let idx = LocalData_Hush.shared_Hush.userList_Hush.firstIndex(where: { $0.userId_Hush == user_hush.userId_Hush }) {
                let current = LocalData_Hush.shared_Hush.userList_Hush[idx].userFans_Hush ?? 0
                LocalData_Hush.shared_Hush.userList_Hush[idx].userFans_Hush = current + 1
            }
        }
        notifyStateChange_Hush()
    }
    
    // MARK: - 举报/拉黑
    
    /// 举报并拉黑用户（将从所有列表中移除该用户数据）
    /// - Parameter user_hush: 被举报用户
    func reportUser_Hush(user_hush: PrewUserModel_Hush) {
        guard let userId_hush = user_hush.userId_Hush else { return }
        MessageViewModel_Hush.shared_Hush.deleteUserMessages_Hush(userId_hush: userId_hush)
        TitleViewModel_Hush.shared_Hush.deleteUserPosts_Hush(userId_hush: userId_hush)
        LocalData_Hush.shared_Hush.userList_Hush.removeAll { $0.userId_Hush == userId_hush }
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Utils_Hush.showSuccess_Hush(message_Hush: "This user will no longer appear.", delay_Hush: 2.0)
        }
        notifyStateChange_Hush()
    }
    
    // MARK: - 用户查询
    
    /// 判断目标 userId 是否为当前登录用户
    /// - Parameter userId_hush: 目标用户 ID
    func isCurrentUser_Hush(userId_hush: Int) -> Bool {
        return loggedUser_Hush?.userId_Hush == userId_hush
    }
    
    /// 通过 userId 查询 PrewUserModel（优先从 LocalData 查找，找不到返回默认空用户）
    /// - Parameter userId_hush: 目标用户 ID
    /// - Returns: PrewUserModel_Hush
    func getUserById_Hush(userId_hush: Int) -> PrewUserModel_Hush {
        let users_hush = LocalData_Hush.shared_Hush.userList_Hush
        if let user_hush = users_hush.first(where: { $0.userId_Hush == userId_hush }) {
            return user_hush
        }
        // 返回默认空用户
        let defaultPrewUser_hush = PrewUserModel_Hush()
        defaultPrewUser_hush.userId_Hush = userId_hush
        defaultPrewUser_hush.userName_Hush = "Guest"
        defaultPrewUser_hush.userHead_Hush = "default_avatar"
        return defaultPrewUser_hush
    }
    
    /// 获取全部用户排行列表（关注排行）
    func getUserFollowRanking_Hush() -> [PrewUserModel_Hush] {
        return LocalData_Hush.shared_Hush.userList_Hush
    }
    
    // MARK: - 帖子操作
    
    /// 向当前登录用户的帖子列表中添加新帖子
    /// - Parameter post_hush: 要添加的帖子
    func addPostToCurrentUser_Hush(post_hush: TitleModel_Hush) {
        guard let user_hush = loggedUser_Hush else { return }
        user_hush.userPosts_Hush.append(post_hush)
        loggedUser_Hush = user_hush
        notifyStateChange_Hush()
    }
    
    /// 从当前登录用户的帖子列表中移除指定帖子
    /// - Parameter post_hush: 要移除的帖子
    func removePostFromCurrentUser_Hush(post_hush: TitleModel_Hush) {
        guard let user_hush = loggedUser_Hush else { return }
        user_hush.userPosts_Hush.removeAll { $0.titleId_Hush == post_hush.titleId_Hush }
        loggedUser_Hush = user_hush
        notifyStateChange_Hush()
    }
    
    // MARK: - 点赞操作
    
    /// 向当前用户的喜欢列表中添加帖子（去重判断）
    /// - Parameter post_hush: 要点赞的帖子
    func addLikeToCurrentUser_Hush(post_hush: TitleModel_Hush) {
        guard let user_hush = loggedUser_Hush else { return }
        if !user_hush.userLike_Hush.contains(where: { $0.titleId_Hush == post_hush.titleId_Hush }) {
            user_hush.userLike_Hush.append(post_hush)
            loggedUser_Hush = user_hush
            notifyStateChange_Hush()
        }
    }
    
    /// 从当前用户的喜欢列表中移除指定帖子
    /// - Parameter post_hush: 要取消点赞的帖子
    func removeLikeFromCurrentUser_Hush(post_hush: TitleModel_Hush) {
        guard let user_hush = loggedUser_Hush else { return }
        user_hush.userLike_Hush.removeAll { $0.titleId_Hush == post_hush.titleId_Hush }
        loggedUser_Hush = user_hush
        notifyStateChange_Hush()
    }
    
    /// 判断当前登录用户是否已点赞该帖子
    /// - Parameter post_hush: 目标帖子
    /// - Returns: 是否已点赞
    func isLikedByCurrentUser_Hush(post_hush: TitleModel_Hush) -> Bool {
        guard let user_hush = loggedUser_Hush else { return false }
        return user_hush.userLike_Hush.contains { $0.titleId_Hush == post_hush.titleId_Hush }
    }
    
    // MARK: - 时间胶囊管理
    
    /// 时间胶囊状态变化通知名
    static let capsuleStateDidChangeNotification_Hush = Notification.Name("CapsuleStateDidChange_Hush")
    
    /// 当前用户的时间胶囊列表（按创建时间倒序）
    private var capsules_Hush: [TimeCapsuleModel_Hush] = []
    
    /// 获取所有时间胶囊（需登录）
    /// - Returns: 按创建时间倒序的胶囊数组，未登录返回空数组
    func getAllCapsules_Hush() -> [TimeCapsuleModel_Hush] {
        guard isLoggedIn_Hush else { return [] }
        return capsules_Hush.sorted { $0.createDate_Hush > $1.createDate_Hush }
    }
    
    /// 添加时间胶囊
    /// - Parameters:
    ///   - title_hush: 胶囊标题
    ///   - content_hush: 胶囊文字内容
    ///   - image_hush: 封面图片（可选）
    ///   - openDate_hush: 指定解锁时间（最短7天，最长10年）
    /// - Returns: 是否添加成功
    @discardableResult
    func addCapsule_Hush(title_hush: String,
                         content_hush: String,
                         image_hush: UIImage?,
                         openDate_hush: Date) -> Bool {
        guard isLoggedIn_Hush else { showLoginPrompt_Hush(); return false }
        
        // 校验解锁时间范围（最短7天，最长10年）
        let minDate_hush = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let maxDate_hush = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date()
        guard openDate_hush >= minDate_hush, openDate_hush <= maxDate_hush else {
            Utils_Hush.showError_Hush(message_Hush: "Open date must be between 7 days and 10 years from now.")
            return false
        }
        
        let newId_hush = (capsules_Hush.map { $0.capsuleId_Hush }.max() ?? 0) + 1
        let capsule_hush = TimeCapsuleModel_Hush(
            capsuleId_hush: newId_hush,
            capsuleTitle_hush: title_hush,
            capsuleContent_hush: content_hush,
            capsuleImage_hush: image_hush,
            createDate_hush: Date(),
            openDate_hush: openDate_hush
        )
        capsules_Hush.append(capsule_hush)
        notifyCapsuleChange_Hush()
        Utils_Hush.showSuccess_Hush(message_Hush: "Capsule planted successfully.")
        return true
    }
    
    /// 删除指定时间胶囊
    /// - Parameter capsuleId_hush: 胶囊 ID
    func deleteCapsule_Hush(capsuleId_hush: Int) {
        guard isLoggedIn_Hush else { return }
        capsules_Hush.removeAll { $0.capsuleId_Hush == capsuleId_hush }
        notifyCapsuleChange_Hush()
        Utils_Hush.showSuccess_Hush(
            message_Hush: "Capsule deleted.",
            image_Hush: UIImage(systemName: "trash.fill"),
            delay_Hush: 1.2
        )
    }
    
    /// 广播胶囊状态变化
    private func notifyCapsuleChange_Hush() {
        NotificationCenter.default.post(
            name: UserViewModel_Hush.capsuleStateDidChangeNotification_Hush,
            object: nil
        )
    }
    
    // MARK: - 私有方法
    
    /// 广播用户状态变化通知
    private func notifyStateChange_Hush() {
        NotificationCenter.default.post(
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush,
            object: nil
        )
    }
    
    /// 提示用户登录（未登录时调用需要登录权限的功能）
    private func showLoginPrompt_Hush() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Hush.toLogin_Hush(style_hush: .present_hush)
        }
    }
}
