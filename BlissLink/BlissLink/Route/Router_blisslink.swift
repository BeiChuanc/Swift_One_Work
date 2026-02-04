import SwiftUI
import Combine

// MARK: - 路由系统
// 核心作用：统一管理应用的导航和路由
// 设计思路：枚举定义路由 + 管理器控制导航 + 容器视图集成

// MARK: - 路由枚举

/// 应用路由枚举
enum Route_blisslink: Hashable, Identifiable {
    // 认证
    case login_blisslink
    case register_blisslink
    
    // 主页面
    case home_blisslink
    case discover_blisslink
    case messageList_blisslink
    case me_blisslink
    
    // 帖子
    case postDetail_blisslink(post_blisslink: TitleModel_blisslink)
    case release_blisslink
    
    // 用户
    case userInfo_blisslink(user_blisslink: PrewUserModel_blisslink)
    case editInfo_blisslink
    case settings_blisslink
    
    // 消息
    case userChat_blisslink(user_blisslink: PrewUserModel_blisslink)
    case groupChat_blisslink(groupId_blisslink: Int)
    case aiChat_blisslink
    
    // 媒体
    case mediaPlayer_blisslink(mediaUrl_blisslink: String, isVideo_blisslink: Bool)
    
    // 练习
    case practiceTimer_blisslink
    
    // 视频通话
    case videoChat_blisslink(user_blisslink: PrewUserModel_blisslink)
    
    // 商店
    case giftShop_blisslink
    
