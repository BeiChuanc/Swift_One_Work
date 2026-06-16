import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Retrs {
    /// 删除账号
    case delete_retrs
    /// 普通登出
    case logout_retrs
}

/// 用户状态管理类
@MainActor
class UserViewModel_Retrs {
    
    /// 单例
    static let shared_Retrs = UserViewModel_Retrs()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Retrs = Notification.Name("UserStateDidChange_Retrs")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Retrs: LoginUserModel_Retrs?
    
    /// 默认用户（游客）
    private let defaultUser_Retrs = LoginUserModel_Retrs(
        userId_Retrs: 0,
        userPwd_Retrs: nil,
        userName_Retrs: "Guest",
        userHead_Retrs: "default_avatar",
        userPosts_Retrs: [],
        userLike_Retrs: [],
        userFollow_Retrs: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Retrs: Bool {
        return loggedUser_Retrs?.userId_Retrs != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Retrs() -> LoginUserModel_Retrs {
        return loggedUser_Retrs ?? defaultUser_Retrs
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Retrs() {
        loggedUser_Retrs = defaultUser_Retrs
        notifyStateChange_Retrs()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Retrs(userId_retrs: Int) {
        // 显示加载动画
        Utils_Retrs.showLoading_Retrs(message_Retrs: "Logging in...")
        
        // 创建登录用户
        loggedUser_Retrs = LoginUserModel_Retrs(
            userId_Retrs: userId_retrs,
            userPwd_Retrs: nil,
            userName_Retrs: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Retrs: "user_avatar",
            userPosts_Retrs: [],
            userLike_Retrs: [],
            userFollow_Retrs: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Retrs.dismissLoading_Retrs()
            
            // 显示成功提示
            Utils_Retrs.showSuccess_Retrs(message_Retrs: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Retrs.switchToTabbar_Retrs(animated: true)
            
            notifyStateChange_Retrs()
        }
    }
    
    /// 用户登出
    func logout_Retrs(logoutType_retrs: LogOutType_Retrs) {
        if !isLoggedIn_Retrs {
            showLoginPrompt_Retrs()
            return
        }
        
        // 重置为游客状态
        loggedUser_Retrs = defaultUser_Retrs
        
        // 清空AI聊天记录
        MessageViewModel_Retrs.shared_Retrs.clearAiChat_Retrs()
        
        // 重新初始化本地数据
        LocalData_Retrs.shared_Retrs.initData_Retrs()
        
        notifyStateChange_Retrs()
        
        // 跳转到首页
         Navigation_Retrs.switchToTabbar_Retrs()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_retrs == .delete_retrs {
                Utils_Retrs.showInfo_Retrs(
                    message_Retrs: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Retrs: 3.0
                )
            } else {
                Utils_Retrs.showSuccess_Retrs(message_Retrs: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Retrs(headUrl_retrs: String) {
        guard let user_retrs = loggedUser_Retrs else { return }
        user_retrs.userHead_Retrs = headUrl_retrs
        loggedUser_Retrs = user_retrs
        Utils_Retrs.showSuccess_Retrs(message_Retrs: "Avatar updated successfully")
        notifyStateChange_Retrs()
    }
    
    /// 更新用户昵称
    func updateName_Retrs(userName_retrs: String) {
        guard let user_retrs = loggedUser_Retrs else { return }
        user_retrs.userName_Retrs = userName_retrs
        loggedUser_Retrs = user_retrs
        Utils_Retrs.showSuccess_Retrs(message_Retrs: "Name updated successfully")
        notifyStateChange_Retrs()
    }
    
    /// 上传用户封面
    func uploadCover_Retrs(coverUrl_retrs: String) {
        Utils_Retrs.showSuccess_Retrs(message_Retrs: "Cover updated successfully")
        notifyStateChange_Retrs()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Retrs() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Retrs() {
        if hasCheckedInToday_Retrs() {
            Utils_Retrs.showWarning_Retrs(
                message_Retrs: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Retrs.showSuccess_Retrs(
            message_Retrs: "Check-in successful!",
            image_Retrs: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Retrs()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_retrs: 目标用户
    /// - Returns: 当前登录用户是否已关注目标用户
    func isFollowing_Retrs(user_retrs: PrewUserModel_Retrs) -> Bool {
        guard let currentUser_retrs = loggedUser_Retrs else { return false }
        return currentUser_retrs.userFollow_Retrs.contains(where: { $0.userId_Retrs == user_retrs.userId_Retrs })
    }
    
    /// 关注/取消关注用户
    func followUser_Retrs(user_retrs: PrewUserModel_Retrs) {
        if !isLoggedIn_Retrs {
            showLoginPrompt_Retrs()
            return
        }
        
        if isFollowing_Retrs(user_retrs: user_retrs) {
            // 取消关注
            loggedUser_Retrs?.userFollow_Retrs.removeAll { $0.userId_Retrs == user_retrs.userId_Retrs }
        } else {
            // 关注
            loggedUser_Retrs?.userFollow_Retrs.append(user_retrs)
        }
        
        notifyStateChange_Retrs()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Retrs(user_retrs: PrewUserModel_Retrs) {
        guard let userId_retrs = user_retrs.userId_Retrs else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Retrs.shared_Retrs.deleteUserMessages_Retrs(
            userId_retrs: userId_retrs
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Retrs.shared_Retrs.deleteUserPosts_Retrs(
            userId_retrs: userId_retrs
        )
        
        // 从本地用户列表中移除
        LocalData_Retrs.shared_Retrs.userList_Retrs.removeAll { $0.userId_Retrs == userId_retrs }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Retrs.showSuccess_Retrs(
                message_Retrs: "This user will no longer appear.",
                delay_Retrs: 2.0
            )
        }
        
        notifyStateChange_Retrs()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Retrs(userId_retrs: Int) -> Bool {
        return loggedUser_Retrs?.userId_Retrs == userId_retrs
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Retrs(userId_retrs: Int) -> PrewUserModel_Retrs {
        let users_retrs = LocalData_Retrs.shared_Retrs.userList_Retrs
        
        if let user_retrs = users_retrs.first(where: { $0.userId_Retrs == userId_retrs }) {
            return user_retrs
        }
        
        // 返回默认用户
        let defaultPrewUser_retrs = PrewUserModel_Retrs()
        defaultPrewUser_retrs.userId_Retrs = userId_retrs
        defaultPrewUser_retrs.userName_Retrs = "Guest"
        defaultPrewUser_retrs.userHead_Retrs = "default_avatar"
        return defaultPrewUser_retrs
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Retrs() -> [PrewUserModel_Retrs] {
        let users_retrs = LocalData_Retrs.shared_Retrs.userList_Retrs
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_retrs
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Retrs(post_retrs: TitleModel_Retrs) {
        guard let user_retrs = loggedUser_Retrs else { return }
        user_retrs.userPosts_Retrs.append(post_retrs)
        loggedUser_Retrs = user_retrs
        notifyStateChange_Retrs()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Retrs(post_retrs: TitleModel_Retrs) {
        guard let user_retrs = loggedUser_Retrs else { return }
        user_retrs.userPosts_Retrs.removeAll { $0.titleId_Retrs == post_retrs.titleId_Retrs }
        loggedUser_Retrs = user_retrs
        notifyStateChange_Retrs()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Retrs(post_retrs: TitleModel_Retrs) {
        guard let user_retrs = loggedUser_Retrs else { return }
        
        // 检查是否已存在
        if !user_retrs.userLike_Retrs.contains(where: { $0.titleId_Retrs == post_retrs.titleId_Retrs }) {
            user_retrs.userLike_Retrs.append(post_retrs)
            loggedUser_Retrs = user_retrs
            notifyStateChange_Retrs()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Retrs(post_retrs: TitleModel_Retrs) {
        guard let user_retrs = loggedUser_Retrs else { return }
        user_retrs.userLike_Retrs.removeAll { $0.titleId_Retrs == post_retrs.titleId_Retrs }
        loggedUser_Retrs = user_retrs
        notifyStateChange_Retrs()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Retrs(post_retrs: TitleModel_Retrs) -> Bool {
        guard let user_retrs = loggedUser_Retrs else { return false }
        return user_retrs.userLike_Retrs.contains { $0.titleId_Retrs == post_retrs.titleId_Retrs }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Retrs() {
        NotificationCenter.default.post(
            name: UserViewModel_Retrs.userStateDidChangeNotification_Retrs,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Retrs() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs)
        }
    }
}
