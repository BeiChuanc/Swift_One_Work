import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Clara {
    
    /// Push方式（导航栈推入）
    case push_clara
    
    /// Present方式（模态展示）
    case present_clara

    /// Replace方式（替换当前视图控制器）
    case replace_clara
}

/// 页面导航管理器
class Navigation_Clara: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Clara() -> UIViewController? {
        return UIViewController.currentViewController_Clara()
    }
    
    /// Push方式跳转到指定页面
    static func push_Clara(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Clara()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Clara(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Clara()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Clara(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Clara()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Clara(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Clara()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Clara(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Clara()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Clara(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Clara()
        guard let navigationController_clara = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_clara = navigationController_clara.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_clara.isEmpty {
            viewControllers_clara[viewControllers_clara.count - 1] = viewController
            navigationController_clara.setViewControllers(viewControllers_clara, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_clara.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Clara(
        viewController_clara: UIViewController,
        style_clara: NavigationStyle_Clara,
        wrapInNavigation_clara: Bool? = nil,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_clara = wrapInNavigation_clara ?? (style_clara == .present_clara)
        
        switch style_clara {
        case .push_clara:
            push_Clara(to: viewController_clara, animated: animated_clara)
            completion_clara?()
            
        case .present_clara:
            let targetVC_clara = shouldWrapInNavigation_clara 
                ? createNavigationController_Clara(rootViewController: viewController_clara)
                : viewController_clara
            
            targetVC_clara.modalPresentationStyle = .fullScreen
            present_Clara(viewController: targetVC_clara, animated: animated_clara, completion: completion_clara)
            
        case .replace_clara:
            replace_Clara(to: viewController_clara, animated: animated_clara)
            completion_clara?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Clara(rootViewController: UIViewController) -> UINavigationController {
        let nav_clara = UINavigationController(rootViewController: rootViewController)
        nav_clara.modalPresentationStyle = .fullScreen
        return nav_clara
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Clara(
        to viewController_clara: UIViewController,
        style_clara: NavigationStyle_Clara,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        navigateToViewController_Clara(
            viewController_clara: viewController_clara,
            style_clara: style_clara,
            wrapInNavigation_clara: nil, // 使用智能判断
            animated_clara: animated_clara,
            completion_clara: completion_clara
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Clara(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Clara(window: UIWindow?) {
        guard let validWindow_clara = validateWindow_Clara(window) else { return }
        
        let tabbar_clara = TabBar_Clara()
        let nav_clara = UINavigationController(rootViewController: tabbar_clara)
        nav_clara.navigationBar.isHidden = true
        
        validWindow_clara.rootViewController = nav_clara
        validWindow_clara.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Clara(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_clara = validateWindow_Clara(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_clara, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_clara.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_clara.rootViewController = viewController
        }
        validWindow_clara.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Clara() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Clara(animated: Bool = true) {
        let window = getAppWindow_Clara()
        setRootToTabbar_Clara(window: window)
        
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
    static func toLogin_Clara(
        style_clara: NavigationStyle_Clara = .present_clara,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        navigate_Clara(
            to: Login_Clara(),
            style_clara: style_clara,
            animated_clara: animated_clara,
            completion_clara: completion_clara
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Clara(
        style_clara: NavigationStyle_Clara = .present_clara,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        navigate_Clara(
            to: Register_Clara(),
            style_clara: style_clara,
            animated_clara: animated_clara,
            completion_clara: completion_clara
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Clara(
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        navigate_Clara(to: Home_Clara(), style_clara: style_clara, animated_clara: animated_clara)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Clara(
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        navigate_Clara(to: Discover_Clara(), style_clara: style_clara, animated_clara: animated_clara)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Clara(
        titleModel_clara: TitleModel_Clara,
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        let detailVC_clara = Detail_Clara()
        detailVC_clara.titleModel_Clara = titleModel_clara
        navigate_Clara(to: detailVC_clara, style_clara: style_clara, animated_clara: animated_clara)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Clara(
        style_clara: NavigationStyle_Clara = .present_clara,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        navigate_Clara(
            to: Release_Clara(),
            style_clara: style_clara,
            animated_clara: animated_clara,
            completion_clara: completion_clara
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Clara(
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        navigate_Clara(to: MessageList_Clara(), style_clara: style_clara, animated_clara: animated_clara)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Clara(
        with userModel_clara: PrewUserModel_Clara,
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        let messageUserVC_clara = MessageUser_Clara()
        messageUserVC_clara.userModel_Clara = userModel_clara
        navigate_Clara(
            to: messageUserVC_clara,
            style_clara: style_clara,
            animated_clara: animated_clara,
            completion_clara: completion_clara
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Clara(
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        navigate_Clara(to: Me_Clara(), style_clara: style_clara, animated_clara: animated_clara)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Clara(
        with userModel_clara: LoginUserModel_Clara,
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        let meVC_clara = Me_Clara()
        meVC_clara.meModel_Clara = userModel_clara
        navigate_Clara(to: meVC_clara, style_clara: style_clara, animated_clara: animated_clara)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Clara(
        with userModel_clara: PrewUserModel_Clara,
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true,
        completion_clara: (() -> Void)? = nil
    ) {
        let userInfoVC_clara = UserInfo_Clara()
        userInfoVC_clara.userModel_Clara = userModel_clara
        navigate_Clara(
            to: userInfoVC_clara,
            style_clara: style_clara,
            animated_clara: animated_clara,
            completion_clara: completion_clara
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Clara(
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        navigate_Clara(to: EditInfo_Clara(), style_clara: style_clara, animated_clara: animated_clara)
    }
    
    /// 跳转到设置页
    static func toSetting_Clara(
        style_clara: NavigationStyle_Clara = .push_clara,
        animated_clara: Bool = true
    ) {
        navigate_Clara(to: Setting_Clara(), style_clara: style_clara, animated_clara: animated_clara)
    }

}

// MARK: - 举报拉黑后安全导航

extension Navigation_Clara {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_clara: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Clara(from viewController_clara: UIViewController) {
        let isPresented_clara = viewController_clara.presentingViewController != nil
        
        if isPresented_clara {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_clara = viewController_clara.presentingViewController
            viewController_clara.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_clara: UINavigationController?
                if let nav_clara = presentingVC_clara as? UINavigationController {
                    navVC_clara = nav_clara
                } else {
                    navVC_clara = presentingVC_clara?.navigationController
                }
                if let nav_clara = navVC_clara {
                    popStackToSafeVC_Clara(nav: nav_clara)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_clara = viewController_clara.navigationController {
                popStackToSafeVC_Clara(nav: nav_clara)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Clara(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_clara: [AnyClass] = [
            Detail_Clara.self,
            MessageUser_Clara.self,
            UserInfo_Clara.self,
            Home_Clara.self,
            Discover_Clara.self,
            Release_Clara.self,
            MessageList_Clara.self,
            Me_Clara.self
        ]
        
        let stack_clara = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_clara in stack_clara.reversed() {
            let isExcluded_clara = excludedTypes_clara.contains { vc_clara.isKind(of: $0) }
            if !isExcluded_clara {
                // 已经处于安全 VC，无需额外跳转
                if vc_clara === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_clara, animated: true)
                return
            }
        }
        
        // 导航栈中所有 VC 均为排除类型，回到根视图控制器（TabBar）
        print("⚠️ 导航堆栈中无安全 VC，已返回根视图控制器")
        nav.popToRootViewController(animated: true)
    }
}

// MARK: - 导航类型枚举

/// 导航页面类型枚举
enum NavigationType_Clara {
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
