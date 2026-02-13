import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Glasspaint {
    /// 删除账号
    case delete_glasspaint
    /// 普通登出
    case logout_glasspaint
}

/// 用户状态管理类
@MainActor
class UserViewModel_Glasspaint {
    
    /// 单例
    static let shared_Glasspaint = UserViewModel_Glasspaint()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Glasspaint = Notification.Name("UserStateDidChange_Glasspaint")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Glasspaint: LoginUserModel_Glasspaint?
    
    /// 默认用户（游客）
    private let defaultUser_Glasspaint = LoginUserModel_Glasspaint(
        userId_Glasspaint: 0,
        userPwd_Glasspaint: nil,
        userName_Glasspaint: "Guest",
        userHead_Glasspaint: "default_avatar",
        userPosts_Glasspaint: [],
        userLike_Glasspaint: [],
        userFollow_Glasspaint: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Glasspaint: Bool {
        return loggedUser_Glasspaint?.userId_Glasspaint != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Glasspaint() -> LoginUserModel_Glasspaint {
        return loggedUser_Glasspaint ?? defaultUser_Glasspaint
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Glasspaint() {
        loggedUser_Glasspaint = defaultUser_Glasspaint
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Glasspaint(userId_glasspaint: Int) {
        // 显示加载动画
        Utils_Glasspaint.showLoading_Glasspaint(message_Glasspaint: "Logging in...")
        
        // 创建登录用户
        loggedUser_Glasspaint = LoginUserModel_Glasspaint(
            userId_Glasspaint: userId_glasspaint,
            userPwd_Glasspaint: nil,
            userName_Glasspaint: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Glasspaint: "user_avatar",
            userPosts_Glasspaint: [],
            userLike_Glasspaint: [],
            userFollow_Glasspaint: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Glasspaint.dismissLoading_Glasspaint()
            
            // 显示成功提示
            Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Glasspaint.switchToTabbar_Glasspaint(animated: true)
            
            notifyStateChange_Glasspaint()
        }
    }
    
    /// 用户登出
    func logout_Glasspaint(logoutType_glasspaint: LogOutType_Glasspaint) {
        if !isLoggedIn_Glasspaint {
            showLoginPrompt_Glasspaint()
            return
        }
        
        // 显示加载动画
        Utils_Glasspaint.showLoading_Glasspaint(message_Glasspaint: "Logging out...")
        
        // 重置为游客状态
        loggedUser_Glasspaint = defaultUser_Glasspaint
        
        // 清空AI聊天记录
        MessageViewModel_Glasspaint.shared_Glasspaint.clearAiChat_Glasspaint()
        
        // 重新初始化本地数据
        LocalData_Glasspaint.shared_Glasspaint.initData_Glasspaint()
        
        notifyStateChange_Glasspaint()
        
        // 跳转到首页
         Navigation_Glasspaint.toHome_Glasspaint()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            // 关闭加载动画
            Utils_Glasspaint.dismissLoading_Glasspaint()
            
            if logoutType_glasspaint == .delete_glasspaint {
                Utils_Glasspaint.showInfo_Glasspaint(
                    message_Glasspaint: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Glasspaint: 3.0
                )
            } else {
                Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Glasspaint(headUrl_glasspaint: String) {
        guard let user_glasspaint = loggedUser_Glasspaint else { return }
        user_glasspaint.userHead_Glasspaint = headUrl_glasspaint
        loggedUser_Glasspaint = user_glasspaint
        Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Avatar updated successfully")
        notifyStateChange_Glasspaint()
    }
    
    /// 更新用户昵称
    func updateName_Glasspaint(userName_glasspaint: String) {
        guard let user_glasspaint = loggedUser_Glasspaint else { return }
        user_glasspaint.userName_Glasspaint = userName_glasspaint
        loggedUser_Glasspaint = user_glasspaint
        Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Name updated successfully")
        notifyStateChange_Glasspaint()
    }
    
    /// 上传用户封面
    func uploadCover_Glasspaint(coverUrl_glasspaint: String) {
        Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Cover updated successfully")
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Glasspaint() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Glasspaint() {
        if hasCheckedInToday_Glasspaint() {
            Utils_Glasspaint.showWarning_Glasspaint(
                message_Glasspaint: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Glasspaint.showSuccess_Glasspaint(
            message_Glasspaint: "Check-in successful!",
            image_Glasspaint: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Glasspaint(user_glasspaint: PrewUserModel_Glasspaint) -> Bool {
        guard let user_glasspaint = loggedUser_Glasspaint else { return false }
        return user_glasspaint.userFollow_Glasspaint.contains(where: { $0.userId_Glasspaint == user_glasspaint.userId_Glasspaint })
    }
    
    /// 关注/取消关注用户
    func followUser_Glasspaint(user_glasspaint: PrewUserModel_Glasspaint) {
        if !isLoggedIn_Glasspaint {
            showLoginPrompt_Glasspaint()
            return
        }
        
        if isFollowing_Glasspaint(user_glasspaint: user_glasspaint) {
            // 取消关注
            loggedUser_Glasspaint?.userFollow_Glasspaint.removeAll { $0.userId_Glasspaint == user_glasspaint.userId_Glasspaint }
        } else {
            // 关注
            loggedUser_Glasspaint?.userFollow_Glasspaint.append(user_glasspaint)
        }
        
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Glasspaint(user_glasspaint: PrewUserModel_Glasspaint) {
        guard let userId_glasspaint = user_glasspaint.userId_Glasspaint else { return }
        
        // 显示加载动画
        Utils_Glasspaint.showLoading_Glasspaint(message_Glasspaint: "Processing...")
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Glasspaint.shared_Glasspaint.deleteUserMessages_Glasspaint(
            userId_glasspaint: userId_glasspaint
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Glasspaint.shared_Glasspaint.deleteUserPosts_Glasspaint(
            userId_glasspaint: userId_glasspaint
        )
        
        // 从本地用户列表中移除
        LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint.removeAll { $0.userId_Glasspaint == userId_glasspaint }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Glasspaint.dismissLoading_Glasspaint()
            Utils_Glasspaint.showSuccess_Glasspaint(
                message_Glasspaint: "This user will no longer appear.",
                delay_Glasspaint: 2.0
            )
        }
        
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Glasspaint(userId_glasspaint: Int) -> Bool {
        return loggedUser_Glasspaint?.userId_Glasspaint == userId_glasspaint
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Glasspaint(userId_glasspaint: Int) -> PrewUserModel_Glasspaint {
        let users_glasspaint = LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint
        
        if let user_glasspaint = users_glasspaint.first(where: { $0.userId_Glasspaint == userId_glasspaint }) {
            return user_glasspaint
        }
        
        // 返回默认用户
        let defaultPrewUser_glasspaint = PrewUserModel_Glasspaint()
        defaultPrewUser_glasspaint.userId_Glasspaint = userId_glasspaint
        defaultPrewUser_glasspaint.userName_Glasspaint = "Guest"
        defaultPrewUser_glasspaint.userHead_Glasspaint = "default_avatar"
        return defaultPrewUser_glasspaint
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Glasspaint() -> [PrewUserModel_Glasspaint] {
        let users_glasspaint = LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_glasspaint
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Glasspaint(post_glasspaint: TitleModel_Glasspaint) {
        guard let user_glasspaint = loggedUser_Glasspaint else { return }
        user_glasspaint.userPosts_Glasspaint.append(post_glasspaint)
        loggedUser_Glasspaint = user_glasspaint
        notifyStateChange_Glasspaint()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Glasspaint(post_glasspaint: TitleModel_Glasspaint) {
        guard let user_glasspaint = loggedUser_Glasspaint else { return }
        user_glasspaint.userPosts_Glasspaint.removeAll { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }
        loggedUser_Glasspaint = user_glasspaint
        notifyStateChange_Glasspaint()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Glasspaint(post_glasspaint: TitleModel_Glasspaint) {
        guard let user_glasspaint = loggedUser_Glasspaint else { return }
        
        // 检查是否已存在
        if !user_glasspaint.userLike_Glasspaint.contains(where: { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }) {
            user_glasspaint.userLike_Glasspaint.append(post_glasspaint)
            loggedUser_Glasspaint = user_glasspaint
            notifyStateChange_Glasspaint()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Glasspaint(post_glasspaint: TitleModel_Glasspaint) {
        guard let user_glasspaint = loggedUser_Glasspaint else { return }
        user_glasspaint.userLike_Glasspaint.removeAll { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }
        loggedUser_Glasspaint = user_glasspaint
        notifyStateChange_Glasspaint()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Glasspaint(post_glasspaint: TitleModel_Glasspaint) -> Bool {
        guard let user_glasspaint = loggedUser_Glasspaint else { return false }
        return user_glasspaint.userLike_Glasspaint.contains { $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Glasspaint() {
        NotificationCenter.default.post(
            name: UserViewModel_Glasspaint.userStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Glasspaint() {
        Utils_Glasspaint.showWarning_Glasspaint(
            message_Glasspaint: "Please login first.",
            delay_Glasspaint: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
        }
    }
}
