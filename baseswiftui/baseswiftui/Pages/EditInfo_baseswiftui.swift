import SwiftUI

// MARK: - 编辑信息页
// 核心作用：编辑用户个人信息
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 编辑信息页
struct EditInfo_baseswiftui: View {
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Edit Profile")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Edit Profile",
            onBack_baseswiftui: {
                router_baseswiftui.pop_baseswiftui()
            }
        ) {
            NavTextButton_baseswiftui(
                text_baseswiftui: "Save",
                onTapped_baseswiftui: {
                    // 保存操作
                    router_baseswiftui.pop_baseswiftui()
                }
            )
        }
    }
}
