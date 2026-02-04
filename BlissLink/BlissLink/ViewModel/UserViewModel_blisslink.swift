import Foundation
import Combine
import UIKit

// MARK: - 用户ViewModel

/// 登出类型枚举
enum LogOutType_blisslink {
    /// 删除账号
    case delete_blisslink
    /// 普通登出
    case logout_blisslink
}

/// 用户状态管理类
class UserViewModel_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = UserViewModel_blisslink()
    
    // MARK: - 响应式属性
    
    /// 当前登录用户
    @Published var loggedUser_blisslink: LoginUserModel_blisslink?
    
    /// 默认用户（游客）
    private let defaultUser_blisslink = LoginUserModel_blisslink(
        userId_blisslink: 0,
        userPwd_blisslink: nil,
        userName_blisslink: "Guest",
        userHead_blisslink: "default_avatar",
        userPosts_blisslink: [],
        userLike_blisslink: [],
        userFollow_blisslink: [],
        yogaMatBackground_blisslink: .forestZen_blisslink,
        badges_blisslink: [],
        memoryStickers_blisslink: []
    )
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录（计算属性，自动响应 loggedUser 变化）
    var isLoggedIn_blisslink: Bool {
        return loggedUser_blisslink?.userId_blisslink != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_blisslink() -> LoginUserModel_blisslink {
        return loggedUser_blisslink ?? defaultUser_blisslink
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_blisslink() {
        loggedUser_blisslink = defaultUser_blisslink
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_blisslink(userId_blisslink: Int) {
        
        // 创建登录用户
        loggedUser_blisslink = LoginUserModel_blisslink(
            userId_blisslink: userId_blisslink,
            userPwd_blisslink: nil,
            userName_blisslink: "BlissLinker", // 可以从本地数据或服务器获取
            userHead_blisslink: "user_avatar",
            userPosts_blisslink: [],
            userLike_blisslink: [],
            userFollow_blisslink: [],
            yogaMatBackground_blisslink: .forestZen_blisslink,
            badges_blisslink: [],
            memoryStickers_blisslink: []
        )
        
        // 延迟跳转到首页
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.2秒
            
            // 显示成功提示
            Utils_blisslink.showSuccess_blisslink(message_blisslink: "Login successful!")
            
            // 关闭登录页面（如果是全屏展示的话）
            Router_blisslink.shared_blisslink.dismissFullScreen_blisslink()
        }
    }
    
    /// 用户登出
    func logout_blisslink(logoutType_blisslink: LogOutType_blisslink) {
        if !isLoggedIn_blisslink {
            showLoginPrompt_blisslink()
            return
        }
        
        // 重置为游客状态
        loggedUser_blisslink = defaultUser_blisslink
        
        // 清空AI聊天记录
        MessageViewModel_blisslink.shared_blisslink.clearAiChat_blisslink()
        
        // 重新初始化本地数据
        LocalData_blisslink.shared_blisslink.initData_blisslink()
        
        // 返回到根页面
        Router_blisslink.shared_blisslink.popToRoot_blisslink()
        
        // 延迟显示提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if logoutType_blisslink == .delete_blisslink {
                Utils_blisslink.showInfo_blisslink(
                    message_blisslink: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_blisslink: 3.0
                )
            } else {
                Utils_blisslink.showSuccess_blisslink(message_blisslink: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_blisslink(headUrl_blisslink: String) {
        loggedUser_blisslink?.userHead_blisslink = headUrl_blisslink
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_blisslink.showSuccess_blisslink(message_blisslink: "Avatar updated successfully")
    }
    
    /// 更新用户昵称
    func updateName_blisslink(userName_blisslink: String) {
        loggedUser_blisslink?.userName_blisslink = userName_blisslink
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_blisslink.showSuccess_blisslink(message_blisslink: "Name updated successfully")
    }
    
    /// 更新用户简介
    func updateIntroduce_blisslink(introduce_blisslink: String) {
        loggedUser_blisslink?.userIntroduce_blisslink = introduce_blisslink
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_blisslink.showSuccess_blisslink(message_blisslink: "Bio updated successfully")
    }
    
    /// 上传用户封面
    func uploadCover_blisslink(coverUrl_blisslink: String) {
        Utils_blisslink.showSuccess_blisslink(message_blisslink: "Cover updated successfully")
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_blisslink() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_blisslink() {
        if hasCheckedInToday_blisslink() {
            Utils_blisslink.showWarning_blisslink(
                message_blisslink: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: "Check-in successful!",
            image_blisslink: UIImage(systemName: "checkmark.seal.fill")
        )
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_blisslink(user_blisslink: PrewUserModel_blisslink) -> Bool {
        guard let loggedUser = loggedUser_blisslink else { return false }
        return loggedUser.userFollow_blisslink.contains(where: { $0.userId_blisslink == user_blisslink.userId_blisslink })
    }
    
    /// 关注/取消关注用户
    func followUser_blisslink(user_blisslink: PrewUserModel_blisslink) {
        if !isLoggedIn_blisslink {
            showLoginPrompt_blisslink()
            return
        }
        
        if isFollowing_blisslink(user_blisslink: user_blisslink) {
            // 取消关注
            loggedUser_blisslink?.userFollow_blisslink.removeAll { $0.userId_blisslink == user_blisslink.userId_blisslink }
        } else {
            // 关注
            loggedUser_blisslink?.userFollow_blisslink.append(user_blisslink)
        }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_blisslink(user_blisslink: PrewUserModel_blisslink) {
        guard let userId_blisslink = user_blisslink.userId_blisslink else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_blisslink.shared_blisslink.deleteUserMessages_blisslink(
            userId_blisslink: userId_blisslink
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_blisslink.shared_blisslink.deleteUserPosts_blisslink(
            userId_blisslink: userId_blisslink
        )
        
        // 从本地用户列表中移除
        LocalData_blisslink.shared_blisslink.userList_blisslink.removeAll { $0.userId_blisslink == userId_blisslink }
        
        // 延迟显示成功提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_blisslink.showSuccess_blisslink(
                message_blisslink: "This user will no longer appear.",
                delay_blisslink: 2.0
            )
        }
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_blisslink(userId_blisslink: Int) -> Bool {
        return loggedUser_blisslink?.userId_blisslink == userId_blisslink
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_blisslink(userId_blisslink: Int) -> PrewUserModel_blisslink {
        let users_blisslink = LocalData_blisslink.shared_blisslink.userList_blisslink
        
        if let user_blisslink = users_blisslink.first(where: { $0.userId_blisslink == userId_blisslink }) {
            return user_blisslink
        }
        
        // 返回默认用户
        let defaultPrewUser_blisslink = PrewUserModel_blisslink()
        defaultPrewUser_blisslink.userId_blisslink = userId_blisslink
        defaultPrewUser_blisslink.userName_blisslink = "Guest"
        defaultPrewUser_blisslink.userHead_blisslink = "default_avatar"
        return defaultPrewUser_blisslink
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_blisslink() -> [PrewUserModel_blisslink] {
        let users_blisslink = LocalData_blisslink.shared_blisslink.userList_blisslink
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_blisslink
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_blisslink(post_blisslink: TitleModel_blisslink) {
        loggedUser_blisslink?.userPosts_blisslink.append(post_blisslink)
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_blisslink(post_blisslink: TitleModel_blisslink) {
        loggedUser_blisslink?.userPosts_blisslink.removeAll { $0.titleId_blisslink == post_blisslink.titleId_blisslink }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_blisslink(post_blisslink: TitleModel_blisslink) {
        // 检查是否已存在
        if let user = loggedUser_blisslink,
           !user.userLike_blisslink.contains(where: { $0.titleId_blisslink == post_blisslink.titleId_blisslink }) {
            loggedUser_blisslink?.userLike_blisslink.append(post_blisslink)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_blisslink(post_blisslink: TitleModel_blisslink) {
        loggedUser_blisslink?.userLike_blisslink.removeAll { $0.titleId_blisslink == post_blisslink.titleId_blisslink }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_blisslink(post_blisslink: TitleModel_blisslink) -> Bool {
        guard let user_blisslink = loggedUser_blisslink else { return false }
        return user_blisslink.userLike_blisslink.contains { $0.titleId_blisslink == post_blisslink.titleId_blisslink }
    }
    
    // MARK: - 瑜伽垫功能
    
    /// 更换瑜伽垫背景
    /// - Parameter background_blisslink: 新背景
    func changeYogaMatBackground_blisslink(background_blisslink: YogaMatBackground_blisslink) {
        loggedUser_blisslink?.yogaMatBackground_blisslink = background_blisslink
        
        // 手动触发更新
        objectWillChange.send()
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: "Mat theme changed!",
            image_blisslink: UIImage(systemName: "checkmark.circle.fill")
        )
        
        print("🎨 更换瑜伽垫背景：\(background_blisslink.rawValue)")
    }
    
    /// 获取当前瑜伽垫背景
    /// - Returns: 当前背景
    func getCurrentYogaMatBackground_blisslink() -> YogaMatBackground_blisslink {
        return loggedUser_blisslink?.yogaMatBackground_blisslink ?? .forestZen_blisslink
    }
    
    /// 添加纪念贴纸
    /// - Parameter sticker_blisslink: 贴纸对象
    func addMemorySticker_blisslink(sticker_blisslink: MemorySticker_blisslink) {
        loggedUser_blisslink?.memoryStickers_blisslink.append(sticker_blisslink)
        
        // 手动触发更新
        objectWillChange.send()
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: "Memory added!",
            image_blisslink: UIImage(systemName: "photo.fill"),
            delay_blisslink: 2.0
        )
    }
    
    /// 获取纪念贴纸列表
    /// - Returns: 贴纸列表
    func getMemoryStickers_blisslink() -> [MemorySticker_blisslink] {
        return loggedUser_blisslink?.memoryStickers_blisslink ?? []
    }
    
    /// 删除纪念贴纸
    /// - Parameter sticker_blisslink: 要删除的贴纸对象
    func deleteMemorySticker_blisslink(sticker_blisslink: MemorySticker_blisslink) {
        loggedUser_blisslink?.memoryStickers_blisslink.removeAll { $0.stickerId_blisslink == sticker_blisslink.stickerId_blisslink }
        
        // 手动触发更新
        objectWillChange.send()
        
        Utils_blisslink.showSuccess_blisslink(
            message_blisslink: "Memory deleted!",
            image_blisslink: UIImage(systemName: "trash.fill"),
            delay_blisslink: 1.5
        )
    }
    
    /// 解锁徽章
    /// - Parameter badge_blisslink: 徽章对象
    func unlockBadge_blisslink(badge_blisslink: MeditationBadge_blisslink) {
        if !badge_blisslink.isUnlocked_blisslink {
            let unlockedBadge_blisslink = badge_blisslink
            unlockedBadge_blisslink.isUnlocked_blisslink = true
            unlockedBadge_blisslink.unlockDate_blisslink = Date()
            
            loggedUser_blisslink?.badges_blisslink.append(unlockedBadge_blisslink)
            
            // 手动触发更新
            objectWillChange.send()
            
            Utils_blisslink.showSuccess_blisslink(
                message_blisslink: "Badge unlocked: \(badge_blisslink.badgeName_blisslink)!",
                image_blisslink: UIImage(systemName: "star.fill"),
                delay_blisslink: 3.0
            )
        }
    }
    
    /// 获取已解锁的徽章列表
    /// - Returns: 徽章列表
    func getUnlockedBadges_blisslink() -> [MeditationBadge_blisslink] {
        return loggedUser_blisslink?.badges_blisslink ?? []
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_blisslink() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            Router_blisslink.shared_blisslink.toLogin_blisslink()
        }
    }
}
