import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Nest {
    /// 删除账号
    case delete_nest
    /// 普通登出
    case logout_nest
}

/// 用户状态管理类
@MainActor
class UserViewModel_Nest {
    
    /// 单例
    static let shared_Nest = UserViewModel_Nest()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Nest = Notification.Name("UserStateDidChange_Nest")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Nest: LoginUserModel_Nest?
    
    /// 默认用户（游客）
    private let defaultUser_Nest = LoginUserModel_Nest(
        userId_Nest: 0,
        userPwd_Nest: nil,
        userName_Nest: "Guest",
        userHead_Nest: "default_avatar",
        userBio_Nest: nil,
        userPosts_Nest: [],
        userLike_Nest: [],
        userFollow_Nest: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Nest: Bool {
        return loggedUser_Nest?.userId_Nest != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Nest() -> LoginUserModel_Nest {
        return loggedUser_Nest ?? defaultUser_Nest
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Nest() {
        loggedUser_Nest = defaultUser_Nest
        notifyStateChange_Nest()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Nest(userId_nest: Int) {
        // 显示加载动画
        Utils_Nest.showLoading_Nest(message_Nest: "Logging in...")
        
        // 创建登录用户
        loggedUser_Nest = LoginUserModel_Nest(
            userId_Nest: userId_nest,
            userPwd_Nest: nil,
            userName_Nest: "Wanderer",
            userHead_Nest: "user_avatar",
            userBio_Nest: nil,
            userPosts_Nest: [],
            userLike_Nest: [],
            userFollow_Nest: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Nest.dismissLoading_Nest()
            
            // 显示成功提示
            Utils_Nest.showSuccess_Nest(message_Nest: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Nest.switchToTabbar_Nest(animated: true)
            
            notifyStateChange_Nest()
        }
    }
    
    /// 用户登出
    func logout_Nest(logoutType_nest: LogOutType_Nest) {
        if !isLoggedIn_Nest {
            showLoginPrompt_Nest()
            return
        }
        
        // 重置为游客状态
        loggedUser_Nest = defaultUser_Nest
        
        // 清空AI聊天记录
        MessageViewModel_Nest.shared_Nest.clearAiChat_Nest()
        
        // 重新初始化本地数据
        LocalData_Nest.shared_Nest.initData_Nest()
        
        notifyStateChange_Nest()
        
        // 跳转到首页
         Navigation_Nest.switchToTabbar_Nest()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_nest == .delete_nest {
                Utils_Nest.showInfo_Nest(
                    message_Nest: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Nest: 3.0
                )
            } else {
                Utils_Nest.showSuccess_Nest(message_Nest: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Nest(headUrl_nest: String) {
        guard let user_nest = loggedUser_Nest else { return }
        user_nest.userHead_Nest = headUrl_nest
        loggedUser_Nest = user_nest
        Utils_Nest.showSuccess_Nest(message_Nest: "Avatar updated successfully")
        notifyStateChange_Nest()
    }
    
    /// 更新用户昵称
    func updateName_Nest(userName_nest: String) {
        guard let user_nest = loggedUser_Nest else { return }
        user_nest.userName_Nest = userName_nest
        loggedUser_Nest = user_nest
        Utils_Nest.showSuccess_Nest(message_Nest: "Name updated successfully")
        notifyStateChange_Nest()
    }
    
    /// 更新用户简介
    func updateBio_Nest(bio_nest: String) {
        guard let user_nest = loggedUser_Nest else { return }
        user_nest.userBio_Nest = bio_nest
        loggedUser_Nest = user_nest
        notifyStateChange_Nest()
    }
    
    /// 上传用户封面
    func uploadCover_Nest(coverUrl_nest: String) {
        Utils_Nest.showSuccess_Nest(message_Nest: "Cover updated successfully")
        notifyStateChange_Nest()
    }
    
    // MARK: - 打卡功能

    /// 发布独居好物打卡
    /// - Parameter checkIn_nest: 打卡数据（封面图、描述、标签）
    func addCheckIn_Nest(checkIn_nest: CheckInPost_Nest) {
        guard isLoggedIn_Nest else { return }
        loggedUser_Nest?.userCheckIns_Nest.append(checkIn_nest)
        notifyStateChange_Nest()
    }

    /// 获取当前用户的打卡列表
    func getCheckIns_Nest() -> [CheckInPost_Nest] {
        return loggedUser_Nest?.userCheckIns_Nest ?? []
    }

    /// 检查今天是否已打卡
    func hasCheckedInToday_Nest() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Nest() {
        if hasCheckedInToday_Nest() {
            Utils_Nest.showWarning_Nest(
                message_Nest: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Nest.showSuccess_Nest(
            message_Nest: "Check-in successful!",
            image_Nest: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Nest()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_nest: 目标用户
    /// - Returns: 当前登录用户是否已关注该用户
    func isFollowing_Nest(user_nest: PrewUserModel_Nest) -> Bool {
        // 注意：guard 绑定名改为 currentUser_Nest，避免遮蔽参数 user_nest
        guard let currentUser_Nest = loggedUser_Nest else { return false }
        return currentUser_Nest.userFollow_Nest.contains(where: { $0.userId_Nest == user_nest.userId_Nest })
    }
    
    /// 关注/取消关注用户
    func followUser_Nest(user_nest: PrewUserModel_Nest) {
        if !isLoggedIn_Nest {
            showLoginPrompt_Nest()
            return
        }
        
        if isFollowing_Nest(user_nest: user_nest) {
            // 取消关注
            loggedUser_Nest?.userFollow_Nest.removeAll { $0.userId_Nest == user_nest.userId_Nest }
        } else {
            // 关注
            loggedUser_Nest?.userFollow_Nest.append(user_nest)
        }
        
        notifyStateChange_Nest()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Nest(user_nest: PrewUserModel_Nest) {
        guard let userId_nest = user_nest.userId_Nest else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Nest.shared_Nest.deleteUserMessages_Nest(
            userId_nest: userId_nest
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Nest.shared_Nest.deleteUserPosts_Nest(
            userId_nest: userId_nest
        )
        
        // 从本地用户列表中移除
        LocalData_Nest.shared_Nest.userList_Nest.removeAll { $0.userId_Nest == userId_nest }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Nest.showSuccess_Nest(
                message_Nest: "This user will no longer appear.",
                delay_Nest: 2.0
            )
        }
        
        notifyStateChange_Nest()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Nest(userId_nest: Int) -> Bool {
        return loggedUser_Nest?.userId_Nest == userId_nest
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Nest(userId_nest: Int) -> PrewUserModel_Nest {
        let users_nest = LocalData_Nest.shared_Nest.userList_Nest
        
        if let user_nest = users_nest.first(where: { $0.userId_Nest == userId_nest }) {
            return user_nest
        }
        
        // 返回默认用户
        let defaultPrewUser_nest = PrewUserModel_Nest()
        defaultPrewUser_nest.userId_Nest = userId_nest
        defaultPrewUser_nest.userName_Nest = "Guest"
        defaultPrewUser_nest.userHead_Nest = "default_avatar"
        return defaultPrewUser_nest
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Nest() -> [PrewUserModel_Nest] {
        let users_nest = LocalData_Nest.shared_Nest.userList_Nest
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_nest
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Nest(post_nest: TitleModel_Nest) {
        guard let user_nest = loggedUser_Nest else { return }
        user_nest.userPosts_Nest.append(post_nest)
        loggedUser_Nest = user_nest
        notifyStateChange_Nest()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Nest(post_nest: TitleModel_Nest) {
        guard let user_nest = loggedUser_Nest else { return }
        user_nest.userPosts_Nest.removeAll { $0.titleId_Nest == post_nest.titleId_Nest }
        loggedUser_Nest = user_nest
        notifyStateChange_Nest()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Nest(post_nest: TitleModel_Nest) {
        guard let user_nest = loggedUser_Nest else { return }
        
        // 检查是否已存在
        if !user_nest.userLike_Nest.contains(where: { $0.titleId_Nest == post_nest.titleId_Nest }) {
            user_nest.userLike_Nest.append(post_nest)
            loggedUser_Nest = user_nest
            notifyStateChange_Nest()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Nest(post_nest: TitleModel_Nest) {
        guard let user_nest = loggedUser_Nest else { return }
        user_nest.userLike_Nest.removeAll { $0.titleId_Nest == post_nest.titleId_Nest }
        loggedUser_Nest = user_nest
        notifyStateChange_Nest()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Nest(post_nest: TitleModel_Nest) -> Bool {
        guard let user_nest = loggedUser_Nest else { return false }
        return user_nest.userLike_Nest.contains { $0.titleId_Nest == post_nest.titleId_Nest }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Nest() {
        NotificationCenter.default.post(
            name: UserViewModel_Nest.userStateDidChangeNotification_Nest,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Nest() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
        }
    }
}
