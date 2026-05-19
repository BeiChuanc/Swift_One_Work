import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Lumia {
    /// 删除账号
    case delete_lumia
    /// 普通登出
    case logout_lumia
}

/// 用户状态管理类
@MainActor
class UserViewModel_Lumia {
    
    /// 单例
    static let shared_Lumia = UserViewModel_Lumia()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Lumia = Notification.Name("UserStateDidChange_Lumia")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Lumia: LoginUserModel_Lumia?
    
    /// 默认用户（游客）
    private let defaultUser_Lumia = LoginUserModel_Lumia(
        userId_Lumia: 0,
        userPwd_Lumia: nil,
        userName_Lumia: "Guest",
        userHead_Lumia: "default_avatar",
        userPosts_Lumia: [],
        userLike_Lumia: [],
        userFollow_Lumia: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Lumia: Bool {
        return loggedUser_Lumia?.userId_Lumia != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Lumia() -> LoginUserModel_Lumia {
        return loggedUser_Lumia ?? defaultUser_Lumia
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Lumia() {
        loggedUser_Lumia = defaultUser_Lumia
        notifyStateChange_Lumia()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Lumia(userId_lumia: Int) {
        // 显示加载动画
        Utils_Lumia.showLoading_Lumia(message_Lumia: "Logging in...")
        
        // 创建登录用户
        loggedUser_Lumia = LoginUserModel_Lumia(
            userId_Lumia: userId_lumia,
            userPwd_Lumia: nil,
            userName_Lumia: "Lumiaer", // 可以从本地数据或服务器获取
            userHead_Lumia: "user_avatar",
            userPosts_Lumia: [],
            userLike_Lumia: [],
            userFollow_Lumia: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Lumia.dismissLoading_Lumia()
            
            // 显示成功提示
            Utils_Lumia.showSuccess_Lumia(message_Lumia: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Lumia.switchToTabbar_Lumia(animated: true)
            
            notifyStateChange_Lumia()
        }
    }
    
    /// 用户登出
    func logout_Lumia(logoutType_lumia: LogOutType_Lumia) {
        if !isLoggedIn_Lumia {
            showLoginPrompt_Lumia()
            return
        }
        
        // 重置为游客状态
        loggedUser_Lumia = defaultUser_Lumia
        
        // 清空AI聊天记录
        MessageViewModel_Lumia.shared_Lumia.clearAiChat_Lumia()
        
        // 重新初始化本地数据
        LocalData_Lumia.shared_Lumia.initData_Lumia()
        
        notifyStateChange_Lumia()
        
        // 跳转到首页
         Navigation_Lumia.switchToTabbar_Lumia()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_lumia == .delete_lumia {
                Utils_Lumia.showInfo_Lumia(
                    message_Lumia: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Lumia: 3.0
                )
            } else {
                Utils_Lumia.showSuccess_Lumia(message_Lumia: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Lumia(headUrl_lumia: String) {
        guard let user_lumia = loggedUser_Lumia else { return }
        user_lumia.userHead_Lumia = headUrl_lumia
        loggedUser_Lumia = user_lumia
        Utils_Lumia.showSuccess_Lumia(message_Lumia: "Avatar updated successfully")
        notifyStateChange_Lumia()
    }
    
    /// 更新用户昵称
    func updateName_Lumia(userName_lumia: String) {
        guard let user_lumia = loggedUser_Lumia else { return }
        user_lumia.userName_Lumia = userName_lumia
        loggedUser_Lumia = user_lumia
        Utils_Lumia.showSuccess_Lumia(message_Lumia: "Name updated successfully")
        notifyStateChange_Lumia()
    }

    /// 更新用户个人简介
    /// - Parameter introduce_lumia: 新的简介文字（空字符串表示清空）
    func updateIntroduce_Lumia(introduce_lumia: String) {
        guard let user_lumia = loggedUser_Lumia else { return }
        user_lumia.userIntroduce_Lumia = introduce_lumia.isEmpty ? nil : introduce_lumia
        loggedUser_Lumia = user_lumia
        notifyStateChange_Lumia()
    }
    
    /// 上传用户封面
    func uploadCover_Lumia(coverUrl_lumia: String) {
        Utils_Lumia.showSuccess_Lumia(message_Lumia: "Cover updated successfully")
        notifyStateChange_Lumia()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Lumia() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Lumia() {
        if hasCheckedInToday_Lumia() {
            Utils_Lumia.showWarning_Lumia(
                message_Lumia: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Lumia.showSuccess_Lumia(
            message_Lumia: "Check-in successful!",
            image_Lumia: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Lumia()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_lumia: 目标用户模型
    /// - Returns: 已关注返回 true，未登录或未关注返回 false
    func isFollowing_Lumia(user_lumia: PrewUserModel_Lumia) -> Bool {
        guard let currentUser_lumia = loggedUser_Lumia else { return false }
        return currentUser_lumia.userFollow_Lumia.contains(where: { $0.userId_Lumia == user_lumia.userId_Lumia })
    }
    
    /// 关注/取消关注用户，同时同步更新目标用户在本地列表中的粉丝数
    /// - Parameter user_lumia: 目标用户模型
    func followUser_Lumia(user_lumia: PrewUserModel_Lumia) {
        if !isLoggedIn_Lumia {
            showLoginPrompt_Lumia()
            return
        }

        let alreadyFollowing_lumia = isFollowing_Lumia(user_lumia: user_lumia)
        if alreadyFollowing_lumia {
            // 取消关注：从列表移除 + 目标用户粉丝数 -1
            loggedUser_Lumia?.userFollow_Lumia.removeAll { $0.userId_Lumia == user_lumia.userId_Lumia }
            updateTargetUserFans_Lumia(userId_lumia: user_lumia.userId_Lumia, delta_lumia: -1)
        } else {
            // 关注：追加到列表 + 目标用户粉丝数 +1
            loggedUser_Lumia?.userFollow_Lumia.append(user_lumia)
            updateTargetUserFans_Lumia(userId_lumia: user_lumia.userId_Lumia, delta_lumia: 1)
        }

        notifyStateChange_Lumia()
    }

    /// 在本地用户列表中修改目标用户的粉丝数
    /// - Parameters:
    ///   - userId_lumia: 目标用户 ID
    ///   - delta_lumia: 变化量（+1 关注，-1 取关）
    private func updateTargetUserFans_Lumia(userId_lumia: Int?, delta_lumia: Int) {
        guard let uid_lumia = userId_lumia,
              let idx_lumia = LocalData_Lumia.shared_Lumia.userList_Lumia.firstIndex(
                  where: { $0.userId_Lumia == uid_lumia }
              ) else { return }
        let current_lumia = LocalData_Lumia.shared_Lumia.userList_Lumia[idx_lumia].userFans_Lumia ?? 0
        LocalData_Lumia.shared_Lumia.userList_Lumia[idx_lumia].userFans_Lumia = max(0, current_lumia + delta_lumia)
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Lumia(user_lumia: PrewUserModel_Lumia) {
        guard let userId_lumia = user_lumia.userId_Lumia else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Lumia.shared_Lumia.deleteUserMessages_Lumia(
            userId_lumia: userId_lumia
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Lumia.shared_Lumia.deleteUserPosts_Lumia(
            userId_lumia: userId_lumia
        )
        
        // 从本地用户列表中移除
        LocalData_Lumia.shared_Lumia.userList_Lumia.removeAll { $0.userId_Lumia == userId_lumia }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Lumia.showSuccess_Lumia(
                message_Lumia: "This user will no longer appear.",
                delay_Lumia: 2.0
            )
        }
        
        notifyStateChange_Lumia()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Lumia(userId_lumia: Int) -> Bool {
        return loggedUser_Lumia?.userId_Lumia == userId_lumia
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Lumia(userId_lumia: Int) -> PrewUserModel_Lumia {
        let users_lumia = LocalData_Lumia.shared_Lumia.userList_Lumia
        
        if let user_lumia = users_lumia.first(where: { $0.userId_Lumia == userId_lumia }) {
            return user_lumia
        }
        
        // 返回默认用户
        let defaultPrewUser_lumia = PrewUserModel_Lumia()
        defaultPrewUser_lumia.userId_Lumia = userId_lumia
        defaultPrewUser_lumia.userName_Lumia = "Guest"
        defaultPrewUser_lumia.userHead_Lumia = "default_avatar"
        return defaultPrewUser_lumia
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Lumia() -> [PrewUserModel_Lumia] {
        let users_lumia = LocalData_Lumia.shared_Lumia.userList_Lumia
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_lumia
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Lumia(post_lumia: TitleModel_Lumia) {
        guard let user_lumia = loggedUser_Lumia else { return }
        user_lumia.userPosts_Lumia.append(post_lumia)
        loggedUser_Lumia = user_lumia
        notifyStateChange_Lumia()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Lumia(post_lumia: TitleModel_Lumia) {
        guard let user_lumia = loggedUser_Lumia else { return }
        user_lumia.userPosts_Lumia.removeAll { $0.titleId_Lumia == post_lumia.titleId_Lumia }
        loggedUser_Lumia = user_lumia
        notifyStateChange_Lumia()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Lumia(post_lumia: TitleModel_Lumia) {
        guard let user_lumia = loggedUser_Lumia else { return }
        
        // 检查是否已存在
        if !user_lumia.userLike_Lumia.contains(where: { $0.titleId_Lumia == post_lumia.titleId_Lumia }) {
            user_lumia.userLike_Lumia.append(post_lumia)
            loggedUser_Lumia = user_lumia
            notifyStateChange_Lumia()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Lumia(post_lumia: TitleModel_Lumia) {
        guard let user_lumia = loggedUser_Lumia else { return }
        user_lumia.userLike_Lumia.removeAll { $0.titleId_Lumia == post_lumia.titleId_Lumia }
        loggedUser_Lumia = user_lumia
        notifyStateChange_Lumia()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Lumia(post_lumia: TitleModel_Lumia) -> Bool {
        guard let user_lumia = loggedUser_Lumia else { return false }
        return user_lumia.userLike_Lumia.contains { $0.titleId_Lumia == post_lumia.titleId_Lumia }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Lumia() {
        NotificationCenter.default.post(
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Lumia() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia)
        }
    }
}
