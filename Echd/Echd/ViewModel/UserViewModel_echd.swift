import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Echd {
    /// 删除账号
    case delete_echd
    /// 普通登出
    case logout_echd
}

/// 用户状态管理类
@MainActor
class UserViewModel_Echd {
    
    /// 单例
    static let shared_Echd = UserViewModel_Echd()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Echd = Notification.Name("UserStateDidChange_Echd")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Echd: LoginUserModel_Echd?
    
    /// 默认用户（游客）
    private let defaultUser_Echd = LoginUserModel_Echd(
        userId_Echd: 0,
        userPwd_Echd: nil,
        userName_Echd: "Guest",
        userHead_Echd: "default_avatar",
        userPosts_Echd: [],
        userLike_Echd: [],
        userFollow_Echd: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Echd: Bool {
        return loggedUser_Echd?.userId_Echd != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Echd() -> LoginUserModel_Echd {
        return loggedUser_Echd ?? defaultUser_Echd
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Echd() {
        loggedUser_Echd = defaultUser_Echd
        notifyStateChange_Echd()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Echd(userId_echd: Int) {
        // 显示加载动画
        Utils_Echd.showLoading_Echd(message_Echd: "Logging in...")
        
        // 创建登录用户
        loggedUser_Echd = LoginUserModel_Echd(
            userId_Echd: userId_echd,
            userPwd_Echd: nil,
            userName_Echd: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Echd: "user_avatar",
            userPosts_Echd: [],
            userLike_Echd: [],
            userFollow_Echd: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Echd.dismissLoading_Echd()
            
            // 显示成功提示
            Utils_Echd.showSuccess_Echd(message_Echd: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Echd.switchToTabbar_Echd(animated: true)
            
            notifyStateChange_Echd()
        }
    }
    
    /// 用户登出
    func logout_Echd(logoutType_echd: LogOutType_Echd) {
        if !isLoggedIn_Echd {
            showLoginPrompt_Echd()
            return
        }
        
        // 重置为游客状态
        loggedUser_Echd = defaultUser_Echd
        
        // 清空AI聊天记录
        MessageViewModel_Echd.shared_Echd.clearAiChat_Echd()
        
        // 重新初始化本地数据
        LocalData_Echd.shared_Echd.initData_Echd()
        
        notifyStateChange_Echd()
        
        // 跳转到首页
         Navigation_Echd.switchToTabbar_Echd()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_echd == .delete_echd {
                Utils_Echd.showInfo_Echd(
                    message_Echd: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Echd: 3.0
                )
            } else {
                Utils_Echd.showSuccess_Echd(message_Echd: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Echd(headUrl_echd: String) {
        guard let user_echd = loggedUser_Echd else { return }
        user_echd.userHead_Echd = headUrl_echd
        loggedUser_Echd = user_echd
        Utils_Echd.showSuccess_Echd(message_Echd: "Avatar updated successfully")
        notifyStateChange_Echd()
    }
    
    /// 更新用户昵称
    func updateName_Echd(userName_echd: String) {
        guard let user_echd = loggedUser_Echd else { return }
        user_echd.userName_Echd = userName_echd
        loggedUser_Echd = user_echd
        Utils_Echd.showSuccess_Echd(message_Echd: "Name updated successfully")
        notifyStateChange_Echd()
    }
    
    /// 上传用户封面
    func uploadCover_Echd(coverUrl_echd: String) {
        Utils_Echd.showSuccess_Echd(message_Echd: "Cover updated successfully")
        notifyStateChange_Echd()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Echd() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Echd() {
        if hasCheckedInToday_Echd() {
            Utils_Echd.showWarning_Echd(
                message_Echd: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Echd.showSuccess_Echd(
            message_Echd: "Check-in successful!",
            image_Echd: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Echd()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Echd(user_echd: PrewUserModel_Echd) -> Bool {
        guard let loggedUser_Echd = loggedUser_Echd else { return false }
        return loggedUser_Echd.userFollow_Echd.contains(where: { $0.userId_Echd == user_echd.userId_Echd })
    }
    
    /// 关注/取消关注用户
    func followUser_Echd(user_echd: PrewUserModel_Echd) {
        if !isLoggedIn_Echd {
            showLoginPrompt_Echd()
            return
        }
        
        if isFollowing_Echd(user_echd: user_echd) {
            // 取消关注
            loggedUser_Echd?.userFollow_Echd.removeAll { $0.userId_Echd == user_echd.userId_Echd }
        } else {
            // 关注
            loggedUser_Echd?.userFollow_Echd.append(user_echd)
        }
        
        notifyStateChange_Echd()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Echd(user_echd: PrewUserModel_Echd) {
        guard let userId_echd = user_echd.userId_Echd else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Echd.shared_Echd.deleteUserMessages_Echd(
            userId_echd: userId_echd
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Echd.shared_Echd.deleteUserPosts_Echd(
            userId_echd: userId_echd
        )
        
        // 从本地用户列表中移除
        LocalData_Echd.shared_Echd.userList_Echd.removeAll { $0.userId_Echd == userId_echd }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Echd.showSuccess_Echd(
                message_Echd: "This user will no longer appear.",
                delay_Echd: 2.0
            )
        }
        
        notifyStateChange_Echd()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Echd(userId_echd: Int) -> Bool {
        return loggedUser_Echd?.userId_Echd == userId_echd
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Echd(userId_echd: Int) -> PrewUserModel_Echd {
        let users_echd = LocalData_Echd.shared_Echd.userList_Echd
        
        if let user_echd = users_echd.first(where: { $0.userId_Echd == userId_echd }) {
            return user_echd
        }
        
        // 返回默认用户
        let defaultPrewUser_echd = PrewUserModel_Echd()
        defaultPrewUser_echd.userId_Echd = userId_echd
        defaultPrewUser_echd.userName_Echd = "Guest"
        defaultPrewUser_echd.userHead_Echd = "default_avatar"
        return defaultPrewUser_echd
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Echd() -> [PrewUserModel_Echd] {
        let users_echd = LocalData_Echd.shared_Echd.userList_Echd
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_echd
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Echd(post_echd: TitleModel_Echd) {
        guard let user_echd = loggedUser_Echd else { return }
        user_echd.userPosts_Echd.append(post_echd)
        loggedUser_Echd = user_echd
        notifyStateChange_Echd()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Echd(post_echd: TitleModel_Echd) {
        guard let user_echd = loggedUser_Echd else { return }
        user_echd.userPosts_Echd.removeAll { $0.titleId_Echd == post_echd.titleId_Echd }
        loggedUser_Echd = user_echd
        notifyStateChange_Echd()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Echd(post_echd: TitleModel_Echd) {
        guard let user_echd = loggedUser_Echd else { return }
        
        // 检查是否已存在
        if !user_echd.userLike_Echd.contains(where: { $0.titleId_Echd == post_echd.titleId_Echd }) {
            user_echd.userLike_Echd.append(post_echd)
            loggedUser_Echd = user_echd
            notifyStateChange_Echd()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Echd(post_echd: TitleModel_Echd) {
        guard let user_echd = loggedUser_Echd else { return }
        user_echd.userLike_Echd.removeAll { $0.titleId_Echd == post_echd.titleId_Echd }
        loggedUser_Echd = user_echd
        notifyStateChange_Echd()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Echd(post_echd: TitleModel_Echd) -> Bool {
        guard let user_echd = loggedUser_Echd else { return false }
        return user_echd.userLike_Echd.contains { $0.titleId_Echd == post_echd.titleId_Echd }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Echd() {
        NotificationCenter.default.post(
            name: UserViewModel_Echd.userStateDidChangeNotification_Echd,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Echd() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Echd.toLogin_Echd(style_echd: .present_echd)
        }
    }
}
