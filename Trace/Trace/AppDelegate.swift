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
        Utils_Trace.setupHUDConfig_Trace(fontSize_Trace: 16)
        
        // 初始化本地数据
        LocalData_Trace.shared_Trace.initData_Trace()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Trace.shared_Trace.initUser_Trace()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Trace.shared_Trace.initPosts_Trace()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Trace.shared_Trace.initChat_Trace()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Trace.setRootToTabbar_Trace(window: window)
        
        return true
    }

}

