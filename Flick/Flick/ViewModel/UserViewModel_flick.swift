import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Flick {
    /// 删除账号
    case delete_flick
    /// 普通登出
    case logout_flick
}

/// 用户状态管理类
@MainActor
class UserViewModel_Flick {
    
    /// 单例
    static let shared_Flick = UserViewModel_Flick()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Flick = Notification.Name("UserStateDidChange_Flick")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Flick: LoginUserModel_Flick?
    
    /// 默认用户（游客）
    private let defaultUser_Flick = LoginUserModel_Flick(
        userId_Flick: 0,
        userPwd_Flick: nil,
        userName_Flick: "Guest",
        userHead_Flick: "default_avatar",
        userPosts_Flick: [],
        userLike_Flick: [],
        userFollow_Flick: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Flick: Bool {
        return loggedUser_Flick?.userId_Flick != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Flick() -> LoginUserModel_Flick {
        return loggedUser_Flick ?? defaultUser_Flick
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Flick() {
        loggedUser_Flick = defaultUser_Flick
        notifyStateChange_Flick()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Flick(userId_flick: Int) {
        // 显示加载动画
        Utils_Flick.showLoading_Flick(message_Flick: "Logging in...")
        
        // 创建登录用户
        loggedUser_Flick = LoginUserModel_Flick(
            userId_Flick: userId_flick,
            userPwd_Flick: nil,
            userName_Flick: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Flick: "user_avatar",
            userPosts_Flick: [],
            userLike_Flick: [],
            userFollow_Flick: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Flick.dismissLoading_Flick()
            
            // 显示成功提示
            Utils_Flick.showSuccess_Flick(message_Flick: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Flick.switchToTabbar_Flick(animated: true)
            
            notifyStateChange_Flick()
        }
    }
    
    /// 用户登出
    func logout_Flick(logoutType_flick: LogOutType_Flick) {
        if !isLoggedIn_Flick {
            showLoginPrompt_Flick()
            return
        }
        
        // 重置为游客状态
        loggedUser_Flick = defaultUser_Flick
        
        // 清空AI聊天记录
        MessageViewModel_Flick.shared_Flick.clearAiChat_Flick()
        
        // 重新初始化本地数据
        LocalData_Flick.shared_Flick.initData_Flick()
        
        notifyStateChange_Flick()
        
        // 跳转到首页
         Navigation_Flick.switchToTabbar_Flick()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_flick == .delete_flick {
                Utils_Flick.showInfo_Flick(
                    message_Flick: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Flick: 3.0
                )
            } else {
                Utils_Flick.showSuccess_Flick(message_Flick: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Flick(headUrl_flick: String) {
        guard let user_flick = loggedUser_Flick else { return }
        user_flick.userHead_Flick = headUrl_flick
        loggedUser_Flick = user_flick
        Utils_Flick.showSuccess_Flick(message_Flick: "Avatar updated successfully")
        notifyStateChange_Flick()
    }
    
    /// 更新用户昵称
    func updateName_Flick(userName_flick: String) {
        guard let user_flick = loggedUser_Flick else { return }
        user_flick.userName_Flick = userName_flick
        loggedUser_Flick = user_flick
        Utils_Flick.showSuccess_Flick(message_Flick: "Name updated successfully")
        notifyStateChange_Flick()
    }
    
    /// 更新用户简介
    /// - Parameter introduce_flick: 新的简介文本
    func updateIntroduce_Flick(introduce_flick: String) {
        guard let user_flick = loggedUser_Flick else { return }
        user_flick.userIntroduce_Flick = introduce_flick
        loggedUser_Flick = user_flick
        notifyStateChange_Flick()
    }
    
    /// 上传用户封面
    func uploadCover_Flick(coverUrl_flick: String) {
        Utils_Flick.showSuccess_Flick(message_Flick: "Cover updated successfully")
        notifyStateChange_Flick()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Flick() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Flick() {
        if hasCheckedInToday_Flick() {
            Utils_Flick.showWarning_Flick(
                message_Flick: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Flick.showSuccess_Flick(
            message_Flick: "Check-in successful!",
            image_Flick: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Flick()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户（比较当前登录用户的关注列表与目标用户 ID）
    func isFollowing_Flick(user_flick: PrewUserModel_Flick) -> Bool {
        guard let selfUser_flick = loggedUser_Flick,
              let targetId_flick = user_flick.userId_Flick else { return false }
        return selfUser_flick.userFollow_Flick.contains(where: { $0.userId_Flick == targetId_flick })
    }
    
    /// 关注/取消关注用户，并同步 LocalData 中目标用户的粉丝数
    func followUser_Flick(user_flick: PrewUserModel_Flick) {
        if !isLoggedIn_Flick {
            showLoginPrompt_Flick()
            return
        }
        guard let targetId_flick = user_flick.userId_Flick else { return }
        
        if isFollowing_Flick(user_flick: user_flick) {
            loggedUser_Flick?.userFollow_Flick.removeAll { $0.userId_Flick == targetId_flick }
            adjustUserFansInLocalList_Flick(userId_flick: targetId_flick, delta_flick: -1)
        } else {
            loggedUser_Flick?.userFollow_Flick.append(user_flick)
            adjustUserFansInLocalList_Flick(userId_flick: targetId_flick, delta_flick: 1)
        }
        
        notifyStateChange_Flick()
    }
    
    /// 调整本地用户列表中指定用户的粉丝数（用于他人主页展示）
    private func adjustUserFansInLocalList_Flick(userId_flick: Int, delta_flick: Int) {
        let list_flick = LocalData_Flick.shared_Flick.userList_Flick
        guard let idx_flick = list_flick.firstIndex(where: { $0.userId_Flick == userId_flick }) else { return }
        let u_flick = list_flick[idx_flick]
        let cur_flick = u_flick.userFans_Flick ?? 0
        u_flick.userFans_Flick = max(0, cur_flick + delta_flick)
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Flick(user_flick: PrewUserModel_Flick) {
        guard let userId_flick = user_flick.userId_Flick else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Flick.shared_Flick.deleteUserMessages_Flick(
            userId_flick: userId_flick
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Flick.shared_Flick.deleteUserPosts_Flick(
            userId_flick: userId_flick
        )
        
        // 从本地用户列表中移除
        LocalData_Flick.shared_Flick.userList_Flick.removeAll { $0.userId_Flick == userId_flick }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Flick.showSuccess_Flick(
                message_Flick: "This user will no longer appear.",
                delay_Flick: 2.0
            )
        }
        
        notifyStateChange_Flick()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Flick(userId_flick: Int) -> Bool {
        return loggedUser_Flick?.userId_Flick == userId_flick
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Flick(userId_flick: Int) -> PrewUserModel_Flick {
        let users_flick = LocalData_Flick.shared_Flick.userList_Flick
        
        if let user_flick = users_flick.first(where: { $0.userId_Flick == userId_flick }) {
            return user_flick
        }
        
        // 返回默认用户
        let defaultPrewUser_flick = PrewUserModel_Flick()
        defaultPrewUser_flick.userId_Flick = userId_flick
        defaultPrewUser_flick.userName_Flick = "Guest"
        defaultPrewUser_flick.userHead_Flick = "default_avatar"
        return defaultPrewUser_flick
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Flick() -> [PrewUserModel_Flick] {
        let users_flick = LocalData_Flick.shared_Flick.userList_Flick
        return users_flick.sorted { ($0.userFans_Flick ?? 0) > ($1.userFans_Flick ?? 0) }
    }
    
    /// 获取推荐用户列表（排除当前登录用户）
    /// - Returns: 推荐用户数组
    func getRecommendedUsers_Flick() -> [PrewUserModel_Flick] {
        let currentId_flick = getCurrentUser_Flick().userId_Flick ?? -1
        return LocalData_Flick.shared_Flick.userList_Flick.filter {
            $0.userId_Flick != currentId_flick
        }
    }
    
    /// 获取当前用户关注的用户 ID 集合
    /// - Returns: 关注用户 ID 的 Set
    func getFollowingUserIds_Flick() -> Set<Int> {
        let follows_flick = getCurrentUser_Flick().userFollow_Flick
        return Set(follows_flick.compactMap { $0.userId_Flick })
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Flick(post_flick: TitleModel_Flick) {
        guard let user_flick = loggedUser_Flick else { return }
        user_flick.userPosts_Flick.append(post_flick)
        loggedUser_Flick = user_flick
        notifyStateChange_Flick()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Flick(post_flick: TitleModel_Flick) {
        guard let user_flick = loggedUser_Flick else { return }
        user_flick.userPosts_Flick.removeAll { $0.titleId_Flick == post_flick.titleId_Flick }
        loggedUser_Flick = user_flick
        notifyStateChange_Flick()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Flick(post_flick: TitleModel_Flick) {
        guard let user_flick = loggedUser_Flick else { return }
        
        // 检查是否已存在
        if !user_flick.userLike_Flick.contains(where: { $0.titleId_Flick == post_flick.titleId_Flick }) {
            user_flick.userLike_Flick.append(post_flick)
            loggedUser_Flick = user_flick
            notifyStateChange_Flick()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Flick(post_flick: TitleModel_Flick) {
        guard let user_flick = loggedUser_Flick else { return }
        user_flick.userLike_Flick.removeAll { $0.titleId_Flick == post_flick.titleId_Flick }
        loggedUser_Flick = user_flick
        notifyStateChange_Flick()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Flick(post_flick: TitleModel_Flick) -> Bool {
        guard let user_flick = loggedUser_Flick else { return false }
        return user_flick.userLike_Flick.contains { $0.titleId_Flick == post_flick.titleId_Flick }
    }
    
    // MARK: - 速记操作

    /// 旧版全局速记 Key（迁移用）
    private let speedNotesLegacyKey_Flick = "SpeedNotes_Flick"

    /// 按登录用户 ID 生成速记存储 Key
    private func speedNotesStorageKey_Flick() -> String {
        let uid_flick = getCurrentUser_Flick().userId_Flick ?? 0
        return "SpeedNotes_Flick_uid_\(uid_flick)"
    }

    /// 加载速记列表（从 UserDefaults，按当前用户分库；必要时从旧全局 Key 迁移）
    func loadSpeedNotes_Flick() -> [SpeedNote_Flick] {
        let key_flick = speedNotesStorageKey_Flick()
        if let data_flick = UserDefaults.standard.data(forKey: key_flick),
           let notes_flick = try? JSONDecoder().decode([SpeedNote_Flick].self, from: data_flick) {
            return notes_flick
        }
        if key_flick != "SpeedNotes_Flick_uid_0",
           let legacy_flick = UserDefaults.standard.data(forKey: speedNotesLegacyKey_Flick),
           let notes_flick = try? JSONDecoder().decode([SpeedNote_Flick].self, from: legacy_flick) {
            saveSpeedNotes_Flick(notes_flick)
            UserDefaults.standard.removeObject(forKey: speedNotesLegacyKey_Flick)
            return notes_flick
        }
        return []
    }

    /// 保存速记列表到 UserDefaults（当前用户分键）
    private func saveSpeedNotes_Flick(_ notes_flick: [SpeedNote_Flick]) {
        if let data_flick = try? JSONEncoder().encode(notes_flick) {
            UserDefaults.standard.set(data_flick, forKey: speedNotesStorageKey_Flick())
        }
    }

    /// 添加速记（自动锁定时间，不可修改）
    /// - Parameter content_flick: 速记内容
    /// - Returns: 新建的速记对象
    @discardableResult
    func addSpeedNote_Flick(content_flick: String) -> SpeedNote_Flick? {
        guard isLoggedIn_Flick else { showLoginPrompt_Flick(); return nil }
        let trimmed_flick = content_flick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_flick.isEmpty else { return nil }
        var notes_flick = loadSpeedNotes_Flick()
        let note_flick = SpeedNote_Flick(content_Flick: trimmed_flick)
        notes_flick.insert(note_flick, at: 0) // 最新在前
        saveSpeedNotes_Flick(notes_flick)
        notifyStateChange_Flick()
        return note_flick
    }

    /// 为指定速记追加补充内容
    /// - Parameters:
    ///   - noteId_flick: 目标速记 ID
    ///   - content_flick: 补充内容
    func addSupplement_Flick(noteId_flick: String, content_flick: String) {
        guard isLoggedIn_Flick else { showLoginPrompt_Flick(); return }
        let trimmed_flick = content_flick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_flick.isEmpty else { return }
        var notes_flick = loadSpeedNotes_Flick()
        guard let idx_flick = notes_flick.firstIndex(where: { $0.noteId_Flick == noteId_flick }) else { return }
        let supplement_flick = SpeedNoteSupplement_Flick(content_Flick: trimmed_flick)
        notes_flick[idx_flick].supplements_Flick.append(supplement_flick)
        saveSpeedNotes_Flick(notes_flick)
        notifyStateChange_Flick()
    }

    /// 删除指定速记
    /// - Parameter noteId_flick: 目标速记 ID
    func deleteSpeedNote_Flick(noteId_flick: String) {
        var notes_flick = loadSpeedNotes_Flick()
        notes_flick.removeAll { $0.noteId_Flick == noteId_flick }
        saveSpeedNotes_Flick(notes_flick)
        notifyStateChange_Flick()
    }

    // MARK: - 时间胶囊操作

    private let timeCapsulesLegacyKey_Flick = "TimeCapsules_Flick"

    private func timeCapsulesStorageKey_Flick() -> String {
        let uid_flick = getCurrentUser_Flick().userId_Flick ?? 0
        return "TimeCapsules_Flick_uid_\(uid_flick)"
    }

    /// 加载时间胶囊（按当前用户分库；必要时迁移旧 Key）
    func loadTimeCapsules_Flick() -> [TimeCapsule_Flick] {
        let key_flick = timeCapsulesStorageKey_Flick()
        if let data_flick = UserDefaults.standard.data(forKey: key_flick),
           let capsules_flick = try? JSONDecoder().decode([TimeCapsule_Flick].self, from: data_flick) {
            return capsules_flick
        }
        if key_flick != "TimeCapsules_Flick_uid_0",
           let legacy_flick = UserDefaults.standard.data(forKey: timeCapsulesLegacyKey_Flick),
           let capsules_flick = try? JSONDecoder().decode([TimeCapsule_Flick].self, from: legacy_flick) {
            saveTimeCapsules_Flick(capsules_flick)
            UserDefaults.standard.removeObject(forKey: timeCapsulesLegacyKey_Flick)
            return capsules_flick
        }
        return []
    }

    private func saveTimeCapsules_Flick(_ capsules_flick: [TimeCapsule_Flick]) {
        if let data_flick = try? JSONEncoder().encode(capsules_flick) {
            UserDefaults.standard.set(data_flick, forKey: timeCapsulesStorageKey_Flick())
        }
    }

    /// 封存时间胶囊
    /// - Parameters:
    ///   - content_flick: 封存内容
    ///   - moodNote_flick: 心情备注
    ///   - moodEmoji_flick: 心情 Emoji
    ///   - unlockOption_flick: 解锁时间选项
    /// - Returns: 新建的时间胶囊对象
    @discardableResult
    func sealTimeCapsule_Flick(content_flick: String,
                               moodNote_flick: String,
                               moodEmoji_flick: String,
                               unlockOption_flick: CapsuleUnlockOption_Flick) -> TimeCapsule_Flick? {
        guard isLoggedIn_Flick else { showLoginPrompt_Flick(); return nil }
        let trimmed_flick = content_flick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_flick.isEmpty else { return nil }
        var capsules_flick = loadTimeCapsules_Flick()
        let capsule_flick = TimeCapsule_Flick(
            content_Flick: trimmed_flick,
            moodNote_Flick: moodNote_flick,
            moodEmoji_Flick: moodEmoji_flick,
            unlockOption_Flick: unlockOption_flick
        )
        capsules_flick.insert(capsule_flick, at: 0)
        saveTimeCapsules_Flick(capsules_flick)
        notifyStateChange_Flick()
        return capsule_flick
    }

    /// 删除指定时间胶囊
    /// - Parameter capsuleId_flick: 目标胶囊 ID
    func deleteTimeCapsule_Flick(capsuleId_flick: String) {
        var capsules_flick = loadTimeCapsules_Flick()
        capsules_flick.removeAll { $0.capsuleId_Flick == capsuleId_flick }
        saveTimeCapsules_Flick(capsules_flick)
        notifyStateChange_Flick()
    }

    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Flick() {
        NotificationCenter.default.post(
            name: UserViewModel_Flick.userStateDidChangeNotification_Flick,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Flick() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Flick.toLogin_Flick(style_flick: .present_flick)
        }
    }
}
