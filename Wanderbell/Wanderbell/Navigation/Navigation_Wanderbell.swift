import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Wanderbell {
    
    /// Push方式（导航栈推入）
    case push_wanderbell
    
    /// Present方式（模态展示）
    case present_wanderbell
}

/// 页面导航管理器
class Navigation_Wanderbell: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Wanderbell() -> UIViewController? {
        return UIViewController.currentViewController_Wanderbell()
    }
    
    /// Push方式跳转到指定页面
    static func push_Wanderbell(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Wanderbell()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Wanderbell(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Wanderbell()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Wanderbell(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Wanderbell()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Wanderbell(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Wanderbell()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Wanderbell(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Wanderbell()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Wanderbell(
        viewController_wanderbell: UIViewController,
        style_wanderbell: NavigationStyle_Wanderbell,
        wrapInNavigation_wanderbell: Bool = true,
        animated_wanderbell: Bool = true,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        switch style_wanderbell {
        case .push_wanderbell:
            push_Wanderbell(to: viewController_wanderbell, animated: animated_wanderbell)
            
        case .present_wanderbell:
            if wrapInNavigation_wanderbell {
                let nav_wanderbell = UINavigationController(rootViewController: viewController_wanderbell)
                nav_wanderbell.modalPresentationStyle = .fullScreen
                present_Wanderbell(viewController: nav_wanderbell, animated: animated_wanderbell, completion: completion_wanderbell)
            } else {
                viewController_wanderbell.modalPresentationStyle = .fullScreen
                present_Wanderbell(viewController: viewController_wanderbell, animated: animated_wanderbell, completion: completion_wanderbell)
            }
        }
    }
    
    // MARK: - 主导航
    static func setRootToTabbar_Wanderbell(window: UIWindow?) {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return
        }
        
        let tabbar = TabBar_Wanderbell()
        let nav = UINavigationController(rootViewController: tabbar)
        nav.navigationBar.isHidden = true
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Wanderbell(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return
        }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = viewController
            }, completion: nil)
        } else {
            window.rootViewController = viewController
        }
        window.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Wanderbell() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Wanderbell(animated: Bool = true) {
        let window = getAppWindow_Wanderbell()
        setRootToTabbar_Wanderbell(window: window)
        
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
    static func toLogin_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .present_wanderbell,
        animated_wanderbell: Bool = true,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        let loginVC = Login_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: loginVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: true,
            animated_wanderbell: animated_wanderbell,
            completion_wanderbell: completion_wanderbell
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .present_wanderbell,
        animated_wanderbell: Bool = true,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        let registerVC = Register_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: registerVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: true,
            animated_wanderbell: animated_wanderbell,
            completion_wanderbell: completion_wanderbell
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let homeVC = Home_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: homeVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let discoverVC = Discover_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: discoverVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .present_wanderbell,
        animated_wanderbell: Bool = true,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        let releaseVC = Release_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: releaseVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: true,
            animated_wanderbell: animated_wanderbell,
            completion_wanderbell: completion_wanderbell
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let messageListVC = MessageList_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: messageListVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Wanderbell(
        with userModel_wanderbell: PrewUserModel_Wanderbell,
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        let messageUserVC = MessageUser_Wanderbell()
        messageUserVC.userModel_Wanderbell = userModel_wanderbell
        navigateToViewController_Wanderbell(
            viewController_wanderbell: messageUserVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: (style_wanderbell == .present_wanderbell),
            animated_wanderbell: animated_wanderbell,
            completion_wanderbell: completion_wanderbell
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let meVC = Me_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: meVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Wanderbell(
        with userModel_wanderbell: LoginUserModel_Wanderbell,
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let meVC = Me_Wanderbell()
        meVC.meModel_Wanderbell = userModel_wanderbell
        navigateToViewController_Wanderbell(
            viewController_wanderbell: meVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Wanderbell(
        with userModel_wanderbell: PrewUserModel_Wanderbell,
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        let userInfoVC = UserInfo_Wanderbell()
        userInfoVC.userModel_Wanderbell = userModel_wanderbell
        navigateToViewController_Wanderbell(
            viewController_wanderbell: userInfoVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: (style_wanderbell == .present_wanderbell),
            animated_wanderbell: animated_wanderbell,
            completion_wanderbell: completion_wanderbell
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let editInfoVC = EditInfo_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: editInfoVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    /// 跳转到设置页
    static func toSetting_Wanderbell(
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        let settingVC = Setting_Wanderbell()
        navigateToViewController_Wanderbell(
            viewController_wanderbell: settingVC,
            style_wanderbell: style_wanderbell,
            wrapInNavigation_wanderbell: false,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航类型枚举跳转（不带模型参数）
    static func navigate_Wanderbell(
        to type_wanderbell: NavigationType_Wanderbell,
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        switch type_wanderbell {
        case .home:
            toHome_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .discover:
            toDiscover_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .release:
            toRelease_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .messageList:
            toMessageList_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .me:
            toMe_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .editInfo:
            toEditInfo_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .setting:
            toSetting_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .login:
            toLogin_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        case .register:
            toRegister_Wanderbell(style_wanderbell: style_wanderbell, animated_wanderbell: animated_wanderbell)
        }
    }
    
    // MARK: - 便捷组合方法
    
    /// 从用户信息页快速跳转到与该用户的聊天页
    static func chatWithUser_Wanderbell(
        userModel_wanderbell: PrewUserModel_Wanderbell,
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        toMessageUser_Wanderbell(
            with: userModel_wanderbell,
            style_wanderbell: style_wanderbell,
            animated_wanderbell: animated_wanderbell
        )
    }
    
    /// 查看其他用户的个人主页
    static func viewUserProfile_Wanderbell(
        userModel_wanderbell: PrewUserModel_Wanderbell,
        style_wanderbell: NavigationStyle_Wanderbell = .push_wanderbell,
        animated_wanderbell: Bool = true
    ) {
        toUserInfo_Wanderbell(
            with: userModel_wanderbell,
            style_wanderbell: style_wanderbell,
            animated_wanderbell: animated_wanderbell
        )
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Wanderbell {
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
