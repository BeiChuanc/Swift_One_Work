import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Trace {
    
    /// Push方式（导航栈推入）
    case push_trace
    
    /// Present方式（模态展示）
    case present_trace

    /// Replace方式（替换当前视图控制器）
    case replace_trace
}

/// 页面导航管理器
class Navigation_Trace: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Trace() -> UIViewController? {
        return UIViewController.currentViewController_Trace()
    }
    
    /// Push方式跳转到指定页面
    static func push_Trace(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Trace()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Trace(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Trace()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Trace(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Trace()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Trace(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Trace()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Trace(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Trace()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Trace(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Trace()
        guard let navigationController_trace = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_trace = navigationController_trace.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_trace.isEmpty {
            viewControllers_trace[viewControllers_trace.count - 1] = viewController
            navigationController_trace.setViewControllers(viewControllers_trace, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_trace.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Trace(
        viewController_trace: UIViewController,
        style_trace: NavigationStyle_Trace,
        wrapInNavigation_trace: Bool? = nil,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_trace = wrapInNavigation_trace ?? (style_trace == .present_trace)
        
        switch style_trace {
        case .push_trace:
            push_Trace(to: viewController_trace, animated: animated_trace)
            completion_trace?()
            
        case .present_trace:
            let targetVC_trace = shouldWrapInNavigation_trace 
                ? createNavigationController_Trace(rootViewController: viewController_trace)
                : viewController_trace
            
            targetVC_trace.modalPresentationStyle = .fullScreen
            present_Trace(viewController: targetVC_trace, animated: animated_trace, completion: completion_trace)
            
        case .replace_trace:
            replace_Trace(to: viewController_trace, animated: animated_trace)
            completion_trace?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Trace(rootViewController: UIViewController) -> UINavigationController {
        let nav_trace = UINavigationController(rootViewController: rootViewController)
        nav_trace.modalPresentationStyle = .fullScreen
        return nav_trace
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Trace(
        to viewController_trace: UIViewController,
        style_trace: NavigationStyle_Trace,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        navigateToViewController_Trace(
            viewController_trace: viewController_trace,
            style_trace: style_trace,
            wrapInNavigation_trace: nil, // 使用智能判断
            animated_trace: animated_trace,
            completion_trace: completion_trace
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Trace(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Trace(window: UIWindow?) {
        guard let validWindow_trace = validateWindow_Trace(window) else { return }
        
        let tabbar_trace = TabBar_Trace()
        let nav_trace = UINavigationController(rootViewController: tabbar_trace)
        // 统一使用 setNavigationBarHidden，由 TabBar_Trace.viewWillAppear 在运行时托管实际状态
        nav_trace.setNavigationBarHidden(true, animated: false)
        
        validWindow_trace.rootViewController = nav_trace
        validWindow_trace.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Trace(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_trace = validateWindow_Trace(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_trace, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_trace.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_trace.rootViewController = viewController
        }
        validWindow_trace.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Trace() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换 TabBar 到指定 Tab 索引（用于首页头像等快捷入口）
    /// - Parameter index: 目标 Tab 索引（0=首页, 1=发现, 2=发布, 3=消息, 4=我的）
    static func switchToTab_Trace(index: Int) {
        guard let window = getAppWindow_Trace(),
              let nav = window.rootViewController as? UINavigationController,
              let tabBar = nav.viewControllers.first as? TabBar_Trace else { return }
        tabBar.switchToTab_Trace(index: index)
    }

    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Trace(animated: Bool = true) {
        let window = getAppWindow_Trace()
        setRootToTabbar_Trace(window: window)
        
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
    static func toLogin_Trace(
        style_trace: NavigationStyle_Trace = .present_trace,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        navigate_Trace(
            to: Login_Trace(),
            style_trace: style_trace,
            animated_trace: animated_trace,
            completion_trace: completion_trace
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Trace(
        style_trace: NavigationStyle_Trace = .present_trace,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        navigate_Trace(
            to: Register_Trace(),
            style_trace: style_trace,
            animated_trace: animated_trace,
            completion_trace: completion_trace
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到打卡页
    static func toCheckIn_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: CheckIn_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到首页
    static func toHome_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: Home_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    // MARK: - 发现页相关

    /// 跳转到挑战详情页（带挑战模型）
    static func toChallengeDetail_Trace(
        challenge_trace: ChallengeModel_Trace,
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        let vc_trace = ChallengeDetail_Trace()
        vc_trace.challenge_Trace = challenge_trace
        navigate_Trace(to: vc_trace, style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到发现页
    static func toDiscover_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: Discover_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Trace(
        titleModel_trace: TitleModel_Trace,
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        let detailVC_trace = Detail_Trace()
        detailVC_trace.titleModel_Trace = titleModel_trace
        navigate_Trace(to: detailVC_trace, style_trace: style_trace, animated_trace: animated_trace)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Trace(
        style_trace: NavigationStyle_Trace = .present_trace,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        navigate_Trace(
            to: Release_Trace(),
            style_trace: style_trace,
            animated_trace: animated_trace,
            completion_trace: completion_trace
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到视频通话页（全屏模态，传入通话对象用户模型）
    /// - Parameter userModel_trace: 通话对象用户信息
    static func toVideoChat_Trace(
        with userModel_trace: PrewUserModel_Trace,
        animated_trace: Bool = true
    ) {
        let vc_trace = VideoChat_Trace()
        vc_trace.userModel_Trace = userModel_trace
        vc_trace.modalPresentationStyle = .fullScreen
        present_Trace(viewController: vc_trace, animated: animated_trace)
    }

    /// 跳转到消息列表
    static func toMessageList_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: MessageList_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Trace(
        with userModel_trace: PrewUserModel_Trace,
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        let messageUserVC_trace = MessageUser_Trace()
        messageUserVC_trace.userModel_Trace = userModel_trace
        navigate_Trace(
            to: messageUserVC_trace,
            style_trace: style_trace,
            animated_trace: animated_trace,
            completion_trace: completion_trace
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: Me_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Trace(
        with userModel_trace: LoginUserModel_Trace,
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        let meVC_trace = Me_Trace()
        meVC_trace.meModel_Trace = userModel_trace
        navigate_Trace(to: meVC_trace, style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Trace(
        with userModel_trace: PrewUserModel_Trace,
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true,
        completion_trace: (() -> Void)? = nil
    ) {
        let userInfoVC_trace = UserInfo_Trace()
        userInfoVC_trace.userModel_Trace = userModel_trace
        navigate_Trace(
            to: userInfoVC_trace,
            style_trace: style_trace,
            animated_trace: animated_trace,
            completion_trace: completion_trace
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: EditInfo_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    /// 跳转到设置页
    static func toSetting_Trace(
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        navigate_Trace(to: Setting_Trace(), style_trace: style_trace, animated_trace: animated_trace)
    }
    
    // MARK: - 枚举导航方法
    
    /// 根据导航类型枚举跳转
    static func navigateByType_Trace(
        to type_trace: NavigationType_Trace,
        style_trace: NavigationStyle_Trace = .push_trace,
        animated_trace: Bool = true
    ) {
        switch type_trace {
        case .home:
            toHome_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .discover:
            toDiscover_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .release:
            toRelease_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .messageList:
            toMessageList_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .me:
            toMe_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .editInfo:
            toEditInfo_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .setting:
            toSetting_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .login:
            toLogin_Trace(style_trace: style_trace, animated_trace: animated_trace)
        case .register:
            toRegister_Trace(style_trace: style_trace, animated_trace: animated_trace)
        }
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Trace {
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
