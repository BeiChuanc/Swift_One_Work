import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Lens {
    /// Push方式（导航栈推入）
    case push_lens
    /// Present方式（模态展示）
    case present_lens
    /// Replace方式（替换当前视图控制器）
    case replace_lens
}

/// 页面导航管理器
/// 功能：统一管理 Push、Present、Replace 及根视图切换
/// 设计：静态方法门面，页面跳转全部收敛到此类
class Navigation_Lens: NSObject {

    // MARK: - 基础导航方法

    /// 获取当前显示的视图控制器
    static func currentViewController_Lens() -> UIViewController? {
        UIViewController.currentViewController_Lens()
    }

    /// 解析来源控制器（未指定时取当前顶层 VC）
    /// 参数：
    /// - from: 指定来源控制器，nil 时自动获取当前顶层
    private static func resolveSourceVC_Lens(from: UIViewController?) -> UIViewController? {
        from ?? currentViewController_Lens()
    }

    /// Push方式跳转到指定页面
    static func push_Lens(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Lens(from: from)?.navigationController?.pushViewController(viewController, animated: animated)
    }

    /// Present方式展示指定页面
    static func present_Lens(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Lens(from: from)?.present(viewController, animated: animated, completion: completion)
    }

    /// Pop返回上一页
    static func pop_Lens(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Lens(from: from)?.navigationController?.popViewController(animated: animated)
    }

    /// Pop返回到根视图控制器
    static func popToRoot_Lens(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Lens(from: from)?.navigationController?.popToRootViewController(animated: animated)
    }

    /// Dismiss关闭当前模态页面
    static func dismiss_Lens(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Lens(from: from)?.dismiss(animated: animated, completion: completion)
    }

    /// Replace方式替换当前页面
    static func replace_Lens(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        guard let nav_lens = resolveSourceVC_Lens(from: from)?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }

