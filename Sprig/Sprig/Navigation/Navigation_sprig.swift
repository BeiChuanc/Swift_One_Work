import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Sprig {
    
    /// Push方式（导航栈推入）
    case push_sprig
    
    /// Present方式（模态展示）
    case present_sprig

    /// Replace方式（替换当前视图控制器）
    case replace_sprig
}

/// 页面导航管理器
class Navigation_Sprig: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Sprig() -> UIViewController? {
        return UIViewController.currentViewController_Sprig()
    }
    
    /// Push方式跳转到指定页面
    static func push_Sprig(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sprig()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Sprig(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sprig()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Sprig(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sprig()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Sprig(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sprig()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Sprig(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sprig()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Sprig(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sprig()
        guard let navigationController_sprig = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_sprig = navigationController_sprig.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_sprig.isEmpty {
            viewControllers_sprig[viewControllers_sprig.count - 1] = viewController
            navigationController_sprig.setViewControllers(viewControllers_sprig, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_sprig.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Sprig(
        viewController_sprig: UIViewController,
        style_sprig: NavigationStyle_Sprig,
        wrapInNavigation_sprig: Bool? = nil,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_sprig = wrapInNavigation_sprig ?? (style_sprig == .present_sprig)
        
        switch style_sprig {
        case .push_sprig:
            push_Sprig(to: viewController_sprig, animated: animated_sprig)
            completion_sprig?()
            
        case .present_sprig:
            let targetVC_sprig = shouldWrapInNavigation_sprig 
                ? createNavigationController_Sprig(rootViewController: viewController_sprig)
                : viewController_sprig
            
            targetVC_sprig.modalPresentationStyle = .fullScreen
            present_Sprig(viewController: targetVC_sprig, animated: animated_sprig, completion: completion_sprig)
            
        case .replace_sprig:
            replace_Sprig(to: viewController_sprig, animated: animated_sprig)
            completion_sprig?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Sprig(rootViewController: UIViewController) -> UINavigationController {
        let nav_sprig = UINavigationController(rootViewController: rootViewController)
        nav_sprig.modalPresentationStyle = .fullScreen
        return nav_sprig
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Sprig(
        to viewController_sprig: UIViewController,
        style_sprig: NavigationStyle_Sprig,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        navigateToViewController_Sprig(
            viewController_sprig: viewController_sprig,
            style_sprig: style_sprig,
            wrapInNavigation_sprig: nil, // 使用智能判断
            animated_sprig: animated_sprig,
            completion_sprig: completion_sprig
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Sprig(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Sprig(window: UIWindow?) {
        guard let validWindow_sprig = validateWindow_Sprig(window) else { return }
        
        let tabbar_sprig = TabBar_Sprig()
        let nav_sprig = UINavigationController(rootViewController: tabbar_sprig)
        nav_sprig.navigationBar.isHidden = true
        
        validWindow_sprig.rootViewController = nav_sprig
        validWindow_sprig.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Sprig(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_sprig = validateWindow_Sprig(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_sprig, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_sprig.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_sprig.rootViewController = viewController
        }
        validWindow_sprig.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Sprig() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Sprig(animated: Bool = true) {
        let window = getAppWindow_Sprig()
        setRootToTabbar_Sprig(window: window)
        
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
    static func toLogin_Sprig(
        style_sprig: NavigationStyle_Sprig = .present_sprig,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        navigate_Sprig(
            to: Login_Sprig(),
            style_sprig: style_sprig,
            animated_sprig: animated_sprig,
            completion_sprig: completion_sprig
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Sprig(
        style_sprig: NavigationStyle_Sprig = .present_sprig,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        navigate_Sprig(
            to: Register_Sprig(),
            style_sprig: style_sprig,
            animated_sprig: animated_sprig,
            completion_sprig: completion_sprig
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Sprig(
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        navigate_Sprig(to: Home_Sprig(), style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Sprig(
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        navigate_Sprig(to: Discover_Sprig(), style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Sprig(
        titleModel_sprig: TitleModel_Sprig,
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        let detailVC_sprig = Detail_Sprig()
        detailVC_sprig.titleModel_Sprig = titleModel_sprig
        navigate_Sprig(to: detailVC_sprig, style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Sprig(
        style_sprig: NavigationStyle_Sprig = .present_sprig,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        navigate_Sprig(
            to: Release_Sprig(),
            style_sprig: style_sprig,
            animated_sprig: animated_sprig,
            completion_sprig: completion_sprig
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Sprig(
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        navigate_Sprig(to: MessageList_Sprig(), style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Sprig(
        with userModel_sprig: PrewUserModel_Sprig,
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        let messageUserVC_sprig = MessageUser_Sprig()
        messageUserVC_sprig.userModel_Sprig = userModel_sprig
        navigate_Sprig(
            to: messageUserVC_sprig,
            style_sprig: style_sprig,
            animated_sprig: animated_sprig,
            completion_sprig: completion_sprig
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Sprig(
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        navigate_Sprig(to: Me_Sprig(), style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Sprig(
        with userModel_sprig: LoginUserModel_Sprig,
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        let meVC_sprig = Me_Sprig()
        meVC_sprig.meModel_Sprig = userModel_sprig
        navigate_Sprig(to: meVC_sprig, style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Sprig(
        with userModel_sprig: PrewUserModel_Sprig,
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true,
        completion_sprig: (() -> Void)? = nil
    ) {
        let userInfoVC_sprig = UserInfo_Sprig()
        userInfoVC_sprig.userModel_Sprig = userModel_sprig
        navigate_Sprig(
            to: userInfoVC_sprig,
            style_sprig: style_sprig,
            animated_sprig: animated_sprig,
            completion_sprig: completion_sprig
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Sprig(
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        navigate_Sprig(to: EditInfo_Sprig(), style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
    
    /// 跳转到设置页
    static func toSetting_Sprig(
        style_sprig: NavigationStyle_Sprig = .push_sprig,
        animated_sprig: Bool = true
    ) {
        navigate_Sprig(to: Setting_Sprig(), style_sprig: style_sprig, animated_sprig: animated_sprig)
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Sprig {
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
