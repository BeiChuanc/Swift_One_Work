import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Vestir {
    /// 删除账号
    case delete_vestir
    /// 普通登出
    case logout_vestir
}

/// 用户状态管理类
@MainActor
class UserViewModel_Vestir {
    
    /// 单例
    static let shared_Vestir = UserViewModel_Vestir()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Vestir = Notification.Name("UserStateDidChange_Vestir")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Vestir: LoginUserModel_Vestir?
    
    /// 默认用户（游客）
    private let defaultUser_Vestir = LoginUserModel_Vestir(
        userId_Vestir: 0,
        userPwd_Vestir: nil,
        userName_Vestir: "Guest",
        userHead_Vestir: "default_avatar",
        userPosts_Vestir: [],
        userLike_Vestir: [],
        userFollow_Vestir: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Vestir: Bool {
        return loggedUser_Vestir?.userId_Vestir != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Vestir() -> LoginUserModel_Vestir {
        return loggedUser_Vestir ?? defaultUser_Vestir
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Vestir() {
        loggedUser_Vestir = defaultUser_Vestir
        notifyStateChange_Vestir()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录（从本地数据查找用户信息）
    func loginById_Vestir(userId_vestir: Int) {
        Utils_Vestir.showLoading_Vestir(message_Vestir: "Logging in...")
        
        loggedUser_Vestir = LoginUserModel_Vestir(
            userId_Vestir: userId_vestir,
            userPwd_Vestir: nil,
            userName_Vestir: "Vestirer",
            userHead_Vestir: "person.circle.fill",
            userPosts_Vestir: [],
            userLike_Vestir: [],
            userFollow_Vestir: []
        )
        
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Utils_Vestir.dismissLoading_Vestir()
            Utils_Vestir.showSuccess_Vestir(message_Vestir: "Login successful!")
            Navigation_Vestir.switchToTabbar_Vestir(animated: true)
            notifyStateChange_Vestir()
        }
    }
    
    /// 更新用户简介
    /// - Parameter introduce_vestir: 新简介内容
    func updateIntroduce_Vestir(introduce_vestir: String) {
        guard let user_vestir = loggedUser_Vestir else { return }
        user_vestir.userIntroduce_Vestir = introduce_vestir
        loggedUser_Vestir = user_vestir
        Utils_Vestir.showSuccess_Vestir(message_Vestir: "Bio updated successfully")
        notifyStateChange_Vestir()
    }
    
    /// 用户登出
    func logout_Vestir(logoutType_vestir: LogOutType_Vestir) {
        if !isLoggedIn_Vestir {
            showLoginPrompt_Vestir()
            return
        }
        
        // 重置为游客状态
        loggedUser_Vestir = defaultUser_Vestir
        
        // 清空AI聊天记录
        MessageViewModel_Vestir.shared_Vestir.clearAiChat_Vestir()
        
        // 重新初始化本地数据
        LocalData_Vestir.shared_Vestir.initData_Vestir()
        
        notifyStateChange_Vestir()
        
        // 跳转到首页
         Navigation_Vestir.switchToTabbar_Vestir()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_vestir == .delete_vestir {
                Utils_Vestir.showInfo_Vestir(
                    message_Vestir: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Vestir: 3.0
                )
            } else {
                Utils_Vestir.showSuccess_Vestir(message_Vestir: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Vestir(headUrl_vestir: String) {
        guard let user_vestir = loggedUser_Vestir else { return }
        user_vestir.userHead_Vestir = headUrl_vestir
        loggedUser_Vestir = user_vestir
        Utils_Vestir.showSuccess_Vestir(message_Vestir: "Avatar updated successfully")
        notifyStateChange_Vestir()
    }
    
    /// 更新用户昵称
    func updateName_Vestir(userName_vestir: String) {
        guard let user_vestir = loggedUser_Vestir else { return }
        user_vestir.userName_Vestir = userName_vestir
        loggedUser_Vestir = user_vestir
        Utils_Vestir.showSuccess_Vestir(message_Vestir: "Name updated successfully")
        notifyStateChange_Vestir()
    }
    
    /// 上传用户封面
    func uploadCover_Vestir(coverUrl_vestir: String) {
        Utils_Vestir.showSuccess_Vestir(message_Vestir: "Cover updated successfully")
        notifyStateChange_Vestir()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Vestir() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Vestir() {
        if hasCheckedInToday_Vestir() {
            Utils_Vestir.showWarning_Vestir(
                message_Vestir: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Vestir.showSuccess_Vestir(
            message_Vestir: "Check-in successful!",
            image_Vestir: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Vestir()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Vestir(user_vestir: PrewUserModel_Vestir) -> Bool {
        // 重命名 guard 变量，避免遮蔽参数 user_vestir（目标用户）
        guard let currentUser_vestir = loggedUser_Vestir else { return false }
        return currentUser_vestir.userFollow_Vestir.contains(where: {
            $0.userId_Vestir == user_vestir.userId_Vestir
        })
    }
    
    /// 关注/取消关注用户
    func followUser_Vestir(user_vestir: PrewUserModel_Vestir) {
        if !isLoggedIn_Vestir {
            showLoginPrompt_Vestir()
            return
        }
        
        if isFollowing_Vestir(user_vestir: user_vestir) {
            // 取消关注
            loggedUser_Vestir?.userFollow_Vestir.removeAll { $0.userId_Vestir == user_vestir.userId_Vestir }
        } else {
            // 关注
            loggedUser_Vestir?.userFollow_Vestir.append(user_vestir)
        }
        
        notifyStateChange_Vestir()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Vestir(user_vestir: PrewUserModel_Vestir) {
        guard let userId_vestir = user_vestir.userId_Vestir else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Vestir.shared_Vestir.deleteUserMessages_Vestir(
            userId_vestir: userId_vestir
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Vestir.shared_Vestir.deleteUserPosts_Vestir(
            userId_vestir: userId_vestir
        )
        
        // 从本地用户列表中移除
        LocalData_Vestir.shared_Vestir.userList_Vestir.removeAll { $0.userId_Vestir == userId_vestir }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Vestir.showSuccess_Vestir(
                message_Vestir: "This user will no longer appear.",
                delay_Vestir: 2.0
            )
        }
        
        notifyStateChange_Vestir()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Vestir(userId_vestir: Int) -> Bool {
        return loggedUser_Vestir?.userId_Vestir == userId_vestir
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Vestir(userId_vestir: Int) -> PrewUserModel_Vestir {
        let users_vestir = LocalData_Vestir.shared_Vestir.userList_Vestir
        
        if let user_vestir = users_vestir.first(where: { $0.userId_Vestir == userId_vestir }) {
            return user_vestir
        }
        
        // 返回默认用户
        let defaultPrewUser_vestir = PrewUserModel_Vestir()
        defaultPrewUser_vestir.userId_Vestir = userId_vestir
        defaultPrewUser_vestir.userName_Vestir = "Guest"
        defaultPrewUser_vestir.userHead_Vestir = "default_avatar"
        return defaultPrewUser_vestir
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Vestir() -> [PrewUserModel_Vestir] {
        let users_vestir = LocalData_Vestir.shared_Vestir.userList_Vestir
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_vestir
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Vestir(post_vestir: TitleModel_Vestir) {
        guard let user_vestir = loggedUser_Vestir else { return }
        user_vestir.userPosts_Vestir.append(post_vestir)
        loggedUser_Vestir = user_vestir
        notifyStateChange_Vestir()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Vestir(post_vestir: TitleModel_Vestir) {
        guard let user_vestir = loggedUser_Vestir else { return }
        user_vestir.userPosts_Vestir.removeAll { $0.titleId_Vestir == post_vestir.titleId_Vestir }
        loggedUser_Vestir = user_vestir
        notifyStateChange_Vestir()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Vestir(post_vestir: TitleModel_Vestir) {
        guard let user_vestir = loggedUser_Vestir else { return }
        
        // 检查是否已存在
        if !user_vestir.userLike_Vestir.contains(where: { $0.titleId_Vestir == post_vestir.titleId_Vestir }) {
            user_vestir.userLike_Vestir.append(post_vestir)
            loggedUser_Vestir = user_vestir
            notifyStateChange_Vestir()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Vestir(post_vestir: TitleModel_Vestir) {
        guard let user_vestir = loggedUser_Vestir else { return }
        user_vestir.userLike_Vestir.removeAll { $0.titleId_Vestir == post_vestir.titleId_Vestir }
        loggedUser_Vestir = user_vestir
        notifyStateChange_Vestir()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Vestir(post_vestir: TitleModel_Vestir) -> Bool {
        guard let user_vestir = loggedUser_Vestir else { return false }
        return user_vestir.userLike_Vestir.contains { $0.titleId_Vestir == post_vestir.titleId_Vestir }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Vestir() {
        NotificationCenter.default.post(
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Vestir() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Vestir.toLogin_Vestir(style_vestir: .present_vestir)
        }
    }
}
