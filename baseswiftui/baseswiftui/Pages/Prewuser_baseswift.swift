import SwiftUI

// MARK: - 用户信息页
// 核心作用：展示其他用户的个人信息和帖子
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 用户信息页
struct Prewuser_baseswift: View {
    
    /// 用户数据
    let user_baseswiftui: PrewUserModel_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("User Profile")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: user_baseswiftui.userName_baseswiftui ?? "Profile",
            onBack_baseswiftui: {
                Router_baseswiftui.shared_baseswiftui.pop_baseswiftui()
            }
        ) {
            NavIconButton_baseswiftui(
                iconName_baseswiftui: "ellipsis",
                onTapped_baseswiftui: {
                    // 更多选项
                }
            )
        }
    }
}
