import SwiftUI

// MARK: - 主内容视图

/// 主内容视图
struct ContentView: View {
    
    @State private var selectedTab_lite: Int = 0
    @ObservedObject var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject var messageVM_lite = MessageViewModel_lite.shared_lite
    @ObservedObject var localData_lite = LocalData_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        RouterView_lite {
            ZStack {
                // 页面内容层
                Group {
                    switch selectedTab_lite {
                    case 0:
                        Home_lite()
                    case 1:
                        Discover_lite()
                    case 2:
                        Release_lite()
                    case 3:
                        MessageList_lite()
                    case 4:
                        Me_lite()
                    default:
                        Home_lite()
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
                    FloatingTabBar_lite(
                        selectedTab_lite: $selectedTab_lite,
                        onTabSelected_lite: handleTabSelected_lite
                    )
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            initializeData_lite()
        }
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签选中事件
    private func handleTabSelected_lite(index_lite: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedTab_lite = index_lite
        }
    }
    
    // MARK: - 初始化方法
    
    /// 初始化所有数据
    private func initializeData_lite() {
        localData_lite.initData_lite()
        userVM_lite.initUser_lite()
        titleVM_lite.initPosts_lite()
        messageVM_lite.initChat_lite()
    }
}
