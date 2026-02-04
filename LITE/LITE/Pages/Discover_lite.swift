import SwiftUI

// MARK: - 发现页
// 核心作用：展示推荐用户和热门内容
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 发现页
struct Discover_lite: View {
    
    @ObservedObject var localData_lite = LocalData_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Discover")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
