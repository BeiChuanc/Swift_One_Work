import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Sylva {
    
    /// Push方式（导航栈推入）
    case push_sylva
    
    /// Present方式（模态展示）
    case present_sylva

    /// Replace方式（替换当前视图控制器）
    case replace_sylva
}

/// 页面导航管理器
class Navigation_Sylva: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Sylva() -> UIViewController? {
        return UIViewController.currentViewController_Sylva()
    }
    
    /// Push方式跳转到指定页面
    static func push_Sylva(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sylva()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Sylva(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sylva()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Sylva(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sylva()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Sylva(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sylva()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Sylva(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sylva()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Sylva(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Sylva()
        guard let navigationController_sylva = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_sylva = navigationController_sylva.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_sylva.isEmpty {
            viewControllers_sylva[viewControllers_sylva.count - 1] = viewController
            navigationController_sylva.setViewControllers(viewControllers_sylva, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_sylva.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Sylva(
        viewController_sylva: UIViewController,
        style_sylva: NavigationStyle_Sylva,
        wrapInNavigation_sylva: Bool? = nil,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_sylva = wrapInNavigation_sylva ?? (style_sylva == .present_sylva)
        
        switch style_sylva {
        case .push_sylva:
            push_Sylva(to: viewController_sylva, animated: animated_sylva)
            completion_sylva?()
            
        case .present_sylva:
            let targetVC_sylva = shouldWrapInNavigation_sylva 
                ? createNavigationController_Sylva(rootViewController: viewController_sylva)
                : viewController_sylva
            
            targetVC_sylva.modalPresentationStyle = .fullScreen
            present_Sylva(viewController: targetVC_sylva, animated: animated_sylva, completion: completion_sylva)
            
        case .replace_sylva:
            replace_Sylva(to: viewController_sylva, animated: animated_sylva)
            completion_sylva?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Sylva(rootViewController: UIViewController) -> UINavigationController {
        let nav_sylva = UINavigationController(rootViewController: rootViewController)
        nav_sylva.modalPresentationStyle = .fullScreen
        return nav_sylva
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Sylva(
        to viewController_sylva: UIViewController,
        style_sylva: NavigationStyle_Sylva,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        navigateToViewController_Sylva(
            viewController_sylva: viewController_sylva,
            style_sylva: style_sylva,
            wrapInNavigation_sylva: nil, // 使用智能判断
            animated_sylva: animated_sylva,
            completion_sylva: completion_sylva
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Sylva(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Sylva(window: UIWindow?) {
        guard let validWindow_sylva = validateWindow_Sylva(window) else { return }
        
        let tabbar_sylva = TabBar_Sylva()
        let nav_sylva = UINavigationController(rootViewController: tabbar_sylva)
        nav_sylva.navigationBar.isHidden = true
        
        validWindow_sylva.rootViewController = nav_sylva
        validWindow_sylva.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Sylva(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_sylva = validateWindow_Sylva(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_sylva, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_sylva.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_sylva.rootViewController = viewController
        }
        validWindow_sylva.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Sylva() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Sylva(animated: Bool = true) {
        let window = getAppWindow_Sylva()
        setRootToTabbar_Sylva(window: window)
        
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
    static func toLogin_Sylva(
        style_sylva: NavigationStyle_Sylva = .present_sylva,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        navigate_Sylva(
            to: Login_Sylva(),
            style_sylva: style_sylva,
            animated_sylva: animated_sylva,
            completion_sylva: completion_sylva
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Sylva(
        style_sylva: NavigationStyle_Sylva = .present_sylva,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        navigate_Sylva(
            to: Register_Sylva(),
            style_sylva: style_sylva,
            animated_sylva: animated_sylva,
            completion_sylva: completion_sylva
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Sylva(
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        navigate_Sylva(to: Home_Sylva(), style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Sylva(
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        navigate_Sylva(to: Discover_Sylva(), style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Sylva(
        titleModel_sylva: TitleModel_Sylva,
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        let detailVC_sylva = Detail_Sylva()
        detailVC_sylva.titleModel_Sylva = titleModel_sylva
        // 任务进度：浏览帖子
        Task { await UserViewModel_Sylva.shared_Sylva.progressTask_Sylva(type_sylva: .browsePost_Sylva) }
        navigate_Sylva(to: detailVC_sylva, style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Sylva(
        style_sylva: NavigationStyle_Sylva = .present_sylva,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        navigate_Sylva(
            to: Release_Sylva(),
            style_sylva: style_sylva,
            animated_sylva: animated_sylva,
            completion_sylva: completion_sylva
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Sylva(
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        navigate_Sylva(to: MessageList_Sylva(), style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Sylva(
        with userModel_sylva: PrewUserModel_Sylva,
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        let messageUserVC_sylva = MessageUser_Sylva()
        messageUserVC_sylva.userModel_Sylva = userModel_sylva
        navigate_Sylva(
            to: messageUserVC_sylva,
            style_sylva: style_sylva,
            animated_sylva: animated_sylva,
            completion_sylva: completion_sylva
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Sylva(
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        navigate_Sylva(to: Me_Sylva(), style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Sylva(
        with userModel_sylva: LoginUserModel_Sylva,
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        let meVC_sylva = Me_Sylva()
        meVC_sylva.meModel_Sylva = userModel_sylva
        navigate_Sylva(to: meVC_sylva, style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Sylva(
        with userModel_sylva: PrewUserModel_Sylva,
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true,
        completion_sylva: (() -> Void)? = nil
    ) {
        let userInfoVC_sylva = UserInfo_Sylva()
        userInfoVC_sylva.userModel_Sylva = userModel_sylva
        navigate_Sylva(
            to: userInfoVC_sylva,
            style_sylva: style_sylva,
            animated_sylva: animated_sylva,
            completion_sylva: completion_sylva
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Sylva(
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        navigate_Sylva(to: EditInfo_Sylva(), style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
    
    /// 跳转到设置页
    static func toSetting_Sylva(
        style_sylva: NavigationStyle_Sylva = .push_sylva,
        animated_sylva: Bool = true
    ) {
        navigate_Sylva(to: Setting_Sylva(), style_sylva: style_sylva, animated_sylva: animated_sylva)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Sylva {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_sylva: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Sylva(from viewController_sylva: UIViewController) {
        let isPresented_sylva = viewController_sylva.presentingViewController != nil
        
        if isPresented_sylva {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_sylva = viewController_sylva.presentingViewController
            viewController_sylva.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_sylva: UINavigationController?
                if let nav_sylva = presentingVC_sylva as? UINavigationController {
                    navVC_sylva = nav_sylva
                } else {
                    navVC_sylva = presentingVC_sylva?.navigationController
                }
                if let nav_sylva = navVC_sylva {
                    popStackToSafeVC_Sylva(nav: nav_sylva)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_sylva = viewController_sylva.navigationController {
                popStackToSafeVC_Sylva(nav: nav_sylva)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Sylva(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_sylva: [AnyClass] = [
            Detail_Sylva.self,
            MessageUser_Sylva.self,
            Home_Sylva.self,
            Discover_Sylva.self,
            Release_Sylva.self,
            MessageList_Sylva.self,
            Me_Sylva.self,
            UserInfo_Sylva.self
        ]
        
        let stack_sylva = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_sylva in stack_sylva.reversed() {
            let isExcluded_sylva = excludedTypes_sylva.contains { vc_sylva.isKind(of: $0) }
            if !isExcluded_sylva {
                // 已经处于安全 VC，无需额外跳转
                if vc_sylva === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_sylva, animated: true)
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
enum NavigationType_Sylva {
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
