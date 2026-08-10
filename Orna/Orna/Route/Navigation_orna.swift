import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Orna {
    /// Push方式（导航栈推入）
    case push_orna
    /// Present方式（模态展示）
    case present_orna
    /// Replace方式（替换当前视图控制器）
    case replace_orna
}

/// 页面导航管理器
/// 功能：统一管理 Push、Present、Replace 及根视图切换
/// 设计：静态方法门面，页面跳转全部收敛到此类
class Navigation_Orna: NSObject {

    // MARK: - 基础导航方法

    /// 获取当前显示的视图控制器
    static func currentViewController_Orna() -> UIViewController? {
        UIViewController.currentViewController_Orna()
    }

    /// 解析来源控制器（未指定时取当前顶层 VC）
    /// 参数：
    /// - from: 指定来源控制器，nil 时自动获取当前顶层
    private static func resolveSourceVC_Orna(from: UIViewController?) -> UIViewController? {
        from ?? currentViewController_Orna()
    }

    /// Push方式跳转到指定页面
    static func push_Orna(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Orna(from: from)?.navigationController?.pushViewController(viewController, animated: animated)
    }

    /// Present方式展示指定页面
    static func present_Orna(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Orna(from: from)?.present(viewController, animated: animated, completion: completion)
    }

    /// Pop返回上一页
    static func pop_Orna(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Orna(from: from)?.navigationController?.popViewController(animated: animated)
    }

    /// Pop返回到根视图控制器
    static func popToRoot_Orna(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Orna(from: from)?.navigationController?.popToRootViewController(animated: animated)
    }

    /// Dismiss关闭当前模态页面
    static func dismiss_Orna(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Orna(from: from)?.dismiss(animated: animated, completion: completion)
    }

    /// Replace方式替换当前页面
    static func replace_Orna(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        guard let nav_orna = resolveSourceVC_Orna(from: from)?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }

