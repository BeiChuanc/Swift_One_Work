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
        Utils_Doze.setupHUDConfig_Doze(fontSize_Doze: 16)
        
        // 初始化本地数据
        LocalData_Doze.shared_Doze.initData_Doze()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Doze.shared_Doze.initUser_Doze()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Doze.shared_Doze.initPosts_Doze()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Doze.shared_Doze.initChat_Doze()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Doze.setRootToTabbar_Doze(window: window)
        
        return true
    }

}

