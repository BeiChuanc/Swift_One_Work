import SwiftUI

// MARK: - 主内容视图

/// 主内容视图
struct ContentView: View {
    
    @State private var selectedTab_baseswiftui: Int = 0
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var messageVM_baseswiftui = MessageViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        RouterView_baseswiftui {
            ZStack {
                // 页面内容层
                Group {
                    switch selectedTab_baseswiftui {
                    case 0:
                        Home_baseswiftui()
                    case 1:
                        Discover_baseswiftui()
                    case 2:
                        Release_baseswiftui()
                    case 3:
                        MessageList_baseswiftui()
                    case 4:
                        Me_baseswiftui()
                    default:
                        Home_baseswiftui()
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
                    FloatingTabBar_baseswiftui(
                        selectedTab_baseswiftui: $selectedTab_baseswiftui,
                        onTabSelected_baseswiftui: handleTabSelected_baseswiftui
                    )
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            initializeData_baseswiftui()
        }
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签选中事件
    private func handleTabSelected_baseswiftui(index_baseswiftui: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedTab_baseswiftui = index_baseswiftui
        }
    }
    
    // MARK: - 初始化方法
    
    /// 初始化所有数据
    private func initializeData_baseswiftui() {
        localData_baseswiftui.initData_baseswiftui()
        userVM_baseswiftui.initUser_baseswiftui()
        titleVM_baseswiftui.initPosts_baseswiftui()
        messageVM_baseswiftui.initChat_baseswiftui()
    }
}
