import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Vestir {
    
    /// Push方式（导航栈推入）
    case push_vestir
    
    /// Present方式（模态展示）
    case present_vestir

    /// Replace方式（替换当前视图控制器）
    case replace_vestir
}

/// 页面导航管理器
class Navigation_Vestir: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Vestir() -> UIViewController? {
        return UIViewController.currentViewController_Vestir()
    }
    
    /// Push方式跳转到指定页面
    static func push_Vestir(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Vestir()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Vestir(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Vestir()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Vestir(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Vestir()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Vestir(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Vestir()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Vestir(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Vestir()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Vestir(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Vestir()
        guard let navigationController_vestir = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_vestir = navigationController_vestir.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_vestir.isEmpty {
            viewControllers_vestir[viewControllers_vestir.count - 1] = viewController
            navigationController_vestir.setViewControllers(viewControllers_vestir, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_vestir.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Vestir(
        viewController_vestir: UIViewController,
        style_vestir: NavigationStyle_Vestir,
        wrapInNavigation_vestir: Bool? = nil,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_vestir = wrapInNavigation_vestir ?? (style_vestir == .present_vestir)
        
        switch style_vestir {
        case .push_vestir:
            push_Vestir(to: viewController_vestir, animated: animated_vestir)
            completion_vestir?()
            
        case .present_vestir:
            let targetVC_vestir = shouldWrapInNavigation_vestir 
                ? createNavigationController_Vestir(rootViewController: viewController_vestir)
                : viewController_vestir
            
            targetVC_vestir.modalPresentationStyle = .fullScreen
            present_Vestir(viewController: targetVC_vestir, animated: animated_vestir, completion: completion_vestir)
            
        case .replace_vestir:
            replace_Vestir(to: viewController_vestir, animated: animated_vestir)
            completion_vestir?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Vestir(rootViewController: UIViewController) -> UINavigationController {
        let nav_vestir = UINavigationController(rootViewController: rootViewController)
        nav_vestir.modalPresentationStyle = .fullScreen
        return nav_vestir
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Vestir(
        to viewController_vestir: UIViewController,
        style_vestir: NavigationStyle_Vestir,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        navigateToViewController_Vestir(
            viewController_vestir: viewController_vestir,
            style_vestir: style_vestir,
            wrapInNavigation_vestir: nil, // 使用智能判断
            animated_vestir: animated_vestir,
            completion_vestir: completion_vestir
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Vestir(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Vestir(window: UIWindow?) {
        guard let validWindow_vestir = validateWindow_Vestir(window) else { return }
        
        let tabbar_vestir = TabBar_Vestir()
        let nav_vestir = UINavigationController(rootViewController: tabbar_vestir)
        nav_vestir.navigationBar.isHidden = true
        
        validWindow_vestir.rootViewController = nav_vestir
        validWindow_vestir.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Vestir(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_vestir = validateWindow_Vestir(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_vestir, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_vestir.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_vestir.rootViewController = viewController
        }
        validWindow_vestir.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Vestir() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Vestir(animated: Bool = true) {
        let window = getAppWindow_Vestir()
        setRootToTabbar_Vestir(window: window)
        
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
    static func toLogin_Vestir(
        style_vestir: NavigationStyle_Vestir = .present_vestir,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        navigate_Vestir(
            to: Login_Vestir(),
            style_vestir: style_vestir,
            animated_vestir: animated_vestir,
            completion_vestir: completion_vestir
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Vestir(
        style_vestir: NavigationStyle_Vestir = .present_vestir,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        navigate_Vestir(
            to: Register_Vestir(),
            style_vestir: style_vestir,
            animated_vestir: animated_vestir,
            completion_vestir: completion_vestir
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Vestir(
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        navigate_Vestir(to: Home_Vestir(), style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Vestir(
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        navigate_Vestir(to: Discover_Vestir(), style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Vestir(
        titleModel_vestir: TitleModel_Vestir,
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        let detailVC_vestir = Detail_Vestir()
        detailVC_vestir.titleModel_Vestir = titleModel_vestir
        navigate_Vestir(to: detailVC_vestir, style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Vestir(
        style_vestir: NavigationStyle_Vestir = .present_vestir,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        navigate_Vestir(
            to: Release_Vestir(),
            style_vestir: style_vestir,
            animated_vestir: animated_vestir,
            completion_vestir: completion_vestir
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Vestir(
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        navigate_Vestir(to: MessageList_Vestir(), style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Vestir(
        with userModel_vestir: PrewUserModel_Vestir,
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        let messageUserVC_vestir = MessageUser_Vestir()
        messageUserVC_vestir.userModel_Vestir = userModel_vestir
        navigate_Vestir(
            to: messageUserVC_vestir,
            style_vestir: style_vestir,
            animated_vestir: animated_vestir,
            completion_vestir: completion_vestir
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Vestir(
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        navigate_Vestir(to: Me_Vestir(), style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Vestir(
        with userModel_vestir: LoginUserModel_Vestir,
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        let meVC_vestir = Me_Vestir()
        meVC_vestir.meModel_Vestir = userModel_vestir
        navigate_Vestir(to: meVC_vestir, style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Vestir(
        with userModel_vestir: PrewUserModel_Vestir,
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true,
        completion_vestir: (() -> Void)? = nil
    ) {
        let userInfoVC_vestir = UserInfo_Vestir()
        userInfoVC_vestir.userModel_Vestir = userModel_vestir
        navigate_Vestir(
            to: userInfoVC_vestir,
            style_vestir: style_vestir,
            animated_vestir: animated_vestir,
            completion_vestir: completion_vestir
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Vestir(
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        navigate_Vestir(to: EditInfo_Vestir(), style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
    
    /// 跳转到设置页
    static func toSetting_Vestir(
        style_vestir: NavigationStyle_Vestir = .push_vestir,
        animated_vestir: Bool = true
    ) {
        navigate_Vestir(to: Setting_Vestir(), style_vestir: style_vestir, animated_vestir: animated_vestir)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Vestir {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_vestir: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Vestir(from viewController_vestir: UIViewController) {
        let isPresented_vestir = viewController_vestir.presentingViewController != nil
        
        if isPresented_vestir {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_vestir = viewController_vestir.presentingViewController
            viewController_vestir.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_vestir: UINavigationController?
                if let nav_vestir = presentingVC_vestir as? UINavigationController {
                    navVC_vestir = nav_vestir
                } else {
                    navVC_vestir = presentingVC_vestir?.navigationController
                }
                if let nav_vestir = navVC_vestir {
                    popStackToSafeVC_Vestir(nav: nav_vestir)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_vestir = viewController_vestir.navigationController {
                popStackToSafeVC_Vestir(nav: nav_vestir)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Vestir(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_vestir: [AnyClass] = [
            Detail_Vestir.self,
            MessageUser_Vestir.self,
            Home_Vestir.self,
            Discover_Vestir.self,
            Release_Vestir.self,
            MessageList_Vestir.self,
            Me_Vestir.self
        ]
        
        let stack_vestir = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_vestir in stack_vestir.reversed() {
            let isExcluded_vestir = excludedTypes_vestir.contains { vc_vestir.isKind(of: $0) }
            if !isExcluded_vestir {
                // 已经处于安全 VC，无需额外跳转
                if vc_vestir === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_vestir, animated: true)
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
enum NavigationType_Vestir {
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
