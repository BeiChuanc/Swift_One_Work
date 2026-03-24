import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Base_one {
    /// 删除账号
    case delete_base_one
    /// 普通登出
    case logout_base_one
}

/// 用户状态管理类
@MainActor
class UserViewModel_Base_one {
    
    /// 单例
    static let shared_Base_one = UserViewModel_Base_one()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Base_one = Notification.Name("UserStateDidChange_Base_one")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Base_one: LoginUserModel_Base_one?
    
    /// 默认用户（游客）
    private let defaultUser_Base_one = LoginUserModel_Base_one(
        userId_Base_one: 0,
        userPwd_Base_one: nil,
        userName_Base_one: "Guest",
        userHead_Base_one: "default_avatar",
        userPosts_Base_one: [],
        userLike_Base_one: [],
        userFollow_Base_one: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Base_one: Bool {
        return loggedUser_Base_one?.userId_Base_one != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Base_one() -> LoginUserModel_Base_one {
        return loggedUser_Base_one ?? defaultUser_Base_one
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Base_one() {
        loggedUser_Base_one = defaultUser_Base_one
        notifyStateChange_Base_one()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Base_one(userId_base_one: Int) {
        // 显示加载动画
        Utils_Base_one.showLoading_Base_one(message_Base_one: "Logging in...")
        
        // 创建登录用户
        loggedUser_Base_one = LoginUserModel_Base_one(
            userId_Base_one: userId_base_one,
            userPwd_Base_one: nil,
            userName_Base_one: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Base_one: "user_avatar",
            userPosts_Base_one: [],
            userLike_Base_one: [],
            userFollow_Base_one: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Base_one.dismissLoading_Base_one()
            
            // 显示成功提示
            Utils_Base_one.showSuccess_Base_one(message_Base_one: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Base_one.switchToTabbar_Base_one(animated: true)
            
            notifyStateChange_Base_one()
        }
    }
    
    /// 用户登出
    func logout_Base_one(logoutType_base_one: LogOutType_Base_one) {
        if !isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        // 重置为游客状态
        loggedUser_Base_one = defaultUser_Base_one
        
        // 清空AI聊天记录
        MessageViewModel_Base_one.shared_Base_one.clearAiChat_Base_one()
        
        // 重新初始化本地数据
        LocalData_Base_one.shared_Base_one.initData_Base_one()
        
        notifyStateChange_Base_one()
        
        // 跳转到首页
         Navigation_Base_one.switchToTabbar_Base_one()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_base_one == .delete_base_one {
                Utils_Base_one.showInfo_Base_one(
                    message_Base_one: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Base_one: 3.0
                )
            } else {
                Utils_Base_one.showSuccess_Base_one(message_Base_one: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Base_one(headUrl_base_one: String) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userHead_Base_one = headUrl_base_one
        loggedUser_Base_one = user_base_one
        Utils_Base_one.showSuccess_Base_one(message_Base_one: "Avatar updated successfully")
        notifyStateChange_Base_one()
    }
    
    /// 更新用户昵称
    func updateName_Base_one(userName_base_one: String) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userName_Base_one = userName_base_one
        loggedUser_Base_one = user_base_one
        Utils_Base_one.showSuccess_Base_one(message_Base_one: "Name updated successfully")
        notifyStateChange_Base_one()
    }
    
    /// 更新用户简介
    /// - Parameter introduce_base_one: 新简介文本
    func updateIntroduce_Base_one(introduce_base_one: String) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userIntroduce_Base_one = introduce_base_one
        loggedUser_Base_one = user_base_one
        notifyStateChange_Base_one()
    }
    
    /// 将选取的头像图片保存到本地并更新用户头像路径
    /// - Parameter image_base_one: 选取的头像图片
    func saveAvatarImage_Base_one(image_base_one: UIImage) {
        guard let userId_base_one = loggedUser_Base_one?.userId_Base_one else { return }
        
        // 压缩为 JPEG 并写入 Documents 目录
        guard let data_base_one = image_base_one.jpegData(compressionQuality: 0.8) else { return }
        let filename_base_one = "avatar_\(userId_base_one).jpg"
        let docsURL_base_one = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL_base_one = docsURL_base_one.appendingPathComponent(filename_base_one)
        
        do {
            try data_base_one.write(to: fileURL_base_one)
            print("头像已保存到本地: \(fileURL_base_one.path)")
            updateHead_Base_one(headUrl_base_one: fileURL_base_one.path)
        } catch {
            print("头像保存失败: \(error)")
        }
    }
    
    /// 上传用户封面
    func uploadCover_Base_one(coverUrl_base_one: String) {
        Utils_Base_one.showSuccess_Base_one(message_Base_one: "Cover updated successfully")
        notifyStateChange_Base_one()
    }
    
    // MARK: - 打卡功能

    /// UserDefaults 打卡记录存储 Key
    private let kCheckinRecords_Base_one = "Tidy_CheckinRecords_v1"

    /// 获取今天的日期字符串（格式：yyyy-MM-dd）
    private func todayString_Base_one() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    /// 检查今天是否已打卡
    func hasCheckedInToday_Base_one() -> Bool {
        let records = UserDefaults.standard.stringArray(forKey: kCheckinRecords_Base_one) ?? []
        return records.contains(todayString_Base_one())
    }

    /// 打卡（记录今日日期）
    func checkIn_Base_one() {
        if hasCheckedInToday_Base_one() {
            Utils_Base_one.showWarning_Base_one(
                message_Base_one: "You have already checked in today."
            )
            return
        }
        var records = UserDefaults.standard.stringArray(forKey: kCheckinRecords_Base_one) ?? []
        records.append(todayString_Base_one())
        UserDefaults.standard.set(records, forKey: kCheckinRecords_Base_one)
        Utils_Base_one.showSuccess_Base_one(
            message_Base_one: "Check-in successful! Keep it up 🔥",
            image_Base_one: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Base_one()
    }

    /// 获取连续打卡天数（从今天往前数连续已打卡的天数）
    /// - Returns: 连续打卡天数，未打卡过返回 0
    func getCheckinStreak_Base_one() -> Int {
        let records = Set(UserDefaults.standard.stringArray(forKey: kCheckinRecords_Base_one) ?? [])
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
    func getAllCheckinDates_Base_one() -> [String] {
        let records = UserDefaults.standard.stringArray(forKey: kCheckinRecords_Base_one) ?? []
        return records.sorted(by: >)
    }

    /// 获取本周（周一至周日）每天的打卡状态
    /// - Returns: 长度为 7 的 Bool 数组，下标 0 = 周一，6 = 周日
    func getWeekCheckinRecord_Base_one() -> [Bool] {
        let records = Set(UserDefaults.standard.stringArray(forKey: kCheckinRecords_Base_one) ?? [])
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
    func isFollowing_Base_one(user_base_one: PrewUserModel_Base_one) -> Bool {
        guard let user_base_one = loggedUser_Base_one else { return false }
        return user_base_one.userFollow_Base_one.contains(where: { $0.userId_Base_one == user_base_one.userId_Base_one })
    }
    
    /// 关注/取消关注用户
    func followUser_Base_one(user_base_one: PrewUserModel_Base_one) {
        if !isLoggedIn_Base_one {
            showLoginPrompt_Base_one()
            return
        }
        
        if isFollowing_Base_one(user_base_one: user_base_one) {
            // 取消关注
            loggedUser_Base_one?.userFollow_Base_one.removeAll { $0.userId_Base_one == user_base_one.userId_Base_one }
        } else {
            // 关注
            loggedUser_Base_one?.userFollow_Base_one.append(user_base_one)
        }
        
        notifyStateChange_Base_one()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Base_one(user_base_one: PrewUserModel_Base_one) {
        guard let userId_base_one = user_base_one.userId_Base_one else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Base_one.shared_Base_one.deleteUserMessages_Base_one(
            userId_base_one: userId_base_one
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Base_one.shared_Base_one.deleteUserPosts_Base_one(
            userId_base_one: userId_base_one
        )
        
        // 从本地用户列表中移除
        LocalData_Base_one.shared_Base_one.userList_Base_one.removeAll { $0.userId_Base_one == userId_base_one }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Base_one.showSuccess_Base_one(
                message_Base_one: "This user will no longer appear.",
                delay_Base_one: 2.0
            )
        }
        
        notifyStateChange_Base_one()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Base_one(userId_base_one: Int) -> Bool {
        return loggedUser_Base_one?.userId_Base_one == userId_base_one
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Base_one(userId_base_one: Int) -> PrewUserModel_Base_one {
        let users_base_one = LocalData_Base_one.shared_Base_one.userList_Base_one
        
        if let user_base_one = users_base_one.first(where: { $0.userId_Base_one == userId_base_one }) {
            return user_base_one
        }
        
        // 返回默认用户
        let defaultPrewUser_base_one = PrewUserModel_Base_one()
        defaultPrewUser_base_one.userId_Base_one = userId_base_one
        defaultPrewUser_base_one.userName_Base_one = "Guest"
        defaultPrewUser_base_one.userHead_Base_one = "default_avatar"
        return defaultPrewUser_base_one
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Base_one() -> [PrewUserModel_Base_one] {
        let users_base_one = LocalData_Base_one.shared_Base_one.userList_Base_one
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_base_one
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userPosts_Base_one.append(post_base_one)
        loggedUser_Base_one = user_base_one
        notifyStateChange_Base_one()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userPosts_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }
        loggedUser_Base_one = user_base_one
        notifyStateChange_Base_one()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard let user_base_one = loggedUser_Base_one else { return }
        
        // 检查是否已存在
        if !user_base_one.userLike_Base_one.contains(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) {
            user_base_one.userLike_Base_one.append(post_base_one)
            loggedUser_Base_one = user_base_one
            notifyStateChange_Base_one()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userLike_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }
        loggedUser_Base_one = user_base_one
        notifyStateChange_Base_one()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Base_one(post_base_one: TitleModel_Base_one) -> Bool {
        guard let user_base_one = loggedUser_Base_one else { return false }
        return user_base_one.userLike_Base_one.contains { $0.titleId_Base_one == post_base_one.titleId_Base_one }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Base_one() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
        }
    }
}
