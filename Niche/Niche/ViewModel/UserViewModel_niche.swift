import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Niche {
    /// 删除账号
    case delete_niche
    /// 普通登出
    case logout_niche
}

/// 用户状态管理类
@MainActor
class UserViewModel_Niche {
    
    /// 单例
    static let shared_Niche = UserViewModel_Niche()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Niche = Notification.Name("UserStateDidChange_Niche")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Niche: LoginUserModel_Niche?
    
    /// 默认用户（游客）
    private let defaultUser_Niche = LoginUserModel_Niche(
        userId_Niche: 0,
        userPwd_Niche: nil,
        userName_Niche: "Guest",
        userIntroduce_Niche: nil,
        userHead_Niche: "default_avatar",
        userPosts_Niche: [],
        userLike_Niche: [],
        userFollow_Niche: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Niche: Bool {
        return loggedUser_Niche?.userId_Niche != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Niche() -> LoginUserModel_Niche {
        return loggedUser_Niche ?? defaultUser_Niche
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Niche() {
        loggedUser_Niche = defaultUser_Niche
        notifyStateChange_Niche()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Niche(userId_niche: Int) {
        // 显示加载动画
        Utils_Niche.showLoading_Niche(message_Niche: "Logging in...")
        
        // 创建登录用户（同步 LocalData 中的名称、简介、头像）
        loggedUser_Niche = LoginUserModel_Niche(
            userId_Niche: userId_niche,
            userPwd_Niche: nil,
            userName_Niche: "Nicher",
            userIntroduce_Niche: "Nothing yet.",
            userHead_Niche: "user_avatar",
            userPosts_Niche: [],
            userLike_Niche: [],
            userFollow_Niche: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Niche.dismissLoading_Niche()
            
            // 显示成功提示
            Utils_Niche.showSuccess_Niche(message_Niche: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Niche.switchToTabbar_Niche(animated: true)
            
            notifyStateChange_Niche()
        }
    }
    
    /// 用户登出
    func logout_Niche(logoutType_niche: LogOutType_Niche) {
        if !isLoggedIn_Niche {
            showLoginPrompt_Niche()
            return
        }
        
        // 重置为游客状态
        loggedUser_Niche = defaultUser_Niche
        
        // 清空AI聊天记录
        MessageViewModel_Niche.shared_Niche.clearAiChat_Niche()
        
        // 重新初始化本地数据
        LocalData_Niche.shared_Niche.initData_Niche()
        
        notifyStateChange_Niche()
        
        // 跳转到首页
         Navigation_Niche.switchToTabbar_Niche()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_niche == .delete_niche {
                Utils_Niche.showInfo_Niche(
                    message_Niche: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Niche: 3.0
                )
            } else {
                Utils_Niche.showSuccess_Niche(message_Niche: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Niche(headUrl_niche: String) {
        guard let user_niche = loggedUser_Niche else { return }
        user_niche.userHead_Niche = headUrl_niche
        loggedUser_Niche = user_niche
        Utils_Niche.showSuccess_Niche(message_Niche: "Avatar updated successfully")
        notifyStateChange_Niche()
    }
    
    /// 更新用户昵称
    func updateName_Niche(userName_niche: String) {
        guard let user_niche = loggedUser_Niche else { return }
        user_niche.userName_Niche = userName_niche
        loggedUser_Niche = user_niche
        Utils_Niche.showSuccess_Niche(message_Niche: "Name updated successfully")
        notifyStateChange_Niche()
    }
    
    /// 上传用户封面
    func uploadCover_Niche(coverUrl_niche: String) {
        Utils_Niche.showSuccess_Niche(message_Niche: "Cover updated successfully")
        notifyStateChange_Niche()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Niche() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Niche() {
        if hasCheckedInToday_Niche() {
            Utils_Niche.showWarning_Niche(
                message_Niche: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Niche.showSuccess_Niche(
            message_Niche: "Check-in successful!",
            image_Niche: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Niche()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Niche(user_niche: PrewUserModel_Niche) -> Bool {
        guard let loggedUser_niche = loggedUser_Niche else { return false }
        return loggedUser_niche.userFollow_Niche.contains(where: { $0.userId_Niche == user_niche.userId_Niche })
    }
    
    /// 更新用户简介（同步到 loggedUser 和 LocalData 的预览用户列表）
    func updateIntroduce_Niche(introduce_niche: String) {
        guard let user_niche = loggedUser_Niche,
              let userId_niche = user_niche.userId_Niche else { return }
        // 同步到登录用户模型
        user_niche.userIntroduce_Niche = introduce_niche
        loggedUser_Niche = user_niche
        // 同步到 LocalData 预览列表
        if let idx_niche = LocalData_Niche.shared_Niche.userList_Niche.firstIndex(where: { $0.userId_Niche == userId_niche }) {
            LocalData_Niche.shared_Niche.userList_Niche[idx_niche].userIntroduce_Niche = introduce_niche
        }
        notifyStateChange_Niche()
    }
    
    /// 关注/取消关注用户
    func followUser_Niche(user_niche: PrewUserModel_Niche) {
        if !isLoggedIn_Niche {
            showLoginPrompt_Niche()
            return
        }
        
        if isFollowing_Niche(user_niche: user_niche) {
            // 取消关注
            loggedUser_Niche?.userFollow_Niche.removeAll { $0.userId_Niche == user_niche.userId_Niche }
        } else {
            // 关注
            loggedUser_Niche?.userFollow_Niche.append(user_niche)
        }
        
        notifyStateChange_Niche()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Niche(user_niche: PrewUserModel_Niche) {
        guard let userId_niche = user_niche.userId_Niche else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Niche.shared_Niche.deleteUserMessages_Niche(
            userId_niche: userId_niche
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Niche.shared_Niche.deleteUserPosts_Niche(
            userId_niche: userId_niche
        )
        
        // 从本地用户列表中移除
        LocalData_Niche.shared_Niche.userList_Niche.removeAll { $0.userId_Niche == userId_niche }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Niche.showSuccess_Niche(
                message_Niche: "This user will no longer appear.",
                delay_Niche: 2.0
            )
        }
        
        notifyStateChange_Niche()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Niche(userId_niche: Int) -> Bool {
        return loggedUser_Niche?.userId_Niche == userId_niche
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Niche(userId_niche: Int) -> PrewUserModel_Niche {
        let users_niche = LocalData_Niche.shared_Niche.userList_Niche
        
        if let user_niche = users_niche.first(where: { $0.userId_Niche == userId_niche }) {
            return user_niche
        }
        
        // 返回默认用户
        let defaultPrewUser_niche = PrewUserModel_Niche()
        defaultPrewUser_niche.userId_Niche = userId_niche
        defaultPrewUser_niche.userName_Niche = "Guest"
        defaultPrewUser_niche.userHead_Niche = "default_avatar"
        return defaultPrewUser_niche
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Niche() -> [PrewUserModel_Niche] {
        let users_niche = LocalData_Niche.shared_Niche.userList_Niche
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_niche
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Niche(post_niche: TitleModel_Niche) {
        guard let user_niche = loggedUser_Niche else { return }
        user_niche.userPosts_Niche.append(post_niche)
        loggedUser_Niche = user_niche
        notifyStateChange_Niche()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Niche(post_niche: TitleModel_Niche) {
        guard let user_niche = loggedUser_Niche else { return }
        user_niche.userPosts_Niche.removeAll { $0.titleId_Niche == post_niche.titleId_Niche }
        loggedUser_Niche = user_niche
        notifyStateChange_Niche()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Niche(post_niche: TitleModel_Niche) {
        guard let user_niche = loggedUser_Niche else { return }
        
        // 检查是否已存在
        if !user_niche.userLike_Niche.contains(where: { $0.titleId_Niche == post_niche.titleId_Niche }) {
            user_niche.userLike_Niche.append(post_niche)
            loggedUser_Niche = user_niche
            notifyStateChange_Niche()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Niche(post_niche: TitleModel_Niche) {
        guard let user_niche = loggedUser_Niche else { return }
        user_niche.userLike_Niche.removeAll { $0.titleId_Niche == post_niche.titleId_Niche }
        loggedUser_Niche = user_niche
        notifyStateChange_Niche()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Niche(post_niche: TitleModel_Niche) -> Bool {
        guard let user_niche = loggedUser_Niche else { return false }
        return user_niche.userLike_Niche.contains { $0.titleId_Niche == post_niche.titleId_Niche }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Niche() {
        NotificationCenter.default.post(
            name: UserViewModel_Niche.userStateDidChangeNotification_Niche,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Niche() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Niche.toLogin_Niche(style_niche: .present_niche)
        }
    }
}
