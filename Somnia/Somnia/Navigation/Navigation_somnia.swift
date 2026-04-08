import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Somnia {
    
    /// Push方式（导航栈推入）
    case push_somnia
    
    /// Present方式（模态展示）
    case present_somnia

    /// Replace方式（替换当前视图控制器）
    case replace_somnia
}

/// 页面导航管理器
class Navigation_Somnia: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Somnia() -> UIViewController? {
        return UIViewController.currentViewController_Somnia()
    }
    
    /// Push方式跳转到指定页面
    static func push_Somnia(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Somnia()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Somnia(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Somnia()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Somnia(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Somnia()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Somnia(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Somnia()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Somnia(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Somnia()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Somnia(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Somnia()
        guard let navigationController_somnia = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_somnia = navigationController_somnia.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_somnia.isEmpty {
            viewControllers_somnia[viewControllers_somnia.count - 1] = viewController
            navigationController_somnia.setViewControllers(viewControllers_somnia, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_somnia.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Somnia(
        viewController_somnia: UIViewController,
        style_somnia: NavigationStyle_Somnia,
        wrapInNavigation_somnia: Bool? = nil,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_somnia = wrapInNavigation_somnia ?? (style_somnia == .present_somnia)
        
        switch style_somnia {
        case .push_somnia:
            push_Somnia(to: viewController_somnia, animated: animated_somnia)
            completion_somnia?()
            
        case .present_somnia:
            let targetVC_somnia = shouldWrapInNavigation_somnia 
                ? createNavigationController_Somnia(rootViewController: viewController_somnia)
                : viewController_somnia
            
            targetVC_somnia.modalPresentationStyle = .fullScreen
            present_Somnia(viewController: targetVC_somnia, animated: animated_somnia, completion: completion_somnia)
            
        case .replace_somnia:
            replace_Somnia(to: viewController_somnia, animated: animated_somnia)
            completion_somnia?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Somnia(rootViewController: UIViewController) -> UINavigationController {
        let nav_somnia = UINavigationController(rootViewController: rootViewController)
        nav_somnia.modalPresentationStyle = .fullScreen
        return nav_somnia
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Somnia(
        to viewController_somnia: UIViewController,
        style_somnia: NavigationStyle_Somnia,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        navigateToViewController_Somnia(
            viewController_somnia: viewController_somnia,
            style_somnia: style_somnia,
            wrapInNavigation_somnia: nil, // 使用智能判断
            animated_somnia: animated_somnia,
            completion_somnia: completion_somnia
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Somnia(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Somnia(window: UIWindow?) {
        guard let validWindow_somnia = validateWindow_Somnia(window) else { return }
        
        let tabbar_somnia = TabBar_Somnia()
        let nav_somnia = UINavigationController(rootViewController: tabbar_somnia)
        nav_somnia.navigationBar.isHidden = true
        
        validWindow_somnia.rootViewController = nav_somnia
        validWindow_somnia.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Somnia(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_somnia = validateWindow_Somnia(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_somnia, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_somnia.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_somnia.rootViewController = viewController
        }
        validWindow_somnia.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Somnia() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Somnia(animated: Bool = true) {
        let window = getAppWindow_Somnia()
        setRootToTabbar_Somnia(window: window)
        
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
    static func toLogin_Somnia(
        style_somnia: NavigationStyle_Somnia = .present_somnia,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        navigate_Somnia(
            to: Login_Somnia(),
            style_somnia: style_somnia,
            animated_somnia: animated_somnia,
            completion_somnia: completion_somnia
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Somnia(
        style_somnia: NavigationStyle_Somnia = .present_somnia,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        navigate_Somnia(
            to: Register_Somnia(),
            style_somnia: style_somnia,
            animated_somnia: animated_somnia,
            completion_somnia: completion_somnia
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: Home_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: Discover_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Somnia(
        titleModel_somnia: TitleModel_Somnia,
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        let detailVC_somnia = Detail_Somnia()
        detailVC_somnia.titleModel_Somnia = titleModel_somnia
        navigate_Somnia(to: detailVC_somnia, style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Somnia(
        style_somnia: NavigationStyle_Somnia = .present_somnia,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        navigate_Somnia(
            to: Release_Somnia(),
            style_somnia: style_somnia,
            animated_somnia: animated_somnia,
            completion_somnia: completion_somnia
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: MessageList_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Somnia(
        with userModel_somnia: PrewUserModel_Somnia,
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        let messageUserVC_somnia = MessageUser_Somnia()
        messageUserVC_somnia.userModel_Somnia = userModel_somnia
        navigate_Somnia(
            to: messageUserVC_somnia,
            style_somnia: style_somnia,
            animated_somnia: animated_somnia,
            completion_somnia: completion_somnia
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: Me_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Somnia(
        with userModel_somnia: LoginUserModel_Somnia,
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        let meVC_somnia = Me_Somnia()
        meVC_somnia.meModel_Somnia = userModel_somnia
        navigate_Somnia(to: meVC_somnia, style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Somnia(
        with userModel_somnia: PrewUserModel_Somnia,
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true,
        completion_somnia: (() -> Void)? = nil
    ) {
        let userInfoVC_somnia = UserInfo_Somnia()
        userInfoVC_somnia.userModel_Somnia = userModel_somnia
        navigate_Somnia(
            to: userInfoVC_somnia,
            style_somnia: style_somnia,
            animated_somnia: animated_somnia,
            completion_somnia: completion_somnia
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: EditInfo_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
    
    /// 跳转到设置页
    static func toSetting_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: Setting_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }

    /// 跳转到 VIP 订阅页面
    /// - Parameters:
    ///   - style_somnia: 导航方式，默认 push
    ///   - animated_somnia: 是否有动画
    static func toVIPSubscription_Somnia(
        style_somnia: NavigationStyle_Somnia = .push_somnia,
        animated_somnia: Bool = true
    ) {
        navigate_Somnia(to: VIPSubscription_Somnia(), style_somnia: style_somnia, animated_somnia: animated_somnia)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Somnia {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_somnia: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Somnia(from viewController_somnia: UIViewController) {
        let isPresented_somnia = viewController_somnia.presentingViewController != nil
        
        if isPresented_somnia {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_somnia = viewController_somnia.presentingViewController
            viewController_somnia.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_somnia: UINavigationController?
                if let nav_somnia = presentingVC_somnia as? UINavigationController {
                    navVC_somnia = nav_somnia
                } else {
                    navVC_somnia = presentingVC_somnia?.navigationController
                }
                if let nav_somnia = navVC_somnia {
                    popStackToSafeVC_Somnia(nav: nav_somnia)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_somnia = viewController_somnia.navigationController {
                popStackToSafeVC_Somnia(nav: nav_somnia)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Somnia(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        // UserInfo_Somnia 同样加入排除：从聊天页举报后不应停留在用户中心
        let excludedTypes_somnia: [AnyClass] = [
            Detail_Somnia.self,
            MessageUser_Somnia.self,
            UserInfo_Somnia.self,
            Home_Somnia.self,
            Discover_Somnia.self,
            Release_Somnia.self,
            MessageList_Somnia.self,
            Me_Somnia.self
        ]
        
        let stack_somnia = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_somnia in stack_somnia.reversed() {
            let isExcluded_somnia = excludedTypes_somnia.contains { vc_somnia.isKind(of: $0) }
            if !isExcluded_somnia {
                // 已经处于安全 VC，无需额外跳转
                if vc_somnia === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_somnia, animated: true)
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
enum NavigationType_Somnia {
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
