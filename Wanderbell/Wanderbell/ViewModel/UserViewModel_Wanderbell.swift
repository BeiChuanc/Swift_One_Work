import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Wanderbell {
    /// 删除账号
    case delete_wanderbell
    /// 普通登出
    case logout_wanderbell
}

/// 用户状态管理类
@MainActor
class UserViewModel_Wanderbell {
    
    /// 单例
    static let shared_Wanderbell = UserViewModel_Wanderbell()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Wanderbell = Notification.Name("UserStateDidChange_Wanderbell")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Wanderbell: LoginUserModel_Wanderbell?
    
    /// 默认用户（游客）
    private let defaultUser_Wanderbell = LoginUserModel_Wanderbell(
        userId_Wanderbell: 0,
        userPwd_Wanderbell: nil,
        userName_Wanderbell: "Guest",
        userHead_Wanderbell: "default_avatar",
        userPosts_Wanderbell: [],
        userLike_Wanderbell: [],
        userFollow_Wanderbell: [],
        userEmotionRecords_Wanderbell: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Wanderbell: Bool {
        return loggedUser_Wanderbell?.userId_Wanderbell != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Wanderbell() -> LoginUserModel_Wanderbell {
        return loggedUser_Wanderbell ?? defaultUser_Wanderbell
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Wanderbell() {
        loggedUser_Wanderbell = defaultUser_Wanderbell
        
        // 加载当前用户的情绪记录
        loadUserEmotionRecords_Wanderbell()
        
        notifyStateChange_Wanderbell()
    }
    
    /// 加载用户情绪记录
    /// 功能：从EmotionViewModel获取当前用户的所有情绪记录并同步到用户模型
    private func loadUserEmotionRecords_Wanderbell() {
        guard let userId_wanderbell = loggedUser_Wanderbell?.userId_Wanderbell else { return }
        
        let userRecords_wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getUserRecords_Wanderbell(userId_wanderbell: userId_wanderbell)
        loggedUser_Wanderbell?.userEmotionRecords_Wanderbell = userRecords_wanderbell
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Wanderbell(userId_wanderbell: Int) {
        // 显示加载动画
        Utils_Wanderbell.showLoading_Wanderbell(message_wanderbell: "Loading...")
        
        // 创建登录用户
        loggedUser_Wanderbell = LoginUserModel_Wanderbell(
            userId_Wanderbell: userId_wanderbell,
            userPwd_Wanderbell: nil,
            userName_Wanderbell: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Wanderbell: "user_avatar",
            userPosts_Wanderbell: [],
            userLike_Wanderbell: [],
            userFollow_Wanderbell: [],
            userEmotionRecords_Wanderbell: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Wanderbell.dismissLoading_Wanderbell()
            
            // 显示成功提示
            Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Login successful!")
            
            // 加载用户情绪记录
            self.loadUserEmotionRecords_Wanderbell()
            
            // 切换到主Tabbar
            Navigation_Wanderbell.switchToTabbar_Wanderbell(animated: true)
            
            notifyStateChange_Wanderbell()
        }
    }
    
    /// 用户登出
    func logout_Wanderbell(logoutType_wanderbell: LogOutType_Wanderbell) {
        if !isLoggedIn_Wanderbell {
            showLoginPrompt_Wanderbell()
            return
        }
        
        // 重置为游客状态
        loggedUser_Wanderbell = defaultUser_Wanderbell
        
        // 清空AI聊天记录
        MessageViewModel_Wanderbell.shared_Wanderbell.clearAiChat_Wanderbell()
        
        // 重新初始化本地数据
        LocalData_Wanderbell.shared_Wanderbell.initData_Wanderbell()
        
        notifyStateChange_Wanderbell()
        
        // 跳转到首页
        Navigation_Wanderbell.switchToTabbar_Wanderbell()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            // 关闭加载动画
            Utils_Wanderbell.dismissLoading_Wanderbell()
            
            if logoutType_wanderbell == .delete_wanderbell {
                Utils_Wanderbell.showInfo_Wanderbell(
                    message_wanderbell: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_wanderbell: 3.0
                )
            } else {
                Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Wanderbell(headUrl_wanderbell: String) {
        guard let user_wanderbell = loggedUser_Wanderbell else { return }
        user_wanderbell.userHead_Wanderbell = headUrl_wanderbell
        loggedUser_Wanderbell = user_wanderbell
        Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Avatar updated successfully")
        notifyStateChange_Wanderbell()
    }
    
    /// 更新用户昵称
    func updateName_Wanderbell(userName_wanderbell: String) {
        guard let user_wanderbell = loggedUser_Wanderbell else { return }
        user_wanderbell.userName_Wanderbell = userName_wanderbell
        loggedUser_Wanderbell = user_wanderbell
        Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Name updated successfully")
        notifyStateChange_Wanderbell()
    }
    
    /// 上传用户封面
    func uploadCover_Wanderbell(coverUrl_wanderbell: String) {
        Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Cover updated successfully")
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Wanderbell() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Wanderbell() {
        if hasCheckedInToday_Wanderbell() {
            Utils_Wanderbell.showWarning_Wanderbell(
                message_wanderbell: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Check-in successful!",
            image_wanderbell: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Wanderbell(user_wanderbell: PrewUserModel_Wanderbell) -> Bool {
        guard let currentUser_wanderbell = loggedUser_Wanderbell else { 
            return false 
        }
        
        let isFollowing_wanderbell = currentUser_wanderbell.userFollow_Wanderbell.contains(where: { 
            $0.userId_Wanderbell == user_wanderbell.userId_Wanderbell 
        })
        
        return isFollowing_wanderbell
    }
    
    /// 关注/取消关注用户
    func followUser_Wanderbell(user_wanderbell: PrewUserModel_Wanderbell) {
        if !isLoggedIn_Wanderbell {
            showLoginPrompt_Wanderbell()
            return
        }
        
        guard let currentUser_wanderbell = loggedUser_Wanderbell else {
            return
        }
        
        let wasFollowing_wanderbell = isFollowing_Wanderbell(user_wanderbell: user_wanderbell)
        
        if wasFollowing_wanderbell {
            // 取消关注
            loggedUser_Wanderbell?.userFollow_Wanderbell.removeAll { $0.userId_Wanderbell == user_wanderbell.userId_Wanderbell }
        } else {
            // 关注
            loggedUser_Wanderbell?.userFollow_Wanderbell.append(user_wanderbell)
        }
        
        // 发送状态变化通知
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Wanderbell(user_wanderbell: PrewUserModel_Wanderbell) {
        guard let userId_wanderbell = user_wanderbell.userId_Wanderbell else { return }
        
        // 取消关注
        loggedUser_Wanderbell?.userFollow_Wanderbell.removeAll { $0.userId_Wanderbell == userId_wanderbell }
        
        // 删除与该用户的聊天记录
        MessageViewModel_Wanderbell.shared_Wanderbell.deleteUserMessages_Wanderbell(
            userId_wanderbell: userId_wanderbell
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Wanderbell.shared_Wanderbell.deleteUserPosts_Wanderbell(
            userId_wanderbell: userId_wanderbell
        )
        
        // 从本地用户列表中移除
        LocalData_Wanderbell.shared_Wanderbell.userList_Wanderbell.removeAll { $0.userId_Wanderbell == userId_wanderbell }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Wanderbell.dismissLoading_Wanderbell()
            Utils_Wanderbell.showSuccess_Wanderbell(
                message_wanderbell: "This user will no longer appear.",
                delay_wanderbell: 2.0
            )
        }
        
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Wanderbell(userId_wanderbell: Int) -> Bool {
        return loggedUser_Wanderbell?.userId_Wanderbell == userId_wanderbell
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Wanderbell(userId_wanderbell: Int) -> PrewUserModel_Wanderbell {
        let users_wanderbell = LocalData_Wanderbell.shared_Wanderbell.userList_Wanderbell
        
        if let user_wanderbell = users_wanderbell.first(where: { $0.userId_Wanderbell == userId_wanderbell }) {
            return user_wanderbell
        }
        
        // 返回默认用户
        let defaultPrewUser_wanderbell = PrewUserModel_Wanderbell()
        defaultPrewUser_wanderbell.userId_Wanderbell = userId_wanderbell
        defaultPrewUser_wanderbell.userName_Wanderbell = "Guest"
        defaultPrewUser_wanderbell.userHead_Wanderbell = "default_avatar"
        return defaultPrewUser_wanderbell
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Wanderbell() -> [PrewUserModel_Wanderbell] {
        let users_wanderbell = LocalData_Wanderbell.shared_Wanderbell.userList_Wanderbell
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_wanderbell
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Wanderbell(post_wanderbell: TitleModel_Wanderbell) {
        guard let user_wanderbell = loggedUser_Wanderbell else { return }
        user_wanderbell.userPosts_Wanderbell.append(post_wanderbell)
        loggedUser_Wanderbell = user_wanderbell
        notifyStateChange_Wanderbell()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Wanderbell(post_wanderbell: TitleModel_Wanderbell) {
        guard let user_wanderbell = loggedUser_Wanderbell else { return }
        user_wanderbell.userPosts_Wanderbell.removeAll { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }
        loggedUser_Wanderbell = user_wanderbell
        notifyStateChange_Wanderbell()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Wanderbell(post_wanderbell: TitleModel_Wanderbell) {
        guard let user_wanderbell = loggedUser_Wanderbell else { return }
        
        // 检查是否已存在
        if !user_wanderbell.userLike_Wanderbell.contains(where: { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }) {
            user_wanderbell.userLike_Wanderbell.append(post_wanderbell)
            loggedUser_Wanderbell = user_wanderbell
            notifyStateChange_Wanderbell()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Wanderbell(post_wanderbell: TitleModel_Wanderbell) {
        guard let user_wanderbell = loggedUser_Wanderbell else { return }
        user_wanderbell.userLike_Wanderbell.removeAll { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }
        loggedUser_Wanderbell = user_wanderbell
        notifyStateChange_Wanderbell()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Wanderbell(post_wanderbell: TitleModel_Wanderbell) -> Bool {
        guard let user_wanderbell = loggedUser_Wanderbell else { return false }
        return user_wanderbell.userLike_Wanderbell.contains { $0.titleId_Wanderbell == post_wanderbell.titleId_Wanderbell }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Wanderbell() {
        NotificationCenter.default.post(
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Wanderbell() {
        // 延迟跳转到登录页面
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
        }
    }
}
