import SwiftUI

// MARK: - 发布页
// 核心作用：发布新帖子
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 发布页
struct Release_baseswiftui: View {
    
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Create Post")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Create Post",
            showBackButton_baseswiftui: false, rightButton_baseswiftui:  {
                HStack(spacing: 12) {
                    NavTextButton_baseswiftui(
                        text_baseswiftui: "Cancel",
                        onTapped_baseswiftui: {
                            // 
                        }, textColor_baseswiftui: .gray
                    )
                    
                    NavTextButton_baseswiftui(
                        text_baseswiftui: "Publish",
                        onTapped_baseswiftui: {
                            // 发布操作
                            router_baseswiftui.dismissFullScreen_baseswiftui()
                        }
                    )
                }
            })
    }
}