        var stack_orna = nav_orna.viewControllers
        if stack_orna.isEmpty {
            nav_orna.pushViewController(viewController, animated: animated)
        } else {
            stack_orna[stack_orna.count - 1] = viewController
            nav_orna.setViewControllers(stack_orna, animated: animated)
        }
    }

    // MARK: - 通用导航方法

    /// 根据导航方式跳转到指定页面
    /// 参数：
    /// - viewController_orna: 目标页面
    /// - style_orna: 导航方式
    /// - wrapInNavigation_orna: 是否包装导航控制器，nil 时 present 默认包装
    /// - animated_orna: 是否动画
    /// - completion_orna: 完成回调
    static func navigateToViewController_Orna(
        viewController_orna: UIViewController,
        style_orna: NavigationStyle_Orna,
        wrapInNavigation_orna: Bool? = nil,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        let shouldWrap_orna = wrapInNavigation_orna ?? (style_orna == .present_orna)

        switch style_orna {
        case .push_orna:
            push_Orna(to: viewController_orna, animated: animated_orna)
            completion_orna?()

        case .present_orna:
            let targetVC_orna = shouldWrap_orna
                ? createNavigationController_Orna(rootViewController: viewController_orna)
                : viewController_orna
            targetVC_orna.modalPresentationStyle = .fullScreen
            present_Orna(viewController: targetVC_orna, animated: animated_orna, completion: completion_orna)

        case .replace_orna:
            replace_Orna(to: viewController_orna, animated: animated_orna)
            completion_orna?()
        }
    }

    /// 创建全屏导航控制器
    private static func createNavigationController_Orna(rootViewController: UIViewController) -> UINavigationController {
        let nav_orna = UINavigationController(rootViewController: rootViewController)
        nav_orna.modalPresentationStyle = .fullScreen
        return nav_orna
    }

    /// 页面跳转简化入口（自动判断是否包装导航控制器）
    private static func navigate_Orna(
        to viewController_orna: UIViewController,
        style_orna: NavigationStyle_Orna,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        navigateToViewController_Orna(
            viewController_orna: viewController_orna,
            style_orna: style_orna,
            animated_orna: animated_orna,
            completion_orna: completion_orna
        )
    }

    // MARK: - 主导航

    /// 验证 Window 是否有效
    private static func validateWindow_Orna(_ window: UIWindow?) -> UIWindow? {
        guard let window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }

    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Orna(window: UIWindow?) {
        guard let window_orna = validateWindow_Orna(window) else { return }

        let nav_orna = UINavigationController(rootViewController: TabBar_Orna())
        nav_orna.navigationBar.isHidden = true
        window_orna.rootViewController = nav_orna
        window_orna.makeKeyAndVisible()
    }

    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Orna(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let window_orna = validateWindow_Orna(window) else { return }

        let applyRoot_orna = { window_orna.rootViewController = viewController }
        if animated {
            UIView.transition(with: window_orna, duration: 0.3, options: .transitionCrossDissolve, animations: applyRoot_orna)
        } else {
            applyRoot_orna()
        }
        window_orna.makeKeyAndVisible()
    }

    /// 获取 AppDelegate 中的 Window
    static func getAppWindow_Orna() -> UIWindow? {
        (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    /// 切换到主 Tabbar（自动获取 Window）
    static func switchToTabbar_Orna(animated: Bool = true) {
        let window_orna = getAppWindow_Orna()
        setRootToTabbar_Orna(window: window_orna)

        guard animated else { return }
        window_orna?.alpha = 0
        UIView.animate(withDuration: 0.3) { window_orna?.alpha = 1 }
    }

    // MARK: - 登录注册

    static func toLogin_Orna(
        style_orna: NavigationStyle_Orna = .present_orna,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        navigate_Orna(to: Login_Orna(), style_orna: style_orna, animated_orna: animated_orna, completion_orna: completion_orna)
    }

    static func toRegister_Orna(
        style_orna: NavigationStyle_Orna = .present_orna,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        navigate_Orna(to: Register_Orna(), style_orna: style_orna, animated_orna: animated_orna, completion_orna: completion_orna)
    }

    // MARK: - 首页 / 发现

    static func toHome_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: Home_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toDiscover_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: Discover_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toTitleDetail_Orna(
        titleModel_orna: TitleModel_Orna,
        style_orna: NavigationStyle_Orna = .push_orna,
        animated_orna: Bool = true
    ) {
        let detailVC_orna = Detail_Orna()
        detailVC_orna.titleModel_Orna = titleModel_orna
        navigate_Orna(to: detailVC_orna, style_orna: style_orna, animated_orna: animated_orna)
    }

    // MARK: - 发布

    static func toRelease_Orna(
        style_orna: NavigationStyle_Orna = .present_orna,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        navigate_Orna(to: Release_Orna(), style_orna: style_orna, animated_orna: animated_orna, completion_orna: completion_orna)
    }

    /// 进入送礼弹层页面
    /// 功能：以透明全屏模态方式展示 GiftPage_Orna，保留当前页面作为遮罩背景
    /// 参数：
    /// - from_orna: 发起展示的来源控制器，nil 时自动使用当前顶层控制器
    /// - animated_orna: 是否使用系统展示动画
    /// 返回值：无
    /// 异常场景：来源控制器为空时不执行展示
    static func toGiftPage_Orna(from_orna: UIViewController? = nil, animated_orna: Bool = true) {
        let giftPage_orna = GiftPage_Orna()
        giftPage_orna.modalPresentationStyle = .overFullScreen
        giftPage_orna.modalTransitionStyle = .crossDissolve
        present_Orna(viewController: giftPage_orna, animated: animated_orna, from: from_orna)
    }

    /// 进入 VIP 订阅页面
    /// 功能：通过统一导航管理器展示 VIPSubscription_Orna 页面
    /// 参数：
    /// - style_orna: 导航方式，默认 push 进入以匹配页面内返回按钮
    /// - animated_orna: 是否使用系统转场动画
    /// 返回值：无
    /// 异常场景：当前页面不存在导航控制器且使用 push 时不执行跳转
    static func toVIPSubscription_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: VIPSubscription_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    // MARK: - 消息

    static func toMessageList_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: MessageList_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toMessageUser_Orna(
        with userModel_orna: PrewUserModel_Orna,
        style_orna: NavigationStyle_Orna = .push_orna,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        let messageUserVC_orna = MessageUser_Orna()
        messageUserVC_orna.userModel_Orna = userModel_orna
        navigate_Orna(to: messageUserVC_orna, style_orna: style_orna, animated_orna: animated_orna, completion_orna: completion_orna)
    }

    // MARK: - 个人中心

    static func toMe_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: Me_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toMe_Orna(
        with userModel_orna: LoginUserModel_Orna,
        style_orna: NavigationStyle_Orna = .push_orna,
        animated_orna: Bool = true
    ) {
        let meVC_orna = Me_Orna()
        meVC_orna.meModel_Orna = userModel_orna
        navigate_Orna(to: meVC_orna, style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toUserInfo_Orna(
        with userModel_orna: PrewUserModel_Orna,
        isFromChat_orna: Bool = false,
        style_orna: NavigationStyle_Orna = .push_orna,
        animated_orna: Bool = true,
        completion_orna: (() -> Void)? = nil
    ) {
        let userInfoVC_orna = UserInfo_Orna()
        userInfoVC_orna.userModel_Orna = userModel_orna
        userInfoVC_orna.isFromChat_Orna = isFromChat_orna
        navigate_Orna(to: userInfoVC_orna, style_orna: style_orna, animated_orna: animated_orna, completion_orna: completion_orna)
    }

    // MARK: - 记忆摆件 / 桌面场景

    /// 进入记忆摆件列表页
    static func toMemoryOrnaments_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: MemoryOrnaments_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    /// 进入记忆摆件详情页
    static func toMemoryOrnamentDetail_Orna(
        with ornament_orna: MemoryOrnamentModel_Orna,
        style_orna: NavigationStyle_Orna = .push_orna,
        animated_orna: Bool = true
    ) {
        let detailVC_orna = MemoryOrnamentDetail_Orna()
        detailVC_orna.ornamentId_Orna = ornament_orna.ornamentId_Orna
        navigate_Orna(to: detailVC_orna, style_orna: style_orna, animated_orna: animated_orna)
    }

    /// 进入桌面场景列表页
    static func toDeskSceneList_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: DeskSceneList_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    /// 进入桌面场景编辑器
    static func toDeskSceneEditor_Orna(
        with scene_orna: DeskSceneModel_Orna,
        style_orna: NavigationStyle_Orna = .push_orna,
        animated_orna: Bool = true
    ) {
        let editorVC_orna = DeskSceneEditor_Orna()
        editorVC_orna.sceneId_Orna = scene_orna.sceneId_Orna
        navigate_Orna(to: editorVC_orna, style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toEditInfo_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: EditInfo_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    static func toSetting_Orna(style_orna: NavigationStyle_Orna = .push_orna, animated_orna: Bool = true) {
        navigate_Orna(to: Setting_Orna(), style_orna: style_orna, animated_orna: animated_orna)
    }

    /// 跳转到视频通话页面
    static func toVideoChat_Orna(
        with userModel_orna: PrewUserModel_Orna,
        style_orna: NavigationStyle_Orna = .present_orna,
        animated_orna: Bool = true
    ) {
        let videoChatVC_orna = VideoChat_Orna()
        videoChatVC_orna.userModel_Orna = userModel_orna
        navigate_Orna(to: videoChatVC_orna, style_orna: style_orna, animated_orna: animated_orna)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Orna {

    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的页面并返回安全位置
    /// 处理两种情形：
    /// 1. 当前 VC 以 present 展示：先 dismiss，再操作 presentingVC 的导航栈
    /// 2. 当前 VC 在导航栈中：直接 pop 到安全位置
    /// 参数：
    /// - viewController_orna: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Orna(from viewController_orna: UIViewController) {
        if let presentingVC_orna = viewController_orna.presentingViewController {
            viewController_orna.dismiss(animated: true) {
                let nav_orna = (presentingVC_orna as? UINavigationController) ?? presentingVC_orna.navigationController
                nav_orna.map { popStackToSafeVC_Orna(nav: $0) }
            }
        } else {
            viewController_orna.navigationController.map { popStackToSafeVC_Orna(nav: $0) }
        }
    }

    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除：帖子详情、消息聊天、TabBar 五个子页面；若均为排除类型则 popToRoot
    private static func popStackToSafeVC_Orna(nav: UINavigationController) {
        let excludedTypes_orna: [AnyClass] = [
            Detail_Orna.self, MessageUser_Orna.self,
            Home_Orna.self, Discover_Orna.self, Release_Orna.self,
            MessageList_Orna.self, Me_Orna.self
        ]

        if let safeVC_orna = nav.viewControllers.reversed().first(where: { vc in
            !excludedTypes_orna.contains { vc.isKind(of: $0) }
        }) {
            guard safeVC_orna !== nav.topViewController else { return }
            nav.popToViewController(safeVC_orna, animated: true)
        } else {
            print("⚠️ 导航堆栈中无安全 VC，已返回根视图控制器")
            nav.popToRootViewController(animated: true)
        }
    }

    /// 从聊天页进入的用户中心中取消关注后，返回消息列表页
    /// 处理两种情形：present 展示时先 dismiss 再操作导航栈；导航栈内则直接 pop
    /// 参数：
    /// - viewController_orna: 发起返回操作的视图控制器（通常为 UserInfo_Orna）
    static func popToMessageListAfterUnfollow_Orna(from viewController_orna: UIViewController) {
        if let presentingVC_orna = viewController_orna.presentingViewController {
            viewController_orna.dismiss(animated: true) {
                let nav_orna = (presentingVC_orna as? UINavigationController) ?? presentingVC_orna.navigationController
                nav_orna.map { popStackToMessageList_Orna(nav: $0) }
            }
        } else {
            viewController_orna.navigationController.map { popStackToMessageList_Orna(nav: $0) }
        }
    }

    /// 在导航栈中查找消息列表页并 pop 到该位置，未找到时 pop 到根视图控制器
    private static func popStackToMessageList_Orna(nav: UINavigationController) {
        if let messageListVC_orna = nav.viewControllers.first(where: { $0 is MessageList_Orna }) {
            nav.popToViewController(messageListVC_orna, animated: true)
        } else {
            print("⚠️ 导航堆栈中无消息列表页，已返回根视图控制器")
            nav.popToRootViewController(animated: true)
        }
    }
}
