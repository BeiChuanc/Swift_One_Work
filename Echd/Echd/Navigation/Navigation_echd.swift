import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Echd {
    
    /// Push方式（导航栈推入）
    case push_echd
    
    /// Present方式（模态展示）
    case present_echd

    /// Replace方式（替换当前视图控制器）
    case replace_echd
}

/// 页面导航管理器
class Navigation_Echd: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Echd() -> UIViewController? {
        return UIViewController.currentViewController_Echd()
    }
    
    /// Push方式跳转到指定页面
    static func push_Echd(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Echd()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Echd(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Echd()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Echd(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Echd()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Echd(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Echd()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Echd(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Echd()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Echd(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Echd()
        guard let navigationController_echd = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_echd = navigationController_echd.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_echd.isEmpty {
            viewControllers_echd[viewControllers_echd.count - 1] = viewController
            navigationController_echd.setViewControllers(viewControllers_echd, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_echd.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Echd(
        viewController_echd: UIViewController,
        style_echd: NavigationStyle_Echd,
        wrapInNavigation_echd: Bool? = nil,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_echd = wrapInNavigation_echd ?? (style_echd == .present_echd)
        
        switch style_echd {
        case .push_echd:
            push_Echd(to: viewController_echd, animated: animated_echd)
            completion_echd?()
            
        case .present_echd:
            let targetVC_echd = shouldWrapInNavigation_echd 
                ? createNavigationController_Echd(rootViewController: viewController_echd)
                : viewController_echd
            
            targetVC_echd.modalPresentationStyle = .fullScreen
            present_Echd(viewController: targetVC_echd, animated: animated_echd, completion: completion_echd)
            
        case .replace_echd:
            replace_Echd(to: viewController_echd, animated: animated_echd)
            completion_echd?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Echd(rootViewController: UIViewController) -> UINavigationController {
        let nav_echd = UINavigationController(rootViewController: rootViewController)
        nav_echd.modalPresentationStyle = .fullScreen
        return nav_echd
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Echd(
        to viewController_echd: UIViewController,
        style_echd: NavigationStyle_Echd,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        navigateToViewController_Echd(
            viewController_echd: viewController_echd,
            style_echd: style_echd,
            wrapInNavigation_echd: nil, // 使用智能判断
            animated_echd: animated_echd,
            completion_echd: completion_echd
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Echd(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Echd(window: UIWindow?) {
        guard let validWindow_echd = validateWindow_Echd(window) else { return }
        
        let tabbar_echd = TabBar_Echd()
        let nav_echd = UINavigationController(rootViewController: tabbar_echd)
        nav_echd.navigationBar.isHidden = true
        
        validWindow_echd.rootViewController = nav_echd
        validWindow_echd.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Echd(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_echd = validateWindow_Echd(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_echd, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_echd.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_echd.rootViewController = viewController
        }
        validWindow_echd.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Echd() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Echd(animated: Bool = true) {
        let window = getAppWindow_Echd()
        setRootToTabbar_Echd(window: window)
        
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
    static func toLogin_Echd(
        style_echd: NavigationStyle_Echd = .present_echd,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        navigate_Echd(
            to: Login_Echd(),
            style_echd: style_echd,
            animated_echd: animated_echd,
            completion_echd: completion_echd
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Echd(
        style_echd: NavigationStyle_Echd = .present_echd,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        navigate_Echd(
            to: Register_Echd(),
            style_echd: style_echd,
            animated_echd: animated_echd,
            completion_echd: completion_echd
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Echd(
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        navigate_Echd(to: Home_Echd(), style_echd: style_echd, animated_echd: animated_echd)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Echd(
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        navigate_Echd(to: Discover_Echd(), style_echd: style_echd, animated_echd: animated_echd)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Echd(
        titleModel_echd: TitleModel_Echd,
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        let detailVC_echd = Detail_Echd()
        detailVC_echd.titleModel_Echd = titleModel_echd
        navigate_Echd(to: detailVC_echd, style_echd: style_echd, animated_echd: animated_echd)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Echd(
        style_echd: NavigationStyle_Echd = .present_echd,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        navigate_Echd(
            to: Release_Echd(),
            style_echd: style_echd,
            animated_echd: animated_echd,
            completion_echd: completion_echd
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Echd(
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        navigate_Echd(to: MessageList_Echd(), style_echd: style_echd, animated_echd: animated_echd)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Echd(
        with userModel_echd: PrewUserModel_Echd,
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        let messageUserVC_echd = MessageUser_Echd()
        messageUserVC_echd.userModel_Echd = userModel_echd
        navigate_Echd(
            to: messageUserVC_echd,
            style_echd: style_echd,
            animated_echd: animated_echd,
            completion_echd: completion_echd
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Echd(
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        navigate_Echd(to: Me_Echd(), style_echd: style_echd, animated_echd: animated_echd)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Echd(
        with userModel_echd: LoginUserModel_Echd,
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        let meVC_echd = Me_Echd()
        meVC_echd.meModel_Echd = userModel_echd
        navigate_Echd(to: meVC_echd, style_echd: style_echd, animated_echd: animated_echd)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Echd(
        with userModel_echd: PrewUserModel_Echd,
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true,
        completion_echd: (() -> Void)? = nil
    ) {
        let userInfoVC_echd = UserInfo_Echd()
        userInfoVC_echd.userModel_Echd = userModel_echd
        navigate_Echd(
            to: userInfoVC_echd,
            style_echd: style_echd,
            animated_echd: animated_echd,
            completion_echd: completion_echd
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Echd(
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        navigate_Echd(to: EditInfo_Echd(), style_echd: style_echd, animated_echd: animated_echd)
    }
    
    /// 跳转到设置页
    static func toSetting_Echd(
        style_echd: NavigationStyle_Echd = .push_echd,
        animated_echd: Bool = true
    ) {
        navigate_Echd(to: Setting_Echd(), style_echd: style_echd, animated_echd: animated_echd)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Echd {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_echd: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Echd(from viewController_echd: UIViewController) {
        let isPresented_echd = viewController_echd.presentingViewController != nil
        
        if isPresented_echd {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_echd = viewController_echd.presentingViewController
            viewController_echd.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_echd: UINavigationController?
                if let nav_echd = presentingVC_echd as? UINavigationController {
                    navVC_echd = nav_echd
                } else {
                    navVC_echd = presentingVC_echd?.navigationController
                }
                if let nav_echd = navVC_echd {
                    popStackToSafeVC_Echd(nav: nav_echd)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_echd = viewController_echd.navigationController {
                popStackToSafeVC_Echd(nav: nav_echd)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Echd(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_echd: [AnyClass] = [
            Detail_Echd.self,
            MessageUser_Echd.self,
            Home_Echd.self,
            Discover_Echd.self,
            Release_Echd.self,
            MessageList_Echd.self,
            Me_Echd.self
        ]
        
        let stack_echd = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_echd in stack_echd.reversed() {
            let isExcluded_echd = excludedTypes_echd.contains { vc_echd.isKind(of: $0) }
            if !isExcluded_echd {
                // 已经处于安全 VC，无需额外跳转
                if vc_echd === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_echd, animated: true)
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
enum NavigationType_Echd {
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
