import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Breeze {
    
    /// Push方式（导航栈推入）
    case push_breeze
    
    /// Present方式（模态展示）
    case present_breeze

    /// Replace方式（替换当前视图控制器）
    case replace_breeze
}

/// 页面导航管理器
class Navigation_Breeze: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Breeze() -> UIViewController? {
        return UIViewController.currentViewController_Breeze()
    }
    
    /// Push方式跳转到指定页面
    static func push_Breeze(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Breeze()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Breeze(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Breeze()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Breeze(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Breeze()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Breeze(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Breeze()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Breeze(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Breeze()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Breeze(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Breeze()
        guard let navigationController_breeze = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_breeze = navigationController_breeze.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_breeze.isEmpty {
            viewControllers_breeze[viewControllers_breeze.count - 1] = viewController
            navigationController_breeze.setViewControllers(viewControllers_breeze, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_breeze.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Breeze(
        viewController_breeze: UIViewController,
        style_breeze: NavigationStyle_Breeze,
        wrapInNavigation_breeze: Bool? = nil,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_breeze = wrapInNavigation_breeze ?? (style_breeze == .present_breeze)
        
        switch style_breeze {
        case .push_breeze:
            push_Breeze(to: viewController_breeze, animated: animated_breeze)
            completion_breeze?()
            
        case .present_breeze:
            let targetVC_breeze = shouldWrapInNavigation_breeze 
                ? createNavigationController_Breeze(rootViewController: viewController_breeze)
                : viewController_breeze
            
            targetVC_breeze.modalPresentationStyle = .fullScreen
            present_Breeze(viewController: targetVC_breeze, animated: animated_breeze, completion: completion_breeze)
            
        case .replace_breeze:
            replace_Breeze(to: viewController_breeze, animated: animated_breeze)
            completion_breeze?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Breeze(rootViewController: UIViewController) -> UINavigationController {
        let nav_breeze = UINavigationController(rootViewController: rootViewController)
        nav_breeze.modalPresentationStyle = .fullScreen
        return nav_breeze
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Breeze(
        to viewController_breeze: UIViewController,
        style_breeze: NavigationStyle_Breeze,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        navigateToViewController_Breeze(
            viewController_breeze: viewController_breeze,
            style_breeze: style_breeze,
            wrapInNavigation_breeze: nil, // 使用智能判断
            animated_breeze: animated_breeze,
            completion_breeze: completion_breeze
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Breeze(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Breeze(window: UIWindow?) {
        guard let validWindow_breeze = validateWindow_Breeze(window) else { return }
        
        let tabbar_breeze = TabBar_Breeze()
        let nav_breeze = UINavigationController(rootViewController: tabbar_breeze)
        nav_breeze.navigationBar.isHidden = true
        
        validWindow_breeze.rootViewController = nav_breeze
        validWindow_breeze.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Breeze(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_breeze = validateWindow_Breeze(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_breeze, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_breeze.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_breeze.rootViewController = viewController
        }
        validWindow_breeze.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Breeze() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Breeze(animated: Bool = true) {
        let window = getAppWindow_Breeze()
        setRootToTabbar_Breeze(window: window)
        
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
    static func toLogin_Breeze(
        style_breeze: NavigationStyle_Breeze = .present_breeze,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        navigate_Breeze(
            to: Login_Breeze(),
            style_breeze: style_breeze,
            animated_breeze: animated_breeze,
            completion_breeze: completion_breeze
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Breeze(
        style_breeze: NavigationStyle_Breeze = .present_breeze,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        navigate_Breeze(
            to: Register_Breeze(),
            style_breeze: style_breeze,
            animated_breeze: animated_breeze,
            completion_breeze: completion_breeze
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: Home_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    // MARK: - 相册页相关
    
    /// 跳转到个人露营相册页
    static func toAlbumPage_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: AlbumPage_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: Discover_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Breeze(
        titleModel_breeze: TitleModel_Breeze,
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        let detailVC_breeze = Detail_Breeze()
        detailVC_breeze.titleModel_Breeze = titleModel_breeze
        navigate_Breeze(to: detailVC_breeze, style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Breeze(
        style_breeze: NavigationStyle_Breeze = .present_breeze,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        navigate_Breeze(
            to: Release_Breeze(),
            style_breeze: style_breeze,
            animated_breeze: animated_breeze,
            completion_breeze: completion_breeze
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: MessageList_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Breeze(
        with userModel_breeze: PrewUserModel_Breeze,
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        let messageUserVC_breeze = MessageUser_Breeze()
        messageUserVC_breeze.userModel_Breeze = userModel_breeze
        navigate_Breeze(
            to: messageUserVC_breeze,
            style_breeze: style_breeze,
            animated_breeze: animated_breeze,
            completion_breeze: completion_breeze
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: Me_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Breeze(
        with userModel_breeze: LoginUserModel_Breeze,
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        let meVC_breeze = Me_Breeze()
        meVC_breeze.meModel_Breeze = userModel_breeze
        navigate_Breeze(to: meVC_breeze, style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    /// 跳转到用户信息页（带用户模型）
    /// - Parameter fromChat_breeze: 是否从聊天页进入（隐藏消息按钮、关注按钮居中，取消关注返回消息列表）
    static func toUserInfo_Breeze(
        with userModel_breeze: PrewUserModel_Breeze,
        fromChat_breeze: Bool = false,
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true,
        completion_breeze: (() -> Void)? = nil
    ) {
        let userInfoVC_breeze = UserInfo_Breeze()
        userInfoVC_breeze.userModel_Breeze = userModel_breeze
        userInfoVC_breeze.isFromChat_Breeze = fromChat_breeze
        navigate_Breeze(
            to: userInfoVC_breeze,
            style_breeze: style_breeze,
            animated_breeze: animated_breeze,
            completion_breeze: completion_breeze
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: EditInfo_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
    
    /// 跳转到设置页
    static func toSetting_Breeze(
        style_breeze: NavigationStyle_Breeze = .push_breeze,
        animated_breeze: Bool = true
    ) {
        navigate_Breeze(to: Setting_Breeze(), style_breeze: style_breeze, animated_breeze: animated_breeze)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Breeze {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_breeze: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Breeze(from viewController_breeze: UIViewController) {
        let isPresented_breeze = viewController_breeze.presentingViewController != nil
        
        if isPresented_breeze {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_breeze = viewController_breeze.presentingViewController
            viewController_breeze.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_breeze: UINavigationController?
                if let nav_breeze = presentingVC_breeze as? UINavigationController {
                    navVC_breeze = nav_breeze
                } else {
                    navVC_breeze = presentingVC_breeze?.navigationController
                }
                if let nav_breeze = navVC_breeze {
                    popStackToSafeVC_Breeze(nav: nav_breeze)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_breeze = viewController_breeze.navigationController {
                popStackToSafeVC_Breeze(nav: nav_breeze)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Breeze(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_breeze: [AnyClass] = [
            Detail_Breeze.self,
            MessageUser_Breeze.self,
            Home_Breeze.self,
            Discover_Breeze.self,
            Release_Breeze.self,
            MessageList_Breeze.self,
            Me_Breeze.self
        ]
        
        let stack_breeze = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_breeze in stack_breeze.reversed() {
            let isExcluded_breeze = excludedTypes_breeze.contains { vc_breeze.isKind(of: $0) }
            if !isExcluded_breeze {
                // 已经处于安全 VC，无需额外跳转
                if vc_breeze === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_breeze, animated: true)
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
enum NavigationType_Breeze {
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
