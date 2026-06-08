import Foundation
import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Hush {
    
    /// Push方式（导航栈推入）
    case push_hush
    
    /// Present方式（模态展示）
    case present_hush

    /// Replace方式（替换当前视图控制器）
    case replace_hush
}

/// 页面导航管理器
class Navigation_Hush: NSObject {
    
    // MARK: - 基础导航方法
    
    /// 获取当前显示的视图控制器
    static func currentViewController_Hush() -> UIViewController? {
        return UIViewController.currentViewController_Hush()
    }
    
    /// Push方式跳转到指定页面
    static func push_Hush(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Hush()
        fromVC?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Present方式展示指定页面
    static func present_Hush(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Hush()
        fromVC?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Pop返回上一页
    static func pop_Hush(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Hush()
        fromVC?.navigationController?.popViewController(animated: animated)
    }
    
    /// Pop返回到根视图控制器
    static func popToRoot_Hush(animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Hush()
        fromVC?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss关闭当前模态页面
    static func dismiss_Hush(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Hush()
        fromVC?.dismiss(animated: animated, completion: completion)
    }
    
    /// Replace方式替换当前页面
    static func replace_Hush(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        let fromVC = from ?? currentViewController_Hush()
        guard let navigationController_hush = fromVC?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }
        
        // 获取当前导航栈
        var viewControllers_hush = navigationController_hush.viewControllers
        
        // 替换最后一个视图控制器
        if !viewControllers_hush.isEmpty {
            viewControllers_hush[viewControllers_hush.count - 1] = viewController
            navigationController_hush.setViewControllers(viewControllers_hush, animated: animated)
        } else {
            // 如果导航栈为空，直接push
            navigationController_hush.pushViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - 通用导航方法
    
    /// 根据导航方式跳转到指定页面
    static func navigateToViewController_Hush(
        viewController_hush: UIViewController,
        style_hush: NavigationStyle_Hush,
        wrapInNavigation_hush: Bool? = nil,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        // 智能判断是否需要包装导航控制器：present 模式默认包装，其他模式默认不包装
        let shouldWrapInNavigation_hush = wrapInNavigation_hush ?? (style_hush == .present_hush)
        
        switch style_hush {
        case .push_hush:
            push_Hush(to: viewController_hush, animated: animated_hush)
            completion_hush?()
            
        case .present_hush:
            let targetVC_hush = shouldWrapInNavigation_hush 
                ? createNavigationController_Hush(rootViewController: viewController_hush)
                : viewController_hush
            
            targetVC_hush.modalPresentationStyle = .fullScreen
            present_Hush(viewController: targetVC_hush, animated: animated_hush, completion: completion_hush)
            
        case .replace_hush:
            replace_Hush(to: viewController_hush, animated: animated_hush)
            completion_hush?()
        }
    }
    
    /// 创建导航控制器
    private static func createNavigationController_Hush(rootViewController: UIViewController) -> UINavigationController {
        let nav_hush = UINavigationController(rootViewController: rootViewController)
        nav_hush.modalPresentationStyle = .fullScreen
        return nav_hush
    }
    
    /// 通用的页面跳转方法（简化版）
    private static func navigate_Hush(
        to viewController_hush: UIViewController,
        style_hush: NavigationStyle_Hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        navigateToViewController_Hush(
            viewController_hush: viewController_hush,
            style_hush: style_hush,
            wrapInNavigation_hush: nil, // 使用智能判断
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    // MARK: - 主导航
    
    /// 验证 Window 是否有效
    private static func validateWindow_Hush(_ window: UIWindow?) -> UIWindow? {
        guard let window = window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }
    
    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Hush(window: UIWindow?) {
        guard let validWindow_hush = validateWindow_Hush(window) else { return }
        
        let tabbar_hush = TabBar_Hush()
        let nav_hush = UINavigationController(rootViewController: tabbar_hush)
        nav_hush.navigationBar.isHidden = true
        
        validWindow_hush.rootViewController = nav_hush
        validWindow_hush.makeKeyAndVisible()
    }
    
    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Hush(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let validWindow_hush = validateWindow_Hush(window) else { return }
        
        if animated {
            // 添加过渡动画
            UIView.transition(with: validWindow_hush, duration: 0.3, options: .transitionCrossDissolve, animations: {
                validWindow_hush.rootViewController = viewController
            }, completion: nil)
        } else {
            validWindow_hush.rootViewController = viewController
        }
        validWindow_hush.makeKeyAndVisible()
    }
    
    /// 获取AppDelegate中的Window
    static func getAppWindow_Hush() -> UIWindow? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.window
        }
        return nil
    }
    
    /// 切换到主Tabbar（从其他地方调用，自动获取Window）
    static func switchToTabbar_Hush(animated: Bool = true) {
        let window = getAppWindow_Hush()
        setRootToTabbar_Hush(window: window)
        
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
    static func toLogin_Hush(
        style_hush: NavigationStyle_Hush = .present_hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        navigate_Hush(
            to: Login_Hush(),
            style_hush: style_hush,
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    /// 跳转到注册页
    static func toRegister_Hush(
        style_hush: NavigationStyle_Hush = .present_hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        navigate_Hush(
            to: Register_Hush(),
            style_hush: style_hush,
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    // MARK: - 首页相关
    
    /// 跳转到首页
    static func toHome_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: Home_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }
    
    // MARK: - 发现页相关
    
    /// 跳转到发现页
    static func toDiscover_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: Discover_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }
    
    /// 跳转到帖子详情页
    static func toTitleDetail_Hush(
        titleModel_hush: TitleModel_Hush,
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        let detailVC_hush = Detail_Hush()
        detailVC_hush.titleModel_Hush = titleModel_hush
        navigate_Hush(to: detailVC_hush, style_hush: style_hush, animated_hush: animated_hush)
    }
    
    // MARK: - 发布相关
    
    /// 跳转到发布页
    static func toRelease_Hush(
        style_hush: NavigationStyle_Hush = .present_hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        navigate_Hush(
            to: Release_Hush(),
            style_hush: style_hush,
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    // MARK: - 消息相关
    
    /// 跳转到消息列表
    static func toMessageList_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: MessageList_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }
    
    /// 跳转到用户消息聊天页（带用户模型）
    static func toMessageUser_Hush(
        with userModel_hush: PrewUserModel_Hush,
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        let messageUserVC_hush = MessageUser_Hush()
        messageUserVC_hush.userModel_Hush = userModel_hush
        navigate_Hush(
            to: messageUserVC_hush,
            style_hush: style_hush,
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    // MARK: - 个人中心相关
    
    /// 跳转到个人中心（当前登录用户）
    static func toMe_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: Me_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }
    
    /// 跳转到个人中心（带登录用户模型）
    static func toMe_Hush(
        with userModel_hush: LoginUserModel_Hush,
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        let meVC_hush = Me_Hush()
        meVC_hush.meModel_Hush = userModel_hush
        navigate_Hush(to: meVC_hush, style_hush: style_hush, animated_hush: animated_hush)
    }
    
    /// 跳转到用户信息页（带用户模型）
    static func toUserInfo_Hush(
        with userModel_hush: PrewUserModel_Hush,
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        let userInfoVC_hush = UserInfo_Hush()
        userInfoVC_hush.userModel_Hush = userModel_hush
        navigate_Hush(
            to: userInfoVC_hush,
            style_hush: style_hush,
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    /// 跳转到用户信息页（支持聊天场景入口标识）
    /// - Parameter fromChat_hush: 是否从聊天页进入（true 时隐藏消息按钮，关注按钮居中显示）
    static func toUserInfo_Hush(
        with userModel_hush: PrewUserModel_Hush,
        fromChat_hush: Bool,
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true,
        completion_hush: (() -> Void)? = nil
    ) {
        let userInfoVC_hush = UserInfo_Hush()
        userInfoVC_hush.userModel_Hush = userModel_hush
        userInfoVC_hush.fromChat_Hush = fromChat_hush
        navigate_Hush(
            to: userInfoVC_hush,
            style_hush: style_hush,
            animated_hush: animated_hush,
            completion_hush: completion_hush
        )
    }
    
    /// 跳转到编辑信息页
    static func toEditInfo_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: EditInfo_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }
    
    /// 跳转到设置页
    static func toSetting_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: Setting_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }

    /// 跳转到 VIP 订阅页
    static func toVIPSubscription_Hush(
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        navigate_Hush(to: VIPSubscription_Hush(), style_hush: style_hush, animated_hush: animated_hush)
    }
    
    // MARK: - 时间胶囊相关
    
    /// 跳转到时间胶囊创建页
    /// - Parameters:
    ///   - style_hush: 导航方式（默认 present）
    ///   - onPlanted_hush: 成功创建后的回调
    static func toTimeCapsuleCreate_Hush(
        style_hush: NavigationStyle_Hush = .present_hush,
        animated_hush: Bool = true,
        onPlanted_hush: (() -> Void)? = nil
    ) {
        let vc_hush = TimeCapsuleCreate_Hush()
        vc_hush.onCapsulePlanted_Hush = onPlanted_hush
        navigate_Hush(
            to: vc_hush,
            style_hush: style_hush,
            animated_hush: animated_hush
        )
    }
    
    // MARK: - 季节挑战相关
    
    /// 跳转到季节挑战详情/评论页
    /// - Parameters:
    ///   - challengeModel_hush: 挑战数据模型
    ///   - style_hush: 导航方式（默认 push）
    static func toSeasonChallengeDetail_Hush(
        challengeModel_hush: SeasonChallengeModel_Hush,
        style_hush: NavigationStyle_Hush = .push_hush,
        animated_hush: Bool = true
    ) {
        let vc_hush = SeasonChallengeDetail_Hush()
        vc_hush.challengeModel_Hush = challengeModel_hush
        navigate_Hush(to: vc_hush, style_hush: style_hush, animated_hush: animated_hush)
    }
    
    // MARK: - 全屏媒体浏览
    
    /// 跳转到全屏媒体浏览页（图片缩放 / 视频播放）
    /// - Parameters:
    ///   - mediaPath_hush: 媒体路径（Assets 名 / 网络 URL / Documents 文件名）
    ///   - isVideo_hush: 是否强制视频模式，false 时由页面自动检测
    ///   - style_hush: 导航方式（默认 present，黑底沉浸式体验）
    static func toMediaPlayer_Hush(
        mediaPath_hush: String?,
        isVideo_hush: Bool = false,
        style_hush: NavigationStyle_Hush = .present_hush,
        animated_hush: Bool = true
    ) {
        let vc_hush = MediaPlayerPage_Hush()
        vc_hush.mediaPath_Hush = mediaPath_hush
        vc_hush.isVideo_Hush = isVideo_hush
        vc_hush.modalPresentationStyle = .overFullScreen
        vc_hush.modalTransitionStyle = .crossDissolve
        // 使用 present 直接展示，不经过导航栈包装
        present_Hush(viewController: vc_hush, animated: animated_hush)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Hush {
    
    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的所有页面并返回安全位置
    /// 处理两种情形：
    ///   1. 当前 VC 以 present 方式展示（如视频通话）：先 dismiss，再操作 presentingVC 的导航栈
    ///   2. 当前 VC 在导航栈中（如帖子详情、消息聊天）：直接在导航栈中 pop 到安全位置
    /// 安全位置定义：导航栈中最靠近栈顶、且不属于"用户相关页面"及"TabBar 五个子页面"的控制器
    /// - Parameter viewController_hush: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Hush(from viewController_hush: UIViewController) {
        let isPresented_hush = viewController_hush.presentingViewController != nil
        
        if isPresented_hush {
            // 模态展示的情形（如视频通话）：先记录 presentingVC，再执行 dismiss
            let presentingVC_hush = viewController_hush.presentingViewController
            viewController_hush.dismiss(animated: true) {
                // dismiss 完成后，从 presentingVC 取导航控制器
                let navVC_hush: UINavigationController?
                if let nav_hush = presentingVC_hush as? UINavigationController {
                    navVC_hush = nav_hush
                } else {
                    navVC_hush = presentingVC_hush?.navigationController
                }
                if let nav_hush = navVC_hush {
                    popStackToSafeVC_Hush(nav: nav_hush)
                }
            }
        } else {
            // 普通 push 情形：直接操作当前导航栈
            if let nav_hush = viewController_hush.navigationController {
                popStackToSafeVC_Hush(nav: nav_hush)
            }
        }
    }
    
    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除的 VC 类型：帖子详情（Detail）、消息聊天（MessageUser）、
    ///               以及 TabBar 的五个子页面（Home / Discover / Release / MessageList / Me）
    /// 若栈中全为排除类型，则 popToRoot（回到 TabBar）
    /// - Parameter nav: 目标导航控制器
    private static func popStackToSafeVC_Hush(nav: UINavigationController) {
        // 需要从目标堆栈中排除的页面类型
        let excludedTypes_hush: [AnyClass] = [
            Detail_Hush.self,
            MessageUser_Hush.self,
            Home_Hush.self,
            Discover_Hush.self,
            Release_Hush.self,
            MessageList_Hush.self,
            Me_Hush.self
        ]
        
        let stack_hush = nav.viewControllers
        // 从栈顶往栈底寻找第一个不在排除列表中的安全 VC
        for vc_hush in stack_hush.reversed() {
            let isExcluded_hush = excludedTypes_hush.contains { vc_hush.isKind(of: $0) }
            if !isExcluded_hush {
                // 已经处于安全 VC，无需额外跳转
                if vc_hush === nav.topViewController {
                    return
                }
                nav.popToViewController(vc_hush, animated: true)
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
enum NavigationType_Hush {
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
