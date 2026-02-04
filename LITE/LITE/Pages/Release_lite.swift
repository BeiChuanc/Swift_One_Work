import SwiftUI

// MARK: - 发布页
// 核心作用：发布新帖子
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 发布页
struct Release_lite: View {
    
    @ObservedObject var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Create Post")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Create Post",
            showBackButton_lite: false, rightButton_lite:  {
                HStack(spacing: 12) {
                    NavTextButton_lite(
                        text_lite: "Cancel",
                        onTapped_lite: {
                            // 
                        }, textColor_lite: .gray
                    )
                    
                    NavTextButton_lite(
                        text_lite: "Publish",
                        onTapped_lite: {
                            // 发布操作
                            router_lite.dismissFullScreen_lite()
                        }
                    )
                }
            })
    }
}
