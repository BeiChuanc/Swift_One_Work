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
        Load_Orna.setupHUDConfig_Orna(fontSize_Orna: 16)
        
        // 初始化本地数据
        LocalData_Orna.shared_Orna.initData_Orna()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Orna.shared_Orna.initUser_Orna()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Orna.shared_Orna.initPosts_Orna()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Orna.shared_Orna.initChat_Orna()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Orna.setRootToTabbar_Orna(window: window)
        
        return true
    }

}
