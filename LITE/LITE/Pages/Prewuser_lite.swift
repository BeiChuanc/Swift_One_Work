import SwiftUI

// MARK: - 用户信息页
// 核心作用：展示其他用户的个人信息和帖子
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 用户信息页
struct Prewuser_lite: View {
    
    /// 用户数据
    let user_lite: PrewUserModel_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("User Profile")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: user_lite.userName_lite ?? "Profile",
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
