import Foundation
import Combine
import UIKit

// MARK: - 用户ViewModel

/// 登出类型枚举
enum LogOutType_lite {
    /// 删除账号
    case delete_lite
    /// 普通登出
    case logout_lite
}

/// 用户状态管理类
class UserViewModel_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = UserViewModel_lite()
    
    // MARK: - 响应式属性
    
    /// 当前登录用户
    @Published var loggedUser_lite: LoginUserModel_lite?
    
    /// 默认用户（游客）
    private let defaultUser_lite = LoginUserModel_lite(
        userId_lite: 0,
        userPwd_lite: nil,
        userName_lite: "Guest",
        userHead_lite: "default_avatar",
        userIntroduce_lite: "Nothing yet.",
        userPosts_lite: [],
        userLike_lite: [],
        userFollow_lite: []
    )
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录（计算属性，自动响应 loggedUser 变化）
    var isLoggedIn_lite: Bool {
        return loggedUser_lite?.userId_lite != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_lite() -> LoginUserModel_lite {
        return loggedUser_lite ?? defaultUser_lite
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_lite() {
        loggedUser_lite = defaultUser_lite
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_lite(userId_lite: Int) {
        // 创建登录用户
        loggedUser_lite = LoginUserModel_lite(
            userId_lite: userId_lite,
            userPwd_lite: nil,
            userName_lite: "Lite", // 可以从本地数据或服务器获取
            userHead_lite: "user_avatar",
            userIntroduce_lite: "Nothing yet.",
            userPosts_lite: [],
            userLike_lite: [],
            userFollow_lite: []
        )
        
        // 延迟跳转到首页
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.2秒
            
            // 显示成功提示
            Utils_lite.showSuccess_lite(message_lite: "Login successful!")
            
            // 关闭登录页面（如果是全屏展示的话）
            Router_lite.shared_lite.dismissFullScreen_lite()
        }
    }
    
    /// 用户登出
    func logout_lite(logoutType_lite: LogOutType_lite) {
        if !isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 重置为游客状态
        loggedUser_lite = defaultUser_lite
        
        // 清空AI聊天记录
        MessageViewModel_lite.shared_lite.clearAiChat_lite()
        
        // 重新初始化本地数据
        LocalData_lite.shared_lite.initData_lite()
        
        // 返回到根页面
        Router_lite.shared_lite.popToRoot_lite()
        
        // 延迟显示提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if logoutType_lite == .delete_lite {
                Utils_lite.showInfo_lite(
                    message_lite: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_lite: 3.0
                )
            } else {
                Utils_lite.showSuccess_lite(message_lite: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_lite(headUrl_lite: String) {
        loggedUser_lite?.userHead_lite = headUrl_lite
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_lite.showSuccess_lite(message_lite: "Avatar updated successfully")
    }
    
    /// 更新用户昵称
    func updateName_lite(userName_lite: String) {
        loggedUser_lite?.userName_lite = userName_lite
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_lite.showSuccess_lite(message_lite: "Name updated successfully")
    }
    
    /// 上传用户封面
    func uploadCover_lite(coverUrl_lite: String) {
        loggedUser_lite?.userCover_lite = coverUrl_lite
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_lite.showSuccess_lite(message_lite: "Cover updated successfully")
    }

    /// 更新用户简介
    func updateIntroduce_lite(introduce_lite: String) {
        loggedUser_lite?.userIntroduce_lite = introduce_lite
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_lite.showSuccess_lite(message_lite: "Introduce updated successfully")
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_lite() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_lite() {
        if hasCheckedInToday_lite() {
            Utils_lite.showWarning_lite(
                message_lite: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_lite.showSuccess_lite(
            message_lite: "Check-in successful!",
            image_lite: UIImage(systemName: "checkmark.seal.fill")
        )
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_lite(user_lite: PrewUserModel_lite) -> Bool {
        guard let loggedUser = loggedUser_lite else { return false }
        return loggedUser.userFollow_lite.contains(where: { $0.userId_lite == user_lite.userId_lite })
    }
    
    /// 关注/取消关注用户
    func followUser_lite(user_lite: PrewUserModel_lite) {
        if !isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        if isFollowing_lite(user_lite: user_lite) {
            // 取消关注
            loggedUser_lite?.userFollow_lite.removeAll { $0.userId_lite == user_lite.userId_lite }
        } else {
            // 关注
            loggedUser_lite?.userFollow_lite.append(user_lite)
        }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_lite(user_lite: PrewUserModel_lite) {
        guard let userId_lite = user_lite.userId_lite else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_lite.shared_lite.deleteUserMessages_lite(
            userId_lite: userId_lite
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_lite.shared_lite.deleteUserPosts_lite(
            userId_lite: userId_lite
        )
        
        // 从本地用户列表中移除
        LocalData_lite.shared_lite.userList_lite.removeAll { $0.userId_lite == userId_lite }
        
        // 延迟显示成功提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Utils_lite.showSuccess_lite(
                message_lite: "This user will no longer appear.",
                delay_lite: 2.0
            )
        }
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_lite(userId_lite: Int) -> Bool {
        return loggedUser_lite?.userId_lite == userId_lite
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_lite(userId_lite: Int) -> PrewUserModel_lite {
        let users_lite = LocalData_lite.shared_lite.userList_lite
        
        if let user_lite = users_lite.first(where: { $0.userId_lite == userId_lite }) {
            return user_lite
        }
        
        // 返回默认用户
        let defaultPrewUser_lite = PrewUserModel_lite()
        defaultPrewUser_lite.userId_lite = userId_lite
        defaultPrewUser_lite.userName_lite = "Guest"
        defaultPrewUser_lite.userHead_lite = "default_avatar"
        return defaultPrewUser_lite
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_lite() -> [PrewUserModel_lite] {
        let users_lite = LocalData_lite.shared_lite.userList_lite
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_lite
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_lite(post_lite: TitleModel_lite) {
        loggedUser_lite?.userPosts_lite.append(post_lite)
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_lite(post_lite: TitleModel_lite) {
        loggedUser_lite?.userPosts_lite.removeAll { $0.titleId_lite == post_lite.titleId_lite }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_lite(post_lite: TitleModel_lite) {
        // 检查是否已存在
        if let user = loggedUser_lite,
           !user.userLike_lite.contains(where: { $0.titleId_lite == post_lite.titleId_lite }) {
            loggedUser_lite?.userLike_lite.append(post_lite)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_lite(post_lite: TitleModel_lite) {
        loggedUser_lite?.userLike_lite.removeAll { $0.titleId_lite == post_lite.titleId_lite }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_lite(post_lite: TitleModel_lite) -> Bool {
        guard let user_lite = loggedUser_lite else { return false }
        return user_lite.userLike_lite.contains { $0.titleId_lite == post_lite.titleId_lite }
    }
    
    // MARK: - 穿搭时光轴管理
    
    /// 获取当前用户的穿搭时光轴列表
    func getUserTimeline_lite() -> [OutfitTimeline_lite] {
        return loggedUser_lite?.userTimeline_lite ?? []
    }
    
    /// 添加穿搭到时光轴
    /// - Parameters:
    ///   - outfit_lite: 要添加的穿搭组合
    ///   - note_lite: 文字备注（可选）
    ///   - memoryTag_lite: 纪念标签（可选）
    func addOutfitToTimeline_lite(outfit_lite: OutfitCombo_lite, note_lite: String? = nil, memoryTag_lite: String? = nil) {
        // 检查是否登录
        if !isLoggedIn_lite {
            showLoginPrompt_lite()
            return
        }
        
        // 创建时光轴记录
        let timelineId_lite = Int.random(in: 10000...99999)
        let timeline_lite = OutfitTimeline_lite(
            timelineId_lite: timelineId_lite,
            userId_lite: loggedUser_lite?.userId_lite ?? 0,
            outfit_lite: outfit_lite,
            recordDate_lite: Date(),
            note_lite: note_lite,
            memoryTag_lite: memoryTag_lite
        )
        
        // 添加到用户的时光轴列表
        loggedUser_lite?.userTimeline_lite.append(timeline_lite)
        
        // 手动触发更新
        objectWillChange.send()
        
        Utils_lite.showSuccess_lite(
            message_lite: "Added to your style timeline!",
            image_lite: UIImage(systemName: "calendar.badge.checkmark")
        )
    }
    
    /// 从时光轴移除穿搭记录
    /// - Parameter timelineId_lite: 时光轴记录ID
    func removeFromTimeline_lite(timelineId_lite: Int) {
        loggedUser_lite?.userTimeline_lite.removeAll { $0.timelineId_lite == timelineId_lite }
        
        // 手动触发更新
        objectWillChange.send()
        
        Utils_lite.showSuccess_lite(message_lite: "Removed from timeline")
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_lite() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_lite.shared_lite.toLogin_liteui()
        }
    }
}
