import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Maki {
    /// Push方式（导航栈推入）
    case push_maki
    /// Present方式（模态展示）
    case present_maki
    /// Replace方式（替换当前视图控制器）
    case replace_maki
}

/// 页面导航管理器
/// 功能：统一管理 Push、Present、Replace 及根视图切换
/// 设计：静态方法门面，页面跳转全部收敛到此类
class Navigation_Maki: NSObject {

    // MARK: - 基础导航方法

    /// 获取当前显示的视图控制器
    static func currentViewController_Maki() -> UIViewController? {
        UIViewController.currentViewController_Maki()
    }

    /// 解析来源控制器（未指定时取当前顶层 VC）
    /// 参数：
    /// - from: 指定来源控制器，nil 时自动获取当前顶层
    private static func resolveSourceVC_Maki(from: UIViewController?) -> UIViewController? {
        from ?? currentViewController_Maki()
    }

    /// Push方式跳转到指定页面
    static func push_Maki(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Maki(from: from)?.navigationController?.pushViewController(viewController, animated: animated)
    }

    /// Present方式展示指定页面
    static func present_Maki(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Maki(from: from)?.present(viewController, animated: animated, completion: completion)
    }

    /// Pop返回上一页
    static func pop_Maki(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Maki(from: from)?.navigationController?.popViewController(animated: animated)
    }

    /// Pop返回到根视图控制器
    static func popToRoot_Maki(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Maki(from: from)?.navigationController?.popToRootViewController(animated: animated)
    }

    /// Dismiss关闭当前模态页面
    static func dismiss_Maki(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Maki(from: from)?.dismiss(animated: animated, completion: completion)
    }

    /// Replace方式替换当前页面
    static func replace_Maki(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        guard let nav_maki = resolveSourceVC_Maki(from: from)?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }

