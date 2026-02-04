import SwiftUI
import Combine

// MARK: - 路由系统
// 核心作用：统一管理应用的导航和路由
// 设计思路：枚举定义路由 + 管理器控制导航 + 容器视图集成

// MARK: - 路由枚举

/// 应用路由枚举
enum Route_lite: Hashable, Identifiable {
    // 认证
    case Login_liteui
    case register_lite
    
    // 主页面
    case Home_liteui
    case Discover_liteui
    case messageList_lite
    case me_lite
    
    // 帖子
    case postDetail_liteui(post_lite: TitleModel_lite)
    case release_lite
    
    // 用户
    case userInfo_lite(user_lite: PrewUserModel_lite)
    case EditInfo_liteui
    case settings_lite
    
    // 消息
    case userChat_lite(user_lite: PrewUserModel_lite)
    case groupChat_lite(groupId_lite: Int)
    case aiChat_lite
    
    // 媒体
    case mediaPlayer_lite(mediaUrl_lite: String)
    
    // 视频通话
    case videoChat_lite(user_lite: PrewUserModel_lite)
    
    var id: String {
        switch self {
        case .Login_liteui: return "login"
        case .register_lite: return "register"
        case .Home_liteui: return "home"
        case .Discover_liteui: return "discover"
        case .messageList_lite: return "messageList"
        case .me_lite: return "me"
        case .postDetail_liteui(let post): return "postDetail_\(post.titleId_lite)"
        case .release_lite: return "release"
        case .userInfo_lite(let user): return "userInfo_\(user.userId_lite ?? 0)"
        case .EditInfo_liteui: return "editInfo"
        case .settings_lite: return "settings"
        case .userChat_lite(let user): return "userChat_\(user.userId_lite ?? 0)"
        case .groupChat_lite(let groupId): return "groupChat_\(groupId)"
        case .aiChat_lite: return "aiChat"
        case .mediaPlayer_lite(let mediaUrl): return "mediaPlayer_\(mediaUrl.hashValue)"
        case .videoChat_lite(let user): return "videoChat_\(user.userId_lite ?? 0)"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Route_lite, rhs: Route_lite) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 路由管理器

/// 路由管理器
class Router_lite: ObservableObject {
    
    static let shared_lite = Router_lite()
    
    @Published var navigationPath_lite = NavigationPath()
    @Published var presentedSheet_lite: Route_lite?
    @Published var presentedFullScreen_lite: Route_lite?
    @Published var showAlert_lite = false
    @Published var alertConfig_lite: AlertConfig_lite?
    
    private init() {}
    
    // MARK: - 基础导航方法
    
    /// 导航到指定路由
    func navigate_lite(to route_lite: Route_lite) {
        navigationPath_lite.append(route_lite)
    }
    
    /// 返回上一页
    func pop_lite() {
        guard !navigationPath_lite.isEmpty else { return }
        navigationPath_lite.removeLast()
    }
    
    /// 返回到根页面
    func popToRoot_lite() {
        navigationPath_lite = NavigationPath()
    }
    
    /// 展示Sheet
    func presentSheet_lite(route_lite: Route_lite) {
        presentedSheet_lite = route_lite
    }
    
    /// 关闭Sheet
    func dismissSheet_lite() {
        presentedSheet_lite = nil
    }
    
    /// 展示全屏页面
    func presentFullScreen_lite(route_lite: Route_lite) {
        presentedFullScreen_lite = route_lite
    }
    
    /// 关闭全屏页面
    func dismissFullScreen_lite() {
        presentedFullScreen_lite = nil
    }
    
    /// 显示Alert
    func showAlert_lite(
        title_lite: String,
        message_lite: String? = nil,
        primaryButton_lite: AlertButton_lite = AlertButton_lite(title_lite: "OK", action_lite: nil),
        secondaryButton_lite: AlertButton_lite? = nil
    ) {
        alertConfig_lite = AlertConfig_lite(
            title_lite: title_lite,
            message_lite: message_lite,
            primaryButton_lite: primaryButton_lite,
            secondaryButton_lite: secondaryButton_lite
        )
        showAlert_lite = true
    }
    
    // MARK: - 便捷导航方法
    
    func toLogin_liteui() {
        presentFullScreen_lite(route_lite: .Login_liteui)
    }
    
    func toRegister_lite() {
        navigate_lite(to: .register_lite)
    }
    
    func toPostDetail_liteui(post_lite: TitleModel_lite) {
        navigate_lite(to: .postDetail_liteui(post_lite: post_lite))
    }
    
    func toUserInfo_lite(user_lite: PrewUserModel_lite) {
        navigate_lite(to: .userInfo_lite(user_lite: user_lite))
    }
    
    func toRelease_lite() {
        presentFullScreen_lite(route_lite: .release_lite)
    }
    
    func toEditInfo_liteui() {
        navigate_lite(to: .EditInfo_liteui)
    }
    
    func toSettings_lite() {
        navigate_lite(to: .settings_lite)
    }
    
    func toUserChat_lite(user_lite: PrewUserModel_lite) {
        navigate_lite(to: .userChat_lite(user_lite: user_lite))
    }
    
    func toGroupChat_lite(groupId_lite: Int) {
        navigate_lite(to: .groupChat_lite(groupId_lite: groupId_lite))
    }
    
    func toAIChat_lite() {
        navigate_lite(to: .aiChat_lite)
    }
    
    func toMediaPlayer_lite(mediaUrl_lite: String) {
        presentFullScreen_lite(route_lite: .mediaPlayer_lite(mediaUrl_lite: mediaUrl_lite))
    }
    
    func toVideoChat_lite(user_lite: PrewUserModel_lite) {
        presentFullScreen_lite(route_lite: .videoChat_lite(user_lite: user_lite))
    }
    
    // MARK: - 视图构建器
    
    @ViewBuilder
    func view_lite(for route_lite: Route_lite) -> some View {
        switch route_lite {
        case .Login_liteui:
            Login_lite()
        case .register_lite:
            Register_lite()
        case .Home_liteui:
            Home_lite()
        case .Discover_liteui:
            Discover_lite()
        case .messageList_lite:
            MessageList_lite()
        case .me_lite:
            Me_lite()
        case .postDetail_liteui(let post):
            Detail_lite(post_lite: post)
        case .release_lite:
            Release_lite()
        case .userInfo_lite(let user):
            Prewuser_lite(user_lite: user)
        case .EditInfo_liteui:
            EditInfo_lite()
        case .settings_lite:
            Set_lite()
        case .userChat_lite(let user):
            MessageUser_lite(user_lite: user)
        case .groupChat_lite(let groupId):
            MessageUser_lite(groupId_lite: groupId)
        case .aiChat_lite:
            MessageUser_lite(isAIChat_lite: true)
        case .mediaPlayer_lite(let mediaUrl):
            MediaPlayer_lite(mediaUrl_lite: mediaUrl)
        case .videoChat_lite(let user):
            VideoChat_lite(user_lite: user)
        }
    }
}

// MARK: - Alert 配置

/// Alert配置
struct AlertConfig_lite {
    let title_lite: String
    let message_lite: String?
    let primaryButton_lite: AlertButton_lite
    let secondaryButton_lite: AlertButton_lite?
}

/// Alert按钮配置
struct AlertButton_lite {
    let title_lite: String
    var role_lite: ButtonRole? = nil
    let action_lite: (() -> Void)?
}

// MARK: - 路由容器视图

/// 路由容器视图
struct RouterView_lite<Content: View>: View {
    
    @ObservedObject var router_lite: Router_lite
    let rootView_lite: Content
    
    init(
        router_lite: Router_lite = Router_lite.shared_lite,
        @ViewBuilder rootView_lite: () -> Content
    ) {
        self.router_lite = router_lite
        self.rootView_lite = rootView_lite()
    }
    
    var body: some View {
        NavigationStack(path: $router_lite.navigationPath_lite) {
            rootView_lite
                .navigationDestination(for: Route_lite.self) { route in
                    router_lite.view_lite(for: route)
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        .sheet(item: $router_lite.presentedSheet_lite) { route in
            NavigationStack {
                router_lite.view_lite(for: route)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                router_lite.dismissSheet_lite()
                            }
                        }
                    }
            }
        }
        .fullScreenCover(item: $router_lite.presentedFullScreen_lite) { route in
            NavigationStack {
                router_lite.view_lite(for: route)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert(
            router_lite.alertConfig_lite?.title_lite ?? "",
            isPresented: $router_lite.showAlert_lite
        ) {
            if let config = router_lite.alertConfig_lite {
                Button(config.primaryButton_lite.title_lite, role: config.primaryButton_lite.role_lite) {
                    config.primaryButton_lite.action_lite?()
                }
                
                if let secondary = config.secondaryButton_lite {
                    Button(secondary.title_lite, role: secondary.role_lite) {
                        secondary.action_lite?()
                    }
                }
            }
        } message: {
            if let message = router_lite.alertConfig_lite?.message_lite {
                Text(message)
            }
        }
    }
}
