import SwiftUI

// MARK: - 帖子详情页
// 核心作用：展示帖子的详细内容、评论和操作
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 帖子详情页
struct Detail_baseswift: View {
    
    /// 帖子数据
    let post_baseswiftui: TitleModel_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Post Detail")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Post Detail",
            onBack_baseswiftui: {
                Router_baseswiftui.shared_baseswiftui.pop_baseswiftui()
            }
        )
    }
}
