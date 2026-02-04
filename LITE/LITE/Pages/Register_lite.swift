import SwiftUI

// MARK: - 注册页
// 核心作用：用户注册界面
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 注册页
struct Register_lite: View {
    
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Register")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Register",
            onBack_lite: {
                router_lite.pop_lite()
            }
        )
    }
}
