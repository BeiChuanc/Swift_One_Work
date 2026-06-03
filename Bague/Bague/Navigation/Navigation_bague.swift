import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Bague {
    
    /// Push方式（导航栈推入）
    case push_bague
    
    /// Present方式（模态展示）
    case present_bague

    /// Replace方式（替换当前视图控制器）
    case replace_bague
}

/// 页面导航管理器
class Navigation_Bague: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Bague() -> UIViewController? {
        return UIViewController.currentViewController_Bague()
    }
    
    /// Push方式跳转到指定页面
    static func push_Bague(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Bague()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Bague(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Bague()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Bague(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Bague()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Bague(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Bague()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Bague(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Bague()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Bague(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Bague()
        guard let navigationController_bague = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_bague = navigationController_bague.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_bague.isEmpty {
            viewControllers_bague[viewControllers_bague.count - 1] = viewController
            navigationController_bague.setViewControllers(viewControllers_bague, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_bague.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Bague(
        viewController_bague: UIViewController,
        style_bague: NavigationStyle_Bague,
        wrapInNavigation_bague: Bool? = nil,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_bague = wrapInNavigation_bague ?? (style_bague == .present_bague)
        
        switch style_bague {
        case .push_bague:
            push_Bague(to: viewController_bague, animated: animated_bague)
            completion_bague?()
            
        case .present_bague:
            let targetVC_bague = shouldWrapInNavigation_bague 
                ? createNavigationController_Bague(rootViewController: viewController_bague)
                : viewController_bague
            
            targetVC_bague.modalPresentationStyle = .fullScreen
            present_Bague(viewController: targetVC_bague, animated: animated_bague, completion: completion_bague)
            
        case .replace_bague:
            replace_Bague(to: viewController_bague, animated: animated_bague)
            completion_bague?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Bague(rootViewController: UIViewController) -> UINavigationController {
        let nav_bague = UINavigationController(rootViewController: rootViewController)
        nav_bague.modalPresentationStyle = .fullScreen
        return nav_bague
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Bague(
        to viewController_bague: UIViewController,
        style_bague: NavigationStyle_Bague,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        navigateToViewController_Bague(
            viewController_bague: viewController_bague,
            style_bague: style_bague,
            wrapInNavigation_bague: nil, // 使用智能判断
            animated_bague: animated_bague,
            completion_bague: completion_bague
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Bague(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Bague(window: UIWindow?) {
        guard let validWindow_bague = validateWindow_Bague(window) else { return }
        
        let tabbar_bague = TabBar_Bague()
        let nav_bague = UINavigationController(rootViewController: tabbar_bague)
        nav_bague.navigationBar.isHidden = true
        
        validWindow_bague.rootViewController = nav_bague
        validWindow_bague.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Bague(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_bague = validateWindow_Bague(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_bague, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_bague.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_bague.rootViewController = viewController
        }
        validWindow_bague.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Bague() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Bague(animated: Bool = true) {
        let window = getAppWindow_Bague()
        setRootToTabbar_Bague(window: window)
        
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
    static func toLogin_Bague(
        style_bague: NavigationStyle_Bague = .present_bague,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        navigate_Bague(
            to: Login_Bague(),
            style_bague: style_bague,
            animated_bague: animated_bague,
            completion_bague: completion_bague
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Bague(
        style_bague: NavigationStyle_Bague = .present_bague,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        navigate_Bague(
            to: Register_Bague(),
            style_bague: style_bague,
            animated_bague: animated_bague,
            completion_bague: completion_bague
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Bague(
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        navigate_Bague(to: Home_Bague(), style_bague: style_bague, animated_bague: animated_bague)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Bague(
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        navigate_Bague(to: Discover_Bague(), style_bague: style_bague, animated_bague: animated_bague)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Bague(
        titleModel_bague: TitleModel_Bague,
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        let detailVC_bague = Detail_Bague()
        detailVC_bague.titleModel_Bague = titleModel_bague
        navigate_Bague(to: detailVC_bague, style_bague: style_bague, animated_bague: animated_bague)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Bague(
        style_bague: NavigationStyle_Bague = .present_bague,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        navigate_Bague(
            to: Release_Bague(),
            style_bague: style_bague,
            animated_bague: animated_bague,
            completion_bague: completion_bague
        )
    }
    
    // MARK: - 功能特色页面

    /// 跳转到我的藏包册
    static func toCollectionBook_Bague() {
        push_Bague(to: CollectionBook_Bague())
    }

    /// 跳转到中古故事馆列表
    static func toVintageStory_Bague() {
        push_Bague(to: VintageStoryList_Bague())
    }

    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Bague(
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        navigate_Bague(to: MessageList_Bague(), style_bague: style_bague, animated_bague: animated_bague)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Bague(
        with userModel_bague: PrewUserModel_Bague,
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        let messageUserVC_bague = MessageUser_Bague()
        messageUserVC_bague.userModel_Bague = userModel_bague
        navigate_Bague(
            to: messageUserVC_bague,
            style_bague: style_bague,
            animated_bague: animated_bague,
            completion_bague: completion_bague
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Bague(
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        navigate_Bague(to: Me_Bague(), style_bague: style_bague, animated_bague: animated_bague)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Bague(
        with userModel_bague: LoginUserModel_Bague,
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        let meVC_bague = Me_Bague()
        meVC_bague.meModel_Bague = userModel_bague
        navigate_Bague(to: meVC_bague, style_bague: style_bague, animated_bague: animated_bague)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Bague(
        with userModel_bague: PrewUserModel_Bague,
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true,
        completion_bague: (() -> Void)? = nil
    ) {
        let userInfoVC_bague = UserInfo_Bague()
        userInfoVC_bague.userModel_Bague = userModel_bague
        navigate_Bague(
            to: userInfoVC_bague,
            style_bague: style_bague,
            animated_bague: animated_bague,
            completion_bague: completion_bague
        )
    }
    
    /// 跳转到用户信息页（从聊天页进入，不显示消息按钮）
    static func toUserInfoFromChat_Bague(
        with userModel_bague: PrewUserModel_Bague,
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        let userInfoVC_bague = UserInfo_Bague()
        userInfoVC_bague.userModel_Bague = userModel_bague
        userInfoVC_bague.fromChat_Bague = true
        navigate_Bague(to: userInfoVC_bague, style_bague: style_bague, animated_bague: animated_bague)
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Bague(
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        navigate_Bague(to: EditInfo_Bague(), style_bague: style_bague, animated_bague: animated_bague)
    }
    
    /// 跳转到设置页
    static func toSetting_Bague(
        style_bague: NavigationStyle_Bague = .push_bague,
        animated_bague: Bool = true
    ) {
        navigate_Bague(to: Setting_Bague(), style_bague: style_bague, animated_bague: animated_bague)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Bague {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_bague: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Bague(from viewController_bague: UIViewController) {
        let isPresented_bague = viewController_bague.presentingViewController != nil
        
        if isPresented_bague {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_bague = viewController_bague.presentingViewController
            viewController_bague.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_bague: UINavigationController?
                if let nav_bague = presentingVC_bague as? UINavigationController {
                    navVC_bague = nav_bague
                } else {
                    navVC_bague = presentingVC_bague?.navigationController
                }
                if let nav_bague = navVC_bague {
                    popStackToSafeVC_Bague(nav: nav_bague)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_bague = viewController_bague.navigationController {
                popStackToSafeVC_Bague(nav: nav_bague)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Bague(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_bague: [AnyClass] = [
            Detail_Bague.self,
            MessageUser_Bague.self,
            Home_Bague.self,
            Discover_Bague.self,
            Release_Bague.self,
            MessageList_Bague.self,
            Me_Bague.self
        ]
        
        let stack_bague = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_bague in stack_bague.reversed() {
            let isExcluded_bague = excludedTypes_bague.contains { vc_bague.isKind(of: $0) }
            if !isExcluded_bague {
                // 已经处于安全 VC，无需额外跳转
                if vc_bague === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_bague, animated: true)
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
enum NavigationType_Bague {
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
