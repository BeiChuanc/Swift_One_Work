import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Ornit {
    
    /// Push方式（导航栈推入）
    case push_ornit
    
    /// Present方式（模态展示）
    case present_ornit

    /// Replace方式（替换当前视图控制器）
    case replace_ornit
}

/// 页面导航管理器
class Navigation_Ornit: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Ornit() -> UIViewController? {
        return UIViewController.currentViewController_Ornit()
    }
    
    /// Push方式跳转到指定页面
    static func push_Ornit(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Ornit()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Ornit(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Ornit()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Ornit(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Ornit()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Ornit(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Ornit()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Ornit(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Ornit()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Ornit(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Ornit()
        guard let navigationController_ornit = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_ornit = navigationController_ornit.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_ornit.isEmpty {
            viewControllers_ornit[viewControllers_ornit.count - 1] = viewController
            navigationController_ornit.setViewControllers(viewControllers_ornit, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_ornit.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Ornit(
        viewController_ornit: UIViewController,
        style_ornit: NavigationStyle_Ornit,
        wrapInNavigation_ornit: Bool? = nil,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_ornit = wrapInNavigation_ornit ?? (style_ornit == .present_ornit)
        
        switch style_ornit {
        case .push_ornit:
            push_Ornit(to: viewController_ornit, animated: animated_ornit)
            completion_ornit?()
            
        case .present_ornit:
            let targetVC_ornit = shouldWrapInNavigation_ornit 
                ? createNavigationController_Ornit(rootViewController: viewController_ornit)
                : viewController_ornit
            
            targetVC_ornit.modalPresentationStyle = .fullScreen
            present_Ornit(viewController: targetVC_ornit, animated: animated_ornit, completion: completion_ornit)
            
        case .replace_ornit:
            replace_Ornit(to: viewController_ornit, animated: animated_ornit)
            completion_ornit?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Ornit(rootViewController: UIViewController) -> UINavigationController {
        let nav_ornit = UINavigationController(rootViewController: rootViewController)
        nav_ornit.modalPresentationStyle = .fullScreen
        return nav_ornit
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Ornit(
        to viewController_ornit: UIViewController,
        style_ornit: NavigationStyle_Ornit,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        navigateToViewController_Ornit(
            viewController_ornit: viewController_ornit,
            style_ornit: style_ornit,
            wrapInNavigation_ornit: nil, // 使用智能判断
            animated_ornit: animated_ornit,
            completion_ornit: completion_ornit
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Ornit(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Ornit(window: UIWindow?) {
        guard let validWindow_ornit = validateWindow_Ornit(window) else { return }
        
        let tabbar_ornit = TabBar_Ornit()
        let nav_ornit = UINavigationController(rootViewController: tabbar_ornit)
        nav_ornit.navigationBar.isHidden = true
        
        validWindow_ornit.rootViewController = nav_ornit
        validWindow_ornit.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Ornit(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_ornit = validateWindow_Ornit(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_ornit, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_ornit.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_ornit.rootViewController = viewController
        }
        validWindow_ornit.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Ornit() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Ornit(animated: Bool = true) {
        let window = getAppWindow_Ornit()
        setRootToTabbar_Ornit(window: window)
        
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
    static func toLogin_Ornit(
        style_ornit: NavigationStyle_Ornit = .present_ornit,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        navigate_Ornit(
            to: Login_Ornit(),
            style_ornit: style_ornit,
            animated_ornit: animated_ornit,
            completion_ornit: completion_ornit
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Ornit(
        style_ornit: NavigationStyle_Ornit = .present_ornit,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        navigate_Ornit(
            to: Register_Ornit(),
            style_ornit: style_ornit,
            animated_ornit: animated_ornit,
            completion_ornit: completion_ornit
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Ornit(
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        navigate_Ornit(to: Home_Ornit(), style_ornit: style_ornit, animated_ornit: animated_ornit)
    }

    /// 跳转到四季专题详情页
    /// - Parameter topic_ornit: 目标专题模型
    static func toTopicDetail_Ornit(
        topic_ornit: SeasonalTopic_Ornit,
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        let vc_ornit = TopicDetail_Ornit()
        vc_ornit.topic_Ornit = topic_ornit
        navigate_Ornit(to: vc_ornit, style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Ornit(
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        navigate_Ornit(to: Discover_Ornit(), style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Ornit(
        titleModel_ornit: TitleModel_Ornit,
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        let detailVC_ornit = Detail_Ornit()
        detailVC_ornit.titleModel_Ornit = titleModel_ornit
        navigate_Ornit(to: detailVC_ornit, style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Ornit(
        style_ornit: NavigationStyle_Ornit = .present_ornit,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        navigate_Ornit(
            to: Release_Ornit(),
            style_ornit: style_ornit,
            animated_ornit: animated_ornit,
            completion_ornit: completion_ornit
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Ornit(
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        navigate_Ornit(to: MessageList_Ornit(), style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Ornit(
        with userModel_ornit: PrewUserModel_Ornit,
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        let messageUserVC_ornit = MessageUser_Ornit()
        messageUserVC_ornit.userModel_Ornit = userModel_ornit
        navigate_Ornit(
            to: messageUserVC_ornit,
            style_ornit: style_ornit,
            animated_ornit: animated_ornit,
            completion_ornit: completion_ornit
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Ornit(
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        navigate_Ornit(to: Me_Ornit(), style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Ornit(
        with userModel_ornit: LoginUserModel_Ornit,
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        let meVC_ornit = Me_Ornit()
        meVC_ornit.meModel_Ornit = userModel_ornit
        navigate_Ornit(to: meVC_ornit, style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    /// 跳转到用户信息页（带用户模型）
    /// - Parameter isFromChat_ornit: 是否从聊天页进入（控制消息按钮显示）
    static func toUserInfo_Ornit(
        with userModel_ornit: PrewUserModel_Ornit,
        isFromChat_ornit: Bool = false,
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true,
        completion_ornit: (() -> Void)? = nil
    ) {
        let userInfoVC_ornit = UserInfo_Ornit()
        userInfoVC_ornit.userModel_Ornit = userModel_ornit
        userInfoVC_ornit.isFromChat_Ornit = isFromChat_ornit
        navigate_Ornit(
            to: userInfoVC_ornit,
            style_ornit: style_ornit,
            animated_ornit: animated_ornit,
            completion_ornit: completion_ornit
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Ornit(
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        navigate_Ornit(to: EditInfo_Ornit(), style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
    
    /// 跳转到设置页
    static func toSetting_Ornit(
        style_ornit: NavigationStyle_Ornit = .push_ornit,
        animated_ornit: Bool = true
    ) {
        navigate_Ornit(to: Setting_Ornit(), style_ornit: style_ornit, animated_ornit: animated_ornit)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Ornit {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_ornit: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Ornit(from viewController_ornit: UIViewController) {
        let isPresented_ornit = viewController_ornit.presentingViewController != nil
        
        if isPresented_ornit {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_ornit = viewController_ornit.presentingViewController
            viewController_ornit.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_ornit: UINavigationController?
                if let nav_ornit = presentingVC_ornit as? UINavigationController {
                    navVC_ornit = nav_ornit
                } else {
                    navVC_ornit = presentingVC_ornit?.navigationController
                }
                if let nav_ornit = navVC_ornit {
                    popStackToSafeVC_Ornit(nav: nav_ornit)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_ornit = viewController_ornit.navigationController {
                popStackToSafeVC_Ornit(nav: nav_ornit)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Ornit(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_ornit: [AnyClass] = [
            Detail_Ornit.self,
            MessageUser_Ornit.self,
            Home_Ornit.self,
            Discover_Ornit.self,
            Release_Ornit.self,
            MessageList_Ornit.self,
            Me_Ornit.self
        ]
        
        let stack_ornit = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_ornit in stack_ornit.reversed() {
            let isExcluded_ornit = excludedTypes_ornit.contains { vc_ornit.isKind(of: $0) }
            if !isExcluded_ornit {
                // 已经处于安全 VC，无需额外跳转
                if vc_ornit === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_ornit, animated: true)
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
enum NavigationType_Ornit {
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
