import SwiftUI

// MARK: - 聊天页面
// 核心作用：与用户、群组或AI进行聊天
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 聊天页面
struct MessageUser_lite: View {
    
    /// 用户数据（用于用户聊天）
    var user_lite: PrewUserModel_lite?
    
    /// 群组ID（用于群聊）
    var groupId_lite: Int?
    
    /// 是否是AI聊天
    var isAIChat_lite: Bool = false
    
    /// 聊天标题
    private var chatTitle_lite: String {
        if isAIChat_lite {
            return "AI Assistant"
        } else if let user = user_lite {
            return user.userName_lite ?? "Chat"
        } else if let groupId = groupId_lite {
            return "Group Chat \(groupId)"
        } else {
            return "Chat"
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Chat")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: chatTitle_lite,
            onBack_lite: {
                Router_lite.shared_lite.pop_lite()
            }
        ) {
            NavIconButton_lite(
                iconName_lite: "ellipsis",
                onTapped_lite: {
                    // 更多选项
                }
            )
        }
    }
}
