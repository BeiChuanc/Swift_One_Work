import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Sylva {
    /// 删除账号
    case delete_sylva
    /// 普通登出
    case logout_sylva
}

/// 用户状态管理类
@MainActor
class UserViewModel_Sylva {
    
    /// 单例
    static let shared_Sylva = UserViewModel_Sylva()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Sylva = Notification.Name("UserStateDidChange_Sylva")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Sylva: LoginUserModel_Sylva?
    
    /// 默认用户（游客）
    private let defaultUser_Sylva = LoginUserModel_Sylva(
        userId_Sylva: 0,
        userPwd_Sylva: nil,
        userName_Sylva: "Guest",
        userHead_Sylva: "default_avatar",
        userPosts_Sylva: [],
        userLike_Sylva: [],
        userFollow_Sylva: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Sylva: Bool {
        return loggedUser_Sylva?.userId_Sylva != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Sylva() -> LoginUserModel_Sylva {
        return loggedUser_Sylva ?? defaultUser_Sylva
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Sylva() {
        loggedUser_Sylva = defaultUser_Sylva
        notifyStateChange_Sylva()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录，优先从本地数据中查找用户信息
    func loginById_Sylva(userId_sylva: Int) {
        Utils_Sylva.showLoading_Sylva(message_Sylva: "Logging in...")
        
        // 从本地数据查找用户信息，若不存在则使用默认值
        let localUser_sylva = LocalData_Sylva.shared_Sylva.userList_Sylva
            .first(where: { $0.userId_Sylva == userId_sylva })
        
        loggedUser_Sylva = LoginUserModel_Sylva(
            userId_Sylva: userId_sylva,
            userPwd_Sylva: nil,
            userName_Sylva: localUser_sylva?.userName_Sylva ?? "TreePlanter",
            userIntroduce_Sylva: localUser_sylva?.userIntroduce_Sylva,
            userHead_Sylva: localUser_sylva?.userHead_Sylva ?? "user",
            userPosts_Sylva: [],
            userLike_Sylva: [],
            userFollow_Sylva: []
        )
        
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Utils_Sylva.dismissLoading_Sylva()
            Utils_Sylva.showSuccess_Sylva(message_Sylva: "Login successful!")
            Navigation_Sylva.switchToTabbar_Sylva(animated: true)
            notifyStateChange_Sylva()
        }
    }
    
    /// 注册新用户并返回新用户ID，调用方再使用 loginById_Sylva 完成登录
    /// - Parameters:
    ///   - userName_sylva: 用户名
    ///   - userPwd_sylva: 密码
    /// - Returns: 新用户ID
    @discardableResult
    func registerUser_Sylva(userName_sylva: String, userPwd_sylva: String) -> Int {
        let newId_sylva = (LocalData_Sylva.shared_Sylva.userList_Sylva.compactMap { $0.userId_Sylva }.max() ?? 14) + 1
        
        let newUser_sylva = PrewUserModel_Sylva(
            userId_Sylva: newId_sylva,
            userName_Sylva: userName_sylva,
            userIntroduce_Sylva: "Plant a tree, grow a future. 🌱",
            userHead_Sylva: "user",
            userMedia_Sylva: ["user"],
            userLike_Sylva: [],
            userFollow_Sylva: 0,
            userFans_Sylva: 0
        )
        LocalData_Sylva.shared_Sylva.userList_Sylva.append(newUser_sylva)
        return newId_sylva
    }
    
    /// 用户登出
    func logout_Sylva(logoutType_sylva: LogOutType_Sylva) {
        if !isLoggedIn_Sylva {
            showLoginPrompt_Sylva()
            return
        }
        
        // 重置为游客状态
        loggedUser_Sylva = defaultUser_Sylva
        
        // 清空AI聊天记录
        MessageViewModel_Sylva.shared_Sylva.clearAiChat_Sylva()
        
        // 重新初始化本地数据
        LocalData_Sylva.shared_Sylva.initData_Sylva()
        
        notifyStateChange_Sylva()
        
        // 跳转到首页
         Navigation_Sylva.switchToTabbar_Sylva()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_sylva == .delete_sylva {
                Utils_Sylva.showInfo_Sylva(
                    message_Sylva: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Sylva: 3.0
                )
            } else {
                Utils_Sylva.showSuccess_Sylva(message_Sylva: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Sylva(headUrl_sylva: String) {
        guard let user_sylva = loggedUser_Sylva else { return }
        user_sylva.userHead_Sylva = headUrl_sylva
        loggedUser_Sylva = user_sylva
        Utils_Sylva.showSuccess_Sylva(message_Sylva: "Avatar updated successfully")
        notifyStateChange_Sylva()
    }
    
    /// 更新用户昵称
    func updateName_Sylva(userName_sylva: String) {
        guard let user_sylva = loggedUser_Sylva else { return }
        user_sylva.userName_Sylva = userName_sylva
        loggedUser_Sylva = user_sylva
        Utils_Sylva.showSuccess_Sylva(message_Sylva: "Name updated successfully")
        notifyStateChange_Sylva()
    }
    
    /// 更新用户简介
    func updateIntroduce_Sylva(introduce_sylva: String) {
        guard let user_sylva = loggedUser_Sylva else { return }
        user_sylva.userIntroduce_Sylva = introduce_sylva
        loggedUser_Sylva = user_sylva
        Utils_Sylva.showSuccess_Sylva(message_Sylva: "Bio updated successfully")
        notifyStateChange_Sylva()
    }
    
    /// 上传用户封面
    func uploadCover_Sylva(coverUrl_sylva: String) {
        Utils_Sylva.showSuccess_Sylva(message_Sylva: "Cover updated successfully")
        notifyStateChange_Sylva()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Sylva() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Sylva(user_sylva: PrewUserModel_Sylva) -> Bool {
        guard let loggedUser_sylva = loggedUser_Sylva else { return false }
        return loggedUser_sylva.userFollow_Sylva.contains(where: { $0.userId_Sylva == user_sylva.userId_Sylva })
    }
    
    /// 关注/取消关注用户
    func followUser_Sylva(user_sylva: PrewUserModel_Sylva) {
        if !isLoggedIn_Sylva {
            showLoginPrompt_Sylva()
            return
        }
        
        if isFollowing_Sylva(user_sylva: user_sylva) {
            // 取消关注
            loggedUser_Sylva?.userFollow_Sylva.removeAll { $0.userId_Sylva == user_sylva.userId_Sylva }
        } else {
            // 关注
            loggedUser_Sylva?.userFollow_Sylva.append(user_sylva)
            // 任务进度：关注用户
            progressTask_Sylva(type_sylva: .followUser_Sylva)
        }

        notifyStateChange_Sylva()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Sylva(user_sylva: PrewUserModel_Sylva) {
        guard let userId_sylva = user_sylva.userId_Sylva else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Sylva.shared_Sylva.deleteUserMessages_Sylva(
            userId_sylva: userId_sylva
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Sylva.shared_Sylva.deleteUserPosts_Sylva(
            userId_sylva: userId_sylva
        )
        
        // 从本地用户列表中移除
        LocalData_Sylva.shared_Sylva.userList_Sylva.removeAll { $0.userId_Sylva == userId_sylva }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Sylva.showSuccess_Sylva(
                message_Sylva: "This user will no longer appear.",
                delay_Sylva: 2.0
            )
        }
        
        notifyStateChange_Sylva()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Sylva(userId_sylva: Int) -> Bool {
        return loggedUser_Sylva?.userId_Sylva == userId_sylva
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Sylva(userId_sylva: Int) -> PrewUserModel_Sylva {
        let users_sylva = LocalData_Sylva.shared_Sylva.userList_Sylva
        
        if let user_sylva = users_sylva.first(where: { $0.userId_Sylva == userId_sylva }) {
            return user_sylva
        }
        
        // 返回默认用户
        let defaultPrewUser_sylva = PrewUserModel_Sylva()
        defaultPrewUser_sylva.userId_Sylva = userId_sylva
        defaultPrewUser_sylva.userName_Sylva = "Guest"
        defaultPrewUser_sylva.userHead_Sylva = "default_avatar"
        return defaultPrewUser_sylva
    }
    
    /// 获取推荐用户列表（排除登录用户自身）
    func getRecommendUsers_Sylva() -> [PrewUserModel_Sylva] {
        let currentId_sylva = getCurrentUser_Sylva().userId_Sylva
        return LocalData_Sylva.shared_Sylva.userList_Sylva.filter {
            $0.userId_Sylva != currentId_sylva
        }
    }
    
    /// 根据用户名查找用户ID（用于账号密码登录场景）
    func findUserIdByName_Sylva(name_sylva: String) -> Int? {
        return LocalData_Sylva.shared_Sylva.userList_Sylva
            .first(where: { $0.userName_Sylva == name_sylva })?.userId_Sylva
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Sylva(post_sylva: TitleModel_Sylva) {
        guard let user_sylva = loggedUser_Sylva else { return }
        user_sylva.userPosts_Sylva.append(post_sylva)
        loggedUser_Sylva = user_sylva
        notifyStateChange_Sylva()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Sylva(post_sylva: TitleModel_Sylva) {
        guard let user_sylva = loggedUser_Sylva else { return }
        user_sylva.userPosts_Sylva.removeAll { $0.titleId_Sylva == post_sylva.titleId_Sylva }
        loggedUser_Sylva = user_sylva
        notifyStateChange_Sylva()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Sylva(post_sylva: TitleModel_Sylva) {
        guard let user_sylva = loggedUser_Sylva else { return }
        
        // 检查是否已存在
        if !user_sylva.userLike_Sylva.contains(where: { $0.titleId_Sylva == post_sylva.titleId_Sylva }) {
            user_sylva.userLike_Sylva.append(post_sylva)
            loggedUser_Sylva = user_sylva
            notifyStateChange_Sylva()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Sylva(post_sylva: TitleModel_Sylva) {
        guard let user_sylva = loggedUser_Sylva else { return }
        user_sylva.userLike_Sylva.removeAll { $0.titleId_Sylva == post_sylva.titleId_Sylva }
        loggedUser_Sylva = user_sylva
        notifyStateChange_Sylva()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Sylva(post_sylva: TitleModel_Sylva) -> Bool {
        guard let user_sylva = loggedUser_Sylva else { return false }
        return user_sylva.userLike_Sylva.contains { $0.titleId_Sylva == post_sylva.titleId_Sylva }
    }
    
    // MARK: - 生态任务 & 打卡

    /// 获取当前有效的每日任务列表（若日期已过则自动重置）
    func getEcoTasks_Sylva() -> [EcoTask_Sylva] {
        guard let user_sylva = loggedUser_Sylva else { return [] }
        let today_sylva = EcoTask_Sylva.todayString_Sylva()
        // 检查第一个任务的日期，若不是今天则全部重置
        if user_sylva.ecoTasks_Sylva.isEmpty || user_sylva.ecoTasks_Sylva[0].taskDate_Sylva != today_sylva {
            let freshTasks_sylva = LocalData_Sylva.shared_Sylva.makeDefaultEcoTasks_Sylva()
            user_sylva.ecoTasks_Sylva = freshTasks_sylva
            loggedUser_Sylva = user_sylva
        }
        return user_sylva.ecoTasks_Sylva
    }

    /// 推进指定类型任务的进度（完成一次操作）
    /// - Parameter type_sylva: 触发的任务类型
    func progressTask_Sylva(type_sylva: TaskType_Sylva) {
        guard let user_sylva = loggedUser_Sylva else { return }
        _ = getEcoTasks_Sylva()  // 确保任务已初始化/重置
        let bonus_sylva = user_sylva.checkInRecord_Sylva.bonusMultiplier_Sylva

        var changed_sylva = false
        for task_sylva in user_sylva.ecoTasks_Sylva where task_sylva.taskType_Sylva == type_sylva && !task_sylva.isCompleted_Sylva {
            task_sylva.currentCount_Sylva += 1
            if task_sylva.currentCount_Sylva >= task_sylva.requiredCount_Sylva {
                task_sylva.isCompleted_Sylva = true
                // 计算实际奖励（含打卡加成）
                let earned_sylva = Int(Double(task_sylva.ecoPoints_Sylva) * bonus_sylva)
                user_sylva.totalEcoPoints_Sylva += earned_sylva
            }
            changed_sylva = true
            break  // 每次只推进一个同类任务
        }
        if changed_sylva {
            loggedUser_Sylva = user_sylva
            notifyStateChange_Sylva()
        }
    }

    /// 获取总环保值
    func getTotalEcoPoints_Sylva() -> Int {
        return loggedUser_Sylva?.totalEcoPoints_Sylva ?? 0
    }

    /// 执行每日打卡
    /// - Returns: 打卡是否成功（今日未打卡才能成功）
    @discardableResult
    func checkIn_Sylva() -> Bool {
        guard let user_sylva = loggedUser_Sylva else { return false }
        let record_sylva = user_sylva.checkInRecord_Sylva
        guard !record_sylva.hasCheckedInToday_Sylva else { return false }

        let today_sylva = EcoTask_Sylva.todayString_Sylva()
        // 判断是否连续：昨天也打了卡
        let yesterday_sylva = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let yFormatter_sylva = DateFormatter()
        yFormatter_sylva.dateFormat = "yyyy-MM-dd"
        let yesterdayStr_sylva = yFormatter_sylva.string(from: yesterday_sylva ?? Date())

        if record_sylva.lastCheckInDate_Sylva == yesterdayStr_sylva {
            record_sylva.consecutiveDays_Sylva += 1
        } else {
            record_sylva.consecutiveDays_Sylva = 1
        }
        record_sylva.lastCheckInDate_Sylva = today_sylva
        record_sylva.totalCheckIns_Sylva += 1

        // 打卡本身也奖励环保值（5pt）
        user_sylva.totalEcoPoints_Sylva += 5
        user_sylva.checkInRecord_Sylva = record_sylva
        loggedUser_Sylva = user_sylva
        notifyStateChange_Sylva()
        return true
    }

    /// 获取打卡记录
    func getCheckInRecord_Sylva() -> CheckInRecord_Sylva {
        return loggedUser_Sylva?.checkInRecord_Sylva ?? CheckInRecord_Sylva()
    }

    // MARK: - 私有方法 - 工具方法

    /// 发送状态更新通知
    private func notifyStateChange_Sylva() {
        NotificationCenter.default.post(
            name: UserViewModel_Sylva.userStateDidChangeNotification_Sylva,
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
