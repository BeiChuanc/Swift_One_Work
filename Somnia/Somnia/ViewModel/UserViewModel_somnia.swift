import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Somnia {
    /// 删除账号
    case delete_somnia
    /// 普通登出
    case logout_somnia
}

/// 用户状态管理类
@MainActor
class UserViewModel_Somnia {
    
    /// 单例
    static let shared_Somnia = UserViewModel_Somnia()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Somnia = Notification.Name("UserStateDidChange_Somnia")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Somnia: LoginUserModel_Somnia?
    
    /// 默认用户（游客）
    private let defaultUser_Somnia = LoginUserModel_Somnia(
        userId_Somnia: 0,
        userPwd_Somnia: nil,
        userName_Somnia: "Guest",
        userHead_Somnia: "default_avatar"
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Somnia: Bool {
        return loggedUser_Somnia?.userId_Somnia != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Somnia() -> LoginUserModel_Somnia {
        return loggedUser_Somnia ?? defaultUser_Somnia
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Somnia() {
        loggedUser_Somnia = defaultUser_Somnia
        notifyStateChange_Somnia()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Somnia(userId_somnia: Int) {
        // 显示加载动画
        Utils_Somnia.showLoading_Somnia(message_Somnia: "Logging in...")
        
        // 创建登录用户（梦境数据字段默认空，由 DreamViewModel 负责按用户加载）
        loggedUser_Somnia = LoginUserModel_Somnia(
            userId_Somnia: userId_somnia,
            userPwd_Somnia: nil,
            userName_Somnia: "Wanderer"
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Somnia.dismissLoading_Somnia()
            
            // 显示成功提示
            Utils_Somnia.showSuccess_Somnia(message_Somnia: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Somnia.switchToTabbar_Somnia(animated: true)
            
            notifyStateChange_Somnia()
        }
    }
    
    /// 用户登出
    func logout_Somnia(logoutType_somnia: LogOutType_Somnia) {
        if !isLoggedIn_Somnia {
            showLoginPrompt_Somnia()
            return
        }
        
        // 重置为游客状态
        loggedUser_Somnia = defaultUser_Somnia
        
        // 清空AI聊天记录
        MessageViewModel_Somnia.shared_Somnia.clearAiChat_Somnia()
        
        // 重新初始化本地数据
        LocalData_Somnia.shared_Somnia.initData_Somnia()
        
        notifyStateChange_Somnia()
        
        // 跳转到首页
         Navigation_Somnia.switchToTabbar_Somnia()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_somnia == .delete_somnia {
                Utils_Somnia.showInfo_Somnia(
                    message_Somnia: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Somnia: 3.0
                )
            } else {
                Utils_Somnia.showSuccess_Somnia(message_Somnia: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Somnia(headUrl_somnia: String) {
        guard let user_somnia = loggedUser_Somnia else { return }
        user_somnia.userHead_Somnia = headUrl_somnia
        loggedUser_Somnia = user_somnia
        Utils_Somnia.showSuccess_Somnia(message_Somnia: "Avatar updated successfully")
        notifyStateChange_Somnia()
    }
    
    /// 更新用户昵称
    func updateName_Somnia(userName_somnia: String) {
        guard let user_somnia = loggedUser_Somnia else { return }
        user_somnia.userName_Somnia = userName_somnia
        loggedUser_Somnia = user_somnia
        Utils_Somnia.showSuccess_Somnia(message_Somnia: "Name updated successfully")
        notifyStateChange_Somnia()
    }
    
    /// 更新用户简介
    /// 功能：修改当前登录用户的个人简介
    /// 参数：introduce_somnia - 新的简介文本
    func updateIntroduce_Somnia(introduce_somnia: String) {
        guard let user_somnia = loggedUser_Somnia else { return }
        user_somnia.userIntroduce_Somnia = introduce_somnia
        loggedUser_Somnia = user_somnia
        notifyStateChange_Somnia()
    }
    
    /// 上传用户封面
    func uploadCover_Somnia(coverUrl_somnia: String) {
        Utils_Somnia.showSuccess_Somnia(message_Somnia: "Cover updated successfully")
        notifyStateChange_Somnia()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Somnia() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Somnia() {
        if hasCheckedInToday_Somnia() {
            Utils_Somnia.showWarning_Somnia(
                message_Somnia: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Somnia.showSuccess_Somnia(
            message_Somnia: "Check-in successful!",
            image_Somnia: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Somnia()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_Somnia(user_somnia: PrewUserModel_Somnia) -> Bool {
        guard let user_somnia = loggedUser_Somnia else { return false }
        return user_somnia.userFollow_Somnia.contains(where: { $0.userId_Somnia == user_somnia.userId_Somnia })
    }
    
    /// 关注/取消关注用户
    func followUser_Somnia(user_somnia: PrewUserModel_Somnia) {
        if !isLoggedIn_Somnia {
            showLoginPrompt_Somnia()
            return
        }
        
        if isFollowing_Somnia(user_somnia: user_somnia) {
            // 取消关注
            loggedUser_Somnia?.userFollow_Somnia.removeAll { $0.userId_Somnia == user_somnia.userId_Somnia }
        } else {
            // 关注
            loggedUser_Somnia?.userFollow_Somnia.append(user_somnia)
        }
        
        notifyStateChange_Somnia()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Somnia(user_somnia: PrewUserModel_Somnia) {
        guard let userId_somnia = user_somnia.userId_Somnia else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Somnia.shared_Somnia.deleteUserMessages_Somnia(
            userId_somnia: userId_somnia
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Somnia.shared_Somnia.deleteUserPosts_Somnia(
            userId_somnia: userId_somnia
        )
        
        // 从本地用户列表中移除
        LocalData_Somnia.shared_Somnia.userList_Somnia.removeAll { $0.userId_Somnia == userId_somnia }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Somnia.showSuccess_Somnia(
                message_Somnia: "This user will no longer appear.",
                delay_Somnia: 2.0
            )
        }
        
        notifyStateChange_Somnia()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Somnia(userId_somnia: Int) -> Bool {
        return loggedUser_Somnia?.userId_Somnia == userId_somnia
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Somnia(userId_somnia: Int) -> PrewUserModel_Somnia {
        let users_somnia = LocalData_Somnia.shared_Somnia.userList_Somnia
        
        if let user_somnia = users_somnia.first(where: { $0.userId_Somnia == userId_somnia }) {
            return user_somnia
        }
        
        // 返回默认用户
        let defaultPrewUser_somnia = PrewUserModel_Somnia()
        defaultPrewUser_somnia.userId_Somnia = userId_somnia
        defaultPrewUser_somnia.userName_Somnia = "Guest"
        defaultPrewUser_somnia.userHead_Somnia = "default_avatar"
        return defaultPrewUser_somnia
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Somnia() -> [PrewUserModel_Somnia] {
        let users_somnia = LocalData_Somnia.shared_Somnia.userList_Somnia
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_somnia
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Somnia(post_somnia: TitleModel_Somnia) {
        guard let user_somnia = loggedUser_Somnia else { return }
        user_somnia.userPosts_Somnia.append(post_somnia)
        loggedUser_Somnia = user_somnia
        notifyStateChange_Somnia()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Somnia(post_somnia: TitleModel_Somnia) {
        guard let user_somnia = loggedUser_Somnia else { return }
        user_somnia.userPosts_Somnia.removeAll { $0.titleId_Somnia == post_somnia.titleId_Somnia }
        loggedUser_Somnia = user_somnia
        notifyStateChange_Somnia()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Somnia(post_somnia: TitleModel_Somnia) {
        guard let user_somnia = loggedUser_Somnia else { return }
        
        // 检查是否已存在
        if !user_somnia.userLike_Somnia.contains(where: { $0.titleId_Somnia == post_somnia.titleId_Somnia }) {
            user_somnia.userLike_Somnia.append(post_somnia)
            loggedUser_Somnia = user_somnia
            notifyStateChange_Somnia()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Somnia(post_somnia: TitleModel_Somnia) {
        guard let user_somnia = loggedUser_Somnia else { return }
        user_somnia.userLike_Somnia.removeAll { $0.titleId_Somnia == post_somnia.titleId_Somnia }
        loggedUser_Somnia = user_somnia
        notifyStateChange_Somnia()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Somnia(post_somnia: TitleModel_Somnia) -> Bool {
        guard let user_somnia = loggedUser_Somnia else { return false }
        return user_somnia.userLike_Somnia.contains { $0.titleId_Somnia == post_somnia.titleId_Somnia }
    }
    
    // MARK: - 梦境数据管理

    /// 将更新后的梦境册、梦境记录、梦物图腾、每日打卡列表写回当前登录用户模型
    /// - Parameters:
    ///   - books_somnia: 最新梦境册列表
    ///   - records_somnia: 最新梦境记录列表
    ///   - totems_somnia: 最新梦物图腾列表
    ///   - checkInDates_somnia: 全局每日打卡时间戳列表
    func updateDreamData_Somnia(
        books_somnia: [DreamBookModel_Somnia],
        records_somnia: [DreamRecordModel_Somnia],
        totems_somnia: [DreamTotemModel_Somnia],
        checkInDates_somnia: [Double] = []
    ) {
        guard let user = loggedUser_Somnia else { return }
        user.userDreamBooks_Somnia      = books_somnia
        user.userDreamRecords_Somnia    = records_somnia
        user.userDreamTotems_Somnia     = totems_somnia
        user.dailyCheckInDates_Somnia   = checkInDates_somnia
        loggedUser_Somnia = user
    }

    /// 读取当前用户的梦境册列表
    /// - Returns: 梦境册数组，未登录时返回空
    func getDreamBooks_Somnia() -> [DreamBookModel_Somnia] {
        return getCurrentUser_Somnia().userDreamBooks_Somnia
    }

    /// 读取当前用户的梦境记录列表
    /// - Returns: 梦境记录数组，未登录时返回空
    func getDreamRecords_Somnia() -> [DreamRecordModel_Somnia] {
        return getCurrentUser_Somnia().userDreamRecords_Somnia
    }

    /// 读取当前用户的梦物图腾列表
    /// - Returns: 梦物图腾数组，未登录时返回空
    func getDreamTotems_Somnia() -> [DreamTotemModel_Somnia] {
        return getCurrentUser_Somnia().userDreamTotems_Somnia
    }

    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Somnia() {
        NotificationCenter.default.post(
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Somnia() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Somnia.toLogin_Somnia(style_somnia: .present_somnia)
        }
    }
}
