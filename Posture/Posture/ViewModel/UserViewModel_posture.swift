import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Posture {
    /// 删除账号
    case delete_posture
    /// 普通登出
    case logout_posture
}

/// 用户状态管理类
/// 核心作用：统一管理登录用户信息、打卡记录、体态档案及关注/点赞等行为
/// 设计思路：单例模式，所有状态变更通过 NotificationCenter 广播，页面响应刷新
/// 关键属性：loggedUser_Posture 存储当前用户，UserDefaults 持久化打卡和档案数据
@MainActor
class UserViewModel_Posture {

    /// 单例
    static let shared_Posture = UserViewModel_Posture()

    // MARK: - 通知名称

    /// 用户状态更新通知
    static let userStateDidChangeNotification_Posture = Notification.Name("UserStateDidChange_Posture")

    /// 体态档案更新通知
    static let planProfileDidChangeNotification_Posture = Notification.Name("PlanProfileDidChange_Posture")

    // MARK: - UserDefaults 键

    /// UserDefaults 存储键
    private struct UDKey_Posture {
        /// 打卡日期数组键（存储 "yyyy-MM-dd" 字符串数组）
        static let checkInDates_Posture = "checkInDates_posture"
        /// 体态档案键（存储 PosturePlanProfile_Posture JSON 数据）
        static let planProfile_Posture  = "planProfile_posture"
    }

    // MARK: - 私有属性

    /// 当前登录用户
    private var loggedUser_Posture: LoginUserModel_Posture?

    /// 默认用户（游客）
    private let defaultUser_Posture = LoginUserModel_Posture(
        userId_Posture: 0,
        userPwd_Posture: nil,
        userName_Posture: "Guest",
        userHead_Posture: "default_avatar",
        userIntroduce_Posture: "Ready to improve posture with tiny habits.",
        userPosts_Posture: [],
        userLike_Posture: [],
        userFollow_Posture: []
    )

    private init() {}

    // MARK: - 公共属性

    /// 是否已登录
    var isLoggedIn_Posture: Bool {
        return loggedUser_Posture?.userId_Posture != 0
    }

    /// 获取当前用户
    func getCurrentUser_Posture() -> LoginUserModel_Posture {
        return loggedUser_Posture ?? defaultUser_Posture
    }

    // MARK: - 初始化

    /// 初始化用户状态（启动时调用）
    func initUser_Posture() {
        loggedUser_Posture = defaultUser_Posture
        notifyStateChange_Posture()
    }

    // MARK: - 登录/登出

