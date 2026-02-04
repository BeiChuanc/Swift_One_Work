import SwiftUI

// MARK: - 帖子详情页
// 核心作用：展示帖子的详细内容、评论和操作
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 帖子详情页
struct Detail_lite: View {
    
    /// 帖子数据
    let post_lite: TitleModel_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Post Detail")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Post Detail",
            onBack_lite: {
                Router_lite.shared_lite.pop_lite()
            }
        )
    }
}
