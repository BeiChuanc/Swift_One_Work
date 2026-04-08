import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Base_one {
    
    /// Push方式（导航栈推入）
    case push_base_one
    
    /// Present方式（模态展示）
    case present_base_one

    /// Replace方式（替换当前视图控制器）
    case replace_base_one
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
    
    /// Replace方式替换当前页面
    static func replace_Base_one(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Base_one()
        guard let navigationController_base_one = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_base_one = navigationController_base_one.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_base_one.isEmpty {
            viewControllers_base_one[viewControllers_base_one.count - 1] = viewController
            navigationController_base_one.setViewControllers(viewControllers_base_one, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_base_one.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Base_one(
        viewController_base_one: UIViewController,
        style_base_one: NavigationStyle_Base_one,
        wrapInNavigation_base_one: Bool? = nil,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_base_one = wrapInNavigation_base_one ?? (style_base_one == .present_base_one)
        
        switch style_base_one {
        case .push_base_one:
            push_Base_one(to: viewController_base_one, animated: animated_base_one)
            completion_base_one?()
            
        case .present_base_one:
            let targetVC_base_one = shouldWrapInNavigation_base_one 
                ? createNavigationController_Base_one(rootViewController: viewController_base_one)
                : viewController_base_one
            
            targetVC_base_one.modalPresentationStyle = .fullScreen
            present_Base_one(viewController: targetVC_base_one, animated: animated_base_one, completion: completion_base_one)
            
        case .replace_base_one:
            replace_Base_one(to: viewController_base_one, animated: animated_base_one)
            completion_base_one?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Base_one(rootViewController: UIViewController) -> UINavigationController {
        let nav_base_one = UINavigationController(rootViewController: rootViewController)
        nav_base_one.modalPresentationStyle = .fullScreen
        return nav_base_one
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Base_one(
        to viewController_base_one: UIViewController,
        style_base_one: NavigationStyle_Base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        navigateToViewController_Base_one(
            viewController_base_one: viewController_base_one,
            style_base_one: style_base_one,
            wrapInNavigation_base_one: nil, // 使用智能判断
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Base_one(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Base_one(window: UIWindow?) {
        guard let validWindow_base_one = validateWindow_Base_one(window) else { return }
        
        let tabbar_base_one = TabBar_Base_one()
        let nav_base_one = UINavigationController(rootViewController: tabbar_base_one)
        nav_base_one.navigationBar.isHidden = true
        
        validWindow_base_one.rootViewController = nav_base_one
        validWindow_base_one.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Base_one(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_base_one = validateWindow_Base_one(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_base_one, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_base_one.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_base_one.rootViewController = viewController
        }
        validWindow_base_one.makeKeyAndVisible()
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
        navigate_Base_one(
            to: Login_Base_one(),
            style_base_one: style_base_one,
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
        navigate_Base_one(
            to: Register_Base_one(),
            style_base_one: style_base_one,
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
        navigate_Base_one(to: Home_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        navigate_Base_one(to: Discover_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Base_one(
        titleModel_base_one: TitleModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let detailVC_base_one = Detail_Base_one()
        detailVC_base_one.titleModel_Base_one = titleModel_base_one
        navigate_Base_one(to: detailVC_base_one, style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        navigate_Base_one(
            to: Release_Base_one(),
            style_base_one: style_base_one,
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
        navigate_Base_one(to: MessageList_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Base_one(
        with userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let messageUserVC_base_one = MessageUser_Base_one()
        messageUserVC_base_one.userModel_Base_one = userModel_base_one
        navigate_Base_one(
            to: messageUserVC_base_one,
            style_base_one: style_base_one,
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
        navigate_Base_one(to: Me_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Base_one(
        with userModel_base_one: LoginUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let meVC_base_one = Me_Base_one()
        meVC_base_one.meModel_Base_one = userModel_base_one
        navigate_Base_one(to: meVC_base_one, style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Base_one(
        with userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let userInfoVC_base_one = UserInfo_Base_one()
        userInfoVC_base_one.userModel_Base_one = userModel_base_one
        navigate_Base_one(
            to: userInfoVC_base_one,
            style_base_one: style_base_one,
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        navigate_Base_one(to: EditInfo_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
    
    /// 跳转到设置页
    static func toSetting_Base_one(
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        navigate_Base_one(to: Setting_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Base_one {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_base_one: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Base_one(from viewController_base_one: UIViewController) {
        let isPresented_base_one = viewController_base_one.presentingViewController != nil
        
        if isPresented_base_one {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_base_one = viewController_base_one.presentingViewController
            viewController_base_one.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_base_one: UINavigationController?
                if let nav_base_one = presentingVC_base_one as? UINavigationController {
                    navVC_base_one = nav_base_one
                } else {
                    navVC_base_one = presentingVC_base_one?.navigationController
                }
                if let nav_base_one = navVC_base_one {
                    popStackToSafeVC_Base_one(nav: nav_base_one)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_base_one = viewController_base_one.navigationController {
                popStackToSafeVC_Base_one(nav: nav_base_one)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Base_one(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_base_one: [AnyClass] = [
            Detail_Base_one.self,
            MessageUser_Base_one.self,
            Home_Base_one.self,
            Discover_Base_one.self,
            Release_Base_one.self,
            MessageList_Base_one.self,
            Me_Base_one.self
        ]
        
        let stack_base_one = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_base_one in stack_base_one.reversed() {
            let isExcluded_base_one = excludedTypes_base_one.contains { vc_base_one.isKind(of: $0) }
            if !isExcluded_base_one {
                // 已经处于安全 VC，无需额外跳转
                if vc_base_one === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_base_one, animated: true)
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
