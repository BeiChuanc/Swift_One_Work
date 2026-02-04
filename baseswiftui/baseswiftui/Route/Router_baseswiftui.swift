import SwiftUI
import Combine

// MARK: - 路由系统
// 核心作用：统一管理应用的导航和路由
// 设计思路：枚举定义路由 + 管理器控制导航 + 容器视图集成

// MARK: - 路由枚举

/// 应用路由枚举
enum Route_baseswiftui: Hashable, Identifiable {
    // 认证
    case Login_baseswiftuiui
    case register_baseswiftui
    
    // 主页面
    case Home_baseswiftuiui
    case Discover_baseswiftuiui
    case messageList_baseswiftui
    case me_baseswiftui
    
    // 帖子
    case postDetail_baseswiftuiui(post_baseswiftui: TitleModel_baseswiftui)
    case release_baseswiftui
    
    // 用户
    case userInfo_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui)
    case EditInfo_baseswiftuiui
    case settings_baseswiftui
    
    // 消息
    case userChat_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui)
    case groupChat_baseswiftui(groupId_baseswiftui: Int)
    case aiChat_baseswiftui
    
    // 媒体
    case mediaPlayer_baseswiftui(mediaUrl_baseswiftui: String)
    
    // 视频通话
    case videoChat_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui)
    
    var id: String {
        switch self {
        case .Login_baseswiftuiui: return "login"
        case .register_baseswiftui: return "register"
        case .Home_baseswiftuiui: return "home"
        case .Discover_baseswiftuiui: return "discover"
        case .messageList_baseswiftui: return "messageList"
        case .me_baseswiftui: return "me"
        case .postDetail_baseswiftuiui(let post): return "postDetail_\(post.titleId_baseswiftui)"
        case .release_baseswiftui: return "release"
        case .userInfo_baseswiftui(let user): return "userInfo_\(user.userId_baseswiftui ?? 0)"
        case .EditInfo_baseswiftuiui: return "editInfo"
        case .settings_baseswiftui: return "settings"
        case .userChat_baseswiftui(let user): return "userChat_\(user.userId_baseswiftui ?? 0)"
        case .groupChat_baseswiftui(let groupId): return "groupChat_\(groupId)"
        case .aiChat_baseswiftui: return "aiChat"
        case .mediaPlayer_baseswiftui(let mediaUrl): return "mediaPlayer_\(mediaUrl.hashValue)"
        case .videoChat_baseswiftui(let user): return "videoChat_\(user.userId_baseswiftui ?? 0)"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Route_baseswiftui, rhs: Route_baseswiftui) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 路由管理器

/// 路由管理器
class Router_baseswiftui: ObservableObject {
    
    static let shared_baseswiftui = Router_baseswiftui()
    
    @Published var navigationPath_baseswiftui = NavigationPath()
    @Published var presentedSheet_baseswiftui: Route_baseswiftui?
    @Published var presentedFullScreen_baseswiftui: Route_baseswiftui?
    @Published var showAlert_baseswiftui = false
    @Published var alertConfig_baseswiftui: AlertConfig_baseswiftui?
    
    private init() {}
    
    // MARK: - 基础导航方法
    
    /// 导航到指定路由
    func navigate_baseswiftui(to route_baseswiftui: Route_baseswiftui) {
        navigationPath_baseswiftui.append(route_baseswiftui)
    }
    
    /// 返回上一页
    func pop_baseswiftui() {
        guard !navigationPath_baseswiftui.isEmpty else { return }
        navigationPath_baseswiftui.removeLast()
    }
    
    /// 返回到根页面
    func popToRoot_baseswiftui() {
        navigationPath_baseswiftui = NavigationPath()
    }
    
    /// 展示Sheet
    func presentSheet_baseswiftui(route_baseswiftui: Route_baseswiftui) {
        presentedSheet_baseswiftui = route_baseswiftui
    }
    
    /// 关闭Sheet
    func dismissSheet_baseswiftui() {
        presentedSheet_baseswiftui = nil
    }
    
    /// 展示全屏页面
    func presentFullScreen_baseswiftui(route_baseswiftui: Route_baseswiftui) {
        presentedFullScreen_baseswiftui = route_baseswiftui
    }
    
    /// 关闭全屏页面
    func dismissFullScreen_baseswiftui() {
        presentedFullScreen_baseswiftui = nil
    }
    
    /// 显示Alert
    func showAlert_baseswiftui(
        title_baseswiftui: String,
        message_baseswiftui: String? = nil,
        primaryButton_baseswiftui: AlertButton_baseswiftui = AlertButton_baseswiftui(title_baseswiftui: "OK", action_baseswiftui: nil),
        secondaryButton_baseswiftui: AlertButton_baseswiftui? = nil
    ) {
        alertConfig_baseswiftui = AlertConfig_baseswiftui(
            title_baseswiftui: title_baseswiftui,
            message_baseswiftui: message_baseswiftui,
            primaryButton_baseswiftui: primaryButton_baseswiftui,
            secondaryButton_baseswiftui: secondaryButton_baseswiftui
        )
        showAlert_baseswiftui = true
    }
    
    // MARK: - 便捷导航方法
    
    func toLogin_baseswiftuiui() {
        presentFullScreen_baseswiftui(route_baseswiftui: .Login_baseswiftuiui)
    }
    
    func toRegister_baseswiftui() {
        navigate_baseswiftui(to: .register_baseswiftui)
    }
    
    func toPostDetail_baseswiftuiui(post_baseswiftui: TitleModel_baseswiftui) {
        navigate_baseswiftui(to: .postDetail_baseswiftuiui(post_baseswiftui: post_baseswiftui))
    }
    
    func toUserInfo_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) {
        navigate_baseswiftui(to: .userInfo_baseswiftui(user_baseswiftui: user_baseswiftui))
    }
    
    func toRelease_baseswiftui() {
        presentFullScreen_baseswiftui(route_baseswiftui: .release_baseswiftui)
    }
    
    func toEditInfo_baseswiftuiui() {
        navigate_baseswiftui(to: .EditInfo_baseswiftuiui)
    }
    
    func toSettings_baseswiftui() {
        navigate_baseswiftui(to: .settings_baseswiftui)
    }
    
    func toUserChat_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) {
        navigate_baseswiftui(to: .userChat_baseswiftui(user_baseswiftui: user_baseswiftui))
    }
    
    func toGroupChat_baseswiftui(groupId_baseswiftui: Int) {
        navigate_baseswiftui(to: .groupChat_baseswiftui(groupId_baseswiftui: groupId_baseswiftui))
    }
    
    func toAIChat_baseswiftui() {
        navigate_baseswiftui(to: .aiChat_baseswiftui)
    }
    
    func toMediaPlayer_baseswiftui(mediaUrl_baseswiftui: String) {
        presentFullScreen_baseswiftui(route_baseswiftui: .mediaPlayer_baseswiftui(mediaUrl_baseswiftui: mediaUrl_baseswiftui))
    }
    
    func toVideoChat_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) {
        presentFullScreen_baseswiftui(route_baseswiftui: .videoChat_baseswiftui(user_baseswiftui: user_baseswiftui))
    }
    
    // MARK: - 视图构建器
    
    @ViewBuilder
    func view_baseswiftui(for route_baseswiftui: Route_baseswiftui) -> some View {
        switch route_baseswiftui {
        case .Login_baseswiftuiui:
            Login_baseswiftui()
        case .register_baseswiftui:
            Register_baseswiftui()
        case .Home_baseswiftuiui:
            Home_baseswiftui()
        case .Discover_baseswiftuiui:
            Discover_baseswiftui()
        case .messageList_baseswiftui:
            MessageList_baseswiftui()
        case .me_baseswiftui:
            Me_baseswiftui()
        case .postDetail_baseswiftuiui(let post):
            Detail_baseswiftui(post_baseswiftui: post)
        case .release_baseswiftui:
            Release_baseswiftui()
        case .userInfo_baseswiftui(let user):
            Prewuser_baseswiftui(user_baseswiftui: user)
        case .EditInfo_baseswiftuiui:
            EditInfo_baseswiftui()
        case .settings_baseswiftui:
            Set_baseswiftui()
        case .userChat_baseswiftui(let user):
            MessageUser_baseswiftui(user_baseswiftui: user)
        case .groupChat_baseswiftui(let groupId):
            MessageUser_baseswiftui(groupId_baseswiftui: groupId)
        case .aiChat_baseswiftui:
            MessageUser_baseswiftui(isAIChat_baseswiftui: true)
        case .mediaPlayer_baseswiftui(let mediaUrl):
            MediaPlayer_baseswiftui(mediaUrl_baseswiftui: mediaUrl)
        case .videoChat_baseswiftui(let user):
            VideoChat_baseswiftui(user_baseswiftui: user)
        }
    }
}

