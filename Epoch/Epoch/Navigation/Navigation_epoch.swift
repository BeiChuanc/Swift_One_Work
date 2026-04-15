import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Epoch {
    
    /// Push方式（导航栈推入）
    case push_epoch
    
    /// Present方式（模态展示）
    case present_epoch

    /// Replace方式（替换当前视图控制器）
    case replace_epoch
}

/// 用户中心入口来源
enum UserInfoEntrySource_Epoch {
    /// 默认入口
    case normal_epoch
    /// 聊天入口
    case message_epoch
    /// 视频通话入口
    case videoCall_epoch
}

/// 页面导航管理器
class Navigation_Epoch: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Epoch() -> UIViewController? {
        return UIViewController.currentViewController_Epoch()
    }
    
    /// Push方式跳转到指定页面
    static func push_Epoch(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Epoch()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Epoch(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Epoch()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Epoch(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Epoch()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Epoch(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Epoch()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Epoch(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Epoch()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Epoch(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Epoch()
        guard let navigationController_epoch = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_epoch = navigationController_epoch.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_epoch.isEmpty {
            viewControllers_epoch[viewControllers_epoch.count - 1] = viewController
            navigationController_epoch.setViewControllers(viewControllers_epoch, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_epoch.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Epoch(
        viewController_epoch: UIViewController,
        style_epoch: NavigationStyle_Epoch,
        wrapInNavigation_epoch: Bool? = nil,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_epoch = wrapInNavigation_epoch ?? (style_epoch == .present_epoch)
        
        switch style_epoch {
        case .push_epoch:
            push_Epoch(to: viewController_epoch, animated: animated_epoch)
            completion_epoch?()
            
        case .present_epoch:
            let targetVC_epoch = shouldWrapInNavigation_epoch 
                ? createNavigationController_Epoch(rootViewController: viewController_epoch)
                : viewController_epoch
            
            targetVC_epoch.modalPresentationStyle = .fullScreen
            present_Epoch(viewController: targetVC_epoch, animated: animated_epoch, completion: completion_epoch)
            
        case .replace_epoch:
            replace_Epoch(to: viewController_epoch, animated: animated_epoch)
            completion_epoch?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Epoch(rootViewController: UIViewController) -> UINavigationController {
        let nav_epoch = UINavigationController(rootViewController: rootViewController)
        nav_epoch.modalPresentationStyle = .fullScreen
        return nav_epoch
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Epoch(
        to viewController_epoch: UIViewController,
        style_epoch: NavigationStyle_Epoch,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        navigateToViewController_Epoch(
            viewController_epoch: viewController_epoch,
            style_epoch: style_epoch,
            wrapInNavigation_epoch: nil, // 使用智能判断
            animated_epoch: animated_epoch,
            completion_epoch: completion_epoch
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Epoch(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Epoch(window: UIWindow?, selectedIndex_epoch: Int = 0) {
        guard let validWindow_epoch = validateWindow_Epoch(window) else { return }
        
        let tabbar_epoch = TabBar_Epoch()
        tabbar_epoch.loadViewIfNeeded()
        tabbar_epoch.selectTab_Epoch(index_epoch: selectedIndex_epoch)
        let nav_epoch = UINavigationController(rootViewController: tabbar_epoch)
        nav_epoch.navigationBar.isHidden = true
        
        validWindow_epoch.rootViewController = nav_epoch
        validWindow_epoch.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Epoch(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_epoch = validateWindow_Epoch(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_epoch, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_epoch.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_epoch.rootViewController = viewController
        }
        validWindow_epoch.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Epoch() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Epoch(animated: Bool = true, selectedIndex_epoch: Int = 0) {
        let window = getAppWindow_Epoch()
        setRootToTabbar_Epoch(window: window, selectedIndex_epoch: selectedIndex_epoch)
        
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
    static func toLogin_Epoch(
        style_epoch: NavigationStyle_Epoch = .present_epoch,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        navigate_Epoch(
            to: Login_Epoch(),
            style_epoch: style_epoch,
            animated_epoch: animated_epoch,
            completion_epoch: completion_epoch
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Epoch(
        style_epoch: NavigationStyle_Epoch = .present_epoch,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        navigate_Epoch(
            to: Register_Epoch(),
            style_epoch: style_epoch,
            animated_epoch: animated_epoch,
            completion_epoch: completion_epoch
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Epoch(
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        navigate_Epoch(to: Home_Epoch(), style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Epoch(
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        navigate_Epoch(to: Discover_Epoch(), style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Epoch(
        titleModel_epoch: TitleModel_Epoch,
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        let detailVC_epoch = Detail_Epoch()
        detailVC_epoch.titleModel_Epoch = titleModel_epoch
        navigate_Epoch(to: detailVC_epoch, style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Epoch(
        style_epoch: NavigationStyle_Epoch = .present_epoch,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        navigate_Epoch(
            to: Release_Epoch(),
            style_epoch: style_epoch,
            animated_epoch: animated_epoch,
            completion_epoch: completion_epoch
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Epoch(
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        navigate_Epoch(to: MessageList_Epoch(), style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Epoch(
        with userModel_epoch: PrewUserModel_Epoch,
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        let messageUserVC_epoch = MessageUser_Epoch()
        messageUserVC_epoch.userModel_Epoch = userModel_epoch
        navigate_Epoch(
            to: messageUserVC_epoch,
            style_epoch: style_epoch,
            animated_epoch: animated_epoch,
            completion_epoch: completion_epoch
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Epoch(
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        navigate_Epoch(to: Me_Epoch(), style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Epoch(
        with userModel_epoch: LoginUserModel_Epoch,
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        let meVC_epoch = Me_Epoch()
        meVC_epoch.meModel_Epoch = userModel_epoch
        navigate_Epoch(to: meVC_epoch, style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Epoch(
        with userModel_epoch: PrewUserModel_Epoch,
        entrySource_epoch: UserInfoEntrySource_Epoch = .normal_epoch,
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true,
        completion_epoch: (() -> Void)? = nil
    ) {
        let userInfoVC_epoch = UserInfo_Epoch()
        userInfoVC_epoch.userModel_Epoch = userModel_epoch
        userInfoVC_epoch.entrySource_Epoch = entrySource_epoch
        navigate_Epoch(
            to: userInfoVC_epoch,
            style_epoch: style_epoch,
            animated_epoch: animated_epoch,
            completion_epoch: completion_epoch
        )
    }


    /// 跳转到编辑信息页
    static func toEditInfo_Epoch(
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        navigate_Epoch(to: EditInfo_Epoch(), style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
    
    /// 跳转到设置页
    static func toSetting_Epoch(
        style_epoch: NavigationStyle_Epoch = .push_epoch,
        animated_epoch: Bool = true
    ) {
        navigate_Epoch(to: Setting_Epoch(), style_epoch: style_epoch, animated_epoch: animated_epoch)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Epoch {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_epoch: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Epoch(from viewController_epoch: UIViewController) {
        let isPresented_epoch = viewController_epoch.presentingViewController != nil
        
        if isPresented_epoch {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_epoch = viewController_epoch.presentingViewController
            viewController_epoch.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_epoch: UINavigationController?
                if let nav_epoch = presentingVC_epoch as? UINavigationController {
                    navVC_epoch = nav_epoch
                } else {
                    navVC_epoch = presentingVC_epoch?.navigationController
                }
                if let nav_epoch = navVC_epoch {
                    popStackToSafeVC_Epoch(nav: nav_epoch)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_epoch = viewController_epoch.navigationController {
                popStackToSafeVC_Epoch(nav: nav_epoch)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Epoch(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_epoch: [AnyClass] = [
            Detail_Epoch.self,
            MessageUser_Epoch.self,
            Home_Epoch.self,
            Discover_Epoch.self,
            Release_Epoch.self,
            MessageList_Epoch.self,
            Me_Epoch.self
        ]
        
        let stack_epoch = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_epoch in stack_epoch.reversed() {
            let isExcluded_epoch = excludedTypes_epoch.contains { vc_epoch.isKind(of: $0) }
            if !isExcluded_epoch {
                // 已经处于安全 VC，无需额外跳转
                if vc_epoch === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_epoch, animated: true)
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
enum NavigationType_Epoch {
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
