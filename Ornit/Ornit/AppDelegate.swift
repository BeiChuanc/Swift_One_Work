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
        Utils_Ornit.setupHUDConfig_Ornit(fontSize_Ornit: 16)
        
        // 初始化本地数据
        LocalData_Ornit.shared_Ornit.initData_Ornit()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Ornit.shared_Ornit.initUser_Ornit()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Ornit.shared_Ornit.initPosts_Ornit()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Ornit.shared_Ornit.initChat_Ornit()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Ornit.setRootToTabbar_Ornit(window: window)
        
        return true
    }

}

