import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Glasspaint {
    
    /// Push方式（导航栈推入）
    case push_glasspaint
    
    /// Present方式（模态展示）
    case present_glasspaint

    /// Replace方式（替换当前视图控制器）
    case replace_glasspaint
}

/// 页面导航管理器
class Navigation_Glasspaint: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Glasspaint() -> UIViewController? {
        return UIViewController.currentViewController_Glasspaint()
    }
    
    /// Push方式跳转到指定页面
    static func push_Glasspaint(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Glasspaint()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Glasspaint(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Glasspaint()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Glasspaint(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Glasspaint()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Glasspaint(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Glasspaint()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Glasspaint(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Glasspaint()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Glasspaint(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Glasspaint()
        guard let navigationController_glasspaint = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_glasspaint = navigationController_glasspaint.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_glasspaint.isEmpty {
            viewControllers_glasspaint[viewControllers_glasspaint.count - 1] = viewController
            navigationController_glasspaint.setViewControllers(viewControllers_glasspaint, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_glasspaint.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Glasspaint(
        viewController_glasspaint: UIViewController,
        style_glasspaint: NavigationStyle_Glasspaint,
        wrapInNavigation_glasspaint: Bool? = nil,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_glasspaint = wrapInNavigation_glasspaint ?? (style_glasspaint == .present_glasspaint)
        
        switch style_glasspaint {
        case .push_glasspaint:
            push_Glasspaint(to: viewController_glasspaint, animated: animated_glasspaint)
            completion_glasspaint?()
            
        case .present_glasspaint:
            let targetVC_glasspaint = shouldWrapInNavigation_glasspaint 
                ? createNavigationController_Glasspaint(rootViewController: viewController_glasspaint)
                : viewController_glasspaint
            
            targetVC_glasspaint.modalPresentationStyle = .fullScreen
            present_Glasspaint(viewController: targetVC_glasspaint, animated: animated_glasspaint, completion: completion_glasspaint)
            
        case .replace_glasspaint:
            replace_Glasspaint(to: viewController_glasspaint, animated: animated_glasspaint)
            completion_glasspaint?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Glasspaint(rootViewController: UIViewController) -> UINavigationController {
        let nav_glasspaint = UINavigationController(rootViewController: rootViewController)
        nav_glasspaint.modalPresentationStyle = .fullScreen
        return nav_glasspaint
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Glasspaint(
        to viewController_glasspaint: UIViewController,
        style_glasspaint: NavigationStyle_Glasspaint,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        navigateToViewController_Glasspaint(
            viewController_glasspaint: viewController_glasspaint,
            style_glasspaint: style_glasspaint,
            wrapInNavigation_glasspaint: nil, // 使用智能判断
            animated_glasspaint: animated_glasspaint,
            completion_glasspaint: completion_glasspaint
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Glasspaint(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Glasspaint(window: UIWindow?) {
        guard let validWindow_glasspaint = validateWindow_Glasspaint(window) else { return }
        
        let tabbar_glasspaint = TabBar_Glasspaint()
        let nav_glasspaint = UINavigationController(rootViewController: tabbar_glasspaint)
        nav_glasspaint.navigationBar.isHidden = true
        
        validWindow_glasspaint.rootViewController = nav_glasspaint
        validWindow_glasspaint.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Glasspaint(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_glasspaint = validateWindow_Glasspaint(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_glasspaint, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_glasspaint.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_glasspaint.rootViewController = viewController
        }
        validWindow_glasspaint.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Glasspaint() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Glasspaint(animated: Bool = true) {
        let window = getAppWindow_Glasspaint()
        setRootToTabbar_Glasspaint(window: window)
        
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
    static func toLogin_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .present_glasspaint,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        navigate_Glasspaint(
            to: Login_Glasspaint(),
            style_glasspaint: style_glasspaint,
            animated_glasspaint: animated_glasspaint,
            completion_glasspaint: completion_glasspaint
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .present_glasspaint,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        navigate_Glasspaint(
            to: Register_Glasspaint(),
            style_glasspaint: style_glasspaint,
            animated_glasspaint: animated_glasspaint,
            completion_glasspaint: completion_glasspaint
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        navigate_Glasspaint(to: Home_Glasspaint(), style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        navigate_Glasspaint(to: Discover_Glasspaint(), style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Glasspaint(
        titleModel_glasspaint: TitleModel_Glasspaint,
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        let detailVC_glasspaint = Detail_Glasspaint()
        detailVC_glasspaint.titleModel_Glasspaint = titleModel_glasspaint
        navigate_Glasspaint(to: detailVC_glasspaint, style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .present_glasspaint,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        navigate_Glasspaint(
            to: Release_Glasspaint(),
            style_glasspaint: style_glasspaint,
            animated_glasspaint: animated_glasspaint,
            completion_glasspaint: completion_glasspaint
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        navigate_Glasspaint(to: MessageList_Glasspaint(), style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Glasspaint(
        with userModel_glasspaint: PrewUserModel_Glasspaint,
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        let messageUserVC_glasspaint = MessageUser_Glasspaint()
        messageUserVC_glasspaint.userModel_Glasspaint = userModel_glasspaint
        navigate_Glasspaint(
            to: messageUserVC_glasspaint,
            style_glasspaint: style_glasspaint,
            animated_glasspaint: animated_glasspaint,
            completion_glasspaint: completion_glasspaint
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        navigate_Glasspaint(to: Me_Glasspaint(), style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Glasspaint(
        with userModel_glasspaint: LoginUserModel_Glasspaint,
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        let meVC_glasspaint = Me_Glasspaint()
        meVC_glasspaint.meModel_Glasspaint = userModel_glasspaint
        navigate_Glasspaint(to: meVC_glasspaint, style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Glasspaint(
        with userModel_glasspaint: PrewUserModel_Glasspaint,
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true,
        completion_glasspaint: (() -> Void)? = nil
    ) {
        let userInfoVC_glasspaint = UserInfo_Glasspaint()
        userInfoVC_glasspaint.userModel_Glasspaint = userModel_glasspaint
        navigate_Glasspaint(
            to: userInfoVC_glasspaint,
            style_glasspaint: style_glasspaint,
            animated_glasspaint: animated_glasspaint,
            completion_glasspaint: completion_glasspaint
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        navigate_Glasspaint(to: EditInfo_Glasspaint(), style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    /// 跳转到设置页
    static func toSetting_Glasspaint(
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        navigate_Glasspaint(to: Setting_Glasspaint(), style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
    }
    
    // MARK: - 枚举导航方法
    
    /// 根据导航类型枚举跳转
    static func navigateByType_Glasspaint(
        to type_glasspaint: NavigationType_Glasspaint,
        style_glasspaint: NavigationStyle_Glasspaint = .push_glasspaint,
        animated_glasspaint: Bool = true
    ) {
        switch type_glasspaint {
        case .home:
            toHome_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .discover:
            toDiscover_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .release:
            toRelease_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .messageList:
            toMessageList_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .me:
            toMe_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .editInfo:
            toEditInfo_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .setting:
            toSetting_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .login:
            toLogin_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        case .register:
            toRegister_Glasspaint(style_glasspaint: style_glasspaint, animated_glasspaint: animated_glasspaint)
        }
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Glasspaint {
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
