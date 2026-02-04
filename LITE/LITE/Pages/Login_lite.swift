import SwiftUI

// MARK: - 登录页
// 核心作用：用户登录界面
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 登录页
struct Login_lite: View {
    
    @ObservedObject var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Login")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Login",
            showBackButton_lite: false, rightButton_lite:  {
                NavIconButton_lite(
                    iconName_lite: "xmark",
                    onTapped_lite: {
                        router_lite.dismissFullScreen_lite()
                    }
                )
            })
    }
}
