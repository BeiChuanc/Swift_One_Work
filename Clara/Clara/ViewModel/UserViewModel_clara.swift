import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Clara {
    /// 删除账号
    case delete_clara
    /// 普通登出
    case logout_clara
}

/// 用户状态管理类
@MainActor
class UserViewModel_Clara {
    
    /// 单例
    static let shared_Clara = UserViewModel_Clara()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Clara = Notification.Name("UserStateDidChange_Clara")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Clara: LoginUserModel_Clara?
    
    /// 默认用户（游客）
    private let defaultUser_Clara = LoginUserModel_Clara(
        userId_Clara: 0,
        userPwd_Clara: nil,
        userName_Clara: "Guest",
        userHead_Clara: "default_avatar",
        userIntroduce_Clara: "",
        userPosts_Clara: [],
        userLike_Clara: [],
        userFollow_Clara: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Clara: Bool {
        return loggedUser_Clara?.userId_Clara != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Clara() -> LoginUserModel_Clara {
        return loggedUser_Clara ?? defaultUser_Clara
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Clara() {
        loggedUser_Clara = defaultUser_Clara
        notifyStateChange_Clara()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Clara(userId_clara: Int) {
        // 显示加载动画
        Utils_Clara.showLoading_Clara(message_Clara: "Logging in...")
        
        // 创建登录用户
        loggedUser_Clara = LoginUserModel_Clara(
            userId_Clara: userId_clara,
            userPwd_Clara: nil,
            userName_Clara: "Claraer", // 可以从本地数据或服务器获取
            userHead_Clara: "user_avatar",
            userIntroduce_Clara: "",
            userPosts_Clara: [],
            userLike_Clara: [],
            userFollow_Clara: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Clara.dismissLoading_Clara()
            
            // 显示成功提示
            Utils_Clara.showSuccess_Clara(message_Clara: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Clara.switchToTabbar_Clara(animated: true)
            
            notifyStateChange_Clara()
        }
    }
    
    /// 用户登出
    func logout_Clara(logoutType_clara: LogOutType_Clara) {
        if !isLoggedIn_Clara {
            showLoginPrompt_Clara()
            return
        }
        
        // 重置为游客状态
        loggedUser_Clara = defaultUser_Clara
        
        // 清空AI聊天记录
        MessageViewModel_Clara.shared_Clara.clearAiChat_Clara()
        
        // 重新初始化本地数据
        LocalData_Clara.shared_Clara.initData_Clara()
        
        notifyStateChange_Clara()
        
        // 跳转到首页
         Navigation_Clara.switchToTabbar_Clara()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_clara == .delete_clara {
                Utils_Clara.showInfo_Clara(
                    message_Clara: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Clara: 3.0
                )
            } else {
                Utils_Clara.showSuccess_Clara(message_Clara: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Clara(headUrl_clara: String) {
        guard let user_clara = loggedUser_Clara else { return }
        user_clara.userHead_Clara = headUrl_clara
        loggedUser_Clara = user_clara
        Utils_Clara.showSuccess_Clara(message_Clara: "Avatar updated successfully")
        notifyStateChange_Clara()
    }
    
    /// 更新用户昵称
    func updateName_Clara(userName_clara: String) {
        guard let user_clara = loggedUser_Clara else { return }
        user_clara.userName_Clara = userName_clara
        loggedUser_Clara = user_clara
        Utils_Clara.showSuccess_Clara(message_Clara: "Name updated successfully")
        notifyStateChange_Clara()
    }

    /// 更新用户简介
    /// - Parameter userIntroduce_clara: 最新个人简介内容
    func updateIntroduce_Clara(userIntroduce_clara: String) {
        guard let user_clara = loggedUser_Clara else { return }
        user_clara.userIntroduce_Clara = userIntroduce_clara
        loggedUser_Clara = user_clara
        notifyStateChange_Clara()
    }
    
    /// 上传用户封面
    func uploadCover_Clara(coverUrl_clara: String) {
        Utils_Clara.showSuccess_Clara(message_Clara: "Cover updated successfully")
        notifyStateChange_Clara()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Clara() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Clara() {
        if hasCheckedInToday_Clara() {
            Utils_Clara.showWarning_Clara(
                message_Clara: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Clara.showSuccess_Clara(
            message_Clara: "Check-in successful!",
            image_Clara: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Clara()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Clara(user_clara: PrewUserModel_Clara) -> Bool {
        guard let loggedUser = loggedUser_Clara else { return false }
        return loggedUser.userFollow_Clara.contains(where: { $0.userId_Clara == user_clara.userId_Clara })
    }
    
    /// 关注/取消关注用户
    func followUser_Clara(user_clara: PrewUserModel_Clara) {
        if !isLoggedIn_Clara {
            showLoginPrompt_Clara()
            return
        }
        
        if isFollowing_Clara(user_clara: user_clara) {
            // 取消关注
            loggedUser_Clara?.userFollow_Clara.removeAll { $0.userId_Clara == user_clara.userId_Clara }
            if let fans = user_clara.userFans_Clara, fans > 0 {
                user_clara.userFans_Clara = fans - 1
            }
        } else {
            // 关注
            loggedUser_Clara?.userFollow_Clara.append(user_clara)
            user_clara.userFans_Clara = (user_clara.userFans_Clara ?? 0) + 1
        }
        
        notifyStateChange_Clara()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Clara(user_clara: PrewUserModel_Clara) {
        guard let userId_clara = user_clara.userId_Clara else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Clara.shared_Clara.deleteUserMessages_Clara(
            userId_clara: userId_clara
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Clara.shared_Clara.deleteUserPosts_Clara(
            userId_clara: userId_clara
        )
        
        // 从本地用户列表中移除
        LocalData_Clara.shared_Clara.userList_Clara.removeAll { $0.userId_Clara == userId_clara }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Clara.showSuccess_Clara(
                message_Clara: "This user will no longer appear.",
                delay_Clara: 2.0
            )
        }
        
        notifyStateChange_Clara()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Clara(userId_clara: Int) -> Bool {
        return loggedUser_Clara?.userId_Clara == userId_clara
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Clara(userId_clara: Int) -> PrewUserModel_Clara {
        let users_clara = LocalData_Clara.shared_Clara.userList_Clara
        
        if let user_clara = users_clara.first(where: { $0.userId_Clara == userId_clara }) {
            return user_clara
        }
        
        // 返回默认用户
        let defaultPrewUser_clara = PrewUserModel_Clara()
        defaultPrewUser_clara.userId_Clara = userId_clara
        defaultPrewUser_clara.userName_Clara = "Guest"
        defaultPrewUser_clara.userHead_Clara = "default_avatar"
        return defaultPrewUser_clara
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Clara() -> [PrewUserModel_Clara] {
        let users_clara = LocalData_Clara.shared_Clara.userList_Clara
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_clara
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Clara(post_clara: TitleModel_Clara) {
        guard let user_clara = loggedUser_Clara else { return }
        user_clara.userPosts_Clara.append(post_clara)
        loggedUser_Clara = user_clara
        notifyStateChange_Clara()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Clara(post_clara: TitleModel_Clara) {
        guard let user_clara = loggedUser_Clara else { return }
        user_clara.userPosts_Clara.removeAll { $0.titleId_Clara == post_clara.titleId_Clara }
        loggedUser_Clara = user_clara
        notifyStateChange_Clara()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Clara(post_clara: TitleModel_Clara) {
        guard let user_clara = loggedUser_Clara else { return }
        
        // 检查是否已存在
        if !user_clara.userLike_Clara.contains(where: { $0.titleId_Clara == post_clara.titleId_Clara }) {
            user_clara.userLike_Clara.append(post_clara)
            loggedUser_Clara = user_clara
            notifyStateChange_Clara()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Clara(post_clara: TitleModel_Clara) {
        guard let user_clara = loggedUser_Clara else { return }
        user_clara.userLike_Clara.removeAll { $0.titleId_Clara == post_clara.titleId_Clara }
        loggedUser_Clara = user_clara
        notifyStateChange_Clara()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Clara(post_clara: TitleModel_Clara) -> Bool {
        guard let user_clara = loggedUser_Clara else { return false }
        return user_clara.userLike_Clara.contains { $0.titleId_Clara == post_clara.titleId_Clara }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Clara() {
        NotificationCenter.default.post(
            name: UserViewModel_Clara.userStateDidChangeNotification_Clara,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Clara() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Clara.toLogin_Clara(style_clara: .present_clara)
        }
    }
}
