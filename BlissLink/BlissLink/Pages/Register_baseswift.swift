import SwiftUI

// MARK: - 注册页
// 核心作用：用户注册界面
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 注册页
struct Register_baseswift: View {
    
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Register")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Register",
            onBack_baseswiftui: {
                router_baseswiftui.pop_baseswiftui()
            }
        )
    }
}
