import SwiftUI

// MARK: - 个人中心页
// 核心作用：展示当前用户的个人信息和设置
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 个人中心页
struct Me_baseswiftui: View {
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Profile")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
