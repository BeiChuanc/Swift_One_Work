import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Doze {
    
    /// Push方式（导航栈推入）
    case push_doze
    
    /// Present方式（模态展示）
    case present_doze

    /// Replace方式（替换当前视图控制器）
    case replace_doze
}

/// 页面导航管理器
class Navigation_Doze: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Doze() -> UIViewController? {
        return UIViewController.currentViewController_Doze()
    }
    
    /// Push方式跳转到指定页面
    static func push_Doze(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Doze()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Doze(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Doze()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Doze(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Doze()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Doze(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Doze()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Doze(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Doze()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Doze(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Doze()
        guard let navigationController_doze = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_doze = navigationController_doze.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_doze.isEmpty {
            viewControllers_doze[viewControllers_doze.count - 1] = viewController
            navigationController_doze.setViewControllers(viewControllers_doze, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_doze.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Doze(
        viewController_doze: UIViewController,
        style_doze: NavigationStyle_Doze,
        wrapInNavigation_doze: Bool? = nil,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_doze = wrapInNavigation_doze ?? (style_doze == .present_doze)
        
        switch style_doze {
        case .push_doze:
            push_Doze(to: viewController_doze, animated: animated_doze)
            completion_doze?()
            
        case .present_doze:
            let targetVC_doze = shouldWrapInNavigation_doze 
                ? createNavigationController_Doze(rootViewController: viewController_doze)
                : viewController_doze
            
            targetVC_doze.modalPresentationStyle = .fullScreen
            present_Doze(viewController: targetVC_doze, animated: animated_doze, completion: completion_doze)
            
        case .replace_doze:
            replace_Doze(to: viewController_doze, animated: animated_doze)
            completion_doze?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Doze(rootViewController: UIViewController) -> UINavigationController {
        let nav_doze = UINavigationController(rootViewController: rootViewController)
        nav_doze.modalPresentationStyle = .fullScreen
        return nav_doze
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Doze(
        to viewController_doze: UIViewController,
        style_doze: NavigationStyle_Doze,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        navigateToViewController_Doze(
            viewController_doze: viewController_doze,
            style_doze: style_doze,
            wrapInNavigation_doze: nil, // 使用智能判断
            animated_doze: animated_doze,
            completion_doze: completion_doze
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Doze(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Doze(window: UIWindow?) {
        guard let validWindow_doze = validateWindow_Doze(window) else { return }
        
        let tabbar_doze = TabBar_Doze()
        let nav_doze = UINavigationController(rootViewController: tabbar_doze)
        nav_doze.navigationBar.isHidden = true
        
        validWindow_doze.rootViewController = nav_doze
        validWindow_doze.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Doze(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_doze = validateWindow_Doze(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_doze, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_doze.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_doze.rootViewController = viewController
        }
        validWindow_doze.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Doze() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Doze(animated: Bool = true) {
        let window = getAppWindow_Doze()
        setRootToTabbar_Doze(window: window)
        
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
    static func toLogin_Doze(
        style_doze: NavigationStyle_Doze = .present_doze,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        navigate_Doze(
            to: Login_Doze(),
            style_doze: style_doze,
            animated_doze: animated_doze,
            completion_doze: completion_doze
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Doze(
        style_doze: NavigationStyle_Doze = .present_doze,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        navigate_Doze(
            to: Register_Doze(),
            style_doze: style_doze,
            animated_doze: animated_doze,
            completion_doze: completion_doze
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Doze(
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        navigate_Doze(to: Home_Doze(), style_doze: style_doze, animated_doze: animated_doze)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Doze(
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        navigate_Doze(to: Discover_Doze(), style_doze: style_doze, animated_doze: animated_doze)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Doze(
        titleModel_doze: TitleModel_Doze,
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        let detailVC_doze = Detail_Doze()
        detailVC_doze.titleModel_Doze = titleModel_doze
        navigate_Doze(to: detailVC_doze, style_doze: style_doze, animated_doze: animated_doze)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Doze(
        style_doze: NavigationStyle_Doze = .present_doze,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        navigate_Doze(
            to: Release_Doze(),
            style_doze: style_doze,
            animated_doze: animated_doze,
            completion_doze: completion_doze
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Doze(
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        navigate_Doze(to: MessageList_Doze(), style_doze: style_doze, animated_doze: animated_doze)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Doze(
        with userModel_doze: PrewUserModel_Doze,
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        let messageUserVC_doze = MessageUser_Doze()
        messageUserVC_doze.userModel_Doze = userModel_doze
        navigate_Doze(
            to: messageUserVC_doze,
            style_doze: style_doze,
            animated_doze: animated_doze,
            completion_doze: completion_doze
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Doze(
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        navigate_Doze(to: Me_Doze(), style_doze: style_doze, animated_doze: animated_doze)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Doze(
        with userModel_doze: LoginUserModel_Doze,
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        let meVC_doze = Me_Doze()
        meVC_doze.meModel_Doze = userModel_doze
        navigate_Doze(to: meVC_doze, style_doze: style_doze, animated_doze: animated_doze)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Doze(
        with userModel_doze: PrewUserModel_Doze,
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true,
        completion_doze: (() -> Void)? = nil
    ) {
        let userInfoVC_doze = UserInfo_Doze()
        userInfoVC_doze.userModel_Doze = userModel_doze
        navigate_Doze(
            to: userInfoVC_doze,
            style_doze: style_doze,
            animated_doze: animated_doze,
            completion_doze: completion_doze
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Doze(
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        navigate_Doze(to: EditInfo_Doze(), style_doze: style_doze, animated_doze: animated_doze)
    }
    
    /// 跳转到设置页
    static func toSetting_Doze(
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        navigate_Doze(to: Setting_Doze(), style_doze: style_doze, animated_doze: animated_doze)
    }
    
    // MARK: - 枚举导航方法
    
    /// 根据导航类型枚举跳转
    static func navigateByType_Doze(
        to type_doze: NavigationType_Doze,
        style_doze: NavigationStyle_Doze = .push_doze,
        animated_doze: Bool = true
    ) {
        switch type_doze {
        case .home:
            toHome_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .discover:
            toDiscover_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .release:
            toRelease_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .messageList:
            toMessageList_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .me:
            toMe_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .editInfo:
            toEditInfo_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .setting:
            toSetting_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .login:
            toLogin_Doze(style_doze: style_doze, animated_doze: animated_doze)
        case .register:
            toRegister_Doze(style_doze: style_doze, animated_doze: animated_doze)
        }
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Doze {
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
