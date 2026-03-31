import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Flick {
    
    /// Push方式（导航栈推入）
    case push_flick
    
    /// Present方式（模态展示）
    case present_flick

    /// Replace方式（替换当前视图控制器）
    case replace_flick
}

/// 页面导航管理器
class Navigation_Flick: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Flick() -> UIViewController? {
        return UIViewController.currentViewController_Flick()
    }
    
    /// Push方式跳转到指定页面
    static func push_Flick(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Flick()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Flick(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Flick()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Flick(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Flick()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Flick(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Flick()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Flick(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Flick()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Flick(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Flick()
        guard let navigationController_flick = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_flick = navigationController_flick.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_flick.isEmpty {
            viewControllers_flick[viewControllers_flick.count - 1] = viewController
            navigationController_flick.setViewControllers(viewControllers_flick, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_flick.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Flick(
        viewController_flick: UIViewController,
        style_flick: NavigationStyle_Flick,
        wrapInNavigation_flick: Bool? = nil,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_flick = wrapInNavigation_flick ?? (style_flick == .present_flick)
        
        switch style_flick {
        case .push_flick:
            push_Flick(to: viewController_flick, animated: animated_flick)
            completion_flick?()
            
        case .present_flick:
            let targetVC_flick = shouldWrapInNavigation_flick 
                ? createNavigationController_Flick(rootViewController: viewController_flick)
                : viewController_flick
            
            targetVC_flick.modalPresentationStyle = .fullScreen
            present_Flick(viewController: targetVC_flick, animated: animated_flick, completion: completion_flick)
            
        case .replace_flick:
            replace_Flick(to: viewController_flick, animated: animated_flick)
            completion_flick?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Flick(rootViewController: UIViewController) -> UINavigationController {
        let nav_flick = UINavigationController(rootViewController: rootViewController)
        nav_flick.modalPresentationStyle = .fullScreen
        return nav_flick
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Flick(
        to viewController_flick: UIViewController,
        style_flick: NavigationStyle_Flick,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        navigateToViewController_Flick(
            viewController_flick: viewController_flick,
            style_flick: style_flick,
            wrapInNavigation_flick: nil, // 使用智能判断
            animated_flick: animated_flick,
            completion_flick: completion_flick
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Flick(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Flick(window: UIWindow?) {
        guard let validWindow_flick = validateWindow_Flick(window) else { return }
        
        let tabbar_flick = TabBar_Flick()
        let nav_flick = UINavigationController(rootViewController: tabbar_flick)
        nav_flick.navigationBar.isHidden = true
        
        validWindow_flick.rootViewController = nav_flick
        validWindow_flick.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Flick(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_flick = validateWindow_Flick(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_flick, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_flick.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_flick.rootViewController = viewController
        }
        validWindow_flick.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Flick() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Flick(animated: Bool = true) {
        let window = getAppWindow_Flick()
        setRootToTabbar_Flick(window: window)
        
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
    static func toLogin_Flick(
        style_flick: NavigationStyle_Flick = .present_flick,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        navigate_Flick(
            to: Login_Flick(),
            style_flick: style_flick,
            animated_flick: animated_flick,
            completion_flick: completion_flick
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Flick(
        style_flick: NavigationStyle_Flick = .present_flick,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        navigate_Flick(
            to: Register_Flick(),
            style_flick: style_flick,
            animated_flick: animated_flick,
            completion_flick: completion_flick
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Flick(
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        navigate_Flick(to: Home_Flick(), style_flick: style_flick, animated_flick: animated_flick)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Flick(
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        navigate_Flick(to: Discover_Flick(), style_flick: style_flick, animated_flick: animated_flick)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Flick(
        titleModel_flick: TitleModel_Flick,
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        let detailVC_flick = Detail_Flick()
        detailVC_flick.titleModel_Flick = titleModel_flick
        navigate_Flick(to: detailVC_flick, style_flick: style_flick, animated_flick: animated_flick)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Flick(
        style_flick: NavigationStyle_Flick = .present_flick,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        navigate_Flick(
            to: Release_Flick(),
            style_flick: style_flick,
            animated_flick: animated_flick,
            completion_flick: completion_flick
        )
    }
    
    // MARK: - 视频通话相关

    /// 跳转到视频通话页面
    /// - Parameters:
    ///   - userModel_flick: 通话对象用户模型
    ///   - style_flick: 导航方式，默认 present
    ///   - animated_flick: 是否开启动画
    static func toVideoChat_Flick(
        with userModel_flick: PrewUserModel_Flick,
        style_flick: NavigationStyle_Flick = .present_flick,
        animated_flick: Bool = true
    ) {
        let videoChatVC_flick = VideoChat_Flick()
        videoChatVC_flick.userModel_Flick = userModel_flick
        navigate_Flick(
            to: videoChatVC_flick,
            style_flick: style_flick,
            animated_flick: animated_flick
        )
    }

    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Flick(
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        navigate_Flick(to: MessageList_Flick(), style_flick: style_flick, animated_flick: animated_flick)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Flick(
        with userModel_flick: PrewUserModel_Flick,
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        let messageUserVC_flick = MessageUser_Flick()
        messageUserVC_flick.userModel_Flick = userModel_flick
        navigate_Flick(
            to: messageUserVC_flick,
            style_flick: style_flick,
            animated_flick: animated_flick,
            completion_flick: completion_flick
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Flick(
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        navigate_Flick(to: Me_Flick(), style_flick: style_flick, animated_flick: animated_flick)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Flick(
        with userModel_flick: LoginUserModel_Flick,
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        let meVC_flick = Me_Flick()
        meVC_flick.meModel_Flick = userModel_flick
        navigate_Flick(to: meVC_flick, style_flick: style_flick, animated_flick: animated_flick)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Flick(
        with userModel_flick: PrewUserModel_Flick,
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true,
        completion_flick: (() -> Void)? = nil
    ) {
        let userInfoVC_flick = UserInfo_Flick()
        userInfoVC_flick.userModel_Flick = userModel_flick
        navigate_Flick(
            to: userInfoVC_flick,
            style_flick: style_flick,
            animated_flick: animated_flick,
            completion_flick: completion_flick
        )
    }
    
    /// 跳转到半截碎念挑战详情页
    static func toChallengeDetail_Flick(
        with challenge_flick: HalfChallenge_Flick,
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        let vc_flick = ChallengeDetail_Flick()
        vc_flick.challenge_Flick = challenge_flick
        navigate_Flick(to: vc_flick, style_flick: style_flick, animated_flick: animated_flick)
    }

    /// 跳转到编辑信息页
    static func toEditInfo_Flick(
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        navigate_Flick(to: EditInfo_Flick(), style_flick: style_flick, animated_flick: animated_flick)
    }
    
    /// 跳转到设置页
    static func toSetting_Flick(
        style_flick: NavigationStyle_Flick = .push_flick,
        animated_flick: Bool = true
    ) {
        navigate_Flick(to: Setting_Flick(), style_flick: style_flick, animated_flick: animated_flick)
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Flick {
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
