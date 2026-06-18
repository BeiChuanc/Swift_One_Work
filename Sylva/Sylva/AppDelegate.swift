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
        Utils_Sylva.setupHUDConfig_Sylva(fontSize_Sylva: 16)
        
        // 初始化本地数据
        LocalData_Sylva.shared_Sylva.initData_Sylva()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Sylva.shared_Sylva.initUser_Sylva()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Sylva.shared_Sylva.initPosts_Sylva()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Sylva.shared_Sylva.initChat_Sylva()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Sylva.setRootToTabbar_Sylva(window: window)
        
        return true
    }

}