// MARK: - Alert 配置

/// Alert配置
struct AlertConfig_baseswiftui {
    let title_baseswiftui: String
    let message_baseswiftui: String?
    let primaryButton_baseswiftui: AlertButton_baseswiftui
    let secondaryButton_baseswiftui: AlertButton_baseswiftui?
}

/// Alert按钮配置
struct AlertButton_baseswiftui {
    let title_baseswiftui: String
    var role_baseswiftui: ButtonRole? = nil
    let action_baseswiftui: (() -> Void)?
}

// MARK: - 路由容器视图

/// 路由容器视图
struct RouterView_baseswiftui<Content: View>: View {
    
    @ObservedObject var router_baseswiftui: Router_baseswiftui
    let rootView_baseswiftui: Content
    
    init(
        router_baseswiftui: Router_baseswiftui = Router_baseswiftui.shared_baseswiftui,
        @ViewBuilder rootView_baseswiftui: () -> Content
    ) {
        self.router_baseswiftui = router_baseswiftui
        self.rootView_baseswiftui = rootView_baseswiftui()
    }
    
    var body: some View {
        NavigationStack(path: $router_baseswiftui.navigationPath_baseswiftui) {
            rootView_baseswiftui
                .navigationDestination(for: Route_baseswiftui.self) { route in
                    router_baseswiftui.view_baseswiftui(for: route)
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        .sheet(item: $router_baseswiftui.presentedSheet_baseswiftui) { route in
            NavigationStack {
                router_baseswiftui.view_baseswiftui(for: route)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                router_baseswiftui.dismissSheet_baseswiftui()
                            }
                        }
                    }
            }
        }
        .fullScreenCover(item: $router_baseswiftui.presentedFullScreen_baseswiftui) { route in
            NavigationStack {
                router_baseswiftui.view_baseswiftui(for: route)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert(
            router_baseswiftui.alertConfig_baseswiftui?.title_baseswiftui ?? "",
            isPresented: $router_baseswiftui.showAlert_baseswiftui
        ) {
            if let config = router_baseswiftui.alertConfig_baseswiftui {
                Button(config.primaryButton_baseswiftui.title_baseswiftui, role: config.primaryButton_baseswiftui.role_baseswiftui) {
                    config.primaryButton_baseswiftui.action_baseswiftui?()
                }
                
                if let secondary = config.secondaryButton_baseswiftui {
                    Button(secondary.title_baseswiftui, role: secondary.role_baseswiftui) {
                        secondary.action_baseswiftui?()
                    }
                }
            }
        } message: {
            if let message = router_baseswiftui.alertConfig_baseswiftui?.message_baseswiftui {
                Text(message)
            }
        }
    }
}
