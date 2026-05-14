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
        Utils_Echd.setupHUDConfig_Echd(fontSize_Echd: 16)
        
        // 初始化本地数据
        LocalData_Echd.shared_Echd.initData_Echd()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Echd.shared_Echd.initUser_Echd()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Echd.shared_Echd.initPosts_Echd()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Echd.shared_Echd.initChat_Echd()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Echd.setRootToTabbar_Echd(window: window)
        
        return true
    }

}

