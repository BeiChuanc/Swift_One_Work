import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Retrs {
    
    /// Push方式（导航栈推入）
    case push_retrs
    
    /// Present方式（模态展示）
    case present_retrs

    /// Replace方式（替换当前视图控制器）
    case replace_retrs
}

/// 页面导航管理器
class Navigation_Retrs: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Retrs() -> UIViewController? {
        return UIViewController.currentViewController_Retrs()
    }
    
    /// Push方式跳转到指定页面
    static func push_Retrs(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Retrs()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Retrs(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Retrs()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Retrs(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Retrs()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Retrs(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Retrs()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Retrs(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Retrs()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Retrs(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Retrs()
        guard let navigationController_retrs = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_retrs = navigationController_retrs.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_retrs.isEmpty {
            viewControllers_retrs[viewControllers_retrs.count - 1] = viewController
            navigationController_retrs.setViewControllers(viewControllers_retrs, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_retrs.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Retrs(
        viewController_retrs: UIViewController,
        style_retrs: NavigationStyle_Retrs,
        wrapInNavigation_retrs: Bool? = nil,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_retrs = wrapInNavigation_retrs ?? (style_retrs == .present_retrs)
        
        switch style_retrs {
        case .push_retrs:
            push_Retrs(to: viewController_retrs, animated: animated_retrs)
            completion_retrs?()
            
        case .present_retrs:
            let targetVC_retrs = shouldWrapInNavigation_retrs 
                ? createNavigationController_Retrs(rootViewController: viewController_retrs)
                : viewController_retrs
            
            targetVC_retrs.modalPresentationStyle = .fullScreen
            present_Retrs(viewController: targetVC_retrs, animated: animated_retrs, completion: completion_retrs)
            
        case .replace_retrs:
            replace_Retrs(to: viewController_retrs, animated: animated_retrs)
            completion_retrs?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Retrs(rootViewController: UIViewController) -> UINavigationController {
        let nav_retrs = UINavigationController(rootViewController: rootViewController)
        nav_retrs.modalPresentationStyle = .fullScreen
        return nav_retrs
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Retrs(
        to viewController_retrs: UIViewController,
        style_retrs: NavigationStyle_Retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        navigateToViewController_Retrs(
            viewController_retrs: viewController_retrs,
            style_retrs: style_retrs,
            wrapInNavigation_retrs: nil, // 使用智能判断
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Retrs(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Retrs(window: UIWindow?) {
        guard let validWindow_retrs = validateWindow_Retrs(window) else { return }
        
        let tabbar_retrs = TabBar_Retrs()
        let nav_retrs = UINavigationController(rootViewController: tabbar_retrs)
        nav_retrs.navigationBar.isHidden = true
        
        validWindow_retrs.rootViewController = nav_retrs
        validWindow_retrs.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Retrs(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_retrs = validateWindow_Retrs(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_retrs, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_retrs.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_retrs.rootViewController = viewController
        }
        validWindow_retrs.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Retrs() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Retrs(animated: Bool = true) {
        let window = getAppWindow_Retrs()
        setRootToTabbar_Retrs(window: window)
        
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
    static func toLogin_Retrs(
        style_retrs: NavigationStyle_Retrs = .present_retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        navigate_Retrs(
            to: Login_Retrs(),
            style_retrs: style_retrs,
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Retrs(
        style_retrs: NavigationStyle_Retrs = .present_retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        navigate_Retrs(
            to: Register_Retrs(),
            style_retrs: style_retrs,
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: Home_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: Discover_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Retrs(
        titleModel_retrs: TitleModel_Retrs,
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        let detailVC_retrs = Detail_Retrs()
        detailVC_retrs.titleModel_Retrs = titleModel_retrs
        navigate_Retrs(to: detailVC_retrs, style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Retrs(
        style_retrs: NavigationStyle_Retrs = .present_retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        navigate_Retrs(
            to: Release_Retrs(),
            style_retrs: style_retrs,
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }
    
    /// 跳转到"我的CCD技巧库"新增条目页（独立于通用发布页 Release_Retrs）
    static func toDiaryPublish_Retrs(
        style_retrs: NavigationStyle_Retrs = .present_retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        navigate_Retrs(
            to: DiaryPublish_Retrs(),
            style_retrs: style_retrs,
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }

    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: MessageList_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Retrs(
        with userModel_retrs: PrewUserModel_Retrs,
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        let messageUserVC_retrs = MessageUser_Retrs()
        messageUserVC_retrs.userModel_Retrs = userModel_retrs
        navigate_Retrs(
            to: messageUserVC_retrs,
            style_retrs: style_retrs,
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: Me_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Retrs(
        with userModel_retrs: LoginUserModel_Retrs,
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        let meVC_retrs = Me_Retrs()
        meVC_retrs.meModel_Retrs = userModel_retrs
        navigate_Retrs(to: meVC_retrs, style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Retrs(
        with userModel_retrs: PrewUserModel_Retrs,
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true,
        completion_retrs: (() -> Void)? = nil
    ) {
        let userInfoVC_retrs = UserInfo_Retrs()
        userInfoVC_retrs.userModel_Retrs = userModel_retrs
        navigate_Retrs(
            to: userInfoVC_retrs,
            style_retrs: style_retrs,
            animated_retrs: animated_retrs,
            completion_retrs: completion_retrs
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: EditInfo_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }
    
    /// 跳转到设置页
    static func toSetting_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: Setting_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }

    /// 跳转到 VIP 订阅页
    static func toVIPSubscription_Retrs(
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        navigate_Retrs(to: VIPSubscription_Retrs(), style_retrs: style_retrs, animated_retrs: animated_retrs)
    }

    /// 跳转到主题活动详情页
    static func toActivityDetail_Retrs(
        activity_Retrs: ThemeActivity_Retrs,
        style_retrs: NavigationStyle_Retrs = .push_retrs,
        animated_retrs: Bool = true
    ) {
        let vc_Retrs = ActivityDetail_Retrs()
        vc_Retrs.activity_Retrs = activity_Retrs
        navigate_Retrs(to: vc_Retrs, style_retrs: style_retrs, animated_retrs: animated_retrs)
    }

    /// 弹出送礼界面
    static func toGiftPage_Retrs(
        with userModel_retrs: PrewUserModel_Retrs? = nil,
        animated_retrs: Bool = true
    ) {
        let vc_Retrs = GiftPage_Retrs()
        vc_Retrs.modalPresentationStyle = .overFullScreen
        vc_Retrs.modalTransitionStyle   = .crossDissolve
        present_Retrs(viewController: vc_Retrs, animated: animated_retrs)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Retrs {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_retrs: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Retrs(from viewController_retrs: UIViewController) {
        let isPresented_retrs = viewController_retrs.presentingViewController != nil
        
        if isPresented_retrs {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_retrs = viewController_retrs.presentingViewController
            viewController_retrs.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_retrs: UINavigationController?
                if let nav_retrs = presentingVC_retrs as? UINavigationController {
                    navVC_retrs = nav_retrs
                } else {
                    navVC_retrs = presentingVC_retrs?.navigationController
                }
                if let nav_retrs = navVC_retrs {
                    popStackToSafeVC_Retrs(nav: nav_retrs)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_retrs = viewController_retrs.navigationController {
                popStackToSafeVC_Retrs(nav: nav_retrs)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Retrs(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_retrs: [AnyClass] = [
            Detail_Retrs.self,
            MessageUser_Retrs.self,
            Home_Retrs.self,
            Discover_Retrs.self,
            Release_Retrs.self,
            MessageList_Retrs.self,
            Me_Retrs.self
        ]
        
        let stack_retrs = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_retrs in stack_retrs.reversed() {
            let isExcluded_retrs = excludedTypes_retrs.contains { vc_retrs.isKind(of: $0) }
            if !isExcluded_retrs {
                // 已经处于安全 VC，无需额外跳转
                if vc_retrs === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_retrs, animated: true)
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
enum NavigationType_Retrs {
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
