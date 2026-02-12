import SwiftUI

// MARK: - 主内容视图

/// 主内容视图
struct ContentView: View {
    
    @State private var selectedTab_platbell: Int = 0
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var messageVM_platbell = MessageViewModel_platbell.shared_platbell
    @ObservedObject var localData_platbell = LocalData_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    var body: some View {
        RouterView_platbell {
            ZStack {
                // 页面内容层
                Group {
                    switch selectedTab_platbell {
                    case 0:
                        Home_platbell()
                    case 1:
                        Discover_platbell()
                    case 2:
                        Release_platbell()
                    case 3:
                        MessageList_platbell()
                    case 4:
                        Me_platbell()
                    default:
                        Home_platbell()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                
                // 悬浮底部导航栏层
                VStack {
                    Spacer()
                    FloatingTabBar_platbell(
                        selectedTab_platbell: $selectedTab_platbell,
                        onTabSelected_platbell: handleTabSelected_platbell
                    )
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            initializeData_platbell()
        }
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签选中事件
    private func handleTabSelected_platbell(index_platbell: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedTab_platbell = index_platbell
        }
    }
    
    // MARK: - 初始化方法
    
    /// 初始化所有数据
    private func initializeData_platbell() {
        localData_platbell.initData_platbell()
        userVM_platbell.initUser_platbell()
        titleVM_platbell.initPosts_platbell()
        messageVM_platbell.initChat_platbell()
    }
}
