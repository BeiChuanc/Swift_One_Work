import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Moode {
    /// 删除账号
    case delete_moode
    /// 普通登出
    case logout_moode
}

/// 用户状态管理类
@MainActor
class UserViewModel_Moode {
    
    /// 单例
    static let shared_Moode = UserViewModel_Moode()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Moode = Notification.Name("UserStateDidChange_Moode")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Moode: LoginUserModel_Moode?
    
    /// 默认用户（游客）
    private let defaultUser_Moode = LoginUserModel_Moode(
        userId_Moode: 0,
        userPwd_Moode: nil,
        userName_Moode: "Guest",
        userHead_Moode: "default_avatar",
        userPosts_Moode: [],
        userLike_Moode: [],
        userFollow_Moode: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Moode: Bool {
        return loggedUser_Moode?.userId_Moode != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Moode() -> LoginUserModel_Moode {
        return loggedUser_Moode ?? defaultUser_Moode
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Moode() {
        loggedUser_Moode = defaultUser_Moode
        notifyStateChange_Moode()
    }
    
    // MARK: - 登录/登出

    /// 通过用户ID登录
    func loginById_Moode(userId_moode: Int) {
        // 显示加载动画
        Utils_Moode.showLoading_Moode(message_Moode: "Logging in...")
        
        // 创建登录用户
        loggedUser_Moode = LoginUserModel_Moode(
            userId_Moode: userId_moode,
            userPwd_Moode: nil,
            userName_Moode: "Mooder", // 可以从本地数据或服务器获取
            userHead_Moode: "user_avatar",
            userPosts_Moode: [],
            userLike_Moode: [],
            userFollow_Moode: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Moode.dismissLoading_Moode()
            
            // 显示成功提示
            Utils_Moode.showSuccess_Moode(message_Moode: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Moode.switchToTabbar_Moode(animated: true)
            
            notifyStateChange_Moode()
        }
    }
    
    /// 用户登出
    func logout_Moode(logoutType_moode: LogOutType_Moode) {
        if !isLoggedIn_Moode {
            showLoginPrompt_Moode()
            return
        }
        
        // 重置为游客状态
        loggedUser_Moode = defaultUser_Moode
        
        // 清空AI聊天记录
        MessageViewModel_Moode.shared_Moode.clearAiChat_Moode()
        
        // 重新初始化本地数据
        LocalData_Moode.shared_Moode.initData_Moode()
        
        notifyStateChange_Moode()
        
        // 跳转到首页
         Navigation_Moode.switchToTabbar_Moode()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            if logoutType_moode == .delete_moode {
                Utils_Moode.showInfo_Moode(
                    message_Moode: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Moode: 3.0
                )
            } else {
                Utils_Moode.showSuccess_Moode(message_Moode: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Moode(headUrl_moode: String) {
        guard let user_moode = loggedUser_Moode else { return }
        user_moode.userHead_Moode = headUrl_moode
        loggedUser_Moode = user_moode
        Utils_Moode.showSuccess_Moode(message_Moode: "Avatar updated successfully")
        notifyStateChange_Moode()
    }
    
    /// 更新用户昵称
    func updateName_Moode(userName_moode: String) {
        guard let user_moode = loggedUser_Moode else { return }
        user_moode.userName_Moode = userName_moode
        loggedUser_Moode = user_moode
        Utils_Moode.showSuccess_Moode(message_Moode: "Name updated successfully")
        notifyStateChange_Moode()
    }
    
    /// 更新用户简介
    func updateIntroduce_Moode(introduce_moode: String) {
        guard let user_moode = loggedUser_Moode else { return }
        user_moode.userIntroduce_Moode = introduce_moode
        loggedUser_Moode = user_moode
        Utils_Moode.showSuccess_Moode(message_Moode: "Bio updated successfully")
        notifyStateChange_Moode()
    }

    /// 上传用户封面
    func uploadCover_Moode(coverUrl_moode: String) {
        Utils_Moode.showSuccess_Moode(message_Moode: "Cover updated successfully")
        notifyStateChange_Moode()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Moode() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Moode() {
        if hasCheckedInToday_Moode() {
            Utils_Moode.showWarning_Moode(
                message_Moode: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Moode.showSuccess_Moode(
            message_Moode: "Check-in successful!",
            image_Moode: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Moode()
    }
    
    // MARK: - 关注功能
    
    /// 判断登录用户是否关注了指定用户
    /// - Parameter user_moode: 目标用户模型
    /// - Returns: 已关注返回 true，否则 false
    func isFollowing_Moode(user_moode: PrewUserModel_Moode) -> Bool {
        guard let loggedUser = loggedUser_Moode else { return false }
        return loggedUser.userFollow_Moode.contains(where: { $0.userId_Moode == user_moode.userId_Moode })
    }
    
    /// 关注/取消关注用户
    func followUser_Moode(user_moode: PrewUserModel_Moode) {
        if !isLoggedIn_Moode {
            showLoginPrompt_Moode()
            return
        }
        
        if isFollowing_Moode(user_moode: user_moode) {
            // 取消关注
            loggedUser_Moode?.userFollow_Moode.removeAll { $0.userId_Moode == user_moode.userId_Moode }
        } else {
            // 关注
            loggedUser_Moode?.userFollow_Moode.append(user_moode)
        }
        
        notifyStateChange_Moode()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Moode(user_moode: PrewUserModel_Moode) {
        guard let userId_moode = user_moode.userId_Moode else { return }
        
        // 显示加载动画
        Utils_Moode.showLoading_Moode(message_Moode: "Processing...")
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Moode.shared_Moode.deleteUserMessages_Moode(
            userId_moode: userId_moode
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Moode.shared_Moode.deleteUserPosts_Moode(
            userId_moode: userId_moode
        )
        
        // 从本地用户列表中移除
        LocalData_Moode.shared_Moode.userList_Moode.removeAll { $0.userId_Moode == userId_moode }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Moode.dismissLoading_Moode()
            Utils_Moode.showSuccess_Moode(
                message_Moode: "This user will no longer appear.",
                delay_Moode: 2.0
            )
        }
        
        notifyStateChange_Moode()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Moode(userId_moode: Int) -> Bool {
        return loggedUser_Moode?.userId_Moode == userId_moode
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Moode(userId_moode: Int) -> PrewUserModel_Moode {
        let users_moode = LocalData_Moode.shared_Moode.userList_Moode
        
        if let user_moode = users_moode.first(where: { $0.userId_Moode == userId_moode }) {
            return user_moode
        }
        
        // 返回默认用户
        let defaultPrewUser_moode = PrewUserModel_Moode()
        defaultPrewUser_moode.userId_Moode = userId_moode
        defaultPrewUser_moode.userName_Moode = "Guest"
        defaultPrewUser_moode.userHead_Moode = "default_avatar"
        return defaultPrewUser_moode
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Moode() -> [PrewUserModel_Moode] {
        let users_moode = LocalData_Moode.shared_Moode.userList_Moode
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_moode
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Moode(post_moode: TitleModel_Moode) {
        guard let user_moode = loggedUser_Moode else { return }
        user_moode.userPosts_Moode.append(post_moode)
        loggedUser_Moode = user_moode
        notifyStateChange_Moode()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Moode(post_moode: TitleModel_Moode) {
        guard let user_moode = loggedUser_Moode else { return }
        user_moode.userPosts_Moode.removeAll { $0.titleId_Moode == post_moode.titleId_Moode }
        loggedUser_Moode = user_moode
        notifyStateChange_Moode()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Moode(post_moode: TitleModel_Moode) {
        guard let user_moode = loggedUser_Moode else { return }
        
        // 检查是否已存在
        if !user_moode.userLike_Moode.contains(where: { $0.titleId_Moode == post_moode.titleId_Moode }) {
            user_moode.userLike_Moode.append(post_moode)
            loggedUser_Moode = user_moode
            notifyStateChange_Moode()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Moode(post_moode: TitleModel_Moode) {
        guard let user_moode = loggedUser_Moode else { return }
        user_moode.userLike_Moode.removeAll { $0.titleId_Moode == post_moode.titleId_Moode }
        loggedUser_Moode = user_moode
        notifyStateChange_Moode()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Moode(post_moode: TitleModel_Moode) -> Bool {
        guard let user_moode = loggedUser_Moode else { return false }
        return user_moode.userLike_Moode.contains { $0.titleId_Moode == post_moode.titleId_Moode }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Moode() {
        NotificationCenter.default.post(
            name: UserViewModel_Moode.userStateDidChangeNotification_Moode,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Moode() {
        Utils_Moode.showWarning_Moode(
            message_Moode: "Please login first.",
            delay_Moode: 1.5
        )
        
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            Navigation_Moode.toLogin_Moode(style_moode: .present_moode)
        }
    }
}