        var stack_maki = nav_maki.viewControllers
        if stack_maki.isEmpty {
            nav_maki.pushViewController(viewController, animated: animated)
        } else {
            stack_maki[stack_maki.count - 1] = viewController
            nav_maki.setViewControllers(stack_maki, animated: animated)
        }
    }

    // MARK: - 通用导航方法

    /// 根据导航方式跳转到指定页面
    /// 参数：
    /// - viewController_maki: 目标页面
    /// - style_maki: 导航方式
    /// - wrapInNavigation_maki: 是否包装导航控制器，nil 时 present 默认包装
    /// - animated_maki: 是否动画
    /// - completion_maki: 完成回调
    static func navigateToViewController_Maki(
        viewController_maki: UIViewController,
        style_maki: NavigationStyle_Maki,
        wrapInNavigation_maki: Bool? = nil,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        let shouldWrap_maki = wrapInNavigation_maki ?? (style_maki == .present_maki)

        switch style_maki {
        case .push_maki:
            push_Maki(to: viewController_maki, animated: animated_maki)
            completion_maki?()

        case .present_maki:
            let targetVC_maki = shouldWrap_maki
                ? createNavigationController_Maki(rootViewController: viewController_maki)
                : viewController_maki
            targetVC_maki.modalPresentationStyle = .fullScreen
            present_Maki(viewController: targetVC_maki, animated: animated_maki, completion: completion_maki)

        case .replace_maki:
            replace_Maki(to: viewController_maki, animated: animated_maki)
            completion_maki?()
        }
    }

    /// 创建全屏导航控制器
    private static func createNavigationController_Maki(rootViewController: UIViewController) -> UINavigationController {
        let nav_maki = UINavigationController(rootViewController: rootViewController)
        nav_maki.modalPresentationStyle = .fullScreen
        return nav_maki
    }

    /// 页面跳转简化入口（自动判断是否包装导航控制器）
    private static func navigate_Maki(
        to viewController_maki: UIViewController,
        style_maki: NavigationStyle_Maki,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        navigateToViewController_Maki(
            viewController_maki: viewController_maki,
            style_maki: style_maki,
            animated_maki: animated_maki,
            completion_maki: completion_maki
        )
    }

    // MARK: - 主导航

    /// 验证 Window 是否有效
    private static func validateWindow_Maki(_ window: UIWindow?) -> UIWindow? {
        guard let window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }

    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Maki(window: UIWindow?) {
        guard let window_maki = validateWindow_Maki(window) else { return }

        let nav_maki = UINavigationController(rootViewController: TabBar_Maki())
        nav_maki.navigationBar.isHidden = true
        window_maki.rootViewController = nav_maki
        window_maki.makeKeyAndVisible()
    }

    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Maki(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let window_maki = validateWindow_Maki(window) else { return }

        let applyRoot_maki = { window_maki.rootViewController = viewController }
        if animated {
            UIView.transition(with: window_maki, duration: 0.3, options: .transitionCrossDissolve, animations: applyRoot_maki)
        } else {
            applyRoot_maki()
        }
        window_maki.makeKeyAndVisible()
    }

    /// 获取 AppDelegate 中的 Window
    static func getAppWindow_Maki() -> UIWindow? {
        (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    /// 切换到主 Tabbar（自动获取 Window）
    static func switchToTabbar_Maki(animated: Bool = true) {
        let window_maki = getAppWindow_Maki()
        setRootToTabbar_Maki(window: window_maki)

        guard animated else { return }
        window_maki?.alpha = 0
        UIView.animate(withDuration: 0.3) { window_maki?.alpha = 1 }
    }

    // MARK: - 登录注册

    static func toLogin_Maki(
        style_maki: NavigationStyle_Maki = .present_maki,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        navigate_Maki(to: Login_Maki(), style_maki: style_maki, animated_maki: animated_maki, completion_maki: completion_maki)
    }

    static func toRegister_Maki(
        style_maki: NavigationStyle_Maki = .present_maki,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        navigate_Maki(to: Register_Maki(), style_maki: style_maki, animated_maki: animated_maki, completion_maki: completion_maki)
    }

    // MARK: - 首页 / 发现

    static func toHome_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: Home_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    static func toDiscover_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: Discover_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    /// 以 overFullScreen 方式展示发现页搜索覆盖层
    static func toDiscoverSearch_Maki(from viewController_maki: UIViewController? = nil) {
        let searchVC_maki = SearchPage_Maki()
        searchVC_maki.modalPresentationStyle = .overFullScreen
        searchVC_maki.modalTransitionStyle   = .crossDissolve
        let sourceVC_maki = viewController_maki ?? currentViewController_Maki()
        sourceVC_maki?.present(searchVC_maki, animated: false)
    }

    static func toTitleDetail_Maki(
        titleModel_maki: TitleModel_Maki,
        style_maki: NavigationStyle_Maki = .push_maki,
        animated_maki: Bool = true
    ) {
        let detailVC_maki = Detail_Maki()
        detailVC_maki.titleModel_Maki = titleModel_maki
        navigate_Maki(to: detailVC_maki, style_maki: style_maki, animated_maki: animated_maki)
    }

    /// 以透明模态方式展示送礼界面。
    /// - 参数：from_maki：发起展示的页面；为空时使用当前可见页面。
    /// - 返回值：无。
    /// - 异常场景：当前页面不可用时不执行展示。
    static func toGiftPage_maki(from_maki: UIViewController? = nil) {
        let giftPage_maki = GiftPage_Maki()
        giftPage_maki.modalPresentationStyle = .overFullScreen
        giftPage_maki.modalTransitionStyle = .crossDissolve
        present_Maki(viewController: giftPage_maki, animated: true, from: from_maki)
    }

    // MARK: - 发布

    static func toRelease_Maki(
        style_maki: NavigationStyle_Maki = .present_maki,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        navigate_Maki(to: Release_Maki(), style_maki: style_maki, animated_maki: animated_maki, completion_maki: completion_maki)
    }

    // MARK: - 消息

    static func toMessageList_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: MessageList_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    static func toMessageUser_Maki(
        with userModel_maki: PrewUserModel_Maki,
        style_maki: NavigationStyle_Maki = .push_maki,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        let messageUserVC_maki = MessageUser_Maki()
        messageUserVC_maki.userModel_Maki = userModel_maki
        navigate_Maki(to: messageUserVC_maki, style_maki: style_maki, animated_maki: animated_maki, completion_maki: completion_maki)
    }

    /// 全屏展示与指定用户的视频通话界面。
    /// - 参数：userModel_maki：通话对象；from_maki：发起展示的页面；animated_maki：是否显示转场动画。
    /// - 返回值：无。
    /// - 异常场景：发起页面不可用时不执行展示。
    static func toVideoChat_maki(
        with userModel_maki: PrewUserModel_Maki,
        from_maki: UIViewController? = nil,
        animated_maki: Bool = true
    ) {
        let videoChat_maki = VideoChat_Maki()
        videoChat_maki.userModel_Maki = userModel_maki
        videoChat_maki.modalPresentationStyle = .fullScreen
        present_Maki(viewController: videoChat_maki, animated: animated_maki, from: from_maki)
    }

    // MARK: - 个人中心

    static func toMe_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: Me_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    static func toMe_Maki(
        with userModel_maki: LoginUserModel_Maki,
        style_maki: NavigationStyle_Maki = .push_maki,
        animated_maki: Bool = true
    ) {
        let meVC_maki = Me_Maki()
        meVC_maki.meModel_Maki = userModel_maki
        navigate_Maki(to: meVC_maki, style_maki: style_maki, animated_maki: animated_maki)
    }

    static func toUserInfo_Maki(
        with userModel_maki: PrewUserModel_Maki,
        style_maki: NavigationStyle_Maki = .push_maki,
        animated_maki: Bool = true,
        completion_maki: (() -> Void)? = nil
    ) {
        let userInfoVC_maki = UserInfo_Maki()
        userInfoVC_maki.userModel_Maki = userModel_maki
        navigate_Maki(to: userInfoVC_maki, style_maki: style_maki, animated_maki: animated_maki, completion_maki: completion_maki)
    }

    static func toEditInfo_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: EditInfo_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    static func toSetting_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: Setting_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    /// 跳转到 VIP 订阅页面。
    /// - 参数：style_maki：页面跳转方式；animated_maki：是否显示跳转动画。
    /// - 返回值：无。
    /// - 异常场景：无。
    static func toVipSubscription_maki(
        style_maki: NavigationStyle_Maki = .push_maki,
        animated_maki: Bool = true
    ) {
        navigate_Maki(to: VIPSubscription_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    // MARK: - 手作时光胶囊 / 成长阶梯

    /// 跳转到封存新胶囊页面
    static func toCreateCapsule_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: CreateCapsule_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    /// 跳转到我的时光胶囊列表页面
    static func toCapsuleList_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: CapsuleList_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    /// 跳转到时光胶囊详情页面（需胶囊已解锁）
    static func toCapsuleDetail_Maki(
        with capsule_maki: TimeCapsuleModel_Maki,
        style_maki: NavigationStyle_Maki = .push_maki,
        animated_maki: Bool = true
    ) {
        let vc_maki = CapsuleDetail_Maki()
        vc_maki.capsuleModel_Maki = capsule_maki
        navigate_Maki(to: vc_maki, style_maki: style_maki, animated_maki: animated_maki)
    }

    /// 跳转到成长阶梯与年度海报页面
    static func toGrowthLadder_Maki(style_maki: NavigationStyle_Maki = .push_maki, animated_maki: Bool = true) {
        navigate_Maki(to: GrowthLadder_Maki(), style_maki: style_maki, animated_maki: animated_maki)
    }

    // MARK: - 全屏媒体浏览

    /// 全屏展示媒体（图片/视频），以 present 方式呈现
    /// 参数：
    /// - mediaPath_maki: 媒体路径（Assets名/网络URL/Documents路径）
    /// - isVideo_maki: 是否强制当作视频处理
    static func toMediaPlayer_Maki(mediaPath_maki: String, isVideo_maki: Bool = false) {
        let vc_maki = MediaPlayerPage_Maki()
        vc_maki.mediaPath_Maki = mediaPath_maki
        vc_maki.isVideo_Maki   = isVideo_maki
        vc_maki.modalPresentationStyle = .fullScreen
        present_Maki(viewController: vc_maki, animated: true, completion: nil)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Maki {

    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的页面并返回安全位置
    /// 处理两种情形：
    /// 1. 当前 VC 以 present 展示：先 dismiss，再操作 presentingVC 的导航栈
    /// 2. 当前 VC 在导航栈中：直接 pop 到安全位置
    /// 参数：
    /// - viewController_maki: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Maki(from viewController_maki: UIViewController) {
        if let presentingVC_maki = viewController_maki.presentingViewController {
            viewController_maki.dismiss(animated: true) {
                let nav_maki = (presentingVC_maki as? UINavigationController) ?? presentingVC_maki.navigationController
                nav_maki.map { popStackToSafeVC_Maki(nav: $0) }
            }
        } else {
            viewController_maki.navigationController.map { popStackToSafeVC_Maki(nav: $0) }
        }
    }

    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除：帖子详情、消息聊天、TabBar 五个子页面；若均为排除类型则 popToRoot
    private static func popStackToSafeVC_Maki(nav: UINavigationController) {
        let excludedTypes_maki: [AnyClass] = [
            Detail_Maki.self, MessageUser_Maki.self,
            Home_Maki.self, Discover_Maki.self, Release_Maki.self,
            MessageList_Maki.self, Me_Maki.self
        ]

        if let safeVC_maki = nav.viewControllers.reversed().first(where: { vc in
            !excludedTypes_maki.contains { vc.isKind(of: $0) }
        }) {
            guard safeVC_maki !== nav.topViewController else { return }
            nav.popToViewController(safeVC_maki, animated: true)
        } else {
            print("⚠️ 导航堆栈中无安全 VC，已返回根视图控制器")
            nav.popToRootViewController(animated: true)
        }
    }
}
