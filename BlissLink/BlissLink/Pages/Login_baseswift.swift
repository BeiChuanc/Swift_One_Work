import SwiftUI

// MARK: - 登录页
// 核心作用：用户登录界面
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 登录页
struct Login_baseswift: View {
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Login")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Login",
            showBackButton_baseswiftui: false
        ) {
            NavIconButton_baseswiftui(
                iconName_baseswiftui: "xmark",
                onTapped_baseswiftui: {
                    router_baseswiftui.dismissFullScreen_baseswiftui()
                }
            )
        }
    }
}
