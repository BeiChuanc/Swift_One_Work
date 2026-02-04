import SwiftUI

// MARK: - 设置页
// 核心作用：应用设置和偏好配置
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 设置页
struct Set_baseswiftui: View {
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Settings")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Settings",
            onBack_baseswiftui: {
                Router_baseswiftui.shared_baseswiftui.pop_baseswiftui()
            }
        )
    }
}