    var id: String {
        switch self {
        case .login_blisslink: return "login"
        case .register_blisslink: return "register"
        case .home_blisslink: return "home"
        case .discover_blisslink: return "discover"
        case .messageList_blisslink: return "messageList"
        case .me_blisslink: return "me"
        case .postDetail_blisslink(let post): return "postDetail_\(post.titleId_blisslink)"
        case .release_blisslink: return "release"
        case .userInfo_blisslink(let user): return "userInfo_\(user.userId_blisslink ?? 0)"
        case .editInfo_blisslink: return "editInfo"
        case .settings_blisslink: return "settings"
        case .userChat_blisslink(let user): return "userChat_\(user.userId_blisslink ?? 0)"
        case .groupChat_blisslink(let groupId): return "groupChat_\(groupId)"
        case .aiChat_blisslink: return "aiChat"
        case .mediaPlayer_blisslink(let mediaUrl, let isVideo): return "mediaPlayer_\(mediaUrl.hashValue)_\(isVideo)"
        case .practiceTimer_blisslink: return "practiceTimer"
        case .videoChat_blisslink(let user): return "videoChat_\(user.userId_blisslink ?? 0)"
        case .giftShop_blisslink: return "giftShop"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Route_blisslink, rhs: Route_blisslink) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 路由管理器

/// 路由管理器
class Router_blisslink: ObservableObject {
    
    static let shared_blisslink = Router_blisslink()
    
    @Published var navigationPath_blisslink = NavigationPath()
    @Published var presentedSheet_blisslink: Route_blisslink?
    @Published var presentedFullScreen_blisslink: Route_blisslink?
    @Published var showAlert_blisslink = false
    @Published var alertConfig_blisslink: AlertConfig_blisslink?
    
    private init() {}
    
    // MARK: - 基础导航方法
    
    /// 导航到指定路由
    func navigate_blisslink(to route_blisslink: Route_blisslink) {
        navigationPath_blisslink.append(route_blisslink)
    }
    
    /// 返回上一页
    func pop_blisslink() {
        guard !navigationPath_blisslink.isEmpty else { return }
        navigationPath_blisslink.removeLast()
    }
    
    /// 返回到根页面
    func popToRoot_blisslink() {
        navigationPath_blisslink = NavigationPath()
    }
    
    /// 展示Sheet
    func presentSheet_blisslink(route_blisslink: Route_blisslink) {
        presentedSheet_blisslink = route_blisslink
    }
    
    /// 关闭Sheet
    func dismissSheet_blisslink() {
        presentedSheet_blisslink = nil
    }
    
    /// 展示全屏页面
    func presentFullScreen_blisslink(route_blisslink: Route_blisslink) {
        presentedFullScreen_blisslink = route_blisslink
    }
    
    /// 关闭全屏页面
    func dismissFullScreen_blisslink() {
        presentedFullScreen_blisslink = nil
    }
    
    /// 显示Alert
    func showAlert_blisslink(
        title_blisslink: String,
        message_blisslink: String? = nil,
        primaryButton_blisslink: AlertButton_blisslink = AlertButton_blisslink(title_blisslink: "OK", action_blisslink: nil),
        secondaryButton_blisslink: AlertButton_blisslink? = nil
    ) {
        alertConfig_blisslink = AlertConfig_blisslink(
            title_blisslink: title_blisslink,
            message_blisslink: message_blisslink,
            primaryButton_blisslink: primaryButton_blisslink,
            secondaryButton_blisslink: secondaryButton_blisslink
        )
        showAlert_blisslink = true
    }
    
    // MARK: - 便捷导航方法
    
    func toLogin_blisslink() {
        presentFullScreen_blisslink(route_blisslink: .login_blisslink)
    }
    
    func toRegister_blisslink() {
        navigate_blisslink(to: .register_blisslink)
    }
    
    func toPostDetail_blisslink(post_blisslink: TitleModel_blisslink) {
        navigate_blisslink(to: .postDetail_blisslink(post_blisslink: post_blisslink))
    }
    
    func toUserInfo_blisslink(user_blisslink: PrewUserModel_blisslink) {
        navigate_blisslink(to: .userInfo_blisslink(user_blisslink: user_blisslink))
    }
    
    func toRelease_blisslink() {
        presentFullScreen_blisslink(route_blisslink: .release_blisslink)
    }
    
    func toEditInfo_blisslink() {
        navigate_blisslink(to: .editInfo_blisslink)
    }
    
    func toSettings_blisslink() {
        navigate_blisslink(to: .settings_blisslink)
    }
    
    func toUserChat_blisslink(user_blisslink: PrewUserModel_blisslink) {
        navigate_blisslink(to: .userChat_blisslink(user_blisslink: user_blisslink))
    }
    
    func toGroupChat_blisslink(groupId_blisslink: Int) {
        navigate_blisslink(to: .groupChat_blisslink(groupId_blisslink: groupId_blisslink))
    }
    
    func toAIChat_blisslink() {
        navigate_blisslink(to: .aiChat_blisslink)
    }
    
    func toMediaPlayer_blisslink(mediaUrl_blisslink: String, isVideo_blisslink: Bool) {
        presentFullScreen_blisslink(route_blisslink: .mediaPlayer_blisslink(mediaUrl_blisslink: mediaUrl_blisslink, isVideo_blisslink: isVideo_blisslink))
    }
    
    func toVideoChat_blisslink(user_blisslink: PrewUserModel_blisslink) {
        presentFullScreen_blisslink(route_blisslink: .videoChat_blisslink(user_blisslink: user_blisslink))
    }
    
    func toGiftShop_blisslink() {
        navigate_blisslink(to: .giftShop_blisslink)
    }
    
    // MARK: - 视图构建器
    
    @ViewBuilder
    func view_blisslink(for route_blisslink: Route_blisslink) -> some View {
        switch route_blisslink {
        case .login_blisslink:
            Login_baseswift()
        case .register_blisslink:
            Register_baseswift()
        case .home_blisslink:
            Home_baseswift()
        case .discover_blisslink:
            Discover_baseswift()
        case .messageList_blisslink:
            MessageList_baseswift()
        case .me_blisslink:
            Me_baseswift()
        case .postDetail_blisslink(let post):
            Detail_baseswift(post_blisslink: post)
        case .release_blisslink:
            Release_baseswift()
        case .userInfo_blisslink(let user):
            Prewuser_baseswift(user_blisslink: user)
        case .editInfo_blisslink:
            EditInfo_baseswift()
        case .settings_blisslink:
            Set_baseswift()
        case .userChat_blisslink(let user):
            MessageUser_baseswift(user_blisslink: user)
        case .groupChat_blisslink(let groupId):
            MessageUser_baseswift(groupId_blisslink: groupId)
        case .aiChat_blisslink:
            MessageUser_baseswift()
        case .mediaPlayer_blisslink(let mediaUrl, let isVideo):
            MediaPlayer_baseswift(mediaUrl_blisslink: mediaUrl, isVideo_blisslink: isVideo)
        case .practiceTimer_blisslink:
            PracticeTimer_blisslink()
        case .videoChat_blisslink(let user):
            VideoChat_blisslink(user_blisslink: user)
        case .giftShop_blisslink:
            GiftShop_blisslink()
        }
    }
}

// MARK: - Alert 配置

/// Alert配置
struct AlertConfig_blisslink {
    let title_blisslink: String
    let message_blisslink: String?
    let primaryButton_blisslink: AlertButton_blisslink
    let secondaryButton_blisslink: AlertButton_blisslink?
}

/// Alert按钮配置
struct AlertButton_blisslink {
    let title_blisslink: String
    var role_blisslink: ButtonRole? = nil
    let action_blisslink: (() -> Void)?
}

// MARK: - 路由容器视图

/// 路由容器视图
struct RouterView_blisslink<Content: View>: View {
    
    @ObservedObject var router_blisslink: Router_blisslink
    let rootView_blisslink: Content
    
    init(
        router_blisslink: Router_blisslink = Router_blisslink.shared_blisslink,
        @ViewBuilder rootView_blisslink: () -> Content
    ) {
        self.router_blisslink = router_blisslink
        self.rootView_blisslink = rootView_blisslink()
    }
    
    var body: some View {
        NavigationStack(path: $router_blisslink.navigationPath_blisslink) {
            rootView_blisslink
                .navigationDestination(for: Route_blisslink.self) { route in
                    router_blisslink.view_blisslink(for: route)
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        .sheet(item: $router_blisslink.presentedSheet_blisslink) { route in
            NavigationStack {
                router_blisslink.view_blisslink(for: route)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                router_blisslink.dismissSheet_blisslink()
                            }
                        }
                    }
            }
        }
        .fullScreenCover(item: $router_blisslink.presentedFullScreen_blisslink) { route in
            // 判断是否是礼物商店，礼物商店不需要NavigationStack
            if case .giftShop_blisslink = route {
                router_blisslink.view_blisslink(for: route)
                    .presentationBackground(Color.clear)
                    .background(Color.clear)
            } else {
                NavigationStack {
                    router_blisslink.view_blisslink(for: route)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .alert(
            router_blisslink.alertConfig_blisslink?.title_blisslink ?? "",
            isPresented: $router_blisslink.showAlert_blisslink
        ) {
            if let config = router_blisslink.alertConfig_blisslink {
                Button(config.primaryButton_blisslink.title_blisslink, role: config.primaryButton_blisslink.role_blisslink) {
                    config.primaryButton_blisslink.action_blisslink?()
                }
                
                if let secondary = config.secondaryButton_blisslink {
                    Button(secondary.title_blisslink, role: secondary.role_blisslink) {
                        secondary.action_blisslink?()
                    }
                }
            }
        } message: {
            if let message = router_blisslink.alertConfig_blisslink?.message_blisslink {
                Text(message)
            }
        }
    }
}
