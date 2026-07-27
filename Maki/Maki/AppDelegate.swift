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
        Load_Maki.setupHUDConfig_Maki(fontSize_Maki: 16)
        
        // 初始化本地数据
        LocalData_Maki.shared_Maki.initData_Maki()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Maki.shared_Maki.initUser_Maki()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Maki.shared_Maki.initPosts_Maki()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Maki.shared_Maki.initChat_Maki()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Maki.setRootToTabbar_Maki(window: window)
        
        return true
    }

}

