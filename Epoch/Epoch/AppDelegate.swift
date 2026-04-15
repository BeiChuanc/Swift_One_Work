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
        Utils_Epoch.setupHUDConfig_Epoch(fontSize_Epoch: 16)
        
        // 初始化本地数据
        LocalData_Epoch.shared_Epoch.initData_Epoch()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Epoch.shared_Epoch.initUser_Epoch()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Epoch.shared_Epoch.initPosts_Epoch()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Epoch.shared_Epoch.initChat_Epoch()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Epoch.setRootToTabbar_Epoch(window: window)
        
        return true
    }

}

