import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Trace {
    /// 删除账号
    case delete_trace
    /// 普通登出
    case logout_trace
}

/// 用户状态管理类
@MainActor
class UserViewModel_Trace {
    
    /// 单例
    static let shared_Trace = UserViewModel_Trace()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Trace = Notification.Name("UserStateDidChange_Trace")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Trace: LoginUserModel_Trace?
    
    /// 默认用户（游客）
    private let defaultUser_Trace = LoginUserModel_Trace(
        userId_Trace: 0,
        userPwd_Trace: nil,
        userName_Trace: "Guest",
        userHead_Trace: "default_avatar",
        userPosts_Trace: [],
        userLike_Trace: [],
        userFollow_Trace: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Trace: Bool {
        return loggedUser_Trace?.userId_Trace != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Trace() -> LoginUserModel_Trace {
        return loggedUser_Trace ?? defaultUser_Trace
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Trace() {
        loggedUser_Trace = defaultUser_Trace
        notifyStateChange_Trace()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Trace(userId_trace: Int) {
        // 显示加载动画
        Utils_Trace.showLoading_Trace(message_Trace: "Logging in...")
        
        // 创建登录用户
        loggedUser_Trace = LoginUserModel_Trace(
            userId_Trace: userId_trace,
            userPwd_Trace: nil,
            userName_Trace: "Tracuer", // 可以从本地数据或服务器获取
            userHead_Trace: "user_avatar",
            userPosts_Trace: [],
            userLike_Trace: [],
            userFollow_Trace: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Trace.dismissLoading_Trace()
            
            // 切换到主Tabbar
            Navigation_Trace.switchToTabbar_Trace(animated: true)
            
            notifyStateChange_Trace()
        }
    }

    /// 用户登出
    func logout_Trace(logoutType_trace: LogOutType_Trace) {
        if !isLoggedIn_Trace {
            showLoginPrompt_Trace()
            return
        }
        
        // 重置为游客状态
        loggedUser_Trace = defaultUser_Trace
        
        // 清空AI聊天记录
        MessageViewModel_Trace.shared_Trace.clearAiChat_Trace()
        
        // 重新初始化本地数据
        LocalData_Trace.shared_Trace.initData_Trace()
        
        notifyStateChange_Trace()
        
        // 跳转到首页
         Navigation_Trace.switchToTabbar_Trace()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            if logoutType_trace == .delete_trace {
                Utils_Trace.showInfo_Trace(
                    message_Trace: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Trace: 3.0
                )
            } else {
                Utils_Trace.showSuccess_Trace(message_Trace: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Trace(headUrl_trace: String) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userHead_Trace = headUrl_trace
        loggedUser_Trace = user_trace
        Utils_Trace.showSuccess_Trace(message_Trace: "Avatar updated successfully")
        notifyStateChange_Trace()
    }
    
    /// 更新用户昵称
    func updateName_Trace(userName_trace: String) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userName_Trace = userName_trace
        loggedUser_Trace = user_trace
        Utils_Trace.showSuccess_Trace(message_Trace: "Name updated successfully")
        notifyStateChange_Trace()
    }
    
    /// 更新用户简介
    func updateIntroduce_Trace(introduce_trace: String) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userIntroduce_Trace = introduce_trace
        loggedUser_Trace = user_trace
        notifyStateChange_Trace()
    }
    
    /// 更新用户头像图片（直接传入 UIImage，内部负责保存到文档目录）
    /// - Parameter image_trace: 用户选择的头像图片
    func updateAvatarImage_Trace(image_trace: UIImage) {
        guard let savedPath_trace = saveAvatarImage_Trace(image_trace: image_trace) else {
            Utils_Trace.showError_Trace(message_Trace: "Failed to update avatar")
            return
        }
        updateHead_Trace(headUrl_trace: savedPath_trace)
    }
    
    /// 批量更新用户个人资料（只更新非 nil 字段）
    /// - Parameters:
    ///   - userName_trace: 新用户名，nil 表示不修改
    ///   - introduce_trace: 新简介，nil 表示不修改
    ///   - headImage_trace: 新头像 UIImage，nil 表示不修改
    func updateProfile_Trace(
        userName_trace: String? = nil,
        introduce_trace: String? = nil,
        headImage_trace: UIImage? = nil
    ) {
        guard let user_trace = loggedUser_Trace else { return }
        
        var hasChanges_trace = false
        
        // 更新用户名
        if let name_trace = userName_trace, !name_trace.isEmpty {
            user_trace.userName_Trace = name_trace
            hasChanges_trace = true
        }
        
        // 更新简介
        if let intro_trace = introduce_trace {
            user_trace.userIntroduce_Trace = intro_trace
            hasChanges_trace = true
        }
        
        // 更新头像（先保存图片到文档目录）
        if let image_trace = headImage_trace,
           let savedPath_trace = saveAvatarImage_Trace(image_trace: image_trace) {
            user_trace.userHead_Trace = savedPath_trace
            hasChanges_trace = true
        }
        
        guard hasChanges_trace else {
            Utils_Trace.showInfo_Trace(message_Trace: "No changes to save")
            return
        }
        
        loggedUser_Trace = user_trace
        Utils_Trace.showSuccess_Trace(message_Trace: "Profile updated!")
        notifyStateChange_Trace()
    }
    
    /// 将头像图片保存到应用文档目录
    /// - Parameter image_trace: 要保存的 UIImage
    /// - Returns: 文件路径字符串，失败返回 nil
    private func saveAvatarImage_Trace(image_trace: UIImage) -> String? {
        guard let data_trace = image_trace.jpegData(compressionQuality: 0.85) else { return nil }
        let filename_trace = "user_avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL_trace = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_trace)
        do {
            try data_trace.write(to: fileURL_trace)
            print("✅ 头像已保存至: \(fileURL_trace.path)")
            return fileURL_trace.path
        } catch {
            print("❌ 保存头像失败: \(error)")
            return nil
        }
    }
    
    /// 上传用户封面
    func uploadCover_Trace(coverUrl_trace: String) {
        Utils_Trace.showSuccess_Trace(message_Trace: "Cover updated successfully")
        notifyStateChange_Trace()
    }
    
    // MARK: - 时光记录管理

    /// 时光记录状态更新通知
    static let traceRecordDidChangeNotification_Trace = Notification.Name("TraceRecordDidChange_Trace")

    /// 当前用户时光记录（读写均指向 loggedUser_Trace 拓展字段）
    private var currentTraceRecords_Trace: [TraceRecord_Trace] {
        get { loggedUser_Trace?.userTraceRecords_Trace ?? [] }
        set { loggedUser_Trace?.userTraceRecords_Trace = newValue }
    }

    /// 添加时光记录（需登录）
    /// - Parameter content_trace: 记录文本内容
    func addTraceRecord_Trace(content_trace: String) {
        guard isLoggedIn_Trace else {
            showLoginPrompt_Trace()
            return
        }
        guard let user_trace = loggedUser_Trace else { return }
        let record_Trace = TraceRecord_Trace(
            recordId_Trace: user_trace.userNextRecordId_Trace,
            content_Trace: content_trace
        )
        user_trace.userNextRecordId_Trace += 1
        user_trace.userTraceRecords_Trace.insert(record_Trace, at: 0)
        NotificationCenter.default.post(
            name: UserViewModel_Trace.traceRecordDidChangeNotification_Trace,
            object: nil
        )
    }

    /// 删除指定时光记录
    /// - Parameter recordId_trace: 要删除的记录 ID
    func deleteTraceRecord_Trace(recordId_trace: Int) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userTraceRecords_Trace.removeAll { $0.recordId_Trace == recordId_trace }
        NotificationCenter.default.post(
            name: UserViewModel_Trace.traceRecordDidChangeNotification_Trace,
            object: nil
        )
    }

    /// 获取指定天的时光记录（默认今天，降序）
    /// - Parameter date_trace: 目标日期
    /// - Returns: 当天所有记录
    func getTraceRecordsForDay_Trace(date_trace: Date = Date()) -> [TraceRecord_Trace] {
        let cal_Trace = Calendar.current
        return currentTraceRecords_Trace.filter {
            cal_Trace.isDate($0.timestamp_Trace, inSameDayAs: date_trace)
        }
    }

    /// 获取本周的时光记录（降序）
    func getTraceRecordsForWeek_Trace() -> [TraceRecord_Trace] {
        let cal_Trace = Calendar.current
        guard let weekStart_Trace = cal_Trace.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        return currentTraceRecords_Trace.filter { $0.timestamp_Trace >= weekStart_Trace }
    }

    /// 获取本月的时光记录（降序）
    func getTraceRecordsForMonth_Trace() -> [TraceRecord_Trace] {
        let cal_Trace = Calendar.current
        guard let monthStart_Trace = cal_Trace.dateInterval(of: .month, for: Date())?.start else { return [] }
        return currentTraceRecords_Trace.filter { $0.timestamp_Trace >= monthStart_Trace }
    }

    // MARK: - 打卡功能

    /// 今日日期键（格式 "yyyy-MM-dd"）
    private var todayKey_Trace: String {
        let fmt_Trace = DateFormatter()
        fmt_Trace.dateFormat = "yyyy-MM-dd"
        return fmt_Trace.string(from: Date())
    }

    /// 当前用户签到日期集合（读写均指向 loggedUser_Trace 拓展字段）
    private var currentCheckInDates_Trace: Set<String> {
        loggedUser_Trace?.userCheckInDates_Trace ?? []
    }

    /// 检查今天是否已打卡
    func hasCheckedInToday_Trace() -> Bool {
        return currentCheckInDates_Trace.contains(todayKey_Trace)
    }

    /// 执行打卡（需登录；已打卡时给出提示）
    func checkIn_Trace() {
        guard isLoggedIn_Trace else {
            showLoginPrompt_Trace()
            return
        }
        if hasCheckedInToday_Trace() {
            Utils_Trace.showWarning_Trace(message_Trace: "Already checked in today.")
            return
        }
        loggedUser_Trace?.userCheckInDates_Trace.insert(todayKey_Trace)
        Utils_Trace.showSuccess_Trace(
            message_Trace: "Check-in successful! Keep it up 🔥",
            image_Trace: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Trace()
    }

    /// 获取指定天数范围内的打卡状态（从最早到今天排列）
    /// - Parameter days_trace: 天数（7 或 15）
    /// - Returns: 每天日期与是否已打卡的元组数组
    func getCheckInStatus_Trace(days_trace: Int) -> [(date: Date, isCheckedIn: Bool)] {
        let cal_Trace = Calendar.current
        let fmt_Trace = DateFormatter()
        fmt_Trace.dateFormat = "yyyy-MM-dd"
        let dates_Trace = currentCheckInDates_Trace
        return (0..<days_trace).compactMap { offset_Trace in
            guard let date_Trace = cal_Trace.date(
                byAdding: .day,
                value: -(days_trace - 1 - offset_Trace),
                to: Date()
            ) else { return nil }
            let key_Trace = fmt_Trace.string(from: date_Trace)
            return (date: date_Trace, isCheckedIn: dates_Trace.contains(key_Trace))
        }
    }

    /// 获取截止今天的连续打卡天数
    func getCheckInStreak_Trace() -> Int {
        let cal_Trace = Calendar.current
        let fmt_Trace = DateFormatter()
        fmt_Trace.dateFormat = "yyyy-MM-dd"
        let dates_Trace = currentCheckInDates_Trace
        var streak_Trace = 0
        var current_Trace = Date()
        while dates_Trace.contains(fmt_Trace.string(from: current_Trace)) {
            streak_Trace += 1
            guard let prev_Trace = cal_Trace.date(byAdding: .day, value: -1, to: current_Trace) else { break }
            current_Trace = prev_Trace
        }
        return streak_Trace
    }
    
    // MARK: - 关注功能
    
    /// 判断当前登录用户是否已关注指定用户
    /// - Parameter user_trace: 目标用户
    /// - Returns: 已关注返回 true，未登录或未关注返回 false
    func isFollowing_Trace(user_trace: PrewUserModel_Trace) -> Bool {
        guard let currentUser_trace = loggedUser_Trace,
              let targetId_trace = user_trace.userId_Trace else { return false }
        return currentUser_trace.userFollow_Trace.contains(where: { $0.userId_Trace == targetId_trace })
    }
    
    /// 关注/取消关注用户
    func followUser_Trace(user_trace: PrewUserModel_Trace) {
        if !isLoggedIn_Trace {
            showLoginPrompt_Trace()
            return
        }
        
        if isFollowing_Trace(user_trace: user_trace) {
            // 取消关注
            loggedUser_Trace?.userFollow_Trace.removeAll { $0.userId_Trace == user_trace.userId_Trace }
        } else {
            // 关注
            loggedUser_Trace?.userFollow_Trace.append(user_trace)
        }
        
        notifyStateChange_Trace()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Trace(user_trace: PrewUserModel_Trace) {
        guard let userId_trace = user_trace.userId_Trace else { return }
        
        // 显示加载动画
        Utils_Trace.showLoading_Trace(message_Trace: "Processing...")
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Trace.shared_Trace.deleteUserMessages_Trace(
            userId_trace: userId_trace
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Trace.shared_Trace.deleteUserPosts_Trace(
            userId_trace: userId_trace
        )
        
        // 从本地用户列表中移除
        LocalData_Trace.shared_Trace.userList_Trace.removeAll { $0.userId_Trace == userId_trace }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Trace.dismissLoading_Trace()
            Utils_Trace.showSuccess_Trace(
                message_Trace: "This user will no longer appear.",
                delay_Trace: 2.0
            )
        }
        
        notifyStateChange_Trace()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Trace(userId_trace: Int) -> Bool {
        return loggedUser_Trace?.userId_Trace == userId_trace
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Trace(userId_trace: Int) -> PrewUserModel_Trace {
        let users_trace = LocalData_Trace.shared_Trace.userList_Trace
        
        if let user_trace = users_trace.first(where: { $0.userId_Trace == userId_trace }) {
            return user_trace
        }
        
        // 返回默认用户
        let defaultPrewUser_trace = PrewUserModel_Trace()
        defaultPrewUser_trace.userId_Trace = userId_trace
        defaultPrewUser_trace.userName_Trace = "Guest"
        defaultPrewUser_trace.userHead_Trace = "default_avatar"
        return defaultPrewUser_trace
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Trace() -> [PrewUserModel_Trace] {
        let users_trace = LocalData_Trace.shared_Trace.userList_Trace
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_trace
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Trace(post_trace: TitleModel_Trace) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userPosts_Trace.append(post_trace)
        loggedUser_Trace = user_trace
        notifyStateChange_Trace()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Trace(post_trace: TitleModel_Trace) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userPosts_Trace.removeAll { $0.titleId_Trace == post_trace.titleId_Trace }
        loggedUser_Trace = user_trace
        notifyStateChange_Trace()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Trace(post_trace: TitleModel_Trace) {
        guard let user_trace = loggedUser_Trace else { return }
        
        // 检查是否已存在
        if !user_trace.userLike_Trace.contains(where: { $0.titleId_Trace == post_trace.titleId_Trace }) {
            user_trace.userLike_Trace.append(post_trace)
            loggedUser_Trace = user_trace
            notifyStateChange_Trace()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Trace(post_trace: TitleModel_Trace) {
        guard let user_trace = loggedUser_Trace else { return }
        user_trace.userLike_Trace.removeAll { $0.titleId_Trace == post_trace.titleId_Trace }
        loggedUser_Trace = user_trace
        notifyStateChange_Trace()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Trace(post_trace: TitleModel_Trace) -> Bool {
        guard let user_trace = loggedUser_Trace else { return false }
        return user_trace.userLike_Trace.contains { $0.titleId_Trace == post_trace.titleId_Trace }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Trace() {
        NotificationCenter.default.post(
            name: UserViewModel_Trace.userStateDidChangeNotification_Trace,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Trace() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Navigation_Trace.toLogin_Trace(style_trace: .present_trace)
        }
    }
}
