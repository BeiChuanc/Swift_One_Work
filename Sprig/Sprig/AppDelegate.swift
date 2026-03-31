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
        Utils_Sprig.setupHUDConfig_Sprig(fontSize_Sprig: 16)
        
        // 初始化本地数据
        LocalData_Sprig.shared_Sprig.initData_Sprig()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Sprig.shared_Sprig.initUser_Sprig()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Sprig.shared_Sprig.initPosts_Sprig()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Sprig.shared_Sprig.initChat_Sprig()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Sprig.setRootToTabbar_Sprig(window: window)
        
        return true
    }

}

