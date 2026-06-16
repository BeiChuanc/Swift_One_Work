import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Niche {
    
    /// Push方式（导航栈推入）
    case push_niche
    
    /// Present方式（模态展示）
    case present_niche

    /// Replace方式（替换当前视图控制器）
    case replace_niche
}

/// 页面导航管理器
class Navigation_Niche: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Niche() -> UIViewController? {
        return UIViewController.currentViewController_Niche()
    }
    
    /// Push方式跳转到指定页面
    static func push_Niche(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Niche()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Niche(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Niche()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Niche(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Niche()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Niche(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Niche()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Niche(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Niche()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Niche(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Niche()
        guard let navigationController_niche = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_niche = navigationController_niche.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_niche.isEmpty {
            viewControllers_niche[viewControllers_niche.count - 1] = viewController
            navigationController_niche.setViewControllers(viewControllers_niche, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_niche.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Niche(
        viewController_niche: UIViewController,
        style_niche: NavigationStyle_Niche,
        wrapInNavigation_niche: Bool? = nil,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_niche = wrapInNavigation_niche ?? (style_niche == .present_niche)
        
        switch style_niche {
        case .push_niche:
            push_Niche(to: viewController_niche, animated: animated_niche)
            completion_niche?()
            
        case .present_niche:
            let targetVC_niche = shouldWrapInNavigation_niche 
                ? createNavigationController_Niche(rootViewController: viewController_niche)
                : viewController_niche
            
            targetVC_niche.modalPresentationStyle = .fullScreen
            present_Niche(viewController: targetVC_niche, animated: animated_niche, completion: completion_niche)
            
        case .replace_niche:
            replace_Niche(to: viewController_niche, animated: animated_niche)
            completion_niche?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Niche(rootViewController: UIViewController) -> UINavigationController {
        let nav_niche = UINavigationController(rootViewController: rootViewController)
        nav_niche.modalPresentationStyle = .fullScreen
        return nav_niche
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Niche(
        to viewController_niche: UIViewController,
        style_niche: NavigationStyle_Niche,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        navigateToViewController_Niche(
            viewController_niche: viewController_niche,
            style_niche: style_niche,
            wrapInNavigation_niche: nil, // 使用智能判断
            animated_niche: animated_niche,
            completion_niche: completion_niche
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Niche(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Niche(window: UIWindow?) {
        guard let validWindow_niche = validateWindow_Niche(window) else { return }
        
        let tabbar_niche = TabBar_Niche()
        let nav_niche = UINavigationController(rootViewController: tabbar_niche)
        nav_niche.navigationBar.isHidden = true
        
        validWindow_niche.rootViewController = nav_niche
        validWindow_niche.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Niche(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_niche = validateWindow_Niche(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_niche, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_niche.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_niche.rootViewController = viewController
        }
        validWindow_niche.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Niche() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Niche(animated: Bool = true) {
        let window = getAppWindow_Niche()
        setRootToTabbar_Niche(window: window)
        
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
    static func toLogin_Niche(
        style_niche: NavigationStyle_Niche = .present_niche,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        navigate_Niche(
            to: Login_Niche(),
            style_niche: style_niche,
            animated_niche: animated_niche,
            completion_niche: completion_niche
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Niche(
        style_niche: NavigationStyle_Niche = .present_niche,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        navigate_Niche(
            to: Register_Niche(),
            style_niche: style_niche,
            animated_niche: animated_niche,
            completion_niche: completion_niche
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: Home_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: Discover_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Niche(
        titleModel_niche: TitleModel_Niche,
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        let detailVC_niche = Detail_Niche()
        detailVC_niche.titleModel_Niche = titleModel_niche
        navigate_Niche(to: detailVC_niche, style_niche: style_niche, animated_niche: animated_niche)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Niche(
        style_niche: NavigationStyle_Niche = .present_niche,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        navigate_Niche(
            to: Release_Niche(),
            style_niche: style_niche,
            animated_niche: animated_niche,
            completion_niche: completion_niche
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: MessageList_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Niche(
        with userModel_niche: PrewUserModel_Niche,
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        let messageUserVC_niche = MessageUser_Niche()
        messageUserVC_niche.userModel_Niche = userModel_niche
        navigate_Niche(
            to: messageUserVC_niche,
            style_niche: style_niche,
            animated_niche: animated_niche,
            completion_niche: completion_niche
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: Me_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Niche(
        with userModel_niche: LoginUserModel_Niche,
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        let meVC_niche = Me_Niche()
        meVC_niche.meModel_Niche = userModel_niche
        navigate_Niche(to: meVC_niche, style_niche: style_niche, animated_niche: animated_niche)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Niche(
        with userModel_niche: PrewUserModel_Niche,
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true,
        completion_niche: (() -> Void)? = nil
    ) {
        let userInfoVC_niche = UserInfo_Niche()
        userInfoVC_niche.userModel_Niche = userModel_niche
        navigate_Niche(
            to: userInfoVC_niche,
            style_niche: style_niche,
            animated_niche: animated_niche,
            completion_niche: completion_niche
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: EditInfo_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }
    
    /// 跳转到设置页
    static func toSetting_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: Setting_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }

    /// 跳转到 VIP 订阅页
    static func toVIPSubscription_Niche(
        style_niche: NavigationStyle_Niche = .push_niche,
        animated_niche: Bool = true
    ) {
        navigate_Niche(to: VIPSubscription_Niche(), style_niche: style_niche, animated_niche: animated_niche)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Niche {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_niche: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Niche(from viewController_niche: UIViewController) {
        let isPresented_niche = viewController_niche.presentingViewController != nil
        
        if isPresented_niche {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_niche = viewController_niche.presentingViewController
            viewController_niche.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_niche: UINavigationController?
                if let nav_niche = presentingVC_niche as? UINavigationController {
                    navVC_niche = nav_niche
                } else {
                    navVC_niche = presentingVC_niche?.navigationController
                }
                if let nav_niche = navVC_niche {
                    popStackToSafeVC_Niche(nav: nav_niche)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_niche = viewController_niche.navigationController {
                popStackToSafeVC_Niche(nav: nav_niche)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Niche(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_niche: [AnyClass] = [
            Detail_Niche.self,
            MessageUser_Niche.self,
            Home_Niche.self,
            Discover_Niche.self,
            Release_Niche.self,
            MessageList_Niche.self,
            Me_Niche.self
        ]
        
        let stack_niche = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_niche in stack_niche.reversed() {
            let isExcluded_niche = excludedTypes_niche.contains { vc_niche.isKind(of: $0) }
            if !isExcluded_niche {
                // 已经处于安全 VC，无需额外跳转
                if vc_niche === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_niche, animated: true)
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
enum NavigationType_Niche {
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
