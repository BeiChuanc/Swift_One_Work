import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Doze {
    /// 删除账号
    case delete_doze
    /// 普通登出
    case logout_doze
}

/// 用户状态管理类
@MainActor
class UserViewModel_Doze {
    
    /// 单例
    static let shared_Doze = UserViewModel_Doze()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Doze = Notification.Name("UserStateDidChange_Doze")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Doze: LoginUserModel_Doze?
    
    /// 默认用户（游客）
    private let defaultUser_Doze = LoginUserModel_Doze(
        userId_Doze: 0,
        userPwd_Doze: nil,
        userName_Doze: "Guest",
        userHead_Doze: "default_avatar",
        userPosts_Doze: [],
        userLike_Doze: [],
        userFollow_Doze: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Doze: Bool {
        return loggedUser_Doze?.userId_Doze != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Doze() -> LoginUserModel_Doze {
        return loggedUser_Doze ?? defaultUser_Doze
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Doze() {
        loggedUser_Doze = defaultUser_Doze
        notifyStateChange_Doze()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Doze(userId_doze: Int) {
        // 显示加载动画
        Utils_Doze.showLoading_Doze(message_Doze: "Logging in...")
        
        // 创建登录用户
        loggedUser_Doze = LoginUserModel_Doze(
            userId_Doze: userId_doze,
            userPwd_Doze: nil,
            userName_Doze: "Dozer", // 可以从本地数据或服务器获取
            userHead_Doze: "user_avatar",
            userPosts_Doze: [],
            userLike_Doze: [],
            userFollow_Doze: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Doze.dismissLoading_Doze()
            
            // 显示成功提示
            Utils_Doze.showSuccess_Doze(message_Doze: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Doze.switchToTabbar_Doze(animated: true)
            
            notifyStateChange_Doze()
        }
    }
    
    /// 用户登出
    func logout_Doze(logoutType_doze: LogOutType_Doze) {
        if !isLoggedIn_Doze {
            showLoginPrompt_Doze()
            return
        }
        
        // 重置为游客状态
        loggedUser_Doze = defaultUser_Doze
        
        // 清空AI聊天记录
        MessageViewModel_Doze.shared_Doze.clearAiChat_Doze()
        
        // 重新初始化本地数据
        LocalData_Doze.shared_Doze.initData_Doze()
        
        notifyStateChange_Doze()
        
        // 跳转到首页
         Navigation_Doze.switchToTabbar_Doze()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            // 关闭加载动画
            Utils_Doze.dismissLoading_Doze()
            
            if logoutType_doze == .delete_doze {
                Utils_Doze.showInfo_Doze(
                    message_Doze: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Doze: 3.0
                )
            } else {
                Utils_Doze.showSuccess_Doze(message_Doze: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Doze(headUrl_doze: String) {
        guard let user_doze = loggedUser_Doze else { return }
        user_doze.userHead_Doze = headUrl_doze
        loggedUser_Doze = user_doze
        Utils_Doze.showSuccess_Doze(message_Doze: "Avatar updated successfully")
        notifyStateChange_Doze()
    }
    
    /// 更新用户昵称
    func updateName_Doze(userName_doze: String) {
        guard let user_doze = loggedUser_Doze else { return }
        user_doze.userName_Doze = userName_doze
        loggedUser_Doze = user_doze
        Utils_Doze.showSuccess_Doze(message_Doze: "Name updated successfully")
        notifyStateChange_Doze()
    }

    /// 更新用户简介
    func updateIntroduce_Doze(introduce_doze: String) {
        guard let user_doze = loggedUser_Doze else { return }
        user_doze.userIntroduce_Doze = introduce_doze
        loggedUser_Doze = user_doze
        notifyStateChange_Doze()
    }
    
    /// 上传用户封面
    func uploadCover_Doze(coverUrl_doze: String) {
        Utils_Doze.showSuccess_Doze(message_Doze: "Cover updated successfully")
        notifyStateChange_Doze()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Doze() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Doze() {
        if hasCheckedInToday_Doze() {
            Utils_Doze.showWarning_Doze(
                message_Doze: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Doze.showSuccess_Doze(
            message_Doze: "Check-in successful!",
            image_Doze: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Doze()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_doze: 目标用户
    /// - Returns: 已关注返回 true，否则 false
    func isFollowing_Doze(user_doze: PrewUserModel_Doze) -> Bool {
        // 注意：避免用 user_doze 作为 guard 绑定名，防止遮蔽同名参数
        guard let currentUser_doze = loggedUser_Doze else { return false }
        return currentUser_doze.userFollow_Doze.contains(where: { $0.userId_Doze == user_doze.userId_Doze })
    }
    
    /// 关注/取消关注用户
    func followUser_Doze(user_doze: PrewUserModel_Doze) {
        if !isLoggedIn_Doze {
            showLoginPrompt_Doze()
            return
        }
        
        if isFollowing_Doze(user_doze: user_doze) {
            // 取消关注
            loggedUser_Doze?.userFollow_Doze.removeAll { $0.userId_Doze == user_doze.userId_Doze }
        } else {
            // 关注
            loggedUser_Doze?.userFollow_Doze.append(user_doze)
        }
        
        notifyStateChange_Doze()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Doze(user_doze: PrewUserModel_Doze) {
        guard let userId_doze = user_doze.userId_Doze else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Doze.shared_Doze.deleteUserMessages_Doze(
            userId_doze: userId_doze
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Doze.shared_Doze.deleteUserPosts_Doze(
            userId_doze: userId_doze
        )
        
        // 从本地用户列表中移除
        LocalData_Doze.shared_Doze.userList_Doze.removeAll { $0.userId_Doze == userId_doze }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Doze.showSuccess_Doze(
                message_Doze: "This user will no longer appear.",
                delay_Doze: 2.0
            )
        }
        
        notifyStateChange_Doze()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Doze(userId_doze: Int) -> Bool {
        return loggedUser_Doze?.userId_Doze == userId_doze
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Doze(userId_doze: Int) -> PrewUserModel_Doze {
        let users_doze = LocalData_Doze.shared_Doze.userList_Doze
        
        if let user_doze = users_doze.first(where: { $0.userId_Doze == userId_doze }) {
            return user_doze
        }
        
        // 返回默认用户
        let defaultPrewUser_doze = PrewUserModel_Doze()
        defaultPrewUser_doze.userId_Doze = userId_doze
        defaultPrewUser_doze.userName_Doze = "Guest"
        defaultPrewUser_doze.userHead_Doze = "default_avatar"
        return defaultPrewUser_doze
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Doze() -> [PrewUserModel_Doze] {
        let users_doze = LocalData_Doze.shared_Doze.userList_Doze
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_doze
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Doze(post_doze: TitleModel_Doze) {
        guard let user_doze = loggedUser_Doze else { return }
        user_doze.userPosts_Doze.append(post_doze)
        loggedUser_Doze = user_doze
        notifyStateChange_Doze()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Doze(post_doze: TitleModel_Doze) {
        guard let user_doze = loggedUser_Doze else { return }
        user_doze.userPosts_Doze.removeAll { $0.titleId_Doze == post_doze.titleId_Doze }
        loggedUser_Doze = user_doze
        notifyStateChange_Doze()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Doze(post_doze: TitleModel_Doze) {
        guard let user_doze = loggedUser_Doze else { return }
        
        // 检查是否已存在
        if !user_doze.userLike_Doze.contains(where: { $0.titleId_Doze == post_doze.titleId_Doze }) {
            user_doze.userLike_Doze.append(post_doze)
            loggedUser_Doze = user_doze
            notifyStateChange_Doze()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Doze(post_doze: TitleModel_Doze) {
        guard let user_doze = loggedUser_Doze else { return }
        user_doze.userLike_Doze.removeAll { $0.titleId_Doze == post_doze.titleId_Doze }
        loggedUser_Doze = user_doze
        notifyStateChange_Doze()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Doze(post_doze: TitleModel_Doze) -> Bool {
        guard let user_doze = loggedUser_Doze else { return false }
        return user_doze.userLike_Doze.contains { $0.titleId_Doze == post_doze.titleId_Doze }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Doze() {
        NotificationCenter.default.post(
            name: UserViewModel_Doze.userStateDidChangeNotification_Doze,
            object: nil
        )
    }
    
    // MARK: - 睡眠相册统计同步

    /// 将从相册数据聚合的统计结果写入当前用户模型
    /// - Parameters:
    ///   - albumCount_doze: 相册总数量
    ///   - totalLogs_doze: 日志（帖子）总数
    ///   - avgQualityPct_doze: 平均睡眠质量百分比（0~100）
    ///   - totalDuration_doze: 总睡眠时长格式化字符串（如 "7h 30m"）
    func updateSleepStats_Doze(albumCount_doze: Int, totalLogs_doze: Int,
                               avgQualityPct_doze: Int, totalDuration_doze: String) {
        // 更新当前登录用户
        loggedUser_Doze?.sleepAlbumCount_Doze = albumCount_doze
        loggedUser_Doze?.totalSleepLogs_Doze = totalLogs_doze
        loggedUser_Doze?.avgSleepQualityPct_Doze = avgQualityPct_doze
        loggedUser_Doze?.totalSleepDuration_Doze = totalDuration_doze
        // 同步到默认用户（游客回退保持一致）
        defaultUser_Doze.sleepAlbumCount_Doze = albumCount_doze
        defaultUser_Doze.totalSleepLogs_Doze = totalLogs_doze
        defaultUser_Doze.avgSleepQualityPct_Doze = avgQualityPct_doze
        defaultUser_Doze.totalSleepDuration_Doze = totalDuration_doze
    }

    /// 显示登录提示
    private func showLoginPrompt_Doze() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Navigation_Doze.toLogin_Doze(style_doze: .present_doze)
        }
    }
}
