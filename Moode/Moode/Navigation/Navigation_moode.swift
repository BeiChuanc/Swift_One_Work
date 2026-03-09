import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Moode {
    
    /// Push方式（导航栈推入）
    case push_moode
    
    /// Present方式（模态展示）
    case present_moode

    /// Replace方式（替换当前视图控制器）
    case replace_moode
}

/// 页面导航管理器
class Navigation_Moode: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Moode() -> UIViewController? {
        return UIViewController.currentViewController_Moode()
    }
    
    /// Push方式跳转到指定页面
    static func push_Moode(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Moode()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Moode(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Moode()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Moode(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Moode()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Moode(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Moode()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Moode(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Moode()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Moode(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Moode()
        guard let navigationController_moode = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_moode = navigationController_moode.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_moode.isEmpty {
            viewControllers_moode[viewControllers_moode.count - 1] = viewController
            navigationController_moode.setViewControllers(viewControllers_moode, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_moode.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Moode(
        viewController_moode: UIViewController,
        style_moode: NavigationStyle_Moode,
        wrapInNavigation_moode: Bool? = nil,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_moode = wrapInNavigation_moode ?? (style_moode == .present_moode)
        
        switch style_moode {
        case .push_moode:
            push_Moode(to: viewController_moode, animated: animated_moode)
            completion_moode?()
            
        case .present_moode:
            let targetVC_moode = shouldWrapInNavigation_moode 
                ? createNavigationController_Moode(rootViewController: viewController_moode)
                : viewController_moode
            
            targetVC_moode.modalPresentationStyle = .fullScreen
            present_Moode(viewController: targetVC_moode, animated: animated_moode, completion: completion_moode)
            
        case .replace_moode:
            replace_Moode(to: viewController_moode, animated: animated_moode)
            completion_moode?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Moode(rootViewController: UIViewController) -> UINavigationController {
        let nav_moode = UINavigationController(rootViewController: rootViewController)
        nav_moode.modalPresentationStyle = .fullScreen
        return nav_moode
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Moode(
        to viewController_moode: UIViewController,
        style_moode: NavigationStyle_Moode,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        navigateToViewController_Moode(
            viewController_moode: viewController_moode,
            style_moode: style_moode,
            wrapInNavigation_moode: nil, // 使用智能判断
            animated_moode: animated_moode,
            completion_moode: completion_moode
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Moode(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Moode(window: UIWindow?) {
        guard let validWindow_moode = validateWindow_Moode(window) else { return }
        
        let tabbar_moode = TabBar_Moode()
        let nav_moode = UINavigationController(rootViewController: tabbar_moode)
        nav_moode.navigationBar.isHidden = true
        
        validWindow_moode.rootViewController = nav_moode
        validWindow_moode.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Moode(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_moode = validateWindow_Moode(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_moode, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_moode.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_moode.rootViewController = viewController
        }
        validWindow_moode.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Moode() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换底部 Tabbar 到指定 Tab 索引（不产生页面跳转，仅切换 Tab）
    /// - Parameter index_moode: 目标索引（0=首页 1=发现 2=发布 3=消息 4=我的）
    static func switchToTab_Moode(index_moode: Int) {
        guard let window_moode = getAppWindow_Moode(),
              let nav_moode = window_moode.rootViewController as? UINavigationController,
              let tabBar_moode = nav_moode.viewControllers.first as? TabBar_Moode else {
            print("⚠️ 警告：未找到 TabBar_Moode，无法切换 Tab")
            return
        }
        tabBar_moode.switchTab_Moode(to: index_moode)
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Moode(animated: Bool = true) {
        let window = getAppWindow_Moode()
        setRootToTabbar_Moode(window: window)
        
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
    static func toLogin_Moode(
        style_moode: NavigationStyle_Moode = .present_moode,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        navigate_Moode(
            to: Login_Moode(),
            style_moode: style_moode,
            animated_moode: animated_moode,
            completion_moode: completion_moode
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Moode(
        style_moode: NavigationStyle_Moode = .present_moode,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        navigate_Moode(
            to: Register_Moode(),
            style_moode: style_moode,
            animated_moode: animated_moode,
            completion_moode: completion_moode
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Moode(
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        navigate_Moode(to: Home_Moode(), style_moode: style_moode, animated_moode: animated_moode)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Moode(
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        navigate_Moode(to: Discover_Moode(), style_moode: style_moode, animated_moode: animated_moode)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Moode(
        titleModel_moode: TitleModel_Moode,
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        let detailVC_moode = Detail_Moode()
        detailVC_moode.titleModel_Moode = titleModel_moode
        navigate_Moode(to: detailVC_moode, style_moode: style_moode, animated_moode: animated_moode)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Moode(
        style_moode: NavigationStyle_Moode = .present_moode,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        navigate_Moode(
            to: Release_Moode(),
            style_moode: style_moode,
            animated_moode: animated_moode,
            completion_moode: completion_moode
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Moode(
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        navigate_Moode(to: MessageList_Moode(), style_moode: style_moode, animated_moode: animated_moode)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Moode(
        with userModel_moode: PrewUserModel_Moode,
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        let messageUserVC_moode = MessageUser_Moode()
        messageUserVC_moode.userModel_Moode = userModel_moode
        navigate_Moode(
            to: messageUserVC_moode,
            style_moode: style_moode,
            animated_moode: animated_moode,
            completion_moode: completion_moode
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Moode(
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        navigate_Moode(to: Me_Moode(), style_moode: style_moode, animated_moode: animated_moode)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Moode(
        with userModel_moode: LoginUserModel_Moode,
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        let meVC_moode = Me_Moode()
        meVC_moode.meModel_Moode = userModel_moode
        navigate_Moode(to: meVC_moode, style_moode: style_moode, animated_moode: animated_moode)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Moode(
        with userModel_moode: PrewUserModel_Moode,
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true,
        completion_moode: (() -> Void)? = nil
    ) {
        let userInfoVC_moode = UserInfo_Moode()
        userInfoVC_moode.userModel_Moode = userModel_moode
        navigate_Moode(
            to: userInfoVC_moode,
            style_moode: style_moode,
            animated_moode: animated_moode,
            completion_moode: completion_moode
        )
    }
    
    /// 跳转到挑战详情页
    static func toChallengeDetail_Moode(
        with challenge_moode: MoodChallenge_Moode,
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        let vc_moode = ChallengeDetail_Moode()
        vc_moode.challenge_Moode = challenge_moode
        navigate_Moode(to: vc_moode, style_moode: style_moode, animated_moode: animated_moode)
    }

    /// 跳转到编辑信息页
    static func toEditInfo_Moode(
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        navigate_Moode(to: EditInfo_Moode(), style_moode: style_moode, animated_moode: animated_moode)
    }
    
    /// 跳转到设置页
    static func toSetting_Moode(
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        navigate_Moode(to: Setting_Moode(), style_moode: style_moode, animated_moode: animated_moode)
    }
    
    // MARK: - 枚举导航方法
    
    /// 根据导航类型枚举跳转
    static func navigateByType_Moode(
        to type_moode: NavigationType_Moode,
        style_moode: NavigationStyle_Moode = .push_moode,
        animated_moode: Bool = true
    ) {
        switch type_moode {
        case .home:
            toHome_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .discover:
            toDiscover_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .release:
            toRelease_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .messageList:
            toMessageList_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .me:
            toMe_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .editInfo:
            toEditInfo_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .setting:
            toSetting_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .login:
            toLogin_Moode(style_moode: style_moode, animated_moode: animated_moode)
        case .register:
            toRegister_Moode(style_moode: style_moode, animated_moode: animated_moode)
        }
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Moode {
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
