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
        Utils_Retrs.setupHUDConfig_Retrs(fontSize_Retrs: 16)
        
        // 初始化本地数据
        LocalData_Retrs.shared_Retrs.initData_Retrs()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Retrs.shared_Retrs.initUser_Retrs()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Retrs.shared_Retrs.initPosts_Retrs()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Retrs.shared_Retrs.initChat_Retrs()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Retrs.setRootToTabbar_Retrs(window: window)
        
        return true
    }

}

