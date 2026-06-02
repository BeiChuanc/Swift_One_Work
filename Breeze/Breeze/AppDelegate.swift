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
        Utils_Breeze.setupHUDConfig_Breeze(fontSize_Breeze: 16)
        
        // 初始化本地数据
        LocalData_Breeze.shared_Breeze.initData_Breeze()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Breeze.shared_Breeze.initUser_Breeze()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Breeze.shared_Breeze.initPosts_Breeze()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Breeze.shared_Breeze.initChat_Breeze()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Breeze.setRootToTabbar_Breeze(window: window)
        
        return true
    }

}

