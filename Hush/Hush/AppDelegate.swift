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
        Utils_Hush.setupHUDConfig_Hush(fontSize_Hush: 16)
        
        // 初始化本地数据
        LocalData_Hush.shared_Hush.initData_Hush()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Hush.shared_Hush.initUser_Hush()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Hush.shared_Hush.initPosts_Hush()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Hush.shared_Hush.initChat_Hush()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Hush.setRootToTabbar_Hush(window: window)
        
        return true
    }

}

