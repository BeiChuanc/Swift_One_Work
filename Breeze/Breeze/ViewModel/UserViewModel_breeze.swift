import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Breeze {
    /// 删除账号
    case delete_breeze
    /// 普通登出
    case logout_breeze
}

/// 用户状态管理类
@MainActor
class UserViewModel_Breeze {
    
    /// 单例
    static let shared_Breeze = UserViewModel_Breeze()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Breeze = Notification.Name("UserStateDidChange_Breeze")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Breeze: LoginUserModel_Breeze?
    
    /// 默认用户（游客）
    private let defaultUser_Breeze = LoginUserModel_Breeze(
        userId_Breeze: 0,
        userPwd_Breeze: nil,
        userName_Breeze: "Guest",
        userIntroduce_Breeze: "Wandering through the woods",
        userHead_Breeze: "default_avatar",
        userPosts_Breeze: [],
        userLike_Breeze: [],
        userFollow_Breeze: []
    )
    
    /// 最近一次打卡日期（用于实现每日打卡闭环）
    private var lastCheckInDate_Breeze: Date?
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Breeze: Bool {
        return loggedUser_Breeze?.userId_Breeze != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Breeze() -> LoginUserModel_Breeze {
        return loggedUser_Breeze ?? defaultUser_Breeze
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Breeze() {
        loggedUser_Breeze = defaultUser_Breeze
        notifyStateChange_Breeze()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    /// - Parameters:
    ///   - userId_breeze: 用户ID（唯一登录入口）
    ///   - userName_breeze: 用户名（来自登录/注册输入，默认 Wanderer）
    ///   - intro_breeze: 用户简介（默认露营主题文案）
    func loginById_Breeze(userId_breeze: Int,
                          userName_breeze: String = "Breezer",
                          intro_breeze: String = "Exploring parks one campsite at a time") {
        // 显示加载动画
        Utils_Breeze.showLoading_Breeze(message_Breeze: "Logging in...")
        
        // 创建登录用户
        loggedUser_Breeze = LoginUserModel_Breeze(
            userId_Breeze: userId_breeze,
            userPwd_Breeze: nil,
            userName_Breeze: userName_breeze,
            userIntroduce_Breeze: intro_breeze,
            userHead_Breeze: "user_avatar",
            userPosts_Breeze: [],
            userLike_Breeze: [],
            userFollow_Breeze: []
        )
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Breeze.dismissLoading_Breeze()
            
            // 显示成功提示
            Utils_Breeze.showSuccess_Breeze(message_Breeze: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Breeze.switchToTabbar_Breeze(animated: true)
            
            notifyStateChange_Breeze()
        }
    }
    
    /// 用户登出
    func logout_Breeze(logoutType_breeze: LogOutType_Breeze) {
        if !isLoggedIn_Breeze {
            showLoginPrompt_Breeze()
            return
        }
        
        // 重置为游客状态
        loggedUser_Breeze = defaultUser_Breeze
        
        // 清空打卡记录
        lastCheckInDate_Breeze = nil
        
        // 清空AI聊天记录
        MessageViewModel_Breeze.shared_Breeze.clearAiChat_Breeze()
        
        // 重新初始化本地数据
        LocalData_Breeze.shared_Breeze.initData_Breeze()
        
        notifyStateChange_Breeze()
        
        // 跳转到首页
         Navigation_Breeze.switchToTabbar_Breeze()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_breeze == .delete_breeze {
                Utils_Breeze.showInfo_Breeze(
                    message_Breeze: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Breeze: 3.0
                )
            } else {
                Utils_Breeze.showSuccess_Breeze(message_Breeze: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Breeze(headUrl_breeze: String) {
        guard let user_breeze = loggedUser_Breeze else { return }
        user_breeze.userHead_Breeze = headUrl_breeze
        loggedUser_Breeze = user_breeze
        notifyStateChange_Breeze()
    }
    
    /// 更新用户昵称
    func updateName_Breeze(userName_breeze: String) {
        guard let user_breeze = loggedUser_Breeze else { return }
        user_breeze.userName_Breeze = userName_breeze
        loggedUser_Breeze = user_breeze
        notifyStateChange_Breeze()
    }
    
    /// 更新用户简介
    /// - Parameter intro_breeze: 新的用户简介
    func updateIntro_Breeze(intro_breeze: String) {
        guard let user_breeze = loggedUser_Breeze else { return }
        user_breeze.userIntroduce_Breeze = intro_breeze
        loggedUser_Breeze = user_breeze
        notifyStateChange_Breeze()
    }
    
    /// 上传用户封面
    func uploadCover_Breeze(coverUrl_breeze: String) {
        Utils_Breeze.showSuccess_Breeze(message_Breeze: "Cover updated successfully")
        notifyStateChange_Breeze()
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    /// - Returns: 当且仅当最近一次打卡日期为今天时返回 true
    func hasCheckedInToday_Breeze() -> Bool {
        guard let lastDate_breeze = lastCheckInDate_Breeze else { return false }
        return Calendar.current.isDateInToday(lastDate_breeze)
    }
    
    /// 打卡
    func checkIn_Breeze() {
        // 未登录则提示登录
        if !isLoggedIn_Breeze {
            showLoginPrompt_Breeze()
            return
        }
        
        if hasCheckedInToday_Breeze() {
            Utils_Breeze.showWarning_Breeze(
                message_Breeze: "You have already checked in today."
            )
            return
        }
        
        // 记录本次打卡日期
        lastCheckInDate_Breeze = Date()
        
        Utils_Breeze.showSuccess_Breeze(
            message_Breeze: "Check-in successful!",
            image_Breeze: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Breeze()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_breeze: 待判断的目标用户
    /// - Returns: 当前登录用户的关注列表是否包含该用户
    func isFollowing_Breeze(user_breeze: PrewUserModel_Breeze) -> Bool {
        guard let loggedUser_breeze = loggedUser_Breeze else { return false }
        return loggedUser_breeze.userFollow_Breeze.contains(where: { $0.userId_Breeze == user_breeze.userId_Breeze })
    }
    
    /// 关注/取消关注用户
    func followUser_Breeze(user_breeze: PrewUserModel_Breeze) {
        if !isLoggedIn_Breeze {
            showLoginPrompt_Breeze()
            return
        }
        
        if isFollowing_Breeze(user_breeze: user_breeze) {
            // 取消关注
            loggedUser_Breeze?.userFollow_Breeze.removeAll { $0.userId_Breeze == user_breeze.userId_Breeze }
        } else {
            // 关注
            loggedUser_Breeze?.userFollow_Breeze.append(user_breeze)
        }
        
        notifyStateChange_Breeze()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Breeze(user_breeze: PrewUserModel_Breeze) {
        guard let userId_breeze = user_breeze.userId_Breeze else { return }
        
        // 从当前用户的关注列表中移除该用户
        loggedUser_Breeze?.userFollow_Breeze.removeAll { $0.userId_Breeze == userId_breeze }
        
        // 删除与该用户的聊天记录
        MessageViewModel_Breeze.shared_Breeze.deleteUserMessages_Breeze(
            userId_breeze: userId_breeze
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Breeze.shared_Breeze.deleteUserPosts_Breeze(
            userId_breeze: userId_breeze
        )
        
        // 从本地用户列表中移除
        LocalData_Breeze.shared_Breeze.userList_Breeze.removeAll { $0.userId_Breeze == userId_breeze }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Breeze.showSuccess_Breeze(
                message_Breeze: "This user will no longer appear.",
                delay_Breeze: 2.0
            )
        }
        
        notifyStateChange_Breeze()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Breeze(userId_breeze: Int) -> Bool {
        return loggedUser_Breeze?.userId_Breeze == userId_breeze
    }
    
    /// 判断指定用户是否已被拉黑/举报（已从本地用户列表中移除）
    /// - Parameter userId_breeze: 目标用户 ID
    /// - Returns: 已被拉黑返回 true，否则返回 false
    func isUserBlocked_Breeze(userId_breeze: Int) -> Bool {
        // 当前登录用户自身不视为拉黑
        guard !isCurrentUser_Breeze(userId_breeze: userId_breeze) else { return false }
        // 不在用户列表 = 已被移除（举报/拉黑）
        return !LocalData_Breeze.shared_Breeze.userList_Breeze.contains(where: {
            $0.userId_Breeze == userId_breeze
        })
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Breeze(userId_breeze: Int) -> PrewUserModel_Breeze {
        let users_breeze = LocalData_Breeze.shared_Breeze.userList_Breeze
        
        if let user_breeze = users_breeze.first(where: { $0.userId_Breeze == userId_breeze }) {
            return user_breeze
        }
        
        // 返回默认用户
        let defaultPrewUser_breeze = PrewUserModel_Breeze()
        defaultPrewUser_breeze.userId_Breeze = userId_breeze
        defaultPrewUser_breeze.userName_Breeze = "Guest"
        defaultPrewUser_breeze.userHead_Breeze = "default_avatar"
        return defaultPrewUser_breeze
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Breeze() -> [PrewUserModel_Breeze] {
        let users_breeze = LocalData_Breeze.shared_Breeze.userList_Breeze
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_breeze
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Breeze(post_breeze: TitleModel_Breeze) {
        guard let user_breeze = loggedUser_Breeze else { return }
        user_breeze.userPosts_Breeze.append(post_breeze)
        loggedUser_Breeze = user_breeze
        notifyStateChange_Breeze()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Breeze(post_breeze: TitleModel_Breeze) {
        guard let user_breeze = loggedUser_Breeze else { return }
        user_breeze.userPosts_Breeze.removeAll { $0.titleId_Breeze == post_breeze.titleId_Breeze }
        loggedUser_Breeze = user_breeze
        notifyStateChange_Breeze()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Breeze(post_breeze: TitleModel_Breeze) {
        guard let user_breeze = loggedUser_Breeze else { return }
        
        // 检查是否已存在
        if !user_breeze.userLike_Breeze.contains(where: { $0.titleId_Breeze == post_breeze.titleId_Breeze }) {
            user_breeze.userLike_Breeze.append(post_breeze)
            loggedUser_Breeze = user_breeze
            notifyStateChange_Breeze()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Breeze(post_breeze: TitleModel_Breeze) {
        guard let user_breeze = loggedUser_Breeze else { return }
        user_breeze.userLike_Breeze.removeAll { $0.titleId_Breeze == post_breeze.titleId_Breeze }
        loggedUser_Breeze = user_breeze
        notifyStateChange_Breeze()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Breeze(post_breeze: TitleModel_Breeze) -> Bool {
        guard let user_breeze = loggedUser_Breeze else { return false }
        return user_breeze.userLike_Breeze.contains { $0.titleId_Breeze == post_breeze.titleId_Breeze }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    // MARK: - 相册管理
    
    /// UserDefaults 相册存储键
    private let albumKey_Breeze = "CampingAlbum_Breeze"
    
    /// 获取当前用户的相册条目列表（按日期倒序）
    /// - Returns: 相册条目数组
    func getAlbumItems_Breeze() -> [CampingAlbumItem_Breeze] {
        guard let data_breeze = UserDefaults.standard.data(forKey: albumKey_Breeze),
              let items_breeze = try? JSONDecoder().decode([CampingAlbumItem_Breeze].self, from: data_breeze) else {
            return []
        }
        return items_breeze.sorted { $0.dateString_Breeze > $1.dateString_Breeze }
    }
    
    /// 添加一条相册条目
    /// - Parameters:
    ///   - imagePath_breeze: 图片存储路径（Documents 目录文件名）
    ///   - season_breeze: 所属季节（默认当前季节）
    ///   - date_breeze: 拍摄日期（默认今天）
    ///   - locationNote_breeze: 公园/地点备注
    ///   - userNote_breeze: 用户自定义备注（可选）
    func addAlbumItem_Breeze(imagePath_breeze: String,
                              season_breeze: Season_Breeze = Season_Breeze.current_Breeze,
                              date_breeze: Date = Date(),
                              locationNote_breeze: String = "",
                              userNote_breeze: String = "") {
        var items_breeze = getAlbumItems_Breeze()
        
        let formatter_breeze = DateFormatter()
        formatter_breeze.dateFormat = "yyyy-MM-dd"
        let dateStr_breeze = formatter_breeze.string(from: date_breeze)
        
        let newId_breeze = (items_breeze.map { $0.itemId_Breeze }.max() ?? 0) + 1
        let item_breeze = CampingAlbumItem_Breeze(
            itemId_Breeze: newId_breeze,
            imagePath_Breeze: imagePath_breeze,
            seasonRaw_Breeze: season_breeze.rawValue,
            dateString_Breeze: dateStr_breeze,
            locationNote_Breeze: locationNote_breeze,
            userNote_Breeze: userNote_breeze
        )
        items_breeze.append(item_breeze)
        saveAlbumItems_Breeze(items_breeze)
        notifyStateChange_Breeze()
    }
    
    /// 删除指定相册条目
    /// - Parameter itemId_breeze: 目标条目 ID
    func deleteAlbumItem_Breeze(itemId_breeze: Int) {
        var items_breeze = getAlbumItems_Breeze()
        items_breeze.removeAll { $0.itemId_Breeze == itemId_breeze }
        saveAlbumItems_Breeze(items_breeze)
        notifyStateChange_Breeze()
    }
    
    /// 获取按季节分组的相册条目 [Season.rawValue: [items]]
    func getAlbumGroupedBySeason_Breeze() -> [String: [CampingAlbumItem_Breeze]] {
        let items_breeze = getAlbumItems_Breeze()
        return Dictionary(grouping: items_breeze, by: { $0.seasonRaw_Breeze })
    }
    
    /// 持久化相册数据到 UserDefaults
    private func saveAlbumItems_Breeze(_ items_breeze: [CampingAlbumItem_Breeze]) {
        if let data_breeze = try? JSONEncoder().encode(items_breeze) {
            UserDefaults.standard.set(data_breeze, forKey: albumKey_Breeze)
        }
    }
    
    // MARK: - 通知
    
    /// 发送状态更新通知
    private func notifyStateChange_Breeze() {
        NotificationCenter.default.post(
            name: UserViewModel_Breeze.userStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Breeze() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Breeze.toLogin_Breeze(style_breeze: .present_breeze)
        }
    }
}
