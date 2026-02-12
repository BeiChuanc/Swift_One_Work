import SwiftUI
import Combine

// MARK: - 路由系统
// 核心作用：统一管理应用的导航和路由
// 设计思路：枚举定义路由 + 管理器控制导航 + 容器视图集成

// MARK: - 路由枚举

/// 应用路由枚举
enum Route_platbell: Hashable, Identifiable {
    // 认证
    case Login_platbellui
    case register_platbell
    
    // 主页面
    case Home_platbellui
    case Discover_platbellui
    case messageList_platbell
    case me_platbell
    
    // 帖子
    case postDetail_platbellui(post_platbell: TitleModel_platbell)
    case release_platbell
    
    // 用户
    case userInfo_platbell(user_platbell: PrewUserModel_platbell)
    case EditInfo_platbellui
    case settings_platbell
    
    // 消息
    case userChat_platbell(user_platbell: PrewUserModel_platbell)
    case groupChat_platbell(groupId_platbell: Int)
    case aiChat_platbell
    
    // 媒体
    case mediaPlayer_platbell(mediaUrl_platbell: String)
    
    // 视频通话
    case videoChat_platbell(user_platbell: PrewUserModel_platbell)
    
    var id: String {
        switch self {
        case .Login_platbellui: return "login"
        case .register_platbell: return "register"
        case .Home_platbellui: return "home"
        case .Discover_platbellui: return "discover"
        case .messageList_platbell: return "messageList"
        case .me_platbell: return "me"
        case .postDetail_platbellui(let post): return "postDetail_\(post.titleId_platbell)"
        case .release_platbell: return "release"
        case .userInfo_platbell(let user): return "userInfo_\(user.userId_platbell ?? 0)"
        case .EditInfo_platbellui: return "editInfo"
        case .settings_platbell: return "settings"
        case .userChat_platbell(let user): return "userChat_\(user.userId_platbell ?? 0)"
        case .groupChat_platbell(let groupId): return "groupChat_\(groupId)"
        case .aiChat_platbell: return "aiChat"
        case .mediaPlayer_platbell(let mediaUrl): return "mediaPlayer_\(mediaUrl.hashValue)"
        case .videoChat_platbell(let user): return "videoChat_\(user.userId_platbell ?? 0)"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Route_platbell, rhs: Route_platbell) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 路由管理器

/// 路由管理器
class Router_platbell: ObservableObject {
    
    static let shared_platbell = Router_platbell()
    
    @Published var navigationPath_platbell = NavigationPath()
    @Published var presentedSheet_platbell: Route_platbell?
    @Published var presentedFullScreen_platbell: Route_platbell?
    @Published var showAlert_platbell = false
    @Published var alertConfig_platbell: AlertConfig_platbell?
    
    private init() {}
    
    // MARK: - 基础导航方法
    
    /// 导航到指定路由
    func navigate_platbell(to route_platbell: Route_platbell) {
        navigationPath_platbell.append(route_platbell)
    }
    
    /// 返回上一页
    func pop_platbell() {
        guard !navigationPath_platbell.isEmpty else { return }
        navigationPath_platbell.removeLast()
    }
    
    /// 返回到根页面
    func popToRoot_platbell() {
        navigationPath_platbell = NavigationPath()
    }
    
    /// 展示Sheet
    func presentSheet_platbell(route_platbell: Route_platbell) {
        presentedSheet_platbell = route_platbell
    }
    
    /// 关闭Sheet
    func dismissSheet_platbell() {
        presentedSheet_platbell = nil
    }
    
    /// 展示全屏页面
    func presentFullScreen_platbell(route_platbell: Route_platbell) {
        presentedFullScreen_platbell = route_platbell
    }
    
    /// 关闭全屏页面
    func dismissFullScreen_platbell() {
        presentedFullScreen_platbell = nil
    }
    
    /// 显示Alert
    func showAlert_platbell(
        title_platbell: String,
        message_platbell: String? = nil,
        primaryButton_platbell: AlertButton_platbell = AlertButton_platbell(title_platbell: "OK", action_platbell: nil),
        secondaryButton_platbell: AlertButton_platbell? = nil
    ) {
        alertConfig_platbell = AlertConfig_platbell(
            title_platbell: title_platbell,
            message_platbell: message_platbell,
            primaryButton_platbell: primaryButton_platbell,
            secondaryButton_platbell: secondaryButton_platbell
        )
        showAlert_platbell = true
    }
    
    // MARK: - 便捷导航方法
    
    func toLogin_platbellui() {
        presentFullScreen_platbell(route_platbell: .Login_platbellui)
    }
    
    func toRegister_platbell() {
        navigate_platbell(to: .register_platbell)
    }
    
    func toPostDetail_platbellui(post_platbell: TitleModel_platbell) {
        navigate_platbell(to: .postDetail_platbellui(post_platbell: post_platbell))
    }
    
    func toUserInfo_platbell(user_platbell: PrewUserModel_platbell) {
        navigate_platbell(to: .userInfo_platbell(user_platbell: user_platbell))
    }
    
    func toRelease_platbell() {
        presentFullScreen_platbell(route_platbell: .release_platbell)
    }
    
    func toEditInfo_platbellui() {
        navigate_platbell(to: .EditInfo_platbellui)
    }
    
    func toSettings_platbell() {
        navigate_platbell(to: .settings_platbell)
    }
    
    func toUserChat_platbell(user_platbell: PrewUserModel_platbell) {
        navigate_platbell(to: .userChat_platbell(user_platbell: user_platbell))
    }
    
    func toGroupChat_platbell(groupId_platbell: Int) {
        navigate_platbell(to: .groupChat_platbell(groupId_platbell: groupId_platbell))
    }
    
    func toAIChat_platbell() {
        navigate_platbell(to: .aiChat_platbell)
    }
    
    func toMediaPlayer_platbell(mediaUrl_platbell: String) {
        presentFullScreen_platbell(route_platbell: .mediaPlayer_platbell(mediaUrl_platbell: mediaUrl_platbell))
    }
    
    func toVideoChat_platbell(user_platbell: PrewUserModel_platbell) {
        presentFullScreen_platbell(route_platbell: .videoChat_platbell(user_platbell: user_platbell))
    }
    
    // MARK: - 视图构建器
    
    @ViewBuilder
    func view_platbell(for route_platbell: Route_platbell) -> some View {
        switch route_platbell {
        case .Login_platbellui:
            Login_platbell()
        case .register_platbell:
            Register_platbell()
        case .Home_platbellui:
            Home_platbell()
        case .Discover_platbellui:
            Discover_platbell()
        case .messageList_platbell:
            MessageList_platbell()
        case .me_platbell:
            Me_platbell()
        case .postDetail_platbellui(let post):
            Detail_platbell(post_platbell: post)
        case .release_platbell:
            Release_platbell()
        case .userInfo_platbell(let user):
            Prewuser_platbell(user_platbell: user)
        case .EditInfo_platbellui:
            EditInfo_platbell()
        case .settings_platbell:
            Set_platbell()
        case .userChat_platbell(let user):
            MessageUser_platbell(user_platbell: user)
        case .groupChat_platbell(let groupId):
            MessageUser_platbell(groupId_platbell: groupId)
        case .aiChat_platbell:
            MessageUser_platbell(isAIChat_platbell: true)
        case .mediaPlayer_platbell(let mediaUrl):
            MediaPlayer_platbell(mediaUrl_platbell: mediaUrl)
        case .videoChat_platbell(let user):
            VideoChat_platbell(user_platbell: user)
        }
    }
}

// MARK: - Alert 配置

/// Alert配置
struct AlertConfig_platbell {
    let title_platbell: String
    let message_platbell: String?
    let primaryButton_platbell: AlertButton_platbell
    let secondaryButton_platbell: AlertButton_platbell?
}

/// Alert按钮配置
struct AlertButton_platbell {
    let title_platbell: String
    var role_platbell: ButtonRole? = nil
    let action_platbell: (() -> Void)?
}

// MARK: - 路由容器视图

/// 路由容器视图
struct RouterView_platbell<Content: View>: View {
    
    @ObservedObject var router_platbell: Router_platbell
    let rootView_platbell: Content
    
    init(
        router_platbell: Router_platbell = Router_platbell.shared_platbell,
        @ViewBuilder rootView_platbell: () -> Content
    ) {
        self.router_platbell = router_platbell
        self.rootView_platbell = rootView_platbell()
    }
    
    var body: some View {
        NavigationStack(path: $router_platbell.navigationPath_platbell) {
            rootView_platbell
                .navigationDestination(for: Route_platbell.self) { route in
                    router_platbell.view_platbell(for: route)
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        .sheet(item: $router_platbell.presentedSheet_platbell) { route in
            NavigationStack {
                router_platbell.view_platbell(for: route)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                router_platbell.dismissSheet_platbell()
                            }
                        }
                    }
            }
        }
        .fullScreenCover(item: $router_platbell.presentedFullScreen_platbell) { route in
            NavigationStack {
                router_platbell.view_platbell(for: route)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert(
            router_platbell.alertConfig_platbell?.title_platbell ?? "",
            isPresented: $router_platbell.showAlert_platbell
        ) {
            if let config = router_platbell.alertConfig_platbell {
                Button(config.primaryButton_platbell.title_platbell, role: config.primaryButton_platbell.role_platbell) {
                    config.primaryButton_platbell.action_platbell?()
                }
                
                if let secondary = config.secondaryButton_platbell {
                    Button(secondary.title_platbell, role: secondary.role_platbell) {
                        secondary.action_platbell?()
                    }
                }
            }
        } message: {
            if let message = router_platbell.alertConfig_platbell?.message_platbell {
                Text(message)
            }
        }
    }
}
