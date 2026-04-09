import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Tidy {
    /// 删除账号
    case delete_tidy
    /// 普通登出
    case logout_tidy
}

/// 用户状态管理类
@MainActor
class UserViewModel_Tidy {
    
    /// 单例
    static let shared_Tidy = UserViewModel_Tidy()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Tidy = Notification.Name("UserStateDidChange_Tidy")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Tidy: LoginUserModel_Tidy?

    /// 已被举报/拉黑的用户 ID 集合（内存级别，退出后重置）
    /// 用于在评论列表、帖子列表等场景屏蔽其内容
    private var reportedUserIds_tidy: Set<Int> = []

    /// 默认用户（游客）
    private let defaultUser_Tidy = LoginUserModel_Tidy(
        userId_Tidy: 0,
        userPwd_Tidy: nil,
        userName_Tidy: "Guest",
        userHead_Tidy: "default_avatar",
        userPosts_Tidy: [],
        userLike_Tidy: [],
        userFollow_Tidy: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Tidy: Bool {
        return loggedUser_Tidy?.userId_Tidy != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Tidy() -> LoginUserModel_Tidy {
        return loggedUser_Tidy ?? defaultUser_Tidy
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Tidy() {
        loggedUser_Tidy = defaultUser_Tidy
        notifyStateChange_Tidy()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Tidy(userId_tidy: Int) {
        // 显示加载动画
        Utils_Tidy.showLoading_Tidy(message_Tidy: "Logging in...")
        
        // 创建登录用户
        loggedUser_Tidy = LoginUserModel_Tidy(
            userId_Tidy: userId_tidy,
            userPwd_Tidy: nil,
            userName_Tidy: "Tidyer", // 可以从本地数据或服务器获取
            userHead_Tidy: "user_avatar",
            userPosts_Tidy: [],
            userLike_Tidy: [],
            userFollow_Tidy: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Tidy.dismissLoading_Tidy()
            
            // 显示成功提示
            Utils_Tidy.showSuccess_Tidy(message_Tidy: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Tidy.switchToTabbar_Tidy(animated: true)
            
            notifyStateChange_Tidy()
        }
    }
    
    /// 用户登出
    func logout_Tidy(logoutType_tidy: LogOutType_Tidy) {
        if !isLoggedIn_Tidy {
            showLoginPrompt_Tidy()
            return
        }
        
        // 重置为游客状态
        loggedUser_Tidy = defaultUser_Tidy
        
        // 清空AI聊天记录
        MessageViewModel_Tidy.shared_Tidy.clearAiChat_Tidy()
        
        // 重新初始化本地数据
        LocalData_Tidy.shared_Tidy.initData_Tidy()
        
        notifyStateChange_Tidy()
        
        // 跳转到首页
         Navigation_Tidy.switchToTabbar_Tidy()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_tidy == .delete_tidy {
                Utils_Tidy.showInfo_Tidy(
                    message_Tidy: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Tidy: 3.0
                )
            } else {
                Utils_Tidy.showSuccess_Tidy(message_Tidy: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Tidy(headUrl_tidy: String) {
        guard let user_tidy = loggedUser_Tidy else { return }
        user_tidy.userHead_Tidy = headUrl_tidy
        loggedUser_Tidy = user_tidy
        Utils_Tidy.showSuccess_Tidy(message_Tidy: "Avatar updated successfully")
        notifyStateChange_Tidy()
    }
    
    /// 更新用户昵称
    func updateName_Tidy(userName_tidy: String) {
        guard let user_tidy = loggedUser_Tidy else { return }
        user_tidy.userName_Tidy = userName_tidy
        loggedUser_Tidy = user_tidy
        Utils_Tidy.showSuccess_Tidy(message_Tidy: "Name updated successfully")
        notifyStateChange_Tidy()
    }
    
    /// 更新用户简介
    /// - Parameter introduce_tidy: 新简介文本
    func updateIntroduce_Tidy(introduce_tidy: String) {
        guard let user_tidy = loggedUser_Tidy else { return }
        user_tidy.userIntroduce_Tidy = introduce_tidy
        loggedUser_Tidy = user_tidy
        notifyStateChange_Tidy()
    }
    
    /// 将选取的头像图片保存到本地并更新用户头像路径
    /// - Parameter image_tidy: 选取的头像图片
    func saveAvatarImage_Tidy(image_tidy: UIImage) {
        guard let userId_tidy = loggedUser_Tidy?.userId_Tidy else { return }
        
        // 压缩为 JPEG 并写入 Documents 目录
        guard let data_tidy = image_tidy.jpegData(compressionQuality: 0.8) else { return }
        let filename_tidy = "avatar_\(userId_tidy).jpg"
        let docsURL_tidy = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL_tidy = docsURL_tidy.appendingPathComponent(filename_tidy)
        
        do {
            try data_tidy.write(to: fileURL_tidy)
            print("头像已保存到本地: \(fileURL_tidy.path)")
            updateHead_Tidy(headUrl_tidy: fileURL_tidy.path)
        } catch {
            print("头像保存失败: \(error)")
        }
    }
    
    /// 上传用户封面
    func uploadCover_Tidy(coverUrl_tidy: String) {
        Utils_Tidy.showSuccess_Tidy(message_Tidy: "Cover updated successfully")
        notifyStateChange_Tidy()
    }
    
    // MARK: - 打卡功能

    /// UserDefaults 打卡记录存储 Key
    private let kCheckinRecords_Tidy = "Tidy_CheckinRecords_v1"

    /// 获取今天的日期字符串（格式：yyyy-MM-dd）
    private func todayString_Tidy() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    /// 检查今天是否已打卡
    func hasCheckedInToday_Tidy() -> Bool {
        let records = UserDefaults.standard.stringArray(forKey: kCheckinRecords_Tidy) ?? []
        return records.contains(todayString_Tidy())
    }

    /// 打卡（记录今日日期）
    func checkIn_Tidy() {
        if hasCheckedInToday_Tidy() {
            Utils_Tidy.showWarning_Tidy(
                message_Tidy: "You have already checked in today."
            )
            return
        }
        var records = UserDefaults.standard.stringArray(forKey: kCheckinRecords_Tidy) ?? []
        records.append(todayString_Tidy())
        UserDefaults.standard.set(records, forKey: kCheckinRecords_Tidy)
        Utils_Tidy.showSuccess_Tidy(
            message_Tidy: "Check-in successful! Keep it up 🔥",
            image_Tidy: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Tidy()
    }

    /// 获取连续打卡天数（从今天往前数连续已打卡的天数）
    /// - Returns: 连续打卡天数，未打卡过返回 0
    func getCheckinStreak_Tidy() -> Int {
        let records = Set(UserDefaults.standard.stringArray(forKey: kCheckinRecords_Tidy) ?? [])
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var streak = 0
        var date = Date()
        while records.contains(formatter.string(from: date)) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    /// 获取所有打卡日期（从新到旧排序）
    /// - Returns: 日期字符串数组，格式 "yyyy-MM-dd"，按降序排列
    func getAllCheckinDates_Tidy() -> [String] {
        let records = UserDefaults.standard.stringArray(forKey: kCheckinRecords_Tidy) ?? []
        return records.sorted(by: >)
    }

    /// 获取本周（周一至周日）每天的打卡状态
    /// - Returns: 长度为 7 的 Bool 数组，下标 0 = 周一，6 = 周日
    func getWeekCheckinRecord_Tidy() -> [Bool] {
        let records = Set(UserDefaults.standard.stringArray(forKey: kCheckinRecords_Tidy) ?? [])
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        // 计算本周周一（使用 ISO 周起算逻辑）
        var comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        comps.weekday = 2
        guard let monday = cal.date(from: comps) else { return Array(repeating: false, count: 7) }
        return (0..<7).map { i in
            guard let day = cal.date(byAdding: .day, value: i, to: monday) else { return false }
            return records.contains(formatter.string(from: day))
        }
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_tidy: 目标用户
    /// - Returns: 已关注返回 true，否则返回 false
    func isFollowing_Tidy(user_tidy: PrewUserModel_Tidy) -> Bool {
        // 使用 currentUser 避免与参数同名遮蔽，确保与目标用户 ID 正确比对
        guard let currentUser_tidy = loggedUser_Tidy else { return false }
        return currentUser_tidy.userFollow_Tidy.contains(where: {
            $0.userId_Tidy == user_tidy.userId_Tidy
        })
    }
    
    /// 关注/取消关注用户，同步更新目标用户粉丝数
    /// - Parameter user_tidy: 目标用户
    func followUser_Tidy(user_tidy: PrewUserModel_Tidy) {
        if !isLoggedIn_Tidy {
            showLoginPrompt_Tidy()
            return
        }
        
        if isFollowing_Tidy(user_tidy: user_tidy) {
            // 取消关注：从关注列表移除，粉丝数 -1
            loggedUser_Tidy?.userFollow_Tidy.removeAll {
                $0.userId_Tidy == user_tidy.userId_Tidy
            }
            user_tidy.userFans_Tidy = max(0, (user_tidy.userFans_Tidy ?? 0) - 1)
        } else {
            // 关注：加入关注列表，粉丝数 +1
            loggedUser_Tidy?.userFollow_Tidy.append(user_tidy)
            user_tidy.userFans_Tidy = (user_tidy.userFans_Tidy ?? 0) + 1
        }
        
        notifyStateChange_Tidy()
    }
    
    // MARK: - 举报功能
    
    /// 判断指定用户 ID 是否已被当前用户举报/拉黑
    /// - Parameter userId_tidy: 待查询的用户 ID
    /// - Returns: 已举报返回 true，否则返回 false
    func isReportedUser_Tidy(userId_tidy: Int) -> Bool {
        return reportedUserIds_tidy.contains(userId_tidy)
    }

    /// 举报用户
    func reportUser_Tidy(user_tidy: PrewUserModel_Tidy) {
        guard let userId_tidy = user_tidy.userId_Tidy else { return }

        // 将该用户 ID 加入屏蔽集合，后续评论/内容列表据此过滤
        reportedUserIds_tidy.insert(userId_tidy)

        // 取消关注：从关注列表中移除
        loggedUser_Tidy?.userFollow_Tidy.removeAll { $0.userId_Tidy == userId_tidy }

        // 删除与该用户的聊天记录
        MessageViewModel_Tidy.shared_Tidy.deleteUserMessages_Tidy(
            userId_tidy: userId_tidy
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Tidy.shared_Tidy.deleteUserPosts_Tidy(
            userId_tidy: userId_tidy
        )
        
        // 从本地用户列表中移除
        LocalData_Tidy.shared_Tidy.userList_Tidy.removeAll { $0.userId_Tidy == userId_tidy }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Tidy.showSuccess_Tidy(
                message_Tidy: "This user will no longer appear.",
                delay_Tidy: 2.0
            )
        }
        
        notifyStateChange_Tidy()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Tidy(userId_tidy: Int) -> Bool {
        return loggedUser_Tidy?.userId_Tidy == userId_tidy
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Tidy(userId_tidy: Int) -> PrewUserModel_Tidy {
        let users_tidy = LocalData_Tidy.shared_Tidy.userList_Tidy
        
        if let user_tidy = users_tidy.first(where: { $0.userId_Tidy == userId_tidy }) {
            return user_tidy
        }
        
        // 返回默认用户
        let defaultPrewUser_tidy = PrewUserModel_Tidy()
        defaultPrewUser_tidy.userId_Tidy = userId_tidy
        defaultPrewUser_tidy.userName_Tidy = "Guest"
        defaultPrewUser_tidy.userHead_Tidy = "default_avatar"
        return defaultPrewUser_tidy
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Tidy() -> [PrewUserModel_Tidy] {
        let users_tidy = LocalData_Tidy.shared_Tidy.userList_Tidy
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_tidy
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Tidy(post_tidy: TitleModel_Tidy) {
        guard let user_tidy = loggedUser_Tidy else { return }
        user_tidy.userPosts_Tidy.append(post_tidy)
        loggedUser_Tidy = user_tidy
        notifyStateChange_Tidy()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Tidy(post_tidy: TitleModel_Tidy) {
        guard let user_tidy = loggedUser_Tidy else { return }
        user_tidy.userPosts_Tidy.removeAll { $0.titleId_Tidy == post_tidy.titleId_Tidy }
        loggedUser_Tidy = user_tidy
        notifyStateChange_Tidy()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Tidy(post_tidy: TitleModel_Tidy) {
        guard let user_tidy = loggedUser_Tidy else { return }
        
        // 检查是否已存在
        if !user_tidy.userLike_Tidy.contains(where: { $0.titleId_Tidy == post_tidy.titleId_Tidy }) {
            user_tidy.userLike_Tidy.append(post_tidy)
            loggedUser_Tidy = user_tidy
            notifyStateChange_Tidy()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Tidy(post_tidy: TitleModel_Tidy) {
        guard let user_tidy = loggedUser_Tidy else { return }
        user_tidy.userLike_Tidy.removeAll { $0.titleId_Tidy == post_tidy.titleId_Tidy }
        loggedUser_Tidy = user_tidy
        notifyStateChange_Tidy()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Tidy(post_tidy: TitleModel_Tidy) -> Bool {
        guard let user_tidy = loggedUser_Tidy else { return false }
        return user_tidy.userLike_Tidy.contains { $0.titleId_Tidy == post_tidy.titleId_Tidy }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Tidy() {
        NotificationCenter.default.post(
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Tidy() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Tidy.toLogin_Tidy(style_tidy: .present_tidy)
        }
    }
}
