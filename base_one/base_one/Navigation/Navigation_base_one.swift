import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Base_one {
    
    /// Push方式（导航栈推入）
    case push_base_one
    
    /// Present方式（模态展示）
    case present_base_one
}

/// 页面导航管理器
class Navigation_Base_one: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Base_one() -> UIViewController? {
        return UIViewController.currentViewController_Base_one()
    }
    
    /// Push方式跳转到指定页面
    static func push_Base_one(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Base_one()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Base_one(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Base_one()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Base_one(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Base_one()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Base_one(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Base_one()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Base_one(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Base_one()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Base_one(
        viewController_base_one: UIViewController,
        style_base_one: NavigationStyle_Base_one,
        wrapInNavigation_base_one: Bool = true,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        switch style_base_one {
        case .push_base_one:
            push_Base_one(to: viewController_base_one, animated: animated_base_one)
            
        case .present_base_one:
            if wrapInNavigation_base_one {
                let nav_base_one = UINavigationController(rootViewController: viewController_base_one)
                nav_base_one.modalPresentationStyle = .fullScreen
                present_Base_one(viewController: nav_base_one, animated: animated_base_one, completion: completion_base_one)
            } else {
                viewController_base_one.modalPresentationStyle = .fullScreen
                present_Base_one(viewController: viewController_base_one, animated: animated_base_one, completion: completion_base_one)
            }
        }
    }
    
    // MARK: - 主导航
    static func setRootToTabbar_Base_one(window: UIWindow?) {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return
        }
        
        let tabbar = TabBar_Base_one()
        let nav = UINavigationController(rootViewController: tabbar)
        nav.navigationBar.isHidden = true
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Base_one(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
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
    static func getAppWindow_Base_one() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Base_one(animated: Bool = true) {
        let window = getAppWindow_Base_one()
        setRootToTabbar_Base_one(window: window)
        
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
    static func toLogin_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let loginVC = Login_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: loginVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: true,
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let registerVC = Register_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: registerVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: true,
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let homeVC = Home_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: homeVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let discoverVC = Discover_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: discoverVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let releaseVC = Release_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: releaseVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: true,
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let messageListVC = MessageList_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: messageListVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Base_one(
        with userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let messageUserVC = MessageUser_Base_one()
        messageUserVC.userModel_Base_one = userModel_base_one
        navigateToViewController_Base_one(
            viewController_base_one: messageUserVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: (style_base_one == .present_base_one),
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let meVC = Me_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: meVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Base_one(
        with userModel_base_one: LoginUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let meVC = Me_Base_one()
        meVC.meModel_Base_one = userModel_base_one
        navigateToViewController_Base_one(
            viewController_base_one: meVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Base_one(
        with userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let userInfoVC = UserInfo_Base_one()
        userInfoVC.userModel_Base_one = userModel_base_one
        navigateToViewController_Base_one(
            viewController_base_one: userInfoVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: (style_base_one == .present_base_one),
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let editInfoVC = EditInfo_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: editInfoVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    /// 跳转到设置页
    static func toSetting_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let settingVC = Setting_Base_one()
        navigateToViewController_Base_one(
            viewController_base_one: settingVC,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: false,
            animated_base_one: animated_base_one
        )
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航类型枚举跳转（不带模型参数）
    static func navigate_Base_one(
        to type_base_one: NavigationType_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        switch type_base_one {
        case .home:
            toHome_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .discover:
            toDiscover_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .release:
            toRelease_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .messageList:
            toMessageList_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .me:
            toMe_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .editInfo:
            toEditInfo_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .setting:
            toSetting_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .login:
            toLogin_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        case .register:
            toRegister_Base_one(style_base_one: style_base_one, animated_base_one: animated_base_one)
        }
    }
    
    // MARK: - 便捷组合方法
    
    /// 从用户信息页快速跳转到与该用户的聊天页
    static func chatWithUser_Base_one(
        userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        toMessageUser_Base_one(
            with: userModel_base_one,
            style_base_one: style_base_one,
            animated_base_one: animated_base_one
        )
    }
    
    /// 查看其他用户的个人主页
    static func viewUserProfile_Base_one(
        userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        toUserInfo_Base_one(
            with: userModel_base_one,
            style_base_one: style_base_one,
            animated_base_one: animated_base_one
        )
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Base_one {
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
