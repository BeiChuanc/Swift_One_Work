import Foundation
import Combine
import UIKit

// MARK: - 用户ViewModel

/// 登出类型枚举
enum LogOutType_baseswiftui {
    /// 删除账号
    case delete_baseswiftui
    /// 普通登出
    case logout_baseswiftui
}

/// 用户状态管理类
class UserViewModel_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = UserViewModel_baseswiftui()
    
    // MARK: - 响应式属性
    
    /// 当前登录用户
    @Published var loggedUser_baseswiftui: LoginUserModel_baseswiftui?
    
    /// 默认用户（游客）
    private let defaultUser_baseswiftui = LoginUserModel_baseswiftui(
        userId_baseswiftui: 0,
        userPwd_baseswiftui: nil,
        userName_baseswiftui: "Guest",
        userHead_baseswiftui: "default_avatar",
        userIntroduce_baseswiftui: "Nothing yet.",
        userPosts_baseswiftui: [],
        userLike_baseswiftui: [],
        userFollow_baseswiftui: []
    )
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录（计算属性，自动响应 loggedUser 变化）
    var isLoggedIn_baseswiftui: Bool {
        return loggedUser_baseswiftui?.userId_baseswiftui != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_baseswiftui() -> LoginUserModel_baseswiftui {
        return loggedUser_baseswiftui ?? defaultUser_baseswiftui
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_baseswiftui() {
        loggedUser_baseswiftui = defaultUser_baseswiftui
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_baseswiftui(userId_baseswiftui: Int) {
        // 创建登录用户
        loggedUser_baseswiftui = LoginUserModel_baseswiftui(
            userId_baseswiftui: userId_baseswiftui,
            userPwd_baseswiftui: nil,
            userName_baseswiftui: "Baseswiftui", // 可以从本地数据或服务器获取
            userHead_baseswiftui: "user_avatar",
            userIntroduce_baseswiftui: "Nothing yet.",
            userPosts_baseswiftui: [],
            userLike_baseswiftui: [],
            userFollow_baseswiftui: []
        )
        
        // 延迟跳转到首页
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.2秒
            
            // 显示成功提示
            Utils_baseswiftui.showSuccess_baseswiftui(message_baseswiftui: "Login successful!")
            
            // 关闭登录页面（如果是全屏展示的话）
            Router_baseswiftui.shared_baseswiftui.dismissFullScreen_baseswiftui()
        }
    }
    
    /// 用户登出
    func logout_baseswiftui(logoutType_baseswiftui: LogOutType_baseswiftui) {
        if !isLoggedIn_baseswiftui {
            showLoginPrompt_baseswiftui()
            return
        }
        
        // 重置为游客状态
        loggedUser_baseswiftui = defaultUser_baseswiftui
        
        // 清空AI聊天记录
        MessageViewModel_baseswiftui.shared_baseswiftui.clearAiChat_baseswiftui()
        
        // 重新初始化本地数据
        LocalData_baseswiftui.shared_baseswiftui.initData_baseswiftui()
        
        // 返回到根页面
        Router_baseswiftui.shared_baseswiftui.popToRoot_baseswiftui()
        
        // 延迟显示提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if logoutType_baseswiftui == .delete_baseswiftui {
                Utils_baseswiftui.showInfo_baseswiftui(
                    message_baseswiftui: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_baseswiftui: 3.0
                )
            } else {
                Utils_baseswiftui.showSuccess_baseswiftui(message_baseswiftui: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_baseswiftui(headUrl_baseswiftui: String) {
        loggedUser_baseswiftui?.userHead_baseswiftui = headUrl_baseswiftui
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_baseswiftui.showSuccess_baseswiftui(message_baseswiftui: "Avatar updated successfully")
    }
    
    /// 更新用户昵称
    func updateName_baseswiftui(userName_baseswiftui: String) {
        loggedUser_baseswiftui?.userName_baseswiftui = userName_baseswiftui
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_baseswiftui.showSuccess_baseswiftui(message_baseswiftui: "Name updated successfully")
    }
    
    /// 上传用户封面
    func uploadCover_baseswiftui(coverUrl_baseswiftui: String) {
        loggedUser_baseswiftui?.userCover_baseswiftui = coverUrl_baseswiftui
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_baseswiftui.showSuccess_baseswiftui(message_baseswiftui: "Cover updated successfully")
    }

    /// 更新用户简介
    func updateIntroduce_baseswiftui(introduce_baseswiftui: String) {
        loggedUser_baseswiftui?.userIntroduce_baseswiftui = introduce_baseswiftui
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_baseswiftui.showSuccess_baseswiftui(message_baseswiftui: "Introduce updated successfully")
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_baseswiftui() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_baseswiftui() {
        if hasCheckedInToday_baseswiftui() {
            Utils_baseswiftui.showWarning_baseswiftui(
                message_baseswiftui: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_baseswiftui.showSuccess_baseswiftui(
            message_baseswiftui: "Check-in successful!",
            image_baseswiftui: UIImage(systemName: "checkmark.seal.fill")
        )
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) -> Bool {
        guard let loggedUser = loggedUser_baseswiftui else { return false }
        return loggedUser.userFollow_baseswiftui.contains(where: { $0.userId_baseswiftui == user_baseswiftui.userId_baseswiftui })
    }
    
    /// 关注/取消关注用户
    func followUser_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) {
        if !isLoggedIn_baseswiftui {
            showLoginPrompt_baseswiftui()
            return
        }
        
        if isFollowing_baseswiftui(user_baseswiftui: user_baseswiftui) {
            // 取消关注
            loggedUser_baseswiftui?.userFollow_baseswiftui.removeAll { $0.userId_baseswiftui == user_baseswiftui.userId_baseswiftui }
        } else {
            // 关注
            loggedUser_baseswiftui?.userFollow_baseswiftui.append(user_baseswiftui)
        }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) {
        guard let userId_baseswiftui = user_baseswiftui.userId_baseswiftui else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_baseswiftui.shared_baseswiftui.deleteUserMessages_baseswiftui(
            userId_baseswiftui: userId_baseswiftui
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_baseswiftui.shared_baseswiftui.deleteUserPosts_baseswiftui(
            userId_baseswiftui: userId_baseswiftui
        )
        
        // 从本地用户列表中移除
        LocalData_baseswiftui.shared_baseswiftui.userList_baseswiftui.removeAll { $0.userId_baseswiftui == userId_baseswiftui }
        
        // 延迟显示成功提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Utils_baseswiftui.showSuccess_baseswiftui(
                message_baseswiftui: "This user will no longer appear.",
                delay_baseswiftui: 2.0
            )
        }
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_baseswiftui(userId_baseswiftui: Int) -> Bool {
        return loggedUser_baseswiftui?.userId_baseswiftui == userId_baseswiftui
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_baseswiftui(userId_baseswiftui: Int) -> PrewUserModel_baseswiftui {
        let users_baseswiftui = LocalData_baseswiftui.shared_baseswiftui.userList_baseswiftui
        
        if let user_baseswiftui = users_baseswiftui.first(where: { $0.userId_baseswiftui == userId_baseswiftui }) {
            return user_baseswiftui
        }
        
        // 返回默认用户
        let defaultPrewUser_baseswiftui = PrewUserModel_baseswiftui()
        defaultPrewUser_baseswiftui.userId_baseswiftui = userId_baseswiftui
        defaultPrewUser_baseswiftui.userName_baseswiftui = "Guest"
        defaultPrewUser_baseswiftui.userHead_baseswiftui = "default_avatar"
        return defaultPrewUser_baseswiftui
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_baseswiftui() -> [PrewUserModel_baseswiftui] {
        let users_baseswiftui = LocalData_baseswiftui.shared_baseswiftui.userList_baseswiftui
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_baseswiftui
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) {
        loggedUser_baseswiftui?.userPosts_baseswiftui.append(post_baseswiftui)
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) {
        loggedUser_baseswiftui?.userPosts_baseswiftui.removeAll { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) {
        // 检查是否已存在
        if let user = loggedUser_baseswiftui,
           !user.userLike_baseswiftui.contains(where: { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }) {
            loggedUser_baseswiftui?.userLike_baseswiftui.append(post_baseswiftui)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) {
        loggedUser_baseswiftui?.userLike_baseswiftui.removeAll { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_baseswiftui(post_baseswiftui: TitleModel_baseswiftui) -> Bool {
        guard let user_baseswiftui = loggedUser_baseswiftui else { return false }
        return user_baseswiftui.userLike_baseswiftui.contains { $0.titleId_baseswiftui == post_baseswiftui.titleId_baseswiftui }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_baseswiftui() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_baseswiftui.shared_baseswiftui.toLogin_baseswiftuiui()
        }
    }
}
