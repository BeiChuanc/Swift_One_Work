import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Posture {
    
    /// Push方式（导航栈推入）
    case push_posture
    
    /// Present方式（模态展示）
    case present_posture

    /// Replace方式（替换当前视图控制器）
    case replace_posture
}

/// 页面导航管理器
class Navigation_Posture: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Posture() -> UIViewController? {
        return UIViewController.currentViewController_Posture()
    }
    
    /// Push方式跳转到指定页面
    static func push_Posture(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Posture()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Posture(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Posture()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Posture(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Posture()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Posture(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Posture()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Posture(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Posture()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Posture(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Posture()
        guard let navigationController_posture = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_posture = navigationController_posture.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_posture.isEmpty {
            viewControllers_posture[viewControllers_posture.count - 1] = viewController
            navigationController_posture.setViewControllers(viewControllers_posture, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_posture.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Posture(
        viewController_posture: UIViewController,
        style_posture: NavigationStyle_Posture,
        wrapInNavigation_posture: Bool? = nil,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_posture = wrapInNavigation_posture ?? (style_posture == .present_posture)
        
        switch style_posture {
        case .push_posture:
            push_Posture(to: viewController_posture, animated: animated_posture)
            completion_posture?()
            
        case .present_posture:
            let targetVC_posture = shouldWrapInNavigation_posture 
                ? createNavigationController_Posture(rootViewController: viewController_posture)
                : viewController_posture
            
            targetVC_posture.modalPresentationStyle = .fullScreen
            present_Posture(viewController: targetVC_posture, animated: animated_posture, completion: completion_posture)
            
        case .replace_posture:
            replace_Posture(to: viewController_posture, animated: animated_posture)
            completion_posture?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Posture(rootViewController: UIViewController) -> UINavigationController {
        let nav_posture = UINavigationController(rootViewController: rootViewController)
        nav_posture.modalPresentationStyle = .fullScreen
        return nav_posture
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Posture(
        to viewController_posture: UIViewController,
        style_posture: NavigationStyle_Posture,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        navigateToViewController_Posture(
            viewController_posture: viewController_posture,
            style_posture: style_posture,
            wrapInNavigation_posture: nil, // 使用智能判断
            animated_posture: animated_posture,
            completion_posture: completion_posture
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Posture(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Posture(window: UIWindow?) {
        guard let validWindow_posture = validateWindow_Posture(window) else { return }
        
        let tabbar_posture = TabBar_Posture()
        let nav_posture = UINavigationController(rootViewController: tabbar_posture)
        nav_posture.navigationBar.isHidden = true
        
        validWindow_posture.rootViewController = nav_posture
        validWindow_posture.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Posture(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_posture = validateWindow_Posture(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_posture, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_posture.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_posture.rootViewController = viewController
        }
        validWindow_posture.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Posture() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Posture(animated: Bool = true) {
        let window = getAppWindow_Posture()
        setRootToTabbar_Posture(window: window)
        
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
    static func toLogin_Posture(
        style_posture: NavigationStyle_Posture = .present_posture,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        navigate_Posture(
            to: Login_Posture(),
            style_posture: style_posture,
            animated_posture: animated_posture,
            completion_posture: completion_posture
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Posture(
        style_posture: NavigationStyle_Posture = .present_posture,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        navigate_Posture(
            to: Register_Posture(),
            style_posture: style_posture,
            animated_posture: animated_posture,
            completion_posture: completion_posture
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: Home_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }

    // MARK: - 话题相关

    /// 跳转到话题详情页
    /// - Parameters:
    ///   - topic_posture: 目标话题模型
    ///   - style_posture: 导航方式
    ///   - animated_posture: 是否动画
    static func toTopicDetail_Posture(
        topic_posture: Topic_Posture,
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        let topicDetailVC_posture = TopicDetail_Posture()
        topicDetailVC_posture.topic_Posture = topic_posture
        navigate_Posture(to: topicDetailVC_posture, style_posture: style_posture, animated_posture: animated_posture)
    }

    // MARK: - 体态计划相关

    /// 跳转到体态档案设置页
    /// - Parameters:
    ///   - style_posture: 导航方式
    ///   - animated_posture: 是否动画
    static func toPlanSetup_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: PlanSetup_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: Discover_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Posture(
        titleModel_posture: TitleModel_Posture,
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        let detailVC_posture = Detail_Posture()
        detailVC_posture.titleModel_Posture = titleModel_posture
        navigate_Posture(to: detailVC_posture, style_posture: style_posture, animated_posture: animated_posture)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Posture(
        style_posture: NavigationStyle_Posture = .present_posture,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        navigate_Posture(
            to: Release_Posture(),
            style_posture: style_posture,
            animated_posture: animated_posture,
            completion_posture: completion_posture
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: MessageList_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Posture(
        with userModel_posture: PrewUserModel_Posture,
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        let messageUserVC_posture = MessageUser_Posture()
        messageUserVC_posture.userModel_Posture = userModel_posture
        navigate_Posture(
            to: messageUserVC_posture,
            style_posture: style_posture,
            animated_posture: animated_posture,
            completion_posture: completion_posture
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: Me_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Posture(
        with userModel_posture: LoginUserModel_Posture,
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        let meVC_posture = Me_Posture()
        meVC_posture.meModel_Posture = userModel_posture
        navigate_Posture(to: meVC_posture, style_posture: style_posture, animated_posture: animated_posture)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Posture(
        with userModel_posture: PrewUserModel_Posture,
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true,
        completion_posture: (() -> Void)? = nil
    ) {
        let userInfoVC_posture = UserInfo_Posture()
        userInfoVC_posture.userModel_Posture = userModel_posture
        navigate_Posture(
            to: userInfoVC_posture,
            style_posture: style_posture,
            animated_posture: animated_posture,
            completion_posture: completion_posture
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: EditInfo_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }
    
    /// 跳转到设置页
    static func toSetting_Posture(
        style_posture: NavigationStyle_Posture = .push_posture,
        animated_posture: Bool = true
    ) {
        navigate_Posture(to: Setting_Posture(), style_posture: style_posture, animated_posture: animated_posture)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Posture {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_posture: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Posture(from viewController_posture: UIViewController) {
        let isPresented_posture = viewController_posture.presentingViewController != nil
        
        if isPresented_posture {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_posture = viewController_posture.presentingViewController
            viewController_posture.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_posture: UINavigationController?
                if let nav_posture = presentingVC_posture as? UINavigationController {
                    navVC_posture = nav_posture
                } else {
                    navVC_posture = presentingVC_posture?.navigationController
                }
                if let nav_posture = navVC_posture {
                    popStackToSafeVC_Posture(nav: nav_posture)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_posture = viewController_posture.navigationController {
                popStackToSafeVC_Posture(nav: nav_posture)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Posture(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_posture: [AnyClass] = [
            Detail_Posture.self,
            MessageUser_Posture.self,
            Home_Posture.self,
            Discover_Posture.self,
            Release_Posture.self,
            MessageList_Posture.self,
            Me_Posture.self
        ]
        
        let stack_posture = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_posture in stack_posture.reversed() {
            let isExcluded_posture = excludedTypes_posture.contains { vc_posture.isKind(of: $0) }
            if !isExcluded_posture {
                // 已经处于安全 VC，无需额外跳转
                if vc_posture === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_posture, animated: true)
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
enum NavigationType_Posture {
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