    /// 通过用户ID登录
    /// - Parameter userId_posture: 用户ID
    func loginById_Posture(userId_posture: Int) {
        Utils_Posture.showLoading_Posture(message_Posture: "Logging in...")

        loggedUser_Posture = LoginUserModel_Posture(
            userId_Posture: userId_posture,
            userPwd_Posture: nil,
            userName_Posture: "Wanderer",
            userHead_Posture: "user_avatar",
            userIntroduce_Posture: "Building better posture one mindful break at a time.",
            userPosts_Posture: [],
            userLike_Posture: [],
            userFollow_Posture: []
        )

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Utils_Posture.dismissLoading_Posture()
            Utils_Posture.showSuccess_Posture(message_Posture: "Login successful!")
            Navigation_Posture.switchToTabbar_Posture(animated: true)
            notifyStateChange_Posture()
        }
    }

    /// 用户登出
    /// - Parameter logoutType_posture: 登出类型（普通登出 or 删除账号）
    func logout_Posture(logoutType_posture: LogOutType_Posture) {
        if !isLoggedIn_Posture {
            showLoginPrompt_Posture()
            return
        }

        loggedUser_Posture = defaultUser_Posture
        MessageViewModel_Posture.shared_Posture.clearAiChat_Posture()
        LocalData_Posture.shared_Posture.initData_Posture()
        notifyStateChange_Posture()
        Navigation_Posture.switchToTabbar_Posture()

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_posture == .delete_posture {
                Utils_Posture.showInfo_Posture(
                    message_Posture: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Posture: 3.0
                )
            } else {
                Utils_Posture.showSuccess_Posture(message_Posture: "Logout successful")
            }
        }
    }

    // MARK: - 用户信息更新

    /// 更新用户头像
    /// - Parameter headUrl_posture: 头像路径或URL
    func updateHead_Posture(headUrl_posture: String) {
        guard let user_posture = loggedUser_Posture else { return }
        user_posture.userHead_Posture = headUrl_posture
        loggedUser_Posture = user_posture
        Utils_Posture.showSuccess_Posture(message_Posture: "Avatar updated successfully")
        notifyStateChange_Posture()
    }

    /// 更新用户昵称
    /// - Parameter userName_posture: 新昵称
    func updateName_Posture(userName_posture: String) {
        guard let user_posture = loggedUser_Posture else { return }
        user_posture.userName_Posture = userName_posture
        loggedUser_Posture = user_posture
        Utils_Posture.showSuccess_Posture(message_Posture: "Name updated successfully")
        notifyStateChange_Posture()
    }

    /// 更新用户简介
    /// - Parameter introduce_posture: 新的用户简介
    func updateIntroduce_Posture(introduce_posture: String) {
        guard let user_posture = loggedUser_Posture else { return }
        user_posture.userIntroduce_Posture = introduce_posture
        loggedUser_Posture = user_posture
        Utils_Posture.showSuccess_Posture(message_Posture: "Profile updated successfully")
        notifyStateChange_Posture()
    }

    /// 上传用户封面
    /// - Parameter coverUrl_posture: 封面路径
    func uploadCover_Posture(coverUrl_posture: String) {
        Utils_Posture.showSuccess_Posture(message_Posture: "Cover updated successfully")
        notifyStateChange_Posture()
    }

    // MARK: - 打卡功能

    /// 检查今天是否已打卡
    /// - Returns: Bool - 今日是否已有打卡记录
    func hasCheckedInToday_Posture() -> Bool {
        let dates_posture = loadCheckInDates_Posture()
        return dates_posture.contains(todayDateString_Posture())
    }

    /// 执行打卡：将今日日期写入 UserDefaults，并计算连续天数后提示
    func checkIn_Posture() {
        if hasCheckedInToday_Posture() {
            Utils_Posture.showWarning_Posture(message_Posture: "You have already checked in today.")
            return
        }
        var dates_posture = loadCheckInDates_Posture()
        dates_posture.append(todayDateString_Posture())
        saveCheckInDates_Posture(dates_posture: dates_posture)

        let streak_posture = getCheckInStreak_Posture()
        Utils_Posture.showSuccess_Posture(
            message_Posture: "Check-in successful! \(streak_posture)-day streak",
            image_Posture: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Posture()
    }

    /// 获取连续打卡天数（从今天往前统计）
    /// - Returns: Int - 连续打卡天数
    func getCheckInStreak_Posture() -> Int {
        let dates_posture = loadCheckInDates_Posture()
        guard !dates_posture.isEmpty else { return 0 }
        let calendar_posture = Calendar.current
        var streak_posture = 0
        var checkDate_posture = Date()
        while true {
            let str_posture = dateToString_Posture(date_posture: checkDate_posture)
            if dates_posture.contains(str_posture) {
                streak_posture += 1
                checkDate_posture = calendar_posture.date(byAdding: .day, value: -1, to: checkDate_posture) ?? checkDate_posture
            } else {
                break
            }
        }
        return streak_posture
    }

    /// 获取最近 N 天打卡状态数组（下标0为最远日，末尾为今天）
    /// - Parameter days_posture: 天数，默认7
    /// - Returns: [Bool] - 对应每天是否已打卡
    func getRecentCheckInBoolArray_Posture(days_posture: Int = 7) -> [Bool] {
        let dates_posture = loadCheckInDates_Posture()
        let calendar_posture = Calendar.current
        return (0..<days_posture).reversed().map { offset_posture in
            let date_posture = calendar_posture.date(byAdding: .day, value: -offset_posture, to: Date()) ?? Date()
            return dates_posture.contains(dateToString_Posture(date_posture: date_posture))
        }
    }

    // MARK: - 体态计划档案

    /// 保存用户体态档案至 UserDefaults，并发出档案变更通知
    /// - Parameter profile_posture: 待保存的体态档案
    func savePlanProfile_Posture(profile_posture: PosturePlanProfile_Posture) {
        if let data_posture = try? JSONEncoder().encode(profile_posture) {
            UserDefaults.standard.set(data_posture, forKey: UDKey_Posture.planProfile_Posture)
        }
        NotificationCenter.default.post(name: UserViewModel_Posture.planProfileDidChangeNotification_Posture, object: nil)
        notifyStateChange_Posture()
    }

    /// 从 UserDefaults 读取用户体态档案
    /// - Returns: PosturePlanProfile_Posture? - 无档案时返回 nil
    func getPlanProfile_Posture() -> PosturePlanProfile_Posture? {
        guard let data_posture = UserDefaults.standard.data(forKey: UDKey_Posture.planProfile_Posture),
              let profile_posture = try? JSONDecoder().decode(PosturePlanProfile_Posture.self, from: data_posture) else {
            return nil
        }
        return profile_posture
    }

    /// 根据体态档案生成每日推荐列表（最多3条）
    /// - Returns: [DailyRecommendation_Posture] - 无档案时返回空数组
    func getDailyRecommendations_Posture() -> [DailyRecommendation_Posture] {
        guard let profile_posture = getPlanProfile_Posture() else { return [] }
        var items_posture: [DailyRecommendation_Posture] = []

        // 根据短板（最多取前2个）生成对应建议
        for weakness_posture in profile_posture.weaknesses_Posture.prefix(2) {
            switch weakness_posture {
            case PostureWeakness_Posture.neck_posture.rawValue:
                items_posture.append(DailyRecommendation_Posture(
                    title_Posture: "Chin Tuck",
                    detail_Posture: "Pull chin back to align your neck. Hold 5s, repeat 10×.",
                    duration_Posture: "3 min",
                    icon_Posture: "figure.cooldown"
                ))
            case PostureWeakness_Posture.upperBack_posture.rawValue:
                items_posture.append(DailyRecommendation_Posture(
                    title_Posture: "Blade Squeeze",
                    detail_Posture: "Pull shoulder blades together. Hold 5s, repeat 15×.",
                    duration_Posture: "4 min",
                    icon_Posture: "figure.strengthtraining.traditional"
                ))
            case PostureWeakness_Posture.lowerBack_posture.rawValue:
                items_posture.append(DailyRecommendation_Posture(
                    title_Posture: "Cat-Cow Flow",
                    detail_Posture: "Alternate arching and rounding your lower back. 10 slow cycles.",
                    duration_Posture: "5 min",
                    icon_Posture: "figure.flexibility"
                ))
            case PostureWeakness_Posture.hips_posture.rawValue:
                items_posture.append(DailyRecommendation_Posture(
                    title_Posture: "Hip Release",
                    detail_Posture: "Lunge forward to release hip flexors. Hold 30s each side.",
                    duration_Posture: "6 min",
                    icon_Posture: "figure.walk"
                ))
            default:
                break
            }
        }

        // 久坐时长 ≥ 6 小时则追加桌面提醒
        if profile_posture.dailySittingHours_Posture >= 6 {
            let freq_posture = profile_posture.dailySittingHours_Posture >= 8 ? "30 min" : "45 min"
            items_posture.append(DailyRecommendation_Posture(
                title_Posture: "Desk Break",
                detail_Posture: "Stand and walk briefly every \(freq_posture) to reset posture.",
                duration_Posture: "2 min",
                icon_Posture: "chair"
            ))
        }

        // 不足3条时补充呼吸重置
        if items_posture.count < 3 {
            items_posture.append(DailyRecommendation_Posture(
                title_Posture: "Breathing Reset",
                detail_Posture: "Inhale 4s, hold 4s, exhale 4s. Let ribs settle and posture soften.",
                duration_Posture: "3 min",
                icon_Posture: "lungs"
            ))
        }

        return Array(items_posture.prefix(3))
    }

    // MARK: - 关注功能

    /// 判断是否关注指定用户
    /// - Parameter user_posture: 目标用户
    /// - Returns: Bool
    func isFollowing_Posture(user_posture: PrewUserModel_Posture) -> Bool {
        guard let currentUser_posture = loggedUser_Posture else { return false }
        return currentUser_posture.userFollow_Posture.contains(where: { $0.userId_Posture == user_posture.userId_Posture })
    }

    /// 关注/取消关注用户
    /// - Parameter user_posture: 目标用户
    func followUser_Posture(user_posture: PrewUserModel_Posture) {
        if !isLoggedIn_Posture {
            showLoginPrompt_Posture()
            return
        }
        if isFollowing_Posture(user_posture: user_posture) {
            loggedUser_Posture?.userFollow_Posture.removeAll { $0.userId_Posture == user_posture.userId_Posture }
        } else {
            loggedUser_Posture?.userFollow_Posture.append(user_posture)
        }
        notifyStateChange_Posture()
    }

    // MARK: - 举报功能

    /// 举报并拉黑用户，移除其帖子和聊天记录
    /// - Parameter user_posture: 被举报用户
    func reportUser_Posture(user_posture: PrewUserModel_Posture) {
        guard let userId_posture = user_posture.userId_Posture else { return }

        MessageViewModel_Posture.shared_Posture.deleteUserMessages_Posture(userId_posture: userId_posture)
        TitleViewModel_Posture.shared_Posture.deleteUserPosts_Posture(userId_posture: userId_posture)
        LocalData_Posture.shared_Posture.userList_Posture.removeAll { $0.userId_Posture == userId_posture }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Utils_Posture.showSuccess_Posture(message_Posture: "This user will no longer appear.", delay_Posture: 2.0)
        }
        notifyStateChange_Posture()
    }

    // MARK: - 用户查询

    /// 判断是否是当前登录用户
    /// - Parameter userId_posture: 用户ID
    /// - Returns: Bool
    func isCurrentUser_Posture(userId_posture: Int) -> Bool {
        return loggedUser_Posture?.userId_Posture == userId_posture
    }

    /// 根据用户ID获取用户信息（不存在时返回默认占位用户）
    /// - Parameter userId_posture: 用户ID
    /// - Returns: PrewUserModel_Posture
    func getUserById_Posture(userId_posture: Int) -> PrewUserModel_Posture {
        let users_posture = LocalData_Posture.shared_Posture.userList_Posture
        if let user_posture = users_posture.first(where: { $0.userId_Posture == userId_posture }) {
            return user_posture
        }
        let defaultPrewUser_posture = PrewUserModel_Posture()
        defaultPrewUser_posture.userId_Posture = userId_posture
        defaultPrewUser_posture.userName_Posture = "Guest"
        defaultPrewUser_posture.userHead_Posture = "default_avatar"
        return defaultPrewUser_posture
    }

    /// 获取用户列表
    func getUserFollowRanking_Posture() -> [PrewUserModel_Posture] {
        return LocalData_Posture.shared_Posture.userList_Posture
    }

    // MARK: - 帖子和点赞管理

    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Posture(post_posture: TitleModel_Posture) {
        guard let user_posture = loggedUser_Posture else { return }
        user_posture.userPosts_Posture.append(post_posture)
        loggedUser_Posture = user_posture
        notifyStateChange_Posture()
    }

    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Posture(post_posture: TitleModel_Posture) {
        guard let user_posture = loggedUser_Posture else { return }
        user_posture.userPosts_Posture.removeAll { $0.titleId_Posture == post_posture.titleId_Posture }
        loggedUser_Posture = user_posture
        notifyStateChange_Posture()
    }

    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Posture(post_posture: TitleModel_Posture) {
        guard let user_posture = loggedUser_Posture else { return }
        if !user_posture.userLike_Posture.contains(where: { $0.titleId_Posture == post_posture.titleId_Posture }) {
            user_posture.userLike_Posture.append(post_posture)
            loggedUser_Posture = user_posture
            notifyStateChange_Posture()
        }
    }

    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Posture(post_posture: TitleModel_Posture) {
        guard let user_posture = loggedUser_Posture else { return }
        user_posture.userLike_Posture.removeAll { $0.titleId_Posture == post_posture.titleId_Posture }
        loggedUser_Posture = user_posture
        notifyStateChange_Posture()
    }

    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Posture(post_posture: TitleModel_Posture) -> Bool {
        guard let user_posture = loggedUser_Posture else { return false }
        return user_posture.userLike_Posture.contains { $0.titleId_Posture == post_posture.titleId_Posture }
    }

    // MARK: - 私有工具方法

    /// 发送用户状态更新通知
    private func notifyStateChange_Posture() {
        NotificationCenter.default.post(name: UserViewModel_Posture.userStateDidChangeNotification_Posture, object: nil)
    }

    /// 弹出登录引导（延迟 0.5 秒）
    private func showLoginPrompt_Posture() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
        }
    }

    /// 获取今日 "yyyy-MM-dd" 格式字符串
    private func todayDateString_Posture() -> String {
        return dateToString_Posture(date_posture: Date())
    }

    /// 将 Date 转换为 "yyyy-MM-dd" 字符串
    /// - Parameter date_posture: 目标日期
    /// - Returns: 格式化字符串
    private func dateToString_Posture(date_posture: Date) -> String {
        let formatter_posture = DateFormatter()
        formatter_posture.dateFormat = "yyyy-MM-dd"
        return formatter_posture.string(from: date_posture)
    }

    /// 从 UserDefaults 读取打卡日期数组
    private func loadCheckInDates_Posture() -> [String] {
        return UserDefaults.standard.stringArray(forKey: UDKey_Posture.checkInDates_Posture) ?? []
    }

    /// 将打卡日期数组写入 UserDefaults
    private func saveCheckInDates_Posture(dates_posture: [String]) {
        UserDefaults.standard.set(dates_posture, forKey: UDKey_Posture.checkInDates_Posture)
    }
}
