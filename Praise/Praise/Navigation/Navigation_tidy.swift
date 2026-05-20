import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Tidy {
    
    /// Push方式（导航栈推入）
    case push_tidy
    
    /// Present方式（模态展示）
    case present_tidy

    /// Replace方式（替换当前视图控制器）
    case replace_tidy
}

/// 页面导航管理器
class Navigation_Tidy: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Tidy() -> UIViewController? {
        return UIViewController.currentViewController_Tidy()
    }
    
    /// Push方式跳转到指定页面
    static func push_Tidy(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Tidy()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Tidy(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Tidy()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Tidy(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Tidy()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Tidy(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Tidy()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Tidy(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Tidy()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Tidy(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Tidy()
        guard let navigationController_tidy = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_tidy = navigationController_tidy.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_tidy.isEmpty {
            viewControllers_tidy[viewControllers_tidy.count - 1] = viewController
            navigationController_tidy.setViewControllers(viewControllers_tidy, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_tidy.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Tidy(
        viewController_tidy: UIViewController,
        style_tidy: NavigationStyle_Tidy,
        wrapInNavigation_tidy: Bool? = nil,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_tidy = wrapInNavigation_tidy ?? (style_tidy == .present_tidy)
        
        switch style_tidy {
        case .push_tidy:
            push_Tidy(to: viewController_tidy, animated: animated_tidy)
            completion_tidy?()
            
        case .present_tidy:
            let targetVC_tidy = shouldWrapInNavigation_tidy 
                ? createNavigationController_Tidy(rootViewController: viewController_tidy)
                : viewController_tidy
            
            targetVC_tidy.modalPresentationStyle = .fullScreen
            present_Tidy(viewController: targetVC_tidy, animated: animated_tidy, completion: completion_tidy)
            
        case .replace_tidy:
            replace_Tidy(to: viewController_tidy, animated: animated_tidy)
            completion_tidy?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Tidy(rootViewController: UIViewController) -> UINavigationController {
        let nav_tidy = UINavigationController(rootViewController: rootViewController)
        nav_tidy.modalPresentationStyle = .fullScreen
        return nav_tidy
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Tidy(
        to viewController_tidy: UIViewController,
        style_tidy: NavigationStyle_Tidy,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        navigateToViewController_Tidy(
            viewController_tidy: viewController_tidy,
            style_tidy: style_tidy,
            wrapInNavigation_tidy: nil, // 使用智能判断
            animated_tidy: animated_tidy,
            completion_tidy: completion_tidy
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Tidy(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Tidy(window: UIWindow?) {
        guard let validWindow_tidy = validateWindow_Tidy(window) else { return }
        
        let tabbar_tidy = TabBar_Tidy()
        let nav_tidy = UINavigationController(rootViewController: tabbar_tidy)
        // 使用 setNavigationBarHidden 而非直接赋值，保证内部状态一致
        nav_tidy.setNavigationBarHidden(true, animated: false)
        
        validWindow_tidy.rootViewController = nav_tidy
        validWindow_tidy.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Tidy(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_tidy = validateWindow_Tidy(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_tidy, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_tidy.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_tidy.rootViewController = viewController
        }
        validWindow_tidy.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Tidy() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Tidy(animated: Bool = true) {
        let window = getAppWindow_Tidy()
        setRootToTabbar_Tidy(window: window)
        
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
    static func toLogin_Tidy(
        style_tidy: NavigationStyle_Tidy = .present_tidy,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        navigate_Tidy(
            to: Login_Tidy(),
            style_tidy: style_tidy,
            animated_tidy: animated_tidy,
            completion_tidy: completion_tidy
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Tidy(
        style_tidy: NavigationStyle_Tidy = .present_tidy,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        navigate_Tidy(
            to: Register_Tidy(),
            style_tidy: style_tidy,
            animated_tidy: animated_tidy,
            completion_tidy: completion_tidy
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: Home_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: Discover_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Tidy(
        titleModel_tidy: TitleModel_Tidy,
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        let detailVC_tidy = Detail_Tidy()
        detailVC_tidy.titleModel_Tidy = titleModel_tidy
        navigate_Tidy(to: detailVC_tidy, style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Tidy(
        style_tidy: NavigationStyle_Tidy = .present_tidy,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        navigate_Tidy(
            to: Release_Tidy(),
            style_tidy: style_tidy,
            animated_tidy: animated_tidy,
            completion_tidy: completion_tidy
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: MessageList_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Tidy(
        with userModel_tidy: PrewUserModel_Tidy,
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        let messageUserVC_tidy = MessageUser_Tidy()
        messageUserVC_tidy.userModel_Tidy = userModel_tidy
        navigate_Tidy(
            to: messageUserVC_tidy,
            style_tidy: style_tidy,
            animated_tidy: animated_tidy,
            completion_tidy: completion_tidy
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: Me_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Tidy(
        with userModel_tidy: LoginUserModel_Tidy,
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        let meVC_tidy = Me_Tidy()
        meVC_tidy.meModel_Tidy = userModel_tidy
        navigate_Tidy(to: meVC_tidy, style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Tidy(
        with userModel_tidy: PrewUserModel_Tidy,
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true,
        completion_tidy: (() -> Void)? = nil
    ) {
        let userInfoVC_tidy = UserInfo_Tidy()
        userInfoVC_tidy.userModel_Tidy = userModel_tidy
        navigate_Tidy(
            to: userInfoVC_tidy,
            style_tidy: style_tidy,
            animated_tidy: animated_tidy,
            completion_tidy: completion_tidy
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: EditInfo_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
    
    /// 跳转到设置页
    static func toSetting_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: Setting_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }

    /// 跳转到 VIP 订阅页
    static func toVIPSubscription_Tidy(
        style_tidy: NavigationStyle_Tidy = .push_tidy,
        animated_tidy: Bool = true
    ) {
        navigate_Tidy(to: VIPSubscription_Tidy(), style_tidy: style_tidy, animated_tidy: animated_tidy)
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Tidy {
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
