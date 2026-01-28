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
        Utils_Wanderbell.setupHUDConfig_Wanderbell(fontSize_wanderbell: 16)
        
        // 初始化本地数据
        LocalData_Wanderbell.shared_Wanderbell.initData_Wanderbell()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Wanderbell.shared_Wanderbell.initUser_Wanderbell()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Wanderbell.shared_Wanderbell.initPosts_Wanderbell()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Wanderbell.shared_Wanderbell.initChat_Wanderbell()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Wanderbell.setRootToTabbar_Wanderbell(window: window)
        
        return true
    }

}

