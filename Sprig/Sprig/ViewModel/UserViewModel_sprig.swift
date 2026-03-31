import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Sprig {
    /// 删除账号
    case delete_sprig
    /// 普通登出
    case logout_sprig
}

/// 用户状态管理类
@MainActor
class UserViewModel_Sprig {
    
    /// 单例
    static let shared_Sprig = UserViewModel_Sprig()
    
    // MARK: - 通知名称
    
    /// 用户状态更新通知
    static let userStateDidChangeNotification_Sprig = Notification.Name("UserStateDidChange_Sprig")
    
    // MARK: - 私有属性
    
    /// 当前登录用户
    private var loggedUser_Sprig: LoginUserModel_Sprig?
    
    /// 默认用户（游客）
    private let defaultUser_Sprig = LoginUserModel_Sprig(
        userId_Sprig: 0,
        userPwd_Sprig: nil,
        userName_Sprig: "Guest",
        userHead_Sprig: "default_avatar",
        userPosts_Sprig: [],
        userLike_Sprig: [],
        userFollow_Sprig: []
    )
    
    private init() {}
    
    // MARK: - 公共属性
    
    /// 是否已登录
    var isLoggedIn_Sprig: Bool {
        return loggedUser_Sprig?.userId_Sprig != 0
    }
    
    /// 获取当前用户
    func getCurrentUser_Sprig() -> LoginUserModel_Sprig {
        return loggedUser_Sprig ?? defaultUser_Sprig
    }
    
    // MARK: - 初始化
    
    /// 初始化用户状态
    func initUser_Sprig() {
        loggedUser_Sprig = defaultUser_Sprig
        notifyStateChange_Sprig()
    }
    
    // MARK: - 登录/登出
    