        var stack_lens = nav_lens.viewControllers
        if stack_lens.isEmpty {
            nav_lens.pushViewController(viewController, animated: animated)
        } else {
            stack_lens[stack_lens.count - 1] = viewController
            nav_lens.setViewControllers(stack_lens, animated: animated)
        }
    }

    // MARK: - 通用导航方法

    /// 根据导航方式跳转到指定页面
    /// 参数：
    /// - viewController_lens: 目标页面
    /// - style_lens: 导航方式
    /// - wrapInNavigation_lens: 是否包装导航控制器，nil 时 present 默认包装
    /// - animated_lens: 是否动画
    /// - completion_lens: 完成回调
    static func navigateToViewController_Lens(
        viewController_lens: UIViewController,
        style_lens: NavigationStyle_Lens,
        wrapInNavigation_lens: Bool? = nil,
        animated_lens: Bool = true,
        completion_lens: (() -> Void)? = nil
    ) {
        let shouldWrap_lens = wrapInNavigation_lens ?? (style_lens == .present_lens)

        switch style_lens {
        case .push_lens:
            push_Lens(to: viewController_lens, animated: animated_lens)
            completion_lens?()

        case .present_lens:
            let targetVC_lens = shouldWrap_lens
                ? createNavigationController_Lens(rootViewController: viewController_lens)
                : viewController_lens
            targetVC_lens.modalPresentationStyle = .fullScreen
            present_Lens(viewController: targetVC_lens, animated: animated_lens, completion: completion_lens)

        case .replace_lens:
            replace_Lens(to: viewController_lens, animated: animated_lens)
            completion_lens?()
        }
    }

    /// 创建全屏导航控制器
    private static func createNavigationController_Lens(rootViewController: UIViewController) -> UINavigationController {
        let nav_lens = UINavigationController(rootViewController: rootViewController)
        nav_lens.modalPresentationStyle = .fullScreen
        return nav_lens
    }

    /// 页面跳转简化入口（自动判断是否包装导航控制器）
    private static func navigate_Lens(
        to viewController_lens: UIViewController,
        style_lens: NavigationStyle_Lens,
        animated_lens: Bool = true,
        completion_lens: (() -> Void)? = nil
    ) {
        navigateToViewController_Lens(
            viewController_lens: viewController_lens,
            style_lens: style_lens,
            animated_lens: animated_lens,
            completion_lens: completion_lens
        )
    }

    // MARK: - 主导航

    /// 验证 Window 是否有效
    private static func validateWindow_Lens(_ window: UIWindow?) -> UIWindow? {
        guard let window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }

    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Lens(window: UIWindow?) {
        guard let window_lens = validateWindow_Lens(window) else { return }

        let nav_lens = UINavigationController(rootViewController: TabBar_Lens())
        nav_lens.navigationBar.isHidden = true
        window_lens.rootViewController = nav_lens
        window_lens.makeKeyAndVisible()
    }

    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Lens(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let window_lens = validateWindow_Lens(window) else { return }

        let applyRoot_lens = { window_lens.rootViewController = viewController }
        if animated {
            UIView.transition(with: window_lens, duration: 0.3, options: .transitionCrossDissolve, animations: applyRoot_lens)
        } else {
            applyRoot_lens()
        }
        window_lens.makeKeyAndVisible()
    }

    /// 获取 AppDelegate 中的 Window
    static func getAppWindow_Lens() -> UIWindow? {
        (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    /// 切换到主 Tabbar（自动获取 Window）
    static func switchToTabbar_Lens(animated: Bool = true) {
        let window_lens = getAppWindow_Lens()
        setRootToTabbar_Lens(window: window_lens)

        guard animated else { return }
        window_lens?.alpha = 0
        UIView.animate(withDuration: 0.3) { window_lens?.alpha = 1 }
    }

    // MARK: - 登录注册

    static func toLogin_Lens(
        style_lens: NavigationStyle_Lens = .present_lens,
        animated_lens: Bool = true,
        completion_lens: (() -> Void)? = nil
    ) {
        navigate_Lens(to: Login_Lens(), style_lens: style_lens, animated_lens: animated_lens, completion_lens: completion_lens)
    }

    static func toRegister_Lens(
        style_lens: NavigationStyle_Lens = .present_lens,
        animated_lens: Bool = true,
        completion_lens: (() -> Void)? = nil
    ) {
        navigate_Lens(to: Register_Lens(), style_lens: style_lens, animated_lens: animated_lens, completion_lens: completion_lens)
    }

    // MARK: - 首页 / 发现

    static func toHome_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: Home_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    static func toDiscover_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: Discover_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    // MARK: - 调制画盘工作室

    /// 跳转作品集列表
    /// - Parameter filterDateKey_Lens: 可选日期筛选 yyyy-MM-dd
    static func toArtworkPortfolio_Lens(
        filterDateKey_Lens: String? = nil,
        style_lens: NavigationStyle_Lens = .push_lens,
        animated_lens: Bool = true
    ) {
        let vc_Lens = ArtworkPortfolio_Lens()
        vc_Lens.filterDateKey_Lens = filterDateKey_Lens
        navigate_Lens(to: vc_Lens, style_lens: style_lens, animated_lens: animated_lens)
    }

    /// 跳转作品创作过程详情
    /// - Parameter artworkId_Lens: 作品 ID
    static func toArtworkProcess_Lens(artworkId_Lens: Int, style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        let vc_Lens = ArtworkProcess_Lens()
        vc_Lens.artworkId_Lens = artworkId_Lens
        navigate_Lens(to: vc_Lens, style_lens: style_lens, animated_lens: animated_lens)
    }

    /// 跳转亚克力分层工作室
    static func toAcrylicStudio_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: AcrylicStudio_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    /// 跳转光源工作室
    static func toLightStudio_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: LightStudio_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    static func toTitleDetail_Lens(
        titleModel_lens: TitleModel_Lens,
        style_lens: NavigationStyle_Lens = .push_lens,
        animated_lens: Bool = true
    ) {
        let detailVC_lens = Detail_Lens()
        detailVC_lens.titleModel_Lens = titleModel_lens
        navigate_Lens(to: detailVC_lens, style_lens: style_lens, animated_lens: animated_lens)
    }

    // MARK: - 发布

    static func toRelease_Lens(
        style_lens: NavigationStyle_Lens = .present_lens,
        animated_lens: Bool = true,
        completion_lens: (() -> Void)? = nil
    ) {
        navigate_Lens(to: Release_Lens(), style_lens: style_lens, animated_lens: animated_lens, completion_lens: completion_lens)
    }

    // MARK: - 消息

    static func toMessageList_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: MessageList_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    static func toMessageUser_Lens(
        with userModel_lens: PrewUserModel_Lens,
        style_lens: NavigationStyle_Lens = .push_lens,
        animated_lens: Bool = true,
        from from_lens: UIViewController? = nil,
        completion_lens: (() -> Void)? = nil
    ) {
        let messageUserVC_lens = MessageUser_Lens()
        messageUserVC_lens.userModel_Lens = userModel_lens
        switch style_lens {
        case .push_lens:
            push_Lens(to: messageUserVC_lens, animated: animated_lens, from: from_lens)
            completion_lens?()
        default:
            navigate_Lens(to: messageUserVC_lens, style_lens: style_lens, animated_lens: animated_lens, completion_lens: completion_lens)
        }
    }

    // MARK: - 个人中心

    static func toMe_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: Me_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    static func toMe_Lens(
        with userModel_lens: LoginUserModel_Lens,
        style_lens: NavigationStyle_Lens = .push_lens,
        animated_lens: Bool = true
    ) {
        let meVC_lens = Me_Lens()
        meVC_lens.meModel_Lens = userModel_lens
        navigate_Lens(to: meVC_lens, style_lens: style_lens, animated_lens: animated_lens)
    }

    static func toUserInfo_Lens(
        with userModel_lens: PrewUserModel_Lens,
        style_lens: NavigationStyle_Lens = .push_lens,
        animated_lens: Bool = true,
        completion_lens: (() -> Void)? = nil
    ) {
        let userInfoVC_lens = UserInfo_Lens()
        userInfoVC_lens.userModel_Lens = userModel_lens
        navigate_Lens(to: userInfoVC_lens, style_lens: style_lens, animated_lens: animated_lens, completion_lens: completion_lens)
    }

    static func toEditInfo_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: EditInfo_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }

    static func toSetting_Lens(style_lens: NavigationStyle_Lens = .push_lens, animated_lens: Bool = true) {
        navigate_Lens(to: Setting_Lens(), style_lens: style_lens, animated_lens: animated_lens)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Lens {

    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的页面并返回安全位置
    /// 处理两种情形：
    /// 1. 当前 VC 以 present 展示：先 dismiss，再操作 presentingVC 的导航栈
    /// 2. 当前 VC 在导航栈中：直接 pop 到安全位置
    /// 参数：
    /// - viewController_lens: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Lens(from viewController_lens: UIViewController) {
        if let presentingVC_lens = viewController_lens.presentingViewController {
            viewController_lens.dismiss(animated: true) {
                let nav_lens = (presentingVC_lens as? UINavigationController) ?? presentingVC_lens.navigationController
                nav_lens.map { popStackToSafeVC_Lens(nav: $0) }
            }
        } else {
            viewController_lens.navigationController.map { popStackToSafeVC_Lens(nav: $0) }
        }
    }

    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除：帖子详情、消息聊天、TabBar 五个子页面；若均为排除类型则 popToRoot
    private static func popStackToSafeVC_Lens(nav: UINavigationController) {
        let excludedTypes_lens: [AnyClass] = [
            Detail_Lens.self, MessageUser_Lens.self,
            Home_Lens.self, Discover_Lens.self, Release_Lens.self,
            MessageList_Lens.self, Me_Lens.self
        ]

        if let safeVC_lens = nav.viewControllers.reversed().first(where: { vc in
            !excludedTypes_lens.contains { vc.isKind(of: $0) }
        }) {
            guard safeVC_lens !== nav.topViewController else { return }
            nav.popToViewController(safeVC_lens, animated: true)
        } else {
            print("⚠️ 导航堆栈中无安全 VC，已返回根视图控制器")
            nav.popToRootViewController(animated: true)
        }
    }
}
