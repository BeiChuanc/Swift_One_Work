import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Lumia {
    
    /// Push方式（导航栈推入）
    case push_lumia
    
    /// Present方式（模态展示）
    case present_lumia

    /// Replace方式（替换当前视图控制器）
    case replace_lumia
}

/// 页面导航管理器
class Navigation_Lumia: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Lumia() -> UIViewController? {
        return UIViewController.currentViewController_Lumia()
    }
    
    /// Push方式跳转到指定页面
    static func push_Lumia(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Lumia()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Lumia(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Lumia()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Lumia(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Lumia()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Lumia(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Lumia()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Lumia(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Lumia()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Lumia(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Lumia()
        guard let navigationController_lumia = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_lumia = navigationController_lumia.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_lumia.isEmpty {
            viewControllers_lumia[viewControllers_lumia.count - 1] = viewController
            navigationController_lumia.setViewControllers(viewControllers_lumia, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_lumia.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Lumia(
        viewController_lumia: UIViewController,
        style_lumia: NavigationStyle_Lumia,
        wrapInNavigation_lumia: Bool? = nil,
        animated_lumia: Bool = true,
        completion_lumia: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_lumia = wrapInNavigation_lumia ?? (style_lumia == .present_lumia)
        
        switch style_lumia {
        case .push_lumia:
            push_Lumia(to: viewController_lumia, animated: animated_lumia)
            completion_lumia?()
            
        case .present_lumia:
            let targetVC_lumia = shouldWrapInNavigation_lumia 
                ? createNavigationController_Lumia(rootViewController: viewController_lumia)
                : viewController_lumia
            
            targetVC_lumia.modalPresentationStyle = .fullScreen
            present_Lumia(viewController: targetVC_lumia, animated: animated_lumia, completion: completion_lumia)
            
        case .replace_lumia:
            replace_Lumia(to: viewController_lumia, animated: animated_lumia)
            completion_lumia?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Lumia(rootViewController: UIViewController) -> UINavigationController {
        let nav_lumia = UINavigationController(rootViewController: rootViewController)
        nav_lumia.modalPresentationStyle = .fullScreen
        return nav_lumia
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Lumia(
        to viewController_lumia: UIViewController,
        style_lumia: NavigationStyle_Lumia,
        animated_lumia: Bool = true,
        completion_lumia: (() -> Void)? = nil
    ) {
        navigateToViewController_Lumia(
            viewController_lumia: viewController_lumia,
            style_lumia: style_lumia,
            wrapInNavigation_lumia: nil, // 使用智能判断
            animated_lumia: animated_lumia,
            completion_lumia: completion_lumia
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Lumia(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Lumia(window: UIWindow?) {
        guard let validWindow_lumia = validateWindow_Lumia(window) else { return }
        
        let tabbar_lumia = TabBar_Lumia()
        let nav_lumia = UINavigationController(rootViewController: tabbar_lumia)
        nav_lumia.navigationBar.isHidden = true
        
        validWindow_lumia.rootViewController = nav_lumia
        validWindow_lumia.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Lumia(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_lumia = validateWindow_Lumia(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_lumia, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_lumia.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_lumia.rootViewController = viewController
        }
        validWindow_lumia.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Lumia() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Lumia(animated: Bool = true) {
        let window = getAppWindow_Lumia()
        setRootToTabbar_Lumia(window: window)
        
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
    static func toLogin_Lumia(
        style_lumia: NavigationStyle_Lumia = .present_lumia,
        animated_lumia: Bool = true,
        completion_lumia: (() -> Void)? = nil
    ) {
        navigate_Lumia(
            to: Login_Lumia(),
            style_lumia: style_lumia,
            animated_lumia: animated_lumia,
            completion_lumia: completion_lumia
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Lumia(
        style_lumia: NavigationStyle_Lumia = .present_lumia,
        animated_lumia: Bool = true,
        completion_lumia: (() -> Void)? = nil
    ) {
        navigate_Lumia(
            to: Register_Lumia(),
            style_lumia: style_lumia,
            animated_lumia: animated_lumia,
            completion_lumia: completion_lumia
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Lumia(
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        navigate_Lumia(to: Home_Lumia(), style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Lumia(
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        navigate_Lumia(to: Discover_Lumia(), style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Lumia(
        titleModel_lumia: TitleModel_Lumia,
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        let detailVC_lumia = Detail_Lumia()
        detailVC_lumia.titleModel_Lumia = titleModel_lumia
        navigate_Lumia(to: detailVC_lumia, style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Lumia(
        style_lumia: NavigationStyle_Lumia = .present_lumia,
        animated_lumia: Bool = true,
        completion_lumia: (() -> Void)? = nil
    ) {
        navigate_Lumia(
            to: Release_Lumia(),
            style_lumia: style_lumia,
            animated_lumia: animated_lumia,
            completion_lumia: completion_lumia
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Lumia(
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        navigate_Lumia(to: MessageList_Lumia(), style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Lumia(
        with userModel_lumia: PrewUserModel_Lumia,
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true,
        completion_lumia: (() -> Void)? = nil
    ) {
        let messageUserVC_lumia = MessageUser_Lumia()
        messageUserVC_lumia.userModel_Lumia = userModel_lumia
        navigate_Lumia(
            to: messageUserVC_lumia,
            style_lumia: style_lumia,
            animated_lumia: animated_lumia,
            completion_lumia: completion_lumia
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Lumia(
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        navigate_Lumia(to: Me_Lumia(), style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Lumia(
        with userModel_lumia: LoginUserModel_Lumia,
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        let meVC_lumia = Me_Lumia()
        meVC_lumia.meModel_Lumia = userModel_lumia
        navigate_Lumia(to: meVC_lumia, style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Lumia(
        with userModel_lumia: PrewUserModel_Lumia,
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true,
        fromMessage_lumia: Bool = false,
        completion_lumia: (() -> Void)? = nil
    ) {
        let userInfoVC_lumia = UserInfo_Lumia()
        userInfoVC_lumia.userModel_Lumia = userModel_lumia
        userInfoVC_lumia.fromMessagePage_Lumia = fromMessage_lumia
        navigate_Lumia(
            to: userInfoVC_lumia,
            style_lumia: style_lumia,
            animated_lumia: animated_lumia,
            completion_lumia: completion_lumia
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Lumia(
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        navigate_Lumia(to: EditInfo_Lumia(), style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
    
    /// 跳转到设置页
    static func toSetting_Lumia(
        style_lumia: NavigationStyle_Lumia = .push_lumia,
        animated_lumia: Bool = true
    ) {
        navigate_Lumia(to: Setting_Lumia(), style_lumia: style_lumia, animated_lumia: animated_lumia)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Lumia {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_lumia: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Lumia(from viewController_lumia: UIViewController) {
        let isPresented_lumia = viewController_lumia.presentingViewController != nil
        
        if isPresented_lumia {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_lumia = viewController_lumia.presentingViewController
            viewController_lumia.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_lumia: UINavigationController?
                if let nav_lumia = presentingVC_lumia as? UINavigationController {
                    navVC_lumia = nav_lumia
                } else {
                    navVC_lumia = presentingVC_lumia?.navigationController
                }
                if let nav_lumia = navVC_lumia {
                    popStackToSafeVC_Lumia(nav: nav_lumia)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_lumia = viewController_lumia.navigationController {
                popStackToSafeVC_Lumia(nav: nav_lumia)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Lumia(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_lumia: [AnyClass] = [
            Detail_Lumia.self,
            MessageUser_Lumia.self,
            Home_Lumia.self,
            Discover_Lumia.self,
            Release_Lumia.self,
            MessageList_Lumia.self,
            Me_Lumia.self
        ]
        
        let stack_lumia = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_lumia in stack_lumia.reversed() {
            let isExcluded_lumia = excludedTypes_lumia.contains { vc_lumia.isKind(of: $0) }
            if !isExcluded_lumia {
                // 已经处于安全 VC，无需额外跳转
                if vc_lumia === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_lumia, animated: true)
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
enum NavigationType_Lumia {
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
