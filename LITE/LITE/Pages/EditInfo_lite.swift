import SwiftUI

// MARK: - 编辑信息页
// 核心作用：编辑用户个人信息
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 编辑信息页
struct EditInfo_lite: View {
    
    @ObservedObject var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Edit Profile")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Edit Profile",
            onBack_lite: {
                router_lite.pop_lite()
            }
        ) {
            NavTextButton_lite(
                text_lite: "Save",
                onTapped_lite: {
                    // 保存操作
                    router_lite.pop_lite()
                }
            )
        }
    }
}
