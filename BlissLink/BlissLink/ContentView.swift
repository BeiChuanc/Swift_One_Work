import SwiftUI

// MARK: - 主内容视图

/// 主内容视图
struct ContentView: View {
    
    @State private var selectedTab_blisslink: Int = 0
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    @ObservedObject var titleVM_blisslink = TitleViewModel_blisslink.shared_blisslink
    @ObservedObject var messageVM_blisslink = MessageViewModel_blisslink.shared_blisslink
    @ObservedObject var localData_blisslink = LocalData_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    
    var body: some View {
        RouterView_blisslink {
            ZStack {
                // 页面内容层
                Group {
                    switch selectedTab_blisslink {
                    case 0:
                        Home_baseswift()
                    case 1:
                        Discover_baseswift()
                    case 2:
                        Release_baseswift()
                    case 3:
                        MessageList_baseswift()
                    case 4:
                        Me_baseswift()
                    default:
                        Home_baseswift()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0), value: selectedTab_blisslink)
                
                // 悬浮底部导航栏层
                VStack {
                    Spacer()
                    FloatingTabBar_blisslink(
                        selectedTab_blisslink: $selectedTab_blisslink,
                        onTabSelected_blisslink: handleTabSelected_blisslink
                    )
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            initializeData_blisslink()
        }
    }
    
    // MARK: - 事件处理方法
    
    /// 处理标签选中事件
    private func handleTabSelected_blisslink(index_blisslink: Int) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0)) {
            selectedTab_blisslink = index_blisslink
        }
    }
    
    // MARK: - 初始化方法
    
    /// 初始化所有数据
    private func initializeData_blisslink() {
        localData_blisslink.initData_blisslink()
        userVM_blisslink.initUser_blisslink()
        titleVM_blisslink.initPosts_blisslink()
        messageVM_blisslink.initChat_blisslink()
        
        // 初始化练习数据
        PracticeViewModel_blisslink.shared_blisslink.initPracticeData_blisslink()
    }
}
