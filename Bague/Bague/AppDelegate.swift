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
        Utils_Bague.setupHUDConfig_Bague(fontSize_Bague: 16)
        
        // 初始化本地数据
        LocalData_Bague.shared_Bague.initData_Bague()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Bague.shared_Bague.initUser_Bague()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Bague.shared_Bague.initPosts_Bague()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Bague.shared_Bague.initChat_Bague()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Bague.setRootToTabbar_Bague(window: window)
        
        return true
    }

}

