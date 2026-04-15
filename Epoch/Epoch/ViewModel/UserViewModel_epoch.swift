import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Epoch {
    /// 删除账号
    case delete_epoch
    /// 普通登出
    case logout_epoch
}

/// 用户状态管理类
@MainActor
class UserViewModel_Epoch {
    
    /// 单例
    static let shared_Epoch = UserViewModel_Epoch()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Epoch = Notification.Name("UserStateDidChange_Epoch")

    /// 用户关系更新通知
    static let userRelationshipDidChangeNotification_Epoch = Notification.Name("UserRelationshipDidChange_Epoch")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Epoch: LoginUserModel_Epoch?
    
    /// 默认用户（游客）
    private let defaultUser_Epoch = LoginUserModel_Epoch(
        userId_Epoch: 0,
        userPwd_Epoch: nil,
        userName_Epoch: "Guest",
        userIntroduce_Epoch: "Browse gentle ceremony moments anytime.",
        userHead_Epoch: "person.crop.circle",
        userPosts_Epoch: [],
        userMomentWall_Epoch: [],
        userLike_Epoch: [],
        userFollow_Epoch: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Epoch: Bool {
        return loggedUser_Epoch?.userId_Epoch != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Epoch() -> LoginUserModel_Epoch {
        return loggedUser_Epoch ?? defaultUser_Epoch
    }

    /// 获取当前用户的预览模型
    /// - Returns: 可用于页面展示的预览用户模型
    func getCurrentUserPreview_Epoch() -> PrewUserModel_Epoch {
        let currentUser_epoch = getCurrentUser_Epoch()
        return PrewUserModel_Epoch(
            userId_Epoch: currentUser_epoch.userId_Epoch,
            userName_Epoch: currentUser_epoch.userName_Epoch,
            userIntroduce_Epoch: currentUser_epoch.userIntroduce_Epoch,
            userHead_Epoch: currentUser_epoch.userHead_Epoch,
            userMedia_Epoch: [],
            userLike_Epoch: currentUser_epoch.userLike_Epoch,
            userFollow_Epoch: currentUser_epoch.userFollow_Epoch.count,
            userFans_Epoch: 0
        )
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Epoch() {
        loggedUser_Epoch = defaultUser_Epoch
        notifyStateChange_Epoch()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Epoch(userId_epoch: Int) {
        Utils_Epoch.showLoading_Epoch(message_Epoch: "Logging in...")

        let localUser_epoch = LocalData_Epoch.shared_Epoch.getUser_Epoch(userId_epoch: userId_epoch)
        let userName_epoch = localUser_epoch?.userName_Epoch ?? "Epocher"
        let userIntroduce_epoch = localUser_epoch?.userIntroduce_Epoch ?? "Share warm rituals with friends."
        let userHead_epoch = localUser_epoch?.userHead_Epoch ?? "person.crop.circle.badge.checkmark"
        let userPosts_epoch = TitleViewModel_Epoch.shared_Epoch.getPosts_Epoch().filter {
            $0.titleUserId_Epoch == userId_epoch
        }
        let userLike_epoch = localUser_epoch?.userLike_Epoch ?? []
        let previousFollow_epoch = loggedUser_Epoch?.userId_Epoch == userId_epoch ? (loggedUser_Epoch?.userFollow_Epoch ?? []) : []

        loggedUser_Epoch = LoginUserModel_Epoch(
            userId_Epoch: userId_epoch,
            userPwd_Epoch: nil,
            userName_Epoch: userName_epoch,
            userIntroduce_Epoch: userIntroduce_epoch,
            userHead_Epoch: userHead_epoch,
            userPosts_Epoch: userPosts_epoch,
            userMomentWall_Epoch: userPosts_epoch,
            userLike_Epoch: userLike_epoch,
            userFollow_Epoch: previousFollow_epoch
        )

        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            Utils_Epoch.dismissLoading_Epoch()
            Utils_Epoch.showSuccess_Epoch(message_Epoch: "Login successful!")
            Navigation_Epoch.switchToTabbar_Epoch(animated: true)
            notifyStateChange_Epoch()
        }
    }
    
    /// 用户登出
    func logout_Epoch(logoutType_epoch: LogOutType_Epoch) {
        if !isLoggedIn_Epoch {
            showLoginPrompt_Epoch()
            return
        }
        
        // 重置为游客状态
        loggedUser_Epoch = defaultUser_Epoch
        
        // 清空AI聊天记录
        MessageViewModel_Epoch.shared_Epoch.logoutChat_Epoch()
        
        // 重新初始化本地数据
        LocalData_Epoch.shared_Epoch.initData_Epoch()
        TitleViewModel_Epoch.shared_Epoch.initPosts_Epoch()
        
        notifyStateChange_Epoch()
        
        // 跳转到首页
        Navigation_Epoch.switchToTabbar_Epoch()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_epoch == .delete_epoch {
                Utils_Epoch.showInfo_Epoch(
                    message_Epoch: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Epoch: 3.0
                )
            } else {
                Utils_Epoch.showSuccess_Epoch(message_Epoch: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Epoch(headUrl_epoch: String) {
        guard isLoggedIn_Epoch, let user_epoch = loggedUser_Epoch else {
            showLoginPrompt_Epoch()
            return
        }
        user_epoch.userHead_Epoch = headUrl_epoch
        Utils_Epoch.showSuccess_Epoch(message_Epoch: "Avatar updated successfully")
        notifyStateChange_Epoch()
    }
    
    /// 更新用户昵称
    func updateName_Epoch(userName_epoch: String) {
        guard isLoggedIn_Epoch, let user_epoch = loggedUser_Epoch else {
            showLoginPrompt_Epoch()
            return
        }
        user_epoch.userName_Epoch = userName_epoch
        Utils_Epoch.showSuccess_Epoch(message_Epoch: "Name updated successfully")
        notifyStateChange_Epoch()
    }

    /// 更新用户简介
    /// - Parameter userIntroduce_epoch: 用户简介
    func updateIntroduce_Epoch(userIntroduce_epoch: String) {
        guard isLoggedIn_Epoch, let user_epoch = loggedUser_Epoch else {
            showLoginPrompt_Epoch()
            return
        }
        user_epoch.userIntroduce_Epoch = userIntroduce_epoch
        Utils_Epoch.showSuccess_Epoch(message_Epoch: "Bio updated successfully")
        notifyStateChange_Epoch()
    }

    /// 统一更新用户资料
    /// - Parameters:
    ///   - userName_epoch: 用户名
    ///   - userIntroduce_epoch: 用户简介
    ///   - headPath_epoch: 头像路径
    /// - Returns: 是否更新成功
    @discardableResult
    func updateProfile_Epoch(
        userName_epoch: String?,
        userIntroduce_epoch: String?,
        headPath_epoch: String?
    ) -> Bool {
        guard isLoggedIn_Epoch, let user_epoch = loggedUser_Epoch else {
            showLoginPrompt_Epoch()
            return false
        }

        let newName_epoch = (userName_epoch?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? userName_epoch?.trimmingCharacters(in: .whitespacesAndNewlines)
            : user_epoch.userName_Epoch
        let newIntroduce_epoch = userIntroduce_epoch?.trimmingCharacters(in: .whitespacesAndNewlines) ?? user_epoch.userIntroduce_Epoch
        let newHead_epoch = headPath_epoch?.isEmpty == false ? headPath_epoch : user_epoch.userHead_Epoch

        user_epoch.userName_Epoch = newName_epoch
        user_epoch.userIntroduce_Epoch = newIntroduce_epoch
        user_epoch.userHead_Epoch = newHead_epoch
        notifyStateChange_Epoch()
        Utils_Epoch.showSuccess_Epoch(message_Epoch: "Profile updated successfully")
        return true
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Epoch() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Epoch() {
        if hasCheckedInToday_Epoch() {
            Utils_Epoch.showWarning_Epoch(
                message_Epoch: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Epoch.showSuccess_Epoch(
            message_Epoch: "Check-in successful!",
            image_Epoch: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Epoch()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Epoch(user_epoch: PrewUserModel_Epoch) -> Bool {
        guard let targetUserId_epoch = user_epoch.userId_Epoch else { return false }
        return loggedUser_Epoch?.userFollow_Epoch.contains(where: { $0.userId_Epoch == targetUserId_epoch }) ?? false
    }
    
    /// 关注/取消关注用户
    @discardableResult
    func followUser_Epoch(user_epoch: PrewUserModel_Epoch) -> Bool {
        if !isLoggedIn_Epoch {
            showLoginPrompt_Epoch()
            return false
        }

        guard let targetUserId_epoch = user_epoch.userId_Epoch,
              let currentUserId_epoch = loggedUser_Epoch?.userId_Epoch,
              targetUserId_epoch != currentUserId_epoch else {
            return false
        }

        let isCurrentlyFollowing_epoch = isFollowing_Epoch(user_epoch: user_epoch)
        if isCurrentlyFollowing_epoch {
            loggedUser_Epoch?.userFollow_Epoch.removeAll { $0.userId_Epoch == targetUserId_epoch }
        } else {
            loggedUser_Epoch?.userFollow_Epoch.append(user_epoch)
        }

        LocalData_Epoch.shared_Epoch.updateFollowCount_Epoch(
            userId_epoch: targetUserId_epoch,
            isFollowing_epoch: !isCurrentlyFollowing_epoch
        )
        notifyStateChange_Epoch()
        notifyRelationshipChange_Epoch(userId_epoch: targetUserId_epoch, isFollowing_epoch: !isCurrentlyFollowing_epoch)
        return !isCurrentlyFollowing_epoch
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Epoch(user_epoch: PrewUserModel_Epoch) {
        guard let userId_epoch = user_epoch.userId_Epoch else { return }

        loggedUser_Epoch?.userFollow_Epoch.removeAll { $0.userId_Epoch == userId_epoch }
        MessageViewModel_Epoch.shared_Epoch.deleteUserMessages_Epoch(
            userId_epoch: userId_epoch
        )
        TitleViewModel_Epoch.shared_Epoch.deleteUserPosts_Epoch(
            userId_epoch: userId_epoch
        )
        LocalData_Epoch.shared_Epoch.removeUser_Epoch(userId_epoch: userId_epoch)

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Utils_Epoch.showSuccess_Epoch(
                message_Epoch: "This user will no longer appear.",
                delay_Epoch: 2.0
            )
        }

        notifyRelationshipChange_Epoch(userId_epoch: userId_epoch, isFollowing_epoch: false)
        notifyStateChange_Epoch()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Epoch(userId_epoch: Int) -> Bool {
        return loggedUser_Epoch?.userId_Epoch == userId_epoch
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Epoch(userId_epoch: Int) -> PrewUserModel_Epoch {
        if let user_epoch = LocalData_Epoch.shared_Epoch.getUser_Epoch(userId_epoch: userId_epoch) {
            return user_epoch
        }

        let defaultPrewUser_epoch = PrewUserModel_Epoch()
        defaultPrewUser_epoch.userId_Epoch = userId_epoch
        defaultPrewUser_epoch.userName_Epoch = "Guest"
        defaultPrewUser_epoch.userIntroduce_Epoch = "This profile is no longer available."
        defaultPrewUser_epoch.userHead_Epoch = "person.crop.circle.badge.exclamationmark"
        return defaultPrewUser_epoch
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Epoch() -> [PrewUserModel_Epoch] {
        return LocalData_Epoch.shared_Epoch.userList_Epoch.sorted {
            ($0.userFans_Epoch ?? 0) > ($1.userFans_Epoch ?? 0)
        }
    }

    /// 获取当前登录用户贴纸墙作品，严格读取 userMomentWall_Epoch，无数据返回空数组
    /// - Parameter limit_epoch: 返回数量上限，0 或负数直接返回空
    /// - Returns: 已按 titleId 倒序排列的贴纸墙作品，未登录或无数据均返回 []
    func getHomeMomentPosts_Epoch(limit_epoch: Int) -> [TitleModel_Epoch] {
        guard limit_epoch > 0,
              isLoggedIn_Epoch,
              let user_epoch = loggedUser_Epoch,
              !user_epoch.userMomentWall_Epoch.isEmpty else {
            return []
        }
        let sortedPosts_epoch = user_epoch.userMomentWall_Epoch.sorted {
            $0.titleId_Epoch > $1.titleId_Epoch
        }
        return Array(sortedPosts_epoch.prefix(limit_epoch))
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Epoch(post_epoch: TitleModel_Epoch) {
        guard let user_epoch = loggedUser_Epoch else { return }
        if !user_epoch.userPosts_Epoch.contains(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
            user_epoch.userPosts_Epoch.insert(post_epoch, at: 0)
        }
        if !user_epoch.userMomentWall_Epoch.contains(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
            user_epoch.userMomentWall_Epoch.insert(post_epoch, at: 0)
        }
        notifyStateChange_Epoch()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Epoch(post_epoch: TitleModel_Epoch) {
        guard let user_epoch = loggedUser_Epoch else { return }
        user_epoch.userPosts_Epoch.removeAll { $0.titleId_Epoch == post_epoch.titleId_Epoch }
        user_epoch.userMomentWall_Epoch.removeAll { $0.titleId_Epoch == post_epoch.titleId_Epoch }
        notifyStateChange_Epoch()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Epoch(post_epoch: TitleModel_Epoch) {
        guard let user_epoch = loggedUser_Epoch else { return }
        if !user_epoch.userLike_Epoch.contains(where: { $0.titleId_Epoch == post_epoch.titleId_Epoch }) {
            user_epoch.userLike_Epoch.append(post_epoch)
            notifyStateChange_Epoch()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Epoch(post_epoch: TitleModel_Epoch) {
        guard let user_epoch = loggedUser_Epoch else { return }
        user_epoch.userLike_Epoch.removeAll { $0.titleId_Epoch == post_epoch.titleId_Epoch }
        notifyStateChange_Epoch()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Epoch(post_epoch: TitleModel_Epoch) -> Bool {
        guard let user_epoch = loggedUser_Epoch else { return false }
        return user_epoch.userLike_Epoch.contains { $0.titleId_Epoch == post_epoch.titleId_Epoch }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Epoch() {
        NotificationCenter.default.post(
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    /// 发送关系更新通知
    /// - Parameters:
    ///   - userId_epoch: 目标用户ID
    ///   - isFollowing_epoch: 是否关注
    private func notifyRelationshipChange_Epoch(userId_epoch: Int, isFollowing_epoch: Bool) {
        NotificationCenter.default.post(
            name: UserViewModel_Epoch.userRelationshipDidChangeNotification_Epoch,
            object: nil,
            userInfo: [
                "userId_Epoch": userId_epoch,
                "isFollowing_Epoch": isFollowing_epoch
            ]
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Epoch() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if let currentVC_epoch = Navigation_Epoch.currentViewController_Epoch(),
               currentVC_epoch is Login_Epoch || currentVC_epoch is Register_Epoch {
                return
            }
            Navigation_Epoch.toLogin_Epoch(style_epoch: .present_epoch)
        }
    }
}
