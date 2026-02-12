import Foundation
import Combine
import UIKit

// MARK: - 用户ViewModel

/// 登出类型枚举
enum LogOutType_platbell {
    /// 删除账号
    case delete_platbell
    /// 普通登出
    case logout_platbell
}

/// 用户状态管理类
class UserViewModel_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = UserViewModel_platbell()
    
    // MARK: - 响应式属性
    
    /// 当前登录用户
    @Published var loggedUser_platbell: LoginUserModel_platbell?
    
    /// 默认用户（游客）
    private let defaultUser_platbell = LoginUserModel_platbell(
        userId_platbell: 0,
        userPwd_platbell: nil,
        userName_platbell: "Guest",
        userHead_platbell: "default_avatar",
        userIntroduce_platbell: "Nothing yet.",
        userPosts_platbell: [],
        userLike_platbell: [],
        userFollow_platbell: [],
        checkInStreak_platbell: 0,
        checkInThisWeek_platbell: 0,
        totalCheckIns_platbell: 0,
        checkInRanking_platbell: 0,
        checkInPoints_platbell: 0,
        lastCheckInDate_platbell: nil
    )
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录（计算属性，自动响应 loggedUser 变化）
    var isLoggedIn_platbell: Bool {
        return loggedUser_platbell?.userId_platbell != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_platbell() -> LoginUserModel_platbell {
        return loggedUser_platbell ?? defaultUser_platbell
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_platbell() {
        loggedUser_platbell = defaultUser_platbell
    }
    
    // MARK: - 登录/登出
    
    /// 用户名密码登录
    /// - Parameters:
    ///   - userName_platbell: 用户名
    ///   - passWord_platbell: 密码
    /// - Returns: 是否登录成功
    func login_platbell(userName_platbell: String, passWord_platbell: String) -> Bool {
        // 这里应该调用实际的登录API，从服务器获取用户真实数据
        // 简单验证：任意非空用户名和密码都可以登录
        
        // 创建登录用户（签到数据应从服务器API返回）
        loggedUser_platbell = LoginUserModel_platbell(
            userId_platbell: 1,  // 实际应该从服务器返回
            userPwd_platbell: passWord_platbell,
            userName_platbell: userName_platbell,
            userHead_platbell: "person.fill",
            userIntroduce_platbell: "Welcome to PlatBell!",
            userPosts_platbell: [],
            userLike_platbell: [],
            userFollow_platbell: [],
            checkInStreak_platbell: 0,  // 应从服务器获取真实数据
            checkInThisWeek_platbell: 0,  // 应从服务器获取真实数据
            totalCheckIns_platbell: 0,  // 应从服务器获取真实数据
            checkInRanking_platbell: 0,  // 应从服务器获取真实数据
            checkInPoints_platbell: 0,  // 应从服务器获取真实数据
            lastCheckInDate_platbell: nil  // 应从服务器获取真实数据
        )
        
        return true
    }
    
    /// 用户注册
    /// - Parameters:
    ///   - userName_platbell: 用户名
    ///   - passWord_platbell: 密码
    /// - Returns: 是否注册成功
    func register_platbell(userName_platbell: String, passWord_platbell: String) -> Bool {
        // 这里应该调用实际的注册API，暂时使用模拟数据
        // 简单验证：检查用户名是否已存在（这里暂时都返回成功）
        
        // 创建新用户
        loggedUser_platbell = LoginUserModel_platbell(
            userId_platbell: Int.random(in: 1000...9999),  // 随机生成用户ID
            userPwd_platbell: passWord_platbell,
            userName_platbell: userName_platbell,
            userHead_platbell: "person.fill",
            userIntroduce_platbell: "New member of PlatBell!",
            userPosts_platbell: [],
            userLike_platbell: [],
            userFollow_platbell: [],
            checkInStreak_platbell: 0,
            checkInThisWeek_platbell: 0,
            totalCheckIns_platbell: 0,
            checkInRanking_platbell: 0,
            checkInPoints_platbell: 0,
            lastCheckInDate_platbell: nil
        )
        
        return true
    }
    
    /// 通过用户ID登录
    /// 功能：根据用户ID创建登录用户，签到数据应从服务器API获取
    func loginById_platbell(userId_platbell: Int) {
        // 创建登录用户（签到数据应从服务器API返回）
        loggedUser_platbell = LoginUserModel_platbell(
            userId_platbell: userId_platbell,
            userPwd_platbell: nil,
            userName_platbell: "Platbell", // 应从本地数据或服务器获取
            userHead_platbell: "user_avatar",
            userIntroduce_platbell: "Nothing yet.",
            userPosts_platbell: [],
            userLike_platbell: [],
            userFollow_platbell: [],
            checkInStreak_platbell: 0,  // 应从服务器获取真实数据
            checkInThisWeek_platbell: 0,  // 应从服务器获取真实数据
            totalCheckIns_platbell: 0,  // 应从服务器获取真实数据
            checkInRanking_platbell: 0,  // 应从服务器获取真实数据
            checkInPoints_platbell: 0,  // 应从服务器获取真实数据
            lastCheckInDate_platbell: nil  // 应从服务器获取真实数据
        )
        
        // 延迟跳转到首页
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            
            // 显示成功提示
            Utils_platbell.showSuccess_platbell(message_platbell: "Login successful!")
            
            // 关闭登录页面（如果是全屏展示的话）
            Router_platbell.shared_platbell.dismissFullScreen_platbell()
        }
    }
    
    /// 用户登出
    func logout_platbell(logoutType_platbell: LogOutType_platbell) {
        if !isLoggedIn_platbell {
            showLoginPrompt_platbell()
            return
        }
        
        // 重置为游客状态
        loggedUser_platbell = defaultUser_platbell
        
        // 清空AI聊天记录
        MessageViewModel_platbell.shared_platbell.clearAiChat_platbell()
        
        // 重新初始化本地数据
        LocalData_platbell.shared_platbell.initData_platbell()
        
        // 返回到根页面
        Router_platbell.shared_platbell.popToRoot_platbell()
        
        // 延迟显示提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if logoutType_platbell == .delete_platbell {
                Utils_platbell.showInfo_platbell(
                    message_platbell: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_platbell: 3.0
                )
            } else {
                Utils_platbell.showSuccess_platbell(message_platbell: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_platbell(headUrl_platbell: String) {
        loggedUser_platbell?.userHead_platbell = headUrl_platbell
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_platbell.showSuccess_platbell(message_platbell: "Avatar updated successfully")
    }
    
    /// 更新用户昵称
    func updateName_platbell(userName_platbell: String) {
        loggedUser_platbell?.userName_platbell = userName_platbell
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_platbell.showSuccess_platbell(message_platbell: "Name updated successfully")
    }
    
    /// 上传用户封面
    func uploadCover_platbell(coverUrl_platbell: String) {
        loggedUser_platbell?.userCover_platbell = coverUrl_platbell
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_platbell.showSuccess_platbell(message_platbell: "Cover updated successfully")
    }

    /// 更新用户简介
    func updateIntroduce_platbell(introduce_platbell: String) {
        loggedUser_platbell?.userIntroduce_platbell = introduce_platbell
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
        Utils_platbell.showSuccess_platbell(message_platbell: "Introduce updated successfully")
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_platbell() -> Bool {
        guard let lastDate_platbell = loggedUser_platbell?.lastCheckInDate_platbell else {
            return false
        }
        
        let currentDate_platbell = getCurrentDateString_platbell()
        return lastDate_platbell == currentDate_platbell
    }
    
    /// 打卡
    func checkIn_platbell() {
        guard let user_platbell = loggedUser_platbell, user_platbell.userId_platbell != 0 else {
            return
        }
        
        if hasCheckedInToday_platbell() {
            Utils_platbell.showWarning_platbell(
                message_platbell: "You have already checked in today."
            )
            return
        }
        
        // 获取昨天日期
        let yesterday_platbell = getYesterdayDateString_platbell()
        let isConsecutive_platbell = loggedUser_platbell?.lastCheckInDate_platbell == yesterday_platbell
        
        // 更新打卡数据
        loggedUser_platbell?.totalCheckIns_platbell += 1
        loggedUser_platbell?.checkInThisWeek_platbell += 1
        loggedUser_platbell?.lastCheckInDate_platbell = getCurrentDateString_platbell()
        
        // 更新连续打卡天数
        if isConsecutive_platbell {
            loggedUser_platbell?.checkInStreak_platbell += 1
        } else {
            loggedUser_platbell?.checkInStreak_platbell = 1
        }
        
        // 更新积分（每次打卡+10分，连续打卡额外+5分）
        let bonusPoints_platbell = isConsecutive_platbell ? 15 : 10
        loggedUser_platbell?.checkInPoints_platbell += bonusPoints_platbell
        
        // 手动触发更新
        objectWillChange.send()
        
        // 显示成功提示
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Check-in successful! +\(bonusPoints_platbell) points",
            image_platbell: UIImage(systemName: "checkmark.seal.fill"),
            delay_platbell: 2.0
        )
    }
    
    // MARK: - 日期工具方法
    
    /// 获取当前日期字符串（yyyy-MM-dd）
    private func getCurrentDateString_platbell() -> String {
        let formatter_platbell = DateFormatter()
        formatter_platbell.dateFormat = "yyyy-MM-dd"
        return formatter_platbell.string(from: Date())
    }
    
    /// 获取昨天日期字符串（yyyy-MM-dd）
    private func getYesterdayDateString_platbell() -> String {
        let formatter_platbell = DateFormatter()
        formatter_platbell.dateFormat = "yyyy-MM-dd"
        guard let yesterday_platbell = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return ""
        }
        return formatter_platbell.string(from: yesterday_platbell)
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    func isFollowing_platbell(user_platbell: PrewUserModel_platbell) -> Bool {
        guard let loggedUser = loggedUser_platbell else { return false }
        return loggedUser.userFollow_platbell.contains(where: { $0.userId_platbell == user_platbell.userId_platbell })
    }
    
    /// 关注/取消关注用户
    func followUser_platbell(user_platbell: PrewUserModel_platbell) {
        if !isLoggedIn_platbell {
            showLoginPrompt_platbell()
            return
        }
        
        if isFollowing_platbell(user_platbell: user_platbell) {
            // 取消关注
            loggedUser_platbell?.userFollow_platbell.removeAll { $0.userId_platbell == user_platbell.userId_platbell }
        } else {
            // 关注
            loggedUser_platbell?.userFollow_platbell.append(user_platbell)
        }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_platbell(user_platbell: PrewUserModel_platbell) {
        guard let userId_platbell = user_platbell.userId_platbell else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_platbell.shared_platbell.deleteUserMessages_platbell(
            userId_platbell: userId_platbell
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_platbell.shared_platbell.deleteUserPosts_platbell(
            userId_platbell: userId_platbell
        )
        
        // 从本地用户列表中移除
        LocalData_platbell.shared_platbell.userList_platbell.removeAll { $0.userId_platbell == userId_platbell }
        
        // 延迟显示成功提示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Utils_platbell.showSuccess_platbell(
                message_platbell: "This user will no longer appear.",
                delay_platbell: 2.0
            )
        }
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_platbell(userId_platbell: Int) -> Bool {
        return loggedUser_platbell?.userId_platbell == userId_platbell
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_platbell(userId_platbell: Int) -> PrewUserModel_platbell {
        let users_platbell = LocalData_platbell.shared_platbell.userList_platbell
        
        if let user_platbell = users_platbell.first(where: { $0.userId_platbell == userId_platbell }) {
            return user_platbell
        }
        
        // 返回默认用户
        let defaultPrewUser_platbell = PrewUserModel_platbell()
        defaultPrewUser_platbell.userId_platbell = userId_platbell
        defaultPrewUser_platbell.userName_platbell = "Guest"
        defaultPrewUser_platbell.userHead_platbell = "default_avatar"
        return defaultPrewUser_platbell
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_platbell() -> [PrewUserModel_platbell] {
        let users_platbell = LocalData_platbell.shared_platbell.userList_platbell
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_platbell
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_platbell(post_platbell: TitleModel_platbell) {
        loggedUser_platbell?.userPosts_platbell.append(post_platbell)
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_platbell(post_platbell: TitleModel_platbell) {
        loggedUser_platbell?.userPosts_platbell.removeAll { $0.titleId_platbell == post_platbell.titleId_platbell }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_platbell(post_platbell: TitleModel_platbell) {
        // 检查是否已存在
        if let user = loggedUser_platbell,
           !user.userLike_platbell.contains(where: { $0.titleId_platbell == post_platbell.titleId_platbell }) {
            loggedUser_platbell?.userLike_platbell.append(post_platbell)
            // 手动触发更新，因为修改了嵌套属性
            objectWillChange.send()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_platbell(post_platbell: TitleModel_platbell) {
        loggedUser_platbell?.userLike_platbell.removeAll { $0.titleId_platbell == post_platbell.titleId_platbell }
        // 手动触发更新，因为修改了嵌套属性
        objectWillChange.send()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_platbell(post_platbell: TitleModel_platbell) -> Bool {
        guard let user_platbell = loggedUser_platbell else { return false }
        return user_platbell.userLike_platbell.contains { $0.titleId_platbell == post_platbell.titleId_platbell }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 显示登录提示
    private func showLoginPrompt_platbell() {
        // 延迟跳转到登录页面
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            Router_platbell.shared_platbell.toLogin_platbellui()
        }
    }
}
