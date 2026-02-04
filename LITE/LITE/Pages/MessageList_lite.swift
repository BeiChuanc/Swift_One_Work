import SwiftUI

// MARK: - 消息列表页
// 核心作用：展示所有聊天会话列表
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 消息列表页
struct MessageList_lite: View {
    
    @ObservedObject var messageVM_lite = MessageViewModel_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Messages")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
