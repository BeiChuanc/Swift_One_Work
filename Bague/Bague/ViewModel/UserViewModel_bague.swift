import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Bague {
    /// 删除账号
    case delete_bague
    /// 普通登出
    case logout_bague
}

/// 用户状态管理类
@MainActor
class UserViewModel_Bague {
    
    /// 单例
    static let shared_Bague = UserViewModel_Bague()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Bague = Notification.Name("UserStateDidChange_Bague")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Bague: LoginUserModel_Bague?
    
    /// 默认用户（游客）
    private let defaultUser_Bague = LoginUserModel_Bague(
        userId_Bague: 0,
        userPwd_Bague: nil,
        userName_Bague: "Guest",
        userHead_Bague: "default_avatar",
        userPosts_Bague: [],
        userLike_Bague: [],
        userFollow_Bague: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Bague: Bool {
        return loggedUser_Bague?.userId_Bague != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Bague() -> LoginUserModel_Bague {
        return loggedUser_Bague ?? defaultUser_Bague
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Bague() {
        loggedUser_Bague = defaultUser_Bague
        notifyStateChange_Bague()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Bague(userId_bague: Int) {
        // 显示加载动画
        Utils_Bague.showLoading_Bague(message_Bague: "Logging in...")
        
        // 创建登录用户
        loggedUser_Bague = LoginUserModel_Bague(
            userId_Bague: userId_bague,
            userPwd_Bague: nil,
            userName_Bague: "Wanderer", // 可以从本地数据或服务器获取
            userHead_Bague: "user_avatar",
            userPosts_Bague: [],
            userLike_Bague: [],
            userFollow_Bague: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Bague.dismissLoading_Bague()
            
            // 显示成功提示
            Utils_Bague.showSuccess_Bague(message_Bague: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Bague.switchToTabbar_Bague(animated: true)
            
            notifyStateChange_Bague()
        }
    }
    
    /// 用户登出
    func logout_Bague(logoutType_bague: LogOutType_Bague) {
        if !isLoggedIn_Bague {
            showLoginPrompt_Bague()
            return
        }
        
        // 重置为游客状态
        loggedUser_Bague = defaultUser_Bague
        
        // 清空AI聊天记录
        MessageViewModel_Bague.shared_Bague.clearAiChat_Bague()
        
        // 重新初始化本地数据
        LocalData_Bague.shared_Bague.initData_Bague()
        
        notifyStateChange_Bague()
        
        // 跳转到首页
         Navigation_Bague.switchToTabbar_Bague()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_bague == .delete_bague {
                Utils_Bague.showInfo_Bague(
                    message_Bague: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Bague: 3.0
                )
            } else {
                Utils_Bague.showSuccess_Bague(message_Bague: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Bague(headUrl_bague: String) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userHead_Bague = headUrl_bague
        loggedUser_Bague = user_bague
        Utils_Bague.showSuccess_Bague(message_Bague: "Avatar updated successfully")
        notifyStateChange_Bague()
    }
    
    /// 更新用户昵称
    func updateName_Bague(userName_bague: String) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userName_Bague = userName_bague
        loggedUser_Bague = user_bague
        Utils_Bague.showSuccess_Bague(message_Bague: "Name updated successfully")
        notifyStateChange_Bague()
    }
    
    /// 更新用户简介
    func updateIntroduce_Bague(introduce_bague: String) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userIntroduce_Bague = introduce_bague
        loggedUser_Bague = user_bague
        notifyStateChange_Bague()
    }
    
    /// 上传用户封面
    func uploadCover_Bague(coverUrl_bague: String) {
        Utils_Bague.showSuccess_Bague(message_Bague: "Cover updated successfully")
        notifyStateChange_Bague()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Bague() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Bague() {
        if hasCheckedInToday_Bague() {
            Utils_Bague.showWarning_Bague(
                message_Bague: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Bague.showSuccess_Bague(
            message_Bague: "Check-in successful!",
            image_Bague: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Bague()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Bague(user_bague: PrewUserModel_Bague) -> Bool {
        guard let currentUser_bague = loggedUser_Bague,
              let targetId_bague = user_bague.userId_Bague else { return false }
        return currentUser_bague.userFollow_Bague.contains(where: { $0.userId_Bague == targetId_bague })
    }
    
    /// 关注/取消关注用户
    func followUser_Bague(user_bague: PrewUserModel_Bague) {
        if !isLoggedIn_Bague {
            showLoginPrompt_Bague()
            return
        }
        
        if isFollowing_Bague(user_bague: user_bague) {
            // 取消关注
            loggedUser_Bague?.userFollow_Bague.removeAll { $0.userId_Bague == user_bague.userId_Bague }
        } else {
            // 关注
            loggedUser_Bague?.userFollow_Bague.append(user_bague)
        }
        
        notifyStateChange_Bague()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Bague(user_bague: PrewUserModel_Bague) {
        guard let userId_bague = user_bague.userId_Bague else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Bague.shared_Bague.deleteUserMessages_Bague(
            userId_bague: userId_bague
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Bague.shared_Bague.deleteUserPosts_Bague(
            userId_bague: userId_bague
        )
        
        // 从本地用户列表中移除
        LocalData_Bague.shared_Bague.userList_Bague.removeAll { $0.userId_Bague == userId_bague }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Bague.showSuccess_Bague(
                message_Bague: "This user will no longer appear.",
                delay_Bague: 2.0
            )
        }
        
        notifyStateChange_Bague()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Bague(userId_bague: Int) -> Bool {
        return loggedUser_Bague?.userId_Bague == userId_bague
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Bague(userId_bague: Int) -> PrewUserModel_Bague {
        let users_bague = LocalData_Bague.shared_Bague.userList_Bague
        
        if let user_bague = users_bague.first(where: { $0.userId_Bague == userId_bague }) {
            return user_bague
        }
        
        // 返回默认用户
        let defaultPrewUser_bague = PrewUserModel_Bague()
        defaultPrewUser_bague.userId_Bague = userId_bague
        defaultPrewUser_bague.userName_Bague = "Guest"
        defaultPrewUser_bague.userHead_Bague = "default_avatar"
        return defaultPrewUser_bague
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Bague() -> [PrewUserModel_Bague] {
        let users_bague = LocalData_Bague.shared_Bague.userList_Bague
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_bague
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Bague(post_bague: TitleModel_Bague) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userPosts_Bague.append(post_bague)
        loggedUser_Bague = user_bague
        notifyStateChange_Bague()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Bague(post_bague: TitleModel_Bague) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userPosts_Bague.removeAll { $0.titleId_Bague == post_bague.titleId_Bague }
        loggedUser_Bague = user_bague
        notifyStateChange_Bague()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Bague(post_bague: TitleModel_Bague) {
        guard let user_bague = loggedUser_Bague else { return }
        
        // 检查是否已存在
        if !user_bague.userLike_Bague.contains(where: { $0.titleId_Bague == post_bague.titleId_Bague }) {
            user_bague.userLike_Bague.append(post_bague)
            loggedUser_Bague = user_bague
            notifyStateChange_Bague()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Bague(post_bague: TitleModel_Bague) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userLike_Bague.removeAll { $0.titleId_Bague == post_bague.titleId_Bague }
        loggedUser_Bague = user_bague
        notifyStateChange_Bague()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Bague(post_bague: TitleModel_Bague) -> Bool {
        guard let user_bague = loggedUser_Bague else { return false }
        return user_bague.userLike_Bague.contains { $0.titleId_Bague == post_bague.titleId_Bague }
    }
    
    // MARK: - 藏包册管理

    /// 获取当前用户的藏包册列表
    func getBags_Bague() -> [BagItem_Bague] {
        return loggedUser_Bague?.userBags_Bague ?? []
    }

    /// 添加藏包册条目
    /// - Parameter item_bague: 要添加的藏包信息
    func addBag_Bague(item_bague: BagItem_Bague) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userBags_Bague.append(item_bague)
        loggedUser_Bague = user_bague
        notifyStateChange_Bague()
    }

    /// 删除藏包册条目
    /// - Parameter itemId_bague: 要删除的条目 ID
    func deleteBag_Bague(itemId_bague: Int) {
        guard let user_bague = loggedUser_Bague else { return }
        user_bague.userBags_Bague.removeAll { $0.itemId_Bague == itemId_bague }
        loggedUser_Bague = user_bague
        notifyStateChange_Bague()
    }

    /// 生成新的藏包 ID（取当前最大 ID + 1）
    func nextBagId_Bague() -> Int {
        let maxId_bague = loggedUser_Bague?.userBags_Bague.max(by: { $0.itemId_Bague < $1.itemId_Bague })?.itemId_Bague ?? 0
        return maxId_bague + 1
    }

    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Bague() {
        NotificationCenter.default.post(
            name: UserViewModel_Bague.userStateDidChangeNotification_Bague,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Bague() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Bague.toLogin_Bague(style_bague: .present_bague)
        }
    }
}
