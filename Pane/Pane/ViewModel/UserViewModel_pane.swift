import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Pane {
    /// 删除账号
    case delete_pane
    /// 普通登出
    case logout_pane
}

/// 用户状态管理类
@MainActor
class UserViewModel_Pane {
    
    /// 单例
    static let shared_Pane = UserViewModel_Pane()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Pane = Notification.Name("UserStateDidChange_Pane")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Pane: LoginUserModel_Pane?
    
    /// 默认用户（游客）
    private let defaultUser_Pane = LoginUserModel_Pane(
        userId_Pane: 0,
        userName_Pane: "Guest",
        userHead_Pane: "default_avatar",
        userPosts_Pane: [],
        userLike_Pane: [],
        userFollow_Pane: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录（用户 ID 存在且不为 0）
    var isLoggedIn_Pane: Bool {
        guard let uid_pane = loggedUser_Pane?.userId_Pane else { return false }
        return uid_pane != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Pane() -> LoginUserModel_Pane {
        return loggedUser_Pane ?? defaultUser_Pane
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Pane() {
        loggedUser_Pane = defaultUser_Pane
        notifyStateChange_Pane()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Pane(userId_pane: Int) {
        // 显示加载动画
        Utils_Pane.showLoading_Pane(message_Pane: "Logging in...")
        
        // 从本地数据取用户信息，无则使用默认值
        let prewUser_pane = LocalData_Pane.shared_Pane.userList_Pane
            .first(where: { $0.userId_Pane == userId_pane })
        loggedUser_Pane = LoginUserModel_Pane(
            userId_Pane: userId_pane,
            userName_Pane: prewUser_pane?.userName_Pane ?? "Paner",
            userHead_Pane: prewUser_pane?.userHead_Pane ?? "user_avatar",
            userPosts_Pane: [],
            userLike_Pane: [],
            userFollow_Pane: []
        )

        // 首次登录时预置 Demo 打卡历史，让日历热力图立即有色彩可渲染
        let storageKey_pane = "pane_checkin_\(userId_pane)"
        if (UserDefaults.standard.stringArray(forKey: storageKey_pane) ?? []).isEmpty {
            seedDemoCheckInDates_Pane(storageKey_pane: storageKey_pane)
        }
        // 将 UserDefaults 中的历史同步到内存模型
        let storedDates_pane = UserDefaults.standard.stringArray(forKey: storageKey_pane) ?? []
        loggedUser_Pane?.userCheckInDates_Pane = storedDates_pane
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Pane.dismissLoading_Pane()
            
            // 显示成功提示
            Utils_Pane.showSuccess_Pane(message_Pane: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Pane.switchToTabbar_Pane(animated: true)
            
            notifyStateChange_Pane()
        }
    }

    /// 为首次登录的 Demo 用户预置近 60 天的打卡历史（模拟真实打卡习惯：多天打卡、随机断档）
    /// - Parameter storageKey_pane: 对应用户的 UserDefaults 存储键
    private func seedDemoCheckInDates_Pane(storageKey_pane: String) {
        let f_pane = DateFormatter()
        f_pane.dateFormat = "yyyy-MM-dd"
        let calendar_pane = Calendar.current

        // 跳过天数序列：模拟真实习惯（每隔几天偶尔缺勤）
        let skipOffsets_pane: Set<Int> = [3, 7, 12, 18, 24, 31, 38, 44, 52, 58]
        var dates_pane: [String] = []

        for i_pane in 0..<60 {
            guard !skipOffsets_pane.contains(i_pane) else { continue }
            guard let date_pane = calendar_pane.date(byAdding: .day, value: -i_pane, to: Date()) else { continue }
            dates_pane.append(f_pane.string(from: date_pane))
        }

        UserDefaults.standard.set(dates_pane, forKey: storageKey_pane)
        print("Demo 打卡历史已预置，共 \(dates_pane.count) 天")
    }
    
    /// 用户登出
    func logout_Pane(logoutType_pane: LogOutType_Pane) {
        if !isLoggedIn_Pane {
            showLoginPrompt_Pane()
            return
        }
        
        // 重置为游客状态
        loggedUser_Pane = defaultUser_Pane
        
        // 清空AI聊天记录
        MessageViewModel_Pane.shared_Pane.clearAiChat_Pane()
        
        // 重新初始化本地数据
        LocalData_Pane.shared_Pane.initData_Pane()
        
        notifyStateChange_Pane()
        
        // 跳转到首页
         Navigation_Pane.switchToTabbar_Pane()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            if logoutType_pane == .delete_pane {
                Utils_Pane.showInfo_Pane(
                    message_Pane: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Pane: 3.0
                )
            } else {
                Utils_Pane.showSuccess_Pane(message_Pane: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Pane(headUrl_pane: String) {
        guard let user_pane = loggedUser_Pane else { return }
        user_pane.userHead_Pane = headUrl_pane
        loggedUser_Pane = user_pane
        Utils_Pane.showSuccess_Pane(message_Pane: "Avatar updated successfully")
        notifyStateChange_Pane()
    }
    
    /// 更新用户昵称
    func updateName_Pane(userName_pane: String) {
        guard let user_pane = loggedUser_Pane else { return }
        user_pane.userName_Pane = userName_pane
        loggedUser_Pane = user_pane
        Utils_Pane.showSuccess_Pane(message_Pane: "Name updated successfully")
        notifyStateChange_Pane()
    }

    /// 更新用户简介
    func updateIntroduce_Pane(introduce_pane: String) {
        guard let user_pane = loggedUser_Pane else { return }
        user_pane.userIntroduce_Pane = introduce_pane
        loggedUser_Pane = user_pane
        Utils_Pane.showSuccess_Pane(message_Pane: "Bio updated successfully")
        notifyStateChange_Pane()
    }
    
    /// 上传用户封面
    func uploadCover_Pane(coverUrl_pane: String) {
        Utils_Pane.showSuccess_Pane(message_Pane: "Cover updated successfully")
        notifyStateChange_Pane()
    }
    
    // MARK: - 模型持久化辅助

    /// 返回今日日期字符串（yyyy-MM-dd）
    func todayDateString_Pane() -> String {
        let f_pane = DateFormatter()
        f_pane.dateFormat = "yyyy-MM-dd"
        return f_pane.string(from: Date())
    }

    /// 将当前用户的打卡日期列表更新到模型字段（供外部同步调用）
    /// - Parameter dates_pane: 新的打卡日期数组
    func updateCheckInDatesInModel_Pane(dates_pane: [String]) {
        loggedUser_Pane?.userCheckInDates_Pane = dates_pane
    }

    /// 将当前用户的窗景册列表同步到模型字段
    /// - Parameter albums_pane: 最新的窗景册数组
    func updateAlbumsInModel_Pane(albums_pane: [WindowAlbum_Pane]) {
        loggedUser_Pane?.userWindowAlbums_Pane = albums_pane
        notifyStateChange_Pane()
    }

    // MARK: - 打卡功能

    /// 当前用户打卡记录的 UserDefaults 备份存储键（按用户 ID 隔离）
    private func checkInStorageKey_Pane() -> String {
        let uid_pane = getCurrentUser_Pane().userId_Pane ?? 0
        return "pane_checkin_\(uid_pane)"
    }

    /// 获取全部已打卡日期字符串数组
    /// 优先从登录用户模型字段读取，模型字段为空时回退到 UserDefaults
    func getCheckInDates_Pane() -> [String] {
        guard isLoggedIn_Pane else { return [] }
        let modelDates_pane = loggedUser_Pane?.userCheckInDates_Pane ?? []
        if !modelDates_pane.isEmpty { return modelDates_pane }
        return UserDefaults.standard.stringArray(forKey: checkInStorageKey_Pane()) ?? []
    }

    /// 检查今天是否已打卡（未登录时返回 false）
    func hasCheckedInToday_Pane() -> Bool {
        guard isLoggedIn_Pane else { return false }
        return getCheckInDates_Pane().contains(todayDateString_Pane())
    }

    /// 执行今日打卡
    /// 功能：未登录时提示跳转登录；今日已打卡时给出提示；否则同时写入模型字段和 UserDefaults
    func checkIn_Pane() {
        guard isLoggedIn_Pane else {
            showLoginPrompt_Pane()
            return
        }
        if hasCheckedInToday_Pane() {
            Utils_Pane.showWarning_Pane(message_Pane: "You have already checked in today.")
            return
        }
        var dates_pane = getCheckInDates_Pane()
        dates_pane.append(todayDateString_Pane())
        // 同步写入模型字段和 UserDefaults 备份
        loggedUser_Pane?.userCheckInDates_Pane = dates_pane
        UserDefaults.standard.set(dates_pane, forKey: checkInStorageKey_Pane())
        Utils_Pane.showSuccess_Pane(
            message_Pane: "Check-in successful!",
            image_Pane: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Pane()
    }

    /// 计算当前连续打卡天数（从今日或昨日向前连续统计）
    /// - Returns: 连续天数，0 表示无连续记录
    func getCheckInStreak_Pane() -> Int {
        guard isLoggedIn_Pane else { return 0 }
        let checkedSet_pane = Set(getCheckInDates_Pane())
        let calendar_pane   = Calendar.current
        let f_pane          = DateFormatter()
        f_pane.dateFormat   = "yyyy-MM-dd"
        var streak_pane     = 0
        var date_pane       = Date()
        // 若今天未打卡，从昨天开始回溯
        if !hasCheckedInToday_Pane() {
            guard let yesterday_pane = calendar_pane.date(byAdding: .day, value: -1, to: date_pane) else { return 0 }
            date_pane = yesterday_pane
        }
        while checkedSet_pane.contains(f_pane.string(from: date_pane)) {
            streak_pane += 1
            guard let prev_pane = calendar_pane.date(byAdding: .day, value: -1, to: date_pane) else { break }
            date_pane = prev_pane
        }
        return streak_pane
    }

    /// 获取指定年月的打卡日历数据（从登录用户模型拓展字段 userCheckInDates_Pane 读取）
    /// - Parameters:
    ///   - year_pane: 目标年份
    ///   - month_pane: 目标月份（1-12）
    /// - Returns: 字典，键为日（1-31），值为打卡次数（通常为 0 或 1，每天最多打卡一次）
    func getCheckInCalendarData_Pane(year_pane: Int, month_pane: Int) -> [Int: Int] {
        guard isLoggedIn_Pane else { return [:] }
        let dates_pane = getCheckInDates_Pane()
        let f_pane = DateFormatter()
        f_pane.dateFormat = "yyyy-MM-dd"
        var result_pane: [Int: Int] = [:]
        for dateStr_pane in dates_pane {
            guard let date_pane = f_pane.date(from: dateStr_pane) else { continue }
            let comps_pane = Calendar.current.dateComponents([.year, .month, .day], from: date_pane)
            guard comps_pane.year  == year_pane,
                  comps_pane.month == month_pane,
                  let day_pane = comps_pane.day else { continue }
            result_pane[day_pane, default: 0] += 1
        }
        return result_pane
    }

    /// 获取最近 N 天的打卡状态记录（用于首页条带和打卡页面展示）
    /// - Parameter days_pane: 要展示的天数（7 或 15）
    /// - Returns: 从最早到最新的 (date, checked, isToday) 元组数组
    func getCheckInRecord_Pane(days_pane: Int) -> [(date: String, checked: Bool, isToday: Bool)] {
        guard isLoggedIn_Pane else { return [] }
        let checkedSet_pane = Set(getCheckInDates_Pane())
        let calendar_pane   = Calendar.current
        let f_pane          = DateFormatter()
        f_pane.dateFormat   = "yyyy-MM-dd"
        let today_pane      = f_pane.string(from: Date())
        var result_pane: [(date: String, checked: Bool, isToday: Bool)] = []
        for i_pane in stride(from: days_pane - 1, through: 0, by: -1) {
            guard let date_pane = calendar_pane.date(byAdding: .day, value: -i_pane, to: Date()) else { continue }
            let str_pane = f_pane.string(from: date_pane)
            result_pane.append((date: str_pane, checked: checkedSet_pane.contains(str_pane), isToday: str_pane == today_pane))
        }
        return result_pane
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_pane: 要判断的目标用户
    /// - Returns: 当前登录用户是否关注了该用户
    func isFollowing_Pane(user_pane: PrewUserModel_Pane) -> Bool {
        guard let currentUser_pane = loggedUser_Pane else { return false }
        return currentUser_pane.userFollow_Pane.contains(where: { $0.userId_Pane == user_pane.userId_Pane })
    }
    
    /// 关注/取消关注用户
    func followUser_Pane(user_pane: PrewUserModel_Pane) {
        if !isLoggedIn_Pane {
            showLoginPrompt_Pane()
            return
        }
        
        if isFollowing_Pane(user_pane: user_pane) {
            // 取消关注
            loggedUser_Pane?.userFollow_Pane.removeAll { $0.userId_Pane == user_pane.userId_Pane }
        } else {
            // 关注
            loggedUser_Pane?.userFollow_Pane.append(user_pane)
        }
        
        notifyStateChange_Pane()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Pane(user_pane: PrewUserModel_Pane) {
        guard let userId_pane = user_pane.userId_Pane else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Pane.shared_Pane.deleteUserMessages_Pane(
            userId_pane: userId_pane
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Pane.shared_Pane.deleteUserPosts_Pane(
            userId_pane: userId_pane
        )
        
        // 从本地用户列表中移除
        LocalData_Pane.shared_Pane.userList_Pane.removeAll { $0.userId_Pane == userId_pane }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Pane.showSuccess_Pane(
                message_Pane: "This user will no longer appear.",
                delay_Pane: 2.0
            )
        }
        
        notifyStateChange_Pane()
    }
    
    // MARK: - 账号登录 / 注册

    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Pane(userId_pane: Int) -> Bool {
        return loggedUser_Pane?.userId_Pane == userId_pane
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Pane(userId_pane: Int) -> PrewUserModel_Pane {
        let users_pane = LocalData_Pane.shared_Pane.userList_Pane
        
        if let user_pane = users_pane.first(where: { $0.userId_Pane == userId_pane }) {
            return user_pane
        }
        
        // 返回默认用户
        let defaultPrewUser_pane = PrewUserModel_Pane()
        defaultPrewUser_pane.userId_Pane = userId_pane
        defaultPrewUser_pane.userName_Pane = "Guest"
        defaultPrewUser_pane.userHead_Pane = "default_avatar"
        return defaultPrewUser_pane
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Pane() -> [PrewUserModel_Pane] {
        let users_pane = LocalData_Pane.shared_Pane.userList_Pane
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_pane
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Pane(post_pane: TitleModel_Pane) {
        guard let user_pane = loggedUser_Pane else { return }
        user_pane.userPosts_Pane.append(post_pane)
        loggedUser_Pane = user_pane
        notifyStateChange_Pane()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Pane(post_pane: TitleModel_Pane) {
        guard let user_pane = loggedUser_Pane else { return }
        user_pane.userPosts_Pane.removeAll { $0.titleId_Pane == post_pane.titleId_Pane }
        loggedUser_Pane = user_pane
        notifyStateChange_Pane()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Pane(post_pane: TitleModel_Pane) {
        guard let user_pane = loggedUser_Pane else { return }
        
        // 检查是否已存在
        if !user_pane.userLike_Pane.contains(where: { $0.titleId_Pane == post_pane.titleId_Pane }) {
            user_pane.userLike_Pane.append(post_pane)
            loggedUser_Pane = user_pane
            notifyStateChange_Pane()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Pane(post_pane: TitleModel_Pane) {
        guard let user_pane = loggedUser_Pane else { return }
        user_pane.userLike_Pane.removeAll { $0.titleId_Pane == post_pane.titleId_Pane }
        loggedUser_Pane = user_pane
        notifyStateChange_Pane()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Pane(post_pane: TitleModel_Pane) -> Bool {
        guard let user_pane = loggedUser_Pane else { return false }
        return user_pane.userLike_Pane.contains { $0.titleId_Pane == post_pane.titleId_Pane }
    }
    
    // MARK: - 发现页相关
    
    /// 获取发现页用户列表（排除当前登录用户）
    /// - Returns: 预制用户数组，若已登录则排除自身
    func getDiscoverUsers_Pane() -> [PrewUserModel_Pane] {
        let all_pane = LocalData_Pane.shared_Pane.userList_Pane
        guard isLoggedIn_Pane, let currentId_pane = loggedUser_Pane?.userId_Pane else {
            return all_pane
        }
        return all_pane.filter { $0.userId_Pane != currentId_pane }
    }

    /// 按关键词搜索用户（用户名模糊匹配）
    /// - Parameter keyword_pane: 搜索关键词，为空时返回全部预制用户
    /// - Returns: 用户名包含关键词的用户数组
    func searchUsers_Pane(keyword_pane: String) -> [PrewUserModel_Pane] {
        let kw_pane = keyword_pane.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !kw_pane.isEmpty else { return LocalData_Pane.shared_Pane.userList_Pane }
        let lower_pane = kw_pane.lowercased()
        return LocalData_Pane.shared_Pane.userList_Pane.filter {
            ($0.userName_Pane ?? "").lowercased().contains(lower_pane) ||
            ($0.userIntroduce_Pane ?? "").lowercased().contains(lower_pane)
        }
    }

    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Pane() {
        NotificationCenter.default.post(
            name: UserViewModel_Pane.userStateDidChangeNotification_Pane,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Pane() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Pane.toLogin_Pane(style_pane: .present_pane)
        }
    }
}
