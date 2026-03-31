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
        Utils_Flick.setupHUDConfig_Flick(fontSize_Flick: 16)
        
        // 初始化本地数据
        LocalData_Flick.shared_Flick.initData_Flick()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Flick.shared_Flick.initUser_Flick()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Flick.shared_Flick.initPosts_Flick()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Flick.shared_Flick.initChat_Flick()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Flick.setRootToTabbar_Flick(window: window)
        
        return true
    }

}

