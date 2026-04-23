import UIKit
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化键盘管理器
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        // 配置HUD全局样式
        Utils_Nest.setupHUDConfig_Nest(fontSize_Nest: 16)
        
        // 初始化本地数据
        LocalData_Nest.shared_Nest.initData_Nest()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Nest.shared_Nest.initUser_Nest()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Nest.shared_Nest.initPosts_Nest()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Nest.shared_Nest.initChat_Nest()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Nest.setRootToTabbar_Nest(window: window)
        
        return true
    }

}

