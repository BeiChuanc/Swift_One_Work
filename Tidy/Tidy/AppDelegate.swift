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
        Utils_Tidy.setupHUDConfig_Tidy(fontSize_Tidy: 16)
        
        // 初始化本地数据
        LocalData_Tidy.shared_Tidy.initData_Tidy()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Tidy.shared_Tidy.initUser_Tidy()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Tidy.shared_Tidy.initPosts_Tidy()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Tidy.shared_Tidy.initChat_Tidy()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Tidy.setRootToTabbar_Tidy(window: window)
        
        return true
    }

}