    /// 通过用户ID登录
    func loginById_Sprig(userId_sprig: Int) {
        // 显示加载动画
        Utils_Sprig.showLoading_Sprig(message_Sprig: "Logging in...")
        
        // 创建登录用户（粉丝数使用预设模拟值）
        let newUser_sprig = LoginUserModel_Sprig(
            userId_Sprig: userId_sprig,
            userPwd_Sprig: nil,
            userName_Sprig: "Spriger",
            userHead_Sprig: "user_avatar",
            userPosts_Sprig: [],
            userLike_Sprig: [],
            userFollow_Sprig: []
        )
        newUser_sprig.userFansCount_Sprig = 128
        loggedUser_Sprig = newUser_sprig
        
        // 延迟跳转到首页
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2秒
            
            // 关闭加载动画
            Utils_Sprig.dismissLoading_Sprig()
            
            // 显示成功提示
            Utils_Sprig.showSuccess_Sprig(message_Sprig: "Login successful!")
            
            // 切换到主Tabbar
            Navigation_Sprig.switchToTabbar_Sprig(animated: true)
            
            notifyStateChange_Sprig()
        }
    }
    
    /// 用户登出
    func logout_Sprig(logoutType_sprig: LogOutType_Sprig) {
        if !isLoggedIn_Sprig {
            showLoginPrompt_Sprig()
            return
        }
        
        // 重置为游客状态
        loggedUser_Sprig = defaultUser_Sprig
        
        // 清空AI聊天记录
        MessageViewModel_Sprig.shared_Sprig.clearAiChat_Sprig()
        
        // 重新初始化本地数据
        LocalData_Sprig.shared_Sprig.initData_Sprig()
        
        notifyStateChange_Sprig()
        
        // 跳转到首页
         Navigation_Sprig.switchToTabbar_Sprig()
        
        // 延迟显示提示
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            
            if logoutType_sprig == .delete_sprig {
                Utils_Sprig.showInfo_Sprig(
                    message_Sprig: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Sprig: 3.0
                )
            } else {
                Utils_Sprig.showSuccess_Sprig(message_Sprig: "Logout successful")
            }
        }
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户头像
    func updateHead_Sprig(headUrl_sprig: String) {
        guard let user_sprig = loggedUser_Sprig else { return }
        user_sprig.userHead_Sprig = headUrl_sprig
        loggedUser_Sprig = user_sprig
        Utils_Sprig.showSuccess_Sprig(message_Sprig: "Avatar updated successfully")
        notifyStateChange_Sprig()
    }
    
    /// 更新用户昵称
    func updateName_Sprig(userName_sprig: String) {
        guard let user_sprig = loggedUser_Sprig else { return }
        user_sprig.userName_Sprig = userName_sprig
        loggedUser_Sprig = user_sprig
        Utils_Sprig.showSuccess_Sprig(message_Sprig: "Name updated successfully")
        notifyStateChange_Sprig()
    }
    
    /// 上传用户封面
    func uploadCover_Sprig(coverUrl_sprig: String) {
        Utils_Sprig.showSuccess_Sprig(message_Sprig: "Cover updated successfully")
        notifyStateChange_Sprig()
    }
    
    /// 更新用户简介
    /// - Parameter introduce_sprig: 新的简介文本
    func updateIntroduce_Sprig(introduce_sprig: String) {
        guard let user_sprig = loggedUser_Sprig else { return }
        user_sprig.userIntroduce_Sprig = introduce_sprig
        loggedUser_Sprig = user_sprig
        notifyStateChange_Sprig()
    }
    
    /// 保存头像图片到本地沙盒并更新用户头像路径
    /// - Parameter image_sprig: 选取的头像 UIImage
    func saveAndUpdateAvatar_Sprig(image_sprig: UIImage) {
        guard let imageData_sprig = image_sprig.jpegData(compressionQuality: 0.85) else {
            print("头像图片压缩失败")
            return
        }
        let fileName_sprig = "avatar_sprig_\(Int(Date().timeIntervalSince1970)).jpg"
        guard let documentsDir_sprig = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let filePath_sprig = documentsDir_sprig.appendingPathComponent(fileName_sprig)
        do {
            try imageData_sprig.write(to: filePath_sprig)
            updateHead_Sprig(headUrl_sprig: filePath_sprig.path)
        } catch {
            print("保存头像图片到本地失败: \(error)")
        }
    }
    
    /// 一次性更新用户资料（昵称 + 简介），仅发送一次状态通知
    /// - Parameters:
    ///   - name_sprig: 新昵称，为 nil 时不更新
    ///   - introduce_sprig: 新简介，为 nil 时不更新
    func updateProfile_Sprig(name_sprig: String?, introduce_sprig: String?) {
        guard let user_sprig = loggedUser_Sprig else { return }
        var changed_sprig = false
        if let name_sprig = name_sprig, !name_sprig.isEmpty {
            user_sprig.userName_Sprig = name_sprig
            changed_sprig = true
        }
        if let introduce_sprig = introduce_sprig {
            user_sprig.userIntroduce_Sprig = introduce_sprig
            changed_sprig = true
        }
        if changed_sprig {
            loggedUser_Sprig = user_sprig
            Utils_Sprig.showSuccess_Sprig(message_Sprig: "Profile updated successfully")
            notifyStateChange_Sprig()
        }
    }
    
    // MARK: - 打卡功能
    
    /// 检查今天是否已打卡
    func hasCheckedInToday_Sprig() -> Bool {
        // 需要从用户扩展信息中获取最后打卡日期
        // 暂时返回false
        return false
    }
    
    /// 打卡
    func checkIn_Sprig() {
        if hasCheckedInToday_Sprig() {
            Utils_Sprig.showWarning_Sprig(
                message_Sprig: "You have already checked in today."
            )
            return
        }
        
        // 更新打卡信息（需要在LoginUserModel中添加extra字段）
        Utils_Sprig.showSuccess_Sprig(
            message_Sprig: "Check-in successful!",
            image_Sprig: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Sprig()
    }
    
    // MARK: - 关注功能
    
    /// 判断是否关注指定用户
    /// - Parameter user_sprig: 目标预制用户模型
    /// - Returns: true 表示当前登录用户已关注该用户
    func isFollowing_Sprig(user_sprig: PrewUserModel_Sprig) -> Bool {
        // 修复：guard 中使用不同的局部变量名，避免遮蔽参数 user_sprig
        guard let loggedUser_sprig = loggedUser_Sprig else { return false }
        return loggedUser_sprig.userFollow_Sprig.contains(where: { $0.userId_Sprig == user_sprig.userId_Sprig })
    }
    
    /// 关注/取消关注用户，并同步更新目标用户的粉丝数
    /// - Parameter user_sprig: 目标预制用户模型
    func followUser_Sprig(user_sprig: PrewUserModel_Sprig) {
        if !isLoggedIn_Sprig {
            showLoginPrompt_Sprig()
            return
        }
        
        if isFollowing_Sprig(user_sprig: user_sprig) {
            // 取消关注：从关注列表移除，粉丝数 -1
            loggedUser_Sprig?.userFollow_Sprig.removeAll { $0.userId_Sprig == user_sprig.userId_Sprig }
            if let fans_sprig = user_sprig.userFans_Sprig, fans_sprig > 0 {
                user_sprig.userFans_Sprig = fans_sprig - 1
            }
        } else {
            // 关注：加入关注列表，粉丝数 +1
            loggedUser_Sprig?.userFollow_Sprig.append(user_sprig)
            user_sprig.userFans_Sprig = (user_sprig.userFans_Sprig ?? 0) + 1
        }
        
        notifyStateChange_Sprig()
    }
    
    // MARK: - 举报功能
    
    /// 举报用户
    func reportUser_Sprig(user_sprig: PrewUserModel_Sprig) {
        guard let userId_sprig = user_sprig.userId_Sprig else { return }
        
        // 取消关注
        // 从关注列表中移除（需要实现）
        
        // 删除与该用户的聊天记录
        MessageViewModel_Sprig.shared_Sprig.deleteUserMessages_Sprig(
            userId_sprig: userId_sprig
        )
        
        // 删除该用户的所有帖子
        TitleViewModel_Sprig.shared_Sprig.deleteUserPosts_Sprig(
            userId_sprig: userId_sprig
        )
        
        // 从本地用户列表中移除
        LocalData_Sprig.shared_Sprig.userList_Sprig.removeAll { $0.userId_Sprig == userId_sprig }
        
        // 延迟显示成功提示
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Utils_Sprig.showSuccess_Sprig(
                message_Sprig: "This user will no longer appear.",
                delay_Sprig: 2.0
            )
        }
        
        notifyStateChange_Sprig()
    }
    
    // MARK: - 用户查询
    
    /// 判断是否是当前登录用户
    func isCurrentUser_Sprig(userId_sprig: Int) -> Bool {
        return loggedUser_Sprig?.userId_Sprig == userId_sprig
    }
    
    /// 根据用户ID获取用户信息
    func getUserById_Sprig(userId_sprig: Int) -> PrewUserModel_Sprig {
        let users_sprig = LocalData_Sprig.shared_Sprig.userList_Sprig
        
        if let user_sprig = users_sprig.first(where: { $0.userId_Sprig == userId_sprig }) {
            return user_sprig
        }
        
        // 返回默认用户
        let defaultPrewUser_sprig = PrewUserModel_Sprig()
        defaultPrewUser_sprig.userId_Sprig = userId_sprig
        defaultPrewUser_sprig.userName_Sprig = "Guest"
        defaultPrewUser_sprig.userHead_Sprig = "default_avatar"
        return defaultPrewUser_sprig
    }
    
    /// 获取用户关注排行榜（从高到低）
    func getUserFollowRanking_Sprig() -> [PrewUserModel_Sprig] {
        let users_sprig = LocalData_Sprig.shared_Sprig.userList_Sprig
        
        // 按某个指标排序（这里需要在PrewUserModel中添加关注数字段）
        // 暂时返回原列表
        return users_sprig
    }
    
    // MARK: - 帖子和点赞管理
    
    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Sprig(post_sprig: TitleModel_Sprig) {
        guard let user_sprig = loggedUser_Sprig else { return }
        user_sprig.userPosts_Sprig.append(post_sprig)
        loggedUser_Sprig = user_sprig
        notifyStateChange_Sprig()
    }
    
    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Sprig(post_sprig: TitleModel_Sprig) {
        guard let user_sprig = loggedUser_Sprig else { return }
        user_sprig.userPosts_Sprig.removeAll { $0.titleId_Sprig == post_sprig.titleId_Sprig }
        loggedUser_Sprig = user_sprig
        notifyStateChange_Sprig()
    }
    
    /// 将帖子添加到当前用户的喜欢列表
    func addLikeToCurrentUser_Sprig(post_sprig: TitleModel_Sprig) {
        guard let user_sprig = loggedUser_Sprig else { return }
        
        // 检查是否已存在
        if !user_sprig.userLike_Sprig.contains(where: { $0.titleId_Sprig == post_sprig.titleId_Sprig }) {
            user_sprig.userLike_Sprig.append(post_sprig)
            loggedUser_Sprig = user_sprig
            notifyStateChange_Sprig()
        }
    }
    
    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Sprig(post_sprig: TitleModel_Sprig) {
        guard let user_sprig = loggedUser_Sprig else { return }
        user_sprig.userLike_Sprig.removeAll { $0.titleId_Sprig == post_sprig.titleId_Sprig }
        loggedUser_Sprig = user_sprig
        notifyStateChange_Sprig()
    }
    
    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Sprig(post_sprig: TitleModel_Sprig) -> Bool {
        guard let user_sprig = loggedUser_Sprig else { return false }
        return user_sprig.userLike_Sprig.contains { $0.titleId_Sprig == post_sprig.titleId_Sprig }
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 发送状态更新通知
    private func notifyStateChange_Sprig() {
        NotificationCenter.default.post(
            name: UserViewModel_Sprig.userStateDidChangeNotification_Sprig,
            object: nil
        )
    }
    
    /// 显示登录提示
    private func showLoginPrompt_Sprig() {
       Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            Navigation_Sprig.toLogin_Sprig(style_sprig: .present_sprig)
        }
    }
}
