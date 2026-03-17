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
        Utils_Pane.setupHUDConfig_Pane(fontSize_Pane: 16)
        
        // 初始化本地数据
        LocalData_Pane.shared_Pane.initData_Pane()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Pane.shared_Pane.initUser_Pane()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Pane.shared_Pane.initPosts_Pane()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Pane.shared_Pane.initChat_Pane()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Pane.setRootToTabbar_Pane(window: window)
        
        return true
    }

}

