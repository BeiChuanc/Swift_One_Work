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
        Utils_Somnia.setupHUDConfig_Somnia(fontSize_Somnia: 16)
        
        // 初始化本地数据
        LocalData_Somnia.shared_Somnia.initData_Somnia()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Somnia.shared_Somnia.initUser_Somnia()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Somnia.shared_Somnia.initPosts_Somnia()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Somnia.shared_Somnia.initChat_Somnia()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Somnia.setRootToTabbar_Somnia(window: window)
        
        return true
    }

}

