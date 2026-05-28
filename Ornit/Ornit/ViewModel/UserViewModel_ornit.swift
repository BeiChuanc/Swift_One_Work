import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Ornit {
    /// 删除账号
    case delete_ornit
    /// 普通登出
    case logout_ornit
}

/// 用户状态管理类
@MainActor
class UserViewModel_Ornit {
    
    /// 单例
    static let shared_Ornit = UserViewModel_Ornit()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Ornit = Notification.Name("UserStateDidChange_Ornit")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Ornit: LoginUserModel_Ornit?
    
    /// 默认用户（游客）
    private let defaultUser_Ornit = LoginUserModel_Ornit(
        userId_Ornit: 0,
        userPwd_Ornit: nil,
        userName_Ornit: "Guest",
        userHead_Ornit: "default_avatar",
        userPosts_Ornit: [],
        userLike_Ornit: [],
        userFollow_Ornit: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Ornit: Bool {
        return loggedUser_Ornit?.userId_Ornit != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Ornit() -> LoginUserModel_Ornit {
        return loggedUser_Ornit ?? defaultUser_Ornit
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Ornit() {
        loggedUser_Ornit = defaultUser_Ornit
        notifyStateChange_Ornit()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Ornit(userId_ornit: Int) {
        // 显示加载动画
        Utils_Ornit.showLoading_Ornit(message_Ornit: "Logging in...")
        
        // 创建登录用户
        loggedUser_Ornit = LoginUserModel_Ornit(
            userId_Ornit: userId_ornit,
            userPwd_Ornit: nil,
            userName_Ornit: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Ornit: "user_avatar",
            userPosts_Ornit: [],
            userLike_Ornit: [],
            userFollow_Ornit: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Ornit.dismissLoading_Ornit()
            
            // 显示成功提示
            Utils_Ornit.showSuccess_Ornit(message_Ornit: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Ornit.switchToTabbar_Ornit(animated: true)
            
            notifyStateChange_Ornit()
        }
    }
    
    /// 用户登出
    func logout_Ornit(logoutType_ornit: LogOutType_Ornit) {
        if !isLoggedIn_Ornit {
            showLoginPrompt_Ornit()
            return
        }
        
        // 重置为游客状态
        loggedUser_Ornit = defaultUser_Ornit
        
        // 清空AI聊天记录
        MessageViewModel_Ornit.shared_Ornit.clearAiChat_Ornit()
        
        // 重新初始化本地数据
        LocalData_Ornit.shared_Ornit.initData_Ornit()
        
        notifyStateChange_Ornit()
        
        // 跳转到首页
         Navigation_Ornit.switchToTabbar_Ornit()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_ornit == .delete_ornit {
                Utils_Ornit.showInfo_Ornit(
                    message_Ornit: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Ornit: 3.0
                )
            } else {
                Utils_Ornit.showSuccess_Ornit(message_Ornit: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    /// - Parameter headUrl_ornit: 新头像的本地文件路径
    func updateHead_Ornit(headUrl_ornit: String) {
        guard let user_ornit = loggedUser_Ornit else { return }
        user_ornit.userHead_Ornit = headUrl_ornit
        loggedUser_Ornit = user_ornit
        Utils_Ornit.showSuccess_Ornit(message_Ornit: "Avatar updated successfully")
        notifyStateChange_Ornit()     
    }

    /// 更新用户昵称
    /// - Parameter userName_ornit: 新昵称
    func updateName_Ornit(userName_ornit: String) {
        guard let user_ornit = loggedUser_Ornit else { return }
        user_ornit.userName_Ornit = userName_ornit
        loggedUser_Ornit = user_ornit
        Utils_Ornit.showSuccess_Ornit(message_Ornit: "Name updated successfully")
        notifyStateChange_Ornit()
    }

    /// 更新用户自我简介
    /// - Parameter introduce_ornit: 新简介内容（最多 100 字）
    func updateIntroduce_Ornit(introduce_ornit: String) {
        guard let user_ornit = loggedUser_Ornit else { return }
        user_ornit.userIntroduce_Ornit = introduce_ornit
        loggedUser_Ornit = user_ornit
        Utils_Ornit.showSuccess_Ornit(message_Ornit: "Bio updated successfully")
        notifyStateChange_Ornit()
    }
    
    /// 上传用户封面
    func uploadCover_Ornit(coverUrl_ornit: String) {
        Utils_Ornit.showSuccess_Ornit(message_Ornit: "Cover updated successfully")
        notifyStateChange_Ornit()
    }
    
    // MARK: - 打卡功能

    /// 检查今天是否已打卡（基于 checkInDates_Ornit 列表）
    func hasCheckedInToday_Ornit() -> Bool {
        let today_ornit = todayDateString_Ornit()
        return loggedUser_Ornit?.checkInDates_Ornit.contains(today_ornit) ?? false
    }

    /// 执行每日打卡
    func checkIn_Ornit() {
        guard isLoggedIn_Ornit else {
            showLoginPrompt_Ornit()
            return
        }
        if hasCheckedInToday_Ornit() {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "You have already checked in today.")
            return
        }
        loggedUser_Ornit?.checkInDates_Ornit.append(todayDateString_Ornit())
        Utils_Ornit.showSuccess_Ornit(
            message_Ornit: "Check-in successful!",
            image_Ornit: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Ornit()
    }

    /// 获取打卡日期列表
    func getCheckInDates_Ornit() -> [String] {
        return loggedUser_Ornit?.checkInDates_Ornit ?? []
    }

    /// 计算当前连续打卡天数
    /// - Returns: 连续天数（从今天往前连续有记录的天数）
    func getCheckInStreak_Ornit() -> Int {
        let dates_ornit = Set(getCheckInDates_Ornit())
        var streak_ornit = 0
        var date_ornit = Date()
        let fmt_ornit = DateFormatter()
        fmt_ornit.dateFormat = "yyyy-MM-dd"
        while dates_ornit.contains(fmt_ornit.string(from: date_ornit)) {
            streak_ornit += 1
            date_ornit = Calendar.current.date(byAdding: .day, value: -1, to: date_ornit) ?? date_ornit
        }
        return streak_ornit
    }

    /// 返回今天日期字符串（yyyy-MM-dd）
    private func todayDateString_Ornit() -> String {
        let fmt_ornit = DateFormatter()
        fmt_ornit.dateFormat = "yyyy-MM-dd"
        return fmt_ornit.string(from: Date())
    }

    // MARK: - 观鸟记录功能

    /// 添加一条观鸟记录
    /// - Parameter observation_ornit: 观鸟记录模型
    func addBirdObservation_Ornit(observation_ornit: BirdObservation_Ornit) {
        guard isLoggedIn_Ornit else {
            showLoginPrompt_Ornit()
            return
        }
        loggedUser_Ornit?.birdObservations_Ornit.append(observation_ornit)
        notifyStateChange_Ornit()
    }

    /// 获取当前用户的全部观鸟记录
    func getBirdObservations_Ornit() -> [BirdObservation_Ornit] {
        return loggedUser_Ornit?.birdObservations_Ornit ?? []
    }

    /// 删除指定 ID 的观鸟记录
    /// - Parameter observationId_ornit: 记录 ID
    func deleteBirdObservation_Ornit(observationId_ornit: Int) {
        loggedUser_Ornit?.birdObservations_Ornit.removeAll { $0.observationId_Ornit == observationId_ornit }
        notifyStateChange_Ornit()
    }

    /// 生成新观鸟记录 ID（当前记录数 + 1）
    func nextObservationId_Ornit() -> Int {
        return (loggedUser_Ornit?.birdObservations_Ornit.count ?? 0) + 1
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Ornit(user_ornit: PrewUserModel_Ornit) -> Bool {
        guard let loggedUser_ornit = loggedUser_Ornit else { return false }
        return loggedUser_ornit.userFollow_Ornit.contains(where: { $0.userId_Ornit == user_ornit.userId_Ornit })
    }
    
    /// 关注/取消关注用户
    func followUser_Ornit(user_ornit: PrewUserModel_Ornit) {
        if !isLoggedIn_Ornit {
            showLoginPrompt_Ornit()
            return
        }
        
        if isFollowing_Ornit(user_ornit: user_ornit) {
            // 取消关注
            loggedUser_Ornit?.userFollow_Ornit.removeAll { $0.userId_Ornit == user_ornit.userId_Ornit }
        } else {
            // 关注
            loggedUser_Ornit?.userFollow_Ornit.append(user_ornit)
        }
        
        notifyStateChange_Ornit()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Ornit(user_ornit: PrewUserModel_Ornit) {
        guard let userId_ornit = user_ornit.userId_Ornit else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Ornit.shared_Ornit.deleteUserMessages_Ornit(
            userId_ornit: userId_ornit
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Ornit.shared_Ornit.deleteUserPosts_Ornit(
            userId_ornit: userId_ornit
        )
        
        // 从本地用户列表中移除
        LocalData_Ornit.shared_Ornit.userList_Ornit.removeAll { $0.userId_Ornit == userId_ornit }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Ornit.showSuccess_Ornit(
                message_Ornit: "This user will no longer appear.",
                delay_Ornit: 2.0
            )
        }
        
        notifyStateChange_Ornit()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Ornit(userId_ornit: Int) -> Bool {
        return loggedUser_Ornit?.userId_Ornit == userId_ornit
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Ornit(userId_ornit: Int) -> PrewUserModel_Ornit {
        let users_ornit = LocalData_Ornit.shared_Ornit.userList_Ornit
        
        if let user_ornit = users_ornit.first(where: { $0.userId_Ornit == userId_ornit }) {
            return user_ornit
        }
        
        // 返回默认用户
        let defaultPrewUser_ornit = PrewUserModel_Ornit()
        defaultPrewUser_ornit.userId_Ornit = userId_ornit
        defaultPrewUser_ornit.userName_Ornit = "Guest"
        defaultPrewUser_ornit.userHead_Ornit = "default_avatar"
        return defaultPrewUser_ornit
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Ornit() -> [PrewUserModel_Ornit] {
        let users_ornit = LocalData_Ornit.shared_Ornit.userList_Ornit
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_ornit
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Ornit(post_ornit: TitleModel_Ornit) {
        guard let user_ornit = loggedUser_Ornit else { return }
        user_ornit.userPosts_Ornit.append(post_ornit)
        loggedUser_Ornit = user_ornit
        notifyStateChange_Ornit()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Ornit(post_ornit: TitleModel_Ornit) {
        guard let user_ornit = loggedUser_Ornit else { return }
        user_ornit.userPosts_Ornit.removeAll { $0.titleId_Ornit == post_ornit.titleId_Ornit }
        loggedUser_Ornit = user_ornit
        notifyStateChange_Ornit()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Ornit(post_ornit: TitleModel_Ornit) {
        guard let user_ornit = loggedUser_Ornit else { return }
        
        // 检查是否已存在
        if !user_ornit.userLike_Ornit.contains(where: { $0.titleId_Ornit == post_ornit.titleId_Ornit }) {
            user_ornit.userLike_Ornit.append(post_ornit)
            loggedUser_Ornit = user_ornit
            notifyStateChange_Ornit()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Ornit(post_ornit: TitleModel_Ornit) {
        guard let user_ornit = loggedUser_Ornit else { return }
        user_ornit.userLike_Ornit.removeAll { $0.titleId_Ornit == post_ornit.titleId_Ornit }
        loggedUser_Ornit = user_ornit
        notifyStateChange_Ornit()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Ornit(post_ornit: TitleModel_Ornit) -> Bool {
        guard let user_ornit = loggedUser_Ornit else { return false }
        return user_ornit.userLike_Ornit.contains { $0.titleId_Ornit == post_ornit.titleId_Ornit }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Ornit() {
        NotificationCenter.default.post(
            name: UserViewModel_Ornit.userStateDidChangeNotification_Ornit,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Ornit() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Ornit.toLogin_Ornit(style_ornit: .present_ornit)
        }
    }
}
