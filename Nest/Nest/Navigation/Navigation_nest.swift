import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Nest {
    
    /// Push方式（导航栈推入）
    case push_nest
    
    /// Present方式（模态展示）
    case present_nest

    /// Replace方式（替换当前视图控制器）
    case replace_nest
}

/// 页面导航管理器
class Navigation_Nest: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Nest() -> UIViewController? {
        return UIViewController.currentViewController_Nest()
    }
    
    /// Push方式跳转到指定页面
    static func push_Nest(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Nest()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Nest(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Nest()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Nest(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Nest()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Nest(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Nest()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Nest(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Nest()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Nest(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Nest()
        guard let navigationController_nest = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_nest = navigationController_nest.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_nest.isEmpty {
            viewControllers_nest[viewControllers_nest.count - 1] = viewController
            navigationController_nest.setViewControllers(viewControllers_nest, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_nest.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Nest(
        viewController_nest: UIViewController,
        style_nest: NavigationStyle_Nest,
        wrapInNavigation_nest: Bool? = nil,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_nest = wrapInNavigation_nest ?? (style_nest == .present_nest)
        
        switch style_nest {
        case .push_nest:
            push_Nest(to: viewController_nest, animated: animated_nest)
            completion_nest?()
            
        case .present_nest:
            let targetVC_nest = shouldWrapInNavigation_nest 
                ? createNavigationController_Nest(rootViewController: viewController_nest)
                : viewController_nest
            
            targetVC_nest.modalPresentationStyle = .fullScreen
            present_Nest(viewController: targetVC_nest, animated: animated_nest, completion: completion_nest)
            
        case .replace_nest:
            replace_Nest(to: viewController_nest, animated: animated_nest)
            completion_nest?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Nest(rootViewController: UIViewController) -> UINavigationController {
        let nav_nest = UINavigationController(rootViewController: rootViewController)
        nav_nest.modalPresentationStyle = .fullScreen
        return nav_nest
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Nest(
        to viewController_nest: UIViewController,
        style_nest: NavigationStyle_Nest,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        navigateToViewController_Nest(
            viewController_nest: viewController_nest,
            style_nest: style_nest,
            wrapInNavigation_nest: nil, // 使用智能判断
            animated_nest: animated_nest,
            completion_nest: completion_nest
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Nest(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Nest(window: UIWindow?) {
        guard let validWindow_nest = validateWindow_Nest(window) else { return }
        
        let tabbar_nest = TabBar_Nest()
        let nav_nest = UINavigationController(rootViewController: tabbar_nest)
        nav_nest.navigationBar.isHidden = true
        
        validWindow_nest.rootViewController = nav_nest
        validWindow_nest.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Nest(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_nest = validateWindow_Nest(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_nest, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_nest.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_nest.rootViewController = viewController
        }
        validWindow_nest.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Nest() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Nest(animated: Bool = true) {
        let window = getAppWindow_Nest()
        setRootToTabbar_Nest(window: window)
        
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
    static func toLogin_Nest(
        style_nest: NavigationStyle_Nest = .present_nest,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        navigate_Nest(
            to: Login_Nest(),
            style_nest: style_nest,
            animated_nest: animated_nest,
            completion_nest: completion_nest
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Nest(
        style_nest: NavigationStyle_Nest = .present_nest,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        navigate_Nest(
            to: Register_Nest(),
            style_nest: style_nest,
            animated_nest: animated_nest,
            completion_nest: completion_nest
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Nest(
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        navigate_Nest(to: Home_Nest(), style_nest: style_nest, animated_nest: animated_nest)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Nest(
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        navigate_Nest(to: Discover_Nest(), style_nest: style_nest, animated_nest: animated_nest)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Nest(
        titleModel_nest: TitleModel_Nest,
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        let detailVC_nest = Detail_Nest()
        detailVC_nest.titleModel_Nest = titleModel_nest
        navigate_Nest(to: detailVC_nest, style_nest: style_nest, animated_nest: animated_nest)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Nest(
        style_nest: NavigationStyle_Nest = .present_nest,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        navigate_Nest(
            to: Release_Nest(),
            style_nest: style_nest,
            animated_nest: animated_nest,
            completion_nest: completion_nest
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Nest(
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        navigate_Nest(to: MessageList_Nest(), style_nest: style_nest, animated_nest: animated_nest)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Nest(
        with userModel_nest: PrewUserModel_Nest,
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        let messageUserVC_nest = MessageUser_Nest()
        messageUserVC_nest.userModel_Nest = userModel_nest
        navigate_Nest(
            to: messageUserVC_nest,
            style_nest: style_nest,
            animated_nest: animated_nest,
            completion_nest: completion_nest
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Nest(
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        navigate_Nest(to: Me_Nest(), style_nest: style_nest, animated_nest: animated_nest)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Nest(
        with userModel_nest: LoginUserModel_Nest,
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        let meVC_nest = Me_Nest()
        meVC_nest.meModel_Nest = userModel_nest
        navigate_Nest(to: meVC_nest, style_nest: style_nest, animated_nest: animated_nest)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Nest(
        with userModel_nest: PrewUserModel_Nest,
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true,
        completion_nest: (() -> Void)? = nil
    ) {
        let userInfoVC_nest = UserInfo_Nest()
        userInfoVC_nest.userModel_Nest = userModel_nest
        navigate_Nest(
            to: userInfoVC_nest,
            style_nest: style_nest,
            animated_nest: animated_nest,
            completion_nest: completion_nest
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Nest(
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        navigate_Nest(to: EditInfo_Nest(), style_nest: style_nest, animated_nest: animated_nest)
    }
    
    /// 跳转到设置页
    static func toSetting_Nest(
        style_nest: NavigationStyle_Nest = .push_nest,
        animated_nest: Bool = true
    ) {
        navigate_Nest(to: Setting_Nest(), style_nest: style_nest, animated_nest: animated_nest)
    }
    
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Nest {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_nest: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Nest(from viewController_nest: UIViewController) {
        let isPresented_nest = viewController_nest.presentingViewController != nil
        
        if isPresented_nest {
            // 模态展示的情形：先记录 presentingVC，再执行 dismiss
            let presentingVC_nest = viewController_nest.presentingViewController
            viewController_nest.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_nest: UINavigationController?
                if let nav_nest = presentingVC_nest as? UINavigationController {
                    navVC_nest = nav_nest
                } else {
                    navVC_nest = presentingVC_nest?.navigationController
                }
                if let nav_nest = navVC_nest {
                    popStackToSafeVC_Nest(nav: nav_nest)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_nest = viewController_nest.navigationController {
                popStackToSafeVC_Nest(nav: nav_nest)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Nest(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_nest: [AnyClass] = [
            Detail_Nest.self,
            MessageUser_Nest.self,
            Home_Nest.self,
            Discover_Nest.self,
            Release_Nest.self,
            MessageList_Nest.self,
            Me_Nest.self
        ]
        
        let stack_nest = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_nest in stack_nest.reversed() {
            let isExcluded_nest = excludedTypes_nest.contains { vc_nest.isKind(of: $0) }
            if !isExcluded_nest {
                // 已经处于安全 VC，无需额外跳转
                if vc_nest === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_nest, animated: true)
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
enum NavigationType_Nest {
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
