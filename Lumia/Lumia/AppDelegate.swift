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
        Utils_Lumia.setupHUDConfig_Lumia(fontSize_Lumia: 16)
        
        // 初始化本地数据
        LocalData_Lumia.shared_Lumia.initData_Lumia()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Lumia.shared_Lumia.initUser_Lumia()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Lumia.shared_Lumia.initPosts_Lumia()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Lumia.shared_Lumia.initChat_Lumia()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Lumia.setRootToTabbar_Lumia(window: window)
        
        return true
    }

}

