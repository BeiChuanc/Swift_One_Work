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
        Utils_Base_one.showLoading_Base_one(message_base_one: "Logging in...")
        
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
            Utils_Base_one.showSuccess_Base_one(message_base_one: "Login successful!")
            
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
        
        // 显示加载动画
        Utils_Base_one.showLoading_Base_one(message_base_one: "Logging out...")
        
        // 重置为游客状态
        loggedUser_Base_one = defaultUser_Base_one
        
        // 清空AI聊天记录
        MessageViewModel_Base_one.shared_Base_one.clearAiChat_Base_one()
        
        // 重新初始化本地数据
        LocalData_Base_one.shared_Base_one.initData_Base_one()
        
        notifyStateChange_Base_one()
        
        // 跳转到首页
         Navigation_Base_one.toHome_Base_one()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            // 关闭加载动画
            Utils_Base_one.dismissLoading_Base_one()
            
            if logoutType_base_one == .delete_base_one {
                Utils_Base_one.showInfo_Base_one(
                    message_base_one: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_base_one: 3.0
                )
            } else {
                Utils_Base_one.showSuccess_Base_one(message_base_one: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Base_one(headUrl_base_one: String) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userHead_Base_one = headUrl_base_one
        loggedUser_Base_one = user_base_one
        Utils_Base_one.showSuccess_Base_one(message_base_one: "Avatar updated successfully")
        notifyStateChange_Base_one()
    }
    
    /// 更新用户昵称
    func updateName_Base_one(userName_base_one: String) {
        guard let user_base_one = loggedUser_Base_one else { return }
        user_base_one.userName_Base_one = userName_base_one
        loggedUser_Base_one = user_base_one
        Utils_Base_one.showSuccess_Base_one(message_base_one: "Name updated successfully")
        notifyStateChange_Base_one()
    }
    
    /// 上传用户封面
    func uploadCover_Base_one(coverUrl_base_one: String) {
        Utils_Base_one.showSuccess_Base_one(message_base_one: "Cover updated successfully")
        notifyStateChange_Base_one()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Base_one() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Base_one() {
        if hasCheckedInToday_Base_one() {
            Utils_Base_one.showWarning_Base_one(
                message_base_one: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Base_one.showSuccess_Base_one(
            message_base_one: "Check-in successful!",
            image_base_one: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Base_one()
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
        
        // 显示加载动画
        Utils_Base_one.showLoading_Base_one(message_base_one: "Processing...")
        
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
            Utils_Base_one.dismissLoading_Base_one()
            Utils_Base_one.showSuccess_Base_one(
                message_base_one: "This user will no longer appear.",
                delay_base_one: 2.0
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
        Utils_Base_one.showWarning_Base_one(
            message_base_one: "Please login first.",
            delay_base_one: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
        }
    }
}
