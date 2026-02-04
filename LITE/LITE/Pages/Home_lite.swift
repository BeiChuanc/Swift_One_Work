import SwiftUI

// MARK: - 首页
// 核心作用：展示帖子列表和推荐内容
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 首页
struct Home_lite: View {
    
    @ObservedObject var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Home")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
