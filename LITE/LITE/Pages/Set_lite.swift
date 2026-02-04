import SwiftUI

// MARK: - 设置页
// 核心作用：应用设置和偏好配置
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 设置页
struct Set_lite: View {
    
    @ObservedObject var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Settings")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Settings",
            onBack_lite: {
                Router_lite.shared_lite.pop_lite()
            }
        )
    }
}
