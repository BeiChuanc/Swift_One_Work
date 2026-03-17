import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Pane {
    
    /// Push方式（导航栈推入）
    case push_pane
    
    /// Present方式（模态展示）
    case present_pane

    /// Replace方式（替换当前视图控制器）
    case replace_pane
}

/// 页面导航管理器
class Navigation_Pane: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Pane() -> UIViewController? {
        return UIViewController.currentViewController_Pane()
    }
    
    /// Push方式跳转到指定页面
    static func push_Pane(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Pane()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Pane(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Pane()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Pane(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Pane()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Pane(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Pane()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Pane(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Pane()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Pane(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Pane()
        guard let navigationController_pane = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_pane = navigationController_pane.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_pane.isEmpty {
            viewControllers_pane[viewControllers_pane.count - 1] = viewController
            navigationController_pane.setViewControllers(viewControllers_pane, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_pane.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Pane(
        viewController_pane: UIViewController,
        style_pane: NavigationStyle_Pane,
        wrapInNavigation_pane: Bool? = nil,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_pane = wrapInNavigation_pane ?? (style_pane == .present_pane)
        
        switch style_pane {
        case .push_pane:
            push_Pane(to: viewController_pane, animated: animated_pane)
            completion_pane?()
            
        case .present_pane:
            let targetVC_pane = shouldWrapInNavigation_pane 
                ? createNavigationController_Pane(rootViewController: viewController_pane)
                : viewController_pane
            
            targetVC_pane.modalPresentationStyle = .fullScreen
            present_Pane(viewController: targetVC_pane, animated: animated_pane, completion: completion_pane)
            
        case .replace_pane:
            replace_Pane(to: viewController_pane, animated: animated_pane)
            completion_pane?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Pane(rootViewController: UIViewController) -> UINavigationController {
        let nav_pane = UINavigationController(rootViewController: rootViewController)
        nav_pane.modalPresentationStyle = .fullScreen
        return nav_pane
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Pane(
        to viewController_pane: UIViewController,
        style_pane: NavigationStyle_Pane,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        navigateToViewController_Pane(
            viewController_pane: viewController_pane,
            style_pane: style_pane,
            wrapInNavigation_pane: nil, // 使用智能判断
            animated_pane: animated_pane,
            completion_pane: completion_pane
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Pane(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Pane(window: UIWindow?) {
        guard let validWindow_pane = validateWindow_Pane(window) else { return }
        
        let tabbar_pane = TabBar_Pane()
        let nav_pane = UINavigationController(rootViewController: tabbar_pane)
        nav_pane.navigationBar.isHidden = true
        
        validWindow_pane.rootViewController = nav_pane
        validWindow_pane.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Pane(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_pane = validateWindow_Pane(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_pane, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_pane.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_pane.rootViewController = viewController
        }
        validWindow_pane.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Pane() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Pane(animated: Bool = true) {
        let window = getAppWindow_Pane()
        setRootToTabbar_Pane(window: window)
        
        if animated {
            // 添加淡入淡出动画
            window?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                window?.alpha = 1
            }
        }
    }
    
    // MARK: - 登录注册相关
    
    /// 跳转到登录页
    static func toLogin_Pane(
        style_pane: NavigationStyle_Pane = .present_pane,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        navigate_Pane(
            to: Login_Pane(),
            style_pane: style_pane,
            animated_pane: animated_pane,
            completion_pane: completion_pane
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Pane(
        style_pane: NavigationStyle_Pane = .present_pane,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        navigate_Pane(
            to: Register_Pane(),
            style_pane: style_pane,
            animated_pane: animated_pane,
            completion_pane: completion_pane
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: Home_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: Discover_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Pane(
        titleModel_pane: TitleModel_Pane,
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        let detailVC_pane = Detail_Pane()
        detailVC_pane.titleModel_Pane = titleModel_pane
        navigate_Pane(to: detailVC_pane, style_pane: style_pane, animated_pane: animated_pane)
    }

    /// 全屏展示媒体（沉浸式浏览页，支持缩放 / 下滑关闭）
    /// - Parameters:
    ///   - mediaPath_pane: 媒体路径（Assets 名 / URL / Documents 文件名 / 本地路径）
    ///   - isVideo_pane:   是否为视频类型（显示播放图标覆盖层）
    ///   - from_pane:      来源 VC，为 nil 时自动取当前顶层 VC
    static func toMediaPlayer_Pane(
        mediaPath_pane: String?,
        isVideo_pane: Bool = false,
        from_pane: UIViewController? = nil
    ) {
        let player_pane            = MediaPlayerPage_Pane()
        player_pane.mediaPath_Pane = mediaPath_pane
        player_pane.isVideo_Pane   = isVideo_pane
        player_pane.modalPresentationStyle = .overFullScreen
        player_pane.modalTransitionStyle   = .crossDissolve
        let fromVC_pane = from_pane ?? currentViewController_Pane()
        fromVC_pane?.present(player_pane, animated: false)
    }

    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Pane(
        style_pane: NavigationStyle_Pane = .present_pane,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        navigate_Pane(
            to: Release_Pane(),
            style_pane: style_pane,
            animated_pane: animated_pane,
            completion_pane: completion_pane
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: MessageList_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Pane(
        with userModel_pane: PrewUserModel_Pane,
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        let messageUserVC_pane = MessageUser_Pane()
        messageUserVC_pane.userModel_Pane = userModel_pane
        navigate_Pane(
            to: messageUserVC_pane,
            style_pane: style_pane,
            animated_pane: animated_pane,
            completion_pane: completion_pane
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: Me_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Pane(
        with userModel_pane: LoginUserModel_Pane,
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        let meVC_pane = Me_Pane()
        meVC_pane.meModel_Pane = userModel_pane
        navigate_Pane(to: meVC_pane, style_pane: style_pane, animated_pane: animated_pane)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Pane(
        with userModel_pane: PrewUserModel_Pane,
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true,
        completion_pane: (() -> Void)? = nil
    ) {
        let userInfoVC_pane = UserInfo_Pane()
        userInfoVC_pane.userModel_Pane = userModel_pane
        navigate_Pane(
            to: userInfoVC_pane,
            style_pane: style_pane,
            animated_pane: animated_pane,
            completion_pane: completion_pane
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: EditInfo_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }
    
    /// 跳转到设置页
    static func toSetting_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: Setting_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }

    /// 跳转到 VIP 订阅页
    static func toVIPSubscription_Pane(
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: VIPSubscription_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }

    /// 跳转到每日打卡页（默认模态弹出）
    static func toCheckIn_Pane(
        style_pane: NavigationStyle_Pane = .present_pane,
        animated_pane: Bool = true
    ) {
        navigate_Pane(to: CheckIn_Pane(), style_pane: style_pane, animated_pane: animated_pane)
    }

    /// 跳转到窗景册详情页
    /// - Parameters:
    ///   - album_pane: 目标窗景册对象
    ///   - style_pane: 导航方式，默认 Push
    static func toAlbum_Pane(
        album_pane: WindowAlbum_Pane,
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        let albumVC_pane = Album_Pane()
        albumVC_pane.album_Pane = album_pane
        navigate_Pane(to: albumVC_pane, style_pane: style_pane, animated_pane: animated_pane)
    }
    
    // MARK: - 枚举导航方法
    
    /// 根据导航类型枚举跳转
    static func navigateByType_Pane(
        to type_pane: NavigationType_Pane,
        style_pane: NavigationStyle_Pane = .push_pane,
        animated_pane: Bool = true
    ) {
        switch type_pane {
        case .home:
            toHome_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .discover:
            toDiscover_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .release:
            toRelease_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .messageList:
            toMessageList_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .me:
            toMe_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .editInfo:
            toEditInfo_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .setting:
            toSetting_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .login:
            toLogin_Pane(style_pane: style_pane, animated_pane: animated_pane)
        case .register:
            toRegister_Pane(style_pane: style_pane, animated_pane: animated_pane)
        }
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Pane {
    /// 首页
    case home
    /// 发现页
    case discover
    /// 发布页
    case release
    /// 消息列表
    case messageList
    /// 个人中心
    case me
    /// 编辑信息
    case editInfo
    /// 设置
    case setting
    /// 登录
    case login
    /// 注册
    case register
}
