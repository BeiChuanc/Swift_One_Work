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
        Utils_Moode.setupHUDConfig_Moode(fontSize_Moode: 16)
        
        // 初始化本地数据
        LocalData_Moode.shared_Moode.initData_Moode()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Moode.shared_Moode.initUser_Moode()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Moode.shared_Moode.initPosts_Moode()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Moode.shared_Moode.initChat_Moode()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Moode.setRootToTabbar_Moode(window: window)
        
        return true
    }

}

